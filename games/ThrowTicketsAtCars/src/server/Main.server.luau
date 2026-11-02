--!strict
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Config = require(RS.ThrowTickets.Config)
local Rules = require(RS.ThrowTickets.Rules)
local Aim = require(RS.ThrowTickets.Aim)
local World = require(script.Parent.World)

assert(#Config.Tiers == 5 and Config.ParkingSlots > 0 and Config.TickSeconds > 0)
for _,tier in Config.Tiers do assert(tier.Distance > 0 and tier.Income > 0) end
local world = World.build()
local remotes = Instance.new("Folder")
remotes.Name, remotes.Parent = "Remotes", RS.ThrowTickets
local function remote(name: string): RemoteEvent
	local r = Instance.new("RemoteEvent")
	r.Name, r.Parent = name, remotes
	return r
end
local Throw, Train, Feedback, Ticket = remote("Throw"), remote("Train"), remote("Feedback"), remote("Ticket")
type State = {slots: {boolean}, folder: Folder, positions: {Vector3}, income: number, lastThrow: number, lastRequest: number, lastTrain: number, plot: number}
type Car = {model: Model, tier: number, position: Vector3, id: string, claimed: boolean}
local states: {[Player]: State} = {}
local cars: {[string]: Car} = {}
local plots: {[number]: boolean} = {}
local serial = 0

local function result(p: Player, text: string)
	p:SetAttribute("LastResult", text)
	Feedback:FireClient(p, text)
end
local function liveRoot(p: Player): BasePart?
	local character = p.Character
	local hum = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if hum and hum.Health > 0 and root and root:IsA("BasePart") then return root end
	return nil
end
local function spawnCar(tier: number, position: Vector3)
	serial += 1
	local id = "Car" .. serial
	local model = World.car(world.Cars, id, tier, position)
	model:SetAttribute("CarId", id)
	model:SetAttribute("Tier", tier)
	model:SetAttribute("Claimed", false)
	cars[id] = {id = id, model = model, tier = tier, position = position, claimed = false}
end
for tier,data in Config.Tiers do
	for _,x in Config.CarLanes do spawnCar(tier, Vector3.new(x, Config.CarHeight, -data.Distance)) end
end

local function tweenPivot(model: Model, destination: CFrame, duration: number)
	local pivot = Instance.new("CFrameValue")
	pivot.Value = model:GetPivot()
	local c = pivot.Changed:Connect(function(value) if model.Parent then model:PivotTo(value) end end)
	local tween = TweenService:Create(pivot, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Value = destination})
	tween:Play()
	tween.Completed:Wait()
	c:Disconnect()
	pivot:Destroy()
end

local function deliver(p: Player, state: State, car: Car, slot: number)
	task.wait(Config.TicketFlightSeconds)
	if states[p] ~= state then return end
	local tow = Instance.new("Model")
	tow.Name = "Tow_" .. car.id
	tow:SetAttribute("OwnerId", p.UserId)
	local body = World.part(tow, "Flatbed", Config.TowSize, car.position + Config.TowStartOffset, Color3.fromRGB(80, 80, 80))
	body.CanCollide = false
	tow.PrimaryPart, tow.Parent = body, world.Tows
	tweenPivot(tow, CFrame.new(car.position + Config.TowApproachOffset), Config.TowApproachSeconds)
	if states[p] ~= state then tow:Destroy(); return end
	tow:SetAttribute("Phase", "Hook")
	task.wait(Config.TowLoadSeconds)
	car.model:PivotTo(tow:GetPivot() + Vector3.new(0, Config.TowLoadHeight, 0))
	car.model.Parent = tow
	tow:SetAttribute("Phase", "Return")
	-- Respawn starts when the source car is actually picked up, not on hit.
	cars[car.id] = nil
	task.delay(Config.RespawnSeconds, function() spawnCar(car.tier, car.position) end)
	tweenPivot(tow, CFrame.new(state.positions[slot] - Vector3.new(0, Config.TowLoadHeight, 0)), Config.TowReturnSeconds)
	if states[p] == state then
		car.model.Parent = state.folder
		car.model:PivotTo(CFrame.new(state.positions[slot]))
		car.model:SetAttribute("Parked", true)
		p:SetAttribute("LastDeliverySeconds", workspace:GetServerTimeNow() - car.model:GetAttribute("ClaimedAt"))
		local mark = car.model:FindFirstChild("Ticketed")
		if mark then mark:Destroy() end
		state.income += Config.Tiers[car.tier].Income
		p:SetAttribute("Income", state.income)
		p:SetAttribute("Delivered", (p:GetAttribute("Delivered") or 0) + 1)
		result(p, string.format("Delivered! +$%d / s", Config.Tiers[car.tier].Income))
	end
	tow:Destroy()
end

Throw.OnServerEvent:Connect(function(p: Player, ...: any)
	local state = states[p]
	if not state then return end
	local now = os.clock()
	if now - state.lastRequest < Config.RequestInterval then return end
	state.lastRequest = now
	if select("#", ...) ~= 2 then return end
	local viewOrigin, direction = ...
	if not Rules.finiteVector(viewOrigin) or not Rules.finiteVector(direction) then return end
	if direction.Magnitude < 0.99 or direction.Magnitude > 1.01 then return end
	if now - state.lastThrow < Config.ThrowCooldown then return end
	local root = liveRoot(p)
	if not root or not Aim.validOrigin(viewOrigin, root.Position) then return end
	if not Rules.inBox(root.Position, Config.LaunchCenter, Config.LaunchHalfX, Config.LaunchHalfZ, Config.LaunchHeightTolerance) then
		result(p, "Stand on the THROW line!"); return
	end
	state.lastThrow = now
	local origin = root.Position
	local power = p:GetAttribute("ThrowPower") :: number
	-- Server independently chooses the car under the validated camera ray.
	local model = Aim.choose(world.Cars, viewOrigin, direction)
	local car = model and cars[model:GetAttribute("CarId")]
	local aimPoint = if car then Aim.point(car.model) else viewOrigin + direction * Config.AimMaxDistance
	local delta = aimPoint - origin
	if delta.Magnitude < 0.001 then return end
	local flightEnd = origin + delta.Unit * math.min(delta.Magnitude, power)
	local function miss(text: string)
		Ticket:FireAllClients(origin, flightEnd, nil, p.UserId, 0)
		result(p, text)
	end
	p:SetAttribute("Throws", (p:GetAttribute("Throws") or 0) + 1)
	if not car or car.claimed or car.model.Parent ~= world.Cars then miss("Aim at a car!"); return end
	local body = car.model.PrimaryPart :: BasePart
	if not Rules.canReach(origin, body.Position, power) then miss("Too far! TRAIN for more power."); return end
	local slot = Rules.firstFree(state.slots, Config.ParkingSlots)
	if not slot then miss("Parking full!"); return end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = {world.Cars}
	local previous = origin
	for step = 1,Config.TicketArcSegments do
		local point = Rules.arcPoint(origin, aimPoint, step / Config.TicketArcSegments, Config.TicketArcHeight)
		local hit = workspace:Raycast(previous, point - previous, params)
		if hit then
			if not hit.Instance:IsDescendantOf(car.model) then miss("Another car is in the way!"); return end
			break
		end
		previous = point
	end
	-- Synchronous reservation. Cosmetic animation never decides ownership or income.
	car.claimed, state.slots[slot] = true, true
	car.model:SetAttribute("Claimed", true)
	car.model:SetAttribute("OwnerId", p.UserId)
	car.model:SetAttribute("ClaimedAt", workspace:GetServerTimeNow())
	p:SetAttribute("ParkingUsed", (p:GetAttribute("ParkingUsed") or 0) + 1)
	Ticket:FireAllClients(origin, aimPoint, car.model, p.UserId, Config.Tiers[car.tier].Income)
	result(p, "Ticket on the way!")
	task.spawn(deliver, p, state, car, slot)
end)

Train.OnServerEvent:Connect(function(p: Player, ...: any)
	local s = states[p]
	if not s then return end
	local now = os.clock()
	if now - s.lastTrain < Config.TrainRequestInterval then return end
	s.lastTrain = now
	if select("#", ...) ~= 1 then return end
	local enabled = ...
	if typeof(enabled) ~= "boolean" or not liveRoot(p) then return end
	p:SetAttribute("Training", enabled)
end)

local function joined(p: Player)
	local plot = 1
	while plots[plot] do plot += 1 end
	plots[plot] = true
	local folder, positions = World.parking(world, plot, p.UserId, p.DisplayName)
	states[p] = {slots = {}, folder = folder, positions = positions, income = 0, lastThrow = -math.huge, lastRequest = -math.huge, lastTrain = -math.huge, plot = plot}
	for name,value in {ThrowPower = Config.StartPower, Income = 0, ParkingUsed = 0, Delivered = 0, Throws = 0} do p:SetAttribute(name, value) end
	p:SetAttribute("Training", false)
	local stats = Instance.new("Folder")
	stats.Name, stats.Parent = "leaderstats", p
	local cash = Instance.new("IntValue")
	cash.Name, cash.Parent = "Cash", stats
	local function characterAdded(character: Model)
		p:SetAttribute("Training", false)
		local root = character:WaitForChild("HumanoidRootPart") :: BasePart
		root.CFrame = CFrame.lookAt(Config.SpawnPosition + Vector3.new(0, Config.SpawnLift, 0), Config.CameraLookAt)
	end
	p.CharacterAdded:Connect(characterAdded)
	if p.Character then task.spawn(characterAdded, p.Character) end
end
Players.PlayerAdded:Connect(joined)
for _,p in Players:GetPlayers() do joined(p) end
Players.PlayerRemoving:Connect(function(p)
	local s = states[p]
	states[p] = nil
	if s then plots[s.plot] = nil; s.folder:Destroy() end
	for _,car in cars do
		if car.claimed and car.model:GetAttribute("OwnerId") == p.UserId then
			cars[car.id] = nil
			car.model:Destroy()
			task.delay(Config.RespawnSeconds, function() spawnCar(car.tier, car.position) end)
		end
	end
	for _,tow in world.Tows:GetChildren() do if tow:GetAttribute("OwnerId") == p.UserId then tow:Destroy() end end
end)

task.spawn(function()
	while true do
		task.wait(Config.TickSeconds)
		for p,s in states do
			p.leaderstats.Cash.Value += s.income
			local root = liveRoot(p)
			local onPad = root and Rules.inBox(root.Position, Config.TrainingPosition, Config.TrainingRadius, Config.TrainingRadius, Config.TrainingHeightTolerance)
			local training = root ~= nil and (p:GetAttribute("Training") == true or onPad == true)
			p:SetAttribute("TrainingActive", training)
			if training then p:SetAttribute("ThrowPower", p:GetAttribute("ThrowPower") + Config.TrainGain) end
		end
	end
end)
print("[ThrowTickets] Prototype ready; no persistence.")

--!strict
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Config = require(RS.ThrowTickets.Config)
local Rules = require(RS.ThrowTickets.Rules)
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
	local tow = Instance.new("Model")
	tow.Name = "Tow_" .. car.id
	tow:SetAttribute("OwnerId", p.UserId)
	local body = World.part(tow, "Flatbed", Config.TowSize, car.position + Config.TowStartOffset, Color3.fromRGB(80, 80, 80))
	body.CanCollide = false
	tow.PrimaryPart, tow.Parent = body, world.Tows
	tweenPivot(tow, CFrame.new(car.position + Config.TowApproachOffset), Config.TowApproachSeconds)
	if states[p] ~= state then tow:Destroy(); return end
	task.wait(Config.TowLoadSeconds)
	car.model:PivotTo(tow:GetPivot() + Vector3.new(0, Config.TowLoadHeight, 0))
	car.model.Parent = tow
	-- Respawn starts when the source car is actually picked up, not on hit.
	cars[car.id] = nil
	task.delay(Config.RespawnSeconds, function() spawnCar(car.tier, car.position) end)
	tweenPivot(tow, CFrame.new(state.positions[slot] - Vector3.new(0, Config.TowLoadHeight, 0)), Config.TowReturnSeconds)
	if states[p] == state then
		car.model.Parent = state.folder
		car.model:PivotTo(CFrame.new(state.positions[slot]))
		car.model:SetAttribute("Parked", true)
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
	local id, direction = ...
	if typeof(id) ~= "string" or #id > 32 or not Rules.finiteVector(direction) then return end
	if direction.Magnitude < 0.99 or direction.Magnitude > 1.01 then return end
	if now - state.lastThrow < Config.ThrowCooldown then return end
	local root = liveRoot(p)
	if not root then return end
	if not Rules.inBox(root.Position, Config.LaunchCenter, Config.LaunchHalfX, Config.LaunchHalfZ, Config.LaunchHeightTolerance) then
		result(p, "Stand on the THROW line!"); return
	end
	state.lastThrow = now
	local origin = root.Position
	local power = p:GetAttribute("ThrowPower") :: number
	local car = cars[id]
	if not car or car.claimed or car.model.Parent ~= world.Cars then
		Ticket:FireAllClients(origin, origin + direction * power)
		result(p, "Aim at a car!"); return
	end
	local body = car.model.PrimaryPart :: BasePart
	local delta = body.Position - origin
	if delta.Unit:Dot(direction) < Config.AimConeDot then result(p, "Miss!"); return end
	p:SetAttribute("Throws", (p:GetAttribute("Throws") or 0) + 1)
	local flightEnd = if delta.Magnitude <= power then body.Position else origin + delta.Unit * power
	-- Only known, server-built endpoints are relayed.
	Ticket:FireAllClients(origin, flightEnd)
	if not Rules.canReach(origin, body.Position, power) then result(p, "Too far! TRAIN for more power."); return end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = {world.Cars}
	local previous = origin
	for step = 1,Config.TicketArcSegments do
		local point = Rules.arcPoint(origin, body.Position, step / Config.TicketArcSegments, Config.TicketArcHeight)
		local hit = workspace:Raycast(previous, point - previous, params)
		if hit then
			if not hit.Instance:IsDescendantOf(car.model) then result(p, "Another car is in the way!"); return end
			break
		end
		previous = point
	end
	local slot = Rules.firstFree(state.slots, Config.ParkingSlots)
	if not slot then result(p, "Parking full!"); return end
	-- No yielding between availability checks, claim and reservation.
	car.claimed, state.slots[slot] = true, true
	car.model:SetAttribute("Claimed", true)
	car.model:SetAttribute("OwnerId", p.UserId)
	local mark = Instance.new("Highlight")
	mark.Name, mark.FillColor, mark.OutlineColor = "Ticketed", Color3.new(1, 0, 0), Color3.new(1, 0, 0)
	mark.FillTransparency, mark.Adornee, mark.Parent = 0.5, car.model, car.model
	p:SetAttribute("ParkingUsed", (p:GetAttribute("ParkingUsed") or 0) + 1)
	result(p, "Ticketed! Tow on the way.")
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

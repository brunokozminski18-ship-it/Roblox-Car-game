--!strict
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Config = require(RS.ThrowTickets.Config)
local Rules = require(RS.ThrowTickets.Rules)
local p = Players.LocalPlayer
local remotes = RS.ThrowTickets:WaitForChild("Remotes")
local Throw = remotes:WaitForChild("Throw") :: RemoteEvent
local Train = remotes:WaitForChild("Train") :: RemoteEvent
local Feedback = remotes:WaitForChild("Feedback") :: RemoteEvent
local Ticket = remotes:WaitForChild("Ticket") :: RemoteEvent
local world = workspace:WaitForChild("TicketPrototype")
local cars = world:WaitForChild("Cars")
local cash = p:WaitForChild("leaderstats"):WaitForChild("Cash") :: IntValue

local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn = "TicketHUD", false
gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 10
gui.Parent = p:WaitForChild("PlayerGui")
local function label(name: string, size: UDim2, pos: UDim2, text: string): TextLabel
	local t = Instance.new("TextLabel")
	t.Name, t.Size, t.Position = name, size, pos
	t.Text, t.TextSize, t.Font = text, 18, Enum.Font.GothamBold
	t.TextColor3, t.BackgroundColor3 = Color3.new(1, 1, 1), Color3.fromRGB(35, 35, 35)
	t.BackgroundTransparency, t.BorderSizePixel = 0.2, 0
	t.Parent = gui
	return t
end
local stats = label("Stats", UDim2.new(0.56, 0, 0, 36), UDim2.new(0.22, 0, 0, 4), "")
local targetText = label("Target", UDim2.new(0.66, 0, 0, 30), UDim2.new(0.17, 0, 0, 44), "Aim at a car")
targetText.TextSize = 16
local message = label("Message", UDim2.new(0.72, 0, 0, 30), UDim2.new(0.14, 0, 1, -38), "Stand on the THROW line. Aim with the camera.")
message.TextSize = 16
local crosshair = label("Crosshair", UDim2.fromOffset(22, 22), UDim2.fromScale(0.5, 0.48), "+")
crosshair.AnchorPoint, crosshair.BackgroundTransparency = Vector2.new(0.5, 0.5), 1
crosshair.TextSize = 28
local function button(name: string, size: Vector2, pos: UDim2): TextButton
	local b = Instance.new("TextButton")
	b.Name, b.Text, b.Size, b.Position = name, name:upper(), UDim2.fromOffset(size.X, size.Y), pos
	b.AnchorPoint = Vector2.new(1, 1)
	b.Font, b.TextSize = Enum.Font.GothamBold, 24
	b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(205, 205, 205), Color3.fromRGB(25, 25, 25)
	b.BorderSizePixel = 2
	b.Parent = gui
	return b
end
-- Above the default jump button; bottom-left stays clear for the joystick.
local throwButton = button("Throw", Vector2.new(132, 68), UDim2.new(1, -16, 1, -103))
local trainButton = button("Train", Vector2.new(132, 50), UDim2.new(1, -16, 1, -181))
trainButton.TextSize = 19
local function responsive()
	local height = gui.AbsoluteSize.Y
	local compact = height < 400
	throwButton.Size = UDim2.fromOffset(if compact then 110 else 132, if compact then 56 else 68)
	trainButton.Size = UDim2.fromOffset(if compact then 110 else 132, 44)
	throwButton.Position = UDim2.new(1, -12, 1, -90)
	trainButton.Position = UDim2.new(1, -12, 1, if compact then -154 else -168)
	stats.TextSize = if compact then 15 else 18
end
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(responsive)
responsive()

local selected = Instance.new("Highlight")
selected.Name, selected.FillTransparency = "AimHighlight", 1
selected.OutlineColor, selected.Parent = Color3.new(1, 1, 1), workspace
local function target(origin: Vector3, direction: Vector3): Model?
	local best: Model? = nil
	local bestScore = Config.AimConeDot
	for _,car in cars:GetChildren() do
		if car:IsA("Model") and car.PrimaryPart and not car:GetAttribute("Claimed") then
			local delta = car.PrimaryPart.Position + Vector3.new(0, Config.RoofOffset, 0) - origin
			local dot = delta.Unit:Dot(direction)
			if delta.Magnitude <= Config.AimMaxDistance and dot > bestScore then
				bestScore, best = dot, car
			end
		end
	end
	return best
end
local function centerTarget(): Model?
	local camera = workspace.CurrentCamera
	if not camera then return nil end
	local pos = crosshair.AbsolutePosition + crosshair.AbsoluteSize / 2
	local ray = camera:ScreenPointToRay(pos.X, pos.Y)
	return target(ray.Origin, ray.Direction)
end

local lastThrow = -math.huge
local function throw(car: Model?)
	if os.clock() - lastThrow < Config.ThrowCooldown then return end
	lastThrow = os.clock()
	throwButton.Text = "THROW!"
	task.delay(Config.RequestInterval, function() throwButton.Text = "THROW" end)
	local character = p.Character
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then return end
	if car and car.PrimaryPart then
		Throw:FireServer(car:GetAttribute("CarId"), (car.PrimaryPart.Position - root.Position).Unit)
	else
		Throw:FireServer("", workspace.CurrentCamera.CFrame.LookVector)
	end
end
throwButton.Activated:Connect(function() throw(centerTarget()) end)
trainButton.Activated:Connect(function() Train:FireServer(not p:GetAttribute("Training")) end)
UIS.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local ray = workspace.CurrentCamera:ScreenPointToRay(input.Position.X, input.Position.Y)
		throw(target(ray.Origin, ray.Direction))
	end
end)

local messageVersion = 0
Feedback.OnClientEvent:Connect(function(text: string)
	messageVersion += 1
	local version = messageVersion
	message.Text = text
	task.delay(Config.MessageSeconds, function()
		if version == messageVersion then message.Text = "Aim with the camera. THROW at a car. TRAIN to reach farther." end
	end)
end)

Ticket.OnClientEvent:Connect(function(origin: Vector3, destination: Vector3)
	local ticket = Instance.new("Part")
	ticket.Name, ticket.Size = "FlyingTicket", Config.TicketSize
	ticket.Anchored, ticket.CanCollide, ticket.CanQuery = true, false, false
	ticket.Color, ticket.Material = Color3.fromRGB(255, 250, 205), Enum.Material.SmoothPlastic
	ticket.Parent = workspace
	Debris:AddItem(ticket, Config.TicketFlightSeconds + Config.MessageSeconds)
	local elapsed = 0
	local connection: RBXScriptConnection
	connection = RunService.RenderStepped:Connect(function(dt)
		elapsed += dt
		local t = math.min(1, elapsed / Config.TicketFlightSeconds)
		local pos = Rules.arcPoint(origin, destination, t, Config.TicketArcHeight)
		ticket.CFrame = CFrame.new(pos) * CFrame.Angles(0, t * math.pi * 2, 0)
		if t >= 1 then connection:Disconnect(); ticket:Destroy() end
	end)
end)

local function updateStats()
	stats.Text = string.format("POWER %d   |   $%d   |   %d/%d CARS", p:GetAttribute("ThrowPower") or 0, cash.Value, p:GetAttribute("ParkingUsed") or 0, Config.ParkingSlots)
	trainButton.Text = if p:GetAttribute("Training") then "TRAIN: ON" else "TRAIN +1/s"
end
for _,attr in {"ThrowPower", "ParkingUsed", "Training"} do p:GetAttributeChangedSignal(attr):Connect(updateStats) end
cash.Changed:Connect(updateStats)
updateStats()
local initial = CFrame.lookAt(Config.CameraOffset, Config.CameraLookAt)
local pitch, yaw = initial:ToOrientation()
local dragging = false
local aimTouch: InputObject? = nil
UIS.InputBegan:Connect(function(input, processed)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then dragging = true end
	if input.UserInputType == Enum.UserInputType.Touch and not processed then aimTouch = input end
end)
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then dragging = false end
	if input == aimTouch then aimTouch = nil end
end)
UIS.InputChanged:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.MouseMovement and dragging) or input == aimTouch then
		yaw -= input.Delta.X * Config.CameraSensitivity
		pitch = math.clamp(pitch - input.Delta.Y * Config.CameraSensitivity, Config.CameraPitchMin, Config.CameraPitchMax)
	end
end)
RunService:BindToRenderStep("TicketCamera", Enum.RenderPriority.Camera.Value + 1, function()
	local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if root then
		local camera = workspace.CurrentCamera
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = CFrame.new(root.Position + Config.CameraOffset) * CFrame.fromOrientation(pitch, yaw, 0)
	end
end)
local accumulator = 0
RunService.RenderStepped:Connect(function(dt)
	accumulator += dt
	if accumulator < Config.RequestInterval then return end
	accumulator = 0
	local car = centerTarget()
	selected.Adornee = car
	if car and car.PrimaryPart then
		local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		local distance = if root then math.ceil((car.PrimaryPart.Position - root.Position).Magnitude) else 0
		local tier = Config.Tiers[car:GetAttribute("Tier")]
		local reachable = distance <= (p:GetAttribute("ThrowPower") or 0)
		selected.OutlineColor = if reachable then Color3.fromRGB(120, 255, 140) else Color3.fromRGB(255, 110, 90)
		targetText.Text = string.format("%d studs  |  $%d / s  |  %s", distance, tier.Income, if reachable then "THROW!" else "TRAIN for more power")
	else targetText.Text = "Aim at a car with the +" end
end)

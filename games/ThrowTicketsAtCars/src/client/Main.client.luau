--!strict
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local Config = require(RS.ThrowTickets.Config)
local Aim = require(RS.ThrowTickets.Aim)
local Effects = require(script.Parent.Effects)
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
gui.ZIndexBehavior, gui.DisplayOrder = Enum.ZIndexBehavior.Sibling, 10
gui.Parent = p:WaitForChild("PlayerGui")
local function label(name: string, size: UDim2, pos: UDim2, text: string): TextLabel
	local t = Instance.new("TextLabel")
	t.Name, t.Size, t.Position = name, size, pos
	t.Text, t.TextSize, t.Font = text, 22, Enum.Font.GothamBold
	t.TextColor3, t.BackgroundColor3 = Color3.new(1, 1, 1), Color3.fromRGB(30, 34, 40)
	t.BackgroundTransparency, t.BorderSizePixel = 0.1, 0
	t.Active = false
	t.Parent = gui
	return t
end
local cashLabel = label("Cash", UDim2.fromOffset(174, 42), UDim2.new(0.5, -178, 0, 4), "")
local powerLabel = label("Power", UDim2.fromOffset(174, 42), UDim2.new(0.5, 4, 0, 4), "")
cashLabel.TextColor3, powerLabel.TextColor3 = Color3.fromRGB(142, 255, 160), Color3.fromRGB(145, 210, 255)
local targetText = label("Target", UDim2.fromOffset(330, 26), UDim2.new(0.5, 0, 0, 50), "Aim at a car")
targetText.AnchorPoint, targetText.TextSize = Vector2.new(0.5, 0), 16
local message = label("Message", UDim2.new(0.68, 0, 0, 26), UDim2.new(0.16, 0, 1, -30), "Aim with the camera. THROW!")
message.TextSize = 15
local crosshair = label("Crosshair", UDim2.fromOffset(24, 24), UDim2.fromOffset(0, 0), "+")
crosshair.AnchorPoint, crosshair.BackgroundTransparency = Vector2.new(0.5, 0.5), 1
crosshair.TextSize, crosshair.TextStrokeTransparency = 30, 0.25
local function button(name: string, size: Vector2, pos: UDim2): TextButton
	local b = Instance.new("TextButton")
	b.Name, b.Text, b.Size, b.Position = name, name:upper(), UDim2.fromOffset(size.X, size.Y), pos
	b.AnchorPoint = Vector2.new(1, 1)
	b.Font, b.TextSize = Enum.Font.GothamBlack, 23
	b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(225, 230, 235), Color3.fromRGB(25, 30, 38)
	b.BorderSizePixel, b.Parent = 2, gui
	return b
end
local throwButton = button("Throw", Vector2.new(110, 62), UDim2.new(1, -12, 1, -98))
local trainButton = button("Train", Vector2.new(110, 44), UDim2.new(1, -12, 1, -170))
trainButton.TextSize = 17
local function responsive()
	local compact = gui.AbsoluteSize.Y < 400
	cashLabel.TextSize, powerLabel.TextSize = if compact then 22 else 28, if compact then 22 else 28
	local width = if compact then 174 else 210
	cashLabel.Size, powerLabel.Size = UDim2.fromOffset(width, 42), UDim2.fromOffset(width, 42)
	cashLabel.Position = UDim2.new(0.5, -width - 4, 0, 4)
	powerLabel.Position = UDim2.new(0.5, 4, 0, 4)
end
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(responsive)
responsive()

local selected = Instance.new("Highlight")
selected.Name, selected.FillTransparency, selected.Parent = "AimHighlight", 1, workspace
local lastThrow = -math.huge
local function throw()
	if os.clock() - lastThrow < Config.ThrowCooldown then return end
	local camera = workspace.CurrentCamera
	if not camera then return end
	lastThrow = os.clock()
	throwButton.Text, throwButton.BackgroundColor3 = "THROW!", Color3.fromRGB(255, 224, 110)
	task.delay(Config.RequestInterval, function()
		throwButton.Text, throwButton.BackgroundColor3 = "THROW", Color3.fromRGB(225, 230, 235)
	end)
	local ray = Aim.centerRay(camera)
	Throw:FireServer(ray.Origin, ray.Direction)
end
throwButton.Activated:Connect(throw)
trainButton.Activated:Connect(function() Train:FireServer(not p:GetAttribute("Training")) end)
UIS.InputBegan:Connect(function(input, processed)
	if not processed and input.UserInputType == Enum.UserInputType.MouseButton1 then throw() end
end)

local messageVersion = 0
Feedback.OnClientEvent:Connect(function(text: string)
	messageVersion += 1
	local version = messageVersion
	message.Text = text
	task.delay(Config.MessageSeconds, function()
		if version == messageVersion then message.Text = "Aim at a car. THROW! TRAIN to reach farther." end
	end)
end)
Ticket.OnClientEvent:Connect(function(origin: Vector3, destination: Vector3, car: Model?, _owner: number, income: number)
	Effects.flight(origin, destination, car, income)
end)
Effects.watchParking(world:WaitForChild("Parking"))
Effects.watchTows(world:WaitForChild("Tows"))

local previousPower = p:GetAttribute("ThrowPower") or Config.StartPower
local function updateStats()
	cashLabel.Text = string.format("CASH  $%d", cash.Value)
	powerLabel.Text = string.format("POWER  %d", p:GetAttribute("ThrowPower") or 0)
	trainButton.Text = if p:GetAttribute("Training") then "TRAIN: ON" else string.format("TRAIN +%d", Config.TrainGain)
end
p:GetAttributeChangedSignal("ThrowPower"):Connect(function()
	local power = p:GetAttribute("ThrowPower") or 0
	local gain = power - previousPower
	previousPower = power
	updateStats()
	local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if gain > 0 and root then Effects.popup(root, string.format("+%d Power", gain), Color3.fromRGB(140, 210, 255), "PowerPopup") end
end)
for _,attr in {"Training", "ParkingUsed"} do p:GetAttributeChangedSignal(attr):Connect(updateStats) end
cash.Changed:Connect(updateStats)
updateStats()

-- PlayerModule alone owns orbit, mouse capture, pinch/wheel zoom and input.
local function restoreCamera(character: Model)
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	local root = character:WaitForChild("HumanoidRootPart") :: BasePart
	local camera = workspace.CurrentCamera
	p.CameraMode = Enum.CameraMode.Classic
	p.CameraMinZoomDistance, p.CameraMaxZoomDistance = Config.CameraMinZoom, Config.CameraMaxZoom
	UIS.MouseBehavior = Enum.MouseBehavior.Default
	humanoid.CameraOffset = Config.CameraFocusOffset
	camera.CameraSubject = humanoid
	camera.CFrame = CFrame.lookAt(root.Position + Config.CameraStartOffset, root.Position)
	camera.CameraType = Enum.CameraType.Custom
end
p.CharacterAdded:Connect(restoreCamera)
if p.Character then task.spawn(restoreCamera, p.Character) end
local accumulator = 0
RunService.RenderStepped:Connect(function(dt)
	local camera = workspace.CurrentCamera
	if not camera then return end
	-- GUI coordinates account for the top bar; the ray uses the true viewport centre.
	local inset = GuiService:GetGuiInset()
	crosshair.Position = UDim2.fromOffset(camera.ViewportSize.X / 2 - inset.X, camera.ViewportSize.Y / 2 - inset.Y)
	accumulator += dt
	if accumulator < Config.RequestInterval then return end
	accumulator = 0
	local ray = Aim.centerRay(camera)
	local car = Aim.choose(cars, ray.Origin, ray.Direction)
	selected.Adornee = car
	if car and car.PrimaryPart then
		local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
		local distance = if root then math.ceil((car.PrimaryPart.Position - root.Position).Magnitude) else 0
		local tier = Config.Tiers[car:GetAttribute("Tier")]
		local reachable = distance <= (p:GetAttribute("ThrowPower") or 0)
		selected.OutlineColor = if reachable then Color3.fromRGB(120, 255, 140) else Color3.fromRGB(255, 110, 90)
		targetText.Text = string.format("%d studs | $%d/s | %s", distance, tier.Income, if reachable then "THROW!" else "TOO FAR")
	else targetText.Text = string.format("Aim at a car | PARKING %d/%d", p:GetAttribute("ParkingUsed") or 0, Config.ParkingSlots) end
end)

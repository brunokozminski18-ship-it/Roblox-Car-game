--!strict
-- Cosmetic only: never changes server state, cash, power, ownership or hit decisions.
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")
local Config = require(RS.ThrowTickets.Config)
local Rules = require(RS.ThrowTickets.Rules)
local Effects = {}
local overlay = Instance.new("ScreenGui")
overlay.Name, overlay.ResetOnSpawn, overlay.DisplayOrder = "TicketFXOverlay", false, 20
overlay.ScreenInsets = Enum.ScreenInsets.None
overlay.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local folder = Instance.new("Folder")
folder.Name, folder.Parent = "TicketClientFX", workspace
local sound = Instance.new("Sound")
sound.Name, sound.SoundId = "TicketImpactTemplate", Config.ImpactSound
sound.Volume, sound.PlaybackSpeed, sound.Parent = Config.ImpactVolume, Config.ImpactPitch, SoundService
task.spawn(function() ContentProvider:PreloadAsync({sound}) end)

local function animate(seconds: number, update: (number) -> (), complete: (() -> ())?)
	local elapsed = 0
	local connection: RBXScriptConnection
	connection = RunService.RenderStepped:Connect(function(dt)
		elapsed += dt
		local t = math.min(1, elapsed / seconds)
		update(t)
		if t >= 1 then connection:Disconnect(); if complete then complete() end end
	end)
end

local function paper(name: string): Part
	local part = Instance.new("Part")
	part.Name, part.Size = name, Config.TicketSize
	part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery = true, false, false, false
	part.Material, part.Color = Enum.Material.SmoothPlastic, Color3.fromRGB(255, 244, 166)
	part.Parent = folder
	return part
end

function Effects.popup(part: BasePart, text: string, color: Color3, name: string?)
	-- Screen-space label follows its world point. It stays readable on a small phone
	-- and is visible in Studio captures that omit AlwaysOnTop BillboardGuis.
	local label = Instance.new("TextLabel")
	label.Name, label.Size = name or "RewardPopup", UDim2.fromOffset(230, 74)
	label.AnchorPoint, label.BackgroundTransparency = Vector2.new(0.5, 0.5), 1
	label.Font, label.TextSize = Enum.Font.GothamBlack, 25
	label.Text, label.TextColor3 = text, color
	label.TextStrokeTransparency, label.TextStrokeColor3 = 0.1, Color3.fromRGB(25, 25, 25)
	label.Active, label.Parent = false, overlay
	Debris:AddItem(label, Config.PopupSeconds + 0.1)
	animate(Config.PopupSeconds, function(t)
		if not label.Parent then return end
		local camera = workspace.CurrentCamera
		if not part.Parent or not camera then label.Visible = false; return end
		local point = camera:WorldToViewportPoint(part.Position + Vector3.new(0, 1.5, 0))
		label.Visible = point.Z > 0 and (part.Position - camera.CFrame.Position).Magnitude <= Config.LabelDistance
		label.Position = UDim2.fromOffset(point.X, point.Y - 16 - t * Config.PopupRisePixels)
		label.TextTransparency = math.max(0, (t - 0.6) / 0.4)
		label.TextStrokeTransparency = label.TextTransparency
	end, function() label:Destroy() end)
end

local function impact(car: Model, income: number)
	if not car.Parent or not car.PrimaryPart then return end
	local glass = car:FindFirstChild("Windshield") :: BasePart?
	local body = car.PrimaryPart
	Effects.popup(body, string.format("TICKETED!\n+$%d/s", income), Color3.fromRGB(255, 223, 75), "TicketedPopup")
	local ping = sound:Clone()
	ping.Name, ping.Parent = "TicketImpact", SoundService
	ping:Play()
	Debris:AddItem(ping, 2)
	local highlight = Instance.new("Highlight")
	highlight.Name, highlight.Adornee = "Ticketed", car
	highlight.FillColor, highlight.OutlineColor = Color3.fromRGB(255, 70, 50), Color3.fromRGB(255, 70, 50)
	highlight.FillTransparency, highlight.Parent = 0.65, car
	Debris:AddItem(highlight, Config.StickerSeconds)
	local sticker = paper("StuckTicket")
	local surface = Instance.new("SurfaceGui")
	surface.Face, surface.CanvasSize = Enum.NormalId.Top, Vector2.new(160, 210)
	local text = Instance.new("TextLabel")
	text.Size, text.BackgroundTransparency = UDim2.fromScale(1, 1), 1
	text.Text, text.TextColor3, text.TextSize = "TICKET", Color3.fromRGB(120, 25, 20), 36
	text.Font, text.Parent = Enum.Font.GothamBlack, surface
	surface.Parent = sticker
	animate(Config.StickerSeconds, function()
		if sticker.Parent and body.Parent then
			local anchor = if glass and glass.Parent then glass.CFrame else body.CFrame * CFrame.new(0, Config.RoofOffset, Config.WindshieldFront)
			sticker.CFrame = anchor * CFrame.new(0, 0, 0.1) * CFrame.Angles(math.pi / 2, 0, 0)
		end
	end, function() sticker:Destroy() end)
	local start = car:GetPivot()
	local originalParent = car.Parent
	animate(Config.HitBounceSeconds, function(t)
		if car.Parent == originalParent then car:PivotTo(start + Vector3.new(0, math.sin(t * math.pi) * Config.HitBounceHeight, 0)) end
	end, function() if car.Parent == originalParent then car:PivotTo(start) end end)
end

function Effects.flight(origin: Vector3, destination: Vector3, car: Model?, income: number)
	local ticket = paper("FlyingTicket")
	Debris:AddItem(ticket, Config.TicketFlightSeconds + 0.2)
	animate(Config.TicketFlightSeconds, function(t)
		if ticket.Parent then
			ticket.CFrame = CFrame.new(Rules.arcPoint(origin, destination, t, Config.TicketArcHeight)) * CFrame.Angles(t * math.pi * 4, t * math.pi * 2, 0)
		end
	end, function()
		ticket:Destroy()
		if car and car.Parent then impact(car, income) end
	end)
end

local popped = setmetatable({}, {__mode = "k"})
local function parkingPop(car: Model)
	if popped[car] or not car.PrimaryPart or not car:GetAttribute("Parked") then return end
	popped[car] = true
	local mark = car:FindFirstChild("Ticketed")
	if mark then mark:Destroy() end
	local visual = car:Clone()
	visual.Name = "ParkingPop"
	visual:PivotTo(car:GetPivot())
	for _,part in visual:GetDescendants() do
		if part:IsA("BasePart") then part.CanCollide, part.CanTouch, part.CanQuery = false, false, false end
	end
	local hidden = {}
	for _,part in car:GetDescendants() do
		if part:IsA("BasePart") then hidden[part] = part.LocalTransparencyModifier; part.LocalTransparencyModifier = 1 end
	end
	local scale = visual:GetScale()
	visual:ScaleTo(Config.ParkingPopStartScale)
	visual.Parent = folder
	animate(Config.ParkingPopSeconds, function(t)
		if visual.Parent then visual:ScaleTo(math.max(Config.ParkingPopStartScale, TweenService:GetValue(t, Enum.EasingStyle.Back, Enum.EasingDirection.Out) * scale)) end
	end, function()
		visual:Destroy()
		for part,value in hidden do if part.Parent then part.LocalTransparencyModifier = value end end
	end)
end

function Effects.watchParking(parking: Instance)
	local function watch(node: Instance)
		if not node:IsA("Model") then return end
		local c: RBXScriptConnection
		c = node:GetAttributeChangedSignal("Parked"):Connect(function()
			if node:GetAttribute("Parked") then c:Disconnect(); task.defer(parkingPop, node) end
		end)
		node.Destroying:Once(function() c:Disconnect() end)
		if node:GetAttribute("Parked") then c:Disconnect(); task.defer(parkingPop, node) end
	end
	parking.DescendantAdded:Connect(watch)
	for _,node in parking:GetDescendants() do watch(node) end
end

function Effects.watchTows(tows: Instance)
	tows.DescendantAdded:Connect(function(node)
		if not node:IsA("Model") or not node:GetAttribute("CarId") then return end
		local tow = node.Parent
		if not tow or not tow:IsA("Model") or not tow.PrimaryPart or not node.PrimaryPart then return end
		local a = Instance.new("Attachment")
		a.Position, a.Parent = Vector3.new(0, 1, Config.TowSize.Z / 2), tow.PrimaryPart
		local b = Instance.new("Attachment")
		b.Parent = node.PrimaryPart
		local beam = Instance.new("Beam")
		beam.Name, beam.Attachment0, beam.Attachment1 = "TowHook", a, b
		beam.Width0, beam.Width1, beam.FaceCamera = Config.HookWidth, Config.HookWidth, true
		beam.Color, beam.Parent = ColorSequence.new(Color3.fromRGB(35, 35, 35)), a
		Debris:AddItem(a, Config.TowReturnSeconds + 0.2)
		Debris:AddItem(b, Config.TowReturnSeconds + 0.2)
	end)
end
return Effects

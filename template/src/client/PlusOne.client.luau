--!strict
--[[
	"+1" presentation (server/Services/PlusOne owns every number):
	  * Power counter with progress to the next form, bottom centre (clear of
	    joystick and jump on phones).
	  * "+N" pops above the character as Power grows.
	  * Form up: flash and a big "LEVEL 10!" line; an aura in the form colour.
	  * Walls: label turns green when Power is enough; when the server says a
	    wall broke, it opens locally for a moment and shatters into pieces.
	  * Goal line above the counter: the one next thing to do (buy gear,
	    smash the next wall, beat the boss), worked out from server attributes.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Config = require(ReplicatedStorage:WaitForChild("GameConfig")) :: any
local Net = require(ReplicatedStorage:WaitForChild("LihFolk"):WaitForChild("Net"))

local cfg = Config.PlusOne
local player = Players.LocalPlayer

local SUFFIXES = { "", "K", "M", "B", "T", "Qa" }
local function shorten(n: number): string
	n = math.floor(n)
	if n < 10000 then
		return tostring(n)
	end
	local tier = 1
	while n >= 1000 and tier < #SUFFIXES do
		n /= 1000
		tier += 1
	end
	return string.format("%.1f", math.floor(n * 10) / 10):gsub("%.0$", "") .. SUFFIXES[tier]
end

local function formFor(power: number): number
	local index = 1
	for i, form in cfg.forms do
		if power >= form.at then
			index = i
		end
	end
	return index
end

-- HUD ---------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "PlusOneHud"
gui.ResetOnSpawn = false

-- Bottom HUD in style D (references/ui/D1_hud.webp): goal line, multiplier
-- chips, a long level bar with the Power icon breaking out of its left end.
local INK = Color3.fromHex("#120D17")
local FONT = Font.fromEnum(Enum.Font.FredokaOne)
local StyleIcons = require(ReplicatedStorage:WaitForChild("UIStyle"):WaitForChild("Icons"))

local function outlined(parent: Instance, size: number, align: Enum.TextXAlignment?): TextLabel
	local function make(offset: number, color: Color3, z: number): TextLabel
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1
		l.Size = UDim2.fromScale(1, 1)
		l.Position = UDim2.fromOffset(0, offset)
		l.FontFace = FONT
		l.TextSize = size
		l.TextXAlignment = align or Enum.TextXAlignment.Center
		l.TextColor3 = color
		l.ZIndex = z
		local st = Instance.new("UIStroke")
		st.Color = INK
		st.Thickness = math.max(2, size * 0.11)
		st.LineJoinMode = Enum.LineJoinMode.Round
		st.Parent = l
		l.Parent = parent
		return l
	end
	local shadow = make(math.floor(size * 0.09), INK, 4)
	local label = make(0, Color3.new(1, 1, 1), 5)
	label:GetPropertyChangedSignal("Text"):Connect(function()
		shadow.Text = label.Text
	end)
	return label
end

local function roundBox(parent: Instance, size: UDim2, color: Color3, transparency: number?): Frame
	local f = Instance.new("Frame")
	f.Size = size
	f.BackgroundColor3 = color
	f.BackgroundTransparency = transparency or 0
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 14)
	c.Parent = f
	f.Parent = parent
	return f
end

local panel = Instance.new("Frame")
panel.Name = "Bottom"
panel.BackgroundTransparency = 1
panel.AnchorPoint = Vector2.new(0.5, 1)
panel.Position = UDim2.new(0.5, 0, 1, -10)
panel.Size = UDim2.fromOffset(600, 150)
local panelScale = Instance.new("UIScale")
panelScale.Parent = panel
panel.Parent = gui

-- goal line (top)
local goalBox = roundBox(panel, UDim2.fromOffset(520, 34), Color3.fromHex("#1B1530"), 0.35)
goalBox.AnchorPoint = Vector2.new(0.5, 0)
goalBox.Position = UDim2.new(0.5, 0, 0, 0)
local goal = outlined(goalBox, 22)

-- multiplier chips (middle)
local chips = Instance.new("Frame")
chips.BackgroundTransparency = 1
chips.AnchorPoint = Vector2.new(0.5, 0)
chips.Position = UDim2.new(0.5, 0, 0, 40)
chips.Size = UDim2.new(1, 0, 0, 40)
local chipList = Instance.new("UIListLayout")
chipList.FillDirection = Enum.FillDirection.Horizontal
chipList.HorizontalAlignment = Enum.HorizontalAlignment.Center
chipList.Padding = UDim.new(0, 24)
chipList.Parent = chips
chips.Parent = panel
local function chip(iconKey: string): TextLabel
	local c = roundBox(chips, UDim2.fromOffset(0, 38), Color3.fromHex("#1B1530"), 0.35)
	c.AutomaticSize = Enum.AutomaticSize.X
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 30)
	pad.PaddingRight = UDim.new(0, 12)
	pad.Parent = c
	local img = Instance.new("ImageLabel")
	img.BackgroundTransparency = 1
	img.Image = StyleIcons[iconKey].image
	img.AnchorPoint = Vector2.new(0.5, 0.5)
	img.Position = UDim2.new(0, -14, 0.5, 0)
	img.Size = UDim2.fromOffset(44, 44)
	img.ZIndex = 6
	img.Parent = c
	local box = Instance.new("Frame")
	box.BackgroundTransparency = 1
	box.Size = UDim2.fromOffset(0, 38)
	box.AutomaticSize = Enum.AutomaticSize.X
	box.Parent = c
	local t = outlined(box, 22, Enum.TextXAlignment.Left)
	t.Size = UDim2.new(0, 0, 1, 0)
	t.AutomaticSize = Enum.AutomaticSize.X
	return t
end
local gearChip = chip("boots")
local rebirthChip = chip("power")

-- level bar (bottom)
local bar = roundBox(panel, UDim2.fromOffset(560, 56), Color3.fromHex("#1B1530"))
bar.AnchorPoint = Vector2.new(0.5, 1)
bar.Position = UDim2.new(0.5, 0, 1, 0)
local barStroke = Instance.new("UIStroke")
barStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
barStroke.Color = INK
barStroke.Thickness = 4
barStroke.Parent = bar
local track = Instance.new("Frame")
track.BackgroundTransparency = 1
track.Position = UDim2.fromOffset(5, 5)
track.Size = UDim2.new(1, -10, 1, -10)
track.Parent = bar
local fill = roundBox(track, UDim2.fromScale(0, 1), Color3.new(1, 1, 1))
fill.ClipsDescendants = true
local fillGradient = Instance.new("UIGradient")
fillGradient.Rotation = 90
fillGradient.Color = ColorSequence.new(Color3.fromHex("#6FD3FF"), Color3.fromHex("#2C7BFF"))
fillGradient.Parent = fill
local gloss = roundBox(fill, UDim2.new(1, -8, 0.38, 0), Color3.new(1, 1, 1), 0.65)
gloss.Position = UDim2.fromOffset(4, 3)
local boltIcon = Instance.new("ImageLabel")
boltIcon.BackgroundTransparency = 1
boltIcon.Image = StyleIcons.power.image
boltIcon.AnchorPoint = Vector2.new(0.5, 0.5)
boltIcon.Position = UDim2.new(0, -6, 0.5, -2)
boltIcon.Size = UDim2.fromOffset(78, 78)
boltIcon.Rotation = -10
boltIcon.ZIndex = 7
boltIcon.Parent = bar
local leftBox = Instance.new("Frame")
leftBox.BackgroundTransparency = 1
leftBox.Position = UDim2.fromOffset(44, 0)
leftBox.Size = UDim2.new(0.5, -44, 1, 0)
leftBox.Parent = bar
local nextText = outlined(leftBox, 32, Enum.TextXAlignment.Left) -- current form name
local rightBox = Instance.new("Frame")
rightBox.BackgroundTransparency = 1
rightBox.AnchorPoint = Vector2.new(1, 0)
rightBox.Position = UDim2.new(1, -16, 0, 0)
rightBox.Size = UDim2.new(0.5, 0, 1, 0)
rightBox.Parent = bar
local power = outlined(rightBox, 32, Enum.TextXAlignment.Right) -- "930 / 1.5K"
local powerScale = Instance.new("UIScale")
powerScale.Parent = rightBox

local function fitBottom()
	local h = gui.AbsoluteSize.Y
	panelScale.Scale = if h < 520 then 0.62 else math.clamp(h / 1080 * 1.1, 0.8, 1.2)
end
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitBottom)
task.defer(fitBottom)

local function refreshChips()
	local gear = (player:GetAttribute("Gear") :: number?) or 0
	local rebirths = (player:GetAttribute("Rebirths") :: number?) or 0
	gearChip.Text = if gear > 0 then `{string.upper(cfg.gear[gear].name)} x{cfg.gear[gear].mult}` else "NO GEAR YET"
	rebirthChip.Text = `REBIRTH x{1 + rebirths * (Config.Rebirth.bonusPerRebirth or 0)}`
end
player:GetAttributeChangedSignal("Gear"):Connect(refreshChips)
player:GetAttributeChangedSignal("Rebirths"):Connect(refreshChips)
refreshChips()

local banner = Instance.new("TextLabel")
banner.AnchorPoint = Vector2.new(0.5, 0.5)
banner.Position = UDim2.fromScale(0.5, 0.3)
banner.Size = UDim2.fromOffset(600, 80)
banner.BackgroundTransparency = 1
banner.Font = Enum.Font.FredokaOne
banner.TextSize = 60
banner.TextStrokeTransparency = 0
banner.Visible = false
banner.Parent = gui
local bannerScale = Instance.new("UIScale")
bannerScale.Parent = banner

local flash = Instance.new("Frame")
flash.Size = UDim2.fromScale(1, 1)
flash.BackgroundColor3 = Color3.new(1, 1, 1)
flash.BackgroundTransparency = 1
flash.Parent = gui

gui.Parent = player:WaitForChild("PlayerGui")

local function showBanner(text: string, color: Color3)
	banner.Text = text
	banner.TextColor3 = color
	banner.Visible = true
	bannerScale.Scale = 0.4
	TweenService:Create(bannerScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	local stamp = os.clock()
	banner:SetAttribute("Stamp", stamp)
	task.delay(1.6, function()
		if banner:GetAttribute("Stamp") == stamp then
			banner.Visible = false
		end
	end)
end

-- "+N" pops above the head --------------------------------------------------
local function pop(amount: number, color: Color3)
	local character = player.Character
	local head = character and character:FindFirstChild("Head")
	if not head or not head:IsA("BasePart") then
		return
	end
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(120, 40)
	bb.StudsOffsetWorldSpace = Vector3.new(math.random(-15, 15) / 10, 2, 0)
	bb.AlwaysOnTop = true
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.FredokaOne
	t.TextScaled = true
	t.TextColor3 = color
	t.TextStrokeTransparency = 0
	t.Text = "+" .. shorten(amount)
	t.Parent = bb
	bb.Parent = head
	TweenService:Create(bb, TweenInfo.new(0.8), { StudsOffsetWorldSpace = bb.StudsOffsetWorldSpace + Vector3.new(0, 3, 0) }):Play()
	TweenService:Create(t, TweenInfo.new(0.8), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	Debris:AddItem(bb, 0.85)
end

-- Aura in the form colour -------------------------------------------------
local function setAura(index: number)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local old = root:FindFirstChild("PlusOneAura")
	if old then
		old:Destroy()
	end
	if index <= 1 then
		return
	end
	local aura = Instance.new("ParticleEmitter")
	aura.Name = "PlusOneAura"
	aura.Color = ColorSequence.new(cfg.forms[index].color)
	aura.LightEmission = 1
	aura.Rate = 6 + index * 6
	aura.Lifetime = NumberRange.new(0.6, 1.1)
	aura.Speed = NumberRange.new(2, 5)
	aura.SpreadAngle = Vector2.new(180, 180)
	aura.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0) })
	aura.Parent = root
end

-- State -------------------------------------------------------------------
local lastPower = 0
local pending = 0
local function refresh()
	local value = (player:GetAttribute(cfg.stat) :: number?) or 0
	if value > lastPower then
		pending += value - lastPower
	end
	lastPower = value
	local index = formFor(value)
	local nextForm = cfg.forms[index + 1]
	nextText.Text = cfg.forms[index].name
	if nextForm then
		local from = cfg.forms[index].at
		fill.Size = UDim2.fromScale(math.clamp((value - from) / (nextForm.at - from), 0.03, 1), 1)
		power.Text = `{shorten(value)} / {shorten(nextForm.at)}`
	else
		fill.Size = UDim2.fromScale(1, 1)
		power.Text = `{shorten(value)} MAX`
	end
end
player:GetAttributeChangedSignal(cfg.stat):Connect(refresh)
refresh()

-- Batch pops so fast gains read as a few big numbers, not a blur.
task.spawn(function()
	while true do
		task.wait(0.25)
		if pending > 0 then
			pop(pending, Color3.fromRGB(255, 230, 90))
			powerScale.Scale = 1.12
			TweenService:Create(powerScale, TweenInfo.new(0.15), { Scale = 1 }):Play()
			pending = 0
		end
	end
end)

local currentForm = (player:GetAttribute("Form") :: number?) or 1
player:GetAttributeChangedSignal("Form"):Connect(function()
	local index = (player:GetAttribute("Form") :: number?) or 1
	setAura(index)
	if index > currentForm then
		local form = cfg.forms[index]
		showBanner(`{string.upper(form.name)}!`, form.color)
		flash.BackgroundTransparency = 0.3
		TweenService:Create(flash, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
	end
	currentForm = index
end)
player.CharacterAdded:Connect(function()
	task.wait(0.5)
	setAura((player:GetAttribute("Form") :: number?) or 1)
end)

-- Goal: the one next thing to do ------------------------------------------
local function wallHp(world: number, index: number): number
	local w = cfg.worlds[world]
	if index > #cfg.walls then
		return w.boss.hp
	end
	return cfg.walls[index].hp * w.scale
end

local function updateGoal()
	local gear = (player:GetAttribute("Gear") :: number?) or 0
	local world = (player:GetAttribute("World") :: number?) or 1
	local best = (player:GetAttribute("Best") :: number?) or 0
	local cash = (player:GetAttribute(cfg.reward) :: number?) or 0
	local nextGear = cfg.gear[gear + 1]
	local nextWall = best + 1
	local last = #cfg.walls + 1
	local egg = Config.Eggs.eggs[`Egg{world}`]
	if egg and cash >= egg.price.amount and (player:GetAttribute("EquippedPets") or 0) == 0 then
		goal.Text = "Open an egg at the start!"
	elseif nextWall <= last and lastPower >= wallHp(world, nextWall) then
		goal.Text = if nextWall == last then `Beat the boss: {cfg.worlds[world].boss.name}!` else "Smash the next wall!"
	elseif nextGear and cash >= nextGear.price then
		goal.Text = `Buy {nextGear.name} at the start (x{nextGear.mult} Power)!`
	elseif nextWall <= last then
		goal.Text = `Walk to {shorten(wallHp(world, nextWall))} Power to smash the next wall`
	else
		goal.Text = "Rebirth for more Power per step!"
	end
end
for _, name in { "Gear", "World", "Best", "EquippedPets", cfg.reward, cfg.stat } do
	player:GetAttributeChangedSignal(name):Connect(updateGoal)
end
updateGoal()

-- Walls and gear stands -----------------------------------------------------
local trackFolder = workspace:WaitForChild("PlusOneTrack")
local function surfaceText(target: Instance): TextLabel?
	local sg = target:FindFirstChildOfClass("SurfaceGui")
	return sg and sg:FindFirstChildOfClass("TextLabel")
end
local GREEN, RED, GREY = Color3.fromRGB(120, 255, 140), Color3.fromRGB(255, 90, 90), Color3.fromRGB(170, 170, 170)
task.spawn(function()
	while true do
		task.wait(0.3)
		local gear = (player:GetAttribute("Gear") :: number?) or 0
		local cash = (player:GetAttribute(cfg.reward) :: number?) or 0
		for _, item in trackFolder:GetChildren() do
			local text = surfaceText(item)
			local hp = item:GetAttribute("Hp")
			local gi = item:GetAttribute("GearIndex")
			if text and hp then
				text.TextColor3 = if lastPower >= hp then GREEN else RED
			elseif text and gi then
				text.TextColor3 = if gi <= gear then GREY elseif gi == gear + 1 and cash >= cfg.gear[gi].price then GREEN else Color3.new(1, 1, 1)
			end
		end
	end
end)

local function shatter(wall: BasePart)
	for _ = 1, 16 do
		local piece = Instance.new("Part")
		piece.Size = Vector3.new(math.random(20, 50) / 10, math.random(20, 50) / 10, 1.5)
		piece.Color = wall.Color
		piece.Material = wall.Material
		piece.CanCollide = false
		piece.CanQuery = false
		piece.CanTouch = false
		piece.Position = wall.Position + Vector3.new(math.random(-14, 14), math.random(-6, 6), 0)
		piece.AssemblyLinearVelocity = Vector3.new(math.random(-30, 30), math.random(20, 50), math.random(-60, -25))
		piece.AssemblyAngularVelocity = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
		piece.Parent = workspace
		Debris:AddItem(piece, 2)
	end
end

local function openWall(world: number, index: number)
	for _, wall in trackFolder:GetChildren() do
		if wall:IsA("BasePart") and wall:GetAttribute("World") == world and wall:GetAttribute("Index") == index then
			-- Local only: this client's character walks through; others still see the wall.
			wall.LocalTransparencyModifier = 1
			wall.CanCollide = false
			local sg = wall:FindFirstChildOfClass("SurfaceGui")
			if sg then
				sg.Enabled = false
			end
			shatter(wall)
			task.delay(2.5, function()
				wall.LocalTransparencyModifier = 0
				wall.CanCollide = true
				if sg then
					sg.Enabled = true
				end
			end)
		end
	end
end

Net.On("PlusOne.Event", function(kind: string, a: number, b: number?, c: number?)
	if kind == "wall" then
		openWall(a, b :: number)
		showBanner(`SMASH! +{shorten(c or 0)} {string.upper(cfg.reward)}`, GREEN)
	elseif kind == "boss" then
		openWall(a, b :: number)
		showBanner(`BOSS DEFEATED! +{shorten(c or 0)}`, Color3.fromRGB(255, 210, 60))
		flash.BackgroundTransparency = 0.2
		TweenService:Create(flash, TweenInfo.new(0.8), { BackgroundTransparency = 1 }):Play()
	elseif kind == "world" then
		showBanner(`NEW WORLD: {string.upper(cfg.worlds[a].name)}!`, Color3.fromRGB(120, 200, 255))
	elseif kind == "gear" then
		local gear = cfg.gear[a]
		showBanner(`{string.upper(gear.name)}! x{gear.mult} POWER`, Color3.fromRGB(255, 210, 60))
	end
end)

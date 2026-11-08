--!strict
--[[
	First-minute hints, client side (mechanism; steps in GameConfig.Hints).
	The server says which step is current (Hints.Get / Hints.Step push) and
	completes it; this script only draws a bouncing arrow at the step's target
	with a short line, and hides it when the step changes.
	Also reports window opens to the server (Analytics.WindowOpened), which is
	what completes "Window:<name>" steps and feeds the onboarding funnel.

	Targets: "button:<Window>", "gui:<path under PlayerGui>", "part:<path in Workspace>".
	A target that is not on screen right now (closed window) shows the line only.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local Controller = require(ReplicatedStorage:WaitForChild("LihFolkUI"):WaitForChild("LihFolkUIController"))
local Style = ReplicatedStorage:WaitForChild("UIStyle")
local Theme = require(Style:WaitForChild("Theme"))
local Icons = require(Style:WaitForChild("Icons"))
local Net = require(ReplicatedStorage:WaitForChild("LihFolk"):WaitForChild("Net"))
local Config = require(ReplicatedStorage:WaitForChild("GameConfig")) :: any

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ARROW_COLOR = Color3.fromHex("#FFD34D")
local INK = Color3.fromHex("#120D17")

---------------------------------------------------------------------------
-- Window opens -> server (analytics funnel and hint triggers)
---------------------------------------------------------------------------
local windows: { [string]: boolean } = {}
for _, name in Config.Analytics.windows do
	windows[name] = true
end
Controller.onChanged(function(name: string, isOpen: boolean)
	if isOpen and windows[name] then
		Net.Send("Analytics.WindowOpened", name)
	end
end)

if not Config.Hints.enabled then
	return
end

---------------------------------------------------------------------------
-- Drawing: a chunky down-pointing arrow (shaft + triangle) and a line of text
---------------------------------------------------------------------------
local function makeArrow(parent: Instance): Frame
	local arrow = Instance.new("Frame")
	arrow.Name = "Arrow"
	arrow.BackgroundTransparency = 1
	arrow.Size = UDim2.fromOffset(44, 60)
	arrow.AnchorPoint = Vector2.new(0.5, 1)
	local shaft = Instance.new("Frame")
	shaft.BackgroundColor3 = ARROW_COLOR
	shaft.Size = UDim2.fromOffset(16, 34)
	shaft.Position = UDim2.fromOffset(14, 0)
	local shaftStroke = Instance.new("UIStroke")
	shaftStroke.Color = INK
	shaftStroke.Thickness = 3
	shaftStroke.Parent = shaft
	shaft.Parent = arrow
	-- Triangle: the bottom half of a square turned 45 degrees, clipped.
	local clip = Instance.new("Frame")
	clip.BackgroundTransparency = 1
	clip.ClipsDescendants = true
	clip.Size = UDim2.fromOffset(44, 26)
	clip.Position = UDim2.fromOffset(0, 32)
	clip.Parent = arrow
	local head = Instance.new("Frame")
	head.BackgroundColor3 = ARROW_COLOR
	head.Size = UDim2.fromOffset(30, 30)
	head.AnchorPoint = Vector2.new(0.5, 0.5)
	head.Position = UDim2.fromOffset(22, 0)
	head.Rotation = 45
	local headStroke = Instance.new("UIStroke")
	headStroke.Color = INK
	headStroke.Thickness = 3
	headStroke.Parent = head
	head.Parent = clip
	arrow.Parent = parent
	return arrow
end

local function makeBubble(parent: Instance): (Frame, TextLabel)
	local bubble = Instance.new("Frame")
	bubble.Name = "Bubble"
	bubble.BackgroundColor3 = Theme.Color.windowTop
	bubble.Size = UDim2.fromOffset(0, 40)
	bubble.AutomaticSize = Enum.AutomaticSize.X
	bubble.AnchorPoint = Vector2.new(0.5, 1)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = bubble
	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = ARROW_COLOR
	stroke.Thickness = 3
	stroke.Parent = bubble
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 14)
	pad.PaddingRight = UDim.new(0, 14)
	pad.Parent = bubble
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.FontFace = Theme.Font.title
	label.TextSize = 20
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Size = UDim2.fromScale(0, 1)
	label.AutomaticSize = Enum.AutomaticSize.X
	label.Parent = bubble
	bubble.Parent = parent
	return bubble, label
end

local gui = Instance.new("ScreenGui")
gui.Name = "Hints"
gui.ResetOnSpawn = false
gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets -- same origin as the menus
gui.DisplayOrder = 70 -- above windows
gui.Parent = playerGui

local holder = Instance.new("Frame")
holder.Name = "Pointer"
holder.BackgroundTransparency = 1
holder.Size = UDim2.fromOffset(0, 0)
holder.Visible = false
holder.Parent = gui
local arrow = makeArrow(holder)
local bubble, bubbleLabel = makeBubble(holder)
local holderScale = Instance.new("UIScale")
holderScale.Parent = holder

-- Bounce: the arrow moves 10 px towards the target and back.
local bounce = TweenService:Create(arrow, TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Position = UDim2.fromOffset(0, -10) })

---------------------------------------------------------------------------
-- Targets
---------------------------------------------------------------------------
local function resolve(target: string): Instance?
	local kind, rest = string.match(target, "^(%a+):(.+)$")
	if kind == "button" and rest then
		local icon = Icons[string.lower(rest)]
		local layer = playerGui:FindFirstChild("MenuButtons")
		return if icon and layer then layer:FindFirstChild("Menu_" .. icon.label, true) else nil
	end
	local root: Instance? = if kind == "gui" then playerGui elseif kind == "part" then workspace else nil
	if not root or not rest then
		return nil
	end
	for name in string.gmatch(rest, "[^%.]+") do
		root = (root :: Instance):FindFirstChild(name)
		if not root then
			return nil
		end
	end
	return root
end

-- True when a GuiObject is actually drawn (every ancestor visible and enabled).
local function onScreen(object: GuiObject): boolean
	local node: Instance? = object
	while node and node ~= playerGui do
		if node:IsA("GuiObject") and not node.Visible then
			return false
		elseif node:IsA("ScreenGui") and not node.Enabled then
			return false
		end
		node = node.Parent
	end
	return node == playerGui
end

local step: any = nil
local billboard: BillboardGui? = nil

local function clearBillboard()
	if billboard then
		billboard:Destroy()
		billboard = nil
	end
end

local function show(newStep: any)
	step = newStep
	clearBillboard()
	holder.Visible = false
	if not step then
		bounce:Cancel()
		return
	end
	bubbleLabel.Text = step.text
	if not GuiService.ReducedMotionEnabled then
		bounce:Play()
	end
end

-- Follows the target every frame while a step is shown (cheap: one lookup,
-- one position write). Parts get a BillboardGui arrow instead.
RunService.RenderStepped:Connect(function()
	if not step then
		return
	end
	local target = resolve(step.target)
	if target and (target:IsA("BasePart") or target:IsA("Model")) then
		holder.Visible = false
		if not billboard then
			local b = Instance.new("BillboardGui")
			b.Name = "HintArrow"
			b.AlwaysOnTop = true
			b.Size = UDim2.fromOffset(220, 120)
			b.StudsOffsetWorldSpace = Vector3.new(0, 4, 0)
			b.Adornee = if target:IsA("Model") then (target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")) else target
			local a = makeArrow(b)
			a.Position = UDim2.new(0.5, 0, 1, 0)
			local bb, bl = makeBubble(b)
			bb.Position = UDim2.new(0.5, 0, 1, -64)
			bl.Text = step.text
			b.Parent = gui
			billboard = b
		end
		return
	end
	clearBillboard()
	-- Another window is open and the target is not in it: wait until it closes.
	local open = Controller.getCurrent()
	local openRoot = if open then playerGui:FindFirstChild("LihFolkUI") and playerGui.LihFolkUI:FindFirstChild(open) else nil
	if openRoot and not (target and target:IsDescendantOf(openRoot)) then
		holder.Visible = false
		return
	end
	holder.Visible = true
	holderScale.Scale = if gui.AbsoluteSize.Y < 520 then 0.8 else 1
	if target and target:IsA("GuiObject") and onScreen(target) then
		-- Arrow above the target pointing down; text above the arrow.
		local pos = target.AbsolutePosition
		local size = target.AbsoluteSize
		holder.Position = UDim2.fromOffset(pos.X + size.X / 2, pos.Y - 4)
		arrow.Visible = true
		-- Keep the bubble on screen near the edges (one write per frame).
		local half = bubble.AbsoluteSize.X / 2
		local x = pos.X + size.X / 2
		local shift = math.clamp(x, half + 8, gui.AbsoluteSize.X - half - 8) - x
		bubble.Position = UDim2.fromOffset(shift / holderScale.Scale, -66)
	else
		-- Target not visible right now: the line only, top centre.
		holder.Position = UDim2.new(0.5, 0, 0, 150)
		arrow.Visible = false
		bubble.Position = UDim2.fromOffset(0, 0)
	end
end)

Net.On("Hints.Step", function(newStep: any)
	show(newStep)
end)
task.spawn(function()
	for _ = 1, 10 do
		local result = Net.Request("Hints.Get")
		if result.ok then
			show(result.data)
			return
		end
		task.wait(1.5)
	end
end)

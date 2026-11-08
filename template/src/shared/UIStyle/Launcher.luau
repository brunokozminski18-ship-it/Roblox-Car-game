--!strict
--[[
	Menu buttons in style D (references/ui/D1_hud.webp: style and placement,
	our own icons — "Free Icon Pack" by gvesster, see UIStyle/Icons):
	  menu   no tile: a big icon with a heavy outlined caption under it;
	         2-column grid at the left edge, vertically centred (PC) or hung
	         from the top (phone, clear of the thumbstick)
	  promo  wide rainbow slab on the right edge with the icon breaking out of
	         its left side, a big title and a small line under it; opens a window
	Launcher.add(windowName, iconKey, order) toggles that window.
	Launcher.promo(windowName, promo, order) adds a promo slab (UIStyle/Icons.Promos).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local Controller = require(ReplicatedStorage:WaitForChild("LihFolkUI"):WaitForChild("LihFolkUIController"))
local Icons = require(script.Parent.Icons)

local Launcher = {}

local CELL = Vector2.new(104, 112) -- icon 84 + caption
local ICON = 84
local PROMO = Vector2.new(300, 92)
local GAP = 6
local MARGIN = 14
local INK = Color3.fromHex("#120D17")
local FONT = Font.fromEnum(Enum.Font.FredokaOne)

export type Entry = { root: GuiButton, setBadge: (on: boolean) -> () }

---------------------------------------------------------------------------
-- Layer: icon grid on the left, promos on the right
---------------------------------------------------------------------------
local gui: ScreenGui? = nil
local left: Frame
local right: Frame
local leftScale: UIScale
local rightScale: UIScale

local function count(parent: Instance): number
	local n = 0
	for _, child in parent:GetChildren() do
		if child:IsA("GuiButton") then
			n += 1
		end
	end
	return n
end

local function layout()
	local g = gui
	if not g then
		return
	end
	local area = g.AbsoluteSize
	if area.Y <= 0 then
		return
	end
	local phone = UserInputService.TouchEnabled and math.min(area.X, area.Y) < 520
	-- Phones: 3 columns, so the grid is shorter and the icons can stay big.
	local perRow = if phone then 3 else 2
	left.Size = UDim2.fromOffset(CELL.X * perRow + GAP * (perRow - 1), 0)
	local rows = math.ceil(count(left) / perRow)
	local leftHeight = rows * CELL.Y + math.max(0, rows - 1) * GAP
	local scale = if phone
		then math.min(0.8, area.Y * 0.6 / math.max(leftHeight, 1)) -- ends above the thumbstick
		else math.clamp(area.Y / 1080 * 1.15, 0.85, 1.25)
	leftScale.Scale = scale
	rightScale.Scale = if phone then math.min(0.7, area.Y / 520) else scale
	if phone then
		left.AnchorPoint = Vector2.new(0, 0)
		left.Position = UDim2.fromOffset(MARGIN, MARGIN + 40)
		right.AnchorPoint = Vector2.new(1, 0)
		right.Position = UDim2.new(1, -MARGIN, 0, MARGIN + 40)
	else
		left.AnchorPoint = Vector2.new(0, 0.5)
		left.Position = UDim2.new(0, MARGIN, 0.5, 0)
		right.AnchorPoint = Vector2.new(1, 0.5)
		right.Position = UDim2.new(1, -MARGIN, 0.45, 0)
	end
end

local function ensureLayer()
	if gui then
		return
	end
	local g = Instance.new("ScreenGui")
	g.Name = "MenuButtons"
	g.ResetOnSpawn = false
	g.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	g.DisplayOrder = 39 -- under windows (41) and the currency HUD (40)

	left = Instance.new("Frame")
	left.Name = "Left"
	left.BackgroundTransparency = 1
	left.Size = UDim2.fromOffset(CELL.X * 2 + GAP, 0)
	left.AutomaticSize = Enum.AutomaticSize.Y
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.fromOffset(CELL.X, CELL.Y)
	grid.CellPadding = UDim2.fromOffset(GAP, GAP)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = left
	leftScale = Instance.new("UIScale")
	leftScale.Parent = left
	left.Parent = g

	right = Instance.new("Frame")
	right.Name = "Right"
	right.BackgroundTransparency = 1
	right.Size = UDim2.fromOffset(PROMO.X + 40, 0)
	right.AutomaticSize = Enum.AutomaticSize.Y
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 22)
	list.HorizontalAlignment = Enum.HorizontalAlignment.Right
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = right
	rightScale = Instance.new("UIScale")
	rightScale.Parent = right
	right.Parent = g

	g.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	g:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
	gui = g
end

---------------------------------------------------------------------------
-- Pieces
---------------------------------------------------------------------------
-- Heavy outlined text: white face, thick ink stroke, ink drop shadow (D1).
local function word(text: string, size: number, parent: Instance, color: Color3?): TextLabel
	local function make(name: string, offset: number): TextLabel
		local l = Instance.new("TextLabel")
		l.Name = name
		l.BackgroundTransparency = 1
		l.Text = text
		l.FontFace = FONT
		l.TextScaled = true
		l.Size = UDim2.fromScale(1, 1)
		l.Position = UDim2.fromOffset(0, offset)
		l.Parent = parent
		local cap = Instance.new("UITextSizeConstraint")
		cap.MaxTextSize = size
		cap.Parent = l
		local stroke = Instance.new("UIStroke")
		stroke.Color = INK
		stroke.Thickness = math.max(2, size * 0.11)
		stroke.LineJoinMode = Enum.LineJoinMode.Round
		stroke.Parent = l
		return l
	end
	local shadow = make("Shadow", math.max(2, math.floor(size * 0.09)))
	shadow.TextColor3 = INK
	shadow.ZIndex = 4
	local label = make("Label", 0)
	label.TextColor3 = color or Color3.new(1, 1, 1)
	label.ZIndex = 5
	return label
end

local function pressable(button: GuiButton, onActivated: () -> ())
	local scale = Instance.new("UIScale")
	scale.Parent = button
	local function to(value: number, time: number, style: Enum.EasingStyle)
		if GuiService.ReducedMotionEnabled then
			scale.Scale = 1
			return
		end
		TweenService:Create(scale, TweenInfo.new(time, style, Enum.EasingDirection.Out), { Scale = value }):Play()
	end
	button.MouseEnter:Connect(function()
		to(1.06, 0.1, Enum.EasingStyle.Quad)
	end)
	button.MouseButton1Down:Connect(function()
		to(0.92, 0.05, Enum.EasingStyle.Quad)
	end)
	button.MouseButton1Up:Connect(function()
		to(1, 0.16, Enum.EasingStyle.Back)
	end)
	button.MouseLeave:Connect(function()
		to(1, 0.12, Enum.EasingStyle.Quad)
	end)
	button.Activated:Connect(onActivated)
end

local function badge(parent: Instance): Frame
	local b = Instance.new("Frame")
	b.Name = "Badge"
	b.AnchorPoint = Vector2.new(0.5, 0.5)
	b.Position = UDim2.new(1, -14, 0, 10)
	b.Size = UDim2.fromOffset(28, 28)
	b.BackgroundColor3 = Color3.fromHex("#FF3B4E")
	b.ZIndex = 8
	b.Visible = false
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = b
	local s = Instance.new("UIStroke")
	s.Color = Color3.new(1, 1, 1)
	s.Thickness = 3
	s.Parent = b
	local mark = Instance.new("TextLabel")
	mark.BackgroundTransparency = 1
	mark.Size = UDim2.fromScale(1, 1)
	mark.Text = "!"
	mark.FontFace = FONT
	mark.TextSize = 20
	mark.TextColor3 = Color3.new(1, 1, 1)
	mark.ZIndex = 9
	mark.Parent = b
	b.Parent = parent
	return b
end

local function image(source: string, parent: Instance): ImageLabel
	local a = Instance.new("ImageLabel")
	a.Name = "Art"
	a.BackgroundTransparency = 1
	a.Image = source
	a.ScaleType = Enum.ScaleType.Fit
	a.AnchorPoint = Vector2.new(0.5, 0.5)
	a.ZIndex = 3
	a.Parent = parent
	return a
end

local function titleCase(s: string): string
	return s:sub(1, 1):upper() .. s:sub(2):lower()
end

---------------------------------------------------------------------------
-- Button kinds
---------------------------------------------------------------------------
local function menuButton(icon: Icons.MenuIcon, order: number): TextButton
	local b = Instance.new("TextButton")
	b.Name = "Menu_" .. icon.label
	b.Text = ""
	b.AutoButtonColor = false
	b.BackgroundTransparency = 1
	b.LayoutOrder = order
	local a = image(icon.image, b)
	a.Position = UDim2.new(0.5, 0, 0, ICON / 2 + 2)
	a.Size = UDim2.fromOffset(ICON, ICON)
	local holder = Instance.new("Frame")
	holder.Name = "Caption"
	holder.BackgroundTransparency = 1
	holder.AnchorPoint = Vector2.new(0.5, 1)
	holder.Position = UDim2.new(0.5, 0, 1, -2)
	holder.Size = UDim2.new(1, 16, 0, 28)
	holder.ZIndex = 4
	holder.Parent = b
	word(titleCase(icon.button or icon.label), 26, holder)
	return b
end

export type Promo = { image: string, title: string, line: string, from: Color3, to: Color3 }

local function promoButton(promo: Promo, order: number): TextButton
	local b = Instance.new("TextButton")
	b.Name = "Promo_" .. promo.title
	b.Text = ""
	b.AutoButtonColor = false
	b.LayoutOrder = order
	b.Size = UDim2.fromOffset(PROMO.X, PROMO.Y)
	b.BackgroundColor3 = Color3.new(1, 1, 1)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = b
	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = INK
	stroke.Thickness = 4
	stroke.Parent = b
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, promo.from),
		ColorSequenceKeypoint.new(0.5, promo.from:Lerp(promo.to, 0.5):Lerp(Color3.new(1, 1, 1), 0.25)),
		ColorSequenceKeypoint.new(1, promo.to),
	})
	g.Rotation = 20
	g.Parent = b
	-- gloss band on the top half
	local gloss = Instance.new("Frame")
	gloss.BackgroundColor3 = Color3.new(1, 1, 1)
	gloss.BackgroundTransparency = 0.7
	gloss.Position = UDim2.fromOffset(6, 5)
	gloss.Size = UDim2.new(1, -12, 0.4, 0)
	gloss.ZIndex = 2
	local gc = Instance.new("UICorner")
	gc.CornerRadius = UDim.new(0, 10)
	gc.Parent = gloss
	gloss.Parent = b
	-- icon breaks out of the left edge
	local a = image(promo.image, b)
	a.Position = UDim2.new(0, 12, 0.5, -4)
	a.Size = UDim2.fromOffset(PROMO.Y * 1.35, PROMO.Y * 1.35)
	a.Rotation = -10
	a.ZIndex = 6
	local titleBox = Instance.new("Frame")
	titleBox.BackgroundTransparency = 1
	titleBox.Position = UDim2.new(0, 70, 0, 8)
	titleBox.Size = UDim2.new(1, -82, 0, 54)
	titleBox.ZIndex = 4
	titleBox.Parent = b
	word(promo.title, 48, titleBox)
	local lineBox = Instance.new("Frame")
	lineBox.BackgroundTransparency = 1
	lineBox.AnchorPoint = Vector2.new(0.5, 0)
	lineBox.Position = UDim2.new(0.5, 30, 1, 2)
	lineBox.Size = UDim2.new(1, -40, 0, 30)
	lineBox.ZIndex = 4
	lineBox.Parent = b
	word(promo.line, 28, lineBox)
	return b
end

function Launcher.add(windowName: string, iconKey: string, order: number): Entry
	local icon = Icons[iconKey]
	assert(icon, `[Launcher] no icon "{iconKey}" in UIStyle.Icons`)
	Controller.start()
	ensureLayer()
	local button = menuButton(icon, order)
	pressable(button, function()
		Controller.toggle(windowName)
	end)
	local b = badge(button)
	button.Parent = left
	layout()
	return {
		root = button,
		setBadge = function(on: boolean)
			b.Visible = on
		end,
	}
end

function Launcher.promo(windowName: string, promo: Promo, order: number): GuiButton
	Controller.start()
	ensureLayer()
	local button = promoButton(promo, order)
	pressable(button, function()
		Controller.open(windowName)
	end)
	button.Parent = right
	layout()
	return button
end

return Launcher

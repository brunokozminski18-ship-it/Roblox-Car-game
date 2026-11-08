--!strict
--[[
	Currency HUD: Cash and Gems counters at the top centre, in style D (references/ui/D1_hud.webp).
	Reads state the server owns: leaderstats.Cash and the player attribute "Gems".
	The "+" next to Cash opens the Shop window (ShopMenu registers it).

	Numbers are shortened by truncation, never rounded up (29,999 -> 29.9K).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local Controller = require(ReplicatedStorage:WaitForChild("LihFolkUI"):WaitForChild("LihFolkUIController"))
local Style = ReplicatedStorage:WaitForChild("UIStyle")
local StyleIcons = require(Style:WaitForChild("Icons"))

local player = Players.LocalPlayer

local COMPACT_HEIGHT = 520 -- safe-area height below which the HUD shrinks (phones)

Controller.start()

local SUFFIXES = { "K", "M", "B", "T", "Qa" }

-- Truncates to one decimal: 29999 -> "29.9K", 1250 -> "1,250".
local function shorten(value: number): string
	value = math.floor(value)
	if value < 10000 then
		local s = tostring(value)
		return (s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
	end
	local tier = 0
	local scaled = value
	while scaled >= 1000 and tier < #SUFFIXES do
		scaled /= 1000
		tier += 1
	end
	local truncated = math.floor(scaled * 10) / 10
	local text = if truncated == math.floor(truncated) then tostring(math.floor(truncated)) else string.format("%.1f", truncated)
	return text .. SUFFIXES[tier]
end

local gui = Instance.new("ScreenGui")
gui.Name = "CurrencyHud"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 40 -- below LihFolk windows (41) so menus cover it
gui.Parent = player:WaitForChild("PlayerGui")

local row = Instance.new("Frame")
row.Name = "Counters"
row.BackgroundTransparency = 1
row.AnchorPoint = Vector2.new(0.5, 0)
row.Position = UDim2.new(0.5, 0, 0, 8)
row.Size = UDim2.fromOffset(0, 60)
row.AutomaticSize = Enum.AutomaticSize.X
local list = Instance.new("UIListLayout")
list.FillDirection = Enum.FillDirection.Horizontal
list.VerticalAlignment = Enum.VerticalAlignment.Center
list.Padding = UDim.new(0, 12)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = row
local rowScale = Instance.new("UIScale")
rowScale.Parent = row
row.Parent = gui

type Counter = { set: (value: number) -> () }

local INK = Color3.fromHex("#120D17")
local FONT = Font.fromEnum(Enum.Font.FredokaOne)

-- Heavy outlined number (style D): white face, thick ink stroke, ink shadow.
local function bigText(parent: Instance, size: number): TextLabel
	local function make(name: string, offset: number): TextLabel
		local l = Instance.new("TextLabel")
		l.Name = name
		l.BackgroundTransparency = 1
		l.FontFace = FONT
		l.TextSize = size
		l.Text = "0"
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.Size = UDim2.fromScale(1, 1)
		l.Position = UDim2.fromOffset(0, offset)
		local stroke = Instance.new("UIStroke")
		stroke.Color = INK
		stroke.Thickness = math.max(2, size * 0.11)
		stroke.LineJoinMode = Enum.LineJoinMode.Round
		stroke.Parent = l
		l.Parent = parent
		return l
	end
	local shadow = make("Shadow", math.floor(size * 0.09))
	shadow.TextColor3 = INK
	local label = make("Label", 0)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.ZIndex = 2
	label:GetPropertyChangedSignal("Text"):Connect(function()
		shadow.Text = label.Text
	end)
	return label
end

local function counter(icon: string, order: number, withPlus: boolean): Counter
	-- Style D (references/ui/D1_hud.webp): a dark see-through pill, the icon
	-- big and breaking out of its left end, a heavy outlined number.
	local slab = Instance.new("Frame")
	slab.Name = "Counter_" .. icon
	slab.BackgroundColor3 = Color3.fromHex("#1B1530")
	slab.BackgroundTransparency = 0.35
	slab.Size = UDim2.fromOffset(0, 54)
	slab.AutomaticSize = Enum.AutomaticSize.X
	slab.LayoutOrder = order
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = slab
	-- The row (number, "+") flows in its own frame so the icon can sit outside it.
	local rowFrame = Instance.new("Frame")
	rowFrame.Name = "Row"
	rowFrame.BackgroundTransparency = 1
	rowFrame.Size = UDim2.fromOffset(0, 54)
	rowFrame.AutomaticSize = Enum.AutomaticSize.X
	rowFrame.Parent = slab
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 58)
	padding.PaddingRight = UDim.new(0, if withPlus then 4 else 18)
	padding.Parent = rowFrame
	local inner = Instance.new("UIListLayout")
	inner.FillDirection = Enum.FillDirection.Horizontal
	inner.VerticalAlignment = Enum.VerticalAlignment.Center
	inner.Padding = UDim.new(0, 8)
	inner.SortOrder = Enum.SortOrder.LayoutOrder
	inner.Parent = rowFrame

	local iconView = Instance.new("ImageLabel")
	iconView.Name = "Icon"
	iconView.BackgroundTransparency = 1
	iconView.Image = StyleIcons[icon].image
	iconView.ScaleType = Enum.ScaleType.Fit
	iconView.AnchorPoint = Vector2.new(0.5, 0.5)
	iconView.Size = UDim2.fromOffset(70, 70)
	iconView.Rotation = -8
	iconView.Position = UDim2.new(0, 22, 0.5, 0)
	iconView.ZIndex = 3
	iconView.Parent = slab

	local numberBox = Instance.new("Frame")
	numberBox.Name = "Number"
	numberBox.BackgroundTransparency = 1
	numberBox.Size = UDim2.fromOffset(0, 48)
	numberBox.AutomaticSize = Enum.AutomaticSize.X
	numberBox.LayoutOrder = 2
	numberBox.Parent = rowFrame
	local label = bigText(numberBox, 38)
	label.Size = UDim2.new(0, 0, 1, 0)
	label.AutomaticSize = Enum.AutomaticSize.X

	if withPlus then
		local plus = Instance.new("TextButton")
		plus.Name = "OpenShop"
		plus.Text = "+"
		plus.FontFace = FONT
		plus.TextSize = 36
		plus.TextColor3 = Color3.new(1, 1, 1)
		plus.Size = UDim2.fromOffset(48, 48)
		plus.LayoutOrder = 3
		plus.BackgroundColor3 = Color3.fromHex("#3BD86B")
		plus.AutoButtonColor = true
		local pc = Instance.new("UICorner")
		pc.CornerRadius = UDim.new(0, 12)
		pc.Parent = plus
		local ps = Instance.new("UIStroke")
		ps.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		ps.Color = INK
		ps.Thickness = 3
		ps.Parent = plus
		local ts = Instance.new("UIStroke")
		ts.Color = INK
		ts.Thickness = 3
		ts.Parent = plus
		plus.Activated:Connect(function()
			Controller.open("Shop")
		end)
		plus.Parent = rowFrame
	end

	local pop = Instance.new("UIScale")
	pop.Parent = slab
	slab.Parent = row

	local last: number? = nil
	return {
		set = function(value: number)
			label.Text = shorten(value)
			if last ~= nil and value > last and not GuiService.ReducedMotionEnabled then
				pop.Scale = 1.06
				TweenService:Create(pop, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
			end
			last = value
		end,
	}
end

local cash = counter("coin", 1, true)
local gems = counter("gem", 2, false)

-- Top centre on every device (menu buttons use both side edges); smaller on phones.
local function fit()
	local compact = gui.AbsoluteSize.Y < COMPACT_HEIGHT
	rowScale.Scale = if compact then 0.85 else 1 -- keeps the "+" at 44 px
	row.AnchorPoint = Vector2.new(0.5, 0)
	row.Position = UDim2.new(0.5, 0, 0, 8)
end
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
fit()

local function refreshGems()
	gems.set(tonumber(player:GetAttribute("Gems")) or 0)
end
player:GetAttributeChangedSignal("Gems"):Connect(refreshGems)
refreshGems()

task.spawn(function()
	local stats = player:WaitForChild("leaderstats", 30)
	local value = stats and stats:WaitForChild("Cash", 30)
	if value and (value:IsA("IntValue") or value:IsA("NumberValue")) then
		local v = value :: NumberValue
		cash.set(v.Value)
		v.Changed:Connect(function()
			cash.set(v.Value)
		end)
	else
		warn("[CurrencyHud] Add leaderstats.Cash (IntValue or NumberValue) on the server")
	end
end)

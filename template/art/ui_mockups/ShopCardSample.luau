--!strict
-- UI style D sample: one shop card built from real Roblox instances, to judge
-- the look in Studio next to references/ui/D3_shop.webp. Run in the command bar
-- or through MCP (Edit). Art is a local Studio preview (rbxasset://textures/ui_preview/...),
-- copied from template/art/icons/glossy and template/art/ui_textures; nothing is uploaded.
-- Builds StarterGui.UIStyleSample; delete it after judging.

local StarterGui = game:GetService("StarterGui")

local INK = Color3.fromRGB(22, 15, 43)
local FONT = Font.fromEnum(Enum.Font.FredokaOne)
local BODY = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold)

local old = StarterGui:FindFirstChild("UIStyleSample")
if old then
	old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "UIStyleSample"
gui.IgnoreGuiInset = true

local function corner(parent: Instance, r: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = parent
end

local function stroke(parent: Instance, thickness: number, mode: Enum.ApplyStrokeMode?)
	local s = Instance.new("UIStroke")
	s.Thickness = thickness
	s.Color = INK
	s.LineJoinMode = Enum.LineJoinMode.Round
	s.ApplyStrokeMode = mode or Enum.ApplyStrokeMode.Contextual
	s.Parent = parent
end

local function gradient(parent: Instance, top: Color3, bottom: Color3)
	local g = Instance.new("UIGradient")
	g.Rotation = 90
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, top),
		ColorSequenceKeypoint.new(0.45, top:Lerp(bottom, 0.55)),
		ColorSequenceKeypoint.new(1, bottom),
	})
	g.Parent = parent
end

local function studs(parent: GuiObject, tile: number)
	local img = Instance.new("ImageLabel")
	img.Name = "Studs"
	img.BackgroundTransparency = 1
	img.Size = UDim2.fromScale(1, 1)
	img.Image = "rbxasset://textures/ui_preview/stud_tile.png"
	img.ScaleType = Enum.ScaleType.Tile
	img.TileSize = UDim2.fromOffset(tile, tile)
	img.ZIndex = parent.ZIndex
	img.Parent = parent
	corner(img, 12)
end

-- Text with a heavy ink stroke and a dropped ink shadow underneath.
local function title(parent: Instance, text: string, size: number, pos: UDim2, box: UDim2, z: number, font: Font?)
	local function make(offset: number, color: Color3, zi: number): TextLabel
		local t = Instance.new("TextLabel")
		t.BackgroundTransparency = 1
		t.AnchorPoint = Vector2.new(0.5, 0.5)
		t.Position = pos + UDim2.fromOffset(0, offset)
		t.Size = box
		t.FontFace = font or FONT
		t.TextSize = size
		t.Text = text
		t.TextColor3 = color
		t.ZIndex = zi
		stroke(t, math.max(2, size * 0.12))
		t.Parent = parent
		return t
	end
	make(math.max(3, size * 0.1), INK, z) -- shadow
	return make(0, Color3.new(1, 1, 1), z + 1)
end

-- Backdrop that stands in for the game behind the window.
local back = Instance.new("Frame")
back.Size = UDim2.fromScale(1, 1)
back.BackgroundColor3 = Color3.fromRGB(70, 120, 90)
back.Parent = gui
gradient(back, Color3.fromRGB(120, 190, 255), Color3.fromRGB(70, 160, 80))

-- The card -----------------------------------------------------------------
local card = Instance.new("Frame")
card.Name = "Card"
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Position = UDim2.new(0.5, 0, 0.55, 0)
card.Size = UDim2.fromOffset(260, 320)
card.BackgroundColor3 = Color3.new(1, 1, 1)
card.ZIndex = 2
card.Parent = gui
corner(card, 18)
stroke(card, 5, Enum.ApplyStrokeMode.Border)
gradient(card, Color3.fromRGB(110, 240, 140), Color3.fromRGB(28, 178, 82))
studs(card, 26)

-- Inner bevel: light top edge
local bevel = Instance.new("Frame")
bevel.BackgroundColor3 = Color3.new(1, 1, 1)
bevel.BackgroundTransparency = 0.65
bevel.Position = UDim2.fromOffset(8, 6)
bevel.Size = UDim2.new(1, -16, 0, 5)
bevel.ZIndex = 3
bevel.Parent = card
corner(bevel, 3)

-- Big icon breaking out of the top edge
local icon = Instance.new("ImageLabel")
icon.Name = "Icon"
icon.BackgroundTransparency = 1
icon.AnchorPoint = Vector2.new(0.5, 0.5)
icon.Position = UDim2.new(0.5, 0, 0, 70)
icon.Size = UDim2.fromOffset(210, 210)
icon.Rotation = -6
icon.Image = "rbxasset://textures/ui_preview/gift.png"
icon.ZIndex = 6
icon.Parent = card

-- Tag (top-left) and tilted ribbon (top-right, over the edge)
local tag = Instance.new("Frame")
tag.Position = UDim2.fromOffset(-8, -14)
tag.Size = UDim2.fromOffset(104, 30)
tag.BackgroundColor3 = Color3.fromRGB(40, 32, 70)
tag.ZIndex = 7
tag.Parent = card
corner(tag, 15)
stroke(tag, 3, Enum.ApplyStrokeMode.Border)
title(tag, "FOREVER", 18, UDim2.fromScale(0.5, 0.5), UDim2.fromScale(1, 1), 8)

local ribbon = Instance.new("Frame")
ribbon.AnchorPoint = Vector2.new(1, 0)
ribbon.Position = UDim2.new(1, 18, 0, -18)
ribbon.Size = UDim2.fromOffset(112, 38)
ribbon.Rotation = 8
ribbon.BackgroundColor3 = Color3.new(1, 1, 1)
ribbon.ZIndex = 7
ribbon.Parent = card
corner(ribbon, 10)
stroke(ribbon, 4, Enum.ApplyStrokeMode.Border)
gradient(ribbon, Color3.fromRGB(255, 110, 120), Color3.fromRGB(225, 30, 60))
title(ribbon, "BEST!", 26, UDim2.fromScale(0.5, 0.5), UDim2.fromScale(1, 1), 8)

-- Name and perk
title(card, "Starter Pack", 38, UDim2.new(0.5, 0, 0, 192), UDim2.new(1, -16, 0, 44), 8)
title(card, "+500 Power  +100 Cash", 20, UDim2.new(0.5, 0, 0, 228), UDim2.new(1, -16, 0, 24), 8, BODY)

-- Price button: slab on a darker lip, with studs
local lip = Instance.new("Frame")
lip.AnchorPoint = Vector2.new(0.5, 1)
lip.Position = UDim2.new(0.5, 0, 1, -12)
lip.Size = UDim2.new(1, -28, 0, 58)
lip.BackgroundColor3 = Color3.fromRGB(176, 107, 0)
lip.ZIndex = 8
lip.Parent = card
corner(lip, 14)
stroke(lip, 4, Enum.ApplyStrokeMode.Border)

local face = Instance.new("Frame")
face.Size = UDim2.new(1, 0, 1, -7)
face.BackgroundColor3 = Color3.new(1, 1, 1)
face.ZIndex = 9
face.Parent = lip
corner(face, 14)
gradient(face, Color3.fromRGB(255, 232, 120), Color3.fromRGB(255, 170, 30))
studs(face, 22)
title(face, utf8.char(0xE002) .. " 49", 34, UDim2.fromScale(0.5, 0.5), UDim2.fromScale(1, 1), 11)

gui.Parent = StarterGui
return "built"

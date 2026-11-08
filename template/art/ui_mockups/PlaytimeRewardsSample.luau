-- UI style D sample v2: "Playtime Rewards" with bright gradients, a soft glow
-- behind every icon, rays on the big prize and tilted ribbons (direction from
-- the user's reference, 01.11.2026; our own layout, texts and icons — "Free Icon
-- Pack" by gvesster). Local Studio preview art: rbxasset://textures/item_art_d
-- and ui_preview (glow, rays, stripes, studs). Builds StarterGui.UIStyleSample.
local StarterGui = game:GetService("StarterGui")
local INK = Color3.fromHex("#14102A")
local FONT = Font.fromEnum(Enum.Font.FredokaOne)
local ART = "rbxasset://textures/item_art_d/"
local TEX = "rbxasset://textures/ui_preview/"

local old = StarterGui:FindFirstChild("UIStyleSample")
if old then old:Destroy() end
local gui = Instance.new("ScreenGui")
gui.Name = "UIStyleSample"
gui.IgnoreGuiInset = true

local function corner(p, r) local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r) c.Parent = p end
local function stroke(p, t, border, color)
	local s = Instance.new("UIStroke") s.Thickness = t s.Color = color or INK s.LineJoinMode = Enum.LineJoinMode.Round
	if border then s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border end
	s.Parent = p
end
local function grad(p, a, b, rot)
	local g = Instance.new("UIGradient") g.Rotation = rot or 90
	g.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, a), ColorSequenceKeypoint.new(0.5, a:Lerp(b, 0.55)), ColorSequenceKeypoint.new(1, b) })
	g.Parent = p
end
local function frame(parent, size, pos, color, z)
	local f = Instance.new("Frame") f.Size = size f.Position = pos or UDim2.new() f.BackgroundColor3 = color or Color3.new(1, 1, 1)
	f.BorderSizePixel = 0 f.ZIndex = z or 1 f.Parent = parent return f
end
local function image(parent, src, size, pos, z, rot, color, alpha)
	local i = Instance.new("ImageLabel") i.BackgroundTransparency = 1 i.Image = src
	i.AnchorPoint = Vector2.new(0.5, 0.5) i.Size = size i.Position = pos i.ZIndex = z i.Rotation = rot or 0
	if color then i.ImageColor3 = color end
	if alpha then i.ImageTransparency = alpha end
	i.Parent = parent return i
end
local function text(parent, s, size, pos, box, z, align, color)
	local function make(off, col, zi)
		local t = Instance.new("TextLabel") t.BackgroundTransparency = 1 t.AnchorPoint = Vector2.new(0.5, 0.5)
		t.Position = pos + UDim2.fromOffset(0, off) t.Size = box t.FontFace = FONT t.TextSize = size t.Text = s
		t.TextColor3 = col t.ZIndex = zi t.TextXAlignment = align or Enum.TextXAlignment.Center
		stroke(t, math.max(2, size * 0.12)) t.Parent = parent return t
	end
	make(math.max(2, math.floor(size * 0.1)), INK, z)
	return make(0, color or Color3.new(1, 1, 1), z + 1)
end
local function ribbon(parent, s, pos, rot, a, b, z)
	local r = frame(parent, UDim2.fromOffset(0, 32), pos, Color3.new(1, 1, 1), z)
	r.AutomaticSize = Enum.AutomaticSize.X r.AnchorPoint = Vector2.new(0.5, 0.5) r.Rotation = rot
	corner(r, 16) stroke(r, 3, true) grad(r, a, b)
	local pad = Instance.new("UIPadding") pad.PaddingLeft = UDim.new(0, 12) pad.PaddingRight = UDim.new(0, 12) pad.Parent = r
	local box = frame(r, UDim2.fromOffset(0, 32), nil, Color3.new(1, 1, 1), z) box.BackgroundTransparency = 1 box.AutomaticSize = Enum.AutomaticSize.X
	local t = text(box, s, 20, UDim2.fromScale(0.5, 0.5), UDim2.fromScale(1, 1), z + 1)
	t.AutomaticSize = Enum.AutomaticSize.X
	for _, l in box:GetChildren() do if l:IsA("TextLabel") then l.Size = UDim2.new(0, 0, 1, 0) l.AutomaticSize = Enum.AutomaticSize.X l.AnchorPoint = Vector2.new(0, 0.5) l.Position = UDim2.new(0, 0, 0.5, l.Position.Y.Offset) end end
	return r
end

-- game behind the window
local back = frame(gui, UDim2.fromScale(1, 1), nil)
grad(back, Color3.fromRGB(120, 190, 255), Color3.fromRGB(70, 160, 80))
local dim = frame(gui, UDim2.fromScale(1, 1), nil, Color3.fromHex("#0B0718"), 2) dim.BackgroundTransparency = 0.5

-- window: deep blue gradient with a soft light top
local W, H = 820, 620
local win = frame(gui, UDim2.fromOffset(W, H), UDim2.fromScale(0.5, 0.52), Color3.new(1, 1, 1), 3)
win.AnchorPoint = Vector2.new(0.5, 0.5) corner(win, 36) stroke(win, 5, true)
grad(win, Color3.fromHex("#2F7BF2"), Color3.fromHex("#16348F"))
local sheen = frame(win, UDim2.new(1, -16, 0, 120), UDim2.fromOffset(8, 6), Color3.new(1, 1, 1), 3)
sheen.BackgroundTransparency = 0.82 corner(sheen, 16)
local sg = Instance.new("UIGradient") sg.Rotation = 90 sg.Transparency = NumberSequence.new(0, 1) sg.Parent = sheen

-- title row
image(win, ART .. "clock.png", UDim2.fromOffset(104, 104), UDim2.fromOffset(52, 34), 8, -12)
text(win, "Playtime Rewards", 48, UDim2.new(0, 360, 0, 46), UDim2.fromOffset(480, 56), 7, Enum.TextXAlignment.Left)
local close = frame(win, UDim2.fromOffset(64, 64), UDim2.new(1, -20, 0, -8), Color3.new(1, 1, 1), 9)
close.AnchorPoint = Vector2.new(0.5, 0.5) corner(close, 32) stroke(close, 4, true) grad(close, Color3.fromHex("#FF6B6B"), Color3.fromHex("#E0202F"))
text(close, "X", 38, UDim2.fromScale(0.5, 0.48), UDim2.fromScale(1, 1), 10)
text(win, "Stay a little longer - the MEGA GIFT unlocks at 30:00!", 24, UDim2.new(0.5, 0, 0, 98), UDim2.fromOffset(760, 30), 7)

-- reward cards
local STYLE = {
	claimed = { Color3.fromHex("#8CF27C"), Color3.fromHex("#22B24A") },
	ready = { Color3.fromHex("#FF86CF"), Color3.fromHex("#E2338C") },
	locked = { Color3.fromHex("#74E6FF"), Color3.fromHex("#1E95F0") },
	mega = { Color3.fromHex("#D98BFF"), Color3.fromHex("#7B2BE6") },
}
local rewards = {
	{ "coin", "+500 CASH", "claimed" }, { "diamond_blue", "+15 GEMS", "claimed" }, { "potion", "LUCK x2", "ready" }, { "lightning", "+2K POWER", "locked", "5:00" },
	{ "chest", "+2,500 CASH", "locked", "10:00" }, { "key", "+1 KEY", "locked", "15:00" }, { "lucky_block", "LUCKY BLOCK", "locked", "20:00" }, { "gift", "MEGA GIFT", "mega", "30:00" },
}
local CW, CH, GX, GY = 180, 190, 14, 16
local x0 = (W - (CW * 4 + GX * 3)) / 2
for i, r in rewards do
	local col, row = (i - 1) % 4, (i - 1) // 4
	local kind = r[3]
	local colors = STYLE[kind]
	local card = frame(win, UDim2.fromOffset(CW, CH), UDim2.fromOffset(x0 + col * (CW + GX), 128 + row * (CH + GY)), Color3.new(1, 1, 1), 5)
	corner(card, 32) stroke(card, 4, true) grad(card, colors[1], colors[2])
	card.ClipsDescendants = false
	-- stripes and a top shine, both inside the card
	local tex = Instance.new("ImageLabel") tex.BackgroundTransparency = 1 tex.Size = UDim2.fromScale(1, 1) tex.Image = TEX .. "stripes.png"
	tex.ScaleType = Enum.ScaleType.Tile tex.TileSize = UDim2.fromOffset(48, 48) tex.ZIndex = 5 tex.Parent = card corner(tex, 32)
	local shine = frame(card, UDim2.new(1, -10, 0.42, 0), UDim2.fromOffset(5, 4), Color3.new(1, 1, 1), 5)
	shine.BackgroundTransparency = 0.78 corner(shine, 28)
	local shg = Instance.new("UIGradient") shg.Rotation = 90 shg.Transparency = NumberSequence.new(0, 1) shg.Parent = shine
	-- glow (and rays on the big prize) behind the icon
	if kind == "mega" then image(card, TEX .. "rays.png", UDim2.fromOffset(190, 190), UDim2.new(0.5, 0, 0, 66), 6, 0, Color3.fromHex("#FFF3B0"), 0.25) end
	image(card, TEX .. "glow.png", UDim2.fromOffset(150, 150), UDim2.new(0.5, 0, 0, 66), 6, 0, Color3.new(1, 1, 1), if kind == "ready" then 0.15 else 0.4)
	local art = image(card, ART .. r[1] .. ".png", UDim2.fromOffset(if kind == "mega" then 112 else 96, if kind == "mega" then 112 else 96), UDim2.new(0.5, 0, 0, 64), 7, if i % 2 == 0 then 6 else -6)
	text(card, r[2], 24, UDim2.new(0.5, 0, 0, 124), UDim2.new(1, -8, 0, 28), 8)
	if kind == "claimed" then
		art.ImageTransparency = 0.35
		image(card, ART .. "check.png", UDim2.fromOffset(76, 76), UDim2.new(0.5, 0, 0, 62), 9)
		text(card, "CLAIMED", 20, UDim2.new(0.5, 0, 1, -20), UDim2.new(1, -8, 0, 24), 8, nil, Color3.fromHex("#E9FFE3"))
	elseif kind == "ready" then
		local b = frame(card, UDim2.new(1, -24, 0, 38), UDim2.new(0, 12, 1, -46), Color3.fromHex("#B3156A"), 8) corner(b, 19) stroke(b, 3, true)
		local f = frame(b, UDim2.new(1, 0, 1, -5), nil, Color3.new(1, 1, 1), 9) corner(f, 19) grad(f, Color3.fromHex("#FFFFFF"), Color3.fromHex("#FFE1F2"))
		text(f, "CLAIM!", 24, UDim2.fromScale(0.5, 0.5), UDim2.fromScale(1, 1), 10, nil, Color3.fromHex("#FF4FA8"))
		ribbon(card, "NOW!", UDim2.new(1, -18, 0, -6), 10, Color3.fromHex("#FFE27A"), Color3.fromHex("#FFB224"), 11)
	else
		local pill = frame(card, UDim2.new(1, -36, 0, 30), UDim2.new(0, 18, 1, -40), Color3.fromHex("#0E1E55"), 8) pill.BackgroundTransparency = 0.35 corner(pill, 15)
		image(pill, ART .. "clock.png", UDim2.fromOffset(36, 36), UDim2.new(0, 8, 0.5, 0), 10)
		text(pill, r[4], 22, UDim2.new(0.5, 10, 0.5, 0), UDim2.fromScale(1, 1), 9)
		if kind == "mega" then ribbon(card, "MEGA!", UDim2.new(1, -20, 0, -6), 10, Color3.fromHex("#FF6B6B"), Color3.fromHex("#E0202F"), 11) end
	end
end

-- footer: time played + next gift slab
local fy = H - 46
image(win, ART .. "fire.png", UDim2.fromOffset(70, 70), UDim2.fromOffset(64, fy), 8, -8)
text(win, "PLAYED: 3:48", 34, UDim2.new(0, 230, 0, fy), UDim2.fromOffset(240, 40), 7, Enum.TextXAlignment.Left, Color3.fromHex("#FFD24A"))
local lip = frame(win, UDim2.fromOffset(360, 60), UDim2.new(1, -24, 0, fy), Color3.fromHex("#6E7380"), 7)
lip.AnchorPoint = Vector2.new(1, 0.5) corner(lip, 30) stroke(lip, 4, true)
local face = frame(lip, UDim2.new(1, 0, 1, -6), nil, Color3.new(1, 1, 1), 8) corner(face, 30) grad(face, Color3.fromHex("#E9ECF2"), Color3.fromHex("#AEB4C0"))
local fs = Instance.new("ImageLabel") fs.BackgroundTransparency = 1 fs.Size = UDim2.fromScale(1, 1) fs.Image = TEX .. "stud_tile.png"
fs.ScaleType = Enum.ScaleType.Tile fs.TileSize = UDim2.fromOffset(22, 22) fs.ImageTransparency = 0.3 fs.ZIndex = 8 fs.Parent = face corner(fs, 30)
text(face, "NEXT IN 01:12", 34, UDim2.fromScale(0.5, 0.5), UDim2.fromScale(1, 1), 9)

gui.Parent = StarterGui
return "built"

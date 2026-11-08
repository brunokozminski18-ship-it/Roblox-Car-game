--!strict
--[[
	Style D components (approved Playtime Rewards sample). Each returns its root instance (plus small helpers where
	useful). Windows are compatible with LihFolkUIController.register, which
	fits them to the screen, dims the background and handles closing.
	Sizes are design units; the controller scales the whole window.
]]

local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local Theme = require(script.Parent.StyleD)
local Icons = require(script.Parent.Icons)

-- Required lazily: the controller is only needed once a window resizes.
local function Controller()
	return require(game:GetService("ReplicatedStorage"):WaitForChild("LihFolkUI"):WaitForChild("LihFolkUIController"))
end

type Swatch = {top: Color3, bottom: Color3, border: Color3}

local C = Theme.Color
local S = Theme.Size

local Components = {}

---------------------------------------------------------------------------
-- Primitives
---------------------------------------------------------------------------
local function corner(parent: GuiObject, radius: number?)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or S.radius)
	c.Parent = parent
end

local function border(parent: GuiObject, color: Color3, thickness: number?)
	local s = Instance.new("UIStroke")
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Color = color
	s.Thickness = thickness or 2
	s.Parent = parent
	return s
end

local function gradient(parent: GuiObject, top: Color3, bottom: Color3)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, top), ColorSequenceKeypoint.new(0.5, top:Lerp(bottom, 0.55)), ColorSequenceKeypoint.new(1, bottom)})
	g.Rotation = 90
	g.Parent = parent
end

local function blank(name: string, size: UDim2?): Frame
	local f = Instance.new("Frame")
	f.Name = name
	f.BackgroundTransparency = 1
	f.BorderSizePixel = 0
	f.Size = size or UDim2.fromScale(1, 1)
	return f
end

export type TextProps = {
	size: number?,
	font: Font?,
	color: Color3?,
	align: Enum.TextXAlignment?,
	box: UDim2?,
	position: UDim2?,
	anchor: Vector2?,
	wrap: boolean?,
	autoX: boolean?,
	outline: boolean?, -- dark text outline (default on)
	layoutOrder: number?,
	parent: Instance?,
}

-- An outlined Fredoka label in style D. Fixed text size in design units (the window's UIScale
-- scales it); long text truncates. No TextScaled: it measures before
-- Fredoka loads and then keeps the too-small size.
function Components.Text(text: string, props: TextProps?): TextLabel
	local p: TextProps = props or {}
	local size = p.size or 20
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Text = text
	label.FontFace = p.font or Theme.Font.heavy
	label.TextColor3 = p.color or C.text
	label.TextXAlignment = p.align or Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Size = p.box or UDim2.new(1, 0, 0, size + 8)
	label.Position = p.position or UDim2.new()
	label.AnchorPoint = p.anchor or Vector2.zero
	label.LayoutOrder = p.layoutOrder or 0
	label.TextSize = math.max(size, S.minText)
	if p.autoX then
		label.AutomaticSize = Enum.AutomaticSize.X
	else
		label.TextWrapped = p.wrap == true
		label.TextTruncate = Enum.TextTruncate.AtEnd
	end
	if p.outline ~= false then
		local s = Instance.new("UIStroke")
		s.Color = C.ink
		s.Thickness = math.max(2, size * S.outline)
		s.Transparency = 0
		s.LineJoinMode = Enum.LineJoinMode.Round
		s.Parent = label
	end
	local shadow = label:Clone()
 shadow.Name = "Shadow"
 shadow.TextColor3 = C.ink
 shadow.AnchorPoint = Vector2.zero
 shadow.Position = UDim2.fromOffset(0, math.max(2, math.floor(size * S.shadow)))
 shadow.Size = UDim2.fromScale(1, 1)
 shadow.AutomaticSize = Enum.AutomaticSize.None
 shadow.ZIndex = 1
 label.ZIndex = 2
 local face = label:Clone()
 face.Name="Face" face.AnchorPoint=Vector2.zero face.Position=UDim2.new() face.Size=UDim2.fromScale(1,1)
 face.AutomaticSize=Enum.AutomaticSize.None face.ZIndex=2
 shadow.Parent = label
 face.Parent=label
 label:GetPropertyChangedSignal("TextColor3"):Connect(function() face.TextColor3=label.TextColor3 end)
 for _, property in {"Text", "TextSize", "TextXAlignment", "TextYAlignment", "TextWrapped", "TextTruncate", "FontFace", "TextTransparency"} do
  label:GetPropertyChangedSignal(property):Connect(function() (shadow :: any)[property] = (label :: any)[property]; (face :: any)[property] = (label :: any)[property] end)
 end
 if p.parent then
  label.Parent = p.parent
	end
	return label
end

-- Diagonal texture bands from the approved D sample.
function Components.Stripes(parent: GuiObject)
 local overlay = Instance.new("ImageLabel")
 overlay.Name = "Stripes"
 overlay.BackgroundTransparency = 1
 overlay.Size = UDim2.fromScale(1,1)
 overlay.Image = Theme.Texture .. "stripes.png"
 overlay.ScaleType = Enum.ScaleType.Tile
 overlay.TileSize = UDim2.fromOffset(S.textureTile,S.textureTile)
 overlay.ZIndex = parent.ZIndex
 corner(overlay, S.cardRadius)
 overlay.Parent = parent
 return overlay
end

local function sheen(parent: GuiObject, height: number?)
 local f = blank("Sheen", UDim2.new(1,-10,height or .42,0))
 f.Position = UDim2.fromOffset(5,4)
 f.BackgroundTransparency = .82
 f.BackgroundColor3 = C.text
 corner(f, S.cardRadius)
 local g = Instance.new("UIGradient") g.Rotation=90 g.Transparency=NumberSequence.new(0,1) g.Parent=f
 f.Parent=parent
 return f
end

function Components.Rays(parent: Instance): ImageLabel
 local i=Instance.new("ImageLabel") i.Name="Rays" i.BackgroundTransparency=1
 i.Image=Theme.Texture .. "rays.png" i.ImageColor3=C.gold i.ImageTransparency=.25
 i.AnchorPoint=Vector2.new(.5,.5) i.Position=UDim2.fromScale(.5,.34) i.Size=UDim2.fromScale(1.05,1.05)
 i.Parent=parent return i
end

function Components.SetCardState(card: GuiObject, state: string)
 local family = Theme.Card[state] or Theme.Card.locked
 local g=card:FindFirstChildOfClass("UIGradient")
 if g then g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,family.top),ColorSequenceKeypoint.new(.5,family.top:Lerp(family.bottom,.55)),ColorSequenceKeypoint.new(1,family.bottom)}) end
end

---------------------------------------------------------------------------
-- Buttons
---------------------------------------------------------------------------
export type ButtonProps = {
	text: string?,
	price: number?, -- shows the Robux mark and the price
	swatch: Swatch?,
	textSize: number?,
	size: UDim2?,
	position: UDim2?,
	anchor: Vector2?,
	name: string?,
	layoutOrder: number?,
	parent: Instance?,
	onActivated: (() -> ())?,
}

export type Button = {
	root: TextButton,
	hit: TextButton,
	label: TextLabel,
	setText: (text: string) -> (),
	setSwatch: (swatch: Swatch) -> (),
}

local function formatNumber(n: number): string
	local s = tostring(math.floor(n))
	return (s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end
Components.formatNumber = formatNumber

function Components.Button(props: ButtonProps): Button
	local swatch = props.swatch or Theme.Button.green
	local button = Instance.new("TextButton")
	button.Name = props.name or "Button"
	button.Text = ""
	button.AutoButtonColor = false
	button.BackgroundColor3 = Color3.new(1, 1, 1)
	button.BorderSizePixel = 0
	button.Size = props.size or UDim2.fromOffset(220, S.button)
	button.Position = props.position or UDim2.new()
	button.AnchorPoint = props.anchor or Vector2.zero
	button.LayoutOrder = props.layoutOrder or 0
	corner(button, S.pillRadius)
	local stroke = border(button, C.ink, S.buttonStroke)
	local g = Instance.new("UIGradient")
	g.Rotation = 90
	g.Parent = button

	-- Rounded shine along the upper face.
	local shine = blank("Shine", UDim2.new(1, -10, 0.4, 0))
	shine.Position = UDim2.fromOffset(2, 2)
	shine.BackgroundTransparency = 0.55
	shine.BackgroundColor3 = Color3.new(1, 1, 1)
	corner(shine, S.pillRadius)
	shine.Parent = button

	local text = props.text or ""
	if props.price then
		text = Theme.ROBUX .. " " .. formatNumber(props.price)
	end
	local size = props.textSize or 26
	local label = Components.Text(text, {
		size = size,
		font = Theme.Font.title,
		align = Enum.TextXAlignment.Center,
		box = UDim2.new(1, -16, 1, -8),
		position = UDim2.fromScale(0.5, 0.5),
		anchor = Vector2.new(0.5, 0.5),
		parent = button,
	})

	local scale = Instance.new("UIScale")
	scale.Parent = button
	local function press(down: boolean)
		if GuiService.ReducedMotionEnabled then
			return
		end
		TweenService:Create(scale, TweenInfo.new(0.06, Enum.EasingStyle.Quad), { Scale = if down then 0.96 else 1 }):Play()
	end
	button.MouseButton1Down:Connect(function()
		press(true)
	end)
	button.MouseButton1Up:Connect(function()
		press(false)
	end)
	button.MouseLeave:Connect(function()
		press(false)
	end)
	if props.onActivated then
		button.Activated:Connect(props.onActivated)
	end

	local studs=Instance.new("ImageLabel") studs.Name="Studs" studs.BackgroundTransparency=1 studs.Size=UDim2.fromScale(1,1)
 studs.Image=Theme.Texture .. "stud_tile.png" studs.ScaleType=Enum.ScaleType.Tile studs.TileSize=UDim2.fromOffset(22,22) studs.ImageTransparency=.3
 corner(studs,S.pillRadius) studs.Parent=button
 local function setSwatch(sw: Swatch)
		g.Color = ColorSequence.new(sw.top, sw.bottom)
		studs.Visible = sw == Theme.Button.grey
		stroke.Color = C.ink
		label.TextColor3 = if sw == Theme.Button.green then C.pink else C.text
	end
	setSwatch(swatch)

	if props.parent then
		button.Parent = props.parent
	end
	return {
		root = button,
		hit = button,
		label = label,
		setText = function(t: string)
			label.Text = t
		end,
		setSwatch = setSwatch,
	}
end

function Components.CloseButton(onActivated: () -> ()): Button
	local b = Components.Button({
		text = "X",
		swatch = Theme.Button.red,
		textSize = 30,
		name = "Close",
		size = UDim2.fromOffset(S.close, S.close),
		onActivated = onActivated,
	})

	return b
end

---------------------------------------------------------------------------
-- Cards and decorations
---------------------------------------------------------------------------
export type CardProps = {
	family: Swatch,
	size: UDim2?,
	name: string?,
	layoutOrder: number?,
	parent: Instance?,
}

function Components.Card(props: CardProps): Frame
	local card = blank(props.name or "Card", props.size)
	card.BackgroundTransparency = 0
	card.BackgroundColor3 = Color3.new(1, 1, 1)
	card.ClipsDescendants = false
	card.LayoutOrder = props.layoutOrder or 0
	corner(card, S.cardRadius)
	gradient(card, props.family.top, props.family.bottom)
	border(card, C.ink, S.cardStroke)
	Components.Stripes(card)
	sheen(card)
	if props.parent then
		card.Parent = props.parent
	end
	return card
end

-- Red NEW ribbon for the top-right corner of a card.
function Components.Ribbon(text: string, parent: Instance): Frame
 local ribbon=blank("Ribbon", UDim2.fromOffset(112,34))
 ribbon.AnchorPoint=Vector2.new(.5,.5) ribbon.Position=UDim2.new(1,-20,0,-6)
 ribbon.Rotation=10 ribbon.BackgroundTransparency=0 ribbon.BackgroundColor3=C.text ribbon.ZIndex=8
 corner(ribbon,S.pillRadius) border(ribbon,C.ink,S.buttonStroke)
 gradient(ribbon,if text=="NOW!" then C.gold else Theme.Button.red.top,if text=="NOW!" then C.gold else Theme.Button.red.bottom)
 Components.Text(text,{size=22,align=Enum.TextXAlignment.Center,box=UDim2.fromScale(1,1),parent=ribbon}).ZIndex=9
 ribbon.Parent=parent return ribbon
end

-- Item art. Pass an image id when there is one; otherwise a soft spotlight
-- marks where the render will go (no letters, no fake icons).
function Components.ItemArt(image: string?, size: UDim2, parent: Instance): GuiObject
	if image and image ~= "" then
		local art = Instance.new("ImageLabel")
		art.Name = "Art"
		art.BackgroundTransparency = 1
		art.Image = image
		art.ScaleType = Enum.ScaleType.Fit
		art.Size = size
		local glow = Instance.new("ImageLabel")
  glow.Name="Glow" glow.BackgroundTransparency=1 glow.Image=Theme.Texture .. "glow.png"
  glow.AnchorPoint=Vector2.new(.5,.5) glow.Position=UDim2.fromScale(.5,.5)
  glow.Size=UDim2.fromScale(1.55,1.55) glow.ImageTransparency=.4 glow.ZIndex=1 glow.Parent=art
  local face=art:Clone() face.Name="ArtFace" face:ClearAllChildren() face.Size=UDim2.fromScale(1,1) face.ZIndex=2 face.Parent=art
  for _,property in {"Image", "ImageTransparency", "ImageColor3"} do
   art:GetPropertyChangedSignal(property):Connect(function() (face :: any)[property]=(art :: any)[property] end)
  end
  art.ZIndex=2
  art.Parent = parent
  return art
	end
	local slot = blank("ArtSlot", size)
	slot.BackgroundTransparency = 0
	slot.BackgroundColor3 = Color3.new(1, 1, 1)
	local g = Instance.new("UIGradient")
	g.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.86),
		NumberSequenceKeypoint.new(1, 1),
	})
	g.Parent = slot
	Components.Text("ITEM ART", {
		size = 15,
		font = Theme.Font.bold,
		color = C.textMuted,
		outline = false,
		align = Enum.TextXAlignment.Center,
		box = UDim2.new(1, 0, 0, 20),
		position = UDim2.fromScale(0.5, 0.5),
		anchor = Vector2.new(0.5, 0.5),
		parent = slot,
	})
	slot.Parent = parent
	return slot
end

function Components.SectionTitle(text: string, layoutOrder: number, parent: Instance): TextLabel
	return Components.Text(string.upper(text), {
		size = 32,
		font = Theme.Font.title,
		box = UDim2.new(1, 0, 0, 44),
		layoutOrder = layoutOrder,
		parent = parent,
	})
end

---------------------------------------------------------------------------
-- Window
---------------------------------------------------------------------------
export type WindowProps = {
	name: string,
	title: string,
	size: Vector2?,
	header: number?,
	footer: number?,
}

-- Returns a table LihFolkUIController.register accepts, plus `tabs` (a strip
-- between the title and the close button) and `body` (scrolling content).
function Components.Window(props: WindowProps)
 local design=props.size or S.window
 local root=blank(props.name,UDim2.fromOffset(design.X,design.Y))
 root.AnchorPoint=Vector2.new(.5,.5) root.Position=UDim2.fromScale(.5,.5) root.Visible=false
 local fitScale=Instance.new("UIScale") fitScale.Name="Fit" fitScale.Parent=root
 local panel=blank("Panel",UDim2.new(1,-S.insetX*2,1,-S.insetTop-S.insetBottom))
 panel.Position=UDim2.fromOffset(S.insetX,S.insetTop) panel.BackgroundTransparency=0 panel.BackgroundColor3=C.text panel.Active=true
 corner(panel,S.radius) gradient(panel,C.windowTop,C.windowBottom) border(panel,C.ink,S.windowStroke) panel.Parent=root
 local motionScale=Instance.new("UIScale") motionScale.Name="Motion" motionScale.Parent=panel
 sheen(panel,.22)
 local key=string.lower(props.name)
 local icon=Icons[key] or (if key=="eggs" then Icons.egg else Icons.gift)
 local art=Instance.new("ImageLabel") art.Name="TitleIcon" art.BackgroundTransparency=1 art.Image=icon.image
 art.AnchorPoint=Vector2.new(.5,.5) art.Position=UDim2.fromOffset(52,28) art.Size=UDim2.fromOffset(S.icon,S.icon) art.Rotation=-12 art.ZIndex=8 art.Parent=panel
 local title=Components.Text(props.title,{size=S.title,box=UDim2.new(1,-170,0,64),position=UDim2.fromOffset(110,6),parent=panel}) title.Name="Title" title.ZIndex=7
 local window: any={name=props.name,designSize=design,root=root,panel=panel,fitScale=fitScale,motionScale=motionScale,loops={},requestClose=function() end}
 local close=Components.CloseButton(function() window.requestClose() end)
 close.root.AnchorPoint=Vector2.new(.5,.5) close.root.Position=UDim2.new(1,-20,0,-8) close.root.ZIndex=12 close.label.ZIndex=13 close.root.Parent=panel
 window.closeButton=close
 local tabs=blank("Tabs",UDim2.new(1,-48,0,S.tab)) tabs.Position=UDim2.fromOffset(24,S.header-10) tabs.Parent=panel
 local tabList=Instance.new("UIListLayout") tabList.FillDirection=Enum.FillDirection.Horizontal tabList.HorizontalFlex=Enum.UIFlexAlignment.Fill tabList.Padding=UDim.new(0,12) tabList.SortOrder=Enum.SortOrder.LayoutOrder tabList.Parent=tabs
 window.tabs=tabs
 local body=Instance.new("ScrollingFrame") body.Name="Body" body.BackgroundTransparency=1 body.BorderSizePixel=0
 body.CanvasSize=UDim2.new() body.AutomaticCanvasSize=Enum.AutomaticSize.Y body.ScrollingDirection=Enum.ScrollingDirection.Y body.ScrollBarThickness=6 body.ScrollBarImageColor3=C.scrollBar body.Selectable=false
 local pad=Instance.new("UIPadding") pad.PaddingTop=UDim.new(0,12) pad.PaddingBottom=UDim.new(0,16) pad.PaddingLeft=UDim.new(0,12) pad.PaddingRight=UDim.new(0,18) pad.Parent=body
 local list=Instance.new("UIListLayout") list.Padding=UDim.new(0,16) list.SortOrder=Enum.SortOrder.LayoutOrder list.Parent=body body.Parent=panel window.body=body
 local function chrome(): number
  local hasTabs=false
  for _,child in tabs:GetChildren() do if child:IsA("GuiObject") then hasTabs=true break end end
  tabs.Visible=hasTabs
  local compact=root.AbsoluteSize.Y<450
  local header=if compact then S.compactHeader else (props.header or S.header)
  title.TextSize=if compact then S.compactTitle else S.title
  art.Size=UDim2.fromOffset(if compact then S.compactIcon else S.icon,if compact then S.compactIcon else S.icon)
  tabs.Position=UDim2.fromOffset(24,header-10)
  local top=header + (if hasTabs then S.tab+8 else 0)
  body.Position=UDim2.fromOffset(12,top) body.Size=UDim2.new(1,-24,1,-top-12)
  return top+S.insetTop+S.insetBottom+40+(if compact then 0 else (props.footer or 0))
 end
 local function fitToContent()
  local scale=fitScale.Scale*motionScale.Scale
  if scale<=0 then return end
  local wanted=math.clamp(math.ceil(chrome()+list.AbsoluteContentSize.Y/scale),240,design.Y)
  if math.abs(wanted-window.designSize.Y)>2 then
   window.designSize=Vector2.new(design.X,wanted) Controller().refresh()
  end
 end
 tabs.ChildAdded:Connect(fitToContent) tabs.ChildRemoved:Connect(fitToContent)
 list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(fitToContent)
 fitScale:GetPropertyChangedSignal("Scale"):Connect(fitToContent)
 root:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitToContent)
 window.fitToContent=fitToContent chrome()
 return window
end

-- A tab in the window's strip. The active tab is a light slab in the
-- window's own colour (its menu button colour), inactive tabs are grey.
function Components.Tab(text: string, order: number, parent: Instance, onActivated: () -> ())
	local active: Swatch = Theme.Button.active
	local b = Components.Button({
		text = string.upper(text),
		swatch = Theme.Button.grey,
		textSize = 19,
		name = "Tab_" .. text,
		size = UDim2.new(0, 60, 1, 0),
		layoutOrder = order,
		parent = parent,
		onActivated = onActivated,
	})
	return {
		root = b.root,
		setActive = function(isActive: boolean)
			b.setSwatch(if isActive then active else Theme.Button.grey)
		end,
	}
end

---------------------------------------------------------------------------
-- Panels, progress, toggles
---------------------------------------------------------------------------
-- A rounded inner box for codes and selected-item details.
function Components.Panel(size: UDim2, layoutOrder: number?, parent: Instance?): Frame
	local f = Instance.new("Frame")
	f.Name = "Panel"
	f.BackgroundColor3 = C.panel
	f.BorderSizePixel = 0
	f.Size = size
	f.LayoutOrder = layoutOrder or 0
	corner(f, S.cardRadius)
	border(f, C.divider, 2)
	if parent then
		f.Parent = parent
	end
	return f
end

-- Non-interactive countdown pill from the approved rewards sample.
function Components.Pill(text: string, parent: Instance)
 local root=Components.Panel(UDim2.new(1,-36,0,36),nil,parent)
 root.Name="Countdown" root.BackgroundColor3=C.field root.BackgroundTransparency=.35
 local stroke=root:FindFirstChildOfClass("UIStroke") if stroke then stroke.Enabled=false end
 local icon=Instance.new("ImageLabel") icon.BackgroundTransparency=1 icon.Image=Theme.Art .. "clock.png"
 icon.AnchorPoint=Vector2.new(.5,.5) icon.Position=UDim2.new(0,12,.5,0) icon.Size=UDim2.fromOffset(36,36) icon.ZIndex=3 icon.Parent=root
 local label=Components.Text(text,{size=22,align=Enum.TextXAlignment.Center,box=UDim2.new(1,-24,1,0),position=UDim2.fromOffset(20,0),parent=root})
 return {root=root,label=label}
end

export type ProgressBar = { root: Frame, set: (have: number, need: number, text: string?) -> () }

-- Gold fill on a rounded dark track with progress in the middle.
function Components.ProgressBar(size: UDim2, parent: Instance?, layoutOrder: number?): ProgressBar
	local track = blank("Progress", size)
	track.BackgroundTransparency = 0
	track.BackgroundColor3 = C.progressTrack
	track.LayoutOrder = layoutOrder or 0
	corner(track, S.pillRadius)
	border(track, C.divider, 2)
	local fill = blank("Fill", UDim2.fromScale(0, 1))
	fill.BackgroundTransparency = 0
	fill.BackgroundColor3 = Color3.new(1, 1, 1)
	corner(fill, S.pillRadius)
	gradient(fill, C.gold, C.gold)
	fill.Parent = track
	local label = Components.Text("", {
		size = 22,
		font = Theme.Font.title,
		align = Enum.TextXAlignment.Center,
		box = UDim2.fromScale(1, 1),
		parent = track,
	})
	label.ZIndex = 3
	if parent then
		track.Parent = parent
	end
	return {
		root = track,
		set = function(have: number, need: number, text: string?)
			local t = if need > 0 then math.clamp(have / need, 0, 1) else 0
			fill.Size = UDim2.fromScale(math.max(t, if t > 0 then 0.02 else 0), 1)
			label.Text = text or `{formatNumber(have)} / {formatNumber(need)}`
		end,
	}
end

export type Toggle = { root: TextButton, set: (on: boolean) -> (), get: () -> boolean }

-- ON/OFF switch: green slab when on, grey when off, the word always shown.
function Components.Toggle(value: boolean, onChanged: (on: boolean) -> ()): Toggle
	local state = value
	local b = Components.Button({ text = "", swatch = Theme.Button.grey, textSize = 22, size = UDim2.fromOffset(120, S.button), name = "Toggle" })
	local function render()
		b.setSwatch(if state then Theme.Button.green else Theme.Button.grey)
		b.setText(if state then "ON" else "OFF")
	end
	b.root.Activated:Connect(function()
		state = not state
		render()
		onChanged(state)
	end)
	render()
	return {
		root = b.root,
		set = function(on: boolean)
			state = on
			render()
		end,
		get = function()
			return state
		end,
	}
end

-- A small rounded tag ("CLAIMED", "x3", "LV 1").
function Components.Tag(text: string, color: Color3, parent: Instance?): Frame
	local tag = blank("Tag", UDim2.fromOffset(0, 26))
	tag.AutomaticSize = Enum.AutomaticSize.X
	tag.BackgroundTransparency = 0
	tag.BackgroundColor3 = color
	tag.ZIndex = 4
	corner(tag, S.pillRadius)
	border(tag, C.ink, 2)
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	pad.Parent = tag
	local label = Components.Text(text, { size = 16, font = Theme.Font.title, autoX = true, box = UDim2.fromScale(0, 1), parent = tag })
	label.ZIndex = 5
	if parent then
		tag.Parent = parent
	end
	return tag
end

-- A card in a rarity colour (pets, items). Same frame as Card.
function Components.RarityCard(rarity: string, props: { size: UDim2?, layoutOrder: number?, parent: Instance? }): Frame
	return Components.Card({
		family = Theme.Rarity[rarity] or Theme.Rarity.common,
		size = props.size,
		layoutOrder = props.layoutOrder,
		parent = props.parent,
	})
end

-- Undiscovered entry: a dark rounded silhouette and "???" (layout from A3).
function Components.Silhouette(parent: Instance): Frame
	local shape = blank("Silhouette", UDim2.fromScale(0.62, 0.85))
	shape.AnchorPoint = Vector2.new(0.5, 0.5)
	shape.Position = UDim2.fromScale(0.5, 0.48)
	shape.BackgroundTransparency = 0
	shape.BackgroundColor3 = C.silhouette
	shape.BackgroundTransparency = 0.15
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0.45, 0)
	c.Parent = shape
	local ratio = Instance.new("UIAspectRatioConstraint")
	ratio.AspectRatio = 0.85
	ratio.Parent = shape
	shape.Parent = parent
	Components.Text("?", {
		size = 34,
		font = Theme.Font.title,
		color = C.textMuted,
		align = Enum.TextXAlignment.Center,
		box = UDim2.fromScale(1, 1),
		parent = shape,
	})
	return shape
end


return Components

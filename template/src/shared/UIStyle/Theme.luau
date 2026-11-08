--!strict
--[[
	Style B tokens: navy-graphite windows, thin frames, flat grey tabs,
	upper-case Montserrat, green Robux buttons, red close.
	Rules and sources: playbook/UI_STYLE.md. Change colours here, not in components.
]]

local Theme = {}

local function hex(value: string): Color3
	return Color3.fromHex(value)
end

export type Swatch = { top: Color3, bottom: Color3, border: Color3 }

Theme.Color = {
	windowTop = hex("#283A4C"),
	windowBottom = hex("#18222D"),
	windowBorder = hex("#5D6873"),
	divider = hex("#4A5561"),
	ink = hex("#0B0F14"), -- text outlines and dark borders
	text = hex("#FFFFFF"),
	textDim = hex("#E2E7EE"), -- secondary text: light enough for phones
	textMuted = hex("#B3BDC9"),
	timer = hex("#FF4D4D"),
	tier = hex("#F2C230"),
	money = hex("#FFFFFF"),
	field = hex("#0B1117"),
	fieldBorder = hex("#6A7682"),
	panel = hex("#121A22"),
	ribbon = hex("#D62B2B"),
	ribbonDark = hex("#8E1414"),
	scrollBar = hex("#5D6873"),
}

-- Buttons and tabs: gradient face plus border.
Theme.Button = {
	green = { top = hex("#52E052"), bottom = hex("#1E9F1E"), border = hex("#0E3A0E") } :: Swatch,
	grey = { top = hex("#6E7276"), bottom = hex("#3F4347"), border = hex("#16191C") } :: Swatch,
	-- Fallback only: tabs normally use a light slab in their window's colour (Components.Tab).
	active = { top = hex("#FFA53A"), bottom = hex("#E8731A"), border = hex("#FFFFFF") } :: Swatch,
	red = { top = hex("#E5484A"), bottom = hex("#B8282C"), border = hex("#4A0B0D") } :: Swatch,
}

-- Card families: dark face with a thin frame in the category colour.
Theme.Card = {
	offer = { top = hex("#3C4D61"), bottom = hex("#233141"), border = hex("#A9B4BF") } :: Swatch,
	cash = { top = hex("#22874F"), bottom = hex("#13502E"), border = hex("#52DE90") } :: Swatch,
	pass = { top = hex("#2D7AC2"), bottom = hex("#194A78"), border = hex("#72B8F5") } :: Swatch,
	vip = { top = hex("#94721F"), bottom = hex("#4E3A0F"), border = hex("#F5C652") } :: Swatch,
}

-- Rarity: card face for pets/items (layout from A3, colours tuned to style B).
Theme.Rarity = {
	common = { top = hex("#5E6670"), bottom = hex("#3A4048"), border = hex("#9AA3AD") } :: Swatch,
	uncommon = { top = hex("#2F8F47"), bottom = hex("#1A5229"), border = hex("#5FD27D") } :: Swatch,
	rare = { top = hex("#2563C9"), bottom = hex("#143B7D"), border = hex("#5C9BFF") } :: Swatch,
	epic = { top = hex("#8A35D6"), bottom = hex("#4E1C80"), border = hex("#C084FF") } :: Swatch,
	legendary = { top = hex("#D99A1C"), bottom = hex("#7A520C"), border = hex("#FFD35C") } :: Swatch,
	unknown = { top = hex("#20262E"), bottom = hex("#12161B"), border = hex("#3C4652") } :: Swatch,
}

Theme.Color.progress = hex("#F2C230")
Theme.Color.progressTrack = hex("#0B1117")
Theme.Color.good = hex("#52E052")
Theme.Color.tile = hex("#3C4652")

local FAMILY ="rbxasset://fonts/families/Montserrat.json"
Theme.Font = {
	title = Font.new(FAMILY, Enum.FontWeight.Heavy),
	heavy = Font.new(FAMILY, Enum.FontWeight.ExtraBold),
	bold = Font.new(FAMILY, Enum.FontWeight.Bold),
}

Theme.Size = {
	window = Vector2.new(960, 600),
	header = 76,
	tab = 52, -- 44 px on phones at the 0.85 touch scale
	close = 52,
	button = 52,
	minText = 15,
	radius = 4,
}

Theme.ROBUX = utf8.char(0xE002) -- Robux mark from Roblox's own font

return Theme

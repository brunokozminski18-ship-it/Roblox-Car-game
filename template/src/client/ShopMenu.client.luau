--!strict
--[[
	SHOP in style D (playbook/UI_STYLE.md). Our own layout:
	  OFFERS   full-width candy cards, with a featured reward and rays
	  PASSES   full-width rows: art, name and perk, price
	  PACKS    two-column grid
	  CODES    one inline row: field + REDEEM
	Tabs jump to their section.

	Content: GameConfig.ShopDisplay. Robux buttons ask the server to prompt
	(Shop.PromptProduct / Shop.PromptPass); with id = 0 the server refuses and
	nothing is prompted. Grants happen only in the server's ProcessReceipt.
	Codes: Codes.Redeem. Art: UIStyle/ItemArt (Free Icon Pack local preview).
	Content is neutral (Item 1, Pass 1) until there is a game.
]]

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LihFolkUI = ReplicatedStorage:WaitForChild("LihFolkUI")
local Controller = require(LihFolkUI:WaitForChild("LihFolkUIController"))
local Style = ReplicatedStorage:WaitForChild("UIStyle")
local Theme = require(Style:WaitForChild("StyleD"))
local UI = require(Style:WaitForChild("Components"))
local Launcher = require(Style:WaitForChild("Launcher"))
local Toast = require(Style:WaitForChild("Toast"))
local ItemArt = require(Style:WaitForChild("ItemArt"))
local Net = require(ReplicatedStorage:WaitForChild("LihFolk"):WaitForChild("Net"))
local Feedback = require(ReplicatedStorage:WaitForChild("LihFolk"):WaitForChild("Feedback"))
local Config = require(ReplicatedStorage:WaitForChild("GameConfig")) :: any

local Color = Theme.Color
local DISPLAY = Config.ShopDisplay
local PRODUCTS = Config.Receipts.products
local PASS_DEFS = Config.Shop.passes

type Offer = { key: string, name: string, note: string, id: number, endsIn: number, image: string? }
type Pass = { key: string, name: string, perk: string, id: number, image: string? }
type Pack = { key: string, name: string, amount: number, id: number, image: string? }

-- Shop content from GameConfig.ShopDisplay; ids from the product/pass config.
local OFFERS: { Offer } = {}
for _, o in DISPLAY.offers do
	table.insert(OFFERS, { key = o.product, name = o.name, note = o.note, id = PRODUCTS[o.product].id, endsIn = o.endsInSeconds, image = ItemArt.image(o.art) })
end
local PASSES: { Pass } = {}
for _, p in DISPLAY.passes do
	table.insert(PASSES, { key = p.pass, name = p.name, perk = p.perk, id = PASS_DEFS[p.pass].id, image = ItemArt.image(p.art) })
end
local PACKS: { Pack } = {}
for _, p in DISPLAY.packs do
	table.insert(PACKS, { key = p.product, name = p.name, amount = p.amount, id = PRODUCTS[p.product].id, image = ItemArt.image(p.art) })
end

-- Robux price on the button: from Roblox (regional pricing) once the id is
-- real, a dash while it is 0. The UI never stores Robux prices.
local function priceText(kind: "product" | "pass", id: number): string
	if id <= 0 then
		return `{Theme.ROBUX} —`
	end
	local ok, info = pcall(function()
		return MarketplaceService:GetProductInfoAsync(id, if kind == "pass" then Enum.InfoType.GamePass else Enum.InfoType.Product)
	end)
	return if ok and info and info.PriceInRobux then `{Theme.ROBUX} {UI.formatNumber(info.PriceInRobux)}` else `{Theme.ROBUX} —`
end

-- Asks the server to prompt. With id = 0 the server refuses ("Unavailable")
-- and never opens a purchase prompt.
local function prompt(kind: "product" | "pass", key: string, _name: string)
	task.spawn(function()
		local result = Net.Request(if kind == "pass" then "Shop.PromptPass" else "Shop.PromptProduct", key)
		if not result.ok then
			Toast.Result(result)
		end
	end)
end

-- "ENDS IN 2D 05:41:09", or "ENDS IN 05:41:09" under a day.
local function countdown(seconds: number): string
	seconds = math.max(0, math.floor(seconds))
	local d = seconds // 86400
	local clock = string.format("%02d:%02d:%02d", (seconds % 86400) // 3600, (seconds % 3600) // 60, seconds % 60)
	return if d > 0 then `ENDS IN {d}D {clock}` else `ENDS IN {clock}`
end

Controller.start()

local window = UI.Window({ name = "Shop", title = "Shop" })
local body: ScrollingFrame = window.body

local order = 0
local function nextOrder(): number
	order += 1
	return order
end

local sections: { { tab: string, anchor: GuiObject } } = {}
local timers: { { label: TextLabel, endsAt: number } } = {}

local function timerPill(offer: Offer, parent: Instance, position: UDim2)
	local label = UI.Text(countdown(offer.endsIn), {
		size = 22,
		color = Color.tier,
		box = UDim2.new(0.66, -20, 0, 28),
		position = position,
		parent = parent,
	})
	table.insert(timers, { label = label, endsAt = os.time() + offer.endsIn })
end

---------------------------------------------------------------------------
-- OFFERS: bright full-width cards, the first with featured rays
---------------------------------------------------------------------------
local offerTitle = UI.SectionTitle("Offers", nextOrder(), body)
table.insert(sections, { tab = "Offers", anchor = offerTitle })

for i, offer in OFFERS do
	local card = UI.Card({ family = if i == 1 then Theme.Card.vip else Theme.Card.offer, size = UDim2.new(1, 0, 0, 204), layoutOrder = nextOrder(), parent = body })
	if i == 1 then UI.Rays(card) end
	UI.ItemArt(offer.image, UDim2.new(0.3, -20, 1, -28), card).Position = UDim2.fromOffset(12, 14)
	local tag = UI.Ribbon(if i == 1 then "FEATURED" else "NEW", card)
	tag.Position = UDim2.new(1, -20, 0, -4)
	timerPill(offer, card, UDim2.new(0.32, 0, 0, 18))
	UI.Text(string.upper(offer.name), { size = 30, box = UDim2.new(0.66, -20, 0, 40), position = UDim2.new(0.32, 0, 0, 50), parent = card })
	UI.Text(offer.note, { size = 22, wrap = true, box = UDim2.new(0.66, -20, 0, 44), position = UDim2.new(0.32, 0, 0, 92), parent = card })
	UI.Button({ text = priceText("product", offer.id), size = UDim2.new(0.5, -20, 0, 56), position = UDim2.new(1, -18, 1, -12), anchor = Vector2.new(1, 1), parent = card,
		onActivated = function() prompt("product", offer.key, offer.name) end })
end

---------------------------------------------------------------------------
-- PASSES: full-width rows
---------------------------------------------------------------------------
local passTitle = UI.SectionTitle("Passes", nextOrder(), body)
table.insert(sections, { tab = "Passes", anchor = passTitle })
for _, pass in PASSES do
	local card = UI.Card({ family = Theme.Card.pass, size = UDim2.new(1, 0, 0, 118), layoutOrder = nextOrder(), parent = body })
	UI.ItemArt(pass.image, UDim2.fromOffset(120, 88), card).Position = UDim2.fromOffset(8, 8)
	UI.Text(string.upper(pass.name), { size = 26, font = Theme.Font.title, box = UDim2.new(0.56, -144, 0, 32), position = UDim2.fromOffset(144, 16), parent = card })
	UI.Text(pass.perk, { size = 20, wrap = true, color = Color.textDim, box = UDim2.new(0.56, -144, 0, 50), position = UDim2.fromOffset(144, 56), parent = card })
	UI.Button({
		text = priceText("pass", pass.id),
		size = UDim2.new(0.35, -18, 0, 56),
		position = UDim2.new(1, -20, 0.5, 0),
		anchor = Vector2.new(1, 0.5),
		parent = card,
		onActivated = function()
			prompt("pass", pass.key, pass.name)
		end,
	})
end

---------------------------------------------------------------------------
-- PACKS: two-column grid with art, amount and price
---------------------------------------------------------------------------
local packTitle = UI.SectionTitle("Packs", nextOrder(), body)
table.insert(sections, { tab = "Packs", anchor = packTitle })
local packRow = Instance.new("Frame")
packRow.Name = "Packs"
packRow.BackgroundTransparency = 1
packRow.Size = UDim2.fromScale(1, 0)
packRow.AutomaticSize = Enum.AutomaticSize.Y
packRow.LayoutOrder = nextOrder()
packRow.Parent = body
local packGrid = Instance.new("UIGridLayout")
packGrid.CellSize = UDim2.new(0.5, -8, 0, 250)
packGrid.CellPadding = UDim2.fromOffset(16, 16)
packGrid.SortOrder = Enum.SortOrder.LayoutOrder
packGrid.Parent = packRow
for i, pack in PACKS do
	local card = UI.Card({ family = Theme.Card.cash, size = UDim2.new(0.25, -11, 1, 0), layoutOrder = i, parent = packRow })
	UI.ItemArt(pack.image, UDim2.new(1, -24, 0, 110), card).Position = UDim2.fromOffset(12, 10)
	UI.Text(string.upper(pack.name), {
		size = 20,
		font = Theme.Font.title,
		align = Enum.TextXAlignment.Center,
		box = UDim2.new(1, -16, 0, 26),
		position = UDim2.fromOffset(8, 124),
		parent = card,
	})
	UI.Text("+" .. UI.formatNumber(pack.amount), {
		size = 24,
		color = Color.money,
		align = Enum.TextXAlignment.Center,
		box = UDim2.new(1, -16, 0, 30),
		position = UDim2.fromOffset(8, 150),
		parent = card,
	})
	UI.Button({
		text = priceText("product", pack.id),
		size = UDim2.new(1, -24, 0, 52),
		position = UDim2.new(0.5, 0, 1, -12),
		anchor = Vector2.new(0.5, 1),
		textSize = 22,
		parent = card,
		onActivated = function()
			prompt("product", pack.key, pack.name)
		end,
	})
end

---------------------------------------------------------------------------
-- CODES: field and REDEEM in one row (server decides: Codes.Redeem)
---------------------------------------------------------------------------
local codesTitle = UI.SectionTitle("Codes", nextOrder(), body)
table.insert(sections, { tab = "Codes", anchor = codesTitle })

local codesBox = UI.Panel(UDim2.new(1, 0, 0, 132), nextOrder(), body)
codesBox.Name = "Codes"

local field = Instance.new("TextBox")
field.Name = "Field"
field.Text = ""
field.PlaceholderText = "TYPE A CODE"
field.PlaceholderColor3 = Color.textMuted
field.TextColor3 = Color.text
field.FontFace = Theme.Font.heavy
field.TextSize = 24
field.ClearTextOnFocus = false
field.BackgroundColor3 = Color.field
field.BorderSizePixel = 0
field.Position = UDim2.fromOffset(20, 20)
field.Size = UDim2.new(0.62, -30, 0, 56)
local fieldStroke = Instance.new("UIStroke")
fieldStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
fieldStroke.Color = Color.fieldBorder
fieldStroke.Thickness = Theme.Size.cardStroke
local fieldCorner = Instance.new("UICorner")
fieldCorner.CornerRadius = UDim.new(1, 0)
fieldCorner.Parent = field
fieldStroke.Parent = field
field.Parent = codesBox

local status = UI.Text("Codes come from our updates and socials.", {
	size = 20,
	font = Theme.Font.bold,
	color = Color.textMuted,
	wrap = true,
	box = UDim2.new(1, -40, 0, 36),
	position = UDim2.fromOffset(20, 86),
	parent = codesBox,
})

local busy = false
UI.Button({
	text = "REDEEM",
	size = UDim2.new(0.38, -30, 0, 56),
	position = UDim2.new(1, -20, 0, 20),
	anchor = Vector2.new(1, 0),
	parent = codesBox,
	onActivated = function()
		if busy then
			return
		end
		local code = string.gsub(field.Text, "^%s*(.-)%s*$", "%1")
		if code == "" then
			status.Text = "! Type a code first"
			return
		end
		busy = true
		status.Text = "CHECKING..."
		task.spawn(function()
			-- The server normalises the code, checks expiry, one use per
			-- player, and locks out repeated misses.
			local result = Net.Request("Codes.Redeem", code)
			busy = false
			if result.ok then
				status.Text = `✓ Code redeemed: +{result.data.reward}`
				field.Text = ""
			else
				status.Text = "! " .. Feedback.Text(result.code)
			end
			Toast.Result(result, if result.ok then `+{result.data.reward}` else nil)
		end)
	end,
})

---------------------------------------------------------------------------
-- Tabs: jump to a section; the tab of the section in view is orange
---------------------------------------------------------------------------
local tabs: { [string]: any } = {}
local function scrollTo(anchor: GuiObject)
	-- CanvasPosition and AbsolutePosition are both in screen pixels (after UIScale).
	local target = body.CanvasPosition.Y + (anchor.AbsolutePosition.Y - body.AbsolutePosition.Y) - 8
	target = math.clamp(target, 0, math.max(0, body.AbsoluteCanvasSize.Y - body.AbsoluteWindowSize.Y))
	TweenService:Create(body, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { CanvasPosition = Vector2.new(0, target) }):Play()
end
for i, section in sections do
	tabs[section.tab] = UI.Tab(section.tab, i, window.tabs, function()
		scrollTo(section.anchor)
	end)
end

local function syncTabs()
	local current = sections[1].tab
	for _, section in sections do
		if section.anchor.AbsolutePosition.Y <= body.AbsolutePosition.Y + 60 then
			current = section.tab
		end
	end
	-- At the bottom the last section can't reach the top, so it wins there.
	if body.CanvasPosition.Y >= body.AbsoluteCanvasSize.Y - body.AbsoluteWindowSize.Y - 4 then
		current = sections[#sections].tab
	end
	for name, tab in tabs do
		tab.setActive(name == current)
	end
end
body:GetPropertyChangedSignal("CanvasPosition"):Connect(syncTabs)
syncTabs()

window.defaultSelection = tabs.Offers.root

Controller.register(window)
Launcher.add("Shop", "shop", 1)

-- Promo slabs (style D): title and art from ShopDisplay.promos, price from Roblox.
for i, promo in Config.ShopDisplay.promos or {} do
	local slab = Launcher.promo("Shop", {
		image = ItemArt.image(promo.art) or "",
		title = promo.title,
		line = "ONLY …",
		from = promo.from,
		to = promo.to,
	}, i)
	task.spawn(function()
		local id = if promo.pass then PASS_DEFS[promo.pass].id else PRODUCTS[promo.product].id
		local text = `ONLY {priceText(if promo.pass then "pass" else "product", id)}`
		for _, label in slab:GetDescendants() do
			if label:IsA("TextLabel") and label.Text == "ONLY …" then
				label.Text = text
			end
		end
	end)
end

-- Countdowns tick only while the shop is open.
local function tick()
	for _, t in timers do
		t.label.Text = countdown(t.endsAt - os.time())
	end
end
task.spawn(function()
	while true do
		if Controller.isOpen("Shop") then
			tick()
		end
		task.wait(1)
	end
end)
tick()

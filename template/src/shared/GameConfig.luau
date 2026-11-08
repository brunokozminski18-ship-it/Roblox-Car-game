--!strict
--[[
	GameConfig: everything a new game changes (template/README.md, "Nowa gra").
	ReplicatedStorage/GameConfig. Display-safe: the client draws UI from it, the
	server decides with its own copy, so editing the client copy changes nothing.
	Secrets (codes) are in ServerStorage/GameSecrets.

	Neutral example content (Pet 1, Item 1) until there is a game.
	Robux products and passes keep id = 0: the server never prompts an id 0.
]]

local Config = {}

---------------------------------------------------------------------------
-- LihFolk systems (formats: LihFolk skills/lihfolk-systems)
---------------------------------------------------------------------------
Config.PlayerData = {
	storeName = "PlayerData_v1", -- never rename after launch
	schemaVersion = 1,
	migrations = {},
}

Config.Currency = {
	currencies = {
		Power = { start = 0, paid = false, leaderstat = true }, -- +1 stat (Config.PlusOne), reset by Rebirth
		Cash = { start = 0, paid = false, leaderstat = true },
		Gems = { start = 5, paid = true }, -- sold for Robux below, so "paid"
	},
	maxMultiplier = 1000,
}

local RARITIES = { "common", "uncommon", "rare", "epic", "legendary" }
local items: { [string]: any } = {}
for i = 1, 12 do
	items[`Pet{i}`] = {
		name = `Pet {i}`,
		stackable = false,
		equippable = true,
		tradable = true,
		-- template fields (UI): rarity colour, card art key (UIStyle/ItemArt)
		rarity = RARITIES[(i - 1) % 5 + 1],
		art = `pet{(i - 1) % 5 + 1}`,
		power = 1 + ((i - 1) % 4 + 1) * 0.1, -- Template: additive pet bonus
		stat = `x{1 + ((i - 1) % 4 + 1) * 0.1} Power`,
	}
end
for i = 1, 4 do
	items[`Item{i}`] = {
		name = `Item {i}`,
		stackable = true,
		maxStack = 99,
		rarity = RARITIES[(i + 1) % 5 + 1],
		art = `item{i}`,
		stat = `Item {i} effect`,
	}
end
Config.Inventory = {
	uniqueCapacity = 20, -- base slots; bought slots add to this (Config.Slots)
	maxEquipped = 3,
	items = items,
}

Config.Shop = {
	-- Soft-currency purchases (Shop.Buy). Price is checked on the server.
	items = {
		Item1 = { price = { currency = "Cash", amount = 250 }, reward = { kind = "item", item = "Item1", count = 1 }, maxQuantity = 10 },
	},
	passes = {
		Pass1 = { id = 0 },
		Pass2 = { id = 0 },
		Pass3 = { id = 0 },
	},
}

Config.Receipts = {
	-- Developer Products. Robux prices are NOT stored here (GetProductInfoAsync).
	products = {
		Offer1 = { id = 0, reward = { kind = "item", item = "Pet9", count = 1 } },
		Offer2 = { id = 0, reward = { kind = "item", item = "Pet10", count = 1 } },
		Offer3 = { id = 0, reward = { kind = "item", item = "Pet11", count = 1 } },
		Pack1 = { id = 0, reward = { kind = "currency", currency = "Gems", amount = 100 } },
		Pack2 = { id = 0, reward = { kind = "currency", currency = "Gems", amount = 600 } },
		Pack3 = { id = 0, reward = { kind = "currency", currency = "Gems", amount = 4000 } },
		Pack4 = { id = 0, reward = { kind = "currency", currency = "Gems", amount = 25000 } },
	},
}

-- Session playtime gifts: thresholds and rewards share this display-safe
-- config with the server. Reset on rejoin; balance is placeholder, NOT FINAL.
Config.PlaytimeRewards = {
	reset = "session",
	track = {
		{ id = "Minute1", minutes = 1, label = "+50 CASH", art = "cash", reward = { kind = "currency", currency = "Cash", amount = 50 } },
		{ id = "Minute2", minutes = 2, label = "+5 GEMS", art = "gems", reward = { kind = "currency", currency = "Gems", amount = 5 } },
		{ id = "Minute3", minutes = 3, label = "+100 CASH", art = "cash", reward = { kind = "currency", currency = "Cash", amount = 100 } },
		{ id = "Minute5", minutes = 5, label = "+10 GEMS", art = "gems", reward = { kind = "currency", currency = "Gems", amount = 10 } },
		{ id = "Minute10", minutes = 10, label = "+250 CASH", art = "offer2", reward = { kind = "currency", currency = "Cash", amount = 250 } },
		{ id = "Minute15", minutes = 15, label = "+20 GEMS", art = "gems", reward = { kind = "currency", currency = "Gems", amount = 20 } },
		{ id = "Minute20", minutes = 20, label = "+500 CASH", art = "offer3", reward = { kind = "currency", currency = "Cash", amount = 500 } },
		{ id = "Minute30", minutes = 30, label = "+1K CASH", art = "offer1", featured = true, reward = { kind = "currency", currency = "Cash", amount = 1000 } },
	},
}

Config.Daily = {
	resetOffsetHours = 0,
	graceDays = 0,
	track = {
		{ kind = "currency", currency = "Cash", amount = 500 },
		{ kind = "currency", currency = "Cash", amount = 1000 },
		{ kind = "item", item = "Item1", count = 1 },
		{ kind = "currency", currency = "Cash", amount = 2500 },
		{ kind = "currency", currency = "Cash", amount = 5000 },
		{ kind = "item", item = "Item2", count = 1 },
		{ kind = "item", item = "Pet12", count = 1 },
	},
}

Config.Rebirth = {
	currency = "Power", -- +1 games rebirth the stat; multiplier applies to Power gains
	baseCost = 40000,
	growth = 2,
	bonusPerRebirth = 0.5, -- Power multiplier: 1 + rebirths * bonus
	maxBulk = 1,
	keep = { "Pets", "Gamepasses", "Index progress" }, -- UI text only
	resets = { "Power" }, -- UI text only; the module resets the rebirth currency
}

-- Quest kinds reported by the server (Main.server.luau): "Claim"/"Daily",
-- "Equip"/"*", "Earn"/"Cash", "Rebirth"/"*", "Discover"/<item>, "Buy"/<key>.
Config.Quests = {
	quests = {
		{ id = "D1", title = "Task 1", group = "Daily", resets = "daily", objectives = { { kind = "Claim", target = "Daily", amount = 1, text = "Claim the daily reward" } }, reward = { kind = "currency", currency = "Cash", amount = 300 } },
		{ id = "D2", title = "Task 2", group = "Daily", resets = "daily", objectives = { { kind = "Earn", target = "Cash", amount = 500, text = "Earn 500 Cash" } }, reward = { kind = "currency", currency = "Cash", amount = 400 } },
		{ id = "D3", title = "Task 3", group = "Daily", resets = "daily", objectives = { { kind = "Equip", target = "*", amount = 1, text = "Equip a pet" } }, reward = { kind = "item", item = "Item1", count = 1 } },
		{ id = "W1", title = "Task 4", group = "Weekly", resets = "weekly", objectives = { { kind = "Discover", target = "*", amount = 4, text = "Find 4 new pets" } }, reward = { kind = "currency", currency = "Gems", amount = 25 } },
		{ id = "W2", title = "Task 5", group = "Weekly", resets = "weekly", objectives = { { kind = "Buy", target = "*", amount = 3, text = "Buy 3 things for Cash" } }, reward = { kind = "currency", currency = "Cash", amount = 3000 } },
		{ id = "W3", title = "Task 6", group = "Weekly", resets = "weekly", objectives = { { kind = "Rebirth", target = "*", amount = 1, text = "Rebirth once" } }, reward = { kind = "currency", currency = "Gems", amount = 50 } },
	},
}

---------------------------------------------------------------------------
-- Template services (template/src/server/Services)
---------------------------------------------------------------------------
Config.Slots = {
	step = 5, -- slots per purchase
	price = { currency = "Cash", amount = 500 },
	maxExtra = 50,
}

Config.Index = {
	areas = {
		{ id = "Area1", name = "Area 1", items = { "Pet1", "Pet2", "Pet3", "Pet4" }, reward = { kind = "currency", currency = "Gems", amount = 20 } },
		{ id = "Area2", name = "Area 2", items = { "Pet5", "Pet6", "Pet7", "Pet8" }, reward = { kind = "currency", currency = "Gems", amount = 40 } },
		{ id = "Area3", name = "Area 3", items = { "Pet9", "Pet10", "Pet11", "Pet12" }, reward = { kind = "currency", currency = "Gems", amount = 80 } },
	},
}

-- Placeholder income until the game has its own activity: Cash per second,
-- earned through Currency.Earn (so the Rebirth multiplier applies). 0 = off.
Config.Income = { perSecond = 0 }

-- "+1" core (server/Services/PlusOne + client/PlusOne). The loop:
--   walk -> Power -> smash walls -> Cash -> buy gear (multiplies Power)
--   -> stronger walls -> boss at the end of the track -> next world.
-- The character transforms at Power thresholds (size, aura, optional
-- accessories from ReplicatedStorage/PlusOneForms/<form.accessories>).
-- A meme reskin changes only names, colours, numbers and models here
-- (template/README.md, "Mem w 2 dni"). Numbers NOT FINAL (LihFolk 48 + measurement).
Config.PlusOne = {
	stat = "Power", -- currency earned per step
	reward = "Cash", -- currency paid by walls, spent on gear
	perStep = 1,
	stepStuds = 2, -- one step = this many studs walked
	maxSpeed = 60, -- studs/s; faster movement (teleport) earns nothing
	forms = { -- reached at Power >= at; scale = character size; accessories = folder name (optional)
		-- Template: intermediate progress goals, NOT FINAL.
		{ at = 0, name = "Level 1", scale = 1, color = Color3.fromRGB(255, 255, 255) },
		{ at = 50, name = "Level 26", scale = 1.12, color = Color3.fromRGB(90, 220, 255) },
		{ at = 250, name = "Level 51", scale = 1.3, color = Color3.fromRGB(110, 255, 120) },
		{ at = 1500, name = "Level 76", scale = 1.55, color = Color3.fromRGB(255, 210, 60) },
		{ at = 10000, name = "Level 101", scale = 1.85, color = Color3.fromRGB(255, 90, 200) },
		{ at = 15000, name = "Level 126", scale = 1.886, color = Color3.fromRGB(180, 90, 255) },
		{ at = 22000, name = "Level 151", scale = 1.936, color = Color3.fromRGB(180, 90, 255) },
		{ at = 28000, name = "Level 176", scale = 1.979, color = Color3.fromRGB(180, 90, 255) },
		{ at = 35000, name = "Level 201", scale = 2.029, color = Color3.fromRGB(180, 90, 255) },
		{ at = 42000, name = "Level 226", scale = 2.079, color = Color3.fromRGB(180, 90, 255) },
		{ at = 50000, name = "Level 251", scale = 2.136, color = Color3.fromRGB(180, 90, 255) },
		{ at = 60000, name = "Level 276", scale = 2.2, color = Color3.fromRGB(180, 90, 255) },
		{ at = 75000, name = "Level 301", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 95000, name = "Level 326", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 115000, name = "Level 351", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 135000, name = "Level 376", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 155000, name = "Level 401", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 175000, name = "Level 426", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 195000, name = "Level 451", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 215000, name = "Level 476", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 235000, name = "Level 501", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 255000, name = "Level 526", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 275000, name = "Level 551", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 295000, name = "Level 576", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 315000, name = "Level 601", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 335000, name = "Level 626", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 355000, name = "Level 651", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 375000, name = "Level 676", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 395000, name = "Level 701", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 415000, name = "Level 726", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 435000, name = "Level 751", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 455000, name = "Level 776", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 475000, name = "Level 801", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 495000, name = "Level 826", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 515000, name = "Level 851", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 535000, name = "Level 876", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 555000, name = "Level 901", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 575000, name = "Level 926", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 595000, name = "Level 951", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 615000, name = "Level 976", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 635000, name = "Level 1001", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 655000, name = "Level 1026", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 675000, name = "Level 1051", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
		{ at = 695000, name = "Level 1076", scale = 2.200, color = Color3.fromRGB(180, 90, 255) },
	},
	gear = { -- bought in order at the stands on each world's start pad; mult = Power per step multiplier
		{ name = "Gloves", price = 20, mult = 1.5 },
		{ name = "Boots", price = 120, mult = 2 },
		{ name = "Belt", price = 600, mult = 3 },
		{ name = "Cape", price = 3000, mult = 4 },
		{ name = "Crown", price = 15000, mult = 6 },
		{ name = "Halo", price = 80000, mult = 8 },
	},
	walls = { -- per world: hp and reward are multiplied by the world's scale
		{ hp = 25, reward = 5 },
		{ hp = 150, reward = 15 },
		{ hp = 800, reward = 50 },
		{ hp = 4000, reward = 160 },
		{ hp = 20000, reward = 500 },
	},
	worlds = { -- the last wall of each world is its boss; beating it unlocks the next world
		{ name = "Grass Lands", floor = Color3.fromRGB(96, 200, 120), scale = 1, boss = { name = "Big Noob", hp = 75000, reward = 2000 } },
		{ name = "Lava Land", floor = Color3.fromRGB(230, 110, 60), scale = 4, boss = { name = "Lava King", hp = 240000, reward = 60000 } },
		{ name = "Space", floor = Color3.fromRGB(90, 90, 200), scale = 12, boss = { name = "Galaxy God", hp = 700000, reward = 2000000 } },
	},
	track = { width = 34, spacing = 70, gap = 90, origin = Vector3.new(0, 0.1, -10) },
}

-- First-minutes analytics (server/Services/Analytics). A new game adds its own
-- steps; triggers: "Joined", "Window:<name>", "Claim:<Daily|Task|Index>",
-- "CurrencyPurchase", "Rebirth", or its own Analytics.Trigger(player, "...").
Config.Analytics = {
	debugInStudio = true, -- print events to Output in Studio (Roblox drops Studio events)
	flushSeconds = 60,
	windows = { "Shop", "Inventory", "Index", "Tasks", "Daily", "Rebirth", "Settings" },
	onboarding = {
		{ trigger = "Joined", name = "Joined" },
		{ trigger = "Window:Daily", name = "Opened Daily" },
		{ trigger = "Claim:Daily", name = "Claimed Daily" },
		{ trigger = "Window:Shop", name = "Opened Shop" },
		{ trigger = "CurrencyPurchase", name = "First Cash purchase" },
		{ trigger = "Rebirth", name = "First Rebirth" },
	},
}

-- First-minute hints (server/Services/Hints + client/Hints). Steps run in
-- order; each shows an arrow and a short line until its trigger happens.
-- Mechanism only: a new game writes its own steps.
--   target   "button:<Window>"  menu button that opens that window
--            "gui:<path>"       any GuiObject under PlayerGui (dots between names)
--            "part:<path>"      a BasePart/Model in Workspace (arrow above it)
--   doneWhen an Analytics trigger: "Window:<name>", "Claim:<Daily|Task|Index>",
--            "CurrencyPurchase", "Rebirth", or a game's own Analytics.Trigger.
Config.Hints = {
	enabled = true,
	steps = {
		{ id = "openDaily", target = "button:Daily", text = "Open Daily Rewards", doneWhen = "Window:Daily" },
		{ id = "claimDaily", target = "gui:LihFolkUI.Daily.Panel.Body.Top.Claim", text = "Claim your reward!", doneWhen = "Claim:Daily" },
	},
}

Config.Settings = {
	-- key = default; the server only stores these keys, as booleans
	defaults = { music = true, sfx = true, reducedMotion = false, hideEffects = false, largeMenus = false },
}

---------------------------------------------------------------------------
-- Shop window layout (what is shown where). Prices: soft items from
-- Config.Shop.items, Robux from GetProductInfoAsync once ids are set.
---------------------------------------------------------------------------
Config.ShopDisplay = {
	offers = {
		{ product = "Offer1", name = "Item 1", note = "Item 1 description goes here.", endsInSeconds = 2 * 86400 + 5 * 3600, art = "offer1" },
		{ product = "Offer2", name = "Item 2", note = "Short description.", endsInSeconds = 6 * 3600, art = "offer2" },
		{ product = "Offer3", name = "Item 3", note = "Short description.", endsInSeconds = 3 * 86400, art = "offer3" },
	},
	passes = {
		{ pass = "Pass1", name = "Pass 1", perk = "Pass 1 perk goes here.", art = "pass1" },
		{ pass = "Pass2", name = "Pass 2", perk = "Pass 2 perk goes here.", art = "pass2" },
		{ pass = "Pass3", name = "Pass 3", perk = "Pass 3 perk goes here.", art = "pass3" },
	},
	packs = {
		{ product = "Pack1", name = "Pack 1", amount = 100, art = "pack1" },
		{ product = "Pack2", name = "Pack 2", amount = 600, art = "pack2" },
		{ product = "Pack3", name = "Pack 3", amount = 4000, art = "pack3" },
		{ product = "Pack4", name = "Pack 4", amount = 25000, art = "pack4" },
	},
	-- Promo slabs on the right edge of the HUD (UIStyle/Launcher, style D):
	-- each points at an offer or pass above; tapping opens the Shop.
	promos = {
		{ title = "x2 Power", pass = "Pass2", art = "pass2", from = Color3.fromRGB(255, 120, 200), to = Color3.fromRGB(90, 200, 255) },
		{ title = "Starter Pack", product = "Offer1", art = "offer1", from = Color3.fromRGB(120, 230, 120), to = Color3.fromRGB(255, 210, 70) },
	},
}

-- Template: free Cash eggs; one per world, four neutral pets each. NOT FINAL.
Config.Eggs = { maxLuck = 1, eggs = {} }
Config.Pets = { maxMultiplier = 2.2 }
for world = 1, #Config.PlusOne.worlds do
	local tiers = {}
	for j, weight in { 55, 28, 13, 4 } do
		local id = `Pet{(world - 1) * 4 + j}`
		items[id].power = 1 + j * 0.1 + (world - 1) * 0.1
		-- card art: items[id].art -> UIStyle/ItemArt (icon pack; see playbook/UI_STYLE.md)
		items[id].stat = `x{items[id].power} Power`
		items[id].rarity = RARITIES[j]
		table.insert(tiers, { name = RARITIES[j], weight = weight, items = { { id = id, weight = 1 } } })
	end
	Config.Eggs.eggs[`Egg{world}`] = {
		name = `Egg {world}`, world = world,
		price = { currency = "Cash", amount = ({ 35, 700, 3000 })[world] },
		tiers = tiers, hatchCounts = { 1 }, paid = false,
	}
end

return Config

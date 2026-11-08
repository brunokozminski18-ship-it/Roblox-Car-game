--!strict
--[[
	Main: the only server Script (LihFolk wiring order, playbook/ARCHITECTURE.md).
	  1. PlayerData.Configure
	  2. Policy, LihFolk services, template services: Init (slices + remotes)
	  3. Cross-module hooks (quest progress comes only from server systems)
	  4. Receipts.Start (the one ProcessReceipt)
	  5. PlayerData.Start (players load last)
	Config: ReplicatedStorage/GameConfig, codes: ServerScriptService/Server/GameSecrets
	(server-only: ServerScriptService never replicates to clients).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("GameConfig")) :: any
local Secrets = require(script.Parent:WaitForChild("GameSecrets")) :: any

local LihFolk = script.Parent:WaitForChild("LihFolk")
local Services = script.Parent:WaitForChild("Services")

local PlayerData = require(LihFolk.PlayerData)
local Policy = require(LihFolk.Policy)
local Currency = require(LihFolk.Currency)
local Inventory = require(LihFolk.Inventory)
local Receipts = require(LihFolk.Receipts)
local Shop = require(LihFolk.Shop)
local Codes = require(LihFolk.Codes)
local DailyRewards = require(LihFolk.DailyRewards)
local Rebirth = require(LihFolk.Rebirth)
local Quests = require(LihFolk.Quests)
local Slots = require(Services.Slots)
local Index = require(Services.Index)
local Settings = require(Services.Settings)
local Income = require(Services.Income)
local Analytics = require(Services.Analytics)
local Hints = require(Services.Hints)
local PlusOne = require(Services.PlusOne)
local EggHatch = require(LihFolk.EggHatch)
local Eggs = require(Services.Eggs)
local PlaytimeRewards = require(Services.PlaytimeRewards)

-- 1. Data layer
PlayerData.Configure(Config.PlayerData)

-- 2. Services
Policy.Init()
Currency.Init(Config.Currency)
Inventory.Init(Config.Inventory)
Receipts.Init(Config.Receipts)
Shop.Init(Config.Shop)
Codes.Init(Secrets.Codes)
DailyRewards.Init(Config.Daily)
Rebirth.Init(Config.Rebirth)
Quests.Init(Config.Quests)
Slots.Init(Config.Slots, Config.Inventory.uniqueCapacity)
Index.Init(Config.Index)
Settings.Init(Config.Settings)
Income.Init(Config.Income, Config.Rebirth.currency)
Analytics.Init(Config.Analytics)
Hints.Init(Config.Hints)
PlusOne.Init(Config.PlusOne)
-- Template: dependencies ready, profiles still unloaded.
EggHatch.Init(Config.Eggs)
Eggs.Init(Config)
PlaytimeRewards.Init(Config.PlaytimeRewards)

-- 3. Hooks: quest progress and analytics from server events only
local rebirthCurrency = Config.Rebirth.currency

Currency.Changed:Connect(function(player: Player, name: string, _balance: number, delta: number, reason: string)
	if delta > 0 and reason ~= "load" then
		Quests.Report(player, "Earn", name, delta)
	elseif delta < 0 and (string.sub(reason, 1, 5) == "shop:" or reason == "slots") then
		Quests.Report(player, "Buy", if reason == "slots" then "Slots" else string.sub(reason, 6), 1)
		Analytics.CurrencyPurchase(player, name, -delta, reason)
	elseif reason == "rebirth" and name == rebirthCurrency then
		Quests.Report(player, "Rebirth", "*", 1)
		Analytics.Rebirth(player)
	end
end)

DailyRewards.Claimed:Connect(function(player: Player, index: number, streak: number)
	Quests.Report(player, "Claim", "Daily", 1)
	Analytics.Claim(player, "Daily", { day = index, streak = streak })
end)

Inventory.Equipped:Connect(function(player: Player, _uid: string, itemId: string)
	Quests.Report(player, "Equip", itemId, 1)
end)

Index.Discovered:Connect(function(player: Player, itemId: string)
	Quests.Report(player, "Discover", itemId, 1)
end)

-- Hints advance on the same triggers as the onboarding funnel.
Analytics.Triggered:Connect(Hints.Trigger)

-- 4. Purchases (every product keeps id = 0 until real ids exist: never prompted)
Receipts.Start()

-- 5. Load players last
PlayerData.Start()

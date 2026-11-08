--!strict
-- Template service: collection index (Config.Index). An item counts as found
-- the first time the player holds it (watched through Inventory.Changed).
-- An area's reward can be claimed once, when every item in it is found.
-- Remotes: Index.Get() -> view, Index.Claim(areaId) ; push: Index.Changed(view)
-- Signal: Index.Discovered(player, itemId)

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LihFolk = ServerScriptService:WaitForChild("Server"):WaitForChild("LihFolk")
local PlayerData = require(LihFolk.PlayerData)
local Inventory = require(LihFolk.Inventory)
local Rewards = require(LihFolk.Rewards)
local Shared = ReplicatedStorage:WaitForChild("LihFolk")
local Net = require(Shared:WaitForChild("Net"))
local Signal = require(Shared:WaitForChild("Signal"))

type Area = { id: string, name: string, items: { string }, reward: Rewards.Reward }
export type Config = { areas: { Area } }

local Index = {}
Index.Discovered = Signal.new()

local areas: { Area } = {}
local areaById: { [string]: Area } = {}
local tracked: { [string]: boolean } = {}
local changedPush: Net.Push? = nil

local function view(profile: PlayerData.Profile): { [string]: any }
	local state = profile.Data.Index
	local out = {}
	for _, area in areas do
		local found = 0
		local list = {}
		for _, itemId in area.items do
			local has = state.Found[itemId] == true
			if has then
				found += 1
			end
			table.insert(list, { item = itemId, found = has })
		end
		table.insert(out, {
			id = area.id,
			name = area.name,
			items = list,
			found = found,
			total = #area.items,
			reward = Rewards.Describe(area.reward),
			claimed = state.Claimed[area.id] == true,
		})
	end
	return { areas = out }
end

-- Marks every tracked item the player now holds. Synchronous.
local function scan(player: Player)
	local profile = PlayerData.Get(player)
	if not profile then
		return
	end
	local state = profile.Data.Index
	local inv = profile.Data.Inventory
	local newly = {}
	for itemId in tracked do
		if not state.Found[itemId] then
			local held = (inv.Stacks[itemId] or 0) > 0
			if not held then
				for _, unique in inv.Uniques do
					if unique.Item == itemId then
						held = true
						break
					end
				end
			end
			if held then
				state.Found[itemId] = true
				table.insert(newly, itemId)
			end
		end
	end
	if #newly > 0 then
		PlayerData.MarkDirty(profile)
		for _, itemId in newly do
			Index.Discovered:Fire(player, itemId)
		end
		if changedPush then
			changedPush:Fire(player, view(profile))
		end
	end
end

local function claim(player: Player, areaId: string): Net.Result
	local area = areaById[areaId]
	local profile = PlayerData.Get(player)
	if not profile then
		return Net.fail("NotReady")
	end
	local state = profile.Data.Index
	if state.Claimed[areaId] then
		return Net.fail("AlreadyClaimed")
	end
	for _, itemId in area.items do
		if not state.Found[itemId] then
			return Net.fail("NotComplete")
		end
	end
	local fits, code = Rewards.CanGrant(player, area.reward)
	if not fits then
		return Net.fail(code or "BagFull")
	end
	-- Mark and grant together, no yield in between.
	state.Claimed[areaId] = true
	Rewards.Grant(player, area.reward, `index:{areaId}`, false, false)
	PlayerData.MarkDirty(profile)
	return Net.ok(view(profile))
end

function Index.Init(config: Config)
	for _, area in config.areas do
		assert(type(area.id) == "string" and string.match(area.id, "^[%w_]+$") and not areaById[area.id], `Index: bad or duplicate area id {area.id}`)
		assert(#area.items >= 1, `Index {area.id}: no items`)
		for _, itemId in area.items do
			assert(Inventory.Exists(itemId), `Index {area.id}: unknown item {itemId}`)
			tracked[itemId] = true
		end
		Rewards.Validate(`Index {area.id}`, area.reward)
		areaById[area.id] = area
		table.insert(areas, area)
	end

	PlayerData.RegisterSlice("Index", function()
		return { Found = {}, Claimed = {} }
	end)
	changedPush = Net.Push("Index.Changed")
	Net.Handle("Index.Get", {
		rate = { burst = 4, perSecond = 1 },
		args = {},
		handler = function(player: Player): Net.Result
			local profile = PlayerData.Get(player)
			return if profile then Net.ok(view(profile)) else Net.fail("NotReady")
		end,
	})
	Net.Handle("Index.Claim", {
		rate = { burst = 3, perSecond = 1 },
		args = { Net.T.key(areaById) },
		handler = claim,
	})

	Inventory.Changed:Connect(scan)
	PlayerData.Loaded:Connect(scan)
end

return Index

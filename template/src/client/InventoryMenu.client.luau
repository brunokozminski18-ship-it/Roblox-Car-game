--!strict
--[[
	INVENTORY in style D (playbook/UI_STYLE.md). Our layout:
	  top    slots bar "USED / CAPACITY" with a green "+" (Slots.Buy, soft currency)
	  grid   cards in their rarity colour (layout from A3), tags for
	         count and EQUIPPED
	  top    detail panel for the selected card with one EQUIP/UNEQUIP action
	Tabs filter ALL / PETS / ITEMS.

	Server-owned: the grid renders Inventory.Snapshot / Inventory.Changed and
	sends intents (Inventory.Equip, Inventory.Unequip, Slots.Buy). Names, rarity
	and stats come from GameConfig.Inventory.items.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Controller = require(ReplicatedStorage:WaitForChild("LihFolkUI"):WaitForChild("LihFolkUIController"))
local Style = ReplicatedStorage:WaitForChild("UIStyle")
local Theme = require(Style:WaitForChild("StyleD"))
local UI = require(Style:WaitForChild("Components"))
local Launcher = require(Style:WaitForChild("Launcher"))
local Toast = require(Style:WaitForChild("Toast"))
local ItemArt = require(Style:WaitForChild("ItemArt"))
local Net = require(ReplicatedStorage:WaitForChild("LihFolk"):WaitForChild("Net"))
local Config = require(ReplicatedStorage:WaitForChild("GameConfig")) :: any

local Color = Theme.Color
local ITEMS = Config.Inventory.items
local SLOT_PRICE = Config.Slots.price

type Entry = { key: string, itemId: string, uid: string?, count: number, equipped: boolean }

local render: (snap: any) -> () -- defined below, used by the slots button

Controller.start()
local window = UI.Window({ name = "Inventory", title = "Inventory" })
local body: ScrollingFrame = window.body

-- Slots bar ----------------------------------------------------------------
local slotsRow = Instance.new("Frame")
slotsRow.Name = "Slots"
slotsRow.BackgroundTransparency = 1
slotsRow.Size = UDim2.new(1, 0, 0, 56)
slotsRow.LayoutOrder = 1
slotsRow.Parent = body
UI.Text("SLOTS", { size = 22, font = Theme.Font.title, box = UDim2.fromOffset(90, 56), parent = slotsRow })
local slots = UI.ProgressBar(UDim2.new(1, -330, 0, 44), slotsRow)
slots.root.Position = UDim2.new(0, 96, 0.5, 0)
slots.root.AnchorPoint = Vector2.new(0, 0.5)
UI.Text(`+{Config.Slots.step} FOR {UI.formatNumber(SLOT_PRICE.amount)} {string.upper(SLOT_PRICE.currency)}`, {
	size = 20,
	color = Color.textDim,
	align = Enum.TextXAlignment.Right,
	box = UDim2.fromOffset(160, 56),
	wrap = true,
	position = UDim2.new(1, -66, 0, 0),
	anchor = Vector2.new(1, 0),
	parent = slotsRow,
})
UI.Button({
	text = "+",
	textSize = 34,
	size = UDim2.fromOffset(56, 56),
	position = UDim2.new(1, 0, 0, 0),
	anchor = Vector2.new(1, 0),
	name = "BuySlots",
	parent = slotsRow,
	onActivated = function()
		task.spawn(function()
			local result = Net.Request("Slots.Buy")
			Toast.Result(result, if result.ok then `Slots: {result.data.capacity}` else nil)
			if result.ok then
				local snap = Net.Request("Inventory.Snapshot")
				if snap.ok then
					render(snap.data)
				end
			end
		end)
	end,
})

-- Grid + detail ------------------------------------------------------------
local split = Instance.new("Frame")
split.Name = "Split"
split.BackgroundTransparency = 1
split.Size = UDim2.fromScale(1, 0)
split.AutomaticSize = Enum.AutomaticSize.Y
split.LayoutOrder = 2
split.Parent = body
local splitList = Instance.new("UIListLayout")
splitList.Padding = UDim.new(0, 16)
splitList.SortOrder = Enum.SortOrder.LayoutOrder
splitList.Parent = split

local gridHolder = Instance.new("Frame")
gridHolder.Name = "Grid"
gridHolder.BackgroundTransparency = 1
gridHolder.Size = UDim2.new(1, 0, 0, 0)
gridHolder.LayoutOrder = 2
gridHolder.AutomaticSize = Enum.AutomaticSize.Y
gridHolder.Parent = split
local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(1 / 3, -8, 0, 170)
grid.CellPadding = UDim2.fromOffset(12, 12)
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = gridHolder

local empty = UI.Text("Nothing here yet. Rewards, codes and the shop fill your inventory.", {
	size = 20,
	color = Color.textDim,
	wrap = true,
	box = UDim2.new(1, 0, 0, 60),
	parent = split,
})

local detail = UI.Panel(UDim2.new(1, 0, 0, 208), 1, split)
local detailArtHolder = Instance.new("Frame")
detailArtHolder.Name = "ArtHolder"
detailArtHolder.BackgroundTransparency = 1
detailArtHolder.Position = UDim2.fromOffset(16, 14)
detailArtHolder.Size = UDim2.new(0.3, -24, 1, -28)
detailArtHolder.Parent = detail
local detailName = UI.Text("", { size = 26, font = Theme.Font.title, box = UDim2.new(0.66, -20, 0, 36), position = UDim2.new(0.32, 0, 0, 18), parent = detail })
local detailRarity = UI.Text("", { size = 18, color = Color.tier, box = UDim2.new(0.66, -20, 0, 28), position = UDim2.new(0.32, 0, 0, 60), parent = detail })
local detailStat = UI.Text("", { size = 20, color = Color.textDim, box = UDim2.new(0.66, -20, 0, 28), position = UDim2.new(0.32, 0, 0, 94), parent = detail })
local equipButton = UI.Button({
	text = "EQUIP",
	size = UDim2.new(0.66, -20, 0, 56),
	position = UDim2.new(0.32, 0, 1, -16),
	anchor = Vector2.new(0, 1),
	parent = detail,
})

-- On short screens the selected item's action is the first visible content.
local function fitDetail()
	local compact = window.root.AbsoluteSize.Y < 450
	slotsRow.LayoutOrder = if compact then 3 else 1
	split.LayoutOrder = if compact then 1 else 2
	detail.Size = UDim2.new(1, 0, 0, if compact then 112 else 208)
	if compact then
		detailArtHolder.Position = UDim2.fromOffset(12, 12)
		detailArtHolder.Size = UDim2.fromOffset(88, 88)
		detailName.Position = UDim2.fromOffset(112, 10)
		detailName.Size = UDim2.new(0.72, -136, 0, 32)
		detailRarity.Position = UDim2.fromOffset(112, 42)
		detailRarity.Size = UDim2.new(0.72, -136, 0, 26)
		detailStat.Position = UDim2.fromOffset(112, 72)
		detailStat.Size = UDim2.new(0.72, -136, 0, 28)
		equipButton.root.Size = UDim2.new(0.28, -16, 0, 56)
		equipButton.root.Position = UDim2.new(1, -12, 0.5, 0)
		equipButton.root.AnchorPoint = Vector2.new(1, 0.5)
	else
		detailArtHolder.Position = UDim2.fromOffset(16, 14)
		detailArtHolder.Size = UDim2.new(0.3, -24, 1, -28)
		detailName.Position = UDim2.new(0.32, 0, 0, 18)
		detailName.Size = UDim2.new(0.66, -20, 0, 36)
		detailRarity.Position = UDim2.new(0.32, 0, 0, 60)
		detailRarity.Size = UDim2.new(0.66, -20, 0, 28)
		detailStat.Position = UDim2.new(0.32, 0, 0, 94)
		detailStat.Size = UDim2.new(0.66, -20, 0, 28)
		equipButton.root.Size = UDim2.new(0.66, -20, 0, 56)
		equipButton.root.Position = UDim2.new(0.32, 0, 1, -16)
		equipButton.root.AnchorPoint = Vector2.new(0, 1)
	end
end
window.root:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitDetail)
fitDetail()

local entries: { Entry } = {}
local cards: { [string]: Frame } = {}
local selectedKey: string? = nil
local filterKind = "all"
local tabs: { [string]: any } = {}

local function kindOf(itemId: string): string
	local def = ITEMS[itemId]
	return if def and def.stackable then "item" else "pet"
end

local function setArt(holder: Instance, itemId: string?)
	for _, child in holder:GetChildren() do
		child:Destroy()
	end
	local def = if itemId then ITEMS[itemId] else nil
	UI.ItemArt(ItemArt.image(def and def.art), UDim2.fromScale(1, 1), holder)
end

local function showDetail(entry: Entry?)
	selectedKey = entry and entry.key
	detail.Visible = entry ~= nil
	if not entry then
		return
	end
	local def = ITEMS[entry.itemId] or {}
	setArt(detailArtHolder, entry.itemId)
	detailName.Text = string.upper(def.name or entry.itemId)
	detailRarity.Text = string.upper(def.rarity or "") .. (if entry.count > 1 then `  x{entry.count}` else "")
	detailStat.Text = def.stat or ""
	local canEquip = entry.uid ~= nil and def.equippable == true
	equipButton.root.Visible = canEquip
	equipButton.setText(if entry.equipped then "UNEQUIP" else "EQUIP")
	equipButton.setSwatch(if entry.equipped then Theme.Button.grey else Theme.Button.green)
	for key, card in cards do
		local stroke = card:FindFirstChildOfClass("UIStroke")
		if stroke then
			local e = nil
			for _, x in entries do
				if x.key == key then
					e = x
				end
			end
			local rarity = if e then (ITEMS[e.itemId] or {}).rarity else nil
			stroke.Thickness = if key == entry.key then Theme.Size.cardStroke + 1 else Theme.Size.cardStroke
			stroke.Color = if key == entry.key then Color.text else (Theme.Rarity[rarity or "common"] or Theme.Rarity.common).border
		end
	end
end

local function applyFilter()
	for _, entry in entries do
		local card = cards[entry.key]
		if card then
			card.Visible = filterKind == "all" or kindOf(entry.itemId) == filterKind
		end
	end
	for name, tab in tabs do
		tab.setActive(name == filterKind)
	end
end

-- Rebuilds the grid from a server snapshot { stacks, uniques, capacity }.
render = function(snap: any)
	for _, card in cards do
		card:Destroy()
	end
	table.clear(cards)
	table.clear(entries)
	for _, u in snap.uniques do
		table.insert(entries, { key = u.uid, itemId = u.item, uid = u.uid, count = 1, equipped = u.equipped })
	end
	for _, s in snap.stacks do
		table.insert(entries, { key = "stack:" .. s.item, itemId = s.item, uid = nil, count = s.count, equipped = false })
	end
	table.sort(entries, function(a, b)
		if a.equipped ~= b.equipped then
			return a.equipped
		end
		return a.itemId < b.itemId
	end)
	slots.set(#snap.uniques, snap.capacity or 0)

	for i, entry in entries do
		local def = ITEMS[entry.itemId] or {}
		local card = UI.RarityCard(def.rarity or "common", { layoutOrder = i, parent = gridHolder })
		card.Name = entry.itemId
		cards[entry.key] = card
		-- Template: Free Icon Pack local preview; owner configures production IDs before release.
		UI.ItemArt(ItemArt.image(def.art), UDim2.new(1, -16, 0, 84), card).Position = UDim2.fromOffset(8, 10)
		UI.Text(def.name or entry.itemId, { size = 22, font = Theme.Font.title, align = Enum.TextXAlignment.Center, box = UDim2.new(1, -12, 0, 24), position = UDim2.new(0, 6, 1, -50), parent = card })
		UI.Text(def.stat or "", { size = 20, color = Color.textDim, align = Enum.TextXAlignment.Center, box = UDim2.new(1, -12, 0, 20), position = UDim2.new(0, 6, 1, -26), parent = card })
		if entry.count > 1 then
			UI.Tag(`x{entry.count}`, Color.panel, card).Position = UDim2.fromOffset(6, 6)
		end
		if entry.equipped then
			local tag = UI.Tag("EQUIPPED", Theme.Button.green.bottom, card)
			tag.AnchorPoint = Vector2.new(1, 0)
			tag.Position = UDim2.new(1, -6, 0, 6)
		end
		local hit = Instance.new("TextButton")
		hit.Name = "Select"
		hit.Text = ""
		hit.BackgroundTransparency = 1
		hit.Size = UDim2.fromScale(1, 1)
		hit.ZIndex = 10
		hit.Parent = card
		hit.Activated:Connect(function()
			showDetail(entry)
			body.CanvasPosition = Vector2.zero
		end)
	end
	empty.Visible = #entries == 0
	applyFilter()
	-- Keep the selection across updates when the entry still exists.
	local keep = nil
	for _, entry in entries do
		if entry.key == selectedKey then
			keep = entry
		end
	end
	showDetail(keep or entries[1])
end

local busy = false
equipButton.root.Activated:Connect(function()
	if busy or not selectedKey then
		return
	end
	local entry = nil
	for _, e in entries do
		if e.key == selectedKey then
			entry = e
		end
	end
	if not entry or not entry.uid then
		return
	end
	busy = true
	task.spawn(function()
		local result = Net.Request(if entry.equipped then "Inventory.Unequip" else "Inventory.Equip", entry.uid)
		if not result.ok then
			Toast.Result(result)
		end
		busy = false
	end)
end)

-- Filter tabs --------------------------------------------------------------
for i, def in { { "all", "All" }, { "pet", "Pets" }, { "item", "Items" } } do
	tabs[def[1]] = UI.Tab(def[2], i, window.tabs, function()
		filterKind = def[1]
		applyFilter()
	end)
end
applyFilter()
showDetail(nil)

window.defaultSelection = tabs.all.root
Controller.register(window)
Launcher.add("Inventory", "inventory", 2)

-- Server data --------------------------------------------------------------
Net.On("Inventory.Changed", function(snap: any)
	render(snap)
end)
task.spawn(function()
	-- The profile may still be loading; the Changed push also covers that case.
	for _ = 1, 10 do
		local snap = Net.Request("Inventory.Snapshot")
		if snap.ok then
			render(snap.data)
			return
		end
		task.wait(1.5)
	end
end)

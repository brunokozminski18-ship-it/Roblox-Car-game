--!strict
--[[
	INDEX in style D (playbook/UI_STYLE.md). Our layout:
	  top    collection bar "FOUND / TOTAL" + reward box with one CLAIM action
	  grid   found entries in their rarity colour; not-found entries are a black
	         silhouette (or a dark shape without art) with "???" (layout from A3)
	Tabs switch the area (GameConfig.Index.areas).

	Server-owned: renders Index.Get / Index.Changed, sends Index.Claim(areaId).
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
local AREAS = Config.Index.areas

Controller.start()
local window = UI.Window({ name = "Index", title = "Index" })
local body: ScrollingFrame = window.body

-- Collection bar + reward --------------------------------------------------
local top = Instance.new("Frame")
top.Name = "Top"
top.BackgroundTransparency = 1
top.Size = UDim2.new(1, 0, 0, 136)
top.LayoutOrder = 1
top.Parent = body

local progress = UI.ProgressBar(UDim2.new(1, 0, 0, 40), top)
progress.root.AnchorPoint = Vector2.zero
progress.root.Position = UDim2.fromScale(0, 0)

local rewardBox = UI.Panel(UDim2.new(1, 0, 0, 72), 0, top)
rewardBox.AnchorPoint = Vector2.new(1, 0)
rewardBox.Position = UDim2.new(1, 0, 0, 56)
local rewardLabel = UI.Text("", { size = 18, wrap = true, box = UDim2.new(1, -160, 1, -8), position = UDim2.fromOffset(12, 4), parent = rewardBox })
local claim = UI.Button({
	text = "CLAIM",
	size = UDim2.fromOffset(138, 56),
	position = UDim2.new(1, -8, 0.5, 0),
	anchor = Vector2.new(1, 0.5),
	textSize = 22,
	parent = rewardBox,
})

-- Grid ---------------------------------------------------------------------
local gridHolder = Instance.new("Frame")
gridHolder.Name = "Grid"
gridHolder.BackgroundTransparency = 1
gridHolder.Size = UDim2.fromScale(1, 0)
gridHolder.AutomaticSize = Enum.AutomaticSize.Y
gridHolder.LayoutOrder = 2
gridHolder.Parent = body
local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(1 / 3, -8, 0, 170)
grid.CellPadding = UDim2.fromOffset(12, 12)
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = gridHolder

local state: any = nil -- last server view { areas = { ... } }
local currentId: string = AREAS[1].id
local tabs: { [string]: any } = {}

local function areaView(id: string): any
	if not state then
		return nil
	end
	for _, a in state.areas do
		if a.id == id then
			return a
		end
	end
	return nil
end

local function render()
	for _, child in gridHolder:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
	local a = areaView(currentId)
	if not a then
		progress.set(0, 1, "LOADING...")
		rewardLabel.Text = ""
		return
	end
	for i, entry in a.items do
		local def = ITEMS[entry.item] or {}
		if entry.found then
			local card = UI.RarityCard(def.rarity or "common", { layoutOrder = i, parent = gridHolder })
			-- Template: Free Icon Pack local preview; owner configures production IDs before release.
			UI.ItemArt(ItemArt.image(def.art), UDim2.new(1, -16, 0, 90), card).Position = UDim2.fromOffset(8, 8)
			UI.Text(def.name or entry.item, { size = 22, font = Theme.Font.title, align = Enum.TextXAlignment.Center, box = UDim2.new(1, -10, 0, 24), position = UDim2.new(0, 5, 1, -48), parent = card })
			UI.Text(string.upper(def.rarity or ""), { size = 20, color = Color.tier, align = Enum.TextXAlignment.Center, box = UDim2.new(1, -10, 0, 20), position = UDim2.new(0, 5, 1, -24), parent = card })
		else
			local card = UI.RarityCard("unknown", { layoutOrder = i, parent = gridHolder })
			local holder = Instance.new("Frame")
			holder.BackgroundTransparency = 1
			holder.Size = UDim2.new(1, 0, 0, 104)
			holder.Parent = card
			local shadow = ItemArt.silhouette(def.art)
			if shadow then
				-- Silhouette from the selected Free Icon Pack artwork (items_d).
				local image = Instance.new("ImageLabel")
				image.BackgroundTransparency = 1
				image.Image = shadow
				image.ScaleType = Enum.ScaleType.Fit
				image.AnchorPoint = Vector2.new(0.5, 0.5)
				image.Position = UDim2.fromScale(0.5, 0.52)
				image.Size = UDim2.fromScale(0.85, 0.85)
				image.Parent = holder
			else
				UI.Silhouette(holder)
			end
			UI.Text("???", { size = 20, font = Theme.Font.title, color = Color.textMuted, align = Enum.TextXAlignment.Center, box = UDim2.new(1, -10, 0, 26), position = UDim2.new(0, 5, 1, -40), parent = card })
		end
	end
	progress.set(a.found, a.total, `{a.found} / {a.total} FOUND`)
	rewardLabel.Text = `REWARD: {string.upper(a.reward)}`
	if a.claimed then
		claim.setText("CLAIMED")
		claim.setSwatch(Theme.Button.grey)
	elseif a.found == a.total then
		claim.setText("CLAIM")
		claim.setSwatch(Theme.Button.green)
	else
		claim.setText("LOCKED")
		claim.setSwatch(Theme.Button.grey)
	end
end

local busy = false
claim.root.Activated:Connect(function()
	local a = areaView(currentId)
	if busy or not a then
		return
	end
	busy = true
	task.spawn(function()
		local result = Net.Request("Index.Claim", currentId)
		if result.ok then
			state = result.data
			render()
		end
		Toast.Result(result, `+{a.reward}`)
		busy = false
	end)
end)

for i, area in AREAS do
	tabs[area.id] = UI.Tab(area.name, i, window.tabs, function()
		currentId = area.id
		for id, tab in tabs do
			tab.setActive(id == area.id)
		end
		render()
	end)
end
tabs[currentId].setActive(true)
render()

window.defaultSelection = tabs[currentId].root
Controller.register(window)
Launcher.add("Index", "index", 3)

Net.On("Index.Changed", function(view: any)
	state = view
	render()
end)
task.spawn(function()
	for _ = 1, 10 do
		local result = Net.Request("Index.Get")
		if result.ok then
			state = result.data
			render()
			return
		end
		task.wait(1.5)
	end
end)

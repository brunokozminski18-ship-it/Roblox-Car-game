--!strict
-- Template: style D egg odds/reveal. All odds, prices and grants stay server-owned.
local RS = game:GetService("ReplicatedStorage")
local Style = RS:WaitForChild("UIStyle")
local UI = require(Style:WaitForChild("Components"))
local Theme = require(Style:WaitForChild("StyleD"))
local ItemArt = require(Style:WaitForChild("ItemArt"))
local Toast = require(Style:WaitForChild("Toast"))
local Controller = require(RS:WaitForChild("LihFolkUI"):WaitForChild("LihFolkUIController"))
local Net = require(RS:WaitForChild("LihFolk"):WaitForChild("Net"))
local Config = require(RS:WaitForChild("GameConfig")) :: any

Controller.start()
local window = UI.Window({ name = "Eggs", title = "Eggs" })
local heading = UI.Text("Choose an egg in the world to see its pets.", { size = 24, wrap = true, box = UDim2.new(1, 0, 0, 62), layoutOrder = 1, parent = window.body })
local button = UI.Button({ text = "OPEN ONE", size = UDim2.new(1, 0, 0, 56), layoutOrder = 2, parent = window.body })
local gridHolder = Instance.new("Frame")
gridHolder.Name = "Pets"
gridHolder.BackgroundTransparency = 1
gridHolder.Size = UDim2.fromScale(1, 0)
gridHolder.AutomaticSize = Enum.AutomaticSize.Y
gridHolder.LayoutOrder = 3
gridHolder.Parent = window.body
local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(1 / 3, -12, 0, 210)
grid.CellPadding = UDim2.fromOffset(18, 18)
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = gridHolder
local disclaimer = UI.Text("", { size = 20, wrap = true, box = UDim2.new(1, 0, 0, 56), layoutOrder = 4, parent = window.body })
local selected: string? = nil
local busy = false
local revision = 0

local function clearCards()
	for _, child in gridHolder:GetChildren() do
		if child:IsA("GuiObject") then child:Destroy() end
	end
end

local function petCard(id: string, detail: string, order: number)
	local pet = Config.Inventory.items[id] or {}
	local card = UI.RarityCard(pet.rarity or "common", { layoutOrder = order, parent = gridHolder })
	UI.ItemArt(ItemArt.image(pet.art), UDim2.new(1, -24, 0, 102), card).Position = UDim2.fromOffset(12, 10)
	UI.Text(pet.name or id, { size = 24, align = Enum.TextXAlignment.Center, box = UDim2.new(1, -16, 0, 32), position = UDim2.fromOffset(8, 112), parent = card })
	UI.Text(`x{pet.power or 1} Power`, { size = 20, align = Enum.TextXAlignment.Center, box = UDim2.new(1, -16, 0, 26), position = UDim2.fromOffset(8, 146), parent = card })
	UI.Text(detail, { size = 22, color = Theme.Color.tier, align = Enum.TextXAlignment.Center, box = UDim2.new(1, -16, 0, 28), position = UDim2.new(0, 8, 1, -34), parent = card })
end

local function showOdds(id: string)
	revision += 1
	local version = revision
	selected = nil
	heading.Text = "Loading odds..."
	button.setText("LOADING...")
	button.setSwatch(Theme.Button.grey)
	disclaimer.Text = ""
	clearCards()
	Controller.open("Eggs")
	local response = Net.Request("Eggs.GetOdds", id)
	if version ~= revision then return end
	if not response.ok then
		Toast.Result(response)
		heading.Text = "Move closer to the egg and try again."
		button.setText("VIEW ODDS AT THE EGG")
		return
	end
	local odds = response.data
	heading.Text = `{odds.name} - {UI.formatNumber(odds.price.amount)} Cash`
	for i, row in odds.rows do
		petCard(row.id, row.text, i)
	end
	disclaimer.Text = odds.disclaimer
	button.setText("OPEN ONE")
	button.setSwatch(if odds.allowed then Theme.Button.green else Theme.Button.grey)
	selected = if odds.allowed then id else nil
end

button.root.Activated:Connect(function()
	local id = selected
	if busy or not id then return end
	busy = true
	selected = nil
	task.spawn(function()
		local response = Net.Request("Eggs.Hatch", id, 1)
		if not response.ok then Toast.Result(response); showOdds(id) end
		busy = false
	end)
end)
window.defaultSelection = button.root
Controller.register(window)
Net.On("Eggs.Open", function(id: string) task.spawn(showOdds, id) end)
Net.On("Eggs.Result", function(_id: string, pets: any)
	revision += 1
	selected = nil
	clearCards()
	heading.Text = "HATCHED!"
	for i, result in pets do
		local pet = Config.Inventory.items[result.item] or {}
		petCard(result.item, string.upper(pet.rarity or ""), i)
	end
	disclaimer.Text = "Equip your pet in Inventory to boost Power!"
	button.setText("VIEW ODDS AT THE EGG")
	button.setSwatch(Theme.Button.grey)
	Controller.open("Eggs")
end)
Net.On("Eggs.OddsChanged", function(id: string?)
	local current = selected
	if current and (not id or id == current) and Controller.isOpen("Eggs") then
		task.spawn(showOdds, current)
	end
end)

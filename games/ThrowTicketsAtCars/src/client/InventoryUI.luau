--!strict
-- One mobile-first style D sample. Appearance/balance: NOT FINAL.
-- Snapshots own the list; this module only selects cars and requests server actions.
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Config = require(game.ReplicatedStorage.ThrowTickets.Config)
local S = require(script.Parent.Style)

type Car = {Id: string, Name: string, Biome: number, Rarity: number, Income: number, Slot: number}
type Card = {root: TextButton, outline: UIStroke, name: TextLabel, rarity: TextLabel, income: TextLabel}
local InventoryUI = {}
local GOLD = Color3.fromHex("FFD24A")

local function short(value: number): string
	for _, unit in {{1e12, "T"}, {1e9, "B"}, {1e6, "M"}, {1e3, "K"}} do
		if value >= unit[1] then
			return string.format("%.1f%s", math.floor(value / unit[1] * 10) / 10, unit[2])
		end
	end
	return tostring(math.floor(value * 10) / 10)
end

-- No decorative animation: reduced-motion players receive the same static controls.
local function button(parent: Instance, name: string, caption: string, size: UDim2, position: UDim2): TextButton
	local b = Instance.new("TextButton")
	b.Name, b.Text, b.Size, b.Position = name, "", size, position
	b.BackgroundColor3, b.BorderSizePixel, b.AutoButtonColor = Color3.new(1, 1, 1), 0, false
	b.Parent = parent
	S.corner(b, 22)
	S.stroke(b, 3)
	local label = S.text(b, "Caption", caption, 20, UDim2.new(), UDim2.fromScale(1, 1))
	label.TextXAlignment = Enum.TextXAlignment.Center
	return b
end

function InventoryUI.mount(world: Folder, garage: RemoteEvent, snapshots: RemoteEvent, travel: RemoteEvent): any
	local p = Players.LocalPlayer
	local playerGui = p:WaitForChild("PlayerGui")
	local gui = Instance.new("ScreenGui")
	gui.Name, gui.ResetOnSpawn, gui.DisplayOrder = "TicketInventory", false, 12
	gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	gui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui:SetAttribute("SelectedCarId", "")
	gui:SetAttribute("InventoryCount", 0)
	gui:SetAttribute("SampleStatus", "NOT FINAL")
	gui.Parent = playerGui

	local hint = S.text(gui, "Hint", "", 16, UDim2.fromOffset(12, 48), UDim2.fromOffset(350, 44))
	hint.TextWrapped = true
	hint.TextYAlignment = Enum.TextYAlignment.Top
	local back = button(gui, "BackToRoad", "BACK TO ROAD", UDim2.fromOffset(160, 44), UDim2.new(1, -12, 0, 48))
	back.AnchorPoint = Vector2.new(1, 0)
	local backCaption = back.Caption :: TextLabel
	backCaption.TextSize = 18
	S.gradient(back, Color3.fromHex("74E6FF"), Color3.fromHex("1E95F0"))

	local count = S.text(gui, "Count", "CARS 0 / 20", 15, UDim2.new(0, 130, 1, -96), UDim2.fromOffset(150, 20))
	local list = Instance.new("ScrollingFrame")
	list.Name = "Cars"
	list.AnchorPoint, list.Position = Vector2.new(0, 1), UDim2.new(0, 130, 1, -8)
	list.Size = UDim2.new(1, -234, 0, 66)
	list.BackgroundTransparency, list.BorderSizePixel, list.ScrollBarThickness = 1, 0, 3
	list.ScrollBarImageColor3 = GOLD
	list.CanvasSize = UDim2.new()
	list.AutomaticCanvasSize = Enum.AutomaticSize.X
	list.ScrollingDirection = Enum.ScrollingDirection.X
	list.Parent = gui
	local layout = Instance.new("UIListLayout")
	layout.FillDirection, layout.SortOrder, layout.Padding = Enum.FillDirection.Horizontal, Enum.SortOrder.LayoutOrder, UDim.new(0, 8)
	layout.Parent = list
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft, padding.PaddingRight, padding.PaddingTop = UDim.new(0, 4), UDim.new(0, 4), UDim.new(0, 3)
	padding.Parent = list
	local empty = S.text(gui, "Empty", "Catch cars on the road!", 16, list.Position, list.Size)
	empty.AnchorPoint, empty.TextXAlignment = Vector2.new(0, 1), Enum.TextXAlignment.Center

	local function action(name: string, width: number, right: number, top: string, bottom: string): TextButton
		local b = button(gui, name, name:upper(), UDim2.fromOffset(width, 52), UDim2.new(1, -right, 1, -86))
		b.AnchorPoint = Vector2.new(1, 1)
		S.gradient(b, Color3.fromHex(top), Color3.fromHex(bottom))
		return b
	end
	local place = action("Place", 100, 12, "8CF27C", "22B24A")
	local sell = action("Sell", 88, 124, "FF86CF", "E2338C")
	local remove = action("Remove", 100, 224, "D98BFF", "7B2BE6")

	local cars: {Car} = {}
	local byId: {[string]: Car} = {}
	local cards: {[string]: Card} = {}
	local selectedId = ""
	local lastNewestId = ""
	local inventoryCount, inventoryLimit = 0, Config.InventoryLimit or 20
	local cardWidth, cardHeight, rowHeight = 108, 60, 66
	local hasSnapshot, alive, synced = false, true, false
	local connections: {RBXScriptConnection} = {}
	local nearestFree, nearestOccupied = 0, 0
	local occupiedId = ""
	local lastRequest = -math.huge

	local function connect(signal: RBXScriptSignal, callback: (...any) -> ())
		table.insert(connections, signal:Connect(callback))
	end
	local function shopOpen(): boolean
		local shop = playerGui:FindFirstChild("TicketShop")
		return shop ~= nil and shop:GetAttribute("Open") == true
	end
	local function ready(): boolean
		return hasSnapshot and p:GetAttribute("DataReady") == true and p:GetAttribute("Throwing") ~= true and not shopOpen()
	end
	local function onPlot(): boolean
		return p:GetAttribute("Location") == "Plot"
	end
	local function selected(): Car?
		local car = byId[selectedId]
		return if car and car.Slot == 0 then car else nil
	end
	local function enabled(b: TextButton, value: boolean)
		b.Active, b.Selectable = value, value
		b:SetAttribute("Enabled", value)
		b.BackgroundColor3 = if value then Color3.new(1, 1, 1) else Color3.fromRGB(105, 105, 115)
		local caption = b.Caption :: TextLabel
		caption.TextTransparency = if value then 0 else .35
	end
	local function selectCar(id: string)
		selectedId = id
		gui:SetAttribute("SelectedCarId", id)
		for carId, card in cards do
			card.outline.Color = if carId == id then GOLD else S.INK
			card.outline.Thickness = if carId == id then 3 else 2
			card.root:SetAttribute("Selected", carId == id)
		end
	end

	local function refreshActions()
		nearestFree, nearestOccupied, occupiedId = 0, 0, ""
		local plotVisible = onPlot() and not shopOpen()
		local usable = ready() and onPlot()
		if usable then
			local parking = world:FindFirstChild("Parking")
			local plot = if parking then parking:FindFirstChild(tostring(p.UserId)) else nil
			local character = p.Character
			local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
			if plot and root and root:IsA("BasePart") then
				local freeDistance, occupiedDistance = math.huge, math.huge
				for i = 1, Config.ParkingSlots do
					local slot = plot:FindFirstChild("Slot" .. i)
					if slot and slot:IsA("BasePart") and slot:GetAttribute("OwnerId") == p.UserId then
						local distance = (root.Position - slot.Position).Magnitude
						if distance <= Config.PlacementDistance then
							local carId = slot:GetAttribute("CarId")
							if type(carId) == "string" and carId ~= "" then
								if distance < occupiedDistance then
									occupiedDistance, nearestOccupied, occupiedId = distance, i, carId
								end
							elseif distance < freeDistance then
								freeDistance, nearestFree = distance, i
							end
						end
					end
				end
			end
		end
		for _, b in {place, sell, remove} do b.Visible = plotVisible end
		back.Visible = not shopOpen()
		local backText = back.Caption :: TextLabel
		backText.Text = if onPlot() then "BACK TO ROAD" else "MY PLOT"
		hint.Visible = plotVisible
		list.Visible, count.Visible = not shopOpen(), not shopOpen()
		empty.Visible = #cars == 0 and not shopOpen()
		list.ScrollingEnabled = ready()
		for _, card in cards do card.root.Active, card.root.Selectable = ready(), ready() end
		enabled(place, usable and selected() ~= nil and nearestFree > 0)
		enabled(sell, usable and selected() ~= nil)
		enabled(remove, usable and nearestOccupied > 0 and inventoryCount < inventoryLimit)
		enabled(back, ready())
		gui:SetAttribute("PlaceSlot", nearestFree)
		gui:SetAttribute("RemoveSlot", nearestOccupied)
		if p:GetAttribute("DataReady") ~= true or not hasSnapshot then
			hint.Text = "Loading your cars..."
		elseif p:GetAttribute("Throwing") == true then
			hint.Text = "Your car is on its way!"
		elseif inventoryCount >= inventoryLimit and nearestOccupied > 0 then
			hint.Text = "Inventory full. Place or sell a car first."
		elseif selected() and nearestFree > 0 then
			hint.Text = "PLACE parks your selected car here."
		elseif selected() then
			hint.Text = "Walk closer to a free parking spot."
		elseif nearestOccupied > 0 then
			hint.Text = "REMOVE returns this car to your inventory."
		elseif #cars > 0 then
			hint.Text = "Select a car, then approach a free spot."
		else
			hint.Text = "Catch cars on the road, then park them here."
		end
	end

	local function resize()
		local larger = GuiService.PreferredTextSize ~= Enum.PreferredTextSize.Medium
		cardWidth, cardHeight, rowHeight = if larger then 150 else 108, if larger then 84 else 60, if larger then 90 else 66
		local width = gui.AbsoluteSize.X
		local left = math.min(130, math.max(12, width * .22))
		local right = math.min(104, math.max(12, width * .17))
		list.Position = UDim2.new(0, left, 1, -8)
		list.Size = UDim2.fromOffset(math.max(44, width - left - right), rowHeight)
		empty.Position, empty.Size = list.Position, list.Size
		count.Position = UDim2.new(0, left, 1, -rowHeight - 30)
		count.Size = UDim2.fromOffset(if larger then 180 else 150, 22)
		hint.Size = UDim2.fromOffset(math.max(100, math.min(350, width - 196)), 60)
		for _, b in {place, sell, remove} do b.Position = UDim2.new(1, b.Position.X.Offset, 1, -rowHeight - 20) end
		for _, card in cards do
			card.root.Size = UDim2.fromOffset(cardWidth, cardHeight)
			card.name.Size = UDim2.new(1, -10, 0, if larger then 30 else 22)
			card.rarity.Position = UDim2.fromOffset(5, if larger then 31 else 22)
			card.rarity.Size = UDim2.new(1, -10, 0, if larger then 22 else 15)
			card.income.Position = UDim2.fromOffset(5, if larger then 55 else 37)
			card.income.Size = UDim2.new(1, -10, 0, if larger then 27 else 20)
		end
	end

	-- Connect before requesting Sync, including when DataReady was already set.
	connect(snapshots.OnClientEvent, function(snapshot: any)
		if type(snapshot) ~= "table" or type(snapshot.Cars) ~= "table" then return end
		local nextCars: {Car}, nextById: {[string]: Car} = {}, {}
		for _, car in snapshot.Cars do
			if type(car) == "table" and type(car.Id) == "string" and type(car.Name) == "string"
				and type(car.Slot) == "number" and type(car.Income) == "number" and type(car.Rarity) == "number" then
				nextById[car.Id] = car
				if car.Slot == 0 then table.insert(nextCars, car) end
			end
		end
		cars, byId, hasSnapshot = nextCars, nextById, true
		inventoryCount = if type(snapshot.InventoryCount) == "number" then snapshot.InventoryCount else #cars
		inventoryLimit = if type(snapshot.Limit) == "number" then snapshot.Limit else Config.InventoryLimit or 20
		gui:SetAttribute("InventoryCount", inventoryCount)
		count.Text = string.format("CARS %d / %d", inventoryCount, inventoryLimit)
		local retained: {[string]: boolean} = {}
		for i, car in cars do
			retained[car.Id] = true
			local card = cards[car.Id]
			if not card then
				local b = button(list, car.Id, "", UDim2.fromOffset(cardWidth, cardHeight), UDim2.new())
				local caption = b:FindFirstChild("Caption")
				if caption then caption:Destroy() end
				S.gradient(b, Color3.fromHex("74E6FF"), Color3.fromHex("1E95F0"))
				local round = b:FindFirstChildOfClass("UICorner")
				if round then round.CornerRadius = UDim.new(0, 16) end
				local name = S.text(b, "Name", "", 16, UDim2.fromOffset(5, 1), UDim2.new(1, -10, 0, 22))
				local rarity = S.text(b, "Rarity", "", 12, UDim2.fromOffset(5, 22), UDim2.new(1, -10, 0, 15))
				local income = S.text(b, "Income", "", 14, UDim2.fromOffset(5, 37), UDim2.new(1, -10, 0, 20))
				for _, label in {name, rarity, income} do label.TextTruncate = Enum.TextTruncate.AtEnd end
				card = {root = b, outline = b:FindFirstChildOfClass("UIStroke") :: UIStroke, name = name, rarity = rarity, income = income}
				cards[car.Id] = card
				local id = car.Id
				b.Activated:Connect(function()
					if ready() and byId[id] and byId[id].Slot == 0 then selectCar(id); refreshActions() end
				end)
			end
			card.root.LayoutOrder = i
			card.root:SetAttribute("CarId", car.Id)
			card.name.Text = car.Name
			local rarity = Config.Rarities[car.Rarity]
			card.rarity.Text = if rarity then rarity.Name:upper() else "CAR"
			card.rarity.TextColor3 = if rarity then rarity.Color else Color3.new(1, 1, 1)
			card.income.Text = "$" .. short(car.Income) .. "/s"
		end
		for id, card in cards do
			if not retained[id] then card.root:Destroy(); cards[id] = nil end
		end
		local previousId = selectedId
		local newestId = if type(snapshot.NewestId) == "string" then snapshot.NewestId else ""
		if newestId ~= "" and newestId ~= lastNewestId and retained[newestId] then selectedId = newestId end
		if newestId ~= "" then lastNewestId = newestId end
		if not retained[selectedId] then selectedId = if cars[1] then cars[1].Id else "" end
		selectCar(selectedId)
		resize()
		refreshActions()
		-- Preserve scrolling on ordinary refresh/sell. Reveal a newly selected capture only.
		if selectedId ~= "" and previousId ~= selectedId then
			local id = selectedId
			task.defer(function()
				if not alive or selectedId ~= id or not cards[id] then return end
				local x = (cards[id].root.LayoutOrder - 1) * (cardWidth + 8)
				if x < list.CanvasPosition.X or x + cardWidth > list.CanvasPosition.X + list.AbsoluteSize.X then
					list.CanvasPosition = Vector2.new(math.max(0, x - math.max(0, list.AbsoluteSize.X - cardWidth)), 0)
				end
			end)
		end
	end)

	local function requestAllowed(): boolean
		refreshActions()
		if not ready() or not onPlot() or os.clock() - lastRequest < .25 then return false end
		lastRequest = os.clock()
		return true
	end
	connect(place.Activated, function()
		if requestAllowed() and selected() and nearestFree > 0 then garage:FireServer("Place", selectedId, nearestFree) end
	end)
	connect(remove.Activated, function()
		if requestAllowed() and nearestOccupied > 0 and occupiedId ~= "" and inventoryCount < inventoryLimit then
			garage:FireServer("Remove", occupiedId, nearestOccupied)
		end
	end)
	connect(sell.Activated, function()
		if requestAllowed() and selected() then garage:FireServer("Sell", selectedId, 0) end
	end)
	connect(back.Activated, function()
		if ready() and os.clock()-lastRequest>=.25 then lastRequest=os.clock();travel:FireServer(if onPlot() then "Road" else "Plot")end
	end)
	local function sync()
		if p:GetAttribute("DataReady") == true and not synced then
			synced = true
			garage:FireServer("Sync", "", 0)
		end
		refreshActions()
	end
	for _, attribute in {"Location", "Throwing", "DataReady"} do
		connect(p:GetAttributeChangedSignal(attribute), if attribute == "DataReady" then sync else refreshActions)
	end
	local function observeShop(shop: Instance)
		if shop.Name == "TicketShop" then connect(shop:GetAttributeChangedSignal("Open"), refreshActions); refreshActions() end
	end
	connect(playerGui.ChildAdded, observeShop)
	local shop = playerGui:FindFirstChild("TicketShop")
	if shop then observeShop(shop) end
	connect(gui:GetPropertyChangedSignal("AbsoluteSize"), resize)
	connect(GuiService:GetPropertyChangedSignal("PreferredTextSize"), resize)
	local elapsed = 0
	connect(RunService.Heartbeat, function(dt: number)
		elapsed += dt
		if elapsed >= .1 then elapsed = 0; refreshActions() end
	end)
	gui.Destroying:Connect(function()
		alive = false
		for _, connection in connections do connection:Disconnect() end
	end)
	resize()
	sync()
	return {gui = gui, isSelecting = function(): boolean return onPlot() and ready() and selected() ~= nil end}
end

return InventoryUI

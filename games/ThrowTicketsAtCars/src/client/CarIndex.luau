--!strict
local Config = require(game.ReplicatedStorage.ThrowTickets.Config)
local Style = require(script.Parent.Style)
local Preview = require(script.Parent.CarPreview)

local Index = {}
local GAP = 8
local GOLD = Color3.fromHex("FFD24A")

local function frame(parent: Instance, name: string, color: Color3): Frame
	local node = Instance.new("Frame")
	node.Name = name
	node.BackgroundColor3 = color
	node.BorderSizePixel = 0
	node.Parent = parent
	return node
end

local function label(parent: Instance, name: string, size: number): TextLabel
	local node = Style.text(parent, name, "", size, UDim2.new(), UDim2.new())
	node.TextXAlignment = Enum.TextXAlignment.Center
	node.TextTruncate = Enum.TextTruncate.AtEnd
	return node
end

function Index.mount(playerGui: Instance, launchButton: GuiButton): any
	local gui = Instance.new("ScreenGui")
	gui.Name = "CarIndex"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 36
	gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	gui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Enabled = false
	gui.Parent = playerGui
	gui:SetAttribute("Open", false)

	local dim = Instance.new("TextButton")
	dim.Name = "Dim"
	dim.Size = UDim2.fromScale(1, 1)
	dim.BackgroundColor3 = Style.INK
	dim.BackgroundTransparency = .3
	dim.Text = ""
	dim.AutoButtonColor = false
	dim.Selectable = false
	dim.Parent = gui

	local panel = frame(gui, "Window", Color3.new(1, 1, 1))
	panel.AnchorPoint = Vector2.new(.5, .5)
	panel.Position = UDim2.fromScale(.5, .5)
	panel.Active = true
	Style.corner(panel, 28)
	Style.stroke(panel, 4)
	Style.gradient(panel, Color3.fromHex("2F7BF2"), Color3.fromHex("16348F"))

	local title = label(panel, "Title", 30)
	title.Text = "CAR INDEX"
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Position = UDim2.fromOffset(16, 6)
	title.Size = UDim2.new(1, -80, 0, 31)
	local total = label(panel, "Total", 16)
	total.TextXAlignment = Enum.TextXAlignment.Left
	total.TextColor3 = GOLD
	total.AnchorPoint=Vector2.new(0,1)
	total.Position = UDim2.new(0,17,1,-8)
	total.Size = UDim2.new(1,-34,0,24)
	total.ZIndex=4;total.TextXAlignment=Enum.TextXAlignment.Center
	local totalTrack=frame(panel,"TotalTrack",Style.INK);totalTrack.Position=UDim2.new(0,15,1,-32);totalTrack.Size=UDim2.new(1,-30,0,24);Style.corner(totalTrack,10)
	local totalFill=frame(totalTrack,"Fill",Color3.fromHex("3187DA"));totalFill.Size=UDim2.fromScale(0,1);Style.corner(totalFill,10)
	local closeButton = Style.button(panel, "Close", "X", UDim2.fromOffset(46, 46), UDim2.new(1, -54, 0, 8))
	closeButton.TextColor3 = Color3.new(1, 1, 1)
	Style.gradient(closeButton, Color3.fromHex("FF6B6B"), Color3.fromHex("E0202F"))

	local list = Instance.new("ScrollingFrame")
	list.Name = "Biomes"
	list.Position = UDim2.fromOffset(12, 62)
	list.Size = UDim2.new(1, -24, 1, -102)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 5
	list.ScrollBarImageColor3 = Color3.fromHex("74E6FF")
	list.ScrollingDirection = Enum.ScrollingDirection.Y
	list.Parent = panel

	local dot = frame(launchButton, "NewDiscovery", Color3.fromHex("F54761"))
	dot.Size = UDim2.fromOffset(14, 14)
	dot.Position = UDim2.new(1, -12, 0, 2)
	dot.ZIndex = launchButton.ZIndex + 2
	dot.Visible = false
	Style.corner(dot, 7)
	Style.stroke(dot, 2)

	local sections: {any} = {}
	local discovered: {[string]: boolean} = {}
	local initialized = false
	local catalogCount = 0
	for index, biome in Config.Biomes do
		local section = frame(list, "Biome" .. index, Color3.new())
		section.BackgroundTransparency = 1
		local tile = frame(section, "BiomeTile", Color3.new(1, 1, 1))
		Style.corner(tile, 16)
		Style.stroke(tile, 2)
		Style.gradient(tile, biome.Color, biome.Color:Lerp(Style.INK, .65))
		local biomeName = label(tile, "BiomeName", 18)
		biomeName.Text = biome.Name
		biomeName.TextWrapped = true
		biomeName.TextTruncate = Enum.TextTruncate.None
		biomeName.Position = UDim2.new(0, 4, .35, -20)
		biomeName.Size = UDim2.new(1, -8, 0, 40)
		local progress = label(section, "Progress", 14)
		progress.TextColor3 = GOLD
		progress.ZIndex=4
		local track = frame(section, "Track", Style.INK)
		Style.corner(track, 5)
		local fill = frame(track, "Fill", GOLD)
		fill.Size = UDim2.fromScale(0, 1)
		Style.corner(fill, 5)
		local cards: {any} = {}
		for _, car in biome.Cars do
			catalogCount += 1
			local color = Config.Rarities[car.Rarity].Color
			local card = frame(section, car.Id, Color3.new(1, 1, 1))
			Style.corner(card, 13)
			Style.stroke(card, 2)
			Style.gradient(card, color:Lerp(Color3.new(1, 1, 1), .28), color:Lerp(Style.INK, .4))
			local host = frame(card, "PreviewHost", Style.INK)
			host.BackgroundTransparency = 1
			host.Position = UDim2.fromOffset(4, 1)
			host.Size = UDim2.new(1, -8, 1, -24)
			local name = label(card, "CarName", 14)
			name.Position = UDim2.new(0, 3, 1, -27)
			name.Size = UDim2.new(1, -6, 0, 14)
			local tier=label(card,"Rarity",11);tier.Position=UDim2.new(0,3,1,-14);tier.Size=UDim2.new(1,-6,0,13)
			table.insert(cards, {root = card, host = host, name = name, tier=tier,data = car})
		end
		table.insert(sections, {root = section, tile = tile, cards = cards, progress = progress, track=track,fill = fill, index = index})
	end
	for i,biome in Config.ComingSoon do
	 local section=frame(list,"ComingSoon"..i,Style.INK);section.BackgroundTransparency=1
	 local tile=frame(section,"BiomeTile",biome.Color:Lerp(Style.INK,.4));Style.corner(tile,16)
	 local title=label(tile,"BiomeName",17);title.Text=biome.Name;title.TextWrapped=true;title.Size=UDim2.fromScale(1,1)
	 local track=frame(section,"Track",Style.INK);local fill=frame(track,"Fill",GOLD)
	 local progress=label(section,"Progress",19);progress.Text="COMING SOON";progress.TextColor3=GOLD
	 table.insert(sections,{root=section,tile=tile,cards={},progress=progress,track=track,fill=fill,coming=true})
	end

	local function paintSection(section: any)
		if section.coming then section.progress.Text="COMING SOON";section.fill.Size=UDim2.fromScale(0,1);return 0 end
		local count = 0
		for _, card in section.cards do
			local unlocked = discovered[card.data.Id] == true
			if unlocked then count += 1 end
			card.name.Text = if unlocked then card.data.Name else "???";card.tier.Text=if unlocked then Config.Rarities[card.data.Rarity].Name else ""
			card.root:SetAttribute("Discovered", unlocked)
		end
		local size = #section.cards
		section.progress.Text = string.format("%d / %d", count, size)
		section.fill.Size = UDim2.fromScale(if size > 0 then count / size else 0, 1)
		return count
	end

	local function updatePreviews()
		if not gui.Enabled then return end
		local top = list.CanvasPosition.Y
		local bottom = top + list.AbsoluteSize.Y
		for _, section in sections do
			local visible = section.top and section.top < bottom + 28 and section.top + section.height > top - 28
			if not visible then continue end
			for _, card in section.cards do
				local unlocked = discovered[card.data.Id] == true
				if card.preview and card.previewUnlocked == unlocked then continue end
				if card.preview then card.preview:Destroy() end
				local car = card.data
				card.preview = Preview.mount(card.host, {
					Biome = section.index, Rarity = car.Rarity, Name = car.Name,
					CatalogId = car.Id, Variant = "Normal",
				}, not unlocked)
				card.previewUnlocked = unlocked
			end
		end
	end

	local function resize()
		local width = math.max(220, math.min(840, gui.AbsoluteSize.X - 24))
		local height = math.max(120, math.min(650, gui.AbsoluteSize.Y - 20))
		panel.Size = UDim2.fromOffset(width, height)
		local compact = width < 650 or height < 360
		local tileWidth = math.floor(width * (if compact then .21 else .19))
		local cellHeight = if compact then 76 else 112
		local cellWidth = math.floor((width - 32 - tileWidth - GAP * 4) / 4)
		local y = 4
		for _, section in sections do
			local rowCount = if section.coming then 1 else math.max(2, math.ceil(#section.cards / 4))
			local cardsHeight=rowCount*(cellHeight+GAP)-GAP
			local sectionHeight = cardsHeight+24
			section.top, section.height = y, sectionHeight
			section.root.Position = UDim2.fromOffset(3, y)
			section.root.Size = UDim2.new(1, -8, 0, sectionHeight)
			section.tile.Size = UDim2.fromOffset(tileWidth, sectionHeight)
			section.track.Position=UDim2.fromOffset(tileWidth+GAP,cardsHeight+4);section.track.Size=UDim2.new(1,-tileWidth-GAP-8,0,18)
			section.progress.Position=section.track.Position;section.progress.Size=section.track.Size
			for i, card in section.cards do
				local col, row = (i - 1) % 4, math.floor((i - 1) / 4)
				card.root.Position = UDim2.fromOffset(tileWidth + GAP + col * (cellWidth + GAP), row * (cellHeight + GAP))
				card.root.Size = UDim2.fromOffset(cellWidth, cellHeight)
			end
			y += sectionHeight + 12
		end
		list.CanvasSize = UDim2.fromOffset(0, y)
		updatePreviews()
	end

	local function setOpen(open: boolean)
		gui.Enabled = open
		gui:SetAttribute("Open", open)
		if open then
			dot.Visible = false
			updatePreviews()
		end
	end

	local function render(snapshot: any)
		if typeof(snapshot) ~= "table" then return end
		local nextDiscovered: {[string]: boolean} = {}
		local hasNew = false
		for _, section in sections do
			for _, card in section.cards do
				local id = card.data.Id
				if snapshot[id] == true then
					nextDiscovered[id] = true
					if not discovered[id] then hasNew = true end
				end
			end
		end
		if initialized and hasNew and not gui.Enabled then dot.Visible = true end
		initialized = true
		discovered = nextDiscovered
		local count = 0
		for _, section in sections do count += paintSection(section) end
		total.Text = string.format("Unlocked: %d/%d", count, catalogCount);totalFill.Size=UDim2.fromScale(count/catalogCount,1)
		updatePreviews()
	end

	gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
	list:GetPropertyChangedSignal("CanvasPosition"):Connect(updatePreviews)
	list:GetPropertyChangedSignal("AbsoluteSize"):Connect(updatePreviews)
	launchButton.Activated:Connect(function() setOpen(not gui.Enabled) end)
	closeButton.Activated:Connect(function() setOpen(false) end)
	dim.Activated:Connect(function() setOpen(false) end)
	resize()
	for _, section in sections do paintSection(section) end
	total.Text = string.format("Unlocked: 0/%d", catalogCount)

	return {gui = gui, render = render, close = function() setOpen(false) end, isOpen = function() return gui.Enabled end}
end

return Index

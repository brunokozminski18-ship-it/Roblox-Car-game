--!strict
local Config = require(game:GetService("ReplicatedStorage").ThrowTickets.Config)
local World = {}

function World.part(parent: Instance, name: string, size: Vector3, position: Vector3, color: Color3): Part
	local p = Instance.new("Part")
	p.Name, p.Size, p.Position = name, size, position
	p.Anchored = true
	p.Material = Enum.Material.SmoothPlastic
	p.Color = color
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

function World.label(parent: BasePart, text: string, offset: number?)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.fromOffset(180, 46)
	gui.StudsOffset = Vector3.new(0, offset or 4, 0)
	gui.MaxDistance = Config.LabelDistance
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 0.25
	label.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextSize = 18
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.Parent, gui.Parent = gui, parent
	return label
end

function World.car(parent: Instance, name: string, tier: number, position: Vector3): Model
	local model = Instance.new("Model")
	model.Name = name
	local body = World.part(model, "Body", Config.CarSize, position, Color3.fromRGB(145, 145, 145))
	World.part(model, "Roof", Config.RoofSize, position + Vector3.new(0, Config.RoofOffset, 0), Config.Tiers[tier].Color)
	for _,p in model:GetChildren() do if p:IsA("BasePart") then p.CanCollide = false end end
	model.PrimaryPart = body
	model.Parent = parent
	return model
end

function World.build(): Folder
	local defaultSpawn = workspace:FindFirstChild("SpawnLocation")
	if defaultSpawn and defaultSpawn:IsA("SpawnLocation") then
		defaultSpawn.Enabled, defaultSpawn.CanCollide, defaultSpawn.Transparency = false, false, 1
		for _,child in defaultSpawn:GetChildren() do if child:IsA("Decal") then child.Transparency = 1 end end
	end
	local previous = workspace:FindFirstChild("TicketPrototype")
	if previous then previous:Destroy() end
	local root = Instance.new("Folder")
	root.Name = "TicketPrototype"
	local gray = Color3.fromRGB(100, 100, 100)
	World.part(root, "Ground", Config.GroundSize, Config.GroundCenter, Color3.fromRGB(165, 165, 165))
	World.part(root, "Road", Config.RoadSize, Config.RoadCenter, gray)
	local line = World.part(root, "ThrowLine", Config.LaunchSize, Config.LaunchCenter, Color3.fromRGB(215, 215, 215))
	World.label(line, "THROW FROM HERE", 1)
	local train = World.part(root, "TrainingPad", Config.TrainingSize, Config.TrainingPosition, Color3.fromRGB(120, 130, 120))
	World.label(train, "TRAIN  +1 POWER / s", 1)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name, spawn.Anchored, spawn.Neutral = "PrototypeSpawn", true, true
	spawn.Size, spawn.Position = Config.SpawnSize, Config.SpawnPosition
	spawn.Transparency, spawn.CanCollide, spawn.Duration = 1, false, 0
	spawn.Parent = root
	for i,tier in Config.Tiers do
		local marker = World.part(root, "Zone" .. i, Vector3.new(1, 0.2, 1), Vector3.new(14, 0.1, -tier.Distance), tier.Color)
		World.label(marker, string.format("%d STUDS  |  $%d / s", tier.Distance, tier.Income), 5)
	end
	for _,name in {"Cars", "Parking", "Tows"} do
		local folder = Instance.new("Folder")
		folder.Name, folder.Parent = name, root
	end
	root.Parent = workspace
	return root
end

function World.parking(root: Folder, plot: number, ownerId: number, displayName: string): (Folder, {Vector3})
	local folder = Instance.new("Folder")
	folder.Name = tostring(ownerId)
	folder.Parent = root.Parking
	local slots = {}
	local origin = Config.ParkingOrigin - Vector3.new((plot - 1) * Config.PlayerPlotSpacing, 0, 0)
	for i = 1,Config.ParkingSlots do
		local col = (i - 1) % Config.ParkingColumns
		local row = math.floor((i - 1) / Config.ParkingColumns)
		local pos = origin - Vector3.new(col * Config.ParkingSpacing.X, 0, row * Config.ParkingSpacing.Z)
		slots[i] = pos + Vector3.new(0, Config.CarHeight, 0)
		World.part(folder, "Slot" .. i, Vector3.new(9, 0.2, 10), pos, Color3.fromRGB(120, 120, 120))
	end
	World.label(folder.Slot1, displayName .. "'s parking", 7)
	return folder,slots
end

return World

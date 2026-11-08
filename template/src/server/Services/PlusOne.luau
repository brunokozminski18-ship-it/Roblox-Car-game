--!strict
-- Template service: the "+1" core (Config.PlusOne). Loop:
--   walk -> Power -> smash walls -> Cash -> buy gear (multiplies Power)
--   -> stronger walls -> boss at the end of the track -> next world.
--   * Steps: every config.stepStuds walked adds config.perStep of config.stat
--     through Currency.Earn (gear and Rebirth multiply). Movement is measured
--     on the server; samples faster than maxSpeed (teleports) earn nothing.
--   * Forms: the highest form with Power >= at sets the character size and,
--     when ReplicatedStorage/PlusOneForms/<form.accessories> exists, its
--     Accessories. Published as the "Form" attribute.
--   * Walls: a player at a wall with Power >= hp breaks it (server check) and
--     earns the reward; the client opens the wall locally. The last wall of a
--     world is its boss: the first win unlocks and moves the player to the next world.
--   * Gear: ProximityPrompt stands on each start pad sell the next gear piece.
-- Saved slice "PlusOne": { Gear, World, Best = { [world] = best wall index } }.
-- Attributes: Form, Gear, World, Best (best wall in the current world).
-- Push: PlusOne.Event(kind, ...) -> "wall"/"boss" (world, index, paid),
--       "gear" (index), "world" (index).

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LihFolk = ServerScriptService:WaitForChild("Server"):WaitForChild("LihFolk")
local PlayerData = require(LihFolk.PlayerData)
local Currency = require(LihFolk.Currency)
local Net = require(ReplicatedStorage:WaitForChild("LihFolk"):WaitForChild("Net"))

export type Form = { at: number, name: string, scale: number, color: Color3, accessories: string? }
export type Config = {
	stat: string,
	reward: string,
	perStep: number,
	stepStuds: number,
	maxSpeed: number,
	forms: { Form },
	gear: { { name: string, price: number, mult: number } },
	walls: { { hp: number, reward: number } },
	worlds: { { name: string, floor: Color3, scale: number, boss: { name: string, hp: number, reward: number } } },
	track: { width: number, spacing: number, gap: number, origin: Vector3 },
}

local TICK = 0.25
local WALL_REACH = 5 -- studs in front of a wall that count as "at the wall"
local WALL_COOLDOWN = 3

local PlusOne = {}

local config: Config
-- walls[world][i] = { part, hp, reward, boss }
local walls: { { { part: BasePart, hp: number, reward: number, boss: boolean } } } = {}
local lastPos: { [Player]: Vector3 } = {}
local carry: { [Player]: number } = {}
local cooldown: { [Player]: { [BasePart]: number } } = {}
local event: Net.Push

-- Pure helpers ------------------------------------------------------------

function PlusOne.formFor(forms: { Form }, power: number): number
	local index = 1
	for i, form in forms do
		if power >= form.at then
			index = i
		end
	end
	return index
end

function PlusOne.wallStats(cfg: Config, world: number, index: number): (number, number, boolean)
	local w = cfg.worlds[world]
	if index > #cfg.walls then
		return w.boss.hp, w.boss.reward, true
	end
	local base = cfg.walls[index]
	return base.hp * w.scale, base.reward * w.scale, false
end

local function shorten(n: number): string
	local suffixes = { "", "K", "M", "B", "T", "Qa" }
	local tier = 1
	while n >= 1000 and tier < #suffixes do
		n /= 1000
		tier += 1
	end
	if tier == 1 then
		return tostring(math.floor(n))
	end
	return (string.format("%.1f", math.floor(n * 10) / 10):gsub("%.0$", "")) .. suffixes[tier]
end

-- World building ------------------------------------------------------------

local function worldOrigin(world: number): Vector3
	return config.track.origin + Vector3.new((world - 1) * (config.track.width + config.track.gap), 0, 0)
end

function PlusOne.StartCFrame(world: number): CFrame
	return CFrame.new(worldOrigin(world) + Vector3.new(0, 4, 6)) * CFrame.Angles(0, 0, 0)
end

local function part(name: string, size: Vector3, position: Vector3, color: Color3, parent: Instance): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.Position = position
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function label(target: BasePart, face: Enum.NormalId, text: string)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 20
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.FredokaOne
	t.TextScaled = true
	t.TextColor3 = Color3.new(1, 1, 1)
	t.TextStrokeTransparency = 0
	t.Text = text
	t.Parent = gui
	gui.Parent = target
end

local function buyGear(player: Player, index: number)
	local profile = PlayerData.Get(player)
	if not profile then
		return
	end
	local state = profile.Data.PlusOne
	if state.Gear ~= index - 1 then
		return -- buy in order; owning it already or skipping ahead does nothing
	end
	if not Currency.Spend(player, config.reward, config.gear[index].price, "gear") then
		return
	end
	state.Gear = index
	PlayerData.MarkDirty(profile)
	player:SetAttribute("Gear", index)
	event:Fire(player, "gear", index)
end

local function buildWorld(world: number, folder: Folder)
	local w = config.worlds[world]
	local t = config.track
	local origin = worldOrigin(world)
	local count = #config.walls + 1
	local length = (count + 1) * t.spacing
	part("Runway", Vector3.new(t.width, 1, length + 20), origin + Vector3.new(0, -0.5, -length / 2 + 10), w.floor, folder)
	local pad = part("StartPad", Vector3.new(t.width, 1.2, 20), origin + Vector3.new(0, -0.4, 10), Color3.fromRGB(245, 245, 250), folder)
	label(pad, Enum.NormalId.Top, string.upper(w.name))
	-- Gear stands along the start pad edges.
	for i, gear in config.gear do
		local side = if i % 2 == 1 then -1 else 1
		local row = math.floor((i - 1) / 2)
		local stand = part(`Gear{i}`, Vector3.new(4, 5, 4), origin + Vector3.new(side * (t.width / 2 - 3), 2.5, 16 - row * 6), Color3.fromRGB(255, 200, 60), folder)
		stand:SetAttribute("GearIndex", i)
		label(stand, if side < 0 then Enum.NormalId.Right else Enum.NormalId.Left, `{string.upper(gear.name)}\nx{gear.mult}`)
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = `Buy {gear.name}`
		prompt.ObjectText = `{shorten(gear.price)} {config.reward}`
		prompt.MaxActivationDistance = 9
		prompt.RequiresLineOfSight = false
		prompt.Parent = stand
		prompt.Triggered:Connect(function(player: Player)
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if root and root:IsA("BasePart") and (root.Position - stand.Position).Magnitude <= 12 then
				buyGear(player, i)
			end
		end)
	end
	walls[world] = {}
	for i = 1, count do
		local hp, reward, boss = PlusOne.wallStats(config, world, i)
		local form = config.forms[math.min(i + 1, #config.forms)]
		local size = if boss then Vector3.new(t.width, 30, 6) else Vector3.new(t.width, 16, 3)
		local wall = part(if boss then "Boss" else `Wall{i}`, size, origin + Vector3.new(0, size.Y / 2, -i * t.spacing), if boss then Color3.fromRGB(200, 40, 60) else form.color, folder)
		wall:SetAttribute("Hp", hp)
		wall:SetAttribute("World", world)
		wall:SetAttribute("Index", i)
		label(wall, Enum.NormalId.Back, if boss then `{string.upper(w.boss.name)}\n{shorten(hp)} POWER` else `{shorten(hp)} POWER`)
		walls[world][i] = { part = wall, hp = hp, reward = reward, boss = boss }
	end
end

local function buildTrack()
	local folder = Instance.new("Folder")
	folder.Name = "PlusOneTrack"
	for world = 1, #config.worlds do
		buildWorld(world, folder)
	end
	folder.Parent = workspace
end

-- Character -----------------------------------------------------------------

local function applyForm(player: Player, power: number)
	local index = PlusOne.formFor(config.forms, power)
	if player:GetAttribute("Form") == index then
		return
	end
	player:SetAttribute("Form", index)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not character or not humanoid then
		return
	end
	local form = config.forms[index]
	for _, name in { "BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale" } do
		local value = humanoid:FindFirstChild(name)
		if value and value:IsA("NumberValue") then
			value.Value = form.scale
		end
	end
	-- Form accessories (a meme reskin drops Accessory models into PlusOneForms/<name>).
	for _, child in character:GetChildren() do
		if child:IsA("Accessory") and child:GetAttribute("PlusOneForm") then
			child:Destroy()
		end
	end
	local library = ReplicatedStorage:FindFirstChild("PlusOneForms")
	local set = form.accessories and library and library:FindFirstChild(form.accessories)
	if set then
		for _, accessory in set:GetChildren() do
			if accessory:IsA("Accessory") then
				local clone = accessory:Clone()
				clone:SetAttribute("PlusOneForm", true)
				humanoid:AddAccessory(clone)
			end
		end
	end
end

local function publish(player: Player, state: any)
	player:SetAttribute("Gear", state.Gear)
	player:SetAttribute("World", state.World)
	player:SetAttribute("Best", state.Best[tostring(state.World)] or 0)
end

local function gearMultiplier(player: Player): number
	local profile = PlayerData.Get(player)
	local gear = profile and profile.Data.PlusOne.Gear or 0
	return if gear > 0 then config.gear[gear].mult else 1
end

-- Tick ----------------------------------------------------------------------

local function step(player: Player)
	local profile = PlayerData.Get(player)
	local character = player.Character
	-- lihfolk-ignore: findfirstchild-chain (type cast only; nil is checked below)
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not profile or not root or not humanoid or humanoid.Health <= 0 then
		lastPos[player] = nil
		return
	end
	local pos = root.Position
	local prev = lastPos[player]
	lastPos[player] = pos
	if prev then
		local moved = Vector3.new(pos.X - prev.X, 0, pos.Z - prev.Z).Magnitude
		if moved <= config.maxSpeed * TICK * 1.5 then
			carry[player] = (carry[player] or 0) + moved
			local steps = math.floor(carry[player] / config.stepStuds)
			if steps > 0 then
				carry[player] -= steps * config.stepStuds
				Currency.Earn(player, config.stat, steps * config.perStep, "step")
			end
		end
	end
	-- Walls of the player's unlocked worlds: the server decides; the client plays the break.
	local state = profile.Data.PlusOne
	local power = Currency.Get(player, config.stat) or 0
	local now = os.clock()
	local cd = cooldown[player]
	if not cd then
		cd = {}
		cooldown[player] = cd
	end
	for world = 1, math.min(state.World, #config.worlds) do
		for i, wall in walls[world] do
			local rel = wall.part.CFrame:PointToObjectSpace(pos)
			-- Either side, so a player coming back to the start pad is never shut in.
			local atWall = math.abs(rel.X) <= wall.part.Size.X / 2 + 1 and math.abs(rel.Z) <= wall.part.Size.Z / 2 + WALL_REACH
			if atWall and power >= wall.hp and (cd[wall.part] or 0) <= now then
				cd[wall.part] = now + WALL_COOLDOWN
				local _, paid = Currency.Earn(player, config.reward, wall.reward, if wall.boss then "boss" else "wall")
				local key = tostring(world)
				if i > (state.Best[key] or 0) then
					state.Best[key] = i
					PlayerData.MarkDirty(profile)
				end
				if wall.boss and world == state.World and world < #config.worlds then
					state.World = world + 1
					PlayerData.MarkDirty(profile)
					event:Fire(player, "boss", world, i, paid)
					task.delay(1.5, function()
						if player.Character == character then
							character:PivotTo(PlusOne.StartCFrame(world + 1))
						end
						event:Fire(player, "world", world + 1)
					end)
				else
					event:Fire(player, "wall", world, i, paid)
				end
				publish(player, state)
			end
		end
	end
end

function PlusOne.Init(newConfig: Config)
	config = newConfig
	assert(Currency.Exists(config.stat) and Currency.Exists(config.reward), "PlusOne: unknown currency")
	assert(config.stepStuds > 0 and config.perStep >= 1 and #config.forms >= 1 and #config.worlds >= 1, "PlusOne: bad config")
	PlayerData.RegisterSlice("PlusOne", function()
		return { Gear = 0, World = 1, Best = {} }
	end)
	Currency.AddMultiplier(config.stat, gearMultiplier)
	event = Net.Push("PlusOne.Event")
	buildTrack()

	Currency.Changed:Connect(function(player: Player, name: string, balance: number)
		if name == config.stat then
			applyForm(player, balance)
		end
	end)
	PlayerData.Loaded:Connect(function(player: Player, profile: PlayerData.Profile)
		publish(player, profile.Data.PlusOne)
		local character = player.Character
		if character and profile.Data.PlusOne.World > 1 then
			character:PivotTo(PlusOne.StartCFrame(profile.Data.PlusOne.World))
		end
	end)
	Players.PlayerAdded:Connect(function(player: Player)
		player.CharacterAdded:Connect(function(character: Model)
			player:SetAttribute("Form", nil)
			task.defer(function()
				local profile = PlayerData.Get(player)
				if profile and profile.Data.PlusOne.World > 1 then
					character:PivotTo(PlusOne.StartCFrame(profile.Data.PlusOne.World))
				end
				applyForm(player, Currency.Get(player, config.stat) or 0)
			end)
		end)
	end)
	Players.PlayerRemoving:Connect(function(player: Player)
		lastPos[player] = nil
		carry[player] = nil
		cooldown[player] = nil
	end)
	task.spawn(function()
		while true do
			task.wait(TICK)
			for _, player in Players:GetPlayers() do
				step(player)
			end
		end
	end)
end

return PlusOne

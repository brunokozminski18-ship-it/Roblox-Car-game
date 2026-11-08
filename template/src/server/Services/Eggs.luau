--!strict
-- Template: Cash egg stations and bounded additive pet Power. UI NOT FINAL.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LihFolk = script.Parent.Parent.LihFolk
local PlayerData = require(LihFolk.PlayerData)
local Inventory = require(LihFolk.Inventory)
local Currency = require(LihFolk.Currency)
local EggHatch = require(LihFolk.EggHatch)
local Net = require(ReplicatedStorage.LihFolk.Net)
local Eggs = {}

function Eggs.multiplier(powers: { number }, cap: number): number
	local bonus = 1
	for _, power in powers do
		if power == power and power >= 1 and power < math.huge then
			bonus += power - 1
		end
	end
	return math.clamp(bonus, 1, cap)
end

function Eggs.Init(config: any)
	local stations: { [string]: BasePart } = {}
	local open = Net.Push("Eggs.Open")
	local result = Net.Push("Eggs.Result")
	local function allowed(player: Player, id: string): boolean
		local profile = PlayerData.Get(player)
		local station = stations[id]
		local egg = config.Eggs.eggs[id]
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		return profile ~= nil and station ~= nil and egg ~= nil
			and profile.Data.PlusOne.World >= egg.world
			and root ~= nil and root:IsA("BasePart")
			and humanoid ~= nil and humanoid.Health > 0
			and (root.Position - station.Position).Magnitude <= 12
	end
	EggHatch.SetContextCheck(allowed)
	Currency.AddMultiplier(config.PlusOne.stat, function(player: Player): number
		local powers = {}
		for _, uid in Inventory.GetEquipped(player) do
			local pet = Inventory.GetUnique(player, uid)
			local def = pet and config.Inventory.items[pet.Item]
			if def and def.power then
				table.insert(powers, def.power)
			end
		end
		return Eggs.multiplier(powers, config.Pets.maxMultiplier)
	end)
	local function publish(player: Player)
		local count = 0
		for _, uid in Inventory.GetEquipped(player) do
			local pet = Inventory.GetUnique(player, uid)
			if pet and config.Inventory.items[pet.Item].power then count += 1 end
		end
		player:SetAttribute("EquippedPets", count)
	end
	Inventory.Changed:Connect(publish)
	PlayerData.Loaded:Connect(publish)
	EggHatch.Hatched:Connect(function(player: Player, id: string, pets: any)
		result:Fire(player, id, pets)
	end)
	for id, egg in config.Eggs.eggs do
		local t = config.PlusOne.track
		local stand = Instance.new("Part")
		stand.Name = id
		stand.Shape = Enum.PartType.Ball
		stand.Anchored = true
		stand.Size = Vector3.new(4, 5, 4)
		stand.Position = t.origin + Vector3.new((egg.world - 1) * (t.width + t.gap), 2.5, 20)
		stand.Color = config.PlusOne.worlds[egg.world].floor
		stand.Parent = workspace:WaitForChild("PlusOneTrack")
		stations[id] = stand
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "View odds"
		prompt.ObjectText = `{egg.name} - {egg.price.amount} Cash`
		prompt.MaxActivationDistance = 9
		prompt.RequiresLineOfSight = false
		prompt.Parent = stand
		local last: { [Player]: number } = setmetatable({}, { __mode = "k" }) :: any
		prompt.Triggered:Connect(function(player: Player)
			if allowed(player, id) and os.clock() - (last[player] or -10) >= 1 then
				last[player] = os.clock()
				open:Fire(player, id)
			end
		end)
	end
end

return Eggs

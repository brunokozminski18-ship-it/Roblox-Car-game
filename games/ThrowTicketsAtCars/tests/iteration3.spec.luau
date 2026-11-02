return function(Rules, Config)
	local count = 0
	local function check(ok, message) assert(ok, message); count += 1 end
	check(Rules.distance(24) == 24, "Power is landing distance")
	check(Rules.distance(99999) == Config.MapEnd, "Map end clamps power")
	check(Rules.distance(-1) == 0, "Negative distance clamps")
	check(Rules.distance(0/0) == 0, "NaN is not a world position")
	for i,b in Config.Biomes do
		check(Rules.biome(b.MinPower) == i, "Inclusive biome threshold " .. i)
		if i > 1 then check(Rules.biome(b.MinPower - 1) == i - 1, "Before biome threshold " .. i) end
	end
	check(Rules.biome(Config.MapEnd) == #Config.Biomes, "Last biome")
	check(Rules.weighted(Config.Rarities, 0) == 1, "Common bucket")
	check(Rules.weighted(Config.Rarities, 0.71) == 2, "Rare bucket")
	check(Rules.weighted(Config.Rarities, 0.95) == 3, "Epic bucket")
	check(Rules.weighted(Config.Rarities, 0.999) == 4, "Legendary bucket")
	local kind,slot = Rules.planParking({}, 1)
	check(kind == "Add" and slot == 1, "First free slot")
	kind,slot = Rules.planParking({9,3,8,3,20,5}, 4)
	check(kind == "Upgrade" and slot == 2, "Weakest, first tie, not newest")
	kind,slot = Rules.planParking({9,3,8,3,20,5}, 3)
	check(kind == "Sell" and slot == nil, "Equal value is sold")
	check(Rules.salePrice(8) == 8 * Config.SaleIncomeSeconds, "Sale from config")
	local reward = Rules.reward(6,4,1)
	check(reward.Income == Config.Biomes[6].BaseIncome * Config.Rarities[4].Multiplier, "Biome times rarity")
	check(reward.Name == Config.Biomes[6].Cars[1].Name, "Car from biome pool")
	local nextBiome,need = Rules.nextBiome(149)
	check(nextBiome == 3 and need == 1, "Next biome distance")
	check(Rules.nextBiome(99999) == nil, "Final biome has no next")
	check(Config.TicketFlightSeconds + Config.TowApproachSeconds + Config.TowLoadSeconds + Config.TowReturnSeconds <= 3, "Transport budget")
	return count .. " iteration-3 assertions passed"
end

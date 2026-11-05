return function(Rules, Config, Schema, Garage, J)
	local checks = 0
	local function check(condition, message)
		assert(condition, message)
		checks += 1
	end

	check(type(Rules.rollCar) == "function", "A single authoritative 10b car roll is required")
	check(Config.Data.Schema >= 5, "10b discovery and parking schema is supported")
	local function sumWeights(entries)
		local sum = 0
		for _, entry in entries do sum += entry.Weight end
		return sum
	end

	local biome = Config.Biomes[1]
	local catalog = {}
	local catalogWeight = {}
	for _, car in biome.Cars do
		check(not catalog[car.Id], "Catalog IDs are unique within the biome")
		catalog[car.Id] = car
		catalogWeight[car.Rarity] = (catalogWeight[car.Rarity] or 0) + car.Weight
	end
	check(#biome.Cars == 6, "A biome offers six collectible cars")

	local ticketId = "diamond"
	local rarityWeights = Rules.rarityWeights(ticketId)
	local variantWeights = Rules.extraWeights(Config.Variants, ticketId)
	local rarityTotal = sumWeights(rarityWeights)
	local variantTotal = sumWeights(variantWeights)
	local variantIndex = {}
	for i, entry in Config.Variants do variantIndex[entry.Id] = i end
	local rng = Random.new(10482026)
	local trials = 10000
	local rarities, cars, variants = {}, {}, {}
	local reward
	for _ = 1, trials do
		local roll = Rules.rollCar(1, ticketId, rng)
		local car = catalog[roll.CatalogId]
		local vi = variantIndex[roll.Variant]
		assert(car and car.Rarity == roll.Rarity and car.Name == roll.Name, "A roll must match its catalog identity and rarity")
		assert(vi and roll.Size == nil and roll.Ticket == ticketId and roll.Biome == 1, "A roll must retain its source and valid extra rolls")
		local base = biome.BaseIncome * Config.Rarities[roll.Rarity].Multiplier * Rules.ticket(ticketId).IncomeMultiplier
		local income = math.max(1, math.floor(base * Config.Variants[vi].Multiplier))
		assert(roll.Income == income, "Variants multiply the unrounded reward before flooring")
		rarities[roll.Rarity] = (rarities[roll.Rarity] or 0) + 1
		cars[car.Id] = (cars[car.Id] or 0) + 1
		variants[vi] = (variants[vi] or 0) + 1
		reward = reward or roll
	end

	local function frequency(count, probability, name)
		local expected = trials * probability
		local deviation = math.sqrt(expected * (1 - probability))
		check(math.abs((count or 0) - expected) <= 6 * deviation + 3,
			string.format("%s frequency: observed %d, expected %.2f of %d", name, count or 0, expected, trials))
	end
	for i, entry in rarityWeights do
		frequency(rarities[i], entry.Weight / rarityTotal, "Rarity " .. i)
	end
	for id, car in catalog do
		local probability = rarityWeights[car.Rarity].Weight / rarityTotal * car.Weight / catalogWeight[car.Rarity]
		frequency(cars[id], probability, "Catalog " .. id)
	end
	for vi, variant in variantWeights do
		frequency(variants[vi], variant.Weight / variantTotal, "Variant " .. vi)
	end

	local function checkOdds(roll)
		local car = catalog[roll.CatalogId]
		local probability = rarityWeights[roll.Rarity].Weight / rarityTotal
			* car.Weight / catalogWeight[roll.Rarity]
			* variantWeights[variantIndex[roll.Variant]].Weight / variantTotal
		check(J.odds(roll, ticketId) == math.max(1, math.floor(1 / probability + .5)), "Odds include conditional catalog odds and the variant")
	end
	checkOdds(reward)
	local forced = Rules.rollCar(1, ticketId, rng, {Rarity = 3, Variant = "Gold"})
	check(forced.Rarity == 3 and forced.Variant == "Gold" and forced.Size == nil, "QA forcing preserves requested rarity and variant")
	checkOdds(forced)

	local legacy = {
		Cash = 9876, Power = 83.125, TrainingLevel = 60, TrainingXP = 99.75,
		Owned = {paper = true, pink = true}, Equipped = "pink", Exercise = 2,
		Cars = {{Id = "old-parked", Biome = 1, Rarity = 2, Name = "Rusty Sedan", Ticket = "pink", Slot = 6}},
	}
	local migrated, reason = Schema.prepare({Schema = 4, Data = legacy})
	check(migrated ~= nil, reason or "Schema 4 fixture migrates")
	local oldCar = migrated.Cars[1]
	check(oldCar.Id == "old-parked" and oldCar.Rarity == 2 and oldCar.Ticket == "pink" and oldCar.Slot == 6,
		"Migration preserves the exact old car identity, rarity, ticket and parking slot")
	check(Rules.savedReward(oldCar).Income == 3, "A pre-10b Rare Rusty Sedan with Pink Slip still earns $3/s")
	check(migrated.Cash == legacy.Cash and migrated.Power == legacy.Power and migrated.Exercise == legacy.Exercise
		and migrated.TrainingLevel == legacy.TrainingLevel and migrated.TrainingXP == legacy.TrainingXP
		and migrated.Equipped == "pink" and migrated.Owned.pink, "Migration preserves all existing player progress")
	check(migrated.ParkingCapacity >= oldCar.Slot and migrated.Discovered[oldCar.CatalogId] == true,
		"Migration unlocks previously owned catalog entries and never shrinks occupied parking")
	local renamed=Schema.copy(migrated);renamed.Cars[1].Name="Previous test name"
	local normalized=Schema.prepare({Schema=Config.Data.Schema,Data=renamed})
	check(normalized and normalized.Cars[1].Name==oldCar.Name and normalized.Cars[1].CatalogId==oldCar.CatalogId,
		"Future display-name changes preserve stable catalog ownership")
	check(legacy.ParkingCapacity == nil and legacy.Discovered == nil and legacy.Cars[1].CatalogId == nil, "Migration leaves the source record untouched")

	local data = Schema.default()
	check(data.ParkingCapacity == Config.ParkingSlots, "Fresh profiles start with starter parking capacity")
	check(Garage.add(data, reward, "rolled", false), "A valid catalog reward fits into a fresh garage")
	check(data.Discovered[reward.CatalogId] == true, "A catch registers its catalog discovery")
	check(Garage.act(data, "Sell", "rolled", 0), "Selling removes a registered car")
	check(data.Discovered[reward.CatalogId] == true, "Discovery survives selling the last copy")
	local restored, restoreReason = Schema.prepare({Schema = Config.Data.Schema, Data = data})
	check(restored and restored.Discovered[reward.CatalogId] == true, restoreReason or "An owned-then-sold discovery survives save/load")

	local capacity = data.ParkingCapacity
	local price = Rules.parkingPrice(data)
	check(type(price) == "number" and price > 0, "A starter parking upgrade costs Cash")
	data.Cash = price - 1
	check(not Rules.upgradeParking(data, capacity) and data.ParkingCapacity == capacity and data.Cash == price - 1,
		"Unaffordable upgrades never change parking or Cash")
	data.Cash = price
	check(Rules.upgradeParking(data, capacity) and data.ParkingCapacity == capacity + 2 and data.Cash == 0,
		"An affordable upgrade adds two slots and charges exact price")
	data.Cash = Config.MaxCash
	check(not Rules.upgradeParking(data, capacity) and data.ParkingCapacity == capacity + 2 and data.Cash == Config.MaxCash,
		"Stale and duplicate upgrade requests cannot charge twice")
	local atMax = Schema.default()
	atMax.ParkingCapacity, atMax.Cash = Config.ParkingMax, Config.MaxCash
	check(not Rules.upgradeParking(atMax, Config.ParkingMax) and atMax.ParkingCapacity == Config.ParkingMax and atMax.Cash == Config.MaxCash,
		"Parking at maximum capacity cannot charge for another slot")

	check(Garage.add(data, reward, "next-slot", false), "Inventory retains a car for slot boundary tests")
	check(not Garage.act(data, "Place", "next-slot", data.ParkingCapacity + 1), "Cannot place in a slot above purchased capacity")
	check(Garage.act(data, "Place", "next-slot", data.ParkingCapacity), "Can place in the newly purchased last slot")
	local corrupt = Schema.copy(data)
	corrupt.ParkingCapacity = data.ParkingCapacity - 1
	check(Schema.prepare({Schema = Config.Data.Schema, Data = corrupt}) == nil, "Schema 5 rejects occupied slots beyond saved capacity")
	corrupt.ParkingCapacity = Config.ParkingMax + 1
	check(Schema.prepare({Schema = Config.Data.Schema, Data = corrupt}) == nil, "Schema 5 rejects capacity above the maximum")

	local full = Schema.default()
	full.ParkingCapacity = Config.ParkingMax
	for i = 1, Config.InventoryLimit do
		assert(Garage.add(full, reward, "inventory-" .. i, false))
	end
	check(not Garage.add(full, reward, "overflow", false), "Parking upgrades do not raise the inventory limit")
	check(Garage.equipBest(full), "Equip best works with purchased parking slots and full inventory")
	check(#full.Cars == Config.InventoryLimit and Garage.inventoryCount(full) == math.max(0, Config.InventoryLimit - Config.ParkingMax),
		"Equip best fills all purchased parking slots without losing cars")
	check(Schema.prepare({Schema = Config.Data.Schema, Data = full}) ~= nil, "The expanded garage survives save/load")

	check(not Garage.requiresConfirmation({Rarity = 1, Variant = Config.Variants[1].Id}),
		"An ordinary Common car can be sold directly")
	check(Garage.requiresConfirmation({Rarity = 3, Variant = Config.Variants[1].Id}),
		"An Epic car needs explicit confirmation before selling")
	check(Garage.requiresConfirmation({Rarity = 1, Variant = Config.Variants[2].Id}),
		"A variant needs confirmation even on a Common car")
 local sized=Schema.copy(migrated)
 sized.Cars[1].Size="BIG"
 assert(Garage.add(sized,forced,"old-giant",false))
 sized.Cars[2].Size="GIANT"
 local stripped=Schema.prepare({Schema=Config.Data.Schema,Data=sized})
 check(stripped and stripped.Cars[1].Size==nil and stripped.Cars[2].Size==nil,"Old sizes are stripped on load")
 check(stripped.Cars[1].Id==oldCar.Id and stripped.Cars[1].Slot==6 and Rules.savedReward(stripped.Cars[1]).Income==3,"Old parked car keeps identity and base income")
 check(stripped.Cars[2].Variant=="Gold" and Rules.savedReward(stripped.Cars[2]).Income==72,"Old GIANT keeps Gold and loses the size multiplier")
 for i=Garage.inventoryCount(full)+1,Config.InventoryLimit do
  assert(Garage.add(full,reward,"extra-"..i,false))
 end
 local incoming,parked
 for _,car in full.Cars do
  if car.Slot==0 then incoming=car elseif car.Slot==1 then parked=car end
 end
 check(not Garage.swap(full,incoming.Id,parked.Id,2) and incoming.Slot==0 and parked.Slot==1,"Stale spot leaves both cars unchanged")
 check(Garage.swap(full,incoming.Id,parked.Id,1) and incoming.Slot==1 and parked.Slot==0,"Swap works with full parking and backpack")
 check(Garage.inventoryCount(full)==Config.InventoryLimit and Garage.parkedCount(full)==Config.ParkingMax,"Swap preserves both capacities")

	return string.format("%d iteration-10b assertions passed (%d deterministic rolls)", checks, trials)
end

--!strict
local Config = require(script.Parent.Config)
local Rules = {}
function Rules.finiteNumber(n: any): boolean
	return typeof(n)=="number" and n==n and math.abs(n)<math.huge
end
function Rules.distance(power: number): number
	return if Rules.finiteNumber(power) then math.clamp(power,0,Config.MapEnd) else 0
end
function Rules.biome(distance: number): number
	local index=1
	for i,data in Config.Biomes do if distance>=data.MinPower then index=i else break end end
	return index
end
function Rules.nextBiome(power: number): (number?,number?)
	local current=Rules.biome(Rules.distance(power))
	local nextBiome=Config.Biomes[current+1]
	return if nextBiome then current+1 else nil, if nextBiome then math.max(0,nextBiome.MinPower-power) else nil
end
function Rules.weighted(entries: any, roll: number): number
	local total=0
	for _,entry in entries do total+=entry.Weight end
	assert(total>0)
	local target=math.clamp(roll,0,1)*total
	local sum=0
	for i,entry in entries do sum+=entry.Weight; if target<sum then return i end end
	return #entries
end
function Rules.reward(biome: number, rarity: number, car: number): any
	local b,r=Config.Biomes[biome],Config.Rarities[rarity]
	return {Biome=biome,Rarity=rarity,Name=b.Cars[car].Name,Income=b.BaseIncome*r.Multiplier}
end
function Rules.salePrice(income: number): number
	return math.floor(income*Config.SaleIncomeSeconds)
end
function Rules.planParking(incomes: {[number]:number}, income: number): (string,number?)
	local weakest: number?=nil
	for i=1,Config.ParkingSlots do
		if incomes[i]==nil then return "Add",i end
		if weakest==nil or incomes[i]<incomes[weakest] then weakest=i end
	end
	if weakest and income>incomes[weakest] then return "Upgrade",weakest end
	return "Sell",nil
end
function Rules.arcPoint(origin: Vector3, destination: Vector3, t: number, height: number): Vector3
	return origin:Lerp(destination,t)+Vector3.new(0,height*4*t*(1-t),0)
end
function Rules.arcHeight(distance: number): number
	return math.clamp(distance*Config.TicketArcFactor,Config.TicketArcHeight,Config.TicketArcMax)
end
function Rules.inBox(p: Vector3, center: Vector3, halfX: number, halfZ: number, height: number): boolean
	local d=p-center
	return math.abs(d.X)<=halfX and math.abs(d.Z)<=halfZ and math.abs(d.Y)<=height
end
return Rules

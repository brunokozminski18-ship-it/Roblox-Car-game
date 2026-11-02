--!strict
local Config = require(script.Parent.Config)
local Rules = {}
function Rules.finiteNumber(n: any): boolean
	return typeof(n)=="number" and n==n and math.abs(n)<math.huge
end
function Rules.ticket(id: any): (any,number)
	for i,t in Config.Tickets do if t.Id==id then return t,i end end
	return Config.Tickets[1],1
end
function Rules.distance(power: number,ticketId: string?): number
	return if Rules.finiteNumber(power) then math.clamp(power*Rules.ticket(ticketId).Multiplier,0,Config.MapEnd) else 0
end
function Rules.biome(distance: number): number
	local index=1
	for i,data in Config.Biomes do if distance>=data.MinPower then index=i else break end end
	return index
end
function Rules.nextBiome(power: number,ticketId: string?): (number?,number?)
	local multiplier=Rules.ticket(ticketId).Multiplier
	local current=Rules.biome(Rules.distance(power,ticketId))
	local nextBiome=Config.Biomes[current+1]
	return if nextBiome then current+1 else nil, if nextBiome then math.max(0,math.ceil(nextBiome.MinPower/multiplier)-power) else nil
end
function Rules.rarityWeights(ticketId: string): any
	local luck=Rules.ticket(ticketId).Luck;local out={}
	for i,r in Config.Rarities do out[i]={Weight=r.Weight*(if i==1 then 1 else 1+luck)} end
	return out
end
function Rules.shop(data: any,action: any,id: any): string
	if typeof(id)~="string" or #id>24 then return "Invalid ticket!" end
	local ticket,index=Rules.ticket(id);if ticket.Id~=id then return "Invalid ticket!" end
	if action=="Buy" then
		if data.Owned[id] then return "Already owned!" end
		if index>1 and not data.Owned[Config.Tickets[index-1].Id]then return "Buy the previous ticket first!" end
		if data.Cash<ticket.Price then return "Not enough Cash!" end
		data.Cash-=ticket.Price;data.Owned[id]=true
		return "Bought "..ticket.Name.."!"
	elseif action=="Equip" then
		if not data.Owned[id] then return "Ticket not owned!" end
		data.Equipped=id;return "Equipped "..ticket.Name.."!"
	end
	return "Invalid action!"
end
function Rules.savedReward(record: any): any
	if typeof(record)~="table" or not Rules.finiteNumber(record.Biome) or record.Biome%1~=0 or not Rules.finiteNumber(record.Rarity)or record.Rarity%1~=0 then return nil end
	local b=Config.Biomes[record.Biome];if not b or not Config.Rarities[record.Rarity] then return nil end
	for i,c in b.Cars do if c.Name==record.Name then return Rules.reward(record.Biome,record.Rarity,i) end end
	return nil
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

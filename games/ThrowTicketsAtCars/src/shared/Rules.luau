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
function Rules.distance(power: number): number
	return if Rules.finiteNumber(power) then math.clamp(power,0,Config.MapEnd) else 0
end
function Rules.biome(distance: number): number
	local index=1
	for i,data in Config.Biomes do if distance>=data.MinPower then index=i else break end end
	return index
end
function Rules.nextBiome(power: number): (number?,number?)
 local nextIndex=Rules.biome(Rules.distance(power))+1;local b=Config.Biomes[nextIndex]
 return if b then nextIndex else nil, if b then math.max(0,b.MinPower-power)else nil
end
function Rules.trafficPosition(biome: number,slot: number,time: number): CFrame
 local start=Config.Biomes[biome].MinPower+9
 local finish=(if Config.Biomes[biome+1]then Config.Biomes[biome+1].MinPower else Config.MapEnd)-9
 local span=math.max(1,finish-start);local progress=(time*Config.TrafficSpeed+slot*11)%span
 local forward=slot%2==1;local distance=start+(if forward then span-progress else progress)
 return CFrame.new(if forward then -Config.TrafficLaneX else Config.TrafficLaneX,Config.CarHeight,-distance)*CFrame.Angles(0,if forward then 0 else math.pi,0)
end
function Rules.rarityWeights(ticketId: string): any
	local luck=Rules.ticket(ticketId).Luck;local out={}
	for i,r in Config.Rarities do out[i]={Weight=r.Weight*(if i==1 then 1 else 1+luck)} end
	return out
end
function Rules.exercise(id: any): (any,number?)
 for i,x in Config.Exercises do if x.Id==id then return x,i end end
 return nil,nil
end
function Rules.trainingRate(power: number,exercise: number): number
 local x=Config.Exercises[exercise];if not x then return 0 end
 return x.Work/Config.Economy.TrainingWorkPerPower[Rules.biome(Rules.distance(power))]
end
function Rules.trainingActive(position: Vector3?,center: Vector3?,enabled: boolean,busy: boolean): boolean
 return enabled and not busy and position~=nil and center~=nil and Rules.inBox(position,center,Config.TrainingRadius,Config.TrainingRadius,Config.TrainingHeightTolerance)
end
function Rules.powerText(power: number): string
 if not Rules.finiteNumber(power)then return "0"end
 local value=math.floor(math.max(0,power)*1000+1e-7)/1000
 return (string.format("%.3f",value):gsub("%.?0+$",""))
end
function Rules.shop(data: any,action: any,id: any): string
 if action=="Exercise"then
  if typeof(id)~="string"or #id>24 then return "Invalid exercise!"end
  local x,index=Rules.exercise(id);if not x then return "Invalid exercise!"end
  if index<=data.Exercise then return "Already owned!"end
  if index~=data.Exercise+1 then return "Buy the previous exercise first!"end
  if Rules.biome(Rules.distance(data.Power))<x.UnlockBiome then return "Reach "..Config.Biomes[x.UnlockBiome].Name.." first!"end
  if data.Cash<x.Price then return "Not enough Cash!"end
  data.Cash-=x.Price;data.Exercise=index
  return "Bought "..x.Name.."!"
 end
	if typeof(id)~="string" or #id>24 then return "Invalid ticket!" end
	local ticket,index=Rules.ticket(id);if ticket.Id~=id then return "Invalid ticket!" end
	if action=="Buy" then
		if data.Owned[id] then return "Already owned!" end
		if index>1 and not data.Owned[Config.Tickets[index-1].Id]then return "Buy the previous ticket first!" end
		if Rules.biome(Rules.distance(data.Power))<ticket.UnlockBiome then return "Reach "..Config.Biomes[ticket.UnlockBiome].Name.." first!"end
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
	for i,c in b.Cars do if c.Name==record.Name then local t=Rules.ticket(record.Ticket);if t.Id~=record.Ticket then return nil end;return Rules.reward(record.Biome,record.Rarity,i,record.Ticket) end end
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
function Rules.reward(biome: number, rarity: number, car: number, ticketId: string?): any
	local b,r=Config.Biomes[biome],Config.Rarities[rarity]
	local ticket=Rules.ticket(ticketId or "paper")
	return {Biome=biome,Rarity=rarity,Name=b.Cars[car].Name,Ticket=ticket.Id,Income=math.max(1,math.floor(b.BaseIncome*r.Multiplier*ticket.IncomeMultiplier))}
end
function Rules.salePrice(income: number): number
	return math.floor(income*Config.SaleIncomeSeconds)
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

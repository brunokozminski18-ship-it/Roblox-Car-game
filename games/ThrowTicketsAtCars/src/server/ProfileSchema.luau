--!strict
-- Whitelist and version boundary. No Instances or derived income in stored profiles.
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local Rules=require(game.ReplicatedStorage.ThrowTickets.Rules)
local Schema={}
function Schema.default(): any
	return {Cash=0,Power=Config.StartPower,Owned={paper=true},Equipped="paper",Parking={}}
end
function Schema.copy(value: any): any
	if typeof(value)~="table" then return value end
	local out={};for k,v in value do out[k]=Schema.copy(v)end;return out
end
function Schema.prepare(raw: any): (any,string?)
	if raw==nil then return Schema.default()end
	if typeof(raw)~="table" or typeof(raw.Schema)~="number"or raw.Schema%1~=0 or raw.Schema<0 or raw.Schema>Config.Data.Schema or typeof(raw.Data)~="table"then return nil,"Unsupported or corrupt save"end
	local d=Schema.copy(raw.Data)
	-- Immutable migration 0 -> 1: tickets were absent in the first prototype shape.
	if raw.Schema==0 then d.Owned={paper=true};d.Equipped="paper" end
	if not Rules.finiteNumber(d.Cash)or d.Cash<0 or d.Cash>Config.MaxCash or d.Cash%1~=0 then return nil,"Invalid Cash"end
	if not Rules.finiteNumber(d.Power)or d.Power<0 or d.Power>Config.MaxPower or d.Power%1~=0 then return nil,"Invalid Power"end
	if typeof(d.Owned)~="table"or typeof(d.Parking)~="table"or typeof(d.Equipped)~="string"then return nil,"Invalid inventory"end
	local owned={};local gap=false
	for _,t in Config.Tickets do
		if d.Owned[t.Id]==true then if gap then return nil,"Invalid unlock sequence"end;owned[t.Id]=true else gap=true end
	end
	if not owned.paper or not owned[d.Equipped]then return nil,"Invalid equipped ticket"end
	local parking={};local slots={};local n=0
	for k,c in d.Parking do
		n+=1
		if typeof(k)~="number"or k%1~=0 or k<1 or k>Config.ParkingSlots or n>Config.ParkingSlots or typeof(c)~="table"then return nil,"Invalid parking"end
		if not Rules.finiteNumber(c.Slot)or c.Slot%1~=0 or c.Slot<1 or c.Slot>Config.ParkingSlots or slots[c.Slot]or not Rules.savedReward(c)then return nil,"Invalid car"end
		slots[c.Slot]=true;table.insert(parking,{Slot=c.Slot,Biome=c.Biome,Rarity=c.Rarity,Name=c.Name})
	end
	if n~=#d.Parking then return nil,"Sparse parking"end
	table.sort(parking,function(a,b)return a.Slot<b.Slot end)
	return {Cash=d.Cash,Power=d.Power,Owned=owned,Equipped=d.Equipped,Parking=parking}
end
return Schema

--!strict
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local Rules=require(game.ReplicatedStorage.ThrowTickets.Rules)
local Schema={}
function Schema.default(): any
 return {Cash=0,Power=Config.StartPower,Owned={paper=true},Equipped="paper",Cars={}}
end
function Schema.copy(value: any): any
 if typeof(value)~="table"then return value end
 local out={};for k,v in value do out[k]=Schema.copy(v)end;return out
end
function Schema.prepare(raw: any): (any,string?)
 if raw==nil then return Schema.default()end
 if typeof(raw)~="table"or typeof(raw.Schema)~="number"or raw.Schema%1~=0 or raw.Schema<0 or raw.Schema>Config.Data.Schema or typeof(raw.Data)~="table"then return nil,"Unsupported or corrupt save"end
 local d=Schema.copy(raw.Data)
 -- Immutable migration 0 -> 1.
 if raw.Schema==0 then d.Owned={paper=true};d.Equipped="paper"end
 -- Migration 1 -> 2: each old parked car keeps its slot and gets a stable id.
 if raw.Schema<2 then
  if typeof(d.Parking)~="table"then return nil,"Invalid legacy parking"end
  d.Cars={}
  for k,c in d.Parking do
   if typeof(k)~="number"or k%1~=0 or k<1 or k>#d.Parking or typeof(c)~="table"or not Rules.finiteNumber(c.Slot)then return nil,"Invalid legacy car"end
   table.insert(d.Cars,{Id="legacy_"..tostring(c.Slot),Biome=c.Biome,Rarity=c.Rarity,Name=c.Name,Slot=c.Slot})
  end
 end
 if not Rules.finiteNumber(d.Cash)or d.Cash<0 or d.Cash>Config.MaxCash or d.Cash%1~=0 then return nil,"Invalid Cash"end
 if not Rules.finiteNumber(d.Power)or d.Power<0 or d.Power>Config.MaxPower or d.Power%1~=0 then return nil,"Invalid Power"end
 if typeof(d.Owned)~="table"or typeof(d.Cars)~="table"or typeof(d.Equipped)~="string"then return nil,"Invalid inventory"end
 local owned={};local gap=false
 for _,t in Config.Tickets do if d.Owned[t.Id]==true then if gap then return nil,"Invalid unlock sequence"end;owned[t.Id]=true else gap=true end end
 if not owned.paper or not owned[d.Equipped]then return nil,"Invalid equipped ticket"end
 local cars={};local ids={};local slots={};local count=0;local inventory=0
 for k,c in d.Cars do
  count+=1
  if typeof(k)~="number"or k%1~=0 or k<1 or k>#d.Cars or count>Config.InventoryLimit+Config.ParkingSlots or typeof(c)~="table"then return nil,"Invalid cars array"end
  if typeof(c.Id)~="string"or #c.Id<1 or #c.Id>64 or ids[c.Id]or not Rules.savedReward(c)then return nil,"Invalid car identity"end
  if not Rules.finiteNumber(c.Slot)or c.Slot%1~=0 or c.Slot<0 or c.Slot>Config.ParkingSlots then return nil,"Invalid slot"end
  if c.Slot>0 then if slots[c.Slot]then return nil,"Duplicate slot"end;slots[c.Slot]=true else inventory+=1 end
  ids[c.Id]=true
  -- A committed pending catch becomes visible inventory on reconnect, exactly once.
  table.insert(cars,{Id=c.Id,Biome=c.Biome,Rarity=c.Rarity,Name=c.Name,Slot=c.Slot})
 end
 if count~=#d.Cars or inventory>Config.InventoryLimit then return nil,"Inventory capacity exceeded"end
 return {Cash=d.Cash,Power=d.Power,Owned=owned,Equipped=d.Equipped,Cars=cars}
end
return Schema

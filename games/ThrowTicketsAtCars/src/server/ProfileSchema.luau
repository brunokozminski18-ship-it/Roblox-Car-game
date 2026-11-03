--!strict
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local Rules=require(game.ReplicatedStorage.ThrowTickets.Rules)
local Progression=require(game.ReplicatedStorage.ThrowTickets.Progression)
local Schema={}
function Schema.default(): any
 return {Cash=0,Power=Config.StartPower,TrainingLevel=1,TrainingXP=0,Owned={paper=true},Equipped="paper",Exercise=1,Cars={}}
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
 if raw.Schema<3 then
  d.Exercise=1
  if typeof(d.Cars)=="table"then for _,c in d.Cars do if typeof(c)=="table"then c.Ticket="paper"end end end
 end
 if not Rules.finiteNumber(d.Exercise)or d.Exercise%1~=0 or not Config.Exercises[d.Exercise]then return nil,"Invalid exercise"end
 if not Rules.finiteNumber(d.Cash)or d.Cash<0 or d.Cash>Config.MaxCash or d.Cash%1~=0 then return nil,"Invalid Cash"end
 if not Rules.finiteNumber(d.Power)or d.Power<0 or d.Power>Config.MaxPower then return nil,"Invalid Power"end
 -- Migration 3 -> 4: retain exact earned Power, derive display level, start fresh XP.
 if raw.Schema<4 then d.TrainingLevel=Progression.levelFromPower(d.Power);d.TrainingXP=0 end
 if not Rules.finiteNumber(d.TrainingLevel)or d.TrainingLevel%1~=0 or d.TrainingLevel<1 or d.TrainingLevel>1e9 then return nil,"Invalid TrainingLevel"end
 if not Rules.finiteNumber(d.TrainingXP)or d.TrainingXP<0 or d.TrainingXP>=Config.Progression.XPPerLevel then return nil,"Invalid TrainingXP"end
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
  table.insert(cars,{Id=c.Id,Biome=c.Biome,Rarity=c.Rarity,Name=c.Name,Ticket=c.Ticket,Slot=c.Slot})
 end
 if count~=#d.Cars or inventory>Config.InventoryLimit then return nil,"Inventory capacity exceeded"end
 return {Cash=d.Cash,Power=d.Power,TrainingLevel=d.TrainingLevel,TrainingXP=d.TrainingXP,Owned=owned,Equipped=d.Equipped,Exercise=d.Exercise,Cars=cars}
end
return Schema

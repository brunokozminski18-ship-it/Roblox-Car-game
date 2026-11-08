--!strict
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local Rules=require(game.ReplicatedStorage.ThrowTickets.Rules)
local Progression=require(game.ReplicatedStorage.ThrowTickets.Progression)
local Returns=require(game.ReplicatedStorage.ThrowTickets.ReturnRules)
local Migration=require(game.ReplicatedStorage.ThrowTickets.CatalogMigration)
local Onboarding=require(script.Parent.Onboarding)
local Schema={}
function Schema.default(): any
 return {Cash=0,Power=Config.StartPower,TrainingLevel=1,TrainingXP=0,Owned={paper=true},Equipped="paper",Exercise=1,Cars={},ParkingCapacity=Config.ParkingSlots,Discovered={},Returns=Returns.default(),Pity={Catches=0,SinceLegendary=0},IndexClaims={},Tutorial=Onboarding.default()}
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
 local capacity=if raw.Schema<5 then Config.ParkingSlots else d.ParkingCapacity
 if not Rules.finiteNumber(capacity)or capacity<Config.ParkingSlots or capacity>Config.ParkingMax or (capacity-Config.ParkingSlots)%2~=0 then return nil,"Invalid parking capacity"end
 if raw.Schema>=5 and typeof(d.Discovered)~="table"then return nil,"Invalid discovery set"end
 if raw.Schema<7 then
  local converted={};for id,yes in d.Discovered or {} do if yes==true then local mapped=Migration.id(id);if mapped then converted[mapped]=true end end end;d.Discovered=converted
 end
 local discovered={};for _,b in Config.AllBiomes do for _,c in b.Cars do if raw.Schema>=5 and d.Discovered[c.Id]==true then discovered[c.Id]=true end end end
 local cars={};local ids={};local slots={};local count=0;local inventory=0
 for k,c in d.Cars do
  count+=1
  if typeof(k)~="number"or k%1~=0 or k<1 or k>#d.Cars or count>Config.InventoryLimit+capacity or typeof(c)~="table"then return nil,"Invalid cars array"end
  local mapped=if raw.Schema<7 then Migration.car(c)else c
  local reward=if mapped then Rules.savedReward(mapped)else nil
  if typeof(c.Id)~="string"or #c.Id<1 or #c.Id>64 or ids[c.Id]or not reward or (raw.Schema>=5 and not c.CatalogId)then return nil,"Invalid car identity"end
  if not Rules.finiteNumber(c.Slot)or c.Slot%1~=0 or c.Slot<0 or c.Slot>capacity then return nil,"Invalid slot"end
  if c.Slot>0 then if slots[c.Slot]then return nil,"Duplicate slot"end;slots[c.Slot]=true else inventory+=1 end
  ids[c.Id]=true
  -- A committed pending catch becomes visible inventory on reconnect, exactly once.
  discovered[reward.CatalogId]=true
  table.insert(cars,{Id=c.Id,Biome=reward.Biome,Rarity=reward.Rarity,Name=reward.Name,CatalogId=reward.CatalogId,Variant=reward.Variant,Ticket=reward.Ticket,Slot=c.Slot})
 end
 if count~=#d.Cars or inventory>Config.InventoryLimit then return nil,"Inventory capacity exceeded"end
 local returns=if raw.Schema<6 then Returns.migrate({Cars=cars,Discovered=discovered})else d.Returns
 if not Returns.validate(returns)then return nil,"Invalid returns"end
 local clean=Returns.default();for k in clean do clean[k]=returns[k]end
 -- Migration 7 -> 8: pity counters and Index claims. Existing players are past the first-session guarantees
 -- (catch count = discovered cars) and already-earned half-collections are marked claimed, without retro cars.
 local pity,claims
 if raw.Schema<8 then
  local n=0;for _ in discovered do n+=1 end
  pity={Catches=n,SinceLegendary=0};claims={}
  for i,b in Config.Biomes do local k=0;for _,c in b.Cars do if discovered[c.Id]then k+=1 end end;if k>=Config.Index.FreeCarAt then claims[tostring(i)]=true end end
 else
  pity,claims=d.Pity,d.IndexClaims
  if typeof(pity)~="table"or not Rules.finiteNumber(pity.Catches)or pity.Catches%1~=0 or pity.Catches<0 or pity.Catches>1e9
   or not Rules.finiteNumber(pity.SinceLegendary)or pity.SinceLegendary%1~=0 or pity.SinceLegendary<0 or pity.SinceLegendary>=Config.Luck.LegendaryPity then return nil,"Invalid pity"end
  if typeof(claims)~="table"then return nil,"Invalid index claims"end
  for k,v in claims do if typeof(k)~="string"or v~=true or not Config.AllBiomes[tonumber(k)or 0]then return nil,"Invalid index claims"end end
  pity={Catches=pity.Catches,SinceLegendary=pity.SinceLegendary};local copy={};for k in claims do copy[k]=true end;claims=copy
 end
 -- Migration 8 -> 9: first-60-seconds tutorial slice. Players who already saved a profile are past onboarding.
 local tutorial
 if raw.Schema<9 then tutorial=Onboarding.finishedSlice()
 else tutorial=Onboarding.clean(d.Tutorial);if not tutorial then return nil,"Invalid tutorial"end end
 return {Cash=d.Cash,Power=d.Power,TrainingLevel=d.TrainingLevel,TrainingXP=d.TrainingXP,Owned=owned,Equipped=d.Equipped,Exercise=d.Exercise,Cars=cars,ParkingCapacity=capacity,Discovered=discovered,Returns=clean,Pity=pity,IndexClaims=claims,Tutorial=tutorial}
end
return Schema

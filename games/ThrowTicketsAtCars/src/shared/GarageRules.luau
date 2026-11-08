--!strict
local Config=require(script.Parent.Config)
local Rules=require(script.Parent.Rules)
local Index=require(script.Parent.IndexRewards)
local Garage={}
function Garage.requiresConfirmation(car: any): boolean
 return car.Rarity>=3 or (car.Variant~=nil and car.Variant~="Normal")
end
function Garage.fullMessage(data: any): string
 return "Your parking is full! ("..(data.ParkingCapacity or Config.ParkingSlots).." cars) Upgrade parking or swap a car."
end
function Garage.parkedCount(data: any): number
 local count=0;for _,car in data.Cars do if car.Slot>0 then count+=1 end end;return count
end
function Garage.sorted(data: any,inventoryOnly: boolean): {any}
 local out={};for _,c in data.Cars do if not c.Pending and(not inventoryOnly or c.Slot==0)then table.insert(out,c)end end
 table.sort(out,function(a,b)local ai,bi=Rules.savedReward(a).Income,Rules.savedReward(b).Income;return if ai==bi then a.Id<b.Id else ai>bi end)
 return out
end
function Garage.equipBest(data: any): (boolean,string)
 local sorted=Garage.sorted(data,false);local target={};local changed=false
 for i,c in sorted do target[c.Id]=if i<=(data.ParkingCapacity or Config.ParkingSlots) then i else 0 end
 for _,c in data.Cars do if not c.Pending then local slot=target[c.Id];if c.Slot~=slot then changed=true end;c.Slot=slot end end
 return true,if changed then "Best cars parked!"else "Best cars already parked!"
end
function Garage.find(data: any,id: any): (any,number?)
 if typeof(id)~="string"or #id<1 or #id>64 then return nil,nil end
 for i,c in data.Cars do if c.Id==id then return c,i end end;return nil,nil
end
function Garage.inventoryCount(data: any): number
 local n=0;for _,c in data.Cars do if c.Slot==0 then n+=1 end end;return n
end
function Garage.income(data: any): number
 local total=0;for _,c in data.Cars do if c.Slot>0 then total+=Rules.savedReward(c).Income end end
 -- Completed Index biomes add +2% each; Cash stays an integer.
 return math.floor(total*(if data.Discovered and data.IndexClaims then Index.incomeMultiplier(data)else 1))
end
function Garage.add(data: any,reward: any,id: string,pending: boolean): (boolean,string)
 if Garage.inventoryCount(data)>=Config.InventoryLimit then return false,"Inventory full!"end
 if Garage.find(data,id)then return false,"Duplicate car!"end
 table.insert(data.Cars,{Id=id,Biome=reward.Biome,Rarity=reward.Rarity,Name=reward.Name,CatalogId=reward.CatalogId,Variant=reward.Variant,Ticket=reward.Ticket,Slot=0,Pending=if pending then true else nil})
 if reward.CatalogId then data.Discovered=data.Discovered or {};data.Discovered[reward.CatalogId]=true end
 return true,"Car added!"
end
function Garage.swap(data: any, incomingId: string, parkedId: string, slot: number): (boolean,string)
 local incoming=Garage.find(data,incomingId)
 local parked=Garage.find(data,parkedId)
 if not incoming or incoming.Pending or incoming.Slot~=0 or not parked or parked.Pending then
  return false,"Cars unavailable!"
 end
 if slot<1 or slot>(data.ParkingCapacity or Config.ParkingSlots) or parked.Slot~=slot then
  return false,"Parking spot changed!"
 end
 -- The incoming car frees the backpack space the outgoing car needs.
 if Garage.inventoryCount(data)>Config.InventoryLimit then return false,"Backpack full!"end
 incoming.Slot=slot
 parked.Slot=0
 return true,"Cars swapped!"
end
function Garage.act(data: any,action: any,id: any,slot: any): (boolean,string)
 local c,index=Garage.find(data,id);if not c then return false,"Car not owned!"end
 if c.Pending then return false,"Car is being towed!"end
 if action=="Place"then
  if not Rules.finiteNumber(slot)or slot%1~=0 or slot<1 or slot>(data.ParkingCapacity or Config.ParkingSlots) then return false,"Invalid slot!"end
  if c.Slot~=0 then return false,"Car already placed!"end
  if Garage.parkedCount(data)>=(data.ParkingCapacity or Config.ParkingSlots)then return false,Garage.fullMessage(data)end
  for _,other in data.Cars do if other.Slot==slot then return false,"Slot occupied!"end end
  c.Slot=slot;return true,"Placed! +$"..Rules.savedReward(c).Income.."/s"
 elseif action=="Remove"then
  if not Rules.finiteNumber(slot)or slot%1~=0 or c.Slot~=slot or slot<1 then return false,"Wrong slot!"end
  if Garage.inventoryCount(data)>=Config.InventoryLimit then return false,"Inventory full!"end
  c.Slot=0;return true,"Returned to inventory!"
 elseif action=="Sell"then
  if slot~=0 then return false,"Invalid sale!"end
  local price=Rules.salePrice(Rules.savedReward(c).Income)
  table.remove(data.Cars,index);data.Cash=math.min(Config.MaxCash,data.Cash+price)
  return true,"Sold for $"..price.."!"
 end
 return false,"Invalid action!"
end
return Garage

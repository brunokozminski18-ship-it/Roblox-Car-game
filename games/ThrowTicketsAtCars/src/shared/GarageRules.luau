--!strict
local Config=require(script.Parent.Config)
local Rules=require(script.Parent.Rules)
local Garage={}
function Garage.find(data: any,id: any): (any,number?)
 if typeof(id)~="string"or #id<1 or #id>64 then return nil,nil end
 for i,c in data.Cars do if c.Id==id then return c,i end end;return nil,nil
end
function Garage.inventoryCount(data: any): number
 local n=0;for _,c in data.Cars do if c.Slot==0 then n+=1 end end;return n
end
function Garage.income(data: any): number
 local total=0;for _,c in data.Cars do if c.Slot>0 then total+=Rules.savedReward(c).Income end end;return total
end
function Garage.add(data: any,reward: any,id: string,pending: boolean): (boolean,string)
 if Garage.inventoryCount(data)>=Config.InventoryLimit then return false,"Inventory full!"end
 if Garage.find(data,id)then return false,"Duplicate car!"end
 table.insert(data.Cars,{Id=id,Biome=reward.Biome,Rarity=reward.Rarity,Name=reward.Name,Slot=0,Pending=if pending then true else nil})
 return true,"Car added!"
end
function Garage.act(data: any,action: any,id: any,slot: any): (boolean,string)
 local c,index=Garage.find(data,id);if not c then return false,"Car not owned!"end
 if c.Pending then return false,"Car is being towed!"end
 if action=="Place"then
  if not Rules.finiteNumber(slot)or slot%1~=0 or slot<1 or slot>Config.ParkingSlots then return false,"Invalid slot!"end
  if c.Slot~=0 then return false,"Car already placed!"end
  for _,other in data.Cars do if other.Slot==slot then return false,"Slot occupied!"end end
  c.Slot=slot;return true,"Placed! +$"..Rules.savedReward(c).Income.."/s"
 elseif action=="Remove"then
  if not Rules.finiteNumber(slot)or slot%1~=0 or c.Slot~=slot or slot<1 then return false,"Wrong slot!"end
  if Garage.inventoryCount(data)>=Config.InventoryLimit then return false,"Inventory full!"end
  c.Slot=0;return true,"Returned to inventory!"
 elseif action=="Sell"then
  if slot~=0 or c.Slot~=0 then return false,"Remove car before selling!"end
  local price=Rules.salePrice(Rules.savedReward(c).Income)
  table.remove(data.Cars,index);data.Cash=math.min(Config.MaxCash,data.Cash+price)
  return true,"Sold for $"..price
 end
 return false,"Invalid action!"
end
return Garage

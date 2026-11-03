--!strict
local Http=game:GetService("HttpService")
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local Rules=require(game.ReplicatedStorage.ThrowTickets.Rules)
local Garage=require(game.ReplicatedStorage.ThrowTickets.GarageRules)
local Tools=require(script.Parent.CarTools)
local Service={}
function Service.new(ctx: any): any
 local api={}
 local function eligible(p: Player,s: any): boolean return ctx.mutable(s)and not s.job and not s.meter and ctx.rootOf(p)~=nil end
 local function nearby(p: Player,s: any,index: any): boolean
  if not Rules.finiteNumber(index)or index%1~=0 or index<1 or index>Config.ParkingSlots then return false end
  local r=ctx.rootOf(p);return r~=nil and (r.Position-s.positions[index]).Magnitude<=Config.PlacementDistance
 end
 function api.act(p: Player,s: any,action: string,id: any,index: any,fromPrompt: boolean?)
  if not eligible(p,s)then return end
  if action=="Place"and fromPrompt~=true then return end
  if typeof(id)~="string"or #id>64 then return end
  if action=="Equip"then if Tools.equip(p,s,id)then ctx.result(p,"Hold E at a free spot to place your car.")end;return end
  if action=="Unequip"then local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid");if h then h:UnequipTools()end;return end
  if action=="Place"or action=="Remove"then
   if not nearby(p,s,index)then ctx.result(p,"Move closer to your parking spot!");return end
   if s.folder:GetAttribute("OwnerId")~=p.UserId then return end
   if action=="Place"then local c=Tools.equipped(p,s);if not c or c.Id~=id then return end end
  elseif action=="EquipBest"then
   if not ctx.atPlot(p,s)then ctx.result(p,"Walk to your plot to equip best!");return end
   local ok,message=Garage.equipBest(s.data);ctx.result(p,message);if ok then ctx.publish(p,s)end;return
  elseif action=="Sell"then
   local car=Garage.find(s.data,id);if not car or car.Pending then return end
   if car.Rarity>=3 then
    local confirmation=s.sale
    if typeof(index)~="string"or not confirmation or confirmation.id~=id or confirmation.token~=index or os.clock()>confirmation.expires then
     local token=Http:GenerateGUID(false);s.sale={id=id,token=token,expires=os.clock()+15}
     ctx.confirm:FireClient(p,id,token,Rules.salePrice(Rules.savedReward(car).Income));return
    end
    s.sale=nil
   end
   index=0
  else return end
  local ok,message=Garage.act(s.data,action,id,index);ctx.result(p,message)
  if ok then ctx.publish(p,s);if action=="Remove"then Tools.equip(p,s,id)end end
 end
 function api.prompt(p: Player,s: any,parent: BasePart,action: string,id: string,index: number)
  local prompt=Instance.new("ProximityPrompt");prompt.Name=if action=="Place"then "PlaceCar"else "PickUpCar"
  prompt.ActionText=if action=="Place"then "Place car"else "Pick up";prompt.ObjectText=if action=="Place"then "Parking spot"else parent.Parent:GetAttribute("CarName")or "Car"
  prompt.ClickablePrompt=true;prompt.HoldDuration=Config.PromptHoldSeconds;prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.MaxActivationDistance=Config.PlacementDistance;prompt.RequiresLineOfSight=false;prompt.Exclusivity=Enum.ProximityPromptExclusivity.OnePerButton
  prompt:SetAttribute("OwnerId",p.UserId);prompt:SetAttribute("GarageAction",action);prompt.Parent=parent
  local heldAt: number?=nil
  prompt.PromptButtonHoldBegan:Connect(function(actor)
   local c=if action=="Remove"then Garage.find(s.data,id)else nil
   if actor==p and eligible(p,s)and nearby(p,s,if c then c.Slot else index)then heldAt=os.clock()end
  end)
  prompt.Triggered:Connect(function(actor)
   local start=heldAt;heldAt=nil
   if actor~=p or not start or os.clock()-start<Config.PromptHoldSeconds-.06 then return end
   local now=os.clock();if now-s.lastGarage<Config.GarageRequestInterval then return end;s.lastGarage=now
   local car=if action=="Place"then Tools.equipped(p,s)else Garage.find(s.data,id)
   if not car then return end
   api.act(p,s,action,car.Id,if action=="Remove"then car.Slot else index,true)
  end)
  return prompt
 end
 return api
end
return Service

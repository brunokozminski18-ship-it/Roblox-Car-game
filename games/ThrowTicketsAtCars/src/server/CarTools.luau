--!strict
-- Disposable projections; all identity and rewards come from profile data.
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local Rules=require(game.ReplicatedStorage.ThrowTickets.Rules)
local Garage=require(game.ReplicatedStorage.ThrowTickets.GarageRules)
local Builder=require(game.ReplicatedStorage.ThrowTickets.CarBuilder)
local Tools={}
function Tools.equipped(p: Player,s: any): any
 local character=p.Character;if not character then return nil end
 for _,tool in character:GetChildren()do if tool:IsA("Tool")then
  local id=tool:GetAttribute("CarId");local car=Garage.find(s.data,id)
  if car and car.Slot==0 and not car.Pending and s.tools[id]==tool then return car end
 end end
 return nil
end
function Tools.sync(p: Player,s: any)
 local backpack=p:FindFirstChildOfClass("Backpack");if not backpack then return end
 s.tools=s.tools or {}
 for id,tool in s.tools do local c=Garage.find(s.data,id)
  if not c or c.Slot~=0 or c.Pending or not(tool:IsDescendantOf(backpack)or(p.Character and tool:IsDescendantOf(p.Character)))then tool:Destroy();s.tools[id]=nil end
 end
 for _,c in s.data.Cars do if c.Slot==0 and not c.Pending and not s.tools[c.Id]then
  local tool=Instance.new("Tool");tool.Name=c.Name;tool.CanBeDropped=false;tool.RequiresHandle=true;tool.ToolTip=c.Name.." | $"..Rules.savedReward(c).Income.."/s"
  tool:SetAttribute("CarId",c.Id);tool:SetAttribute("Income",Rules.savedReward(c).Income)
  local model=Builder.create(Instance.new("Folder"),"HeldCar",Rules.savedReward(c),Vector3.zero)
  local staging=model.Parent;model:ScaleTo(.24)
  local handle=model.PrimaryPart :: BasePart;handle.Name="Handle"
  for _,part in model:GetDescendants()do if part:IsA("BasePart")then
   part.Anchored=false;part.Massless=true;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false
   if part~=handle then local weld=Instance.new("WeldConstraint");weld.Part0=handle;weld.Part1=part;weld.Parent=part end
  end end
  for _,part in model:GetChildren()do part.Parent=tool end;staging:Destroy()
  tool.Grip=CFrame.new(0,-.35,-.8)*CFrame.Angles(0,math.pi/2,0)
  s.tools[c.Id]=tool
  tool.Equipped:Connect(function()
   if s.profile.Status~="active"or not Garage.find(s.data,c.Id)or c.Slot~=0 or c.Pending or s.job or s.meter then
    local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid");if h then h:UnequipTools()end;return
   end
   p:SetAttribute("EquippedCarId",c.Id)
  end)
  tool.Unequipped:Connect(function()task.defer(function()
   local equipped=Tools.equipped(p,s);p:SetAttribute("EquippedCarId",if equipped then equipped.Id else "")
  end)end)
  tool.Parent=backpack
 end end
 local equipped=Tools.equipped(p,s);p:SetAttribute("EquippedCarId",if equipped then equipped.Id else "")
end
function Tools.equip(p: Player,s: any,id: string): boolean
 local c=Garage.find(s.data,id);if not c or c.Pending or c.Slot~=0 then return false end
 Tools.sync(p,s)
 local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid");local tool=s.tools[id]
 if not h or h.Health<=0 or not tool then return false end
 h:EquipTool(tool);p:SetAttribute("EquippedCarId",id);return true
end
return Tools

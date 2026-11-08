local notice=workspace:FindFirstChild("PlayNotice"); if notice then notice:Destroy() end
local H=require(script.Parent.Helpers)
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
H.part("Arena",Vector3.new(100,1,120),Vector3.new(0,-0.5,-30),120)
H.spawn(Vector3.new(0,0.5,14))
local target=H.part("Wide basket",Vector3.new(26,1,18),Vector3.new(0,0.5,-42),195)
H.sign(target,"BASKET")
for _,x in {-14,14} do H.part("Basket rim",Vector3.new(1,4,18),Vector3.new(x,2,-42),155) end
local divider=H.part("Breakable divider",Vector3.new(24,6,1),Vector3.new(0,3,-22),80)
H.sign(divider,"BREAKABLE")
local props,held,scores,lastShot={},{},{},{}
for i,x in {-5,5} do
 local home=Vector3.new(x,2,5)
 local p=H.part(i==1 and "Soft prop" or "Heavy prop",i==1 and Vector3.new(3,3,3) or Vector3.new(5,2,3),home,i==1 and 180 or 90)
 H.sign(p,i==1 and "MELON" or "HEAVY CRATE")
 p.CanCollide=false
 local obj={part=p,home=home,owner=nil,flight=nil,charge=nil}; props[i]=obj
 obj.prompt=H.prompt(p,"Grab / Catch",function(player)
  if held[player] or obj.owner then return end
  obj.owner=player; obj.flight=nil; obj.charge=nil; held[player]=obj; obj.prompt.Enabled=false
  player:SetAttribute("Carrying",true)
  player:SetAttribute("ThrowSpeed",i==1 and 62 or 49)
 end)
end
local function reset(obj)
 if obj.owner then obj.owner:SetAttribute("Carrying",false); held[obj.owner]=nil end
 obj.owner=nil; obj.flight=nil; obj.charge=nil; obj.shooter=nil; obj.part.Position=obj.home; obj.prompt.Enabled=true
end
local remote=Instance.new("RemoteEvent"); remote.Name="Throw"; remote.Parent=game:GetService("ReplicatedStorage")
remote.OnServerEvent:Connect(function(player,action,...)
 if not H.allow(player) then return end
 if select("#",...)~=0 or typeof(action)~="string" or #action>8 or (action~="Start" and action~="Release" and action~="Cancel") then return end
 local r=H.root(player); local obj=held[player]
 if not r or not obj or obj.owner~=player then return end
 if action=="Cancel" then obj.charge=nil; return end
 if action=="Start" then obj.charge=obj.charge or os.clock(); return end
 if not obj.charge or os.clock()-(lastShot[player] or -10)<0.3 then return end
 local power=math.clamp((os.clock()-obj.charge)/1.2,0.4,1)
 local look=r.CFrame.LookVector; local flat=Vector3.new(look.X,0,look.Z)
 if flat.Magnitude<0.1 then return end
 local speed=player:GetAttribute("ThrowSpeed") -- set only by this server
 player:SetAttribute("Carrying",false)
 obj.shooter=player
 lastShot[player]=os.clock(); held[player]=nil; obj.owner=nil; obj.charge=nil; obj.prompt.Enabled=true
 obj.part.Position=r.Position+flat.Unit*4+Vector3.new(0,2,0)
 obj.flight={velocity=(flat.Unit+Vector3.new(0,0.72,0)).Unit*speed*power,age=0,bounces=0}
end)
Players.PlayerRemoving:Connect(function(player)
 if held[player] then reset(held[player]) end
 scores[player]=nil; lastShot[player]=nil
end)
RunService.Heartbeat:Connect(function(dt)
 -- Bounded fixed substeps and swept raycasts; no client network ownership or Touched scoring.
 local steps=math.min(12,math.max(1,math.ceil(dt/0.016))); local step=math.min(dt,0.192)/steps
 for _,obj in props do
  if obj.owner then
   local r=H.root(obj.owner)
   if not r then reset(obj) else obj.part.Position=r.Position+Vector3.new(0,3,0) end
  elseif obj.flight then
   local f=obj.flight
   for _=1,steps do
    f.age+=step
    local delta=f.velocity*step+Vector3.new(0,-55,0)*step*step/2
    local params=RaycastParams.new(); local exclude={obj.part}
    for _,p in props do table.insert(exclude,p.part) end
    for _,player in Players:GetPlayers() do if player.Character then table.insert(exclude,player.Character) end end
    params.FilterDescendantsInstances=exclude; params.FilterType=Enum.RaycastFilterType.Exclude
    local hit=workspace:Raycast(obj.part.Position,delta,params)
    f.velocity+=Vector3.new(0,-55,0)*step
    if hit then
     obj.part.Position=hit.Position+hit.Normal*1.6
     if hit.Instance==target then
      -- Credit thrower, never the client that reports a collision.
      local shooter=obj.shooter
      if shooter and shooter.Parent==Players then scores[shooter]=(scores[shooter] or 0)+1; H.feedback(shooter,"Nice! Try the heavy crate",true) end
      H.flash(target); reset(obj); break
     elseif hit.Instance==divider then
      divider.CanQuery=false; divider.CanCollide=false; divider.Transparency=0.8
      task.delay(3,function() divider.CanQuery=true; divider.CanCollide=true; divider.Transparency=0 end)
      f.velocity*=0.85
     else
      f.velocity=(f.velocity-2*f.velocity:Dot(hit.Normal)*hit.Normal)*0.55; f.bounces+=1
     end
    else obj.part.Position+=delta end
    if f.age>8 or f.bounces>5 or obj.part.Position.Y < -10 then if obj.shooter and obj.shooter.Parent==Players then H.feedback(obj.shooter,"Miss! Try a different distance",false) end; reset(obj); break end
   end
  end
 end
 for _,player in Players:GetPlayers() do
  local obj=held[player]
  if obj then obj.shooter=player end
  player:SetAttribute("Count",scores[player] or 0)
  if obj then
   local r=H.root(player); local toward=r and (target.Position-r.Position).Unit
   H.guide(player,obj.charge and "Release when dots reach the basket" or (r and r.CFrame.LookVector:Dot(toward)>0.8 and "Hold THROW to charge" or "Face the basket with the joystick"),target.Position)
  else local pick=props[(scores[player] or 0)>0 and 2 or 1]; H.guide(player,(scores[player] or 0)>0 and "Grab the heavy crate" or "Grab the melon",pick.part.Position) end
 end
end)

local scenery=H.part("Scenery",Vector3.new(1,1,1),Vector3.new(36,0,-62),120); scenery.Transparency=1; scenery.CanCollide=false; scenery.CanQuery=false
for i=1,3 do H.detail(scenery,Vector3.new(3,5+i,3),Vector3.new(i*5,3,0),Color3.fromRGB(49,120,103)) end

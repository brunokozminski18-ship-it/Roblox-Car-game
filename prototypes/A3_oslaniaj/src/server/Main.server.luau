local notice=workspace:FindFirstChild("PlayNotice"); if notice then notice:Destroy() end
local H=require(script.Parent.Helpers)
local Players=game:GetService("Players")
H.part("Training ground",Vector3.new(160,1,130),Vector3.new(55,-0.5,-25),120)
H.spawn(Vector3.new(0,0.5,14))
local plots={}
for i=1,4 do
 local x=(i-1)*35
 local floor=H.part("Training plot "..i,Vector3.new(30,0.2,30),Vector3.new(x,0.1,-15),155)
 local title=H.sign(floor,"CLAIM PLOT")
 local doll=H.part("Figure",Vector3.new(3,5,3),Vector3.new(x,2.5,-15),210)
 local plot={owner=nil,slots={},busy=false,wins=0,round=0,bent=false,title=title}; plots[i]=plot
 local function guide()
  if not plot.owner then return end
  local nextSlot=plot.round%2+1; local ready=plot.slots[nextSlot] and (plot.slots[nextSlot].mode>0 or plot.slots[1].mode==2 or plot.slots[2].mode==2)
  H.guide(plot.owner,ready and "Press TEST to try your shelter" or (nextSlot==1 and "Tap the front socket to place a wall" or "Side attack next! Cover the side"),ready and Vector3.new(x-10,1,-8) or (nextSlot==1 and Vector3.new(x,1,-21) or Vector3.new(x+6,1,-15)))
 end
 H.prompt(floor,"Claim plot",function(player)
  if plot.owner or plot.busy then return end
  for _,other in plots do if other.owner==player then return end end
  plot.owner=player; title.Text="YOUR PLOT"; guide()
 end)
 for index,pos in {Vector3.new(x,1,-21),Vector3.new(x+6,1,-15)} do
  local slot=H.part(index==1 and "Front socket" or "Side socket",Vector3.new(6,0.5,6),pos,85)
  local s={mode=0,parts={}}; plot.slots[index]=s
  local text=H.sign(slot,"TAP SOCKET"); s.text=text
  H.prompt(slot,"Cycle panel",function(player)
   if plot.owner~=player or plot.busy then return end
   s.mode=(s.mode+1)%(plot.bent and 3 or 2)
   for _,part in s.parts do part:Destroy() end; s.parts={}
   if s.mode>0 then
    local panel=H.part("Straight panel",index==1 and Vector3.new(9,7,1) or Vector3.new(1,7,9),pos+Vector3.new(0,2.5,0),110)
    table.insert(s.parts,panel)
    if s.mode==2 then
     -- Bent corner actually covers the adjacent incoming ray too.
     local corner=H.part("Bent return",index==1 and Vector3.new(1,7,12) or Vector3.new(12,7,1),index==1 and Vector3.new(x+6,3.5,-15) or Vector3.new(x,3.5,-21),175)
     table.insert(s.parts,corner)
    end
   end
   text.Text=({"EMPTY","STRAIGHT","BENT"})[s.mode+1]; guide()
  end)
 end
 local button=H.part("Test shelter",Vector3.new(5,2,5),Vector3.new(x-10,1,-8),195)
 H.sign(button,"TEST")
 H.prompt(button,"Launch test",function(player)
  if plot.owner~=player or plot.busy then return end
  plot.busy=true; plot.round+=1
  local side=plot.round%2==0
  H.guide(player,side and "SIDE attack! Watch your wall" or "FRONT attack! Watch your wall",side and Vector3.new(x+20,3,-15) or Vector3.new(x,3,-35))
  local origin=Vector3.new(x+(side and 20 or 0),3,-15-(side and 0 or 20))
  local bonk=H.part(side and "SIDE BONK" or "FRONT BONK",Vector3.new(4,4,4),origin,65)
  bonk.CanCollide=false; H.sign(bonk,side and "SIDE >" or "FRONT >")
  task.delay(2,function()
   if plot.owner~=player then bonk:Destroy(); plot.busy=false; return end
   local panels={}
   for _,s in plot.slots do for _,p in s.parts do table.insert(panels,p) end end
   local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Include; params.FilterDescendantsInstances=panels
   local hit=workspace:Raycast(origin,doll.Position-origin,params)
   local destination=hit and hit.Position or doll.Position
   game:GetService("TweenService"):Create(bonk,TweenInfo.new(0.4),{Position=destination}):Play()
   task.delay(0.45,function()
    bonk:Destroy()
    if plot.owner~=player then plot.busy=false; return end
    if hit then
     plot.wins+=1; plot.bent=true; H.flash(hit.Instance)
     player:SetAttribute("Count",plot.wins); H.feedback(player,"Blocked! Bent panel unlocked",true)
    else
     doll.Transparency=0.75
     H.feedback(player,side and "Side gap! Cover that side" or "Front gap! Place a front wall",false)
    end
    task.delay(0.6,function() doll.Transparency=0; plot.busy=false; guide() end)
   end)
  end)
 end)
end
Players.PlayerRemoving:Connect(function(player)
 for _,plot in plots do
  if plot.owner==player then
   plot.owner=nil; plot.wins=0; plot.round=0; plot.bent=false; plot.title.Text="CLAIM PLOT"
   for _,s in plot.slots do s.mode=0; s.text.Text="TAP SOCKET"; for _,p in s.parts do p:Destroy() end; s.parts={} end
  end
 end
end)

local function welcome(player) H.guide(player,"Claim your plot",Vector3.new(0,1,-15)) end
Players.PlayerAdded:Connect(welcome); for _,p in Players:GetPlayers() do welcome(p) end

local scenery=H.part("Scenery",Vector3.new(1,1,1),Vector3.new(124,0,-58),120); scenery.Transparency=1; scenery.CanCollide=false; scenery.CanQuery=false
for i=1,3 do H.detail(scenery,Vector3.new(3,5+i,3),Vector3.new(i*5,3,0),Color3.fromRGB(49,120,103)) end

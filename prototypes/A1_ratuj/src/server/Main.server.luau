local notice=workspace:FindFirstChild("PlayNotice"); if notice then notice:Destroy() end
local H = require(script.Parent.Helpers)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
H.part("Ground",Vector3.new(112,1,110),Vector3.new(15,-0.5,-35),115)
H.spawn(Vector3.new(0,0.5,8))
local shelter = H.part("Shelter",Vector3.new(18,1,14),Vector3.new(0,0.5,0),195)
H.sign(shelter,"SAFE HOME")
H.part("Divider",Vector3.new(4,9,55),Vector3.new(15,4.5,-33),90)
-- Shortcut is a corridor (x -9..13); one side pocket is the only cover from the roar.
H.part("Corridor wall",Vector3.new(2,9,40),Vector3.new(-10,4.5,-40),90)
H.part("Corridor wall",Vector3.new(2,9,8),Vector3.new(-10,4.5,-12),90)
local pocket = H.part("Hiding pocket",Vector3.new(2,9,6),Vector3.new(-16,4.5,-18),90)
H.part("Pocket side",Vector3.new(5,9,1),Vector3.new(-13,4.5,-20.5),90)
H.part("Pocket side",Vector3.new(5,9,1),Vector3.new(-13,4.5,-15.5),90)
H.sign(pocket,"HIDE HERE")
local safeFloor=H.part("Pocket floor",Vector3.new(5,0.1,4),Vector3.new(-12.5,0.1,-18),150); safeFloor.Color=Color3.fromRGB(65,235,151); safeFloor.Material=Enum.Material.Neon; safeFloor.CanCollide=false; safeFloor.CanQuery=false
local noise = H.part("Noisy shortcut",Vector3.new(22,0.2,12),Vector3.new(2,0.1,-29),75)
H.sign(noise,"NOISY PATH")
local function inLane(p) return p.X > -9 and p.X < 13 end
local quiet = H.part("Quiet detour",Vector3.new(14,0.2,60),Vector3.new(32,0.1,-32),170)
H.sign(quiet,"QUIET PATH")
local gate = H.part("Help flap",Vector3.new(13,7,1),Vector3.new(29,3.5,-10),100)
H.prompt(gate,"Open for 5 seconds",function()
 if not gate.CanCollide then return end
 gate.CanCollide = false; gate.Transparency = 0.8
 task.delay(5,function() gate.CanCollide = true; gate.Transparency = 0 end)
end)
-- Quiet route remains passable around the flap even without a helper.
local objects, carried, scores, pulses, triggered = {},{},{},{},{}
for i,pos in ipairs({Vector3.new(-5,2,-12),Vector3.new(0,2,-64)}) do
 local p = H.part(i == 1 and "Near rescue" or "Far rescue",Vector3.new(3,3,3),pos,160)
 local item = {part=p,home=pos,owner=nil}; objects[i]=item
 H.sign(p,i == 1 and "RESCUE ME" or "RESCUE ME")
 item.prompt = H.prompt(p,"Pick up",function(player)
  if item.owner or carried[player] then return end
  item.owner = player; carried[player] = item; triggered[player] = false
  p.CanCollide = false; item.prompt.Enabled = false
 end)
end
local function release(player, reset)
 local item = carried[player]
 if item then
  carried[player] = nil; item.owner = nil; item.part.CanCollide = true; item.prompt.Enabled = true
  local r = H.root(player)
  item.part.Position = reset and item.home or (r and r.Position+Vector3.new(3,0,0) or item.home)
 end
 triggered[player] = nil
end
-- One fixed, argument-free intent remote; no client-selected objects or reward.
local remote = Instance.new("RemoteEvent"); remote.Name="Drop"; remote.Parent=game:GetService("ReplicatedStorage")
remote.OnServerEvent:Connect(function(player,...)
 if not H.allow(player) then return end
 if select("#",...) ~= 0 or not H.root(player) then return end
 release(player,false)
end)
Players.PlayerRemoving:Connect(function(p)
 release(p,true); scores[p]=nil
 if pulses[p] then pulses[p].wall:Destroy(); pulses[p]=nil end
 for slot=1,8 do
  local shelf=workspace:FindFirstChild("Shelf"..p.UserId.."_"..slot)
  if shelf then shelf:Destroy() end
 end
end)
local accumulator=0
RunService.Heartbeat:Connect(function(dt)
 accumulator += dt; if accumulator < 0.05 then return end; accumulator=0
 for _,player in Players:GetPlayers() do
  local r = H.root(player); local item=carried[player]; local pulse=pulses[player]
  if not r then release(player,true); if pulse then pulse.wall:Destroy(); pulses[player]=nil end; continue end
  if item then
   item.part.Position = r.Position + Vector3.new(0,3,0)
   if inLane(r.Position) and math.abs(r.Position.Z+29)<6 and not triggered[player] and not pulse then
    triggered[player]=true
    -- Roar comes from the shelter end towards the carrier: hide in the pocket or get pushed back.
    local wall=H.part("Roar wave",Vector3.new(22,9,1),Vector3.new(2,4.5,-7),65)
    wall.CanCollide=false; H.sign(wall,"ROAR!")
    pulses[player]={wall=wall,start=os.clock()}; pulse=pulses[player]
   end
   if math.abs(r.Position.X)<9 and math.abs(r.Position.Z)<7 then
    scores[player]=(scores[player] or 0)+1
    H.feedback(player,"Safe at home!",true)
    local n=scores[player]; release(player,true); H.flash(shelter)
    -- Bounded visible shelf: last eight rescues, never an unbounded collection.
    local slot=(n-1)%8+1; local name="Shelf"..player.UserId.."_"..slot
    local old=workspace:FindFirstChild(name); if old then old:Destroy() end
    H.part(name,Vector3.new(1.5,1.5,1.5),Vector3.new(-8+slot*2,2,5),210)
   end
  end
  if pulse then
   local age=os.clock()-pulse.start
   local z=-7-math.clamp(age-1,0,3)*25
   pulse.wall.Position=Vector3.new(2,4.5,z)
   if age>=1 and inLane(r.Position) and math.abs(r.Position.Z-z)<3 then
    H.feedback(player,"Caught by the roar!",false)
    release(player,true); r.CFrame=CFrame.new(0,4,8); age=5
   end
   if age>4 then pulse.wall:Destroy(); pulses[player]=nil end
  end
  player:SetAttribute("Count",scores[player] or 0)
  if pulses[player] then H.guide(player,"Roar incoming! Hide in the green pocket",Vector3.new(-12,2,-18))
  elseif carried[player] then H.guide(player,"Bring your creature home",r.Position.X>17 and r.Position.Z < -4 and Vector3.new(32,1,-4) or shelter.Position)
  else local pick=objects[(scores[player] or 0)>0 and 2 or 1]; H.guide(player,"Pick up the little creature",pick.part.Position) end
 end
end)

local scenery=H.part("Scenery",Vector3.new(1,1,1),Vector3.new(47,0,-65),120); scenery.Transparency=1; scenery.CanCollide=false; scenery.CanQuery=false
for i=1,3 do H.detail(scenery,Vector3.new(3,5+i,3),Vector3.new(i*5,3,0),Color3.fromRGB(49,120,103)) end

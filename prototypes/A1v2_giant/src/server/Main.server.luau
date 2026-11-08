-- Don't Wake the Giant, grey-box v2: one kitchen, noise meter, sneak, hideouts, per-player roar.
local notice=workspace:FindFirstChild("PlayNotice"); if notice then notice:Destroy() end
local H = require(script.Parent.Helpers)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local rgb = Color3.fromRGB

-- Tunables (NOT FINAL; measured in playtests).
local WALK, SNEAK = 16, 8
local FLOOR_NOISE = {tiles=30, wood=12, carpet=3} -- per second while walking with a creature
local EMPTY_HANDS = 0.25                          -- multiplier without a creature
local DECAY, HIDE_DECAY = 10, 50                  -- per second when quiet / hidden
local CLANG = 30                                  -- bumping a pot
local WARN = 1.5                                   -- seconds to hide before the roar

-- Map: nest at +z, giant at -z. Tiles in the middle (loud), carpet on the left (quiet), wood on the right.
H.part("Floor",Vector3.new(100,1,120),Vector3.new(0,-0.5,-45),rgb(176,128,84))
for i=0,6 do for j=0,24 do
 local tile=H.part("Tile",Vector3.new(4,0.2,4),Vector3.new(-12+i*4,0.1,-2-j*4),(i+j)%2==0 and rgb(240,240,232) or rgb(140,190,222))
 tile.CanQuery=false
end end
H.part("Carpet",Vector3.new(18,0.2,100),Vector3.new(-31,0.1,-50),rgb(178,52,64)).CanQuery=false
for _,w in {{Vector3.new(100,30,2),Vector3.new(0,15,-106)},{Vector3.new(2,30,122),Vector3.new(-51,15,-45)},{Vector3.new(2,30,122),Vector3.new(51,15,-45)},{Vector3.new(100,30,2),Vector3.new(0,15,16)}} do
 H.part("Wall",w[1],w[2],rgb(236,214,170))
end
H.part("Mouse hole",Vector3.new(10,8,0.4),Vector3.new(0,4,14.8),rgb(30,22,18))
local nest=H.part("Nest",Vector3.new(18,0.6,12),Vector3.new(0,0.3,8),rgb(120,200,110))
H.sign(nest,"NEST / SAFE",3)
local spawn=Instance.new("SpawnLocation"); spawn.Size=Vector3.new(6,0.4,4); spawn.Position=Vector3.new(0,0.8,12)
spawn.Anchored=true; spawn.Neutral=true; spawn.Duration=0; spawn.Color=rgb(150,230,130); spawn.Material=Enum.Material.SmoothPlastic; spawn.Parent=workspace
local function inNest(p) return math.abs(p.X)<9 and p.Z>2 end
local function floorAt(p)
 if math.abs(p.X)<14 and p.Z<0 then return "tiles" elseif p.X<-22 and p.X>-40 then return "carpet" end
 return "wood"
end

-- Table and hideouts (inside a hideout = noise drains fast and the roar passes over you).
H.part("Table top",Vector3.new(24,2,18),Vector3.new(0,12,-45),rgb(122,82,52))
for _,o in {Vector3.new(-11,0,-8),Vector3.new(11,0,-8),Vector3.new(-11,0,8),Vector3.new(11,0,8)} do H.part("Table leg",Vector3.new(2,11,2),Vector3.new(o.X,5.5,-45+o.Z),rgb(102,68,44)) end
local hides={
 {name="Under table",min=Vector3.new(-10,0,-53),max=Vector3.new(10,0,-37)},
 {name="Cupboard",min=Vector3.new(-50,0,-74),max=Vector3.new(-42,0,-62)},
 {name="Box",min=Vector3.new(30,0,-38),max=Vector3.new(40,0,-28)},
}
for _,h in hides do
 local c=(h.min+h.max)/2; h.center=Vector3.new(c.X,0,c.Z)
 local mark=H.part(h.name.." spot",Vector3.new(h.max.X-h.min.X,0.15,h.max.Z-h.min.Z),Vector3.new(c.X,0.25,c.Z),rgb(70,235,150))
 mark.Material=Enum.Material.Neon; mark.Transparency=0.35; mark.CanCollide=false; mark.CanQuery=false
 H.sign(mark,"HIDE",3)
end
H.part("Cupboard back",Vector3.new(1,14,14),Vector3.new(-50.5,7,-68),rgb(150,106,70))
H.part("Cupboard top",Vector3.new(9,1,14),Vector3.new(-46,14,-68),rgb(150,106,70))
for _,z in {-75,-61} do H.part("Cupboard side",Vector3.new(9,14,1),Vector3.new(-46,7,z),rgb(150,106,70)) end
for _,x in {29.5,40.5} do H.part("Box side",Vector3.new(1,6,11),Vector3.new(x,3,-33),rgb(196,160,104)) end
H.part("Box back",Vector3.new(12,6,1),Vector3.new(35,3,-38.5),rgb(196,160,104))
local function hidden(p)
 for _,h in hides do if p.X>h.min.X and p.X<h.max.X and p.Z>h.min.Z and p.Z<h.max.Z then return h end end
end

-- Pots: bumping one while not sneaking is a loud clang.
local pots={}
for _,pos in {Vector3.new(-6,1.5,-22),Vector3.new(8,1.5,-30),Vector3.new(-5,1.5,-66),Vector3.new(7,1.5,-74),Vector3.new(26,1.5,-62)} do
 local pot=H.part("Pot",Vector3.new(3,3,3),pos,rgb(150,158,170)); pot.Material=Enum.Material.Metal
 H.detail(pot,Vector3.new(3.6,0.4,3.6),Vector3.new(0,1.6,0),rgb(110,116,126))
 table.insert(pots,pot)
end

-- The giant: one shared model at the back; its eye opens while anyone is waking it.
local giant=H.part("Giant",Vector3.new(36,30,10),Vector3.new(0,15,-99),rgb(96,130,190))
local head=H.detail(giant,Vector3.new(22,18,16),Vector3.new(0,25,2),rgb(240,196,150))
H.detail(head,Vector3.new(24,5,17),Vector3.new(0,8,0),rgb(92,62,40)) -- hair
H.detail(head,Vector3.new(3,3,2),Vector3.new(0,-1,8),rgb(222,160,120)) -- nose
for _,x in {-14,14} do H.detail(giant,Vector3.new(8,8,20),Vector3.new(x,-11,8),rgb(240,196,150)) end -- hands
local lids,eyes={},{}
for _,x in {-5,5} do
 table.insert(lids,H.detail(head,Vector3.new(5,0.6,0.5),Vector3.new(x,2,8.1),rgb(60,40,30)))
 local eye=H.detail(head,Vector3.new(5,4,0.5),Vector3.new(x,2,8.1),Color3.new(1,1,1)); eye.Transparency=1
 local pupil=H.detail(eye,Vector3.new(2,2,0.3),Vector3.new(0,0,0.3),rgb(200,30,40)); pupil.Transparency=1
 table.insert(eyes,eye); table.insert(eyes,pupil)
end
local snore=H.sign(head,"Z z z",12,200)
local function setEyes(open)
 for _,l in lids do l.Transparency=open and 1 or 0 end
 for _,e in eyes do e.Transparency=open and 0 or 1 end
 snore.Text=open and "WHO'S THERE?!" or "Z z z"
 snore.TextColor3=open and rgb(255,90,90) or Color3.new(1,1,1)
end

-- Creatures: louder = rarer = more crumbs. Squeaks add noise even while sneaking.
local kinds={
 {name="Mouse",home=Vector3.new(6,1.5,-14),color=rgb(190,190,200),value=1,squeak=0,every=0,sound=""},
 {name="Duckling",home=Vector3.new(32,1.5,-52),color=rgb(255,220,60),value=3,squeak=14,every=4,sound="QUACK!"},
 {name="Parrot",home=Vector3.new(0,1.5,-86),color=rgb(60,200,90),value=8,squeak=25,every=2.5,sound="SQUAWK!"},
}
local creatures,state={},{}
for _,k in kinds do
 local p=H.part(k.name,Vector3.new(2.6,2.6,2.6),k.home,k.color)
 for _,x in {-0.6,0.6} do H.detail(p,Vector3.new(0.5,0.6,0.2),Vector3.new(x,0.4,-1.35),rgb(25,25,35)) end
 local pop=H.sign(p,"",3,60); pop.Parent.Enabled=false
 local hl=Instance.new("Highlight"); hl.FillTransparency=0.8; hl.OutlineColor=Color3.new(1,1,1); hl.Parent=p
 local c={kind=k,part=p,pop=pop,owner=nil}
 c.prompt=H.prompt(p,"Grab",function(player)
  local s=state[player]
  if not s or c.owner or s.carry or s.wake then return end
  c.owner=player; s.carry=c; s.nextSqueak=os.clock()+k.every; c.prompt.Enabled=false; p.CanCollide=false
 end)
 table.insert(creatures,c)
end
local function release(player, toHome)
 local s=state[player]; local c=s and s.carry
 if not c then return end
 s.carry=nil; c.owner=nil
 local r=H.root(player)
 c.part.CFrame=CFrame.new((toHome or not r) and c.kind.home or Vector3.new(r.Position.X,1.5,r.Position.Z)+r.CFrame.LookVector*3)
 c.part.CanCollide=true; c.prompt.Enabled=true
end
local function squeak(c)
 c.pop.Text=c.kind.sound; c.pop.Parent.Enabled=true
 task.delay(0.8,function() c.pop.Parent.Enabled=false end)
end

-- Nest shelf: the last rescues of this session, bounded.
local shelf={}
local function addToShelf(color)
 local i=#shelf%10
 if shelf[i+1] then shelf[i+1]:Destroy() end
 local p=H.part("Rescued",Vector3.new(1.4,1.4,1.4),Vector3.new(-7+i*1.6,1.3,11),color); p.CanCollide=false
 shelf[i+1]=p
end

-- Remotes: argument-checked, rate-limited intents only.
local RS=game:GetService("ReplicatedStorage")
local dropRemote=Instance.new("RemoteEvent"); dropRemote.Name="Drop"; dropRemote.Parent=RS
local sneakRemote=Instance.new("RemoteEvent"); sneakRemote.Name="Sneak"; sneakRemote.Parent=RS
dropRemote.OnServerEvent:Connect(function(player,...)
 if not H.allow(player) or select("#",...)~=0 then return end
 local s=state[player]; if s and not s.wake then release(player,false) end
end)
sneakRemote.OnServerEvent:Connect(function(player,on,...)
 if not H.allow(player) or select("#",...)~=0 or typeof(on)~="boolean" then return end
 local s=state[player]; local _,h=H.root(player)
 if not s or not h then return end
 s.sneak=on; h.WalkSpeed=on and SNEAK or WALK; player:SetAttribute("Sneaking",on)
end)

Players.PlayerAdded:Connect(function(player)
 state[player]={noise=0,crumbs=0,rescued=0,sneak=false,carry=nil,wake=nil,clang={}}
 player.CharacterAdded:Connect(function(char)
  local s=state[player]; if not s then return end
  s.sneak=false; player:SetAttribute("Sneaking",false)
  local h=char:WaitForChild("Humanoid"); h.WalkSpeed=WALK
 end)
end)
Players.PlayerRemoving:Connect(function(player) release(player,true); state[player]=nil end)

local function caught(player, s, r)
 release(player,true); s.noise=0; s.wake=nil
 if r then r.CFrame=CFrame.new(0,4,12) end
 H.feedback(player,"The giant heard you!",false)
end

local acc=0
RunService.Heartbeat:Connect(function(dt)
 acc+=dt; if acc<0.1 then return end
 local step=acc; acc=0
 local now=workspace:GetServerTimeNow()
 local anyWake=false
 for player,s in state do
  local r=H.root(player)
  if not r then release(player,true); s.wake=nil; s.noise=0; continue end
  local pos=r.Position
  local c=s.carry
  if c then c.part.CFrame=CFrame.new(pos+Vector3.new(0,3.2,0)) end
  local hide=hidden(pos)
  -- Noise.
  if not s.wake then
   local moving=Vector3.new(r.AssemblyLinearVelocity.X,0,r.AssemblyLinearVelocity.Z).Magnitude>2
   local gain=0
   if moving and not s.sneak and not inNest(pos) then gain=FLOOR_NOISE[floorAt(pos)]*(c and 1 or EMPTY_HANDS) end
   if moving and not s.sneak then
    for _,pot in pots do
     if (pot.Position-pos).Magnitude<4 and (s.clang[pot] or 0)<os.clock() then
      s.clang[pot]=os.clock()+2; s.noise+=CLANG; H.feedback(player,"CLANG!",false)
     end
    end
   end
   if c and c.kind.every>0 and os.clock()>=s.nextSqueak then
    s.nextSqueak=os.clock()+c.kind.every; s.noise+=c.kind.squeak; squeak(c)
   end
   if inNest(pos) then gain=0 end
   if gain>0 then s.noise+=gain*step else s.noise-=(hide and HIDE_DECAY or DECAY)*step end
   s.noise=math.clamp(s.noise,0,100)
   if s.noise>=100 and not inNest(pos) then
    s.wake=now; player:SetAttribute("WaveStart",now+WARN)
    H.feedback(player,"The giant is waking up! HIDE!",false)
   end
  end
  -- Roar: after the warning it fills the whole kitchen; only hideouts and the nest are safe.
  if s.wake then
   anyWake=true
   if now>=s.wake+WARN then
    if hide or inNest(pos) then
     s.wake=nil; s.noise=40; H.feedback(player,"Phew! It didn't see you",true)
    else
     caught(player,s,r)
    end
    task.delay(0.6,function() player:SetAttribute("WaveStart",nil) end)
   end
  end
  -- Delivery.
  if c and inNest(pos) then
   s.carry=nil; c.owner=nil; c.part.CFrame=CFrame.new(c.kind.home+Vector3.new(0,-20,0))
   task.delay(2,function() if not c.owner then c.part.CFrame=CFrame.new(c.kind.home); c.part.CanCollide=true; c.prompt.Enabled=true end end)
   s.crumbs+=c.kind.value; s.rescued+=1; addToShelf(c.kind.color)
   H.feedback(player,"Saved the "..c.kind.name:lower().."! +"..c.kind.value.." crumbs",true)
  end
  -- Guide (one step at a time).
  if s.wake then
   local best,bd=nil,math.huge
   for _,h in hides do local d=(h.center-pos).Magnitude; if d<bd then best,bd=h,d end end
   H.guide(player,"The giant is waking! Get to a HIDE spot!",best.center)
  elseif c then H.guide(player,c.kind.every>0 and "Bring it home! It "..c.kind.sound:lower():gsub("!","").."s, so hurry or hide" or "Bring it to the nest. SNEAK on the tiles",nest.Position)
  elseif s.rescued==0 then H.guide(player,"Grab the mouse",kinds[1].home)
  elseif s.rescued==1 then H.guide(player,"Try the duckling. It quacks!",kinds[2].home)
  elseif s.rescued==2 then H.guide(player,"The parrot pays most... if you dare",kinds[3].home)
  else H.guide(player,"Louder creatures = more crumbs",nil) end
  player:SetAttribute("Noise",math.floor(s.noise)); player:SetAttribute("Crumbs",s.crumbs); player:SetAttribute("Waking",s.wake~=nil)
 end
 setEyes(anyWake)
end)

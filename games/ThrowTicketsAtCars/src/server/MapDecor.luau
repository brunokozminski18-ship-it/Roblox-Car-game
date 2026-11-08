--!strict
-- Map v5 dressing, SAMPLE (NOT FINAL): plaza, tunnel mouth and plots only; deeper tunnel stays greybox until approved.
-- Original part-built look (no imported meshes): checker grass, dirt-block cliffs with a grass lip, blocky trees,
-- traffic-light posts at the throw line, striped stall awnings, wooden fences. LihFolk worldbuilding: bright cartoon
-- lighting preset, decor non-colliding and shadowless where small.
local Lighting=game:GetService("Lighting")
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local Decor={}
local GRASS_A,GRASS_B=Color3.fromRGB(104,196,72),Color3.fromRGB(122,212,86)
local DIRT_A,DIRT_B=Color3.fromRGB(128,88,58),Color3.fromRGB(110,74,48)
local LIP=Color3.fromRGB(92,180,62)
local function block(parent: Instance,name: string,size: Vector3,cf: CFrame,color: Color3,collide: boolean?): Part
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Anchored=true
 p.Material=Enum.Material.SmoothPlastic;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.CanCollide=collide==true;p.CanTouch=false;p.CanQuery=collide==true
 p.CastShadow=size.Magnitude>12;p.Parent=parent
 return p
end
-- Bright cartoon preset (LihFolk Stylized Lighting Recipes).
local function lighting()
 Lighting.ClockTime=13.5;Lighting.Brightness=2.5;Lighting.Ambient=Color3.fromRGB(110,110,125);Lighting.OutdoorAmbient=Color3.fromRGB(150,150,160)
 local atmo=Lighting:FindFirstChildOfClass("Atmosphere")or Instance.new("Atmosphere");atmo.Density=.25;atmo.Offset=.1;atmo.Haze=.5;atmo.Color=Color3.fromRGB(200,225,255);atmo.Parent=Lighting
 local cc=Lighting:FindFirstChild("TT_Grade")or Instance.new("ColorCorrectionEffect");cc.Name="TT_Grade";cc.Contrast=.08;cc.Saturation=.15;cc.Parent=Lighting
 local bloom=Lighting:FindFirstChild("TT_Bloom")or Instance.new("BloomEffect");bloom.Name="TT_Bloom";bloom.Intensity=.5;bloom.Threshold=1.4;bloom.Size=24;bloom.Parent=Lighting
end
-- Blocky tree: trunk plus two stacked leaf cubes, slightly varied.
local function tree(parent: Instance,pos: Vector3,rng: Random)
 local h=rng:NextNumber(7,11);local s=rng:NextNumber(.85,1.2)
 block(parent,"Trunk",Vector3.new(2,h,2)*Vector3.new(s,1,s),CFrame.new(pos+Vector3.new(0,h/2,0)),Color3.fromRGB(118,80,50))
 local leaf=if rng:NextNumber()<.5 then GRASS_A else Color3.fromRGB(80,170,60)
 block(parent,"Leaves",Vector3.new(9,6,9)*s,CFrame.new(pos+Vector3.new(0,h+2,0))*CFrame.Angles(0,rng:NextNumber(0,math.pi/2),0),leaf)
 block(parent,"LeavesTop",Vector3.new(6,4,6)*s,CFrame.new(pos+Vector3.new(0,h+6.5,0))*CFrame.Angles(0,rng:NextNumber(0,math.pi/2),0),GRASS_B)
end
-- Traffic light post: the car-themed lamp at both ends of the throw line.
local function trafficLight(parent: Instance,pos: Vector3)
 block(parent,"Pole",Vector3.new(1.2,12,1.2),CFrame.new(pos+Vector3.new(0,6,0)),Color3.fromRGB(60,64,72))
 block(parent,"Housing",Vector3.new(3,7.5,2.4),CFrame.new(pos+Vector3.new(0,14.5,0)),Color3.fromRGB(34,36,42))
 for i,c in {Color3.fromRGB(255,70,60),Color3.fromRGB(255,200,40),Color3.fromRGB(70,230,90)}do
  local lamp=block(parent,"Lamp",Vector3.new(1.8,1.8,.4),CFrame.new(pos+Vector3.new(0,17-(i-1)*2.4,1.3)),c)
  lamp.Material=Enum.Material.Neon;lamp.Transparency=if i==3 then 0 else .55
 end
end
function Decor.world(root: Instance)
 local L=Config.Layout
 local f=Instance.new("Folder");f.Name="Decor";f.Parent=root
 local rng=Random.new(20261108)
 lighting()
 task.spawn(Decor.tunnel,root) -- cosmetic, builds in the background (one biome per frame)
 -- Plaza checker grass (tiles sit on the plaza collider, no collision of their own).
 -- lihfolk-ignore: findfirstchild-chain (optional type, checked on the next line)
 local plaza=root:FindFirstChild("Plaza")::BasePart?
 if plaza then plaza.Color=GRASS_A
  local tile=12;local nx=math.floor(L.PlazaWidth/tile);local nz=math.floor(L.PlazaDepth/tile)
  for ix=0,nx-1 do for iz=0,nz-1 do if (ix+iz)%2==0 then
   block(f,"Grass",Vector3.new(tile,.04,tile),CFrame.new(-L.PlazaWidth/2+tile/2+ix*tile,-.03,tile/2+iz*tile),GRASS_B).CastShadow=false
  end end end
  -- Sandy walk from the spawn to the throw line.
  block(f,"Walk",Vector3.new(14,.05,34),CFrame.new(0,-.01,21),Color3.fromRGB(232,206,150)).CastShadow=false
 end
 -- Cliffs: dirt blocks on the plaza faces; tunnel walls are themed per biome in Decor.tunnel.
 local cliffs=root:FindFirstChild("Cliffs")
 if cliffs then for _,c in cliffs:GetChildren()do if c.Name=="Cliff"then (c::BasePart).Color=DIRT_A elseif c.Name=="Grass"then (c::BasePart).Color=LIP end end end
 local cell=8;local rows=math.floor(L.CliffHeight/cell)
 for side=-1,1,2 do
  local inner=side*Config.GroundWidth/2
  -- Plaza-facing front face (z = 0), from the tunnel edge outward to the plaza edge.
  for i=0,math.floor((L.PlazaWidth/2-Config.GroundWidth/2)/cell)-1 do for r=0,rows-1 do if (i+r)%2==0 then
   block(f,"Dirt",Vector3.new(cell,cell,.3),CFrame.new(inner+side*(cell/2+i*cell),cell/2+r*cell-1,.12),DIRT_B).CastShadow=false
  end end end
  for k=0,3 do tree(f,Vector3.new(side*(Config.GroundWidth/2+18+k*rng:NextNumber(20,26)),L.CliffHeight,-rng:NextNumber(10,22)),rng)end
  trafficLight(f,Vector3.new(inner+side*2.5,0,Config.LaunchCenter.Z+2))
 end
 -- Lower cliffs closing the plaza on the sides and behind the plots (collidable edge, no void).
 local rim=24
 local function wall(size: Vector3,center: Vector3,faceAxis: string,faceSign: number)
  block(f,"PlazaCliff",size,CFrame.new(center),DIRT_A,true)
  block(f,"PlazaCliffTop",Vector3.new(size.X,1,size.Z),CFrame.new(center+Vector3.new(0,size.Y/2+.5,0)),LIP)
  local long=if faceAxis=="X"then size.Z else size.X
  for i=0,math.floor(long/cell)-1 do for r=0,math.floor(size.Y/cell)-1 do if (i+r)%2==0 then
   local along=-long/2+cell/2+i*cell;local y=center.Y-size.Y/2+cell/2+r*cell
   local cf=if faceAxis=="X"then CFrame.new(center.X+faceSign*(size.X/2+.12),y,center.Z+along)else CFrame.new(center.X+along,y,center.Z+faceSign*(size.Z/2+.12))
   block(f,"Dirt",if faceAxis=="X"then Vector3.new(.3,cell,cell)else Vector3.new(cell,cell,.3),cf,DIRT_B).CastShadow=false
  end end end
 end
 local W,D=L.PlazaWidth,L.PlazaDepth
 wall(Vector3.new(W+60,rim,30),Vector3.new(0,rim/2-1,D+15),"Z",-1)
 for side=-1,1,2 do wall(Vector3.new(30,rim,D),Vector3.new(side*(W/2+15),rim/2-1,D/2),"X",-side)end
 for k=0,9 do tree(f,Vector3.new(-W/2+15+k*(W-30)/9+rng:NextNumber(-4,4),rim-1,D+rng:NextNumber(6,22)),rng)end
 for side=-1,1,2 do for k=0,3 do tree(f,Vector3.new(side*(W/2+rng:NextNumber(6,24)),rim-1,15+k*30+rng:NextNumber(-5,5)),rng)end end
 -- Trees and bushes framing the plaza corners (kept off paths, plots and stands).
 for _,x in {-136,136}do tree(f,Vector3.new(x,0,L.PlazaDepth-10),rng)end
 -- Striped awnings on the stands.
 for _,name in {"OpenShop","OpenSell"}do
  -- lihfolk-ignore: findfirstchild-chain (both results checked before use)
  local stand=root:FindFirstChild(name)::Model?;local roof=stand and stand:FindFirstChild("Roof")::BasePart?
  if stand and roof then
   roof.Transparency=1
   -- Sloped awning facing the plaza (+Z) plus a scalloped front valance, both striped.
   for i=0,7 do
    local color=if i%2==0 then roof.Color else Color3.new(1,1,1)
    block(stand,"Stripe",Vector3.new(2,.8,9.5),roof.CFrame*CFrame.new(-7+i*2,0,.6)*CFrame.Angles(math.rad(22),0,0),color)
    block(stand,"Valance",Vector3.new(2,1.6,.4),roof.CFrame*CFrame.new(-7+i*2,-2.3,5),color)
   end
  end
 end
end

-- Tunnel walls themed per biome (approved style 08.11.2026). Each theme: wall colours, lip colour, rim dressing.
local function rgb(r: number,g: number,b: number): Color3 return Color3.fromRGB(r,g,b)end
local THEMES: {[string]: any}={
 ["Junkyard"]={a=rgb(128,88,58),b=rgb(110,74,48),lip=LIP,rim="tree"},
 ["Suburbs"]={a=rgb(132,92,60),b=rgb(114,78,50),lip=rgb(110,200,80),rim="tree"},
 ["Downtown"]={a=rgb(120,126,140),b=rgb(98,104,118),lip=rgb(140,146,158),rim="tower"},
 ["Farm Roads"]={a=rgb(140,98,62),b=rgb(122,84,52),lip=rgb(150,200,70),rim="hay"},
 ["Desert Highway"]={a=rgb(222,170,104),b=rgb(204,150,88),lip=rgb(240,206,140),rim="cactus"},
 ["Snowy Pass"]={a=rgb(128,138,156),b=rgb(110,120,138),lip=rgb(245,250,255),rim="pine"},
 ["Sports Track"]={a=rgb(214,64,64),b=rgb(240,240,240),lip=rgb(150,150,160),rim="flag"},
 ["Millionaire Hills"]={a=rgb(128,96,66),b=rgb(110,82,56),lip=rgb(84,190,96),rim="hedge"},
 ["Hypercar Island"]={a=rgb(232,200,140),b=rgb(214,182,122),lip=rgb(250,230,170),rim="palm"},
 ["Future City"]={a=rgb(40,48,82),b=rgb(30,36,64),lip=rgb(60,230,255),rim="neon"},
}
local function rimProp(parent: Instance,kind: string,pos: Vector3,rng: Random)
 if kind=="tree"or kind=="hedge"and rng:NextNumber()<.5 then tree(parent,pos,rng)
 elseif kind=="hedge"then block(parent,"Hedge",Vector3.new(10,4,5),CFrame.new(pos+Vector3.new(0,2,0)),rgb(60,150,70))
 elseif kind=="tower"then local h=rng:NextNumber(14,34);local b=block(parent,"Tower",Vector3.new(14,h,14),CFrame.new(pos+Vector3.new(0,h/2,0)),if rng:NextNumber()<.5 then rgb(150,160,178)else rgb(120,132,150))
  for y=4,h-4,6 do block(parent,"Windows",Vector3.new(14.2,2,10),b.CFrame*CFrame.new(0,-h/2+y,0),rgb(255,230,140))end
 elseif kind=="hay"then block(parent,"Hay",Vector3.new(5,4,5),CFrame.new(pos+Vector3.new(0,2,0))*CFrame.Angles(0,rng:NextNumber(0,1),0),rgb(236,200,90));if rng:NextNumber()<.5 then tree(parent,pos+Vector3.new(8,0,0),rng)end
 elseif kind=="cactus"then local h=rng:NextNumber(6,10);local c=rgb(70,160,80)
  block(parent,"Cactus",Vector3.new(2.4,h,2.4),CFrame.new(pos+Vector3.new(0,h/2,0)),c);block(parent,"Arm",Vector3.new(4,1.6,1.6),CFrame.new(pos+Vector3.new(1.6,h*.55,0)),c);block(parent,"Arm",Vector3.new(1.6,3,1.6),CFrame.new(pos+Vector3.new(3,h*.55+1.5,0)),c)
 elseif kind=="pine"then local h=rng:NextNumber(3,5)
  block(parent,"Trunk",Vector3.new(1.6,h,1.6),CFrame.new(pos+Vector3.new(0,h/2,0)),rgb(110,76,50))
  for i,w in {8,6,4}do block(parent,"Needles",Vector3.new(w,3,w),CFrame.new(pos+Vector3.new(0,h+1.5+(i-1)*2.6,0)),rgb(50,120,80))end
  block(parent,"Snow",Vector3.new(4.4,1,4.4),CFrame.new(pos+Vector3.new(0,h+7.4,0)),rgb(250,252,255))
 elseif kind=="flag"then block(parent,"Pole",Vector3.new(.6,12,.6),CFrame.new(pos+Vector3.new(0,6,0)),rgb(230,230,230))
  local flag=block(parent,"Flag",Vector3.new(.2,3,5),CFrame.new(pos+Vector3.new(0,10.5,2.6)),if rng:NextNumber()<.5 then rgb(30,30,30)else rgb(240,240,240))
  flag.CastShadow=false
 elseif kind=="palm"then local h=rng:NextNumber(9,13)
  for i=0,3 do block(parent,"Trunk",Vector3.new(1.8,h/4,1.8),CFrame.new(pos+Vector3.new(i*.4,h/8+i*h/4,0)),rgb(150,110,70))end
  for k=0,3 do block(parent,"Frond",Vector3.new(8,.6,2.4),CFrame.new(pos+Vector3.new(1.6,h,0))*CFrame.Angles(0,k*math.pi/4,math.rad(-14)),rgb(70,170,70))end
 elseif kind=="neon"then local h=rng:NextNumber(10,18)
  block(parent,"Pylon",Vector3.new(3,h,3),CFrame.new(pos+Vector3.new(0,h/2,0)),rgb(28,32,56))
  local ring=block(parent,"Glow",Vector3.new(3.4,1,3.4),CFrame.new(pos+Vector3.new(0,h-1,0)),rgb(60,230,255));ring.Material=Enum.Material.Neon;ring.CastShadow=false
 end
end
function Decor.tunnel(root: Instance)
 local L=Config.Layout
 local f=Instance.new("Folder");f.Name="TunnelDecor";f.Parent=root
 local rng=Random.new(1108)
 local cell=10;local rows=math.floor(L.CliffHeight/cell)
 for _,b in Config.Biomes do
  local theme=THEMES[b.Name]or THEMES["Junkyard"]
  local start,finish=b.Start,math.min(b.Finish,Config.MapEnd)
  local node=Instance.new("Folder");node.Name=b.Name;node.Parent=f
  for side=-1,1,2 do
   local inner=side*Config.GroundWidth/2
   -- Wall: base colour slab over the cliff, then alternating cells (offset by side so walls do not mirror).
   block(node,"Wall",Vector3.new(.2,L.CliffHeight,finish-start),CFrame.new(inner-side*.06,L.CliffHeight/2-1,-(start+finish)/2),theme.a).CastShadow=false
   local first=math.floor(start/cell)
   for i=first,math.ceil(finish/cell)-1 do for r=0,rows-1 do if (i+r+(if side>0 then 1 else 0))%2==0 then
    local z0=math.max(i*cell,start);local z1=math.min((i+1)*cell,finish)
    if z1>z0 then block(node,"Cell",Vector3.new(.3,cell,z1-z0),CFrame.new(inner-side*.12,cell/2+r*cell-1,-(z0+z1)/2),theme.b).CastShadow=false end
   end end end
   block(node,"Lip",Vector3.new(3,2,finish-start),CFrame.new(inner-side*.5,L.CliffHeight-.5,-(start+finish)/2),theme.lip)
   block(node,"Top",Vector3.new(L.CliffWidth,.2,finish-start),CFrame.new(side*(Config.GroundWidth/2+L.CliffWidth/2),L.CliffHeight+.1,-(start+finish)/2),theme.lip).CastShadow=false
   -- Rim dressing: one prop roughly every 30 studs, near the edge so it reads from the road.
   local z=start+rng:NextNumber(6,20)
   while z<finish-6 do
    rimProp(node,theme.rim,Vector3.new(inner+side*rng:NextNumber(7,24),L.CliffHeight+.2,-z),rng)
    z+=rng:NextNumber(24,38)
   end
  end
  task.wait()
 end
end
-- Plot dressing: wooden posts on the fence, blue front rails, a grass border.
function Decor.plot(folder: Instance,origin: Vector3)
 local f=Instance.new("Folder");f.Name="Decor";f.Parent=folder
 local wood=Color3.fromRGB(176,128,80)
 for _,n in {"FenceBack","FenceSide","FenceFront"}do for _,c in folder:GetChildren()do if c.Name==n then local p=c::BasePart;p.Transparency=1 end end end
 local function rail(a: Vector3,b: Vector3,color: Color3)
  local d=b-a;local len=d.Magnitude
  for _,y in {1.2,2.6}do block(f,"Rail",Vector3.new(.5,.5,len),CFrame.lookAt(a:Lerp(b,.5)+Vector3.new(0,y,0),b+Vector3.new(0,y,0)),color)end
  for t=0,math.floor(len/4)do block(f,"Post",Vector3.new(.8,3.4,.8),CFrame.new(a+d.Unit*math.min(t*4,len)+Vector3.new(0,1.7,0)),color)end
 end
 local x0,x1,z0,z1=origin.X-15,origin.X+15,origin.Z-20,origin.Z+20
 rail(Vector3.new(x0,0,z1),Vector3.new(x1,0,z1),wood)
 rail(Vector3.new(x0,0,z0),Vector3.new(x0,0,z1),wood);rail(Vector3.new(x1,0,z0),Vector3.new(x1,0,z1),wood)
 local blue=Color3.fromRGB(90,140,220)
 rail(Vector3.new(x0,0,z0),Vector3.new(origin.X-5,0,z0),blue);rail(Vector3.new(origin.X+5,0,z0),Vector3.new(x1,0,z0),blue)
end
return Decor

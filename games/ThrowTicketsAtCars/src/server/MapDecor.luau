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
 -- Cliffs: dirt blocks on the plaza faces and the first stretch of the tunnel walls, grass lip on top.
 local mouth=160 -- studs of tunnel wall dressed in the sample
 local cliffs=root:FindFirstChild("Cliffs")
 if cliffs then for _,c in cliffs:GetChildren()do if c.Name=="Cliff"then (c::BasePart).Color=DIRT_A elseif c.Name=="Grass"then (c::BasePart).Color=LIP end end end
 local cell=8;local rows=math.floor(L.CliffHeight/cell)
 for side=-1,1,2 do
  local inner=side*Config.GroundWidth/2
  -- Plaza-facing front face (z = 0), from the tunnel edge outward to the plaza edge.
  for i=0,math.floor((L.PlazaWidth/2-Config.GroundWidth/2)/cell)-1 do for r=0,rows-1 do if (i+r)%2==0 then
   block(f,"Dirt",Vector3.new(cell,cell,.3),CFrame.new(inner+side*(cell/2+i*cell),cell/2+r*cell-1,.12),DIRT_B).CastShadow=false
  end end end
  -- Tunnel inner wall near the mouth.
  for i=0,math.floor(mouth/cell)-1 do for r=0,rows-1 do if (i+r)%2==1 then
   block(f,"Dirt",Vector3.new(.3,cell,cell),CFrame.new(inner-side*.12,cell/2+r*cell-1,-cell/2-i*cell),DIRT_B).CastShadow=false
  end end end
  -- Overhanging grass lip along the tunnel rim and the plaza face.
  block(f,"Lip",Vector3.new(3,2,mouth),CFrame.new(inner-side*.5,L.CliffHeight-.5,-mouth/2),LIP)
  block(f,"Lip",Vector3.new(L.PlazaWidth/2-Config.GroundWidth/2+2,2,3),CFrame.new(side*(Config.GroundWidth/2+(L.PlazaWidth/2-Config.GroundWidth/2)/2),L.CliffHeight-.5,.5),LIP)
  -- Trees on the cliff tops, clustered near the rim so they read from the plaza and the throw line.
  for k=0,6 do
   local z=-8-k*rng:NextNumber(18,24);local x=inner+side*rng:NextNumber(8,26)
   tree(f,Vector3.new(x,L.CliffHeight,z),rng)
  end
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

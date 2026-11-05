--!strict
-- Primitive block models, LihFolk Vault V2: Parts Unions and MeshParts (CC BY 4.0).
-- Four authored samples; other families deliberately remain simpler draft blockouts.
local D={}
local dark=Color3.fromHex("242936");local chrome=Color3.fromHex("A4B3BE");local glass=Color3.fromHex("91C6D3")
function D.build(model: Model,origin: Vector3,car: any)
 local paint=car.Color;local kind=car.Kind;local name=car.Name
 local function p(id: string,size: Vector3,at: Vector3,color: Color3?,shape: any?,rotation: CFrame?): Part
  local o=Instance.new("Part");o.Name=id;o.Size=size;o.CFrame=CFrame.new(origin+at)*(rotation or CFrame.identity);o.Color=color or paint
  o.Shape=shape or Enum.PartType.Block;o.Material=Enum.Material.SmoothPlastic;o.Anchored=true;o.CanCollide=false;o.CanTouch=false;o.CanQuery=false;o.TopSurface=Enum.SurfaceType.Smooth;o.BottomSurface=Enum.SurfaceType.Smooth;o.Parent=model;return o
 end
 local function box(id,x,y,z,px,py,pz,color,rotation)return p(id,Vector3.new(x,y,z),Vector3.new(px,py,pz),color,nil,rotation)end
 local function ball(id,size,at,color)local o=p(id,size,at,color,Enum.PartType.Ball);return o end
 local function wheel(x: number,z: number,radius: number,y: number,tread: boolean?)
  p("Tire",Vector3.new(.85,radius*2,radius*2),Vector3.new(x,y,z),dark,Enum.PartType.Cylinder)
  p("WheelRim",Vector3.new(.9,radius*1.12,radius*1.12),Vector3.new(x,y,z),chrome,Enum.PartType.Cylinder)
  p("Hub",Vector3.new(.94,radius*.48,radius*.48),Vector3.new(x,y,z),paint,Enum.PartType.Cylinder)
  if tread then for i=0,7 do local a=i*math.pi/4;box("Tread",1.02,.32,.65,x,y+math.cos(a)*radius,z+math.sin(a)*radius,Color3.fromHex("343943"),CFrame.Angles(a,0,0))end end
 end
 local function wheels(width: number,length: number,radius: number,y: number,tread: boolean?)for _,x in {-width,width}do for _,z in {-length,length}do wheel(x,z,radius,y,tread)end end end
 local body=box("Body",5.6,2.5,7.6,0,0,0,dark);body.Transparency=1;model.PrimaryPart=body
 local windshield=p("Windshield",Vector3.new(4.5,1.25,.1),Vector3.new(0,1.3,1.8),glass);windshield.Material=Enum.Material.Glass;windshield.Transparency=.3
 local function cab(w,l,height: number?)
  box("Chassis",w,.6,l,0,-.35,0,dark);box("Bodywork",w,1,l,0,.1,0,paint)
  box("Cabin",w*.83,height or 1.45,l*.47,0,1.25,-.3,paint)
  for _,x in {-1,1}do local window=box("SideWindow",.08,1,l*.34,x*w*.423,1.35,-.3,glass);window.Transparency=.28 end
  box("Roof",w*.9,.22,l*.5,0,2.04,-.3,paint)
  windshield.Size=Vector3.new(w*.75,1,.12);windshield.Position=origin+Vector3.new(0,1.35,l*.21)
  for _,x in {-1,1}do box("Headlight",.9,.38,.12,x*w*.32,.15,l/2+.06,Color3.fromHex("FFF0B4"));box("TailLight",.8,.3,.12,x*w*.32,.2,-l/2-.06,Color3.fromHex("D7484A"))end
  box("Bumper",w+.2,.25,.25,0,-.25,l/2+.13,chrome);box("RearBumper",w+.2,.25,.25,0,-.25,-l/2-.13,chrome)
 end
 local function steering(at: Vector3)
  p("SteeringColumn",Vector3.new(.18,1.3,.18),at-Vector3.new(0,.5,0),dark,nil,CFrame.Angles(math.rad(28),0,0))
  p("SteeringWheel",Vector3.new(.16,1,1),at,dark,Enum.PartType.Cylinder,CFrame.Angles(0,0,math.pi/2)*CFrame.Angles(0,math.rad(30),0))
  p("SteeringInset",Vector3.new(.18,.66,.66),at,paint,Enum.PartType.Cylinder,CFrame.Angles(0,0,math.pi/2)*CFrame.Angles(0,math.rad(30),0))
  box("SteeringSpoke",.12,.12,.85,at.X,at.Y+.1,at.Z,chrome)
 end
 if name=="Couch Cruiser"then
  windshield.Transparency=1
  windshield.Position=origin+Vector3.new(0,.6,2.95)
  box("SofaBase",5.4,.7,5.8,0,-.05,0,paint)
  box("SofaBack",5.5,2.1,.85,0,1.3,-2.45,paint)
  for _,x in {-2.55,2.55}do box("RolledArm",.8,1.65,5.6,x,.85,0,paint);box("ArmPiping",.84,.08,5.65,x,1.65,0,Color3.fromHex("E28A9B"))end
  for _,x in {-1.53,0,1.53}do
   box("SeatCushion",1.43,.55,3.8,x,.55,.2,Color3.fromHex("C95D79"))
   box("BackCushion",1.43,1.35,.4,x,1.5,-1.86,Color3.fromHex("CA6680"))
   ball("TuftButton",Vector3.new(.15,.15,.12),Vector3.new(x,1.5,-1.62),Color3.fromHex("8E354E"))
  end
  box("FrontSeam",4.7,.07,.08,0,.55,2.15,Color3.fromHex("E28A9B"));steering(Vector3.new(1.1,1.65,1.9));wheels(2.3,1.85,.57,-.82)
 elseif name=="Grandma's Rocket"then
  cab(5.8,8.6);wheels(3,2.8,1.05,-.35)
  box("BenchSeat",4.5,.6,1.2,0,.85,-.5,Color3.fromHex("9E4851"));box("LaceCloth",2.4,.06,.9,0,1.1,1.5,Color3.fromHex("FFF4DD"))
  for i=-2,2 do box("LacePattern",.08,.07,.92,i*.4,1.15,1.5,Color3.fromHex("BCA887"))end
  for _,x in {-1.65,1.65}do
   p("RocketEngine",Vector3.new(2.7,1.25,1.25),Vector3.new(x,.85,-4.25),chrome,Enum.PartType.Cylinder,CFrame.Angles(0,math.pi/2,0))
   p("Nozzle",Vector3.new(.4,1.48,1.48),Vector3.new(x,.85,-5.65),dark,Enum.PartType.Cylinder,CFrame.Angles(0,math.pi/2,0))
   local fire=ball("RocketFlame",Vector3.new(.9,.9,2),Vector3.new(x,.85,-6.3),Color3.fromHex("FF9A37"));fire.Material=Enum.Material.Neon
   local core=ball("FlameCore",Vector3.new(.45,.45,1.6),Vector3.new(x,.85,-6.5),Color3.fromHex("FFE16A"));core.Material=Enum.Material.Neon
   box("EngineBrace",.3,.8,1.1,x,1.15,-3.6,dark)
  end
  steering(Vector3.new(1.2,1.35,.9));box("Grille",2.4,.4,.13,0,.12,4.38,dark)
 elseif name=="Monster Truck"then
  windshield.Position=origin+Vector3.new(0,2.7,1.2);windshield.Size=Vector3.new(3.5,1,.12)
  box("RaisedFrame",4.1,.55,6.5,0,1,0,dark);box("OrangeTruckBody",4.7,1.2,7,0,1.8,0,paint)
  box("Cabin",4.1,1.5,3.3,0,2.95,-.2,paint);box("Roof",4.45,.3,3.55,0,3.85,-.2,paint)
  for _,x in {-2.1,2.1}do box("SideWindow",.1,1.05,2.3,x,3,-.2,glass)end
  for _,z in {-2.3,2.3}do
   p("Axle",Vector3.new(6.5,.38,.38),Vector3.new(0,.3,z),chrome,Enum.PartType.Cylinder)
   for _,x in {-1.6,1.6}do box("YellowShock",.3,1.6,.3,x,.75,z,Color3.fromHex("F6CF3B"),CFrame.Angles(0,0,math.rad(x*16)))end
  end
  wheels(3.1,2.5,1.8,.4,true)
  box("FrontBullbar",5,.25,.3,0,1.35,3.7,chrome);box("HoodStripe",.8,.08,2.2,0,2.44,2.2,dark)
  for _,x in {-1.5,1.5}do box("Headlight",.8,.4,.14,x,1.9,3.56,Color3.fromHex("FFF0B4"))end
 elseif name=="UFO Car"then
  windshield.Transparency=1
  windshield.Position=origin+Vector3.new(0,.75,4.45)
  p("SaucerLower",Vector3.new(.65,7,7),Vector3.new(0,.1,0),dark,Enum.PartType.Cylinder,CFrame.Angles(0,0,math.pi/2))
  p("SilverSaucer",Vector3.new(.85,8.6,8.6),Vector3.new(0,.65,0),paint,Enum.PartType.Cylinder,CFrame.Angles(0,0,math.pi/2))
  p("SaucerLip",Vector3.new(.18,9,9),Vector3.new(0,.72,0),chrome,Enum.PartType.Cylinder,CFrame.Angles(0,0,math.pi/2))
  local dome=ball("GlassDome",Vector3.new(4.3,3.4,4.3),Vector3.new(0,1.6,0),glass);dome.Material=Enum.Material.Glass;dome.Transparency=.48
  ball("AlienHead",Vector3.new(1.3,1.5,1.1),Vector3.new(0,1.85,.1),Color3.fromHex("83CE69"))
  for _,x in {-.34,.34}do ball("AlienEye",Vector3.new(.34,.52,.15),Vector3.new(x,2,.63),dark)end
  for i=0,9 do local a=i*math.pi/5;local lamp=ball("RimLamp",Vector3.new(.45,.2,.45),Vector3.new(math.cos(a)*3.65,1.16,math.sin(a)*3.65),if i%2==0 then Color3.fromHex("91FFB8")else Color3.fromHex("B59BFF"));lamp.Material=Enum.Material.Neon end
  wheels(2.6,2.4,.7,-.7)
 else
  -- Draft families: distinct silhouettes and one simple signature detail, not the approved series.
  local long=kind=="bus"or kind=="limo"or kind=="rig";local l=if long then 11.8 elseif kind=="kart"then 5.6 else 8
  if kind=="couch"then l=6 end
  cab(if kind=="wedge"or kind=="formula"then 5.7 else 5.4,l)
  if kind=="wedge"or kind=="coupe"or kind=="formula"or kind=="dragster"then
   model.Cabin.Size*=Vector3.new(1,.65,1);model.Roof.Position-=Vector3.new(0,.5,0);windshield.Size*=Vector3.new(1,.7,1)
   box("Spoiler",6,.2,.8,0,1.4,-l/2+.4,dark)
  end
  if kind=="pod"then wheels(2.2,2.2,.35,-.8);for _,x in {-2.7,2.7}do local o=box("LiftPad",.3,.2,5,x,-.8,0,Color3.fromHex("78EEEF"));o.Material=Enum.Material.Neon end
  elseif kind=="monster"then wheels(3.2,2.6,1.65,.25)
  elseif kind=="tractor"or kind=="combine"then for _,x in {-2.9,2.9}do wheel(x,-2,1.5,.1);wheel(x,2.8,.75,-.65)end
  elseif kind=="trike"or kind=="snowmobile"then wheel(0,2.4,.85,-.55);for _,x in {-2.3,2.3}do wheel(x,-2.4,.85,-.55)end
  else wheels(2.8,if long then 4.2 else 2.55,1,-.4)end
  if kind=="van"or kind=="truck"or kind=="camper"or kind=="bus"or kind=="rig"or kind=="coop"then
   box("TallBox",5.3,2.4,if long then 7.5 else 4.5,0,1.8,-1.1,paint)
   for _,x in {-2.7,2.7}do for z=-2,1,1.5 do box("BoxWindow",.08,.8,1.1,x,2.15,z,glass)end end
  end
  if kind=="pickup"or kind=="wagon"then box("CargoBed",4.3,.65,3.1,0,.9,-2,Color3.fromHex("6B543C"))end
  if kind=="tractor"or kind=="combine"then box("EngineHood",2.8,1.4,3,0,1.2,2,paint);box("Exhaust",.3,2,.3,1.2,2.2,1,dark)end
  if kind=="combine"then box("CuttingHeader",8.8,.7,1,0,-.1,4.5,chrome);for x=-4,4 do box("CutterTooth",.3,.5,.7,x,-.2,5,dark)end end
  if kind=="tank"then for _,x in {-2.6,2.6}do box("Track",1.5,1.4,8,x,-.3,0,dark)end end
  if kind=="cart"then
   model.Cabin.Transparency=1;model.Roof.Transparency=1;windshield.Transparency=1
   for _,x in {-2.6,2.6}do for z=-2,2 do box("BasketBar",.12,2.2,.12,x,1.35,z,chrome)end end
   for _,y in {.4,1.2,2.2}do box("BasketRim",5.3,.12,.12,0,y,2.4,chrome);box("BasketRim",5.3,.12,.12,0,y,-2.4,chrome)end
   box("Engine",2,1.2,1.4,0,.4,-3.2,dark);box("CartSpoiler",6,.2,.7,0,2.5,-3,paint)
  end
  if kind=="yacht"then box("BoatDeck",6.5,.35,10,0,1.3,0,Color3.fromHex("EEE2BD"));box("Flybridge",3.5,.4,3,0,3,0,chrome);box("Mast",.2,3,.2,0,3.4,-1,chrome)end
  if kind=="blimp"then ball("Airship",Vector3.new(5,3,9),Vector3.new(0,4,0),paint);box("AirshipStrut",.2,2,.2,0,2.6,0,dark)end
  if kind=="gondola"then box("LiftHook",.4,2,.4,0,3,0,chrome)end
  if kind=="igloo"then for i=0,5 do local a=i*math.pi/3;box("IceBlock",1.3,1.3,1.3,math.cos(a)*1.5,2.5,math.sin(a)*1.5,Color3.fromHex("CEEFFF"))end;ball("IglooCap",Vector3.new(2.8,1.8,2.8),Vector3.new(0,3,0),glass)end
  if kind=="yeti"or kind=="penguin"then
   ball("CharacterBody",Vector3.new(5.3,3.5,6),Vector3.new(0,1.8,0),paint)
   for _,x in {-1,1}do ball("EyeWhite",Vector3.new(.7,.7,.2),Vector3.new(x,2.6,3),Color3.new(1,1,1));ball("Eye",Vector3.new(.3,.4,.22),Vector3.new(x,2.6,3.12),dark)end
   if kind=="penguin"then ball("WhiteBelly",Vector3.new(3.7,2.4,.35),Vector3.new(0,1.25,3),Color3.new(1,1,1));box("Beak",1.2,.45,.8,0,2.1,3.3,Color3.fromHex("FFC04F"))end
  end
  if kind=="mech"then for _,x in {-3,3}do for _,z in {-2.4,2.4}do box("RobotLeg",.6,2.2,.6,x,-.2,z,chrome);box("RobotFoot",1.4,.3,1.6,x,-1.25,z,dark)end end end
  if kind=="portal"then for i=0,11 do local a=i*math.pi/6;local o=box("PortalSegment",.6,.9,.4,math.cos(a)*2.4,1.5+math.sin(a)*2.4,-4.4,Color3.fromHex("9B74F4"),CFrame.Angles(0,0,a));o.Material=Enum.Material.Neon end end
  if kind=="rocket"or kind=="jet"then p("JetEngine",Vector3.new(3,1.7,1.7),Vector3.new(0,.9,-4),chrome,Enum.PartType.Cylinder,CFrame.Angles(0,math.pi/2,0));local fire=ball("Flame",Vector3.new(1,1,2),Vector3.new(0,.9,-5.9),Color3.fromHex("FFAD45"));fire.Material=Enum.Material.Neon end
  if kind=="shark"then local fin=box("SharkFin",.3,2,2,0,3,0,paint);fin.CFrame*=CFrame.Angles(math.rad(20),0,0);for _,x in {-2.8,2.8}do box("SideFin",1.6,.25,2,x,.5,0,paint)end end
  -- Low-cost one-piece visual punchlines for the remaining draft entries.
  if name:find("Pizza")then local pizza=p("PizzaRoof",Vector3.new(.35,6.2,6.2),Vector3.new(0,2.5,0),Color3.fromHex("E3B85C"),Enum.PartType.Cylinder,CFrame.Angles(0,0,math.pi/2));for _,x in {-1.5,0,1.5}do ball("Pepperoni",Vector3.new(.65,.12,.65),Vector3.new(x,2.72,.6),Color3.fromHex("C84C3F"))end end
  if name:find("Ice Cream")then p("Cone",Vector3.new(.9,1.8,.9),Vector3.new(0,3.5,0),Color3.fromHex("CFA56C"));ball("IceCream",Vector3.new(2,2,2),Vector3.new(0,4.5,0),Color3.fromHex("F6CADF"))end
  if name=="Food Truck"then ball("HotDog",Vector3.new(1.6,.9,3.5),Vector3.new(0,3.5,0),Color3.fromHex("D69757"));ball("Sausage",Vector3.new(.8,.6,3.8),Vector3.new(0,4,0),Color3.fromHex("BD5441"))end
  if name:find("Hay")or name=="Muddy Pickup"then for _,x in {-1.2,1.2}do box("HayBale",2,1.4,2.4,x,1.5,-2,Color3.fromHex("D9BE66"))end end
  if name=="Chicken Coop Racer"then box("CoopRoof",6,.35,6.5,0,3.25,-1,Color3.fromHex("873F35"));ball("Chicken",Vector3.new(.7,.8,.7),Vector3.new(2.75,2.2,-1),Color3.new(1,1,1))end
  if name=="Cow Car"then for _,x in {-2.5,2.5}do box("CowPatch",.1,.75,1.4,x,.5,-1,dark);box("Horn",.3,.8,.3,x*.55,1.3,3,Color3.fromHex("ECE0B8"))end end
  if name:find("Cactus")then for _,x in {-3,3}do box("CactusMirror",.5,1.6,.5,x,1.8,1,Color3.fromHex("328850"))end end
  if name=="Snow Plow"then box("PlowBlade",7,1.3,.4,0,-.1,4.5,chrome,CFrame.Angles(math.rad(-18),0,0))end
  if name=="Wing Door GT"then for _,x in {-2.6,2.6}do box("WingDoor",.3,3,2.8,x,2.6,0,paint,CFrame.Angles(0,0,math.rad(x*12)))end end
  if name:find("Golden")or name=="Scrap King"or name=="Champion GT"then box("RoofPrize",1.4,1,.9,0,2.7,0,Color3.fromHex("F6D15B"))end
  if name=="Pool Party Convertible"then ball("FlamingoBody",Vector3.new(1.5,1,2),Vector3.new(0,2.9,-1),Color3.fromHex("F18CB3"));box("FlamingoNeck",.35,1.8,.35,.6,3.8,-.4,Color3.fromHex("F18CB3"))end
  if name=="Money Printer Car"then box("Printer",2.5,1.2,1.8,0,2.6,-1,chrome);for i=1,3 do box("Banknote",1.3,.06,.65,0,2.6+i*.4,-2.2-i*.35,Color3.fromHex("A0D48B"))end end
  if kind=="taxi"then box("TaxiSign",1.8,.65,.5,0,2.5,0,Color3.fromHex("FFE489"))end
  if name=="Cop Cruiser"then box("RedBeacon",1.4,.4,.7,-.85,2.4,0,Color3.fromHex("F25259"));box("BlueBeacon",1.4,.4,.7,.85,2.4,0,Color3.fromHex("539AF5"))end
  if name:find("Neon")or name:find("Laser")or name:find("Lightning")or name=="Infinity Hyper"then for i=1,3 do local o=box("EnergyStripe",.14,.14,6,-2+i,2.2,0,Color3.fromHSV(i/3,.65,1));o.Material=Enum.Material.Neon end end
  if name=="Hologram Coupe"or name=="Ice Crystal Coupe"then for _,o in model:GetChildren()do if o:IsA("BasePart")and o~=body then o.Transparency=.4;o.Material=Enum.Material.Glass end end end
 end
end
return D

--!strict
-- Rusty Sedan v2: the same ONE sample, more readable damage, primitive parts only.
local Sedan={}
function Sedan.decorate(model: Model,part: any,position: Vector3)
 local rust=Color3.fromRGB(139,65,33);local orange=Color3.fromRGB(207,107,43)
 local faded=Color3.fromRGB(109,139,129)
 local body=model.Body::Part;body.Size=Vector3.new(5.7,1.6,8.8);body.Color=faded
 local roof=model.Roof::Part;roof.Size=Vector3.new(5.2,1.4,4.3);roof.Color=roof.Color:Lerp(faded,.25)
 local function panel(name: string,size: Vector3,offset: Vector3,color: Color3): Part
  local p=part(model,name,size,position+offset,color);p.Material=Enum.Material.Concrete;p.Reflectance=0;return p
 end
 panel("CabinBase",Vector3.new(5.6,.9,4.4),Vector3.new(0,1.1,0),faded)
 panel("LeftFender",Vector3.new(.7,1.6,8.8),Vector3.new(-3.05,0,0),faded)
 panel("RightRearFender",Vector3.new(.7,1.6,5.5),Vector3.new(3.05,0,-1.65),faded)
 local dent=panel("DentedFender",Vector3.new(.35,1.25,2.8),Vector3.new(2.78,-.05,3),rust)
 dent.CFrame*=CFrame.Angles(0,math.rad(-18),math.rad(10))
 local crease=panel("DentCrease",Vector3.new(.12,.18,1.8),Vector3.new(2.98,.32,2.9),Color3.fromRGB(61,57,45));crease.CFrame*=CFrame.Angles(0,math.rad(-18),math.rad(12))
 local door=panel("MismatchedDoor",Vector3.new(.13,1.5,2.7),Vector3.new(3.43,.12,-.35),Color3.fromRGB(196,170,73))
 panel("DoorHandle",Vector3.new(.15,.16,.55),Vector3.new(3.53,.45,-1.05),Color3.fromRGB(61,65,65))
 for _,x in {-3.35,3.35}do
  for _,z in {-2.65,2.65}do
   local wheel=part(model,"Wheel",Vector3.new(1,2.4,2.4),position+Vector3.new(x,-.2,z),Color3.fromRGB(31,32,37));wheel.Shape=Enum.PartType.Cylinder
   local hub=panel("Hub",Vector3.new(1.04,1.05,1.05),Vector3.new(x,-.2,z),if x>0 and z>0 then rust else Color3.fromRGB(111,109,102));hub.Shape=Enum.PartType.Cylinder
  end
  part(model,"SideWindow",Vector3.new(.08,1.1,3.9),position+Vector3.new(x/3.35*2.66,1.8,0),Color3.fromRGB(93,120,135))
  local mirror=panel("Mirror",Vector3.new(.7,.5,.7),Vector3.new(x/3.35*3.5,1.1,1.65),faded)
  if x>0 then mirror.CFrame*=CFrame.Angles(0,0,math.rad(28))end
 end
 part(model,"RearWindow",Vector3.new(5,1.1,.1),position+Vector3.new(0,1.8,-2.21),Color3.fromRGB(93,120,135))
 for _,z in {-4.55,4.55}do
  local bumper=panel(if z>0 then "CrookedBumper"else "RearBumper",Vector3.new(6.7,.5,.4),Vector3.new(if z>0 then -.25 else 0,-.25,z),Color3.fromRGB(94,76,53))
  if z>0 then bumper.CFrame*=CFrame.Angles(0,math.rad(6),math.rad(-10))end
  for _,x in {-2.25,2.25}do
   part(model,if z>0 then "Headlight"else "TailLight",Vector3.new(1.1,.6,.12),position+Vector3.new(x,.3,z),if z<0 then Color3.fromRGB(141,43,35)elseif x>0 then Color3.fromRGB(63,61,49)else Color3.fromRGB(239,204,111))
  end
 end
 panel("Grille",Vector3.new(2.5,.5,.12),Vector3.new(0,.25,4.48),Color3.fromRGB(40,47,49))
 local hood=panel("RustHood",Vector3.new(5,.13,2.2),Vector3.new(-.15,.85,3.15),orange);hood.CFrame*=CFrame.Angles(math.rad(3),math.rad(-4),0)
 panel("RustHoodDark",Vector3.new(2,.06,1.1),Vector3.new(-1.1,.96,3.45),rust)
 panel("RustRoof",Vector3.new(3.3,.08,2.8),Vector3.new(-.55,2.58,-.15),orange)
 panel("RustRoofDark",Vector3.new(1.5,.09,1.5),Vector3.new(.8,2.59,.7),rust)
 panel("RustDoor",Vector3.new(.15,.6,1.4),Vector3.new(3.46,-.29,.15),rust)
 panel("RustTrunk",Vector3.new(4,.08,1.9),Vector3.new(.3,.85,-3.3),rust)
 for _,p in model:GetChildren()do if p:IsA("BasePart")then p.Reflectance=0;if p.Name=="Body"or p.Name=="Roof"then p.Material=Enum.Material.Concrete end end end
 model:SetAttribute("SampleDesign","Rusty Sedan v2 — NOT FINAL")
end
return Sedan

--!strict
-- ONE sample design, built entirely from primitive parts. No uploads or brands.
local Sedan={}
function Sedan.decorate(model: Model,part: any,position: Vector3)
	local rust=Color3.fromRGB(166,86,48)
	local body=model.Body::Part;body.Size=Vector3.new(6.5,1.6,8.8);body.Color=Color3.fromRGB(116,151,142)
	local roof=model.Roof::Part;roof.Size=Vector3.new(5.2,1.4,4.3)
	part(model,"CabinBase",Vector3.new(5.6,0.9,4.4),position+Vector3.new(0,1.1,0),body.Color)
	for _,x in {-3.35,3.35}do
		for _,z in {-2.65,2.65}do
			local wheel=part(model,"Wheel",Vector3.new(1,2.4,2.4),position+Vector3.new(x,-0.2,z),Color3.fromRGB(31,32,37))
			wheel.Shape=Enum.PartType.Cylinder
			local hub=part(model,"Hub",Vector3.new(1.04,1.05,1.05),wheel.Position,Color3.fromRGB(137,135,128));hub.Shape=Enum.PartType.Cylinder
		end
		part(model,"SideWindow",Vector3.new(0.08,1.1,3.9),position+Vector3.new(x/3.35*2.66,1.8,0),Color3.fromRGB(93,136,157))
		part(model,"DoorSeam",Vector3.new(.09,1.8,.08),position+Vector3.new(x/3.35*3.28,.25,-.3),Color3.fromRGB(60,80,76))
		part(model,"Mirror",Vector3.new(.7,.5,.7),position+Vector3.new(x/3.35*3.5,1.1,1.65),body.Color)
	end
	part(model,"RearWindow",Vector3.new(5,1.1,.1),position+Vector3.new(0,1.8,-2.21),Color3.fromRGB(93,136,157))
	for _,z in {-4.55,4.55}do
		part(model,"Bumper",Vector3.new(6.7,.5,.4),position+Vector3.new(0,-.25,z),Color3.fromRGB(92,88,77))
		for _,x in {-2.25,2.25}do part(model,if z>0 then "Headlight"else "TailLight",Vector3.new(1.1,.6,.12),position+Vector3.new(x,.3,z),if z>0 then Color3.fromRGB(255,221,137)else Color3.fromRGB(166,44,39))end
	end
	part(model,"Grille",Vector3.new(2.5,.5,.12),position+Vector3.new(0,.25,4.48),Color3.fromRGB(40,47,49))
	part(model,"RustHood",Vector3.new(2.5,.06,1.4),position+Vector3.new(-1,.83,3.35),rust)
	part(model,"RustDoor",Vector3.new(.08,.65,1.5),position+Vector3.new(3.29,.25,.7),rust)
	part(model,"RustTrunk",Vector3.new(1.4,.06,1),position+Vector3.new(1.3,.83,-3.3),rust)
	model:SetAttribute("SampleDesign","Rusty Sedan v1 — NOT FINAL")
end
return Sedan

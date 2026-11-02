--!strict
local Config=require(script.Parent.Config)
local RustySedan=require(script.Parent.RustySedan)
local Builder={}
function Builder.part(parent: Instance,name: string,size: Vector3,position: Vector3,color: Color3): Part
	local p=Instance.new("Part")
	p.Name,p.Size,p.Position=name,size,position
	p.Anchored,p.Material,p.Color=true,Enum.Material.SmoothPlastic,color
	p.TopSurface,p.BottomSurface=Enum.SurfaceType.Smooth,Enum.SurfaceType.Smooth
	p.Parent=parent
	return p
end
function Builder.create(parent: Instance,name: string,reward: any,position: Vector3): Model
	local m=Instance.new("Model");m.Name=name;m.ModelStreamingMode=Enum.ModelStreamingMode.Persistent
	local body=Builder.part(m,"Body",Config.CarSize,position,Color3.fromRGB(145,145,145))
	Builder.part(m,"Roof",Config.RoofSize,position+Vector3.new(0,Config.RoofOffset,0),Config.Rarities[reward.Rarity].Color)
	local glass=Builder.part(m,"Windshield",Config.WindshieldSize,position+Vector3.new(0,Config.RoofOffset,Config.WindshieldFront),Color3.fromRGB(135,157,170))
	glass.Material=Enum.Material.Glass
	if reward.Name=="Rusty Sedan"then RustySedan.decorate(m,Builder.part,position)end
	for _,p in m:GetChildren() do if p:IsA("BasePart") then p.CanCollide,p.CanTouch,p.CanQuery=false,false,false end end
	m.PrimaryPart=body
	m:SetAttribute("CarName",reward.Name);m:SetAttribute("Rarity",reward.Rarity);m:SetAttribute("Biome",reward.Biome);m:SetAttribute("Income",reward.Income)
	m.Parent=parent
	return m
end
return Builder

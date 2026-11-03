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
	local style=reward.Style or 1
	for _,c in Config.Biomes[reward.Biome or 1].Cars do if c.Id==reward.CatalogId then style=c.Style;break end end
	local tint=Config.Biomes[reward.Biome or 1].Color:Lerp(Color3.fromRGB(112+style*10,121+style*7,132+style*6),.68)
	local body=Builder.part(m,"Body",Config.CarSize*Vector3.new(.86+style*.02,.86+(style%3)*.08,.85+style*.022),position,tint)
	Builder.part(m,"Roof",Config.RoofSize*Vector3.new(.83+(style%4)*.055,1,.84+(style%4)*.06),position+Vector3.new(0,Config.RoofOffset,0),Config.Rarities[reward.Rarity].Color)
	local glass=Builder.part(m,"Windshield",Config.WindshieldSize,position+Vector3.new(0,Config.RoofOffset,Config.WindshieldFront),Color3.fromRGB(135,157,170))
	glass.Material=Enum.Material.Glass
	if reward.Name=="Rusty Hatch"or reward.Name=="Rusty Sedan"then RustySedan.decorate(m,Builder.part,position)end
	for _,p in m:GetChildren() do if p:IsA("BasePart") then p.CanCollide,p.CanTouch,p.CanQuery=false,false,false end end
	m.PrimaryPart=body
	local variant=reward.Variant
	if variant and variant~="Normal" then
	 local color=if variant=="Gold"then Color3.fromRGB(255,188,45)elseif variant=="Diamond"then Color3.fromRGB(124,224,255)else Color3.fromRGB(98,255,146)
	 for _,part in m:GetChildren()do if part:IsA("BasePart")and part~=glass then part.Color=color;part.Material=if variant=="Neon"then Enum.Material.Neon else Enum.Material.Metal;part.Reflectance=if variant=="Diamond"then .23 else .08 end end
	end
	m:SetAttribute("CarName",reward.Name);m:SetAttribute("Rarity",reward.Rarity);m:SetAttribute("Biome",reward.Biome);m:SetAttribute("Income",reward.Income)
	m.Parent=parent
	return m
end
return Builder

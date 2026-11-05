--!strict
local Config=require(script.Parent.Config)
local Design=require(script.Parent.VehicleDesign)
local Builder={}
function Builder.ticketOffset(model: Model): Vector3
 local windshield=model:FindFirstChild("Windshield")::BasePart
 assert(windshield and model.PrimaryPart,"Vehicle transport anchors required")
 return windshield.Position-model.PrimaryPart.Position
end
function Builder.part(parent: Instance,name: string,size: Vector3,position: Vector3,color: Color3): Part
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=position;p.Color=color;p.Anchored=true;p.Material=Enum.Material.SmoothPlastic;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
function Builder.create(parent: Instance,name: string,reward: any,position: Vector3): Model
 local biome=Config.Biomes[reward.Biome or 1];local car=biome.Cars[1]
 for _,candidate in biome.Cars do if candidate.Id==reward.CatalogId or candidate.Name==reward.Name then car=candidate;break end end
 local m=Instance.new("Model");m.Name=name;m.ModelStreamingMode=Enum.ModelStreamingMode.Persistent
 Design.build(m,position,car)
 if reward.Variant and reward.Variant~="Normal"then
  local tint=if reward.Variant=="Gold"then Color3.fromHex("FFBC2D")elseif reward.Variant=="Diamond"then Color3.fromHex("7CE0FF")else Color3.fromHex("62FF92")
  for _,part in m:GetChildren()do if part:IsA("BasePart")and part.Material~=Enum.Material.Glass and part.Name~="Tire"and part.Name~="Tread"and part.Name~="Body"then
   part.Color=tint;part.Material=if reward.Variant=="Neon"then Enum.Material.Neon else Enum.Material.Metal;part.Reflectance=if reward.Variant=="Diamond"then .2 else .06
  end end
 end
 m:SetAttribute("CarName",car.Name);m:SetAttribute("CatalogId",car.Id);m:SetAttribute("Rarity",car.Rarity);m:SetAttribute("Biome",reward.Biome);m:SetAttribute("Income",reward.Income);m:SetAttribute("Draft",true)
 m.Parent=parent;return m
end
return Builder

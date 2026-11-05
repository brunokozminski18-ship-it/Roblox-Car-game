--!strict
local Builder=require(game.ReplicatedStorage.ThrowTickets.CarBuilder)
local Preview={}
function Preview.mount(parent: Instance,car: any,silhouette: boolean?): ViewportFrame
 local v=Instance.new("ViewportFrame");v.Name="CarPreview";v.Size=UDim2.fromScale(1,1);v.BackgroundTransparency=1
 v.Ambient=Color3.new(.8,.8,.8);v.LightColor=Color3.new(1,1,1);v.LightDirection=Vector3.new(-1,-2,-3);v.Parent=parent
 local world=Instance.new("WorldModel");world.Parent=v
 local model=Builder.create(world,"Car",car,Vector3.zero)
 if silhouette then
  v.Ambient=Color3.new();v.LightColor=Color3.new()
  for _,part in model:GetDescendants()do if part:IsA("BasePart")and part.Transparency<1 then part.Color=Color3.new();part.Material=Enum.Material.SmoothPlastic;part.Reflectance=0;part.Transparency=0 end end
 end
 local cf,size=model:GetBoundingBox();local camera=Instance.new("Camera");camera.FieldOfView=35
 camera.CFrame=CFrame.lookAt(cf.Position+Vector3.new(1,.65,1.25)*size.Magnitude,cf.Position);camera.Parent=v;v.CurrentCamera=camera
 return v
end
return Preview

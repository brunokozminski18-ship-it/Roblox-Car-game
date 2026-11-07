-- Read-only. Run pages 1-3, 4-6, ... 19-19 per variant; keep responses below MCP truncation.
local variant, firstIndex, lastIndex = "Normal", 1, 3
local Http=game:GetService("HttpService")
local function vec(v) return {v.X,v.Y,v.Z} end
local function cf(c) return {c:GetComponents()} end
local function color(c) return string.format("#%02X%02X%02X",math.round(c.R*255),math.round(c.G*255),math.round(c.B*255)) end
local folder=workspace.Cars:FindFirstChild(variant)
local models={}
local sorted=folder:GetChildren();table.sort(sorted,function(a,b)return a.Name<b.Name end)
for idx,m in sorted do
if idx < firstIndex or idx > lastIndex then continue end
 if m:IsA("Model") then
 local row={name=m.Name,path=m:GetFullName(),pivot=cf(m:GetPivot()),primary=m.PrimaryPart and m.PrimaryPart.Name or false,parts={},hierarchy={},effects={}}
 for _,d in m:GetDescendants() do
  table.insert(row.hierarchy,{path=d:GetFullName():sub(#m:GetFullName()+2),class=d.ClassName})
  if d:IsA("BasePart") then
   local p={name=d.Name,path=d:GetFullName():sub(#m:GetFullName()+2),class=d.ClassName,size=vec(d.Size),cframe=cf(d.CFrame),color=color(d.Color),material=d.Material.Name,variant=d.MaterialVariant,transparency=d.Transparency,reflectance=d.Reflectance,anchored=d.Anchored,collide=d.CanCollide,query=d.CanQuery,touch=d.CanTouch,shadow=d.CastShadow,pivot=cf(d.PivotOffset)}
   if d:IsA("MeshPart") then p.mesh=d.MeshId;p.texture=d.TextureID;p.meshSize=vec(d.MeshSize);p.collision=d.CollisionFidelity.Name;p.render=d.RenderFidelity.Name;p.doubleSided=d.DoubleSided end
   table.insert(row.parts,p)
  elseif d:IsA("ParticleEmitter") then table.insert(row.effects,{path=d:GetFullName(),class=d.ClassName,texture=d.Texture,rate=d.Rate,enabled=d.Enabled})
  elseif d:IsA("SurfaceAppearance") then table.insert(row.effects,{path=d:GetFullName(),class=d.ClassName,colorMap=d.ColorMap,normal=d.NormalMap})
  elseif d:IsA("SpecialMesh") then table.insert(row.effects,{path=d:GetFullName(),class=d.ClassName,mesh=d.MeshId,texture=d.TextureId,scale=vec(d.Scale)})
  end
 end
 table.sort(row.parts,function(a,b)return a.path<b.path end)
 table.sort(row.hierarchy,function(a,b)return a.path<b.path end)
 table.insert(models,row)
 end
 task.wait()
end
table.sort(models,function(a,b)return a.name<b.name end)
return Http:JSONEncode({variant=variant,models=models})

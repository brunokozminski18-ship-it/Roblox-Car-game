local function n(v) if math.abs(v)<.000005 then return "0.00000" end return string.format("%.5f",v) end
local function hash(rows) table.sort(rows) local h=5381 for _,s in rows do for i=1,#s do h=(h*33+string.byte(s,i))%4294967296 end h=(h*33+10)%4294967296 end return h end
local function vec(t,v) table.insert(t,n(v.X));table.insert(t,n(v.Y));table.insert(t,n(v.Z)) end
local function cf(t,v) for _,k in {v:GetComponents()} do table.insert(t,n(k)) end end
local function color(c) return string.format("#%02X%02X%02X",math.round(c.R*255),math.round(c.G*255),math.round(c.B*255)) end
local r={}
for _,f in workspace.Cars:GetChildren() do if not f:IsA('Folder') then continue end for _,m in f:GetChildren() do if not m:IsA('Model') then continue end local parts,tree={},{} for _,d in m:GetDescendants() do
 table.insert(tree,d.ClassName.."|"..d:GetFullName():sub(#m:GetFullName()+2))
 if d:IsA('BasePart') then local mesh=d:IsA('MeshPart')
 local t={d.Name,d.ClassName,d.Material.Name,d.MaterialVariant,color(d.Color),mesh and d.MeshId or "",mesh and d.TextureID or "",mesh and d.RenderFidelity.Name or "",mesh and d.CollisionFidelity.Name or "",tostring(d.Anchored),tostring(d.CanCollide),tostring(d.CanQuery),tostring(d.CanTouch),tostring(d.CastShadow),mesh and tostring(d.DoubleSided) or "",n(d.Transparency),n(d.Reflectance)}
 vec(t,d.Size);cf(t,d.CFrame);cf(t,d.PivotOffset);if mesh then vec(t,d.MeshSize) end table.insert(parts,table.concat(t,"|"))
 end end r[f.Name.."/"..m.Name]={parts=hash(parts),hierarchy=hash(tree)} task.wait() end end return game:GetService('HttpService'):JSONEncode(r)

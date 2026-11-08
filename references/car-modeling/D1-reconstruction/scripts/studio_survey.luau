-- Studio Edit optical measurement helpers, 1406 x 650 viewport, 4 degree vertical FOV.
-- The source D1 remains read-only. The separate display is removed at the end.
local function lightBegin()
local L=game:GetService("Lighting")
assert(not _G.D1Fog,"Already measuring") local old={} for _,k in {"FogStart","FogEnd","FogColor","Ambient","OutdoorAmbient","Brightness","EnvironmentDiffuseScale","EnvironmentSpecularScale","GlobalShadows","ExposureCompensation"} do old[k]=L[k] end
local effects={} local hold=Instance.new("Folder",game.ServerStorage);hold.Name="_D1OpticalLightingHold" for _,v in L:GetChildren() do if v:IsA("Atmosphere") or v:IsA("PostEffect") then table.insert(effects,v);v.Parent=hold end end
_G.D1Fog={old=old,effects=effects,hold=hold};L.FogStart=500;L.FogEnd=540;L.FogColor=Color3.new(0,0,0);L.Ambient=Color3.new(1,1,1);L.OutdoorAmbient=Color3.new(1,1,1);L.Brightness=0;L.EnvironmentDiffuseScale=0;L.EnvironmentSpecularScale=0;L.GlobalShadows=false;L.ExposureCompensation=0;return #effects
end
local function lightEnd()
local L=game:GetService("Lighting") if _G.D1Fog then for k,v in _G.D1Fog.old do L[k]=v end for _,v in _G.D1Fog.effects do v.Parent=L end _G.D1Fog.hold:Destroy();_G.D1Fog=nil end return "restored"
end
local function whiteSurvey(index)
local idx=index local p=workspace.Cars.Normal.D1:GetChildren()[idx] local base=Vector3.new(320,460,360) local rig=workspace._D1OpticalBench;rig:ClearAllChildren()
local L=game.Lighting;L.FogStart=512;L.FogEnd=528
local function cube(size,pos,color) local o=Instance.new("Part");o.Anchored=true;o.CastShadow=false;o.Size=size;o.Color=color;o.Material=Enum.Material.SmoothPlastic;o.CFrame=CFrame.new(base+pos);o.Parent=rig;return o end
cube(Vector3.new(150,85,.2),Vector3.new(0,0,-17),Color3.new(0,0,0))
local rots={} local dirs={Vector3.yAxis,Vector3.xAxis,-Vector3.zAxis,Vector3.zAxis,-Vector3.xAxis,-Vector3.yAxis}
for j,d in dirs do local r=CFrame.lookAt(Vector3.zero,-d,math.abs(d.Y)>.99 and Vector3.zAxis or Vector3.yAxis):Inverse()
local o=cube(Vector3.one,Vector3.new(((j-1)%3-1)*23,(.5-math.floor((j-1)/3))*16.4+.7,0),Color3.new(1,1,1));o.CFrame=o.CFrame*r*p.CFrame.Rotation
local m=Instance.new("SpecialMesh");m.MeshType=Enum.MeshType.FileMesh;m.MeshId=p.MeshId;m.Scale=Vector3.one*13.2/p.MeshSize;m.Parent=o;table.insert(rots,{r:GetComponents()}) end
for k=0,60 do local z=(k/60-.5)*15.0;local scale=(520-z)/520;cube(Vector3.new(.95*scale,1.4*scale,.02),Vector3.new((k-30)*1.05*scale,-17.0*scale,z-.01),Color3.new(1,1,1)) end
return "ready"
end
local function blackSurvey(index)
local idx=index local p=workspace.Cars.Normal.D1:GetChildren()[idx] local base=Vector3.new(320,460,360) local rig=workspace._D1OpticalBench;rig:ClearAllChildren()
local L=game.Lighting;L.FogColor=Color3.new(1,1,1);L.FogStart=512;L.FogEnd=528
local function cube(size,pos,color) local o=Instance.new("Part");o.Anchored=true;o.CastShadow=false;o.Size=size;o.Color=color;o.Material=Enum.Material.SmoothPlastic;o.CFrame=CFrame.new(base+pos);o.Parent=rig;return o end
cube(Vector3.new(150,85,.2),Vector3.new(0,0,-17),Color3.new(0,0,0))
local rots={} local dirs={Vector3.yAxis,Vector3.xAxis,-Vector3.zAxis,Vector3.zAxis,-Vector3.xAxis,-Vector3.yAxis}
for j,d in dirs do local r=CFrame.lookAt(Vector3.zero,-d,math.abs(d.Y)>.99 and Vector3.zAxis or Vector3.yAxis):Inverse()
local o=cube(Vector3.one,Vector3.new(((j-1)%3-1)*23,(.5-math.floor((j-1)/3))*16.4+.7,0),Color3.new(0,0,0));o.CFrame=o.CFrame*r*p.CFrame.Rotation
local m=Instance.new("SpecialMesh");m.MeshType=Enum.MeshType.FileMesh;m.MeshId=p.MeshId;m.Scale=Vector3.one*13.2/p.MeshSize;m.Parent=o;table.insert(rots,{r:GetComponents()}) end
for k=0,60 do local z=(k/60-.5)*18.0;local scale=(520-z)/520;cube(Vector3.new(.95*scale,1.4*scale,.02),Vector3.new((k-30)*1.05*scale,-17.0*scale,z-.01),Color3.new(0,0,0)) end
return "ready"
end
return {begin=lightBegin,finish=lightEnd,white=whiteSurvey,black=blackSurvey}

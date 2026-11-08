local function nativeDisplay(part)
 assert(part:GetAttribute("OwnGeometry")==true,"Authored parts only");local em=part.MeshContent.Object;assert(em,"Missing authored mesh");local scale=24;local pieces={};local normalThickness=.032
 local function wedge(centre,right,up,back,height,length)
 if height<.002 or length<.002 then return end
 local w=Instance.new("WedgePart");w.Anchored=true;w.CanCollide=false;w.CastShadow=false;w.Size=Vector3.new(normalThickness,height,length);w.CFrame=CFrame.fromMatrix(centre,right,up,back);table.insert(pieces,w)
 end
 for _,face in em:GetFaces() do local v=em:GetFaceVertices(face);local a,b,c=em:GetPosition(v[1])*scale,em:GetPosition(v[2])*scale,em:GetPosition(v[3])*scale
 local ab,ac,bc=b-a,c-a,c-b;if ab.Magnitude>ac.Magnitude and ab.Magnitude>bc.Magnitude then c,a=a,c elseif ac.Magnitude>bc.Magnitude then a,b=b,a end
 ab,ac,bc=b-a,c-a,c-b;local cross=ac:Cross(ab);if cross.Magnitude>.00001 then local right=cross.Unit;local back=bc.Unit;local up=bc:Cross(right).Unit;local h=math.abs(ab:Dot(up));wedge((a+b)/2,right,up,back,h,math.abs(ab:Dot(back)));wedge((a+c)/2,-right,up,-back,h,math.abs(ac:Dot(back)))end end
 local group=Instance.new("Model");group.Name=part.Name;group:SetAttribute("SourcePartIndex",part:GetAttribute("SourcePartIndex"))
 local function position(o)
 local cf=o.CFrame;o.Size=o.Size/scale;o.CFrame=part.CFrame*CFrame.new(cf.Position/scale)*cf.Rotation;o.Color=part.Color;if o:IsA("PartOperation") then o.UsePartColor=true end;o.Material=part.Material;o.Reflectance=part.Reflectance;o.Anchored=true;o.CanCollide=false;o.CanQuery=false;o.CanTouch=false;o.CastShadow=false;o.Parent=group
 end
 for start=1,#pieces,160 do
 local subset={};for k=start+1,math.min(#pieces,start+159) do table.insert(subset,pieces[k]) end
 local ok,outputs=pcall(function()return game:GetService("GeometryService"):UnionAsync(pieces[start],subset,{SplitApart=false,CollisionFidelity=Enum.CollisionFidelity.Box,RenderFidelity=Enum.RenderFidelity.Precise})end)
 if ok and #outputs>0 then for _,o in outputs do position(o)end;pieces[start]:Destroy();for _,p in subset do p:Destroy()end
 else position(pieces[start]);for _,p in subset do position(p) end end;task.wait() end
 return group,#pieces
end
return nativeDisplay

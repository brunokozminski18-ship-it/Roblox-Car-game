-- Prototype helpers; source: LihFolk Vault V2, server validation / prompts.
local Players = game:GetService("Players")
local H = {}
local limits = {}
function H.allow(player)
 local now = os.clock()
 local b = limits[player] or {tokens = 8, time = now}
 b.tokens = math.min(8, b.tokens + (now-b.time)*4)
 b.time = now
 limits[player] = b
 if b.tokens < 1 then return false end
 b.tokens -= 1
 return true
end
function H.root(player)
 local c = player.Character
 local h = c and c:FindFirstChildOfClass("Humanoid")
 local r = c and c:FindFirstChild("HumanoidRootPart")
 if not h or h.Health <= 0 or not r then return nil end
 local p = r.Position
 if p.X ~= p.X or p.Y ~= p.Y or p.Z ~= p.Z or p.Magnitude > 2000 then return nil end
 local look = r.CFrame.LookVector
 if look.X ~= look.X or look.Y ~= look.Y or look.Z ~= look.Z or look.Magnitude > 2 then return nil end
 return r
end
function H.near(player, position, distance)
 local r = H.root(player)
 return r and (r.Position-position).Magnitude <= distance
end
function H.part(name, size, position, shade, parent)
 local p = Instance.new("Part")
 p.Name = name; p.Size = size; p.Position = position
 p.Anchored = true; p.Color = Color3.fromRGB(shade or 145,shade or 145,shade or 145)
 p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
 p.Material = Enum.Material.SmoothPlastic; p.Parent = parent or workspace
 H.skin(p)
 return p
end
function H.sign(part, text)
 local gui = Instance.new("BillboardGui")
 gui.Name="WorldLabel"; gui.Size = UDim2.fromOffset(124,30); gui.StudsOffset = Vector3.new(0,4.5,0)
 gui.AlwaysOnTop = false; gui.MaxDistance = 30; gui.Parent = part
 local t = Instance.new("TextLabel")
 t.Size = UDim2.fromScale(1,1); t.BackgroundTransparency = 0.15
 t.BackgroundColor3 = Color3.fromRGB(24,34,45); t.TextColor3 = Color3.new(1,1,1)
 t.TextSize = 18; t.TextWrapped = false; t.Text = text; t.Parent = gui
 return t
end
function H.prompt(part, action, callback)
 local p = Instance.new("ProximityPrompt")
 p.ActionText = action; p.ObjectText = part.Name; p.MaxActivationDistance = 10
 p.RequiresLineOfSight = false; p.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
 p.Parent = part
 p.Triggered:Connect(function(player)
  if not H.allow(player) then return end
  if not p.Enabled or not part:IsDescendantOf(workspace) or not H.near(player,part.Position,11) then return end
  callback(player)
 end)
 return p
end
function H.spawn(position)
 local s = Instance.new("SpawnLocation")
 s.Size = Vector3.new(8,1,8); s.Position = position; s.Anchored = true
 s.Neutral = true; s.Duration = 0; s.Color = Color3.fromRGB(88,225,154); s.Material=Enum.Material.SmoothPlastic; s.Parent = workspace
end
function H.flash(p)
 local old = p.Color; p.Color = Color3.new(1,1,1)
 task.delay(0.25,function() if p.Parent then p.Color = old end end)
end
Players.PlayerRemoving:Connect(function(player) limits[player] = nil end)
-- Cosmetic geometry is non-colliding/non-queryable; client follows the original root.
function H.detail(root,size,offset,color)
 local p=Instance.new("Part"); p.Name="Detail"; p.Size=size; p.CFrame=root.CFrame*CFrame.new(offset)
 p.Anchored=true; p.CanCollide=false; p.CanQuery=false; p.CanTouch=false
 p.Color=color; p.Material=Enum.Material.SmoothPlastic; p:SetAttribute("Offset",offset); p.Parent=root
 return p
end
function H.skin(p)
 local n=p.Name; local rgb=Color3.fromRGB
 local palette={Ground=rgb(90,137,106),Arena=rgb(225,204,154),Shelter=rgb(78,238,143),["Training ground"]=rgb(107,153,128),["Quiet detour"]=rgb(88,209,149),["Hiding pocket"]=rgb(62,223,151),["Noisy shortcut"]=rgb(248,139,64),["Wide basket"]=rgb(99,247,154),["Basket rim"]=rgb(44,166,109),["Help flap"]=rgb(56,192,174)}
 p.Color=palette[n] or rgb(79,103,128)
 if n:find("Training plot") then p.Color=rgb(123,191,212) end
 if n:find("socket") then p.Color=rgb(81,217,255); p.Material=Enum.Material.Neon end
 if n=="Test shelter" then p.Color=rgb(255,223,72); p.Material=Enum.Material.Neon end
 if n=="Straight panel" or n=="Bent return" then p.Color=rgb(66,156,233) end
 if n=="Shelter" then
  for _,x in {-8,8} do H.detail(p,Vector3.new(1,7,1),Vector3.new(x,3.5,-5),rgb(38,169,117)) end
  H.detail(p,Vector3.new(18,1,2),Vector3.new(0,7,-5),rgb(106,255,171))
 end
 if n=="Wide basket" then
  for _,z in {-8.5,8.5} do H.detail(p,Vector3.new(26,2,0.5),Vector3.new(0,1,z),rgb(46,190,114)) end
 end
 if n=="Breakable divider" then p.Color=rgb(218,138,71) end
 if n:find("BONK") then p.Color=rgb(255,62,74); p.Material=Enum.Material.Neon end
 if n=="Roar wave" then
  p.Color=rgb(255,58,92); p.Transparency=1; p.Material=Enum.Material.Neon
  for i=-5,5 do local d=H.detail(p,Vector3.new(0.6,3+4*math.abs(math.sin(i*1.7)),0.7),Vector3.new(i*1.8,0,0),rgb(255,49,99)); d.Material=Enum.Material.Neon; d.Transparency=0.35 end
 elseif n:find("rescue") or n=="Figure" then
  p.Color=rgb(255,208,67)
  local head=n=="Figure" and H.detail(p,Vector3.new(2.6,2.2,2.6),Vector3.new(0,3.2,0),rgb(255,218,108)) or p
  for _,x in {-0.65,0.65} do H.detail(head,Vector3.new(0.6,0.7,0.2),Vector3.new(x,0.5,1.4),rgb(25,32,51)) end
  H.detail(head,Vector3.new(0.6,0.2,0.2),Vector3.new(0,-0.5,1.4),rgb(25,32,51))
  for _,x in {-1.7,1.7} do H.detail(p,Vector3.new(0.8,1.1,1),Vector3.new(x,-0.5,0),rgb(255,182,45)) end
 elseif n=="Soft prop" or n=="Heavy prop" then
  p.Color=n=="Soft prop" and rgb(97,223,73) or rgb(197,128,55)
  if n=="Soft prop" then p.Shape=Enum.PartType.Ball end
  for _,x in {-0.8,0.8} do H.detail(p,Vector3.new(0.25,p.Size.Y,0.15),Vector3.new(x,0,p.Size.Z/2),n=="Soft prop" and rgb(50,104,43) or rgb(112,72,41)) end
  if n=="Soft prop" then H.detail(p,Vector3.new(0.5,0.7,0.5),Vector3.new(0,p.Size.Y/2+0.2,0),rgb(65,105,42)) else H.detail(p,Vector3.new(4.6,0.3,0.2),Vector3.new(0,0,1.6),rgb(112,72,41)) end
 end
 if n:find("rescue") or n=="Soft prop" or n=="Heavy prop" then
  local h=Instance.new("Highlight"); h.FillColor=p.Color; h.OutlineColor=Color3.new(1,1,1); h.FillTransparency=0.8
  h.OutlineTransparency=0.15; h.DepthMode=Enum.HighlightDepthMode.Occluded; h.Parent=p
 end
end
function H.guide(player,text,position)
 player:SetAttribute("GuideText",text); player:SetAttribute("GuideTarget",position)
end
function H.feedback(player,text,success)
 player:SetAttribute("Feedback",text); player:SetAttribute("Positive",success)
 player:SetAttribute("FeedbackId",(player:GetAttribute("FeedbackId") or 0)+1)
end
return H

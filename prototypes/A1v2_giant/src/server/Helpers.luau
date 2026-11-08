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
 return r, h
end
function H.near(player, position, distance)
 local r = H.root(player)
 return r and (r.Position-position).Magnitude <= distance
end
function H.part(name, size, position, color, parent)
 local p = Instance.new("Part")
 p.Name = name; p.Size = size; p.Position = position
 p.Anchored = true; p.Color = color or Color3.fromRGB(145,145,145)
 p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
 p.Material = Enum.Material.SmoothPlastic; p.Parent = parent or workspace
 return p
end
-- Cosmetic piece welded to a root; moves with it, never collides.
function H.detail(root, size, offset, color, shape)
 local p = Instance.new("Part"); p.Name = "Detail"; p.Size = size
 if shape then p.Shape = shape end
 p.CFrame = root.CFrame*CFrame.new(offset); p.Color = color; p.Material = Enum.Material.SmoothPlastic
 p.Anchored = false; p.Massless = true; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false
 local w = Instance.new("WeldConstraint"); w.Part0 = root; w.Part1 = p; w.Parent = p
 p.Parent = root
 return p
end
function H.sign(part, text, offset, distance)
 local gui = Instance.new("BillboardGui")
 gui.Name = "WorldLabel"; gui.Size = UDim2.fromOffset(130,30); gui.StudsOffset = Vector3.new(0,offset or 4,0)
 gui.MaxDistance = distance or 40; gui.Parent = part
 local t = Instance.new("TextLabel")
 t.Size = UDim2.fromScale(1,1); t.BackgroundTransparency = 0.15
 t.BackgroundColor3 = Color3.fromRGB(24,34,45); t.TextColor3 = Color3.new(1,1,1)
 t.TextSize = 18; t.Font = Enum.Font.GothamBold; t.Text = text; t.Parent = gui
 return t
end
function H.prompt(part, action, callback)
 local p = Instance.new("ProximityPrompt")
 p.ActionText = action; p.ObjectText = part.Name; p.MaxActivationDistance = 9
 p.RequiresLineOfSight = false; p.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
 p.Parent = part
 p.Triggered:Connect(function(player)
  if not H.allow(player) then return end
  if not p.Enabled or not part:IsDescendantOf(workspace) or not H.near(player,part.Position,11) then return end
  callback(player)
 end)
 return p
end
function H.guide(player, text, position)
 player:SetAttribute("GuideText", text); player:SetAttribute("GuideTarget", position)
end
function H.feedback(player, text, success)
 player:SetAttribute("Feedback", text); player:SetAttribute("Positive", success)
 player:SetAttribute("FeedbackId", (player:GetAttribute("FeedbackId") or 0)+1)
end
Players.PlayerRemoving:Connect(function(player) limits[player] = nil end)
return H

-- Presentation only: server attributes own noise, crumbs, guide and the roar timing.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Tween=game:GetService("TweenService")
local CAS=game:GetService("ContextActionService")
local RS=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local gui=Instance.new("ScreenGui"); gui.Name="GiantHud"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=false; gui.Parent=player:WaitForChild("PlayerGui")
local function corner(parent) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,6); c.Parent=parent end
local function label(size,pos,textSize)
 local t=Instance.new("TextLabel"); t.Size=size; t.Position=pos; t.BackgroundColor3=Color3.fromRGB(24,34,45)
 t.BackgroundTransparency=0.12; t.TextColor3=Color3.new(1,1,1); t.TextSize=textSize; t.Font=Enum.Font.GothamBold
 t.TextWrapped=true; t.Text=""; t.Parent=gui
 corner(t)
 return t
end
local instruction=label(UDim2.new(0.6,0,0,40),UDim2.new(0.2,0,0,4),20)
local crumbs=label(UDim2.fromOffset(150,30),UDim2.new(0.5,-160,1,-44),18)
local scale=Instance.new("UIScale"); scale.Parent=crumbs
-- Noise bar next to the crumbs counter.
local bar=Instance.new("Frame"); bar.Size=UDim2.fromOffset(150,30); bar.Position=UDim2.new(0.5,10,1,-44)
bar.BackgroundColor3=Color3.fromRGB(24,34,45); bar.Parent=gui; corner(bar)
local fill=Instance.new("Frame"); fill.Size=UDim2.fromScale(0,1); fill.BorderSizePixel=0; fill.Parent=bar; corner(fill)
local barText=Instance.new("TextLabel"); barText.Size=UDim2.fromScale(1,1); barText.BackgroundTransparency=1; barText.Font=Enum.Font.GothamBold
barText.TextSize=16; barText.TextColor3=Color3.new(1,1,1); barText.TextStrokeTransparency=0.4; barText.Parent=bar
local result=label(UDim2.new(0.6,0,0,48),UDim2.fromScale(0.2,0.3),24); result.Visible=false
-- Red screen edge while the giant wakes.
local edge=Instance.new("Frame"); edge.Size=UDim2.fromScale(1,1); edge.BackgroundTransparency=1; edge.Parent=gui
local stroke=Instance.new("UIStroke"); stroke.Thickness=18; stroke.Color=Color3.fromRGB(255,40,60); stroke.Transparency=1; stroke.Parent=edge

local lastCrumbs=0
player:GetAttributeChangedSignal("Crumbs"):Connect(function()
 local n=player:GetAttribute("Crumbs") or 0
 if n>lastCrumbs then scale.Scale=1.3; Tween:Create(scale,TweenInfo.new(0.3),{Scale=1}):Play() end
 lastCrumbs=n
end)
player:GetAttributeChangedSignal("FeedbackId"):Connect(function()
 local id=player:GetAttribute("FeedbackId"); result.Text=player:GetAttribute("Feedback") or ""
 result.BackgroundColor3=player:GetAttribute("Positive") and Color3.fromRGB(28,151,94) or Color3.fromRGB(192,48,72)
 result.Visible=true; task.delay(1.6,function() if player:GetAttribute("FeedbackId")==id then result.Visible=false end end)
end)

-- Guide beam to the current target.
local function marker()
 local p=Instance.new("Part"); p.Size=Vector3.new(0.1,0.1,0.1); p.Transparency=1
 p.Anchored=true; p.CanCollide=false; p.CanQuery=false; p.CanTouch=false; p.Parent=workspace
 return p
end
local from,to=marker(),marker()
local a0=Instance.new("Attachment"); a0.Parent=from; local a1=Instance.new("Attachment"); a1.Parent=to
local beam=Instance.new("Beam"); beam.Attachment0=a0; beam.Attachment1=a1
beam.FaceCamera=true; beam.Width0=0.2; beam.Width1=0.5; beam.LightEmission=1; beam.Color=ColorSequence.new(Color3.fromRGB(255,237,115)); beam.Parent=from

-- The roar wave is drawn locally: only the noisy player sees and suffers it.
local wave=Instance.new("Part"); wave.Name="RoarWave"; wave.Size=Vector3.new(100,14,2); wave.Anchored=true; wave.CanCollide=false; wave.CanQuery=false; wave.CanTouch=false
wave.Material=Enum.Material.Neon; wave.Color=Color3.fromRGB(255,60,90); wave.Transparency=1; wave.Parent=workspace

RunService.RenderStepped:Connect(function()
 local noise=player:GetAttribute("Noise") or 0
 fill.Size=UDim2.fromScale(noise/100,1)
 fill.BackgroundColor3=noise<50 and Color3.fromRGB(80,210,120) or noise<80 and Color3.fromRGB(250,200,60) or Color3.fromRGB(240,60,70)
 barText.Text=player:GetAttribute("Sneaking") and "NOISE (sneaking)" or "NOISE"
 crumbs.Text="CRUMBS "..(player:GetAttribute("Crumbs") or 0)
 instruction.Text=player:GetAttribute("GuideText") or "Grab the mouse"
 local waking=player:GetAttribute("Waking")
 stroke.Transparency=waking and 0.2+math.sin(os.clock()*12)*0.2 or 1
 local start=player:GetAttribute("WaveStart")
 local t=start and workspace:GetServerTimeNow()-start
 if t and t>0 then wave.Position=Vector3.new(0,7,-94+t*300); wave.Transparency=0.45 else wave.Transparency=1 end
 local c=player.Character; local r=c and c:FindFirstChild("HumanoidRootPart")
 local target=player:GetAttribute("GuideTarget")
 beam.Enabled=r~=nil and target~=nil
 if r and target then from.Position=r.Position; to.Position=target+Vector3.new(0,2,0) end
end)

-- Buttons: keys Q (DROP) and C (SNEAK); on touch our own buttons left of / above the jump button.
local drop=RS:WaitForChild("Drop"); local sneak=RS:WaitForChild("Sneak")
local sneaking=false
local sneakButton
local function toggleSneak()
 sneaking=not sneaking; sneak:FireServer(sneaking)
 if sneakButton then sneakButton.Text=sneaking and "WALK" or "SNEAK" end
end
CAS:BindAction("Drop",function(_,s) if s==Enum.UserInputState.Begin then drop:FireServer() end return Enum.ContextActionResult.Sink end,false,Enum.KeyCode.Q)
CAS:BindAction("Sneak",function(_,s) if s==Enum.UserInputState.Begin then toggleSneak() end return Enum.ContextActionResult.Sink end,false,Enum.KeyCode.C)
if game:GetService("UserInputService").TouchEnabled then
 local function button(text,pos,color,onTap)
  local b=Instance.new("TextButton"); b.Size=UDim2.fromOffset(78,78); b.AnchorPoint=Vector2.new(0.5,0.5); b.Position=pos
  b.BackgroundColor3=color; b.TextColor3=Color3.new(1,1,1); b.Font=Enum.Font.GothamBlack; b.TextSize=18; b.Text=text
  local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=b
  b.Activated:Connect(onTap); b.Parent=gui
  return b
 end
 sneakButton=button("SNEAK",UDim2.new(1,-210,1,-70),Color3.fromRGB(70,120,220),toggleSneak)
 button("DROP",UDim2.new(1,-120,1,-175),Color3.fromRGB(200,90,60),function() drop:FireServer() end)
end
player.CharacterAdded:Connect(function() sneaking=false; if sneakButton then sneakButton.Text="SNEAK" end end)

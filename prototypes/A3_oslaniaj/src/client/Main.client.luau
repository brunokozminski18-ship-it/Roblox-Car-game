-- Presentation only: server attributes own instruction, target, count and results.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Tween=game:GetService("TweenService")
local player=Players.LocalPlayer
local gui=Instance.new("ScreenGui"); gui.Name="PrototypeGuide"; gui.ResetOnSpawn=false; gui.Parent=player:WaitForChild("PlayerGui")
local function text(size,pos,fontSize)
 local t=Instance.new("TextLabel"); t.Size=size; t.Position=pos; t.BackgroundColor3=Color3.fromRGB(24,34,45)
 t.BackgroundTransparency=0.12; t.TextColor3=Color3.new(1,1,1); t.TextSize=fontSize; t.TextWrapped=true; t.Text=""; t.Parent=gui
 return t
end
local instruction=text(UDim2.new(0.94,0,0,52),UDim2.fromScale(0.03,0.01),24)
local counter=text(UDim2.fromOffset(150,30),UDim2.new(0.5,-75,0,59),18)
local result=text(UDim2.new(0.8,0,0,56),UDim2.fromScale(0.1,0.36),26); result.Visible=false
local scale=Instance.new("UIScale"); scale.Parent=counter
local lastCount=0
player:GetAttributeChangedSignal("Count"):Connect(function()
 local count=player:GetAttribute("Count") or 0
 if count>lastCount then scale.Scale=1.25; Tween:Create(scale,TweenInfo.new(0.3),{Scale=1}):Play() end
 lastCount=count
end)
player:GetAttributeChangedSignal("FeedbackId"):Connect(function()
 local id=player:GetAttribute("FeedbackId"); result.Text=player:GetAttribute("Feedback") or ""
 result.BackgroundColor3=player:GetAttribute("Positive") and Color3.fromRGB(28,151,94) or Color3.fromRGB(192,48,72)
 result.BackgroundTransparency=0; Tween:Create(result,TweenInfo.new(0.4),{BackgroundTransparency=0.22}):Play()
 result.Visible=true; task.delay(1.8,function() if player:GetAttribute("FeedbackId")==id then result.Visible=false end end)
end)
local function marker()
 local p=Instance.new("Part"); p.Size=Vector3.new(0.1,0.1,0.1); p.Transparency=1
 p.Anchored=true; p.CanCollide=false; p.CanQuery=false; p.CanTouch=false; p.Parent=workspace
 return p
end
local start,finish=marker(),marker()
local a=Instance.new("Attachment",start); local b=Instance.new("Attachment",finish)
local beam=Instance.new("Beam"); beam.Attachment0=a; beam.Attachment1=b; beam.FaceCamera=true
beam.Width0=0.22; beam.Width1=0.6; beam.Color=ColorSequence.new(Color3.fromRGB(255,237,115)); beam.LightEmission=1; beam.Parent=start
local arrow=Instance.new("BillboardGui"); arrow.Size=UDim2.fromOffset(50,50); arrow.AlwaysOnTop=true; arrow.Parent=finish
local tip=Instance.new("TextLabel"); tip.Size=UDim2.fromScale(1,1); tip.BackgroundTransparency=1; tip.Text="▼"; tip.TextSize=40; tip.TextColor3=Color3.fromRGB(255,235,91); tip.Parent=arrow
local details,highlights,signs={},{},{}
local function track(p)
 if p:IsA("BasePart") and p:GetAttribute("Offset") then details[p]=true end
 if p:IsA("Highlight") then highlights[p]=true end
 if p:IsA("BillboardGui") and p.Name=="WorldLabel" then signs[p]=true end
end
workspace.DescendantAdded:Connect(track); for _,p in workspace:GetDescendants() do track(p) end
RunService.RenderStepped:Connect(function()
 for p in details do
  if not p.Parent then details[p]=nil else
   local root=p.Parent; p.CFrame=root.CFrame*CFrame.new(p:GetAttribute("Offset")); p.Transparency=(root.Name=="Figure" or root.Name=="Detail") and root.Transparency or (p.Material==Enum.Material.Neon and 0.25 or 0)
  end
 end
 for h in highlights do if not h.Parent then highlights[h]=nil else h.FillTransparency=0.75+math.sin(os.clock()*4)*0.18 end end
 local c=player.Character; local r=c and c:FindFirstChild("HumanoidRootPart")
 local nearest,distance=nil,26
 for sign in signs do
  if not sign.Parent then signs[sign]=nil elseif r then local d=(sign.Parent.Position-r.Position).Magnitude; if d<distance then nearest=sign; distance=d end end
 end
 for sign in signs do sign.Enabled=sign==nearest end
 local target=player:GetAttribute("GuideTarget")
 instruction.Text=player:GetAttribute("GuideText") or "Claim your plot"
 counter.Text="BLOCKED "..(player:GetAttribute("Count") or 0)
 beam.Enabled=r~=nil and target~=nil; arrow.Enabled=beam.Enabled
 if r and target then start.Position=r.Position; finish.Position=target+Vector3.new(0,3+math.sin(os.clock()*3)*0.3,0) end
end)

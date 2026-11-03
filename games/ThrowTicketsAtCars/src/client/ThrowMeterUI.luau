--!strict
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local Meter=require(game.ReplicatedStorage.ThrowTickets.ThrowMeter)
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local S=require(script.Parent.Style)
local UI={}
function UI.mount(remote: RemoteEvent)
 local p=Players.LocalPlayer
 local gui=Instance.new("ScreenGui");gui.Name="ThrowMeter";gui.DisplayOrder=45;gui.ResetOnSpawn=false;gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;gui.Parent=p.PlayerGui
 local tap=S.button(gui,"Tap","",UDim2.fromScale(1,1),UDim2.new());tap.BackgroundTransparency=1
 for _,c in tap:GetChildren()do if c:IsA("UIStroke")then c:Destroy()end end
 local bar=Instance.new("Frame");bar.Name="Bar";bar.AnchorPoint=Vector2.new(.5,.5);bar.Position=UDim2.fromScale(.58,.46);bar.Size=UDim2.fromOffset(54,220);bar.BorderSizePixel=0;bar.BackgroundColor3=Color3.new(1,1,1);bar.Parent=tap;S.corner(bar,24);S.stroke(bar,4)
 local gradient=Instance.new("UIGradient");gradient.Rotation=90;gradient.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex("58EB6B")),ColorSequenceKeypoint.new(.5,Color3.fromHex("FFE55D")),ColorSequenceKeypoint.new(1,Color3.fromHex("F0544D"))});gradient.Parent=bar
 for _,y in {.25,.5,.75}do local line=Instance.new("Frame");line.Size=UDim2.new(1,0,0,2);line.Position=UDim2.fromScale(0,y);line.BackgroundColor3=S.INK;line.BackgroundTransparency=.5;line.BorderSizePixel=0;line.Parent=bar end
 local marker=Instance.new("Frame");marker.Name="Slider";marker.AnchorPoint=Vector2.new(.5,.5);marker.Size=UDim2.new(1,20,0,16);marker.Position=UDim2.fromScale(.5,1);marker.BorderSizePixel=0;marker.BackgroundColor3=Color3.new(1,1,1);marker.Parent=bar;S.corner(marker,8);S.stroke(marker,3)
 local bonus=S.text(bar,"Bonus","",24,UDim2.new(1,20,.5,-24),UDim2.fromOffset(180,48));bonus.TextWrapped=true
 local label=S.text(tap,"Instruction","TAP TO THROW!",32,UDim2.fromScale(.5,.88),UDim2.new(1,-24,0,46));label.AnchorPoint=Vector2.new(.5,.5);label.TextXAlignment=Enum.TextXAlignment.Center
 local sent: number?=nil;local frozen=0
 local function throw()
  local start=p:GetAttribute("MeterStart");if typeof(start)~="number"or sent==start then return end
  local time=workspace:GetServerTimeNow();frozen=Meter.position(time-start);sent=start;remote:FireServer(time)
 end
 tap.Activated:Connect(throw)
 UIS.InputBegan:Connect(function(input,processed)if not processed and(input.KeyCode==Enum.KeyCode.Space or input.UserInputType==Enum.UserInputType.MouseButton1)then throw()end end)
 RunService.RenderStepped:Connect(function()
  local start=p:GetAttribute("MeterStart");gui.Enabled=typeof(start)=="number"
  if not gui.Enabled then sent=nil;return end
  local position=if sent==start then frozen else Meter.position(workspace:GetServerTimeNow()-start)
  marker.Position=UDim2.fromScale(.5,position);bonus.Text=string.format("%+.1f\nPOWER",(p:GetAttribute("ThrowSelection")or p:GetAttribute("ThrowPower")or 0)*Meter.bonus(position))
  label.Text=if sent==start then (if frozen<=Config.Juice.PerfectPosition then "PERFECT!"else "THROWING!")else "TAP TO THROW!"
  bar.Size=UDim2.fromOffset(54,math.clamp(gui.AbsoluteSize.Y*.67,120,380));label.TextSize=if gui.AbsoluteSize.X<600 then 26 else 32
 end)
 gui.Enabled=false
end
return UI

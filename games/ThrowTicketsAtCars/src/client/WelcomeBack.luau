--!strict
-- First UI sample for iteration 10c. NOT FINAL.
local S=require(script.Parent.Style)
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local Welcome={}
local function money(n: number): string
 local value=tostring(math.floor(n));local formatted=value:reverse():gsub("(%d%d%d)","%1,"):reverse();return formatted:gsub("^,","")
end
function Welcome.mount(parent: Instance,onClaim: () -> ()): any
 local gui=Instance.new("ScreenGui");gui.Name="WelcomeBack";gui.ResetOnSpawn=false;gui.DisplayOrder=55
 gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=parent;gui.Enabled=false
 local dim=Instance.new("TextButton");dim.Name="Dim";dim.Size=UDim2.fromScale(1,1);dim.Text="";dim.AutoButtonColor=false;dim.BackgroundColor3=S.INK;dim.BackgroundTransparency=.32;dim.Parent=gui
 local panel=Instance.new("Frame");panel.Name="Window";panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.5);panel.BackgroundColor3=Color3.new(1,1,1);panel.BorderSizePixel=0;panel.Parent=gui
 S.corner(panel,28);S.stroke(panel,4);S.gradient(panel,Color3.fromHex("2F7BF2"),Color3.fromHex("16348F"))
 local title=S.text(panel,"Title","Welcome Back!",34,UDim2.fromOffset(18,16),UDim2.new(1,-36,0,44));title.TextXAlignment=Enum.TextXAlignment.Center
 local description=S.text(panel,"Description","While you were away your cars earned",20,UDim2.fromOffset(18,68),UDim2.new(1,-36,0,48));description.TextWrapped=true;description.TextXAlignment=Enum.TextXAlignment.Center
 local amount=S.text(panel,"Amount","",42,UDim2.fromOffset(18,112),UDim2.new(1,-36,0,52));amount.TextColor3=Color3.fromHex("FFF4A0");amount.TextXAlignment=Enum.TextXAlignment.Center
 local away=S.text(panel,"Away","",19,UDim2.fromOffset(18,166),UDim2.new(1,-36,0,28));away.TextXAlignment=Enum.TextXAlignment.Center
 local claim=S.button(panel,"Claim","CLAIM",UDim2.new(1,-64,0,56),UDim2.new(0,32,1,-72));claim.TextSize=28;claim.TextColor3=Color3.new(1,1,1);claim.TextStrokeTransparency=.15;S.gradient(claim,Color3.fromHex("8CF27C"),Color3.fromHex("22B24A"))
 local note=S.text(panel,"Note",string.format("%g%% offline income • up to %g hours",Config.Returns.OfflineFraction*100,Config.Returns.OfflineCapSeconds/3600),14,UDim2.new(0,12,1,-105),UDim2.new(1,-24,0,22));note.TextXAlignment=Enum.TextXAlignment.Center
 local function resize()panel.Size=UDim2.fromOffset(math.min(500,gui.AbsoluteSize.X-24),math.min(310,gui.AbsoluteSize.Y-16));title.TextSize=if gui.AbsoluteSize.X<600 then 29 else 34 end
 gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize);resize()
 claim.Activated:Connect(function()if claim.Active then claim.Active=false;claim.Text="CLAIMING...";onClaim()end end)
 return {gui=gui,show=function(cash: number,seconds: number)
  amount.Text="$"..money(cash);away.Text=string.format("Away for %dh %dm",seconds//3600,(seconds%3600)//60)
  claim.Active=true;claim.Text="CLAIM";gui.Enabled=true
 end,hide=function()gui.Enabled=false end,retry=function()claim.Active=true;claim.Text="CLAIM"end}
end
return Welcome

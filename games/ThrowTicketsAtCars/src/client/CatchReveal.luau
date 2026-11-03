--!strict
local Tween=game:GetService("TweenService")
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local S=require(script.Parent.Style)
local Preview=require(script.Parent.CarPreview)
local Reveal={}
function Reveal.mount(parent: Instance,playSound: ((string,number?)->())?): any
 local sound=playSound or function()end
 local gui=Instance.new("ScreenGui");gui.Name="CatchReveal";gui.ResetOnSpawn=false;gui.DisplayOrder=60;gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;gui.Parent=parent
 local dim=Instance.new("TextButton");dim.Name="Dim";dim.Size=UDim2.fromScale(1,1);dim.Text="";dim.BackgroundColor3=S.INK;dim.BackgroundTransparency=.35;dim.Parent=gui
 local panel=Instance.new("Frame");panel.Name="Card";panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.5);panel.BackgroundColor3=Color3.new(1,1,1);panel.BorderSizePixel=0;panel.Active=true;panel.Parent=gui
 S.corner(panel,28);local outline=S.stroke(panel,4);S.gradient(panel,Color3.fromHex("2F7BF2"),Color3.fromHex("16348F"))
 local header=S.text(panel,"Header","TICKETED!",27,UDim2.fromOffset(20,8),UDim2.new(1,-40,0,34))
 local badge=S.text(panel,"Best","NEW BEST!",20,UDim2.new(1,-20,0,10),UDim2.fromOffset(170,32));badge.AnchorPoint=Vector2.new(1,0);badge.TextXAlignment=Enum.TextXAlignment.Right;badge.TextColor3=Color3.fromHex("FFD24A")
 local icon=Instance.new("Frame");icon.Name="Car";icon.Position=UDim2.fromScale(.025,.19);icon.Size=UDim2.fromScale(.4,.59);icon.BackgroundTransparency=.85;icon.BackgroundColor3=S.INK;icon.Parent=panel;S.corner(icon,20)
 local name=S.text(panel,"CarName","",29,UDim2.fromScale(.46,.23),UDim2.fromScale(.51,.22));name.TextWrapped=true;name.TextXAlignment=Enum.TextXAlignment.Left
 local rarity=S.text(panel,"Rarity","",18,UDim2.fromScale(.46,.46),UDim2.fromScale(.5,.11))
 local income=S.text(panel,"Income","",27,UDim2.fromScale(.46,.58),UDim2.fromScale(.5,.14));income.TextColor3=Color3.fromHex("B2FFAD")
 local odds=S.text(panel,"Odds","",19,UDim2.fromScale(.46,.73),UDim2.fromScale(.5,.1));odds.TextColor3=Color3.fromHex("FFD24A")
 local nextButton=S.button(panel,"Continue","Tap to continue",UDim2.new(1,-36,0,44),UDim2.new(0,18,1,-54));nextButton.TextSize=20;S.gradient(nextButton,Color3.fromHex("FFF4A0"),Color3.fromHex("FFD24A"))
 local scale=Instance.new("UIScale");scale.Parent=panel
 local version=0;local callback=nil;local ready=false
 local function resize()panel.Size=UDim2.fromOffset(math.min(660,gui.AbsoluteSize.X-24),math.min(340,gui.AbsoluteSize.Y-20));name.TextSize=if gui.AbsoluteSize.X<600 then 23 else 29;header.TextSize=if gui.AbsoluteSize.X<600 then 22 else 27 end
 gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize);resize()
 local function hide()version+=1;gui.Enabled=false;callback=nil;ready=false end
 local function proceed()if gui.Enabled and ready and callback then local action=callback;hide();sound("Tap");action()end end
 nextButton.Activated:Connect(proceed);dim.Activated:Connect(proceed)
 gui.Enabled=false
 return {gui=gui,hide=hide,show=function(data: any,onContinue: ()->())
  version+=1;local current=version;callback=onContinue;ready=false;gui.Enabled=true;gui:SetAttribute("Ready",false);gui:SetAttribute("JobId",data.Id)
  for _,x in icon:GetChildren()do if x:IsA("ViewportFrame")then x:Destroy()end end;Preview.mount(icon,data)
  local rare=data.Rarity>=3;local color=Config.Rarities[data.Rarity].Color
  outline.Color=color;rarity.Text=Config.Rarities[data.Rarity].Name:upper();rarity.TextColor3=color;income.Text="$"..data.Income.."/s";badge.Visible=data.NewBest==true
  header.Text=if rare then "RARE CATCH!"else "TICKETED!";odds.Visible=rare;odds.Text=if rare then "1 in 1"else ""
  scale.Scale=if rare then .72 else .9;Tween:Create(scale,TweenInfo.new(.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()
  local full=data.Name:upper();local shown={};for i=1,#full do shown[i]=full:sub(i,i)==" "end
  local function masked()local out={};for i=1,#full do out[i]=if shown[i]then full:sub(i,i)else "_"end;return table.concat(out)end
  name.Text=masked();nextButton.Text="Revealing...";sound(if rare then "Rare"else "Impact")
  task.spawn(function()
   local started=os.clock();local oddsTarget=math.max(1,data.Odds or 1)
   for i=1,#full do
    if version~=current or not gui.Parent then return end
    shown[i]=true;name.Text=masked()
    if full:sub(i,i)~=" "then sound("Letter",.95+i*.025)end
    if rare then odds.Text="1 in "..math.floor(1+(oddsTarget-1)*i/#full);sound("Counter",.9+i*.02)end
    task.wait(Config.Juice.LetterSeconds*(if rare then 1.35 else 1))
   end
   local remaining=(if rare then Config.Juice.RareRevealMin else Config.Juice.CommonRevealMin)-(os.clock()-started)
   if remaining>0 then task.wait(remaining)end
   if version~=current then return end
   name.Text=full;odds.Text="1 in "..oddsTarget;nextButton.Text="Tap to continue";ready=true;gui:SetAttribute("Ready",true);sound(if rare then "Rare"else "Toast")
  end)
 end}
end
return Reveal

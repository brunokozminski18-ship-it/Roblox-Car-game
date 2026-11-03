--!strict
-- The reward stays in the world: this overlay supplies only reveal typography/input.
local Tween=game:GetService("TweenService")
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local S=require(script.Parent.Style)
local Reveal={}
function Reveal.mount(parent: Instance,playSound: ((string,number?)->())?): any
 local sound=playSound or function()end
 local gui=Instance.new("ScreenGui");gui.Name="CatchReveal";gui.ResetOnSpawn=false;gui.DisplayOrder=60;gui.ScreenInsets=Enum.ScreenInsets.None;gui.Parent=parent
 local panel=Instance.new("Frame");panel.Name="Card";panel.Size=UDim2.fromScale(1,1);panel.BackgroundTransparency=1;panel.Parent=gui
 for _,bottom in {false,true}do
  local band=Instance.new("Frame");band.Name=if bottom then "LowerBand"else "UpperBand";band.Size=UDim2.fromScale(1,.055)
  band.Position=UDim2.fromScale(0,if bottom then .945 else 0);band.BorderSizePixel=0;band.BackgroundColor3=S.INK;band.BackgroundTransparency=.12;band.Parent=panel
 end
 local function centered(name: string,value: string,size: number,y: number,height: number): TextLabel
  local t=S.text(panel,name,value,size,UDim2.fromScale(.5,y),UDim2.new(1,-40,0,height));t.AnchorPoint=Vector2.new(.5,.5);t.TextXAlignment=Enum.TextXAlignment.Center;return t
 end
 local name=centered("CarName","",43,.76,60)
 local rarity=centered("Rarity","",23,.835,32)
 local income=centered("Income","",29,.895,40);income.TextColor3=Color3.fromHex("B2FFAD")
 local odds=centered("Odds","",36,.14,52);odds.TextColor3=Color3.fromHex("FFD24A")
 local badge=S.text(panel,"Best","NEW BEST!",24,UDim2.fromScale(.72,.735),UDim2.fromOffset(180,38));badge.AnchorPoint=Vector2.new(.5,.5);badge.Rotation=-8;badge.TextXAlignment=Enum.TextXAlignment.Center
 badge.TextColor3=S.INK;badge.TextStrokeTransparency=1;badge.BackgroundTransparency=0;badge.BackgroundColor3=Color3.fromHex("FFD24A");S.corner(badge,8);S.stroke(badge,3)
 local hint=centered("Hint","Tap to continue",18,.972,28)
 local nextButton=Instance.new("TextButton");nextButton.Name="Continue";nextButton.Size=UDim2.fromScale(1,1);nextButton.Text="";nextButton.BackgroundTransparency=1;nextButton.AutoButtonColor=false;nextButton:SetAttribute("AudioMuted",true);nextButton.Parent=panel
 local scale=Instance.new("UIScale");scale.Parent=name
 local version=0;local callback=nil;local ready=false;local skip=false
 local function placeBadge()
  local h=gui.AbsoluteSize.Y;local width=badge.Size.X.Offset
  local x=math.min(name.TextBounds.X/2+width/2+14,gui.AbsoluteSize.X/2-width/2-12)
  badge.Position=UDim2.new(.5,x,1,if h<500 then -155 else -225)
 end
 local function resize()
  local h=gui.AbsoluteSize.Y;name.TextSize=math.clamp(h*.1,26,43);rarity.TextSize=math.clamp(h*.065,17,23);income.TextSize=math.clamp(h*.08,21,29)
  odds.TextSize=math.clamp(h*.1,27,36);badge.TextSize=math.clamp(h*.065,16,24);hint.TextSize=math.clamp(h*.05,14,18)
  badge.Size=UDim2.fromOffset(math.clamp(gui.AbsoluteSize.X*.25,120,180),math.clamp(h*.09,28,38));placeBadge()
  name.Position=UDim2.new(.5,0,1,if h<500 then -116 else -180);rarity.Position=UDim2.new(.5,0,1,if h<500 then -84 else -134);income.Position=UDim2.new(.5,0,1,if h<500 then -59 else -96);hint.Position=UDim2.new(.5,0,1,-28)
 end
 name:GetPropertyChangedSignal("TextBounds"):Connect(placeBadge)
 gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize);resize()
 local function hide()version+=1;gui.Enabled=false;callback=nil;ready=false;gui:SetAttribute("Ready",false)end
 local function proceed()
  if not gui.Enabled then return end
  if not ready then skip=true;sound("Tap");return end
  if callback then local action=callback;hide();sound("Tap");action()end
 end
 nextButton.Activated:Connect(proceed);gui.Enabled=false
 return {gui=gui,hide=hide,show=function(data: any,onContinue: ()->())
  version+=1;local current=version;callback=onContinue;ready=false;skip=false;gui.Enabled=true;gui:SetAttribute("Ready",false);gui:SetAttribute("JobId",data.Id)
  local rare=data.Rarity>=3;local color=Config.Rarities[data.Rarity].Color
  name.TextColor3=Color3.new(1,1,1);rarity.Text=Config.Rarities[data.Rarity].Name:upper();rarity.TextColor3=color;income.Text="$"..data.Income.."/s"
  rarity.Visible=false;income.Visible=false;badge.Visible=false;odds.Visible=rare;odds.Text=if rare then "1 in 1"else "";hint.Text="Tap to skip reveal"
  local full=data.Name:upper();local shown={};local order={}
  for i=1,#full do shown[i]=full:sub(i,i)==" ";if not shown[i]then table.insert(order,i)end end
  local rng=Random.new();for i=#order,2,-1 do local j=rng:NextInteger(1,i);order[i],order[j]=order[j],order[i]end
  local function masked()local out={};for i=1,#full do out[i]=if shown[i]then full:sub(i,i)else "_"end;return table.concat(out)end
  name.Text=masked();scale.Scale=1
  task.spawn(function()
   local started=os.clock();local target=math.max(1,data.Odds or 1);task.wait(.35)
   for step,index in order do
    if version~=current or not gui.Parent then return end
    if skip then break end
    shown[index]=true;name.Text=masked();sound("Letter",.95+step*.025)
    if rare then odds.Text="1 in "..math.floor(1+(target-1)*step/#order);sound("Counter",.9+step*.02)end
    task.wait(Config.Juice.LetterSeconds*(if rare then 1.35 else 1))
   end
   if version~=current then return end
   name.Text=full;name.TextColor3=color;rarity.Visible=true;income.Visible=true;badge.Visible=data.NewBest==true;odds.Text="1 in "..target
   scale.Scale=.88;Tween:Create(scale,TweenInfo.new(.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play();sound(if rare then "Rare"else "Toast")
   local remaining=math.max((if rare then Config.Juice.RareRevealMin else Config.Juice.CommonRevealMin),#full*Config.Juice.LetterSeconds*(if rare then 1.35 else 1))-(os.clock()-started)
   if remaining>0 then hint.Text="Revealing...";task.wait(remaining)end
   if version~=current then return end
   hint.Text="Tap to continue";ready=true;gui:SetAttribute("Ready",true)
  end)
 end}
end
return Reveal

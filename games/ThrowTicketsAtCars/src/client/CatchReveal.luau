--!strict
-- The reward stays in the world: this overlay supplies only reveal typography/input.
local Tween=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local Juice=require(game.ReplicatedStorage.ThrowTickets.JuiceRules)
local S=require(script.Parent.Style)
local Reveal={}
local function oddsText(value: number): string
 local digits=tostring(math.floor(value))
 return "1 in "..(digits:reverse():gsub("(%d%d%d)","%1,"):reverse():gsub("^,",""))
end
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
 local variantLabel=centered("Variant","",17,.67,24)
 local income=centered("Income","",29,.895,40);income.TextColor3=Color3.fromHex("B2FFAD")
 local odds=centered("Odds","",36,.14,52);odds.TextColor3=Color3.fromHex("FFD24A")
 local rareTitle=centered("RareTitle","",24,.07,32);rareTitle.TextColor3=Color3.fromHex("E2ADFF")
 local badge=S.text(panel,"Best","NEW BEST!",24,UDim2.fromScale(.72,.735),UDim2.fromOffset(180,38));badge.AnchorPoint=Vector2.new(.5,.5);badge.Rotation=-8;badge.TextXAlignment=Enum.TextXAlignment.Center
 badge.TextColor3=S.INK;badge.TextStrokeTransparency=1;badge.BackgroundTransparency=0;badge.BackgroundColor3=Color3.fromHex("FFD24A");S.corner(badge,8);S.stroke(badge,3)
 local hint=centered("Hint","Tap to continue",18,.972,28)
 local nextButton=Instance.new("TextButton");nextButton.Name="Continue";nextButton.Size=UDim2.fromScale(1,1);nextButton.Text="";nextButton.BackgroundTransparency=1;nextButton.AutoButtonColor=false;nextButton:SetAttribute("AudioMuted",true);nextButton.Parent=panel
 local scale=Instance.new("UIScale");scale.Parent=name
 local oddsScale=Instance.new("UIScale");oddsScale.Parent=odds
 local counterConnection: RBXScriptConnection?=nil
 local pop: Tween?=nil
 local version=0
 local callback: (() -> ())?=nil
 local completeCard: (() -> ())?=nil
 local complete=false
 local minimumElapsed=false
 local queued=false
 local function placeBadge()
  local h=gui.AbsoluteSize.Y;local width=badge.Size.X.Offset
  local x=math.min(name.TextBounds.X/2+width/2+14,gui.AbsoluteSize.X/2-width/2-12)
  badge.Position=UDim2.new(.5,x,1,if h<500 then -155 else -225)
 end
 local function resize()
  local h=gui.AbsoluteSize.Y;name.TextSize=math.clamp(h*.1,26,43);rarity.TextSize=math.clamp(h*.065,17,23);income.TextSize=math.clamp(h*.08,21,29)
  odds.TextSize=math.clamp(h*.1,27,36);badge.TextSize=math.clamp(h*.065,16,24);hint.TextSize=math.clamp(h*.05,14,18)
  badge.Size=UDim2.fromOffset(math.clamp(gui.AbsoluteSize.X*.25,120,180),math.clamp(h*.09,28,38));placeBadge()
  name.Position=UDim2.new(.5,0,1,if h<500 then -116 else -180);variantLabel.Position=UDim2.new(.5,0,1,if h<500 then -145 else -220);rarity.Position=UDim2.new(.5,0,1,if h<500 then -84 else -134);income.Position=UDim2.new(.5,0,1,if h<500 then -59 else -96);hint.Position=UDim2.new(.5,0,1,-28)
 end
 name:GetPropertyChangedSignal("TextBounds"):Connect(placeBadge)
 gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize);resize()
 local function hide()
  if counterConnection then counterConnection:Disconnect();counterConnection=nil end
  if pop then pop:Cancel();pop=nil end
  oddsScale.Scale=1
  version+=1;gui.Enabled=false;callback=nil;completeCard=nil
  complete,minimumElapsed,queued=false,false,false
  gui:SetAttribute("Ready",false)
  gui:SetAttribute("Complete",false)
  gui:SetAttribute("ContinueQueued",false)
 end
 local function updateContinue()
  gui:SetAttribute("Ready",complete and minimumElapsed)
  if not complete then return end
  if minimumElapsed and queued then
   local action=callback
   hide()
   if action then action()end
  elseif queued then
   hint.Text="Continuing..."
  else
   hint.Text="Tap to continue"
  end
 end
 local function proceed()
  if not gui.Enabled or queued then return end
  sound("Tap")
  if not complete then
   if completeCard then completeCard()end
   return
  end
  queued=true
  gui:SetAttribute("ContinueQueued",true)
  updateContinue()
 end
 nextButton.Activated:Connect(proceed);gui.Enabled=false
 return {gui=gui,hide=hide,show=function(data: any,onContinue: ()->())
  hide()
  local current=version
  callback=onContinue;gui.Enabled=true;gui:SetAttribute("JobId",data.Id)
  local rare=data.Rarity>=3
  local variant=if typeof(data.Variant)=="string"then data.Variant:upper()else "NORMAL"
  local superLucky=data.SuperLucky==true
  local rarityData=Config.Rarities[data.Rarity]
  local color=rarityData.Color
  local showOdds=rare or superLucky or variant~="NORMAL"
  local target=math.max(1,math.floor(tonumber(data.Odds)or 1))
  rareTitle.Visible=rare or superLucky
  rareTitle.Text=if superLucky then "SUPER LUCKY!" elseif rare then rarityData.Name:upper().." CATCH!"else ""
  name.TextColor3=Color3.new(1,1,1);rarity.Text=rarityData.Name:upper();rarity.TextColor3=color;income.Text="$"..data.Income.."/s"
  variantLabel.Text=variant;variantLabel.Visible=false;variantLabel.TextColor3=if variant=="GOLD"then Color3.fromHex("FFD54D")elseif variant=="DIAMOND"then Color3.fromHex("87ECFF")else Color3.fromHex("A3FF9C")
  rarity.Visible=false;income.Visible=false;badge.Visible=false;odds.Visible=showOdds;odds.Text=if showOdds then "1 in 1"else "";hint.Text="Tap to reveal"
  local counterFinished=not showOdds
  local function finishOdds()
   if counterFinished then return end
   counterFinished=true
   if counterConnection then counterConnection:Disconnect();counterConnection=nil end
   odds.Text=oddsText(target)
   sound("Rare")
   oddsScale.Scale=1.14
   pop=Tween:Create(oddsScale,TweenInfo.new(.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Scale=1})
   pop:Play()
  end
  if showOdds then
   local duration=math.clamp(1.5+.3*math.log10(target),1.5,2.5)
   local started=os.clock()
   local lastTick=-math.huge
   local lastNumber=1
   counterConnection=RunService.RenderStepped:Connect(function()
    local now=os.clock()
    local progress=math.clamp((now-started)/duration,0,1)
    if progress>=1 then finishOdds();return end
    local eased=Tween:GetValue(progress,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out)
    local value=math.floor(1+(target-1)*eased)
    if value~=lastNumber then
     odds.Text=oddsText(value)
     lastNumber=value
     if now-lastTick>=.12 then
      lastTick=now
      sound("Counter",.85+.4*progress)
     end
    end
   end)
  end
  local full=data.Name:upper();local shown={};local order={}
  for i=1,#full do shown[i]=full:sub(i,i)==" ";if not shown[i]then table.insert(order,i)end end
  local rng=Random.new();for i=#order,2,-1 do local j=rng:NextInteger(1,i);order[i],order[j]=order[j],order[i]end
  local function masked()local out={};for i=1,#full do out[i]=if shown[i]then full:sub(i,i)else "_"end;return table.concat(out)end
  name.Text=masked();scale.Scale=1
  local function finish()
   if version~=current or complete then return end
   complete=true
   gui:SetAttribute("Complete",true)
   name.Text=full;name.TextColor3=color;rarity.Visible=true;income.Visible=true;variantLabel.Visible=variant~="NORMAL"
   badge.Visible=data.NewBest==true;finishOdds()
   scale.Scale=.88
   Tween:Create(scale,TweenInfo.new(.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()
   if not showOdds then sound("Toast")end
   updateContinue()
  end
  completeCard=finish
  local now=workspace:GetServerTimeNow()
  local deadline=if typeof(data.ReadyAt)=="number" and data.ReadyAt==data.ReadyAt and math.abs(data.ReadyAt)<math.huge
   then data.ReadyAt+.06 else now+Juice.revealSeconds(full,data.Rarity)
  task.spawn(function()
   while version==current do
    local remaining=deadline-workspace:GetServerTimeNow()
    if remaining<=0 then
     minimumElapsed=true
     updateContinue()
     return
    end
    task.wait(remaining)
   end
  end)
  task.spawn(function()
   task.wait(if rare then .65 else .35)
   for step,index in order do
    if version~=current or complete or not gui.Parent then return end
    shown[index]=true;name.Text=masked();sound("Letter",.98+step*.004)
    task.wait(Config.Juice.LetterSeconds*(if rare then Config.Juice.RareLetterMultiplier else 1))
   end
   while version==current and not complete and not counterFinished do task.wait()end
   finish()
  end)
 end}
end
return Reveal

--!strict
-- Presentation only: XP, offers, boosts and rewards come from the server.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Tween=game:GetService("TweenService")
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local Rules=require(game.ReplicatedStorage.ThrowTickets.Rules)
local S=require(script.Parent.Style)
local Audio=require(script.Parent.Audio)
local Effects=require(script.Parent.Effects)
local UI={}
function UI.mount(remotes: any,shop: any): any
 local p=Players.LocalPlayer
 local gui=Instance.new("ScreenGui");gui.Name="JuiceHUD";gui.ResetOnSpawn=false;gui.DisplayOrder=35;gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;gui.Parent=p.PlayerGui
 local function centered(name: string,value: string,y: number,size: number): TextLabel
  local t=S.text(gui,name,value,size,UDim2.new(.5,0,0,y),UDim2.new(1,-32,0,38));t.AnchorPoint=Vector2.new(.5,0);t.TextXAlignment=Enum.TextXAlignment.Center;return t
 end
 local biome=centered("FlightBiome","",4,27);local luck=centered("FlightLuck","",40,23);luck.TextColor3=Color3.fromHex("B2FFAD")
 local result=centered("ThrowResult","",83,26);result.TextColor3=Color3.fromHex("FFE56E")
 local levelUp=centered("LevelUp","",128,23);levelUp.TextColor3=Color3.fromHex("B2FFAD")
 local xp=Instance.new("Frame");xp.Name="XPBar";xp.AnchorPoint=Vector2.new(.5,1);xp.Position=UDim2.new(.5,0,1,-8);xp.Size=UDim2.new(1,-220,0,28);xp.BackgroundColor3=Color3.fromHex("162C65");xp.BorderSizePixel=0;xp.ClipsDescendants=true;xp.Parent=gui;S.corner(xp,12);S.stroke(xp,2)
 local fill=Instance.new("Frame");fill.Name="Fill";fill.Size=UDim2.fromScale(0,1);fill.BorderSizePixel=0;fill.BackgroundColor3=Color3.new(1,1,1);fill.Parent=xp;S.corner(fill,12);S.gradient(fill,Color3.fromHex("73DFFF"),Color3.fromHex("2374E5"))
 local xpText=S.text(xp,"Progress","",17,UDim2.fromOffset(8,0),UDim2.new(1,-16,1,0));xpText.TextXAlignment=Enum.TextXAlignment.Center
 local boost=Instance.new("TextButton");boost.Name="Boost";boost.Text="2x";boost.Font=S.FONT;boost.TextSize=38;boost.TextColor3=S.INK;boost.AutoButtonColor=false;boost.BorderSizePixel=0;boost.BackgroundColor3=Color3.new(1,1,1);boost.AnchorPoint=Vector2.new(.5,.5);boost.Size=UDim2.fromOffset(84,84);boost.Parent=gui;S.corner(boost,999);S.stroke(boost,4);S.gradient(boost,Color3.fromHex("FFF4A0"),Color3.fromHex("F5BA34"))
 local boostScale=Instance.new("UIScale");boostScale.Parent=boost
 local toast=Instance.new("Frame");toast.Name="GearToast";toast.Position=UDim2.fromOffset(16,48);toast.Size=UDim2.fromOffset(340,132);toast.BorderSizePixel=0;toast.BackgroundColor3=Color3.fromHex("16348F");toast.Parent=gui;S.corner(toast,16);S.stroke(toast,3)
 local title=S.text(toast,"Title","NEW GEAR!",22,UDim2.fromOffset(12,6),UDim2.new(1,-24,0,28));title.TextColor3=Color3.fromHex("FFE56E")
 S.text(toast,"Available","You can now buy",13,UDim2.fromOffset(12,34),UDim2.new(1,-24,0,18))
 local name=S.text(toast,"GearName","",20,UDim2.fromOffset(12,54),UDim2.new(1,-24,0,24))
 local detail=S.text(toast,"Detail","",14,UDim2.fromOffset(12,82),UDim2.new(1,-118,0,32));detail.TextWrapped=true;detail.TextColor3=Color3.fromHex("B2FFAD")
 local visit=S.button(toast,"Visit","SHOP",UDim2.fromOffset(88,44),UDim2.new(1,-12,1,-12));visit.AnchorPoint=Vector2.new(1,1);visit.TextSize=18;S.gradient(visit,Color3.fromHex("9BE86E"),Color3.fromHex("39AB45"))
 local timer=Instance.new("Frame");timer.Name="TimeLeft";timer.BorderSizePixel=0;timer.BackgroundColor3=Color3.fromHex("FFD24A");timer.Position=UDim2.new(0,12,1,-5);timer.Size=UDim2.new(1,-24,0,3);timer.Parent=toast
 local offer: any=nil;local gear: any=nil;local pending=false;local resultUntil=0;local levelUntil=0;local flight=false;local lastCount=-1;local boostedUntil=0;local popUntil=0;local glow: Highlight?=nil;local rng=Random.new()
 local function placeBoost()
  local width,height=gui.AbsoluteSize.X,gui.AbsoluteSize.Y
  local x=rng:NextNumber(.4,.6)*width
  if gear then x=math.max(x,toast.Position.X.Offset+toast.AbsoluteSize.X+54)end
  boost.Position=UDim2.fromOffset(math.clamp(x,152,width-152),math.clamp(height*.56+rng:NextNumber(-18,18),154,math.max(154,height-76)))
 end
 boost.Activated:Connect(function()
  if not offer or pending or workspace:GetServerTimeNow()>=offer.ExpiresAt then return end
  pending=true;remotes.TrainingBoost:FireServer(offer.Id);offer=nil;popUntil=os.clock()+.22
  boostScale.Scale=.95;Tween:Create(boostScale,TweenInfo.new(.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1.3}):Play()
 end)
 visit.Activated:Connect(function()if gear then remotes.GearVisit:FireServer(gear.Kind,gear.Id);gear=nil end end)
 local function hidden(): boolean
  local playerGui=p.PlayerGui;local cars=playerGui:FindFirstChild("MyCars");local store=playerGui:FindFirstChild("TicketShop")
  local index=playerGui:FindFirstChild("CarIndex")
  return (cars~=nil and cars:GetAttribute("Open")==true)or(store~=nil and store:GetAttribute("Open")==true)or(index~=nil and index:GetAttribute("Open")==true)
 end
 local function feedback(kind: string,data: any)
  if kind=="Flight"then
   flight=true;biome.Text=tostring(data.Biome):upper();luck.Text=string.format("LUCK %.2fx",data.Luck)
   local count=math.floor(data.Luck*20);if count~=lastCount then lastCount=count;Audio.play("Counter",.95+math.min(data.Progress,1)*.15)end
  elseif kind=="FlightEnd"then flight=false;lastCount=-1
  elseif kind=="ThrowResult"then
   result.Text=(if data.Perfect then "PERFECT!  "else "")..string.format("%+.1f POWER",data.BonusPower);resultUntil=os.clock()+1.8
  elseif kind=="XP"then
   local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
   if root then Effects.popup(root,"+"..Rules.powerText(data.Amount).." XP",Color3.fromRGB(145,215,255),"XPPopup")end
   Audio.play("XP")
   if data.Levels>0 then levelUp.Text="LEVEL UP! Throw Power +"..Rules.powerText(data.Gain).."!";levelUntil=os.clock()+2.5;Audio.play("LevelUp")end
  elseif kind=="BoostOffer"then offer=data;pending=false;boostScale.Scale=1;popUntil=0;placeBoost();Audio.play("BoostOffer")
  elseif kind=="BoostStarted"then boostedUntil=data.Until;offer=nil;pending=false;Audio.play("Boost")
  elseif kind=="Gear"then gear=data;name.Text=data.Name;detail.Text="$"..Rules.powerText(data.Price).."  •  "..data.Effect;if offer then placeBoost()end;Audio.play("Toast")
  elseif kind=="GearOpen"then gear=nil;shop.openCategory(data.Kind)
  end
 end
 RunService.RenderStepped:Connect(function()
  local now=workspace:GetServerTimeNow();local phase=p:GetAttribute("ThrowPhase");local busy=p:GetAttribute("Throwing")==true or p:GetAttribute("CinematicActive")==true;local modal=hidden()
  biome.Visible=flight;luck.Visible=flight;result.Visible=os.clock()<resultUntil and phase~="Reveal"and phase~="Tow";levelUp.Visible=os.clock()<levelUntil and not busy and not modal
  xp.Visible=not busy and not modal
  local compact=gui.AbsoluteSize.Y<520
  if compact then levelUp.Visible=false end
  xp.Size=UDim2.fromOffset(math.clamp(gui.AbsoluteSize.X-(if compact then 300 else 220),220,720),28)
  toast.Size=UDim2.fromOffset(if compact then 244 else 340,if compact then 92 else 132);toast.Position=UDim2.fromOffset(12,112)
  title.TextSize=if compact then 18 else 22;toast.Available.Visible=not compact
  name.Position=UDim2.fromOffset(12,if compact then 27 else 54);name.Size=UDim2.new(1,-24,0,24);name.TextSize=if compact then 17 else 20
  detail.Position=UDim2.fromOffset(12,if compact then 54 else 82);detail.Size=UDim2.new(1,-110,0,32);detail.TextSize=if compact then 12 else 14
  visit.Size=UDim2.fromOffset(if compact then 80 else 88,44);visit.Position=UDim2.new(1,-8,1,-8)
  local value=p:GetAttribute("TrainingXP")or 0;local needed=p:GetAttribute("TrainingXPNeeded")or Config.Progression.XPPerLevel
  fill.Size=UDim2.fromScale(math.clamp(value/needed,0,1),1)
  xpText.Text=if compact and os.clock()<levelUntil then levelUp.Text else "Level "..tostring(p:GetAttribute("TrainingLevel")or 1).."   •   "..Rules.powerText(value).."/"..needed.." XP"
  xpText.TextSize=if compact and xp.AbsoluteSize.X<300 then 14 else 17
  xpText.TextColor3=if compact and os.clock()<levelUntil then Color3.fromHex("B2FFAD")else Color3.new(1,1,1)
  if offer and now>=offer.ExpiresAt then offer=nil;pending=false end
  local active=p:GetAttribute("TrainingActive")==true
  local boosting=now<boostedUntil and active
  boost.Visible=not busy and not modal and active and (offer~=nil or os.clock()<popUntil)
  boost.Size=UDim2.fromOffset(if compact then 84 else 92,if compact then 84 else 92)
  boost.Active=offer~=nil and not pending;boost.Text="2x"
  if p:GetAttribute("BoostTargetVisible")~=boost.Visible then p:SetAttribute("BoostTargetVisible",boost.Visible)end
  if boosting and p.Character and not glow then
   glow=Instance.new("Highlight");glow.Name="TrainingBoostGlow";glow.Adornee=p.Character;glow.FillColor=Color3.fromHex("FFE56E");glow.OutlineColor=Color3.fromHex("FFF4A0");glow.FillTransparency=.55;glow.OutlineTransparency=.15;glow.DepthMode=Enum.HighlightDepthMode.Occluded;glow.Parent=p.Character
  elseif not boosting and glow then glow:Destroy();glow=nil end
  if gear and now>=gear.ExpiresAt then gear=nil end
  toast.Visible=gear~=nil and not busy and not modal
  if gear then timer.Size=UDim2.fromOffset((toast.AbsoluteSize.X-24)*math.clamp((gear.ExpiresAt-now)/Config.Juice.ToastSeconds,0,1),3)end
 end)
 p.CharacterRemoving:Connect(function()offer=nil;popUntil=0;boostedUntil=0;if glow then glow:Destroy();glow=nil end end)
 biome.Visible=false;luck.Visible=false;result.Visible=false;levelUp.Visible=false;boost.Visible=false;toast.Visible=false
 return {feedback=feedback,gui=gui}
end
return UI

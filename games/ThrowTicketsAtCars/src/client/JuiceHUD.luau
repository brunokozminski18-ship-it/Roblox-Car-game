--!strict
-- Presentation only: XP, offers, boosts and rewards come from the server.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
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
 local boost=S.button(gui,"Boost","2x",UDim2.fromOffset(68,68),UDim2.new(1,-28,.58,0));boost.AnchorPoint=Vector2.new(1,.5);boost.TextSize=28;S.gradient(boost,Color3.fromHex("FFE568"),Color3.fromHex("E79321"))
 local boostHint=S.text(boost,"Hint","TAP!",13,UDim2.new(0,-8,1,2),UDim2.new(1,16,0,22));boostHint.TextXAlignment=Enum.TextXAlignment.Center
 local toast=Instance.new("Frame");toast.Name="GearToast";toast.Position=UDim2.fromOffset(16,48);toast.Size=UDim2.fromOffset(340,132);toast.BorderSizePixel=0;toast.BackgroundColor3=Color3.fromHex("16348F");toast.Parent=gui;S.corner(toast,16);S.stroke(toast,3)
 local title=S.text(toast,"Title","NEW GEAR!",22,UDim2.fromOffset(12,6),UDim2.new(1,-24,0,28));title.TextColor3=Color3.fromHex("FFE56E")
 S.text(toast,"Available","You can now buy",13,UDim2.fromOffset(12,34),UDim2.new(1,-24,0,18))
 local name=S.text(toast,"GearName","",20,UDim2.fromOffset(12,54),UDim2.new(1,-24,0,24))
 local detail=S.text(toast,"Detail","",14,UDim2.fromOffset(12,82),UDim2.new(1,-118,0,32));detail.TextWrapped=true;detail.TextColor3=Color3.fromHex("B2FFAD")
 local visit=S.button(toast,"Visit","SHOP",UDim2.fromOffset(88,44),UDim2.new(1,-12,1,-12));visit.AnchorPoint=Vector2.new(1,1);visit.TextSize=18;S.gradient(visit,Color3.fromHex("9BE86E"),Color3.fromHex("39AB45"))
 local timer=Instance.new("Frame");timer.Name="TimeLeft";timer.BorderSizePixel=0;timer.BackgroundColor3=Color3.fromHex("FFD24A");timer.Position=UDim2.new(0,12,1,-5);timer.Size=UDim2.new(1,-24,0,3);timer.Parent=toast
 local offer: any=nil;local gear: any=nil;local pending=false;local resultUntil=0;local levelUntil=0;local flight=false;local lastCount=-1;local boostedUntil=0
 boost.Activated:Connect(function()
  if not offer or pending or workspace:GetServerTimeNow()>=offer.ExpiresAt then return end
  pending=true;remotes.TrainingBoost:FireServer(offer.Id)
 end)
 visit.Activated:Connect(function()if gear then remotes.GearVisit:FireServer(gear.Kind,gear.Id);gear=nil end end)
 local function hidden(): boolean
  local playerGui=p.PlayerGui;local cars=playerGui:FindFirstChild("MyCars");local store=playerGui:FindFirstChild("TicketShop")
  return (cars~=nil and cars:GetAttribute("Open")==true)or(store~=nil and store:GetAttribute("Open")==true)
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
  elseif kind=="BoostOffer"then offer=data;pending=false;Audio.play("Toast")
  elseif kind=="BoostStarted"then boostedUntil=data.Until;offer=nil;pending=false;Audio.play("Boost")
  elseif kind=="Gear"then gear=data;name.Text=data.Name;detail.Text="$"..Rules.powerText(data.Price).."  •  "..data.Effect;Audio.play("Toast")
  elseif kind=="GearOpen"then gear=nil;shop.openCategory(data.Kind)
  end
 end
 RunService.RenderStepped:Connect(function()
  local now=workspace:GetServerTimeNow();local phase=p:GetAttribute("ThrowPhase");local busy=p:GetAttribute("Throwing")==true;local modal=hidden()
  biome.Visible=flight;luck.Visible=flight;result.Visible=os.clock()<resultUntil and phase~="Reveal"and phase~="Tow";levelUp.Visible=os.clock()<levelUntil and not busy and not modal
  xp.Visible=not busy and not modal
  xp.Size=UDim2.fromOffset(math.clamp(gui.AbsoluteSize.X-220,220,720),28)
  local value=p:GetAttribute("TrainingXP")or 0;local needed=p:GetAttribute("TrainingXPNeeded")or Config.Progression.XPPerLevel
  fill.Size=UDim2.fromScale(math.clamp(value/needed,0,1),1)
  xpText.Text="Level "..tostring(p:GetAttribute("TrainingLevel")or 1).."   •   "..Rules.powerText(value).."/"..needed.." XP"
  if offer and now>=offer.ExpiresAt then offer=nil;pending=false end
  local active=p:GetAttribute("TrainingActive")==true
  local boosting=now<boostedUntil and active
  boost.Visible=not busy and not modal and active and (offer~=nil or boosting)
  boost.Active=offer~=nil and not pending;boost.Text=if boosting then "2x!"else "2x";boostHint.Text=if boosting then string.format("%.1fs",math.max(0,boostedUntil-now))elseif pending then "..."else "TAP!"
  if gear and now>=gear.ExpiresAt then gear=nil end
  toast.Visible=gear~=nil and not busy and not modal
  if gear then timer.Size=UDim2.fromOffset((toast.AbsoluteSize.X-24)*math.clamp((gear.ExpiresAt-now)/Config.Juice.ToastSeconds,0,1),3)end
 end)
 biome.Visible=false;luck.Visible=false;result.Visible=false;levelUp.Visible=false;boost.Visible=false;toast.Visible=false
 return {feedback=feedback,gui=gui}
end
return UI

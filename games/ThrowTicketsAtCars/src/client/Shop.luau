--!strict
-- One UI sample in approved style D. Player-facing layout and balance: NOT FINAL.
local Players=game:GetService("Players")
local Tween=game:GetService("TweenService")
local GuiService=game:GetService("GuiService")
local RunService=game:GetService("RunService")
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local Rules=require(game.ReplicatedStorage.ThrowTickets.Rules)
local Shop={}
local function short(n: number): string
 for _,unit in {{1e12,"T"},{1e9,"B"},{1e6,"M"},{1e3,"K"}}do if n>=unit[1]then return string.format("%.1f%s",math.floor(n/unit[1]*10)/10,unit[2])end end
 return tostring(math.floor(n))
end
local items={}
for i,x in Config.Exercises do table.insert(items,{Kind="Exercise",Tier=i,Data=x})end
for i,x in Config.Tickets do table.insert(items,{Kind="Ticket",Tier=i,Data=x})end
local function isOwned(p,item)
 return if item.Kind=="Exercise"then (p:GetAttribute("Exercise")or 1)>=item.Tier else p:GetAttribute("Own_"..item.Data.Id)==true
end
local function isUnlocked(p,item)
 if isOwned(p,item)then return true end
 local previous=if item.Kind=="Exercise"then item.Tier==1 or (p:GetAttribute("Exercise")or 1)>=item.Tier-1 else item.Tier==1 or p:GetAttribute("Own_"..Config.Tickets[item.Tier-1].Id)==true
 return previous and Rules.biome(Rules.distance(p:GetAttribute("ThrowPower")or 0))>=item.Data.UnlockBiome
end
local function perk(item,power: number)
 local x=item.Data
 return if item.Kind=="Exercise"then "+"..Rules.powerText(Rules.trainingRate(power,item.Tier)*100).." XP/s | x"..x.Work elseif x.Luck>0 then string.format("+%d%% luck | x%g income",math.round(x.Luck*100),x.IncomeMultiplier)else "Standard odds"
end
local Style=require(script.Parent.Style)
local INK,FONT,Motion=Style.INK,Style.FONT,Style.Motion
local corner,stroke,gradient,text,button=Style.corner,Style.stroke,Style.gradient,Style.text,Style.button
local function ticketIcon(parent: Instance,color: Color3,size: number,pos: UDim2)
 local icon=Instance.new("Frame");icon.Name="TicketIcon";icon.Size,icon.Position=UDim2.fromOffset(size*.7,size),pos
 icon.BackgroundColor3,icon.BorderSizePixel,icon.Rotation=color,0,-12;corner(icon,5);stroke(icon,3);icon.Parent=parent
 for i=1,3 do local line=Instance.new("Frame");line.Size=UDim2.new(.65,0,0,3);line.Position=UDim2.fromScale(.17,.24+i*.13);line.BorderSizePixel,line.BackgroundColor3=0,INK;line.BackgroundTransparency=.3;line.Parent=icon end
 return icon
end
function Shop.mount(hud: ScreenGui,cash: IntValue,remote: RemoteEvent,feedback: RemoteEvent,launch: TextButton): any
 local p=Players.LocalPlayer
 local gui=Instance.new("ScreenGui");gui.Name,gui.ResetOnSpawn,gui.DisplayOrder="TicketShop",false,30
 gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;gui.SafeAreaCompatibility=Enum.SafeAreaCompatibility.None;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=p.PlayerGui
 local pulseScale=launch:FindFirstChildOfClass("UIScale")::UIScale
 local dim=Instance.new("TextButton");dim.Name="Dim";dim.Size=UDim2.fromScale(1,1);dim.Text="";dim.BackgroundColor3=INK;dim.BackgroundTransparency=.3;dim.Visible=false;dim.AutoButtonColor=false;dim.Parent=gui
 local panel=Instance.new("Frame");panel.Name="Window";panel.AnchorPoint,panel.Position=Vector2.new(.5,.5),UDim2.fromScale(.5,.5)
 panel.BorderSizePixel,panel.BackgroundColor3=0,Color3.new(1,1,1);panel.Visible=false;panel.Active=true;panel.Parent=gui;corner(panel,36);stroke(panel,5);gradient(panel,Color3.fromHex("2F7BF2"),Color3.fromHex("16348F"))
 local gloss=Instance.new("Frame");gloss.Name="Gloss";gloss.Size=UDim2.new(1,-16,0,60);gloss.Position=UDim2.fromOffset(8,4);gloss.BorderSizePixel=0;gloss.BackgroundColor3=Color3.new(1,1,1);gloss.BackgroundTransparency=.82;gloss.Parent=panel;corner(gloss,32)
 local gg=gradient(gloss,Color3.new(1,1,1),Color3.new(1,1,1));gg.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)})
 ticketIcon(panel,Config.Tickets[2].Color,60,UDim2.fromOffset(22,4))
 local title=text(panel,"Title","UPGRADES",36,UDim2.fromOffset(86,7),UDim2.new(1,-160,0,42))
 local balance=text(panel,"Balance","",18,UDim2.fromOffset(88,48),UDim2.new(1,-170,0,24));balance.TextColor3=Color3.fromHex("FFD24A")
 local close=button(panel,"Close","X",UDim2.fromOffset(52,52),UDim2.new(1,-18,0,8));close.AnchorPoint=Vector2.new(1,0)
 close.TextColor3=Color3.new(1,1,1);gradient(close,Color3.fromHex("FF6B6B"),Color3.fromHex("E0202F"))
 local category="Exercise"
 local trainingTab=button(panel,"TrainingTab","TRAINING",UDim2.new(1/3,-18,0,44),UDim2.fromOffset(18,76))
 local ticketTab=button(panel,"TicketsTab","TICKETS",UDim2.new(1/3,-18,0,44),UDim2.new(1/3,9,0,76))
 local freeTab=button(panel,"FreeCarTab","FREE CAR",UDim2.new(1/3,-18,0,44),UDim2.new(2/3,0,0,76));gradient(freeTab,Color3.fromHex("74E6FF"),Color3.fromHex("1E95F0"))
 local dot=Instance.new("Frame");dot.Name="FreeCarDot";dot.Size=UDim2.fromOffset(18,18);dot.Position=UDim2.new(1,-12,0,-3);dot.BackgroundColor3=Color3.fromHex("FF354F");dot.BorderSizePixel=0;dot.Visible=false;dot.Parent=launch;corner(dot,99);stroke(dot,2)
 local freePanel=Instance.new("Frame");freePanel.Name="FreeCar";freePanel.BackgroundTransparency=1;freePanel.Position=UDim2.fromOffset(20,132);freePanel.Size=UDim2.new(1,-40,1,-174);freePanel.Visible=false;freePanel.Parent=panel
 local freeName=text(freePanel,"Title","FREE RANDOM CAR",27,UDim2.fromScale(0,.02),UDim2.new(1,0,0,40));freeName.TextXAlignment=Enum.TextXAlignment.Center
 local freeBiome=text(freePanel,"Biome","",20,UDim2.fromScale(0,.27),UDim2.new(1,0,0,30));freeBiome.TextXAlignment=Enum.TextXAlignment.Center
 local freeCountdown=text(freePanel,"Countdown","",23,UDim2.fromScale(0,.48),UDim2.new(1,0,0,32));freeCountdown.TextXAlignment=Enum.TextXAlignment.Center;freeCountdown.TextColor3=Color3.fromHex("FFF4A0")
 local freeClaim=button(freePanel,"Claim","CLAIM",UDim2.new(.8,0,0,54),UDim2.new(.1,0,1,-58));gradient(freeClaim,Color3.fromHex("8CF27C"),Color3.fromHex("22B24A"));freeClaim.TextSize=25
 local freeRequest=0
 freeClaim.Activated:Connect(function()if os.clock()>=freeRequest and p:GetAttribute("FreeCarReady")==true and p:GetAttribute("ReturnBusy")~=true then freeRequest=os.clock()+.5;remote.Parent.ReturnClaim:FireServer("FreeCar")end end)
 gradient(trainingTab,Color3.fromHex("FFF4A0"),Color3.fromHex("FFD24A"));gradient(ticketTab,Color3.fromHex("74E6FF"),Color3.fromHex("1E95F0"))
 local list=Instance.new("ScrollingFrame");list.Name="Tickets";list.Position=UDim2.fromOffset(16,132);list.Size=UDim2.new(1,-32,1,-174)
 list.BackgroundTransparency,list.BorderSizePixel,list.ScrollBarThickness=1,0,6;list.ScrollBarImageColor3=Color3.fromHex("74E6FF")
 list.CanvasSize=UDim2.new();list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.ScrollingDirection=Enum.ScrollingDirection.Y;list.Parent=panel
 local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,8);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=list
 local padding=Instance.new("UIPadding");padding.PaddingTop,padding.PaddingBottom=UDim.new(0,4),UDim.new(0,4);padding.PaddingLeft=UDim.new(0,4);padding.PaddingRight=UDim.new(0,12);padding.Parent=list
 local notice=text(panel,"Notice","Training upgrades double your XP gain.",16,UDim2.new(0,22,1,-34),UDim2.new(1,-44,0,26));notice.TextXAlignment=Enum.TextXAlignment.Center
 local rows={};local opened=false;local pulse: Tween?=nil;local pulsing=false
 -- A narrow moving reflection clipped to the header surface.
 local shineLayer=Instance.new("Frame");shineLayer.Name="ShineLayer";shineLayer.Size=UDim2.fromScale(1,1);shineLayer.ClipsDescendants=true
 shineLayer.BackgroundTransparency=1;shineLayer.BorderSizePixel=0;shineLayer.Parent=gloss
 local shine=Instance.new("Frame");shine.Name="Shine";shine.AnchorPoint=Vector2.new(.5,.5);shine.Size=UDim2.new(.09,0,0,120)
 shine.Position=UDim2.fromScale(-.15,.5);shine.Rotation=22;shine.BackgroundColor3=Color3.new(1,1,1);shine.BorderSizePixel=0;shine.Visible=false;shine.Parent=shineLayer
 local shineGradient=gradient(shine,Color3.new(1,1,1),Color3.new(1,1,1))
 shineGradient.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.26,.75),NumberSequenceKeypoint.new(.52,.66),NumberSequenceKeypoint.new(.82,.86),NumberSequenceKeypoint.new(1,1)})
 local shineTween=Tween:Create(shine,TweenInfo.new(.85,Enum.EasingStyle.Linear),{Position=UDim2.fromScale(1.15,.5)})
 local nextShine=os.clock()+Config.Juice.ShineEvery
 local function stopShine()shineTween:Cancel();shine.Visible=false end
 -- Cancel also fires Completed; deferred cancellation must not hide a new sweep.
 shineTween.Completed:Connect(function(state: Enum.PlaybackState)
  if state==Enum.PlaybackState.Completed and shineTween.PlaybackState==Enum.PlaybackState.Completed then shine.Visible=false end
 end)
 for i,item in items do
  local t=item.Data
  local row=Instance.new("Frame");row.Name=t.Id;row.LayoutOrder=i;row.Size=UDim2.new(1,0,0,82);row.BorderSizePixel=0;row.BackgroundColor3=Color3.new(1,1,1);row.ClipsDescendants=true;row.Parent=list;corner(row,24);stroke(row,3)
  local g=gradient(row,Color3.fromHex("74E6FF"),Color3.fromHex("1E95F0"))
  local stripes=Instance.new("Frame");stripes.Name="Stripe";stripes.Size=UDim2.fromOffset(42,180);stripes.Position=UDim2.new(.55,0,.5,-90);stripes.Rotation=30;stripes.BackgroundColor3=Color3.new(1,1,1);stripes.BackgroundTransparency=.9;stripes.BorderSizePixel=0;stripes.Parent=row
  local icon=ticketIcon(row,t.Color or Color3.fromHex("D98BFF"),52,UDim2.fromOffset(20,15))
  local name=text(row,"Name",t.Name,23,UDim2.fromOffset(76,9),UDim2.new(1,-220,0,28))
  local perk=text(row,"Perk",perk(item,p:GetAttribute("ThrowPower")or 0),17,UDim2.fromOffset(76,40),UDim2.new(1,-220,0,26))
  local action=button(row,"Action","",UDim2.fromOffset(130,56),UDim2.new(1,-8,.5,0));action.AnchorPoint=Vector2.new(1,.5);action.TextSize=17
  local price=text(action,"Price","",22,UDim2.new(0,0,1,-29),UDim2.new(1,0,0,26));price.TextXAlignment=Enum.TextXAlignment.Center;price.TextStrokeTransparency=1;price.TextColor3=INK
  local lock=Instance.new("Frame");lock.Name="Lock";lock.Size=UDim2.fromOffset(20,24);lock.Position=UDim2.new(0,8,.5,-12);lock.BackgroundTransparency=1;lock.Parent=action
  local shackle=Instance.new("Frame");shackle.Size=UDim2.fromOffset(12,14);shackle.Position=UDim2.fromOffset(4,0);shackle.BackgroundTransparency=1;shackle.Parent=lock;corner(shackle,6);stroke(shackle,2,Color3.new(1,1,1))
  local lockBody=Instance.new("Frame");lockBody.Size=UDim2.fromOffset(18,13);lockBody.Position=UDim2.fromOffset(1,10);lockBody.BackgroundColor3=Color3.new(1,1,1);lockBody.BorderSizePixel=0;lockBody.Parent=lock;corner(lockBody,3)
  action.Activated:Connect(function()if not p:GetAttribute("DataReady")then return end;remote:FireServer(if item.Kind=="Exercise"then "Exercise"elseif p:GetAttribute("Own_"..t.Id)then "Equip"else "Buy",t.Id)end)
  rows[i]={root=row,gradient=g,action=action,price=price,name=name,perk=perk,icon=icon,lock=lock,stripes=stripes}
 end
 local function nextTicket(affordable: boolean?,kind: string?): number?
  for i,item in items do if (not kind or item.Kind==kind)and not isOwned(p,item)and isUnlocked(p,item)and(not affordable or cash.Value>=item.Data.Price)then return i end end;return nil
 end
 local function updatePulse()
  local index=nextTicket(true);local should=not opened and p:GetAttribute("DataReady")==true and index~=nil
  if should==pulsing then return end;pulsing=should
  if pulse then pulse:Cancel();pulse=nil end;pulseScale.Scale=1
  launch:SetAttribute("AffordableHint",should)
  launch.Text=if should then "SHOP!"else "SHOP"
  if should and not GuiService.ReducedMotionEnabled then pulse=Tween:Create(pulseScale,Motion.pulse,{Scale=1.06});pulse:Play()end
 end
 local function refresh()
  dot.Visible=p:GetAttribute("FreeCarReady")==true
  freePanel.Visible=category=="FreeCar";list.Visible=category~="FreeCar"
  local biome=Config.Biomes[p:GetAttribute("FreeCarBiome")or 1];freeBiome.Text="From "..biome.Name.." • Backpack space required"
  local remaining=math.max(0,(p:GetAttribute("FreeCarAt")or 0)-(p:GetAttribute("ReturnServerNow")or 0))
  freeCountdown.Text=if p:GetAttribute("FreeCarReady")==true then "Your free car is ready!"else string.format("Next free car in %02d:%02d",remaining//60,remaining%60)
  freeClaim.Text=if p:GetAttribute("ReturnBusy")==true then "CLAIMING..."elseif p:GetAttribute("FreeCarReady")==true then "CLAIM"else "NOT READY"
  freeClaim.Active=p:GetAttribute("DataReady")==true and p:GetAttribute("FreeCarReady")==true and p:GetAttribute("ReturnBusy")~=true
  balance.Text="CASH $"..short(cash.Value).."   •   POWER "..Rules.powerText(p:GetAttribute("ThrowPower")or 0)
  local nextIndex=nextTicket()
  for i,item in items do
   local t=item.Data
   local row=rows[i];row.root.Visible=item.Kind==category;local owned=isOwned(p,item);local equipped=if item.Kind=="Exercise"then p:GetAttribute("Exercise")==item.Tier else p:GetAttribute("EquippedTicket")==t.Id
   local unlocked=isUnlocked(p,item);local affordable=cash.Value>=t.Price
   local state=if equipped then "Equipped"elseif owned then "Owned"elseif not unlocked then "Locked"elseif affordable then "Affordable"else "Unaffordable"
   row.root:SetAttribute("State",state)
   row.action.Text=if equipped then "EQUIPPED"elseif owned then (if item.Kind=="Exercise"then "OWNED"else "EQUIP")elseif not unlocked then "LOCKED"else "BUY"
   row.action.TextYAlignment=if owned or not unlocked then Enum.TextYAlignment.Center else Enum.TextYAlignment.Top
   row.price.Text="$"..short(t.Price);row.price.Visible=not owned and unlocked
   row.price.TextColor3=if affordable then Color3.fromHex("087D38")else Color3.fromHex("C52E41")
   row.lock.Visible=not unlocked
   row.action.BackgroundColor3=if not unlocked then Color3.fromHex("34436B")else Color3.new(1,1,1)
   row.action.TextColor3=if not unlocked then Color3.new(1,1,1)elseif equipped then Color3.fromHex("087D38")else INK
   row.gradient.Color=if equipped then ColorSequence.new(Color3.fromHex("8CF27C"),Color3.fromHex("22B24A"))elseif state=="Affordable"then ColorSequence.new(Color3.fromHex("FFFBE9"),Color3.fromHex("FFE9A0"))elseif state=="Locked"then ColorSequence.new(Color3.fromHex("344B86"),Color3.fromHex("243668"))else ColorSequence.new(Color3.fromHex("74E6FF"),Color3.fromHex("1E95F0"))
   row.name.TextColor3=if unlocked then Color3.new(1,1,1)else Color3.fromHex("BFCBE1")
   row.icon.BackgroundColor3=if unlocked then(t.Color or Color3.fromHex("D98BFF"))else(t.Color or Color3.fromHex("D98BFF")):Lerp(INK,.55)
   row.stripes.BackgroundTransparency=if unlocked then .9 else .97
   if not unlocked then
    local previous=if item.Kind=="Exercise"then Config.Exercises[item.Tier-1]else Config.Tickets[item.Tier-1]
    local previousOwned=if item.Kind=="Exercise"then (p:GetAttribute("Exercise")or 1)>=item.Tier-1 else previous==nil or p:GetAttribute("Own_"..previous.Id)==true
    row.perk.Text=if previous and not previousOwned then "Buy "..previous.Name.." first"else "Reach "..Config.Biomes[t.UnlockBiome].Name.." first"
   else row.perk.Text=perk(item,p:GetAttribute("ThrowPower")or 0)end

  end
  updatePulse()
 end
 local function setOpen(value: boolean)
  opened=value;dim.Visible,panel.Visible=value,value;gui:SetAttribute("Open",value)
  stopShine();nextShine=os.clock()+Config.Juice.ShineEvery
  if value then
   refresh();GuiService.SelectedObject=if game:GetService("UserInputService"):GetLastInputType().Name:find("Gamepad")then close else nil
   task.defer(function()
    game:GetService("RunService").RenderStepped:Wait()
    local index=nextTicket(nil,category);local tier=if index then items[index].Tier else 1
    list.CanvasPosition=Vector2.new(0,math.min(math.max(0,list.AbsoluteCanvasSize.Y-list.AbsoluteSize.Y),math.max(0,(tier-1)*90)))
   end)
  else GuiService.SelectedObject=nil end
  updatePulse()
 end
 local function resize()
  panel.Size=UDim2.fromOffset(math.min(760,gui.AbsoluteSize.X-32),math.min(662,gui.AbsoluteSize.Y-24))
  local compact=gui.AbsoluteSize.Y<520
  freeName.Visible=not compact
  freeBiome.Position=if compact then UDim2.fromOffset(0,0)else UDim2.fromScale(0,.27)
  freeCountdown.Position=if compact then UDim2.fromOffset(0,30)else UDim2.fromScale(0,.48)
  freeCountdown.Size=UDim2.new(1,0,0,if compact then 26 else 32)
  freeBiome.TextSize=if compact then 16 else 20
  title.TextSize=if gui.AbsoluteSize.Y<400 then 30 else 40
  for _,row in rows do row.name.TextSize=if gui.AbsoluteSize.X<600 then 20 else 23;row.perk.TextSize=if gui.AbsoluteSize.X<600 then 15 else 17 end
 end
 local function chooseCategory(kind: string)
  category=kind
  for _,entry in {{trainingTab,"Exercise"},{ticketTab,"Ticket"},{freeTab,"FreeCar"}}do
   local active=kind==entry[2];local g=entry[1]:FindFirstChildOfClass("UIGradient")
   g.Color=if active then ColorSequence.new(Color3.fromHex("FFF4A0"),Color3.fromHex("FFD24A"))else ColorSequence.new(Color3.fromHex("74E6FF"),Color3.fromHex("1E95F0"))
   entry[1]:SetAttribute("Selected",active)
  end
  notice.Text=if kind=="Exercise"then "Training upgrades double your XP gain."elseif kind=="FreeCar"then string.format("A free random car every %d minutes. No purchase needed.",Config.Returns.FreeCarSeconds/60)else "Tickets boost luck and captured income."
  list.CanvasPosition=Vector2.zero;refresh()
 end
 local function openCategory(kind: string)
  if kind=="Gear"or kind=="Training"then kind="Exercise"end
  if kind~="Exercise"and kind~="Ticket"and kind~="FreeCar"then return end
  chooseCategory(kind);setOpen(true)
 end
 trainingTab.Activated:Connect(function()chooseCategory("Exercise")end)
 ticketTab.Activated:Connect(function()chooseCategory("Ticket")end)
 freeTab.Activated:Connect(function()chooseCategory("FreeCar")end)
 chooseCategory("Exercise")
 launch.Activated:Connect(function()setOpen(not opened)end);close.Activated:Connect(function()setOpen(false)end);dim.Activated:Connect(function()setOpen(false)end)
 feedback.OnClientEvent:Connect(function(value)if opened then notice.Text=value end end)
 cash.Changed:Connect(refresh)
 for _,attribute in {"EquippedTicket","Exercise","ThrowPower","DataReady","FreeCarAt","FreeCarReady","FreeCarBiome","ReturnServerNow","ReturnBusy"}do p:GetAttributeChangedSignal(attribute):Connect(refresh)end
 p:GetAttributeChangedSignal("Throwing"):Connect(function()if p:GetAttribute("Throwing")==true then setOpen(false)end end)
 for _,t in Config.Tickets do p:GetAttributeChangedSignal("Own_"..t.Id):Connect(refresh)end
 GuiService:GetPropertyChangedSignal("ReducedMotionEnabled"):Connect(function()stopShine();nextShine=os.clock()+Config.Juice.ShineEvery;pulsing=not pulsing;updatePulse()end)
 local shineConnection=RunService.Heartbeat:Connect(function()
  if not opened or GuiService.ReducedMotionEnabled or os.clock()<nextShine then return end
  nextShine=os.clock()+Config.Juice.ShineEvery
  shineTween:Cancel();shine.Position=UDim2.fromScale(-.15,.5);shine.Visible=true;shineTween:Play()
 end)
 gui.Destroying:Connect(function()shineConnection:Disconnect();stopShine();shineTween:Destroy()end)
 gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize);resize();refresh()
 return {isOpen=function()return opened end,close=function()setOpen(false)end,openCategory=openCategory}
end
return Shop

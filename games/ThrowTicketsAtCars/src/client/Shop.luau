--!strict
-- One UI sample in approved style D. Player-facing layout and balance: NOT FINAL.
local Players=game:GetService("Players")
local Tween=game:GetService("TweenService")
local GuiService=game:GetService("GuiService")
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local Rules=require(game.ReplicatedStorage.ThrowTickets.Rules)
local Shop={}
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
 local title=text(panel,"Title","TICKET SHOP",36,UDim2.fromOffset(86,7),UDim2.new(1,-160,0,42))
 local balance=text(panel,"Balance","",18,UDim2.fromOffset(88,48),UDim2.new(1,-170,0,24));balance.TextColor3=Color3.fromHex("FFD24A")
 local close=button(panel,"Close","X",UDim2.fromOffset(52,52),UDim2.new(1,-18,0,8));close.AnchorPoint=Vector2.new(1,0)
 close.TextColor3=Color3.new(1,1,1);gradient(close,Color3.fromHex("FF6B6B"),Color3.fromHex("E0202F"))
 local list=Instance.new("ScrollingFrame");list.Name="Tickets";list.Position=UDim2.fromOffset(16,80);list.Size=UDim2.new(1,-32,1,-122)
 list.BackgroundTransparency,list.BorderSizePixel,list.ScrollBarThickness=1,0,6;list.ScrollBarImageColor3=Color3.fromHex("74E6FF")
 list.CanvasSize=UDim2.new();list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.ScrollingDirection=Enum.ScrollingDirection.Y;list.Parent=panel
 local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,8);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=list
 local padding=Instance.new("UIPadding");padding.PaddingTop,padding.PaddingBottom=UDim.new(0,4),UDim.new(0,4);padding.PaddingLeft=UDim.new(0,4);padding.PaddingRight=UDim.new(0,12);padding.Parent=list
 local notice=text(panel,"Notice","Luck boosts Rare+ weights. Buy, then EQUIP.",16,UDim2.new(0,22,1,-34),UDim2.new(1,-44,0,26));notice.TextXAlignment=Enum.TextXAlignment.Center
 local rows={};local opened=false;local pulse: Tween?=nil;local pulsing=false
 for i,t in Config.Tickets do
  local row=Instance.new("Frame");row.Name=t.Id;row.LayoutOrder=i;row.Size=UDim2.new(1,0,0,82);row.BorderSizePixel=0;row.BackgroundColor3=Color3.new(1,1,1);row.ClipsDescendants=true;row.Parent=list;corner(row,24);stroke(row,3)
  local g=gradient(row,Color3.fromHex("74E6FF"),Color3.fromHex("1E95F0"))
  local stripes=Instance.new("Frame");stripes.Name="Stripe";stripes.Size=UDim2.fromOffset(42,180);stripes.Position=UDim2.new(.55,0,.5,-90);stripes.Rotation=30;stripes.BackgroundColor3=Color3.new(1,1,1);stripes.BackgroundTransparency=.9;stripes.BorderSizePixel=0;stripes.Parent=row
  local icon=ticketIcon(row,t.Color,52,UDim2.fromOffset(20,15))
  local name=text(row,"Name",t.Name,23,UDim2.fromOffset(76,9),UDim2.new(1,-220,0,28))
  local perk=text(row,"Perk",(if t.Luck>0 then string.format("+%d%% luck",math.round(t.Luck*100))else "Standard odds"),17,UDim2.fromOffset(76,40),UDim2.new(1,-220,0,26))
  local action=button(row,"Action","",UDim2.fromOffset(130,56),UDim2.new(1,-8,.5,0));action.AnchorPoint=Vector2.new(1,.5);action.TextSize=17
  local price=text(action,"Price","",22,UDim2.new(0,0,1,-29),UDim2.new(1,0,0,26));price.TextXAlignment=Enum.TextXAlignment.Center;price.TextStrokeTransparency=1;price.TextColor3=INK
  local lock=Instance.new("Frame");lock.Name="Lock";lock.Size=UDim2.fromOffset(20,24);lock.Position=UDim2.new(0,8,.5,-12);lock.BackgroundTransparency=1;lock.Parent=action
  local shackle=Instance.new("Frame");shackle.Size=UDim2.fromOffset(12,14);shackle.Position=UDim2.fromOffset(4,0);shackle.BackgroundTransparency=1;shackle.Parent=lock;corner(shackle,6);stroke(shackle,2,Color3.new(1,1,1))
  local lockBody=Instance.new("Frame");lockBody.Size=UDim2.fromOffset(18,13);lockBody.Position=UDim2.fromOffset(1,10);lockBody.BackgroundColor3=Color3.new(1,1,1);lockBody.BorderSizePixel=0;lockBody.Parent=lock;corner(lockBody,3)
  action.Activated:Connect(function()if not p:GetAttribute("DataReady")then return end;remote:FireServer(if p:GetAttribute("Own_"..t.Id)then "Equip"else "Buy",t.Id)end)
  rows[i]={root=row,gradient=g,action=action,price=price,name=name,perk=perk,icon=icon,lock=lock,stripes=stripes,pulsing=false}
 end
 local function nextTicket(): number?
  for i,t in Config.Tickets do if not p:GetAttribute("Own_"..t.Id)then return i end end;return nil
 end
 local function buyPulses()
  for _,row in rows do
   local active=opened and row.root:GetAttribute("State")=="Affordable"and not GuiService.ReducedMotionEnabled
   row.action:SetAttribute("Pulsing",active)
   if row.pulsing~=active then
    row.pulsing=active;if row.pulse then row.pulse:Cancel();row.pulse=nil end
    row.action.BackgroundColor3=if row.root:GetAttribute("State")=="Locked"then Color3.fromHex("34436B")else Color3.new(1,1,1)
    if active then row.pulse=Tween:Create(row.action,Motion.pulse,{BackgroundColor3=Color3.fromHex("B9FFB0")});row.pulse:Play()end
   end
  end
 end
 local function updatePulse()
  buyPulses()
  local index=nextTicket();local should=not opened and p:GetAttribute("DataReady")==true and index~=nil and cash.Value>=Config.Tickets[index].Price
  if should==pulsing then return end;pulsing=should
  if pulse then pulse:Cancel();pulse=nil end;pulseScale.Scale=1
  launch:SetAttribute("AffordableHint",should)
  launch.Text=if should then "SHOP!"else "SHOP"
  if should and not GuiService.ReducedMotionEnabled then pulse=Tween:Create(pulseScale,Motion.pulse,{Scale=1.06});pulse:Play()end
 end
 local function refresh()
  balance.Text="CASH $"..tostring(cash.Value).."   •   POWER "..tostring(p:GetAttribute("ThrowPower")or 0)
  local nextIndex=nextTicket()
  for i,t in Config.Tickets do
   local row=rows[i];local owned=p:GetAttribute("Own_"..t.Id)==true;local equipped=p:GetAttribute("EquippedTicket")==t.Id
   local unlocked=owned or i==nextIndex;local affordable=cash.Value>=t.Price
   local state=if equipped then "Equipped"elseif owned then "Owned"elseif not unlocked then "Locked"elseif affordable then "Affordable"else "Unaffordable"
   row.root:SetAttribute("State",state)
   row.action.Text=if equipped then "EQUIPPED"elseif owned then "EQUIP"elseif not unlocked then "LOCKED"else "BUY"
   row.action.TextYAlignment=if owned or not unlocked then Enum.TextYAlignment.Center else Enum.TextYAlignment.Top
   row.price.Text="$"..tostring(t.Price);row.price.Visible=not owned and unlocked
   row.price.TextColor3=if affordable then Color3.fromHex("087D38")else Color3.fromHex("C52E41")
   row.lock.Visible=not unlocked
   row.action.BackgroundColor3=if not unlocked then Color3.fromHex("34436B")else Color3.new(1,1,1)
   row.action.TextColor3=if not unlocked then Color3.new(1,1,1)elseif equipped then Color3.fromHex("087D38")else INK
   row.gradient.Color=if equipped then ColorSequence.new(Color3.fromHex("8CF27C"),Color3.fromHex("22B24A"))elseif state=="Affordable"then ColorSequence.new(Color3.fromHex("FFFBE9"),Color3.fromHex("FFE9A0"))elseif state=="Locked"then ColorSequence.new(Color3.fromHex("344B86"),Color3.fromHex("243668"))else ColorSequence.new(Color3.fromHex("74E6FF"),Color3.fromHex("1E95F0"))
   row.name.TextColor3=if unlocked then Color3.new(1,1,1)else Color3.fromHex("BFCBE1")
   row.icon.BackgroundColor3=if unlocked then t.Color else t.Color:Lerp(INK,.55)
   row.stripes.BackgroundTransparency=if unlocked then .9 else .97
   row.perk.Text=if not unlocked then "Buy "..Config.Tickets[i-1].Name.." first"elseif t.Luck>0 then string.format("+%d%% luck",math.round(t.Luck*100))else "Standard odds"

  end
  updatePulse()
 end
 local function setOpen(value: boolean)
  opened=value;dim.Visible,panel.Visible=value,value;gui:SetAttribute("Open",value)
  if value then
   refresh();GuiService.SelectedObject=if game:GetService("UserInputService"):GetLastInputType().Name:find("Gamepad")then close else nil
   task.defer(function()
    game:GetService("RunService").RenderStepped:Wait()
    local index=nextTicket()or select(2,Rules.ticket(p:GetAttribute("EquippedTicket")))
    list.CanvasPosition=Vector2.new(0,math.min(math.max(0,list.AbsoluteCanvasSize.Y-list.AbsoluteSize.Y),math.max(0,(index-1)*90)))
   end)
  else GuiService.SelectedObject=nil end
  updatePulse()
 end
 local function resize()
  panel.Size=UDim2.fromOffset(math.min(760,gui.AbsoluteSize.X-32),math.min(662,gui.AbsoluteSize.Y-24))
  title.TextSize=if gui.AbsoluteSize.Y<400 then 30 else 40
  for _,row in rows do row.name.TextSize=if gui.AbsoluteSize.X<600 then 20 else 23;row.perk.TextSize=if gui.AbsoluteSize.X<600 then 15 else 17 end
 end
 launch.Activated:Connect(function()setOpen(not opened)end);close.Activated:Connect(function()setOpen(false)end);dim.Activated:Connect(function()setOpen(false)end)
 feedback.OnClientEvent:Connect(function(value)if opened then notice.Text=value end end)
 cash.Changed:Connect(refresh)
 for _,attribute in {"EquippedTicket","ThrowPower","DataReady"}do p:GetAttributeChangedSignal(attribute):Connect(refresh)end
 for _,t in Config.Tickets do p:GetAttributeChangedSignal("Own_"..t.Id):Connect(refresh)end
 GuiService:GetPropertyChangedSignal("ReducedMotionEnabled"):Connect(function()pulsing=not pulsing;updatePulse()end)
 gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize);resize();refresh()
 return {isOpen=function()return opened end,close=function()setOpen(false)end}
end
return Shop

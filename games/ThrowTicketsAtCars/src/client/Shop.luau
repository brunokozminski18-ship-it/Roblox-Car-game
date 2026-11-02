--!strict
-- One UI sample in approved style D. Player-facing layout and balance: NOT FINAL.
local Players=game:GetService("Players")
local Tween=game:GetService("TweenService")
local GuiService=game:GetService("GuiService")
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local Rules=require(game.ReplicatedStorage.ThrowTickets.Rules)
local Shop={}
local INK=Color3.fromHex("14102A")
local FONT=Enum.Font.FredokaOne
local Motion={press=TweenInfo.new(.12),open=TweenInfo.new(.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),pulse=TweenInfo.new(.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true)}
local function corner(o: Instance,r: number)local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r);c.Parent=o end
local function stroke(o: Instance,n: number,color: Color3?)local s=Instance.new("UIStroke");s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;s.Thickness,s.Color=n,color or INK;s.Parent=o;return s end
local function gradient(o: Instance,a: Color3,b: Color3)local g=Instance.new("UIGradient");g.Rotation,g.Color=90,ColorSequence.new(a,b);g.Parent=o;return g end
local function text(parent: Instance,name: string,value: string,size: number,pos: UDim2,dim: UDim2): TextLabel
 local t=Instance.new("TextLabel");t.Name,t.Text,t.TextSize=name,value,size;t.Font=FONT
 t.Size,t.Position,t.BackgroundTransparency=dim,pos,1;t.TextColor3=Color3.new(1,1,1);t.TextStrokeColor3,t.TextStrokeTransparency=INK,.15
 t.TextXAlignment=Enum.TextXAlignment.Left;t.Active=false;t.Parent=parent;return t
end
local function button(parent: Instance,name: string,caption: string,size: UDim2,pos: UDim2): TextButton
 local b=Instance.new("TextButton");b.Name,b.Text,b.Size,b.Position=name,caption,size,pos
 b.Font,b.TextSize=FONT,20;b.TextColor3,b.BackgroundColor3=INK,Color3.new(1,1,1)
 b.BorderSizePixel,b.AutoButtonColor=0,false;corner(b,999);stroke(b,3);b.Parent=parent
 -- Gradients tint a TextButton's own glyphs too. Keep the caption in a child.
 b.TextTransparency=1
 local captionLabel=Instance.new("TextLabel");captionLabel.Name="Caption";captionLabel.Size=UDim2.fromScale(1,1);captionLabel.BackgroundTransparency=1;captionLabel.Active=false;captionLabel.Parent=b
 local function syncCaption()
  for _,property in {"Text","Font","TextSize","TextColor3","TextStrokeColor3","TextStrokeTransparency","TextYAlignment"}do (captionLabel::any)[property]=(b::any)[property]end
 end
 for _,property in {"Text","TextSize","TextColor3","TextStrokeColor3","TextStrokeTransparency","TextYAlignment"}do b:GetPropertyChangedSignal(property):Connect(syncCaption)end
 syncCaption()
 local scale=Instance.new("UIScale");scale.Parent=b
 b.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then Tween:Create(scale,Motion.press,{Scale=.96}):Play()end end)
 b.InputEnded:Connect(function()Tween:Create(scale,Motion.press,{Scale=1}):Play()end)
 return b
end
local function ticketIcon(parent: Instance,color: Color3,size: number,pos: UDim2)
 local icon=Instance.new("Frame");icon.Name="TicketIcon";icon.Size,icon.Position=UDim2.fromOffset(size*.7,size),pos
 icon.BackgroundColor3,icon.BorderSizePixel,icon.Rotation=color,0,-12;corner(icon,5);stroke(icon,3);icon.Parent=parent
 for i=1,3 do local line=Instance.new("Frame");line.Size=UDim2.new(.65,0,0,3);line.Position=UDim2.fromScale(.17,.24+i*.13);line.BorderSizePixel,line.BackgroundColor3=0,INK;line.BackgroundTransparency=.3;line.Parent=icon end
 return icon
end
function Shop.mount(hud: ScreenGui,cash: IntValue,remote: RemoteEvent,feedback: RemoteEvent): any
 local p=Players.LocalPlayer
 local gui=Instance.new("ScreenGui");gui.Name,gui.ResetOnSpawn,gui.DisplayOrder="TicketShop",false,30
 gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;gui.SafeAreaCompatibility=Enum.SafeAreaCompatibility.None;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=p.PlayerGui
 local launch=button(hud,"Shop","SHOP",UDim2.fromOffset(110,62),UDim2.new(1,-132,1,-98));launch.AnchorPoint=Vector2.new(1,1)
 launch.TextColor3=Color3.new(1,1,1);launch.TextStrokeColor3,launch.TextStrokeTransparency=INK,.15
 gradient(launch,Color3.fromHex("FF86CF"),Color3.fromHex("E2338C"))
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
  ticketIcon(row,t.Color,52,UDim2.fromOffset(20,15))
  local name=text(row,"Name",t.Name,23,UDim2.fromOffset(76,9),UDim2.new(1,-204,0,28))
  local perk=text(row,"Perk",string.format("x%g distance  |  +%d%% luck",t.Multiplier,math.round(t.Luck*100)),17,UDim2.fromOffset(76,40),UDim2.new(1,-204,0,26))
  local action=button(row,"Action","",UDim2.fromOffset(118,52),UDim2.new(1,-8,.5,0));action.AnchorPoint=Vector2.new(1,.5);action.TextSize=17
  local price=text(action,"Price","",14,UDim2.new(0,0,1,-18),UDim2.new(1,0,0,18));price.TextXAlignment=Enum.TextXAlignment.Center;price.TextStrokeTransparency=1;price.TextColor3=INK
  action.Activated:Connect(function()if not p:GetAttribute("DataReady")then return end;remote:FireServer(if p:GetAttribute("Own_"..t.Id)then "Equip"else "Buy",t.Id)end)
  rows[i]={root=row,gradient=g,action=action,price=price,name=name,perk=perk}
 end
 local function nextTicket(): number?
  for i,t in Config.Tickets do if not p:GetAttribute("Own_"..t.Id)then return i end end;return nil
 end
 local function updatePulse()
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
   row.action.Text=if equipped then "EQUIPPED"elseif owned then "EQUIP"elseif not unlocked then "LOCKED"else "BUY"
   row.action.TextYAlignment=if owned then Enum.TextYAlignment.Center else Enum.TextYAlignment.Top
   row.price.Text=if owned then ""else "$"..tostring(t.Price);row.price.Visible=not owned
   row.action.BackgroundColor3=if equipped then Color3.fromHex("FFD24A")elseif unlocked and (owned or affordable)then Color3.new(1,1,1)else Color3.fromHex("B7CDE9")
   row.gradient.Color=if owned then ColorSequence.new(Color3.fromHex("8CF27C"),Color3.fromHex("22B24A"))elseif i==nextIndex then ColorSequence.new(Color3.fromHex("FF86CF"),Color3.fromHex("E2338C"))else ColorSequence.new(Color3.fromHex("74E6FF"),Color3.fromHex("1E95F0"))
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

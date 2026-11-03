--!strict
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local S=require(script.Parent.Style)
local Preview=require(script.Parent.CarPreview)
local View={}
function View.mount(parent: Instance,onAction: (string,string)->()): any
 local gui=Instance.new("ScreenGui");gui.Name="MyCars";gui.ResetOnSpawn=false;gui.DisplayOrder=35
 gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Parent=parent
 local dim=Instance.new("TextButton");dim.Name="Dim";dim.Size=UDim2.fromScale(1,1);dim.Text="";dim.BackgroundColor3=S.INK;dim.BackgroundTransparency=.3;dim.Parent=gui
 local panel=Instance.new("Frame");panel.Name="Window";panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.5);panel.BackgroundColor3=Color3.new(1,1,1);panel.BorderSizePixel=0;panel.Parent=gui
 S.corner(panel,28);S.stroke(panel,4);S.gradient(panel,Color3.fromHex("2F7BF2"),Color3.fromHex("16348F"))
 local title=S.text(panel,"Title","MY CARS",30,UDim2.fromOffset(20,4),UDim2.new(1,-96,0,38))
 local count=S.text(panel,"Counts","PARKED 0/6   |   INVENTORY 0/20",16,UDim2.fromOffset(20,40),UDim2.new(1,-90,0,24));count.TextColor3=Color3.fromHex("FFD24A")
 local close=S.button(panel,"Close","X",UDim2.fromOffset(48,48),UDim2.new(1,-60,0,10));S.gradient(close,Color3.fromHex("FF6B6B"),Color3.fromHex("E0202F"))
 local list=Instance.new("ScrollingFrame");list.Name="Cars";list.Position=UDim2.fromOffset(14,70);list.Size=UDim2.new(1,-28,1,-140);list.BackgroundTransparency=1;list.BorderSizePixel=0;list.ScrollBarThickness=5;list.AutomaticCanvasSize=Enum.AutomaticSize.Y;list.CanvasSize=UDim2.new();list.Parent=panel
 local layout=Instance.new("UIListLayout");layout.Padding=UDim.new(0,8);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=list
 local pad=Instance.new("UIPadding");pad.PaddingLeft=UDim.new(0,4);pad.PaddingRight=UDim.new(0,10);pad.PaddingTop=UDim.new(0,4);pad.PaddingBottom=UDim.new(0,4);pad.Parent=list
 local best=S.button(panel,"EquipBest","EQUIP BEST",UDim2.new(1,-36,0,48),UDim2.new(0,18,1,-60));S.gradient(best,Color3.fromHex("FFF4A0"),Color3.fromHex("FFD24A"));best.TextSize=26
 local empty=S.text(list,"Empty","Catch a car on the throw pad!",20,UDim2.new(),UDim2.new(1,0,0,70));empty.TextXAlignment=Enum.TextXAlignment.Center
 local confirm=S.button(panel,"ConfirmSale","",UDim2.new(1,-36,0,58),UDim2.new(0,18,1,-66));confirm.Visible=false;confirm.TextSize=18;S.gradient(confirm,Color3.fromHex("FF86CF"),Color3.fromHex("E2338C"))
 local rows={};local sale=nil
 local function open(value: boolean)gui.Enabled=value;gui:SetAttribute("Open",value);sale=nil;confirm.Visible=false;best.Visible=true end
 local function resize()panel.Size=UDim2.fromOffset(math.min(720,gui.AbsoluteSize.X-28),math.min(570,gui.AbsoluteSize.Y-20));title.TextSize=if gui.AbsoluteSize.X<600 then 26 else 30 end
 gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize);resize()
 close.Activated:Connect(function()open(false)end);dim.Activated:Connect(function()open(false)end)
 best.Activated:Connect(function()onAction("EquipBest","")end)
 confirm.Activated:Connect(function()if sale then onAction("ConfirmSell",sale.Id);sale=nil;confirm.Visible=false;best.Visible=true end end)
 open(false)
 return {gui=gui,open=open,isOpen=function()return gui.Enabled end,
 confirm=function(car: any,price: number) sale=car;confirm.Text="CONFIRM SELL "..car.Name.." FOR $"..price;confirm.Visible=true;best.Visible=false end,
 render=function(cars: {any},inventory: number)
  local retained={};local parked=0;for _,c in cars do if c.Slot>0 then parked+=1 end end
  count.Text=string.format("PARKED %d/%d   |   INVENTORY %d/%d",parked,Config.ParkingSlots,inventory,Config.InventoryLimit)
  empty.Visible=#cars==0
  for i,c in cars do
   retained[c.Id]=true;local row=rows[c.Id]
   if not row then
    local frame=Instance.new("Frame");frame.Name=c.Id;frame.Size=UDim2.new(1,0,0,104);frame.BackgroundColor3=Color3.new(1,1,1);frame.BorderSizePixel=0;frame.Parent=list;S.corner(frame,20);S.stroke(frame,2);S.gradient(frame,Color3.fromHex("74E6FF"),Color3.fromHex("1E95F0"))
    local icon=Instance.new("Frame");icon.Name="Icon";icon.Size=UDim2.fromOffset(86,86);icon.Position=UDim2.fromOffset(8,9);icon.BackgroundTransparency=.75;icon.BackgroundColor3=S.INK;icon.Parent=frame;S.corner(icon,16);Preview.mount(icon,c)
    local name=S.text(frame,"Name",c.Name,21,UDim2.fromOffset(102,6),UDim2.new(1,-220,0,26));name.TextTruncate=Enum.TextTruncate.AtEnd
    local rarity=S.text(frame,"Rarity",Config.Rarities[c.Rarity].Name:upper(),15,UDim2.fromOffset(102,34),UDim2.new(1,-220,0,22));rarity.TextColor3=Config.Rarities[c.Rarity].Color
    local income=S.text(frame,"Income","$"..c.Income.."/s",23,UDim2.fromOffset(102,59),UDim2.new(1,-220,0,30));income.TextColor3=Color3.fromHex("B2FFAD")
    local action=S.button(frame,"Action","PLACE",UDim2.fromOffset(102,44),UDim2.new(1,-110,0,5));action.TextSize=16;S.gradient(action,Color3.fromHex("8CF27C"),Color3.fromHex("22B24A"))
    local sell=S.button(frame,"Sell","SELL",UDim2.fromOffset(102,44),UDim2.new(1,-110,0,55));sell.TextSize=17;S.gradient(sell,Color3.fromHex("FF86CF"),Color3.fromHex("E2338C"))
    row={frame=frame,action=action,car=c};rows[c.Id]=row
    action.Activated:Connect(function()onAction(if row.car.Slot>0 then "Remove"else "Equip",c.Id)end)
    sell.Activated:Connect(function()onAction("Sell",c.Id)end)
   end
   row.car=c;row.frame.LayoutOrder=i;row.action.Text=if c.Slot>0 then "PICK UP"else "PLACE"
  end
  for id,row in rows do if not retained[id]then row.frame:Destroy();rows[id]=nil end end
 end}
end
return View

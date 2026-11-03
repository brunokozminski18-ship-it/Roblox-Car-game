--!strict
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local StarterGui=game:GetService("StarterGui")
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local S=require(script.Parent.Style)
local Preview=require(script.Parent.CarPreview)
local Inventory={}
function Inventory.mount(world: Instance,garage: RemoteEvent,snapshots: RemoteEvent,confirmSale: RemoteEvent,launch: TextButton,indexView: any): any
 local p=Players.LocalPlayer;local playerGui=p:WaitForChild("PlayerGui")
 task.spawn(function()for _=1,20 do local ok=pcall(function()StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false)end);if ok then break end;task.wait(.2)end end)
 local cars,byId,hotbars={},{},{};local token=nil;local lastRequest=-math.huge
 local view: any
 local function send(action: string,id: string)
  if not p:GetAttribute("DataReady")or p:GetAttribute("Throwing")then return end
  if action=="ConfirmSell"then
   if not token or token.id~=id then return end
   local value=token.value;token=nil
   local delaySeconds=math.max(0,.18-(os.clock()-lastRequest));lastRequest=os.clock()+delaySeconds
   task.delay(delaySeconds,function()garage:FireServer("Sell",id,value)end);return
  end
  if os.clock()-lastRequest<.18 then return end
  lastRequest=os.clock()
  local c=byId[id]
  garage:FireServer(action,id,if action=="Remove"and c then c.Slot else 0)
  if action=="PreparePlace"then view.open(false)end
 end
 view=require(script.Parent.MyCarsView).mount(playerGui,function(action,id)send(if action=="Equip"then "PreparePlace"else action,id)end)
 local gui=Instance.new("ScreenGui");gui.Name="CarHotbar";gui.ResetOnSpawn=false;gui.DisplayOrder=15;gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;gui.Parent=playerGui
 local bar=Instance.new("Frame");bar.Name="Slots";bar.AnchorPoint=Vector2.new(.5,1);bar.Position=UDim2.new(.5,0,1,-46);bar.BackgroundTransparency=1;bar.Parent=gui
 local layout=Instance.new("UIListLayout");layout.FillDirection=Enum.FillDirection.Horizontal;layout.HorizontalAlignment=Enum.HorizontalAlignment.Center;layout.Padding=UDim.new(0,7);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=bar
 local function busy(): boolean
  local shop=playerGui:FindFirstChild("TicketShop");return p:GetAttribute("Throwing")==true or p:GetAttribute("CinematicActive")==true or(shop~=nil and shop:GetAttribute("Open")==true)
 end
 local function render()
  local equipped=p:GetAttribute("EquippedCarId")or "";local inventory={}
  for _,c in cars do if c.Slot==0 then table.insert(inventory,c)end end
  local visible={};for i=1,math.min(Config.HotbarSlots,#inventory)do visible[i]=inventory[i]end
  if byId[equipped]and byId[equipped].Slot==0 then
   local found=false;for _,c in visible do if c.Id==equipped then found=true end end
   if not found then visible[math.min(Config.HotbarSlots,#visible+1)]=byId[equipped]end
  end
  local size=if gui.AbsoluteSize.Y<400 then math.clamp(math.floor((gui.AbsoluteSize.X-328)/5),44,54)else 70;bar.Size=UDim2.fromOffset(Config.HotbarSlots*(size+7),size)
  for i=1,Config.HotbarSlots do
   local c=visible[i];local slot=hotbars[i]
   if c and(not slot or slot.id~=c.Id)then
    if slot then slot.button:Destroy()end
    local b=S.button(bar,"Slot"..i,"",UDim2.fromOffset(size,size),UDim2.new());b.LayoutOrder=i;b:SetAttribute("CarId",c.Id)
    local corner=b:FindFirstChildOfClass("UICorner");corner.CornerRadius=UDim.new(0,13);S.gradient(b,Color3.fromHex("74E6FF"),Color3.fromHex("1E95F0"))
    local icon=Instance.new("Frame");icon.Size=UDim2.new(1,-4,1,-18);icon.Position=UDim2.fromOffset(2,16);icon.BackgroundTransparency=1;icon.Parent=b;Preview.mount(icon,c)
    local income=S.text(b,"Income","$"..c.Income.."/s",14,UDim2.fromOffset(2,0),UDim2.new(1,-4,0,19));income.TextXAlignment=Enum.TextXAlignment.Center;income.TextColor3=Color3.fromHex("B2FFAD")
    S.text(b,"Number",tostring(i),13,UDim2.new(0,5,1,-18),UDim2.fromOffset(18,18))
    b.Activated:Connect(function()send(if p:GetAttribute("EquippedCarId")==c.Id then "Unequip"else "Equip",c.Id)end)
    slot={button=b,id=c.Id};hotbars[i]=slot
   elseif not c and slot then slot.button:Destroy();hotbars[i]=nil;slot=nil end
   if slot then slot.button.Size=UDim2.fromOffset(size,size);local outline=slot.button:FindFirstChildOfClass("UIStroke");outline.Color=if equipped==slot.id then Color3.fromHex("FFD24A")else S.INK;outline.Thickness=if equipped==slot.id then 4 else 2 end
  end
  bar.Visible=not busy()and not view.isOpen()and not indexView.isOpen()and not p:GetAttribute("PowerSelectorVisible")and not p:GetAttribute("BoostTargetVisible")
  if p:GetAttribute("MeterStart")then view.open(false)end
 end
 launch.Activated:Connect(function()if not busy()then view.open(not view.isOpen());render()end end)
 view.gui:GetAttributeChangedSignal("Open"):Connect(render)
 snapshots.OnClientEvent:Connect(function(snapshot)
  if typeof(snapshot)~="table"or typeof(snapshot.Cars)~="table"then return end
  cars=snapshot.Cars;table.sort(cars,function(a,b)return if a.Income==b.Income then a.Id<b.Id else a.Income>b.Income end)
  byId={};for _,c in cars do byId[c.Id]=c end
  view.render(cars,snapshot.InventoryCount,snapshot.ParkingCapacity);indexView.render(snapshot.Discovered);render()
 end)
 confirmSale.OnClientEvent:Connect(function(id,value,price)if byId[id]then token={id=id,value=value};view.confirm(byId[id],price)end end)
 UIS.InputBegan:Connect(function(input,processed)
  if processed or busy()or view.isOpen()or indexView.isOpen()then return end
  local i=input.KeyCode.Value-Enum.KeyCode.One.Value+1;local slot=hotbars[i]
  if i>=1 and i<=Config.HotbarSlots and slot then send(if p:GetAttribute("EquippedCarId")==slot.id then "Unequip"else "Equip",slot.id)end
 end)
 for _,a in {"EquippedCarId","Throwing","MeterStart"}do p:GetAttributeChangedSignal(a):Connect(render)end
 local function sync()if p:GetAttribute("DataReady")then garage:FireServer("Sync","",0)end end
 p:GetAttributeChangedSignal("DataReady"):Connect(sync);sync()
 -- Locally hide other players' prompts. Server still validates every Triggered.
 local prompts={}
 local function watch(x: Instance)if x:IsA("ProximityPrompt")and x:GetAttribute("GarageAction")then prompts[x]=true end end
 for _,x in world:GetDescendants()do watch(x)end;world.DescendantAdded:Connect(watch)
 world.DescendantRemoving:Connect(function(x)prompts[x]=nil end)
 local elapsed=0;RunService.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<.1 then return end;elapsed=0
  for prompt in prompts do
   local own=prompt:GetAttribute("OwnerId")==p.UserId;local action=prompt:GetAttribute("GarageAction")
   local parent=prompt.Parent
   if action=="Remove"then
    prompt.ActionText=if (p:GetAttribute("EquippedCarId")or "")~=""then "Swap car"else "Pick up"
   end
   if parent then prompt.Enabled=own and not busy()and not view.isOpen()and not indexView.isOpen()and(if action=="Place"then parent:GetAttribute("Unlocked")==true and (p:GetAttribute("EquippedCarId")or "")~=""and parent:GetAttribute("CarId")==nil else true)end
  end
  render()
 end)
 render();return view
end
return Inventory

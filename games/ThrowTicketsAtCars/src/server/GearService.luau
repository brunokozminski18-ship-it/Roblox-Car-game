--!strict
-- LihFolk Vault V2 (CC BY 4.0): server validation, world UI and interaction TL;DRs.
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local Rules=require(game.ReplicatedStorage.ThrowTickets.Rules)
local World=require(script.Parent.World)
local Service={}
local DISTANCE=12
local MONEY_UNITS={{Scale=1e12,Suffix="T"},{Scale=1e9,Suffix="B"},{Scale=1e6,Suffix="M"},{Scale=1e3,Suffix="K"}}
local function nextItem(data: any,kind: string): any
 if kind=="Exercise"then return Config.Exercises[data.Exercise+1]end
 if kind=="Ticket"then
  for i,item in Config.Tickets do
   if not data.Owned[item.Id]then
    return if i==1 or data.Owned[Config.Tickets[i-1].Id]then item else nil
   end
  end
 end
 return nil
end
local function effect(kind: string,item: any): string
 if kind=="Exercise"then return string.format("x%g training",item.Work/Config.Exercises[1].Work)end
 return string.format("+%g%% luck / x%g income",item.Luck*100,item.IncomeMultiplier)
end
local function payload(kind: string,item: any): any
 return {Kind=kind,Id=item.Id,Name=item.Name,Price=item.Price,Effect=effect(kind,item)}
end
local function affordable(data: any,item: any): boolean
 return Rules.biome(Rules.distance(data.Power))>=item.UnlockBiome and data.Cash>=item.Price
end
local function money(value: number): string
 for _,unit in MONEY_UNITS do
  if value>=unit.Scale then return string.format("%g%s",math.floor(value/unit.Scale*10)/10,unit.Suffix)end
 end
 return string.format("%.0f",value)
end
function Service.new(ctx: any): any
 local api={}
 local function ready(p: Player,s: any): boolean
  return s~=nil and ctx.mutable(s)and p.Parent~=nil and p:GetAttribute("DataReady")==true
 end
 local function idle(p: Player,s: any): boolean
  return ready(p,s)and not s.job and not s.meter
 end
 local function stationFor(p: Player,s: any): BasePart?
  local station=s.gearStation
  if station and station.Parent==s.folder and s.folder:GetAttribute("OwnerId")==p.UserId and station:GetAttribute("OwnerId")==p.UserId then return station end
  return nil
 end
 local function open(p: Player,s: any,kind: string)
  local item=nextItem(s.data,kind)
  ctx.Juice:FireClient(p,"GearOpen",if item then payload(kind,item)else {Kind=kind})
 end
 local function paint(p: Player,s: any)
  local station=stationFor(p,s);if not station then return end
  local text=s.gearText;local prompt=s.gearPrompt
  local item=nextItem(s.data,"Exercise")
  local message="TRAINING SHOP\nAll training gear owned"
  if item then
   local color=if affordable(s.data,item)then "#75F28B"else "#FF7B87"
   message=string.format("%s\n%s\n<font color=\"%s\">$%s</font>",item.Name,effect("Exercise",item),color,money(item.Price))
  end
  if text and text.Parent and text.Text~=message then text.Text=message end
  if prompt and prompt.Parent then prompt.ObjectText=if item then item.Name else "Training shop"end
  station:SetAttribute("NextExerciseId",if item then item.Id else nil)
  station:SetAttribute("Price",if item then item.Price else nil)
  station:SetAttribute("Affordable",item~=nil and affordable(s.data,item))
 end
 function api.mount(p: Player,s: any)
  if not s or not s.folder or s.folder:GetAttribute("OwnerId")~=p.UserId then return end
  if stationFor(p,s)then paint(p,s);return end
  local pad=s.folder:FindFirstChild("TrainingPad")
  if not pad or not pad:IsA("BasePart")then return end
  local station=World.part(s.folder,"NextExerciseStation",Vector3.new(3,.8,3),pad.Position+Vector3.new(6,0,0),Color3.fromRGB(113,104,135))
  station.CanTouch=false;station:SetAttribute("OwnerId",p.UserId)
  local label=Instance.new("BillboardGui");label.Name="NextExerciseLabel";label.Size=UDim2.fromOffset(230,92)
  label.StudsOffsetWorldSpace=Vector3.new(0,station.Size.Y/2+3,0);label.MaxDistance=38;label.AlwaysOnTop=false;label.Parent=station
  local text=Instance.new("TextLabel");text.Name="Offer";text.Size=UDim2.fromScale(1,1);text.BackgroundColor3=Color3.fromRGB(47,43,57)
  text.BackgroundTransparency=.15;text.TextColor3=Color3.new(1,1,1);text.Font=Enum.Font.FredokaOne;text.TextSize=20
  text.TextStrokeColor3=Color3.fromRGB(20,16,42);text.TextStrokeTransparency=.15;text.RichText=true;text.TextWrapped=true;text.Parent=label
  local prompt=Instance.new("ProximityPrompt");prompt.Name="TrainingShop";prompt.ActionText="Training shop";prompt.ObjectText="Training shop"
  prompt.MaxActivationDistance=DISTANCE;prompt.RequiresLineOfSight=false;prompt.HoldDuration=0;prompt.ClickablePrompt=true
  prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.GamepadKeyCode=Enum.KeyCode.ButtonX;prompt.Exclusivity=Enum.ProximityPromptExclusivity.OnePerButton
  prompt:SetAttribute("OwnerId",p.UserId);prompt.Parent=station
  s.gearStation=station;s.gearText=text;s.gearPrompt=prompt;s.gearNotified=s.gearNotified or {}
  prompt.Triggered:Connect(function(actor: Player)
   if actor~=p or not idle(p,s)or not stationFor(p,s)then return end
   local now=os.clock();if now-(s.lastGearPrompt or -math.huge)<Config.ShopRequestInterval then return end;s.lastGearPrompt=now
   local root=ctx.rootOf(p);if not root or (root.Position-station.Position).Magnitude>DISTANCE then return end
   open(p,s,"Exercise")
  end)
  paint(p,s)
 end
 function api.update(p: Player,s: any)
  if not s then return end;paint(p,s)
  if not idle(p,s)or not s.juiceReady then return end
  local now=workspace:GetServerTimeNow();if now<(s.gearToastUntil or 0)then return end
  s.gearNotified=s.gearNotified or {}
  for _,kind in {"Exercise","Ticket"}do
   local item=nextItem(s.data,kind)
   if item then
    local key=kind..":"..item.Id
    if not s.gearNotified[key]and affordable(s.data,item)then
     local offer=payload(kind,item);offer.ExpiresAt=now+Config.Juice.ToastSeconds
     s.gearNotified[key]=true;s.gearToastUntil=offer.ExpiresAt
     ctx.Juice:FireClient(p,"Gear",offer);return
    end
   end
  end
 end
 function api.visit(p: Player,s: any,kind: any,id: any): boolean
  if not idle(p,s)then return false end
  local now=os.clock();if now-(s.lastGearVisit or -math.huge)<Config.ShopRequestInterval then return false end;s.lastGearVisit=now
  if (kind~="Exercise"and kind~="Ticket")or typeof(id)~="string"or #id>24 then return false end
  if not s.gearNotified or not s.gearNotified[kind..":"..id]then return false end
  local item=nextItem(s.data,kind)
  if not item or item.Id~=id or not affordable(s.data,item)then return false end
  local station=stationFor(p,s);local root=ctx.rootOf(p);local character=p.Character
  if not station or not root or not character then return false end
  -- No yield between eligibility and teleport/open; this action never buys anything.
  p:SetAttribute("Training",false);p:SetAttribute("TrainingActive",false);p:SetAttribute("Location","Plot")
  root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero
  local position=station.Position+Vector3.new(0,3,4)
  character:PivotTo(CFrame.lookAt(position,station.Position+Vector3.new(0,2,0)))
  open(p,s,kind)
  return true
 end
 return api
end
return Service

--!strict
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local GuiService=game:GetService("GuiService")
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local Rules=require(game.ReplicatedStorage.ThrowTickets.Rules)
local S=require(script.Parent.Style)
local Selector={}
function Selector.mount(remote: RemoteEvent): any
 local p=Players.LocalPlayer;local playerGui=p:WaitForChild("PlayerGui")
 local gui=Instance.new("ScreenGui");gui.Name="PowerSelector";gui.ResetOnSpawn=false;gui.DisplayOrder=20
 gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;gui.SafeAreaCompatibility=Enum.SafeAreaCompatibility.None
 gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;gui.Enabled=false;gui.Parent=playerGui
 local panel=Instance.new("Frame");panel.Name="Selector";panel.AnchorPoint=Vector2.new(.5,1);panel.Position=UDim2.new(.5,0,1,-45)
 panel.Size=UDim2.fromOffset(360,96);panel.BackgroundColor3=Color3.new(1,1,1);panel.BorderSizePixel=0;panel.Parent=gui
 S.corner(panel,22);S.stroke(panel,3);S.gradient(panel,Color3.fromHex("2F7BF2"),Color3.fromHex("16348F"))
 local title=S.text(panel,"Power","THROW POWER",18,UDim2.fromOffset(13,4),UDim2.new(1,-26,0,25))
 title.TextXAlignment=Enum.TextXAlignment.Center;title.TextColor3=Color3.fromHex("FFF2A6")
 local hit=Instance.new("TextButton");hit.Name="Slider";hit.Text="";hit.AutoButtonColor=false;hit.BackgroundTransparency=1
 hit.Size=UDim2.new(1,-90,0,44);hit.Position=UDim2.fromOffset(8,29);hit.Selectable=true;hit.Parent=panel
 local rail=Instance.new("Frame");rail.Name="Track";rail.Position=UDim2.new(0,22,.5,-5);rail.Size=UDim2.new(1,-44,0,10)
 rail.BackgroundColor3=Color3.fromHex("0E1E55");rail.BorderSizePixel=0;rail.Active=false;rail.Parent=hit;S.corner(rail,5)
 local fill=Instance.new("Frame");fill.Name="Fill";fill.Size=UDim2.fromScale(1,1);fill.BackgroundColor3=Color3.fromHex("FFD24A")
 fill.BorderSizePixel=0;fill.Active=false;fill.Parent=rail;S.corner(fill,5)
 local knob=Instance.new("Frame");knob.Name="Knob";knob.AnchorPoint=Vector2.new(.5,.5);knob.Position=UDim2.fromScale(1,.5)
 knob.Size=UDim2.fromOffset(28,36);knob.BackgroundColor3=Color3.new(1,1,1);knob.BorderSizePixel=0;knob.Active=false;knob.Parent=rail;S.corner(knob,12);S.stroke(knob,3)
 local max=S.button(panel,"Max","MAX",UDim2.fromOffset(64,44),UDim2.new(1,-74,0,29));max.TextSize=19
 S.gradient(max,Color3.fromHex("FFF4A0"),Color3.fromHex("FFD24A"))
 local lands=S.text(panel,"LandsIn","",16,UDim2.fromOffset(8,73),UDim2.new(1,-16,0,21));lands.TextXAlignment=Enum.TextXAlignment.Center
 local dragInput: InputObject?=nil;local dragging=false;local preview: number?=nil;local queued: number?=nil
 local lastSent=-math.huge;local lastValue: number?=nil;local queueVersion=0;local pendingUntil=0
 local connections: {RBXScriptConnection}={};local alive=true
 local function connect(signal: RBXScriptSignal,callback: any)table.insert(connections,signal:Connect(callback))end
 local function bounds(): (number,number)
  local value=p:GetAttribute("ThrowPower")
  local power=if Rules.finiteNumber(value)then math.clamp(value,0,Config.MaxPower)else 0
  return math.min(1,power),power
 end
 local function actual(): number
  local low,high=bounds();local value=p:GetAttribute("ThrowSelection")
  return if p:GetAttribute("SelectionMax")==true or not Rules.finiteNumber(value)then high else math.clamp(value,low,high)
 end
 local function windowOpen(name: string): boolean
  local window=playerGui:FindFirstChild(name);return window~=nil and window:GetAttribute("Open")==true
 end
 local function available(): boolean
  if p:GetAttribute("DataReady")~=true or p:GetAttribute("Throwing")==true or p:GetAttribute("MeterStart")~=nil
   or p:GetAttribute("ShopOpen")==true or p:GetAttribute("CarsOpen")==true or windowOpen("TicketShop")or windowOpen("MyCars")then return false end
  local character=p.Character;local root=character and character:FindFirstChild("HumanoidRootPart");local humanoid=character and character:FindFirstChildOfClass("Humanoid")
  return root~=nil and root:IsA("BasePart")and humanoid~=nil and humanoid.Health>0 and (root.Position-Config.LaunchCenter).Magnitude<=20
 end
 local function render()
  local low,high=bounds();local value=math.clamp(if preview~=nil then preview else actual(),low,high)
  local ratio=if high>low then (value-low)/(high-low)else 1
  fill.Size=UDim2.fromScale(ratio,1);knob.Position=UDim2.fromScale(ratio,.5)
  local isMax=if preview~=nil then math.abs(value-high)<.0001 else p:GetAttribute("SelectionMax")==true
  title.Text="THROW POWER  "..Rules.powerText(value)..(if isMax then "  MAX"else "")
  local biome=Config.Biomes[Rules.biome(Rules.distance(value))];lands.Text="Lands in: "..biome.Name
  max:SetAttribute("Selected",isMax);panel:SetAttribute("SelectedPower",value);panel:SetAttribute("Maximum",high)
 end
 local function refresh()
  local show=available();gui.Enabled=show
  if p:GetAttribute("PowerSelectorVisible")~=show then p:SetAttribute("PowerSelectorVisible",show)end
  if not show then
   dragging=false;dragInput=nil;preview=nil;queued=nil;queueVersion+=1
  elseif not dragging and preview~=nil and os.clock()>=pendingUntil then preview=nil end
  render()
 end
 local function commit(value: number)
  if not alive or not available()then return end
  local low,high=bounds();value=math.clamp(value,low,high)
  -- Keep the last completed gesture when several taps arrive inside the throttle.
  queued=value;preview=value;pendingUntil=os.clock()+.8;queueVersion+=1
  local version=queueVersion
  local function send()
   if not alive or version~=queueVersion or queued==nil or not available()then return end
   local minimum,maximum=bounds();local chosen=math.clamp(queued,minimum,maximum);queued=nil
   if lastValue==chosen and os.clock()-lastSent<.15 then return end
   lastValue=chosen;lastSent=os.clock();remote:FireServer(chosen)
  end
  local waitFor=.12-(os.clock()-lastSent)
  if waitFor>0 then task.delay(waitFor,send)else send()end
  render()
 end
 local function fromPoint(x: number): number
  local low,high=bounds();local ratio=math.clamp((x-rail.AbsolutePosition.X)/math.max(1,rail.AbsoluteSize.X),0,1)
  -- Whole units are easier to choose; retain exact fractional Power at MAX.
  return if ratio>=.999 then high else math.clamp(math.floor(low+(high-low)*ratio+.5),low,high)
 end
 connect(hit.InputBegan,function(input: InputObject)
  if not gui.Enabled or (input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1)then return end
  if dragging then return end;dragging=true;dragInput=input;preview=fromPoint(input.Position.X);render()
 end)
 connect(UIS.InputChanged,function(input: InputObject)
  if not dragging or not gui.Enabled or not dragInput then return end
  if input==dragInput or (dragInput.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseMovement)then
   preview=fromPoint(input.Position.X);render()
  end
 end)
 connect(UIS.InputEnded,function(input: InputObject)
  if not dragging or not dragInput then return end
  if input==dragInput or (dragInput.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseButton1)then
   local value=preview or fromPoint(input.Position.X);dragging=false;dragInput=nil;commit(value)
  end
 end)
 connect(hit.Activated,function(input: InputObject?)
  if not gui.Enabled or dragging then return end
  -- Pointer taps are already handled by the same release path as dragging.
  if not input or (input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1)then commit(preview or actual())end
 end)
 connect(UIS.InputBegan,function(input: InputObject,_processed: boolean)
  -- This is focused UI input; the UI may already have marked it processed.
  if not gui.Enabled or GuiService.SelectedObject~=hit then return end
  local direction=if input.KeyCode==Enum.KeyCode.Left or input.KeyCode==Enum.KeyCode.DPadLeft then -1 elseif input.KeyCode==Enum.KeyCode.Right or input.KeyCode==Enum.KeyCode.DPadRight then 1 else 0
  if direction==0 then return end
  local low,high=bounds();commit(math.clamp((preview or actual())+direction*math.max(1,math.floor((high-low)/20)),low,high))
 end)
 connect(max.Activated,function()local _,power=bounds();commit(power)end)
 connect(UIS.WindowFocusReleased,function()dragging=false;dragInput=nil;preview=nil;queued=nil;queueVersion+=1;refresh()end)
 local function resize()
  panel.Size=UDim2.fromOffset(math.max(240,math.min(400,gui.AbsoluteSize.X-160)),96)
  panel.Position=UDim2.new(.5,0,1,-45);title.TextSize=if gui.AbsoluteSize.X<600 then 16 else 18
 end
 connect(gui:GetPropertyChangedSignal("AbsoluteSize"),resize)
 for _,attribute in {"ThrowSelection","SelectionMax"}do
  connect(p:GetAttributeChangedSignal(attribute),function()if not dragging then preview=nil end;refresh()end)
 end
 for _,attribute in {"ThrowPower","DataReady","Throwing","MeterStart","ShopOpen","CarsOpen"}do connect(p:GetAttributeChangedSignal(attribute),refresh)end
 local elapsed=0;connect(RunService.Heartbeat,function(dt: number)elapsed+=dt;if elapsed>=.08 then elapsed=0;refresh()end end)
 resize();refresh()
 return {gui=gui,refresh=refresh,destroy=function()
  alive=false;queueVersion+=1;for _,connection in connections do connection:Disconnect()end
  p:SetAttribute("PowerSelectorVisible",false);gui:Destroy()
 end}
end
return Selector

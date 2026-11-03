-- Studio-only real-time UI pacing test. No Cash/Power injection and no teleport helpers.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players.LocalPlayer
local gui=p:WaitForChild("PlayerGui")
local HUD=gui:WaitForChild("TicketHUD");local Inv=gui:WaitForChild("TicketInventory")
local Shop=gui:WaitForChild("TicketShop")
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local VI=assert(game.UserInputService:CreateVirtualInput(),"VirtualInput unavailable")
local function waitFor(test,limit)
 local start=os.clock();repeat if test()then return end;task.wait(.05)until os.clock()-start>limit
 error("Timed out after "..limit.."s")
end
local function click(b)
 assert(b.Visible and b.Active,"Button inactive: "..b:GetFullName())
 local inset=game.GuiService:GetGuiInset()
 local position=b.AbsolutePosition+Vector2.new(12,b.AbsoluteSize.Y/2)+inset
 VI:SendMousePosition(position);VI:SendMouseButton(position,Enum.UserInputType.MouseButton1,true);task.wait(.12);VI:SendMouseButton(position,Enum.UserInputType.MouseButton1,false);task.wait(.15)
end
local log={Events={},NoGrants=true,Device="iPhone 7 landscape"}
local start=workspace:GetServerTimeNow()
local function elapsed()return workspace:GetServerTimeNow()-start end
local function event(name) table.insert(log.Events,{Name=name,Seconds=elapsed(),Cash=p.leaderstats.Cash.Value,Power=p:GetAttribute("ThrowPower")});p:SetAttribute("QAPaceResults",game.HttpService:JSONEncode(log))end
local function buy(action,id,attribute,target)
 click(HUD.Shop);waitFor(function()return Shop:GetAttribute("Open")end,3)
 local list=Shop.Window.Tickets;local row=list[id]
 list.CanvasPosition=Vector2.new(0,math.min(math.max(0,list.AbsoluteCanvasSize.Y-list.AbsoluteSize.Y),row.LayoutOrder*90-90))
 task.wait(.15);click(row.Action)
 waitFor(function()return p:GetAttribute(attribute)==target end,4)
 event("Bought "..id)
 if action=="Buy"then task.wait(.35);click(row.Action);waitFor(function()return p:GetAttribute("EquippedTicket")==id end,4)end
 click(Shop.Window.Close);waitFor(function()return not Shop:GetAttribute("Open")end,3)
end
local function purchase()
 if p:GetAttribute("Exercise")==1 and p.leaderstats.Cash.Value>=Config.Exercises[2].Price then buy("Exercise","focused","Exercise",2)end
 if p:GetAttribute("Exercise")==2 and not p:GetAttribute("Own_pink")and p.leaderstats.Cash.Value>=Config.Tickets[2].Price then buy("Buy","pink","Own_pink",true)end
end
local function catch()
 local began=elapsed();local count=p:GetAttribute("ParkedCount")or 0
 click(HUD.Throw);waitFor(function()return p:GetAttribute("Location")=="Plot"end,25)

 local best,dist=nil,math.huge
 for _,slot in workspace.TicketPrototype.Parking:GetDescendants()do
  if slot:IsA("BasePart")and slot:GetAttribute("OwnerId")==p.UserId and slot.Name:match("^Slot%d+$")and not slot:GetAttribute("CarId")then
   local d=(slot.Position-p.Character.HumanoidRootPart.Position).Magnitude;if d<dist then best,dist=slot,d end
  end
 end
 if best then
  if dist>7 then p.Character.Humanoid:MoveTo(best.Position+Vector3.new(0,0,4));waitFor(function()return (p.Character.HumanoidRootPart.Position-best.Position).Magnitude<8 end,8)end
  waitFor(function()return Inv:GetAttribute("PlaceSlot")~=0 end,3);click(Inv.Place)
  waitFor(function()return p:GetAttribute("ParkedCount")==count+1 end,4)
 else
  waitFor(function()return Inv:GetAttribute("SelectedCarId")~=""end,3);click(Inv.Sell)
 end
 click(Inv.BackToRoad);waitFor(function()return p:GetAttribute("Location")=="Road"end,4)
 event("Car cycle")
 while elapsed()-began<Config.Simulation.CatchLoopSeconds do task.wait(.1)end
end
task.spawn(function()
 local ok,err=pcall(function()
  waitFor(function()return p:GetAttribute("DataReady")end,10)
  assert(p.leaderstats.Cash.Value==0 and p:GetAttribute("ThrowPower")==Config.StartPower and p:GetAttribute("InventoryCount")==0 and p:GetAttribute("Exercise")==1,"Profile must start from zero")
  event("Start")
  for _=1,Config.ParkingSlots do purchase();catch();purchase()end
  if not p:GetAttribute("Training")then click(HUD.Train)end
  local nextCatch=elapsed()+Config.Simulation.RefreshSeconds-Config.Simulation.CatchLoopSeconds
  while(p:GetAttribute("ThrowPower")or 0)<Config.Biomes[2].MinPower do
   purchase()
   if elapsed()>=nextCatch then catch();purchase();if not p:GetAttribute("Training")then click(HUD.Train)end;nextCatch=elapsed()+Config.Simulation.RefreshSeconds-Config.Simulation.CatchLoopSeconds end
   task.wait(.1)
  end
  event("Suburbs");log.Complete=true;log.TotalSeconds=elapsed();log.Errors={}
 end)
 if not ok then log.Error=tostring(err)end
 p:SetAttribute("QAPaceResults",game.HttpService:JSONEncode(log))
end)
return "real-time pacing started"

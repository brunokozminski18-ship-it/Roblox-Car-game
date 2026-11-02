-- Studio Client only, unsynced. Run once in a fresh Play session.
assert(game:GetService("RunService"):IsStudio())
local p = game.Players.LocalPlayer
assert(p:GetAttribute("ParkingUsed") == 0, "Start a fresh Play session")
local Http = game:GetService("HttpService")
local Aim = require(game.ReplicatedStorage.ThrowTickets.Aim)
local remotes = game.ReplicatedStorage.ThrowTickets.Remotes
local world = workspace.TicketPrototype
local results = {}
local function save(name, ok, detail)
	table.insert(results, {name=name, pass=ok, detail=detail})
	p:SetAttribute("QAResults", Http:JSONEncode(results))
	assert(ok, name .. ": " .. tostring(detail))
end
local function car(tier)
	for _,c in world.Cars:GetChildren() do
		if c:GetAttribute("Tier")==tier and not c:GetAttribute("Claimed") then return c end
	end
	error("No available tier "..tier)
end
local function fire(c)
	local origin = p.Character.HumanoidRootPart.Position + Vector3.new(0,7,14)
	remotes.Throw:FireServer(origin, (Aim.point(c)-origin).Unit)
	task.wait(.18)
end
local sawPower, sawHit, sawSticker, sawPop, sawHook, sawSound = false,false,false,false,false,false
local overlay = p.PlayerGui.TicketFXOverlay
local a = overlay.ChildAdded:Connect(function(n) if n.Name=="PowerPopup" then sawPower=true elseif n.Name=="TicketedPopup" then sawHit=true end end)
local b = workspace.TicketClientFX.ChildAdded:Connect(function(n) if n.Name=="StuckTicket" then sawSticker=true elseif n.Name=="ParkingPop" then sawPop=true end end)
local c = world.Tows.DescendantAdded:Connect(function(n) if n.Name=="TowHook" then sawHook=true end end)
local d = game.SoundService.ChildAdded:Connect(function(n) if n.Name=="TicketImpact" then sawSound=true end end)
task.spawn(function()
	fire(car(2))
	save("too far",p:GetAttribute("LastResult")=="Too far! TRAIN for more power.",p:GetAttribute("LastResult"))
	task.wait(.5)
	save("miss has no hit payoff",not sawHit and not sawSticker and p:GetAttribute("ParkingUsed")==0,0)
	fire(car(1)); task.wait(.57); fire(car(1)); task.wait(.45)
	save("two background tows",#world.Tows:GetChildren()==2 and p:GetAttribute("ParkingUsed")==2,#world.Tows:GetChildren())
	remotes.Train:FireServer(true)
	local deadline=os.clock()+28
	while p:GetAttribute("ThrowPower")<44 and os.clock()<deadline do task.wait(.2) end
	save("training and +1 popup",p:GetAttribute("ThrowPower")>=44 and sawPower,p:GetAttribute("ThrowPower"))
	remotes.Train:FireServer(false)
	save("cash after delivery",p.leaderstats.Cash.Value>0 and p:GetAttribute("Delivered")==2,p.leaderstats.Cash.Value)
	local used=p:GetAttribute("ParkingUsed")
	fire(car(2))
	save("farther target after training",p:GetAttribute("ParkingUsed")==used+1,p:GetAttribute("LastResult"))
	task.wait(.57);fire(car(2));task.wait(.57);fire(car(1));task.wait(.57);fire(car(1))
	save("six reservations",p:GetAttribute("ParkingUsed")==6,p:GetAttribute("ParkingUsed"))
	task.wait(4.8)
	local target=car(1);fire(target)
	save("full parking",p:GetAttribute("LastResult")=="Parking full!" and not target:GetAttribute("Claimed"),p:GetAttribute("LastResult"))
	save("six deliveries and authoritative income",p:GetAttribute("Delivered")==6 and p:GetAttribute("Income")==10,p:GetAttribute("Income"))
	save("tow fits three seconds",p:GetAttribute("LastDeliverySeconds")<=3,p:GetAttribute("LastDeliverySeconds"))
	save("client hit/sticker/pop/hook/audio",sawHit and sawSticker and sawPop and sawHook and sawSound,Http:JSONEncode({hit=sawHit,sticker=sawSticker,pop=sawPop,hook=sawHook,sound=sawSound}))
	for _,args in {{Vector3.new(0/0,0,0),Vector3.new(0,0,-1)},{Vector3.zero,Vector3.new(math.huge,0,0)},{"bad",Vector3.zero},{Vector3.new(10000,0,0),Vector3.new(0,0,-1)},{Vector3.zero,Vector3.zero}} do
		remotes.Throw:FireServer(table.unpack(args));task.wait(.14)
	end
	for _=1,30 do remotes.Throw:FireServer(Vector3.zero,Vector3.new(0,0,-1)) end
	task.wait(3.5)
	save("bad input and spam grant nothing",p:GetAttribute("ParkingUsed")==6 and p:GetAttribute("Delivered")==6,p:GetAttribute("ParkingUsed"))
	save("transient FX cleaned",#workspace.TicketClientFX:GetChildren()==0 and #overlay:GetChildren()==0,#workspace.TicketClientFX:GetChildren())
	save("default camera retained",workspace.CurrentCamera.CameraType==Enum.CameraType.Custom,workspace.CurrentCamera.CameraType.Name)
	a:Disconnect();b:Disconnect();c:Disconnect();d:Disconnect()
	p:SetAttribute("QADone",true)
end)
return "Scenario running; poll LocalPlayer.QAResults / QADone."

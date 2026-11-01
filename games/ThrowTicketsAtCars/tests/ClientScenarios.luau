-- Studio Client only, unsynced. Start clean; THROW two close cars and toggle TRAIN first.
assert(game:GetService("RunService"):IsStudio())
local p = game.Players.LocalPlayer
local Http = game:GetService("HttpService")
local remotes = game.ReplicatedStorage.ThrowTickets.Remotes
local world = workspace.TicketPrototype
local results = {}
local function save(name, ok, detail)
	table.insert(results, {name = name, pass = ok, detail = detail})
	p:SetAttribute("QAResults", Http:JSONEncode(results))
	assert(ok, name .. ": " .. tostring(detail))
end
local function car(tier)
	for _,c in world.Cars:GetChildren() do
		if c:GetAttribute("Tier") == tier and not c:GetAttribute("Claimed") then return c end
	end
	error("No available tier " .. tier)
end
local function fire(c)
	local root = p.Character.HumanoidRootPart
	remotes.Throw:FireServer(c.Name, (c.PrimaryPart.Position - root.Position).Unit)
	task.wait(.18)
end
task.spawn(function()
	task.wait(.8)
	fire(car(2))
	save("too far", p:GetAttribute("LastResult") == "Too far! TRAIN for more power.", p:GetAttribute("LastResult"))
	local power = p:GetAttribute("ThrowPower")
	local deadline = os.clock() + 30
	while p:GetAttribute("ThrowPower") < 44 and os.clock() < deadline do task.wait(.2) end
	save("real training ticks", p:GetAttribute("ThrowPower") >= 44 and p:GetAttribute("ThrowPower") > power, p:GetAttribute("ThrowPower"))
	save("cash after deliveries", p.leaderstats.Cash.Value > 0 and p:GetAttribute("Delivered") == 2, p.leaderstats.Cash.Value)
	local before = p:GetAttribute("ParkingUsed")
	fire(car(2))
	save("farther car over respawned near car", p:GetAttribute("ParkingUsed") == before + 1, p:GetAttribute("LastResult"))
	task.wait(.75)
	fire(car(2))
	task.wait(.75)
	fire(car(1))
	task.wait(.75)
	fire(car(1))
	save("six reservations", p:GetAttribute("ParkingUsed") == 6, p:GetAttribute("ParkingUsed"))
	task.wait(5.5)
	local c = car(1)
	fire(c)
	save("full parking", p:GetAttribute("LastResult") == "Parking full!" and not c:GetAttribute("Claimed"), p:GetAttribute("LastResult"))
	save("six deliveries", p:GetAttribute("Delivered") == 6 and p:GetAttribute("Income") == 10, p:GetAttribute("Income"))
	local used = p:GetAttribute("ParkingUsed")
	for _,args in {{"bad", Vector3.new(0/0,0,0)}, {c.Name, Vector3.new(math.huge,0,0)}, {world, Vector3.zero}, {c.Name, Vector3.zero}, {string.rep("x",1000),Vector3.new(0,0,-1)}} do
		remotes.Throw:FireServer(table.unpack(args)); task.wait(.14)
	end
	for _=1,30 do remotes.Throw:FireServer(c.Name, Vector3.new(0,0,-1)) end
	task.wait(.2)
	save("malformed and spam grant nothing", p:GetAttribute("ParkingUsed") == used and p:GetAttribute("Delivered") == 6, p:GetAttribute("ParkingUsed"))
	p:SetAttribute("QADone", true)
end)
return "Scenario started; poll LocalPlayer.QAResults/QADone."

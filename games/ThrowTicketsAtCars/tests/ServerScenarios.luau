-- Studio Server only. No test hooks are shipped in src/.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players:GetPlayers()[1]
assert(p:GetAttribute("Throws")==0,"Fresh Play required")
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local Rules=require(game.ReplicatedStorage.ThrowTickets.Rules)
local Http=game:GetService("HttpService")
local results={}
local seen={}
local function save(name,ok,detail)
	table.insert(results,{name=name,pass=ok,detail=detail});p:SetAttribute("QAResults",Http:JSONEncode(results))
	assert(ok,name..": "..tostring(detail))
end
local function waitFor(predicate,seconds)
	local deadline=os.clock()+seconds
	repeat if predicate()then return true end;task.wait(.03)until os.clock()>deadline
	return false
end
local function send(mode)
	p:SetAttribute("QAMode",mode);p:SetAttribute("QAGo",(p:GetAttribute("QAGo")or 0)+1)
end
local function shot(power)
	task.wait(Config.ThrowCooldown+.08)
	p:SetAttribute("ThrowPower",power)
	local before=p:GetAttribute("Throws");send("Throw")
	assert(waitFor(function()return p:GetAttribute("Throws")==before+1 end,2),"Normal intent not accepted")
	local expected=Rules.biome(Rules.distance(power))
	assert(p:GetAttribute("LastBiome")==expected and p:GetAttribute("LastDistance")==Rules.distance(power),"Wrong biome or distance")
	assert(p:GetAttribute("LastLandingZ")==-Rules.distance(power),"Landing is not exactly Power")
	local name=p:GetAttribute("LastCarName");local inPool=false
	for _,entry in Config.Biomes[expected].Cars do if entry.Name==name then inPool=true end end
	assert(inPool,"Car outside biome pool")
	local rarity=p:GetAttribute("LastRarity");seen[rarity]=true
	assert(p:GetAttribute("LastRollIncome")==Config.Biomes[expected].BaseIncome*Config.Rarities[rarity].Multiplier,"Wrong income")
end
local function activeSum()
	local folder=workspace.TicketPrototype.Parking[tostring(p.UserId)];local total=0
	for i=1,Config.ParkingSlots do total+=folder["Slot"..i]:GetAttribute("ActiveIncome")end
	return total
end
task.spawn(function()
	local ok,err=pcall(function()
		p:SetAttribute("QAStage","Fill Junkyard")
		for _=1,6 do shot(24)end
		assert(waitFor(function()return p:GetAttribute("ParkedCount")==6 end,4),"Parking did not fill")
		save("six cars and income",p:GetAttribute("ParkingUsed")==6 and p:GetAttribute("Income")==activeSum(),p:GetAttribute("Income"))
		local folder=workspace.TicketPrototype.Parking[tostring(p.UserId)]
		local weakest=1
		for i=2,6 do if folder["Slot"..i]:GetAttribute("ActiveIncome")<folder["Slot"..weakest]:GetAttribute("ActiveIncome")then weakest=i end end
		local oldIncome=p:GetAttribute("Income")
		p:SetAttribute("QAStage","Upgrade weakest")
		shot(2500)
		save("stronger replaces weakest reservation",p:GetAttribute("LastOutcome")=="Upgrade"and p:GetAttribute("LastSlot")==weakest,p:GetAttribute("LastSlot"))
		save("old car earns during tow",p:GetAttribute("Income")==oldIncome,p:GetAttribute("Income"))
		for _=1,5 do shot(2500)end
		assert(waitFor(function()return p:GetAttribute("Upgrades")==6 end,4),"Six upgrades did not complete")
		save("upgrade delivery is atomic",p:GetAttribute("ParkedCount")==6 and p:GetAttribute("Income")==activeSum()and p:GetAttribute("LastResult")=="Upgraded parking!",p:GetAttribute("Income"))
		p:SetAttribute("QAStage","Sell weaker")
		local sales=p:GetAttribute("Sales");local saleTotal=p:GetAttribute("SaleTotal");oldIncome=p:GetAttribute("Income")
		shot(0);local price=Rules.salePrice(p:GetAttribute("LastRollIncome"))
		save("weaker rolls are sold",p:GetAttribute("LastOutcome")=="Sell",p:GetAttribute("LastOutcome"))
		assert(waitFor(function()return p:GetAttribute("Sales")==sales+1 end,4),"Sale missing")
		save("sale pays exactly once",p:GetAttribute("SaleTotal")==saleTotal+price and p:GetAttribute("LastSale")==price and p:GetAttribute("LastResult")=="Sold for $"..price,price)
		save("sale preserves parking",p:GetAttribute("Income")==oldIncome and p:GetAttribute("ParkedCount")==6,oldIncome)
		p:SetAttribute("QAStage","Biome boundaries")
		for _,power in {0,24,49,50,149,150,399,400,999,1000,2499,2500,99999}do shot(power)end
		save("all biome boundaries and map clamp",p:GetAttribute("LastDistance")==Config.MapEnd,p:GetAttribute("LastDistance"))
		p:SetAttribute("QAStage","Cooldown and malformed arguments")
		task.wait(Config.ThrowCooldown+.08);local before=p:GetAttribute("Throws");send("Burst");task.wait(.4)
		save("server cooldown blocks burst",p:GetAttribute("Throws")==before+1,p:GetAttribute("Throws")-before)
		task.wait(.2);before=p:GetAttribute("Throws");send("Invalid");task.wait(1.2)
		save("client cannot choose power/car/reward",p:GetAttribute("Throws")==before,p:GetAttribute("Throws")-before)
		p:SetAttribute("QAStage","Actual random variety")
		for _=1,20 do shot(24)end
		local variety=0;for _ in seen do variety+=1 end
		save("actual rarity variety",variety>=2,variety)
		p:SetAttribute("QAStage","Cleanup and respawn")
		task.wait(4.8)
		local views=0;for _,m in workspace.TicketPrototype.Cars:GetChildren()do if m:GetAttribute("Display")then views+=1 end end
		save("view cars respawn",views==#Config.Biomes*Config.ViewCarsPerBiome,views)
		save("transport fits three seconds",p:GetAttribute("LastDeliverySeconds")<=3,p:GetAttribute("LastDeliverySeconds"))
		save("server income matches active cars",p:GetAttribute("Income")==activeSum(),p:GetAttribute("Income"))
		p:SetAttribute("QAStage","Complete")
	end)
	p:SetAttribute("QAFinished",true);p:SetAttribute("QAPassed",ok)
	if not ok then p:SetAttribute("QAError",tostring(err));p:SetAttribute("QAStage","FAILED")end
end)
return "Server scenario started; poll QAStage/QAResults/QAPassed."

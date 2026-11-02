--!strict
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local Config=require(RS.ThrowTickets.Config)
local Rules=require(RS.ThrowTickets.Rules)
local World=require(script.Parent.World)
local RunService=game:GetService("RunService")
local ServerStorage=game:GetService("ServerStorage")
local Schema=require(script.Parent.ProfileSchema)
local Profiles=require(script.Parent.Profiles)
local storeName=Config.Data.StoreName..(if RunService:IsStudio() then "_STUDIO" else "")
local profiles=Profiles.new(game:GetService("DataStoreService"):GetDataStore(storeName))
local leaving=0
local loading=0
local closing=false
assert(Config.Biomes[1].MinPower==0 and Config.MapEnd>Config.Biomes[#Config.Biomes].MinPower)
assert(Config.TicketFlightSeconds+Config.TowApproachSeconds+Config.TowLoadSeconds+Config.TowReturnSeconds<=3)
for i,b in Config.Biomes do
	assert(b.BaseIncome>0 and #b.Cars>=2)
	if i>1 then assert(b.MinPower>Config.Biomes[i-1].MinPower)end
	for _,c in b.Cars do assert(c.Weight>0 and #c.Name<80)end
end
for _,r in Config.Rarities do assert(r.Weight>0 and r.Multiplier>0)end
local world=World.build()
local remotes=Instance.new("Folder");remotes.Name,remotes.Parent="Remotes",RS.ThrowTickets
local function remote(name: string): RemoteEvent
	local r=Instance.new("RemoteEvent");r.Name,r.Parent=name,remotes;return r
end
local Throw,Train,Feedback,Ticket,Shop=remote("Throw"),remote("Train"),remote("Feedback"),remote("Ticket"),remote("Shop")
local states: {[Player]:any}={}
local plots: {[number]:boolean}={}
local views: {any}={}
for i=1,#Config.Biomes do
	for k=1,Config.ViewCarsPerBiome do table.insert(views,{biome=i,slot=k,model=world.Cars:FindFirstChild("View_"..i.."_"..k)})end
end
local rng=Random.new()
local serial=0
local function result(p: Player,text: string)
	p:SetAttribute("LastResult",text);Feedback:FireClient(p,text)
end
local function rootOf(p: Player): BasePart?
	local c=p.Character;local h=c and c:FindFirstChildOfClass("Humanoid");local r=c and c:FindFirstChild("HumanoidRootPart")
	return if h and h.Health>0 and r and r:IsA("BasePart") then r else nil
end
local function mutable(s: any): boolean
 return s~=nil and s.profile.Status=="active"
end
local function mirror(p: Player,s: any)
 p.leaderstats.Cash.Value=s.data.Cash;p:SetAttribute("ThrowPower",s.data.Power)
 p:SetAttribute("EquippedTicket",s.data.Equipped)
 for _,t in Config.Tickets do p:SetAttribute("Own_"..t.Id,s.data.Owned[t.Id]==true)end
 p:SetAttribute("EffectiveDistance",Rules.distance(s.data.Power,s.data.Equipped))
end
local function changed(p: Player,s: any)
 local parking={}
 for i=1,Config.ParkingSlots do local slot=s.slots[i];if slot then local r=slot.reward;table.insert(parking,{Slot=i,Biome=r.Biome,Rarity=r.Rarity,Name=r.Name})end end
 s.data.Parking=parking;profiles:touch(s.profile);mirror(p,s)
end
local function save(p: Player,s: any,release: boolean): string
 local status=profiles:save(s.profile,release)
 if p.Parent then
  p:SetAttribute("SaveStatus",if status=="saved"then "Saved"else "Save retrying")
  if status=="lost"then p:SetAttribute("DataReady",false);p:Kick("Progress opened on another server. Please rejoin.")end
 end
 return status
end
local function saveSoon(p: Player,s: any)
 if s.saveQueued then return end;s.saveQueued=true
 task.delay(math.max(Config.Data.SaveSoonSeconds,Config.Data.MinSaveGap-(os.clock()-s.profile.LastSave)),function()
  s.saveQueued=false;if states[p]==s and mutable(s)then save(p,s,false)end
 end)
end
local function publish(p: Player,s: any)
	local used,parked=0,0
	for i=1,Config.ParkingSlots do
		local slot=s.slots[i];local part=s.folder:FindFirstChild("Slot"..i)
		if slot then
			used+=1;if slot.model and slot.model.Parent then parked+=1 end
		end
		part:SetAttribute("PromisedIncome",if slot then slot.reward.Income else 0)
		part:SetAttribute("ActiveIncome",if slot then slot.activeIncome else 0)
		part:SetAttribute("Pending",slot~=nil and slot.pending==true)
	end
	p:SetAttribute("ParkingUsed",used);p:SetAttribute("ParkedCount",parked);p:SetAttribute("Income",s.income)
 changed(p,s)
end
local function takeView(biome: number)
	for _,v in views do
		if v.biome==biome and v.model and v.model.Parent then
			v.model:Destroy();v.model=nil
			task.delay(Config.TicketFlightSeconds+Config.TowApproachSeconds+Config.TowLoadSeconds+Config.RespawnSeconds,function()
				if world.Parent and not v.model then v.model=World.viewCar(world,v.biome,v.slot)end
			end)
			return
		end
	end
end
local function tweenPivot(model: Model,to: CFrame,seconds: number)
	local v=Instance.new("CFrameValue");v.Value=model:GetPivot()
	local c=v.Changed:Connect(function(cf)if model.Parent then model:PivotTo(cf)end end)
	local tween=TweenService:Create(v,TweenInfo.new(seconds,Enum.EasingStyle.Linear),{Value=to})
	tween:Play();tween.Completed:Wait();c:Disconnect();v:Destroy()
end
local function cleanJob(s: any,j: any)
	if j.tow and j.tow.Parent then j.tow:Destroy()end
	if j.car.Parent and not j.car:GetAttribute("Parked") then j.car:Destroy()end
	s.jobs[j.id]=nil
end
local function deliver(p: Player,s: any,j: any)
	task.wait(Config.TicketFlightSeconds)
	if states[p]~=s or not mutable(s)then cleanJob(s,j);return end
	local tow=Instance.new("Model");tow.Name="Tow_"..j.id;tow.ModelStreamingMode=Enum.ModelStreamingMode.Persistent;tow:SetAttribute("OwnerId",p.UserId)
	local body=World.part(tow,"Flatbed",Config.TowSize,j.position+Config.TowStartOffset,Color3.fromRGB(78,78,78))
	body.CanCollide=false;tow.PrimaryPart,tow.Parent=body,world.Tows;j.tow=tow
	tweenPivot(tow,CFrame.new(j.position+Config.TowApproachOffset),Config.TowApproachSeconds)
	if states[p]~=s or not mutable(s)or not j.car.Parent then cleanJob(s,j);return end
	tow:SetAttribute("Phase","Hook");task.wait(Config.TowLoadSeconds)
	if states[p]~=s or not mutable(s)or not j.car.Parent then cleanJob(s,j);return end
	j.car:PivotTo(tow:GetPivot()+Vector3.new(0,Config.TowLoadHeight,0));j.car.Parent=tow
	tow:SetAttribute("Phase","Return")
	local destination=if j.slot then s.positions[j.slot]-Vector3.new(0,Config.TowLoadHeight,0) else j.position+Config.SoldTowExit
	tweenPivot(tow,CFrame.new(destination),Config.TowReturnSeconds)
	if states[p]~=s or not mutable(s)then cleanJob(s,j);return end
	if j.action=="Sell" then
		local amount=Rules.salePrice(j.reward.Income)
		p:SetAttribute("Sales",p:GetAttribute("Sales")+1);p:SetAttribute("SaleTotal",p:GetAttribute("SaleTotal")+amount);p:SetAttribute("LastSale",amount)
		result(p,string.format("Sold for $%d",amount))
	else
		local slot=s.slots[j.slot]
		-- A newer, stronger pending car may have replaced this reservation.
		if slot and slot.token==j.id then
			local oldIncome=slot.activeIncome
			if slot.model and slot.model.Parent then slot.model:Destroy()end
			j.car:PivotTo(CFrame.new(s.positions[j.slot]));j.car.Parent=s.folder
			slot.model,slot.activeIncome,slot.pending=j.car,j.reward.Income,false
			s.income+=j.reward.Income-oldIncome
			j.car:SetAttribute("Parked",true)
			p:SetAttribute("Delivered",p:GetAttribute("Delivered")+1)
			if j.action=="Upgrade" then
				p:SetAttribute("Upgrades",p:GetAttribute("Upgrades")+1);result(p,"Upgraded parking!")
			else result(p,string.format("Parked! +$%d/s",j.reward.Income))end
		end
	end
	p:SetAttribute("LastDeliverySeconds",workspace:GetServerTimeNow()-j.started)
	publish(p,s);cleanJob(s,j)
end
Throw.OnServerEvent:Connect(function(p: Player,...: any)
	local s=states[p];if not mutable(s)then return end
	local now=os.clock();if now-s.lastRequest<Config.RequestInterval then return end;s.lastRequest=now
	-- Intent only. Even one client argument is invalid.
	if select("#",...)~=0 or now-s.lastThrow<Config.ThrowCooldown then return end
	local root=rootOf(p);if not root then return end
	if not Rules.inBox(root.Position,Config.LaunchCenter,Config.LaunchHalfX,Config.LaunchHalfZ,Config.LaunchHeightTolerance)then result(p,"Stand on the THROW line!");return end
	local power=s.data.Power
	if not Rules.finiteNumber(power)or power<0 then return end
	s.lastThrow=now
	local distance=Rules.distance(power,s.data.Equipped);local biome=Rules.biome(distance)
	local rarity=Rules.weighted(Rules.rarityWeights(s.data.Equipped),rng:NextNumber())
	local carType=Rules.weighted(Config.Biomes[biome].Cars,rng:NextNumber())
	local reward=Rules.reward(biome,rarity,carType)
	local incomes={};for i,slot in s.slots do incomes[i]=slot.reward.Income end
	local action,slotIndex=Rules.planParking(incomes,reward.Income)
	-- Commit sale cash with the roll. Disconnecting during the cosmetic tow loses no reward.
	if action=="Sell"then s.data.Cash=math.min(Config.MaxCash,s.data.Cash+Rules.salePrice(reward.Income))end
	serial+=1
	if slotIndex then
		local slot=s.slots[slotIndex]
		if not slot then slot={activeIncome=0,model=nil};s.slots[slotIndex]=slot end
		slot.reward,slot.token,slot.pending=reward,serial,true
	end
	-- All checks, roll and reservation finish before any yield.
	local landing=Vector3.new(Config.ThrowOrigin.X,Config.LandingHeight,Config.ThrowOrigin.Z-distance)
	local position=landing-Vector3.new(0,Config.RoofOffset,Config.WindshieldFront)
	takeView(biome)
	local model=World.car(world.Cars,"Ticketed_"..serial,reward,position)
	model:SetAttribute("TicketId",s.data.Equipped);model:SetAttribute("CarId",tostring(serial));model:SetAttribute("Claimed",true);model:SetAttribute("OwnerId",p.UserId)
	model:SetAttribute("Outcome",action);model:SetAttribute("SaleValue",Rules.salePrice(reward.Income))
	model:SetAttribute("ClaimedAt",workspace:GetServerTimeNow())
	local j={id=serial,car=model,reward=reward,action=action,slot=slotIndex,position=position,started=workspace:GetServerTimeNow()}
	s.jobs[serial]=j
	p:SetAttribute("Throws",p:GetAttribute("Throws")+1)
	p:SetAttribute("LastDistance",distance);p:SetAttribute("LastBiome",biome);p:SetAttribute("LastRarity",rarity)
	p:SetAttribute("LastCarName",reward.Name);p:SetAttribute("LastRollIncome",reward.Income);p:SetAttribute("LastOutcome",action)
	p:SetAttribute("LastSlot",slotIndex or 0);p:SetAttribute("LastLandingZ",landing.Z)
	publish(p,s)
	-- Metadata is independent of streamed instance availability on a distant client.
	Ticket:FireAllClients(Config.ThrowOrigin,landing,model,p.UserId,reward.Income,{Id=tostring(serial),Name=reward.Name,Rarity=rarity,Biome=biome,Income=reward.Income,Outcome=action,SaleValue=Rules.salePrice(reward.Income),Position=position,TicketId=s.data.Equipped})
	result(p,string.format("%s | %s | $%d/s",reward.Name,Config.Rarities[rarity].Name,reward.Income))
	task.spawn(deliver,p,s,j)
end)
Train.OnServerEvent:Connect(function(p: Player,...: any)
	local s=states[p];if not mutable(s)then return end
	local now=os.clock();if now-s.lastTrain<Config.TrainRequestInterval then return end;s.lastTrain=now
	if select("#",...)~=1 then return end
	local enabled=...;if typeof(enabled)~="boolean"or not rootOf(p)then return end
	p:SetAttribute("Training",enabled)
end)
Shop.OnServerEvent:Connect(function(p: Player,...: any)
 local s=states[p];if not mutable(s)then return end
 local now=os.clock();if now-s.lastShop<Config.ShopRequestInterval then return end;s.lastShop=now
 if select("#",...)~=2 then return end
 local action,id=...;local text=Rules.shop(s.data,action,id)
 result(p,text)
 if text:sub(1,7)=="Bought "or text:sub(1,9)=="Equipped "then changed(p,s);saveSoon(p,s)end
end)
local function joined(p: Player)
 if closing then return end
 loading+=1
 p:SetAttribute("DataReady",false);p:SetAttribute("SaveStatus","Loading")
 local stats=Instance.new("Folder");stats.Name,stats.Parent="leaderstats",p
 local cash=Instance.new("IntValue");cash.Name,cash.Parent="Cash",stats
 local suffix=if RunService:IsStudio()then ServerStorage:GetAttribute("TestProfileKey")else nil
 local key=(if typeof(suffix)=="string"and #suffix<=40 then "QA_"..suffix.."_" else "U_")..p.UserId
 local profile,status=profiles:load(key,p.UserId,function()return closing or not p.Parent end)
 loading-=1
 if not profile then
  if p.Parent then p:SetAttribute("SaveStatus",status);p:Kick(if status=="locked"then "Progress is saving elsewhere. Rejoin in a minute."else "Progress could not load safely. Please rejoin. In Studio, enable API Services.")end
  return
 end
 local plot=1;while plots[plot]do plot+=1 end;plots[plot]=true
 local folder,positions=World.parking(world,plot,p.UserId,p.DisplayName)
 local s={folder=folder,positions=positions,slots={},jobs={},income=0,plot=plot,profile=profile,data=profile.Data,lastThrow=-math.huge,lastRequest=-math.huge,lastTrain=-math.huge,lastShop=-math.huge}
 states[p]=s
 for name,value in {Income=0,ParkingUsed=0,ParkedCount=0,Delivered=0,Throws=0,Sales=0,SaleTotal=0,LastSale=0,Upgrades=0}do p:SetAttribute(name,value)end
 for _,record in s.data.Parking do
  local reward=Rules.savedReward(record);local model=World.car(folder,"Parked_"..record.Slot,reward,positions[record.Slot]);model:SetAttribute("Parked",true);model:SetAttribute("OwnerId",p.UserId)
  s.slots[record.Slot]={reward=reward,activeIncome=reward.Income,model=model,token=0,pending=false};s.income+=reward.Income
 end
 p:SetAttribute("Training",false);publish(p,s);p:SetAttribute("DataReady",true);p:SetAttribute("SaveStatus","Saved")
 local function characterAdded(c: Model)
  p:SetAttribute("Training",false)
  local r=c:WaitForChild("HumanoidRootPart")::BasePart
  if c.Parent then r.CFrame=CFrame.lookAt(Config.SpawnPosition+Vector3.new(0,Config.SpawnLift,0),Vector3.new(0,Config.SpawnLift,-20))end
 end
 p.CharacterAdded:Connect(characterAdded);if p.Character then task.spawn(characterAdded,p.Character)end
end
local function release(p: Player)
 local s=states[p];if not s then return end
 states[p]=nil;p:SetAttribute("DataReady",false);s.profile.Status="closing";leaving+=1
 -- detach gameplay before the first yield; promised cars were already checkpointed.
 for _,j in s.jobs do cleanJob(s,j)end
 plots[s.plot]=nil;s.folder:Destroy()
 save(p,s,true);leaving-=1
end
Players.PlayerAdded:Connect(function(p)task.spawn(joined,p)end)
for _,p in Players:GetPlayers()do task.spawn(joined,p)end
Players.PlayerRemoving:Connect(release)
game:BindToClose(function()
 closing=true
 for p in states do task.spawn(release,p)end
 local deadline=os.clock()+Config.Data.ShutdownSeconds
 while (leaving>0 or loading>0)and os.clock()<deadline do task.wait(.1)end
end)
task.spawn(function()
 while not closing do
  task.wait(Config.TickSeconds)
  for p,s in states do if mutable(s)then
   s.data.Cash=math.min(Config.MaxCash,s.data.Cash+s.income)
   local r=rootOf(p)
   local onPad=r and Rules.inBox(r.Position,Config.TrainingPosition,Config.TrainingRadius,Config.TrainingRadius,Config.TrainingHeightTolerance)
   local training=r~=nil and(p:GetAttribute("Training")==true or onPad==true)
   p:SetAttribute("TrainingActive",training)
   if training then s.data.Power=math.min(Config.MaxPower,s.data.Power+Config.TrainGain)end
   if training or s.income>0 then profiles:touch(s.profile)end;mirror(p,s)
   if os.clock()>=s.profile.NextSave and not s.profile.Saving then
    if s.profile.Dirty or os.clock()-s.profile.LastSave>=Config.Data.LeaseSeconds/3 then
     if game:GetService("DataStoreService"):GetRequestBudgetForRequestType(Enum.DataStoreRequestType.UpdateAsync)>0 then
      s.profile.NextSave=os.clock()+Config.Data.AutosaveSeconds;task.spawn(save,p,s,false)
     end
    else s.profile.NextSave=s.profile.LastSave+Config.Data.LeaseSeconds/3 end
   end
  end end
 end
end)
-- Server-only Studio harness. No RemoteEvent, no live grants, no client access.
if RunService:IsStudio()then
 local qa=Instance.new("BindableFunction");qa.Name="ThrowTicketsQA";qa.Parent=ServerStorage
 qa.OnInvoke=function(command: string,value: any,target: Player?)
  local p=target or Players:GetPlayers()[1];local s=states[p];if not s then return nil end
  if command=="Inspect"then return Schema.copy(s.data)
  elseif command=="SetCash"and Rules.finiteNumber(value)and value>=0 and value<=Config.MaxCash then s.data.Cash=math.floor(value);changed(p,s);return true
  elseif command=="SetPower"and Rules.finiteNumber(value)and value>=0 and value<=Config.MaxPower then s.data.Power=math.floor(value);changed(p,s);return true
  elseif command=="Save"then return save(p,s,false)
  elseif command=="Exit"then release(p);return true end
  return nil
 end
end
print("[ThrowTickets] Tickets, session persistence and Rusty Sedan sample ready.")

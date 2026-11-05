--!strict
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local Http=game:GetService("HttpService")
local RunService=game:GetService("RunService")
local SS=game:GetService("ServerStorage")
local Config=require(RS.ThrowTickets.Config)
local Rules=require(RS.ThrowTickets.Rules)
local GarageRules=require(RS.ThrowTickets.GarageRules)
local World=require(script.Parent.World)
local Schema=require(script.Parent.ProfileSchema)
local Profiles=require(script.Parent.Profiles)
local Tools=require(script.Parent.CarTools)
local Meter=require(RS.ThrowTickets.ThrowMeter)
local J=require(RS.ThrowTickets.JuiceRules)
local Progression=require(RS.ThrowTickets.Progression)
local GearService=require(script.Parent.GearService)
local GarageService=require(script.Parent.GarageService)
local ParkingUpgrade=require(script.Parent.ParkingUpgrade)
local ReturnRules=require(RS.ThrowTickets.ReturnRules)
local ReturnClock=require(script.Parent.ReturnClock)
local ReturnService=require(script.Parent.ReturnService)
local Leaderboards=require(script.Parent.Leaderboards)
local profiles=Profiles.new(game:GetService("DataStoreService"):GetDataStore(Config.Data.StoreName..(if RunService:IsStudio()then "_STUDIO"else "")))
local world=World.build()
local old=RS.ThrowTickets:FindFirstChild("Remotes");if old then old:Destroy()end
local remotes=Instance.new("Folder");remotes.Name,remotes.Parent="Remotes",RS.ThrowTickets
local function remote(name: string): RemoteEvent local r=Instance.new("RemoteEvent");r.Name,r.Parent=name,remotes;return r end
local Throw,Train,Feedback,Ticket,Shop,Garage,Snapshot=remote("Throw"),remote("Train"),remote("Feedback"),remote("Ticket"),remote("Shop"),remote("Garage"),remote("InventorySnapshot")
local ConfirmSale=remote("ConfirmSale")
local Juice,SelectPower,ContinueCatch,TrainingBoost,GearVisit=remote("Juice"),remote("SelectPower"),remote("ContinueCatch"),remote("TrainingBoost"),remote("GearVisit")
local JuiceReady=remote("JuiceReady")
local ReturnClaim,Social=remote("ReturnClaim"),remote("Social")
local returnService: any
local boards: any
local gearService: any
local garageService: any
local parkingUpgrade: any
local states: {[Player]:any}={}
local plots: {[number]:boolean}={}
local loading,leaving=0,0
local closing=false
local rng=Random.new()
local function result(p: Player,text: string)if p.Parent then p:SetAttribute("LastResult",text);Feedback:FireClient(p,text)end end
local function rootOf(p: Player): BasePart?
 local c=p.Character;local h=c and c:FindFirstChildOfClass("Humanoid");local r=c and c:FindFirstChild("HumanoidRootPart")
 return if h and h.Health>0 and r and r:IsA("BasePart")then r else nil
end
local function mutable(s: any): boolean return s~=nil and s.profile.Status=="active"and not s.rewardBusy and not s.rewardFailed end
local function trainingNow(p: Player,s: any,enabled: boolean): boolean
 local root=rootOf(p);local pad=s.folder:FindFirstChild("TrainingPad")
 return Rules.trainingActive(if root then root.Position else nil,if pad then pad.Position else nil,enabled,s.job~=nil or s.meter~=nil)
end
local function selection(s: any): number return if s.selectedMax~=false then s.data.Power else math.clamp(s.selectedPower or s.data.Power,math.min(1,s.data.Power),s.data.Power)end
local function mirror(p: Player,s: any)
 p.leaderstats.Cash.Value=s.data.Cash;p:SetAttribute("ThrowPower",s.data.Power)
 p:SetAttribute("EquippedTicket",s.data.Equipped);p:SetAttribute("EffectiveDistance",Rules.distance(s.data.Power))
 for _,t in Config.Tickets do p:SetAttribute("Own_"..t.Id,s.data.Owned[t.Id]==true)end
 p:SetAttribute("Exercise",s.data.Exercise);p:SetAttribute("TrainingRate",Rules.trainingRate(s.data.Power,s.data.Exercise))
 p:SetAttribute("InventoryCount",GarageRules.inventoryCount(s.data));p:SetAttribute("Income",s.income)
 p:SetAttribute("TrainingLevel",s.data.TrainingLevel);p:SetAttribute("TrainingXP",s.data.TrainingXP);p:SetAttribute("TrainingXPNeeded",Config.Progression.XPPerLevel);p:SetAttribute("ThrowSelection",selection(s));p:SetAttribute("SelectionMax",s.selectedMax~=false)
 if gearService then gearService.update(p,s)end
 if parkingUpgrade then parkingUpgrade.update(p,s)end
 if returnService then returnService.update(p,s)end
end
local function snapshot(p: Player,s: any)
 local cards={};for _,c in s.data.Cars do if not c.Pending then local r=Rules.savedReward(c);table.insert(cards,{Id=c.Id,Name=c.Name,Biome=c.Biome,Rarity=c.Rarity,CatalogId=c.CatalogId,Variant=c.Variant,Income=r.Income,Slot=c.Slot})end end
 Snapshot:FireClient(p,{Cars=cards,InventoryCount=GarageRules.inventoryCount(s.data),Limit=Config.InventoryLimit,ParkingCapacity=s.data.ParkingCapacity,Discovered=s.data.Discovered,NewestId=p:GetAttribute("LastCapturedId")})
end
local function publish(p: Player,s: any)
 for id,model in s.placed do local c=GarageRules.find(s.data,id);if not c or c.Slot==0 then model:Destroy();s.placed[id]=nil end end
 World.capacity(s.folder,s.data.ParkingCapacity)
 for i=1,Config.ParkingMax do local part=s.folder["Slot"..i];part:SetAttribute("CarId",nil);part:SetAttribute("ActiveIncome",0)end
 local parked=0
 for _,c in s.data.Cars do if c.Slot>0 then
  parked+=1;local reward=Rules.savedReward(c);local model=s.placed[c.Id]
  if not model then
   model=World.car(s.folder,"Parked_"..c.Id,reward,s.positions[c.Slot]);model:SetAttribute("OwnerId",p.UserId);model:SetAttribute("CarId",c.Id);model:SetAttribute("Parked",true);s.placed[c.Id]=model
   model:ScaleTo(model:GetScale()*.60)
   local label=World.label(model.PrimaryPart,c.Name.."\n"..c.Variant.."  •  $"..reward.Income.."/s",3.2)
   label.Name="CarLabel";label.Size=UDim2.fromOffset(144,35);label.MaxDistance=22;label.AlwaysOnTop=false;label.TextLabel.TextSize=14
   if garageService then garageService.prompt(p,s,model.PrimaryPart,"Remove",c.Id,c.Slot)end
  end
  model:PivotTo(model:GetPivot()+s.positions[c.Slot]-model.PrimaryPart.Position+Vector3.new(0,model.PrimaryPart.Size.Y/2-Config.CarHeight+.1,0))
  s.folder["Slot"..c.Slot]:SetAttribute("CarId",c.Id);s.folder["Slot"..c.Slot]:SetAttribute("ActiveIncome",reward.Income)
 end end
 s.income=GarageRules.income(s.data);p:SetAttribute("ParkingUsed",parked);p:SetAttribute("ParkedCount",parked)
 profiles:touch(s.profile);Tools.sync(p,s);mirror(p,s);snapshot(p,s)
end
local function save(p: Player,s: any,release: boolean): string
 local status=profiles:save(s.profile,release)
 if p.Parent then p:SetAttribute("SaveStatus",if status=="saved"then "Saved"else "Save retrying")
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
local function atPlot(p: Player,s: any): boolean
 local r=rootOf(p);return r~=nil and (r.Position-s.center).Magnitude<=Config.PlotInteractRadius
end
local function teleport(p: Player,s: any,plot: boolean)
 p:SetAttribute("Training",false);p:SetAttribute("TrainingActive",false);s.spawnPlot=plot
 local r=rootOf(p);local pos=if plot then s.entrance else Config.SpawnPosition+Vector3.new(0,Config.SpawnLift,0)
 if r then
  r.AssemblyLinearVelocity=Vector3.zero;r.AssemblyAngularVelocity=Vector3.zero
  p.Character:PivotTo(CFrame.lookAt(pos,pos+Vector3.new(0,0,-20)))
 end
 p:SetAttribute("Location",if plot then "Plot"else "Road")
end
local function tweenPivot(model: Model,to: CFrame,seconds: number,style: Enum.EasingStyle?)
 local value=Instance.new("CFrameValue");value.Value=model:GetPivot()
 local c=value.Changed:Connect(function(cf)if model.Parent then model:PivotTo(cf)end end)
 local tween=TweenService:Create(value,TweenInfo.new(seconds,style or Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Value=to})
 tween:Play();tween.Completed:Wait();c:Disconnect();value:Destroy()
end
local function cleanJob(job: any)
 if job.tow and job.tow.Parent then job.tow:Destroy()end
 if job.car and job.car.Parent then job.car:Destroy()end
end
local function phase(p: Player,s: any,value: string)
 s.phase=value;p:SetAttribute("ThrowPhase",value);p:SetAttribute("Throwing",value~="Idle")
end
local function completeCatch(p: Player,s: any,j: any)
 if states[p]~=s or not mutable(s)or s.job~=j then cleanJob(j);return end
 local record=GarageRules.find(s.data,j.id)
 if record then record.Pending=nil end
 s.data.Returns.Tutorial=true
 cleanJob(j);s.job=nil;phase(p,s,"Idle")
 p:SetAttribute("LastCapturedId",j.id);p:SetAttribute("LastDeliverySeconds",workspace:GetServerTimeNow()-j.started)
 p:SetAttribute("Delivered",(p:GetAttribute("Delivered")or 0)+1)
 teleport(p,s,true);publish(p,s);Tools.equip(p,s,j.id);saveSoon(p,s);result(p,if j.discovered then "NEW CAR DISCOVERED!" else "Car caught! Hold E at a free parking spot.")
end
local function runCatch(p: Player,s: any,j: any)
 local ok,err=xpcall(function()
  task.delay(Config.ThrowWindupSeconds,function()if states[p]==s and s.job==j and mutable(s)then phase(p,s,"Flying")end end)
  tweenPivot(j.car,CFrame.new(j.position-Vector3.new(0,0,2)),Config.ThrowWindupSeconds+Config.TicketFlightSeconds)
  if states[p]~=s or not mutable(s)or s.job~=j then cleanJob(j);return end
  phase(p,s,"Hit");p:SetAttribute("LastHitAt",workspace:GetServerTimeNow())
  tweenPivot(j.car,CFrame.new(j.position),Config.Juice.BrakeSeconds,Enum.EasingStyle.Quad)
  if states[p]~=s or not mutable(s)or s.job~=j then cleanJob(j);return end
  phase(p,s,"Reveal");j.revealAt=workspace:GetServerTimeNow()
  j.readyAt=j.revealAt+(if j.metadata.SuperLucky or j.reward.Rarity>=3 then 1.2 else .65);j.metadata.ReadyAt=j.readyAt
  Juice:FireClient(p,"Reveal",j.metadata)
  while states[p]==s and mutable(s)and not j.continued and workspace:GetServerTimeNow()<j.revealAt+Config.Juice.RevealTimeout do task.wait(.05)end
  if states[p]~=s or not mutable(s)then cleanJob(j);return end
  phase(p,s,"Tow")
  local tow=Instance.new("Model");tow.Name="Tow_"..j.id;tow.ModelStreamingMode=Enum.ModelStreamingMode.Persistent;tow:SetAttribute("OwnerId",p.UserId)
  local body=World.part(tow,"Flatbed",Config.TowSize,j.position+Config.TowStartOffset,Color3.fromRGB(78,78,78));body.CanCollide=false;body.CanTouch=false;body.CanQuery=false
  tow.PrimaryPart,tow.Parent=body,world.Tows;j.tow=tow
  tweenPivot(tow,CFrame.new(j.position+Config.TowApproachOffset),Config.TowApproachSeconds)
  if states[p]~=s or not mutable(s)then cleanJob(j);return end
  tow:SetAttribute("Phase","Hook");task.wait(Config.TowLoadSeconds)
  if states[p]~=s or not mutable(s)then cleanJob(j);return end
  j.car:PivotTo(tow:GetPivot()+Vector3.new(0,Config.TowLoadHeight,0));j.car.Parent=tow;tow:SetAttribute("Phase","Return")
  tweenPivot(tow,CFrame.new(s.entrance-Vector3.new(0,2,0)),Config.TowReturnSeconds)
  completeCatch(p,s,j)
 end,debug.traceback)
 if not ok then warn("[ThrowTickets] Cosmetic transport recovered: "..tostring(err));completeCatch(p,s,j)end
end
local function performThrow(p: Player,bonus: number)
 local s=states[p];if not mutable(s)then return end
 local now=os.clock()
 if s.job or now-s.lastThrow<Config.ThrowCooldown then return end
 local r=rootOf(p);if not r then return end
 if not Rules.inBox(r.Position,Config.LaunchCenter,Config.LaunchHalfX,Config.LaunchHalfZ,Config.LaunchHeightTolerance)then result(p,"Stand on the THROW line!");return end
 if GarageRules.inventoryCount(s.data)>=Config.InventoryLimit then result(p,"Inventory full!");return end
 local chosen=selection(s);local distance=J.distance(s.data.Power,chosen,bonus);local biome=Rules.biome(distance)
 s.meter=nil;p:SetAttribute("MeterStart",nil);p:SetAttribute("LastThrowBonus",bonus)
 local humanoid=p.Character and p.Character:FindFirstChildOfClass("Humanoid");if humanoid then humanoid:UnequipTools()end
 local reward=Rules.rollCar(biome,s.data.Equipped,rng,if RunService:IsStudio()then s.nextRoll else nil);s.nextRoll=nil
 local discovered=not s.data.Discovered[reward.CatalogId]
 local best=0;for _,owned in s.data.Cars do best=math.max(best,Rules.savedReward(owned).Income)end
 local id=Http:GenerateGUID(false)
 assert(GarageRules.add(s.data,reward,id,true))
 s.data.Returns.BestOdds=math.max(s.data.Returns.BestOdds,math.floor(J.odds(reward,s.data.Equipped)))
 s.lastThrow=now;p:SetAttribute("Training",false);p:SetAttribute("TrainingActive",false);phase(p,s,"Windup")
 local car=World.car(world.Cars,"Ticketed_"..id,reward,Vector3.zero)
 local offset=World.ticketOffset(car)
 local landing=Vector3.new(Config.CaptureLaneX,Config.CarHeight+offset.Y,-distance)
 local position=landing-offset
 local approach=position+Vector3.new(0,0,-Config.CaptureApproachDistance)
 car:PivotTo(car:GetPivot()+approach-car.PrimaryPart.Position)
 car:SetAttribute("CarId",id);car:SetAttribute("Claimed",true);car:SetAttribute("OwnerId",p.UserId);car:SetAttribute("TicketId",s.data.Equipped);car:SetAttribute("Outcome","Inventory")
 local j={id=id,car=car,reward=reward,position=position,discovered=discovered,started=workspace:GetServerTimeNow()};s.job=j
 -- Confirm ownership durably before showing the accepted throw; the job blocks all competing actions while this yields.
 profiles:touch(s.profile)
 local saved=save(p,s,false)
 if saved~="saved"or states[p]~=s or not mutable(s)then
  cleanJob(j)
  if states[p]==s and p.Parent then p:Kick("Progress could not be saved safely. Please rejoin.")end
  return
 end
 local start=workspace:GetServerTimeNow();j.started=start
 for key,value in {LastDistance=distance,LastBiome=biome,LastRarity=reward.Rarity,LastCarName=reward.Name,LastRollIncome=reward.Income,LastLandingZ=landing.Z,LastShotId=id,Throws=(p:GetAttribute("Throws")or 0)+1}do p:SetAttribute(key,value)end
 publish(p,s);saveSoon(p,s)
 j.metadata={Id=id,Name=reward.Name,Rarity=reward.Rarity,Biome=biome,Income=reward.Income,Position=position,ApproachFrom=approach,TicketId=s.data.Equipped,StartTime=start,WindupSeconds=Config.ThrowWindupSeconds,FlightSeconds=Config.TicketFlightSeconds,Reveal=true,NewBest=reward.Income>best,Odds=J.odds(reward,s.data.Equipped),Luck=1+Rules.ticket(s.data.Equipped).Luck,Perfect=J.perfect(bonus),BonusPower=chosen*bonus}
 j.metadata.CatalogId=reward.CatalogId;j.metadata.Variant=reward.Variant;j.metadata.SuperLucky=reward.Rarity==4 or reward.Variant~="Normal"
 Juice:FireClient(p,"ThrowResult",{Perfect=j.metadata.Perfect,BonusPower=j.metadata.BonusPower})
 Ticket:FireAllClients(Config.ThrowOrigin,landing,car,p.UserId,reward.Income,j.metadata)
 task.spawn(runCatch,p,s,j)
end
Train.OnServerEvent:Connect(function(p: Player,...: any)
 local s=states[p];if not mutable(s)or select("#",...)~=1 or s.job then return end
 local now=os.clock();if now-s.lastTrain<Config.TrainRequestInterval then return end;s.lastTrain=now
 local enabled=...;if typeof(enabled)~="boolean"or not rootOf(p)or s.meter then return end
 if enabled and not trainingNow(p,s,true)then result(p,"Stand on your training pad!");return end
 p:SetAttribute("Training",enabled);p:SetAttribute("TrainingActive",trainingNow(p,s,enabled))
end)
Shop.OnServerEvent:Connect(function(p: Player,...: any)
 local s=states[p];if not mutable(s)or s.job or s.meter or select("#",...)~=2 then return end
 local now=os.clock();if now-s.lastShop<Config.ShopRequestInterval then return end;s.lastShop=now
 local action,id=...;local text=Rules.shop(s.data,action,id);result(p,text)
 if text:sub(1,7)=="Bought "or text:sub(1,9)=="Equipped "then publish(p,s);saveSoon(p,s)end
end)
garageService=GarageService.new({mutable=mutable,rootOf=rootOf,atPlot=atPlot,result=result,publish=publish,saveSoon=saveSoon,confirm=ConfirmSale})
parkingUpgrade=ParkingUpgrade.new({mutable=mutable,rootOf=rootOf,result=result,publish=publish,saveSoon=saveSoon})
Garage.OnServerEvent:Connect(function(p: Player,...: any)
 local s=states[p];if not mutable(s)or select("#",...)~=3 then return end
 local now=os.clock();if now-s.lastGarage<Config.GarageRequestInterval then return end;s.lastGarage=now
 local action,id,index=...
 if typeof(action)~="string"or #action>12 then return end
 if action=="Sync"and id==""and index==0 then snapshot(p,s);return end
 garageService.act(p,s,action,id,index)
end)
-- Client supplies only the synchronized tap time; no position, reward or bonus.
Throw.OnServerEvent:Connect(function(p: Player,...: any)
 local s=states[p];if not mutable(s)or select("#",...)~=1 or not s.meter or s.job then return end
 local now=os.clock();if now-s.lastRequest<Config.RequestInterval then return end;s.lastRequest=now
 local tap=...;local bonus=Meter.tap(s.meter,tap,workspace:GetServerTimeNow(),p:GetNetworkPing())
 if bonus==nil then return end
 performThrow(p,bonus)
end)
SelectPower.OnServerEvent:Connect(function(p: Player,...: any)
 local s=states[p];if not mutable(s)or s.job or s.meter or select("#",...)~=1 then return end
 local now=os.clock();if now-(s.lastSelection or 0)<.08 then return end;s.lastSelection=now
 local value=J.selection(s.data.Power,...);if value==nil then return end
 s.selectedPower=value;s.selectedMax=math.abs(value-s.data.Power)<.0001;mirror(p,s)
end)
JuiceReady.OnServerEvent:Connect(function(p: Player,...: any)
 local s=states[p];if select("#",...)~=0 or not mutable(s)or p:GetAttribute("DataReady")~=true or s.juiceReady then return end
 s.juiceReady=true;gearService.update(p,s)
end)
ContinueCatch.OnServerEvent:Connect(function(p: Player,...: any)
 local s=states[p];if not mutable(s)or select("#",...)~=1 or not s.job or s.phase~="Reveal"then return end
 local id=...;local j=s.job
 if typeof(id)~="string"or #id>64 or id~=j.id or workspace:GetServerTimeNow()<j.readyAt then return end
 j.continued=true
end)
TrainingBoost.OnServerEvent:Connect(function(p: Player,...: any)
 local s=states[p];if not mutable(s)or select("#",...)~=1 or not trainingNow(p,s,p:GetAttribute("Training")==true)then return end
 local id=...;local offer=s.boostOffer;local now=workspace:GetServerTimeNow()
 if typeof(id)~="string"or #id>64 or not offer or id~=offer.Id or now>offer.ExpiresAt or now<(s.boostUntil or 0)then return end
 s.boostOffer=nil;s.boostUntil=now+Config.Progression.BoostSeconds;s.nextBoostOffer=now+Config.Progression.OfferEvery
 p:SetAttribute("BoostUntil",s.boostUntil);Juice:FireClient(p,"BoostStarted",{Until=s.boostUntil})
end)
GearVisit.OnServerEvent:Connect(function(p: Player,...: any)
 local s=states[p];if not mutable(s)or select("#",...)~=2 then return end
 gearService.visit(p,s,...)
end)
local poll=0
RunService.Heartbeat:Connect(function(dt)
 poll+=dt;if poll<Config.ThrowMeter.PollSeconds then return end;poll=0
 for p,s in states do if mutable(s)then
  local r=rootOf(p);local inside=r~=nil and Rules.inBox(r.Position,Config.LaunchCenter,Config.LaunchHalfX,Config.LaunchHalfZ,Config.LaunchHeightTolerance)
  if not inside then s.padArmed=true end
  if s.meter then
   if not inside or s.job then s.meter=nil;p:SetAttribute("MeterStart",nil);phase(p,s,"Idle")
   elseif workspace:GetServerTimeNow()-s.meter>=Config.ThrowMeter.Timeout then performThrow(p,Meter.bonus(.5))end
  elseif inside and s.padArmed and not s.job and os.clock()-s.lastThrow>=Config.ThrowCooldown then
   s.padArmed=false
   if GarageRules.inventoryCount(s.data)>=Config.InventoryLimit then result(p,"Backpack full! Sell or park a car before throwing.")
   else s.meter=workspace:GetServerTimeNow();p:SetAttribute("MeterStart",s.meter);p:SetAttribute("Training",false);p:SetAttribute("TrainingActive",false);phase(p,s,"Meter")end
  end
  local onPad=trainingNow(p,s,true)
  if onPad and not s.onTrainingPad and not s.job and not s.meter then p:SetAttribute("Training",true)end
  if not onPad then p:SetAttribute("Training",false)end
  s.onTrainingPad=onPad
  p:SetAttribute("TrainingActive",trainingNow(p,s,p:GetAttribute("Training")==true))
 end end
end)
gearService=GearService.new({Juice=Juice,result=result,rootOf=rootOf,mutable=mutable})
returnService=ReturnService.new({profiles=profiles,save=save,publish=publish,result=result,mutable=mutable,social=Social})
boards=Leaderboards.new(world,states)
ReturnClaim.OnServerEvent:Connect(function(p: Player,...: any)
 if select("#",...)~=1 then return end
 local s=states[p];if s then returnService.claim(p,s,...)end
end)
Social.OnServerEvent:Connect(function(p: Player,...: any)
 local s=states[p];if not mutable(s)or select("#",...)~=1 then return end
 local busy=...;if typeof(busy)=="boolean"then s.modal=busy end
end)
local function joined(p: Player)
 if closing then return end;loading+=1;p:SetAttribute("DataReady",false)
 local stats=Instance.new("Folder");stats.Name,stats.Parent="leaderstats",p
 local cash=Instance.new("IntValue");cash.Name,cash.Parent="Cash",stats
 local suffix=if RunService:IsStudio()then SS:GetAttribute("TestProfileKey")else nil
 local key=(if typeof(suffix)=="string"and #suffix<=40 then "QA_"..suffix.."_"else "U_")..p.UserId
 local profile,status=profiles:load(key,p.UserId,function()return closing or not p.Parent end);loading-=1
 if not profile then if p.Parent then p:Kick(if status=="locked"then "Progress is saving elsewhere. Rejoin shortly."else "Progress could not load safely. Please rejoin.")end;return end
 local plot=1;while plots[plot]do plot+=1 end;plots[plot]=true
 local folder,positions=World.parking(world,plot,p.UserId,p.DisplayName)
 local entrance=positions[1]+Vector3.new(0,3,6)
 local s={profile=profile,data=profile.Data,plot=plot,folder=folder,positions=positions,entrance=entrance,center=folder.ParkingGround.Position,placed={},tools={},padArmed=true,income=0,phase="Idle",lastThrow=-math.huge,lastRequest=-math.huge,lastTrain=-math.huge,lastShop=-math.huge,lastGarage=-math.huge}
 states[p]=s;s.nextBoostOffer=workspace:GetServerTimeNow()+6
 if not returnService.arrive(p,s)then
  if states[p]==s and p.Parent then s.rewardFailed=true;p:Kick("Return rewards could not load safely. Please rejoin.")end
  return
 end
 if states[p]~=s or not p.Parent or profile.Status~="active"or closing then return end
 gearService.mount(p,s)
 parkingUpgrade.mount(p,s)
 for i=1,Config.ParkingMax do garageService.prompt(p,s,folder["Slot"..i],"Place","",i)end
 for key,value in {Throws=0,Delivered=0,InventoryCount=0,Income=0,ParkingUsed=0,ParkedCount=0}do p:SetAttribute(key,value)end
 p:SetAttribute("Location","Road");p:SetAttribute("Training",false);p:SetAttribute("TrainingActive",false);phase(p,s,"Idle")
 publish(p,s);p:SetAttribute("DataReady",true);p:SetAttribute("SaveStatus","Saved")
 local function characterAdded(c: Model)
  p:SetAttribute("Training",false);p:SetAttribute("TrainingActive",false);c:WaitForChild("HumanoidRootPart")
  if states[p]==s and c.Parent then
   s.meter=nil;p:SetAttribute("MeterStart",nil);if not s.job then phase(p,s,"Idle")end
   teleport(p,s,s.spawnPlot==true);Tools.sync(p,s)
  end
 end
 p.CharacterAdded:Connect(characterAdded);if p.Character then task.spawn(characterAdded,p.Character)end
end
local function release(p: Player)
 local s=states[p];if not s or s.releasing then return end;s.releasing=true;leaving+=1
 while s.rewardBusy do task.wait(.05)end
 states[p]=nil;p:SetAttribute("DataReady",false);s.profile.Status="closing"
 ReturnRules.depart(s.data,ReturnClock.now());profiles:touch(s.profile)
 boards.leaving(p,s)
 if s.job then cleanJob(s.job)end;s.folder:Destroy();plots[s.plot]=nil
 save(p,s,true);leaving-=1
end
Players.PlayerAdded:Connect(function(p)task.spawn(joined,p)end);for _,p in Players:GetPlayers()do task.spawn(joined,p)end
Players.PlayerRemoving:Connect(release)
game:BindToClose(function()
 closing=true;for p in states do task.spawn(release,p)end
 local deadline=os.clock()+Config.Data.ShutdownSeconds;while(leaving>0 or loading>0)and os.clock()<deadline do task.wait(.1)end
end)
task.spawn(function()
 local previous=os.clock();local playFraction=0
 while not closing do task.wait(Config.TickSeconds)
  local elapsed=os.clock()-previous;previous=os.clock();playFraction+=elapsed;local played=math.floor(playFraction);playFraction-=played
  for p,s in states do if mutable(s)then
   s.data.Cash=math.min(Config.MaxCash,s.data.Cash+s.income)
   local training=trainingNow(p,s,p:GetAttribute("Training")==true)
   p:SetAttribute("TrainingActive",training)
   if training then
    local now=workspace:GetServerTimeNow();local boosted=now<(s.boostUntil or 0)
    if s.boostOffer and now>s.boostOffer.ExpiresAt then s.boostOffer=nil end
    if not boosted and not s.boostOffer and now>=(s.nextBoostOffer or 0)then
     s.boostOffer={Id=Http:GenerateGUID(false),ExpiresAt=now+Config.Progression.OfferLifetime};s.nextBoostOffer=now+Config.Progression.OfferEvery;Juice:FireClient(p,"BoostOffer",s.boostOffer)
    end
    local amount=Rules.trainingRate(s.data.Power,s.data.Exercise)*Config.Progression.XPPerLevel*Config.TickSeconds*(if boosted then 2 else 1)
    local levels,gain=Progression.addXP(s.data,amount)
    Juice:FireClient(p,"XP",{Amount=amount,Levels=levels,Gain=gain,Level=s.data.TrainingLevel,XP=s.data.TrainingXP,Needed=Config.Progression.XPPerLevel,Power=s.data.Power,Boosted=boosted})
   end
   returnService.tick(p,s,played)
   if played>0 or training or s.income>0 then profiles:touch(s.profile)end;mirror(p,s)
   if os.clock()>=s.profile.NextSave and not s.profile.Saving then
    if s.profile.Dirty or os.clock()-s.profile.LastSave>=Config.Data.LeaseSeconds/3 then
     if game:GetService("DataStoreService"):GetRequestBudgetForRequestType(Enum.DataStoreRequestType.UpdateAsync)>0 then s.profile.NextSave=os.clock()+Config.Data.AutosaveSeconds;task.spawn(save,p,s,false)end
    else s.profile.NextSave=s.profile.LastSave+Config.Data.LeaseSeconds/3 end
   end
  end end
 end
end)
if RunService:IsStudio()then
 local qa=Instance.new("BindableFunction");qa.Name="ThrowTicketsQA";qa.Parent=SS
 qa.OnInvoke=function(command: string,value: any,target: Player?)
  local p=target or Players:GetPlayers()[1];local s=states[p];if not s or not RunService:IsStudio()or not string.match(s.profile.Key,"^QA_")then return nil end
  if command=="Inspect"then return Schema.copy(s.data)
  elseif command=="Reset"and not s.job then
   s.data=Schema.default();s.profile.Data=s.data;ReturnRules.arrive(s.data,ReturnClock.now());teleport(p,s,false);publish(p,s);return save(p,s,false)
  elseif command=="AddCash"and Rules.finiteNumber(value)and value>0 then
   s.data.Cash=math.min(Config.MaxCash,s.data.Cash+math.floor(value));publish(p,s);return true
  elseif command=="AddPower"and Rules.finiteNumber(value)and value>0 then
   s.data.Power=math.min(Config.MaxPower,s.data.Power+value);publish(p,s);return true
  elseif command=="SetCash"and Rules.finiteNumber(value)and value>=0 and value<=Config.MaxCash then s.data.Cash=math.floor(value);publish(p,s);return true
  elseif command=="SetPower"and Rules.finiteNumber(value)and value>=0 and value<=Config.MaxPower then s.data.Power=math.floor(value);s.data.TrainingLevel=Progression.levelFromPower(s.data.Power);s.data.TrainingXP=0;publish(p,s);return true
  elseif command=="GiveCar"then
   local b=if typeof(value)=="number"and Config.Biomes[value]then value elseif typeof(value)=="table"and Config.Biomes[value.Biome]then value.Biome else 1
   local rarity=if typeof(value)=="table"and Config.Rarities[value.Rarity]then value.Rarity else 1
   local ok=GarageRules.add(s.data,Rules.reward(b,rarity,1,nil,if typeof(value)=="table"then value.Variant else nil),Http:GenerateGUID(false),false);if ok then publish(p,s)end;return ok
  elseif command=="TeleportSlot"and Rules.finiteNumber(value)and s.positions[value]then
   local r=rootOf(p);if r then p.Character:PivotTo(CFrame.new(s.positions[value]+Vector3.new(0,3,0)));p:SetAttribute("Location","Plot");return true end
  elseif command=="ForceNext"and typeof(value)=="table"then
   local rarity=value.Rarity;if typeof(rarity)=="string"then for i,r in Config.Rarities do if r.Name:lower()==rarity:lower() then rarity=i;break end end end
   if rarity~=nil and (not Rules.finiteNumber(rarity)or not Config.Rarities[rarity])then return false end
   local function normalize(entries,id)
    if typeof(id)~="string"then return nil end
    for _,e in entries do if e.Id:lower()==id:lower()then return e.Id end end
    return nil
   end
   local variant=normalize(Config.Variants,value.Variant)
   if value.Variant~=nil and not variant then return false end
   s.nextRoll={Rarity=rarity,Variant=variant};return true
  elseif command=="SetXP"and Rules.finiteNumber(value)and value>=0 and value<Config.Progression.XPPerLevel then s.data.TrainingXP=value;publish(p,s);return true
  elseif command=="Save"then return save(p,s,false)
  elseif command=="AdvanceTime"and Rules.finiteNumber(value)and math.abs(value)<=86400*500 then
   SS:SetAttribute("ReturnQAOffset",(SS:GetAttribute("ReturnQAOffset")or 0)+value);returnService.update(p,s);return ReturnClock.now()
  elseif command=="Tutorial"and typeof(value)=="boolean"then s.data.Returns.Tutorial=value;publish(p,s);return true
  elseif command=="PlaySeconds"and Rules.finiteNumber(value)and value>=0 then s.data.Returns.PlaySeconds=math.floor(value);s.data.Returns.LastLike=0;return true
  elseif command=="Claim"then returnService.claim(p,s,value);return Schema.copy(s.data.Returns)
  elseif command=="Boards"then return boards.qa(value)
  elseif command=="Exit"then release(p);return true end
  return nil
 end
end
print("[ThrowTickets] Iteration 11: ten biomes and 74 draft cars ready (NOT FINAL).")

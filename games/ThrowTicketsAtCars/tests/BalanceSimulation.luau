-- Active-play model using the game's actual rolls, XP, prices and six-slot garage.
-- No offline/free cars or optional 2x boost. Auto-sale and purchases assume an attentive player.
return function(Config,Rules,Garage,seed,options)
 options=options or {};local Progression=require(game.ReplicatedStorage.ThrowTickets.Progression)
 local state={Cash=0,Power=Config.StartPower,Exercise=1,Owned={paper=true},Equipped="paper",Cars={},Discovered={},TrainingXP=0,TrainingLevel=1,ParkingCapacity=Config.ParkingSlots}
 local rng=Random.new(seed);local biomes={{Name=Config.Biomes[1].Name,Seconds=0}};local purchases={};local casts=0;local training=0
 local busy=0;local nextCatch=0;local reward=nil;local fast=Config.ParkingSlots;local biome=1
 local function deliver()
  casts+=1;local id="sim"..casts;assert(Garage.add(state,reward,id,false))
  Garage.equipBest(state)
  local sell={};for _,c in state.Cars do if c.Slot==0 then table.insert(sell,c.Id)end end
  for _,carId in sell do assert(Garage.act(state,"Sell",carId,0))end
  reward=nil
 end
 for second=1,Config.Simulation.MaxSeconds do
  if second%2000==0 then task.wait()end
  state.Cash=math.min(Config.MaxCash,state.Cash+Garage.income(state))
  local current=Rules.biome(Rules.distance(state.Power))
  if current>biome then biome=current;fast=Config.ParkingSlots;nextCatch=second;table.insert(biomes,{Name=Config.Biomes[biome].Name,Seconds=second})end
  if biome==#Config.Biomes then return {Seed=seed,Biomes=biomes,Purchases=purchases,Seconds=second,Casts=casts,TrainingSeconds=training,Cash=state.Cash,Power=state.Power,Income=Garage.income(state)}end
  if busy>0 then busy-=1;if busy==0 and reward then deliver()end
  else
   local choices={}
   local x=Config.Exercises[state.Exercise+1]
   if not options.NoExercises and x and biome>=x.UnlockBiome then table.insert(choices,{Action="Exercise",Item=x,Score=(x.Work/Config.Exercises[state.Exercise].Work-1)/x.Price})end
   if not options.NoTickets then for _,t in Config.Tickets do if not state.Owned[t.Id]then
    if biome>=t.UnlockBiome then local old=Rules.ticket(state.Equipped);table.insert(choices,{Action="Buy",Item=t,Score=(t.IncomeMultiplier/old.IncomeMultiplier-1)/t.Price})end;break
   end end end
   table.sort(choices,function(a,b)return a.Score>b.Score end)
   local bought=false
   for _,c in choices do if state.Cash>=c.Item.Price then
    local before=Rules.trainingRate(state.Power,state.Exercise);assert(Rules.shop(state,c.Action,c.Item.Id):sub(1,7)=="Bought ")
    if c.Action=="Buy"then Rules.shop(state,"Equip",c.Item.Id)end
    table.insert(purchases,{Name=c.Item.Name,Kind=c.Action,Seconds=second,Price=c.Item.Price,PriceMinutes=c.Item.Minutes,TrainingRateBefore=before,TrainingRateAfter=Rules.trainingRate(state.Power,state.Exercise)})
    busy=Config.Simulation.PurchaseSeconds;bought=true;break
   end end
   if not bought then
    if second>=nextCatch then
     reward=Rules.rollCar(biome,state.Equipped,rng);busy=options.CatchSeconds or Config.Simulation.CatchLoopSeconds;fast=math.max(0,fast-1)
     nextCatch=second+(if fast>0 then busy+1 else options.RefreshSeconds or Config.Simulation.RefreshSeconds)
    else
     local amount=Rules.trainingRate(state.Power,state.Exercise)*Config.Progression.XPPerLevel
     Progression.addXP(state,amount);training+=1
    end
   end
  end
 end
 return {Seed=seed,Biomes=biomes,Purchases=purchases,Casts=casts,TrainingSeconds=training,Incomplete=true,Power=state.Power}
end

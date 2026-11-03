-- Offline module: identical Config, reward, shop, garage and training rules as the game.
-- Assumptions are explicit Config.Simulation values; no paid boosts, no offline income.
return function(Config,Rules,Garage,seed,options)
 options=options or {}
 local state={Cash=0,Power=Config.StartPower,Exercise=1,Owned={paper=true},Equipped="paper",Cars={}}
 local random=seed;local function roll()random=(random*16807)%2147483647;return random/2147483647 end
 local purchases,biomes,casts={},{{Name=Config.Biomes[1].Name,Seconds=0}},0
 local busy,nextCatch,reward=0,0,nil
 local fast=Config.ParkingSlots
 local currentBiome=1;local trainingSeconds=0
 local function value(ticket)
  local sum,weight=0,0;for i,r in Config.Rarities do local w=Rules.rarityWeights(ticket.Id)[i].Weight;sum+=w*Rules.reward(currentBiome,i,1,ticket.Id).Income;weight+=w end
  return sum/weight
 end
 local function candidates()
  local list={}
  if not options.NoExercises then local x=Config.Exercises[state.Exercise+1];if x and currentBiome>=x.UnlockBiome then
   table.insert(list,{Kind="Exercise",Item=x,Score=(x.Work/Config.Exercises[state.Exercise].Work-1)/x.Price})
  end end
  if not options.NoTickets then for _,x in Config.Tickets do if not state.Owned[x.Id]then if currentBiome>=x.UnlockBiome then
   local old=Rules.ticket(state.Equipped);local ratio=value(x)/value(old)
   local payback=x.Price/(Config.Biomes[currentBiome].ReferenceIncomePerMinute*(ratio-1))
   if payback<=Config.Economy.TicketPaybackHorizonMinutes then table.insert(list,{Kind="Buy",Item=x,Score=(ratio-1)/x.Price,PaybackMinutes=payback})end
  end;break end end end
  table.sort(list,function(a,b)return a.Score>b.Score end)
  return list
 end
 local function deliver()
  casts+=1;local id="sim"..casts
  local ok=Garage.add(state,reward,id,false);assert(ok)
  local free,worst=nil,nil
  for slot=1,Config.ParkingSlots do local used=false;for _,c in state.Cars do if c.Slot==slot then used=true;if not worst or Rules.savedReward(c).Income<Rules.savedReward(worst).Income then worst=c end end end;if not used then free=slot;break end end
  if free then assert(Garage.act(state,"Place",id,free))
  elseif reward.Income>Rules.savedReward(worst).Income then
   local slot=worst.Slot;assert(Garage.act(state,"Remove",worst.Id,slot));assert(Garage.act(state,"Sell",worst.Id,0));assert(Garage.act(state,"Place",id,slot))
  else assert(Garage.act(state,"Sell",id,0))end
  reward=nil
 end
 for second=1,Config.Simulation.MaxSeconds do
  if second%600==0 then task.wait()end
  state.Cash+=Garage.income(state)
  local biome=Rules.biome(Rules.distance(state.Power))
  if biome>currentBiome then currentBiome=biome;fast=Config.ParkingSlots;nextCatch=second;table.insert(biomes,{Name=Config.Biomes[biome].Name,Seconds=second})end
  if busy>0 then busy-=1;if busy==0 and reward then deliver()end
  else
   local bought=false
   for _,c in candidates()do if state.Cash>=c.Item.Price then
    local before=Rules.trainingRate(state.Power,state.Exercise);local message=Rules.shop(state,c.Kind,c.Item.Id);assert(message:sub(1,7)=="Bought ",message)
    if c.Kind=="Buy"then assert(Rules.shop(state,"Equip",c.Item.Id):sub(1,9)=="Equipped ")end
    table.insert(purchases,{Name=c.Item.Name,Kind=c.Kind,Seconds=second,Price=c.Item.Price,PriceMinutes=c.Item.Minutes,Biome=Config.Biomes[currentBiome].Name,PaybackMinutes=c.PaybackMinutes,TrainingRateBefore=before,TrainingRateAfter=Rules.trainingRate(state.Power,state.Exercise)})
    busy=Config.Simulation.PurchaseSeconds;bought=true;break
   end end
   if not bought then
    if second>=nextCatch then
     reward=Rules.reward(currentBiome,Rules.weighted(Rules.rarityWeights(state.Equipped),roll()),Rules.weighted(Config.Biomes[currentBiome].Cars,roll()),state.Equipped)
     busy=Config.Simulation.CatchLoopSeconds;fast=math.max(0,fast-1)
     nextCatch=second+(if fast>0 then Config.Simulation.CatchLoopSeconds+1 else Config.Simulation.RefreshSeconds)
    else
     state.Power=math.min(Config.MaxPower,state.Power+Rules.trainingRate(state.Power,state.Exercise));trainingSeconds+=1
    end
   end
  end
  if #biomes==#Config.Biomes and (#purchases==#Config.Exercises+#Config.Tickets-2 or options.NoTickets or options.NoExercises)then
   return {Seed=seed,Biomes=biomes,Purchases=purchases,Seconds=second,Casts=casts,TrainingSeconds=trainingSeconds,Cash=state.Cash,Power=state.Power,Income=Garage.income(state)}
  end
 end
 return {Seed=seed,Biomes=biomes,Purchases=purchases,Casts=casts,TrainingSeconds=trainingSeconds,Incomplete=true,Power=state.Power}
end

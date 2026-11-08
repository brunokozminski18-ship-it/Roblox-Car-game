-- 18-biome progression, release gating, map, pity and Index rewards (research/Progression18.md, 08.11.2026).
return function(Config,Rules,Schema,Garage)
 local Index=require(game.ReplicatedStorage.ThrowTickets.IndexRewards)
 local J=require(game.ReplicatedStorage.ThrowTickets.JuiceRules)
 local n=0;local function check(ok,msg)assert(ok,msg);n+=1 end
 check(#Config.AllBiomes==18 and #Config.Biomes==Config.Release.ReleasedBiomes,"Authored 18, released subset playable")
 check(#Config.ComingSoon==math.min(Config.Release.PreviewBiomes,18-#Config.Biomes),"Next biomes previewed as COMING SOON")
 local ids={}
 for i,b in Config.AllBiomes do
  local t={0,0,0,0};for _,c in b.Cars do t[c.Rarity]+=1;check(not ids[c.Id],"Unique catalog id");ids[c.Id]=true end
  check(#b.Cars==8 and t[1]==3 and t[2]==2 and t[3]==2 and t[4]==1,"Every biome has 3/2/2/1 cars")
  if i>1 then local p=Config.AllBiomes[i-1];check(b.MinPower>p.MinPower and b.BaseIncome>p.BaseIncome and b.Start>p.Start,"Monotonic power, income and road")end
  if i<=10 then check(b.Start==b.MinPower,"Launch biomes keep their measured geometry")end
 end
 for _,x in Config.AllTickets do check(x.Price<=Config.MaxCash and x.Price<2^53 and Rules.luck(x.Id)<=Config.Luck.Cap,"Ticket price and luck capped")end
 for _,x in Config.AllExercises do check(x.Price<=Config.MaxCash,"Exercise price capped")end
 check(Rules.distance(1e12)==Config.MapEnd,"Throws stop at the released map end")
 for i,b in Config.Biomes do check(Rules.biome(Rules.distance(b.MinPower))==i,"Biome boundary");if i>1 then check(Rules.biome(Rules.distance(b.MinPower-1))==i-1,"Before boundary")end end
 local last=-1;for p=0,Config.Release.PowerEnd,37 do local d=Rules.distance(p);check(d>=last,"Power to road is monotonic");last=d end
 check(J.distance(3000,3000,0)==Rules.distance(3000),"Throw distance uses the same mapping")
 local rng=Random.new(11);local pity={Catches=0,SinceLegendary=0};local gap,maxgap=0,0
 for k=1,50000 do
  local car=Rules.rollCar(1,"paper",rng,nil,pity);Rules.notePity(pity,car.Rarity)
  if k==3 then check(car.Rarity>=2,"Third catch is at least Rare")end
  if k==10 then check(car.Rarity>=3,"Tenth catch is at least Epic")end
  if car.Rarity==4 then maxgap=math.max(maxgap,gap);gap=0 else gap+=1 end
 end
 check(maxgap<Config.Luck.LegendaryPity,"Legendary pity bound")
 local data=Schema.default()
 for k=1,Config.Index.FreeCarAt do data.Discovered[Config.Biomes[1].Cars[k].Id]=true end
 local due=Index.due(data);check(#due==1 and due[1]==1,"Half collection earns one free car");Index.markClaimed(data,1);check(#Index.due(data)==0,"Claimed once")
 for _,c in Config.Biomes[1].Cars do data.Discovered[c.Id]=true end
 check(math.abs(Index.incomeMultiplier(data)-(1+Config.Index.CompleteBonus))<1e-9,"Complete biome bonus")
 local saved={Schema=Config.Data.Schema,Data=Schema.copy(data)};check(Schema.prepare(saved)~=nil,"Schema round trip")
 local bad=Schema.copy(saved);bad.Data.Pity.SinceLegendary=Config.Luck.LegendaryPity;check(Schema.prepare(bad)==nil,"Reject invalid pity")
 local old=Schema.copy(saved);old.Schema=7;old.Data.Pity=nil;old.Data.IndexClaims=nil
 local mig=Schema.prepare(old);check(mig~=nil and mig.IndexClaims["1"]==true,"Migration 7 -> 8 marks earned half collections")
 return n.." progression18 assertions passed"
end

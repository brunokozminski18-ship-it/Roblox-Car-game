-- Pure progression/save tests; dependencies are injected by the Studio edit runner.
return function(Progression,Schema,Config)
 local count=0;local function check(ok,message)assert(ok,message);count+=1 end
 local function equal(a,b)
  if typeof(a)~=typeof(b)then return false end
  if typeof(a)~="table"then return a==b end
  for k,v in a do if not equal(v,b[k])then return false end end
  for k in b do if a[k]==nil then return false end end
  return true
 end
 check(type(Progression)=="table"and type(Progression.addXP)=="function","Training needs shared pure XP progression")
 local fresh=Schema.default()
 check(fresh.TrainingLevel==1 and fresh.TrainingXP==0 and fresh.Power==Config.StartPower,"Fresh progression starts at level 1 and preserves starting Power")
 local levels,gain=Progression.addXP(fresh,25.5)
 check(levels==0 and gain==0 and fresh.TrainingXP==25.5 and fresh.Power==Config.StartPower,"Fractional internal XP accumulates without early Power")
 levels,gain=Progression.addXP(fresh,274.5)
 check(levels==3 and gain==3 and fresh.TrainingLevel==4 and fresh.TrainingXP==0 and fresh.Power==Config.StartPower+3,"One award can cross multiple levels exactly")
 fresh.TrainingXP=99.75
 levels,gain=Progression.addXP(fresh,.5)
 check(levels==1 and gain==1 and fresh.TrainingXP==.25 and fresh.TrainingLevel==5,"Fractional XP remainder survives a level boundary")
 fresh.Power=Config.MaxPower-.25
 levels,gain=Progression.addXP(fresh,200)
 check(levels==2 and gain==.25 and fresh.Power==Config.MaxPower,"Power cap grants only the actual remaining Power")
 levels,gain=Progression.addXP(fresh,100)
 check(levels==1 and gain==0 and fresh.Power==Config.MaxPower,"XP and level remain valid at the Power cap")
 for _,amount in {0,-1,0/0,math.huge,-math.huge,1e6+1,"100",false,{}}do
  local before=Schema.copy(fresh)
  levels,gain=Progression.addXP(fresh,amount)
  check(levels==0 and gain==0 and equal(fresh,before),"Invalid or absurd XP award must leave all progression unchanged")
 end
 local before=Schema.copy(fresh);levels,gain=Progression.addXP(fresh,nil)
 check(levels==0 and gain==0 and equal(fresh,before),"Missing XP award is rejected")
 local atLimit=Schema.default();levels,gain=Progression.addXP(atLimit,1e6)
 check(levels==10000 and gain==10000 and atLimit.TrainingXP==0,"Documented maximum internal award is accepted")
 check(Progression.levelFromPower(Config.StartPower)==1 and Progression.levelFromPower(0)==1,"Migration never creates a level below 1")
 check(Progression.levelFromPower(78.5)==55 and Progression.levelFromPower(Config.MaxPower)<=1e9,"Migration floors old fractional Power into bounded integer level")
 local old={Cash=123456,Power=78.55555,Owned={paper=true,pink=true},Equipped="pink",Exercise=2,Cars={
  {Id="parked_car",Biome=2,Rarity=3,Name=Config.Biomes[2].LegacyCars[1].Name,Ticket="pink",Slot=2},
  {Id="stored_car",Biome=1,Rarity=1,Name=Config.Biomes[1].LegacyCars[2].Name,Ticket="paper",Slot=0},
 }}
 local untouched=Schema.copy(old);local migrated,reason=Schema.prepare({Schema=3,Data=old})
 check(migrated~=nil,reason or "Schema 3 migration must load")
 check(migrated.TrainingLevel==55 and migrated.TrainingXP==0,"Schema 3 receives derived level and empty XP")
 for k,v in old do
  if k=="Cars"then
   check(#v==#migrated.Cars and migrated.Cars[1].Id==v[1].Id and migrated.Cars[2].Id==v[2].Id,"Migration preserves owned instances")
  else check(equal(v,migrated[k]),"Migration preserves old field "..k)end
 end
 check(equal(old,untouched),"Migration never mutates the loaded old profile")
 for _,power in {0,Config.StartPower,Config.StartPower+.125,Config.MaxPower}do
  local legacy=Schema.copy(old);legacy.Power=power
  local result=Schema.prepare({Schema=3,Data=legacy})
  check(result and result.Power==power and result.TrainingXP==0 and result.TrainingLevel==Progression.levelFromPower(power),"Migration preserves exact boundary Power")
 end
 for _,field in {"TrainingXP","TrainingLevel"}do
  local invalid=if field=="TrainingXP"then {-1,100,math.huge,-math.huge,0/0,"0",false} else {0,-1,1.5,1e9+1,math.huge,-math.huge,0/0,"1",false}
  for _,value in invalid do
   local bad=Schema.copy(migrated);bad[field]=value
   check(Schema.prepare({Schema=5,Data=bad})==nil,"Schema 5 rejects invalid "..field)
  end
  local bad=Schema.copy(migrated);bad[field]=nil
  check(Schema.prepare({Schema=5,Data=bad})==nil,"Schema 5 rejects missing "..field)
 end
 migrated.TrainingXP=99.75;migrated.BoostUntil=123;migrated.TrainingOffer={Expires=456}
 local restored=Schema.prepare({Schema=5,Data=migrated})
 check(restored and restored.TrainingLevel==55 and restored.TrainingXP==99.75,"New progression survives schema 5 save/load")
 check(restored.BoostUntil==nil and restored.TrainingOffer==nil,"Transient training boost/offer is never persisted")
 local again=Schema.prepare({Schema=5,Data=restored})
 check(equal(restored,again),"Schema 5 prepare is idempotent and preserves every saved field")
 return count.." progression10a assertions passed"
end

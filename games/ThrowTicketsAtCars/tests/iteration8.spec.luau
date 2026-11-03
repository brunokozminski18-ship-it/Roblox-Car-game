return function(Rules,Config,Schema,Garage,Meter)
 local n=0;local function check(ok,msg)assert(ok,msg);n+=1 end
 check(type(Garage.sorted)=="function","Income sorting must exist")
 local d=Schema.default()
 for i=1,Config.InventoryLimit do Garage.add(d,Rules.reward(1,1,1),string.format("car%02d",i),false)end
 d.Cars[1].Slot=1
 Garage.add(d,Rules.reward(6,4,1),"best",false)
 local before=#d.Cars
 check(Garage.equipBest(d),"Equip best works with full backpack")
 check(#d.Cars==before and Garage.find(d,"best").Slot>0,"No loss and strongest is parked")
 check(Garage.inventoryCount(d)<=Config.InventoryLimit,"Capacity after bulk swap")
 local seen={};for _,c in d.Cars do if c.Slot>0 then check(not seen[c.Slot],"Unique parking slot");seen[c.Slot]=true end end
 local ordered=Garage.sorted(d,false)
 for i=2,#ordered do local a,b=ordered[i-1],ordered[i];local ai,bi=Rules.savedReward(a).Income,Rules.savedReward(b).Income;check(ai>bi or(ai==bi and a.Id<b.Id),"Stable descending income")end
 local cash=d.Cash;local best=Garage.find(d,"best")
 check(Garage.act(d,"Sell","best",0),"Can sell a parked car atomically")
 check(#d.Cars==before-1 and d.Cash>cash and not Garage.find(d,"best"),"Sale removes ownership once")
 check(not Garage.act(d,"Sell","best",0),"Repeated sale rejected")
 check(math.abs(Meter.bonus(0)-Config.ThrowMeter.MaxBonus)<1e-6,"Top green maximum")
 check(math.abs(Meter.bonus(1)-Config.ThrowMeter.MinBonus)<1e-6,"Bottom red minimum")
 check(Meter.position(0)==1 and Meter.position(Config.ThrowMeter.Period/2)==0,"Oscillating clock")
 check(Meter.tap(10,9,10,0)==nil,"Reject pre-start tap")
 check(Meter.tap(10,10.5,10.1,0)==nil,"Reject future tap")
 check(Meter.tap(10,10.1,11,0)==nil,"Reject replayed old timestamp")
 local b=Meter.tap(10,10.1,10.15,.1);check(b~=nil and b>=-.05 and b<=.10,"Ping-bounded tap bonus")
 return n.." iteration-8 assertions passed"
end

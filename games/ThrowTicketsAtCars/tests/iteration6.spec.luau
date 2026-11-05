return function(Rules,Config,Schema,Garage)
 local n=0;local function check(ok,msg)assert(ok,msg);n+=1 end
 for _,t in Config.Tickets do check(t.Multiplier==nil and Rules.distance(24,t.Id)==24,"Ticket never multiplies distance")end
 check(Rules.distance(99999)==Config.MapEnd,"Map limit")
 check(Rules.nextBiome(49)==2,"Power-only threshold")
 for i,b in Config.Biomes do check(Rules.biome(b.MinPower)==i,"Biome boundary");if i>1 then check(Rules.biome(b.MinPower-1)==i-1,"Before biome boundary")end end
 check(Rules.trafficPosition(1,1,1)~=Rules.trafficPosition(1,1,1.25),"Traffic moves on fixed path")
 check(Config.ThrowWindupSeconds+Config.TicketFlightSeconds>=2 and Config.ThrowWindupSeconds+Config.TicketFlightSeconds<=3,"Cast duration")
 local old={Schema=1,Data={Cash=777,Power=84,Owned={paper=true,pink=true,parking=true,court=true},Equipped="court",Parking={{Slot=2,Biome=1,Rarity=3,Name="Rusty Sedan"}}}}
 local migrated=Schema.prepare(old)
 check(migrated and migrated.Cash==777 and migrated.Power==84 and migrated.Equipped=="court","Migration keeps progression")
 check(#migrated.Cars==1 and migrated.Cars[1].Slot==2 and migrated.Cars[1].Id=="legacy_2","Migration preserves car and slot")
 check(Garage.income(migrated)==Rules.reward(1,3,1,"paper").Income,"Migration preserves derived income")
 local d=Schema.default();local reward=Rules.reward(1,1,1)
 local ok=Garage.add(d,reward,"a",false);check(ok and Garage.inventoryCount(d)==1,"Capture inventory")
 ok=Garage.act(d,"Place","a",1);check(ok and d.Cars[1].Slot==1 and Garage.income(d)==1,"Place earns")
 Garage.add(d,reward,"b",false)
 check(not Garage.act(d,"Place","b",1),"Occupied slot refused")
 check(not Garage.act(d,"Sell","a",1),"Invalid sale payload refused")
 check(not Garage.act(d,"Place","foreign",2),"Foreign id refused")
 check(not Garage.act(d,"Place","b",0/0),"NaN slot refused")
 check(Garage.act(d,"Remove","a",1) and Garage.income(d)==0,"Remove stops income")
 local cash=d.Cash;check(Garage.act(d,"Sell","a",0) and d.Cash==cash+Rules.salePrice(1),"Sell once")
 cash=d.Cash;check(not Garage.act(d,"Sell","a",0) and d.Cash==cash,"No duplicate sale")
 d=Schema.default();for i=1,Config.InventoryLimit do check(Garage.add(d,reward,"full"..i,false),"Fill inventory")end
 check(not Garage.add(d,reward,"overflow",false),"Inventory full refuses capture")
 check(Garage.act(d,"Place","full1",1) and Garage.add(d,reward,"new",false),"Placed car frees capacity")
 check(not Garage.act(d,"Remove","full1",1),"Full inventory refuses remove")
 d=Schema.default();Garage.add(d,reward,"pending",true)
 check(not Garage.act(d,"Sell","pending",0),"Pending loot inaccessible")
 local saved=Schema.prepare({Schema=Config.Data.Schema,Data=d})
 check(saved and #saved.Cars==1 and not saved.Cars[1].Pending,"Interrupted catch restored once in inventory")
 saved.Cars[2]=Schema.copy(saved.Cars[1]);check(Schema.prepare({Schema=Config.Data.Schema,Data=saved})==nil,"Duplicate ids refused")
 check(Schema.prepare({Schema=99,Data=d})==nil,"Future schema refused")
 return n.." iteration-6 assertions passed"
end

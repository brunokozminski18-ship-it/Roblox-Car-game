return function(Rules,Config,Schema,Garage)
 local n=0;local function check(ok,msg)assert(ok,msg);n+=1 end
 check(Config.Exercises and #Config.Exercises==11,"Eleven configured training tiers are required")
 local d=Schema.default();check(d.Exercise==1,"Starter training is saved")
 for _,items in {Config.Exercises,Config.Tickets}do for _,x in items do check(x.Price==math.floor(x.Minutes*Config.Biomes[x.UnlockBiome].ReferenceIncomePerMinute+.5),"Prices derived from minutes")end end
 local before=d.Cash;check(Rules.shop(d,"Exercise","focused")=="Not enough Cash!"and d.Cash==before,"Training affordability")
 d.Cash=1e12;check(Rules.shop(d,"Exercise","master")=="Buy the previous exercise first!","Training sequence")
 local oldRate=Rules.trainingRate(d.Power,d.Exercise);check(Rules.shop(d,"Exercise","focused"):sub(1,7)=="Bought ","Training purchase")
 check(d.Exercise==2 and Rules.trainingRate(d.Power,d.Exercise)>oldRate,"Training benefit")
 before=d.Cash;check(Rules.shop(d,"Exercise","focused")=="Already owned!"and d.Cash==before,"No duplicate training purchase")
 check(Rules.shop(d,"Exercise","weighted")=="Reach Suburbs first!","Biome unlock")
 local paper=Rules.reward(1,2,1,"paper");local pink=Rules.reward(1,2,1,"pink")
 check(pink.Income>paper.Income,"Capture ticket improves income")
 Garage.add(d,pink,"capture",false);check(d.Cars[1].Ticket=="pink","Capture ticket stored")
 d.Equipped="paper";check(Rules.savedReward(d.Cars[1]).Income==pink.Income,"Switching ticket does not reprice old car")
 check(Rules.salePrice(pink.Income)==pink.Income*Config.SaleIncomeSeconds and Config.SaleIncomeSeconds>=120,"Sale pays minutes")
 local old={Schema=2,Data={Cash=123,Power=24,Owned={paper=true},Equipped="paper",Cars={{Id="legacy",Biome=1,Rarity=1,Name="Rusty Sedan",Slot=1}}}}
 local migrated=Schema.prepare(old);check(migrated and migrated.Exercise==1 and migrated.Cars[1].Ticket=="paper"and migrated.Cash==123,"Schema 2 migration preserves progression")
 migrated.Power=24.25;check(Schema.prepare({Schema=Config.Data.Schema,Data=migrated})~=nil,"Fractional training progress saves")
 migrated.Exercise=99;check(Schema.prepare({Schema=Config.Data.Schema,Data=migrated})==nil,"Corrupt exercise rejected")
 local unknown=Schema.copy(d);unknown.Cars[1].Ticket="forged";check(Schema.prepare({Schema=Config.Data.Schema,Data=unknown})==nil,"Forged ticket rejected")
 for _,t in Config.Tickets do check(t.Multiplier==nil and Rules.distance(24,t.Id)==24,"Tickets never change distance")end
 return n.." iteration-7 assertions passed"
end

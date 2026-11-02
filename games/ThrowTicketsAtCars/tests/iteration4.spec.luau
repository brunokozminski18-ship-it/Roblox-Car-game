return function(Rules,Config,Schema)
	local count=0
	local function check(ok,message)assert(ok,message);count+=1 end
	check(Rules.distance(24,"pink")==60,"Pink Slip must multiply range")
	check(Rules.distance(99999,"diamond")==Config.MapEnd,"Ticket respects map limit")
	check(Rules.distance(24,"fake")==24,"Unknown ticket has no bonus")
	for i,t in Config.Tickets do
		check(Rules.biome(Rules.distance(24,t.Id))==i,"Each ticket makes a visible biome jump")
	end
	local d=Schema.default()
	check(Rules.shop(d,"Buy","diamond")=="Buy the previous ticket first!","Cannot skip unlocks")
	check(Rules.shop(d,"Equip","pink")=="Ticket not owned!","Cannot equip unowned")
	check(Rules.shop(d,"Buy","pink")=="Not enough Cash!" and d.Cash==0,"No cash, no mutation")
	d.Cash=1000
	check(Rules.shop(d,"Buy","pink")=="Bought Pink Slip!" and d.Cash==900 and d.Owned.pink,"Atomic price and ownership")
	check(d.Equipped=="paper","Purchase does not silently equip")
	check(Rules.shop(d,"Buy","pink")=="Already owned!" and d.Cash==900,"No duplicate charge")
	check(Rules.shop(d,"Equip","pink")=="Equipped Pink Slip!" and d.Equipped=="pink","Equip owned")
	check(Rules.shop(d,"Buy",0/0)=="Invalid ticket!","Reject NaN id")
	check(Rules.shop(d,"Wrong","pink")=="Invalid action!","Reject invalid action")
	local w=Rules.rarityWeights("diamond")
	local total=0;for _,v in w do total+=v.Weight end
	check(w[1].Weight==Config.Rarities[1].Weight and w[4].Weight>Config.Rarities[4].Weight,"Luck changes only Rare+ weights")
	check(w[1].Weight/total<0.7,"Luck increases normalized rare chance")
	local copy=Schema.prepare({Schema=1,Data=d})
	check(copy and copy.Equipped=="pink" and copy.Owned.pink,"Snapshot round trip")
	copy.Owned.pink=false;check(d.Owned.pink,"Independent profile tables")
	check(Schema.prepare({Schema=99,Data=d})==nil,"Future schema refused")
	check(Schema.prepare({Schema=1,Data={Cash=0/0}})==nil,"Corrupt profile refused")
	local legacy=Schema.prepare({Schema=0,Data={Cash=50,Power=40,Parking={}}})
	check(legacy and legacy.Owned.paper and legacy.Equipped=="paper","Version zero additive migration")
	d.Parking={{Slot=2,Biome=1,Rarity=3,Name="Rusty Sedan"}}
	local restored=Schema.prepare({Schema=1,Data=d})
	check(restored and #restored.Parking==1 and Rules.savedReward(restored.Parking[1]).Income==8,"Car income rebuilt from catalog")
	d.Parking[2]={Slot=2,Biome=1,Rarity=1,Name="Old Van"}
	check(Schema.prepare({Schema=1,Data=d})==nil,"Duplicate slots rejected")
	return count.." iteration-4 assertions passed"
end

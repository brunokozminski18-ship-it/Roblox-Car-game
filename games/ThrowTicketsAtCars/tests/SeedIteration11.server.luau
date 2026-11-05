-- Run only in a Studio QA server after 11-20261105 is selected in Edit.
assert(game:GetService("RunService"):IsStudio())
assert(game.ServerStorage:GetAttribute("TestProfileKey")=="11-20261105")
local p=game.Players:GetPlayers()[1];assert(p)
assert(game.ServerStorage.ThrowTicketsQA:Invoke("Exit",nil,p)) -- release QA lease before fixture write
local d={Cash=12345,Power=2500,TrainingXP=25,TrainingLevel=2477,Owned={paper=true,pink=true,parking=true,court=true,gold=true,diamond=true},Equipped="diamond",Exercise=6,ParkingCapacity=6,Discovered={b4_car6=true,b5_car4=true,b6_car8=true},Cars={
 {Id="qa-sports",Biome=4,Rarity=3,Name="Paddock Phantom",CatalogId="b4_car6",Variant="Gold",Ticket="paper",Slot=1},
 {Id="qa-luxury",Biome=5,Rarity=2,Name="Pearl Phaeton",CatalogId="b5_car4",Variant="Diamond",Ticket="pink",Slot=2},
 {Id="qa-hyper",Biome=6,Rarity=4,Name="Island Emperor",CatalogId="b6_car8",Variant="Neon",Ticket="diamond",Slot=0}},Returns={Tutorial=true,LastSeen=0,OfflineRate=0,PendingCash=0,PendingSeconds=0,AwaySeconds=0,FreeAt=0,PlaySeconds=40,LastLike=0,BestOdds=40000}}
game:GetService("DataStoreService"):GetDataStore("ThrowTicketsAtCars_v1_STUDIO"):UpdateAsync("QA_11-20261105_"..p.UserId,function()return {Schema=6,Data=d}end)
return "Isolated schema6 fixture saved; stop and rejoin to verify migration."

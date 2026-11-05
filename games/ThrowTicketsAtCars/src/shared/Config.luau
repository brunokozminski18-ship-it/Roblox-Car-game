--!strict
-- Prototype tuning: NOT FINAL. All progression, rewards and world dimensions live here.
local Catalog=require(script.Parent.CarCatalog)
local Config={
	Returns={OfflineFraction=.4,OfflineCapSeconds=8*3600,OfflineMinSeconds=60,FreeCarSeconds=15*60,LikeSeconds=10*60},
	Boards={RefreshSeconds=60,WriteSeconds=120,Count=10,StorePrefix="TTAC_Boards_v2",BudgetReserve=1},
	StartPower=24, TickSeconds=1,
 Progression={XPPerLevel=100,PowerPerLevel=1,OfferEvery=12,OfferLifetime=4,BoostSeconds=2},
 Juice={LetterSeconds=.18,CommonRevealMin=2.4,RareRevealMin=5,RareLetterMultiplier=1.8,RevealTimeout=16,PerfectPosition=.06,ToastSeconds=7,ShineEvery=5,BrakeSeconds=.3},
 Economy={StarterIncomeCars=3,TicketPaybackHorizonMinutes=120,ReferenceParkedRarity=3,ReferenceCatchSeconds=45,ReferenceTicket={"paper","pink","parking","court","gold","diamond","solar","neon","cosmic","quantum"},TrainingWorkPerPower={4,8,16,35,90,150,400,800,1800,2500}},
 Simulation={CatchLoopSeconds=14,RefreshSeconds=45,PurchaseSeconds=2,MaxSeconds=86400},
 Exercises={
 {Id="basic",Name="Basic Training",Work=1,Minutes=0,UnlockBiome=1},
 {Id="focused",Name="Focused Training",Work=2,Minutes=1,UnlockBiome=1},
 {Id="weighted",Name="Weighted Training",Work=4,Minutes=2,UnlockBiome=2},
 {Id="intense",Name="Intense Training",Work=8,Minutes=3,UnlockBiome=3},
 {Id="elite",Name="Elite Training",Work=16,Minutes=4,UnlockBiome=4},
 {Id="master",Name="Master Training",Work=32,Minutes=5,UnlockBiome=5},
 {Id="arctic",Name="Arctic Training",Work=64,Minutes=6,UnlockBiome=6},
 {Id="racing",Name="Racing Training",Work=128,Minutes=7,UnlockBiome=7},
 {Id="champion",Name="Champion Training",Work=256,Minutes=8,UnlockBiome=8},
 {Id="hyper",Name="Hyper Training",Work=512,Minutes=10,UnlockBiome=9},
 {Id="future",Name="Future Training",Work=1024,Minutes=12,UnlockBiome=10},
 },
 InventoryLimit=20, HotbarSlots=5, GarageRequestInterval=.15, PlacementDistance=9, PlotInteractRadius=36,
 ThrowMeter={Period=1.4,Timeout=3,MinBonus=-.05,MaxBonus=.10,MaxPingTolerance=.25,PollSeconds=.08},
 PromptHoldSeconds=.5,
 ThrowWindupSeconds=.45, CameraReturnHold=.3, CaptureApproachDistance=32, CaptureLaneX=7,
 TrafficHz=30, TrafficSpeed=22, TrafficLaneX=7, TrafficRenderDistance=450,
	ShopRequestInterval=0.3, MaxCash=1e15, MaxPower=1e9,
	Data={StoreName="ThrowTicketsAtCars_v1",Schema=7,LeaseSeconds=90,AutosaveSeconds=25,Attempts=4,SaveSoonSeconds=2,MinSaveGap=8,ShutdownSeconds=25},
	Tickets={
		{Id="paper",Name="Paper Ticket",Minutes=0,UnlockBiome=1,IncomeMultiplier=1,Luck=0,Color=Color3.fromRGB(255,244,180)},
		{Id="pink",Name="Pink Slip",Minutes=1.5,UnlockBiome=1,IncomeMultiplier=1.5,Luck=0.05,Color=Color3.fromRGB(255,133,199)},
		{Id="parking",Name="Parking Fine",Minutes=3,UnlockBiome=2,IncomeMultiplier=2.2,Luck=0.10,Color=Color3.fromRGB(124,230,255)},
		{Id="court",Name="Court Summons",Minutes=4,UnlockBiome=3,IncomeMultiplier=3.2,Luck=0.15,Color=Color3.fromRGB(194,139,255)},
		{Id="gold",Name="Golden Ticket",Minutes=5,UnlockBiome=4,IncomeMultiplier=4.6,Luck=0.20,Color=Color3.fromRGB(255,208,66)},
		{Id="diamond",Name="Diamond Ticket",Minutes=6,UnlockBiome=5,IncomeMultiplier=12,Luck=0.25,Color=Color3.fromRGB(165,255,243)},
  {Id="solar",Name="Solar Ticket",Minutes=8,UnlockBiome=6,IncomeMultiplier=18,Luck=0.3,Color=Color3.fromHex("FFB35C")},
  {Id="neon",Name="Neon Ticket",Minutes=10,UnlockBiome=7,IncomeMultiplier=27,Luck=0.35,Color=Color3.fromHex("81FFB8")},
  {Id="cosmic",Name="Cosmic Ticket",Minutes=12,UnlockBiome=8,IncomeMultiplier=40,Luck=0.4,Color=Color3.fromHex("CBA0FF")},
  {Id="quantum",Name="Quantum Ticket",Minutes=15,UnlockBiome=9,IncomeMultiplier=60,Luck=0.45,Color=Color3.fromHex("8CDDFF")},
  {Id="temporal",Name="Temporal Ticket",Minutes=20,UnlockBiome=10,IncomeMultiplier=90,Luck=0.5,Color=Color3.fromHex("F3A4F4")},
	},
	ThrowCooldown=0.2, RequestInterval=0.12, TrainRequestInterval=0.3,
	MapEnd=6000, RoadWidth=24, GroundWidth=88, MapPadding=18,
	ThrowOrigin=Vector3.new(0,3.25,0), LandingHeight=3.25,
	TicketFlightSeconds=2, TicketArcHeight=8, TicketArcFactor=0.16, TicketArcMax=200,
	TicketSize=Vector3.new(0.8,0.08,1.2), MessageSeconds=3,
	TowApproachSeconds=0.5, TowLoadSeconds=0.2, TowReturnSeconds=1.3,
	RespawnSeconds=3, SaleIncomeSeconds=180,
	ParkingSlots=6, ParkingMax=16, ParkingColumns=4, ParkingUpgradeMinutes={3,7,15,30,60},
	Variants={{Id="Normal",Weight=.9375,Multiplier=1},{Id="Gold",Weight=.05,Multiplier=2},{Id="Diamond",Weight=.01,Multiplier=4},{Id="Neon",Weight=.0025,Multiplier=8}},
	ParkingSpacing=Vector3.new(11,0,12), ParkingOrigin=Vector3.new(-54,0,-6), PlayerPlotSpacing=54,
	CarSize=Vector3.new(7,2.5,9), RoofSize=Vector3.new(5.5,1.4,4.5), CarHeight=1.4, RoofOffset=1.85,
	WindshieldSize=Vector3.new(5.3,1.15,0.12), WindshieldFront=2.32,
	LaunchCenter=Vector3.new(0,0.12,0), LaunchSize=Vector3.new(21,0.24,8),
	LaunchHalfX=10.5, LaunchHalfZ=4, LaunchHeightTolerance=7,
	TrainingPosition=Vector3.new(-17,0.2,7), TrainingSize=Vector3.new(8,0.4,8), TrainingRadius=4, TrainingHeightTolerance=7,
	SpawnPosition=Vector3.new(0,0.15,10), SpawnSize=Vector3.new(5,0.3,5), SpawnLift=4,
	TowSize=Vector3.new(8,1,14), TowStartOffset=Vector3.new(0,0,-18), TowApproachOffset=Vector3.new(0,0,-1), TowLoadHeight=1,
	SoldTowExit=Vector3.new(26,0,-28),
	LabelDistance=100, GateLabelDistance=130, GateHeight=4.5, GateSignX=23, GatePostSpacing=7, GateBeamSize=Vector3.new(18,3,0.6),
	ViewCarsPerBiome=4, DecorationCount=6, ViewCarX=9, DecorX=29,
	CameraMinZoom=0.5, CameraMaxZoom=64, CameraStartOffset=Vector3.new(0,7,14), CameraFocusOffset=Vector3.new(2.25,1.25,0),
	HitBounceHeight=0.8, HitBounceSeconds=0.26,
	PopupSeconds=1.2, PopupRisePixels=40, ParkingPopSeconds=0.3, ParkingPopStartScale=0.01,
	ImpactSound="rbxasset://sounds/volume_slider.ogg", ImpactVolume=0.45, ImpactPitch=1.5,
	StickerSeconds=3, HookWidth=0.18,
	Rarities={
		{Name="Common",Weight=70,Multiplier=1,Color=Color3.fromRGB(205,210,215)},
		{Name="Rare",Weight=22,Multiplier=2,Color=Color3.fromRGB(70,160,255)},
		{Name="Epic",Weight=7,Multiplier=3,Color=Color3.fromRGB(185,95,250)},
		{Name="Legendary",Weight=1,Multiplier=5,Color=Color3.fromRGB(255,205,65)},
	},
	Biomes=Catalog.Biomes, ComingSoon=Catalog.ComingSoon,
}
-- Prices are authored in minutes. Reference includes a six-car park and active sales.
-- Starter benchmark is the measured ramp-up rather than an already full rare park.
local rarityTotal,rarityWeight=0,0
for _,r in Config.Rarities do rarityTotal+=r.Weight*r.Multiplier;rarityWeight+=r.Weight end
for i,b in Config.Biomes do
 b.EndPower=if Config.Biomes[i+1]then Config.Biomes[i+1].MinPower else Config.MapEnd
 local ticket=Config.Tickets[i]
 local equivalents=if i==1 then Config.Economy.StarterIncomeCars else Config.ParkingSlots*Config.Economy.ReferenceParkedRarity+(Config.SaleIncomeSeconds/Config.Economy.ReferenceCatchSeconds)*(rarityTotal/rarityWeight)
 b.ReferenceIncomePerMinute=b.BaseIncome*ticket.IncomeMultiplier*equivalents*60
end
for _,items in {Config.Exercises,Config.Tickets}do for _,item in items do
 item.Price=math.floor(item.Minutes*Config.Biomes[item.UnlockBiome].ReferenceIncomePerMinute+.5)
end end
return table.freeze(Config)

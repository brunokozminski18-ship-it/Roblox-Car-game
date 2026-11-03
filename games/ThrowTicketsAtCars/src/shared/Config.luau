--!strict
-- Prototype tuning: NOT FINAL. All progression, rewards and world dimensions live here.
local Config={
	StartPower=24, TickSeconds=1,
 Progression={XPPerLevel=100,PowerPerLevel=1,OfferEvery=12,OfferLifetime=4,BoostSeconds=2},
 Juice={LetterSeconds=.065,CommonRevealMin=1.3,RareRevealMin=2.5,RevealTimeout=12,PerfectPosition=.06,ToastSeconds=7,ShineEvery=5,BrakeSeconds=.3},
 Economy={StarterIncomeCars=3,TicketPaybackHorizonMinutes=120,ReferenceParkedRarity=3,ReferenceCatchSeconds=45,ReferenceTicket={"paper","pink","parking","court","gold","diamond"},TrainingWorkPerPower={4,18,32,90,220,220}},
 Simulation={CatchLoopSeconds=14,RefreshSeconds=45,PurchaseSeconds=2,MaxSeconds=86400},
 Exercises={
 {Id="basic",Name="Basic Training",Work=1,Minutes=0,UnlockBiome=1},
 {Id="focused",Name="Focused Training",Work=2,Minutes=1,UnlockBiome=1},
 {Id="weighted",Name="Weighted Training",Work=4,Minutes=2,UnlockBiome=2},
 {Id="intense",Name="Intense Training",Work=8,Minutes=8,UnlockBiome=3},
 {Id="elite",Name="Elite Training",Work=16,Minutes=25,UnlockBiome=4},
 {Id="master",Name="Master Training",Work=32,Minutes=90,UnlockBiome=5},
 },
 InventoryLimit=20, HotbarSlots=5, GarageRequestInterval=.15, PlacementDistance=9, PlotInteractRadius=36,
 ThrowMeter={Period=1.4,Timeout=3,MinBonus=-.05,MaxBonus=.10,MaxPingTolerance=.25,PollSeconds=.08},
 PromptHoldSeconds=.5,
 ThrowWindupSeconds=.45, CameraReturnHold=.3, CaptureApproachDistance=32, CaptureLaneX=7,
 TrafficHz=30, TrafficSpeed=22, TrafficLaneX=7, TrafficRenderDistance=450,
	ShopRequestInterval=0.3, MaxCash=1e15, MaxPower=1e9,
	Data={StoreName="ThrowTicketsAtCars_v1",Schema=4,LeaseSeconds=90,AutosaveSeconds=25,Attempts=4,SaveSoonSeconds=2,MinSaveGap=8,ShutdownSeconds=25},
	Tickets={
		{Id="paper",Name="Paper Ticket",Minutes=0,UnlockBiome=1,IncomeMultiplier=1,Luck=0,Color=Color3.fromRGB(255,244,180)},
		{Id="pink",Name="Pink Slip",Minutes=1.5,UnlockBiome=1,IncomeMultiplier=1.5,Luck=0.05,Color=Color3.fromRGB(255,133,199)},
		{Id="parking",Name="Parking Fine",Minutes=6,UnlockBiome=2,IncomeMultiplier=2.2,Luck=0.10,Color=Color3.fromRGB(124,230,255)},
		{Id="court",Name="Court Summons",Minutes=15,UnlockBiome=3,IncomeMultiplier=3.2,Luck=0.15,Color=Color3.fromRGB(194,139,255)},
		{Id="gold",Name="Golden Ticket",Minutes=40,UnlockBiome=4,IncomeMultiplier=4.6,Luck=0.20,Color=Color3.fromRGB(255,208,66)},
		{Id="diamond",Name="Diamond Ticket",Minutes=120,UnlockBiome=5,IncomeMultiplier=12,Luck=0.25,Color=Color3.fromRGB(165,255,243)},
	},
	ThrowCooldown=0.2, RequestInterval=0.12, TrainRequestInterval=0.3,
	MapEnd=3200, RoadWidth=24, GroundWidth=88, MapPadding=18,
	ThrowOrigin=Vector3.new(0,3.25,0), LandingHeight=3.25,
	TicketFlightSeconds=2, TicketArcHeight=8, TicketArcFactor=0.16, TicketArcMax=200,
	TicketSize=Vector3.new(0.8,0.08,1.2), MessageSeconds=3,
	TowApproachSeconds=0.5, TowLoadSeconds=0.2, TowReturnSeconds=1.3,
	RespawnSeconds=3, SaleIncomeSeconds=180,
	ParkingSlots=6, ParkingColumns=2,
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
	Biomes={
		{Name="Junkyard",MinPower=0,BaseIncome=1,Color=Color3.fromRGB(145,118,91),Cars={{Name="Rusty Sedan",Weight=1},{Name="Old Van",Weight=1},{Name="Broken Pickup",Weight=1}}},
		{Name="Suburbs",MinPower=50,BaseIncome=6,Color=Color3.fromRGB(122,153,111),Cars={{Name="Family Car",Weight=1},{Name="Minivan",Weight=1},{Name="Hatchback",Weight=1}}},
		{Name="Downtown",MinPower=150,BaseIncome=28,Color=Color3.fromRGB(112,132,153),Cars={{Name="Taxi",Weight=1},{Name="Police Cruiser",Weight=1},{Name="Limo",Weight=1}}},
		{Name="Sports Track",MinPower=400,BaseIncome=120,Color=Color3.fromRGB(171,105,98),Cars={{Name="Sports Coupe",Weight=1},{Name="Rally Car",Weight=1},{Name="Muscle Car",Weight=1}}},
		{Name="Luxury Classics",MinPower=1000,BaseIncome=500,Color=Color3.fromRGB(184,166,122),Cars={{Name="Vintage Roadster",Weight=1},{Name="Gold-Trim Classic",Weight=1}}},
		{Name="Hypercar Island",MinPower=2500,BaseIncome=2200,Color=Color3.fromRGB(91,164,176),Cars={{Name="Hypercar",Weight=1},{Name="Golden Hypercar",Weight=1},{Name="Rocket Car",Weight=1}}},
	},
}
-- Prices are authored in minutes. Reference includes a six-car park and active sales.
-- Starter benchmark is the measured ramp-up rather than an already full rare park.
local rarityTotal,rarityWeight=0,0
for _,r in Config.Rarities do rarityTotal+=r.Weight*r.Multiplier;rarityWeight+=r.Weight end
for i,b in Config.Biomes do
 local ticket=Config.Tickets[i]
 local equivalents=if i==1 then Config.Economy.StarterIncomeCars else Config.ParkingSlots*Config.Economy.ReferenceParkedRarity+(Config.SaleIncomeSeconds/Config.Economy.ReferenceCatchSeconds)*(rarityTotal/rarityWeight)
 b.ReferenceIncomePerMinute=b.BaseIncome*ticket.IncomeMultiplier*equivalents*60
end
for _,items in {Config.Exercises,Config.Tickets}do for _,item in items do
 item.Price=math.floor(item.Minutes*Config.Biomes[item.UnlockBiome].ReferenceIncomePerMinute+.5)
end end
return table.freeze(Config)

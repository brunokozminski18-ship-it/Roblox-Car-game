--!strict
local Config = require(game:GetService("ReplicatedStorage").ThrowTickets.Config)
local CarBuilder=require(game.ReplicatedStorage.ThrowTickets.CarBuilder)
local Rules=require(game.ReplicatedStorage.ThrowTickets.Rules)
local Props=require(script.Parent.BiomeProps)
local World = {}
function World.part(parent: Instance,name: string,size: Vector3,position: Vector3,color: Color3): Part
	local p=Instance.new("Part")
	p.Name,p.Size,p.Position=name,size,position
	p.Anchored,p.Material,p.Color=true,Enum.Material.SmoothPlastic,color
	p.TopSurface,p.BottomSurface=Enum.SurfaceType.Smooth,Enum.SurfaceType.Smooth
	p.Parent=parent
	return p
end
function World.label(parent: BasePart,text: string,offset: number?)
	local gui=Instance.new("BillboardGui")
	gui.Name,gui.Size,gui.StudsOffset="Label",UDim2.fromOffset(180,44),Vector3.new(0,offset or 4,0)
	gui.MaxDistance=Config.LabelDistance
	local t=Instance.new("TextLabel")
	t.Size,t.BackgroundTransparency=UDim2.fromScale(1,1),0.2
	t.BackgroundColor3,t.TextColor3=Color3.fromRGB(35,35,35),Color3.new(1,1,1)
	t.Font,t.TextSize,t.Text=Enum.Font.GothamBold,18,text
	t.Parent,gui.Parent=gui,parent
	return gui
end
World.car=CarBuilder.create
World.ticketOffset=CarBuilder.ticketOffset
function World.plotOrigin(plot: number): Vector3
 local group=math.floor((plot-1)/2)
 local side=if plot%2==1 then -1 else 1
 local rows={20,64,-24,108,-68,-112}
 return Vector3.new(side*(54+group%5*32),0,rows[math.floor(group/5)%#rows+1])
end
function World.viewPosition(biome: number,slot: number): Vector3
	local start=Config.Biomes[biome].Start
	local finish=math.min(Config.Biomes[biome].Finish,Config.MapEnd)
	local distance=start+(finish-start)*(slot-0.5)/Config.ViewCarsPerBiome
	return Vector3.new(if slot%2==1 then -Config.ViewCarX else Config.ViewCarX,Config.CarHeight,-distance)
end
function World.viewCar(root: Folder,biome: number,slot: number): Model
	local b=Config.Biomes[biome]
	local index=(slot-1)%#b.Cars+1;local reward=Rules.reward(biome,b.Cars[index].Rarity,index,"paper")
	local m=World.car(root.Cars,"View_"..biome.."_"..slot,reward,World.viewPosition(biome,slot))
	m:SetAttribute("Display",true);m:SetAttribute("DisplaySlot",slot)
	return m
end
local function gate(root: Folder,index: number)
	local b=Config.Biomes[index]
	local model=Instance.new("Model");model.Name="Gate"..index;model.ModelStreamingMode=Enum.ModelStreamingMode.Persistent;model:SetAttribute("Biome",index)
	for _,offset in {-Config.GatePostSpacing,Config.GatePostSpacing} do
		World.part(model,"Post",Vector3.new(0.8,Config.GateHeight,0.8),Vector3.new(Config.GateSignX+offset,Config.GateHeight/2,-b.Start),Color3.fromRGB(125,133,143))
	end
	local beam=World.part(model,"Sign",Config.GateBeamSize,Vector3.new(Config.GateSignX,Config.GateHeight,-b.Start),Color3.fromRGB(52,74,109))
	for _,face in {Enum.NormalId.Back,Enum.NormalId.Front} do
		local gui=Instance.new("SurfaceGui");gui.Name="BiomeSign";gui.Face=face
		gui.Active=false
		gui.SizingMode,gui.CanvasSize=Enum.SurfaceGuiSizingMode.FixedSize,Vector2.new(1000,160)
		gui.LightInfluence,gui.MaxDistance=0,Config.GateLabelDistance
		gui.Enabled=index==1
		local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1
		t.Text=string.format("%s  |  %d+ RANGE",b.Name:upper(),b.MinPower)
		t.Font,t.TextSize,t.TextColor3=Enum.Font.FredokaOne,58,Color3.new(1,1,1)
		t.Parent,gui.Parent=gui,beam
	end
	model.Parent=root.Gates
end
function World.build(biomeCount: number?): Folder
	for _,name in {"SpawnLocation","Baseplate"} do
		local p=workspace:FindFirstChild(name)
		if p and p:IsA("BasePart") then
			p.Transparency,p.CanCollide=1,false
			if p:IsA("SpawnLocation") then p.Enabled=false end
			for _,d in p:GetChildren() do if d:IsA("Decal") then d.Transparency=1 end end
		end
	end
	local old=workspace:FindFirstChild("TicketPrototype");if old then old:Destroy() end
	local root=Instance.new("Folder");root.Name="TicketPrototype"
	for _,name in {"Cars","Parking","Tows","Gates","Biomes"} do local f=Instance.new("Folder");f.Name,f.Parent=name,root end
	root.Parent=workspace
	local count=biomeCount or #Config.Biomes
	for i=1,count do
		local b=Config.Biomes[i]
		local finish=math.min(b.Finish,Config.MapEnd)
		local length=finish-b.Start
		local node=Instance.new("Folder");node.Name=b.Name;node.Parent=root.Biomes
		for start=b.Start,finish-1,1000 do
		 local span=math.min(1000,finish-start);local z=-start-span/2
		 World.part(node,"Ground",Vector3.new(Config.GroundWidth,1,span),Vector3.new(0,-.55,z),b.Color)
		 World.part(node,"Road",Vector3.new(Config.RoadWidth,.2,span),Vector3.new(0,0,z),Color3.fromRGB(91,95,100))
		end
		Props.build(node,b,World.part)
		gate(root,i)
		for slot=1,Config.ViewCarsPerBiome do World.viewCar(root,i,slot) end
		task.wait()
	end
	local locked=Instance.new("Folder");locked.Name="ComingSoon";locked.Parent=root
	for i,b in Config.ComingSoon do
	 local start=Config.MapEnd+10+(i-1)*350;local f=Instance.new("Folder");f.Name=b.Name;f.Parent=locked;f:SetAttribute("Locked",true)
	 World.part(f,"Ground",Vector3.new(Config.GroundWidth,1,340),Vector3.new(0,-.55,-start-170),b.Color)
	 World.part(f,"Road",Vector3.new(Config.RoadWidth,.2,340),Vector3.new(0,0,-start-170),Color3.fromRGB(85,85,93))
	 World.part(f,"Barrier",Vector3.new(Config.GroundWidth,15,2),Vector3.new(0,7,-start),Color3.fromRGB(75,70,94)).Transparency=.2
	 local sign=World.part(f,"Sign",Vector3.new(24,6,.8),Vector3.new(0,10,-start+1.5),Color3.fromRGB(46,42,66))
	 local label=World.label(sign,b.Name.."\nCOMING SOON",4);label.MaxDistance=150;label.AlwaysOnTop=true
	end
	World.part(root,"StartApron",Vector3.new(Config.GroundWidth,1,Config.MapPadding),Vector3.new(0,-0.55,Config.MapPadding/2),Config.Biomes[1].Color)
	World.part(root,"ParkingHubGround",Vector3.new(420,1,300),Vector3.new(0,-.65,0),Config.Biomes[1].Color)
	World.part(root,"ThrowLine",Config.LaunchSize,Config.LaunchCenter,Color3.fromRGB(225,225,225))
	local spawn=Instance.new("SpawnLocation");spawn.Name="PrototypeSpawn";spawn.Anchored,spawn.Neutral=true,true
	spawn.Size,spawn.Position=Config.SpawnSize,Config.SpawnPosition;spawn.Transparency,spawn.CanCollide,spawn.Duration=1,false,0;spawn.Parent=root
	root.Parent=workspace
	return root
end
function World.capacity(folder: Folder,capacity: number)
	folder:SetAttribute("Capacity",capacity)
	for index=1,Config.ParkingMax do
		local slot=folder:FindFirstChild("Slot"..index)
		if slot and slot:IsA("BasePart") then
			local unlocked=index<=capacity
			slot:SetAttribute("Unlocked",unlocked)
			slot.Transparency=if unlocked then 0 else 1
			slot.CanCollide=unlocked
			slot.CanQuery=unlocked
			slot.CanTouch=unlocked
		end
	end
end
function World.parking(root: Folder,plot: number,ownerId: number,displayName: string): (Folder,{Vector3})
	local f=Instance.new("Folder");f.Name=tostring(ownerId);f:SetAttribute("OwnerId",ownerId);f.Parent=root.Parking
	local origin=World.plotOrigin(plot)
	-- The lot and training pad both fit between adjacent origins (32 by 44 studs).
	World.part(f,"ParkingGround",Vector3.new(30,1,43),origin-Vector3.new(8.5,0.55,7.2),Color3.fromRGB(130,130,130))
	local train=World.part(f,"TrainingPad",Config.TrainingSize,origin+Vector3.new(0,.2,10),Color3.fromRGB(120,155,140));train:SetAttribute("OwnerId",ownerId);World.label(train,"TRAINING",1)
	local positions={}
	for i=1,Config.ParkingMax do
		local pos=origin-Vector3.new((i-1)%4*6.5,0,math.floor((i-1)/4)*8.2)
		positions[i]=pos+Vector3.new(0,Config.CarHeight,0)
		local part=World.part(f,"Slot"..i,Vector3.new(6.2,0.2,7.8),pos,Color3.fromRGB(178,178,178))
		part:SetAttribute("OwnerId",ownerId);part:SetAttribute("ActiveIncome",0)
	end
	local sign=World.part(f,"ParkingUpgradeSign",Vector3.new(5,3,.5),origin+Vector3.new(-10,1.5,8),Color3.fromRGB(47,105,199))
	sign.CanCollide=false;sign.CanTouch=false;sign:SetAttribute("OwnerId",ownerId)
	local label=World.label(sign,"PARKING UPGRADE",2.25);label.Name="UpgradeLabel";label.MaxDistance=35
	local icon=Instance.new("Frame");icon.Name="CarIcon";icon.BorderSizePixel=0;icon.Size=UDim2.fromOffset(22,8);icon.Position=UDim2.fromOffset(38,12);icon.BackgroundColor3=Color3.fromHex("B9D5F7");icon.Parent=label
	local roof=Instance.new("Frame");roof.BorderSizePixel=0;roof.Size=UDim2.fromOffset(12,5);roof.Position=UDim2.fromOffset(4,-4);roof.BackgroundColor3=icon.BackgroundColor3;roof.Parent=icon
	for _,x in {3,15}do local wheel=Instance.new("Frame");wheel.BorderSizePixel=0;wheel.Size=UDim2.fromOffset(5,5);wheel.Position=UDim2.fromOffset(x,6);wheel.BackgroundColor3=Color3.fromHex("25344B");wheel.Parent=icon end
	World.capacity(f,Config.ParkingSlots)
	World.label(f.Slot1,displayName.."'s parking",7).MaxDistance=45
	return f,positions
end
return World

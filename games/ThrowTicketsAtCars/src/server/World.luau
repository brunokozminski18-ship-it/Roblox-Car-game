--!strict
local Config = require(game:GetService("ReplicatedStorage").ThrowTickets.Config)
local CarBuilder=require(game.ReplicatedStorage.ThrowTickets.CarBuilder)
local Rules=require(game.ReplicatedStorage.ThrowTickets.Rules)
local Props=require(script.Parent.BiomeProps)
local Decor=require(script.Parent.MapDecor)
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
-- Plot centre. Plots 1..5 stand in one row on the plaza, plot 3 straight ahead of the tunnel.
-- Extra plots (server set above 5 players) get a fallback row behind, so nothing overlaps.
function World.plotOrigin(plot: number): Vector3
 local L=Config.Layout
 local index=(plot-1)%L.Plots;local row=math.floor((plot-1)/L.Plots)
 return Vector3.new((index-(L.Plots-1)/2)*L.PlotSpacing,0,L.PlotZ+row*50)
end
-- A walk-up stand against a cliff face; the client opens the matching UI from its prompt.
local function stand(root: Instance,name: string,text: string,x: number,color: Color3)
 local L=Config.Layout
 local m=Instance.new("Model");m.Name=name
 local base=World.part(m,"Counter",Vector3.new(14,4,6),Vector3.new(x,2,L.StandZ),Color3.fromRGB(150,108,70))
 World.part(m,"Roof",Vector3.new(16,1,8),Vector3.new(x,9,L.StandZ),color)
 for _,dx in {-6.5,6.5}do World.part(m,"Post",Vector3.new(1,5,1),Vector3.new(x+dx,6.5,L.StandZ-2.5),Color3.fromRGB(120,86,56))end
 local pad=World.part(m,"Pad",Vector3.new(10,.2,6),Vector3.new(x,.1,L.StandZ+6),color);pad.Transparency=.35;pad.CanCollide=false
 local label=World.label(base,text,12.5);label.MaxDistance=120;label.Size=UDim2.fromOffset(160,48);label.TextLabel.TextSize=26
 local prompt=Instance.new("ProximityPrompt");prompt.Name=name;prompt.ActionText=if name=="OpenShop"then "Open shop"else "Sell cars";prompt.ObjectText=text
 prompt.HoldDuration=0;prompt.MaxActivationDistance=12;prompt.RequiresLineOfSight=false;prompt.KeyboardKeyCode=Enum.KeyCode.E;prompt.Parent=pad
 m.PrimaryPart=base;m.Parent=root
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
	local L=Config.Layout
	World.part(root,"Plaza",Vector3.new(L.PlazaWidth,1,L.PlazaDepth),Vector3.new(0,-.55,L.PlazaDepth/2),Color3.fromRGB(110,190,90))
	-- Tunnel: cliffs on both sides of the biome road, front faces at z=0 looking at the plaza.
	local cliffs=Instance.new("Folder");cliffs.Name="Cliffs";cliffs.Parent=root
	local length=Config.MapEnd+10+#Config.ComingSoon*350
	for side=-1,1,2 do
	 for start=0,length-1,1000 do
	  local span=math.min(1000,length-start)
	  World.part(cliffs,"Cliff",Vector3.new(L.CliffWidth,L.CliffHeight,span),Vector3.new(side*(Config.GroundWidth/2+L.CliffWidth/2),L.CliffHeight/2-1,-start-span/2),Color3.fromRGB(122,86,58))
	  World.part(cliffs,"Grass",Vector3.new(L.CliffWidth,1,span),Vector3.new(side*(Config.GroundWidth/2+L.CliffWidth/2),L.CliffHeight-.5,-start-span/2),Color3.fromRGB(96,180,72))
	 end
	end
	local line=World.part(root,"ThrowLine",Config.LaunchSize,Config.LaunchCenter,Color3.fromRGB(255,110,20));line.Material=Enum.Material.Neon
	-- Traffic lights at both ends of the line come from MapDecor.
	stand(root,"OpenShop","SHOP",-L.ShopX,Color3.fromRGB(226,51,140))
	stand(root,"OpenSell","SELL",L.ShopX,Color3.fromRGB(35,160,80))
	local spawn=Instance.new("SpawnLocation");spawn.Name="PrototypeSpawn";spawn.Anchored,spawn.Neutral=true,true
	spawn.Size,spawn.Position=Config.SpawnSize,Config.SpawnPosition;spawn.Transparency,spawn.CanCollide,spawn.Duration=1,false,0;spawn.Parent=root
	Decor.world(root)
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
	-- Lot faces north (the tunnel): front row of slots first, training pad outside the open front fence.
	World.part(f,"ParkingGround",Vector3.new(30,1,40),origin-Vector3.new(0,0.49,0),Color3.fromRGB(130,130,130))
	local wood=Color3.fromRGB(176,128,80)
	World.part(f,"FenceBack",Vector3.new(30,3,.6),origin+Vector3.new(0,1.5,20),wood)
	for _,x in {-15,15}do World.part(f,"FenceSide",Vector3.new(.6,3,40),origin+Vector3.new(x,1.5,0),wood)end
	for _,x in {-10,10}do World.part(f,"FenceFront",Vector3.new(10,3,.6),origin+Vector3.new(x,1.5,-20),Color3.fromRGB(90,140,220))end
	local train=World.part(f,"TrainingPad",Config.TrainingSize,origin+Vector3.new(0,.2,-25),Color3.fromRGB(120,155,140));train:SetAttribute("OwnerId",ownerId);World.label(train,"TRAINING",1)
	local positions={}
	for i=1,Config.ParkingMax do
		local pos=origin+Vector3.new(-9.75+(i-1)%4*6.5,0,-12.3+math.floor((i-1)/4)*8.2)
		positions[i]=pos+Vector3.new(0,Config.CarHeight,0)
		local part=World.part(f,"Slot"..i,Vector3.new(6.2,0.2,7.8),pos,Color3.fromRGB(178,178,178))
		part:SetAttribute("OwnerId",ownerId);part:SetAttribute("ActiveIncome",0)
	end
	local sign=World.part(f,"ParkingUpgradeSign",Vector3.new(5,3,.5),origin+Vector3.new(-11,1.5,-22),Color3.fromRGB(47,105,199))
	sign.CanCollide=false;sign.CanTouch=false;sign:SetAttribute("OwnerId",ownerId)
	local label=World.label(sign,"PARKING UPGRADE",2.25);label.Name="UpgradeLabel";label.MaxDistance=35
	local icon=Instance.new("Frame");icon.Name="CarIcon";icon.BorderSizePixel=0;icon.Size=UDim2.fromOffset(22,8);icon.Position=UDim2.fromOffset(38,12);icon.BackgroundColor3=Color3.fromHex("B9D5F7");icon.Parent=label
	local roof=Instance.new("Frame");roof.BorderSizePixel=0;roof.Size=UDim2.fromOffset(12,5);roof.Position=UDim2.fromOffset(4,-4);roof.BackgroundColor3=icon.BackgroundColor3;roof.Parent=icon
	for _,x in {3,15}do local wheel=Instance.new("Frame");wheel.BorderSizePixel=0;wheel.Size=UDim2.fromOffset(5,5);wheel.Position=UDim2.fromOffset(x,6);wheel.BackgroundColor3=Color3.fromHex("25344B");wheel.Parent=icon end
	Decor.plot(f,origin)
	World.capacity(f,Config.ParkingSlots)
	World.label(f.Slot1,displayName.."'s parking",7).MaxDistance=45
	return f,positions
end
return World

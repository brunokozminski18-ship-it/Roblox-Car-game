--!strict
local Config = require(game:GetService("ReplicatedStorage").ThrowTickets.Config)
local RustySedan=require(script.Parent.RustySedan)
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
function World.car(parent: Instance,name: string,reward: any,position: Vector3): Model
	local m=Instance.new("Model");m.Name=name;m.ModelStreamingMode=Enum.ModelStreamingMode.Persistent
	local body=World.part(m,"Body",Config.CarSize,position,Color3.fromRGB(145,145,145))
	World.part(m,"Roof",Config.RoofSize,position+Vector3.new(0,Config.RoofOffset,0),Config.Rarities[reward.Rarity].Color)
	local glass=World.part(m,"Windshield",Config.WindshieldSize,position+Vector3.new(0,Config.RoofOffset,Config.WindshieldFront),Color3.fromRGB(135,157,170))
	glass.Material=Enum.Material.Glass
	if reward.Name=="Rusty Sedan"then RustySedan.decorate(m,World.part,position)end
	for _,p in m:GetChildren() do if p:IsA("BasePart") then p.CanCollide=false end end
	m.PrimaryPart=body
	m:SetAttribute("CarName",reward.Name);m:SetAttribute("Rarity",reward.Rarity);m:SetAttribute("Biome",reward.Biome);m:SetAttribute("Income",reward.Income)
	m.Parent=parent
	return m
end
function World.viewPosition(biome: number,slot: number): Vector3
	local start=Config.Biomes[biome].MinPower
	local finish=if Config.Biomes[biome+1] then Config.Biomes[biome+1].MinPower else Config.MapEnd
	local distance=start+(finish-start)*(slot-0.5)/Config.ViewCarsPerBiome
	return Vector3.new(if slot%2==1 then -Config.ViewCarX else Config.ViewCarX,Config.CarHeight,-distance)
end
function World.viewCar(root: Folder,biome: number,slot: number): Model
	local b=Config.Biomes[biome]
	local reward={Biome=biome,Rarity=1,Income=b.BaseIncome,Name=b.Cars[(slot-1)%#b.Cars+1].Name}
	local m=World.car(root.Cars,"View_"..biome.."_"..slot,reward,World.viewPosition(biome,slot))
	m:SetAttribute("Display",true);m:SetAttribute("DisplaySlot",slot)
	return m
end
local function gate(root: Folder,index: number)
	local b=Config.Biomes[index]
	local model=Instance.new("Model");model.Name="Gate"..index;model.ModelStreamingMode=Enum.ModelStreamingMode.Persistent;model:SetAttribute("Biome",index)
	for _,offset in {-Config.GatePostSpacing,Config.GatePostSpacing} do
		World.part(model,"Post",Vector3.new(0.8,Config.GateHeight,0.8),Vector3.new(Config.GateSignX+offset,Config.GateHeight/2,-b.MinPower),Color3.fromRGB(125,133,143))
	end
	local beam=World.part(model,"Sign",Config.GateBeamSize,Vector3.new(Config.GateSignX,Config.GateHeight,-b.MinPower),Color3.fromRGB(52,74,109))
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
	local count=biomeCount or #Config.Biomes
	for i=1,count do
		local b=Config.Biomes[i]
		local finish=if Config.Biomes[i+1] then Config.Biomes[i+1].MinPower else Config.MapEnd
		local length=finish-b.MinPower
		local node=Instance.new("Folder");node.Name=b.Name;node.Parent=root.Biomes
		World.part(node,"Ground",Vector3.new(Config.GroundWidth,1,length),Vector3.new(0,-0.55,-b.MinPower-length/2),b.Color)
		World.part(node,"Road",Vector3.new(Config.RoadWidth,0.2,length),Vector3.new(0,0,-b.MinPower-length/2),Color3.fromRGB(91,95,100))
		for k=1,Config.DecorationCount do
			local height=if i==4 then 2 else (2+i)*((k%3)+1)
			local x=if k%2==0 then Config.DecorX else -Config.DecorX
			World.part(node,"GreyBlock"..k,Vector3.new(6,height,6),Vector3.new(x,height/2,-b.MinPower-length*k/(Config.DecorationCount+1)),Color3.fromRGB(124,124,124))
		end
		gate(root,i)
		for slot=1,Config.ViewCarsPerBiome do World.viewCar(root,i,slot) end
	end
	World.part(root,"StartApron",Vector3.new(Config.GroundWidth,1,Config.MapPadding),Vector3.new(0,-0.55,Config.MapPadding/2),Config.Biomes[1].Color)
	local line=World.part(root,"ThrowLine",Config.LaunchSize,Config.LaunchCenter,Color3.fromRGB(225,225,225))
	local train=World.part(root,"TrainingPad",Config.TrainingSize,Config.TrainingPosition,Color3.fromRGB(120,135,120))
	World.label(train,string.format("TRAIN +%d POWER / s",Config.TrainGain),1)
	local spawn=Instance.new("SpawnLocation");spawn.Name="PrototypeSpawn";spawn.Anchored,spawn.Neutral=true,true
	spawn.Size,spawn.Position=Config.SpawnSize,Config.SpawnPosition;spawn.Transparency,spawn.CanCollide,spawn.Duration=1,false,0;spawn.Parent=root
	root.Parent=workspace
	return root
end
function World.parking(root: Folder,plot: number,ownerId: number,displayName: string): (Folder,{Vector3})
	local f=Instance.new("Folder");f.Name=tostring(ownerId);f.Parent=root.Parking
	local origin=Config.ParkingOrigin-Vector3.new((plot-1)*Config.PlayerPlotSpacing,0,0)
	World.part(f,"ParkingGround",Vector3.new(27,1,40),origin-Vector3.new(5.5,0.55,12),Color3.fromRGB(130,130,130))
	local positions={}
	for i=1,Config.ParkingSlots do
		local pos=origin-Vector3.new((i-1)%Config.ParkingColumns*Config.ParkingSpacing.X,0,math.floor((i-1)/Config.ParkingColumns)*Config.ParkingSpacing.Z)
		positions[i]=pos+Vector3.new(0,Config.CarHeight,0)
		local part=World.part(f,"Slot"..i,Vector3.new(9,0.2,10),pos,Color3.fromRGB(178,178,178))
		part:SetAttribute("PromisedIncome",0);part:SetAttribute("ActiveIncome",0)
	end
	World.label(f.Slot1,displayName.."'s parking",7).MaxDistance=45
	return f,positions
end
return World

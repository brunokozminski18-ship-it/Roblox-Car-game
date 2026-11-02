--!strict
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local GuiService=game:GetService("GuiService")
local Config=require(RS.ThrowTickets.Config)
local Rules=require(RS.ThrowTickets.Rules)
local Effects=require(script.Parent.Effects)
local p=Players.LocalPlayer
local remotes=RS.ThrowTickets:WaitForChild("Remotes")
local Throw=remotes:WaitForChild("Throw")::RemoteEvent
local Train=remotes:WaitForChild("Train")::RemoteEvent
local Feedback=remotes:WaitForChild("Feedback")::RemoteEvent
local Ticket=remotes:WaitForChild("Ticket")::RemoteEvent
local world=workspace:WaitForChild("TicketPrototype")
local gates=world:WaitForChild("Gates")
local cash=p:WaitForChild("leaderstats"):WaitForChild("Cash")::IntValue
local gui=Instance.new("ScreenGui")
gui.Name,gui.ResetOnSpawn="TicketHUD",false
gui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets
gui.ZIndexBehavior,gui.DisplayOrder=Enum.ZIndexBehavior.Sibling,10
gui.Parent=p:WaitForChild("PlayerGui")
local function label(name: string,size: UDim2,pos: UDim2,text: string): TextLabel
	local t=Instance.new("TextLabel");t.Name,t.Size,t.Position=name,size,pos
	t.Text,t.TextSize,t.Font=text,22,Enum.Font.GothamBold
	t.TextColor3,t.BackgroundColor3=Color3.new(1,1,1),Color3.fromRGB(30,34,40)
	t.BackgroundTransparency,t.BorderSizePixel,t.Active=0.1,0,false;t.Parent=gui;return t
end
local cashLabel=label("Cash",UDim2.fromOffset(174,42),UDim2.new(0.5,-178,0,4),"")
local powerLabel=label("Power",UDim2.fromOffset(174,42),UDim2.new(0.5,4,0,4),"")
cashLabel.TextColor3,powerLabel.TextColor3=Color3.fromRGB(142,255,160),Color3.fromRGB(145,210,255)
local biomeLabel=label("Biome",UDim2.fromOffset(356,26),UDim2.new(0.5,0,0,50),"")
biomeLabel.AnchorPoint,biomeLabel.TextSize=Vector2.new(0.5,0),18
local nextLabel=label("NextBiome",UDim2.fromOffset(356,26),UDim2.new(0.5,0,0,78),"")
nextLabel.AnchorPoint,nextLabel.TextSize=Vector2.new(0.5,0),14
local track=Instance.new("Frame");track.Name="BiomeProgress";track.Size=UDim2.fromOffset(356,6)
track.AnchorPoint,track.Position=Vector2.new(0.5,0),UDim2.new(0.5,0,0,104)
track.BorderSizePixel,track.BackgroundColor3,track.Active=0,Color3.fromRGB(35,35,35),false;track.Parent=gui
local fill=Instance.new("Frame");fill.Name="Fill";fill.Size=UDim2.fromScale(0,1)
fill.BorderSizePixel,fill.BackgroundColor3,fill.Active=0,Color3.fromRGB(255,213,80),false;fill.Parent=track
local message=label("Message",UDim2.new(0.7,0,0,28),UDim2.new(0.15,0,1,-32),"THROW! Distance = Power")
message.TextSize=15
local function button(name: string,size: Vector2,pos: UDim2): TextButton
	local b=Instance.new("TextButton");b.Name,b.Text,b.Size,b.Position=name,name:upper(),UDim2.fromOffset(size.X,size.Y),pos
	b.AnchorPoint=Vector2.new(1,1);b.Font,b.TextSize=Enum.Font.GothamBlack,23
	b.BackgroundColor3,b.TextColor3=Color3.fromRGB(225,230,235),Color3.fromRGB(25,30,38)
	b.BorderSizePixel,b.Parent=2,gui;return b
end
local throwButton=button("Throw",Vector2.new(110,62),UDim2.new(1,-12,1,-98))
local trainButton=button("Train",Vector2.new(110,44),UDim2.new(1,-12,1,-170));trainButton.TextSize=17
local function responsive()
	local compact=gui.AbsoluteSize.Y<400;local width=if compact then 174 else 210
	cashLabel.TextSize,powerLabel.TextSize=if compact then 22 else 28,if compact then 22 else 28
	cashLabel.Size,powerLabel.Size=UDim2.fromOffset(width,42),UDim2.fromOffset(width,42)
	cashLabel.Position,powerLabel.Position=UDim2.new(0.5,-width-4,0,4),UDim2.new(0.5,4,0,4)
end
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(responsive);responsive()
local lastThrow=-math.huge
local function throw()
	if os.clock()-lastThrow<Config.ThrowCooldown then return end
	lastThrow=os.clock();throwButton.Text,throwButton.BackgroundColor3="THROW!",Color3.fromRGB(255,224,110)
	task.delay(Config.RequestInterval,function()throwButton.Text,throwButton.BackgroundColor3="THROW",Color3.fromRGB(225,230,235)end)
	-- No direction, power, biome or reward is supplied by this client.
	Throw:FireServer()
end
throwButton.Activated:Connect(throw)
trainButton.Activated:Connect(function()Train:FireServer(not p:GetAttribute("Training"))end)
UIS.InputBegan:Connect(function(input,processed)
	if not processed and input.UserInputType==Enum.UserInputType.MouseButton1 then throw()end
end)
local version=0
Feedback.OnClientEvent:Connect(function(text: string)
	version+=1;local current=version;message.Text=text
	task.delay(Config.MessageSeconds,function()if version==current then message.Text="THROW! Distance = Power"end end)
end)
Ticket.OnClientEvent:Connect(function(origin: Vector3,destination: Vector3,car: Model?,owner: number,income: number,metadata: any)
	Effects.flight(origin,destination,car,income,owner==p.UserId,metadata)
end)
Effects.watchParking(world:WaitForChild("Parking"));Effects.watchTows(world:WaitForChild("Tows"))
local function short(n: number): string
	if n>=1000000 then return string.format("%.1fM",math.floor(n/100000)/10)end
	if n>=1000 then return string.format("%.1fK",math.floor(n/100)/10)end
	return tostring(n)
end
local previousPower=p:GetAttribute("ThrowPower")or Config.StartPower
local function updateStats()
	local power=p:GetAttribute("ThrowPower")or 0;local distance=Rules.distance(power)
	local index=Rules.biome(distance);local b=Config.Biomes[index]
	cashLabel.Text="CASH $"..short(cash.Value);powerLabel.Text="POWER "..short(power)
	biomeLabel.Text=string.format("%s | %d STUDS",b.Name:upper(),distance)
	biomeLabel.TextColor3=b.Color:Lerp(Color3.new(1,1,1),0.65)
	local nextIndex,need=Rules.nextBiome(power)
	if nextIndex then
		local nextBiome=Config.Biomes[nextIndex]
		nextLabel.Text=string.format("Next biome: %s - need %d Power",nextBiome.Name,need)
		fill.Size=UDim2.fromScale(math.clamp((power-b.MinPower)/(nextBiome.MinPower-b.MinPower),0,1),1)
	else nextLabel.Text=string.format("MAX BIOME | Road limit: %d studs",Config.MapEnd);fill.Size=UDim2.fromScale(1,1)end
	trainButton.Text=if p:GetAttribute("Training")then"TRAIN: ON"else string.format("TRAIN +%d",Config.TrainGain)
end
p:GetAttributeChangedSignal("ThrowPower"):Connect(function()
	local power=p:GetAttribute("ThrowPower")or 0;local gain=power-previousPower;previousPower=power;updateStats()
	local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart")::BasePart?
	if gain>0 and gain<=Config.TrainGain and root then Effects.popup(root,string.format("+%d Power",gain),Color3.fromRGB(140,210,255),"PowerPopup")end
end)
for _,attr in {"Training","ParkingUsed"}do p:GetAttributeChangedSignal(attr):Connect(updateStats)end
cash.Changed:Connect(updateStats);updateStats()
-- PlayerModule remains the sole camera controller. Throws never take it over.
local function restoreCamera(character: Model)
	local h=character:WaitForChild("Humanoid")::Humanoid;local root=character:WaitForChild("HumanoidRootPart")::BasePart
	local camera=workspace.CurrentCamera;p.CameraMode=Enum.CameraMode.Classic
	p.CameraMinZoomDistance,p.CameraMaxZoomDistance=Config.CameraMinZoom,Config.CameraMaxZoom
	UIS.MouseBehavior=Enum.MouseBehavior.Default;h.CameraOffset=Config.CameraFocusOffset
	camera.CameraSubject=h;camera.CFrame=CFrame.lookAt(root.Position+Config.CameraStartOffset,root.Position);camera.CameraType=Enum.CameraType.Custom
end
p.CharacterAdded:Connect(restoreCamera);if p.Character then task.spawn(restoreCamera,p.Character)end
local elapsed=0
RunService.RenderStepped:Connect(function(dt)
	elapsed+=dt;if elapsed<Config.RequestInterval then return end;elapsed=0
	local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart")::BasePart?
	if not root then return end
	local nearest: Model?=nil;local best=Config.GateLabelDistance
	for _,g in gates:GetChildren()do
		local sign=g:FindFirstChild("Sign")::BasePart?
		if sign then local distance=(sign.Position-root.Position).Magnitude;if distance<best then nearest,best=g,distance end end
	end
	for _,g in gates:GetChildren()do
		local sign=g:FindFirstChild("Sign")
		if sign then
			local camera=workspace.CurrentCamera
			local show=g==nearest
			if camera and show then
				local top=camera:WorldToViewportPoint(sign.Position+sign.CFrame.UpVector*sign.Size.Y*0.16)
				local bottom=camera:WorldToViewportPoint(sign.Position-sign.CFrame.UpVector*sign.Size.Y*0.16)
				local inset=GuiService:GetGuiInset()
				local hudTop=cashLabel.AbsolutePosition.Y+inset.Y
				local hudBottom=track.AbsolutePosition.Y+track.AbsoluteSize.Y+inset.Y
				local overlaps=math.min(top.Y,bottom.Y)<hudBottom+6 and math.max(top.Y,bottom.Y)>hudTop-6
				show=top.Z>0 and not overlaps
			end
			for _,surface in sign:GetChildren()do if surface:IsA("SurfaceGui")then surface.Enabled=show end end
		end
	end
end)

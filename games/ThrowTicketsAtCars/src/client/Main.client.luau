--!strict
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local GuiService=game:GetService("GuiService")
local Config=require(RS.ThrowTickets.Config)
local Rules=require(RS.ThrowTickets.Rules)
local Audio=require(script.Parent.Audio)
task.spawn(function()local status=Audio.preload();Players.LocalPlayer:SetAttribute("AudioPreload",game:GetService("HttpService"):JSONEncode(status))end)
local Effects=require(script.Parent.Effects)
local ShopUI=require(script.Parent.Shop)
local Cinematics=require(script.Parent.Cinematics)
local Exercises=require(script.Parent.Exercises)
local p=Players.LocalPlayer
Audio.mountButtons(p:WaitForChild("PlayerGui"))
local remotes=RS.ThrowTickets:WaitForChild("Remotes")
local Throw=remotes:WaitForChild("Throw")::RemoteEvent
local Train=remotes:WaitForChild("Train")::RemoteEvent
local Feedback=remotes:WaitForChild("Feedback")::RemoteEvent
local Ticket=remotes:WaitForChild("Ticket")::RemoteEvent
local world=workspace:WaitForChild("TicketPrototype")
local gates=world:WaitForChild("Gates")
local cash=(p:WaitForChild("leaderstats",math.huge)::Folder):WaitForChild("Cash",math.huge)::IntValue -- the profile load can take a few seconds
local hud=require(script.Parent.HUD).mount(p:WaitForChild("PlayerGui"))
local gui,trainButton,message=hud.gui,hud.train,hud.message
local shop=ShopUI.mount(gui,cash,remotes:WaitForChild("Shop")::RemoteEvent,Feedback,hud.shop)
local indexView=require(script.Parent.CarIndex).mount(p:WaitForChild("PlayerGui"),hud.index)
local juice=require(script.Parent.JuiceHUD).mount(remotes,shop)
Cinematics.setFeedback(juice.feedback)
local reveal=require(script.Parent.CatchReveal).mount(p:WaitForChild("PlayerGui"),Audio.play)
remotes:WaitForChild("Juice").OnClientEvent:Connect(function(kind,data)
 if kind=="Reveal"then reveal.show(data,function()remotes.ContinueCatch:FireServer(data.Id)end)
 else juice.feedback(kind,data)end
end)
local function juiceReady()if p:GetAttribute("DataReady")then (remotes:WaitForChild("JuiceReady")::RemoteEvent):FireServer()end end
p:GetAttributeChangedSignal("DataReady"):Connect(juiceReady);juiceReady()
p.CharacterRemoving:Connect(reveal.hide)
p:GetAttributeChangedSignal("ThrowPhase"):Connect(function()local phase=p:GetAttribute("ThrowPhase");if phase=="Idle"or phase=="Tow"then reveal.hide()end end)
local inventory=require(script.Parent.InventoryUI).mount(world,remotes:WaitForChild("Garage")::RemoteEvent,remotes:WaitForChild("InventorySnapshot")::RemoteEvent,remotes:WaitForChild("ConfirmSale")::RemoteEvent,hud.cars,indexView)
require(script.Parent.ReturnUI).mount(remotes,shop,inventory,indexView)
require(script.Parent.LeaderboardUI).mount(world)
-- Map v5 stands: SHOP (left) opens the shop, SELL (right) opens My Cars where selling happens.
game:GetService("ProximityPromptService").PromptTriggered:Connect(function(prompt: ProximityPrompt)
 if not prompt:IsDescendantOf(world)then return end
 if prompt.Name=="OpenShop"then shop.openCategory("Exercise")elseif prompt.Name=="OpenSell"then inventory.open(true)end
end)
indexView.gui:GetAttributeChangedSignal("Open"):Connect(function()if indexView.isOpen()then inventory.open(false);shop.close()end end)
inventory.gui:GetAttributeChangedSignal("Open"):Connect(function()if inventory.isOpen()then indexView.close()end end)
p.PlayerGui.TicketShop:GetAttributeChangedSignal("Open"):Connect(function()if shop.isOpen()then indexView.close();inventory.open(false)end end)
p:GetAttributeChangedSignal("Throwing"):Connect(function()if p:GetAttribute("Throwing")then indexView.close()end end)
require(script.Parent.ThrowMeterUI).mount(Throw)
require(script.Parent.PowerSelector).mount(remotes:WaitForChild("SelectPower")::RemoteEvent,hud.powerSettings)
Exercises.mount();require(script.Parent.Traffic).mount(world)
require(script.Parent.CharacterFx).mount(remotes:WaitForChild("Juice")::RemoteEvent)
task.spawn(function()require(script.Parent.Onboarding).mount(world,remotes,hud,Audio.play)end)
trainButton.Activated:Connect(function()Train:FireServer(not p:GetAttribute("TrainingActive"))end)
local version=0;local messageDeadline=0
local bannerVersion=0
local function messageVisibility()
 message.Visible=os.clock()<messageDeadline and not p:GetAttribute("BoostTargetVisible")and not p:GetAttribute("PowerSelectorVisible")
end
for _,a in {"BoostTargetVisible","PowerSelectorVisible"}do p:GetAttributeChangedSignal(a):Connect(messageVisibility)end
Feedback.OnClientEvent:Connect(function(text: string)
	if text:sub(1,9)=="Sold for "or text:sub(1,20)=="Your parking is full"or text:sub(1,13)=="Backpack full"or text=="NEW CAR DISCOVERED!"or text:sub(1,17)=="Parking upgraded!"then
	 bannerVersion+=1;local n=bannerVersion;hud.banner.Text=text;hud.banner.BackgroundColor3=if text:find("full",1,true)then Color3.fromHex("A32742")else Color3.fromHex("23683C");hud.banner.Visible=true
	 task.delay(3,function()if bannerVersion==n then hud.banner.Visible=false end end);return
	end
	if string.sub(text,1,6)=="Bought"then Audio.play("Purchase")end
	version+=1;local current=version;message.Text=text;messageDeadline=os.clock()+Config.MessageSeconds;messageVisibility()
	task.delay(Config.MessageSeconds,function()if version==current then message.Text="";message.Visible=false end end)
end)
Ticket.OnClientEvent:Connect(function(origin: Vector3,destination: Vector3,car: Model?,owner: number,income: number,metadata: any)
	Cinematics.play(origin,destination,car,owner,income,metadata)
end)
Effects.watchParking(world:WaitForChild("Parking"));Effects.watchTows(world:WaitForChild("Tows"))
local function updateStats()
 local boosted=workspace:GetServerTimeNow()<(p:GetAttribute("BoostUntil")or 0)
 hud.render(cash.Value,p:GetAttribute("ThrowPower")or 0,p:GetAttribute("EquippedTicket"),p:GetAttribute("TrainingActive")==true,(p:GetAttribute("TrainingRate")or 0)*(if boosted then 2 else 1))
 hud.mode(p:GetAttribute("Location")or "Road",p:GetAttribute("Throwing")==true,p:GetAttribute("ThrowPhase")or "Idle")
 hud.gui.Enabled=p:GetAttribute("CinematicActive")~=true
 local phase=p:GetAttribute("ThrowPhase");hud.top.Visible=phase~="Flying"and phase~="Hit"and phase~="Reveal"
end
p:GetAttributeChangedSignal("ThrowPower"):Connect(function()
	updateStats()
end)
for _,attr in {"Training","TrainingActive","TrainingXP","BoostUntil","Exercise","TrainingRate","ParkingUsed","EquippedTicket","Location","Throwing","ThrowPhase","CinematicActive"}do p:GetAttributeChangedSignal(attr):Connect(updateStats)end
cash.Changed:Connect(updateStats);updateStats()
-- Default camera outside a bounded throw cinematic; Cinematics restores on every exit.
local function restoreCamera(character: Model)
	local h=character:WaitForChild("Humanoid")::Humanoid;local root=character:WaitForChild("HumanoidRootPart")::BasePart
	Cinematics.cancel()
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
				local hudTop=hud.top.AbsolutePosition.Y+inset.Y
				local hudBottom=hud.top.AbsolutePosition.Y+hud.top.AbsoluteSize.Y+inset.Y
				local overlaps=math.min(top.Y,bottom.Y)<hudBottom+6 and math.max(top.Y,bottom.Y)>hudTop-6
				show=top.Z>0 and not overlaps
			end
			for _,surface in sign:GetChildren()do if surface:IsA("SurfaceGui")then surface.Enabled=show end end
		end
	end
end)

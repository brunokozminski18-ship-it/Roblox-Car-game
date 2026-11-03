--!strict
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local GuiService=game:GetService("GuiService")
local Config=require(RS.ThrowTickets.Config)
local Rules=require(RS.ThrowTickets.Rules)
local Effects=require(script.Parent.Effects)
local ShopUI=require(script.Parent.Shop)
local Cinematics=require(script.Parent.Cinematics)
local Exercises=require(script.Parent.Exercises)
local p=Players.LocalPlayer
local remotes=RS.ThrowTickets:WaitForChild("Remotes")
local Throw=remotes:WaitForChild("Throw")::RemoteEvent
local Train=remotes:WaitForChild("Train")::RemoteEvent
local Feedback=remotes:WaitForChild("Feedback")::RemoteEvent
local Ticket=remotes:WaitForChild("Ticket")::RemoteEvent
local world=workspace:WaitForChild("TicketPrototype")
local gates=world:WaitForChild("Gates")
local cash=p:WaitForChild("leaderstats"):WaitForChild("Cash")::IntValue
local hud=require(script.Parent.HUD).mount(p:WaitForChild("PlayerGui"))
local gui,trainButton,message=hud.gui,hud.train,hud.message
local shop=ShopUI.mount(gui,cash,remotes:WaitForChild("Shop")::RemoteEvent,Feedback,hud.shop)
local inventory=require(script.Parent.InventoryUI).mount(world,remotes:WaitForChild("Garage")::RemoteEvent,remotes:WaitForChild("InventorySnapshot")::RemoteEvent,remotes:WaitForChild("ConfirmSale")::RemoteEvent,hud.cars)
require(script.Parent.ThrowMeterUI).mount(Throw)
Exercises.mount();require(script.Parent.Traffic).mount(world)
trainButton.Activated:Connect(function()Train:FireServer(not p:GetAttribute("TrainingActive"))end)
local version=0
Feedback.OnClientEvent:Connect(function(text: string)
	version+=1;local current=version;message.Text=text;message.Visible=true
	task.delay(Config.MessageSeconds,function()if version==current then message.Text="";message.Visible=false end end)
end)
Ticket.OnClientEvent:Connect(function(origin: Vector3,destination: Vector3,car: Model?,owner: number,income: number,metadata: any)
	Cinematics.play(origin,destination,car,owner,income,metadata)
end)
Effects.watchParking(world:WaitForChild("Parking"));Effects.watchTows(world:WaitForChild("Tows"))
local previousPower=p:GetAttribute("ThrowPower")or Config.StartPower
local function updateStats()
 hud.render(cash.Value,p:GetAttribute("ThrowPower")or 0,p:GetAttribute("EquippedTicket"),p:GetAttribute("TrainingActive")==true,p:GetAttribute("TrainingRate")or 0)
 hud.mode(p:GetAttribute("Location")or "Road",p:GetAttribute("Throwing")==true,p:GetAttribute("ThrowPhase")or "Idle")
end
p:GetAttributeChangedSignal("ThrowPower"):Connect(function()
	local power=p:GetAttribute("ThrowPower")or 0;local gain=power-previousPower;previousPower=power;updateStats()
	local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart")::BasePart?
	if gain>0 and gain<=Config.Exercises[#Config.Exercises].Work and root then Effects.popup(root,"+"..Rules.powerText(gain).." Power",Color3.fromRGB(140,210,255),"PowerPopup")end
end)
for _,attr in {"Training","TrainingActive","Exercise","TrainingRate","ParkingUsed","EquippedTicket","Location","Throwing","ThrowPhase"}do p:GetAttributeChangedSignal(attr):Connect(updateStats)end
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

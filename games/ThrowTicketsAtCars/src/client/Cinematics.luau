--!strict
-- One bounded camera owner for flight/hit/reveal; default camera restored on every exit.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local GuiService=game:GetService("GuiService")
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local Rules=require(game.ReplicatedStorage.ThrowTickets.Rules)
local Effects=require(script.Parent.Effects)
local Exercises=require(script.Parent.Exercises)
local Audio=require(script.Parent.Audio)
local C={};local p=Players.LocalPlayer
local binding="ThrowTicketsCinematic";local active: any=nil;local seen={};local feedback=function(_event: string,_data: any)end
function C.setFeedback(callback: (string,any)->())feedback=callback end
local function restore(s: any)
 if s.closed then return end;s.closed=true
 if active==s then active=nil;RunService:UnbindFromRenderStep(binding)end
 for _,connection in s.connections do connection:Disconnect()end
 if s.cancel then s.cancel()end
 for part,value in s.hidden or {}do if part.Parent then part.LocalTransparencyModifier=value end end
 if s.touch and s.touch.Parent then s.touch.Enabled=s.touchEnabled end
 local humanoid=p.Character and p.Character:FindFirstChildOfClass("Humanoid")
 if s.camera and s.camera.Parent then
  s.camera.CFrame=s.frame;s.camera.Focus=s.focus;s.camera.FieldOfView=s.fov
  s.camera.CameraSubject=if s.subject and s.subject.Parent then s.subject else humanoid
  s.camera.CameraType=if s.subject and s.subject.Parent then s.kind else Enum.CameraType.Custom
 end
 local camera=workspace.CurrentCamera
 if camera and camera~=s.camera and camera.CameraType==Enum.CameraType.Scriptable then camera.CameraSubject=humanoid;camera.CameraType=Enum.CameraType.Custom end
 feedback("FlightEnd",{})
end
function C.cancel()if active then restore(active)end end
function C.play(origin: Vector3,destination: Vector3,car: Model?,owner: number,income: number,data: any)
 if seen[data.Id]then return end;seen[data.Id]=true;task.delay(30,function()seen[data.Id]=nil end)
 local mine=owner==p.UserId;local now=workspace:GetServerTimeNow();local delaySeconds=math.max(0,data.StartTime+data.WindupSeconds-now)
 local ownerPlayer=Players:GetPlayerByUserId(owner);if ownerPlayer and delaySeconds>0 then Exercises.windup(ownerPlayer,delaySeconds)end
 local session: any=nil
 if mine and p.Character and p.Character:FindFirstChildOfClass("Humanoid")then
  C.cancel();local camera=workspace.CurrentCamera
  session={closed=false,camera=camera,frame=camera.CFrame,focus=camera.Focus,fov=camera.FieldOfView,subject=camera.CameraSubject,kind=camera.CameraType,connections={}};active=session
  local current=session;current.hidden={};current.touch=p.PlayerGui:FindFirstChild("TouchGui");if current.touch then current.touchEnabled=current.touch.Enabled;current.touch.Enabled=false end
  local humanoid=p.Character:FindFirstChildOfClass("Humanoid")
  table.insert(current.connections,humanoid.Died:Connect(function()restore(current)end))
  table.insert(current.connections,p.CharacterRemoving:Connect(function()restore(current)end))
  table.insert(current.connections,workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()restore(current)end))
  table.insert(current.connections,p:GetAttributeChangedSignal("ThrowPhase"):Connect(function()local phase=p:GetAttribute("ThrowPhase");if phase=="Tow"or phase=="Idle"then restore(current)end end))
  task.delay(delaySeconds+data.FlightSeconds+Config.Juice.RevealTimeout+5,function()restore(current)end)
  Audio.play("Throw")
 end
 task.delay(delaySeconds,function()
  if session and session.closed then return end
  local point=origin;local impactAt: number?=nil
  if session then
   local current=session;local camera=current.camera;camera.CameraType=Enum.CameraType.Scriptable
   RunService:BindToRenderStep(binding,Enum.RenderPriority.Camera.Value+1,function()
    if current.closed then return end
    local target=if impactAt then data.Position+Vector3.new(0,.7,0)else point
    local offset=Vector3.new(4,6,13)
    if impactAt then
     local elapsed=os.clock()-impactAt
     local pullback=math.clamp((elapsed-.28)/.85,0,1);pullback=1-(1-pullback)^3
     local final=if data.Rarity>=3 then Vector3.new(-8,4,10)else Vector3.new(-10,4.5,12)
     offset=Vector3.new(0,1.2,6):Lerp(final,pullback)
    end
    local shake=Vector3.zero
    if impactAt and not GuiService.ReducedMotionEnabled then
     local elapsed=os.clock()-impactAt;local envelope=math.max(0,1-elapsed/.42)^2
     shake=Vector3.new(math.sin(elapsed*87),math.cos(elapsed*73),0)*.24*envelope
    end
    camera.CFrame=CFrame.lookAt(target+offset+shake,target);camera.Focus=CFrame.new(target)
   end)
  end
  local cancel=Effects.flight(origin,destination,car,income,mine,data,function(position,t)
   point=position
   if mine then feedback("Flight",{Biome=Config.Biomes[Rules.biome(math.abs(position.Z))].Name,Progress=t,Luck=(data.Luck or 1)*t})end
  end,function()
   if session and not session.closed then
    impactAt=os.clock();Audio.play("Brake");feedback("FlightEnd",{})
    local cars=workspace:FindFirstChild("TicketPrototype")and workspace.TicketPrototype:FindFirstChild("Cars")
    local watched={}
    local function conceal(node: Instance)
     local model=if node:IsA("Model")then node else node:FindFirstAncestorOfClass("Model")
     if model and not watched[model]then
      watched[model]=true
      table.insert(session.connections,model:GetAttributeChangedSignal("Display"):Connect(function()
       if model:GetAttribute("Display")==true then for _,part in model:GetDescendants()do
        if part:IsA("BasePart")and session.hidden[part]==nil then session.hidden[part]=part.LocalTransparencyModifier;part.LocalTransparencyModifier=1 end
       end end
      end))
     end
     if model and model:GetAttribute("Display")==true then for _,part in model:GetDescendants()do
      if part:IsA("BasePart")and session.hidden[part]==nil then session.hidden[part]=part.LocalTransparencyModifier;part.LocalTransparencyModifier=1 end
     end end
    end
    if cars then for _,model in cars:GetChildren()do conceal(model)end;table.insert(session.connections,cars.DescendantAdded:Connect(conceal))end
   end
  end)
  if session then session.cancel=cancel end
 end)
end
return C

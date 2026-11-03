--!strict
-- One bounded camera owner for flight/hit/reveal; default camera restored on every exit.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local GuiService=game:GetService("GuiService")
local Tween=game:GetService("TweenService")
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local Rules=require(game.ReplicatedStorage.ThrowTickets.Rules)
local Effects=require(script.Parent.Effects)
local Exercises=require(script.Parent.Exercises)
local Audio=require(script.Parent.Audio)
local C={};local p=Players.LocalPlayer
local binding="ThrowTicketsCinematic";local active: any=nil;local seen={};local feedback=function(_event: string,_data: any)end
local overlay=Instance.new("ScreenGui");overlay.Name="CatchTransition";overlay.ResetOnSpawn=false;overlay.DisplayOrder=80;overlay.ScreenInsets=Enum.ScreenInsets.None;overlay.Parent=p:WaitForChild("PlayerGui")
local curtain=Instance.new("Frame");curtain.Name="Fade";curtain.Size=UDim2.fromScale(1,1);curtain.BorderSizePixel=0;curtain.BackgroundColor3=Color3.fromRGB(12,15,25);curtain.BackgroundTransparency=1;curtain.Parent=overlay
local flash=curtain:Clone();flash.Name="RareFlash";flash.BackgroundColor3=Color3.fromRGB(216,160,255);flash.Parent=overlay
local fadeTween: Tween?=nil
local function fade(value: number,seconds: number)
 if fadeTween then fadeTween:Cancel()end
 fadeTween=Tween:Create(curtain,TweenInfo.new(seconds,Enum.EasingStyle.Sine),{BackgroundTransparency=value});fadeTween:Play()
end
function C.setFeedback(callback: (string,any)->())feedback=callback end
local function restore(s: any,keepFade: boolean?)
 if s.closed then return end;s.closed=true
 if active==s then active=nil;RunService:UnbindFromRenderStep(binding)end
 for _,connection in s.connections do connection:Disconnect()end
 if s.cancel then s.cancel()end
 for part,value in s.hidden or {}do if part.Parent then part.LocalTransparencyModifier=value end end
 if s.touch and s.touch.Parent then s.touch.Enabled=s.touchEnabled end
 p:SetAttribute("CinematicActive",false);flash.BackgroundTransparency=1
 if not keepFade then if fadeTween then fadeTween:Cancel()end;curtain.BackgroundTransparency=1 end
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
local function finish(s: any)
 if s.closed or s.returning then return end;s.returning=true
 fade(0,.14)
 task.delay(.15,function()if s.closed then return end;restore(s,true);fade(1,.3)end)
end
function C.cancel()if active then restore(active)end end
function C.play(origin: Vector3,destination: Vector3,car: Model?,owner: number,income: number,data: any)
 if seen[data.Id]then return end;seen[data.Id]=true;task.delay(30,function()seen[data.Id]=nil end)
 local mine=owner==p.UserId;local now=workspace:GetServerTimeNow();local delaySeconds=math.max(0,data.StartTime+data.WindupSeconds-now)
 local ownerPlayer=Players:GetPlayerByUserId(owner);if ownerPlayer and delaySeconds>0 then Exercises.windup(ownerPlayer,delaySeconds)end
 local session: any=nil
 if mine and p.Character and p.Character:FindFirstChildOfClass("Humanoid")then
  C.cancel();local camera=workspace.CurrentCamera
  session={closed=false,camera=camera,frame=camera.CFrame,focus=camera.Focus,fov=camera.FieldOfView,subject=camera.CameraSubject,kind=if camera.CameraType==Enum.CameraType.Scriptable then Enum.CameraType.Custom else camera.CameraType,connections={}};active=session
  p:SetAttribute("CinematicActive",true)
  local current=session;current.hidden={};current.touch=p.PlayerGui:FindFirstChild("TouchGui");if current.touch then current.touchEnabled=current.touch.Enabled;current.touch.Enabled=false end
  local humanoid=p.Character:FindFirstChildOfClass("Humanoid")
  table.insert(current.connections,humanoid.Died:Connect(function()restore(current)end))
  table.insert(current.connections,p.CharacterRemoving:Connect(function()restore(current)end))
  table.insert(current.connections,workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()restore(current)end))
  table.insert(current.connections,p:GetAttributeChangedSignal("ThrowPhase"):Connect(function()
   local phase=p:GetAttribute("ThrowPhase")
   if phase=="Tow"and not current.towStart then current.towStart=os.clock();current.towFrame=current.camera.CFrame;feedback("FlightEnd",{})
   elseif phase=="Idle"then finish(current)end
  end))
  task.delay(delaySeconds+data.FlightSeconds+Config.Juice.RevealTimeout+6,function()restore(current)end)
  Audio.play("Throw")
 end
 task.delay(delaySeconds,function()
  if session and session.closed then return end
  local point=origin;local impactAt: number?=nil
  if session then
   local current=session;local camera=current.camera;camera.CameraType=Enum.CameraType.Scriptable
   RunService:BindToRenderStep(binding,Enum.RenderPriority.Camera.Value+1,function()
    if current.closed then return end
    camera.CameraType=Enum.CameraType.Scriptable
    if current.returning then return end
    if current.towStart then
     local target=if car and car.Parent and car.PrimaryPart then car.PrimaryPart.Position+Vector3.new(0,1,0)else data.Position+Vector3.new(0,1,0)
     local desired=CFrame.lookAt(target+Vector3.new(-18,10,22),target)
     local t=math.clamp((os.clock()-current.towStart)/.65,0,1);t=t*t*(3-2*t)
     camera.CFrame=current.towFrame:Lerp(desired,t);camera.Focus=CFrame.new(target);return
    end
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
     local rare=data.Rarity>=3;local elapsed=os.clock()-impactAt;local envelope=math.max(0,1-elapsed/(if rare then .65 else .3))^2
     shake=Vector3.new(math.sin(elapsed*63),math.cos(elapsed*57),0)*(if rare then .45 else .16)*envelope
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
    if data.Rarity>=3 then
     Audio.play("RareArrival")
     if not GuiService.ReducedMotionEnabled then flash.BackgroundColor3=Config.Rarities[data.Rarity].Color;flash.BackgroundTransparency=.82;Tween:Create(flash,TweenInfo.new(.5),{BackgroundTransparency=1}):Play()end
    end
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

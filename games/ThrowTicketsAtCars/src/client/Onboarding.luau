--!strict
-- First 60 seconds (client): objective banner, beam + highlight to the player's own targets, SHOP pulse, skip.
-- Hidden while a throw, reveal or tow plays, so nothing covers the catch moment.
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local CollectionService=game:GetService("CollectionService")
local TweenService=game:GetService("TweenService")
local GuiService=game:GetService("GuiService")
local HttpService=game:GetService("HttpService")
local Tutorial=require(RS.ThrowTickets.LihFolkTutorial)
local Steps=require(RS.ThrowTickets.TutorialSteps)
local S=require(script.Parent.Style)
local Onboarding={}
function Onboarding.mount(world: Instance,remotes: Instance,hud: any,play: (string)->())
 local p=Players.LocalPlayer
 local remote=remotes:WaitForChild("Tutorial")::RemoteEvent
 -- Client-local tags: only this player's own slot and pad are ever tagged on this client.
 local function tagPlot(folder: Instance)
  local pad=folder:WaitForChild("TrainingPad",10);if pad then CollectionService:AddTag(pad,"TT_MyTrainingPad")end
  local function retag()
   local chosen: Instance?=nil
   for i=1,40 do
    local slot=folder:FindFirstChild("Slot"..i);if not slot then break end
    CollectionService:RemoveTag(slot,"TT_MyFreeSlot")
    if not chosen and slot:IsA("BasePart")and slot.Transparency<1 and slot:GetAttribute("CarId")==nil then chosen=slot end
   end
   if chosen then CollectionService:AddTag(chosen,"TT_MyFreeSlot")end
  end
  for _,c in folder:GetChildren()do if c.Name:match("^Slot%d+$")then c:GetAttributeChangedSignal("CarId"):Connect(retag)end end
  retag()
 end
 local parking=world:WaitForChild("Parking")
 local mine=parking:FindFirstChild(tostring(p.UserId));if mine then task.spawn(tagPlot,mine)end
 parking.ChildAdded:Connect(function(c)if c.Name==tostring(p.UserId)then task.spawn(tagPlot,c)end end)
 local ui=Tutorial.Client.DefaultUi()
 local gui=p.PlayerGui:WaitForChild("LihFolkTutorialUI")::ScreenGui
 local objective=gui:WaitForChild("Objective")::TextLabel
 local hint=gui:WaitForChild("Hint")::TextLabel
 -- Below the top bar, the HUD buttons and the LEVEL UP toast; centred so it never sits under a thumb.
 objective.Position=UDim2.new(.5,0,0,190);hint.Position=UDim2.new(.5,0,0,232)
 objective.TextColor3=Color3.fromHex("FFF2A6");S.stroke(objective,3)
 local skip=S.button(gui,"TutorialSkip","SKIP",UDim2.fromOffset(88,44),UDim2.new(1,-12,0,190));skip.AnchorPoint=Vector2.new(1,0);skip.TextSize=18;skip.Visible=false
 local wantObjective,wantHint,wantSkip=false,false,false
 local function calm(): boolean return GuiService.ReducedMotionEnabled end
 local function busy(): boolean
  local phase=p:GetAttribute("ThrowPhase")
  return (phase~=nil and phase~="Idle")or p:GetAttribute("MeterStart")~=nil or p:GetAttribute("CinematicActive")==true
 end
 local function visibility()
  local free=not busy()
  objective.Visible=wantObjective and free;hint.Visible=wantHint and free;skip.Visible=wantSkip and free
 end
 for _,a in {"ThrowPhase","MeterStart","CinematicActive"}do p:GetAttributeChangedSignal(a):Connect(visibility)end
 -- SHOP pulse for the HUD step (guide = "none" there).
 local pulse: Tween?=nil
 -- lihfolk-ignore: findfirstchild-chain (optional type, checked before every use)
 local shopStroke=hud.shop:FindFirstChildOfClass("UIStroke")::UIStroke?
 local baseThickness=if shopStroke then shopStroke.Thickness else 0
 local function pulseShop(on: boolean)
  if pulse then pulse:Cancel();pulse=nil end
  if not shopStroke then return end
  shopStroke.Color=if on then Color3.fromHex("FFD24A")else S.INK
  shopStroke.Thickness=if on then baseThickness+3 else baseThickness
  if on and not calm()then
   pulse=TweenService:Create(shopStroke,TweenInfo.new(.6,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Thickness=baseThickness+6});pulse:Play()
  end
 end
 local base=ui
 local view={
  showObjective=function(id: string,text: string,progress: number,goal: number)
   base.showObjective(id,text,progress,goal);wantObjective=true;pulseShop(id=="buy");visibility()
  end,
  hideObjective=function()base.hideObjective();wantObjective=false;pulseShop(false);visibility()end,
  showHint=function(id: string,text: string)base.showHint(id,text);wantHint=true;visibility()end,
  hideHint=function()base.hideHint();wantHint=false;visibility()end,
  celebrate=function(_id: string)play("Toast")end,
  setSkipVisible=function(v: boolean)wantSkip=v;visibility()end,
 }
 local confirming=false
 skip.Activated:Connect(function()
  if not confirming then
   confirming=true;skip.Text="SURE?"
   task.delay(3,function()confirming=false;skip.Text="SKIP"end);return
  end
  remote:FireServer("skip")
 end)
 -- End of the tutorial is a celebration that hands over the next goal (server sends the goal text).
 local wasFinished: boolean?=nil
 local function onState()
  local raw=p:GetAttribute("LFTutorial");if typeof(raw)~="string"then return end
  local ok,state=pcall(HttpService.JSONDecode,HttpService,raw);if not ok or typeof(state)~="table"then return end
  if wasFinished==false and state.finished==true then
   play("LevelUp")
   objective.Text="YOU'RE READY! Catch them all!";wantObjective=true;visibility()
   task.delay(3,function()if objective.Text=="YOU'RE READY! Catch them all!"then wantObjective=false;visibility()end end)
  end
  wasFinished=state.finished==true
 end
 p:GetAttributeChangedSignal("LFTutorial"):Connect(onState);onState()
 local client=Tutorial.Client.new({steps=Steps,remote=remote,ui=view,beamColor=Color3.fromHex("FFD24A")})
 client:Start()
 return client
end
return Onboarding

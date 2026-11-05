--!strict
local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local S=require(script.Parent.Style)
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local UI={}
function UI.mount(remotes: Folder,shop: any,inventory: any,index: any)
 local p=Players.LocalPlayer
 local welcome=require(script.Parent.WelcomeBack).mount(p.PlayerGui,function()remotes.ReturnClaim:FireServer("Offline")end)
 local pendingLike=false;local lastShown=-math.huge;local hideAt=0;local previousBusy: boolean?=nil
 local toast=S.text(welcome.gui,"LikeToast","Enjoying the game? Don't forget to like! 👍",19,UDim2.new(.5,0,0,66),UDim2.fromOffset(460,48))
 toast.AnchorPoint=Vector2.new(.5,0);toast.TextXAlignment=Enum.TextXAlignment.Center;toast.BackgroundTransparency=.05;toast.BackgroundColor3=Color3.fromHex("214EAB");toast.TextWrapped=true;toast.Visible=false;S.corner(toast,16);S.stroke(toast,3)
 -- A separate screen keeps the non-modal toast alive after the welcome card closes.
 local toastGui=Instance.new("ScreenGui");toastGui.Name="ReturnToasts";toastGui.ResetOnSpawn=false;toastGui.DisplayOrder=54;toastGui.ScreenInsets=Enum.ScreenInsets.CoreUISafeInsets;toastGui.Parent=p.PlayerGui;toast.Parent=toastGui
 local function catching()return p:GetAttribute("Throwing")==true or p:GetAttribute("CinematicActive")==true end
 local function otherModal()return shop.isOpen()or inventory.isOpen()or index.isOpen()or p:GetAttribute("PowerSelectorVisible")==true or p:GetAttribute("BoostTargetVisible")==true end
 local function update()
  local cash=p:GetAttribute("OfflineCash")or 0
  if p:GetAttribute("DataReady")==true and cash>0 and not catching()and not otherModal()then
   if not welcome.gui.Enabled then welcome.show(cash,p:GetAttribute("OfflineAway")or 0)end
  else welcome.hide()end
  if p:GetAttribute("ReturnBusy")~=true then welcome.retry()end
 end
 for _,a in {"DataReady","OfflineCash","OfflineAway","ReturnBusy","Throwing","CinematicActive"}do p:GetAttributeChangedSignal(a):Connect(update)end
 remotes.Social.OnClientEvent:Connect(function(kind)if kind=="Like"then pendingLike=true end end)
 local elapsed=0;local connection=Run.Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<.2 then return end;elapsed=0;update()
  local busy=catching()or otherModal()or welcome.gui.Enabled
  if busy~=previousBusy then previousBusy=busy;remotes.Social:FireServer(busy)end
  if busy or os.clock()>=hideAt then toast.Visible=false end
  if pendingLike and not busy and os.clock()-lastShown>=Config.Returns.LikeSeconds then
   pendingLike=false;lastShown=os.clock();hideAt=lastShown+5;toast.Visible=true
  end
  toast.Size=UDim2.fromOffset(math.min(460,toastGui.AbsoluteSize.X-32),48)
 end)
 welcome.gui.Destroying:Connect(function()connection:Disconnect();toastGui:Destroy()end)
 update()
end
return UI

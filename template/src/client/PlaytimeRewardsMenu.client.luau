--!strict
-- Template: session gifts; server owns eligibility, elapsed and claims.
local RS = game:GetService("ReplicatedStorage")
local Style = RS:WaitForChild("UIStyle")
local UI = require(Style.Components)
local D = require(Style.StyleD)
local ItemArt = require(Style.ItemArt)
local Launcher = require(Style.Launcher)
local Toast = require(Style.Toast)
local Controller = require(RS:WaitForChild("LihFolkUI").LihFolkUIController)
local Net = require(RS:WaitForChild("LihFolk").Net)
local Config = require(RS:WaitForChild("GameConfig")) :: any
local track = Config.PlaytimeRewards.track
local function clock(value: number): string
 local seconds=math.max(0,math.ceil(value))
 return string.format("%02d:%02d",seconds//60,seconds%60)
end
Controller.start()
local window=UI.Window({name="Playtime",title="Playtime Rewards",size=D.Playtime.window,header=D.Playtime.header,footer=D.Playtime.footer})
local subtitle=UI.Text("Free gifts for time played. Resets when you leave.",{size=22,wrap=true,box=UDim2.new(1,0,0,D.Playtime.subtitleHeight),parent=window.body})
subtitle.LayoutOrder=1
local grid=Instance.new("Frame") grid.Name="Gifts" grid.BackgroundTransparency=1 grid.Size=UDim2.new(1,0,0,0) grid.AutomaticSize=Enum.AutomaticSize.Y grid.LayoutOrder=2 grid.Parent=window.body
local layout=Instance.new("UIGridLayout") layout.CellSize=UDim2.new(.25,-12,0,D.Playtime.cardHeight) layout.CellPadding=UDim2.fromOffset(14,16) layout.SortOrder=Enum.SortOrder.LayoutOrder layout.Parent=grid
local footer=Instance.new("Frame") footer.BackgroundTransparency=1 footer.Size=UDim2.new(1,-40,0,60) footer.Parent=window.panel footer.Name="SessionTime" footer.Position=UDim2.new(0,20,1,-72)
local fire=Instance.new("ImageLabel") fire.BackgroundTransparency=1 fire.Image=ItemArt.image("fire") or "" fire.Size=UDim2.fromOffset(64,64) fire.Position=UDim2.fromOffset(0,-4) fire.Rotation=-8 fire.Parent=footer
local played=UI.Text("PLAYED: --:--",{size=28,color=D.Color.gold,box=UDim2.new(.49,-72,1,0),position=UDim2.fromOffset(72,0),parent=footer})
local nextGift=UI.Button({text="NEXT IN --:--",swatch=D.Button.grey,textSize=26,size=UDim2.new(.51,-8,1,-8),position=UDim2.new(.49,0,0,4),parent=footer})
nextGift.root.Selectable=false nextGift.root.Active=false
local fitting=false
local function fit()
 if fitting then return end
 fitting=true
 local compact=window.root.AbsoluteSize.Y<450
 if compact then
  footer.Parent=window.body footer.LayoutOrder=3 footer.Position=UDim2.new() footer.Size=UDim2.new(1,0,0,60)
 else
  footer.Parent=window.panel footer.Position=UDim2.new(0,20,1,-72) footer.Size=UDim2.new(1,-40,0,60)
 end
 local top=window.body.Position.Y.Offset
 local bottom=if compact then 12 else 86
 window.body.Size=UDim2.new(1,-24,1,-top-bottom)
 local width=grid.AbsoluteSize.X/math.max(window.fitScale.Scale*window.motionScale.Scale,.01)
 local cols=if width>=760 then 4 elseif width>=540 then 3 else 2
 layout.CellSize=UDim2.new(1/cols,-math.ceil(14*(cols-1)/cols)-1,0,D.Playtime.cardHeight)
 fitting=false
end
window.root:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
window.body:GetPropertyChangedSignal("Size"):Connect(fit)
grid:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
fit()
local launcher=Launcher.add("Playtime","playtime",8)
local claimed: {[string]: boolean}={}
local elapsedAtSync=0
local syncedAt=0
local loaded=false
local busy=false
local cards: {any}={}
local render: () -> ()
local function elapsed(): number
 return if loaded then elapsedAtSync+os.clock()-syncedAt else 0
end
local function accept(response: any)
 if response.data and type(response.data.elapsed)=="number" and type(response.data.claimed)=="table" then
  elapsedAtSync=response.data.elapsed syncedAt=os.clock() claimed=response.data.claimed loaded=true
 end
end
local function claim(id: string)
 if busy or not loaded then return end
 busy=true render()
 local result=Net.Request("PlaytimeRewards.Claim",id)
 accept(result)
 if not result.ok then Toast.Result(result) end
 busy=false render()
end
for i, gift in track do
 local card=UI.Card({family=if gift.featured then D.Card.mega else D.Card.locked,size=UDim2.fromOffset(180,D.Playtime.cardHeight),layoutOrder=i,parent=grid})
 card.Name=gift.id
 if gift.featured then UI.Rays(card) UI.Ribbon("MEGA!",card) end
 local art=UI.ItemArt(ItemArt.image(gift.art),UDim2.fromOffset(96,96),card)
 art.AnchorPoint=Vector2.new(.5,.5) art.Position=UDim2.new(.5,0,0,60) art.Rotation=if i%2==0 then 6 else -6
 UI.Text(gift.label,{size=23,align=Enum.TextXAlignment.Center,box=UDim2.new(1,-12,0,30),position=UDim2.fromOffset(6,112),parent=card})
 local button=UI.Button({text="--:--",swatch=D.Button.grey,textSize=23,size=UDim2.new(1,-24,0,52),position=UDim2.new(0,12,1,-62),name="Claim_"..gift.id,parent=card,onActivated=function() task.spawn(claim,gift.id) end})
 local pill=UI.Pill("--:--",card) pill.root.Position=UDim2.new(0,18,1,-48)
 local doneLabel=UI.Text("CLAIMED",{size=22,align=Enum.TextXAlignment.Center,box=UDim2.new(1,-12,0,36),position=UDim2.new(0,6,1,-48),parent=card})
 local check=UI.ItemArt(ItemArt.image("check"),UDim2.fromOffset(64,64),card) check.Name="ClaimedCheck" check.AnchorPoint=Vector2.new(.5,.5) check.Position=UDim2.new(.5,0,0,60) check.ZIndex=5 check.Visible=false
 local now=UI.Ribbon("NOW!",card) now.Visible=false
 table.insert(cards,{gift=gift,card=card,button=button,check=check,now=now,pill=pill,doneLabel=doneLabel,state=""})
end
render=function()
 local seconds=elapsed()
 local ready=false
 local nextIn: number?=nil
 for _, row in cards do
  local gift=row.gift
  local remaining=math.max(0,gift.minutes*60-seconds)
  local done=claimed[gift.id]==true
  local available=loaded and not done and remaining<=0
  local state=if done then "claimed" elseif available then "ready" elseif gift.featured then "mega" else "locked"
  if state~=row.state then UI.SetCardState(row.card,state) row.state=state end
  row.check.Visible=done row.now.Visible=available
  row.doneLabel.Visible=done
  row.button.root.Visible=available
  row.pill.root.Visible=not done and not available
  row.pill.label.Text=if loaded then clock(remaining) else "--:--"
  row.button.setText(if done then "CLAIMED" elseif not loaded then "LOADING" elseif available then (if busy then "WAIT..." else "CLAIM!") else clock(remaining))
  row.button.setSwatch(if available then D.Button.green else D.Button.grey)
  row.button.root.Active=available and not busy row.button.root.Selectable=available and not busy
  if available then ready=true end
  if not done and remaining>0 then nextIn=math.min(nextIn or math.huge,remaining) end
 end
 played.Text=if loaded then "PLAYED: "..clock(math.floor(seconds)) else "PLAYED: --:--"
 nextGift.setText(if not loaded then "CONNECTING..." elseif ready then "GIFT READY!" elseif nextIn then "NEXT IN "..clock(nextIn) else "ALL CLAIMED!")
 launcher.setBadge(ready)
end
window.defaultSelection=window.closeButton.root -- always visible, including before the first gift
Controller.register(window)
local function refresh()
 if busy then return end
 busy=true
 local result=Net.Request("PlaytimeRewards.Get")
 accept(result)
 busy=false render()
end
Controller.onChanged(function(name: string,isOpen: boolean)
 if name=="Playtime" and isOpen then task.spawn(refresh) end
end)
task.spawn(function()
 local nextSync=0
 while window.root.Parent do
  if os.clock()>=nextSync then
   refresh()
   nextSync=os.clock()+(if loaded then 15 else 1.5)
  end
  render()
  task.wait(.25)
 end
end)


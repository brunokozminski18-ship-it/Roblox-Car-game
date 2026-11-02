-- Studio Client: real UI contract, after mounting and loading an isolated QA profile.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players.LocalPlayer
local hud=p.PlayerGui.TicketHUD
local window=p.PlayerGui.TicketShop.Window
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local count=0
local function check(ok,msg)assert(ok,msg);count+=1 end
check(hud.TopBar.AbsoluteSize.Y+hud.TopBar.Position.Y.Offset+3<=workspace.CurrentCamera.ViewportSize.Y*.12,"Top HUD <=12% including margin/stroke")
check(not hud.TopBar.Stats.TextWrapped and hud.TopBar.Stats.TextBounds.Y<=28,"Single-line stats fit")
check(hud.Shop.AbsolutePosition.X+hud.Shop.AbsoluteSize.X+8<=hud.Train.AbsolutePosition.X,"SHOP left of TRAIN, 8px gap")
check(hud.Train.AbsolutePosition.X+hud.Train.AbsoluteSize.X+8<=hud.Throw.AbsolutePosition.X,"TRAIN left of THROW, 8px gap")
check(hud.Throw.AbsoluteSize.X*hud.Throw.AbsoluteSize.Y>hud.Train.AbsoluteSize.X*hud.Train.AbsoluteSize.Y,"THROW largest")
for _,b in {hud.Shop,hud.Train,hud.Throw,window.Close}do check(b.AbsoluteSize.X>=44 and b.AbsoluteSize.Y>=44,"Touch target >=44")end
check(not window.Tickets.paper.Perk.Text:find("+0%%"),"Hide zero luck")
local found={}
for _,t in Config.Tickets do
 local row=window.Tickets[t.Id];local state=row:GetAttribute("State");found[state]=true
 local color=row.UIGradient.Color.Keypoints[1].Value
 if state=="Equipped"then
  check(color.G>color.R and color.G>color.B and row.Action.Text=="EQUIPPED","Equipped is green and labelled")
 else check(not(color.G>color.R and color.G>color.B),"Green reserved for equipped")end
 if state=="Locked"then check(row.Action.Lock.Visible and row.Perk.Text:match("^Buy .+ first$")~=nil,"Locked explains predecessor and has lock")end
 if state=="Affordable"or state=="Unaffordable"then
  local price=row.Action.Price
  check(price.Visible and price.TextSize>=22 and row.Action.Text=="BUY","Large price on BUY")
  check(if state=="Affordable"then price.TextColor3.G>price.TextColor3.R else price.TextColor3.R>price.TextColor3.G,"Price colour matches funds")
  if window.Visible then check(row.Action:GetAttribute("Pulsing")== (state=="Affordable"and not game:GetService("GuiService").ReducedMotionEnabled),"Only affordable BUY pulses")end
 end
end
return {assertions=count,states=found}

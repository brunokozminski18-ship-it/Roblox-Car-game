-- Studio QA profile only. Walks normally; taps carry only synchronized time.
assert(game:GetService("RunService"):IsStudio())
local p=game.Players.LocalPlayer
local remote=game.ReplicatedStorage.ThrowTickets.Remotes.Throw
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local log={Device="phone landscape",Events={}}
local function record(name,values)table.insert(log.Events,{Name=name,Values=values});p:SetAttribute("QAIteration8",game.HttpService:JSONEncode(log))end
local function waitFor(predicate,seconds)
 local deadline=os.clock()+seconds
 repeat if predicate()then return end;task.wait(.015)until os.clock()>deadline
 error("Timeout after "..seconds)
end
task.spawn(function()
 local ok,err=pcall(function()
  waitFor(function()return not p:GetAttribute("Throwing")end,15)
  local plot=workspace.TicketPrototype.Parking[tostring(p.UserId)]
  p.Character.Humanoid:MoveTo(plot.TrainingPad.Position)
  waitFor(function()return p:GetAttribute("TrainingActive")end,8)
  local before=p:GetAttribute("ThrowPower");task.wait(1.3)
  assert(p:GetAttribute("ThrowPower")>before,"Training immediately works at plot")
  record("Training on plot",{Before=before,After=p:GetAttribute("ThrowPower"),Location=p:GetAttribute("Location")})
  for _,target in {{"green",.5},{"red",.99},{"timeout",nil}}do
   p.Character.Humanoid:MoveTo(Vector3.new(0,0,0))
   waitFor(function()return p:GetAttribute("MeterStart")~=nil end,12)
   local start=p:GetAttribute("MeterStart");local power=p:GetAttribute("ThrowPower");local throws=p:GetAttribute("Throws")or 0
   if target[2]then
    remote:FireServer(0/0);task.wait(.14);remote:FireServer(start-1);task.wait(.14);remote:FireServer(workspace:GetServerTimeNow()+100)
    waitFor(function()return workspace:GetServerTimeNow()-start>=Config.ThrowMeter.Period*target[2]end,2)
    local tap=workspace:GetServerTimeNow();remote:FireServer(tap)
    for _=1,40 do remote:FireServer(tap)end
   end
   waitFor(function()return(p:GetAttribute("Throws")or 0)>throws end,15)
   local bonus=p:GetAttribute("LastThrowBonus");local distance=p:GetAttribute("LastDistance")
   assert(p:GetAttribute("Throws")==throws+1,"Only one throw accepted")
   assert(math.abs(distance/power-1-bonus)<1e-5,"Server distance uses bounded bonus")
   if target[1]=="green"then assert(bonus>.09,"Green near +10%")
   elseif target[1]=="red"then assert(bonus<-.03,"Red near -5%")
   else assert(math.abs(bonus-.025)<1e-6,"Timeout uses midpoint")end
   record(target[1],{Bonus=bonus,Distance=distance,Power=power,Throws=p:GetAttribute("Throws"),Spam=target[2]~=nil})
   waitFor(function()return not p:GetAttribute("Throwing")end,15)
   task.wait(.4);assert(p:GetAttribute("Throws")==throws+1,"No extra queued throw")
  end
  log.Complete=true
 end)
 if not ok then log.Error=tostring(err)end
 p:SetAttribute("QAIteration8",game.HttpService:JSONEncode(log))
end)
return "Iteration 8 timed integration running"

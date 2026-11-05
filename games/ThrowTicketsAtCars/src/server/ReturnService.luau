--!strict
local R=require(game.ReplicatedStorage.ThrowTickets.ReturnRules)
local Rules=require(game.ReplicatedStorage.ThrowTickets.Rules)
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local Clock=require(script.Parent.ReturnClock)
local Service={}
function Service.new(ctx: any): any
 local api={};local rng=Random.new()
 function api.update(p: Player,s: any)
  local r=s.data.Returns;local now=Clock.now()
  p:SetAttribute("OfflineCash",r.PendingCash);p:SetAttribute("OfflineAway",r.AwaySeconds)
  p:SetAttribute("FreeCarAt",r.FreeAt);p:SetAttribute("ReturnServerNow",now)
  p:SetAttribute("FreeCarReady",R.freeReady(s.data,now));p:SetAttribute("ReturnBusy",s.rewardBusy==true)
  p:SetAttribute("FreeCarBiome",Rules.biome(Rules.distance(s.data.Power)))
 end
 function api.arrive(p: Player,s: any): boolean
  R.arrive(s.data,Clock.now());ctx.profiles:touch(s.profile)
  local status=ctx.save(p,s,false)
  return status=="saved"and s.profile.Status=="active"and p.Parent~=nil
 end
 function api.claim(p: Player,s: any,action: any)
  if not ctx.mutable(s)or s.job or s.meter or (action~="Offline"and action~="FreeCar")then return end
  local now=os.clock();if now-(s.lastReturn or -math.huge)<.5 then return end;s.lastReturn=now
  -- Acquire before any yield. All other gameplay mutations and release respect this lock.
  s.rewardBusy=true;api.update(p,s)
  while s.profile.Saving do task.wait(.05)end
  if s.profile.Status~="active"then s.rewardBusy=false;return end
  local accepted=false;local message="Nothing to claim!"
  if action=="Offline"then
   local paid=R.claimOffline(s.data);accepted=paid>0
   message=if accepted then "Claimed $"..paid.." offline earnings!"else "Nothing to claim!"
  else
   local biome=Rules.biome(Rules.distance(s.data.Power))
   accepted,message=R.claimFree(s.data,Clock.now(),Rules.rollCar(biome,s.data.Equipped,rng),game.HttpService:GenerateGUID(false))
  end
  if accepted then
   ctx.profiles:touch(s.profile)
   local status=ctx.save(p,s,false)
   if status~="saved"then
    -- Do not roll back an ambiguously committed reward or expose spendable cash.
    -- Release retries the same complete state. Next join sees either both fields or neither.
    s.rewardFailed=true;s.rewardBusy=false
    p:SetAttribute("DataReady",false);p:Kick("Reward could not be saved safely. Please rejoin.");return
   end
  end
  s.rewardBusy=false
  if accepted then ctx.publish(p,s)else api.update(p,s)end
  ctx.result(p,message)
 end
 function api.tick(p: Player,s: any,seconds: number)
  s.data.Returns.PlaySeconds+=seconds
  api.update(p,s)
  if R.likeDue(s.data,s.job~=nil or s.meter~=nil or s.modal==true)then
   R.markLike(s.data);ctx.profiles:touch(s.profile)
   ctx.social:FireClient(p,"Like")
  end
 end
 return api
end
return Service

--!strict
-- LihFolk Vault V2 (CC BY 4.0): Offline Earnings, Retention and Return Hooks.
local Config=require(script.Parent.Config)
local Garage=require(script.Parent.GarageRules)
local Rules=require(script.Parent.Rules)
local J=require(script.Parent.JuiceRules)
local R={}
function R.default(): any
 return {Tutorial=false,LastSeen=0,OfflineRate=0,PendingCash=0,PendingSeconds=0,AwaySeconds=0,FreeAt=0,PlaySeconds=0,LastLike=0,BestOdds=0}
end
function R.migrate(data: any): any
 local r=R.default()
 r.Tutorial=#data.Cars>0 or next(data.Discovered)~=nil
 for _,c in data.Cars do r.BestOdds=math.max(r.BestOdds,math.floor(J.odds(Rules.savedReward(c),c.Ticket)))end
 return r
end
function R.validate(r: any): boolean
 if typeof(r)~="table"or typeof(r.Tutorial)~="boolean"then return false end
 for _,k in {"LastSeen","OfflineRate","PendingCash","PendingSeconds","AwaySeconds","FreeAt","PlaySeconds","LastLike","BestOdds"}do
  if not Rules.finiteNumber(r[k])or r[k]<0 or r[k]%1~=0 or r[k]>(if k=="PendingSeconds"then Config.Returns.OfflineCapSeconds else Config.MaxCash)then return false end
 end
 return r.LastLike<=r.PlaySeconds
end
function R.arrive(data: any,now: number)
 local r=data.Returns
 if r.FreeAt==0 then r.FreeAt=now+Config.Returns.FreeCarSeconds end
 if r.LastSeen>0 then
  local away=math.max(0,now-r.LastSeen)
  if r.Tutorial and away>=Config.Returns.OfflineMinSeconds and r.OfflineRate>0 then
   local seconds=math.min(away,math.max(0,Config.Returns.OfflineCapSeconds-r.PendingSeconds))
   r.PendingCash=math.min(Config.MaxCash,r.PendingCash+math.floor(seconds*r.OfflineRate*Config.Returns.OfflineFraction))
   r.PendingSeconds+=seconds
   if seconds>0 then r.AwaySeconds=away end
  end
 end
 r.LastSeen=0 -- consumed before ready; persisted with pending, never re-accrued
end
function R.depart(data: any,now: number)
 data.Returns.LastSeen=now;data.Returns.OfflineRate=Garage.income(data)
end
function R.claimOffline(data: any): number
 local r=data.Returns;local amount=math.min(r.PendingCash,Config.MaxCash-data.Cash)
 if r.PendingCash<=0 or amount<=0 then return 0 end
 data.Cash+=amount;r.PendingCash=0;r.PendingSeconds=0;r.AwaySeconds=0
 return amount
end
function R.freeReady(data: any,now: number): boolean return data.Returns.FreeAt>0 and now>=data.Returns.FreeAt end
function R.claimFree(data: any,now: number,reward: any,id: string): (boolean,string)
 if not R.freeReady(data,now)then return false,"Free car is not ready yet!"end
 if Garage.inventoryCount(data)>=Config.InventoryLimit then return false,"Backpack full! Sell or park a car first."end
 local ok,message=Garage.add(data,reward,id,false)
 if not ok then return false,message end
 data.Returns.FreeAt=now+Config.Returns.FreeCarSeconds
 return true,"Free car claimed! "..reward.Name
end
function R.likeDue(data: any,busy: boolean): boolean
 return not busy and data.Returns.PlaySeconds-data.Returns.LastLike>=Config.Returns.LikeSeconds
end
function R.markLike(data: any)data.Returns.LastLike=data.Returns.PlaySeconds end
function R.scores(data: any): any
 return {MostCars=#data.Cars,TopMoney=data.Cash,LuckiestCatch=data.Returns.BestOdds}
end
return R

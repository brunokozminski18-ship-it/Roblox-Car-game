return function(Service,Schema)
 local n=0;local function check(ok,msg)assert(ok,msg);n+=1 end
 local s={data=Schema.default(),profile={Status="active"}}
 s.data.Cash=10;s.data.Returns.PendingCash=240;s.data.Returns.PendingSeconds=60
 local p={attributes={},SetAttribute=function(self,k,v)self.attributes[k]=v end,Kick=function(self,msg)self.kicked=msg end}
 local saves,published=0,0;local disk;local fail=false;local api
 local function mutable(state)return state and state.profile.Status=="active"and not state.rewardBusy and not state.rewardFailed end
 api=Service.new({mutable=mutable,profiles={touch=function()end},
  save=function()
   saves+=1;check(not mutable(s),"Other gameplay locked while reward save yields")
   api.claim(p,s,"Offline") -- reentrant double click during save
   disk=Schema.copy(s.data)
   check(disk.Cash==250 and disk.Returns.PendingCash==0,"Cash and consumed bank saved together")
   return if fail then "error"else "saved"
  end,
  publish=function()published+=1 end,result=function()end,social={FireClient=function()end}})
 api.claim(p,s,"Offline")
 check(saves==1 and published==1 and s.data.Cash==250,"Exactly one confirmed payout")
 s.lastReturn=-math.huge;api.claim(p,s,"Offline")
 check(saves==1 and s.data.Cash==250,"Repeated CLAIM after throttle window pays nothing")
 local restored=Schema.prepare({Schema=6,Data=disk})
 check(restored and restored.Cash==250 and restored.Returns.PendingCash==0,"Reconnect after confirmed claim")
 s.data=Schema.default();s.data.Cash=10;s.data.Returns.PendingCash=240;s.data.Returns.PendingSeconds=60;s.lastReturn=-math.huge;fail=true
 api.claim(p,s,"Offline")
 check(p.kicked~=nil and s.rewardFailed and not mutable(s),"Unknown save acknowledgement freezes gameplay and reconnects")
 check(published==1 and s.data.Cash==250 and s.data.Returns.PendingCash==0,"No rollback or exposed reward on unknown commit")
 s.lastReturn=-math.huge;api.claim(p,s,"Offline");check(saves==2,"Failed session cannot retry or spend")
 restored=Schema.prepare({Schema=6,Data=disk})
 check(restored.Cash==250 and restored.Returns.PendingCash==0,"Committed but unacknowledged claim cannot duplicate on reconnect")
 local departed={Parent=true};local initializing={data=Schema.default(),profile={Status="active"}}
 local arrival=Service.new({profiles={touch=function()end},save=function()
  initializing.profile.Status="released";departed.Parent=nil;return "saved"
 end})
 check(not arrival.arrive(departed,initializing),"Leaving during yielding arrival save cancels initialization")
 return n.." claim transaction assertions passed"
end

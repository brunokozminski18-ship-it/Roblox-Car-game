return function(Profiles,Schema)
	local n=0;local function check(ok,msg)assert(ok,msg);n+=1 end
	local db={};local writes=0;local fail=false;local unknown=false;local cancel=false
	local store={UpdateAsync=function(_,key,transform)
		if fail then error("503: simulated unavailable")end
		local nextValue=transform(Schema.copy(db[key]),nil)
		if nextValue then db[key]=Schema.copy(nextValue);writes+=1 end
		if key=="cancel"then cancel=true end
		if unknown then unknown=false;error("503: simulated lost acknowledgement")end
		return Schema.copy(db[key])
	end}
	local api=Profiles.new(store,{Attempts=2,Wait=function()end})
	local p,status=api:load("fresh",1)
	check(p and status=="ready"and p.Data.Cash==0,"Confirmed new player")
	local other,locked=api:load("fresh",1)
	check(not other and locked=="locked","Live lease excludes second writer")
	p.Data.Cash=777;p.Data.Power=50;api:touch(p)
	check(api:save(p,true)=="saved"and db.fresh.Session==nil,"Release saves complete state")
	local restored=api:load("fresh",1)
	check(restored and restored.Data.Cash==777 and restored.Data.Power==50,"Reload exact progress")
	local before=writes;fail=true
	local bad,reason=api:load("failure",2)
	check(not bad and reason=="failed"and writes==before and db.failure==nil,"Failed load never saves defaults")
	fail=false
	db.fresh.Session.Token="new-owner"
	check(api:save(restored,false)=="lost"and restored.Status=="lost","Fence stale writer")
	db.future={Schema=99,Data={}};before=writes
	check(api:load("future",3)==nil and writes==before,"Future schema untouched")
	local a=api:load("unknown",4);a.Data.Cash=12;api:touch(a);unknown=true
	check(api:save(a,true)=="saved"and db.unknown.Data.Cash==12 and db.unknown.Session==nil,"Unknown release acknowledgement is idempotent")
	local cancelled,why=api:load("cancel",5,function()return cancel end)
	check(not cancelled and why=="left"and db.cancel.Session==nil,"Shutdown during load releases claimed lease")
	return n.." profile safety assertions passed"
end

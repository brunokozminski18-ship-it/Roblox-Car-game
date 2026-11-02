--!strict
-- Based on LihFolk Vault V2 (CC BY 4.0): Session Locking and Saving Correctly.
-- The ONLY DataStore writer. Injectable store for fault and lease tests.
local Http=game:GetService("HttpService")
local Config=require(game.ReplicatedStorage.ThrowTickets.Config)
local Schema=require(script.Parent.ProfileSchema)
local Profiles={};Profiles.__index=Profiles
local function permanent(err: any): boolean
	local s=tostring(err):lower()
	return s:find("studio access",1,true)~=nil or s:find("not allowed",1,true)~=nil or s:find("403",1,true)~=nil or s:find("cannot store",1,true)~=nil
end
function Profiles.new(store: any,options: any?): any
	return setmetatable({store=store,options=options or {}},Profiles)
end
function Profiles:pause(attempt: number)
	local delay=math.min(0.5*2^(attempt-1),4)*(0.75+math.random()*0.5)
	if self.options.Wait then self.options.Wait(delay)else task.wait(delay)end
end
function Profiles:load(key: string,userId: number,cancel: (() -> boolean)?): (any,string)
	local token=Http:GenerateGUID(false);local last="failed"
	for attempt=1,self.options.Attempts or Config.Data.Attempts do
		if cancel and cancel()then return nil,"left"end
		local data=nil;local outcome="failed"
		local ok,err=pcall(function()
			self.store:UpdateAsync(key,function(old,keyInfo)
				data=nil;outcome="failed"
				if old and typeof(old)~="table"then return nil end
				local session=old and old.Session
				if session and (typeof(session)~="table"or typeof(session.ExpiresAt)~="number"or typeof(session.Token)~="string")then return nil end
				if session and session.Token~=token and session.ExpiresAt>os.time()then outcome="locked";return nil end
				data=Schema.prepare(old);if not data then outcome="corrupt";return nil end
				outcome="ready"
				return {Schema=Config.Data.Schema,Data=data,Session={Token=token,JobId=game.JobId,ExpiresAt=os.time()+Config.Data.LeaseSeconds}}, {userId}, if keyInfo then keyInfo:GetMetadata()else nil
			end)
		end)
		if ok and outcome=="ready"then
			local p={Key=key,UserId=userId,Token=token,Data=data,Status="active",Saving=false,Revision=0,Dirty=false,LastSave=os.clock(),NextSave=os.clock()+Config.Data.AutosaveSeconds*(0.75+math.random()*0.25)}
			if cancel and cancel()then self:save(p,true);return nil,"left"end
			return p,"ready"
		end
		last=if ok then outcome else "failed"
		if last=="corrupt"or(not ok and permanent(err))then break end
		if attempt<(self.options.Attempts or Config.Data.Attempts)then self:pause(attempt)end
	end
	return nil,last
end
function Profiles:touch(p: any)
	if p.Status=="active"then p.Revision+=1;p.Dirty=true end
end
function Profiles:save(p: any,release: boolean): string
	if not p or (p.Status~="active"and p.Status~="closing")then return "lost"end
	while p.Saving do task.wait(.05)end
	if p.Status~="active"and p.Status~="closing"then return "lost"end
	p.Saving=true
	local snapshot,invalid=Schema.prepare({Schema=Config.Data.Schema,Data=p.Data})
	if not snapshot then p.Saving=false;warn("[Profiles] Refused invalid snapshot: "..tostring(invalid));return "error"end
	assert(#Http:JSONEncode(snapshot)<100000,"Profile size exceeded")
	local revision=p.Revision;local writeId=Http:GenerateGUID(false);local result="error"
	for attempt=1,self.options.Attempts or Config.Data.Attempts do
		local outcome="error"
		local ok,err=pcall(function()
			self.store:UpdateAsync(p.Key,function(old,keyInfo)
				outcome="error"
				-- A failed acknowledgement may follow a successful final release.
				if typeof(old)=="table"and old.LastWrite==writeId then outcome="saved";return nil end
				if typeof(old)~="table"or typeof(old.Session)~="table"or old.Session.Token~=p.Token then outcome="lost";return nil end
				outcome="saved"
				return {Schema=Config.Data.Schema,Data=snapshot,LastWrite=writeId,SavedAt=os.time(),Session=if release then nil else {Token=p.Token,JobId=game.JobId,ExpiresAt=os.time()+Config.Data.LeaseSeconds}}, {p.UserId}, if keyInfo then keyInfo:GetMetadata()else nil
			end)
		end)
		if ok then result=outcome;if result~="error"then break end elseif permanent(err)then break end
		if attempt<(self.options.Attempts or Config.Data.Attempts)then self:pause(attempt)end
	end
	p.Saving=false
	if result=="lost"then p.Status="lost"
	elseif result=="saved"then
		p.Dirty=p.Revision~=revision;p.LastSave=os.clock();p.NextSave=os.clock()+Config.Data.AutosaveSeconds*(0.9+math.random()*0.1)
		if release then p.Status="released"end
	end
	return result
end
return Profiles

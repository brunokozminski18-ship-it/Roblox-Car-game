--!strict
-- Gameplay clock only. Session leases always use real wall time in Profiles.
local Clock={}
function Clock.now(): number
 local ss=game:GetService("ServerStorage")
 local offset=0
 if game:GetService("RunService"):IsStudio()and typeof(ss:GetAttribute("TestProfileKey"))=="string"then
  local value=ss:GetAttribute("ReturnQAOffset")
  if typeof(value)=="number"and value==value and math.abs(value)<=86400*500 then offset=value end
 end
 return math.floor(workspace:GetServerTimeNow()+offset)
end
return Clock

--!strict
-- Template addition (not part of LihFolk): an in-memory stand-in for a
-- DataStore, used ONLY in Studio when ServerStorage attribute UseMemoryStore
-- is true (for places without "Enable Studio Access to API Services").
-- Every write goes through a JSON round trip, so data a real DataStore would
-- refuse (NaN, Instances, mixed arrays) still fails here. Data lives only for
-- one Play session: save/rejoin across sessions needs the real DataStore.

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

assert(RunService:IsStudio(), "StudioMemoryStore is Studio-only")

local StudioMemoryStore = {}
StudioMemoryStore.__index = StudioMemoryStore

local data: { [string]: string } = {}

function StudioMemoryStore.new()
	return setmetatable({}, StudioMemoryStore)
end

local function decode(raw: string?): any
	return if raw then HttpService:JSONDecode(raw) else nil
end

function StudioMemoryStore.UpdateAsync(_self: any, key: string, transform: (any, any) -> (any, any, any)): any
	task.wait() -- real UpdateAsync always yields; keep callers honest
	local result = transform(decode(data[key]), nil)
	if result == nil then
		return nil -- cancelled by the transform
	end
	data[key] = HttpService:JSONEncode(result)
	return decode(data[key])
end

function StudioMemoryStore.GetAsync(_self: any, key: string): any
	task.wait()
	return decode(data[key])
end

return StudioMemoryStore

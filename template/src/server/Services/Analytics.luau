--!strict
--[[
	Template service: first-minutes analytics (LihFolk "Analytics and Funnels",
	"Measuring Onboarding"). Everything is set in Config.Analytics, so a new game
	only adds its own onboarding steps and window names.

	  onboarding  ordered steps; each names a trigger. Steps are logged forward
	              only (a skipped step is fine, going back is ignored), once per
	              player lifetime (saved in the profile).
	  triggers    "Joined", "Window:<name>", "Claim:<kind>", "CurrencyPurchase",
	              "Rebirth", or any string a game passes to Analytics.Trigger.
	  custom      WindowOpened (field: window), FirstClaim (kind),
	              FirstCurrencyPurchase (currency), Rebirth; counts are batched.
	  economy     every Cash/Gems change as Source/Sink with its reason.

	Server only. Roblox ignores events from Studio, so in Studio (debugInStudio)
	each event is printed to Output instead, for checking in Play.
	Client remote: Analytics.WindowOpened(windowName) - only names in
	Config.Analytics.windows, rate limited.
]]

local AnalyticsService = game:GetService("AnalyticsService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

assert(RunService:IsServer(), "Analytics is server-only")

local LihFolk = ServerScriptService:WaitForChild("Server"):WaitForChild("LihFolk")
local PlayerData = require(LihFolk.PlayerData)
local Currency = require(LihFolk.Currency)
local Net = require(ReplicatedStorage:WaitForChild("LihFolk"):WaitForChild("Net"))

type Step = { trigger: string, name: string }
export type Config = { debugInStudio: boolean?, windows: { string }, onboarding: { Step }, flushSeconds: number? }

local Analytics = {}
-- Fired for every trigger, before the funnel check: (player, trigger).
-- Hints and other first-minute systems listen to it.
Analytics.Triggered = require(ReplicatedStorage:WaitForChild("LihFolk"):WaitForChild("Signal")).new()

local IS_STUDIO = RunService:IsStudio()
local FIELD_KEYS = {
	Enum.AnalyticsCustomFieldKeys.CustomField01.Name,
	Enum.AnalyticsCustomFieldKeys.CustomField02.Name,
	Enum.AnalyticsCustomFieldKeys.CustomField03.Name,
}

local debugPrint = false
local steps: { Step } = {}
local stepByTrigger: { [string]: number } = {}
local windowSet: { [string]: boolean } = {}
local pending: { [Player]: { [string]: { name: string, value: number, fields: { string }? } } } = {}

local function toFields(values: { string }?): { [string]: string }?
	if not values then
		return nil
	end
	local out = {}
	for i = 1, math.min(#values, 3) do
		out[FIELD_KEYS[i]] = tostring(values[i])
	end
	return out
end

-- Analytics must never break gameplay: every call is protected.
local function send(label: string, fn: () -> ())
	if IS_STUDIO then
		if debugPrint then
			print(`[Analytics] {label}`)
		end
		return -- Studio events never reach the dashboard
	end
	local ok, err = pcall(fn)
	if not ok then
		warn("[Analytics]", err)
	end
end

-- Returns true the first time `key` happens for this player (saved).
local function first(player: Player, key: string): boolean
	local profile = PlayerData.Get(player)
	if not profile then
		return false
	end
	local seen = profile.Data.Analytics.Firsts
	if seen[key] then
		return false
	end
	seen[key] = true
	PlayerData.MarkDirty(profile)
	return true
end

---------------------------------------------------------------------------
-- Public API
---------------------------------------------------------------------------

-- Onboarding: advances the funnel if `trigger` is the next configured step
-- (or a later one). Games call this for their own steps.
function Analytics.Trigger(player: Player, trigger: string)
	Analytics.Triggered:Fire(player, trigger)
	local index = stepByTrigger[trigger]
	local profile = PlayerData.Get(player)
	if not index or not profile then
		return
	end
	local state = profile.Data.Analytics
	if index <= state.Onboarding then
		return
	end
	state.Onboarding = index
	PlayerData.MarkDirty(profile)
	local name = steps[index].name
	send(`onboarding {index} "{name}"`, function()
		AnalyticsService:LogOnboardingFunnelStepEvent(player, index, name)
	end)
end

-- Batched custom event (one name, up to three fixed-set fields).
function Analytics.Count(player: Player, eventName: string, amount: number?, fields: { string }?)
	local byKey = pending[player]
	if not byKey then
		byKey = {}
		pending[player] = byKey
	end
	local key = eventName .. "|" .. table.concat(fields or {}, "|")
	local entry = byKey[key]
	if entry then
		entry.value += amount or 1
	else
		byKey[key] = { name = eventName, value = amount or 1, fields = fields }
	end
end

local function flush(player: Player)
	local byKey = pending[player]
	pending[player] = nil
	if not byKey then
		return
	end
	for _, entry in byKey do
		send(`custom {entry.name} x{entry.value} {table.concat(entry.fields or {}, ",")}`, function()
			AnalyticsService:LogCustomEvent(player, entry.name, entry.value, toFields(entry.fields))
		end)
	end
end

function Analytics.Claim(player: Player, kind: string, _info: any?)
	Analytics.Trigger(player, `Claim:{kind}`)
	if first(player, "Claim") then
		Analytics.Count(player, "FirstClaim", 1, { kind })
	end
end

function Analytics.CurrencyPurchase(player: Player, currency: string, _amount: number, _reason: string)
	Analytics.Trigger(player, "CurrencyPurchase")
	if first(player, "CurrencyPurchase") then
		Analytics.Count(player, "FirstCurrencyPurchase", 1, { currency })
	end
end

function Analytics.Rebirth(player: Player)
	Analytics.Trigger(player, "Rebirth")
	Analytics.Count(player, "Rebirth", 1)
end

function Analytics.WindowOpened(player: Player, window: string)
	Analytics.Trigger(player, `Window:{window}`)
	Analytics.Count(player, "WindowOpened", 1, { window })
end

---------------------------------------------------------------------------
-- Init
---------------------------------------------------------------------------

function Analytics.Init(config: Config)
	debugPrint = config.debugInStudio == true
	for i, step in config.onboarding do
		assert(type(step.trigger) == "string" and type(step.name) == "string", `Analytics onboarding {i}: trigger and name required`)
		assert(stepByTrigger[step.trigger] == nil, `Analytics: trigger {step.trigger} used twice`)
		stepByTrigger[step.trigger] = i
		steps[i] = step
	end
	for _, name in config.windows do
		windowSet[name] = true
	end

	PlayerData.RegisterSlice("Analytics", function()
		return { Onboarding = 0, Firsts = {} }
	end)

	Net.Listen("Analytics.WindowOpened", {
		rate = { burst = 5, perSecond = 1 },
		args = { Net.T.key(windowSet) },
		handler = Analytics.WindowOpened,
	})

	PlayerData.Loaded:Connect(function(player: Player)
		Analytics.Trigger(player, "Joined")
	end)

	-- Economy: every balance change except loading, with its reason as type.
	Currency.Changed:Connect(function(player: Player, name: string, balance: number, delta: number, reason: string)
		if delta == 0 or reason == "load" then
			return
		end
		local kind = string.match(reason, "^[%a]+") or "other" -- "shop:Item1" -> "shop" (fixed set)
		if kind == "quest" or kind == "index" then
			Analytics.Claim(player, if kind == "quest" then "Task" else "Index")
		end
		if kind == "income" or kind == "step" then
			return -- per-second income / per-step Power would flood the economy dashboard; batch it
		end
		local flow = if delta > 0 then Enum.AnalyticsEconomyFlowType.Source else Enum.AnalyticsEconomyFlowType.Sink
		send(`economy {if delta > 0 then "source" else "sink"} {name} {math.abs(delta)} ({kind})`, function()
			AnalyticsService:LogEconomyEvent(player, flow, name, math.abs(delta), balance, kind, reason)
		end)
	end)

	-- Flush batched counts every flushSeconds and when a player leaves.
	local every = config.flushSeconds or 60
	task.spawn(function()
		while true do
			task.wait(every)
			for player in pending do
				flush(player)
			end
		end
	end)
	Players.PlayerRemoving:Connect(flush)
end

return Analytics

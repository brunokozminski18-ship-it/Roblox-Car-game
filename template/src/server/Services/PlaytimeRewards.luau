--!strict
-- Template: deterministic gifts for time connected to THIS server session.
-- Reset on every join; a saved Claimed map is deliberately replaced on load.
-- Client sends only a configured gift id, never elapsed time or a reward.
-- Remotes: PlaytimeRewards.Get(), PlaytimeRewards.Claim(id) -> snapshot.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local LihFolk = ServerScriptService:WaitForChild("Server"):WaitForChild("LihFolk")
local PlayerData = require(LihFolk.PlayerData)
local Rewards = require(LihFolk.Rewards)
local Net = require(ReplicatedStorage:WaitForChild("LihFolk"):WaitForChild("Net"))

export type Gift = {
	id: string,
	minutes: number,
	label: string,
	art: string,
	reward: Rewards.Reward,
	featured: boolean?,
}
export type Config = { reset: string?, track: { Gift } }
type Session = { profile: PlayerData.Profile, startedAt: number }

local PlaytimeRewards = {}
local gifts: { [string]: Gift } = {}
local joinedAt: { [Player]: number } = {}
local sessions: { [Player]: Session } = {}
local initialized = false

local function sessionFor(player: Player, profile: PlayerData.Profile): Session
	local current = sessions[player]
	if current and current.profile == profile then
		return current
	end
	-- This runs both from Loaded and lazily from a remote, so a request racing
	-- the Loaded signal cannot restore yesterday's claims or reset a new claim.
	local fresh = { profile = profile, startedAt = joinedAt[player] or os.clock() }
	profile.Data.PlaytimeRewards = { Claimed = {} }
	PlayerData.MarkDirty(profile)
	sessions[player] = fresh
	return fresh
end

local function snapshot(player: Player, profile: PlayerData.Profile): { [string]: any }
	local session = sessionFor(player, profile)
	return {
		elapsed = math.max(0, os.clock() - session.startedAt),
		claimed = table.clone(profile.Data.PlaytimeRewards.Claimed),
		reset = "session",
	}
end

local function claim(player: Player, id: string): Net.Result
	local profile = PlayerData.Get(player)
	if not profile then
		return Net.fail("NotReady")
	end
	local gift = gifts[id]
	-- The network validator checks known ids; keep the service guarded too.
	if not gift then
		return Net.fail("Invalid")
	end
	local session = sessionFor(player, profile)
	local claimed = profile.Data.PlaytimeRewards.Claimed
	if claimed[id] == true then
		return Net.fail("AlreadyClaimed", snapshot(player, profile))
	end
	if os.clock() - session.startedAt < gift.minutes * 60 then
		return Net.fail("NotEligible", snapshot(player, profile))
	end
	local fits, code = Rewards.CanGrant(player, gift.reward)
	if not fits then
		return Net.fail(code or "BagFull", snapshot(player, profile))
	end
	-- All existing Rewards grants are synchronous. No yield between these
	-- checks, the grant and the claim marker; duplicate requests grant once.
	if not Rewards.Grant(player, gift.reward, `playtime:{id}`, false, false) then
		return Net.fail("Error", snapshot(player, profile))
	end
	claimed[id] = true
	PlayerData.MarkDirty(profile)
	return Net.ok(snapshot(player, profile))
end

function PlaytimeRewards.Init(config: Config)
	assert(not initialized, "PlaytimeRewards.Init called twice")
	assert(config.reset == nil or config.reset == "session", "PlaytimeRewards: only session reset is implemented")
	assert(type(config.track) == "table" and #config.track > 0, "PlaytimeRewards: nonempty track required")
	local previousMinutes = 0
	for _, gift in config.track do
		assert(type(gift.id) == "string" and #gift.id <= 64 and string.match(gift.id, "^[%w_]+$") and not gifts[gift.id], "PlaytimeRewards: bad or duplicate id")
		assert(type(gift.minutes) == "number" and gift.minutes == gift.minutes and gift.minutes > previousMinutes and gift.minutes < math.huge, `PlaytimeRewards {gift.id}: increasing finite minutes required`)
		assert(type(gift.label) == "string" and gift.label ~= "", `PlaytimeRewards {gift.id}: label required`)
		assert(type(gift.art) == "string" and gift.art ~= "", `PlaytimeRewards {gift.id}: art key required`)
		Rewards.Validate(`PlaytimeRewards {gift.id}`, gift.reward)
		gifts[gift.id] = gift
		previousMinutes = gift.minutes
	end
	initialized = true

	PlayerData.RegisterSlice("PlaytimeRewards", function()
		return { Claimed = {} }
	end)
	Players.PlayerAdded:Connect(function(player: Player)
		joinedAt[player] = os.clock()
	end)
	for _, player in Players:GetPlayers() do
		joinedAt[player] = os.clock()
	end
	PlayerData.Loaded:Connect(function(player: Player, profile: PlayerData.Profile)
		sessionFor(player, profile)
	end)
	Players.PlayerRemoving:Connect(function(player: Player)
		joinedAt[player] = nil
		sessions[player] = nil
	end)

	Net.Handle("PlaytimeRewards.Get", {
		rate = { burst = 4, perSecond = 1 },
		args = {},
		handler = function(player: Player): Net.Result
			local profile = PlayerData.Get(player)
			return if profile then Net.ok(snapshot(player, profile)) else Net.fail("NotReady")
		end,
	})
	Net.Handle("PlaytimeRewards.Claim", {
		rate = { burst = 4, perSecond = 1 },
		args = { Net.T.key(gifts) },
		handler = claim,
	})
end

return PlaytimeRewards

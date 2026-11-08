--!strict
-- Template service: placeholder income until a game has its own activity.
-- Every second each loaded player earns Config.Income.perSecond Cash through
-- Currency.Earn (multipliers such as Rebirth apply). perSecond = 0 turns it off.

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local LihFolk = ServerScriptService:WaitForChild("Server"):WaitForChild("LihFolk")
local PlayerData = require(LihFolk.PlayerData)
local Currency = require(LihFolk.Currency)

local Income = {}

function Income.Init(config: { perSecond: number }, currency: string)
	assert(config.perSecond >= 0, "Income: perSecond >= 0")
	assert(Currency.Exists(currency), `Income: unknown currency {currency}`)
	if config.perSecond == 0 then
		return
	end
	task.spawn(function()
		while true do
			task.wait(1)
			for _, player in Players:GetPlayers() do
				if PlayerData.Get(player) then
					Currency.Earn(player, currency, config.perSecond, "income")
				end
			end
		end
	end)
end

return Income

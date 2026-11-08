--!strict
-- Template service: buy inventory slots with soft currency (Config.Slots).
-- Capacity = Config.Inventory.uniqueCapacity + bought extra slots.
-- Remote: Slots.Buy() -> { capacity }   (checks: ready, max, price, balance)

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LihFolk = ServerScriptService:WaitForChild("Server"):WaitForChild("LihFolk")
local PlayerData = require(LihFolk.PlayerData)
local Currency = require(LihFolk.Currency)
local Inventory = require(LihFolk.Inventory)
local Net = require(ReplicatedStorage:WaitForChild("LihFolk"):WaitForChild("Net"))

export type Config = { step: number, price: { currency: string, amount: number }, maxExtra: number }

local Slots = {}

function Slots.Init(config: Config, baseCapacity: number)
	assert(config.step >= 1 and config.maxExtra >= config.step, "Slots: step >= 1, maxExtra >= step")
	assert(Currency.Exists(config.price.currency) and config.price.amount >= 1, "Slots: bad price")

	PlayerData.RegisterSlice("Slots", function()
		return { Extra = 0 }
	end)
	Inventory.SetCapacityProvider(function(_player: Player, profile: PlayerData.Profile): number
		return baseCapacity + profile.Data.Slots.Extra
	end)

	Net.Handle("Slots.Buy", {
		rate = { burst = 3, perSecond = 1 },
		args = {},
		handler = function(player: Player): Net.Result
			local profile = PlayerData.Get(player)
			if not profile then
				return Net.fail("NotReady")
			end
			local state = profile.Data.Slots
			if state.Extra + config.step > config.maxExtra then
				return Net.fail("MaxReached")
			end
			-- Spend and add in one synchronous block.
			if not Currency.Spend(player, config.price.currency, config.price.amount, "slots") then
				return Net.fail("NotEnough")
			end
			state.Extra += config.step
			PlayerData.MarkDirty(profile)
			return Net.ok({ capacity = baseCapacity + state.Extra })
		end,
	})
end

return Slots

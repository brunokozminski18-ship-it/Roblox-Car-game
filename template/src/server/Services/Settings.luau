--!strict
-- Template service: saved player settings (Config.Settings.defaults).
-- Only known keys, only booleans. Remotes: Settings.Get(), Settings.Save(table)

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LihFolk = ServerScriptService:WaitForChild("Server"):WaitForChild("LihFolk")
local PlayerData = require(LihFolk.PlayerData)
local Net = require(ReplicatedStorage:WaitForChild("LihFolk"):WaitForChild("Net"))

export type Config = { defaults: { [string]: boolean } }

local Settings = {}

function Settings.Init(config: Config)
	local defaults = config.defaults
	local keyCount = 0
	for key, value in defaults do
		assert(type(key) == "string" and type(value) == "boolean", "Settings: defaults are key = boolean")
		keyCount += 1
	end

	-- A settings table: at most keyCount entries, known keys, boolean values.
	local function validSettings(value: any): boolean
		if type(value) ~= "table" then
			return false
		end
		local n = 0
		for key, v in value do
			n += 1
			if n > keyCount or type(key) ~= "string" or defaults[key] == nil or type(v) ~= "boolean" then
				return false
			end
		end
		return true
	end

	PlayerData.RegisterSlice("Settings", function()
		return table.clone(defaults)
	end)
	Net.Handle("Settings.Get", {
		rate = { burst = 3, perSecond = 1 },
		args = {},
		handler = function(player: Player): Net.Result
			local profile = PlayerData.Get(player)
			return if profile then Net.ok(profile.Data.Settings) else Net.fail("NotReady")
		end,
	})
	Net.Handle("Settings.Save", {
		rate = { burst = 3, perSecond = 0.5 },
		args = { validSettings },
		handler = function(player: Player, values: { [string]: boolean }): Net.Result
			local profile = PlayerData.Get(player)
			if not profile then
				return Net.fail("NotReady")
			end
			for key, v in values do
				profile.Data.Settings[key] = v
			end
			PlayerData.MarkDirty(profile)
			return Net.ok(profile.Data.Settings)
		end,
	})
end

return Settings

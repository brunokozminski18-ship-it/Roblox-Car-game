--!strict
-- GameSecrets: server-only config. ServerScriptService/Server/GameSecrets
-- (ServerScriptService never replicates, so clients cannot read these codes).
-- Codes are written normalised: A-Z and 0-9 only, 3-24 characters.
-- EXAMPLE codes for the template; replace them per game.

local Secrets = {}

Secrets.Codes = {
	codes = {
		WELCOME = { reward = { kind = "currency", currency = "Cash", amount = 1000 } },
		STARTERPETS = { reward = { kind = "bundle", rewards = {
			{ kind = "item", item = "Pet1", count = 1 },
			{ kind = "item", item = "Pet2", count = 1 },
			{ kind = "item", item = "Pet3", count = 1 },
			{ kind = "item", item = "Pet4", count = 1 },
		} } },
		BIGCASH = { reward = { kind = "currency", currency = "Cash", amount = 10000 } },
	},
	maxMisses = 5,
	missWindowSeconds = 120,
	lockoutSeconds = 300,
}

return Secrets

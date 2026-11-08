--!strict
-- Template service: first-minute hints (Config.Hints). The server owns the
-- progress: steps run in order, a step is done when its `doneWhen` trigger
-- happens (Analytics.Triggered, wired in Main), and done steps are saved, so a
-- player sees each hint once. The client only draws the current step.
-- Remote: Hints.Get() -> step | nil ; push: Hints.Step(step | nil)

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LihFolk = ServerScriptService:WaitForChild("Server"):WaitForChild("LihFolk")
local PlayerData = require(LihFolk.PlayerData)
local Net = require(ReplicatedStorage:WaitForChild("LihFolk"):WaitForChild("Net"))

type Step = { id: string, target: string, text: string, doneWhen: string }
export type Config = { enabled: boolean, steps: { Step } }

local Hints = {}

local steps: { Step } = {}
local enabled = false
local stepPush: Net.Push? = nil

local function current(profile: PlayerData.Profile): Step?
	if not enabled then
		return nil
	end
	local done = profile.Data.Hints.Done
	for _, step in steps do
		if not done[step.id] then
			return step
		end
	end
	return nil
end

-- Called with every Analytics trigger; completes the current step if it matches.
function Hints.Trigger(player: Player, trigger: string)
	local profile = PlayerData.Get(player)
	if not profile then
		return
	end
	local step = current(profile)
	if not step or step.doneWhen ~= trigger then
		return
	end
	profile.Data.Hints.Done[step.id] = true
	PlayerData.MarkDirty(profile)
	if stepPush then
		stepPush:Fire(player, current(profile))
	end
end

function Hints.Init(config: Config)
	enabled = config.enabled == true
	local seen = {}
	for i, step in config.steps do
		assert(type(step.id) == "string" and not seen[step.id], `Hints step {i}: missing or duplicate id`)
		assert(type(step.target) == "string" and type(step.text) == "string" and type(step.doneWhen) == "string", `Hints step {step.id}: target, text and doneWhen are required`)
		seen[step.id] = true
		table.insert(steps, step)
	end
	PlayerData.RegisterSlice("Hints", function()
		return { Done = {} }
	end)
	stepPush = Net.Push("Hints.Step")
	Net.Handle("Hints.Get", {
		rate = { burst = 3, perSecond = 1 },
		args = {},
		handler = function(player: Player): Net.Result
			local profile = PlayerData.Get(player)
			return if profile then Net.ok(current(profile)) else Net.fail("NotReady")
		end,
	})
end

return Hints

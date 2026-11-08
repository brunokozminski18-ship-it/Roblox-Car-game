--!strict
--[[
	SETTINGS in style D (playbook/UI_STYLE.md). Our layout: one panel row per
	option (name, one-line description, ON/OFF on the right), RESET at the end.

	Applies locally right away; the server stores them (Settings.Save, batched)
	and they come back on join (Settings.Get). Keys: GameConfig.Settings.defaults.
]]

local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Controller = require(ReplicatedStorage:WaitForChild("LihFolkUI"):WaitForChild("LihFolkUIController"))
local Style = ReplicatedStorage:WaitForChild("UIStyle")
local Theme = require(Style:WaitForChild("StyleD"))
local UI = require(Style:WaitForChild("Components"))
local Launcher = require(Style:WaitForChild("Launcher"))
local Toast = require(Style:WaitForChild("Toast"))
local Net = require(ReplicatedStorage:WaitForChild("LihFolk"):WaitForChild("Net"))

local Color = Theme.Color

type Option = { key: string, name: string, info: string, default: boolean, apply: (on: boolean) -> () }

local function groupVolume(name: string, on: boolean)
	local group = SoundService:FindFirstChild(name)
	if group and group:IsA("SoundGroup") then
		group.Volume = if on then 0.5 else 0
	end
end

local OPTIONS: { Option } = {
	{ key = "music", name = "Music", info = "Background music.", default = true, apply = function(on)
		groupVolume("Music", on)
	end },
	{ key = "sfx", name = "Sound Effects", info = "Clicks, rewards and other sounds.", default = true, apply = function(on)
		groupVolume("SFX", on)
	end },
	{ key = "reducedMotion", name = "Reduced Motion", info = "Fewer pops, spins and shakes.", default = GuiService.ReducedMotionEnabled, apply = function(on)
		Controller.setReducedMotion(on)
	end },
	{ key = "hideEffects", name = "Hide Other Effects", info = "Hide other players' effects.", default = false, apply = function(on)
		workspace:SetAttribute("HideOtherEffects", on)
	end },
	{ key = "largeMenus", name = "Larger Menus", info = "Make windows bigger.", default = false, apply = function(on)
		Controller.setPlayerScale(if on then 1.2 else 1)
	end },
}

local values: { [string]: boolean } = {}
local toggles: { [string]: any } = {}
local pending = false

local function save()
	if pending then
		return
	end
	pending = true
	task.delay(1, function() -- batch quick changes into one save
		pending = false
		local result = Net.Request("Settings.Save", values)
		if not result.ok then
			Toast.Result(result)
		end
	end)
end

Controller.start()
local window = UI.Window({ name = "Settings", title = "Settings" })
local body: ScrollingFrame = window.body

for i, option in OPTIONS do
	values[option.key] = option.default
	local row = UI.Panel(UDim2.new(1, 0, 0, 96), i, body)
	UI.Text(string.upper(option.name), { size = 22, font = Theme.Font.title, box = UDim2.new(1, -170, 0, 28), position = UDim2.fromOffset(16, 10), parent = row })
	UI.Text(option.info, { size = 20, color = Color.textDim, wrap = true, box = UDim2.new(1, -170, 0, 42), position = UDim2.fromOffset(16, 42), parent = row })
	local toggle = UI.Toggle(option.default, function(on)
		values[option.key] = on
		option.apply(on)
		save()
	end)
	toggle.root.AnchorPoint = Vector2.new(1, 0.5)
	toggle.root.Position = UDim2.new(1, -16, 0.5, 0)
	toggle.root.Parent = row
	toggles[option.key] = toggle
end

UI.Button({
	text = "RESET",
	swatch = Theme.Button.grey,
	textSize = 22,
	size = UDim2.fromOffset(200, 56),
	layoutOrder = #OPTIONS + 1,
	parent = body,
	onActivated = function()
		for _, option in OPTIONS do
			values[option.key] = option.default
			toggles[option.key].set(option.default)
			option.apply(option.default)
		end
		save()
	end,
})

window.defaultSelection = toggles[OPTIONS[1].key].root
Controller.register(window)
Launcher.add("Settings", "settings", 0) -- first in the grid, top-left (C3)

-- Saved settings from the server (falls back to the defaults above).
task.spawn(function()
	for _ = 1, 10 do
		local result = Net.Request("Settings.Get")
		if result.ok then
			for _, option in OPTIONS do
				local saved = result.data[option.key]
				if type(saved) == "boolean" then
					values[option.key] = saved
					toggles[option.key].set(saved)
					option.apply(saved)
				end
			end
			return
		end
		task.wait(1.5)
	end
end)

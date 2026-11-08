--!strict
--[[
	REBIRTH in style D (playbook/UI_STYLE.md). Our layout:
	  top    NOW card -> NEXT card (gold frame), each with the cash multiplier
	  middle cost bar "have / need CASH"
	  bottom two short lists, YOU KEEP and RESETS, and one REBIRTH action
	         (grey "NEED ... CASH" until affordable; a second tap confirms)

	Server-owned (LihFolk Rebirth): reads leaderstats.<currency> and the
	attribute "Rebirths"; sends Rebirth.Request(1). Numbers come from
	GameConfig.Rebirth, with the same cost formula as the server.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Controller = require(ReplicatedStorage:WaitForChild("LihFolkUI"):WaitForChild("LihFolkUIController"))
local Style = ReplicatedStorage:WaitForChild("UIStyle")
local Theme = require(Style:WaitForChild("StyleD"))
local UI = require(Style:WaitForChild("Components"))
local Launcher = require(Style:WaitForChild("Launcher"))
local Toast = require(Style:WaitForChild("Toast"))
local Net = require(ReplicatedStorage:WaitForChild("LihFolk"):WaitForChild("Net"))
local Config = require(ReplicatedStorage:WaitForChild("GameConfig")) :: any

local player = Players.LocalPlayer
local Color = Theme.Color

local REBIRTH = Config.Rebirth
local CURRENCY = REBIRTH.currency
local KEEP = REBIRTH.keep or {}
local RESETS = REBIRTH.resets or { CURRENCY }

-- Same as LihFolk Rebirth.totalCost(n, 1, ...): the next single rebirth.
local function costFor(rebirths: number): number
	return math.floor(REBIRTH.baseCost * REBIRTH.growth ^ rebirths)
end

local function shorten(n: number): string
	if n >= 1e9 then
		return `{math.floor(n / 1e8) / 10}B`
	elseif n >= 1e6 then
		return `{math.floor(n / 1e5) / 10}M`
	elseif n >= 1e4 then
		return `{math.floor(n / 1e2) / 10}K`
	end
	return UI.formatNumber(n)
end

Controller.start()
local window = UI.Window({ name = "Rebirth", title = "Rebirth", size = Vector2.new(960, 460) })
local body: ScrollingFrame = window.body

-- NOW -> NEXT ---------------------------------------------------------------
local tiers = Instance.new("Frame")
tiers.Name = "Tiers"
tiers.BackgroundTransparency = 1
tiers.Size = UDim2.new(1, 0, 0, 118)
tiers.LayoutOrder = 1
tiers.Parent = body

local function tierCard(family, position: UDim2, anchor: Vector2, heading: string)
	local card = UI.Card({ family = family, size = UDim2.new(0.5, -40, 1, 0), parent = tiers })
	card.Position = position
	card.AnchorPoint = anchor
	UI.Text(heading, { size = 18, color = Color.textDim, align = Enum.TextXAlignment.Center, box = UDim2.new(1, 0, 0, 20), position = UDim2.fromOffset(0, 8), parent = card })
	local level = UI.Text("", { size = 24, font = Theme.Font.title, align = Enum.TextXAlignment.Center, box = UDim2.new(1, 0, 0, 30), position = UDim2.fromOffset(0, 30), parent = card })
	local mult = UI.Text("", { size = 28, font = Theme.Font.title, color = Color.tier, align = Enum.TextXAlignment.Center, box = UDim2.new(1, 0, 0, 44), position = UDim2.fromOffset(0, 64), parent = card })
	return level, mult
end
local nowLevel, nowMult = tierCard(Theme.Card.pass, UDim2.fromScale(0, 0), Vector2.zero, "NOW")
local nextLevel, nextMult = tierCard(Theme.Card.vip, UDim2.fromScale(1, 0), Vector2.new(1, 0), "AFTER REBIRTH")
UI.Text(">", {
	size = 76,
	font = Theme.Font.title,
	color = Color.tier,
	align = Enum.TextXAlignment.Center,
	box = UDim2.fromOffset(80, 100),
	position = UDim2.fromScale(0.5, 0.5),
	anchor = Vector2.new(0.5, 0.5),
	parent = tiers,
})

-- Cost bar and the one action share a row, so the action is on screen on a
-- phone without scrolling. ------------------------------------------------------
local actionRow = Instance.new("Frame")
actionRow.Name = "Action"
actionRow.BackgroundTransparency = 1
actionRow.Size = UDim2.new(1, 0, 0, 60)
actionRow.LayoutOrder = 2
actionRow.Parent = body
local cost = UI.ProgressBar(UDim2.new(0.6, -12, 0, 46), actionRow)
cost.root.AnchorPoint = Vector2.new(0, 0.5)
cost.root.Position = UDim2.fromScale(0, 0.5)
local button = UI.Button({
	text = "REBIRTH",
	textSize = 22,
	size = UDim2.new(0.4, 0, 0, 60),
	position = UDim2.new(1, 0, 0.5, 0),
	anchor = Vector2.new(1, 0.5),
	parent = actionRow,
})

-- What stays and what resets ----------------------------------------------------
local bottom = Instance.new("Frame")
bottom.Name = "Bottom"
bottom.BackgroundTransparency = 1
bottom.Size = UDim2.new(1, 0, 0, 120)
bottom.LayoutOrder = 3
bottom.Parent = body

local function list(title: string, items: { string }, color: Color3, x: number)
	local panel = UI.Panel(UDim2.new(0.5, -6, 1, 0), 0, bottom)
	panel.Position = UDim2.new(x, if x > 0 then 6 else 0, 0, 0)
	UI.Text(title, { size = 18, font = Theme.Font.title, color = color, box = UDim2.new(1, -24, 0, 26), position = UDim2.fromOffset(12, 8), parent = panel })
	UI.Text(table.concat(items, "\n"), {
		size = 21,
		color = Color.textDim,
		wrap = true,
		box = UDim2.new(1, -24, 1, -42),
		position = UDim2.fromOffset(12, 36),
		parent = panel,
	}).TextYAlignment = Enum.TextYAlignment.Top
end
list("YOU KEEP", KEEP, Color.good, 0)
list("RESETS", RESETS, Color.timer, 0.5)

local confirmUntil = 0
local canRebirth = false

local function cash(): number
	local stats = player:FindFirstChild("leaderstats")
	local value = stats and stats:FindFirstChild(CURRENCY)
	return if value and (value:IsA("IntValue") or value:IsA("NumberValue")) then (value :: NumberValue).Value else 0
end

local function refresh()
	local rebirths = tonumber(player:GetAttribute("Rebirths")) or 0
	local need = costFor(rebirths)
	local have = cash()
	canRebirth = have >= need
	nowLevel.Text = `REBIRTH {rebirths}`
	nowMult.Text = `x{1 + rebirths * REBIRTH.bonusPerRebirth} {string.upper(CURRENCY)}`
	nextLevel.Text = `REBIRTH {rebirths + 1}`
	nextMult.Text = `x{1 + (rebirths + 1) * REBIRTH.bonusPerRebirth} {string.upper(CURRENCY)}`
	cost.set(have, need, `{shorten(math.min(have, need))} / {shorten(need)} {string.upper(CURRENCY)}`)
	if os.clock() < confirmUntil then
		return
	end
	if canRebirth then
		button.setText("REBIRTH")
		button.setSwatch(Theme.Button.green)
	else
		button.setText(`NEED {shorten(need - have)} MORE`)
		button.setSwatch(Theme.Button.grey)
	end
end

local busy = false
button.root.Activated:Connect(function()
	if busy then
		return
	end
	if not canRebirth then
		-- Not enough: still ask the server, which refuses and says why.
		busy = true
		task.spawn(function()
			Toast.Result(Net.Request("Rebirth.Request", 1))
			busy = false
		end)
		return
	end
	if os.clock() >= confirmUntil then
		confirmUntil = os.clock() + 3
		button.setText("TAP AGAIN TO CONFIRM")
		button.setSwatch(Theme.Button.red)
		task.delay(3.05, refresh)
		return
	end
	confirmUntil = 0
	busy = true
	task.spawn(function()
		local result = Net.Request("Rebirth.Request", 1)
		Toast.Result(result, if result.ok then `REBIRTH {result.data.rebirths}! x{result.data.multiplier} {string.upper(CURRENCY)}` else nil)
		busy = false
		refresh()
	end)
end)

window.defaultSelection = button.root
Controller.register(window)
Launcher.add("Rebirth", "rebirth", 6)

player:GetAttributeChangedSignal("Rebirths"):Connect(refresh)
task.spawn(function()
	local stats = player:WaitForChild("leaderstats", 30)
	local value = stats and stats:WaitForChild(CURRENCY, 30)
	if value then
		(value :: NumberValue).Changed:Connect(refresh)
	end
	refresh()
end)
refresh()

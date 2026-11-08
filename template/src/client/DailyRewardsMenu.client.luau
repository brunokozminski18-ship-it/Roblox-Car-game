--!strict
--[[
	DAILY REWARDS in style D (playbook/UI_STYLE.md). Our layout:
	  top    streak and "NEXT IN 05:41:09" on the left, the one CLAIM action on
	         the right (visible without scrolling on a phone)
	  grid   one card per day of GameConfig.Daily.track; the last day has a special
	         purple face with rays and a BIG tag; claimed days are green with CLAIMED
	  bottom the streak rule in one line

	Server-owned (LihFolk DailyRewards): streak, day and reset time come from
	Daily.Status; the grant from Daily.Claim. The reset is 00:00 UTC (+offset).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Controller = require(ReplicatedStorage:WaitForChild("LihFolkUI"):WaitForChild("LihFolkUIController"))
local Style = ReplicatedStorage:WaitForChild("UIStyle")
local Theme = require(Style:WaitForChild("StyleD"))
local UI = require(Style:WaitForChild("Components"))
local Launcher = require(Style:WaitForChild("Launcher"))
local Toast = require(Style:WaitForChild("Toast"))
local ItemArt = require(Style:WaitForChild("ItemArt"))
local Net = require(ReplicatedStorage:WaitForChild("LihFolk"):WaitForChild("Net"))
local Config = require(ReplicatedStorage:WaitForChild("GameConfig")) :: any

local Color = Theme.Color
local TRACK = Config.Daily.track
local ITEMS = Config.Inventory.items

local function clock(seconds: number): string
	seconds = math.max(0, math.floor(seconds))
	return string.format("%02d:%02d:%02d", seconds // 3600, (seconds % 3600) // 60, seconds % 60)
end

-- What a day card shows for a reward from the track.
local function describe(reward: any): (string, string?)
	if reward.kind == "currency" then
		return `+{UI.formatNumber(reward.amount)}`, string.lower(reward.currency)
	elseif reward.kind == "item" then
		local def = ITEMS[reward.item] or {}
		return def.name or reward.item, def.art
	elseif reward.kind == "bundle" then
		return describe(reward.rewards[1])
	end
	return "?", nil
end

Controller.start()
local window = UI.Window({ name = "Daily", title = "Daily Rewards", size = Vector2.new(960, 450) })
local body: ScrollingFrame = window.body

-- Top line ------------------------------------------------------------------
local top = Instance.new("Frame")
top.Name = "Top"
top.BackgroundTransparency = 1
top.Size = UDim2.new(1, 0, 0, 58)
top.LayoutOrder = 1
top.Parent = body
local streakLabel = UI.Text("", { size = 26, font = Theme.Font.title, box = UDim2.new(0.5, 0, 0, 30), parent = top })
local nextLabel = UI.Text("", { size = 21, color = Color.timer, box = UDim2.new(0.5, 0, 0, 26), position = UDim2.fromOffset(0, 32), parent = top })
local claimButton = UI.Button({
	text = "CLAIM",
	size = UDim2.fromOffset(280, 56),
	position = UDim2.new(1, 0, 0, 0),
	anchor = Vector2.new(1, 0),
	name = "Claim",
	parent = top,
})

-- Day strip -------------------------------------------------------------------
local strip = Instance.new("Frame")
strip.Name = "Days"
strip.BackgroundTransparency = 1
strip.Size = UDim2.fromScale(1, 0)
strip.AutomaticSize = Enum.AutomaticSize.Y
strip.LayoutOrder = 2
strip.Parent = body
local stripList = Instance.new("UIGridLayout")
stripList.CellSize = UDim2.new(1 / 3, -12, 0, 200)
stripList.CellPadding = UDim2.fromOffset(18, 18)
stripList.SortOrder = Enum.SortOrder.LayoutOrder
stripList.Parent = strip

local cards: { Frame } = {}
for day, reward in TRACK do
	local last = day == #TRACK
	local family = if last then Theme.Card.vip else Theme.Card.offer
	local card = UI.Card({ family = family, size = UDim2.new(0, 80, 1, 0), layoutOrder = day, parent = strip })
	local label, art = describe(reward)
	UI.Text(`DAY {day}`, { size = 20, font = Theme.Font.title, align = Enum.TextXAlignment.Center, box = UDim2.new(1, 0, 0, 30), position = UDim2.fromOffset(0, 8), parent = card })
	UI.ItemArt(ItemArt.image(art), UDim2.new(1, -16, 0, 96), card).Position = UDim2.fromOffset(8, 42)
	UI.Text(label, { size = 20, align = Enum.TextXAlignment.Center, box = UDim2.new(1, -8, 0, 28), position = UDim2.new(0, 4, 1, -62), parent = card })
	if last then
		UI.Rays(card)
		local tag = UI.Tag("BIG", Theme.Button.red.bottom, card)
		tag.AnchorPoint = Vector2.new(0.5, 0)
		tag.Position = UDim2.new(0.5, 0, 1, -32)
	end
	cards[day] = card
end

UI.Text(`Come back every day. Miss a day and the streak starts again from Day 1. New day at 00:00 UTC.`, {
	size = 20,
	font = Theme.Font.bold,
	color = Color.textDim,
	align = Enum.TextXAlignment.Center,
	wrap = true,
	box = UDim2.new(1, 0, 0, 52),
	layoutOrder = 4,
	parent = body,
})

local status: any = nil
local resetAt = os.clock()
local launcher

local function render()
	if not status then
		streakLabel.Text = "LOADING..."
		claimButton.setText("...")
		claimButton.setSwatch(Theme.Button.grey)
		return
	end
	-- Which day is today's (claimable) or the one just claimed.
	local length = status.trackLength
	local claimedDay = if status.canClaim then status.rewardIndex - 1 else ((status.streak - 1) % length) + 1
	if status.canClaim and status.willReset then
		claimedDay = 0 -- the streak breaks: everything starts again from day 1
	end
	streakLabel.Text = `STREAK: {if status.canClaim and status.willReset then 0 else status.streak} {if status.streak == 1 then "DAY" else "DAYS"}`
	for day, card in cards do
		local old = card:FindFirstChild("StateTag")
		if old then
			old:Destroy()
		end
		local claimed = day <= claimedDay
		local today = status.canClaim and day == status.rewardIndex
		UI.SetCardState(card, if claimed then "claimed" elseif today then "ready" elseif day == #cards then "mega" else "locked")
		if claimed then
			local tag = UI.Tag("CLAIMED", Theme.Button.green.bottom, card)
			tag.Name = "StateTag"
			tag.ZIndex = 8
			tag.AnchorPoint = Vector2.new(0.5, 0.5)
			tag.Position = UDim2.fromScale(0.5, 0.45)
		end
	end
	if status.canClaim then
		claimButton.setText(`CLAIM DAY {status.rewardIndex}`)
		claimButton.setSwatch(Theme.Button.green)
	else
		claimButton.setText("CLAIMED TODAY")
		claimButton.setSwatch(Theme.Button.grey)
	end
	if launcher then
		launcher.setBadge(status.canClaim)
	end
end

local function refresh()
	local result = Net.Request("Daily.Status")
	if result.ok then
		status = result.data
		resetAt = os.clock() + status.secondsUntilReset
		render()
	end
	return result.ok
end

local busy = false
claimButton.root.Activated:Connect(function()
	if busy then
		return
	end
	busy = true
	task.spawn(function()
		-- Always asks the server: a second claim on the same day is refused there.
		local result = Net.Request("Daily.Claim")
		Toast.Result(result, if result.ok then `+{result.data.reward}` else nil)
		if result.data and result.data.status then
			status = result.data.status
			render()
		else
			refresh()
		end
		busy = false
	end)
end)

window.defaultSelection = claimButton.root
Controller.register(window)
launcher = Launcher.add("Daily", "daily", 5)
render()

task.spawn(function()
	for _ = 1, 10 do
		if refresh() then
			break
		end
		task.wait(1.5)
	end
	while true do
		local left = resetAt - os.clock()
		if Controller.isOpen("Daily") then
			nextLabel.Text = `NEXT IN {clock(left)}`
		end
		if left <= 0 then
			task.wait(2)
			refresh() -- new day: the server says what is claimable now
		end
		task.wait(1)
	end
end)

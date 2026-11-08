--!strict
--[[
	TASKS in style D (playbook/UI_STYLE.md). Our layout:
	  top    "RESETS IN 05:41:09" for the open list
	  rows   one panel per task: name, goal, progress bar, reward, one action
	         (CLAIM when done, grey IN PROGRESS otherwise, grey CLAIMED after)
	Tabs: the quest groups in GameConfig.Quests (Daily, Weekly).

	Server-owned: progress comes only from server systems (Quests.Report in
	Main). Renders Quests.Get / Quests.Changed, sends Quests.Claim(id).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Controller = require(ReplicatedStorage:WaitForChild("LihFolkUI"):WaitForChild("LihFolkUIController"))
local Style = ReplicatedStorage:WaitForChild("UIStyle")
local Theme = require(Style:WaitForChild("StyleD"))
local UI = require(Style:WaitForChild("Components"))
local Launcher = require(Style:WaitForChild("Launcher"))
local Toast = require(Style:WaitForChild("Toast"))
local Net = require(ReplicatedStorage:WaitForChild("LihFolk"):WaitForChild("Net"))
local Config = require(ReplicatedStorage:WaitForChild("GameConfig")) :: any

local Color = Theme.Color

-- Groups in config order.
local GROUPS: { string } = {}
do
	local seen = {}
	for _, quest in Config.Quests.quests do
		local group = quest.group or "Tasks"
		if not seen[group] then
			seen[group] = true
			table.insert(GROUPS, group)
		end
	end
end

local function clock(seconds: number): string
	seconds = math.max(0, math.floor(seconds))
	local d = seconds // 86400
	local hms = string.format("%02d:%02d:%02d", (seconds % 86400) // 3600, (seconds % 3600) // 60, seconds % 60)
	return if d > 0 then `{d}D {hms}` else hms
end

Controller.start()
local window = UI.Window({ name = "Tasks", title = "Tasks" })
local body: ScrollingFrame = window.body

local resetLabel = UI.Text("", { size = 21, color = Color.timer, box = UDim2.new(1, 0, 0, 26), layoutOrder = 1, parent = body })

local rowsHolder = Instance.new("Frame")
rowsHolder.Name = "Rows"
rowsHolder.BackgroundTransparency = 1
rowsHolder.Size = UDim2.fromScale(1, 0)
rowsHolder.AutomaticSize = Enum.AutomaticSize.Y
rowsHolder.LayoutOrder = 2
rowsHolder.Parent = body
local rowsList = Instance.new("UIListLayout")
rowsList.Padding = UDim.new(0, 12)
rowsList.SortOrder = Enum.SortOrder.LayoutOrder
rowsList.Parent = rowsHolder

local quests: { any } = {}
local currentGroup = GROUPS[1]
local resetAt: number? = nil -- os.clock() deadline for the open group
local launcher
local busy = false

local function render()
	for _, child in rowsHolder:GetChildren() do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
	resetAt = nil
	local ready = false
	local i = 0
	for _, quest in quests do
		if quest.complete and not quest.claimed then
			ready = true
		end
		if quest.group == currentGroup then
			i += 1
			if quest.resetsIn and not resetAt then
				resetAt = os.clock() + quest.resetsIn
			end
			local objective = quest.objectives[1]
			local row = UI.Card({ family = Theme.Card.pass, size = UDim2.new(1, 0, 0, 154), layoutOrder = i, parent = rowsHolder })
			UI.SetCardState(row, if quest.claimed then "claimed" elseif quest.complete then "ready" else "locked")
			row.Name = "Task_" .. quest.id
			UI.Text(string.upper(quest.title), { size = 22, font = Theme.Font.title, box = UDim2.new(0.7, -24, 0, 28), position = UDim2.fromOffset(16, 14), parent = row })
			UI.Text(if objective then objective.text else "Done for now", { size = 20, color = Color.textDim, wrap = true, box = UDim2.new(0.7, -24, 0, 48), position = UDim2.fromOffset(16, 44), parent = row })
			local middle = UDim2.fromOffset(16, 90)
			local bar = UI.ProgressBar(UDim2.new(0.46, -20, 0, 32), row)
			bar.root.Position = middle + UDim2.fromOffset(0, 12)
			if objective then
				bar.set(math.min(objective.current, objective.amount), objective.amount)
			else
				bar.set(1, 1, "DONE")
			end
			UI.Text(`REWARD +{string.upper(quest.reward)}`, { size = 20, color = Color.tier, box = UDim2.new(0.54, -32, 0, 42), wrap = true, position = UDim2.new(0.46, 4, 0, 100), parent = row })
			local canClaim = quest.complete and not quest.claimed
			local button = UI.Button({
				text = if quest.claimed then "CLAIMED" elseif quest.complete then "CLAIM" else "LOCKED",
				swatch = if canClaim then Theme.Button.green else Theme.Button.grey,
				textSize = 20,
				size = UDim2.new(0.3, -24, 0, 56),
				position = UDim2.new(1, -16, 0, 48),
				anchor = Vector2.new(1, 0.5),
				name = "Claim",
				parent = row,
				onActivated = function()
					if busy then
						return
					end
					busy = true
					task.spawn(function()
						-- The server decides; a click on a grey button still asks
						-- and shows why it is refused.
						local result = Net.Request("Quests.Claim", quest.id)
						Toast.Result(result, if result.ok then `+{result.data.reward}` else nil)
						local fresh = Net.Request("Quests.Get")
						if fresh.ok then
							quests = fresh.data
							render()
						end
						busy = false
					end)
				end,
			})
			if quest.claimed then
				button.label.TextColor3 = Color.textMuted
			end
		end
	end
	resetLabel.Text = if resetAt then `RESETS IN {clock(resetAt - os.clock())}` else ""
	if launcher then
		launcher.setBadge(ready)
	end
end

local tabs: { [string]: any } = {}
for i, group in GROUPS do
	tabs[group] = UI.Tab(group, i, window.tabs, function()
		currentGroup = group
		for name, tab in tabs do
			tab.setActive(name == group)
		end
		render()
	end)
end
tabs[currentGroup].setActive(true)
render()

window.defaultSelection = tabs[currentGroup].root
Controller.register(window)
launcher = Launcher.add("Tasks", "tasks", 4)

-- Progress pushes can come every second (income): rebuild rows only while the
-- window is open; otherwise keep the data and refresh the badge.
local dirty = false
Net.On("Quests.Changed", function(view: any)
	quests = view
	if Controller.isOpen("Tasks") then
		render()
	else
		dirty = true
		local ready = false
		for _, quest in quests do
			ready = ready or (quest.complete and not quest.claimed)
		end
		launcher.setBadge(ready)
	end
end)
Controller.onChanged(function(name: string, isOpen: boolean)
	if name == "Tasks" and isOpen and dirty then
		dirty = false
		render()
	end
end)
task.spawn(function()
	for _ = 1, 10 do
		local result = Net.Request("Quests.Get")
		if result.ok then
			quests = result.data
			render()
			break
		end
		task.wait(1.5)
	end
	while true do
		task.wait(1)
		if resetAt and Controller.isOpen("Tasks") then
			resetLabel.Text = `RESETS IN {clock(resetAt - os.clock())}`
		end
	end
end)

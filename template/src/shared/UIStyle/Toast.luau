--!strict
--[[
	Short message bar under the currency counters, in style B.
	Toast.Result(result, successText?) shows a server Net.Result: green on ok,
	red with the LihFolk Feedback text otherwise. One message at a time; a new
	one replaces the old.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Theme = require(script.Parent.Theme)
local Feedback = require(ReplicatedStorage:WaitForChild("LihFolk"):WaitForChild("Feedback"))

local Toast = {}

local gui: ScreenGui? = nil
local bar: Frame
local label: TextLabel
local stroke: UIStroke
local serial = 0

local function ensure()
	if gui then
		return
	end
	local g = Instance.new("ScreenGui")
	g.Name = "Toast"
	g.ResetOnSpawn = false
	g.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	g.DisplayOrder = 60 -- above windows
	bar = Instance.new("Frame")
	bar.Name = "Bar"
	bar.AnchorPoint = Vector2.new(0.5, 0)
	bar.Position = UDim2.new(0.5, 0, 0, 64)
	bar.Size = UDim2.fromOffset(0, 40)
	bar.AutomaticSize = Enum.AutomaticSize.X
	bar.BackgroundColor3 = Theme.Color.windowBottom
	bar.Visible = false
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = bar
	stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Thickness = 3
	stroke.Parent = bar
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 16)
	pad.PaddingRight = UDim.new(0, 16)
	pad.Parent = bar
	label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.FontFace = Theme.Font.heavy
	label.TextSize = 20
	label.TextColor3 = Theme.Color.text
	label.Size = UDim2.fromScale(0, 1)
	label.AutomaticSize = Enum.AutomaticSize.X
	label.Parent = bar
	local scale = Instance.new("UIScale")
	scale.Parent = bar
	bar.Parent = g
	g.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	gui = g
end

function Toast.Show(text: string, good: boolean?)
	ensure()
	serial += 1
	local mine = serial
	label.Text = text
	stroke.Color = if good then Theme.Button.green.top else Theme.Button.red.top
	bar.Visible = true
	local scale = bar:FindFirstChildOfClass("UIScale") :: UIScale
	scale.Scale = 0.9
	TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	task.delay(2.5, function()
		if serial == mine then
			bar.Visible = false
		end
	end)
end

function Toast.Result(result: { ok: boolean, code: string, data: any? }, successText: string?)
	if result.ok then
		Toast.Show(successText or Feedback.Messages.Ok, true)
	else
		Toast.Show(Feedback.Text(result.code), false)
	end
end

return Toast

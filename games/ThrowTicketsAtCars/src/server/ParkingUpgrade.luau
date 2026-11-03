--!strict
local Players = game:GetService("Players")
local Config = require(game.ReplicatedStorage.ThrowTickets.Config)
local Rules = require(game.ReplicatedStorage.ThrowTickets.Rules)

local ParkingUpgrade = {}

function ParkingUpgrade.new(ctx: any): any
	local api = {}

	function api.update(_player: Player, state: any)
		local sign = state.folder:FindFirstChild("ParkingUpgradeSign")
		if not sign then return end
		local capacity = state.data.ParkingCapacity
		local price = Rules.parkingPrice(state.data)
		local canUpgrade = capacity < Config.ParkingMax and typeof(price) == "number"
		local label = sign:FindFirstChild("UpgradeLabel")
		local text = label and label:FindFirstChildOfClass("TextLabel")
		if text then
			local affordable=canUpgrade and state.data.Cash>=price
			text.Text=if canUpgrade then string.format("     %d > %d\n▲ $%s",capacity,capacity+2,Rules.powerText(price))else "PARKING • 16\nMAX CAPACITY"
			text.TextColor3=if affordable then Color3.fromHex("92FFA0")elseif canUpgrade then Color3.fromHex("FF9292")else Color3.new(1,1,1)
		end
		local prompt = sign:FindFirstChild("ParkingUpgradePrompt")
		if prompt and prompt:IsA("ProximityPrompt") then
			prompt.Enabled = canUpgrade
			prompt.ActionText = if canUpgrade then "Upgrade $" .. Rules.powerText(price) else "Max capacity"
			prompt.ObjectText = if canUpgrade then string.format("%d > %d cars",capacity,capacity+2)else "Parking"
		end
	end

	function api.mount(player: Player, state: any)
		local sign = state.folder:FindFirstChild("ParkingUpgradeSign")
		if not sign or not sign:IsA("BasePart") or sign:FindFirstChild("ParkingUpgradePrompt") then return end
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "ParkingUpgradePrompt"
		prompt.KeyboardKeyCode = Enum.KeyCode.E
		prompt.ClickablePrompt = true
		prompt.HoldDuration = Config.PromptHoldSeconds
		prompt.MaxActivationDistance = Config.PlacementDistance
		prompt.RequiresLineOfSight = false
		prompt.Exclusivity = Enum.ProximityPromptExclusivity.OnePerButton
		prompt:SetAttribute("OwnerId", player.UserId)
		prompt.Parent = sign

		local function eligible(actor: Player): boolean
			if actor ~= player or player.Parent ~= Players or not ctx.mutable(state) or state.job or state.meter then return false end
			if sign.Parent ~= state.folder or not state.folder:IsDescendantOf(workspace) then return false end
			if sign:GetAttribute("OwnerId") ~= player.UserId or state.folder:GetAttribute("OwnerId") ~= player.UserId then return false end
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local root = ctx.rootOf(player)
			return humanoid ~= nil and humanoid.Health > 0 and root ~= nil
				and (root.Position - sign.Position).Magnitude <= Config.PlacementDistance
		end

		local hold: { started: number, capacity: number }? = nil
		local lastAttempt = -math.huge
		prompt.PromptButtonHoldBegan:Connect(function(actor)
			if not prompt.Enabled or not eligible(actor) then return end
			hold = { started = os.clock(), capacity = state.data.ParkingCapacity }
		end)
		prompt.PromptButtonHoldEnded:Connect(function(actor)
			if actor==player and hold and os.clock()-hold.started<Config.PromptHoldSeconds-.06 then hold=nil end
		end)
		prompt.Triggered:Connect(function(actor)
			if actor ~= player then return end
			local currentHold = hold
			hold = nil
			if not currentHold or not prompt.Enabled or not eligible(actor) then return end
			local now = os.clock()
			local heldFor = now - currentHold.started
			if heldFor < Config.PromptHoldSeconds - .06 or heldFor > Config.PromptHoldSeconds + 1.5 then return end
			if now - lastAttempt < Config.GarageRequestInterval then return end
			lastAttempt = now
			local ok, message = Rules.upgradeParking(state.data, currentHold.capacity)
			if ok then
				ctx.publish(player, state)
				ctx.saveSoon(player, state)
				api.update(player, state)
			end
			ctx.result(player, message)
		end)
		api.update(player, state)
		return prompt
	end

	return api
end

return ParkingUpgrade

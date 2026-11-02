--!strict
-- Cosmetic view cars only. Reward/parked/towed cars never enter this cache.
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(RS.ThrowTickets.Config)
local Rules = require(RS.ThrowTickets.Rules)
local Traffic = {}
local mounted: {[Instance]: boolean} = setmetatable({}, {__mode = "k"}) :: any

function Traffic.mount(world: Instance)
	if mounted[world] then return end
	mounted[world] = true
	local cars = world:WaitForChild("Cars")
	local cache: {[Model]: boolean} = {}
	local observed: {[Model]: {RBXScriptConnection}} = {}
	local links: {RBXScriptConnection} = {}
	local function add(node: Instance)
		if not node:IsA("Model") or node:GetAttribute("Display") ~= true then return end
		cache[node] = true
		for _, part in node:GetDescendants() do
			if part:IsA("BasePart") then part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery = true, false, false, false end
		end
	end
	local function watch(node: Instance)
		if not node:IsA("Model") or observed[node] then return end
		-- Replicated models can arrive before their attributes or their anchored parts.
		observed[node] = {
			node:GetAttributeChangedSignal("Display"):Connect(function() add(node) end),
			node.DescendantAdded:Connect(function(part)
				if node:GetAttribute("Display") == true and part:IsA("BasePart") then
					part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery = true, false, false, false
				end
			end),
		}
		add(node)
	end
	for _, node in cars:GetChildren() do watch(node) end
	table.insert(links, cars.ChildAdded:Connect(watch))
	table.insert(links, cars.ChildRemoved:Connect(function(node)
		if not node:IsA("Model") then return end
		cache[node] = nil
		local watches = observed[node]
		if watches then for _, link in watches do link:Disconnect() end; observed[node] = nil end
	end))
	local elapsed = 0
	table.insert(links, RunService.PreRender:Connect(function(dt)
		elapsed += dt
		if elapsed < 1 / Config.TrafficHz then return end
		elapsed %= 1 / Config.TrafficHz
		local camera = workspace.CurrentCamera
		if not camera then return end
		local now = workspace:GetServerTimeNow()
		local cameraPosition = camera.CFrame.Position
		for car in cache do
			if car.Parent ~= cars or car:GetAttribute("Display") ~= true then cache[car] = nil; continue end
			local biome, slot = car:GetAttribute("Biome"), car:GetAttribute("DisplaySlot")
			if typeof(biome) ~= "number" or typeof(slot) ~= "number" or not car.PrimaryPart then continue end
			local frame = Rules.trafficPosition(biome, slot, now)
			if (frame.Position - cameraPosition).Magnitude <= Config.TrafficRenderDistance then car:PivotTo(frame) end
		end
	end))
	table.insert(links, world.Destroying:Connect(function()
		for _, link in links do link:Disconnect() end
		for _, watches in observed do for _, link in watches do link:Disconnect() end end
		table.clear(observed)
		table.clear(cache)
		mounted[world] = nil
	end))
end

return Traffic

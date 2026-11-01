-- Rebuild the Edit preview from the same modules as Play. No Studio-only source.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play first")
local World = require(game.ServerScriptService.ThrowTickets.World)
local Config = require(game.ReplicatedStorage.ThrowTickets.Config)
local root = World.build()
World.parking(root, 1, 0, "Player")
for tier,data in Config.Tiers do
	for lane,x in Config.CarLanes do
		local car = World.car(root.Cars, "Preview_" .. tier .. "_" .. lane, tier, Vector3.new(x, Config.CarHeight, -data.Distance))
		car:SetAttribute("Tier", tier)
	end
end
workspace.CurrentCamera.CFrame = CFrame.lookAt(Vector3.new(75, 70, 55), Vector3.new(-10, 0, -40))
return "Edit preview rebuilt from source. Play replaces it with live cars and personal parking."

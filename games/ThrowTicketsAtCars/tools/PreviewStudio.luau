-- Edit preview uses the exact generator used by Play.
assert(not game:GetService("RunService"):IsRunning(),"Stop Play first")
local World=require(game.ServerScriptService.ThrowTickets.World)
local root=World.build()
World.parking(root,1,0,"Player")
workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(65,48,65),Vector3.new(-2,3,-65))
workspace.CurrentCamera.CameraType=Enum.CameraType.Custom
return {biomes=#root.Biomes:GetChildren(),displayCars=#root.Cars:GetChildren()}

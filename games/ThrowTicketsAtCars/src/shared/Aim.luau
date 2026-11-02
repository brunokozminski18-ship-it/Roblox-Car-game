--!strict
local Config = require(script.Parent.Config)
local Rules = require(script.Parent.Rules)
local Aim = {}

function Aim.centerRay(camera: Camera): Ray
	local size = camera.ViewportSize
	return camera:ViewportPointToRay(size.X / 2, size.Y / 2)
end

function Aim.validOrigin(origin: any, playerPosition: Vector3): boolean
	return Rules.finiteVector(origin) and (origin - playerPosition).Magnitude <= Config.CameraMaxZoom + Config.CameraOriginSlack
end

function Aim.point(car: Model): Vector3
	local glass = car:FindFirstChild("Windshield") :: BasePart?
	return if glass then glass.Position else (car.PrimaryPart :: BasePart).Position + Vector3.new(0, Config.RoofOffset, 0)
end

function Aim.choose(cars: Instance, origin: Vector3, direction: Vector3): Model?
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = {cars}
	local hit = workspace:Raycast(origin, direction * Config.AimMaxDistance, params)
	if hit then
		local model = hit.Instance:FindFirstAncestorOfClass("Model")
		if model and model.Parent == cars and not model:GetAttribute("Claimed") then return model end
	end
	local best: Model? = nil
	local bestDot = Config.AimConeDot
	for _,car in cars:GetChildren() do
		if car:IsA("Model") and car.PrimaryPart and not car:GetAttribute("Claimed") then
			local delta = Aim.point(car) - origin
			if delta.Magnitude > 0 and delta.Magnitude <= Config.AimMaxDistance then
				local dot = delta.Unit:Dot(direction)
				if dot > bestDot then best, bestDot = car, dot end
			end
		end
	end
	return best
end
return Aim

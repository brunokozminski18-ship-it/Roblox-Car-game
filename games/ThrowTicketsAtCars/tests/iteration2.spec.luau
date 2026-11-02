-- Run in Studio Edit with a fresh Aim module. No live player state is modified.
return function(Aim, Config)
	local camera = Instance.new("Camera")
	camera.CFrame = CFrame.lookAt(Vector3.new(3, 8, 12), Vector3.new(0, 3, -20))
	local ray = Aim.centerRay(camera)
	assert(ray.Direction:Dot(camera.CFrame.LookVector) > 0.9999, "Reticle must use the optical centre, independent of GUI insets")
	assert(Aim.validOrigin(Vector3.new(0, 5, 12), Vector3.zero))
	assert(not Aim.validOrigin(Vector3.new(0/0, 0, 0), Vector3.zero))
	assert(not Aim.validOrigin(Vector3.new(0, 0, Config.CameraMaxZoom + Config.CameraOriginSlack + 1), Vector3.zero))
	assert(Config.TicketFlightSeconds + Config.TowApproachSeconds + Config.TowLoadSeconds + Config.TowReturnSeconds <= 3, "Entire tow sequence must fit 3 seconds")
	camera:Destroy()
	return "5 iteration-2 assertions passed"
end

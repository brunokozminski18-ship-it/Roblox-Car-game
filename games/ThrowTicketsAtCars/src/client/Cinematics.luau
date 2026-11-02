--!strict
-- Owner-only camera. All throws still render on observers; no rewards are granted here.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Config = require(RS.ThrowTickets.Config)
local Effects = require(script.Parent.Effects)
local Exercises = require(script.Parent.Exercises)
local Cinematics = {}
local player = Players.LocalPlayer
local binding = "ThrowTicketsCinematic"
local seen: {[string]: boolean} = {}

type Snapshot = {camera: Camera, kind: Enum.CameraType, subject: Instance?, frame: CFrame, focus: CFrame, fov: number}
type Session = {closed: boolean, snapshot: Snapshot?, links: {RBXScriptConnection}, cancelFlight: (() -> ())?}
local active: Session? = nil

local function restore(session: Session)
	if session.closed then return end
	session.closed = true
	if active == session then active = nil; RunService:UnbindFromRenderStep(binding) end
	for _, link in session.links do link:Disconnect() end
	table.clear(session.links)
	if session.cancelFlight then session.cancelFlight(); session.cancelFlight = nil end
	local saved = session.snapshot
	if not saved then return end
	local camera = saved.camera
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if camera.Parent then
		camera.CFrame, camera.Focus, camera.FieldOfView = saved.frame, saved.focus, saved.fov
		local subject = saved.subject
		if subject and subject.Parent then camera.CameraSubject = subject
		elseif humanoid then camera.CameraSubject = humanoid end
		camera.CameraType = if subject and subject.Parent then saved.kind else Enum.CameraType.Custom
	end
	-- A camera replaced during respawn must never inherit this shot's Scriptable lock.
	local current = workspace.CurrentCamera
	if current and current ~= camera and current.CameraType == Enum.CameraType.Scriptable then
		if humanoid then current.CameraSubject = humanoid end
		current.FieldOfView, current.CameraType = saved.fov, Enum.CameraType.Custom
	end
end

function Cinematics.play(origin: Vector3, destination: Vector3, car: Model?, ownerId: number, income: number, metadata: any)
	local id = if metadata and typeof(metadata.Id) == "string" then metadata.Id else nil
	if id then
		if seen[id] then return end
		seen[id] = true
		task.delay(20, function() seen[id] = nil end)
	end
	local now = workspace:GetServerTimeNow()
	local start = if metadata and typeof(metadata.StartTime) == "number" then metadata.StartTime else now
	local windup = if metadata and typeof(metadata.WindupSeconds) == "number" then metadata.WindupSeconds else Config.ThrowWindupSeconds
	local flight = if metadata and typeof(metadata.FlightSeconds) == "number" then metadata.FlightSeconds else Config.TicketFlightSeconds
	local waitSeconds = math.max(0, start + windup - now)
	local owner = Players:GetPlayerByUserId(ownerId)
	if owner and waitSeconds > 0 then Exercises.windup(owner, waitSeconds) end
	local mine = ownerId == player.UserId
	local session: Session? = nil
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if mine and humanoid and humanoid.Health > 0 and now < start + windup + flight + Config.CameraReturnHold then
		if active then restore(active) end
		local created: Session = {closed = false, snapshot = nil, links = {}, cancelFlight = nil}
		session, active = created, created
		table.insert(created.links, humanoid.Died:Connect(function() restore(created) end))
		table.insert(created.links, player.CharacterRemoving:Connect(function() restore(created) end))
		table.insert(created.links, player.CharacterAdded:Connect(function() restore(created) end))
		table.insert(created.links, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() restore(created) end))
		-- Independent watchdog also covers a callback error or a destroyed result model.
		task.delay(math.max(0, start + windup + flight - now) + Config.CameraReturnHold + 1, function() restore(created) end)
	end
	task.delay(waitSeconds, function()
		local current = session
		if current and current.closed then return end
		local ok, err = pcall(function()
			local camera = workspace.CurrentCamera
			local point = origin
			local delta = destination - origin
			local forward = if delta.Magnitude > 0.01 then delta.Unit else Vector3.new(0, 0, -1)
			local right = forward:Cross(Vector3.yAxis)
			if right.Magnitude < 0.01 then right = Vector3.xAxis else right = right.Unit end
			if current and camera then
				current.snapshot = {camera = camera, kind = camera.CameraType, subject = camera.CameraSubject, frame = camera.CFrame, focus = camera.Focus, fov = camera.FieldOfView}
				camera.CameraType = Enum.CameraType.Scriptable
				RunService:BindToRenderStep(binding, Enum.RenderPriority.Camera.Value + 1, function()
					if current.closed then return end
					local success, message = pcall(function()
						if workspace.CurrentCamera ~= camera then restore(current); return end
						camera.CFrame = CFrame.lookAt(point - forward * 13 + Vector3.new(0, 6, 0) + right * 4, point + forward * 3)
						camera.Focus = CFrame.new(point)
					end)
					if not success then restore(current); warn("Throw camera stopped: " .. tostring(message)) end
				end)
			end
			local cancel = Effects.flight(origin, destination, car, income, mine, metadata, function(position: Vector3)
				point = position
			end, function()
				if current then task.delay(Config.CameraReturnHold, function() restore(current) end) end
			end)
			if current then current.cancelFlight = cancel end
		end)
		if not ok then
			if current then restore(current) end
			warn("Throw cinematic stopped: " .. tostring(err))
		end
	end)
end

function Cinematics.cancel()
	if active then restore(active) end
end

return Cinematics

--!strict
-- Local visual layer only. Training rewards and permission stay on the server.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Exercises = {}

type Joint = {node: Instance, role: string, frame: CFrame}
type Pose = {player: Player, character: Model?, joints: {Joint}, saved: {[Instance]: CFrame}, links: {RBXScriptConnection}, windupStart: number, windupEnd: number}
local poses: {[Player]: Pose} = {}
local mounted = false

local function restore(pose: Pose)
	for joint, value in pose.saved do
		if joint.Parent then (joint :: any).Transform = value end
	end
	table.clear(pose.saved)
end

local function bindCharacter(pose: Pose, character: Model?)
	restore(pose)
	for _, link in pose.links do link:Disconnect() end
	table.clear(pose.links)
	table.clear(pose.joints)
	pose.character = character
	if not character then return end
	local function add(node: Instance)
		if not node:IsA("Motor6D") and not node:IsA("AnimationConstraint") then return end
		local joint = node :: any
		local child = if node:IsA("Motor6D") then joint.Part1 else joint.Attachment1 and joint.Attachment1.Parent
		local name = string.lower(node.Name .. " " .. (if child then child.Name else ""))
		local side = if string.find(name, "right") then "Right" elseif string.find(name, "left") then "Left" else ""
		local role = ""
		if string.find(name, "shoulder") or string.find(name, "upperarm") or string.find(name, "right arm") or string.find(name, "left arm") then
			role = side .. "Shoulder"
		elseif string.find(name, "elbow") or string.find(name, "lowerarm") then
			role = side .. "Elbow"
		elseif string.find(name, "waist") then role = "Waist" end
		if role == "" then return end
		local frame = if node:IsA("Motor6D") then joint.C0 else if joint.Attachment0 then joint.Attachment0.CFrame else CFrame.identity
		table.insert(pose.joints, {node = node, role = role, frame = frame})
	end
	for _, node in character:GetDescendants() do add(node) end
	table.insert(pose.links, character.DescendantAdded:Connect(add))
end

local function ensure(player: Player): Pose
	local existing = poses[player]
	if existing then return existing end
	local pose: Pose = {player = player, character = nil, joints = {}, saved = {}, links = {}, windupStart = 0, windupEnd = 0}
	poses[player] = pose
	bindCharacter(pose, player.Character)
	return pose
end

function Exercises.mount()
	if mounted then return end
	mounted = true
	ensure(Players.LocalPlayer)
	RunService.PreAnimation:Connect(function()
		for _, pose in poses do restore(pose) end
	end)
	RunService.PreSimulation:Connect(function()
		local now = os.clock()
		for player, pose in poses do
			if pose.character ~= player.Character then bindCharacter(pose, player.Character) end
			local character = pose.character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health <= 0 then continue end
			local throwing = now < pose.windupEnd
			-- The Train clip replaces the procedural raise when it can play.
			local training = player == Players.LocalPlayer and player:GetAttribute("TrainingActive") == true and not require(script.Parent.CharacterAnims).available("Train")
			if not throwing and not training then continue end
			-- A full forward arm raise every 1.25 seconds, with soft endpoints.
			local raise = (1 - math.cos(now * math.pi * 2 / 1.25)) * 0.5
			local t = if throwing then math.clamp((now - pose.windupStart) / (pose.windupEnd - pose.windupStart), 0, 1) else 0
			for _, joint in pose.joints do
				if not joint.node:IsDescendantOf(character :: Model) then continue end
				local angle, twist = 0, 0
				if throwing then
					if joint.role == "RightShoulder" then angle = math.rad(-55 + 155 * t * t)
					elseif joint.role == "RightElbow" then angle = math.rad(-50 * math.sin(t * math.pi))
					elseif joint.role == "Waist" then twist = math.rad(-18 * math.sin(t * math.pi)) end
				elseif string.find(joint.role, "Shoulder") then angle = math.rad(120) * raise
				elseif string.find(joint.role, "Elbow") then angle = math.rad(-12) * raise end
				local node = joint.node :: any
				local animated = node.Transform :: CFrame
				pose.saved[joint.node] = animated
				-- Convert the torso-space raise into either rig's joint frame (R6 C0 axes differ).
				local rotation = joint.frame.Rotation:Inverse() * CFrame.Angles(angle, twist, 0) * joint.frame.Rotation
				node.Transform = rotation * animated
			end
		end
	end)
	Players.PlayerRemoving:Connect(function(player)
		local pose = poses[player]
		if pose then bindCharacter(pose, nil); poses[player] = nil end
	end)
end

function Exercises.windup(player: Player, seconds: number)
	Exercises.mount()
	if seconds <= 0 then return end
	-- Trail and release burst for every thrower (each client renders its own copy).
	require(script.Parent.Vfx).throw(player, seconds)
	-- Local player: real throw animation when available (it replicates to everyone); procedural swing as fallback.
	if player == Players.LocalPlayer and require(script.Parent.CharacterAnims).playTimed("Throw", seconds) then return end
	-- Other players: their own client plays the uploaded clip and it replicates, so do not layer the swing on top.
	if player ~= Players.LocalPlayer and (require(game:GetService("ReplicatedStorage").ThrowTickets.Config).Animations or {}).Throw ~= "" then return end
	local pose = ensure(player)
	pose.windupStart = os.clock()
	pose.windupEnd = pose.windupStart + seconds
end

return Exercises

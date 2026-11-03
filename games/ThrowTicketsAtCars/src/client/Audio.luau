--!strict
-- Client feedback only. Prebuilt bounded voices; play() never yields or fetches.
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Catalog = require(ReplicatedStorage.ThrowTickets.AudioCatalog)

type Result = { Loaded: boolean, Length: number, Id: string }
type Pool = { Sounds: { Sound }, LastPlayed: number, Next: number, Status: Folder }
local Audio = {}
local random = Random.new()
local pools: { [string]: Pool } = {}
local startedAt: { [Sound]: number } = {}
local serial: { [Sound]: number } = {}
local buttons = setmetatable({} :: { [GuiButton]: RBXScriptConnection }, { __mode = "k" })
local mounts: { [Instance]: { RBXScriptConnection } } = {}
local loading = false
local finished = false
local MAX_PLAYING = 12

local folder = Instance.new("Folder")
folder.Name = "AudioStatus"
folder:SetAttribute("PreloadComplete", false)
folder:SetAttribute("MaxPlaying", MAX_PLAYING)
folder.Parent = SoundService

for key, cue in pairs(Catalog) do
	local status = Instance.new("Folder")
	status.Name = key
	status:SetAttribute("Id", cue.Id)
	status:SetAttribute("SourceURL", cue.SourceURL)
	status:SetAttribute("TimingMeasured", false)
	status:SetAttribute("Loaded", false)
	status:SetAttribute("Length", 0)
	status.Parent = folder
	local sounds: { Sound } = {}
	for index = 1, cue.Voices do
		local sound = Instance.new("Sound")
		sound.Name = key .. "Voice" .. index
		sound.SoundId = cue.Id
		sound.Volume = cue.Volume
		sound.PlaybackSpeed = cue.PlaybackSpeed
		sound.Looped = false
		sound.Parent = status
		table.insert(sounds, sound)
	end
	pools[key] = { Sounds = sounds, LastPlayed = -math.huge, Next = 1, Status = status }
end

function Audio.status(): { [string]: Result }
	local results: { [string]: Result } = {}
	for key, pool in pairs(pools) do
		local sound = pool.Sounds[1]
		local loaded = sound.IsLoaded and sound.TimeLength > 0
		results[key] = { Loaded = loaded, Length = sound.TimeLength, Id = sound.SoundId }
		pool.Status:SetAttribute("Loaded", loaded)
		pool.Status:SetAttribute("Length", sound.TimeLength)
	end
	return results
end

-- Yields: call once in task.spawn at startup. Concurrent calls share one preload.
function Audio.preload(): { [string]: Result }
	if loading then
		repeat task.wait() until not loading
	elseif not finished then
		loading = true
		local sounds: { Instance } = {}
		for _, pool in pairs(pools) do
			for _, sound in ipairs(pool.Sounds) do table.insert(sounds, sound) end
		end
		local ok = pcall(function() ContentProvider:PreloadAsync(sounds) end)
		folder:SetAttribute("PreloadCallSucceeded", ok)
		finished, loading = true, false
		folder:SetAttribute("PreloadComplete", true)
	end
	return Audio.status()
end

-- Optional pitch is a multiplier (for a rising counter/letter run).
function Audio.play(key: string, pitch: number?): boolean
	local cue = Catalog[key]
	local pool = pools[key]
	if not cue or not pool then return false end
	local now = os.clock()
	if now - pool.LastPlayed < cue.MinInterval then return false end
	local sound: Sound? = nil
	for offset = 0, #pool.Sounds - 1 do
		local index = (pool.Next + offset - 1) % #pool.Sounds + 1
		local candidate = pool.Sounds[index]
		if candidate.IsLoaded and candidate.TimeLength > 0 then
			sound = candidate
			if not candidate.IsPlaying then
				pool.Next = index % #pool.Sounds + 1
				break
			end
		end
	end
	if not sound then return false end
	-- Steal an old voice at the global cap. No new instances during playback.
	local count, oldest, oldestTime = 0, nil :: Sound?, math.huge
	for active, at in pairs(startedAt) do
		if active.IsPlaying then
			count += 1
			if at < oldestTime then oldest, oldestTime = active, at end
		else
			startedAt[active] = nil
		end
	end
	if count >= MAX_PLAYING and not sound.IsPlaying and oldest then oldest:Stop() end
	sound:Stop()
	sound.TimePosition = 0 -- Onset unmeasured; intentionally no guessed lead-in skip.
	local multiplier = if pitch and pitch == pitch then math.clamp(pitch, 0.65, 1.8) else 1
	sound.PlaybackSpeed = cue.PlaybackSpeed * multiplier * random:NextNumber(1 - cue.PitchVariance, 1 + cue.PitchVariance)
	sound.Volume = cue.Volume
	local token = (serial[sound] or 0) + 1
	serial[sound], startedAt[sound], pool.LastPlayed = token, now, now
	sound:Play()
	-- Trim long source tails without stopping a subsequent reuse of this voice.
	task.delay(cue.MaxDuration, function()
		if serial[sound :: Sound] == token then (sound :: Sound):Stop() end
	end)
	return true
end

local function bindButton(instance: Instance)
	if not instance:IsA("GuiButton") or buttons[instance] then return end
	buttons[instance] = instance.Activated:Connect(function()
		if instance:GetAttribute("AudioMuted") == true then return end
		local key = instance:GetAttribute("AudioKey")
		Audio.play(if typeof(key) == "string" then key else "Tap")
	end)
end

-- Attribute AudioKey overrides Tap; AudioMuted=true suppresses a custom-wired button.
-- Repeated mounting is harmless, including when menus add buttons later.
function Audio.mountButtons(playerGui: Instance)
	if mounts[playerGui] then return end
	local connections: { RBXScriptConnection } = {}
	mounts[playerGui] = connections
	table.insert(connections, playerGui.DescendantAdded:Connect(bindButton))
	table.insert(connections, playerGui.DescendantRemoving:Connect(function(instance)
		if instance:IsA("GuiButton") then
			local connection = buttons[instance]
			if connection then connection:Disconnect(); buttons[instance] = nil end
		end
	end))
	table.insert(connections, playerGui.Destroying:Connect(function()
		for _, connection in ipairs(connections) do connection:Disconnect() end
		mounts[playerGui] = nil
	end))
	for _, instance in ipairs(playerGui:GetDescendants()) do bindButton(instance) end
end

return Audio

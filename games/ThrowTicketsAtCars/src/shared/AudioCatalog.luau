--!strict
-- Creator Store search, 2026-11-03. Availability is checked in the current experience
-- by Audio.preload(); Store discovery alone does not prove playback permission.
-- Sound design: LihFolk Vault V2, Sound Design for Games / Feedback Timing.
-- Onset and peak have NOT been measured. Do not schedule these cues early.
export type Cue = {
	Id: string,
	Name: string,
	Creator: string,
	SourceURL: string,
	Volume: number,
	PlaybackSpeed: number,
	PitchVariance: number,
	Voices: number,
	MinInterval: number,
	MaxDuration: number,
	TimingMeasured: boolean,
}

local function cue(id: string, name: string, creator: string, volume: number, speed: number, variance: number, voices: number, interval: number, duration: number): Cue
	return table.freeze({
		Id = "rbxassetid://" .. id,
		Name = name,
		Creator = creator,
		SourceURL = "https://create.roblox.com/store/asset/" .. id,
		Volume = volume,
		PlaybackSpeed = speed,
		PitchVariance = variance,
		Voices = voices,
		MinInterval = interval,
		MaxDuration = duration,
		TimingMeasured = false,
	})
end

local Catalog: { [string]: Cue } = {
	Tap = cue("106623224876186", "Tiny Click - Daily Sounds", "DailySoundsFX", 0.14, 1, 0.035, 2, 0.045, 0.3),
	Toast = cue("106553517979212", "UI Notification", "CoreCraft Studio", 0.18, 1, 0, 1, 0.15, 1.2),
	Counter = cue("138309872562566", "Retro Coin Collect - Daily Sounds", "DailySoundsFX", 0.09, 1.1, 0.025, 1, 0.045, 0.18),
	Letter = cue("106984966606682", "Cartoon Pop - Daily Sounds", "DailySoundsFX", 0.11, 1.15, 0.035, 1, 0.035, 0.25),
	LevelUp = cue("112485797063762", "UI - Level Up", "SodaBreadle", 0.28, 1, 0, 1, 0.3, 2.4),
	Purchase = cue("130378474223829", "Coin Pickup - Daily Sounds", "DailySoundsFX", 0.22, 1, 0, 2, 0.1, 0.65),
	Brake = cue("9126103903", "Tire Chirp Engine Car In Short Punchy Skids (SFX)", "ProSoundEffects", 0.32, 1, 0.025, 1, 0.15, 0.8),
	Impact = cue("106984966606682", "Cartoon Pop - Daily Sounds", "DailySoundsFX", 0.3, 0.72, 0.04, 2, 0.06, 0.35),
	Rare = cue("134821092416328", "Rewards Level Up - Next Tier", "Los Calientes Studio", 0.32, 1, 0, 1, 0.4, 3),
	XP = cue("130378474223829", "Coin Pickup - Daily Sounds", "DailySoundsFX", 0.12, 1.25, 0.02, 1, 0.08, 0.3),
	Boost = cue("80984744279155", "Fast Whoosh - Daily Sounds", "DailySoundsFX", 0.22, 1.2, 0.025, 1, 0.2, 0.8),
	Throw = cue("80984744279155", "Fast Whoosh - Daily Sounds", "DailySoundsFX", 0.2, 1, 0.04, 2, 0.1, 0.9),
}

return table.freeze(Catalog)

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
		Volume = volume * 0.52, -- Test mix: all game cues about 48% quieter.
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
	Toast = cue("106553517979212", "UI Notification", "CoreCraft Studio", 0.18, .9, 0.02, 1, 0.2, .65),
	Counter = cue("130378474223829", "Coin Pickup - Daily Sounds", "DailySoundsFX", 0.09, .95, 0.025, 1, 0.09, 0.16),
	Letter = cue("106623224876186", "Tiny Click - Daily Sounds", "DailySoundsFX", 0.11, .92, 0.03, 1, 0.08, 0.14),
	LevelUp = cue("106553517979212", "UI Notification", "CoreCraft Studio", 0.28, .85, .02, 1, 0.3, .9),
	Purchase = cue("130378474223829", "Coin Pickup - Daily Sounds", "DailySoundsFX", 0.22, 1, 0, 2, 0.1, 0.65),
	Brake = cue("80984744279155", "Fast Whoosh - Daily Sounds", "DailySoundsFX", 0.32, .85, 0.025, 1, 0.15, 0.5),
	Impact = cue("106984966606682", "Cartoon Pop - Daily Sounds", "DailySoundsFX", 0.3, 0.72, 0.04, 2, 0.06, 0.35),
	RareArrival = cue("80984744279155", "Fast Whoosh - Daily Sounds", "DailySoundsFX", 0.26, .72, .02, 1, .4, .9),
	Rare = cue("130378474223829", "Coin Pickup - Daily Sounds", "DailySoundsFX", 0.32, .72, .02, 1, .4, .65),
	XP = cue("106984966606682", "Cartoon Pop - Daily Sounds", "DailySoundsFX", 0.12, .85, 0.025, 1, 0.12, 0.14),
	BoostOffer = cue("106984966606682", "Cartoon Pop - Daily Sounds", "DailySoundsFX", .20, 1, .025, 1, .2, .2),
	Boost = cue("80984744279155", "Fast Whoosh - Daily Sounds", "DailySoundsFX", 0.22, 1, 0.025, 1, 0.2, 0.7),
	Throw = cue("80984744279155", "Fast Whoosh - Daily Sounds", "DailySoundsFX", 0.2, 1, 0.04, 2, 0.1, 0.9),
}

return table.freeze(Catalog)

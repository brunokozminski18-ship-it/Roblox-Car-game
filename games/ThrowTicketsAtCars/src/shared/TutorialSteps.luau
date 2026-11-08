--!strict
-- First 60 seconds (LihFolk lihfolk-tutorial). Teaching order = list order; objectives are 8 words or fewer.
-- Core loop in one line: throw a ticket -> catch a car -> park it for cash -> train -> throw farther.
-- World targets: the shared ThrowLine by path; the player's own slot and pad by client-local tags
-- (TT_MyFreeSlot, TT_MyTrainingPad, set in client/Onboarding.luau). Server hooks live in server/Onboarding.luau.
-- Status: NOT FINAL (texts, order and the cash top-up need a human playtest).
return {
	{
		id = "throw",
		objective = "Walk onto the white THROW pad!",
		signal = "Thrown",
		target = { path = { "TicketPrototype", "ThrowLine" } },
		hint = { any = "Follow the yellow line to the white pad" },
		hintAfter = 6,
	},
	{
		id = "park",
		objective = "Park your car to earn cash!",
		requires = { "throw" },
		target = { tag = "TT_MyFreeSlot", prompt = true },
		hint = { Keyboard = "Hold E on the glowing spot", Touch = "Hold the Place car button", Gamepad = "Hold the button on the glowing spot" },
		hintAfter = 6,
	},
	{
		id = "train",
		objective = "Stand on TRAINING to get stronger!",
		signal = "LevelUp",
		requires = { "park" },
		target = { tag = "TT_MyTrainingPad" },
		hint = { any = "Stand still on the green pad" },
		hintAfter = 6,
	},
	{
		id = "throw2",
		objective = "Throw again to catch another car!",
		signal = "Caught",
		requires = { "train" },
		target = { path = { "TicketPrototype", "ThrowLine" } },
		hint = { any = "Follow the yellow line back to the pad" },
		hintAfter = 8,
		reward = "FirstExerciseCash", -- tops Cash up to exactly the first exercise price
	},
	{
		id = "buy",
		objective = "Buy Focused Training in the SHOP!",
		requires = { "throw2" },
		guide = "none", -- HUD target: the SHOP button pulses instead of a world beam
		hint = { Keyboard = "Click the pink SHOP button", Touch = "Tap the pink SHOP button", Gamepad = "Open the pink SHOP button" },
		hintAfter = 6,
	},
}

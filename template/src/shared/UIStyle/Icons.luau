--!strict
--[[
	Menu icon images and colours (playbook/UI_STYLE.md, "Ikony menu").
	Images: template/art/icons/set_d — "Free Icon Pack" by gvesster (BuiltByBit),
	commercial use allowed, no resale, no claim of ownership (licence PDF in
	template/art/icons/vendor). User decision 01.11.2026. Old Blender renders: art/icons/set.

	PREVIEW ONLY: the rbxasset:// paths point at a copy in this machine's Studio
	content folder (content/textures/icons_d), so they show in Studio
	but NOT in a published game, and vanish when Studio updates. Before release,
	upload the PNGs (needs the owner's OK) and paste the rbxassetid:// ids here.
]]

local PREVIEW = "rbxasset://textures/icons_d/"

-- kind: "big" = wide labelled menu button, "small" = square tile with a
-- caption (playbook/UI_STYLE.md, "Przyciski menu (C3)"). side: which screen
-- edge a big button sits on. button = text on the big button when the window
-- title is too long for it.
export type MenuIcon = { image: string, color: Color3, label: string, kind: string?, side: string?, button: string? }

local Icons: { [string]: MenuIcon } = {
	playtime = { image = "rbxasset://textures/item_art_d/clock.png", color = Color3.fromHex("#FF86CF"), label = "GIFTS", kind = "small" },
	shop = { image = PREVIEW .. "shop.png", color = Color3.fromHex("#FF7A00"), label = "SHOP", kind = "big", side = "left" },
	inventory = { image = PREVIEW .. "inventory.png", color = Color3.fromHex("#00C2B0"), label = "INVENTORY", kind = "big", side = "left", button = "ITEMS" },
	index = { image = PREVIEW .. "index.png", color = Color3.fromHex("#1F6BFF"), label = "INDEX", kind = "big", side = "right" },
	tasks = { image = PREVIEW .. "tasks.png", color = Color3.fromHex("#2FCF1F"), label = "TASKS", kind = "big", side = "right" },
	daily = { image = PREVIEW .. "daily.png", color = Color3.fromHex("#FF2E8A"), label = "DAILY", kind = "small" },
	rebirth = { image = PREVIEW .. "rebirth.png", color = Color3.fromHex("#8E3CFF"), label = "REBIRTH", kind = "small" },
	settings = { image = PREVIEW .. "settings.png", color = Color3.fromHex("#8796AA"), label = "SETTINGS", kind = "small" },
	coin = { image = PREVIEW .. "coin.png", color = Color3.fromHex("#FFC93C"), label = "COINS" },
	gem = { image = PREVIEW .. "gem.png", color = Color3.fromHex("#3DD6FF"), label = "GEMS" },
	-- "+1" template art (no menu button: no kind)
	power = { image = PREVIEW .. "power.png", color = Color3.fromHex("#FFC21A"), label = "POWER" },
	pets = { image = PREVIEW .. "pets.png", color = Color3.fromHex("#C0603A"), label = "PETS" },
	egg = { image = PREVIEW .. "egg.png", color = Color3.fromHex("#FFB27A"), label = "EGG" },
	gift = { image = PREVIEW .. "gift.png", color = Color3.fromHex("#7A4CFF"), label = "GIFT" },
	boots = { image = PREVIEW .. "boots.png", color = Color3.fromHex("#E8304A"), label = "BOOTS" },
	crown = { image = PREVIEW .. "crown.png", color = Color3.fromHex("#FFC21A"), label = "CROWN" },
}

return Icons

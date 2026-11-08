--!strict
--[[
	Card art for items, offers and rewards.
	Images: template/art/icons/items_d — "Free Icon Pack" by gvesster (licence:
	playbook/UI_STYLE.md, "Skąd grafiki"), silhouettes made from their alpha.
	Old Blender renders of LihFolk props: template/art/items (render_card.py).
	ItemArt.image(key) -> image or nil (nil shows the empty "ITEM ART" slot);
	ItemArt.silhouette(key) -> black silhouette for "???" in Index.
	Keys come from GameConfig (items[*].art, ShopDisplay[*].art).

	PREVIEW ONLY: rbxasset:// paths point at a copy in this machine's Studio
	content folder (content/textures/item_art_d), so they show in Studio
	but NOT in a published game. Before release, upload the PNGs (owner's OK)
	and put rbxassetid:// ids in ART below.
]]

local PREVIEW = "rbxasset://textures/item_art_d/"

-- key (GameConfig art field) = file name (without .png) in item_art_d.
-- Neutral template content; a meme reskin swaps these for its own art.
local ART: { [string]: string } = {
	clock = "clock", gift = "gift", check = "check", fire = "fire",
	pet1 = "bunny", pet2 = "cat", pet3 = "dog", pet4 = "golden_bunny",
	pet5 = "golden_cat", pet6 = "golden_dog", pet7 = "bunny", pet8 = "cat",
	pet9 = "dog", pet10 = "golden_bunny", pet11 = "golden_cat", pet12 = "golden_dog",
	item1 = "potion", item2 = "key", item3 = "chest", item4 = "lucky_block",
	offer1 = "gift", offer2 = "chest", offer3 = "lucky_block",
	pass1 = "vip", pass2 = "lightning", pass3 = "coil",
	pack1 = "diamond_blue", pack2 = "diamond_purple", pack3 = "diamond_green", pack4 = "diamond_golden",
	cash = "coin", gems = "diamond_blue", power = "lightning",
}

local ItemArt = {}

function ItemArt.image(key: string?): string?
	local file = if key then ART[key] else nil
	return if file then PREVIEW .. file .. ".png" else nil
end

function ItemArt.silhouette(key: string?): string?
	local file = if key then ART[key] else nil
	return if file then PREVIEW .. file .. "_silhouette.png" else nil
end

return ItemArt

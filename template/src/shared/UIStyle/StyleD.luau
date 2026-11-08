--!strict
-- Approved style D tokens. Separate from Theme so the accepted HUD stays intact.
local D = {}
local function h(s: string): Color3 return Color3.fromHex(s) end
local ink, white = h("14102A"), h("FFFFFF")
local function sw(a: string, b: string) return {top=h(a), bottom=h(b), border=ink} end
D.Color = {
 ink=ink, text=white, textDim=h("E9F4FF"), textMuted=h("D4E4FF"),
 windowTop=h("2F7BF2"), windowBottom=h("16348F"), windowBorder=ink,
 divider=h("74E6FF"), timer=h("FFD24A"), tier=h("FFD24A"), money=white,
 field=h("0E1E55"), fieldBorder=h("74E6FF"), panel=h("214AB1"),
 ribbon=h("FF6B6B"), ribbonDark=h("E0202F"), scrollBar=h("74E6FF"),
 progress=h("FFD24A"), progressTrack=h("0E1E55"), good=h("8CF27C"), tile=ink,
 pink=h("FF4FA8"), gold=h("FFD24A"), silhouette=ink,
}
D.Card = {claimed=sw("8CF27C","22B24A"), ready=sw("FF86CF","E2338C"), locked=sw("74E6FF","1E95F0"), mega=sw("D98BFF","7B2BE6")}
D.Card.offer=D.Card.ready D.Card.cash=D.Card.claimed D.Card.pass=D.Card.locked D.Card.vip=D.Card.mega
D.Button = {green=sw("FFFFFF","FFE1F2"),grey=sw("E9ECF2","AEB4C0"),active=sw("FF86CF","E2338C"),red=sw("FF6B6B","E0202F")}
D.Rarity = {common=D.Card.locked,uncommon=D.Card.claimed,rare=D.Card.locked,epic=D.Card.mega,legendary=D.Card.ready,unknown=D.Card.locked}
D.Font={title=Font.fromEnum(Enum.Font.FredokaOne),heavy=Font.fromEnum(Enum.Font.FredokaOne),bold=Font.fromEnum(Enum.Font.FredokaOne)}
D.Size={window=Vector2.new(960,620),header=96,tab=52,close=64,button=52,minText=20,radius=36,
 cardRadius=32,windowStroke=5,cardStroke=4,buttonStroke=3,outline=.12,shadow=.1,
 insetX=24,insetTop=36,insetBottom=8,compactHeader=76,compactTitle=36,compactIcon=84,icon=104,title=48,textureTile=48,pillRadius=999}
D.Playtime={window=Vector2.new(880,720),header=80,footer=74,cardHeight=210,subtitleHeight=26}
D.Texture="rbxasset://textures/ui_preview/"
D.Art="rbxasset://textures/item_art_d/"
D.ROBUX=utf8.char(0xE002)
return D

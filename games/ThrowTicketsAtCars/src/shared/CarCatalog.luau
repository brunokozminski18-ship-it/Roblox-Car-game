--!strict
-- research/CarList_draft.md (05.11.2026). DraftDescription is authoring data, never player UI.
local Catalog={Biomes={}}
Catalog.Biomes[1]={Name="Junkyard",MinPower=0,BaseIncome=1,Color=Color3.fromHex("91765B"),Prop="scrap",Cars={
 {Id="n11_rusty_hatch",Name="Rusty Hatch",Rarity=1,Weight=1,Style=1,Kind="hatch",Color=Color3.fromHex("8D5A38"),Description="Rusty Hatch - block-built hatch collection car",DraftDescription="mały hatchback cały w rdzy, brak jednych drzwi"},
 {Id="n11_doorless_van",Name="Doorless Van",Rarity=1,Weight=1,Style=2,Kind="van",Color=Color3.fromHex("729187"),Description="Doorless Van - block-built van collection car",DraftDescription="van bez drzwi, w środku stare opony"},
 {Id="n11_flat_tire_pickup",Name="Flat-Tire Pickup",Rarity=1,Weight=1,Style=3,Kind="pickup",Color=Color3.fromHex("916D4E"),Description="Flat-Tire Pickup - block-built pickup collection car",DraftDescription="pickup na trzech kołach i cegle"},
 {Id="n11_couch_cruiser",Name="Couch Cruiser",Rarity=2,Weight=1,Style=4,Kind="couch",Color=Color3.fromHex("B64B68"),Description="Rolling sofa with a steering wheel",DraftDescription="kanapa na czterech kółkach z kierownicą"},
 {Id="n11_shopping_cart_racer",Name="Shopping Cart Racer",Rarity=3,Weight=1,Style=5,Kind="cart",Color=Color3.fromHex("A7BCC5"),Description="Shopping Cart Racer - block-built cart collection car",DraftDescription="wielki wózek sklepowy z silnikiem i spoilerem"},
 {Id="n11_scrap_king",Name="Scrap King",Rarity=4,Weight=1,Style=6,Kind="scrap",Color=Color3.fromHex("A08343"),Description="Scrap King - block-built scrap collection car",DraftDescription="auto sklejone z części innych aut, korona z felg na dachu"},
}}
Catalog.Biomes[2]={Name="Suburbs",MinPower=50,BaseIncome=5,Color=Color3.fromHex("7A996F"),Prop="houses",Cars={
 {Id="n11_grandma_sedan",Name="Grandma Sedan",Rarity=1,Weight=1,Style=7,Kind="sedan",Color=Color3.fromHex("D4BD91"),Description="Grandma Sedan - block-built sedan collection car",DraftDescription="beżowy sedan, serwetka na desce, max 20 km/h"},
 {Id="n11_soccer_mom_van",Name="Soccer Mom Van",Rarity=1,Weight=1,Style=8,Kind="van",Color=Color3.fromHex("8FBECE"),Description="Soccer Mom Van - block-built van collection car",DraftDescription="minivan z naklejkami \"my kid is…\""},
 {Id="n11_lawn_mower_kart",Name="Lawn Mower Kart",Rarity=1,Weight=1,Style=9,Kind="kart",Color=Color3.fromHex("7CB548"),Description="Lawn Mower Kart - block-built kart collection car",DraftDescription="kosiarka-gokart"},
 {Id="n11_ice_cream_truck",Name="Ice Cream Truck",Rarity=2,Weight=1,Style=10,Kind="truck",Color=Color3.fromHex("A8DDEC"),Description="Ice Cream Truck - block-built truck collection car",DraftDescription="wóz z wielkim rożkiem na dachu"},
 {Id="n11_pizza_delivery_bug",Name="Pizza Delivery Bug",Rarity=3,Weight=1,Style=11,Kind="hatch",Color=Color3.fromHex("E2AA48"),Description="Pizza Delivery Bug - block-built hatch collection car",DraftDescription="małe autko z ogromną pizzą zamiast dachu"},
 {Id="n11_grandma_s_rocket",Name="Grandma's Rocket",Rarity=4,Weight=1,Style=12,Kind="rocket",Color=Color3.fromHex("D4BD91"),Description="Beige sedan with twin rear rocket engines",DraftDescription="ten sam beżowy sedan, ale z silnikiem rakietowym z tyłu"},
}}
Catalog.Biomes[3]={Name="Downtown",MinPower=150,BaseIncome=22,Color=Color3.fromHex("708499"),Prop="towers",Cars={
 {Id="n11_yellow_cab",Name="Yellow Cab",Rarity=1,Weight=1,Style=13,Kind="taxi",Color=Color3.fromHex("F2BE36"),Description="Yellow Cab - block-built taxi collection car",DraftDescription="taksówka z kogutem TAXI"},
 {Id="n11_city_bus",Name="City Bus",Rarity=1,Weight=1,Style=14,Kind="bus",Color=Color3.fromHex("41A6B7"),Description="City Bus - block-built bus collection car",DraftDescription="długi autobus, za długi na jedno miejsce"},
 {Id="n11_food_truck",Name="Food Truck",Rarity=1,Weight=1,Style=15,Kind="truck",Color=Color3.fromHex("C35B47"),Description="Food Truck - block-built truck collection car",DraftDescription="buda z hot dogiem na dachu"},
 {Id="n11_cop_cruiser",Name="Cop Cruiser",Rarity=2,Weight=1,Style=16,Kind="sedan",Color=Color3.fromHex("2B3D67"),Description="Cop Cruiser - block-built sedan collection car",DraftDescription="radiowóz z migającymi światłami"},
 {Id="n11_stretch_limo",Name="Stretch Limo",Rarity=2,Weight=1,Style=17,Kind="limo",Color=Color3.fromHex("303748"),Description="Stretch Limo - block-built limo collection car",DraftDescription="absurdalnie długa limuzyna"},
 {Id="n11_double_decker",Name="Double-Decker",Rarity=3,Weight=1,Style=18,Kind="bus",Color=Color3.fromHex("C9574E"),Description="Double-Decker - block-built bus collection car",DraftDescription="piętrowy autobus z basenem na górze"},
 {Id="n11_mayor_s_golden_limo",Name="Mayor's Golden Limo",Rarity=4,Weight=1,Style=19,Kind="limo",Color=Color3.fromHex("E7B43E"),Description="Mayor's Golden Limo - block-built limo collection car",DraftDescription="złota limuzyna z flagami i czerwonym dywanem"},
}}
Catalog.Biomes[4]={Name="Farm Roads",MinPower=300,BaseIncome=90,Color=Color3.fromHex("859B53"),Prop="farm",Cars={
 {Id="n11_muddy_pickup",Name="Muddy Pickup",Rarity=1,Weight=1,Style=20,Kind="pickup",Color=Color3.fromHex("87613E"),Description="Muddy Pickup - block-built pickup collection car",DraftDescription="pickup cały w błocie, siano na pace"},
 {Id="n11_tiny_tractor",Name="Tiny Tractor",Rarity=1,Weight=1,Style=21,Kind="tractor",Color=Color3.fromHex("C54437"),Description="Tiny Tractor - block-built tractor collection car",DraftDescription="mały czerwony traktor"},
 {Id="n11_hay_wagon",Name="Hay Wagon",Rarity=1,Weight=1,Style=22,Kind="wagon",Color=Color3.fromHex("C69746"),Description="Hay Wagon - block-built wagon collection car",DraftDescription="przyczepa z sianem na kołach"},
 {Id="n11_cow_car",Name="Cow Car",Rarity=2,Weight=1,Style=23,Kind="sedan",Color=Color3.fromHex("EEE9D9"),Description="Cow Car - block-built sedan collection car",DraftDescription="auto w łaty jak krowa, rogi na masce"},
 {Id="n11_combine_crusher",Name="Combine Crusher",Rarity=3,Weight=1,Style=24,Kind="combine",Color=Color3.fromHex("89AD42"),Description="Combine Crusher - block-built combine collection car",DraftDescription="wielki kombajn z wirującymi ostrzami"},
 {Id="n11_chicken_coop_racer",Name="Chicken Coop Racer",Rarity=3,Weight=1,Style=25,Kind="coop",Color=Color3.fromHex("BD7847"),Description="Chicken Coop Racer - block-built coop collection car",DraftDescription="kurnik na kołach, kury w oknach"},
 {Id="n11_golden_tractor",Name="Golden Tractor",Rarity=4,Weight=1,Style=26,Kind="tractor",Color=Color3.fromHex("E8BA3F"),Description="Golden Tractor - block-built tractor collection car",DraftDescription="złoty traktor ze świecącymi kołami"},
}}
Catalog.Biomes[5]={Name="Desert Highway",MinPower=550,BaseIncome=360,Color=Color3.fromHex("D8B77C"),Prop="cactus",Cars={
 {Id="n11_dusty_camper",Name="Dusty Camper",Rarity=1,Weight=1,Style=27,Kind="camper",Color=Color3.fromHex("D2B98B"),Description="Dusty Camper - block-built camper collection car",DraftDescription="kamper z leżakiem na dachu"},
 {Id="n11_big_rig",Name="Big Rig",Rarity=1,Weight=1,Style=28,Kind="rig",Color=Color3.fromHex("B86544"),Description="Big Rig - block-built rig collection car",DraftDescription="ciężarówka z naczepą"},
 {Id="n11_dune_buggy",Name="Dune Buggy",Rarity=1,Weight=1,Style=29,Kind="buggy",Color=Color3.fromHex("E2B846"),Description="Dune Buggy - block-built buggy collection car",DraftDescription="lekki buggy z rurami"},
 {Id="n11_hot_rod",Name="Hot Rod",Rarity=2,Weight=1,Style=30,Kind="coupe",Color=Color3.fromHex("B3353C"),Description="Hot Rod - block-built coupe collection car",DraftDescription="hot rod z płomieniami na bokach"},
 {Id="n11_cactus_cruiser",Name="Cactus Cruiser",Rarity=2,Weight=1,Style=31,Kind="sedan",Color=Color3.fromHex("49915B"),Description="Cactus Cruiser - block-built sedan collection car",DraftDescription="zielone auto z kaktusami zamiast lusterek"},
 {Id="n11_monster_truck",Name="Monster Truck",Rarity=3,Weight=1,Style=32,Kind="monster",Color=Color3.fromHex("E47E31"),Description="Small body on enormous off-road tires",DraftDescription="ogromne koła, małe nadwozie"},
 {Id="n11_desert_tank_car",Name="Desert Tank-Car",Rarity=3,Weight=1,Style=33,Kind="tank",Color=Color3.fromHex("BCA976"),Description="Desert Tank-Car - block-built tank collection car",DraftDescription="auto na gąsienicach w barwach pustyni"},
 {Id="n11_sandstorm_king",Name="Sandstorm King",Rarity=4,Weight=1,Style=34,Kind="monster",Color=Color3.fromHex("D0A04B"),Description="Sandstorm King - block-built monster collection car",DraftDescription="monster truck otoczony wirującym piaskiem"},
}}
Catalog.Biomes[6]={Name="Snowy Pass",MinPower=900,BaseIncome=1400,Color=Color3.fromHex("D6E8ED"),Prop="snow",Cars={
 {Id="n11_snow_plow",Name="Snow Plow",Rarity=1,Weight=1,Style=35,Kind="truck",Color=Color3.fromHex("6495B2"),Description="Snow Plow - block-built truck collection car",DraftDescription="pług z wielką łopatą"},
 {Id="n11_chained_suv",Name="Chained SUV",Rarity=1,Weight=1,Style=36,Kind="suv",Color=Color3.fromHex("6E869B"),Description="Chained SUV - block-built suv collection car",DraftDescription="SUV z łańcuchami na kołach"},
 {Id="n11_snowmobile",Name="Snowmobile",Rarity=1,Weight=1,Style=37,Kind="snowmobile",Color=Color3.fromHex("DE4C56"),Description="Snowmobile - block-built snowmobile collection car",DraftDescription="skuter śnieżny"},
 {Id="n11_ski_lift_car",Name="Ski Lift Car",Rarity=2,Weight=1,Style=38,Kind="gondola",Color=Color3.fromHex("CE6255"),Description="Ski Lift Car - block-built gondola collection car",DraftDescription="wagonik wyciągu na kołach"},
 {Id="n11_igloo_cruiser",Name="Igloo Cruiser",Rarity=2,Weight=1,Style=39,Kind="igloo",Color=Color3.fromHex("B3E7EE"),Description="Igloo Cruiser - block-built igloo collection car",DraftDescription="auto z lodu z igloo na dachu"},
 {Id="n11_yeti_truck",Name="Yeti Truck",Rarity=3,Weight=1,Style=40,Kind="yeti",Color=Color3.fromHex("E5E0D1"),Description="Yeti Truck - block-built yeti collection car",DraftDescription="futrzana ciężarówka z oczami"},
 {Id="n11_penguin_bus",Name="Penguin Bus",Rarity=3,Weight=1,Style=41,Kind="penguin",Color=Color3.fromHex("263A4B"),Description="Penguin Bus - block-built penguin collection car",DraftDescription="autobus w kształcie pingwina"},
 {Id="n11_ice_crystal_coupe",Name="Ice Crystal Coupe",Rarity=4,Weight=1,Style=42,Kind="coupe",Color=Color3.fromHex("B5EFF4"),Description="Ice Crystal Coupe - block-built coupe collection car",DraftDescription="przezroczyste auto z kryształu lodu"},
}}
Catalog.Biomes[7]={Name="Sports Track",MinPower=1400,BaseIncome=5500,Color=Color3.fromHex("A66860"),Prop="race",Cars={
 {Id="n11_street_coupe",Name="Street Coupe",Rarity=1,Weight=1,Style=43,Kind="coupe",Color=Color3.fromHex("D05247"),Description="Street Coupe - block-built coupe collection car",DraftDescription="niskie coupe z małym spoilerem"},
 {Id="n11_rally_hatch",Name="Rally Hatch",Rarity=1,Weight=1,Style=44,Kind="hatch",Color=Color3.fromHex("F1F0D2"),Description="Rally Hatch - block-built hatch collection car",DraftDescription="hatchback w naklejkach rajdowych"},
 {Id="n11_drift_kart",Name="Drift Kart",Rarity=1,Weight=1,Style=45,Kind="kart",Color=Color3.fromHex("8D58C7"),Description="Drift Kart - block-built kart collection car",DraftDescription="gokart z dymiącymi oponami"},
 {Id="n11_muscle_beast",Name="Muscle Beast",Rarity=2,Weight=1,Style=46,Kind="coupe",Color=Color3.fromHex("414654"),Description="Muscle Beast - block-built coupe collection car",DraftDescription="muscle car z wlotem na masce"},
 {Id="n11_twin_turbo_gt",Name="Twin Turbo GT",Rarity=2,Weight=1,Style=47,Kind="coupe",Color=Color3.fromHex("2F9CBA"),Description="Twin Turbo GT - block-built coupe collection car",DraftDescription="szerokie GT z dwiema turbinami"},
 {Id="n11_formula_rocket",Name="Formula Rocket",Rarity=3,Weight=1,Style=48,Kind="formula",Color=Color3.fromHex("D23B43"),Description="Formula Rocket - block-built formula collection car",DraftDescription="bolid wyścigowy"},
 {Id="n11_nitro_dragster",Name="Nitro Dragster",Rarity=3,Weight=1,Style=49,Kind="dragster",Color=Color3.fromHex("E5A838"),Description="Nitro Dragster - block-built dragster collection car",DraftDescription="dragster z płomieniami z rur"},
 {Id="n11_champion_gt",Name="Champion GT",Rarity=4,Weight=1,Style=50,Kind="coupe",Color=Color3.fromHex("DDB844"),Description="Champion GT - block-built coupe collection car",DraftDescription="złote GT z pucharem na dachu"},
}}
Catalog.Biomes[8]={Name="Millionaire Hills",MinPower=2200,BaseIncome=21000,Color=Color3.fromHex("B8A67A"),Prop="villas",Cars={
 {Id="n11_vintage_roadster",Name="Vintage Roadster",Rarity=1,Weight=1,Style=51,Kind="roadster",Color=Color3.fromHex("72BFC5"),Description="Vintage Roadster - block-built roadster collection car",DraftDescription="stary kabriolet z lat 50"},
 {Id="n11_pool_party_convertible",Name="Pool Party Convertible",Rarity=1,Weight=1,Style=52,Kind="roadster",Color=Color3.fromHex("EC8BAB"),Description="Pool Party Convertible - block-built roadster collection car",DraftDescription="kabriolet z dmuchanym flamingiem"},
 {Id="n11_butler_sedan",Name="Butler Sedan",Rarity=1,Weight=1,Style=53,Kind="sedan",Color=Color3.fromHex("252936"),Description="Butler Sedan - block-built sedan collection car",DraftDescription="czarny sedan z szoferem"},
 {Id="n11_chrome_classic",Name="Chrome Classic",Rarity=2,Weight=1,Style=54,Kind="coupe",Color=Color3.fromHex("C9D4DA"),Description="Chrome Classic - block-built coupe collection car",DraftDescription="klasyk cały w chromie"},
 {Id="n11_yacht_on_wheels",Name="Yacht on Wheels",Rarity=2,Weight=1,Style=55,Kind="yacht",Color=Color3.fromHex("F0ECE0"),Description="Yacht on Wheels - block-built yacht collection car",DraftDescription="mały jacht na kołach"},
 {Id="n11_diamond_limo",Name="Diamond Limo",Rarity=3,Weight=1,Style=56,Kind="limo",Color=Color3.fromHex("92D7EB"),Description="Diamond Limo - block-built limo collection car",DraftDescription="limuzyna wysadzana diamentami"},
 {Id="n11_money_printer_car",Name="Money Printer Car",Rarity=3,Weight=1,Style=57,Kind="sedan",Color=Color3.fromHex("599764"),Description="Money Printer Car - block-built sedan collection car",DraftDescription="auto, z którego wylatują banknoty"},
 {Id="n11_billionaire_blimp_car",Name="Billionaire Blimp-Car",Rarity=4,Weight=1,Style=58,Kind="blimp",Color=Color3.fromHex("AA86D4"),Description="Billionaire Blimp-Car - block-built blimp collection car",DraftDescription="auto z balonem-sterowcem na dachu"},
}}
Catalog.Biomes[9]={Name="Hypercar Island",MinPower=3400,BaseIncome=80000,Color=Color3.fromHex("5BA4B0"),Prop="palms",Cars={
 {Id="n11_hyper_wedge",Name="Hyper Wedge",Rarity=1,Weight=1,Style=59,Kind="wedge",Color=Color3.fromHex("EA644B"),Description="Hyper Wedge - block-built wedge collection car",DraftDescription="płaski klin, bardzo niski"},
 {Id="n11_carbon_arrow",Name="Carbon Arrow",Rarity=1,Weight=1,Style=60,Kind="wedge",Color=Color3.fromHex("272D37"),Description="Carbon Arrow - block-built wedge collection car",DraftDescription="czarne auto z włókna węglowego"},
 {Id="n11_wing_door_gt",Name="Wing Door GT",Rarity=1,Weight=1,Style=61,Kind="wedge",Color=Color3.fromHex("EEBE3C"),Description="Wing Door GT - block-built wedge collection car",DraftDescription="drzwi otwierane do góry"},
 {Id="n11_jet_car",Name="Jet Car",Rarity=2,Weight=1,Style=62,Kind="jet",Color=Color3.fromHex("98AABC"),Description="Jet Car - block-built jet collection car",DraftDescription="auto z silnikiem odrzutowym"},
 {Id="n11_shark_racer",Name="Shark Racer",Rarity=2,Weight=1,Style=63,Kind="shark",Color=Color3.fromHex("649DAE"),Description="Shark Racer - block-built shark collection car",DraftDescription="auto w kształcie rekina"},
 {Id="n11_lightning_hyper",Name="Lightning Hyper",Rarity=3,Weight=1,Style=64,Kind="wedge",Color=Color3.fromHex("63C9EA"),Description="Lightning Hyper - block-built wedge collection car",DraftDescription="auto z błyskawicami wokół kół"},
 {Id="n11_rocket_hypercar",Name="Rocket Hypercar",Rarity=3,Weight=1,Style=65,Kind="rocket",Color=Color3.fromHex("E6ECEA"),Description="Rocket Hypercar - block-built rocket collection car",DraftDescription="auto-rakieta z płomieniem"},
 {Id="n11_infinity_hyper",Name="Infinity Hyper",Rarity=4,Weight=1,Style=66,Kind="wedge",Color=Color3.fromHex("A783E7"),Description="Infinity Hyper - block-built wedge collection car",DraftDescription="świecące tęczowe hiperauto"},
}}
Catalog.Biomes[10]={Name="Future City",MinPower=5000,BaseIncome=300000,Color=Color3.fromHex("585B92"),Prop="neon",Cars={
 {Id="n11_hover_pod",Name="Hover Pod",Rarity=1,Weight=1,Style=67,Kind="pod",Color=Color3.fromHex("9FB5C5"),Description="Hover Pod - block-built pod collection car",DraftDescription="kapsuła unosząca się nad ziemią"},
 {Id="n11_robo_taxi",Name="Robo Taxi",Rarity=1,Weight=1,Style=68,Kind="taxi",Color=Color3.fromHex("F0D45A"),Description="Robo Taxi - block-built taxi collection car",DraftDescription="taksówka bez kierowcy z ekranem-buzią"},
 {Id="n11_neon_bike_car",Name="Neon Bike-Car",Rarity=1,Weight=1,Style=69,Kind="trike",Color=Color3.fromHex("6A65CB"),Description="Neon Bike-Car - block-built trike collection car",DraftDescription="trójkołowiec z neonami"},
 {Id="n11_laser_cruiser",Name="Laser Cruiser",Rarity=2,Weight=1,Style=70,Kind="wedge",Color=Color3.fromHex("B269C7"),Description="Laser Cruiser - block-built wedge collection car",DraftDescription="auto z laserowymi pasami"},
 {Id="n11_hologram_coupe",Name="Hologram Coupe",Rarity=2,Weight=1,Style=71,Kind="coupe",Color=Color3.fromHex("83DEEE"),Description="Hologram Coupe - block-built coupe collection car",DraftDescription="półprzezroczyste auto-hologram"},
 {Id="n11_mech_car",Name="Mech Car",Rarity=3,Weight=1,Style=72,Kind="mech",Color=Color3.fromHex("A9B7BA"),Description="Mech Car - block-built mech collection car",DraftDescription="auto, które stoi na robotycznych nogach"},
 {Id="n11_ufo_car",Name="UFO Car",Rarity=3,Weight=1,Style=73,Kind="ufo",Color=Color3.fromHex("91A5B8"),Description="Wheeled flying saucer with a glass dome",DraftDescription="spodek z kołami"},
 {Id="n11_time_machine",Name="Time Machine",Rarity=4,Weight=1,Style=74,Kind="portal",Color=Color3.fromHex("8C87BF"),Description="Time Machine - block-built portal collection car",DraftDescription="auto z wirującym portalem za sobą"},
}}
Catalog.ComingSoon={{Name="Moon Base",Color=Color3.fromHex("8E91AC")},{Name="Candy Land",Color=Color3.fromHex("E9A4CE")}}
return Catalog

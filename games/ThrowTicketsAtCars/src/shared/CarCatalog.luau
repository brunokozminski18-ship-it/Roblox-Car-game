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
 {Id="n18_bathtub_buggy",Name="Bathtub Buggy",Rarity=2,Weight=1,Style=75,Kind="buggy",Color=Color3.fromHex("E8E8E0"),Description="Bathtub on wheels with a shower-head antenna",DraftDescription="Bathtub on wheels with a shower-head antenna"},
 {Id="n18_crane_claw_car",Name="Crane Claw Car",Rarity=3,Weight=1,Style=76,Kind="truck",Color=Color3.fromHex("D9A83B"),Description="Small car with a crane and grabber claw on the roof",DraftDescription="Small car with a crane and grabber claw on the roof"},
}}
Catalog.Biomes[2]={Name="Suburbs",MinPower=50,BaseIncome=5,Color=Color3.fromHex("7A996F"),Prop="houses",Cars={
 {Id="n11_grandma_sedan",Name="Grandma Sedan",Rarity=1,Weight=1,Style=7,Kind="sedan",Color=Color3.fromHex("D4BD91"),Description="Grandma Sedan - block-built sedan collection car",DraftDescription="beżowy sedan, serwetka na desce, max 20 km/h"},
 {Id="n11_soccer_mom_van",Name="Soccer Mom Van",Rarity=1,Weight=1,Style=8,Kind="van",Color=Color3.fromHex("8FBECE"),Description="Soccer Mom Van - block-built van collection car",DraftDescription="minivan z naklejkami \"my kid is…\""},
 {Id="n11_lawn_mower_kart",Name="Lawn Mower Kart",Rarity=1,Weight=1,Style=9,Kind="kart",Color=Color3.fromHex("7CB548"),Description="Lawn Mower Kart - block-built kart collection car",DraftDescription="kosiarka-gokart"},
 {Id="n11_ice_cream_truck",Name="Ice Cream Truck",Rarity=2,Weight=1,Style=10,Kind="truck",Color=Color3.fromHex("A8DDEC"),Description="Ice Cream Truck - block-built truck collection car",DraftDescription="wóz z wielkim rożkiem na dachu"},
 {Id="n11_pizza_delivery_bug",Name="Pizza Delivery Bug",Rarity=3,Weight=1,Style=11,Kind="hatch",Color=Color3.fromHex("E2AA48"),Description="Pizza Delivery Bug - block-built hatch collection car",DraftDescription="małe autko z ogromną pizzą zamiast dachu"},
 {Id="n11_grandma_s_rocket",Name="Grandma's Rocket",Rarity=4,Weight=1,Style=12,Kind="rocket",Color=Color3.fromHex("D4BD91"),Description="Beige sedan with twin rear rocket engines",DraftDescription="ten sam beżowy sedan, ale z silnikiem rakietowym z tyłu"},
 {Id="n18_mail_van",Name="Mail Van",Rarity=2,Weight=1,Style=77,Kind="van",Color=Color3.fromHex("3E6FB0"),Description="Small mail van with parcels on the roof",DraftDescription="Small mail van with parcels on the roof"},
 {Id="n18_bbq_grill_racer",Name="BBQ Grill Racer",Rarity=3,Weight=1,Style=78,Kind="cart",Color=Color3.fromHex("3B3B3F"),Description="Rolling barbecue with a smoking chimney",DraftDescription="Rolling barbecue with a smoking chimney"},
}}
Catalog.Biomes[3]={Name="Downtown",MinPower=150,BaseIncome=22,Color=Color3.fromHex("708499"),Prop="towers",Cars={
 {Id="n11_yellow_cab",Name="Yellow Cab",Rarity=1,Weight=1,Style=13,Kind="taxi",Color=Color3.fromHex("F2BE36"),Description="Yellow Cab - block-built taxi collection car",DraftDescription="taksówka z kogutem TAXI"},
 {Id="n11_city_bus",Name="City Bus",Rarity=1,Weight=1,Style=14,Kind="bus",Color=Color3.fromHex("41A6B7"),Description="City Bus - block-built bus collection car",DraftDescription="długi autobus, za długi na jedno miejsce"},
 {Id="n11_food_truck",Name="Food Truck",Rarity=1,Weight=1,Style=15,Kind="truck",Color=Color3.fromHex("C35B47"),Description="Food Truck - block-built truck collection car",DraftDescription="buda z hot dogiem na dachu"},
 {Id="n11_cop_cruiser",Name="Cop Cruiser",Rarity=2,Weight=1,Style=16,Kind="sedan",Color=Color3.fromHex("2B3D67"),Description="Cop Cruiser - block-built sedan collection car",DraftDescription="radiowóz z migającymi światłami"},
 {Id="n11_stretch_limo",Name="Stretch Limo",Rarity=2,Weight=1,Style=17,Kind="limo",Color=Color3.fromHex("303748"),Description="Stretch Limo - block-built limo collection car",DraftDescription="absurdalnie długa limuzyna"},
 {Id="n11_double_decker",Name="Double-Decker",Rarity=3,Weight=1,Style=18,Kind="bus",Color=Color3.fromHex("C9574E"),Description="Double-Decker - block-built bus collection car",DraftDescription="piętrowy autobus z basenem na górze"},
 {Id="n11_mayor_s_golden_limo",Name="Mayor's Golden Limo",Rarity=4,Weight=1,Style=19,Kind="limo",Color=Color3.fromHex("E7B43E"),Description="Mayor's Golden Limo - block-built limo collection car",DraftDescription="złota limuzyna z flagami i czerwonym dywanem"},
 {Id="n18_billboard_truck",Name="Billboard Truck",Rarity=3,Weight=1,Style=79,Kind="truck",Color=Color3.fromHex("E9E2D0"),Description="Truck carrying a giant glowing billboard",DraftDescription="Truck carrying a giant glowing billboard"},
}}
Catalog.Biomes[4]={Name="Farm Roads",MinPower=300,BaseIncome=90,Color=Color3.fromHex("859B53"),Prop="farm",Cars={
 {Id="n11_muddy_pickup",Name="Muddy Pickup",Rarity=1,Weight=1,Style=20,Kind="pickup",Color=Color3.fromHex("87613E"),Description="Muddy Pickup - block-built pickup collection car",DraftDescription="pickup cały w błocie, siano na pace"},
 {Id="n11_tiny_tractor",Name="Tiny Tractor",Rarity=1,Weight=1,Style=21,Kind="tractor",Color=Color3.fromHex("C54437"),Description="Tiny Tractor - block-built tractor collection car",DraftDescription="mały czerwony traktor"},
 {Id="n11_hay_wagon",Name="Hay Wagon",Rarity=1,Weight=1,Style=22,Kind="wagon",Color=Color3.fromHex("C69746"),Description="Hay Wagon - block-built wagon collection car",DraftDescription="przyczepa z sianem na kołach"},
 {Id="n11_cow_car",Name="Cow Car",Rarity=2,Weight=1,Style=23,Kind="sedan",Color=Color3.fromHex("EEE9D9"),Description="Cow Car - block-built sedan collection car",DraftDescription="auto w łaty jak krowa, rogi na masce"},
 {Id="n11_combine_crusher",Name="Combine Crusher",Rarity=3,Weight=1,Style=24,Kind="combine",Color=Color3.fromHex("89AD42"),Description="Combine Crusher - block-built combine collection car",DraftDescription="wielki kombajn z wirującymi ostrzami"},
 {Id="n11_chicken_coop_racer",Name="Chicken Coop Racer",Rarity=3,Weight=1,Style=25,Kind="coop",Color=Color3.fromHex("BD7847"),Description="Chicken Coop Racer - block-built coop collection car",DraftDescription="kurnik na kołach, kury w oknach"},
 {Id="n11_golden_tractor",Name="Golden Tractor",Rarity=4,Weight=1,Style=26,Kind="tractor",Color=Color3.fromHex("E8BA3F"),Description="Golden Tractor - block-built tractor collection car",DraftDescription="złoty traktor ze świecącymi kołami"},
 {Id="n18_milk_tanker",Name="Milk Tanker",Rarity=2,Weight=1,Style=80,Kind="truck",Color=Color3.fromHex("F2F2EE"),Description="Tanker shaped like a milk bottle",DraftDescription="Tanker shaped like a milk bottle"},
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
Catalog.Biomes[11]={Name="Moon Base",MinPower=7000,BaseIncome=720000,Color=Color3.fromHex("8E91AC"),Prop="moon",Cars={
 {Id="n18_moon_buggy",Name="Moon Buggy",Rarity=1,Weight=1,Style=81,Kind="buggy",Color=Color3.fromHex("C9CCD6"),Description="Open rover with a dish antenna",DraftDescription="Open rover with a dish antenna"},
 {Id="n18_crater_hopper",Name="Crater Hopper",Rarity=1,Weight=1,Style=82,Kind="pod",Color=Color3.fromHex("A7B0C4"),Description="Small car on springs instead of wheels",DraftDescription="Small car on springs instead of wheels"},
 {Id="n18_satellite_van",Name="Satellite Van",Rarity=1,Weight=1,Style=83,Kind="van",Color=Color3.fromHex("D8D8E2"),Description="Van with a satellite dish",DraftDescription="Van with a satellite dish"},
 {Id="n18_alien_taxi",Name="Alien Taxi",Rarity=2,Weight=1,Style=84,Kind="taxi",Color=Color3.fromHex("7FD36B"),Description="Green taxi with antennae",DraftDescription="Green taxi with antennae"},
 {Id="n18_lunar_rover",Name="Lunar Rover",Rarity=2,Weight=1,Style=85,Kind="truck",Color=Color3.fromHex("E2E4EA"),Description="Six-wheel rover with solar panels",DraftDescription="Six-wheel rover with solar panels"},
 {Id="n18_rocket_limo",Name="Rocket Limo",Rarity=3,Weight=1,Style=86,Kind="limo",Color=Color3.fromHex("E6E8F0"),Description="Limousine with a rocket on the roof",DraftDescription="Limousine with a rocket on the roof"},
 {Id="n18_astro_tow_truck",Name="Astro Tow Truck",Rarity=3,Weight=1,Style=87,Kind="truck",Color=Color3.fromHex("F0A33C"),Description="Tow truck with a robot arm",DraftDescription="Tow truck with a robot arm"},
 {Id="n18_moonwalker_mech",Name="Moonwalker Mech",Rarity=4,Weight=1,Style=88,Kind="mech",Color=Color3.fromHex("B9C3E6"),Description="Car that walks on four legs",DraftDescription="Car that walks on four legs"},
}}
Catalog.Biomes[12]={Name="Candy Land",MinPower=9500,BaseIncome=1700000,Color=Color3.fromHex("E9A4CE"),Prop="candy",Cars={
 {Id="n18_gumdrop_coupe",Name="Gumdrop Coupe",Rarity=1,Weight=1,Style=89,Kind="coupe",Color=Color3.fromHex("F06B9A"),Description="Round coupe made of jelly",DraftDescription="Round coupe made of jelly"},
 {Id="n18_lollipop_kart",Name="Lollipop Kart",Rarity=1,Weight=1,Style=90,Kind="kart",Color=Color3.fromHex("F2C94C"),Description="Kart with a lollipop steering wheel",DraftDescription="Kart with a lollipop steering wheel"},
 {Id="n18_wafer_wagon",Name="Wafer Wagon",Rarity=1,Weight=1,Style=91,Kind="wagon",Color=Color3.fromHex("D9B27C"),Description="Estate car built from wafers",DraftDescription="Estate car built from wafers"},
 {Id="n18_donut_car",Name="Donut Car",Rarity=2,Weight=1,Style=92,Kind="pod",Color=Color3.fromHex("E89BC0"),Description="Donut-shaped car with sprinkles",DraftDescription="Donut-shaped car with sprinkles"},
 {Id="n18_cupcake_cruiser",Name="Cupcake Cruiser",Rarity=2,Weight=1,Style=93,Kind="pod",Color=Color3.fromHex("F5D6E3"),Description="Cupcake on wheels with a cherry",DraftDescription="Cupcake on wheels with a cherry"},
 {Id="n18_chocolate_tank",Name="Chocolate Tank",Rarity=3,Weight=1,Style=94,Kind="tank",Color=Color3.fromHex("6B4430"),Description="Tank-car made of chocolate bars",DraftDescription="Tank-car made of chocolate bars"},
 {Id="n18_cake_on_wheels",Name="Cake on Wheels",Rarity=3,Weight=1,Style=95,Kind="bus",Color=Color3.fromHex("F7E1C8"),Description="Layered cake with candles",DraftDescription="Layered cake with candles"},
 {Id="n18_sugar_rush_gt",Name="Sugar Rush GT",Rarity=4,Weight=1,Style=96,Kind="wedge",Color=Color3.fromHex("F25FA8"),Description="Rainbow GT made of candy",DraftDescription="Rainbow GT made of candy"},
}}
Catalog.Biomes[13]={Name="Volcano Road",MinPower=12500,BaseIncome=4100000,Color=Color3.fromHex("5A3B36"),Prop="volcano",Cars={
 {Id="n18_ash_hauler",Name="Ash Hauler",Rarity=1,Weight=1,Style=97,Kind="rig",Color=Color3.fromHex("7C7C80"),Description="Grey dump truck covered in ash",DraftDescription="Grey dump truck covered in ash"},
 {Id="n18_basalt_buggy",Name="Basalt Buggy",Rarity=1,Weight=1,Style=98,Kind="buggy",Color=Color3.fromHex("3E3E44"),Description="Buggy carved from black stone",DraftDescription="Buggy carved from black stone"},
 {Id="n18_ember_hatch",Name="Ember Hatch",Rarity=1,Weight=1,Style=99,Kind="hatch",Color=Color3.fromHex("8A3A2A"),Description="Hatchback with glowing cracks",DraftDescription="Hatchback with glowing cracks"},
 {Id="n18_magma_pickup",Name="Magma Pickup",Rarity=2,Weight=1,Style=100,Kind="pickup",Color=Color3.fromHex("D9531E"),Description="Pickup with lava in the bed",DraftDescription="Pickup with lava in the bed"},
 {Id="n18_lava_surfer",Name="Lava Surfer",Rarity=2,Weight=1,Style=101,Kind="wedge",Color=Color3.fromHex("F07A1F"),Description="Flat car like a board on lava",DraftDescription="Flat car like a board on lava"},
 {Id="n18_obsidian_coupe",Name="Obsidian Coupe",Rarity=3,Weight=1,Style=102,Kind="coupe",Color=Color3.fromHex("1E1B24"),Description="Glossy coupe of volcanic glass",DraftDescription="Glossy coupe of volcanic glass"},
 {Id="n18_fire_truck_inferno",Name="Fire Truck Inferno",Rarity=3,Weight=1,Style=103,Kind="truck",Color=Color3.fromHex("C8302A"),Description="Fire truck that sprays flames",DraftDescription="Fire truck that sprays flames"},
 {Id="n18_volcano_king",Name="Volcano King",Rarity=4,Weight=1,Style=104,Kind="monster",Color=Color3.fromHex("B5402A"),Description="Car with a small volcano on the roof",DraftDescription="Car with a small volcano on the roof"},
}}
Catalog.Biomes[14]={Name="Toy Town",MinPower=16500,BaseIncome=10000000,Color=Color3.fromHex("F2D06B"),Prop="toys",Cars={
 {Id="n18_wind_up_car",Name="Wind-Up Car",Rarity=1,Weight=1,Style=105,Kind="hatch",Color=Color3.fromHex("D7DCE3"),Description="Tin car with a wind-up key",DraftDescription="Tin car with a wind-up key"},
 {Id="n18_building_block_van",Name="Building Block Van",Rarity=1,Weight=1,Style=106,Kind="van",Color=Color3.fromHex("E5483F"),Description="Van built from giant blocks",DraftDescription="Van built from giant blocks"},
 {Id="n18_rubber_duck_car",Name="Rubber Duck Car",Rarity=1,Weight=1,Style=107,Kind="pod",Color=Color3.fromHex("F5D33F"),Description="Yellow duck on wheels",DraftDescription="Yellow duck on wheels"},
 {Id="n18_toy_train_car",Name="Toy Train Car",Rarity=2,Weight=1,Style=108,Kind="bus",Color=Color3.fromHex("3F7FD9"),Description="Toy train wagon on wheels",DraftDescription="Toy train wagon on wheels"},
 {Id="n18_teddy_truck",Name="Teddy Truck",Rarity=2,Weight=1,Style=109,Kind="truck",Color=Color3.fromHex("B5835A"),Description="Truck driven by a teddy bear",DraftDescription="Truck driven by a teddy bear"},
 {Id="n18_rc_monster",Name="RC Monster",Rarity=3,Weight=1,Style=110,Kind="monster",Color=Color3.fromHex("4CBF5A"),Description="Remote-control car with an antenna",DraftDescription="Remote-control car with an antenna"},
 {Id="n18_spring_box_racer",Name="Spring Box Racer",Rarity=3,Weight=1,Style=111,Kind="cart",Color=Color3.fromHex("9B59D0"),Description="Box with a spring clown that pops out",DraftDescription="Box with a spring clown that pops out"},
 {Id="n18_toy_box_titan",Name="Toy Box Titan",Rarity=4,Weight=1,Style=112,Kind="tank",Color=Color3.fromHex("E79A3B"),Description="Giant toy chest on tracks",DraftDescription="Giant toy chest on tracks"},
}}
Catalog.Biomes[15]={Name="Haunted Highway",MinPower=21500,BaseIncome=23900000,Color=Color3.fromHex("3C3355"),Prop="haunted",Cars={
 {Id="n18_ghost_hatch",Name="Ghost Hatch",Rarity=1,Weight=1,Style=113,Kind="hatch",Color=Color3.fromHex("D9E6EE"),Description="See-through ghost car",DraftDescription="See-through ghost car"},
 {Id="n18_pumpkin_coupe",Name="Pumpkin Coupe",Rarity=1,Weight=1,Style=114,Kind="pod",Color=Color3.fromHex("E8822F"),Description="Car made from a giant pumpkin",DraftDescription="Car made from a giant pumpkin"},
 {Id="n18_bat_van",Name="Bat Van",Rarity=1,Weight=1,Style=115,Kind="van",Color=Color3.fromHex("2A2633"),Description="Black van with bat wings",DraftDescription="Black van with bat wings"},
 {Id="n18_hearse_hot_rod",Name="Hearse Hot Rod",Rarity=2,Weight=1,Style=116,Kind="limo",Color=Color3.fromHex("1F1C24"),Description="Hearse with flame paint",DraftDescription="Hearse with flame paint"},
 {Id="n18_skeleton_buggy",Name="Skeleton Buggy",Rarity=2,Weight=1,Style=117,Kind="buggy",Color=Color3.fromHex("E9E4D8"),Description="Buggy built from bones",DraftDescription="Buggy built from bones"},
 {Id="n18_witch_broom_racer",Name="Witch Broom Racer",Rarity=3,Weight=1,Style=118,Kind="formula",Color=Color3.fromHex("6B3FA0"),Description="Racer with a broom for a spoiler",DraftDescription="Racer with a broom for a spoiler"},
 {Id="n18_haunted_mansion_truck",Name="Haunted Mansion Truck",Rarity=3,Weight=1,Style=119,Kind="rig",Color=Color3.fromHex("4A4560"),Description="Truck carrying a haunted house",DraftDescription="Truck carrying a haunted house"},
 {Id="n18_phantom_king",Name="Phantom King",Rarity=4,Weight=1,Style=120,Kind="coupe",Color=Color3.fromHex("7CF29A"),Description="Glowing green phantom car with a crown",DraftDescription="Glowing green phantom car with a crown"},
}}
Catalog.Biomes[16]={Name="Dino Valley",MinPower=28000,BaseIncome=57300000,Color=Color3.fromHex("7A8F4A"),Prop="dino",Cars={
 {Id="n18_stone_wheel_cart",Name="Stone Wheel Cart",Rarity=1,Weight=1,Style=121,Kind="cart",Color=Color3.fromHex("8F8778"),Description="Cart with stone wheels",DraftDescription="Cart with stone wheels"},
 {Id="n18_fossil_jeep",Name="Fossil Jeep",Rarity=1,Weight=1,Style=122,Kind="pickup",Color=Color3.fromHex("B49B6E"),Description="Off-roader with bones on the hood",DraftDescription="Off-roader with bones on the hood"},
 {Id="n18_fern_buggy",Name="Fern Buggy",Rarity=1,Weight=1,Style=123,Kind="buggy",Color=Color3.fromHex("5C8F45"),Description="Buggy covered in fern leaves",DraftDescription="Buggy covered in fern leaves"},
 {Id="n18_egg_pod",Name="Egg Pod",Rarity=2,Weight=1,Style=124,Kind="pod",Color=Color3.fromHex("EDE3C8"),Description="Car shaped like a giant egg",DraftDescription="Car shaped like a giant egg"},
 {Id="n18_amber_coupe",Name="Amber Coupe",Rarity=2,Weight=1,Style=125,Kind="coupe",Color=Color3.fromHex("E3A23A"),Description="Amber car with a bug inside",DraftDescription="Amber car with a bug inside"},
 {Id="n18_raptor_racer",Name="Raptor Racer",Rarity=3,Weight=1,Style=126,Kind="wedge",Color=Color3.fromHex("6F8C3A"),Description="Car with a raptor head and tail",DraftDescription="Car with a raptor head and tail"},
 {Id="n18_dino_hauler",Name="Dino Hauler",Rarity=3,Weight=1,Style=127,Kind="rig",Color=Color3.fromHex("8E6E4A"),Description="Truck with a dinosaur in the back",DraftDescription="Truck with a dinosaur in the back"},
 {Id="n18_rex_rig",Name="Rex Rig",Rarity=4,Weight=1,Style=128,Kind="monster",Color=Color3.fromHex("5F7A35"),Description="Huge truck shaped like a dinosaur king",DraftDescription="Huge truck shaped like a dinosaur king"},
}}
Catalog.Biomes[17]={Name="Ocean Floor",MinPower=36000,BaseIncome=137600000,Color=Color3.fromHex("2F6F8F"),Prop="ocean",Cars={
 {Id="n18_bubble_car",Name="Bubble Car",Rarity=1,Weight=1,Style=129,Kind="pod",Color=Color3.fromHex("9ED8EA"),Description="Car inside a glass bubble",DraftDescription="Car inside a glass bubble"},
 {Id="n18_coral_hatch",Name="Coral Hatch",Rarity=1,Weight=1,Style=130,Kind="hatch",Color=Color3.fromHex("E9765F"),Description="Hatchback covered in coral",DraftDescription="Hatchback covered in coral"},
 {Id="n18_diver_van",Name="Diver Van",Rarity=1,Weight=1,Style=131,Kind="van",Color=Color3.fromHex("C9A24A"),Description="Van with a diving helmet",DraftDescription="Van with a diving helmet"},
 {Id="n18_submarine_sedan",Name="Submarine Sedan",Rarity=2,Weight=1,Style=132,Kind="sedan",Color=Color3.fromHex("F2C230"),Description="Sedan-submarine with a periscope",DraftDescription="Sedan-submarine with a periscope"},
 {Id="n18_jellyfish_cruiser",Name="Jellyfish Cruiser",Rarity=2,Weight=1,Style=133,Kind="ufo",Color=Color3.fromHex("C79BEA"),Description="Glowing car with tentacles",DraftDescription="Glowing car with tentacles"},
 {Id="n18_reef_shark_racer",Name="Reef Shark Racer",Rarity=3,Weight=1,Style=134,Kind="shark",Color=Color3.fromHex("5C7C8F"),Description="Car with a shark fin and teeth",DraftDescription="Car with a shark fin and teeth"},
 {Id="n18_treasure_chest_truck",Name="Treasure Chest Truck",Rarity=3,Weight=1,Style=135,Kind="truck",Color=Color3.fromHex("B5823A"),Description="Truck with a treasure chest",DraftDescription="Truck with a treasure chest"},
 {Id="n18_kraken_car",Name="Kraken Car",Rarity=4,Weight=1,Style=136,Kind="monster",Color=Color3.fromHex("8E3F6B"),Description="Car wrapped in kraken tentacles",DraftDescription="Car wrapped in kraken tentacles"},
}}
Catalog.Biomes[18]={Name="Cosmic Highway",MinPower=46000,BaseIncome=330200000,Color=Color3.fromHex("1E1A3C"),Prop="cosmic",Cars={
 {Id="n18_comet_coupe",Name="Comet Coupe",Rarity=1,Weight=1,Style=137,Kind="coupe",Color=Color3.fromHex("5FA8F0"),Description="Coupe with a fiery comet tail",DraftDescription="Coupe with a fiery comet tail"},
 {Id="n18_star_hatch",Name="Star Hatch",Rarity=1,Weight=1,Style=138,Kind="hatch",Color=Color3.fromHex("F2D96B"),Description="Hatchback covered in stars",DraftDescription="Hatchback covered in stars"},
 {Id="n18_planet_pod",Name="Planet Pod",Rarity=1,Weight=1,Style=139,Kind="ufo",Color=Color3.fromHex("D98C5F"),Description="Round capsule with a ring",DraftDescription="Round capsule with a ring"},
 {Id="n18_nebula_cruiser",Name="Nebula Cruiser",Rarity=2,Weight=1,Style=140,Kind="wedge",Color=Color3.fromHex("9A5FD9"),Description="Car in nebula colours",DraftDescription="Car in nebula colours"},
 {Id="n18_meteor_truck",Name="Meteor Truck",Rarity=2,Weight=1,Style=141,Kind="truck",Color=Color3.fromHex("6E5E52"),Description="Truck carrying a meteorite",DraftDescription="Truck carrying a meteorite"},
 {Id="n18_black_hole_racer",Name="Black Hole Racer",Rarity=3,Weight=1,Style=142,Kind="portal",Color=Color3.fromHex("15131F"),Description="Black car with a spinning portal",DraftDescription="Black car with a spinning portal"},
 {Id="n18_galaxy_limo",Name="Galaxy Limo",Rarity=3,Weight=1,Style=143,Kind="limo",Color=Color3.fromHex("2B2560"),Description="Limousine with constellations in the windows",DraftDescription="Limousine with constellations in the windows"},
 {Id="n18_infinity_engine",Name="Infinity Engine",Rarity=4,Weight=1,Style=144,Kind="jet",Color=Color3.fromHex("F2F2FF"),Description="Car with an energy ring and three engines",DraftDescription="Car with an energy ring and three engines"},
}}
Catalog.ComingSoon={{Name="Moon Base",Color=Color3.fromHex("8E91AC")},{Name="Candy Land",Color=Color3.fromHex("E9A4CE")}}
return Catalog

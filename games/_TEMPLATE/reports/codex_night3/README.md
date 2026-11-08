# Noc 3 — 31.10.2026
Status: IMPLEMENTED, NOT FINAL; Roblox runtime: reviewed, not run.

## Pety i jaja
- LihFolk EggHatch + Odds; 3 jaja za niepłatne Cash, po 4 pety, szanse 55/28/13/4%.
- Serwer kontroluje losowanie, koszt, profil, żywą postać, odblokowany świat i odległość ≤12 studs; Net waliduje ID/liczbę i ogranicza żądania.
- Prompt „View odds” na starcie świata; minimalne okno szans PRZED zakupem, wynik pushem, cel „Open an egg at the start!”.
- Inventory zachowuje 3 sloty; Index już śledzi Pet1–Pet12, bez nowej logiki odkryć.
- Mnożnik Power = min(2.2, 1 + suma(power−1)) × gear × Rebirth przez Currency.AddMultiplier; globalny limit pozostaje 1000.
- Suma bonusów ogranicza skok po trzecim pecie (LihFolk Vault V2, 48, Pricing Curves and Upgrade Costs: stacking i limity).
- Nowy slice Eggs: Pity/Obtained/Boosts/Hatched; PlayerData dodaje domyślne wartości przy wczytaniu, istniejących pól nie zmieniamy.

## Ikony
- Blender 5.2 headless: 25 PNG 512×512, w tym gift; 6 gear, 3 waluty, 7 menu, 3 jaja, 5 petów.
- Rig, kamera, światła i materiały gift zachowane; nowe modele z prymitywów, bez Internetu.
- Arkusz 256/64 px na jasnym i ciemnym tle: [_sheet.png](_sheet.png); szybki podgląd: [icons_64.png](icons_64.png).
- Obejrzano 64 px; poprawiono rozłączone zęby settings i strzałkę rebirth; pety mają uszy misia/królika/kota, oczy żaby i ryjek.
- Pięć PNG petów skopiowano do content/textures/plus1_glossy znalezionej instalacji Studio, bez uruchamiania Studio.
- Karty Inventory/Index biorą config.previewImage; na innym komputerze trzeba skopiować podglądy, do publikacji potrzebne ID właściciela.

## Ekonomia — symulacja, NOT FINAL
- Źródła: LihFolk Vault V2, 48: Pricing Curves and Upgrade Costs oraz Simulating an Economy Before Launch; playbook/ECONOMY.
- Python czyta GameConfig: 16 studs/s, tick 0.25 s, zaokrąglenia Earn, dojścia/powroty, cooldown ścian 3 s, zakupy i losowe pety.
- Polityka: kolejny gear, do 3 jaj/świat, najlepsze 3 pety; Rebirth, gdy odbudowa od zera skraca czas do następnego bossa.
- Bazowo bez Robux, Daily, zadań i kodów; osobno wariant bez jaj i z pierwszym Daily.
- Seed 42: nagroda 4.5 s, Gloves 18.5 s, jajo 39.5 s; boss/świat 2: 22.74 min, boss/świat 3: 46.07 min, finał 84.43 min.
- Seeds 1/42/99: boss 1 z petami 20.78–24.09 min; bez jaj 27.73 min; finał bez jaj 149.32 min.
- Najdłuższa przerwa między progami: 3.12 min z petami, 3.90 min bez jaj; z pierwszym Daily boss 1: 21.55 min.
- Wszystkie pierwsze formy/ściany/bossowie/światy i zakupy: [economy.csv](economy.csv); [wykres Power/czas](economy.png).
- Gloves x2→x1.5 zmniejsza początkowe przyspieszenie, zachowując szybki zakup.
- Boots x4→x2 zostawia miejsce na bonus petów bez pomijania pierwszych ścian.
- Belt x10→x3 utrzymuje kolejne progi w zasięgu kilku minut.
- Cape x25→x4 hamuje skok prędkości przed piątą ścianą.
- Crown x60→x6 zapewnia przyrost bez skrócenia bossa do kilku minut.
- Halo x150→x8 ogranicza koniec świata 1; ceny wszystkich gear pozostają bez zmian.
- Boss 1 60K→75K daje margines do celu 20–40 min przy lepszych rzutach w testowanych seedach.
- Skale światów 40/1500→4/12 i bossowie 4M/200M→240K/700K pozwalają je ukończyć bez Robux przy nowych mnożnikach.
- Rebirth baseCost 5K→40K ogranicza wczesne resety; growth=2 i bonus=0.5 zachowane.
- Dodatkowe progi form 15K–695K i uporządkowane nazwy Level skracają przerwy; rozmiar pozostaje ≤2.2.
- Jaja 35/700/3000 Cash dają wczesny zakup i rosnący koszt; power 1+j×0.1+(świat−1)×0.1 i cap2.2 ograniczają stacking.

## Faktycznie sprawdzone
- PASS: rojo build template/default.project.json do %TEMP% po częściach 1/2/3; końcowy build ponowiony po przeglądzie.
- PASS: Python — odtworzone formFor/wallStats/mnożnik petów, granice Odds i 100K rzutów z testem chi-kwadrat.
- PASS: asercje tempa dla 3 seedów z jajami i bez, wszystkie 15 ścian i 3 bossów; wariant Daily.
- Odtworzenie dotyczy używanego configu: 1 pet/tier, bez pity/luck; NIE uruchomiono speców Luau ani kodu serwera.
- Ponownie przeczytano zmienione skrypty i wiring; build Rojo pakuje kod, nie dowodzi poprawności wykonania Luau.
- NEEDS VERIFICATION: wygląd, telefon/dotyk, multiplayer, kolizje, zapis/rejoin i starsze profile; model upraszcza ruch i czas obsługi UI.
- Ryzyka: farming Cash co 3 s (istniejący), brak mocnego endgame sinka, po skali 2.2 formy głównie liczbowe; symulacja nie dowodzi zabawy.

## Zmienione pliki (ścieżki od vaulta)
- template/src/server/{Main.server.luau,LihFolk/EggHatch.luau,Services/Eggs.luau}; template/src/shared/{GameConfig.luau,LihFolk/Odds.luau}.
- template/src/client/{EggsMenu,PlusOne,InventoryMenu,IndexMenu}.client.luau; template/README.md.
- template/art/icons/{render_glossy.py,contact_sheet.py,glossy/*.png}; research/plus1_economy_sim.py; niniejszy folder raportu.
- Zewnętrznie: 5 lokalnych PNG w instalacji Studio; LihFolk i chronione foldery bez zmian; bez commitów/publikacji/zakupów.

## Rano — 3 testy w Studio
1. Telefon poziomo: prompt → szanse → hatch → Inventory/equip/unequip → Power i Index; czytelność kart i zamykanie okna.
2. Dwie osoby: zablokowany świat, hatch z daleka, spam, brak Cash i pełna torba — brak potrąceń/nagród przy odmowie.
3. Save/rejoin starego i nowego profilu: pety, sloty, Eggs, Rebirth, boss → świat; realny czas pierwszego bossa.

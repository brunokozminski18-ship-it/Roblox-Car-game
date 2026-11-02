# Start — THROW TICKETS AT CARS!

## Test w 2 minuty
1. Play. Stań na białej linii przy starcie.
2. Celuj przeciągając ekran telefonu; PC: prawy przycisk + mysz. Zoom: szczypnięcie / kółko.
3. Wciśnij THROW. PC: klik myszą także rzuca w środek ekranu, niezależnie od kursora.
4. Rzuć w drugie bliskie auto, zanim pierwsza laweta wróci. Obserwuj parking i Cash.
5. Włącz TRAIN na ok. 20 sekund. Wyceluj w zielony dach (40 studs) i rzuć.
6. Zapełnij 6 miejsc; kolejny rzut daje Parking full! Stop/Play zeruje sesję.

## Folder i Studio
- Źródło prawdy: src/, wszystkie wartości rozgrywki: src/shared/Config.luau.
- Rojo: uruchom rojo serve default.project.json --port 34873 z folderu gry i połącz plugin.
- Alternatywa MCP: python tools/rojo_snapshot.py → tools/SyncStudio.luau w Edit.
- Import MCP wymaga tymczasowego HttpEnabled; po imporcie można wyłączyć.
- Budowanie bez serwera: python tools/rojo_snapshot.py --build-only.
- Generator sceny jest w src/server/World.luau; scena powstaje przy Play.
- Lokalny build: assets/Prototype.rbxlx (poza gitem, kod bez publikacji).
- Miejsce: 74773184167716. Bez zapisu: Stop/Play usuwa auta i pieniądze.
- Wygląd i balans: NOT FINAL. Test zabawy z 3 ludźmi jeszcze nieodbyty.

[[games/ThrowTicketsAtCars/GAME_DESIGN|Design]] · [[games/ThrowTicketsAtCars/PROGRESS|Stan]] · [[games/ThrowTicketsAtCars/BUGS|Błędy]]

# Start — THROW TICKETS AT CARS!

## Otwieranie
- Pełny lokalny zapis Studio: assets/SavedStudio_2026-11-02.rbxlx.
- Źródłem prawdy pozostaje src/ i Config; mapa generowana z World.luau.
- Najpierw sprawdź CURRENT_TASK i raport iteracji 3.

## Test pętli
1. Play, stań na białej linii. THROW zawsze rzuca wzdłuż drogi; celowanie nie jest potrzebne.
2. Nazwa, rzadkość, mandat i laweta; po cooldownie możesz rzucać ponownie.
3. TRAIN do 50 Power → Suburbs. HUD pokazuje docelowy biom i brak do kolejnego.
4. Parking 6 aut: lepsze wymienia najsłabsze; gorsze/równe sprzedawane za $X.
5. Stop/Play zeruje sesję. Bez DataStore.

## Rojo i testy
- rojo serve default.project.json --port 34873; połącz plugin.
- Alternatywa MCP: python tools/rojo_snapshot.py → tools/SyncStudio.luau w Edit.
- Build: python tools/rojo_snapshot.py --build-only → assets/Prototype.rbxlx.
- tools/PreviewStudio.luau odtwarza podgląd Edit z tego samego World.
- Testy: ClientScenarios w Client, następnie ServerScenarios w Server, na świeżym Play.
- Import usuwa przestarzałe elementy tylko we własnych folderach ThrowTickets; tymczasowy HTTP po pracy wyłączamy.
- Miejsce 74773184167716, bez publikacji.
- Raport: [[games/ThrowTicketsAtCars/reports/2026-11-02_iteration3]].

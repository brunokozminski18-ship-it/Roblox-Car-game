# Start — THROW TICKETS AT CARS!
## Pierwsze minuty
1. Play w miejscu74773184167716, API Services włączone. THROW → laweta → własna działka.
2. Wybierz kartę, podejdź do wolnego miejsca i PLACE. BACK TO ROAD. Złap/postaw pierwsze auta.
3. SHOP → Focused Training ($180), potem TRAIN. Pierwszy zakup w pomiarze71 s, Suburbs po2:31.
4. Mandaty zwiększają luck i dochód nowo złapanych aut. Dystans nadal równy Power.
5. REMOVE/SELL/MY PLOT pozostają dostępne. Stop/Play zachowuje auta, ćwiczenie, mandaty i ułamkowy Power.

## Źródło i kopia
- src/ i Config są źródłem prawdy; 18 plików Rojo. Kopia lokalna assets/SavedStudio_2026-11-03.rbxlx.
- Ceny edytuj jako Minutes/UnlockBiome, nie Price. Referencyjny dochód i tempo ćwiczeń są w Config.Economy.
- Lokalny plik jest kopią kodu/mapy; test API wykonuj w powiązanym miejscu. Duże assets/ poza gitem.
- Wygląd i balans NOT FINAL. Raport: [[games/ThrowTicketsAtCars/reports/2026-11-03_iteration7]].

## Rojo i testy
- rojo serve default.project.json --port34873; alternatywa MCP: python tools/rojo_snapshot.py i tools/SyncStudio.luau w Edit z chwilowym HTTP on.
- Build: python tools/rojo_snapshot.py --build-only. PreviewStudio odtwarza mapę z World.
- QA: ServerStorage.TestProfileKey ustaw w Edit przed Play. Nie resetuj użytkownika podczas testów.
- Server Command Bar w Play: game.ServerStorage.ThrowTicketsQA:Invoke("Reset"), :Invoke("AddCash",1000), :Invoke("AddPower",5).
- Reset zeruje aktywny profil; na potrzeby testu użyj oddzielnego klucza QA. Bindable istnieje tylko w Studio i nie jest widoczny klientowi.
- rules/iteration6/iteration7/profiles.spec:112 asercji. BalanceSimulation(Config,Rules,GarageRules,seed) i pacing.spec(runs,phone):30 seedów/512 kontroli tempa.
- PhonePacing.client.luau uruchamiaj w Client na świeżym QA; potrzebuje VirtualInput. Nie przyznaje zasobów ani nie teleportuje przez QA.
- Helper testu klika lewy fragment, bo CaptureControls może zasłonić środek. Pomiar wyników w atrybucie gracza QAPaceResults.
- Po teście Stop Play, TestProfileKey nil, StopSimulationAsync, HTTP off, Studio Edit. Bez publikacji.

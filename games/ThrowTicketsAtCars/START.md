# Start — THROW TICKETS AT CARS!
## Test w 2 minuty
1. Play w miejscu 74773184167716; API Services włączone. THROW: zamach, lot, trafienie, laweta, teleport na własną działkę.
2. W hotbarze wybierz auto. Podejdź do wolnego miejsca i PLACE; Cash rośnie. REMOVE oddaje auto; SELL sprzedaje wybrane auto z ekwipunku.
3. BACK TO ROAD, TRAIN +1: postać ćwiczy, Power rośnie. THROW podczas transportu jest zablokowany.
4. SHOP: mandat zwiększa tylko luck, dystans pozostaje równy Power. MY PLOT pozwala wrócić bez kolejnego rzutu.
5. Stop/Play: wracają Cash, Power, mandaty, ekwipunek i miejsca aut. Studio używa osobnego magazynu.

## Źródła i kopia
- src/ i Config to źródło prawdy; 18 plików źródłowych. Pełna lokalna kopia: assets/SavedStudio_2026-11-02.rbxlx.
- Test API wykonuj w powiązanym miejscu, nie w nowym nieopublikowanym pliku. Duże assets/ poza gitem.
- Rusty Sedan v2 to jedyny model-próbka; reszta aut jest klockowa. Wygląd/balans NOT FINAL.

## Rojo i QA
- rojo serve default.project.json --port 34873; połącz plugin.
- Alternatywa MCP: python tools/rojo_snapshot.py → tools/SyncStudio.luau w Edit, tymczasowo HTTP on.
- Build: python tools/rojo_snapshot.py --build-only. PreviewStudio odtwarza mapę z World.
- Osobne QA: ServerStorage.TestProfileKey przed Play; dotyczy tylko Studio. Nigdy nie zmieniaj klucza U_ użytkownika w teście.
- Testy reguł: rules.spec(Rules), iteration6.spec(Rules,Config,Schema,GarageRules), profiles.spec(Profiles,Schema); razem 78 asercji.
- Studio-only ServerStorage.ThrowTicketsQA: Inspect, SetCash, SetPower, GiveCar(biom), TeleportSlot(n), Save, Exit. Nie jest dostępne klientowi.
- Historyczny test iteration4b.client obejmuje stany sklepu; bieżący pełny scenariusz i wyniki są w raporcie 6.
- Po teście usuń TestProfileKey, StopSimulationAsync, HTTP off, pozostaw Edit. Bez publikacji.
- Raport: [[games/ThrowTicketsAtCars/reports/2026-11-02_iteration6]].

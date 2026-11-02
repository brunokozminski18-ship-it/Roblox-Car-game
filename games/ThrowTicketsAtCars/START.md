# Start — THROW TICKETS AT CARS!

## Test w 2 minuty
1. Play w otwartym miejscu 74773184167716; API Services jest włączone.
2. THROW kilka razy, zapełnij parking; Cash rośnie. TRAIN możesz włączyć równolegle.
3. Gdy SHOP pulsuje: otwórz, BUY Pink Slip ($100), potem EQUIP; rzut leci 2,5× dalej.
4. Stop/Play: Cash, Power, mandat i parking powinny wrócić. Studio ma osobny magazyn.
5. Rusty Sedan: pierwsze auto widokowe po lewej stronie drogi; jedna próbka, pozostałe są szare.

## Źródła i kopia
- src/ i Config są źródłem prawdy. Pełna lokalna kopia: assets/SavedStudio_2026-11-02.rbxlx.
- Lokalny plik jest kopią mapy i kodu; test API wykonuj w powiązanym miejscu, nie w nowym nieopublikowanym pliku.
- Duże assets/ poza gitem, źródła generatora i modelu w gicie.

## Rojo i QA
- rojo serve default.project.json --port 34873; połącz plugin.
- Alternatywa MCP: python tools/rojo_snapshot.py → tools/SyncStudio.luau w Edit, tymczasowo HTTP on.
- Build: python tools/rojo_snapshot.py --build-only.
- PreviewStudio odtwarza Edit z World; wszystkie 12 źródeł synchronizowane z folderu.
- Świeże QA: ServerStorage.TestProfileKey przed Play; klucz jest czytany tylko w Studio.
- Regresja: ClientScenarios w Client, ServerScenarios w Server; świeży profil, Paper Ticket.
- Asercje: rules/iteration3/iteration4/profiles.spec; ostatnie dwa wymagają ProfileSchema/Profiles.
- Studio-only ServerStorage.ThrowTicketsQA: Inspect, SetCash, SetPower, Save, Exit (ścieżka leave).
- Po teście usuń TestProfileKey, wyłącz emulator i HTTP, zostaw Edit. Bez publikacji.
- Raport: [[games/ThrowTicketsAtCars/reports/2026-11-02_iteration4]].
- Próbki 4b: [[games/ThrowTicketsAtCars/reports/2026-11-02_iteration4b]]; kontrola UI w Client: tests/iteration4b.client.luau.

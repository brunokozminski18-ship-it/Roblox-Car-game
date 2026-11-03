# Start — THROW TICKETS AT CARS!
1. Play w miejscu74773184167716. Podejdź na białą płytkę; tap/klik zatrzymuje TAP TO THROW. Brak tapu3 s daje średni bonus.
2. Po lawecie auto jest Tool w plecaku i hotbarze. Wybierz slot/klawisz1–5; podejdź do wolnego miejsca i przytrzymaj E/Place car0.5 s.
3. Pick up oddaje auto. CARS otwiera My Cars: PLACE wyposaża, PICK UP podnosi w zasięgu, SELL sprzedaje (Epic+ z potwierdzeniem).
4. EQUIP BEST na działce stawia najlepsze6 aut. W oknie widać również auta poza hotbarem.
5. Własna płytka treningu stoi przy działce. SHOP sprzedaje ćwiczenia/mandaty; wracaj na rzut pieszo. Nie ma BACK TO ROAD ani blokady Plot.
6. Mandaty zwiększają luck i dochód nowego auta; pasek daje małą zmianę zasięgu-5%..+10%.

## Źródło i testy
- src/ i Config są źródłem prawdy;24 skrypty Rojo. Build: python tools/rojo_snapshot.py --build-only.
- Rojo serve: default.project.json port34873; fallback: tools/rojo_snapshot.py i tools/SyncStudio.luau w Edit z chwilowym HTTP on.
- PreviewStudio odtwarza mapę z World. Model/gameplay zmieniaj w folderze, nie tylko Studio.
- QA: ServerStorage.TestProfileKey przed Play; osobny profil, nie resetuj danych użytkownika.
- Bindable ThrowTicketsQA tylko Studio: Inspect/Reset/GiveCar/TeleportSlot/Save oraz +Cash/+Power; brak dostępu klienta.
- rules/iteration6/iteration7/iteration8/garage-security/profiles.spec:153 asercje.
- tests/Iteration8.client.luau: trening, rzeczywisty marsz, zielony/czerwony/timeout,40 powtórzeń, bez ustawiania bonusu z klienta.
- Raport: [[games/ThrowTicketsAtCars/reports/2026-11-03_iteration8]]. Ręczny touch-hold nadal NEEDS VERIFICATION.
- Po testach: Edit, StopSimulationAsync, TestProfileKey nil, HTTP off. Nie publikuj bez zgody.
- Trening: wejdź na swoją płytkę; STOP=trening trwa, TRAIN=wznów. SHOP → TRAINING → BUY kupuje i aktywuje wyższe ćwiczenie, każde2× poprzednie. Power rośnie również ułamkowo, HUD pokazuje przyrost co tick.

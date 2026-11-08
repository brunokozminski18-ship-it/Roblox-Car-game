# Raport: serwer pod okna, grafiki, analityka, podpowiedzi — 30–31.10.2026

Bez commitów, publikacji, produktów i passów na koncie. `research/` i `prototypes/` nietknięte. Studio zostało w Edit, emulator wyłączony.

## Zrobione

1. **Poprawki UI** (z poprzedniej tury): jasna aktywna zakładka w kolorze okna, większy i jaśniejszy drobny tekst, większe przyciski HUD na PC, większa strzałka w Rebirth. Dodatkowo: „CLAIMED TODAY” zamiast uciętego „COME BACK…” na telefonie.
2. **Serwer** na modułach LihFolk (`template/src/server`, szczegóły w `template/README.md`): zapis gracza, Cash/Gems, Inventory (EQUIP/UNEQUIP, sloty za Cash), Index (odkrycia, CLAIM nagrody obszaru), Tasks (dzienne/tygodniowe z resetem UTC, postęp tylko z serwera), Daily (seria, CLAIM), Rebirth, kody w sklepie, ustawienia. Każdy remote przez `Net` (typy, zakres, limit szybkości). Robux: config z ID 0, serwer odmawia („Unavailable”) i nie otwiera zakupu. Skrypt demo usunięty; zamiast niego `Income` (+10 Cash/s przez `Currency.Earn`, wyłączany w configu).
3. **Okna** czytają dane z serwera i pokazują wynik w toaście (teksty LihFolk `Feedback`).
4. **Grafiki przedmiotów**: `template/art/items/render_card.py` (Blender, ta sama kamera/światło, przezroczyste tło, sylwetka). Sprawdzone na 8 modelach z CATALOG.csv: Coin_01, Gem_03, Medal_02, Chest_01, Crate_02, Bottle_03, Lantern_04, RoundShield_03 (`item_art_sheet.png`). Wstawione lokalnie do kart Inventory, Index (z sylwetkami), Daily i sklepu.
5. **Analityka** (`Services/Analytics`, wg LihFolk „Analytics and Funnels”): lejek onboardingu z configu, zdarzenia `WindowOpened`, `FirstClaim`, `FirstCurrencyPurchase`, `Rebirth` (zbiorczo co 60 s), ekonomia Source/Sink z powodem. W Studio wypisywane w Output.
6. **Podpowiedzi** (`Services/Hints` + `client/Hints`): kroki z configu, strzałka do przycisku/elementu UI/obiektu w świecie, krótki tekst, krok kończy się zdarzeniem i zapisuje. Przykład: „Open Daily Rewards” → „Claim your reward!”.
7. **Instrukcja** „Nowa gra z szablonu” w `template/README.md`.

## Sprawdzone w Play (31.10.2026)

| Test | Wynik |
| --- | --- |
| Start serwera, 21 remote'ów, brak błędów | OK |
| Daily CLAIM / drugi CLAIM tego dnia | OK / odrzucony `AlreadyClaimed` |
| Kod WELCOME / ponownie / zły kod / 8 złych kodów naraz | OK / `AlreadyRedeemed` / `NotFound` / 3× `NotFound`, 5× `TooFast` |
| Inventory: EQUIP, UNEQUIP (też kliknięciem w oknie), fałszywe uid, zły typ | OK, OK / `Invalid`, `Invalid` |
| Sloty „+” | OK, 20 → 25 |
| Sklep za Cash / za drogo / nieznany przedmiot | OK / `NotEnough` / `Invalid` |
| Robux (produkt, pass z ID 0) | odrzucone `Unavailable`, bez okna zakupu |
| Index CLAIM / drugi / nieukończony obszar | OK (+20 Gems) / `AlreadyClaimed` / `NotComplete` |
| Tasks: postęp z serwera, CLAIM / drugi / nieukończone | OK / `AlreadyClaimed` / `NotComplete` |
| Rebirth bez Cash / z Cash | `NotEnough` / OK: Rebirths 1, Cash 0, mnożnik ×1,5 |
| Settings zapis / nieznany klucz | OK, wraca przez `Settings.Get` / `Invalid` |
| Zły kod w oknie sklepu (klik) | toast + komunikat pod polem (`pc_03`) |
| Telefon (iPhone 17 Pro poziomo): dotknięcie Daily → CLAIM | OK, toast „+500 Cash”, podpowiedź znika (`phone_01–02`) |
| Lejek onboardingu | Joined → Opened Daily → Claimed Daily → First Cash purchase (Output) |
| Grafiki w Index, sylwetki, sklep | OK (`pc_05–07`) |
| **Save/rejoin** (31.10, prawdziwy DataStore `PlayerData_v1_STUDIO`, profil QA `TestProfileKey = "qa"`) | OK: po Stop → Play wróciły pety (4), założony pet, sloty 25, seria Daily, ustawienia, odkrycia Index, Gems; `TestProfileKey` potem usunięty |
| Brak dostępu do API (próba przed włączeniem) | bezpiecznie: profil nie wczytany, nic nie zapisane, gracz wyrzucony z „Nothing was changed” |

## Nie zrobione / nie przetestowane

- Testy multiplayer, gamepad, tablet — nie robione.
- Klikanie każdego przycisku na telefonie — sprawdzony tylko Daily (pozostałe akcje przez te same remote'y na PC; kliknięcia w emulatorze bywają zawodne).
- Ikony i grafiki nie są wgrane do Robloxa (działają tylko w Studio na tym komputerze).
- Grafiki petów to zastępcze rekwizyty — paczka LihFolk nie ma petów.
- Biblioteka LihFolk ma etykietę „reviewed, not run”; nie uruchamiałem jej testów jednostkowych (`tests/Runner`), tylko testy w Play powyżej.

## Uwagi

- Rojo wyłącza się, gdy przeniesie się plik, który obserwuje — po takiej zmianie trzeba go uruchomić ponownie i kliknąć Connect.
- Toast nachodzi lekko na nagłówek otwartego okna (`pc_03`) — do poprawy przy następnej pracy nad UI.
- Ten raport skrócić do wniosków w `PROGRESS`/`lessons` po 7 dniach.

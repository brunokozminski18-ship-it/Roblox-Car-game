# Okna D i Playtime Rewards — 01.11.2026

Status: IMPLEMENTED; technicznie VERIFIED w Play 01.11.2026. Wygląd migracji NOT FINAL do oceny użytkownika.
Wzorzec: zatwierdzony `template/art/ui_mockups/PlaytimeRewardsSample.luau` v3.

## Przerobione okna
- Shop, w tym Codes; Inventory; Index; Tasks; Daily; Rebirth; Settings; Eggs.
- Nowe Playtime Rewards: 8 kart, 4 stany, zegary, PLAYED / NEXT IN, ikona zegara i czerwony „!”.
- Wspólne tokeny StyleD: niebieskie okno, zaokrąglenia, obrysy, Fredoka z cieniem, połysk, pasy, glow, rays i pigułki.
- Okna nadal używają LihFolkUIController: dopasowanie, przyciemnienie, zamykanie i jedno okno naraz.
- HUD: Launcher, CurrencyHud, dolny pasek PlusOne i ich Theme bez zmian. Dodano wyłącznie wpis ikony i wywołanie Launcher.add dla GIFTS.
- Grafiki wyłącznie set_d/items_d/ui_textures, lokalne ścieżki rbxasset://; bez uploadu.

## Playtime Rewards
- Config: `template/src/shared/GameConfig.luau`, `Config.PlaytimeRewards.track` (id/minutes/label/art/reward/featured).
- Progi: 1, 2, 3, 5, 10, 15, 20, 30 min; deterministyczne Cash/Gems, liczby NOT FINAL.
- Serwer `Services/PlaytimeRewards.luau`: Init → RegisterSlice → Net.Handle; os.clock od dołączenia, także podczas zamkniętego okna.
- Get zwraca elapsed/claimed/reset; Claim przyjmuje tylko znane ID. Walidacja, limit wywołań, próg i blokada duplikatu są na serwerze.
- Rewards.CanGrant/Grant i oznaczenie odbioru odbywają się synchronicznie; błąd nie oznacza nagrody jako odebranej.
- Reset sesyjny: nowe wejście zeruje czas i Claimed, również po wczytaniu starej mapy z profilu. UI mówi „Resets when you leave”.
- Wybrano prostszy wariant sesyjny do szablonu. LihFolk pokazuje przykład dzienny z limitem; nie jest to wymóg wszystkich prezentów.
- Źródło zasad: LihFolk Vault V2, „21 LihFolk UI Design System” i „05 UI and UX / Menu Archetypes - Shop Settings Codes Rewards”.

## Sprawdzone
- `rojo build template/default.project.json` PASS; aktualne moduły ładowały się w Play, ponowne przeczytanie kodu i przegląd przez drugiego agenta.
- Studio „New Game”, Rojo 34872, UseMemoryStore=true. Telefon pierwszy: iPhone 7 poziomo, preset 667×375 (viewport silnika 666×374).
- PC: preset 1920×1080 (viewport 1919×1079). Wszystkie okna otwierane realnymi przyciskami; X zamyka, widoczne jedno okno.
- Pomiar: brak przycisków poniżej 44 px; telefon EQUIP 47,38 px i w całości w widocznej części. Treść przewijana, bez zmniejszania tekstu.
- Telefon: 3 kolumny prezentów, przewijana stopka; PC: 4×2 i cała ostatnia karta mieści się nad stopką.
- UI → serwer → UI: CLAIM po minucie, Cash 0→50, zielona karta i check; drugi odbiór AlreadyClaimed, za wcześnie NotEligible.
- Dwa równoczesne Claim Minute2: jeden Ok, drugi AlreadyClaimed; Gems 5→10. Nieznane ID i dodatkowy argument „czas” odrzucone jako Invalid.
- Badge był widoczny po progu; nowa sesja: elapsed około 4 s, puste claimed, Cash 0 / Gems 5.
- Codes STARTERPETS nadał 4 pety; EQUIP podniósł EquippedPets do 1. Eggs: szanse → OPEN ONE → HATCHED, Cash 50→15.
- Poprawki z testów: kompaktowy Inventory, pełna siatka Playtime na PC, stały widoczny punkt fokusu (X).
- Brak błędów skryptów okien. Output nadal zgłasza ostrzeżenia infrastruktury „Script injection failed”, obcego assetu 203785492 i oczekiwane ID produktów 0.
- Po testach: Studio Edit, emulator wyłączony, UseMemoryStore usunięty; bez commitów, publikacji, zakupów ani uploadów.

## Niesprawdzone
- Pełne 30 minut, trwały zapis/rejoin z DataStore, fizyczny telefon, multiplayer, gamepad i balans ekonomii.
- Nowe okna nie otrzymały jeszcze osobnej akceptacji wyglądu; akceptacja wzorca nie jest akceptacją każdego ekranu.

## Zmienione pliki
- `template/src/shared/UIStyle/`: nowy StyleD.luau; Components.luau, Icons.luau, ItemArt.luau.
- `template/src/client/`: ShopMenu, InventoryMenu, IndexMenu, TasksMenu, DailyRewardsMenu, RebirthMenu, SettingsMenu, EggsMenu (`.client.luau`).
- Nowy `template/src/client/PlaytimeRewardsMenu.client.luau` i `template/src/server/Services/PlaytimeRewards.luau`.
- `template/src/server/Main.server.luau`, `template/src/shared/GameConfig.luau`, `template/README.md`, `playbook/UI_STYLE.md`.
- Stan/wnioski: `games/_TEMPLATE/CURRENT_TASK.md`, `games/_TEMPLATE/PROGRESS.md`, `lessons/TemplateUI.md`; ten raport i dowody testów.

## Zrzuty i dowody
- [Wszystkie okna na telefonie](overview_phone.jpg), [nagroda gotowa](phone_playtime_ready.jpg), [odebrana](phone_playtime_claimed.jpg).
- [Playtime PC](pc_playtime.jpg), [Eggs PC](pc_eggs.jpg), [Settings PC](pc_settings.jpg); pojedyncze `phone_*.jpg` w tym folderze.
- `playtime_test.json`, `pc_audit.json`: surowe odpowiedzi i pomiary.

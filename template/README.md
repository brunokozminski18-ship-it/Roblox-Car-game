# Szablon gry (kod)

Status: IMPLEMENTED, NOT FINAL. Projekt Rojo: wszystkie okna w stylu D + serwer na modułach LihFolk. Treści neutralne (Pet 1, Item 1), wszystko, co zmienia nowa gra, jest w configu. Styl: [[playbook/UI_STYLE]], zasady: [[playbook/ARCHITECTURE]].

## Nowa gra z szablonu (krok po kroku)

1. **Skopiuj** cały folder `template/` do nowej gry (z `default.project.json`) oraz `games/_TEMPLATE/` do `games/<nazwa>/`.
2. **Zmień config** `src/shared/GameConfig.luau`:
   - `PlayerData.storeName` — nowa nazwa magazynu dla tej gry (nigdy nie zmieniaj po premierze).
   - `Currency` — nazwy i start walut; `paid = true` dla waluty kupowanej za Robux.
   - `Inventory.items` — przedmioty/pety: nazwa, `rarity`, `art`, `stat`.
   - `Shop`, `Receipts`, `ShopDisplay` — sklep; ID produktów i passów zostają `0`, dopóki nie stworzysz ich na koncie (z ID 0 serwer nic nie otwiera).
   - `Daily.track`, `PlaytimeRewards.track` (progi minut, etykiety, grafiki i nagrody; reset sesyjny), `Rebirth`, `Quests`, `Index.areas`, `Slots`, `Settings.defaults`.
   - `Analytics.onboarding` i `Hints.steps` — własne kroki pierwszej minuty.
   - `Income.perSecond` — tymczasowy przychód; ustaw `0`, gdy gra ma własną czynność (wtedy waluta przez `Currency.Earn` w serwisie gry).
   - `PlusOne` — rdzeń „+1” (NOT FINAL): kroki → Power → ściany → Cash → ekwipunek (mnoży Power) → boss → nowy świat; formy postaci. Szczegóły: „Mem w 2 dni” niżej.
3. **Zmień kody** w `src/server/GameSecrets.luau` (tylko serwer).
4. **Grafiki D**: `art/icons/set_d`, `art/icons/items_d`, `art/ui_textures`; mapowanie w `UIStyle/Icons.luau` i `ItemArt.luau`. Wyłącznie lokalny podgląd, bez uploadu; licencja: [[playbook/UI_STYLE]].
5. **Nowa mechanika** = nowy serwis w `src/server/Services/` w kształcie modułów LihFolk (`Init` → `PlayerData.RegisterSlice` → `Net.Handle`), podłączony w `Main.server.luau`. Postęp zadań zgłaszaj tylko z serwera: `Quests.Report(player, kind, target, n)`.

**Nie ruszaj:** `src/server/LihFolk/` i `src/shared/LihFolk/` (biblioteka; nasze zmiany oznaczone „Template:”), kolejności w `Main.server.luau`, `src/shared/UIStyle/` (styl; zmiany tylko z decyzją użytkownika), migracji zapisu po premierze (nowa migracja = nowy numer `schemaVersion`).

## Mem w 2 dni (szablon „+1”)

Pętla jest gotowa (31.10.2026): kroki → Power → ściany → Cash → ekwipunek na stanowiskach przy starcie (mnoży Power) → boss na końcu toru → następny świat. Na ekranie: licznik Power z paskiem do następnej formy, jedna linijka celu, „+N” nad głową, rozpad ścian, napisy awansu. Pod mema zmieniasz tylko to:

| Dzień | Co | Gdzie |
| --- | --- | --- |
| 0 | Wpis w [[trends/TRENDS]], decyzja użytkownika, nazwa gry w formie „+1 …” | vault |
| 1 | **Formy** = przemiana postaci z memu: `name`, `color`, `scale`, `accessories` (folder z Accessory w `ReplicatedStorage/PlusOneForms/<nazwa>`) | `GameConfig.PlusOne.forms` |
| 1 | **Ekwipunek** (nazwy przedmiotów z memu), **światy** (nazwa, kolor toru, boss), nazwa statystyki (`Power` → np. `Web Power`) | `GameConfig.PlusOne.gear/worlds`, `Currency` |
| 1 | Modele: dodatki form, bossowie (dziś czerwony blok), dekoracje torów — jedna próbka do akceptacji, potem seria | Blender / LihFolk Asset Pack |
| 2 | Pety z mnożnikiem i jaja za Cash (IMPLEMENTED, NOT FINAL), ikona i miniatura „poziom 1 vs poziom 999”, test na telefonie, publikację robi użytkownik | [[playbook/LAUNCH_72H]] |

Pety: pod mema podmień nazwy i `previewImage`/`art` w `Inventory.items`; bonus `1 + suma(power - 1)`, limit w `Config.Pets`.
Jaja: `Config.Eggs` definiuje ceny Cash, świat i szanse; stanowiska, podgląd szans i wynik są gotowe, NOT FINAL.
Grafiki D: lokalne `rbxasset://textures/icons_d/`, `item_art_d/`, `ui_preview/`. Przed premierą użytkownik zatwierdza upload i podmienia adresy. Stare rendery glossy i art/items nie są używane w oknach.

Sprawdzone 31.10.2026 w Studio (1 gracz, iPhone 13 Pro poziomo, magazyn w pamięci): Power za kroki, formy (rozmiar), ściany 25/150 pękają i płacą, 800 blokuje, zakup rękawic (x2), linia celu. **Niesprawdzone:** boss i przejście do świata 2, dodatki form (brak modeli), kilku graczy. Liczby NOT FINAL.

## Co jest

- `src/server/Main.server.luau` — jedyny skrypt serwera, kolejność LihFolk.
- `src/server/LihFolk/` — PlayerData (zapis z blokadą sesji), Policy, Currency, Inventory, Rewards, Receipts, Shop, Codes, DailyRewards, Rebirth, Quests. Zmiany szablonu: magazyn w pamięci dla Studio (`StudioMemoryStore`), pojemność ekwipunku zależna od gracza, zadania dzienne/tygodniowe z resetem UTC, sygnały `DailyRewards.Claimed`, `Inventory.Equipped`.
- `src/server/Services/` — Slots (sloty za walutę), Index (odkrycia, nagroda za obszar), Settings (zapis ustawień), Income, Analytics (lejek, zdarzenia, ekonomia), Hints (podpowiedzi), PlusOne (rdzeń „+1”: kroki → Power, formy postaci, ściany; klient: `client/PlusOne`).
- `src/shared/LihFolk/` — Net (jedyne miejsce z remote'ami: walidacja typów, limit szybkości), Signal, Feedback (teksty błędów).
- `src/client/` — okna D: Shop (Codes), Inventory, Index, Tasks, Daily, Rebirth, Settings, Eggs i Playtime Rewards; licznik waluty i podpowiedzi.
- `Services/PlaytimeRewards.luau` — czas od dołączenia liczony na serwerze; Get/Claim, odbiór raz na sesję przez Rewards. Konfiguracja: `GameConfig.PlaytimeRewards`; UI mówi „Resets when you leave”.
- `UIStyle/StyleD.luau` — tokeny okien; `Components` — wspólne okno/karta/tekst/przyciski. HUD i jego Theme/Launcher pozostają bez zmian.
- `art/icons/set_d`, `art/icons/items_d`, `art/ui_textures` — wybrane grafiki D (Icons by @gvesster).

## Testy w Studio

- Dostęp Studio do API jest włączony (31.10): w Studio PlayerData zapisuje do `<nazwa>_STUDIO`, osobno od gry. `TestProfileKey = "qa"` na ServerStorage daje osobny profil testowy (usuń po teście). Bez dostępu do API: atrybut `UseMemoryStore = true` na ServerStorage (dane tylko do Stop).
- Analityka w Studio nic nie wysyła (Roblox ignoruje Studio) — przy `debugInStudio = true` wypisuje zdarzenia w Output.
- `rojo serve` w tym folderze, w Studio Rojo → Connect (port 34872). Nie przenoś plików, gdy Rojo działa (wyłącza się).

## Stan okien D (01.11.2026)

IMPLEMENTED; VERIFIED w Play: mały telefon poziomo i preset PC 1920×1080, odbiór Playtime po minucie, blokada duplikatu i wcześniejszego odbioru, reset nowej sesji. Wygląd migracji NOT FINAL — wzorzec D jest zatwierdzony, poszczególne okna wymagają oceny użytkownika. Raport i zrzuty: [[games/_TEMPLATE/reports/codex_ui_d/README]].

## Do dodania
- Wgranie ikon i grafik, prawdziwe ID produktów — decyzje użytkownika.

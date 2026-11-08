# Raport: UI w stylu B, praca nocna 30.10.2026

Bez commitów, bez publikacji, bez wgrywania czegokolwiek na konto Roblox. Folderu `research/` nie ruszałem. Studio zostało w Edit, emulator wyłączony.

## Co zrobiłem

1. **Ikony menu od nowa (toon).** Skrypt `template/art/icons/render_toon.py` (Blender 5.2, EEVEE): twarde progi cienia, obrys Freestyle, kanciaste bryły, jedna kamera 3/4 i jedno światło dla wszystkich.
   - 3 warianty SHOP: A „flat cel”, B „cel + odblask”, C „miękki cel” — `template/art/icons/variants/{A,B,C}/shop.png`.
   - Porównanie z C1 w tej samej skali: `icons_01_shop_variants_vs_C1.png` (tu) i surowe obok siebie: `icons_02_shop_variants_raw.png`.
   - Wybrany A (8.5 / B 6.9 / C 7.3 wg rubryki modelu z LihFolk `quality-score`; ocena twórcy, nie ślepa). Uzasadnienie i tabela: `playbook/UI_STYLE.md`, wpisy w `template/.lihfolk/ledger.jsonl`.
   - Komplet w A: SHOP (kasa z paragonem), INVENTORY (skrzynia z otwartą kłódką), INDEX (lupa z „?”), TASKS (tarcza ze strzałą), DAILY (budzik), REBIRTH (klepsydra z piaskiem u góry), SETTINGS (dwa zębate kółka) + moneta i klejnot do licznika. Arkusz: `icons_00_full_set.png`.
2. **Kafle menu w grze** (`UIStyle.Components.LauncherTile`): ciemny kafel, słaba poświata w kolorze ikony, podpis z obrysem w tym kolorze. Ikony widać w Studio z lokalnej kopii (patrz „Czego nie zrobiłem”).
3. **Okna w stylu B** z własnym układem i neutralnymi treściami:
   - **Inventory** — pasek SLOTS 18 / 30 z zielonym „+”, siatka kart w kolorze rzadkości (z A3), tagi `x2` i EQUIPPED, panel szczegółów z EQUIP, zakładki ALL / PETS / ITEMS.
   - **Index** — pasek „5 / 12 FOUND”, pole nagrody z CLAIM (LOCKED, gdy niepełne), znalezione karty w kolorze rzadkości, nieznalezione jako ciemny kształt z „???”, zakładki AREA 1–3.
   - **Tasks** — zakładki DAILY / WEEKLY, „RESETS IN …”, wiersze: nazwa, cel, pasek postępu, nagroda, przycisk CLAIM / IN PROGRESS / CLAIMED.
   - **Daily Rewards** — seria i CLAIM w górnym wierszu, 7 równych kart dni (dzień 7 złoty z tagiem BIG), odebrane przyciemnione z CLAIMED, zasada serii w jednym zdaniu.
   - **Rebirth** — karty NOW → AFTER REBIRTH z mnożnikiem, pasek kosztu i przycisk w jednym wierszu (szary „NEED … MORE”, potwierdzenie drugim dotknięciem), listy YOU KEEP / RESETS.
   - **Settings** — wiersze z ON/OFF (muzyka, efekty, mniej ruchu, ukryj efekty innych, większe okna) i RESET.
   - Licznik Cash/Gems przerobiony na styl B z ikonami monety i klejnotu. Osobne okno Codes usunięte — kody są w sklepie.
4. **Poprawki wspólne:** nagłówek okna jako rząd (tytuł nie wchodzi pod zakładki), zakładki 52 jednostki, przyciski ≥ 52 jednostki, siatka kafli menu 3 × 3 na telefonie.

## Co sprawdziłem (Play w Studio, 30.10.2026)

| Okno | Telefon (iPhone 17 Pro poziomo) | PC 1920×1080 |
| --- | --- | --- |
| HUD + kafle | `phone_00_hud.jpg` — kafle kończą się 12 px nad pierścieniem joysticka | `pc_00_hud.jpg` |
| Shop | `phone_01_shop.jpg` — w ekranie, najmniejszy przycisk 44 px | `pc_01_shop.jpg` |
| Inventory | `phone_02_inventory.jpg` — w ekranie, 44 px | `pc_02_inventory.jpg`, wybór karty działa |
| Index | `phone_03_index.jpg` — w ekranie, 44 px | `pc_03_index.jpg` |
| Tasks | `phone_04_tasks.jpg` — w ekranie, 44 px | `pc_04_tasks.jpg` |
| Daily | `phone_05_daily.jpg` — w ekranie, 44 px, CLAIM widoczny bez przewijania | `pc_05_daily.jpg` |
| Rebirth | `phone_06_rebirth.jpg` — w ekranie, 44 px, przycisk widoczny bez przewijania | `pc_06_rebirth.jpg` |
| Settings | `phone_07_settings.jpg` — w ekranie, 44 px | `pc_07_settings.jpg`, przełącznik ON/OFF działa |

- „W ekranie” i „44 px” mierzył skrypt w kliencie (panel w bezpiecznym obszarze, najmniejszy bok każdego przycisku i pola tekstowego).
- Pliki `*_before_fix.jpg` pokazują, co poprawiłem: na telefonie główny przycisk Daily i Rebirth był pod krawędzią okna.
- Konsola bez błędów z naszych skryptów (jest tylko stary komunikat o assecie 203785492 z samego place'a).

## Czego nie zrobiłem lub nie dało się

- **Ikon nie wgrałem do Robloxa** (to tworzy assety na Twoim koncie — wymaga Twojej zgody). W grze widać je tylko w Studio na tym komputerze: skopiowałem PNG do folderu zasobów Studio (`%LOCALAPPDATA%\Roblox\Versions\version-7062aec9dbe74b14\content\textures\menu_icons_preview`). Po aktualizacji Studio znikną; w opublikowanej grze ich nie będzie.
- **Na emulatorze telefonu kliknięcie przełącznika w przewijanym oknie nie zadziałało**, na PC ten sam przełącznik działa. Wygląda na ograniczenie klikania przez MCP w emulatorze, ale bez fizycznego telefonu nie mam pewności.
- **Brak serwera pod okna**: CLAIM, EQUIP, REDEEM, „+”, REBIRTH wysyłają intencje do `ReplicatedStorage.Remotes.*`, których nie ma (w konsoli pojawi się ostrzeżenie). Dane w oknach to demo po stronie klienta.
- **Grafiki przedmiotów** nadal są puste („ITEM ART”) — czeka na Twój wybór źródła.
- Ocena ikon nie jest ślepa (wymóg `quality-score`: 3 niezależnych recenzentów) — nie uruchamiałem dodatkowych agentów bez Twojej prośby.
- Nie testowałem tabletu, gamepada ani długich tłumaczeń.

## 3 najsłabsze rzeczy (moim zdaniem)

1. **Puste „ITEM ART” wszędzie.** Bez grafik okna Inventory, Index i Daily wyglądają jak makiety; nie da się ocenić, czy karty w kolorze rzadkości z realistycznymi przedmiotami będą czytelne. Sylwetka „???” w Index to tylko zaokrąglony kształt — prawdziwa sylwetka powstanie z obrazka peta zabarwionego na czarno.
2. **Ikony: SHOP i INVENTORY słabo czytelne w 48–64 px.** Kasa jest wąska i ma dużo drobiazgów, kłódka na skrzyni zlewa się w plamę, szkło lupy i klepsydry jest blade. Moneta w liczniku ma dziwny romb. Dobrze wypadają TASKS, DAILY, SETTINGS.
3. **Telefon jest ciasny.** Okna zajmują cały ekran i większość treści jest pod krawędzią (trzeba przewijać), kafle menu zajmują lewą górną ćwiartkę 3 × 3, a nad joystickiem jest tylko 12 px zapasu. Warto rozważyć mniej przycisków menu na start albo drugą kolumnę po prawej.

## Gdzie co jest

- Kod: `template/src/` (okna w `client/`, styl w `shared/UIStyle/`).
- Ikony: `template/art/icons/` (`set/`, `variants/`, `v1_smooth/`).
- Zasady stylu: `playbook/UI_STYLE.md`.

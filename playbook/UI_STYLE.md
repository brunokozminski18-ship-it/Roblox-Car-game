# Styl UI

Decyzja użytkownika 30.10.2026. Referencje: `references/ui/`. Nie kopiujemy ich 1:1: bierzemy styl i układ, a nazwy, grafiki i teksty są nasze. Zasady telefonu: [[playbook/MOBILE_UI]].

## Styl, nie kopia (uwaga użytkownika 30.10.2026)

Pierwsza próbka sklepu była za blisko B. Z B bierzemy tylko **styl**: kolory, ramki, czcionkę, zakładki i kształt przycisków. **Własne** są: układ kart i okien, teksty, podpisy, format licznika czasu, kolejność sekcji. Nie przenosimy z B: „TIER 5 - LIMITED”, opisu VIP, formatu `0w 1d 17h 45m 33s`, układu „dwie oferty + szeroki VIP + trzy karty”.

Dopóki nie ma gry, przykłady są neutralne: „Item 1”, „Pass 1”, „Pack 1”, krótkie opisy typu „Pass 1 perk goes here.”

## Historyczny styl B (pliki B1–B6) — zastąpiony przez D

Bierzemy stąd kolory, ramki, zakładki, kształt przycisków, czcionkę i realizm grafik przedmiotów.

| Element | Wygląd |
| --- | --- |
| Okno | Granatowo-grafitowe tło (gradient `#283A4C` → `#18222D`, patrz „Spójność”), cienka jasnoszara ramka (`#5D6873`, 2 px) i ciemna obwódka zewnętrzna. Narożniki prawie proste (4 px). |
| Nagłówek | Tytuł wersalikami po lewej (SHOP, INDEX), biały, gruby. Pod nagłówkiem cienka linia `#4A5561`. |
| Zakładki | Płaskie szare prostokąty (gradient `#6E7276` → `#3F4347`), ciemna ramka i cienka jasna krawędź u góry, biały tekst wersalikami. Aktywna zakładka jasna w kolorze okna, na kolorowym pasku nagłówka (patrz „Spójność”). |
| Zamknij | Czerwony kwadrat (`#E5484A` → `#B8282C`) z ciemną ramką i X. |
| Przycisk główny | Zielony (`#52E052` → `#1E9F1E`), ciemnozielona ramka, ikona Robux i cena, biały tekst z ciemnym obrysem. |
| Przycisk drugorzędny | Szary jak zakładka (np. GIFT PLAYER). |
| Karty | Ciemne tło z lekkim gradientem, delikatne ukośne pasy i cienka ramka w kolorze kategorii: waluta zielona, przepustki niebieskie, VIP złota, oferty grafitowe. |
| Wstążka NEW | Czerwona wstążka (kształt i miejsce dobieramy sami). |
| Licznik czasu | Czerwony; format nasz, np. `ENDS IN 2D 05:41:09`. |
| Kwoty waluty | Biały tekst (`$12,500`); w Indeksie ceny zielone. |
| Pasek postępu | Żółty na ciemnym torze z liczbą `27 / 61` (B4). |
| Czcionka | Montserrat (wbudowana w Robloxa): tytuły i przyciski Heavy/ExtraBold, opisy Bold. Wersaliki w nagłówkach, zakładkach i przyciskach. |
| Grafiki | Realistyczne przedmioty: zdjęciowe rendery z cieniem, bez obrysu, zachodzące lekko poza kartę. Bez liter w kółkach. |

## Z A1–A3 tylko układ

- Karty petów w kolorze rzadkości (tło karty = kolor rzadkości) i podgląd wybranego peta z boku.
- Sylwetki „???” w Indeksie dla nieodkrytych (czarna sylwetka, nazwa `???`).
- Pasek postępu kolekcji (`2/8`) z nagrodą za ukończenie.
- Procenty szans pod każdym petem na karcie jaja i pakiety jaj (1 / 3 / 10 / 50) z ceną pod przyciskiem.

Aktualne kolory, czcionka i wykończenie: styl D opisany niżej; opis B zachowany jako historyczna referencja.

## Ikony menu (C1)

Referencja: `references/ui/C1_menu_icons.png`. Bierzemy sposób wykonania, nie obiekty: koszyk, skrzynka z narzędziami, książka z „i” i lista zadań z C1 są zajęte; robimy własne przedmioty.

Pierwsza próbka (gładkie cienie, połysk, torba z monetą, różowy prezent) wyglądała jak generowana przez AI — odrzucona 30.10.2026, archiwum w `template/art/icons/v1_smooth/`.

**Styl ikon: wariant A „flat cel”** (wybrany 30.10.2026 spośród A/B/C, NOT FINAL do akceptacji użytkownika):

- **Cieniowanie toon:** 3 twarde progi (cień chłodny i ciemniejszy, kolor bazowy, rozjaśnienie), bez gradientów, bez połysku, kolory jako emisja (dokładnie te z palety).
- **Obrys:** ciemny atrament `#120D17`, Freestyle, 6 px na renderze 512 px (kontur i krawędzie).
- **Bryły:** kanciaste, „chunky” bloki z małym fazowaniem (1–2 segmenty), kąt 3/4 z góry z lewej.
- **Obiekt:** nieoczywisty, z jednym detalem: SHOP kasa z paragonem, INVENTORY skrzynia z otwartą kłódką, INDEX lupa ze znakiem „?”, TASKS tarcza ze strzałą w środku, DAILY budzik z dzwonkami, REBIRTH klepsydra z piaskiem u góry, SETTINGS dwa zębate kółka. Do licznika waluty: moneta i klejnot.
- **Kamera i światło:** wspólne, w skrypcie `template/art/icons/render_toon.py` (azymut −38°, wysokość 28°, 120 mm, słońce z lewej z przodu, twardy cień). Nie zmieniamy ich dla pojedynczej ikony.
- **Render:** PNG 512×512, przezroczyste tło; do UI przycinane do obiektu (`set/ui/`).
- **Przycisk w grze:** patrz „Przyciski menu (C3)” niżej (ciemny kafel z C1 zastąpiony 30.10.2026).
- **Kolor ikony** = kolor przycisku. Kolory: `UIStyle/Icons.luau`.

**Dlaczego A** (porównanie z C1 w tej samej skali: `template/art/icons/variants/shop_compare_C1.png`; ocena wg rubryki modelu LihFolk `quality-score`, kryteria V1–V6 i V8 „zgodność z zestawem” = z C1; bramki A1–A18 nie dotyczą, bo ikona to render, nie model w grze):

| Wariant | V1 sylwetka 64 px (3) | V2 hierarchia (2) | V3 proporcje (2) | V4 krawędzie (2) | V5 czyste cieniowanie (2) | V6 paleta (1) | V8 jak C1 (1) | Wynik |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| A flat cel | 1 | 2 | 2 | 2 | 2 | 2 | 1 | **8.5** |
| B cel + odblask | 1 | 2 | 2 | 1 | 1 | 2 | 1 | 6.9 |
| C miękki cel | 1 | 2 | 2 | 1 | 2 | 2 | 0 | 7.3 |

- A: twarde progi i gruby obrys czytają się w 64 px najlepiej i są najbliżej C1. Słabe: sylwetka kasy jest wąska i ruchliwa (V1 = 1).
- B: odblaski robią białe kropki na krawędziach (artefakty, V5), cieńszy obrys.
- C: miękkie przejścia wracają do „gładkiego” wyglądu, który odrzuciłeś (V8 = 0).
- To ocena twórcy, nie trzech ślepych recenzentów, których wymaga `quality-score` — wynik kierunkowy.

## HUD w stylu D (polecenie użytkownika 01.11.2026, zastępuje C3 poniżej)

Wzór: `references/ui/D1_hud.webp` (+1 Spider Arm) — styl i rozmieszczenie, nie kopia. Ikony z paczki „Free Icon Pack” (patrz „Skąd grafiki”). Kod: `UIStyle/Launcher.luau`, `client/CurrencyHud`, dolny pasek w `client/PlusOne`.
- **Menu:** bez płytek — duża ikona i podpis Fredoka One, biały z grubym ciemnym obrysem i cieniem. Siatka przy lewej krawędzi: PC 2 kolumny na środku wysokości, telefon 3 kolumny od góry (kończy się nad joystickiem).
- **Promocje po prawej:** szerokie tęczowe płyty, ikona wychodzi z lewej, tytuł i „ONLY <cena z Robloxa>”; dotknięcie otwiera sklep. Lista: `GameConfig.ShopDisplay.promos`.
- **Waluty:** ciemna półprzezroczysta pigułka, duża ikona wychodząca z lewej, gruba liczba, zielony „+”.
- **Dół:** linia celu, żetony mnożników (ekwipunek, rebirth), długi niebieski pasek poziomu z piorunem.
- Sprawdzone 01.11.2026: iPhone 13 Pro poziomo i PC (zrzuty `games/_TEMPLATE/reports/ui_D/hud_*.jpg`). HUD bez zmian w migracji okien D. Stan okien: sekcja wzorca poniżej.

## Okna w stylu D — wzorzec (USER APPROVED 01.11.2026, próbka „Playtime Rewards” v3)

Wzorzec do skopiowania na wszystkie okna: `template/art/ui_mockups/PlaytimeRewardsSample.luau`, zrzut `games/_TEMPLATE/reports/ui_D/playtime_rewards_v3_round.jpg`. Kierunek z wzoru użytkownika (okno Daily Rewards innej gry) — tylko styl, układ i teksty własne.
- **Okno:** pionowy gradient niebieski `#2F7BF2` → `#16348F`, obrys `#14102A` 5 px, zaokrąglenie 36, delikatny biały połysk u góry (przezroczystość 0,82 → 1).
- **Tytuł:** duża ikona z paczki wystająca z lewego górnego rogu (obrót ok. −12°), tytuł Fredoka One 48, biały, gruby obrys + cień. **X:** okrągły, czerwony gradient, wystaje poza róg okna.
- **Karty:** gradient zależny od stanu — zielony odebrane `#8CF27C→#22B24A`, różowy gotowe `#FF86CF→#E2338C`, błękitny zablokowane `#74E6FF→#1E95F0`, fioletowy specjalne `#D98BFF→#7B2BE6`; zaokrąglenie 32, obrys 4, ukośne paski (`ui_textures/stripes.png`), połysk w górnej części, **poświata za ikoną** (`glow.png`), promienie przy głównej nagrodzie (`rays.png`).
- **Przyciski, pigułki, wstążki:** w pełni okrągłe końce; wstążki przechylone ±10° na rogu karty; przycisk akcji biały z kolorowym napisem; neutralny przycisk szary z klockami (`stud_tile.png`).
- Tekst zawsze biały Fredoka One z obrysem ok. 12% rozmiaru i cieniem; liczniki/akcenty złote `#FFD24A`.

**Stan wdrożenia 01.11.2026:** IMPLEMENTED: Shop (w tym Codes), Inventory, Index, Tasks, Daily, Rebirth, Settings, Eggs i nowe Playtime Rewards. Tokeny w `UIStyle/StyleD.luau`, wspólne komponenty w `Components.luau`; stary `Theme` pozostaje dla zaakceptowanego HUD. Playtime ma 4 kolumny na PC i 3 na małym telefonie; na telefonie stopka przewija się z treścią. Wystające elementy mieszczą się w bezpiecznej ramce. Techniczne testy Play VERIFIED; wygląd nowych okien NOT FINAL do oceny użytkownika. Raport/zrzuty: [[games/_TEMPLATE/reports/codex_ui_d/README]].

## Przyciski menu (C3) — ZASTĄPIONE przez styl D

Decyzja użytkownika 30.10.2026: styl i rozmieszczenie przycisków jak na `references/ui/C3_hud_both_sides.webp` (wycinki: `C3_left_column.png`, `C3_right_column.png`), bez kopiowania obiektów i nazw. Zastępuje wersję C2 z tego samego dnia. Kod: `UIStyle/Launcher.luau`, przypisanie w `UIStyle/Icons.luau` (`kind`, `side`).

- **Duże przyciski:** prostokąt w nasyconym kolorze menu z jasnym gradientem od góry, ciemny obrys 3 px, ciemniejsza „warga” 5 px na dole; obiekt toon w pełnym kolorze po lewej, przycięty krawędzią przycisku; biały napis Montserrat Heavy z pełnym ciemnym obrysem i cieniem, dopasowany do miejsca obok obiektu (`TextService`). Projekt 176×82.
- **Małe kwadraty:** ta sama płyta 84×84, obiekt w pełnym kolorze, podpis zwykłą wielkością liter („Settings”) jak największy (do 24), z pełnym obrysem; może lekko wystawać poza kafel. Na telefonie małe kwadraty stoją w jednym rzędzie po 3 (kolumna niższa, więc większa skala i podpisy ok. 18 px).
- **Rozmieszczenie:** lewa krawędź — SHOP, ITEMS; prawa krawędź — małe kwadraty (Settings, Daily, Rebirth; na PC siatka 2 kolumn), pod nimi INDEX, TASKS. Na PC obie kolumny na środku wysokości, na telefonie od góry (najwyższa kolumna do 62% wysokości). Licznik waluty na środku u góry.
- **Napis na dużym przycisku** maks. 5–6 liter; dłuższe nazwy dostają krótszą (`button`, np. INVENTORY → ITEMS).
- Sprawdzone 30.10.2026 (iPhone 17 Pro poziomo, PC): najmniejszy przycisk 46 px, prawa kolumna 19 px nad przyciskiem skoku, lewa daleko nad joystickiem. Wygląd: NOT FINAL.

## Historyczna spójność B/C3 (30.10.2026) — zastąpiona przez D

Okna w stylu B i jaskrawe przyciski C3 wyglądały jak z dwóch gier. Spośród dwóch wariantów (zrzuty: `games/_TEMPLATE/reports/ui_variants/porownanie_wariantow.jpg`) wybrany **wariant 1**: przyciski zostają jaskrawe, okna dostają mocniejsze akcenty.

- **Pasek nagłówka** okna w kolorze jego przycisku menu (sklep pomarańczowy, Index niebieski…); kolor brany z `UIStyle/Icons.luau` po nazwie okna.
- **Aktywna zakładka jasna w kolorze okna** (rozjaśniony kolor przycisku menu, biała ramka); nieaktywne szare.
- **Tekst drugorzędny** (opisy, cele zadań, liczniki czasu, stopki, listy): co najmniej 20 jednostek (ok. 17 px na telefonie), kolor `#E2E7EE`.
- **Przyciski HUD na PC:** skala ok. 1,3 × wysokość/1080 (min. 0,9), małe kwadraty 92×92.
- **Jaśniejsze tło okna** (`#283A4C` → `#18222D`) i jaśniejsze, bardziej nasycone karty (oferty, przepustki, pakiety, VIP).
- Odrzucony wariant 2 (ciemne kafle przycisków) nie jest już w kodzie.

Okna dopasowują wysokość do zawartości (nie ma pustego pasa pod ostatnim rzędem), dłuższe przewijają się.

## Skąd grafiki przedmiotów

Kolejność od najlepszej:

1. **Rendery naszych modeli z Blendera** (pipeline z Pumpkin Huntera): ten sam przedmiot w grze i w UI, prawa po naszej stronie, spójne światło. Wolniejsze: model plus render.
2. **Grafiki AI** (przezroczysty PNG) dla rzeczy, których nie ma w grze jako model (pakiety waluty, sejf, karta VIP). Szybkie, ale każdą sprawdza użytkownik, bez znaków towarowych i prawdziwych marek.
3. **ViewportFrame**, czyli żywy model 3D w UI: zero wgrywania, zawsze zgodny z grą. Wygląda tak dobrze jak model.

Paczka LihFolk (`Models/Kits`) ma stylizowane modele low-poly (monety, klejnoty, skrzynie, beczki). Nadają się do ViewportFrame, ale nie dają realistycznego wyglądu.

Wgranie grafiki do Robloxa tworzy asset na koncie użytkownika i przechodzi moderację, więc robimy to tylko za jego zgodą. Grafik z Creator Store i z internetu nie używamy — **wyjątek (decyzja użytkownika 01.11.2026):** paczki ikon wybrane przez użytkownika, z licencją zezwalającą na użycie komercyjne. Teraz: „Free Icon Pack” 3.0.1 by gvesster (BuiltByBit) — wolno w grach zarabiających; nie wolno odsprzedawać ani podawać jako własne; podpis autora mile widziany (dopisać „Icons by @gvesster” w opisie gry). Całość w `template/art/icons/vendor/` (poza gitem, z licencją), wybrane ikony w `template/art/icons/set_d/`, mapowanie w `UIStyle/Icons.luau`.

## Ikona Robux

Znak Robux z czcionki Robloxa (`utf8.char(0xE002)`), bez własnych ID. Zasady marki Roblox: nie zmieniamy kształtu ani koloru znaku.

## Kod

`template/src/shared/UIStyle`: `StyleD` (tokeny okien D), `Theme` (zachowany dla HUD), `Components` (okno, zakładki, przyciski, karty, pasek postępu, przełącznik), `Icons` (obrazy i kolory ikon), `Launcher` (kafel otwierający okno). Okna rejestrujemy w `LihFolkUIController` (dopasowanie do ekranu, przyciemnienie, zamykanie). Przyciski i zakładki mają co najmniej 52 jednostki (44 px na telefonie), główna akcja okna jest widoczna na telefonie bez przewijania.

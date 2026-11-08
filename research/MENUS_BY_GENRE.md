# Menu według czynności — 30.10.2026

Status: PLANNED / NOT FINAL. Architektura informacji do rozważenia po wyborze gry i teście zabawy, nie gotowy UI ani zmiana szablonu. Dotyczy A1, A2 i A3 z [[research/CORE_ACTIVITIES]].

## Co wynika ze źródeł, a co proponuję

LihFolk Genre Playbooks opisują pętle, stany, nagrody i ryzyka gatunków, ale nie narzucają poniższych nazw zakładek. Nazwy, podział na premierę/później oraz redukcja funkcji są **propozycją autora**. Nie oznaczam sklepu, petów i Rebirth jako potrzebnych tylko dlatego, że istnieją w szablonie. Dashboard mówi: UI szablonu IMPLEMENTED, serwer PLANNED; nie jest to dowód gotowości poniższych menu.

Wszystkie angielskie etykiety są proponowanym tekstem dla gracza. Numery A1–A3 są identyfikatorami z poprzedniego dokumentu. „Premiera” oznacza zakres po potwierdzeniu czynności, a nie polecenie budowy dziś. Bez nowych twierdzeń ilościowych o Robloxie.

## A1 — Ratuj: krótki bieg z ładunkiem

**Dopasowanie gatunku:** story/escape obby z presją zagrożenia; element wspólnej rundy tylko wtedy, gdy poprawia tempo. Podstawa: LihFolk Vault V2 [G1], „Variants” i TL;DR o czytelnych próbach, oraz [G2], „Timing and dead time”. Galeria jest własną adaptacją celu po udanej akcji, a nie standardowym wymaganiem obby.

| Element na premierę | Co zawiera i po co | Kiedy dostępny |
| --- | --- | --- |
| HUD, bez otwierania okna | Cel „RESCUE”, wskaźnik hałasu, zapowiedź zagrożenia, kierunek schronu, stan niesionego obiektu | Podczas ruchu; nie zasłania drogi |
| Przycisk kontekstowy | „PICK UP” / „DROP”, podgląd wskazanego obiektu | Przy obiekcie lub podczas niesienia |
| „COLLECTION” | Zakładki „RESCUED” i „MISSING”; uratowane sylwetki oraz wskazanie, gdzie szukać następnego celu | Z półki w schronie; zamknięcie przed wyjściem na trasę |
| Krótki wynik w świecie | „RESCUED” oraz nowo zajęte miejsce na półce | Po dostarczeniu, bez obowiązkowego „CLAIM” |
| „SETTINGS” | „AUDIO”, „CONTROLS”; opis chwytu, ustawienie dźwięku, informacja o wizualnym sygnale zagrożenia | Ze schronu lub pauzy; sygnał wizualny zawsze obecny |
| Informacja o zapisie | Czy kolekcja została zapisana; przy problemie jasne „SAVE PENDING” | Przy półce, bez wymuszania kolejnego biegu |

**Później:** „CHALLENGES” dla nowych wariantów tras, „STYLE” z wyposażeniem wyglądu, opcjonalny ranking uczciwych prób. Nie dodawać osobnego ekwipunku dla jedynego noszonego obiektu. „SHOP” dopiero przy określonej ofercie i osobnej decyzji użytkownika; żadnych pustych zakładek na premierę.

**Przepływ wejścia:** spawn patrzy na bliski obiekt i schron → chwyt → decyzja drogi → dostarczenie → widoczny nowy cel. Album otwiera się na życzenie; nie zastępuje pierwszej akcji.

**Sytuacje brzegowe:** po złapaniu przez zagrożenie wracasz do schronu z czytelnym wyjaśnieniem; uratowane wcześniej obiekty zostają. Gracz dołączający nie czeka na pełną rundę, żeby wykonać łatwy ratunek. Otwarty album zamyka się przed ruchem w strefę ryzyka, bez utraty sterowania.

**Na szarym prototypie:** HUD i krótki wynik, galeria wyłącznie sesji. Menu trwałej kolekcji i zapis to zakres późniejszej wersji, po teście.

## A2 — Rzucaj: fizyczna zabawka z celem

**Dopasowanie gatunku:** komediowa zabawka + pojedyncze zadanie party. Nie obiecujemy kolekcji minigier. LihFolk Vault V2 [G2], „Minigame design” i „Rewards and progression”, dostarcza podstaw do czytelnego celu, udziału słabszych graczy i widocznego wyniku. [G4] uzasadnia samą zabawkę i społeczną komedię; menu to adaptacja autora.

| Element na premierę | Co zawiera i po co | Kiedy dostępny |
| --- | --- | --- |
| HUD chwytu | „GRAB” / „THROW”, wskazany rekwizyt, prosty podgląd toru, oznaczenie szerokiego celu | Podczas zabawy, bez osobnego panelu celowania |
| „TOYS” | Zakładki „AVAILABLE” i „LOCKED”; wybór dostępnego rekwizytu z widocznym warunkiem odblokowania następnego | W bezpiecznej strefie pobierania rekwizytów |
| Wynik próby | Trafiony cel, nowo otwarta bramka, najlepszy wynik sesji | Krótka informacja po rzucie, bez blokowania kolejnego chwytu |
| „PLAY” | „PRACTICE” i „CO-OP”; pokazuje bieżący cel i pozwala wejść bez oczekiwania na zapełnienie serwera | Na miejscu startu, nie obowiązkowy ekran po spawnie |
| „SETTINGS” | „AUDIO”, „CONTROLS”; jak zmienić wskazany rekwizyt i puścić chwyt | Dostępne z bezpiecznej strefy |

Na premierę rekwizyty są źródłem odmiennych zachowań, nie kolekcją petów. Ewentualne zapamiętywanie odblokowanych zabawek wymaga osobnego wdrożenia i testu; prototyp przechowuje je tylko w sesji.

**Później:** „CHALLENGES” z autorskimi układami urządzeń, „STYLE” z kosmetycznymi smugami i reakcjami, zapis ulubionego zestawu. „RESULTS”/„SPECTATE” dopiero, jeśli wybierzemy rundy z eliminacją; w obecnej zabawce nie ma uzasadnienia dla obserwowania po przegranej. Sklep i płatna siła rzutu nie są potrzebne do testu.

**Przepływ wejścia:** gotowy rekwizyt przed graczem → chwyt i rzut → wyraźne przewrócenie przeszkody → cel dla podania do znajomego. Lista zabawek jest dostępna, ale nie otwiera się automatycznie.

**Sytuacje brzegowe:** brak partnera oznacza dostępne zadanie treningowe; upuszczony poza mapą przedmiot wraca do stanowiska; brak wolnego rekwizytu jest komunikowany w świecie. Nie tworzymy okien za każdym razem, gdy nie da się chwycić. Wariant rzucania graczami, jeśli kiedykolwiek powstanie, potrzebuje dobrowolnego udziału i czytelnego wyjścia.

**Ograniczenie gatunku:** [G2] zaleca szeroki zestaw minigier dla pełnej kolekcji party; ta propozycja świadomie nie spełnia takiego zakresu. Jeśli test pokaże nudę po poznaniu rekwizytów, nie nazywać pojedynczego toru pełną grą party i nie dokładać automatycznie wielkiej listy menu.

## A3 — Osłaniaj: buduj i sprawdź schronienie

**Dopasowanie gatunku:** uproszczone run-based survival/crafting bez rozbudowanego zbierania. LihFolk Vault V2 [G3], „Session length and persistence model”, „Crafting design”, „Building”, „Multiplayer, PvP and griefing”. Źródło wspiera mały zakres, widoczne brakujące składniki i prawa do budowy; poniższe gniazda i karty testów są propozycją autora.

| Element na premierę | Co zawiera i po co | Kiedy dostępny |
| --- | --- | --- |
| HUD próby | Kierunek nadciągającego ataku, stan osłanianej figurki, faza „BUILD” / „INCOMING” / „REPAIR” | Przez całą próbę, nie w modalnym oknie |
| Pasek „BUILD” | Zakładki „PANELS” i „SUPPORTS”; duże karty, dostępność, podgląd miejsca, „ROTATE”, „REMOVE”, „UNDO” | Podczas budowania; domyślnie prosty panel |
| „TEST” | Nazwa zagrożenia, jego zapowiedź i „START”; w grze grupowej czytelny stan gotowości | Przy planszy, nie może uruchamiać cudzego projektu bez uzgodnienia |
| Wynik próby | Strzałka kierunku ataku i wskazanie miejsca przebicia, „TRY AGAIN” | Po ataku; bez zasłaniania uszkodzenia |
| „BLUEPRINTS” | „SAVED” i „NEW”; zapisz/załaduj własny projekt, potwierdź zastąpienie | Między próbami; na premierę tylko jeśli trwały zapis został zweryfikowany |
| „TEAM” | Kto może zmieniać projekt; właściciel nadaje/odbiera możliwość budowy | Przy wspólnej planszy |
| „SETTINGS” | „AUDIO”, „CONTROLS”; sterowanie gniazdami i obrotem | Z bezpiecznej strefy |

**Później:** „CHALLENGES” z nowymi kierunkami zagrożenia, „STYLE” dla dekoracji; „RECIPES” i pełny ekwipunek dopiero, jeśli test uzasadni zbieranie materiałów. Brak głodu i narzędzi oznacza brak menu jedzenia, craftingu sprzętu i hotbara broni. Nie projektować ich na zapas.

**Przepływ wejścia:** gotowa figurka-cel → podświetlone gniazdo → ustawienie panelu → łagodny test → widoczna korekta. Wcześniejsza plansza treningowa działa bez konieczności nazywania i zapisywania projektu.

**Sytuacje brzegowe:** komunikat „YOUR BLUEPRINT SAVES; THIS RUN RESETS” wyjaśnia zakres zapisu, jeśli zostanie wdrożony. Brak potwierdzonego zapisu blokuje zastąpienie jedynej zapisanej wersji, nie samą zabawę. Niedozwolone gniazdo wskazuje powód w podglądzie; nie wolno stawiać panelu na postaci ani zamknąć wyjścia innemu graczowi. Odchodzący właściciel nie zostawia zespołu bez możliwości zakończenia próby.

**Na szarym prototypie:** pasek paneli, test i wynik; projekt i uprawnienia tylko na czas sesji. Pełne BLUEPRINTS jest pracą po potwierdzeniu zabawy, nie warunkiem pierwszego eksperymentu.

## Wspólne zasady i kolejność

- W trakcie działania pokazujemy stan w świecie i HUD. Menu służy do wyboru między próbami, nie do wykonywania głównej czynności.
- Na premierę potrzebne są wyłącznie funkcje widoczne w danej pętli. Podmenu nie muszą być stałymi ikonami przy krawędzi ekranu; SETTINGS może być wspólnym wejściem.
- Telefon poziomo: duże cele dotykowe, bez nakładania na joystick i skok, bez precyzyjnego drag-and-drop. Kryteria rozmiaru i późniejsze rozdzielczości testowe określa [[playbook/MOBILE_UI]]; nie zmieniam tych wartości.
- Źródłem stylu jest [[playbook/UI_STYLE]], nie cudzy interfejs. Wspólny styl okien nie narzuca tej samej liczby zakładek każdej grze.
- Zgodnie z AGENTS przed serią UI należy pokazać użytkownikowi pojedynczą próbkę. Dziś powstaje tylko tekstowa propozycja; nie budowano ekranów, ikon ani komponentów.
- Kolejność po wyborze użytkownika: szary prototyp czynności → test zabawy i telefonu → próbka najważniejszego okna → ocena wyglądu → dopiero pozostałe menu. Bez publikacji i zakupów.

## Źródła — LihFolk Vault V2 (CC BY 4.0)

Odczyt 30.10.2026. Ścieżki względem `C:/Users/bruno/Documents/LihFolk/full/LihFolk Vault V2/LihFolk Vault V2/`.

- **G1:** `10 Game Design and Genres/Genre Playbook - Obbies and Platformers.md`, TL;DR i „Variants”: czytelna próba i punkt restartu.
- **G2:** `10 Game Design and Genres/Genre Playbook - Party and Minigame Collections.md`, „Timing and dead time”, „Minigame design”, „Rewards and progression”, „Common mistakes”: brak pustego oczekiwania, prosta reguła, cel widoczny, udział słabszych graczy.
- **G3:** `10 Game Design and Genres/Genre Playbook - Survival and Crafting.md`, sekcje wymienione przy A3: ograniczony model świata, prawa do budowy, czytelny zapis, gniazda i katalog dostępnych elementów jako adaptacja.
- **G4:** `59 Viral and Trend Game Teardowns/Teardown - Fling Things and People.md`, „Core loop”, „First 60 seconds”, „Retention hooks”: chwyt i rzut, społeczna zabawa, przedmioty i domy jako późniejsze rozszerzenia.
- Pomocniczo LihFolk Vault V2: `59 Viral and Trend Game Teardowns/Teardown - Escape Tsunami for Brainrots.md`, „First 60 seconds” i „Core loop” — różnica między ryzykiem niesienia a zabezpieczonym obiektem.

Nie używano internetu do ustalania potrzeb menu ani wiedzy o implementacji. Powyższe propozycje nie wymagają przyjęcia historycznych cen, statystyk retencji ani deklarowanych reguł platformy z biblioteki.

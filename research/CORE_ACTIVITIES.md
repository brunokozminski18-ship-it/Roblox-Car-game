# Główne czynności pod mem — 30.10.2026

Status: PLANNED / NOT FINAL. Propozycje autora, nie zatwierdzony projekt ani wynik testu.

## Jak czytać

Cel: wybrać czynność, która bawi bez sklepu, petów i Rebirth. Nazwy robocze dla gracza są po angielsku. Mem powinien zmieniać regułę, zagrożenie lub zachowanie obiektu, a nie tylko teksturę.

**Pochodzenie liczb:** 7 propozycji mieści się w zamówionych 6–8; okna 10 s i 30 s, zakres 1–2 dni oraz kryteria i procedura testu pochodzą z polecenia i [[playbook/FUN_CHECKLIST]]. Wszystkie opisane efekty w tych oknach to CELE PROJEKTOWE, nie zmierzone czasy. Liczebność scen, przeszkód i wariantów niżej to ZAŁOŻENIA AUTORA ograniczające prototyp. Ranking jest oceną autora, bez danych o retencji. Nie używam historycznych CCU jako dowodu, że propozycja zadziała.

## Ranking i ocena FUN_CHECKLIST

P = rozwiązanie zaplanowane i opisane poniżej; ? = wymaga testu, nie można ocenić z dokumentu; S = słaby punkt koncepcji. P nie oznacza VERIFIED. Kryteria F1–F10 odpowiadają kolejno pytaniom checklisty: czasownik, przyjemność bez nagród, reakcja świata, wybór/umiejętność, inni gracze, widoczny cel, wejście i nagroda, jutro, telefon, mem.

| Miejsce autora | ID / czynność | F1 | F2 | F3 | F4 | F5 | F6 | F7 | F8 | F9 | F10 | Uzasadnienie kolejności |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | A1 Ratuj | P | ? | P | P | P | P | ? | P | ? | P | Decyzja zawróć albo ryzykuj jest widoczna w świecie; proste sterowanie, szybki reset. |
| 2 | A2 Rzucaj | P | ? | P | P | P | P | ? | S | ? | P | Każdy rzut tworzy zdarzenie; największa niewiadoma to czytelność chwytu na dotyku i powrót jutro. |
| 3 | A3 Osłaniaj | P | ? | P | P | P | P | ? | P | ? | P | Własna konstrukcja natychmiast zdaje test; ryzyko, że budowanie spowolni wejście. |
| 4 | A4 Wykradaj | P | ? | P | P | P | P | ? | P | ? | P | Mocny konflikt społeczny, ale wymaga przeciwników i może frustrować. |
| 5 | A5 Łap | P | ? | P | P | S | P | ? | P | ? | P | Łatwy prototyp; inni gracze mogą pozostać tylko widownią. |
| 6 | A6 Zastygaj | P | ? | P | P | P | P | ? | S | ? | P | Bardzo jasne reguły; samodzielnie ma mało odmian i słaby powód powrotu. |
| 7 | A7 Składaj | P | ? | P | P | P | P | ? | P | ? | P | Twórcze porażki dają komedię, ale ruchome konstrukcje zwiększają ryzyko przekroczenia zakresu. |

Próg z FUN_CHECKLIST: jeśli 3 z pierwszych 5 odpowiedzi to „nie”, zmieniamy czynność. Tutaj brak takich rozstrzygnięć, bo „?” nie jest „tak”. Nie przyznaję punktów za nieprzeprowadzone testy. S przy F5 A5 i F8 A2/A6 oznacza problem, który trzeba rozwiązać przed wyborem, a nie udowodnioną porażkę.

## A1 — Ratuj / Rescue Before the Roar

- **Czasownik:** ratuj.
- **Zwrot:** niesiony stworek budzi zagrożenie swoim hałasem, więc gracz wybiera między krótszą głośną drogą a wolniejszym, cichszym objazdem.
- **W 10 s:** podchodzi do bliskiego klocka-stworka, chwyta go dużym przyciskiem i widzi, jak podnosi się wskaźnik hałasu oraz zbliża ściana zagrożenia.
- **Reguła do prototypu (propozycja autora):** głośny fragment skrótu uruchamia wyraźnie zapowiedziany impuls zagrożenia tylko na danym pasie trasy; objazd omija wyzwalacz. Nie karzemy całego serwera za hałas innej osoby. Wskaźnik pokazuje stan wyzwalacza, nie arbitralną karę po fakcie.
- **Nagroda do 30 s:** donosi łatwy obiekt do widocznego schronu; stworek zajmuje miejsce na półce, zapala się uratowany segment. Bez losowania i bez kupowania prędkości.
- **Inni:** kompan otwiera boczną osłonę, pomagając niosącemu; samotny gracz ma dostępną łatwą drogę. Nikt nie blokuje wejścia ani nie odbiera już uratowanych obiektów.
- **Jutro:** zapisywana galeria uratowanych odmian i nowy układ osłon; wymaga osobnego przygotowania zawartości. Nie obiecujemy codziennego eventu bez zasobów na jego wykonanie.
- **Telefon:** joystick i kontekstowy przycisk podnieś/upuść; automatyczny wybór pobliskiego obiektu, szerokie wejścia. Zagrożenie komunikowane kształtem, ruchem i dźwiękiem, nie samym kolorem.
- **Pasujące memy:** krzyczący zwierzak, przesadnie głośny przedmiot, absurdalny kurier; mem musi tłumaczyć hałas i ucieczkę. To rodziny motywów, nie twierdzenie, że obecnie rosną.
- **Szare klocki, 1–2 dni:** jedna trasa, bliska i dalsza strefa odbioru, dwie drogi powrotne, schron, przewidywalna ściana i klapka pomocy. Najpierw sama pętla podnieś–decyzja–powrót. Bez bazy zarabiającej pieniądze, AI potwora i kolekcji do zapisu w prototypie.
- **Najważniejszy test:** czy ktoś sam próbuje trudniejszej drogi po dostarczeniu łatwego obiektu? Jeżeli jedynie czeka na wzrost licznika, zmienić trasę lub hałas, nie dokładać ulepszeń.
- **Podstawa:** LihFolk Vault V2 [L1] „Core loop”, „First 60 seconds”, „Multiplayer”; [L2] „twist”; [L3] TL;DR o czytelnym zagrożeniu, kontrze i widocznym postępie. Hałas i pomocnicza klapka są moją propozycją.

## A2 — Rzucaj / Fling the Problem

- **Czasownik:** rzucaj.
- **Zwrot:** zamiast rzucać bez celu, wspólnie przerzucacie niezgrabny przedmiot przez coraz dziwniejsze bramki.
- **W 10 s:** chwyta duży przedmiot stojący przed nim, widzi prosty łuk rzutu, puszcza go i przewraca klockową przeszkodę.
- **Nagroda do 30 s:** trafia w szeroki cel, otwiera kolejną bramkę i widzi ślad najlepszego trafienia; nagrodą jest nowa zabawka do użycia, nie mnożnik.
- **Inni:** mogą odbić albo złapać przedmiot na drugiej stronie; cel solo pozostaje dostępny. Rzucamy rekwizytami, a łapanie graczy tylko w dobrowolnym trybie zabawy, by nie zamienić wejścia w nękanie.
- **Jutro:** SŁABY PUNKT: bez nowych urządzeń jest to przede wszystkim zabawka na spotkanie ze znajomymi. Propozycja później: zapisana kolekcja trafień i zmienny tor; nie traktować samej dziennej nagrody jako naprawy.
- **Telefon:** kontekstowy chwyt najbliższego obiektu, duża strefa celu i puść = rzuć; bez konieczności ręcznego celowania kamerą w mały punkt. Nie zakładamy, że mobilny chwyt już działa.
- **Pasujące memy:** przedmiot „zbyt ciężki”, sprężysty kot, nieudolny dostawca; żart wynika z masy, odbicia lub kształtu obiektu.
- **Szare klocki, 1–2 dni:** arena, chwyt, ograniczony rzut, miękki i ciężki rekwizyt, szeroki kosz i przegroda. Reset obiektów, ograniczenie liczby rekwizytów, bez edytora świata i zapisu domów.
- **Najważniejszy test:** po usunięciu punktów gracze nadal podają, odbijają i powtarzają rzuty; jeśli muszą walczyć z kamerą, uprościć chwyt.
- **Podstawa:** LihFolk Vault V2 [L4] „Core loop”, „First 60 seconds”, „Retention hooks”; [L5] „Minigame design” i ograniczanie bezczynności. Bramki i podania to adaptacja autora, nie opis gry źródłowej.

## A3 — Osłaniaj / Build Against the Bonk

- **Czasownik:** osłaniaj.
- **Zwrot:** układasz osłonę przed nadciągającym absurdalnym zagrożeniem, a po uderzeniu natychmiast widać, co zbudowałeś źle.
- **W 10 s:** bierze gotowy panel z paska, umieszcza go w dużym podświetlonym gnieździe i osłania figurkę.
- **Nagroda do 30 s:** pierwsze łagodne uderzenie omija osłoniętą figurkę, odblokowując zakrzywiony panel do następnej próby. To test podstawowego schronienia, nie pełna noc survivalu.
- **Inni:** jeden gracz zakrywa przód, drugi zabezpiecza bok; wspólna próba pokazuje wkład każdego. Własna mała plansza treningowa pozwala zacząć bez grupy.
- **Jutro:** zapis ulubionego projektu i kolejne kierunki ataku; poprawa konstrukcji ma znaczenie. Brak niszczenia bazy pod nieobecność właściciela.
- **Telefon:** wybór elementu z krótkiego paska i stuknięcie gniazda; podgląd poprawnego miejsca i prosty obrót. Bez swobodnego przeciągania drobnych części.
- **Pasujące memy:** wielki but, kichający zwierzak, spadający absurdalny produkt; kształt lub kierunek zagrożenia wpływa na osłonę.
- **Szare klocki, 1–2 dni:** niewielka plansza z gniazdami, prosty i zagięty panel, figurka-cel, atak z przodu i z boku, szybka naprawa po próbie. Bez głodu, zbierania drewna, otwartego świata, skomplikowanej fizyki gruzu i trwałego zapisu.
- **Najważniejszy test:** czy po utracie figurki gracz sam przesuwa panel i próbuje znowu? Czy rozumie powód przegranej bez tłumaczenia?
- **Podstawa:** LihFolk Vault V2 [L6] „Core loop”, „Building”, „Multiplayer”; [L3] widoczny obiekt postępu i role; [L7] przetrwanie czytelnego zagrożenia. Prosty test osłon to świadome ograniczenie survivalu, nie pełny gatunek.

## A4 — Wykradaj / Steal the Noisy Flag

- **Czasownik:** wykradaj.
- **Zwrot:** wykradasz publiczne hałasujące trofeum, lecz możesz podrzucić je koledze, żeby zmylić pościg.
- **W 10 s:** podnosi neutralne trofeum z centrum i widzi drogę do mety oraz alarm zdradzający niosącego.
- **Nagroda do 30 s:** dostarcza treningowe trofeum do strefy i zdobywa wynik rundy. Nie kradnie trwałej kolekcji ani zakupów innych graczy.
- **Inni:** obrońcy przecinają trasę, koledzy przejmują podanie; bez przeciwnika działa ćwiczenie dostarczenia, ale właściwe napięcie wymaga ludzi.
- **Jutro:** rewanż drużynowy, nowe trasy i kosmetyczne odznaki za opanowanie podań, bez utraty dorobku offline.
- **Telefon:** przycisk podnieś/podaj wybiera pobliskiego partnera; krótkie drogi i szerokie strefy przechwycenia, bez precyzyjnego strzelania.
- **Pasujące memy:** złodziej przekąski, głośna maskotka, uciekający przedmiot. Sygnał zdradzający pozycję jest częścią żartu.
- **Szare klocki, 1–2 dni:** centralne trofeum, dwie mety, drogi skrótu i objazdu, podanie, przechwycenie i reset. Bez ekonomii, płatnych tarcz, trwałych baz i dobierania między serwerami.
- **Najważniejszy test:** czy przegrany chce rewanżu i rozumie przechwycenie? Odrzucić wariant, jeśli grupa stale gnębi nowego gracza.
- **Podstawa:** LihFolk Vault V2 [L8] TL;DR — widoczne ryzyko i kontra; [L5] rundy zespołowe, jasny stan i możliwy powrót do rywalizacji. Podania i brak trwałej straty są propozycją autora.

## A5 — Łap / Catch the Weird One

- **Czasownik:** łap.
- **Zwrot:** absurdalne stworzenia uciekają różnymi rytmami, więc rozpoznajesz ich ruch zamiast bezmyślnie czekać na losowanie.
- **W 10 s:** nad szeroką strefą widzi powtarzalny ruch i przytrzymuje przycisk, puszczając w chwili przejścia obiektu przez oznaczony obszar.
- **Nagroda do 30 s:** łatwy pierwszy chwyt trafia do widocznego albumu z pustą sylwetką następnej odmiany.
- **Inni:** wspólny duży cel wymaga naprzemiennych chwytów; SŁABY PUNKT: w wersji solo inni są tylko publicznością, współpraca potrzebuje osobnego sprawdzenia.
- **Jutro:** uzupełnienie skończonego albumu i opanowanie następnego wzorca ruchu; bez wymuszania obecności o konkretnej godzinie.
- **Telefon:** przytrzymaj/puść w dużej strefie, bez śledzenia małego kursora; rytm pokazany także ruchem i ikoną.
- **Pasujące memy:** zwierzę z charakterystycznym chodem, przedmiot nagle ożywający, zmiana skali; zachowanie musi zmieniać moment chwytu.
- **Szare klocki, 1–2 dni:** tor, strefa chwytu, łatwy i przerywany rytm, album sesji, współdzielony cel. Bez świata łowienia, rzadkości, losowych dropów, wędek i handlu.
- **Najważniejszy test:** czy kolejny chwyt jest ciekawszy dzięki rozpoznaniu rytmu, nawet bez albumu? Jeśli nie, to kolekcjoner z nową oprawą.
- **Podstawa:** LihFolk Vault V2 [L9] TL;DR — umiejętność w minigrze i skończony cel kolekcji. Stosuję tę zasadę bez kopiowania wędkowania.

## A6 — Zastygaj / Freeze When It Looks

- **Czasownik:** zastygaj.
- **Zwrot:** ogromna maskotka patrzy tylko wtedy, gdy kończy swój przesadzony gest, a gracz decyduje, kiedy zaryzykować ostatni krok.
- **W 10 s:** idzie do widocznej bramy, rozpoznaje zapowiedź obrotu, zatrzymuje się przed spojrzeniem i widzi, jak inny klocek zostaje cofnięty.
- **Nagroda do 30 s:** osiąga pierwszy bezpieczny fragment trasy; checkpoint pozostaje po pomyłce. Nie czeka wyeliminowany na koniec całej rundy.
- **Inni:** wspólny wyścig, widoczne pomyłki i ratunek przy bocznym przełączniku; pomoc nie jest wymagana do ukończenia.
- **Jutro:** SŁABY PUNKT: sam zmienny timing nie wystarczy. Potrzebne ręcznie zaprojektowane odmiany reguły i trasy; nie proponuję dużej kolekcji minigier jako szybkiej łatki.
- **Telefon:** ruch joystickiem i puszczenie; zapowiedź w animacji i ikonie, tolerancja zatrzymania do sprawdzenia w przyszłych testach.
- **Pasujące memy:** przesadna mina, niezręczne spojrzenie, zwierzak nagle odwracający głowę; bez kopiowania identyfikacji serialu.
- **Szare klocki, 1–2 dni:** korytarz, punkt kontrolny, obracający się klocek, zapowiedź spojrzenia i cofnięcie zamiast długiej eliminacji. Bez głosowania, sezonu i zestawu konkurencji.
- **Najważniejszy test:** czy gracz potrafi przewidzieć spojrzenie i rozumie cofnięcie? Jeśli kara wygląda na przypadkową, przerwać rozwijanie wariantu.
- **Podstawa:** LihFolk Vault V2 [L10] TL;DR — jasna reguła i uczciwa eliminacja; [L11] TL;DR oraz „Variants” — tania próba, czytelny checkpoint; [L5] bezczynność po porażce.

## A7 — Składaj / Build a Silly Escape

- **Czasownik:** składaj.
- **Zwrot:** tworzysz pojazd ucieczkowy z absurdalnych części, a krótki przejazd od razu obnaża jego słaby punkt.
- **W 10 s:** dokłada szeroką osłonę do gotowego podwozia i naciska LAUNCH; nie buduje od zera.
- **Nagroda do 30 s:** przejeżdża przez łagodną przeszkodę, dostaje kolejny element i widzi ślad najdalszego przejazdu.
- **Inni:** budują razem lub oglądają awarię sąsiedniej konstrukcji; proste przypisanie własności części zapobiega rozbieraniu cudzej pracy.
- **Jutro:** zapisany projekt, poprawiona konstrukcja i inny układ przeszkód; wartość ma własna kreacja, nie sama waluta.
- **Telefon:** gniazda na podwoziu i katalog dużych klocków, bez swobodnego modelowania i sterowania pojazdem podczas testowego przejazdu.
- **Pasujące memy:** zbyt duży bagaż, dziwny pojazd, przedmiot w roli silnika; część powinna zmieniać równowagę lub osłonę.
- **Szare klocki, 1–2 dni:** gotowe podwozie, osłona i szeroka podpora, prosty zjazd oraz przeszkoda. Bez wody, symulacji wyporu, silników, dowolnego spawania i świata eksploracji. Jeśli ruch konstrukcji jest niestabilny, testujemy stałe podwozie i odpinane panele zamiast rozbudowywać fizykę.
- **Najważniejszy test:** czy gracz po awarii zmienia konstrukcję z jasnym zamiarem, czy wyłącznie szuka najmocniejszego klocka?
- **Podstawa:** LihFolk Vault V2 [L12] „Retention hooks”, „Multiplayer”, „Technical notes” — twórczość z celem, zapis projektu i koszt fizyki; [L6] gniazda i ograniczanie zakresu. Gotowe podwozie jest ograniczeniem autora.

## Jak rozstrzygnąć ranking później

Na razie nie budujemy niczego. Propozycja do wyboru przez użytkownika: zacząć od A1, porównać z A2, a A3 zachować jako wariant twórczy. Zgodnie z [[playbook/FUN_CHECKLIST]] późniejszy test to 15 minut i 3 osoby na telefonie; obserwować samodzielne ponowienie czynności i powód zatrzymania. Telefon poziomo; PC pomocniczo. Zapisywać obserwacje oddzielnie od interpretacji. Żadna koncepcja nie jest USER APPROVED ani VERIFIED.

## Źródła — LihFolk Vault V2 (CC BY 4.0)

Ścieżki L1–L12 są względem `C:/Users/bruno/Documents/LihFolk/full/LihFolk Vault V2/LihFolk Vault V2/`. Odczyt 30.10.2026. Nie kopiowano biblioteki; powyżej własne adaptacje zasad i pętli. TL;DR czytano w każdej wskazanej notatce; rozwinięcia wymieniono przy koncepcjach.

- **L1:** `59 Viral and Trend Game Teardowns/Teardown - Escape Tsunami for Brainrots.md`.
- **L2:** `59 Viral and Trend Game Teardowns/Viral Game Anatomy - Hooks, Loops and Timing.md`, TL;DR.
- **L3:** `32 Case Studies of Top Roblox Games/Case Study - 99 Nights in the Forest.md`, TL;DR.
- **L4:** `59 Viral and Trend Game Teardowns/Teardown - Fling Things and People.md`.
- **L5:** `10 Game Design and Genres/Genre Playbook - Party and Minigame Collections.md`, sekcje „Timing and dead time”, „Minigame design”, „Rewards and progression”.
- **L6:** `10 Game Design and Genres/Genre Playbook - Survival and Crafting.md`, „Core loop”, „Session length and persistence model”, „Building”, „Multiplayer, PvP and griefing”.
- **L7:** `59 Viral and Trend Game Teardowns/Teardown - Natural Disaster Survival.md`, TL;DR.
- **L8:** `32 Case Studies of Top Roblox Games/Case Study - Steal a Brainrot.md`, TL;DR.
- **L9:** `32 Case Studies of Top Roblox Games/Case Study - Fisch.md`, TL;DR.
- **L10:** `59 Viral and Trend Game Teardowns/Teardown - Ink Game.md`, TL;DR.
- **L11:** `10 Game Design and Genres/Genre Playbook - Obbies and Platformers.md`, TL;DR i „Variants”.
- **L12:** `59 Viral and Trend Game Teardowns/Teardown - Build A Boat For Treasure.md`.
- **L13:** `C:/Users/bruno/Documents/LihFolk/full/LihFolk Vault V2/skills/roblox-trend-game/SKILL.md` i `references/trend-games-research.md`: „Executive summary”, „Platform context”, „How to spot the next trend”, „What separates hits from failed clones”. Zastosowano rozróżnianie etykiet źródłowych, nową regułę zamiast samej podmiany grafiki i ostrożność wobec trackerów. Nie przyjęto gotowej ekonomii ani harmonogramu jako decyzji użytkownika.


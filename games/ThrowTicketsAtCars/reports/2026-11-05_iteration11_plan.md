# Iteracja 11 — plan
Spec: zlecenie użytkownika 05.11.2026 i research/CarList_draft.md (74 pozycje, 10 biomów). Rojo/Luau; wykonanie w tym chacie. Wygląd i lista NOT FINAL. Bez Rebirth/Robux/publikacji; teksty EN.

- [x] Catalog: osobny moduł danych, 74 stabilne nowe Id, opis i rodzina bryły. Config nadal udostępnia wszystkie dane gry. Biomy 1..10 aktywne, ComingSoon osobno.
- [x] Schema7: jawna mapa starych 6 biomów do 1/2/3/7/8/9, Luxury Classics→Millionaire Hills. Mapowanie auta w tej samej rzadkości, zachowane Id/slot/odmiana/mandat; odkrycia też mapowane. Testy wszystkich 48 starych pozycji i wcześniejszych formatów.
- [x] Ekonomia: ceny w minutach, 10 poziomów progów/dochodu, trening i mandaty zachowują role; stare Id sprzętu zachowane i nowe dopisane. Progi Power są też dystansem mapy. Symulacja używa XP i prawdziwego losowania rarity/model/variant; kilka seedów, wariant bez boostu, jawne założenia aktywnej gry.
- [x] Mapa: segmentowana droga 10 biomów, różne podłoża, 2–3 proste rekwizyty; dwa zamknięte odcinki za MapEnd, brak ich w Rules.rollCar i brak dostępnych kart aut w Index.
- [x] Modele: wspólne prymitywy i pivot Body/Windshield zgodny z transportem; 4 staranne próbki, pozostałe 70 z prostymi rozpoznawalnymi rodzinami i detalami. Wszystkie sprawdzone geometrycznie, bez dopracowywania serii przed akceptacją.
- [x] QA: 10k losowań dla kilku biomów, brak łapania ComingSoon, migracja starego QA przez zapis/rejoin, Index74 + 2 blokady, telefon poziomo, zrzuty 4 aut i mapy. Raport/lista, dokumentacja, commit; Edit/QA/emulator przywrócone. Zatrzymać się na ocenę próbek.

Źródło wiedzy: LihFolk Vault V2 (CC BY 4.0), MCP tylko odczyt. Parts Unions and MeshParts: części z nazwami/pivotem, blockout jako styl; Progression and Pacing / Pricing Curves: czas celu i piłokształtne korzyści, koszty przeciw korzyściom; RNG/Collection: odds wyliczane z prawdziwych wag. Asset Pack sprawdzany wyłącznie przez CATALOG.csv, bez kopiowania Dataset.

Wynik:3560asercji,40krolls,5seedów i wolniejszy wariant; QA schema6→7/save/rejoin/Index/Future. Przegląd zamknął anchor i wysokość modeli oraz test pacing. Seria zatrzymana na ocenie4 próbek, pozostałe70 uproszczone.

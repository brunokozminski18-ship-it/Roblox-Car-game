# Progresja 18 biomów: balans i plan wydań (08.11.2026)

Status: **PLANNED / NOT FINAL**. To projekt do akceptacji użytkownika, a nie decyzja. Do `DECISIONS` gry trafia dopiero po jego akceptacji.
Autor: Claude (projekt i obliczenia). Wykonanie w kodzie: Codex, po akceptacji.
Lista aut: [[research/CarList_18biomes]]. Obliczenia: `research/progression18_sim.py` (uruchom: `python research/progression18_sim.py`).
Źródła: LihFolk Vault V2 (CC BY 4.0): *Progression and Pacing Design*, *Rarity Ladders and Drop Pacing Math*, *RNG Drops and Luck Systems*, *Genre Playbook - RNG and Collection Games*, *Pricing Curves and Upgrade Costs*, *Update Cadence and Hype Cycles*. Stan gry: `CarCatalog.luau`, `Config.luau`, symulacja z iteracji 11.

## 1. Co zostaje bez zmian
- Pętla: trening → Power → rzut mandatem → biom zależny od Power → złapanie → laweta → działka. Mandat daje tylko luck i mnożnik dochodu, nigdy zasięg.
- Rzadkości 70/22/7/1 (C/R/E/L), w biomie 3C/2R/2E/1L. Odmiany Gold 5% ×2, Diamond 1% ×4, Neon 0,25% ×8.
- Ceny w minutach dochodu referencyjnego biomu, w którym rzecz się odblokowuje. Tempo piłokształtne: po wejściu do nowego biomu skok dochodu, potem dłuższe zbieranie.
- Biomy 1–10 i ich progi Power (0/50/150/300/550/900/1400/2200/3400/5000), dochody bazowe i mandaty 1–11: bez zmian.
- Bez Rebirth (decyzja 03.11.2026).

## 2. Plan wydań
Nie wszystkie 144 auta muszą być gotowe na start. Na premierę: biomy 1–10 (80 aut: 74 obecne + 6 uzupełnień, żeby każdy biom miał 8).

| Wydanie | Biomy | Nowe auta | Kiedy (cel) | Dlaczego |
| --- | --- | --- | --- | --- |
| Premiera | 1–10 | 6 | start | ok. 5,6 h aktywnej gry do Future City |
| U1 | 11 Moon Base, 12 Candy Land | 16 | +7 dni | oba już widać jako COMING SOON; zaangażowani gracze (2 h/dzień) dochodzą do końca w 3.–4. dniu |
| U2 | 13 Volcano Road, 14 Toy Town | 16 | +14 dni | utrzymuje tempo trendu w drugim tygodniu |
| U3 | 15 Haunted Highway, 16 Dino Valley | 16 | +28 dni | od teraz co 2 tygodnie (LihFolk: treść co 2–4 tygodnie) |
| U4 | 17 Ocean Floor, 18 Cosmic Highway | 16 | +42 dni | finał drogi |

- Każda aktualizacja odsłania kolejne dwa biomy jako COMING SOON (zamknięta brama), żeby zawsze był widoczny następny cel.
- Między aktualizacjami pościg trwa dalej: komplet Indexu, odmiany Gold/Diamond/Neon i Luckiest Catch.
- Aktualizację wypuszczamy przed otwarciem treści i odblokowujemy ją czasem serwera, żeby był czas na poprawki (LihFolk, *Update Cadence*).

## 3. Progresja (wynik symulacji)
Czas „w biomie” to cel aktywnej gry, z którego wyliczono `WorkPerPower`. Założenie: 70% czasu na treningu, 30% na rzucaniu. Wartości 1–10 pochodzą z gry, a 11–18 to nowe propozycje.

| # | Biom | Wydanie | Power od | Czas w biomie | Łącznie | WorkPerPower | Dochód bazowy/s | Mandat × / luck | Ćwiczenie | Mandat |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | Junkyard | Premiera | 0 | 3 min | 0,1 h | gra: 4 | 1 | ×1 / 0 | 0 | 0 |
| 2 | Suburbs | Premiera | 50 | 5 min | 0,1 h | gra: 8 | 5 | ×1,5 / 0,05 | 1 min | 1,5 min |
| 3 | Downtown | Premiera | 150 | 10 min | 0,3 h | gra: 16 | 22 | ×2,2 / 0,10 | 2 min | 3 min |
| 4 | Farm Roads | Premiera | 300 | 17 min | 0,6 h | gra: 35 | 90 | ×3,2 / 0,15 | 3 min | 4 min |
| 5 | Desert Highway | Premiera | 550 | 25 min | 1,0 h | gra: 90 | 360 | ×4,6 / 0,20 | 4 min | 5 min |
| 6 | Snowy Pass | Premiera | 900 | 35 min | 1,6 h | gra: 150 | 1,4K | ×12 / 0,25 | 5 min | 6 min |
| 7 | Sports Track | Premiera | 1 400 | 45 min | 2,3 h | gra: 400 | 5,5K | ×18 / 0,30 | 6 min | 8 min |
| 8 | Millionaire Hills | Premiera | 2 200 | 55 min | 3,2 h | gra: 800 | 21K | ×27 / 0,35 | 7 min | 10 min |
| 9 | Hypercar Island | Premiera | 3 400 | 65 min | 4,3 h | gra: 1 800 | 80K | ×40 / 0,40 | 8 min | 12 min |
| 10 | Future City | Premiera | 5 000 | 75 min | 5,6 h | gra: 2 500 | 300K | ×60 / 0,45 | 10 min | 15 min |
| 11 | Moon Base | U1 | 7 000 | 95 min | 7,2 h | 3 060 | 720K | ×90 / 0,50 | 12 min | 20 min |
| 12 | Candy Land | U1 | 9 500 | 115 min | 9,1 h | 6 190 | 1,7M | ×103,5 / 0,57 | 14 min | 22 min |
| 13 | Volcano Road | U2 | 12 500 | 140 min | 11,4 h | 11 350 | 4,1M | ×119 / 0,64 | 16 min | 25 min |
| 14 | Toy Town | U2 | 16 500 | 165 min | 14,2 h | 21 470 | 10M | ×136,8 / 0,71 | 18 min | 28 min |
| 15 | Haunted Highway | U3 | 21 500 | 195 min | 17,4 h | 39 170 | 23,9M | ×157,3 / 0,78 | 20 min | 31 min |
| 16 | Dino Valley | U3 | 28 000 | 225 min | 21,2 h | 73 630 | 57,3M | ×180,9 / 0,85 | 22 min | 34 min |
| 17 | Ocean Floor | U4 | 36 000 | 260 min | 25,5 h | 136 250 | 137,6M | ×208 / 0,92 | 25 min | 38 min |
| 18 | Cosmic Highway | U4 | 46 000 | 300 min | 30,5 h | 224 920 | 330,2M | ×239,2 / 0,99 | 28 min | 42 min |

- Koniec drogi: Power 60 000. Ćwiczenia 12–18 podwajają Work (2048 … 131 072), jak dotąd.
- Dla biomów 1–10 symulacja z celami czasowymi daje `WorkPerPower` 5/8/20/42/88/175/282/461/820/1505. Gra ma dziś 4/8/16/35/90/150/400/800/1800/2500, a pomiar Codexa dał 6,7 h do Future City. Różnica (5,6 h tutaj, 6,7 h w grze) mieści się w dokładności modelu. **Biomów 1–10 nie przestawiamy przed testem z ludźmi.**
- Na wejściu do nowego biomu auta są ok. 2,4–4× cenniejsze. Gracz od razu czuje skok, a dopiero potem zbiera na następne ćwiczenie.
- Ciężkie progi nie wydłużają gry sztucznie: każdy biom daje nowe auta, nowe ćwiczenie i nowy mandat. Najdłuższa cena to 42 min dochodu i to zawsze na koniec biomu, kiedy gracz ma już zapełnioną działkę.

## 4. Rzadkość i szanse
Liczone w `progression18_sim.py`: ok. 1,3 złapania na minutę aktywnej gry.

| Luck | Common | Rare | Epic | Legendary | Konkretne Legendary | Legendary Neon | Legendary: mediana / p90 / p99 złapań | Komplet 8 aut biomu |
|---|---|---|---|---|---|---|---|---|
| 0 | 70,0% | 22,0% | 7,0% | 1,00% | 1 in 100 | 1 in 40 000 | 69 / 230 / 461 | ~111 złapań |
| 0,5 | 60,9% | 28,7% | 9,1% | 1,30% | 1 in 77 | 1 in 21 083 | 53 / 177 / 353 | ~86 |
| 1,0 | 53,8% | 33,8% | 10,8% | 1,54% | 1 in 65 | 1 in 13 812 | 45 / 150 / 299 | ~73 |

Wnioski:
- Pierwsze Legendary przy luck 0 to mediana ok. 54 min aktywnej gry, ale p90 to ok. 3 h. Pechowa dziesiątka graczy czeka za długo, a LihFolk wymaga pity dla każdego rzadkiego pościgu.
- Luck rośnie łagodnie, a przy maksimum 1,0 Legendary jest tylko 1,5× częstsze. Drabina się nie rozpada (LihFolk, *Luck inflation*).
- Komplet Indexu biomu to ok. 73–111 złapań. W biomach 1–5 gracz przechodzi dalej wcześniej, więc wraca tam suwakiem siły, co jest dobrym, dobrowolnym celem. W biomach 11–18 komplet zdobywa się w trakcie przejścia.

**Propozycje do akceptacji użytkownika:**
1. **Pity Legendary:** gwarantowane Legendary najpóźniej co 120 złapań (licznik na serwerze, zapisywany w profilu, zerowany przez każde Legendary). Nikt nie czeka dłużej niż ok. 90 min, a mediana się prawie nie zmienia. Wyświetlane „1 in X” liczymy z tabeli, a pity podajemy osobno.
2. **Pierwsza sesja:** trzecie złapanie w grze to gwarantowane Rare, a dziesiąte to gwarantowane Epic. Każdy nowy gracz ma wtedy „wow” w pierwszych 5 minutach (LihFolk, *FTUE*).
3. **Limit luck = 1,0** (mandaty 12–18 dochodzą najwyżej do 0,99). Przyszłe źródła luck (eventy, Server Luck, płatne) sumujemy, a nie mnożymy, i obejmuje je ten sam limit.
4. **Nagrody Indexu:** 4/8 aut biomu daje darmowe auto z tego biomu, a 8/8 daje odznakę biomu i +2% dochodu na stałe (sumuje się, maks. +36% przy 18 biomach). LihFolk: nagradzać po drodze, nie tylko za 100%.

## 5. Ekonomia: zmiany techniczne
- **MaxCash:** dziś 1e15, a najwyższa cena w biomie 18 to ok. 4,7e15. Podnieść do **9e15** (2^53, czyli największa liczba całkowita, którą Luau zapisze dokładnie). Wzrost biomów 11–18 jest celowo spłaszczony (dochód ×2,4 na biom, mandat ×1,15), żeby się w tym zmieścić. Nie przekraczać tego limitu w kolejnych biomach bez osobnego projektu dużych liczb.
- **Tablica Top Money** już przybliża wartości powyżej 1M. Sprawdzić ją dla wartości rzędu 1e15.
- Ceny parkingu (3/7/15/30/60 min dochodu startowego) bez zmian.

## 6. Długość mapy (do decyzji)
Dziś miejsce lądowania to `min(MapEnd, Power×(1+bonus))` w studach, a MapEnd to 6000. Przy Power 46 000–60 000 mapa miałaby 60 km, co jest za długie dla lotu mandatu (2 s), kamery i streamingu.
**Propozycja:** odczepić studs od Power. Każdy biom dostaje stały odcinek drogi (np. 600 studów), a pozycję wylicza funkcja przedziałami liniowa po progach Power. Biomy 1–10 można zostawić w obecnej geometrii i dokładać po 600 studów, więc 18 biomów zajmie ok. 10 800 studów. Wymaga testu w Studio (NEEDS VERIFICATION).

## 7. Sprawdzenie spójności
- [x] Mandat nie zmienia zasięgu w żadnym biomie, tylko luck i dochód.
- [x] Każdy biom 11–18 ma ćwiczenie, mandat, 8 aut (3/2/2/1) i własne „Power od”. Progi rosną ×1,26–1,36.
- [x] Ceny poniżej 2^53 po zmianie MaxCash. Najwyższa: mandat biomu 18, 42 min dochodu.
- [x] Luck ograniczony do 1,0, drabina rzadkości się nie rozpada.
- [x] Najdłuższe oczekiwanie na rzadkość ograniczone przez pity (propozycja 1).
- [x] Gracz, który niczego nie kupuje opcjonalnie, przechodzi dalej. Wszystkie progi zależą tylko od treningu i zarobionej kasy.
- [ ] Do zrobienia przez Codexa: powtórzyć ten balans w jego symulatorze (dokładny model rzutów, sprzedaży i parkingu) i dopasować `WorkPerPower` 11–18 do celów czasowych z tabeli.
- [ ] Test z ludźmi: czas do biomu 2 (cel 3 min), 5 (1 h) i 10 (5,5–6,5 h) oraz moment pierwszego Legendary.

## 8. Zadania dla Codexa (po akceptacji, w tej kolejności)
1. Premiera: 6 nowych aut w biomach 1–4 (lista w [[research/CarList_18biomes]]), żeby każdy biom miał 8. Index 80 aut.
2. Propozycje z punktu 4, które użytkownik zatwierdzi: pity, gwarancje pierwszej sesji, limit luck i nagrody Indexu.
3. MaxCash 9e15 i test tablic przy dużych liczbach.
4. Funkcja Power → pozycja na mapie (punkt 6), jeszcze przed U1.
5. U1–U4: dane z tabeli w punkcie 3 i auta z listy. Każda aktualizacja ma 2 biomy, a kolejne 2 widać jako COMING SOON.
6. Po każdej zmianie: symulacja (czas na biom, mediana i p90 Legendary) i raport w `reports/`.

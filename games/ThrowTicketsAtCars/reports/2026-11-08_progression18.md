# Raport: progresja 18 biomów (Claude, 08.11.2026)

Gałąź: `claude/progression-18`. Projekt: [[research/Progression18]], lista aut: [[research/CarList_18biomes]].

## Co zmieniono
- `CarCatalog.luau`: +6 aut w biomach 1–4 (każdy biom ma 8) i biomy 11–18 po 8 aut (razem 144). `Kind` tymczasowy.
- `Config.luau`: `Release` (ReleasedBiomes=10, PreviewBiomes=2, BiomeLength=800, PowerEnd=60000), `Luck` (Cap 1, pity 120, Rare 3., Epic 10.), `Index` (4/8 auto, +2% za 8/8), mandaty 12–19, ćwiczenia 12–19, WorkPerPower 11–18, MaxCash 9e15, schema 8. `Config.Biomes/Tickets/Exercises` = tylko wydane; pełne listy w `All*`.
- `Rules.luau`: mapa Power → studs (1–10 bez zmian), biom wg `Start`, `Rules.luck` z limitem, `guarantee`/`notePity`, `rollCar(..., pity)`.
- `JuiceRules`, `HUD`, `World`, `BiomeProps`: pozycje z `Start/Finish`; rekwizyty greybox dla biomów 11–18.
- `IndexRewards.luau` (nowy), `GarageRules.income` × bonus Indexu, `Main.server`: pity przy rzucie, nagrody Indexu po złapaniu i 3 s po wejściu.
- `ProfileSchema`: pola `Pity`, `IndexClaims`, migracja 7 → 8 (licznik = liczba odkryć, osiągnięte 4/8 oznaczone bez wstecznych aut).

## Testy (VERIFIED 08.11.2026, zakres: logika współdzielona)
Moduły gałęzi wgrane tymczasowo do `ServerStorage` w otwartym miejscu gry (bez zapisu, folder usunięty po teście):
- 287 kontroli: 286 PASS. Jedna rozbieżność to oczekiwanie testu (średnia Legendary z pity 120 = 1,42%, zgodnie z formułą), poprawione w dokumentacji.
- Start bez zmian: 10 biomów, mapa 6000, 11 mandatów, 11 ćwiczeń, COMING SOON = Moon Base, Candy Land.
- Najwyższa cena (mandat 19) 5,03e15 < MaxCash 9e15 < 2^53.
- Pity: najdłuższa przerwa bez Legendary 119 na 200 000 losowań; 3. złapanie ≥ Rare, 10. ≥ Epic.
- Index: 4/8 daje jedną nagrodę, 8/8 daje ×1,02 dochodu; zapis schema 8 i migracja 7 → 8 działają, zły pity odrzucony.
- `Main.server` z poprawkami kompiluje się (sprawdzone w Studio, bez uruchamiania gry).

## NIE sprawdzone
- Pełna rozgrywka w Play (rzut, reveal, laweta z nowymi polami), stare testy z `tests/` w nowym katalogu (zmieniono tylko oczekiwanie 74 → 80 w `iteration11.spec`), `ReleasedBiomes=18` na mapie, UI nagród Indexu, telefon.

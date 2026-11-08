# Stan gry

Stan teraz, nie historia (historia jest w gicie). Do ok. 80 linii.

## Działa (VERIFIED, data, zakres testu)
- Prototyp v2 `prototypes/A1v2_giant` — VERIFIED 31.10.2026, Studio Play, 1 gracz sterowany skryptem, emulator iPhone 13 Pro poziomo; Output bez błędów skryptów:
  - mysz: chwyt → gniazdo, +1 Crumbs, podpowiedź przechodzi do kaczątka;
  - papuga, bieg prosto po kafelkach: hałas pełny ok. z = −40, ostrzeżenie 1,5 s, „The giant heard you!”, powrót do gniazda bez papugi;
  - papuga, bieg i postój pod stołem: hałas spada do 0, potem do gniazda, +8 Crumbs;
  - papuga ze SNEAK: hałas nie przekracza ok. 25, bez budzenia (wolniej, ok. 12 s);
  - HUD na dole, przyciski SNEAK/DROP nie zasłaniają skoku (zrzuty: `reports/proto_v2/`).

## W toku / NOT FINAL
- Liczby hałasu (kafle 30/s, drewno 12/s, dywan 3/s, puste ręce ×0,25, papuga +25 co 2,5 s, kaczątko +14 co 4 s, garnek +30, ostrzeżenie 1,5 s) — do strojenia po teście z graczami.
- SNEAK może być za bezpieczny (głośne zwierzaki też bezpieczne przy skradaniu) — sprawdzić, czy ktoś w ogóle biega.

## Niesprawdzone (NEEDS VERIFICATION)
- Dotknięcie przycisków SNEAK/DROP palcem w emulatorze (sprawdzone klawiszami C/Q, ta sama funkcja).
- Kaczątko, garnki („CLANG!”), szafka i pudło jako kryjówki, kilku graczy naraz, PC.
- Czy to bawi: test z 3 osobami na telefonie (etap 3).

## Następny krok
Etap 3 planu: 15 min, 3 osoby na telefonie, zapis w `playtests/` wg [[playbook/PLAYTEST_TEMPLATE]].

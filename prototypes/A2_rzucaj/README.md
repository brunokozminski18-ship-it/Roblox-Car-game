# A2 — Fling the Problem

IMPLEMENTED / NEEDS VERIFICATION — 31.10.2026. Jedna samodzielna próbka, wygląd i zabawa NOT FINAL.

## Uruchomienie
Otwórz `A2_rzucaj.rbxlx` w Studio, emulator telefonu poziomo, Play.
Mapa jest generowana przez serwer po Play.
Przebudowa w tym folderze: `rojo build default.project.json -o A2_rzucaj.rbxlx`.
Do edycji na żywo: `rojo serve default.project.json`, wtyczka Rojo, osobne puste miejsce.
Nie podłączaj do istniejącej gry i nie publikuj.

## Sterowanie
Dotknij Grab / Catch przy rekwizycie. Obróć postać joystickiem w stronę kosza.
Przytrzymaj THROW (PC: Q), puść aby rzucić; siła rośnie do maksimum przez 1,2 s.
Białe punkty pokazują przybliżony łuk; nie uwzględniają odbić.
Miękki klocek leci szybciej niż ciężki. Ciężkim podejdź bliżej kosza.
Trafienie przegrody otwiera ją na 3 s, trafienie dna kosza podnosi licznik i resetuje rekwizyt.
Rekwizyty resetują się również po 8 s lotu lub kilku odbiciach. Nie zadają obrażeń graczom.

## Pięć minut
1. 0–1 min: podnieś miękki klocek, wykonaj krótki i pełny rzut.
2. 1–2 min: przewróć przegrodę, traf w szeroki kosz; sprawdź licznik i reset.
3. 2–3 min: porównaj ciężki rekwizyt, zmień odległość i siłę.
4. 3–4 min: spróbuj złapać lecący klocek (druga osoba pomaga); resetuj postać z przedmiotem.
5. 4–5 min: ignoruj punkty i sprawdź, czy chcesz dalej rzucać lub podawać.
Zanotuj przypadkowe rzuty podczas obracania kamery i zasłanianie joysticka/skoku.

## Kontrola offline i ograniczenia
Rojo build PASS; przegląd LihFolk `skills/roblox-secure-remotes` w `../SECURITY_REVIEW.md`.
Nie testowano silnika Luau, telefonu, synchronizacji, dotykowego przytrzymania, chwytania ani balistyki w Studio.
Nie ma lokalnego kompilatora Luau; build Rojo nie jest testem wykonania skryptów.
Największa słabość: celowanie kierunkiem postaci może być niewygodne na telefonie.
Lot jest serwerową symulacją punktu z przemiataną raycastem drogą; rozmiar i masa bryły nie są pełną fizyką.
Brak nowej zabawki po trafieniu, trwałego śladu najlepszego rzutu i kolejnych bramek: zakres to arena, dwa rekwizyty, kosz, przegroda i reset.
Brak zapisu, sklepu, petów i zewnętrznych assetów; reakcja to odbicie, otwarcie przegrody, błysk i liczba.
Źródło: LihFolk Vault V2 (CC BY 4.0), Projectiles and Ballistics, Server Authority and Validation, Input — UserInputService and ContextActionService.

## Czytelna oprawa — 31.10.2026
Status nowych zmian: IMPLEMENTED / NEEDS VERIFICATION; wcześniejszy test mechanik w Studio wykonał Claude, nie obejmował tej oprawy.
Kolory, proste postacie, jeden krok u góry, Beam do celu, pulsujące przedmioty i animowany licznik są warstwą prezentacji.
Przed Play widoczna jest tablica PRESS PLAY; serwer usuwa ją i buduje mapę.
Sprawdź w Studio telefon 568×320 i 667×375 poziomo: napisy, prompty, przycisk akcji, strzałkę, sukces i porażkę.
Bez nowych dźwięków ani assetów; geometria dekoracyjna nie ma kolizji ani udziału w raycastach.

# A3 — Build Against the Bonk

IMPLEMENTED / NEEDS VERIFICATION — 31.10.2026. Jedna samodzielna próbka, wygląd i zabawa NOT FINAL.

## Uruchomienie
Otwórz `A3_oslaniaj.rbxlx` w Studio, emulator telefonu poziomo i Play.
Mapa powstaje po uruchomieniu serwera.
Przebudowa: `rojo build default.project.json -o A3_oslaniaj.rbxlx` z tego folderu.
Opcjonalnie `rojo serve default.project.json`, wtyczka Rojo, osobne puste miejsce.
Nie podłączaj do innej gry i nie publikuj.

## Sterowanie
Podejdź do środka planszy, dotknij Claim plot. Są cztery niezależne plansze.
Podejdź do gniazda: Cycle panel przełącza pusty → prosty → pusty.
Po pierwszym udanym bloku odblokowuje się zagięty panel: pusty → prosty → zagięty → pusty.
Orientacja automatycznie pasuje do gniazda przedniego lub bocznego; bez osobnego paska i przycisku obrotu.
Dotknij Launch test. Ataki przechodzą naprzemiennie z przodu i z boku, z zapowiedzią 2 s.
Podczas próby panele są zablokowane. Po porażce figurka wraca, można od razu poprawić osłonę.
Zagięty panel ma drugie ramię, które osłania sąsiedni kierunek.

## Pięć minut
1. 0–1 min: zajmij planszę, ustaw panel z przodu, uruchom próbę.
2. 1–2 min: pozostaw bok pusty, sprawdź porażkę i jej komunikat.
3. 2–3 min: napraw bok, porównaj dwa proste panele z jednym zagiętym.
4. 3–4 min: usuń osłonę, przeprowadź test, spróbuj zmienić panel podczas ataku.
5. 4–5 min: poprawiaj samodzielnie; opcjonalnie sprawdź, czy druga osoba nie zmienia Twojej planszy.
Zanotuj, czy przyczyna porażki jest zrozumiała bez czytania instrukcji.

## Kontrola offline i ograniczenia
Rojo build PASS; przegląd LihFolk `skills/roblox-secure-remotes` w `../SECURITY_REVIEW.md`.
Nie testowano Luau w silniku, telefonu, widoczności promptów, timingów, multiplayera ani rzeczywistej czytelności zagięcia.
Brak lokalnego kompilatora Luau; build Rojo nie wykonuje skryptów.
Największa słabość: dwa gniazda i dwa kierunki mogą szybko stać się oczywistą łamigłówką.
Test używa pojedynczego promienia do figurki; nie symuluje gruzu ani uderzenia całej bryły.
Jedna osoba na planszę, bez wspólnego edytowania. Piąta osoba czeka na wolną planszę.
Bez zapisu, głodu, materiałów, sklepu i petów; reakcja to ruch uderzenia, błysk/zanik figurki i licznik.
Źródło: LihFolk Vault V2 (CC BY 4.0), Server Authority and Validation, ProximityPrompt — Engine Reference Card.

## Czytelna oprawa — 31.10.2026
Status nowych zmian: IMPLEMENTED / NEEDS VERIFICATION; wcześniejszy test mechanik w Studio wykonał Claude, nie obejmował tej oprawy.
Kolory, proste postacie, jeden krok u góry, Beam do celu, pulsujące przedmioty i animowany licznik są warstwą prezentacji.
Przed Play widoczna jest tablica PRESS PLAY; serwer usuwa ją i buduje mapę.
Sprawdź w Studio telefon 568×320 i 667×375 poziomo: napisy, prompty, przycisk akcji, strzałkę, sukces i porażkę.
Bez nowych dźwięków ani assetów; geometria dekoracyjna nie ma kolizji ani udziału w raycastach.

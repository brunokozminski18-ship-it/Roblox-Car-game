# A1 — Rescue Before the Roar

IMPLEMENTED / NEEDS VERIFICATION — 31.10.2026. Jedna samodzielna próbka, wygląd i zabawa NOT FINAL.

## Uruchomienie
Otwórz `A1_ratuj.rbxlx` w Studio, wybierz emulator telefonu poziomo i Play.
Mapa powstaje z części po uruchomieniu serwera; pusty widok edycji jest spodziewany.
Alternatywnie w tym folderze: `rojo build default.project.json -o A1_ratuj.rbxlx` lub `rojo serve default.project.json` i połączenie wtyczką Rojo z pustym miejscem.
Nie podłączaj projektu do innej gry. Niczego nie publikuj.

## Sterowanie
Joystick, dotknięcie wbudowanego promptu Pick up, przycisk DROP (PC: Q).
Doniesienie do jasnego schronu automatycznie zalicza ratunek.
Ciemny skrót uruchamia sekundową zapowiedź, potem ruchomą ścianę na tym pasie.
Ryk nadchodzi od schronu po 1 s: schowaj się w bocznym schowku po lewej albo wrócisz na start. Objazd prawą drogą jest cichy. (zmiana 31.10.2026)
Klapa pomocy otwiera się na 5 s; można ominąć ją samemu.

## Pięć minut
1. 0–1 min: podnieś bliski klocek, odnieś go, sprawdź licznik i półkę.
2. 1–2 min: przynieś daleki klocek skrótem; sprawdź zapowiedź i cofnięcie.
3. 2–3 min: wybierz prawy objazd; porównaj ryzyko z czasem drogi.
4. 3–4 min: upuść, podnieś ponownie; zresetuj postać podczas noszenia.
5. 4–5 min: powtórz z własnej chęci; opcjonalnie druga osoba otwiera klapę.
Zanotuj, czy rozumiesz przyczynę cofnięcia i czy sam wybierasz dalszy ratunek.

## Kontrola offline i ograniczenia
Rojo build PASS; przegląd wejść wg LihFolk `skills/roblox-secure-remotes` wykonany.
Pełny zakres i ograniczenia: `../SECURITY_REVIEW.md`.
Nie testowano: uruchomienia Luau w silniku, telefonu, kolizji postaci, multiplayera, resetów w Studio ani atrakcyjności.
Brak osobnego kompilatora Luau; build Rojo pakuje kod, nie dowodzi jego wykonania.
Największa słabość: szerokie otwarte otoczenie może pozwolić zbyt łatwo ominąć zagrożenie.
Brak zapisu, ekonomii, petów i zewnętrznych assetów; efekt to ruch ściany, błysk i licznik.
Wiedza techniczna: LihFolk Vault V2 (CC BY 4.0), Server Authority and Validation, ProximityPrompt — Engine Reference Card.

## Czytelna oprawa — 31.10.2026
Status nowych zmian: IMPLEMENTED / NEEDS VERIFICATION; wcześniejszy test mechanik w Studio wykonał Claude, nie obejmował tej oprawy.
Kolory, proste postacie, jeden krok u góry, Beam do celu, pulsujące przedmioty i animowany licznik są warstwą prezentacji.
Przed Play widoczna jest tablica PRESS PLAY; serwer usuwa ją i buduje mapę.
Sprawdź w Studio telefon 568×320 i 667×375 poziomo: napisy, prompty, przycisk akcji, strzałkę, sukces i porażkę.
Bez nowych dźwięków ani assetów; geometria dekoracyjna nie ma kolizji ani udziału w raycastach.

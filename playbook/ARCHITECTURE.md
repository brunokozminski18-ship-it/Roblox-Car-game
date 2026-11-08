# Architektura

## Podział
- **Serwer:** waluty, własność, zakupy, nagrody, losowania, strefy, zapis.
- **Klient:** UI, input, kamera, efekty. Klient jest niezaufany.
- **Wspólne moduły:** configi i stałe. UI nie kopiuje cen.

## Każdy remote sprawdza
Typ i zakres argumentów (NaN, długość), czy dane gracza są wczytane, własność, prawdziwy koszt, odległość/strefę, cooldown, duplikat. Jeden wynik albo jasny błąd; `pcall` nie udaje sukcesu.

## Zapis
- Jeden magazyn, wersja schematu. Nowe pole: domyślna wartość → migracja → walidacja → snapshot/restore → whitelist → test save/load/rejoin.
- Testy na osobnym magazynie QA; po teście przywróć ustawienia.

## Projekt
- Rojo mapuje cały kod; folder + git to źródło prawdy. Mapa i modele w Studio, kod nigdy tylko w Studio.
- Event-driven zamiast pętli co klatkę; pooling efektów; foldery zamiast skanowania Workspace.

## Test po zmianie
1. Normalny przepływ: UI → remote → serwer → dane → UI, Output bez błędów.
2. Odrzucenia: brak waluty, ponowny zakup, cudzy/nieistniejący przedmiot, spam.
3. Save/load/rejoin przy zmianie danych; multiplayer przy wspólnym stanie i tradingu.
4. Wynik z datą i zakresem do `PROGRESS`.

Szczegóły API i limitów: biblioteka LihFolk.

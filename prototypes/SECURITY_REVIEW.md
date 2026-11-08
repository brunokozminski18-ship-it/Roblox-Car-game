# Przegląd jako krytyk — 31.10.2026

Zakres: ponowny odczyt trzech skryptów serwera, klientów i helperów, wg LihFolk Vault V2 `skills/roblox-secure-remotes/SKILL.md` (CC BY 4.0).
To przegląd statyczny, bez fuzzingu, testów w Studio i gwarancji poprawności wykonania.

## Wejścia
| Projekt | Wejście | Walidacja i własność |
| --- | --- | --- |
| A1 | Drop, RemoteEvent klient → serwer | limit jako pierwsza instrukcja, dokładnie zero argumentów, żywa postać, przedmiot z serwerowej tabeli gracza |
| A2 | Throw, RemoteEvent klient → serwer | wspólny limit przed typami, dokładnie jeden string z listy Start/Release/Cancel, limit długości, żywa postać, właściciel, serwerowy czas ładowania i cooldown |
| A3 | bez remote | wyłącznie prompty z walidacją serwera |
| wszystkie | ProximityPrompt.Triggered | wspólny limit przed kontekstem, enabled, istnienie obiektu, żywa i skończona pozycja postaci, dystans do 11 studów; potem stan własności i zajętości |

Remote tworzy tylko skrypt serwerowy, po jednym w A1/A2. Klient wysyła intencję; nie wysyła pozycji, celu, punktów ani mocy.
Stan jest replikowany atrybutami; brak relayów, InvokeClient, DataStore, HTTP i debug/admin remote.
Brak yield między sprawdzeniem własności i zmianą. A3 oznacza busy przed task.delay i ponownie sprawdza właściciela w opóźnionych etapach.
Bucket: 8 żądań burst, odnowienie 4/s na gracza, wspólne dla promptów i remote; odrzucenia ciche.
Tabele graczy sprzątane na wyjściu; obiekty ograniczone: dwa rekwizyty A2, dwa ratunki A1, cztery plansze A3, osiem segmentów półki na aktywnego gracza.

## Znalezione i poprawione
- A1: ściana zostawała po wyjściu gracza — niszczenie ściany i półki podczas PlayerRemoving.
- A2: przypisanie autora w Heartbeat mogło spóźnić się względem rzutu — autor ustawiany atomowo w Release i czyszczony przy resecie.
- A3: stare etykiety po zwolnieniu planszy i przejęcie w trakcie opóźnionej próby — reset etykiet i blokada claim podczas busy.
- A3: ramię zagięcia przecinało tor na granicy bryły — wyśrodkowane na odpowiednim kierunku ataku.
- Wszystkie: sprawdzana skończoność pozycji i LookVector postaci przed użyciem w obliczeniach.
- A1/A2: prompt niesionego przedmiotu mógł zasłaniać inne interakcje — wyłączany na czas noszenia i włączany po puszczeniu/resecie.

## Pozostałe ograniczenia według wpływu
- Średni: standardowy ruch postaci jest kontrolowany przez klienta; dystans do obiektów nie jest zabezpieczeniem przed teleportowaniem postaci. Brak walidacji historii ruchu. Może to fałszować licznik sesji A1; nie ma trwałych dóbr ani ekonomii.
- Średni: balistyka A2 używa promienia środka obiektu, A3 promienia do środka celu; możliwe wizualne zahaczenia, które nie są zaliczane. Sprawdzić w grze.
- Niski: limit jest wspólny, spam klienta może tymczasowo zablokować jego własny chwyt lub puszczenie; ponowienie wejścia pozwala odzyskać sterowanie.
- Niski: brak rejestru odrzuceń i pełnych metryk nadużyć w tych jednorazowych próbkach; to odstępstwo od zalecanego zliczania naruszeń.
- Nie stwierdzono użycia deprecated API w odczytanym kodzie wg użytych notatek LihFolk; nie wykonywano aktualizacji wiedzy przez internet ani analizy typów silnika.

## Rano
Sprawdzić Output, śmierć/reset podczas chwytu i próby, dwóch graczy chwytających ten sam przedmiot, wyjście właściciela i dotykowe Cancel/Release.
Nie uruchamiano abuse tests: Studio było wyraźnie wyłączone z zakresu.

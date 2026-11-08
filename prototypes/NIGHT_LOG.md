Przygotowałem trzy oddzielne projekty Rojo A1 Ratuj, A2 Rzucaj i A3 Osłaniaj, a każdy plik rbxlx zbudował się poprawnie; stan to IMPLEMENTED / NEEDS VERIFICATION, nie zatwierdzona rozgrywka.
Nie korzystałem ze Studio ani Blendera, nie robiłem commitów i niczego nie publikowałem; nie przetestowałem wykonania Luau, dotyku, multiplayera ani pięciominutowej gry i nie wybieram zwycięzcy bez grania.
Najsłabsze w A1 jest zbyt otwarte otoczenie, które może ułatwić omijanie ściany i osłabić decyzję między skrótem a objazdem.
Najsłabsze w A2 jest celowanie kierunkiem postaci na telefonie oraz uproszczony lot punktowego rekwizytu, więc wygoda rzutu i chwytu wymaga sprawdzenia.
Najsłabsze w A3 są tylko dwa gniazda, przez co rozwiązanie może szybko stać się oczywiste; rano otwórz każdy rbxlx w Studio, zagraj pięć minut poziomo na emulatorze telefonu i przekaż Claude błędy oraz wybór czynności, która najbardziej wciąga.

## Oprawa i prowadzenie — 31.10.2026
- A1: żółte stworki z oczami, zielony schron/schowek, pomarańczowy skrót i pasma czerwonego ryku; zachowany kierunek od schronu oraz geometria schowka Claude.
- A2: pulsujący melon i ciężka skrzynia, zielony kosz, kroki chwyt → kierunek → ładowanie → puszczenie oraz wynik/miss na środku.
- A3: figurka z głową i oczami, niebieskie gniazda/panele, żółty TEST, czerwony atak; instrukcja wskazuje kolejny kierunek osłony.
- Wspólne: jeden duży krok, Beam i strzałka, najbliższa krótka etykieta, animowany licznik, komunikat wyniku, dekoracje bez kolizji/query, tablica przed Play.
- Reguły mechanik pozostawione; serwer dopisuje tylko atrybuty prezentacji i sygnały wyniku, klient przesuwa wyłącznie dekoracyjne części/efekty.
- Bez dźwięku, nowych systemów, internetu, Studio, commitów i publikacji; status nowych zmian IMPLEMENTED / NEEDS VERIFICATION.
- Do sprawdzenia w Studio: 568×320 i 667×375 poziomo, przyciski i prompty, widoczność twarzy/fali/Beam, nakładanie napisów, reset i multiplayer.
- Ryzyko: Beam wskazuje kierunek, nie omija ścian; detale śledzone lokalnie mogą opóźniać się o klatkę, a ozdobne brzegi kosza nie są nowymi powierzchniami kolizji.
- Kontrola offline: trzy buildy Rojo PASS, XML/tablice przed Play i spakowane źródła zgodne; A1 301, A2 318, A3 275 linii Luau; ponownie odczytano skrypty i współrzędne tras, bez uruchamiania gry.

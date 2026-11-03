# ThrowTicketsAtCars — wnioski z prototypu
- 02.11.2026, test techniczny Studio (1 gracz), nie test zabawy z ludźmi.
- Efekt leci łukiem → walidacja też musi badać łuk. Prosta blokowała dalsze auto za bliższym; wspólna funkcja trajektorii usunęła rozbieżność.
- Rezerwuj miejsce przed startem transportu; income uruchamiaj po dostawie. Dwie lawety równocześnie i limit 6 przeszły test.
- Samo odpalenie remote nie dowodzi sterowania. Osobno sprawdzono fizyczny przycisk telefonu, przeciąganie kamery i klik auta na PC.
- Automatyzacja wejścia zależy od urządzenia; na małym iPhone 7 zadziałał cel GUI, wcześniejszy offset współrzędnych nie trafił.
- Bieżący LogService klient/serwer pozwolił odróżnić 0 błędów gry od starych komunikatów w wyniku narzędzia konsoli.
- Pasywne TRAIN, Cash bez zastosowania i koniec wyborów przy pełnym parkingu to hipotezy ryzyka, wymagają oceny graczy.
- Raport: [[games/ThrowTicketsAtCars/reports/2026-11-02_prototype]]. Wygląd i balans: NOT FINAL.
- Iteracja 2: Scriptable wymuszany co klatkę blokował domyślny orbit/zoom. Własny test ruchu nie dowodzi zgodności ze standardową kamerą; PlayerModule musi pozostać właścicielem wejścia.
- Iteracja 2: MCP potrafi podać zerowy MouseMovement.Delta przy RMB; nie dostosowujemy gry do ograniczenia narzędzia i nie opisujemy tego jako PASS fizycznego obrotu myszy.
- Iteracja 2: AlwaysOnTop BillboardGui znikał w automatycznych zrzutach (pułapka znana z LihFolk). Ekranowe popupy śledzące auto dały czytelny efekt i możliwy do sprawdzenia zrzut.

- Iteracja 3: pełny parking nie kończy sesji — tokeny rezerwacji oddzielają obiecany i aktywny dochód; lepsze auta zastępują najsłabsze, pozostałe są sprzedawane.
- Iteracja 3: daleki model może nie być gotowy przy nadejściu eventu nawet z Persistent. Serwerowe metadane i lokalny podgląd utrzymują czytelny wynik.
- Iteracja 3: pojedynczy napis bramy także może wejść pod HUD. Trzeba sprawdzać przecięcie projekcji, nie tylko liczbę widocznych bram.
- Iteracja 3: podgląd Edit może trzymać stary require(World) po zmianie Source; wymiana tożsamości ModuleScript przy imporcie odświeżyła cache.
- Iteracja 3, końcowy smoke: VirtualInput rozwiązał test kamery — telefon zamienia przytrzymanie i ruch LMB w Touch; PC wymaga RMB, potem SendMouseDelta przy LockCurrentPosition. Potwierdzono 96°/59,57°, bez zmian w grze.
- VirtualInput może odrzucić klik pod nakładką CoreGui CaptureControls; sprawdzaj rzeczywiste zdarzenia i alternatywny punkt przycisku. Samo odrzucenie testowej komendy nie oznacza błędu gry.
- Iteracja 4: serwerowy profil jest źródłem Cash/Power; leaderstats i atrybuty tylko go pokazują. Przepisanie ich z UI nie może zmienić ceny, dystansu ani własności.
- Iteracja 4: zapisuj obiecany parking przed animacją, a sprzedaż zaliczaj z losowaniem. Wyjście podczas lawety nie odbiera zatwierdzonego wyniku.
- Iteracja 4: shutdown czeka także na rozpoczęte loady, nie tylko finalne save; inaczej normalne zamknięcie może zostawić lease do 90 s.
- Iteracja 4: UIGradient na TextButton barwi także jego litery, a UIStroke Contextual obrysowuje tekst. Osobny podpis i ApplyStrokeMode.Border usunęły nieczytelne BUY/X.
- Iteracja 4: x1/2,5/7/18/45/110 daje sześć biomów przy Power 24; to sprawdzony skok zasięgu, nie dowód dobrego tempa zakupów. Próbki UI/auta i balans NOT FINAL.
- Iteracja 4b: zielony powinien jednoznacznie znaczyć EQUIPPED, nie wszystkie posiadane rzeczy; kolor ceny i jawny poprzednik wyjaśniają zakup bez samouczka.
- Iteracja 4b: puls zakupu animuje kolor, naciskanie skalę; dwie animacje tej samej skali mogłyby się anulować. Wspólny Style utrzymuje zgodność HUD i sklepu.
- Iteracja 4b: liczymy wysokość HUD z marginesem i obrysem (41/374 px), nie same etykiety; boczne tablice otwierają widok dalszych biomów.

- Iteracja 6: najpierw porównaj folder, git i Studio; napis x2.5 wynikał z braku całej iteracji 5, nie tylko starego UI.
- Iteracja 6: stabilne ID i jeden rekord auta z Slot=0 lub numerem miejsca upraszczają własność, zapis i odporność na powtórzoną sprzedaż.
- Iteracja 6: rezerwacja pojemności i trwały zapis przed animacją utrzymują jeden łup po przerwaniu sesji; kosztem jest opóźnienie backendu przed rzutem.
- Iteracja 6: pełny ekwipunek wymaga niezależnego powrotu na działkę (MY PLOT), inaczej blokada rzutu odcina jedyną drogę do sprzedaży.
- Iteracja 6: kamera filmowa potrzebuje ścieżki anulowania przy śmierci/odrodzeniu. W PC zabicie w locie przywróciło Custom i nowy Humanoid bez utraty łupu.
- Iteracja 6: 78 asercji i Studio telefon/PC potwierdzają mechanikę; nie dowodzą zabawy, działania na urządzeniu ani izolacji działek wielu graczy.

- Iteracja 7 (03.11): ceny w minutach referencyjnego dochodu pozwoliły równocześnie stroić pule aut i zakupy; benchmark startowy musi uwzględniać zapełnianie działki, nie pełny parking od pierwszej sekundy.
- Iteracja 7: payback wykazał słabość końcowego mandatu mimo dużego nominalnego bonusu. Dopasowano korzyść, nie samą cenę; model obejmuje też sprzedaż za 3 min dochodu, ważny aktywny faucet.
- Iteracja 7: 30 symulacji wspólnych reguł i 151 s rzeczywistego telefonu dały różne, ale zgodne z celami czasy; założenia czasu transportu/obsługi trzeba oddzielić od pomiaru UI.
- Iteracja 7: ułamkowy Power wymaga jednocześnie zmiany whitelisty zapisu i zaokrąglenia HUD; inaczej ekran pokazuje długi ogon cyfr. Save/rejoin zachował dokładną wartość i bonus mandatu przypisany do auta.
- Iteracja 7: LihFolk Vault V2 (CC BY 4.0) podaje metodę cen/pacingu/payback, a nie gotowe liczby tej gry. Horyzont120 min i polityka zachłanna są naszymi założeniami; długi grind nadal wymaga ludzi.

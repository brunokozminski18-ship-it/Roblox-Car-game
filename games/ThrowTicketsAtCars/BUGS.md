# Błędy i ograniczenia
- Końcowy świeży przebieg Studio 02.11.2026: 0 błędów gry na kliencie i serwerze.
- NOT FINAL: hotbar, sklep/HUD, Rusty Sedan, ceny, luck i tempo treningu.
- NEEDS VERIFICATION: fizyczny telefon, swobodny ruch na urządzeniu i wielu graczy. QA stabilizował postać na potrzeby klików/zrzutów.
- Trwały zapis łupu poprzedza animację; opóźnienie backendu może wydłużyć fazę przygotowania. Sama sekwencja animacji+lawety ok. 4,45 s.
- Awaria/niejednoznaczny zapis testowane przez wstrzyknięty magazyn; rzeczywista awaria backendu niebadana.
- Przy utracie sesji może obowiązywać lease do 90 s; gracz dostaje komunikat o bezpiecznym ponownym wejściu.
- Brak dochodu offline; auta w ekwipunku nie zarabiają.
- Naprawiono: mnożniki mandatów, brak ćwiczeń, brak powrotu do działki przy pełnym ekwipunku, dekoracje nachodzące na miejsca pierwszej działki.

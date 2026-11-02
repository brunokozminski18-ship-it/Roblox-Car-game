# Błędy i ograniczenia
- Błędów gry nie odnotowano w końcowych testach 02.11.2026.
- NOT FINAL: wygląd sklepu, próbka Rusty Sedan, ceny/mnożniki i czas do kolejnego zakupu.
- Fizyczny telefon, duża liczba graczy i awaria prawdziwego backendu nieprzetestowane.
- Błędy backendu, utrata lease i niejednoznaczny zapis testowane przez wstrzyknięty magazyn.
- Przy awarii serwera lub nieudanym finalnym zapisie może obowiązywać lease do 90 s; gracz dostaje jasny komunikat.
- Studio VirtualInput może odrzucić klik w nakładkę CaptureControls; klik lewej części przycisku działał.
- NEEDS VERIFICATION: w emulatorze występował ruch postaci przed klikami UI; pomiary/zrzuty 4b robiono z nieruchomą postacią QA. Fizyczny telefon niebadany.
- Studio zgłaszało ostrzeżenia pluginu i systemowego assetu avatara 203785492; brak MessageError gry.

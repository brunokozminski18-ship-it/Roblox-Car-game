# Testy w Roblox Studio przez MCP

Sprawdzone w Pumpkin Hunterze (19–29.10.2026). Dotyczy agentów sterujących Studio przez MCP `Roblox_Studio`.

## Zasady pracy
- Zacznij od `list_roblox_studios`, a potem pracuj na właściwym otwartym place.
- Telefon najpierw ([[playbook/MOBILE_UI]]): każdy test UI/onboardingu najpierw w emulatorze telefonu (poziomo), PC pomocniczo. Raport podaje wynik telefonu jako główny.
- Emulator przełącza agent sam, nie prosi użytkownika.
- Po teście: Studio w trybie Edit, emulator wyłączony, ustawienia magazynu QA przywrócone. Nie publikuj.

## Emulator telefonu
- Tylko w Edit (w Play setter rzuca błąd): `game:GetService("StudioDeviceSimulatorService")`.
  - Telefon: znajdź urządzenie (np. `iphone_17_pro`, tablet `ipad_a16`) przez `GetDeviceListAsync`, potem `SetDeviceAsync(id)`, `task.wait(.2)`, `SetOrientationAsync(LandscapeLeft)`.
  - PC: `StopSimulationAsync()`.
- Kliknięcia GUI w emulatorze: `user_mouse_input` z `instance_path` nie trafia. Użyj współrzędnych: środek `AbsolutePosition` elementu + (62, 20). Na PC odwrotnie: działa `instance_path`, współrzędne nie.
- Przypadkowe tapnięcia potrafią otworzyć okna HUD — zamknij je po teście.

## Pułapki
- `require()` w `execute_luau` daje osobną kopię modułu: zmiana tabeli configu tam nie zmienia gry na żywo. Testuj przez atrybuty gracza, które czyta serwer, albo przez bota klienta (`Humanoid:MoveTo`, wywołania remote jak gracz).
- Wywołania dłuższe niż ok. 60 s się urywają: pracę odpal w `task.spawn` i sprawdzaj wynik krótkimi wywołaniami.
- Moduł kamery nadpisuje bezpośredni `Camera.CFrame` — na chwilę ustaw `CameraType = Scriptable`, potem z powrotem `Custom`.
- Klient nie może używać `HttpGet`.
- Błąd DataStore 9002 (Studio niezalogowane do API) blokuje zapis i zakupy w teście — restart Studio.
- Świeże konto testowe: tymczasowo inna nazwa magazynu QA, po teście przywróć oryginalną.

## Testy wielu graczy
Po `StudioTestService:ExecuteMultiplayerTestAsync`: 1) zakończ test (`EndTest`) i sprawdź, że nie zostały procesy serwera/klientów; 2) z Edit uruchom raz `ExecutePlayModeAsync({})` w `task.spawn` i zakończ go — inaczej następny Play użytkownika otworzy kilka okien Studio; 3) powiedz użytkownikowi, że tryb przywrócono.

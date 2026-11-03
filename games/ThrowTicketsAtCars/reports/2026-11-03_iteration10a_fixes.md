# Iteracja10a — poprawki po teście użytkownika
03.11.2026. IMPLEMENTED/VERIFIED w zakresie poniżej. **Wersja testowa; wygląd, dźwięk i balans NOT FINAL.** Bez Rebirth, Robux i publikacji.

## Zmiany
1. PowerSelector otwiera tylko ikona przy Power(44×44). Domyślnie schowany iMAX. Wybrana siła jest stanem sesji i pozostaje przez kolejne rzuty; MAX śledzi wzrost Power. Płytka uruchamia wyłącznie TAP TO THROW; sklep zamyka się przy wejściu na nią.
2. Epic+: minimum5 s, litery1.8× wolniej, osobny EPIC CATCH, whoosh na trafieniu i niższy coin na odsłonięciu, count-up1inX z dźwiękiem. Shake0.45/0.65 s wobec common0.16/0.3 s; pojedynczy kolorowy wash0.5 s, bez strobo. ReducedMotion pomija shake/flash.
3. Kamera pozostaje właścicielem ujęcia przez Tow, płynnie odsuwa się0.65 s i pokazuje zabranie auta. Teleport: fade-in0.14 s, przywrócenie kamery/TouchGui, fade-out0.3 s. Cleanup obejmuje śmierć/respawn/zmianę kamery/watchdog i normalizuje przypadkowy snapshot Scriptable do Custom.
4.2x:84 px na telefonie/92 naPC, losowe centralne położenie, dźwięk pojawienia; bez odliczania. Niekliknięte znika po4 s. Klik: natychmiastowy pop, wysłany tylkoId oferty, serwer potwierdza2 s boosta, postać ma Highlight; kółko znika, bez trwałego2x przy krawędzi.
5. NEW GEAR: toast czeka na gotowy klient JuiceReady, dzięki czemu nie ginie przy odczycie profilu. Ten samId oferty nie emituje się ponownie w sesji; nowe ulepszenie/mandat to osobna oferta. Przycisk teleportuje do własnego stanowiska i otwiera właściwy sklep, bez automatycznego zakupu.
6. Smuga: UIGradient.Offset−1→1 w1.1 s co5 s, peak bieli38% zamiast ledwie widocznej starej warstwy10%. Zatrzymanie na close/ReducedMotion, brak blokowania kliknięć.
7. Telefon: top48 px, Power44×44/menu88×48, hotbar44–54, XP w dolnym środku między narożnikami, kompaktowy toast244×92/SHOP80×44. LEVEL UP chwilowo zastępuje tekst XPbar; centralny popup schowany. Komunikat max400 px ponad hotbarem i schowany pod2x/suwakiem.
8. Wszystkie głośności×0.52(około−48%). Usunięte ostre tire skid, retro coin i długie wysokie fanfary; istniejące Creator Store click/pop/coin/whoosh, niższy pitch. XP/Letter krótkie0.14 s, ciche, wariacja około2.5–3%; bez rosnącego pisku liter.
9. FlightHUD/biom/LUCK/PERFECT/+POWER/XP/level-up zachowane i sprawdzone w telefonie. Gameplay nagród/cen/XP/boostów nadal serwerowy, schema4 bez zmiany.

## Źródła i wykonanie
Przed pracą odczyt MCP Obsidiana tylko read-only: **LihFolk Vault V2(CC BY4.0)**, TL;DR Game Feel and Juice; Reward Moments and Celebrations; Feedback Timing - Sound Visual and Haptic Sync; Sound Design for Games; Mobile Button Layout Editor. Zastosowano tier ladder, truthful result, bounded shake/flash, preload/pool/choke, safe area i kontrolę nakładania UI. Lokalnie playbook/MOBILE_UI iUI_STYLE. Kod wyłącznie repo/Rojo,32 źródła; jeden właściciel sceny i dokumentacji. Plan9 punktów użytkownika wykonany; niezależny review kodu i dodatkowy review compact UI bez nowych konkretnych usterek.

## Testy
Wyłącznie osobny QA key `iteration10a-userfix-20261103`; grant200/30000/Power/XP/rarity fixtures dotyczył QA. Profil użytkownika bez grantów i resetów. Telefon główny: iPhone7 landscape666×374, safe GUI666×316; PC native viewport zależny od okna(1406–1914×761). Preset568×320 nie występuje w udostępnionej liście emulatora; nie deklarujemy testu na takim urządzeniu.

| Kontrola | Wynik |
|---|---|
| Reguły |284 PASS:264 wcześniejsze+20 nowych. Nowy revealSeconds najpierw RED(brak funkcji), potem GREEN;33 kontroli juice obejmuje rare/common, minimum i najdłuższe nazwy z zapasem do timeout16 s. |
| Suwak | Przy wejściu/wyjściu z płytki Selector=false, Meter=true. Ręczny klik ikony otwiera. Wybrane101 utrzymało się po common iEpic na telefonie iPC. MAX=true/207 przy Power207, over-power iNaN nie zmieniły wyboru. Stan resetuje się do MAX przy nowej sesji. |
| Common/Epic | Natywny PC: common2.4185 s/Epic5.0199 s do Ready; telefon Epic5.0189 s. Rzadki licznik1in10→1in43; earlyContinue odrzucone. RareArrival/Rare/CounterPlayed, wash minTransparency0.832. Oba warianty→Tow→działka/Tool. |
| Płynne Continue | Kamera ogląda Tow zamiast natychmiast wracać do postaci. Końcowy native audit telefonu:120 klatek Tow:Scriptable, po zakończeniu32 klatki Custom; TouchGui true iFade1. Test obejmował celowo stary Scriptable snapshot. Fade przechodził przez0→1. |
|2x | Losowe pozycje m.in.(347,169),(385,184),(395,167) w safe666×316;84×84. Niekliknięte3.963/3.985/3.997 s, brak etykiety timera. Pop max1.331, Highlight zaobserwowany, serverXP25→50 lub6.25→12.5/s, boost wygasa. |
| Gear QA | Telefon Cash200: Focused toast, SHOP→(-48,~2.85,34), TRAINING open.22 s=1 emisja Exercise:focused. PC20 ponownych JuiceReady: bez duplikacji; Weighted iPink po jednej odrębnej ofercie. Zakup Focused:200→20,Exercise1→2, PurchasePlayed. Przy wczytaniu istniejącego QA toast pokazał się po gotowości klienta. |
| Smuga | Telefon:Visible=true, Offset−0.045; PC−0.093 przy przechwyceniu środkowej części. Na zrzutach rzeczywiście widać ukośną białą smugę na panelu. |
| Mobile | Pomiary:Power44×44, menu88×48, hotbar54×54; Jump70×70 przy(571,226). XP366×28 iMessage366×26 w x150; Message y178, hotbar y216, brak wzajemnego przykrywania. Dolne wizualne narożniki pozostają wolne. DynamicThumbstick ma większy przezroczysty obszar wejścia niż widoczny joystick; nie jest dodatkowym panelem gry. |
| Cały HUD | Przejrzano normalny HUD, ręczny selector, Meter, Flight/PERFECT, common/Epic, My Cars, Shop/shine, Gear iBoost/XP. Otwarty Shop→wejście na płytkę: ShopOpen=false/Meter=true/Selector=false. LEVEL UP czytelny na dolnym pasku. |
| Audio |14 cue/5 ID: nativeLoaded=true iLength>0. Wszystkie14 cue mają Played w pełnym PC przebiegu. Usunięte ID ostrego skidu/retro/fanfar nie występują w nowym katalogu. To weryfikacja ładowania/uruchomienia; subiektywna przyjemność i finalny dobór pozostają do odsłuchu użytkownika. |
| Koniec |0 MessageError w kontrolach klient/serwer, końcowy nowy build telefonu również0. Studio Edit, QA key usunięty, emulator/HTTP off, lokalny serwer zamknięty. Stare MessageWarning Studio injection/ContentId203785492 nadal poza źródłami gry. |

## Przed i po
![HUD przed — suwak otwarty przy podejściu](<C:/Users/bruno/Documents/Roblox Games/games/ThrowTicketsAtCars/reports/2026-11-03_iteration10a_fixes_phone_hud_before.png>)
![HUD po — schowany suwak i ikona Power](<C:/Users/bruno/Documents/Roblox Games/games/ThrowTicketsAtCars/reports/2026-11-03_iteration10a_fixes_phone_hud_after.png>)
![2x przed — przy krawędzi obok skoku](<C:/Users/bruno/Documents/Roblox Games/games/ThrowTicketsAtCars/reports/2026-11-03_iteration10a_fixes_phone_boost_before.png>)
![2x po — duży losowy cel bliżej środka](<C:/Users/bruno/Documents/Roblox Games/games/ThrowTicketsAtCars/reports/2026-11-03_iteration10a_fixes_phone_boost_offer.png>)
![Końcowy LEVEL UP na pasku XP](<C:/Users/bruno/Documents/Roblox Games/games/ThrowTicketsAtCars/reports/2026-11-03_iteration10a_fixes_phone_levelup.png>)
![Epic podczas dłuższego odsłaniania](<C:/Users/bruno/Documents/Roblox Games/games/ThrowTicketsAtCars/reports/2026-11-03_iteration10a_fixes_phone_epic_partial.png>)
![Kamera pozostaje przy lawecie](<C:/Users/bruno/Documents/Roblox Games/games/ThrowTicketsAtCars/reports/2026-11-03_iteration10a_fixes_phone_tow.png>)
![Czytelna smuga w sklepie telefonu](<C:/Users/bruno/Documents/Roblox Games/games/ThrowTicketsAtCars/reports/2026-11-03_iteration10a_fixes_phone_shine.png>)
![PC Epic](<C:/Users/bruno/Documents/Roblox Games/games/ThrowTicketsAtCars/reports/2026-11-03_iteration10a_fixes_pc_epic.png>)

Pozostałe zrzuty w tym folderze: suffixy phone_common/epic_full/boost_glow/gear/meter/selector/cars ipc_shine. Dowody: [[games/ThrowTicketsAtCars/reports/2026-11-03_iteration10a_fixes_evidence.json]].

## Co sprawdzić jako gracz
- Ikona przy Power: wybierz wcześniejszy biom, rzuć kilka razy, potem MAX; suwak nie powinien sam wracać.
- Porównaj common zEpic i oceń, czy rzadkie złapanie wyraźnie czuć; Continue powinno płynnie pokazać lawetę i powrót.
- Podczas treningu złap2x: krótki pop, poświata, większe XP; niekliknięte kółko znika bez timera. Sprawdź LEVEL UP na dolnym pasku.
- Obejrzyj NEW GEAR→SHOP i smugę sklepu; oceń, czy telefon ma wygodne przyciski i wolne dolne narożniki.
- Posłuchaj nowego, cichszego miksu i wskaż dźwięki, które nadal przeszkadzają. Finalne dźwięki wybierzemy później.

Ograniczenia: fizyczny telefon, inne rozdzielczości i multiplayer nie zastąpione emulatorem; wygląd/brzmienie/balans nie stają się USER APPROVED przez techniczny PASS.

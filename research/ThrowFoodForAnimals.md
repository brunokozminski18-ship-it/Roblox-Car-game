# Throw Food For Animals — analiza (03.11.2026)

Gra: 68,7K graczy, 93% łapek. Notatki użytkownika + klatki z filmu (co 7 s, 3:40). Mechaniki podglądamy, grafiki i nazw nie kopiujemy.
Numery `[A]`–`[L]` są używane w promptach dla Codexa.

## Pętla
Rzut przynętą (pasek siły) → lot przez biomy → złapanie (animacja) → teleport na działkę → postaw / sprzedaj → trening i lepsza przynęta → dalszy biom.

## Co trzyma gracza
**[A] Złapanie (najważniejsze)**
- Kamera z perspektywy zwierzęcia idącego do przynęty, ekran trzęsie się w rytm kroków, potem zmiana kadru i powolne odsłonięcie.
- Nazwa odsłaniana literami jak w wisielcu (`B_N_IP` → `BUNYIP`) — napięcie.
- Karta: nazwa, rozmiar (BIG), $/s, plakietka "NEW BEST!", "tap to continue".
- Rzadkie złapanie: osobna animacja, licznik rzadkości rośnie z dźwiękiem.
- W locie przynęty: baner z nazwą biomu i licznik LUCK (np. 32.27X) rosnący z dźwiękiem.

**[B] Rzut**
- Pionowy pasek: "+20 POWER", "PERFECT!".
- Suwak "THROW POWER 1825 / 2168", "Lands in: <biom>", przycisk MAX — można celowo rzucić do wcześniejszego biomu (do kolekcji).

**[C] Trening**
- Level + pasek XP na dole, "+XP" przy każdym powtórzeniu, dźwięk.
- Co jakiś czas kółko "2x" (z dźwiękiem): kliknięcie = 2x na ~2 s, inaczej znika.
- "LEVEL UP! Throw power +5!".

**[D] Podpowiedzi zakupu**
- Toast "NEW EQUIPMENT! You can now buy X" + UPGRADE (teleport do miejsca), pasek czasu wyświetlania.
- Przy stanowisku cena zielona (stać) / czerwona (nie stać).
- Sklep z przynętami: kafelki z tierem, rzadkością przynęty, ceną; EQUIP.

**[E] Kolekcja**
- Index: biomy po lewej, sylwetki "???" dla niezłapanych, x/8 na biom, "Unlocked 52/140" łącznie.
  - Lewa karta biomu: nazwa + mała makieta biomu. Prawa: siatka 4 kolumny, 8–12 slotów na biom, pasek x/8 pod siatką; całość przewijana pionowo.
  - Tło kafelka = kolor rzadkości (szary, zielony, niebieski, fioletowy, różowy, żółty) widoczne też dla niezłapanych → gracz widzi, czego szukać.
  - Sylwetka zdradza kształt, nazwa dopiero po złapaniu.
- Odmiany (mutacje): GOLD, DIAMOND, RUBY; rozmiary BIG / GIANT. Luck poprawia odmiany i rozmiar.
  - Karta: odmiana małym kolorowym napisem NAD nazwą, rozmiar POD nazwą, nazwa w kolorze rzadkości, $/s na zielono.
  - Na działce zwierzę GOLD ma złoty materiał + błyskawice/poświatę; nad każdym zwierzęciem etykieta nazwa + $/s (+ BIG).
- Rzadkie złapanie: przed odsłonięciem świecąca skrzynka z "1 in X" rosnącym w górę i paskiem z 5 segmentów; przy bardzo rzadkim napis "SUPER LUCKY!" i licznik np. "1 in 2,601". Skrzynka zostaje obok zwierzęcia.

**[F] Działka**
- Ulepszenie działki za kasę: tabliczka "16 > 18 ▲ $cena", toast "Plot upgraded! It holds 18 animals now".
- "Your plot is full!", "Sold for $X!" (zielone, układają się w stos), potwierdzenie YES/NO przy sprzedaży rzadkich.
- Tabliczka ulepszenia stoi w świecie przy płocie działki (łapka, "16 > 18", przycisk "▲ $cena"): zielony = stać, ciemny = nie stać.
- "Your plot is full! (16 animals)" czerwony, "Sold for $X!" zielony — oba jako pasek u góry na środku.
- Okno My Animals: x/16, PICK UP / SELL, EQUIP BEST.
  - Dwie sekcje: na działce (PICK UP / SELL) i niżej BACKPACK n (EQUIP / SELL). Pełna działka → nowe zwierzęta idą do plecaka.
  - Wiersz: ikona na tle koloru rzadkości, odmiana, nazwa, rozmiar, $/s.
  - Trzymane zwierzę w hotbarze na dole: ikona, $/s, ilość.
- Obok Power mała ikona zębatki → tu otwiera się suwak siły rzutu (zgodnie z poprawką 10a).

**[G] Powroty i społeczność**
- Toast "Your animals earn $X offline!".
- Po powrocie okno "Welcome Back!": "While you were away your animals earned $X", "Away for 7m", duży zielony CLAIM z białą smugą.
- Co jakiś czas "Don't forget to like the game".
- 3 tablice przy spawnie: Most Animals, Top Money, Luckiest Catch (avatary graczy, top 10, "updates every minute").
- Darmowy przedmiot w sklepie (Free Animal), czerwona kropka na przycisku sklepu, gdy jest do odebrania.

**[H] Styl**
- Wszystko w jednym stylu. Minimalny HUD: Index i Shop po lewej, Animals po prawej, Power i Cash w lewym dole.
- Biała smuga przechodzi co chwilę po oknie sklepu. Każdy element ma dźwięk.

## Robux (na później, wymaga zgody użytkownika)
- **[I]** Przy pasku rzutu: "100x LUCK" za 9 R$ (impuls).
- **[J]** Sklep: limitowany zwierzak "900% of your best animal" (499), jajko eventowe 80 / 3 za 200 z tabelą szans, Rainbow Egg 99 / 3 za 249, Server Luck 2x→4x→8x→16x po 19 R$ (+15 min, działa na cały serwer).
- **[K]** Paczki kasy, Power i przynęt (wartość skaluje się z postępem, plakietki "+100% VALUE"), gamepassy x2 Cash (99) i x2 Training (149), 2 zwierzaki za R$ (199/299), GIFT innemu graczowi.
- **[L] Zasady Robloxa** (LihFolk: *Paid Random Items and Odds Disclosure in Practice*, *Skill - Roblox Monetization Compliance*):
  - Płatne losowania muszą pokazywać szanse każdego wyniku, sumujące się do 100%.
  - Płatny luck też jest modyfikatorem szans: szanse aktualizują się na żywo podczas boosta.
  - Ceny pobiera się z `GetProductInfoAsync`, nie wpisuje na sztywno.
  - `PolicyService` wyłącza płatne losowania tam, gdzie są zakazane.

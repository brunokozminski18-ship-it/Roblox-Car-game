# Monetyzacja

Ceny ustalamy dla każdej gry osobno: na podstawie LihFolk (`11 Monetization Publishing and Live Ops`, `48 Economy Design Deep Dive`, skill `roblox-monetization-compliance`) i analityki naszej gry po premierze. Wynik zapisujemy w `DECISIONS` gry.

## Typowe oferty w grach tego typu
- Passy: mnożnik waluty, VIP, więcej slotów na pety, szybsze/wielokrotne otwieranie jaj, szczęście.
- Produkty: czasowe boosty, paczki waluty, Starter Pack dla nowych graczy.

## Zasady
- Nagrodę za Developer Product przyznaje tylko serwer (ProcessReceipt), z trwałym znacznikiem zakupu — powtórzony receipt nie daje drugiej nagrody.
- Cenę i dostępność czytaj z MarketplaceService; nie pokazuj wpisanej ręcznie ceny.
- Jaja za walutę, którą można kupić za Robux = płatne losowanie: PolicyService + szanse widoczne przed zakupem.
- Handel petami: sprawdzenie PolicyService u obu graczy.
- Bez pay-to-skip całej gry jednym zakupem.

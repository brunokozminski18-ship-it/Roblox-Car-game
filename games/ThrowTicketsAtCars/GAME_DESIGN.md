# THROW TICKETS AT CARS! — obecny design
- Prototyp z klocków. Wygląd i balans: NOT FINAL.
- USER APPROVED 02.11.2026: Rzut bez celowania: odległość = Power, biom decyduje o puli aut.
- Rzut z białej linii, zawsze wzdłuż drogi; kierunek postaci i kamery nie zmienia wyniku.
- Odległość ograniczona do końca mapy, domyślnie 3200 studów.
- Klient tylko prosi o rzut; serwer liczy pozycję, cooldown, losowanie i pieniądze.

## Pętla
THROW → biom i losowanie → TICKETED! → laweta w tle → parking albo sprzedaż → TRAIN → dalszy biom.

## Biomy — progi i pule w Config
| Biom | Power | Pula |
| --- | --- | --- |
| Junkyard | 0+ | Rusty Sedan, Old Van, Broken Pickup |
| Suburbs | 50+ | Family Car, Minivan, Hatchback |
| Downtown | 150+ | Taxi, Police Cruiser, Limo |
| Sports Track | 400+ | Sports Coupe, Rally Car, Muscle Car |
| Luxury Classics | 1000+ | Vintage Roadster, Gold-Trim Classic |
| Hypercar Island | 2500+ | Hypercar, Golden Hypercar, Rocket Car |
- Własny kolor podłoża, sześć dekoracji z klocków i cztery auta widokowe na biom.
- Najwyżej jeden najbliższy napis bramy; ukryty, jeżeli wchodzi pod HUD.
- Auta widokowe wracają po zabraniu; brak widokowego auta nie blokuje rzutu.

## Losowanie i parking
- Wagi Common/Rare/Epic/Legendary: domyślnie 70/22/7/1.
- Gatunek auta losowany osobno z puli biomu; każdy ma nazwę i wariant rzadkości.
- Dochód = BaseIncome biomu × mnożnik rzadkości (1/3/8/20).
- Parking 6 miejsc. Lepsze auto zastępuje najsłabsze; stare zarabia do dostawy.
- Gorsze lub równe auto sprzedawane jednorazowo; cena domyślnie 10 sekund jego dochodu.
- Token rezerwacji chroni równoległe dostawy. Cash i income kontroluje serwer.
- Wszystkie liczby są wersją do balansu, nie zatwierdzonym balansem.

## Prezentacja i zakres
- HUD: Cash, Power, biom rzutu, Next biome i pasek.
- Nazwa i rzadkość w kolorze; wynik dalekiego rzutu widoczny również bez wczytanego modelu.
- Efekty klienta zachowane: mandat/łuk/obrót, podskok, dźwięk, parking pop i +1 Power.
- Kamera pozostaje standardowa; rzut nie przejmuje sterowania.
- Bez sklepu, petów, Rebirth, DataStore, marek, modeli samochodowych i publikacji.

Źródła: [[playbook/ARCHITECTURE]], [[playbook/ECONOMY]], LihFolk Vault V2.

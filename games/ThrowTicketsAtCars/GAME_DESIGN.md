# THROW TICKETS AT CARS! — obecny design
- Pętla: THROW → losowanie auta w biomie → mandat/laweta → parking lub sprzedaż → TRAIN / ticket upgrade → dalszy biom.
- Rzut z białej linii, wzdłuż drogi; kierunek kamery i postaci nie zmienia wyniku.
- Serwer liczy dystans = min(Power × equipped ticket, 3200), biom, losowanie, waluty i własność.

## Mandaty — Config, balans NOT FINAL
| Mandat | Cena Cash | Zasięg × | Bonus wag Rare+ |
| --- | --- | --- | --- |
| Paper Ticket | 0 | 1 | 0% |
| Pink Slip | 100 | 2,5 | 5% |
| Parking Fine | 1200 | 7 | 10% |
| Court Summons | 12000 | 18 | 15% |
| Golden Ticket | 90000 | 45 | 20% |
| Diamond Ticket | 600000 | 110 | 25% |
- Zakupy po kolei, raz; wyposażanie dowolnego posiadanego. BUY nie wyposaża automatycznie.
- Luck mnoży wyłącznie wagi Rare/Epic/Legendary przez 1+bonus, potem normalizacja.
- SHOP pulsuje, gdy stać na następny mandat; menu otwiera listę przy następnym celu.
- Stany wierszy: tylko EQUIPPED zielony; affordable jasny/puls BUY; unaffordable niebieski/cena czerwona; locked ciemny/kłódka/warunek.
- SHOP, TRAIN i największy THROW w rzędzie pod kciukiem; pasek HUD poniżej 12% wysokości telefonu.

## Biomy i auta
| Biom | Minimalny dystans | Pula |
| --- | --- | --- |
| Junkyard | 0 | Rusty Sedan, Old Van, Broken Pickup |
| Suburbs | 50 | Family Car, Minivan, Hatchback |
| Downtown | 150 | Taxi, Police Cruiser, Limo |
| Sports Track | 400 | Sports Coupe, Rally Car, Muscle Car |
| Luxury Classics | 1000 | Vintage Roadster, Gold-Trim Classic |
| Hypercar Island | 2500 | Hypercar, Golden Hypercar, Rocket Car |
- 4 auta widokowe na biom, odnawiane; niskie tablice przy poboczu, jeden najbliższy napis, chowany pod HUD.
- Jedyna próbka modelu: Rusty Sedan v2 z 36 części; pozostałe auta szare. Próbka NOT FINAL.
- Rzadkości bazowe Common/Rare/Epic/Legendary: wagi 70/22/7/1; mnożniki dochodu 1/3/8/20.
- Dochód = BaseIncome biomu × rzadkość; nazwa auta z puli wybranego biomu.

## Parking i zapis
- 6 miejsc. Lepsze wymienia najsłabsze; stare zarabia do dostawy. Token odrzuca starą dostawę.
- Słabsze/równe sprzedawane za 10 sekund dochodu; Cash zapisany od razu, laweta kosmetyczna w tle.
- Cash, Power, Owned, Equipped i Parking zapisane w jednym profilu Schema 1 z blokadą sesji.
- Pending auto zapisane jako obiecany stan miejsca i odtwarzane jako zaparkowane.
- Bez dochodu offline. Studio używa osobnego magazynu _STUDIO, nie magazynu live.

## Prezentacja i granice
- HUD: jedna linia Cash/Power/biom i cienki pasek postępu; kamera standardowa, rzuty jej nie przejmują.
- Mandat w kolorze wyposażonego typu, łuk/obrót, TICKETED, dźwięk, pop i +1 Power.
- Próbka sklepu styl D i Rusty Sedan: NOT FINAL, czekają na ocenę.
- Bez petów, Rebirth, Robux, innych modeli i publikacji.
Źródła: LihFolk Vault V2 (CC BY 4.0), playbook/ARCHITECTURE, ECONOMY, UI_STYLE, MOBILE_UI.

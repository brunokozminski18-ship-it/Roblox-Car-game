# THROW TICKETS AT CARS! 🚗
- Prototyp: szare klocki. Wygląd i balans: NOT FINAL.
- Jedno zdanie: policjant rzuca mandatami w auta, które laweta zabiera na zarabiający parking.
- Czasownik: rzucaj.
- Pętla: celuj kamerą → rzuć → czerwony znacznik → laweta → auto zarabia → trenuj dalszy rzut.
- Telefon: duży THROW po prawej, celownik, pomoc celowania; PC także klik myszą; zawsze środek kamery.
- 5 stref: 20/40/60/80/100 studów; po dwa szare auta z kolorowym dachem.
- Parking: 6 miejsc na gracza; rezerwacja od trafienia, income dopiero po dostawie.
- Pełny parking: odmowa bez przejęcia auta; brak wymiany aut w tym prototypie.
- Trening: przełącznik TRAIN albo płytka, +1/s, bez podwajania.
- Wszystkie wartości rozgrywki i geometrii: wspólny Config; wynik ustala serwer.
- Bez sklepu, petów, Rebirth, DataStore, marek, uploadów, publikacji i Robux.

## Założenia implementacyjne Codexa (nie akceptacja użytkownika)
- Rzut z oznaczonej linii startowej, aby chodzenie do auta nie zastępowało treningu.
- Odległość 3D od postaci do środka auta; dlatego start 24 pozwala trafić strefę 20.
- Cel pod celownikiem z niewielką tolerancją; serwer sam wybiera cel z ograniczonego promienia kamery, sprawdza dystans i łuk.
- Laweta nie blokuje kolejnych rzutów; zajęte i dostarczone miejsca liczą się do limitu.
- Po śmierci parking zostaje do końca sesji; po wyjściu znika. Bez trwałego zapisu.

## FUN_CHECKLIST — hipotezy, do testu z ludźmi
- 10 sekund bez nagród: NEEDS VERIFICATION; mandat i laweta mają dać czytelny efekt.
- Reakcja świata: łuk mandatu, czerwony znacznik, laweta, przyrost Cash.
- Umiejętność: celowanie i wybór droższego auta; trening sam w sobie pasywny.
- Inni gracze: wspólne auta, osobne parkingi; brak rozbudowanej rywalizacji.
- Pierwsza minuta: pierwsze auto bez treningu, kolejny tier po kilkunastu sekundach treningu.
- Powrót jutro i rynek: poza zakresem prototypu; nie wykonano badania rynku.
- Test zabawy: 3 osoby na telefonie pozostaje do zrobienia przez użytkownika.
- Ryzyko: po 6 autach koniec wyborów; Cash nie ma zastosowania w tym teście.

Źródła zasad wykonania: [[playbook/FUN_CHECKLIST]], [[playbook/ARCHITECTURE]], LihFolk Vault V2.

## Iteracja 2 (02.11.2026)
- Kamera PlayerModule: Custom, Humanoid, obrót i zoom; brak przejmowania wejścia i nadpisywania co klatkę.
- Reakcja po potwierdzeniu serwera: mandat na szybie, podskok, TICKETED! +$/s i dźwięk.
- +$/s to przyrost dochodu po dostawie, nie jednorazowe przyznanie Cash.
- Parking pop oraz +1 Power są lokalne; transport z lotem mandatu trwa ok. 2,55 s.

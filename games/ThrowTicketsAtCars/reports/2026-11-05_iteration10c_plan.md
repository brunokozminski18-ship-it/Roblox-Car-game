# Iteracja 10c — plan wykonania
05.11.2026. Spec: zlecenie użytkownika i research/ThrowFoodForAnimals.md [G]. Wykonanie w tym chacie przez Codex.

Cel: bezpieczne powroty, rankingi i darmowe auto. Luau/Rojo, profil źródłem prawdy. NOT FINAL, teksty EN. Bez Rebirth/Robux/publikacji.

- [x] ReturnRules i schema 6: LastSeen/OfflineRate, pending max 8 h, tutorial, free cooldown, playtime/like, BestOdds. Testy 59/60 s, 8 h, cofnięcia zegara, migracji, serializacji.
- [x] ReturnService/Clock: load nalicza i zapisuje pending; CLAIM zapisuje razem cash i wyzerowany pending przed potwierdzeniem. Blokada mutacji przy zapisie nagrody; niepewny zapis wymusza reconnect. QA tylko klucze QA_, offset tylko serwer.
- [x] Jedna próbka Welcome Back w stylu D, telefon poziomo, do oceny. Pozostały wygląd po akceptacji próbki (AGENTS.md).
- [x] Free car: obecny biom postępu wg Power, losowanie serwera, bez rekordu catch; plecak; atomowy zapis auta/cooldownu. Czas biegnie między sesjami, bez kumulacji nagród.
- [x] Most Cars = posiadane auta, Top Money = kasa, Luckiest Catch = historyczne 1 in X. UpdateAsync tylko zmienione (generacja sesji / max rekordu), budżety read+write, top10/60 s, cache i fallback lokalny. QA osobno.
- [x] Like: 600 s czasu gry także po rejoin; odroczenie w catch/meter/modalach; bez nagrody za like.
- [x] QA: przesunięty zegar, cap/pending, spam claim, zapis/rejoin, kilka profili rankingu, pełny plecak/cooldown. Telefon przed PC. Build/regresje, raport/lista, commit, ustawienia Studio przywrócone.

Źródło: LihFolk Vault V2 (CC BY 4.0), odczyt MCP 05.11.2026. Ordered budgets: write 30+5×players/min, list 5+2×players/min. 3 list/min; zmienione zapisy rozłożone co 120 s i przy wyjściu.

Ryzyka: nieznane potwierdzenie zapisu, wyjście podczas CLAIM, konkurencyjny autosave, carry pending po rejoin, brak budżetu API.

Wykonanie: 470 asercji PASS, Studio QA i przegląd kodu zakończone. Celowe odstępstwo: po przeglądzie zapis indeksu warunkowy, aby starsza sesja nie cofała wyników; duże Money zakodowane z dokładnością <3ppm. Szczegóły i granice w raporcie 2026-11-05_iteration10c.

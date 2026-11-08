---
updated: 2026-10-30
---
# Wnioski: Be a Pumpkin Hunter

Symulator zbierania dyń: collector → plecak → Sell → lepszy sprzęt → bramy 5 stref → jaja i pety → Rebirth. Praca wrzesień–październik 2026, wielu agentów (Codex, Gemini, Antigravity, Claude).

## Gra

1. **Główna czynność była nudna.** Gracz tylko chodzi i zbiera, a reszta to zakupy w menu. W porównaniu z Ninja Legends czy Bubble Gum Simulator brakuje aktywnej, zmiennej czynności, eventów i rzeczy do robienia z innymi. Systemy (pety, strefy, Rebirth) powstały, zanim ktoś sprawdził, czy samo zbieranie bawi. → Zawsze [[playbook/FUN_CHECKLIST]] przed systemami.
2. **Motyw sezonowy kończy się z datą.** Gra o Halloween dopracowywana do końca października traci sens 1.11. → Motyw sezonowy wypuszczać min. 3–4 tygodnie przed datą albo wybierać motyw bez daty ważności.
3. **Budowanie dużych rzeczy bez próbki kosztuje.** System latających wysp powstał i został wycofany. Waluta Candy istniała bez celu wydawania i została usunięta 29.10. → Najpierw mały przykład i decyzja, potem seria.

## Pierwsze minuty (analityka i test na świeżym koncie, 27–28.10)

4. **35% graczy nie kupowało pierwszego sprzętu.** Pomogły: strzałki do sklepu, jednorazowy obrót kamery na sklep, okno z zaznaczonym przedmiotem, na który gracza stać, i automatyczne zamykanie okna po odejściu od sklepu.
5. **Martwa strefa po samouczku.** Gracze nie wiedzieli, że jaja przyspieszają zarobek ×2–4; lejek „Tutorial Complete → Zone 2” tracił 22%. Pomogły jednorazowe podpowiedzi następnego celu (np. „VISIT EGGS”) i obniżenie bramy strefy 2 z 42K do 30K.
6. **Dojście do sprzedaży było za daleko** (jedyny Sell przy spawnie, plecak pełny w ~10 s). → Punkt sprzedaży w każdej strefie od początku.
7. **Liczby zaokrąglane w górę oszukują gracza** („30K” przy 29 999 obok bramy 30K). → Skróty liczb obcinać, nie zaokrąglać.

## Telefon

8. Ok. 83% graczy Robloxa gra na telefonie. Najwięcej problemów było na małych ekranach poziomo: banery na licznikach HUD, okno pełnego plecaka zasłaniające kartę jaja, ogłoszenia stref na środku ekranu. → [[playbook/MOBILE_UI]], test w emulatorze telefonu przy każdej zmianie UI.

## Technika i praca

9. **Studio jako źródło prawdy = utracona praca.** 41 skryptów żyło tylko w Studio, lokalne kopie się rozjeżdżały, a Studio raz otworzyło starszą wersję z chmury i część pracy trzeba było odzyskiwać z kopii. → Cały kod w Rojo + git od pierwszego dnia.
10. **Rozdęta dokumentacja.** 359 notatek, z czego ok. 10 to wiedza; reszta to raporty, archiwa i README modeli. DECISIONS 683 linii, PROGRESS 42 KB — agenci nie mieścili ich w kontekście. → Limity z [[AGENTS]].
11. **Kilku agentów piszących do tych samych plików** dopisywało każdy po swojemu. → Jeden agent prowadzi grę naraz.
12. Studio czasem traci logowanie do DataStore (błąd 9002) — wtedy zakupy w teście „nie działają”. Restart Studio. Testy na osobnym magazynie QA, profil testowy przywracany po teście.
13. Moduł kamery Robloxa nadpisuje bezpośrednie ustawienie `CFrame` — do obrotu kamery przełączać na Scriptable i z powrotem na Custom.
14. Jaja + waluta za Robux = „płatne losowanie”: wymagane PolicyService i pokazane szanse przed zakupem.

## Co zadziałało i warto przenieść

- Zapis z walidacją i jednym magazynem, idempotentne zakupy, trading z dziennikiem transakcji.
- Samouczek ze strzałkami, analityka lejka pierwszych minut.
- Zasady statusów i decyzji tylko od użytkownika.
- Pipeline Blender → pety z VFX.

Status: wnioski z pracy i testów do 29.10.2026; wyniki gry po publikacji — NEEDS VERIFICATION (dopisać po analityce z listopada).

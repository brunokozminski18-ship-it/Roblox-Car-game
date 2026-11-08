# Styl samochodów z Car Pack

Pełna baza wiedzy i skill `car-modeling` (08.11.2026): [[references/car-modeling/SKILL]]. Atlas wszystkich 19 baz, inwentarz 95 aut, 68 zrzutów oraz skrypty Blender Python i QA; ograniczenia dostępu do geometrii opisane w [[references/car-modeling/references/export-and-sources]].

Wzorzec do wykonania kolejnego samochodu w Blenderze. Pomiar z 07.11.2026 w otwartym `Car Pack.rbxl`, ścieżka w Studio `Workspace/Cars`. Zacznij od folderu `Normal`. Do profilu z wysoką kabiną użyj `BimmerN2` i `Gulf`, do sportowej maski i świateł użyj `Supre`. Obejrzyj przód pod kątem, czysty bok i tył w tej samej skali na ekranie.

## Proporcje odczytane w Studio

Wymiary to obwiednie widocznych MeshPartów w osiach sceny, w studach. Pominąłem pomocniczy Handle. Rozstaw osi obliczyłem z położeń środków opon. Średnica jest przybliżeniem według największego lokalnego wymiaru części opony.

| Model | Dł. × szer. × wys. | Rozstaw osi / dł. | Średnica opony / dł. | MeshParty |
| --- | --- | --- | --- | --- |
| BimmerN2 | 9,19 × 4,39 × 2,99 | 59,7% | 15,7% przód / 16,5% tył | 22 |
| Supre | 10,02 × 4,57 × 2,66 | 55,9% | 14,3% obie osie | 23 |
| Gulf | 9,66 × 4,68 × 3,47 | 61,2% | 16,0% przód / 16,9% tył | 21 |

Wszystkie 19 baz zajmuje 9,19–10,37 studa długości i składa się z 20–33 MeshPartów. Te liczby opisują organizację gotowych obiektów. Studio odmówiło odczytu źródłowych wierzchołków przez EditableMesh. Liczba trójkątów, dokładna topologia i układ UV oryginałów pozostały niezmierzone.

## Budowa następnego auta

1. Ze zdjęcia docelowego auta wyznacz osie, zwisy, początek przedniej szyby, szczyt i koniec dachu oraz wysokość bagażnika. Wybierz z tabeli najbliższy typ nadwozia. Zachowaj różnice między sedanem, hatchbackiem a supersamochodem.
2. Poprowadź duże płaszczyzny przez środek maski, górę błotnika, bark i dół drzwi. Oświetlenie ma ujawnić zmianę kąta. Najwięcej podziałów przeznacz na obrys nadkola oraz przejście maski w zderzak. W Supre bok drzwi z odległości kamery gry wygląda jak jedno pole lakieru.
3. Zbuduj nieprzezroczystą szybę i słupki zewnętrzne. W Supre przednia szyba ma kolor `#6E99CA`, materiał Plastic, Transparency 0 i Reflectance 0,5. Ten kolor występuje w 18 z 19 aut bazowych. W Blenderze sprawdzaj odbiór błękitu w docelowym świetle.
4. Obrys reflektora wykonaj jako pojedyncze jasne pole. Dopasuj jego narożniki do konkretnego auta. W Supre przód ma Neon `#B3B4BA`, tył Neon `#FF5959`, wnęki `#111111`, splitter i akcenty `#37383E`. Boki i przód powinny łączyć się również przy widoku z profilu.
5. Opona ma mieć czytelny wielokątny obrys. `#2A2A30` występuje we wszystkich 19 bazach. W Supre i BimmerN2 felga jest `#61616F`; zbliżenia pokazują szerokie sektory i prosty środek. Golf ma jeszcze prostsze koło. Wyznacz pivot każdego koła na osi.
6. W204 ma być bez znaczka Mercedesa na grillu, masce, klapie i piastach. Rozpoznawalność oprzyj na szerokim grillu z pojedynczą poprzeczką, podwójnym przetłoczeniu maski, kształcie reflektorów i czterech końcówkach wydechu. W profilu zachowaj tylną parę drzwi i słupek B.

## Jak czytać przód auta bez emblematu

Na zbliżeniu BimmerN2 ma dwa oddzielne ciemne otwory pośrodku i szeroki dolny wlot. W Supre przód wyróżnia spiczasty środek maski pomiędzy skośnymi lampami. Gulf ma krótki przód, szerokie lampy i wysoki dach. Przy porównaniu zachowaj na ekranie tę samą szerokość auta i sprawdź położenie lamp względem grilla.

W Studio zmierzono szerokość obwiedni części zawierającej parę przednich lamp, razem z odstępem między nimi. To 75,8% całkowitej szerokości BimmerN2, 80,1% Supre i 74,5% Gulf. Wysokości tych części wynoszą kolejno 0,35, 0,36 i 0,47 studa. Szerokość pojedynczego reflektora i jego narożniki dobierz do zdjęcia konkretnego samochodu.

## Warianty i kontrola

Każda z czterech odmian dla wszystkich 19 baz zachowuje komplet identyfikatorów i rozmiarów siatek bazowych. W Supre Golden zmienia lakier na `#FFB000`, Diamond na `#04AFEC`, Ruby na `#FF4646`. Te trzy wersje mają odpowiednio 1, 3 i 4 emitery. Neon używa świecącego lakieru w kolorze bazowym. W 95 autach zbadane MeshParty mają puste TextureID i nie mają SurfaceAppearance.

Porównaj miniatury o szerokości około 250 px. Sprawdź, czy przy tej wielkości widać osobno szybę, lampy, wloty, koła i cechę rozpoznawczą. W większym podglądzie obejrzyj łączenia lamp z błotnikiem, prześwit i tył. Po eksporcie otwórz GLB ponownie i porównaj wymiary, liczbę siatek, trójkąty i obecność palety.

Próbka porównawcza: [[games/ThrowTicketsAtCars/assets/cars/W204 C63/W204 - porownanie.jpg]]. Z lewej W204 w Blenderze, z prawej oryginalne auta w Studio. Różne oświetlenie wpływa na jasność szyb i felg.

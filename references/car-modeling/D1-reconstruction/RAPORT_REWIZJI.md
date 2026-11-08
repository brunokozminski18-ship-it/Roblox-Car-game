# D1 — kontrola rekonstrukcji po ponownym otwarciu

08.11.2026. Rekonstrukcja stoi naprzeciwko D1. Oryginał posłużył do pomiarów optycznych. Kontrola hierarchii i właściwości wszystkich 95 oryginalnych aut wykazała zgodność ze stanem wyjściowym.

## Zgodność widocznych obrysów

Wartości to wspólny obszar dwóch masek podzielony przez ich sumę. Obie wersje porównano z oryginałem. Kolumny pokazują wynik poprzedniej i nowej wersji po odczycie pliku projektu.

| Ujęcie | Element | Poprzednio | Obecnie |
|---|---|---:|---:|
| Przód | Lakier | 93.03% | 93.74% |
| Przód | Szyby | 98.04% | 98.45% |
| Przód | Reflektory | 84.54% | 91.74% |
| Przód pod kątem | Lakier | 93.00% | 93.73% |
| Przód pod kątem | Szyby | 95.72% | 95.96% |
| Przód pod kątem | Reflektory | 86.42% | 88.96% |
| Bok | Lakier | 87.70% | 87.31% |
| Bok | Szyby | 91.58% | 92.46% |
| Tył pod kątem | Lakier | 93.40% | 94.54% |
| Tył pod kątem | Szyby | 86.59% | 84.37% |
| Tył pod kątem | Tylne lampy | 71.05% | 81.51% |
| Góra | Lakier | 96.78% | 97.24% |
| Góra | Szyby | 93.93% | 93.97% |

## Niezależne zbliżenia

Tych pięciu ustawień aparatu nie użyto do obliczania przesunięć wierzchołków. Służyły do wyboru wersji. Obszar oceny ograniczono do rzutu mierzonego elementu. Na zbliżeniu maski oceniono widoczny lakier.

| Element | Poprzednio | Obecnie |
|---|---:|---:|
| Reflektory od przodu | 83.27% | 89.21% |
| Reflektor pod kątem | 85.76% | 88.44% |
| Szyba boczna | 92.02% | 92.30% |
| Tylna lampa z drugiej strony | 63.66% | 67.59% |
| Lakier maski | 96.46% | 96.79% |

## Co zmieniło wynik

- Dopasowanie lokalnych płaszczyzn poprawiło tylną belkę i dyfuzor. Pełna korekta centralnego wlotu zwiększała błąd głębokości, więc ją wycofano.
- Dopasowanie obrysów poprawiło drzwi, szyby i tylne światła. Poprawkę przedniej lampy zastąpiono korektą maski w miejscach, w których karoseria przesłaniała zmierzony obrys.
- Obie tylne lampy sprawdzono z przeciwnych stron. Korektę wlotów maski cofnięto razem z ich podparciem, kiedy poprawa na wprost pogorszyła widok z góry.
- W trwałym podglądzie sprawdzono również mniejsze grupy brył karoserii i szyb. W szerokim ujęciu od tyłu wynik szyb spadł z 84,37% do 83,78%, a boczny obrys lakieru z 87,31% do 87,05%. Przywrócono poprzednią wersję.
- Pokrycie ciemnego wlotu drzwi na bocznym zdjęciu wzrosło z 95.31% do 96.90%. Dane wszystkich testów porównawczych są w pliku Wyniki.json.

## Geometria i zapis

Z 118,980 promieni w rekonstrukcję trafiło 118,025, wcześniej 118,032. Mediana błędu dla trafień zmieniła się z 0.00299 do 0.00284 studa. 90. percentyl zmienił się z 0.11924 do 0.11967 studa. Promienie pochodzą z pomiarów optycznych użytych przy budowie.

Blender ponownie otworzył model. Po eksporcie i imporcie GLB zachował 29 siatek i 13,464 trójkąty. Różnica wymiarów wyniosła 0.0 studa. Zapisany projekt zawiera gotowy widoczny model. Na kontrolnej kopii obiektu w świeżo otwartym Studio sprawdzono odtworzenie 29 własnych MeshPartów i 29 połączeń Weld.

## Pozostałe różnice

Zbliżenia pokazują różnice w załamaniach powierzchni maski, dolnej krawędzi tylnych lamp i przejściach między drzwiami a tylnym błotnikiem. W szerokim ujęciu ukośnym z tyłu trwały podgląd oddaje szyby słabiej niż edytowalne siatki. Studio odmówiło odczytu źródłowych wierzchołków. Optyka nie rozstrzyga budowy zakrytych powierzchni, UV ani identyczności topologii. Zgodność 1:1 pozostaje niepotwierdzona.

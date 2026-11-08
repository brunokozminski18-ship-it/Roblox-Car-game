# D1 — wynik rekonstrukcji, 8 listopada 2026

W pełnym projekcie Car Pack własny D1 stoi około 14 studów przed pierwowzorem, przodem do niego. Porównałem pozycje, rozmiary, kolory, materiały i identyfikatory części 95 samochodów pomiędzy zapisem bazowym i oddawaną sceną. Wszystkie przeszły kontrolę, w tym 30 części oryginalnego D1.

## Pięć ujęć po ponownym otwarciu

Górny rząd planszy przedstawia oryginał. Dolny rząd pokazuje trwałą reprezentację odczytaną z pliku w osobnej sesji Studio. Kamery miały jednakowe położenia względem auta, pole widzenia 35° i obraz 1406 × 650. Do zdjęć porównawczych ustawiono własny samochód wyżej, aby oddzielić go od innych modeli. Po sesji przywrócono jego położenie.

| Ujęcie | Lakier | Szyby | Światła |
| --- | ---: | ---: | ---: |
| Przód | 93,0% | 98,0% | 84,5% |
| Przód ¾ | 93,0% | 95,7% | 86,4% |
| Bok | 87,7% | 91,6% | — |
| Tył ¾ | 93,4% | 86,6% | 71,1% |
| Góra | 96,8% | 93,9% | — |

Wartość to pole wspólne dwóch masek barwy podzielone przez pole ich sumy (IoU). Średnia dla lakieru wynosi 92,8% wobec 65,1% w pierwszej wersji. Na wynik szyb wpływają również odbicia i tło. Tabela ocenia widoczne obszary na zdjęciach. Źródłowe wartości zapisano w pliku porównania.

## Iteracje i decyzje

| Próba | Trzy sprawdzane rozbieżności | Wynik |
| --- | --- | --- |
| Bryły z obrysów | Otwory w masce, zagłębienia boków, dyfuzor | Porównano 29 części z odłożonymi widokami. Dopasowanie samych obrysów pogorszyło część opon. |
| Pomiary głębokości | Kształt oszklenia, przekrój nadwozia, felgi | Zastosowano pary ekspozycji z wzorcami odległości, a felgom i oponom nadano zmierzony dziesięciokątny profil. |
| Wycinanie otworów | Nos, przejścia przy lampach, otwory maski | Ogólne wycinanie z jednostronnych sylwetek obniżyło pokrycie lakieru z przodu do 49,9%. Wycofano tę karoserię. |
| Przekroje i cienkie panele | Poprzeczka tylna, dyfuzor, skrzydło | Dla poprzeczki błąd głębokości na 90. percentylu zmalał z 0,253 do 0,034 studa. Zachowano wcześniejsze części tam, gdzie przekroje pogorszyły wynik. |
| Osadzenie detali | Reflektory, wkładki maski, tylne światła | Korygowano kontakt ze zmierzoną powierzchnią, gdy widoczny na oryginale detal zasłaniała własna karoseria. Największe przesunięcie wyniosło 0,065 studa. Następnie ponowiono zdjęcia całego auta. |

## Geometria i granice pomiaru

Z 118 980 promieni skierowanych na optycznie zmierzone powierzchnie 118 032 trafiły w rekonstrukcję. Dla trafień mediana odległości pomiędzy powierzchniami wyniosła 0,003 studa, a 90. percentyl 0,119 studa. W pierwszej próbie odpowiednie wartości wynosiły 0,050 i 0,354 studa, przy pokryciu około 73,4%. Promienie pochodzą z pomiaru wykorzystanego do budowy. Jest to sprawdzenie dopasowania do obserwacji, a nie niezależny pomiar rzeczywistej siatki.

Największa niepewność geometryczna dotyczy wewnętrznych i bocznych powierzchni felg. Na zdjęciach różnią się również dolne krawędzie tylnych lamp, płaszczyzny wokół wlotów maski i niektóre połączenia paneli. Studio odmówiło odczytu źródłowych wierzchołków. Identyczność topologii, UV i ukrytych ścian pozostaje niepotwierdzona.

## Pliki i odtworzenie

W folderze `assets/D1 delivery` znajdują się pełny projekt `D1 - Car Pack.rbxlx`, edytowalny `D1.blend`, eksport `D1.glb`, plansza z pięciu ujęć i wyniki kontroli. Blender ponownie otworzył plik źródłowy. Eksport i ponowny import GLB zachowały 29 siatek, 13 464 trójkąty i wymiary. W pliku Blendera usunięto zduplikowane lub zdegenerowane trójkąty.

W Studio samochód jest od razu widoczny dzięki lokalnej geometrii w `PortableDisplay`. Plik zawiera także kompletny przepis na własne MeshParty. Poniższe polecenie w pasku poleceń Studio zamienia podgląd na 29 siatek. Przetestowano je po ponownym otwarciu. Powstało 29 widocznych MeshPartów i 29 poprawnych połączeń z Handle.

```lua
local car = workspace.D1_Rebuilt_From_Analysis
require(car.RestoreOwnGeometry)(car)
```

Trwały podgląd jest potrzebny, ponieważ zwykły zapis lokalnych EditableMesh usuwa ich zawartość po ponownym otwarciu. Zachowaj dostarczony projekt jako wersję do otwierania. Edycję odtworzonych MeshPartów zapisuj w roboczej kopii.

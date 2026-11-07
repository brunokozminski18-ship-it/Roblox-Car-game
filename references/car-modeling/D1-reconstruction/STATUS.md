# D1 — stan próby odtworzenia, 08.11.2026

**NOT FINAL. Zgodność wizualna 1:1 nie została osiągnięta.**

## Co wykonano
- Odczyt 30 części oryginału: 29 MeshPartów i Handle; 29 Weldów. Każda siatka ma pomiar rozmiaru, położenia, koloru i materiału w source-parts.json oraz rolę w PART_ANALYSIS.md.
- Osiem widoków oryginału: przód, przód 3/4, bok, tył 3/4, tył, góra, maska i koło.
- 29 własnych siatek, 1694 własne trójkąty, nowy Handle i 29 Weldów. Bez Clone, bez źródłowych MeshId i bez źródłowych wierzchołków. Wszystkie nowe MeshId są puste — używają lokalnych obiektów EditableMesh.
- Model w Studio: `Workspace.D1_Rebuilt_From_Analysis`. Znajduje się około 14 studów przed oryginałem, obrócony o 180°, przodami do siebie. Oryginał pozostaje w `Workspace.Cars.Normal.D1`.
- Kontrola oryginału: 30/30 odczytanych części zachowało nazwę, CFrame, Size, kolor, materiał, Reflectance, Transparency i MeshId. verification.json: brak różnic.

## Co nie przeszło oceny
- Sylwetka, obrysy i połączenia paneli, kształty lamp, felgi oraz tył wciąż różnią się od wzorca. Zgodność obwiedni nie dowodzi zgodności kształtu ani jakości.
- Główna karoseria `82937210116011`, przednie lampy, szyby i pokrywa silnika odmówiły odczytu EditableMesh: `no permission to load asset`. Nie pozyskano źródłowej topologii. Odtworzenie korzysta z pomiarów i widoków.
- Nowe powierzchnie są miejscami otwarte i używają DoubleSided=true. Nie jest to ukończony model produkcyjny ani drivable rig.
- Dla własnych wlotów w masce zmieniono dopasowanie wysokości do zaprojektowanej powierzchni; nie należy deklarować identyczności wymiarów wszystkich 29 części.

## Pliki i trwałość
- Kod: scripts/build_d1.py. Własna geometria: assets/D1-independent-rebuild.blend i assets/authored-parts.json.
- ModuleScript `RestoreOwnGeometry` w nowym modelu i plik scripts/restore_meshes.luau zawierają cały własny przepis na geometrię. Sprawdzono wykonanie przywracania: ponownie 29 MeshPartów.
- EditableMesh jest lokalnym podglądem tej sesji; nie udajemy trwałych opublikowanych mesh assetów. Po ponownym otwarciu zapisanej sceny siatki wymagają ponownego odtworzenia przez ten moduł. Nie testowano cyklu zapis/ponowne otwarcie rbxl.
- Studio pozostało w Edit; kamera pokazuje oba auta, zaznaczona jest rekonstrukcja. Bez publikacji i bez uploadu assetów.

## Wniosek
Same obwiednie części plus ogólny przepis na low-poly nie wystarczają do odtworzenia jakości i kształtów 1:1. Potrzebny jest dokładniejszy rysunek powierzchni i ich połączeń, weryfikowany dla każdej roli w tych samych widokach. Obecny rezultat pozostaje niezaakceptowaną próbą, a nie wykonaniem wymagania 1:1.

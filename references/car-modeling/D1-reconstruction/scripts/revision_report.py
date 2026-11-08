"""Assemble checked Studio, Blender, optical and integrity records for the D1 review."""
import hashlib
import json
import shutil
from pathlib import Path


base=Path(__file__).resolve().parents[1]
assets=base/"assets"
dest=assets/"D1 - rewizja optyczna"
def read(file):
    return json.loads(file.read_text(encoding="utf-8"))
old=read(assets/"compare-reopened.json")
new=read(assets/"compare-final-reopen.json")
detail=read(assets/"detail-comparison.json")
trim=read(assets/"trim-results.json")
rays=read(assets/"accepted-ray-audit.json")
before=read(assets/"contact-ray-audit.json")
qa=read(dest/"D1.roundtrip.json")
integrity=read(assets/"reopened-final-integrity.json")
initial=read(base.parent/"evidence/integrity.json")["baseline"]
assert integrity["cars"]==initial and len(initial)==95 and qa["status"]=="PASS"
assert integrity["restore"]["revision"]=="accepted" and integrity["restore"]["welds"]==29
trials=["plane-mix","plane-trim","boundary","nose","contour2","relieved","hybrid","detail-pass","bilateral","fine-matched"]
summary={"originalCarsChecked":len(initial),"restore":integrity["restore"],"oldDisplay":old,"finalDisplay":new,
         "independentCloseups":detail,"trim":trim,"trials":{s:read(assets/f"compare-{s}.json") for s in trials}}
(dest/"Wyniki.json").write_text(json.dumps(summary,indent=2),encoding="utf-8")
shutil.copyfile(assets/"compare-final-reopen.jpg",dest/"Pięć widoków.jpg")
shutil.copyfile(assets/"detail-comparison.jpg",dest/"Zbliżenia.jpg")
shutil.copyfile(assets/"accepted-ray-audit.json",dest/"Geometria.json")
lines=["# D1 — kontrola rekonstrukcji po ponownym otwarciu", "",
       "08.11.2026. Rekonstrukcja stoi naprzeciwko D1. Oryginał posłużył do pomiarów optycznych. Kontrola hierarchii i właściwości wszystkich 95 oryginalnych aut wykazała zgodność ze stanem wyjściowym.", "",
       "## Zgodność widocznych obrysów", "",
       "Wartości to wspólny obszar dwóch masek podzielony przez ich sumę. Obie wersje porównano z oryginałem. Kolumny pokazują wynik poprzedniej i nowej wersji po odczycie pliku projektu.", "",
       "| Ujęcie | Element | Poprzednio | Obecnie |","|---|---|---:|---:|"]
views=["Przód","Przód pod kątem","Bok","Tył pod kątem","Góra"]
roles={"paint":"Lakier","glass":"Szyby","headlamp":"Reflektory","taillamp":"Tylne lampy"}
for label,(view,scores) in zip(views,new.items()):
    for key,value in scores.items():
        lines.append(f"| {label} | {roles[key]} | {old[view][key]:.2%} | {value:.2%} |")
lines+=["","## Niezależne zbliżenia","","Tych pięciu ustawień aparatu nie użyto do obliczania przesunięć wierzchołków. Służyły do wyboru wersji. Obszar oceny ograniczono do rzutu mierzonego elementu. Na zbliżeniu maski oceniono widoczny lakier.", "",
        "| Element | Poprzednio | Obecnie |","|---|---:|---:|"]
for name,a,b in zip(["Reflektory od przodu","Reflektor pod kątem","Szyba boczna","Tylna lampa z drugiej strony","Lakier maski"],detail["old-display"],detail["final-reopen"]):
    lines.append(f"| {name} | {a:.2%} | {b:.2%} |")
lines+=["","## Co zmieniło wynik","","- Dopasowanie lokalnych płaszczyzn poprawiło tylną belkę i dyfuzor. Pełna korekta centralnego wlotu zwiększała błąd głębokości, więc ją wycofano.",
        "- Dopasowanie obrysów poprawiło drzwi, szyby i tylne światła. Poprawkę przedniej lampy zastąpiono korektą maski w miejscach, w których karoseria przesłaniała zmierzony obrys.",
        "- Obie tylne lampy sprawdzono z przeciwnych stron. Korektę wlotów maski cofnięto razem z ich podparciem, kiedy poprawa na wprost pogorszyła widok z góry.",
        "- W trwałym podglądzie sprawdzono również mniejsze grupy brył karoserii i szyb. W szerokim ujęciu od tyłu wynik szyb spadł z 84,37% do 83,78%, a boczny obrys lakieru z 87,31% do 87,05%. Przywrócono poprzednią wersję.",
        f"- Pokrycie ciemnego wlotu drzwi na bocznym zdjęciu wzrosło z {trim['reopened']['intake-2']:.2%} do {trim['final-reopen']['intake-2']:.2%}. Dane wszystkich testów porównawczych są w pliku Wyniki.json.",
        "","## Geometria i zapis","",
        f"Z {rays['rays']:,} promieni w rekonstrukcję trafiło {rays['hits']:,}, wcześniej {before['hits']:,}. Mediana błędu dla trafień zmieniła się z {before['medianStuds']:.5f} do {rays['medianStuds']:.5f} studa. 90. percentyl zmienił się z {before['p90Studs']:.5f} do {rays['p90Studs']:.5f} studa. Promienie pochodzą z pomiarów optycznych użytych przy budowie.",
        "",f"Blender ponownie otworzył model. Po eksporcie i imporcie GLB zachował {qa['before']['mesh_count']} siatek i {qa['before']['triangles']:,} trójkąty. Różnica wymiarów wyniosła {qa['max_dimension_error']} studa. Zapisany projekt zawiera gotowy widoczny model. Na kontrolnej kopii obiektu w świeżo otwartym Studio sprawdzono odtworzenie 29 własnych MeshPartów i 29 połączeń Weld.",
        "","## Pozostałe różnice","","Zbliżenia pokazują różnice w załamaniach powierzchni maski, dolnej krawędzi tylnych lamp i przejściach między drzwiami a tylnym błotnikiem. W szerokim ujęciu ukośnym z tyłu trwały podgląd oddaje szyby słabiej niż edytowalne siatki. Studio odmówiło odczytu źródłowych wierzchołków. Optyka nie rozstrzyga budowy zakrytych powierzchni, UV ani identyczności topologii. Zgodność 1:1 pozostaje niepotwierdzona."]
report="\n".join(lines)+"\n"
(dest/"Raport.md").write_text(report,encoding="utf-8")
(base/"RAPORT_REWIZJI.md").write_text(report,encoding="utf-8")
manifest={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in dest.iterdir() if p.is_file() and p.suffix not in (".lock",) and p.name!="SHA256.json"}
(dest/"SHA256.json").write_text(json.dumps(manifest,indent=2,ensure_ascii=False),encoding="utf-8")
for name,digest in manifest.items():
    assert hashlib.sha256((dest/name).read_bytes()).hexdigest()==digest
print(len(manifest),"files verified")

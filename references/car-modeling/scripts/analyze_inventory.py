"""Read-only Studio inventory analysis. Bounds are transformed part boxes, not vertices."""
import argparse
import csv
import json
from collections import Counter
from pathlib import Path


def corners(p):
    c, s = p['cframe'], p['size']
    for a in (-.5, .5):
        for b in (-.5, .5):
            for d in (-.5, .5):
                v = (s[0]*a, s[1]*b, s[2]*d)
                yield [c[i]+sum(c[3+i*3+j]*v[j] for j in range(3)) for i in range(3)]


def bounds(parts):
    pts = [v for p in parts for v in corners(p)]
    lo = [min(v[i] for v in pts) for i in range(3)]
    hi = [max(v[i] for v in pts) for i in range(3)]
    return lo, hi, [hi[i]-lo[i] for i in range(3)]


def geometry_signature(model):
    # Duplicated names are common: compare multisets, never dictionaries keyed by name.
    return Counter((p['name'], p['mesh'], tuple(round(x, 5) for x in p['size']))
                   for p in model['parts'] if p['class'] == 'MeshPart')


def summarize(model):
    meshes = [p for p in model['parts'] if p['class'] == 'MeshPart']
    lo, hi, size = bounds(meshes)
    # Cars in this inspected pack face -world Z. Do not apply that to a rotated pack.
    width, height, length = size
    # Dark trim shares the tire colour. Names were inspected across all 19 bases.
    tire_name = 'Meshes/Cars_Cylinder' if model['name'] == 'Gulf' else 'Meshes/Cars_Cylinder.004'
    tires = [p for p in meshes if p['name'] == tire_name and p['color'] == '#2A2A30']
    if len(tires) != 4:
        raise ValueError(f"{model['name']}: inspect tire classifier; expected 4, got {len(tires)}")
    zs = sorted(p['cframe'][2] for p in tires)
    axles = []
    for z in zs:
        if not axles or abs(z-axles[-1]) > .03:
            axles.append(z)
    wheelbase = axles[-1]-axles[0] if len(axles) == 2 else None
    diameters = [max(p['size']) for p in tires]
    return {'name': model['name'], 'meshparts': len(meshes),
            'length': length, 'width': width, 'height': height,
            'width_length': width/length, 'height_length': height/length,
            'wheelbase': wheelbase, 'wheelbase_length': wheelbase/length if wheelbase else None,
            'tire_diameter_min': min(diameters) if diameters else None,
            'tire_diameter_max': max(diameters) if diameters else None,
            'tire_count_by_name_and_palette': len(tires),
            'front_overhang': axles[0]-lo[2] if len(axles) == 2 else None,
            'rear_overhang': hi[2]-axles[-1] if len(axles) == 2 else None,
            'bounds_min': lo, 'bounds_max': hi,
            'palette': dict(Counter(p['color'] for p in meshes)),
            'materials': dict(Counter(p['material'] for p in meshes)),
            'render_fidelity': dict(Counter(p['render'] for p in meshes)),
            'hierarchy': dict(Counter(h['class'] for h in model['hierarchy']))}


def main(root):
    root = Path(root)
    sets = {v: json.loads((root/f'{v}.json').read_text(encoding='utf-8'))['models']
            for v in ('Normal', 'Golden', 'Diamond', 'Ruby', 'Neon')}
    normal = {m['name']: m for m in sets['Normal']}
    rows = [summarize(m) for m in sets['Normal']]
    comparisons = []
    for variant, models in sets.items():
        for m in models:
            base = normal[m['name']]
            comparisons.append({'variant': variant, 'name': m['name'],
                                'mesh_asset_size_multiset_equal': geometry_signature(base) == geometry_signature(m),
                                'emitters': len([e for e in m['effects'] if e['class'] == 'ParticleEmitter']),
                                'palette': dict(Counter(p['color'] for p in m['parts'] if p['class'] == 'MeshPart')),
                                'materials': dict(Counter(p['material'] for p in m['parts'] if p['class'] == 'MeshPart'))})
    all_meshes = [p for models in sets.values() for m in models for p in m['parts'] if p['class'] == 'MeshPart']
    report = {'method': 'world-axis bounds of visible MeshPart OBB corners; excludes Handle; tire diameter is local max Size, not sampled vertices',
              'models': rows, 'variants': comparisons,
              'totals': {'cars': sum(map(len, sets.values())), 'meshparts': len(all_meshes),
                         'unique_mesh_ids': len({p['mesh'] for p in all_meshes}),
                         'nonempty_textures': sum(bool(p['texture']) for p in all_meshes),
                         'surface_appearance': sum(e['class'] == 'SurfaceAppearance' for models in sets.values() for m in models for e in m['effects']),
                         'variant_geometry_mismatches': sum(not c['mesh_asset_size_multiset_equal'] for c in comparisons)}}
    (root/'summary.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
    columns = ['name','meshparts','length','width','height','width_length','height_length','wheelbase','wheelbase_length','tire_diameter_min','tire_diameter_max','front_overhang','rear_overhang']
    with (root/'dimensions.csv').open('w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, columns, extrasaction='ignore')
        writer.writeheader()
        writer.writerows(rows)
    print(json.dumps(report['totals']))
    for r in rows:
        print(f"{r['name']:10} {r['meshparts']:2}  {r['length']:.3f} x {r['width']:.3f} x {r['height']:.3f}  WB/L={r['wheelbase_length'] or 0:.3f}")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('evidence')
    main(parser.parse_args().evidence)

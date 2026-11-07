# Modeling recipe and quality control

## Shape before detail

1. Choose body class and write a landmark table: nose, front axle, cowl, roof apex, cabin end, rear axle and tail, expressed as fractions of length. Use atlas reference measurements for wheelbase and overall volume. Estimate unmeasured cabin landmarks from images and mark them PROPOSED; do not invent precision.
2. Draw the complete side outline including front and rear wheels. Check front width and roof taper from front/top views. The camera should reveal both axle gaps and the whole bumper/wing silhouette. Avoid perspective-dependent measurements from a screenshot; use the inventory for dimensions.
3. Author a positive-X half-surface in Blender; keep X=0 centre seam mirrored and clipped. Define stations at the front bumper, front arch, cowl, door/shoulder transition, rear arch and tail. Station count follows curvature, not a fixed universal number. `panel_loft` connects explicit profiles; it does not decide a car's proportions.
4. Split bonnet, fender/door shoulder, lower side, cabin and bumper into manageable panel surfaces. On each, preserve broad planes; add a narrow chamfer only where it creates a visible edge. A single huge chamfered cube cannot express a bonnet falling between raised fenders and a recessed cabin.
5. Trim wheel openings against the actual tire envelope in side view. Manual vertices or a low-sided boolean cutter on a duplicate are options. Clean Boolean slivers; redirect edges into the shoulder instead of stretching one face across the arch. Test tire clearance and silhouette under flat light.
6. Fit an opaque glazing surface with painted pillars and a clearly positioned cowl. Keep roof and side window shapes distinct. A real family SUV needs its own rear passenger compartment and tail shape; Gulf is only a high-cabin reference, not an SUV preset.
7. Shape front and rear as volumes: bumper returns wrap onto the side, lamp outline follows the fender, dark intake sits within a recessed surround. Use a shallow dark inset plus lip when the depth is visible. Add a clean light polygon slightly outside its support surface to avoid coplanar flicker; adjust spacing in target units and inspect close up.
8. Wheels: build a low-sided casing with broad tread and chamfered shoulders, then inset rim face and substantial simple spokes/hub. Keep tire diameter and sidewall thickness consistent with the selected body class. Place origins at axle centres. A smooth torus and fine realistic tread do not match the observed style.
9. Secondary features: mirrors as chunky wedges, exhausts as simple shells with dark ends, spoilers as flat faceted aero sections. Keep local face directions intentional. Do not use decimation as the main source of stylization; it can destroy designed panel flow.
10. Use semantic objects/material roles: BodyPaint, Glazing, Tire_FL/FR/RL/RR, Rim_*, Headlights, Taillights, IntakeDark, Trim, Exhaust. Combine static islands only when the shared material/role and gameplay behavior justify it. Preserve individual wheel pivots.

## Blender tooling

The helpers in `../scripts/blender_car_tools.py` use no external packages beyond Blender. Import them through `sys.path` in a separate authoring file. All functions require an explicit collection, create new objects and leave current objects/selection untouched.

```python
from blender_car_tools import panel_loft, tire, material
# `work` is a newly created collection belonging to the new design.
paint = material('BodyPaint', '#31577D')
panel = panel_loft('BonnetHalf', [
    (-4.5, [(0,1.3), (1.2,1.35), (1.8,1.0)]),
    (-2.8, [(0,1.6), (1.3,1.75), (1.9,1.2)]),
], collection=work, mat=paint)
# These example points are a tiny original panel exercise, not a complete car preset.
```

`material` converts sRGB hex colours to linear Blender inputs. It stores Studio colour/material/transparency/reflectance as custom properties. They are a sidecar source; GLB does not automatically implement Roblox Neon or Reflectance. Do not equate roughness=.5 with Roblox Reflectance=.5. Use a neutral preview and then verify in Studio lighting.

Use a Blender background process for imports/tests. The connected artist scene was unsaved and in Edit Mesh mode during the inspection; it was preserved. Never reset it to run a batch.

## QA gates

For a repeatable neutral Blender comparison use orthographic views with the same scale for both cars, 900×600 px, camera aiming at the midpoint of the combined dimensions. With length near 10 units, use ortho_scale=9 (vertical span; horizontal span=13.5), front-three-quarter direction (8,-11,7), side (12,0,0), rear-three-quarter (-8,11,7), and a separate top view with ortho_scale=13. Use Standard colour management, exposure=0, gamma=1, a neutral world (linear RGB .18, strength .5) and three white area lights, all aimed at the target: key at offset (6,-8,10), 500 W, size 7; fill (-7,-4,6), 250 W, size 8; rim (2,7,9), 350 W, size 6. Keep these settings identical between comparisons and document the preview. This is a proposed review setup, not a reconstruction of Studio lighting. Actual Studio captures used FOV=35 perspective; their settings are in captures.json.

Choose a provisional triangle and material-split budget from the target scene: count cars simultaneously visible at normal phone camera distance, multiply by evaluated triangles and material/object groups, then measure a representative worst-case scene on the target phone or an explicitly named test device. Record frame time and visible-car count before/after one change. The observed 20–33 MeshParts/car does not establish acceptable draw calls or phone performance. No performance threshold has been measured in this reference pack.

| Gate | Evidence needed | Failure action |
|---|---|---|
| identity | same-screen-size front 3/4, full side, rear 3/4 vs two relevant atlas cars | reshape roof, nose, arches or signature feature; do not hide a weak side with a dramatic front camera |
| proportions | L/W/H, wheelbase, front/rear overhangs, tire diameters | compare by body class; document intentional differences |
| read at 250 px | glazing, lights, wheel/tire, intake and unique feature remain separated | simplify or increase graphic separation |
| surface quality | close views of hood, arch/door junction, bumper and roof; flat and raking light | remove pinching, noise, slivers, coplanar flicker and accidental smoothing |
| technical mesh | evaluated triangle counts, material slots, boundary/nonmanifold edges, zero-area triangles, scale/mirroring, UV status | inspect each warning. Open lamp/panel surfaces may be intentional; do not automatically fill all boundaries |
| pivots | each wheel origin on axle; agreed root pivot and orientation | fix in editable master before export |
| round trip | reimport GLB, bounds within .001 working stud, same triangles and expected splits | investigate scale, axes, modifiers and material-based splitting |
| Studio sample | inspect one new sample under target lighting at camera distance; record actual imported mesh/material counts | correct mapping/scale and repeat affected checks |
| appearance | explicit user feedback | status NOT FINAL until accepted; a technical PASS is insufficient |

`blender_audit.py` measures evaluated meshes, including modifiers. It reports topology warnings and material slot counts; it does not assert a universal triangle budget, detect all self-intersections, prove normals point outward for an arbitrary open surface, or certify visual quality. Flat polygon counts do not prove there are no custom-normal effects. A colourless imported object requires checking materials/vertex colours/import settings rather than assuming the palette survived.

`blender_roundtrip.py` exports a named collection in a background copy of the NEW master, imports it and saves a comparison report. It checks dimensions, triangles and mesh counts; separately compare material colour, object naming, pivots, texture presence and Studio-specific property mapping. A GLB can pass geometry checks yet look wrong in Studio.

## Validation commands

```text
python scripts/analyze_inventory.py evidence
blender -b --factory-startup --python-exit-code 1 --python scripts/test_blender_tools.py -- evidence/blender-tools-qa.json
blender -b --factory-startup --python-exit-code 1 --python scripts/blender_audit.py -- --input new-car.glb --out new-car-audit.json
blender -b new-car.blend --python-exit-code 1 --python scripts/blender_roundtrip.py -- --collection CAR_EXPORT --out new-car.glb
```

The synthetic fixture tests panels, tire manifold construction, dimensions, colour conversion, rim generation, audit behavior and GLB round-trip. It does not test Car Pack source geometry or validate a finished new car. The fixture's mesh/triangle totals must never be quoted as Car Pack's totals.

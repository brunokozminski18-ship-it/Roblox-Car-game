---
name: car-modeling
description: Use for every request from this user to create, reconstruct, inspect, or review a car model. Consult Car Pack references and use verified Blender and Roblox Studio geometry and five-view comparison procedures.
---

# Car modeling

Build new designs with Car Pack's visual grammar: controlled silhouette, broad faceted panels, opaque blue glazing, bold light shapes, simple dark recesses and substantial wheels. Match the nearest body class, rather than stretching one generic car.

## Evidence and boundaries

Read [the measured style bible](references/style-bible.md) and [the per-car atlas](references/model-atlas.md) before selecting proportions. The 07–08.11.2026 inspection covers **95 cars / 19 bases / 2,340 MeshParts / 300 distinct mesh IDs** in `Car Pack.rbxl`. Five variants reuse each base's mesh-ID/size multiset.

Source vertex data was **not obtained**: EditableMesh denied asset access; UI export could not be completed. Triangle counts, source topology, normals, UV layout and exact tire sector count are unknown. Never present helper defaults or a new model's budget as measurements of the pack. Read [export and evidence limits](references/export-and-sources.md) before attempting geometry access. Preserve source models; do not circumvent asset permissions.

## Working procedure

1. Inspect the active task and the user's requested body type. Choose two relevant atlas references. Do not add emblems or distinctive reference geometry unless requested and permitted. Original designs should have their own lamp outlines, roofline and feature arrangement.
2. Set **X width, Y length, Z up, front −Y, 1 Blender unit = 1 target stud** as the working convention; verify actual importer scale with a known dimension. Define wheel centres, overhangs, cowl, roof apex and roof end before details. A dimension is a target, not a new Roblox unit rule.
3. Follow [the modeling recipe and QA](references/modeling-and-qa.md). First solve the side silhouette, front width and wheel placement. Then shape the bonnet, shoulder, arches, bumper, glazing and rear. Put subdivisions where they change the outline or visible plane breaks.
4. Use `scripts/blender_car_tools.py` for explicit half-panel lofts, chamfered tire casings, broad rim spokes and palette metadata. These helpers create original adjustable pieces; they do not reconstruct the source meshes or guarantee style. Require a destination collection. Do not reset the artist's scene.
5. Keep independently recolourable/material regions separate and wheels pivoted at their axles. Preserve a Blender master and material/role sidecar. Use semantic names, not the source pack's repeated import names. Do not copy its decorative anchored assembly as a drivable chassis.
6. Produce **one sample** with front three-quarter, complete side, rear three-quarter and a ~250 px comparison. Show it to the user; continue a series only after approval. Technical PASS does not approve appearance or balance.
7. Audit and round-trip the export. `python scripts/analyze_inventory.py evidence` recalculates the reference measurements. For new meshes, run background Blender with `--python-exit-code 1 --python scripts/blender_audit.py -- --input <car.glb> --out <audit.json>`. Use `blender_roundtrip.py` against an explicitly named export collection in an isolated copy of the new `.blend`.

## Review contract

For every car request in this workspace, start from the measured atlas and the
closest reference body. For a reconstruction, also follow the
[five-camera optical comparison procedure](references/optical-comparison.md).
Keep the strongest previous version of each part. Use the same five cameras
to check the assembled vehicle after any change to the shell or adjacent trim.

Deliver the editable master, export, dimensions/pivots/material mapping, same-scale views, technical QA and remaining visual questions. Report separately **MEASURED**, **OBSERVED**, **PROPOSED**, and **UNMEASURED** facts. In this user's vault, write conversation in Polish and player text in English; honor the active project's source-of-truth and approval rules.

Common failures: generic box body; uniform subdivision everywhere; smooth torus tires; transparent windows requiring an absent interior; texture noise replacing shape; combining everything into one colour slot; counting dark trim as tires; collapsing duplicate source names into a dictionary; claiming Blender roughness reproduces Roblox Reflectance.

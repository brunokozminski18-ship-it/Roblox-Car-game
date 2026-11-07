# Geometry access, evidence and sources

## What was actually accessed

Studio MCP identified the only connected project as Car Pack.rbxl, in Edit mode. All Workspace Models were enumerated, then all five Cars variant folders were inspected in batches of three cars to avoid the tool's 100,000-character output truncation. A first full-folder query was truncated and discarded; persisted JSON files contain complete parsed batches.

Read `../evidence/Normal.json` for each model's flat/nested hierarchy, all BaseParts, MeshIds, Size, MeshSize, CFrame, PivotOffset, colours, materials, texture IDs, reflectance, physics flags and effects. Repeated names are retained in arrays; their name/path is NOT a unique key. See `construction.json` for joint endpoints and helper details.

95 model inventories and 19×3 comparable views were obtained. Additional front, wheel, top and variant captures document construction and appearance. `captures.json` records camera positions/FOV; unchanged source screenshots and labelled contact sheets are under `evidence/screenshots/`. Screenshots include neighboring parked cars and some editor gizmos; they are visual evidence, not orthographic plans or vertex measurements.

## Export result and limits

- Tested MeshId `rbxassetid://119204191489050`: AssetService CreateEditableMeshAsync failed with `no permission to load asset`. This is an observed permission failure for that asset, not proof that every source mesh is inaccessible.
- Blender MCP connected to Blender 5.2.1 LTS and confirmed OBJ/GLTF import operators. The artist's unsaved Edit-mode scene was not changed.
- A Windows UI export attempt could not reach the export dialog: capture timed out; recovered accessibility text had no usable coordinate geometry. No OBJ, glTF or GLB of an original was obtained. Therefore there is no source geometry report from Blender.
- Since LihFolk did not describe this Studio→external export route, official Roblox documentation was consulted. The [3D Export documentation](https://create.roblox.com/docs/art/modeling/gltf-export) describes Explorer → Save / Export → Export as glTF and permission checks. It lists directly owned/group assets or explicitly shared meshes/images as exportable, and restricts acquired Creator Store/open assets without sharing. This is platform behavior, separate from the purchased pack's license.

Do not infer exact triangles, quads, topology, hard-edge layout, UVs, vertex colours or exact tire sectors from the available boxes/screenshots. Visible polygonal tire outlines and facets are OBSERVED. Helper defaults and modeling recipes are PROPOSED. Even a successful OBJ export can split vertices or lose authoring data; identify it as exported render geometry, not the untouched Blender source topology.

## Reattempting geometry analysis

1. Re-list Studio instances and confirm Car Pack.rbxl. Save the current camera/selection; do not edit the car.
2. Inspect available export options using supported UI/tools. Prefer the documented glTF route when available, with appropriate asset access. Do not enable security settings, bypass asset checks, scrape asset delivery endpoints or interpret a purchased local rbxl as a permission override.
3. If Studio refuses an asset, record its ID and exact message. Work from the current measurements/images. A future directly owned source `.blend` or author-authorized export can close the geometry gap.
4. Import an authorized OBJ/GLB in a separate background Blender process using `blender_audit.py`. Compare overall dimensions/part count against Studio inventory; exclude invisible helper cubes. Keep import axes/scale in the report. OBJ does not retain Studio assembly behavior, Neon, Reflectance or all naming.
5. For further MCP analysis, run `audit()` read-only in OBJECT mode on the imported reference collection in a dedicated file. Record evaluated triangles, components/face normals/UVs where actually measured. Never replace or modify an original car in Studio to obtain these measurements.

## Sources and attribution

1. **Primary local measurements and screenshots:** Car Pack.rbxl, 07–08.11.2026, Studio MCP. Source identifiers and inventory remain local; no source mesh geometry has been copied into the skill.
2. **LihFolk Vault V2**, CC BY 4.0, library kept separately at `C:/Users/bruno/Documents/LihFolk/full/LihFolk Vault V2/LihFolk Vault V2/`. Consulted notes: `06 World Building and Art/Modeling in Blender for Roblox.md`; `06 World Building and Art/Parts Unions and MeshParts.md`; `54 Untextured Stylised Modelling/Faceted Low-Poly - Flat Normals and Facet Size.md`; `54 Untextured Stylised Modelling/Flat Colour vs Gradient Atlas vs Vertex Colour.md`; `55 Modelling Nuance and Readability/Style Bibles for Consistent Models.md`; `08 Animation/02 Rigging and Importing/Exporting FBX vs GLB.md`; `17 Pipelines/Blender Automation with Python.md`. Their guidance supports explicit scale/pivot validation, large readable facets, deliberate colour splits, isolated background builds and export checks. Library prose has not been replicated.
3. **Official Roblox**: [3D Export](https://create.roblox.com/docs/art/modeling/gltf-export), consulted to fill the missing export/permission information. Do not claim the permission check succeeded.
4. **Local installed Blender Python API/MCP** and executed Blender 5.2.1 fixture tests support the supplied tool behavior. `blender-tools-qa.json` contains actual test evidence.

No old Halloween simulator folders, backups or exports were used. The earlier CAR_PACK_STYLE note supplied initial context; current recorded measurements are the evidence for this skill.

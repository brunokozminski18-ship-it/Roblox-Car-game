"""Write independent per-part meshes to a Blender master and Studio sidecar."""
import json
import sys
from pathlib import Path

import bpy
import bmesh
import numpy as np

assets = Path(__file__).resolve().parents[1]/"assets"
name, budget, *extra = sys.argv[sys.argv.index("--")+1:]
fits = json.loads((assets/(name+".json")).read_text())
previous = json.loads((assets/(extra[0] if extra else "authored-parts.json")).read_text())
bpy.ops.wm.read_factory_settings(use_empty=True)
collection = bpy.data.collections.new("D1")
bpy.context.scene.collection.children.link(collection)

for part in previous:
    key = str(part["index"])
    candidate = fits.get(key)
    if candidate:
        vertices = np.asarray(candidate["vertices"])
        faces = candidate["triangles"]
    else:
        vertices = np.asarray(part["vertices"]) + part["centre"]
        faces = part["triangles"]
    center = (vertices.min(0)+vertices.max(0))/2
    dimensions = np.maximum(vertices.max(0)-vertices.min(0), 1e-7)
    mesh = bpy.data.meshes.new("Panel "+key)
    mesh.from_pydata(((vertices-center)/dimensions).tolist(), [], faces)
    obj = bpy.data.objects.new(f"{int(key):02d} D1",mesh)
    collection.objects.link(obj)
    bpy.context.view_layer.objects.active = obj
    if candidate:
        # Normalize before simplification to preserve slim lenses and side trim.
        bm = bmesh.new()
        bm.from_mesh(mesh)
        bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
        for step in range(candidate.get("smooth_steps",0 if candidate.get("analytic") else 3)):
            bmesh.ops.smooth_vert(bm, verts=list(bm.verts), factor=.68,
                                  use_axis_x=True,use_axis_y=True,use_axis_z=True)
        bm.to_mesh(mesh)
        bm.free()
        target = len(mesh.polygons) if candidate.get("analytic") else int(budget) * (3 if key in ("18","19","14") else 1)
        mod = obj.modifiers.new("Planar surface fitting", "DECIMATE")
        mod.ratio = min(1, target/max(1,len(mesh.polygons)))
        bpy.ops.object.modifier_apply(modifier=mod.name)
    mesh = obj.data
    local = np.asarray([list(v.co) for v in mesh.vertices])*dimensions
    center_shift = (local.max(0)+local.min(0))/2
    local -= center_shift
    center += center_shift
    for vertex, co in zip(mesh.vertices,local):
        vertex.co = co
    obj.location = center
    mesh.update()
    mesh.calc_loop_triangles()
    part.update(vertices=local.round(6).tolist(), centre=center.tolist(),
                size=(local.max(0)-local.min(0)).tolist(),
                triangles=[list(t.vertices) for t in mesh.loop_triangles],
                normals=[list(t.normal) for t in mesh.loop_triangles])
    matname = part["color"]+" "+part["material"]
    mat = bpy.data.materials.get(matname) or bpy.data.materials.new(matname)
    srgb = [int(part["color"][i:i+2],16)/255 for i in (1,3,5)]
    mat.diffuse_color = (*[(v/12.92 if v<.04045 else ((v+.055)/1.055)**2.4) for v in srgb],1)
    mesh.materials.append(mat)
    obj["SourcePartIndex"] = int(key)
    obj["RobloxReflectance"] = part["reflectance"]
    obj["RobloxMaterial"] = part["material"]

bpy.context.preferences.filepaths.save_version = 0
bpy.ops.wm.save_as_mainfile(filepath=str(assets/(name+".blend")))
(assets/(name+"-mesh.json")).write_text(json.dumps(previous,separators=(",",":")))
print("Parts",len(previous),"triangles",sum(len(p["triangles"]) for p in previous))

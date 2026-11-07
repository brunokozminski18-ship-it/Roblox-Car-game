"""Audit evaluated meshes without modifying them. Optional import ONLY in background Blender.

blender -b --factory-startup --python-exit-code 1 --python blender_audit.py -- --input car.glb --out audit.json
MCP, current OBJECT-mode scene: result = audit(list(bpy.context.selected_objects))
"""
import argparse
import json
import math
import sys
from pathlib import Path
import bpy
import bmesh
from mathutils import Vector


def audit(objects):
    if bpy.context.mode != 'OBJECT':
        raise RuntimeError('Read-only audit requires OBJECT mode; do not change an artist session automatically')
    deps = bpy.context.evaluated_depsgraph_get()
    rows, all_points = [], []
    for obj in objects:
        if obj.type != 'MESH':
            continue
        evaluated = obj.evaluated_get(deps)
        mesh = evaluated.to_mesh()
        bm = None
        try:
            mesh.calc_loop_triangles()
            points = [evaluated.matrix_world @ v.co for v in mesh.vertices]
            if not points:
                rows.append({'name':obj.name,'empty':True,'triangles':0})
                continue
            all_points.extend(points)
            bm = bmesh.new()
            bm.from_mesh(mesh)
            lo = [min(p[i] for p in points) for i in range(3)]
            hi = [max(p[i] for p in points) for i in range(3)]
            uvs = [loop.uv[:] for loop in mesh.uv_layers.active.data] if mesh.uv_layers.active else []
            tri_areas = [((points[t.vertices[1]]-points[t.vertices[0]]).cross(points[t.vertices[2]]-points[t.vertices[0]])).length*.5 for t in mesh.loop_triangles]
            rows.append({'name':obj.name,'vertices':len(mesh.vertices),'edges':len(mesh.edges),
                         'polygons':len(mesh.polygons),'triangles':len(mesh.loop_triangles),
                         'dimensions_world':[hi[i]-lo[i] for i in range(3)],
                         'origin_world':list(obj.matrix_world.translation),
                         'negative_world_determinant':obj.matrix_world.determinant()<0,
                         'scale':list(obj.scale),'rotation_euler':list(obj.rotation_euler),
                         'material_slots':len(mesh.materials),
                         'materials':[m.name if m else None for m in mesh.materials],
                         'boundary_edges':sum(e.is_boundary for e in bm.edges),
                         'nonmanifold_edges':sum(not e.is_manifold for e in bm.edges),
                         'zero_area_triangles':sum(a<1e-10 for a in tri_areas),
                         'flat_polygons':sum(not p.use_smooth for p in mesh.polygons),
                         'uv_layers':len(mesh.uv_layers),
                         'uv_outside_01':sum(not (0<=u<=1 and 0<=v<=1) for u,v in uvs),
                         'custom_properties':{k:obj[k] for k in obj.keys() if isinstance(obj[k],(str,int,float,bool))}})
        finally:
            if bm:
                bm.free()
            evaluated.to_mesh_clear()
    dimensions = [max(p[i] for p in all_points)-min(p[i] for p in all_points) for i in range(3)] if all_points else [0,0,0]
    return {'blender':bpy.app.version_string,'method':'evaluated vertices, world transforms; export topology may differ from authoring topology',
            'mesh_count':len(rows),'triangles':sum(r['triangles'] for r in rows),
            'dimensions_world_xyz':dimensions,'objects':rows}


def main():
    args = sys.argv[sys.argv.index('--')+1:] if '--' in sys.argv else []
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--input', type=Path)
    parser.add_argument('--out', required=True, type=Path)
    options = parser.parse_args(args)
    if options.input:
        if not bpy.app.background:
            raise RuntimeError('Import in a separate background Blender, preserving the open scene')
        before = set(bpy.data.objects)
        ext = options.input.suffix.lower()
        if ext in ('.glb','.gltf'):
            bpy.ops.import_scene.gltf(filepath=str(options.input.resolve()))
        elif ext == '.obj':
            bpy.ops.wm.obj_import(filepath=str(options.input.resolve()),forward_axis='NEGATIVE_Z',up_axis='Y')
        else:
            raise ValueError('Supported reference files: .obj, .glb, .gltf')
        objects = list(set(bpy.data.objects)-before)
    else:
        objects = list(bpy.context.scene.objects)
    bpy.context.view_layer.update()
    report = audit(sorted(objects,key=lambda o:o.name))
    options.out.parent.mkdir(parents=True,exist_ok=True)
    options.out.write_text(json.dumps(report,indent=2),encoding='utf-8')
    print(f"CAR_AUDIT meshes={report['mesh_count']} triangles={report['triangles']}")


if __name__ == '__main__':
    try:
        main()
    except Exception:
        import traceback
        traceback.print_exc()
        sys.exit(1)

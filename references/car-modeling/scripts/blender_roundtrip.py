"""GLB round-trip validation on explicitly supplied original work, background only."""
import json
import sys
from pathlib import Path
import bpy

sys.path.insert(0, str(Path(__file__).parent))
from blender_audit import audit


def roundtrip(objects, output):
    if not bpy.app.background or bpy.context.mode != 'OBJECT':
        raise RuntimeError('Use an isolated background Blender in OBJECT mode')
    objects = [o for o in objects if o.type == 'MESH']
    if not objects:
        raise ValueError('No meshes in explicitly chosen export set')
    output = Path(output).resolve()
    output.parent.mkdir(parents=True,exist_ok=True)
    before = audit(objects)
    source_objects = set(bpy.data.objects)
    for obj in bpy.context.view_layer.objects:
        obj.select_set(False)
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]
    bpy.ops.export_scene.gltf(filepath=str(output), export_format='GLB', use_selection=True,
                              export_apply=True, export_normals=True, export_materials='EXPORT')
    bpy.ops.import_scene.gltf(filepath=str(output))
    imported = list(set(bpy.data.objects)-source_objects)
    bpy.context.view_layer.update()
    after = audit(sorted(imported,key=lambda o:o.name))
    error = max(abs(a-b) for a,b in zip(before['dimensions_world_xyz'],after['dimensions_world_xyz']))
    checks = {'dimensions_within_0_001_stud':error<=.001,
              'triangles_equal':before['triangles']==after['triangles'],
              'mesh_count_equal':before['mesh_count']==after['mesh_count']}
    report = {'status':'PASS' if all(checks.values()) else 'NEEDS VERIFICATION',
              'checks':checks,'max_dimension_error':error,'before':before,'after':after}
    output.with_suffix('.roundtrip.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
    return report


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--collection',required=True)
    parser.add_argument('--out',required=True,type=Path)
    args = parser.parse_args(sys.argv[sys.argv.index('--')+1:])
    try:
        collection = bpy.data.collections.get(args.collection)
        if not collection:
            raise ValueError('Named collection not found')
        report = roundtrip(list(collection.all_objects),args.out)
        if report['status'] != 'PASS':
            raise RuntimeError('Round-trip changed geometry; inspect report')
        print('CAR_ROUNDTRIP_PASS')
    except Exception:
        import traceback
        traceback.print_exc()
        sys.exit(1)

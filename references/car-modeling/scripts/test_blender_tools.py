"""Behavioural smoke test on synthetic fixtures; run in a fresh background Blender."""
import json
import sys
from pathlib import Path
import bpy
import bmesh

sys.path.insert(0, str(Path(__file__).parent))
import blender_car_tools as car


def main():
    assert bpy.app.background, 'Use a separate background process, preserving the artist session'
    collection = bpy.data.collections.new('QA_SYNTHETIC_ONLY')
    bpy.context.scene.collection.children.link(collection)
    tire = car.tire('TestTire', .75, .32, segments=12, collection=collection)
    bm = bmesh.new()
    bm.from_mesh(tire.data)
    assert all(e.is_manifold for e in bm.edges), 'Tire casing must be closed and manifold'
    assert abs(tire.dimensions.x-.32) < 1e-5
    assert abs(tire.dimensions.z-1.5) < 1e-5
    bm.free()
    panel = car.panel_loft('TestPanel', [(-2, [(0,1), (1,1), (1.2,.5)]), (2, [(0,1.2), (.8,1.1), (1.1,.5)])], collection=collection)
    assert len(panel.data.polygons) == 2
    assert panel.modifiers[0].type == 'MIRROR'
    assert car.srgb_to_linear(.5) > .21 and car.srgb_to_linear(.5) < .22
    mat = car.material('TestGlass', '#6E99CA', role='glass')
    assert mat['studio_transparency'] == 0 and mat['studio_reflectance'] == .5
    rim = car.rim('TestRim', .50, .16, spokes=5, collection=collection)
    assert len(rim.data.polygons) > 5
    import blender_audit
    report = blender_audit.audit([tire, panel, rim])
    assert report['mesh_count'] == 3
    assert report['triangles'] > 0
    assert report['objects'][0]['nonmanifold_edges'] == 0
    assert report['objects'][1]['boundary_edges'] > 0, 'Open panels must be reported, not silently filled'
    output = Path(sys.argv[sys.argv.index('--')+1])
    import blender_roundtrip
    roundtrip = blender_roundtrip.roundtrip([tire, panel, rim], output.with_suffix('.glb'))
    assert roundtrip['status'] == 'PASS'
    output.write_text(json.dumps({'status':'PASS','assertions':14,'report':report,'roundtrip':roundtrip['checks']}, indent=2), encoding='utf-8')
    print('CAR_TOOLS_QA_PASS')


if __name__ == '__main__':
    try:
        main()
    except Exception:
        import traceback
        traceback.print_exc()
        sys.exit(1)

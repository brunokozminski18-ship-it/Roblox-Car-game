"""Preserve the verified positions, face normals, colours and independent wheels."""
import bpy,json,sys
from pathlib import Path
from mathutils import Vector

assets=Path(__file__).resolve().parents[1]/"assets"
variant, folder = sys.argv[sys.argv.index("--")+1:] if "--" in sys.argv else ("contact", "D1 delivery")
dest=assets/folder
dest.mkdir(exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)
collection=bpy.data.collections.new("D1")
bpy.context.scene.collection.children.link(collection)
for p in json.loads((assets/(variant+"-mesh.json")).read_text()):
    name=f"{p['index']:02d} {p['name']}"
    mesh=bpy.data.meshes.new(name)
    faces=[];face_normals=[];seen=set()
    for tri,n in zip(p["triangles"],p["normals"]):
        coords=tuple(tuple(p["vertices"][i]) for i in tri)
        key=tuple(sorted(coords))
        a,b,c=map(Vector,coords)
        if key in seen or (b-a).cross(c-a).length<1e-12:continue
        seen.add(key);faces.append(tri);face_normals.append(n)
    mesh.from_pydata(p["vertices"],[],faces)
    mesh.update()
    obj=bpy.data.objects.new(name,mesh)
    collection.objects.link(obj)
    obj.location=p["centre"]
    obj["SourcePartIndex"]=p["index"]
    obj["RobloxMaterial"]=p["material"]
    obj["RobloxReflectance"]=p["reflectance"]
    color=p["color"]
    mat=bpy.data.materials.get(color) or bpy.data.materials.new(color)
    srgb=[int(color[i:i+2],16)/255 for i in (1,3,5)]
    linear=[x/12.92 if x<=.04045 else ((x+.055)/1.055)**2.4 for x in srgb]
    mat.diffuse_color=(*linear,1)
    mesh.materials.append(mat)
    normals=[]
    for face,n in zip(mesh.polygons,face_normals):
        face.use_smooth=True
        normals.extend([n]*len(face.loop_indices))
    mesh.normals_split_custom_set(normals)
for screen in bpy.data.screens:
    for area in screen.areas:
        if area.type=="VIEW_3D":
            sp=area.spaces.active
            sp.shading.color_type="MATERIAL"
            sp.region_3d.view_location=(0,0,2)
            sp.region_3d.view_rotation=Vector((8,-12,5)).to_track_quat("Z","Y")
            sp.region_3d.view_distance=15
bpy.context.preferences.filepaths.save_version=0
bpy.ops.wm.save_as_mainfile(filepath=str(dest/"D1.blend"))
bpy.ops.export_scene.gltf(filepath=str(dest/"D1.glb"),export_format="GLB")

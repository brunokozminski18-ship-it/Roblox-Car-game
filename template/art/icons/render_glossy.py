"""Glossy 3D shop icons for UI style D (references/ui/D1-D3).

Chunky cartoon objects with a glossy coat, saturated colours, a dark ink
outline (inverted hull) and a three-light rig (warm key, cool rim, soft fill).
One shared camera and light rig for every icon. Output: 512x512 PNG,
transparent background.

Run headless:
  blender -b --factory-startup -P render_glossy.py -- <out_dir> [icon ...]
Icons: gift
"""

import math
import os
import sys

import bpy
from mathutils import Vector

SIZE = 512
INK = (0.03, 0.02, 0.06, 1.0)
OUTLINE = 0.06  # inverted hull thickness (Blender units)

CAM_AZIMUTH = math.radians(-32)
CAM_ELEVATION = math.radians(24)
CAM_DISTANCE = 10.0
CAM_TARGET = Vector((0.0, 0.0, 1.0))
LENS_MM = 85


def hex_rgb(h):
    h = h.lstrip("#")
    srgb = [int(h[i : i + 2], 16) / 255 for i in (0, 2, 4)]
    lin = [c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in srgb]
    return (*lin, 1.0)


def reset():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    engines = {e.identifier for e in bpy.types.RenderSettings.bl_rna.properties["engine"].enum_items}
    scene.render.engine = "BLENDER_EEVEE_NEXT" if "BLENDER_EEVEE_NEXT" in engines else "BLENDER_EEVEE"
    scene.render.resolution_x = SIZE
    scene.render.resolution_y = SIZE
    scene.render.film_transparent = True
    if hasattr(scene, "eevee"):
        scene.eevee.taa_render_samples = 96
    scene.view_settings.view_transform = "Standard"
    scene.view_settings.look = "None"
    world = bpy.data.worlds.new("World")
    world.use_nodes = True
    bg = world.node_tree.nodes["Background"]
    bg.inputs["Color"].default_value = (0.55, 0.6, 0.75, 1)
    bg.inputs["Strength"].default_value = 1.1
    scene.world = world
    return scene


def glossy(name, color):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = hex_rgb(color)
    bsdf.inputs["Roughness"].default_value = 0.35
    for key in ("Coat Weight", "Clearcoat"):
        if key in bsdf.inputs:
            bsdf.inputs[key].default_value = 0.6
    for key in ("Coat Roughness", "Clearcoat Roughness"):
        if key in bsdf.inputs:
            bsdf.inputs[key].default_value = 0.08
    return mat


def ink_material():
    mat = bpy.data.materials.new("Ink")
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial")
    em = nodes.new("ShaderNodeEmission")
    em.inputs["Color"].default_value = INK
    mat.node_tree.links.new(em.outputs[0], out.inputs[0])
    mat.use_backface_culling = True
    return mat


def finish(obj, mat, bevel=0.08, segments=3):
    obj.data.materials.append(mat)
    if bevel > 0:
        mod = obj.modifiers.new("Bevel", "BEVEL")
        mod.width = bevel
        mod.segments = segments
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.shade_smooth()
    # Inverted hull outline: second material on a flipped shell.
    obj.data.materials.append(INK_MAT)
    shell = obj.modifiers.new("Outline", "SOLIDIFY")
    shell.thickness = OUTLINE
    shell.offset = 1.0
    shell.use_flip_normals = True
    shell.material_offset = 1
    return obj


def cube(name, size, loc, mat, bevel=0.08):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = size
    bpy.ops.object.transform_apply(scale=True)
    return finish(obj, mat, bevel)


def torus(name, loc, rot, major, minor, mat):
    bpy.ops.mesh.primitive_torus_add(location=loc, rotation=rot, major_radius=major, minor_radius=minor, major_segments=40, minor_segments=16)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = (1.0, 0.42, 1.25)
    bpy.ops.object.transform_apply(scale=True)
    return finish(obj, mat, bevel=0)


def sphere(name, loc, radius, mat):
    bpy.ops.mesh.primitive_uv_sphere_add(location=loc, radius=radius, segments=32, ring_count=16)
    obj = bpy.context.active_object
    obj.name = name
    return finish(obj, mat, bevel=0)


def build_gift():
    red = glossy("Box", "#FF2438")
    gold = glossy("Ribbon", "#FFC414")
    cube("Box", (1.9, 1.9, 1.55), (0, 0, 0.78), red, 0.1)
    cube("Lid", (2.15, 2.15, 0.5), (0, 0, 1.78), red, 0.1)
    # ribbon bands across box and lid
    cube("BandX", (0.42, 1.98, 1.58), (0, 0, 0.78), gold, 0.05)
    cube("BandY", (1.98, 0.42, 1.58), (0, 0, 0.78), gold, 0.05)
    cube("LidBandX", (0.46, 2.22, 0.54), (0, 0, 1.78), gold, 0.05)
    cube("LidBandY", (2.22, 0.46, 0.54), (0, 0, 1.78), gold, 0.05)
    # bow
    torus("BowL", (-0.5, 0, 2.42), (math.radians(90), math.radians(-38), math.radians(8)), 0.5, 0.2, gold)
    torus("BowR", (0.5, 0, 2.42), (math.radians(90), math.radians(38), math.radians(-8)), 0.5, 0.2, gold)
    sphere("Knot", (0, 0, 2.18), 0.26, gold)


def rig(scene):
    cam_data = bpy.data.cameras.new("Cam")
    cam_data.lens = LENS_MM
    cam = bpy.data.objects.new("Cam", cam_data)
    scene.collection.objects.link(cam)
    pos = CAM_TARGET + Vector((
        CAM_DISTANCE * math.cos(CAM_ELEVATION) * math.sin(CAM_AZIMUTH),
        -CAM_DISTANCE * math.cos(CAM_ELEVATION) * math.cos(CAM_AZIMUTH),
        CAM_DISTANCE * math.sin(CAM_ELEVATION),
    ))
    cam.location = pos
    cam.rotation_euler = (CAM_TARGET - pos).to_track_quat("-Z", "Y").to_euler()
    scene.camera = cam

    def area(name, loc, energy, color, size):
        data = bpy.data.lights.new(name, "AREA")
        data.energy = energy
        data.color = color
        data.size = size
        obj = bpy.data.objects.new(name, data)
        scene.collection.objects.link(obj)
        obj.location = loc
        obj.rotation_euler = (CAM_TARGET - Vector(loc)).to_track_quat("-Z", "Y").to_euler()

    area("Key", (-4, -5, 7), 2200, (1.0, 0.96, 0.9), 3)
    area("Rim", (4, 5, 4), 1600, (0.8, 0.9, 1.0), 2)
    area("Fill", (5, -6, 1.5), 700, (1.0, 1.0, 1.0), 6)
    area("Top", (0, 0, 9), 600, (1.0, 1.0, 1.0), 6)


# Template: additional geometry only; original materials, rig and camera unchanged.
def prism(name, points, depth, mat):
    verts = [(x, y, z) for y in (-depth/2, depth/2) for x,z in points]
    n = len(points)
    faces = [tuple(reversed(range(n))), tuple(range(n,2*n))]
    faces += [(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
    mesh=bpy.data.meshes.new(name); mesh.from_pydata(verts,[],faces); mesh.update()
    obj=bpy.data.objects.new(name,mesh); bpy.context.collection.objects.link(obj)
    bpy.context.view_layer.objects.active=obj; obj.select_set(True)
    bpy.ops.object.mode_set(mode='EDIT'); bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.mesh.normals_make_consistent(inside=False); bpy.ops.object.mode_set(mode='OBJECT')
    return finish(obj,mat,0.07)


def ring(name, loc, radius, tube, mat, rotation=(math.pi/2,0,0)):
    bpy.ops.mesh.primitive_torus_add(location=loc, rotation=rotation, major_radius=radius, minor_radius=tube, major_segments=40, minor_segments=16)
    return finish(bpy.context.object,mat,0)


def build_icon(kind):
    gold=glossy('Gold','#FFBF17'); blue=glossy('Blue','#238FFF')
    purple=glossy('Purple','#B23AFF'); red=glossy('Red','#FF3A55')
    white=glossy('White','#FFF5DC'); dark=glossy('Eyes','#121229')
    green=glossy('Green','#39E883')
    if kind.startswith('pet') or kind=='pets':
        k=int(kind[-1]) if kind[-1].isdigit() else 1
        color=[blue,purple,gold,green,red][k-1]
        sphere('Body',(0,0,1.1),0.9,color)
        for x in (-0.48,0.48):
            if k==2:
                ear=sphere('BunnyEar',(x,0,2.0),0.26,color);ear.scale=(0.8,0.8,2.3)
            elif k==3:
                prism('CatEar',[(x-0.3,1.7),(x+0.3,1.7),(x,2.4)],0.55,color)
            elif k==4:
                sphere('FrogEye',(x,-0.08,1.95),0.35,white)
                sphere('FrogPupil',(x,-0.38,1.97),0.14,dark)
            else:
                sphere('Ear',(x,0,1.95),0.32,color)
            sphere('Paw',(x,-0.4,0.42),0.28,white)
        for x in (-0.32,0.32):
            sphere('Eye',(x,-0.81,1.25),0.14,dark)
            sphere('Shine',(x-0.025,-0.93,1.3),0.045,white)
        if k==5:
            sphere('Snout',(0,-0.85,0.95),0.29,white)
            for x in (-0.11,0.11):sphere('Nostril',(x,-1.1,0.95),0.065,dark)
        else:
            sphere('Nose',(0,-0.92,0.92),0.12,red)
    elif kind.startswith('egg'):
        color=[green,red,purple][int(kind[-1])-1]
        obj=sphere('Egg',(0,0,1.25),1,color); obj.scale=(0.82,0.82,1.25)
        for x,z in [(-0.35,1.5),(0.25,0.9),(0.3,1.95)]: sphere('Spot',(x,-0.73,z),0.17,gold)
    elif kind=='power':
        prism('Bolt',[(-0.2,2.7),(-0.95,1.15),(-0.15,1.15),(-0.45,0),(1.05,1.65),(0.2,1.65),(0.65,2.7)],0.45,gold)
    elif kind=='gem':
        prism('Gem',[(-1,1.75),(-0.55,2.35),(0.55,2.35),(1,1.75),(0,0.25)],0.7,blue)
        prism('Facet',[(-0.5,1.75),(0,2.25),(0.5,1.75),(0,0.4)],0.82,purple)
    elif kind=='cash':
        obj=sphere('Coin',(0,0,1.25),1.1,gold); obj.scale=(1,0.25,1)
        cube('Bar',(0.25,0.2,1.4),(0,-0.34,1.25),white)
    elif kind=='gloves':
        for x in (-0.6,0.6):
            cube('Glove',(0.85,0.9,1.15),(x,0,1.25),red,0.3)
            sphere('Thumb',(x+0.35,-0.22,1),0.28,red)
            cube('Cuff',(0.85,0.9,0.35),(x,0,0.5),gold)
    elif kind=='boots':
        for x in (-0.58,0.58):
            cube('Shaft',(0.8,0.8,1.5),(x,0.2,1.25),blue,0.2)
            cube('Foot',(0.85,1.3,0.6),(x,-0.1,0.55),blue,0.2)
            cube('Sole',(0.9,1.4,0.18),(x,-0.1,0.25),gold)
    elif kind=='belt':
        cube('Belt',(2.4,0.65,0.7),(0,0,1.2),purple,0.2)
        cube('Buckle',(0.9,0.25,1),(0,-0.45,1.2),gold)
        cube('Inset',(0.45,0.15,0.5),(0,-0.62,1.2),blue)
    elif kind=='cape':
        prism('Cape',[(-0.55,2.35),(0.55,2.35),(1,0.25),(0,0.5),(-1,0.25)],0.35,red)
        sphere('Clasp',(0,-0.25,2.15),0.25,gold)
    elif kind=='crown':
        prism('Crown',[(-1,0.5),(1,0.5),(1.15,2.1),(0.5,1.6),(0,2.5),(-0.5,1.6),(-1.15,2.1)],0.9,gold)
        sphere('Jewel',(0,-0.55,1.2),0.25,red)
    elif kind=='halo':
        ring('Halo',(0,0,1.5),0.9,0.17,gold,(math.radians(30),0,0))
        sphere('Glint',(-0.8,-0.3,2.1),0.2,white)
    elif kind=='shop':
        cube('Bag',(1.8,0.9,1.6),(0,0,1),green,0.18)
        torus('Handle',(0,0,1.9),(math.pi/2,0,0),0.55,0.13,gold)
    elif kind=='daily':
        cube('Calendar',(2,0.55,1.9),(0,0,1.2),white)
        cube('Header',(2.05,0.65,0.5),(0,0,2),red)
        for x in (-0.5,0,0.5):
            for z in (0.75,1.3): cube('Day',(0.28,0.15,0.28),(x,-0.35,z),blue)
    elif kind=='settings':
        ring('Cog',(0,0,1.2),0.65,0.23,blue)
        for i in range(8):
            a=i*math.tau/8
            o=cube('Tooth',(0.5,0.55,0.45),(0.78*math.sin(a),0,1.2+0.78*math.cos(a)),blue)
    elif kind=='rebirth':
        ring('Cycle',(0,0,1.25),0.75,0.2,green)
        prism('Arrow',[(0.35,2.35),(1,1.95),(0.35,1.65)],0.65,gold)
    elif kind=='tasks':
        cube('Board',(1.65,0.55,2.1),(0,0,1.25),gold)
        cube('Paper',(1.4,0.15,1.8),(0,-0.36,1.2),white)
        for z in (0.65,1.2,1.75):
            cube('Check',(0.25,0.12,0.25),(-0.4,-0.5,z),green)
            cube('Line',(0.65,0.12,0.12),(0.15,-0.5,z),blue)
    elif kind=='index':
        cube('Book',(1.9,0.65,2.2),(0,0,1.25),purple,0.14)
        cube('Spine',(0.3,0.75,2.25),(-0.8,0,1.25),gold)
        sphere('Seal',(0.2,-0.46,1.3),0.48,gold)


ICONS = {"gift": build_gift}
for _name in "gloves boots belt cape crown halo power cash gem shop rebirth daily pets settings tasks index egg1 egg2 egg3 pet1 pet2 pet3 pet4 pet5".split():
    ICONS[_name] = lambda name=_name: build_icon(name)

if __name__ == "__main__":
    argv = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    out_dir = argv[0] if argv else "."
    names = argv[1:] or list(ICONS)
    os.makedirs(out_dir, exist_ok=True)
    for name in names:
        scene = reset()
        INK_MAT = ink_material()
        ICONS[name]()
        rig(scene)
        scene.render.filepath = os.path.join(out_dir, f"{name}.png")
        bpy.ops.render.render(write_still=True)
        print("rendered", scene.render.filepath)

"""Menu icons for style B (playbook/UI_STYLE.md, section "Ikony menu").

Cartoon 3D objects with ONE shared camera, lens and light rig, rendered to
512x512 PNG with a transparent background.

Run headless:
  blender -b --factory-startup -P render_icons.py -- <out_dir> [icon ...]
"""

import math
import os
import sys

import bpy
from mathutils import Vector

SIZE = 512
SAMPLES = 96

# Shared rig: never change per icon, so the set stays consistent.
CAMERA_LOCATION = (-2.9, -4.6, 2.9)
CAMERA_TARGET = (0.0, 0.0, 0.62)
LENS_MM = 95


# --------------------------------------------------------------------------
# Scene
# --------------------------------------------------------------------------
def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.samples = SAMPLES
    scene.cycles.use_denoising = True
    scene.cycles.device = "CPU"
    scene.render.resolution_x = SIZE
    scene.render.resolution_y = SIZE
    scene.render.film_transparent = True
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"
    scene.view_settings.view_transform = "Standard"  # keeps cartoon colours saturated
    scene.view_settings.look = "None"

    world = bpy.data.worlds.new("World")
    world.use_nodes = True
    world.node_tree.nodes["Background"].inputs["Color"].default_value = (0.55, 0.6, 0.7, 1)
    world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.35
    scene.world = world
    return scene


def add_camera(scene):
    cam_data = bpy.data.cameras.new("Camera")
    cam_data.lens = LENS_MM
    cam = bpy.data.objects.new("Camera", cam_data)
    scene.collection.objects.link(cam)
    cam.location = CAMERA_LOCATION
    direction = Vector(CAMERA_TARGET) - Vector(CAMERA_LOCATION)
    cam.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()
    scene.camera = cam


def add_area_light(scene, name, location, energy, size, color=(1, 1, 1)):
    data = bpy.data.lights.new(name, "AREA")
    data.energy = energy
    data.size = size
    data.color = color
    light = bpy.data.objects.new(name, data)
    scene.collection.objects.link(light)
    light.location = location
    direction = Vector(CAMERA_TARGET) - Vector(location)
    light.rotation_euler = direction.to_track_quat("-Z", "Y").to_euler()


def add_lights(scene):
    add_area_light(scene, "Key", (-3.5, -3.0, 5.0), 650, 4.0)  # top-left
    add_area_light(scene, "Fill", (4.0, -3.0, 1.5), 180, 4.0, (0.85, 0.9, 1.0))
    add_area_light(scene, "Rim", (1.5, 4.5, 3.5), 700, 3.0)


# --------------------------------------------------------------------------
# Building blocks
# --------------------------------------------------------------------------
def material(name, hex_color, roughness=0.32, coat=0.4):
    h = hex_color.lstrip("#")
    rgb = [int(h[i : i + 2], 16) / 255 for i in (0, 2, 4)]
    rgb = [c**2.2 for c in rgb]  # sRGB -> linear
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*rgb, 1)
    bsdf.inputs["Roughness"].default_value = roughness
    if "Coat Weight" in bsdf.inputs:
        bsdf.inputs["Coat Weight"].default_value = coat
        bsdf.inputs["Coat Roughness"].default_value = 0.15
    return mat


def finish(obj, mat, bevel=0.06, segments=4, smooth=True):
    obj.data.materials.append(mat)
    if bevel > 0:
        mod = obj.modifiers.new("Bevel", "BEVEL")
        mod.width = bevel
        mod.segments = segments
        mod.limit_method = "ANGLE"
    if smooth:
        bpy.ops.object.select_all(action="DESELECT")
        obj.select_set(True)
        bpy.context.view_layer.objects.active = obj
        bpy.ops.object.shade_smooth()
        if hasattr(obj.data, "use_auto_smooth"):
            obj.data.use_auto_smooth = True
    return obj


def box(name, size, location, mat, bevel=0.06, rotation=(0, 0, 0)):
    bpy.ops.mesh.primitive_cube_add(size=1, location=location, rotation=rotation)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = size
    bpy.ops.object.transform_apply(scale=True)
    return finish(obj, mat, bevel)


def torus(name, major, minor, location, rotation, mat, scale=(1, 1, 1)):
    bpy.ops.mesh.primitive_torus_add(
        major_radius=major, minor_radius=minor, major_segments=48, minor_segments=16,
        location=location, rotation=rotation,
    )
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = scale
    return finish(obj, mat, bevel=0)


def cylinder(name, radius, depth, location, rotation, mat, bevel=0.03):
    bpy.ops.mesh.primitive_cylinder_add(vertices=48, radius=radius, depth=depth, location=location, rotation=rotation)
    obj = bpy.context.active_object
    obj.name = name
    return finish(obj, mat, bevel)


def sphere(name, radius, location, mat, scale=(1, 1, 1)):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=32, ring_count=16, radius=radius, location=location)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = scale
    return finish(obj, mat, bevel=0)


# --------------------------------------------------------------------------
# Icons (each about 1.4 units tall, standing on z = 0)
# --------------------------------------------------------------------------
def icon_shop():
    """Paper shopping bag with rope handles and a gold coin badge."""
    bag = material("Bag", "#FF8A1F")
    cuff = material("Cuff", "#E5640F")
    rope = material("Rope", "#3A2A20", roughness=0.6, coat=0)
    gold = material("Gold", "#FFC93C", roughness=0.25, coat=0.6)

    box("Body", (1.0, 0.6, 1.05), (0, 0, 0.525), bag, bevel=0.07)
    box("Cuff", (1.04, 0.64, 0.16), (0, 0, 1.0), cuff, bevel=0.05)
    for y in (-0.18, 0.18):
        torus("Handle", 0.27, 0.045, (0, y, 1.08), (math.radians(90), 0, 0), rope)
    cylinder("Coin", 0.27, 0.07, (0, -0.33, 0.5), (math.radians(90), 0, 0), gold)
    face = material("CoinFace", "#FFE07A", roughness=0.25, coat=0.6)
    cylinder("CoinFace", 0.19, 0.03, (0, -0.375, 0.5), (math.radians(90), 0, 0), face, bevel=0.01)


def icon_daily():
    """Gift box with a gold ribbon and bow."""
    body_mat = material("Box", "#E8409B")
    lid_mat = material("Lid", "#F25AAE")
    ribbon = material("Ribbon", "#FFC93C", roughness=0.25, coat=0.6)

    box("Body", (0.95, 0.95, 0.75), (0, 0, 0.375), body_mat, bevel=0.06)
    box("Lid", (1.05, 1.05, 0.24), (0, 0, 0.82), lid_mat, bevel=0.06)
    # Body ribbons stop under the lid; lid ribbons wrap the lid, so no gaps show.
    box("RibbonX", (0.98, 0.2, 0.72), (0, 0, 0.36), ribbon, bevel=0.02)
    box("RibbonY", (0.2, 0.98, 0.72), (0, 0, 0.36), ribbon, bevel=0.02)
    box("LidRibbonX", (1.08, 0.2, 0.26), (0, 0, 0.82), ribbon, bevel=0.03)
    box("LidRibbonY", (0.2, 1.08, 0.26), (0, 0, 0.82), ribbon, bevel=0.03)
    for side in (-1, 1):
        torus(
            "Bow",
            0.2,
            0.06,
            (side * 0.2, 0, 1.08),
            (math.radians(90), math.radians(side * -35), 0),
            ribbon,
            scale=(1.0, 1.0, 0.75),
        )
    sphere("Knot", 0.1, (0, 0, 1.0), ribbon, scale=(1.1, 1.1, 0.9))


ICONS = {
    "shop": icon_shop,
    "daily": icon_daily,
}


def main():
    argv = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    out_dir = os.path.abspath(argv[0] if argv else "out")
    names = argv[1:] or list(ICONS)
    os.makedirs(out_dir, exist_ok=True)
    for name in names:
        scene = reset_scene()
        add_camera(scene)
        add_lights(scene)
        ICONS[name]()
        scene.render.filepath = os.path.join(out_dir, f"{name}.png")
        bpy.ops.render.render(write_still=True)
        print(f"[icons] wrote {scene.render.filepath}")


main()

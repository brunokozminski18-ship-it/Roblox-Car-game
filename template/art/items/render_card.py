"""Card art for items (playbook/UI_STYLE.md: realistic item renders, style B).

Any .glb -> two 512x512 PNGs with a transparent background:
  <name>.png             the item, lit the same way as every other card
  <name>_silhouette.png  the same shape in solid black (Index "???" cards)
One camera, one light rig, one framing rule for all items: the model is
centred and scaled so its bounding sphere fills the same share of the frame.

  blender -b --factory-startup -P render_card.py -- <out_dir> <name>=<file.glb> [...]
"""

import math
import os
import sys

import bpy
import numpy as np
from mathutils import Vector

SIZE = 512
SAMPLES = 64
FILL = 0.82  # share of the frame the bounding sphere's diameter fills

# Shared rig: never change per item.
CAM_AZIMUTH = math.radians(-35)
CAM_ELEVATION = math.radians(22)
LENS_MM = 85


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
    for transform in ("AgX", "Filmic"):
        try:
            scene.view_settings.view_transform = transform
            break
        except TypeError:
            continue
    scene.view_settings.look = "None"
    world = bpy.data.worlds.new("World")
    world.use_nodes = True
    bg = world.node_tree.nodes["Background"]
    bg.inputs["Color"].default_value = (0.75, 0.8, 0.9, 1)
    bg.inputs["Strength"].default_value = 0.6
    scene.world = world
    return scene


def import_model(path):
    bpy.ops.import_scene.gltf(filepath=path)
    meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    if not meshes:
        raise RuntimeError(f"no mesh in {path}")
    # World-space bounding box of all meshes.
    lo = Vector((math.inf,) * 3)
    hi = Vector((-math.inf,) * 3)
    for ob in meshes:
        for corner in ob.bound_box:
            w = ob.matrix_world @ Vector(corner)
            lo = Vector((min(lo[i], w[i]) for i in range(3)))
            hi = Vector((max(hi[i], w[i]) for i in range(3)))
    center = (lo + hi) / 2
    radius = (hi - lo).length / 2
    # Move every root so the model is centred on the origin.
    for ob in bpy.context.scene.objects:
        if ob.parent is None:
            ob.location -= center
    return radius


def add_camera(scene, radius):
    cam_data = bpy.data.cameras.new("Camera")
    cam_data.lens = LENS_MM
    cam = bpy.data.objects.new("Camera", cam_data)
    scene.collection.objects.link(cam)
    # Distance so the bounding sphere fills FILL of the frame.
    half_fov = math.atan(cam_data.sensor_width / 2 / LENS_MM)
    distance = radius / (FILL * math.tan(half_fov))
    offset = Vector((
        math.sin(CAM_AZIMUTH) * math.cos(CAM_ELEVATION),
        -math.cos(CAM_AZIMUTH) * math.cos(CAM_ELEVATION),
        math.sin(CAM_ELEVATION),
    ))
    cam.location = offset * distance
    cam.rotation_euler = (-cam.location).to_track_quat("-Z", "Y").to_euler()
    scene.camera = cam
    return distance


def add_light(scene, name, direction, energy, size, distance):
    data = bpy.data.lights.new(name, "AREA")
    data.energy = energy * distance * distance
    data.size = size * distance
    light = bpy.data.objects.new(name, data)
    scene.collection.objects.link(light)
    light.location = Vector(direction).normalized() * distance
    light.rotation_euler = (-light.location).to_track_quat("-Z", "Y").to_euler()


def render(scene, out_path):
    scene.render.filepath = out_path
    bpy.ops.render.render(write_still=True)


def silhouette(src, dst):
    """Solid black copy of the render, same alpha (exact same outline)."""
    img = bpy.data.images.load(src)
    px = np.array(img.pixels[:], dtype=np.float32).reshape(-1, 4)
    px[:, 0:3] = 0.0
    img.pixels[:] = px.ravel().tolist()
    img.filepath_raw = dst
    img.file_format = "PNG"
    img.save()


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    out_dir = os.path.abspath(argv[0])
    os.makedirs(out_dir, exist_ok=True)
    for pair in argv[1:]:
        name, path = pair.split("=", 1)
        scene = reset_scene()
        radius = import_model(path)
        distance = add_camera(scene, radius)
        # Key from top-left-front, soft fill from the right, rim from behind.
        add_light(scene, "Key", (-1.0, -1.2, 1.4), 6.0, 0.8, distance)
        add_light(scene, "Fill", (1.4, -0.8, 0.3), 2.0, 1.0, distance)
        add_light(scene, "Rim", (0.4, 1.5, 1.0), 5.0, 0.6, distance)
        color = os.path.join(out_dir, f"{name}.png")
        render(scene, color)
        silhouette(color, os.path.join(out_dir, f"{name}_silhouette.png"))
        print(f"[card] {name} <- {os.path.basename(path)}")


main()

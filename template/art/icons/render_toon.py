"""Toon menu icons for style B (playbook/UI_STYLE.md, "Ikony menu").

Cel-shaded cartoon objects: hard 2-3 shadow steps, dark outline (Freestyle),
chunky bevelled blocks, one shared 3/4 camera and light rig for every icon.
Output: 512x512 PNG, transparent background.

Run headless:
  blender -b --factory-startup -P render_toon.py -- <out_dir> <variant A|B|C> [icon ...]

Variants (style only; geometry is the same):
  A  "flat cel"   3 hard steps, no highlight, thick ink outline
  B  "cel + spec" 2 hard steps, one hard specular spot, medium outline
  C  "soft cel"   3 steps with eased edges, rim band, thin outline
"""

import math
import os
import sys

import bpy
from mathutils import Vector

SIZE = 512

# Shared rig: never change per icon.
CAM_AZIMUTH = math.radians(-38)  # from the front-left
CAM_ELEVATION = math.radians(28)
CAM_DISTANCE = 9.5
CAM_TARGET = Vector((0.0, 0.0, 0.62))
LENS_MM = 120
SUN_DIRECTION = Vector((0.6, 0.75, -1.0))  # direction the light travels: it comes from top-left-front

INK = (0.07, 0.05, 0.09)

VARIANTS = {
    "A": {"steps": 3, "ease": False, "spec": 0.0, "rim": 0.0, "line": 6.0},
    "B": {"steps": 2, "ease": False, "spec": 0.55, "rim": 0.0, "line": 4.5},
    "C": {"steps": 3, "ease": True, "spec": 0.0, "rim": 0.35, "line": 3.0},
}
STYLE = VARIANTS["A"]


# --------------------------------------------------------------------------
# Scene
# --------------------------------------------------------------------------
def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    for engine in ("BLENDER_EEVEE_NEXT", "BLENDER_EEVEE"):
        try:
            scene.render.engine = engine
            break
        except TypeError:
            continue
    scene.render.resolution_x = SIZE
    scene.render.resolution_y = SIZE
    scene.render.film_transparent = True
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"
    scene.view_settings.view_transform = "Standard"
    scene.view_settings.look = "None"
    if hasattr(scene, "eevee"):
        eevee = scene.eevee
        if hasattr(eevee, "taa_render_samples"):
            eevee.taa_render_samples = 32

    world = bpy.data.worlds.new("World")
    world.use_nodes = True
    world.node_tree.nodes["Background"].inputs["Color"].default_value = (1, 1, 1, 1)
    world.node_tree.nodes["Background"].inputs["Strength"].default_value = 0.25
    scene.world = world

    # Ink outline.
    scene.render.use_freestyle = True
    scene.render.line_thickness_mode = "ABSOLUTE"
    scene.render.line_thickness = 1.0  # the line style below sets the real width
    layer = scene.view_layers[0]
    layer.use_freestyle = True
    settings = layer.freestyle_settings
    lineset = settings.linesets[0] if settings.linesets else settings.linesets.new("Ink")
    lineset.select_by_visibility = True
    lineset.select_by_edge_types = True
    lineset.select_silhouette = True
    lineset.select_border = True
    lineset.select_crease = True
    lineset.select_external_contour = True
    settings.crease_angle = math.radians(120)
    style = lineset.linestyle
    if style is None:
        style = bpy.data.linestyles.new("Ink")
        lineset.linestyle = style
    style.color = INK
    style.thickness = STYLE["line"]
    return scene


def add_camera(scene):
    cam_data = bpy.data.cameras.new("Camera")
    cam_data.lens = LENS_MM
    cam = bpy.data.objects.new("Camera", cam_data)
    scene.collection.objects.link(cam)
    offset = Vector((
        math.sin(CAM_AZIMUTH) * math.cos(CAM_ELEVATION),
        -math.cos(CAM_AZIMUTH) * math.cos(CAM_ELEVATION),
        math.sin(CAM_ELEVATION),
    ))
    cam.location = CAM_TARGET + offset * CAM_DISTANCE
    cam.rotation_euler = (CAM_TARGET - cam.location).to_track_quat("-Z", "Y").to_euler()
    scene.camera = cam


def add_sun(scene):
    data = bpy.data.lights.new("Sun", "SUN")
    data.energy = 3.0
    data.angle = 0.0  # hard shadow edge
    sun = bpy.data.objects.new("Sun", data)
    scene.collection.objects.link(sun)
    sun.rotation_euler = SUN_DIRECTION.to_track_quat("-Z", "Y").to_euler()


# --------------------------------------------------------------------------
# Toon material: light -> hard ramp -> emission (exact colours on screen)
# --------------------------------------------------------------------------
def hex_linear(hex_color, k=1.0):
    h = hex_color.lstrip("#")
    rgb = [min(1.0, int(h[i : i + 2], 16) / 255 * k) for i in (0, 2, 4)]
    return [c**2.2 for c in rgb]


def toon(name, hex_color):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    nt = mat.node_tree
    nt.nodes.clear()
    out = nt.nodes.new("ShaderNodeOutputMaterial")
    diffuse = nt.nodes.new("ShaderNodeBsdfDiffuse")
    to_rgb = nt.nodes.new("ShaderNodeShaderToRGB")
    ramp = nt.nodes.new("ShaderNodeValToRGB")
    emit = nt.nodes.new("ShaderNodeEmission")
    nt.links.new(diffuse.outputs[0], to_rgb.inputs[0])
    nt.links.new(to_rgb.outputs["Color"], ramp.inputs["Fac"])

    shade = hex_linear(hex_color, 0.55)
    shade = [shade[0] * 0.85, shade[1] * 0.8, min(1.0, shade[2] * 1.15)]  # cool, slightly purple shadow
    mid = hex_linear(hex_color, 1.0)
    lit = hex_linear(hex_color, 1.22)
    cr = ramp.color_ramp
    cr.interpolation = "EASE" if STYLE["ease"] else "CONSTANT"
    cr.elements[0].position = 0.0
    cr.elements[0].color = (*shade, 1)
    cr.elements[1].position = 0.35
    cr.elements[1].color = (*mid, 1)
    if STYLE["steps"] >= 3:
        e = cr.elements.new(0.72)
        e.color = (*lit, 1)
    color = ramp.outputs["Color"]

    if STYLE["spec"] > 0:
        gloss = nt.nodes.new("ShaderNodeBsdfGlossy")
        gloss.inputs["Roughness"].default_value = 0.18
        g_rgb = nt.nodes.new("ShaderNodeShaderToRGB")
        g_ramp = nt.nodes.new("ShaderNodeValToRGB")
        g_ramp.color_ramp.interpolation = "CONSTANT"
        g_ramp.color_ramp.elements[0].color = (0, 0, 0, 1)
        g_ramp.color_ramp.elements[1].position = 0.75
        g_ramp.color_ramp.elements[1].color = (1, 1, 1, 1)
        add = nt.nodes.new("ShaderNodeMix")
        add.data_type = "RGBA"
        add.blend_type = "ADD"
        add.inputs["Factor"].default_value = STYLE["spec"]
        nt.links.new(gloss.outputs[0], g_rgb.inputs[0])
        nt.links.new(g_rgb.outputs["Color"], g_ramp.inputs["Fac"])
        nt.links.new(color, add.inputs[6])
        nt.links.new(g_ramp.outputs["Color"], add.inputs[7])
        color = add.outputs[2]

    if STYLE["rim"] > 0:
        weight = nt.nodes.new("ShaderNodeLayerWeight")
        weight.inputs["Blend"].default_value = 0.2
        r_ramp = nt.nodes.new("ShaderNodeValToRGB")
        r_ramp.color_ramp.interpolation = "CONSTANT"
        r_ramp.color_ramp.elements[0].color = (0, 0, 0, 1)
        r_ramp.color_ramp.elements[1].position = 0.7
        r_ramp.color_ramp.elements[1].color = (*lit, 1)
        mix = nt.nodes.new("ShaderNodeMix")
        mix.data_type = "RGBA"
        mix.blend_type = "SCREEN"
        mix.inputs["Factor"].default_value = STYLE["rim"]
        nt.links.new(weight.outputs["Facing"], r_ramp.inputs["Fac"])
        nt.links.new(color, mix.inputs[6])
        nt.links.new(r_ramp.outputs["Color"], mix.inputs[7])
        color = mix.outputs[2]

    nt.links.new(color, emit.inputs["Color"])
    nt.links.new(emit.outputs[0], out.inputs["Surface"])
    return mat


# --------------------------------------------------------------------------
# Building blocks (chunky: 1-2 bevel segments, flat shading)
# --------------------------------------------------------------------------
def finish(obj, mat, bevel=0.05, segments=2):
    obj.data.materials.append(mat)
    if bevel > 0:
        mod = obj.modifiers.new("Bevel", "BEVEL")
        mod.width = bevel
        mod.segments = segments
        mod.limit_method = "ANGLE"
        mod.harden_normals = True
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.shade_smooth()
    return obj


def box(size, location, mat, rotation=(0, 0, 0), bevel=0.05):
    bpy.ops.mesh.primitive_cube_add(size=1, location=location, rotation=rotation)
    obj = bpy.context.active_object
    obj.scale = size
    bpy.ops.object.transform_apply(scale=True)
    return finish(obj, mat, bevel)


def cylinder(radius, depth, location, mat, rotation=(0, 0, 0), vertices=32, bevel=0.03):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=location, rotation=rotation)
    return finish(bpy.context.active_object, mat, bevel)


def cone(r1, r2, depth, location, mat, rotation=(0, 0, 0), vertices=32, bevel=0.03):
    bpy.ops.mesh.primitive_cone_add(vertices=vertices, radius1=r1, radius2=r2, depth=depth, location=location, rotation=rotation)
    return finish(bpy.context.active_object, mat, bevel)


def torus(major, minor, location, mat, rotation=(0, 0, 0), scale=(1, 1, 1)):
    bpy.ops.mesh.primitive_torus_add(major_radius=major, minor_radius=minor, major_segments=40, minor_segments=12, location=location, rotation=rotation)
    obj = bpy.context.active_object
    obj.scale = scale
    return finish(obj, mat, bevel=0)


def sphere(radius, location, mat, scale=(1, 1, 1)):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=12, radius=radius, location=location)
    obj = bpy.context.active_object
    obj.scale = scale
    return finish(obj, mat, bevel=0)


def text(body, size, location, rotation, mat, depth=0.06):
    bpy.ops.object.text_add(location=location, rotation=rotation)
    obj = bpy.context.active_object
    obj.data.body = body
    obj.data.size = size
    obj.data.extrude = depth
    obj.data.bevel_depth = 0.01
    obj.data.align_x = "CENTER"
    obj.data.align_y = "CENTER"
    obj.data.materials.append(mat)
    return obj


def bent_strip(size, location, mat, angle, rotation=(0, 0, 0)):
    """A thin strip curled with a bend deform (receipt paper, scroll)."""
    bpy.ops.mesh.primitive_cube_add(size=1, location=location, rotation=rotation)
    obj = bpy.context.active_object
    obj.scale = size
    bpy.ops.object.transform_apply(scale=True)
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.subdivide(number_cuts=12)
    bpy.ops.object.mode_set(mode="OBJECT")
    bend = obj.modifiers.new("Bend", "SIMPLE_DEFORM")
    bend.deform_method = "BEND"
    bend.deform_axis = "X"
    bend.angle = angle
    return finish(obj, mat, bevel=0)


# --------------------------------------------------------------------------
# Icons (about 1.4 units tall, standing on z = 0). Colours: playbook UI_STYLE.
# --------------------------------------------------------------------------
def icon_shop():
    """Chunky cash register; detail: a long receipt curling out of the top."""
    from mathutils import Euler

    body = toon("Body", "#FF8A1F")
    dark = toon("Dark", "#3A3F4A")
    key = toon("Key", "#FFF1D6")
    paper = toon("Paper", "#FFFFFF")
    screen = toon("Screen", "#7CF0B0")

    box((1.4, 1.0, 0.5), (0, 0, 0.25), body, bevel=0.07)  # base
    box((1.22, 0.1, 0.22), (0, -0.5, 0.22), dark, bevel=0.04)  # drawer
    box((0.3, 0.08, 0.07), (0, -0.57, 0.22), key, bevel=0.02)  # drawer handle
    tilt = Euler((math.radians(-25), 0, 0))
    deck_center = Vector((0, -0.12, 0.62))
    box((1.3, 0.62, 0.26), tuple(deck_center), body, rotation=tuple(tilt), bevel=0.06)  # sloped key deck
    for i in range(3):
        for j in range(2):
            local = Vector((-0.4 + i * 0.4, -0.13 + j * 0.27, 0.15))
            local.rotate(tilt)
            box((0.3, 0.22, 0.09), tuple(deck_center + local), key, rotation=tuple(tilt), bevel=0.03)
    box((1.3, 0.42, 0.8), (0, 0.3, 0.75), body, bevel=0.07)  # back body
    box((0.7, 0.16, 0.4), (0.28, 0.3, 1.38), body, bevel=0.06)  # display head
    box((0.52, 0.04, 0.26), (0.28, 0.21, 1.38), screen, bevel=0.02)
    text("$", 0.3, (0.28, 0.18, 1.37), (math.radians(90), 0, 0), dark, depth=0.02)
    box((0.12, 0.12, 0.2), (0.28, 0.3, 1.12), dark, bevel=0.02)  # neck
    box((0.42, 0.14, 0.05), (-0.42, 0.3, 1.16), dark, bevel=0.015)  # paper slot
    # Receipt: short segments along an arc rising from the slot and curling forward.
    pos, ang = Vector((-0.42, 0.3, 1.18)), math.radians(0)
    for _ in range(7):
        step = Vector((0, -math.sin(ang), math.cos(ang))) * 0.13
        box((0.32, 0.03, 0.14), tuple(pos + step / 2), paper, rotation=(ang, 0, 0), bevel=0.008)
        pos, ang = pos + step, ang + math.radians(26)


def icon_inventory():
    """Treasure chest; detail: the padlock hangs open."""
    wood = toon("Wood", "#2EC4B6")
    band = toon("Band", "#2B3140")
    gold = toon("Gold", "#FFC93C")
    box((1.3, 0.85, 0.7), (0, 0, 0.35), wood, bevel=0.07)
    cylinder(0.43, 1.3, (0, 0, 0.72), wood, rotation=(0, math.radians(90), 0), vertices=24, bevel=0.05)
    for x in (-0.48, 0.48):
        box((0.14, 0.9, 0.74), (x, 0, 0.36), band, bevel=0.03)
        cylinder(0.455, 0.15, (x, 0, 0.72), band, rotation=(0, math.radians(90), 0), vertices=24)
    box((0.3, 0.1, 0.3), (0, -0.46, 0.62), gold, bevel=0.04)  # lock plate
    box((0.26, 0.14, 0.24), (0.06, -0.55, 0.36), gold, rotation=(0, math.radians(18), 0), bevel=0.04)  # open lock body
    torus(0.1, 0.035, (-0.03, -0.55, 0.53), gold, rotation=(math.radians(90), math.radians(30), 0), scale=(1, 1.4, 1))


def icon_index():
    """Magnifying glass; detail: a big question mark inside the lens."""
    rim = toon("Rim", "#3D8BFF")
    handle = toon("Handle", "#2B3140")
    glass = toon("Glass", "#DDF2FF")
    mark = toon("Mark", "#FFC93C")
    tilt = (math.radians(90), 0, math.radians(-20))
    torus(0.52, 0.11, (0, 0, 0.95), rim, rotation=tilt)
    cylinder(0.5, 0.06, (0, 0, 0.95), glass, rotation=tilt, bevel=0.0)
    cylinder(0.11, 0.7, (0.42, 0.15, 0.25), handle, rotation=(0, math.radians(-38), math.radians(-20)), bevel=0.04)
    cylinder(0.15, 0.14, (0.25, 0.09, 0.47), rim, rotation=(0, math.radians(-38), math.radians(-20)))
    text("?", 0.75, (0.0, -0.08, 0.92), tilt, mark, depth=0.07)


def icon_tasks():
    """Target board; detail: an arrow stuck in the bullseye."""
    from mathutils import Euler

    rings = ["#7BD33A", "#FFFFFF", "#7BD33A", "#FFFFFF", "#E5484A"]
    face_rot = (math.radians(75), 0, math.radians(-10))
    for i, hexc in enumerate(rings):
        r = 0.72 - i * 0.14
        cylinder(r, 0.14 + i * 0.02, (0, 0.0 - i * 0.012, 0.85), toon(f"Ring{i}", hexc), rotation=face_rot, vertices=40, bevel=0.02)
    shaft = toon("Shaft", "#FFC93C")
    fletch = toon("Fletch", "#E5484A")
    # Arrow stuck in the bullseye, sticking out up and to the right.
    face_normal = Vector((0, 0, 1))
    face_normal.rotate(Euler(face_rot))
    bullseye = Vector((0, -0.06, 0.85)) + face_normal * 0.02
    out = (face_normal * 0.7 + Vector((0.85, 0.45, 0.55))).normalized()  # across the view, readable
    rot = out.to_track_quat("Z", "Y").to_euler()
    cylinder(0.06, 0.95, tuple(bullseye + out * 0.47), shaft, rotation=tuple(rot), vertices=12, bevel=0)
    for k in (0, 1):
        fin = rot.copy()
        fin.rotate_axis("Z", math.radians(90 * k))
        box((0.3, 0.04, 0.26), tuple(bullseye + out * 0.86), fletch, rotation=tuple(fin), bevel=0.01)


def icon_daily():
    """Alarm clock; detail: twin bells and a hammer between them."""
    body = toon("Body", "#FF4F9A")
    face = toon("Face", "#FFF7EC")
    metal = toon("Metal", "#FFC93C")
    hand = toon("Hand", "#2B3140")
    rot = (math.radians(90), 0, 0)
    cylinder(0.55, 0.4, (0, 0, 0.7), body, rotation=rot, vertices=40, bevel=0.06)
    cylinder(0.43, 0.06, (0, -0.2, 0.7), face, rotation=rot, vertices=40, bevel=0.01)
    box((0.06, 0.03, 0.3), (0, -0.24, 0.82), hand, bevel=0.01)
    box((0.22, 0.03, 0.06), (0.1, -0.24, 0.7), hand, bevel=0.01)
    for side in (-1, 1):
        sphere(0.24, (side * 0.38, 0.0, 1.22), metal, scale=(1, 1, 0.75))
        box((0.08, 0.08, 0.32), (side * 0.32, 0.0, 0.18), hand, rotation=(0, math.radians(side * 25), 0))
    box((0.06, 0.06, 0.24), (0, 0, 1.3), hand)
    sphere(0.07, (0, 0, 1.44), metal)


def icon_rebirth():
    """Hourglass; detail: the sand falls upward (rebirth = start again)."""
    frame = toon("Frame", "#9B5CFF")
    glass = toon("Glass", "#E8F4FF")
    sand = toon("Sand", "#FFC93C")
    cylinder(0.55, 0.14, (0, 0, 0.07), frame, vertices=6, bevel=0.03)
    cylinder(0.55, 0.14, (0, 0, 1.33), frame, vertices=6, bevel=0.03)
    for a in range(3):
        ang = math.radians(a * 120 + 30)
        cylinder(0.05, 1.2, (math.cos(ang) * 0.45, math.sin(ang) * 0.45, 0.7), frame, vertices=10)
    cone(0.38, 0.06, 0.55, (0, 0, 0.42), glass, rotation=(math.radians(180), 0, 0), vertices=24)
    cone(0.38, 0.06, 0.55, (0, 0, 0.98), glass, vertices=24)
    cone(0.3, 0.05, 0.3, (0, 0, 1.08), sand, vertices=24)  # sand gathers at the TOP
    cylinder(0.03, 0.5, (0, 0, 0.7), sand, vertices=8, bevel=0)


def icon_settings():
    """Two meshed gears; detail: the small gear is a different colour."""
    big = toon("Big", "#9AA7B8")
    small = toon("Small", "#FFC93C")
    hub = toon("Hub", "#2B3140")

    def gear(radius, teeth, location, mat, rotation):
        g = cylinder(radius, 0.26, location, mat, rotation=rotation, vertices=32, bevel=0.03)
        for t in range(teeth):
            a = 2 * math.pi * t / teeth
            bpy.ops.mesh.primitive_cube_add(size=1)
            tooth = bpy.context.active_object
            tooth.scale = (radius * 0.32, radius * 0.3, 0.26)
            bpy.ops.object.transform_apply(scale=True)
            tooth.location = (math.cos(a) * radius * 1.08, math.sin(a) * radius * 1.08, 0)
            tooth.rotation_euler = (0, 0, a)
            tooth.parent = g
            finish(tooth, mat, bevel=0.025)
        return g

    rot = (math.radians(70), 0, math.radians(-25))
    gear(0.5, 10, (-0.12, 0.05, 0.78), big, rot)
    cylinder(0.17, 0.32, (-0.12, 0.05, 0.78), hub, rotation=rot)
    gear(0.28, 8, (0.55, -0.25, 0.32), small, rot)
    cylinder(0.1, 0.32, (0.55, -0.25, 0.32), hub, rotation=rot)


def icon_coin():
    """Thick coin standing at an angle; detail: a raised diamond and rim."""
    gold = toon("Gold", "#FFC93C")
    face = toon("Face", "#FFE07A")
    rot = (math.radians(75), 0, math.radians(-15))
    cylinder(0.62, 0.22, (0, 0, 0.7), gold, rotation=rot, vertices=40, bevel=0.05)
    cylinder(0.46, 0.26, (0, 0, 0.7), face, rotation=rot, vertices=40, bevel=0.03)
    box((0.3, 0.3, 0.3), (0, -0.14, 0.72), gold, rotation=(math.radians(75), math.radians(45), math.radians(-15)), bevel=0.04)


def icon_gem():
    """Cut gem; detail: a flat table on top and faceted crown."""
    gem = toon("Gem", "#3DD6FF")
    top = toon("Top", "#9AF0FF")
    cone(0.6, 0.38, 0.32, (0, 0, 0.96), gem, vertices=8, bevel=0.0)
    cone(0.6, 0.02, 0.8, (0, 0, 0.4), gem, rotation=(math.radians(180), 0, 0), vertices=8, bevel=0.0)
    cylinder(0.38, 0.02, (0, 0, 1.12), top, vertices=8, bevel=0.0)


ICONS = {
    "shop": icon_shop,
    "inventory": icon_inventory,
    "index": icon_index,
    "tasks": icon_tasks,
    "daily": icon_daily,
    "rebirth": icon_rebirth,
    "settings": icon_settings,
    "coin": icon_coin,
    "gem": icon_gem,
}


def main():
    global STYLE
    argv = sys.argv[sys.argv.index("--") + 1 :] if "--" in sys.argv else []
    out_dir = os.path.abspath(argv[0] if argv else "out")
    variant = argv[1] if len(argv) > 1 else "A"
    STYLE = VARIANTS[variant]
    names = argv[2:] or list(ICONS)
    os.makedirs(out_dir, exist_ok=True)
    for name in names:
        scene = reset_scene()
        add_camera(scene)
        add_sun(scene)
        ICONS[name]()
        scene.render.filepath = os.path.join(out_dir, f"{name}.png")
        bpy.ops.render.render(write_still=True)
        print(f"[icons] wrote {scene.render.filepath} ({scene.render.engine}, variant {variant})")


main()

"""Original geometry helpers. Defaults are proposals, never measured source topology.

Coordinate convention: X width, Y length, Z up; front=-Y; 1 unit=1 stud.
No scene resets, imports, saves, selection changes or destructive operations.
"""
import math
import bpy
import bmesh


def srgb_to_linear(c):
    return c/12.92 if c <= .04045 else ((c+.055)/1.055)**2.4


def material(name, hex_color, role='paint'):
    rgb = [srgb_to_linear(int(hex_color[i:i+2], 16)/255) for i in (1,3,5)]
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*rgb, 1)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = (*rgb, 1)
    bsdf.inputs['Roughness'].default_value = .5
    # Reflectance in Roblox is NOT Blender metallic/roughness. Preserve it as metadata.
    mat['studio_color_srgb'] = hex_color
    mat['studio_material'] = 'Neon' if role in ('headlight','taillight') else 'Plastic'
    mat['studio_transparency'] = 0
    mat['studio_reflectance'] = .5 if role == 'glass' else 0
    if role in ('headlight','taillight'):
        bsdf.inputs['Emission Color'].default_value = (*rgb, 1)
        bsdf.inputs['Emission Strength'].default_value = 1
    return mat


def mesh_object(name, vertices, faces, collection, mat=None):
    if collection is None:
        raise ValueError('Explicit destination collection required')
    mesh = bpy.data.meshes.new(name+'_Mesh')
    mesh.from_pydata(vertices, [], faces)
    mesh.update()
    bm = bmesh.new()
    bm.from_mesh(mesh)
    bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
    bm.to_mesh(mesh)
    bm.free()
    obj = bpy.data.objects.new(name, mesh)
    collection.objects.link(obj)
    if mat:
        mesh.materials.append(mat)
    for face in mesh.polygons:
        face.use_smooth = False
    bpy.context.view_layer.update()
    return obj


def panel_loft(name, stations, *, collection, mat=None, mirror=True):
    """Loft an explicitly designed half-panel, NOT a complete car generator.

    stations: ordered (y, [(half_width_x, height_z), ...]); equal profile lengths.
    Open boundaries are intentional: trim wheel openings before solidifying.
    Use separate surfaces for bonnet, fender/door shoulder, cabin and bumper.
    """
    if len(stations) < 2 or len(stations[0][1]) < 2:
        raise ValueError('At least 2 stations and 2 profile points required')
    n = len(stations[0][1])
    if any(len(profile) != n for _,profile in stations):
        raise ValueError('Profiles need identical point count and semantic ordering')
    if any(b[0] <= a[0] for a,b in zip(stations, stations[1:])):
        raise ValueError('Stations must advance along +Y, front to rear')
    if any(x < 0 for _,profile in stations for x,z in profile):
        raise ValueError('Author the positive-X half, mirror across X=0')
    vertices = [(x,y,z) for y,profile in stations for x,z in profile]
    faces = [(i*n+j,(i+1)*n+j,(i+1)*n+j+1,i*n+j+1)
             for i in range(len(stations)-1) for j in range(n-1)]
    obj = mesh_object(name, vertices, faces, collection, mat)
    if mirror:
        mod = obj.modifiers.new('Symmetry_X', 'MIRROR')
        mod.use_clip = True
        mod.use_mirror_merge = True
        mod.merge_threshold = .0001
    return obj


def lathe_x(name, profile, *, segments, collection, mat=None):
    """Closed polygon cross-section (axial X, radius), rotated about the wheel X axis."""
    if segments < 6 or len(profile) < 3 or any(r <= 0 for x,r in profile):
        raise ValueError('Use >=6 sectors and a positive closed profile with >=3 points')
    vertices = [(x,r*math.sin(2*math.pi*i/segments),r*math.cos(2*math.pi*i/segments))
                for x,r in profile for i in range(segments)]
    faces = []
    for j in range(len(profile)):
        k = (j+1)%len(profile)
        for i in range(segments):
            q = (i+1)%segments
            faces.append((j*segments+i,j*segments+q,k*segments+q,k*segments+i))
    return mesh_object(name, vertices, faces, collection, mat)


def tire(name, radius, width, *, segments=12, collection, mat=None):
    """Faceted casing with broad tread and chamfered shoulders; no noisy tread texture.

    12 sectors, .68 inner radius and .90 shoulder are starting proposals.
    The original polygon count/profile is UNMEASURED.
    """
    if radius <= 0 or width <= 0:
        raise ValueError('Radius and width must be positive')
    profile = [(-width*.5,radius*.68),(-width*.5,radius*.90),(-width*.38,radius),
               (width*.38,radius),(width*.5,radius*.90),(width*.5,radius*.68)]
    obj = lathe_x(name, profile, segments=segments, collection=collection, mat=mat)
    obj['role'] = 'tire'
    obj['source_topology'] = 'original proposal; not reconstructed source mesh'
    return obj


def rim(name, radius, depth, *, spokes=5, collection, mat=None):
    """Original broad, slightly swept solid spokes. Tune against the reference image."""
    if radius <= 0 or depth <= 0 or spokes < 3:
        raise ValueError('Positive dimensions and >=3 spokes required')
    vertices, faces = [], []
    # Separate solid spoke islands deliberately avoid a thin wire-spoke look.
    for i in range(spokes):
        a = 2*math.pi*i/spokes
        shape = [(radius*.18,a-.35),(radius*.82,a-.20),
                 (radius*.98,a+.08),(radius*.25,a+.28)]
        start = len(vertices)
        for x in (-depth/2,depth/2):
            vertices.extend((x,r*math.sin(t),r*math.cos(t)) for r,t in shape)
        faces.extend([tuple(start+j for j in (3,2,1,0)),tuple(start+j for j in (4,5,6,7))])
        faces.extend((start+j,start+(j+1)%4,start+(j+1)%4+4,start+j+4) for j in range(4))
    # A simple twelve-sided solid hub, pivot exactly on the axle.
    start = len(vertices)
    for x in (-depth*.6,depth*.6):
        vertices.extend((x,radius*.25*math.sin(2*math.pi*i/12),radius*.25*math.cos(2*math.pi*i/12)) for i in range(12))
    faces.extend([tuple(start+i for i in reversed(range(12))),tuple(start+12+i for i in range(12))])
    faces.extend((start+i,start+(i+1)%12,start+(i+1)%12+12,start+i+12) for i in range(12))
    obj = mesh_object(name, vertices, faces, collection, mat)
    obj['role'] = 'rim'
    return obj

"""Independent D1 reconstruction from measured boxes and multi-view observations.

No source mesh data is loaded. One new geometry group per observed source MeshPart.
Blender X width, Y length (front negative), Z vertical; numeric units=Studio studs.
Run: blender -b --factory-startup --python-exit-code 1 --python build_d1.py
"""
import json
import math
from pathlib import Path
import bpy
import bmesh
from mathutils import Vector
from mathutils.geometry import tessellate_polygon

BASE=Path(__file__).resolve().parents[1]
SOURCE=json.loads((BASE/'source-parts.json').read_text(encoding='utf-8'))
ORIGIN=(-60.1920051574707,31.513320922851564)
G={}


def add(k,v,f):
    geom=G.setdefault(k,[[],[]]);offset=len(geom[0])
    geom[0].extend(v);geom[1].extend(tuple(offset+i for i in face)for face in f)


def poly(k,points):
    add(k,points,tessellate_polygon([points]))


def panel_with_hole(k,outline,hole):
    # Blender's tessellator supports separate outer and inner contours.
    inner=list(reversed(hole))
    add(k,outline+inner,tessellate_polygon([outline,inner]))


def grid(k,rows):
    n=len(rows[0])
    add(k,[p for row in rows for p in row],[(i*n+j,(i+1)*n+j,(i+1)*n+j+1,i*n+j+1)
        for i in range(len(rows)-1)for j in range(n-1)])


def mirror_poly(k,points):
    for s in(-1,1):poly(k,[(s*x,y,z)for x,y,z in points])


def solid(k,points,vector):
    n=len(points);d=Vector(vector)
    v=points+[tuple(Vector(p)+d)for p in points]
    add(k,v,[tuple(reversed(range(n))),tuple(range(n,2*n))]+[(i,(i+1)%n,(i+1)%n+n,i+n)for i in range(n)])


def tube(k,points,radius=.03,n=6):
    pts=list(map(Vector,points));rows=[]
    for i,p in enumerate(pts):
        t=(pts[min(i+1,len(pts)-1)]-pts[max(i-1,0)]).normalized()
        a=t.cross(Vector((0,0,1)))
        if a.length<.01:a=t.cross(Vector((0,1,0)))
        a.normalize();b=t.cross(a).normalized()
        rows.append([tuple(p+radius*(math.cos(math.tau*j/n)*a+math.sin(math.tau*j/n)*b))for j in range(n)])
    grid(k,[row+[row[0]]for row in rows])
    poly(k,list(reversed(rows[0])));poly(k,rows[-1])


def lerp(keys,y):
    if y<=keys[0][0]:return keys[0][1]
    for (a,v),(b,w)in zip(keys,keys[1:]):
        if y<=b:return v+(w-v)*(y-a)/(b-a)
    return keys[-1][1]


def side_width(y):
    return lerp([(-4.95,1.7),(-4.0,2.03),(-2.7,2.13),(-1.5,1.97),(.2,1.88),(1.7,2.00),(3.1,2.13),(4.95,1.80)],y)


def shoulder(y):
    return lerp([(-4.95,1.95),(-3.8,2.4),(-2.7,2.64),(-1.6,2.72),(.8,2.80),(2.4,2.76),(3.4,2.64),(4.95,2.44)],y)


def lamp_outline():
    # Independently traced silhouette in the calibrated frontal Studio capture.
    pixels=[(483,435),(487,422),(493,419),(502,422),(557,486),(550,481),
            (516,456),(503,451),(497,452),(492,472),(494,477),(487,466)]
    f=650/(2*math.tan(math.radians(35/2)))
    uy,uz=.9805806757,.1961161351;dy,dz=-uz,uy
    result=[]
    for px,py in pixels:
        length=-3.50-.95*(px-483)/(557-483)
        zdiff=length+12.00820923
        q=(325-py)/f
        height=4.8+(q*dz-uz)*zdiff/(uy-q*dy)
        depth=dy*(height-4.8)+dz*zdiff
        x=-(px-703)*depth/f
        result.append((x,length,height))
    # Constrain this image-derived shape to the measured lamp group's box.
    p=next(p for p in SOURCE['parts']if p['index']==10)
    lo,hi=source_bounds(p)
    rawlo=[min(v[i]for v in result)for i in range(3)]
    rawhi=[max(v[i]for v in result)for i in range(3)]
    bounds=[(1.15,hi[0]),(lo[1],hi[1]),(lo[2],hi[2])]
    return [tuple(a+(v[i]-rawlo[i])/(rawhi[i]-rawlo[i])*(b-a)for i,(a,b)in enumerate(bounds))for v in result]


def wheels():
    # The observed radial box ratio cos(18 degrees) motivates this original ten-sided profile.
    for k in(6,7,8,9):
        rows=[]
        for x,r in[(-.33,.55),(-.33,.89),(-.23,1.0),(.23,1.0),(.33,.89),(.33,.55)]:
            rows.append([(x,r*math.cos(math.tau*i/10),r*math.sin(math.tau*i/10))for i in range(10)])
        v=[p for row in rows for p in row]
        add(k,v,[(j*10+i,j*10+(i+1)%10,((j+1)%6)*10+(i+1)%10,((j+1)%6)*10+i)for j in range(6)for i in range(10)])
    for k in(1,2,3,4):
        # Broad original turbine spokes over an inset disk; ten large sectors.
        facing=1 if k in(1,4)else -1
        n=10
        back=[(-facing*.10,math.cos(i*math.tau/n),math.sin(i*math.tau/n))for i in range(n)]
        front=[(-facing*.075,math.cos(i*math.tau/n),math.sin(i*math.tau/n))for i in range(n)]
        add(k,back+front,[tuple(reversed(range(n))),tuple(range(n,2*n))]+[(i,(i+1)%n,(i+1)%n+n,i+n)for i in range(n)])
        for i in range(n):
            a=i*math.tau/n
            shape=[(.29,a-.10),(.96,a-.03),(.96,a+.21),(.37,a+.32)]
            pts=[(facing*x,r*math.cos(t),r*math.sin(t))for (r,t),x in zip(shape,(.015,.14,-.02,.055))]
            add(k,pts,[(0,1,2),(0,2,3)])
        hub=[(facing*.15,.30*math.cos(i*math.tau/n),.30*math.sin(i*math.tau/n))for i in range(n)]
        solid(k,hub,(-facing*.04,0,0))


def body():
    # Four fender surfaces with true cut-out lower boundaries, not black painted wheels.
    for side in(-1,1):
        for centre,rad,lo,hi,zcentre in[(-2.693,.76,-4.20,-1.92,1.742),(3.106,.79,1.80,4.95,1.775)]:
            ys={lo,hi,centre-rad-.025,centre+rad+.025}
            ys.update(centre+rad*math.cos(i*math.pi/5)for i in range(6))
            rows=[]
            for y in sorted(y for y in ys if lo<=y<=hi):
                d=y-centre
                low=1.21
                if abs(d)<=rad+.00001:low=zcentre+math.sqrt(max(0,rad*rad-d*d))*.951
                top=shoulder(y)
                w=side_width(y)
                rows.append([(side*(w-.025),y,low),(side*w,y,low+(top-low)*.67),(side*(w-.075),y,top)])
            grid(18,rows)
        # Opening perimeter: an angled scoop with its surrounding painted frame.
        inner=[(1.54,2.49),(-1.924,2.12),(-1.54,1.74),(-.98,1.48),(.80,1.44),(1.26,1.68)]
        outer=[(1.95,2.78),(-1.92,2.65),(-1.92,1.21),(-.98,1.21),(.95,1.21),(2.25,1.21)]
        inn=[(side*(side_width(y)-.06),y,z)for y,z in inner]
        out=[(side*side_width(y),y,z)for y,z in outer]
        add(18,out+inn,[(i,(i+1)%6,(i+1)%6+6,i+6)for i in range(6)])
        # Black recess is behind the painted mouth, not coplanar with it.
        poly(15,[(side*(side_width(y)-.12),y,z)for y,z in inner])
        # Solid shoulder return connects the glazing to the side aperture frame.
        grid(18,[[(side*1.55,-2.35,2.76),(side*2.08,-2.35,2.65)],
                 [(side*1.50,-1.25,2.74),(side*1.95,-1.25,2.70)],
                 [(side*1.48,.15,2.75),(side*1.88,.15,2.79)],
                 [(side*1.44,1.35,2.84),(side*1.98,1.35,2.78)],
                 [(side*1.67,2.0,2.84),(side*2.05,2.0,2.77)]])
    # Continuous broad bonnet planes. Feature surfaces are fitted to this skin below.
    for side in(-1,1):
        outline=[(0,-4.95,1.88),(.80,-4.90,1.90),(1.10,-4.52,1.96),
                 (1.16,-4.24,2.05),(1.40,-3.80,2.23),(1.86,-3.50,2.32),
                 (2.10,-3.30,2.49),(1.74,-2.67,2.61),(0,-2.85,2.62)]
        poly(18,[(side*x,y,z)for x,y,z in outline])
        # Thin painted perimeter gives the lamp its characteristic hooked return.
        lamp=[(1.86,-3.50,2.32),(1.87,-3.92,2.16),(1.68,-4.45,1.845),
              (1.69,-4.10,2.02),(1.15,-4.24,1.94),(1.42,-3.80,2.23)]
        c=sum((Vector(v)for v in lamp),Vector())/len(lamp)
        a=[(side*x,y,z)for x,y,z in lamp]
        b=[(side*p.x,p.y,p.z)for p in[c+(Vector(v)-c)*1.09 for v in lamp]]
        add(18,a+b,[(i,(i+1)%6,(i+1)%6+6,i+6)for i in range(6)])
    # Cockpit roof and orange rails; screen surfaces are open apertures rather than overlays.
    grid(18,[[(-1.05,-.67,3.29),(0,-.67,3.38),(1.05,-.67,3.29)],
             [(-1.14,-.30,3.35),(0,-.30,3.42),(1.14,-.30,3.35)],
             [(-.98,.65,3.30),(0,.65,3.38),(.98,.65,3.30)],
             [(-.79,1.35,3.08),(0,1.35,3.15),(.79,1.35,3.08)]])
    # Engine shoulders flare out to the rear wheel arches.
    for side in(-1,1):
        rows=[]
        for y,inner,h,outer,oz in[(-.60,.32,3.38,1.13,3.31),(.7,.39,3.29,1.25,3.15),(1.4,.90,3.10,1.84,2.92),(2.6,.77,2.92,2.12,2.81),(3.8,.26,2.70,2.07,2.66),(4.20,.24,2.63,1.82,2.51)]:
            rows.append([(side*inner,y,h),(side*(inner+outer)*.56,y,(h+oz)*.5),(side*outer,y,oz)])
        grid(18,rows)
    # Rear orange corner blades, visible around the open rear diffuser.
    for side in(-1,1):
        poly(18,[(side*1.83,3.85,2.65),(side*2.1,4.25,2.40),(side*1.94,4.93,2.21),
                 (side*1.88,4.94,1.24),(side*1.72,4.76,1.25),(side*1.82,4.55,1.75)])
        # Painted inward return beside the rear opening.
        grid(18,[[(side*1.75,4.45,1.28),(side*1.57,4.60,1.30)],
                 [(side*1.45,4.36,1.77),(side*1.29,4.55,1.78)],
                 [(side*1.60,4.12,2.18),(side*1.44,4.28,2.18)]])


def windows_and_mirrors():
    rows=[]
    for y,z,w,curve,sag in[(-2.89,2.67,1.12,.10,.015),(-2.52,2.80,1.50,.18,.035),
                           (-1.80,3.08,1.42,.18,.095),(-.94,3.29,1.19,.16,.12),(-.66,3.32,1.02,.12,.10)]:
        rows.append([(t*w,y+curve*t*t,z-sag*t*t)for t in(-1,-.55,0,.55,1)])
    grid(19,rows)
    perimeter=rows[0]+[r[-1]for r in rows[1:]]+list(reversed(rows[-1][:-1]))+[r[0]for r in reversed(rows[1:-1])]
    centre=Vector((0,-1.7,2.98))
    outer=[tuple(centre+(Vector(p)-centre)*1.055+Vector((0,0,-.015)))for p in perimeter]
    n=len(perimeter);add(18,perimeter+outer,[(i,(i+1)%n,(i+1)%n+n,i+n)for i in range(n)])
    for side in(-1,1):
        profile=[(-1.65,2.74),(-.70,3.24),(.50,3.25),(1.38,2.94),(.98,2.80),(-1.15,2.77)]
        pts=[(side*(1.53-(z-2.7)*.60),y,z)for y,z in profile]
        poly(19,pts)
        c=sum((Vector(p)for p in pts),Vector())/len(pts)
        outer=[tuple(c+(Vector(p)-c)*1.15)for p in pts]
        add(18,pts+outer,[(i,(i+1)%6,(i+1)%6+6,i+6)for i in range(6)])
        # Connect the windshield, A-pillar, side window and cowl into one continuous skin.
        poly(18,[(side*x,y,z)for x,y,z in[(1.12,-2.79,2.655),(1.50,-2.34,2.765),
                 (1.42,-1.62,2.985),(1.19,-.78,3.17),(1.02,-.54,3.22),
                 (1.21,-.70,3.24),(1.51,-1.65,2.74),(1.55,-2.10,2.70)]])
        poly(18,[(side*x,y,z)for x,y,z in[(0,-2.85,2.62),(1.74,-2.85,2.61),
                 (1.55,-2.10,2.70),(1.50,-2.34,2.765),(1.12,-2.79,2.655)]])
        poly(18,[(side*x,y,z)for x,y,z in[(1.51,-1.65,2.74),(1.49,-1.15,2.77),
                 (1.47,.98,2.80),(1.39,1.38,2.94),(1.84,1.40,2.92),
                 (1.88,.15,2.79),(1.95,-1.25,2.70)]])
        # Independent faceted mirror housing and small planar reflective face.
        outline=[(-.14,-.09),(-.12,.08),(.10,.14),(.28,.08),(.31,-.08),(.12,-.14)]
        points=[(side*(1.86+dx),-1.18,2.72+dz)for dx,dz in outline]
        solid(20,points,(0,-.12,0))
        poly(17,[(side*(1.87+dx*.84),-1.171,2.72+dz*.80)for dx,dz in outline])


def front_details():
    # Pair of bonnet openings cut into the same slope as the hood.
    mirror_poly(12,[(.15,-3.57,2.39),(.90,-3.58,2.37),(.67,-4.10,2.05),(.39,-4.25,1.92),(.18,-4.25,1.94)])
    # McLaren P1-like boomerang light, defined by its outer and inner bend.
    mirror_poly(10,lamp_outline())
    mirror_poly(11,[(1.71,-3.60,2.11),(1.65,-4.02,1.94),(1.20,-4.30,1.61),
                   (.95,-4.32,1.30),(1.45,-4.12,1.30)])
    # Front black cheeks fold below the orange central nose instead of a flat grille sticker.
    mirror_poly(13,[(1.59,-3.64,2.00),(1.51,-4.04,1.93),(.97,-4.64,1.67),
                   (.72,-4.95,1.30),(1.20,-4.83,1.29)])
    # Central dark intake aperture, recessed into the two supporting cheeks.
    poly(16,[(-.81,-4.96,1.29),(-.76,-4.88,1.55),(-.65,-4.79,1.61),
             (.65,-4.79,1.61),(.76,-4.88,1.55),(.81,-4.96,1.29)])
    # Thin U-shaped splitter with a broad angular lip.
    outer=[(-2.20,-3.36),(-2.20,-4.05),(-1.60,-4.65),(-.8,-4.97),(0,-5.016),(.8,-4.97),(1.60,-4.65),(2.20,-4.05),(2.20,-3.36)]
    inner=[(-2.02,-3.39),(-2.0,-3.98),(-1.50,-4.49),(-.78,-4.68),(0,-4.73),(.78,-4.68),(1.50,-4.49),(2.0,-3.98),(2.02,-3.39)]
    for i in range(len(outer)-1):
        pts=[(*outer[i],1.214),(*outer[i+1],1.214),(*inner[i+1],1.214),(*inner[i],1.214)]
        solid(21,pts,(0,0,.089))


def engine_cover():
    rows=[]
    for y,w,z in[(-.68,.33,3.44),(.35,.33,3.37),(.95,.46,3.23),(1.35,.91,3.12),(2.9,.70,2.91),(3.42,.37,2.76),(3.77,.23,2.68)]:
        rows.append([(-w,y,z-.025),(0,y,z),(w,y,z-.025)])
    grid(14,rows)


def rear_details():
    # Rear black openings connect the lamp recesses and lower central negative space.
    poly(24,[(-2.01,4.17,2.54),(-1.73,4.34,2.62),(-.9,4.38,2.26),(0,4.39,2.29),
             (.9,4.38,2.26),(1.73,4.34,2.62),(2.01,4.17,2.54),
             (1.54,4.36,1.31),(.72,4.23,1.54),(0,4.26,1.51),(-.72,4.23,1.54),(-1.54,4.36,1.31)])
    for side in(-1,1):
        # Broad red outline, leaving the inner region dark.
        outer=[(.42,2.23),(1.25,2.61),(1.75,2.52),(1.827,2.35),(1.55,2.01)]
        inner=[(.44,2.19),(1.27,2.54),(1.70,2.45),(1.75,2.34),(1.52,2.07)]
        depths=[4.65,4.55,4.20,3.744,4.696]
        a=[(side*x,y,z)for(x,z),y in zip(outer,depths)]
        b=[(side*x,y+.008,z)for(x,z),y in zip(inner,depths)]
        add(26,a+b,[(i,i+1,i+6,i+5)for i in range(4)])
    # Upper bowed crossbar with thicker middle, surrounding the central exhaust.
    grid(23,[[(-1.73,4.05,2.12),(-.85,4.30,1.98),(0,4.36,1.96),(.85,4.30,1.98),(1.73,4.05,2.12)],
             [(-1.73,4.20,1.92),(-.85,4.52,1.90),(0,4.53,1.90),(.85,4.52,1.90),(1.73,4.20,1.92)]])
    # Lower diffuser: exaggerated faceted U and centre step observed in the original.
    path=[(-2.14,3.78,1.22),(-1.72,4.40,1.20),(-1.31,4.67,1.23),(-.98,4.48,1.80),
          (-.50,4.42,1.75),(0,4.60,1.62),(.50,4.42,1.75),(.98,4.48,1.80),
          (1.31,4.67,1.23),(1.72,4.40,1.20),(2.14,3.78,1.22)]
    rows=[path,[(x,y-.18,z+.10)for x,y,z in path]];grid(22,rows)
    # Central exhaust surround and central support piece are distinct source groups.
    poly(25,[(-.386,4.19,2.08),(-.27,4.29,2.47),(.27,4.29,2.47),(.386,4.19,2.08)])
    for k,ro,ri in[(28,.23,.18),(27,.18,0)]:
        rows=[]
        for y,r in[(4.555,ro),(4.69,ro),(4.695,ri if ri else ro*.94)]:
            rows.append([(r*math.cos(math.tau*i/8),y,2.225+r*.68*math.sin(math.tau*i/8))for i in range(8)])
        v=[p for row in rows for p in row]
        add(k,v,[(j*8+i,j*8+(i+1)%8,(j+1)*8+(i+1)%8,(j+1)*8+i)for j in range(2)for i in range(8)])
        if not ri:poly(k,rows[-1])
    # Two separate supports in one mesh; broad bent aerofoil in another.
    for x in(-.63,.63):
        tube(29,[(x,4.07,2.44),(x,4.13,2.73),(x,4.26,2.92)],.105,6)
    rows=[]
    for y,z,width in[(3.98,3.02,1.36),(4.12,3.07,1.33),(4.65,3.16,1.25)]:
        rows.append([(-width,y,z+.08),(-.76,y,z-.02),(0,y,z-.03),(.76,y,z-.02),(width,y,z+.08)])
    grid(30,rows)
    # Rounded blade front/downward return lends actual volume in side view.
    grid(30,[rows[0],[(x,y+.04,z-.13)for x,y,z in rows[0]]])


def source_bounds(part):
    cf,s=part['cf'],part['size']
    pts=[]
    for a in(-.5,.5):
        for b in(-.5,.5):
            for c in(-.5,.5):
                v=(a*s[0],b*s[1],c*s[2])
                w=[cf[i]+sum(cf[3+i*3+j]*v[j]for j in range(3))for i in range(3)]
                pts.append((w[0]-ORIGIN[0],w[2]-ORIGIN[1],w[1]))
    lo=[min(v[i]for v in pts)for i in range(3)];hi=[max(v[i]for v in pts)for i in range(3)]
    return lo,hi


def make():
    if not bpy.app.background:raise RuntimeError('Isolated background Blender required')
    bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
    wheels();body();windows_and_mirrors();front_details();engine_cover();rear_details()
    out=[];collection=bpy.data.collections.new('D1_REBUILT');bpy.context.scene.collection.children.link(collection)
    for p in SOURCE['parts']:
        k=p['index']
        if p['class']!='MeshPart':continue
        verts,faces=G[k]
        lo=[min(v[i]for v in verts)for i in range(3)];hi=[max(v[i]for v in verts)for i in range(3)]
        # A flat authored patch receives minimal thickness only where an inspected box has depth.
        flat=[i for i in range(3)if hi[i]-lo[i]<1e-7]
        for axis in flat:
            original=list(verts);n=len(verts)
            verts=original+[tuple(x+(.01 if i==axis else 0)for i,x in enumerate(v))for v in original]
            faces=faces+[tuple(i+n for i in reversed(f))for f in faces]
            hi[axis]+=.01
        target_lo,target_hi=source_bounds(p)
        v=[tuple(target_lo[i]+(a[i]-lo[i])/(hi[i]-lo[i])*(target_hi[i]-target_lo[i])for i in range(3))for a in verts]
        if k==12:
            # The screenshot-derived outline is known more precisely than hidden source depth.
            # Seat lamps/vent colour fields on the designed bonnet rather than leaving intersections.
            corrected=[]
            for x,y,z in v:
                base=lerp([(-4.95,1.88),(-4.25,2.10),(-3.57,2.40),(-2.85,2.62)],y)
                w=lerp([(-4.95,1.40),(-4.25,1.98),(-3.57,2.10),(-2.85,1.74)],y)
                height=base+.10*(abs(x)/w)**2+.024
                corrected.append((x,y,height))
            v=corrected
            target_lo=[min(a[i]for a in v)for i in range(3)];target_hi=[max(a[i]for a in v)for i in range(3)]
        centre=[(a+b)*.5 for a,b in zip(target_lo,target_hi)]
        mesh=bpy.data.meshes.new(f'{k:02d}_AuthoredMesh');mesh.from_pydata(v,[],faces);mesh.update()
        bm=bmesh.new();bm.from_mesh(mesh);bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(mesh);bm.free()
        mesh.calc_loop_triangles()
        triangles=[list(t.vertices)for t in mesh.loop_triangles]
        normals=[list(mesh.polygons[t.polygon_index].normal)for t in mesh.loop_triangles]
        obj=bpy.data.objects.new(f'{k:02d}_Rebuilt',mesh);collection.objects.link(obj)
        col=p['color'];rgb=[int(col[i:i+2],16)/255 for i in(1,3,5)]
        mat=bpy.data.materials.new(f'{k:02d}_Colour');mat.diffuse_color=(*rgb,1);mesh.materials.append(mat)
        for f in mesh.polygons:f.use_smooth=False
        out.append({'index':k,'name':p['name'],'color':col,'material':p['material'],'reflectance':p['reflectance'],
                    'centre':centre,'size':[target_hi[i]-target_lo[i]for i in range(3)],
                    'vertices':[[round(a[i]-centre[i],6)for i in range(3)]for a in v],
                    'triangles':triangles,'normals':[[round(x,6)for x in n]for n in normals]})
    assets=BASE/'assets';assets.mkdir(exist_ok=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(assets/'D1-independent-rebuild.blend'))
    (assets/'authored-parts.json').write_text(json.dumps(out,separators=(',',':')),encoding='utf-8')
    print('D1_OWN_GEOMETRY',json.dumps({'meshparts':len(out),'triangles':sum(len(p['triangles'])for p in out),'indices':[p['index']for p in out]}))


if __name__=='__main__':
    try:make()
    except Exception:
        import traceback;traceback.print_exc();raise SystemExit(1)

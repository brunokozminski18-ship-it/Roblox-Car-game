"""Seat visible colour panels using reference photos and authored support geometry.

Run in background Blender. A contact correction requires a reference-coloured
pixel and a nearby authored occluder. No changes are made to other regions.
"""
import json
import sys
from pathlib import Path
import numpy as np
from mathutils import Vector
from mathutils.bvhtree import BVHTree

assets=Path(__file__).resolve().parents[1]/"assets"
args=sys.argv[sys.argv.index("--")+1:] if "--" in sys.argv else []
source, target, *only = args or ["selected","contact"]
parts=json.loads((assets/(source+"-mesh.json")).read_text())
parts_by_id={p["index"]:p for p in parts}


def world(p):
    return (np.array(p["vertices"])+p["centre"])[:,[0,2,1]]


def tree(p):
    return BVHTree.FromPolygons(world(p).tolist(),p["triangles"],all_triangles=True)


refs=np.load(assets/"trim-masks.npz")
support={k:tree(parts_by_id[k]) for k in (18,9,11,24,22,23)}
stats={}
for idx,views,blockers in [(10,[0,1],(18,11)),(12,[0,1,4],(18,)),(26,[3,5,6,7],(18,24,22,23))]:
    if only and str(idx) not in only:continue
    p=parts_by_id[idx];xyz=world(p)
    original=xyz.copy()
    for step in range(3):
        changes=np.zeros_like(xyz)
        weights=np.zeros(len(xyz))
        for j in views:
            eye,forward,right,up=refs["camera"+str(j)]
            mask=refs[f"mask{idx}_{j}"]
            h,w=mask.shape
            f=h/2/np.tan(np.deg2rad(17.5))
            delta=xyz-eye
            z=delta@forward
            px=np.rint(w/2+f*(delta@right)/z).astype(int)
            py=np.rint(h/2-f*(delta@up)/z).astype(int)
            seen=mask[np.clip(py,0,h-1),np.clip(px,0,w-1)]
            for i in np.where(seen)[0]:
                ray=Vector(delta[i]);distance=ray.length;ray.normalize()
                correction=0
                for k in blockers:
                    hit,_,_,depth=support[k].ray_cast(Vector(eye),ray)
                    if hit is not None and -.002<distance-depth<.095:
                        correction=max(correction,distance-depth+.005)
                if correction:
                    changes[i]-=np.array(ray)*correction
                    weights[i]+=1
        keep=weights>0
        xyz[keep]+=changes[keep]/weights[keep,None]
        displacement=xyz-original;size=np.linalg.norm(displacement,axis=1)
        xyz=original+displacement*np.minimum(1,.065/np.maximum(size,1e-12))[:,None]
    local=xyz[:,[0,2,1]]
    center=(local.min(0)+local.max(0))/2
    p.update(centre=center.tolist(),size=np.ptp(local,axis=0).tolist(),vertices=(local-center).round(6).tolist())
    stats[str(idx)]=dict(max=float(np.linalg.norm(xyz-original,axis=1).max()),
                         moved=int((np.linalg.norm(xyz-original,axis=1)>.001).sum()))
(assets/(target+"-mesh.json")).write_text(json.dumps(parts,separators=(",",":")))
(assets/(target+"-adjustment.json")).write_text(json.dumps(stats,indent=2))

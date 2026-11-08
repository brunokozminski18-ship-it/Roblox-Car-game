"""Relieve only authored support triangles obscuring a measured visible lens."""
import json
import sys
from pathlib import Path
import numpy as np
from mathutils import Vector
from mathutils.bvhtree import BVHTree


assets=Path(__file__).resolve().parents[1]/"assets"
base,target,*selected=sys.argv[sys.argv.index("--")+1:]
rows=json.loads((assets/(base+"-mesh.json")).read_text())
parts={p["index"]:p for p in rows}
refs=np.load(assets/"trim-masks.npz")


def world(p):
    return (np.asarray(p["vertices"])+p["centre"])[:,[0,2,1]]


def tree(p):
    return BVHTree.FromPolygons(world(p).tolist(),p["triangles"],all_triangles=True)


for idx, blockers, cameras in [(10,(18,11),[0,1]),(26,(18,24),[3,5,6,7]),(12,(18,),[0,1,4]),(15,(18,),[1,2,3])]:
    if str(idx) not in (selected or ["10","26"]):continue
    lens=tree(parts[idx])
    for k in blockers:
        p=parts[k];v=world(p);faces=np.asarray(p["triangles"])
        support=tree(p);sums=np.zeros_like(v);weights=np.zeros(len(v))
        for j in cameras:
            eye,fwd,right,up=refs["camera"+str(j)]
            mask=refs[f"mask{idx}_{j}"];h,w=mask.shape
            focal=h/2/np.tan(np.deg2rad(17.5))
            delta=world(parts[idx])-eye
            depths=delta@fwd
            pixels=np.c_[h/2-focal*(delta@up)/depths,w/2+focal*(delta@right)/depths]
            y0,x0=np.maximum(pixels.min(0).astype(int)-2,0)
            y1,x1=np.minimum(pixels.max(0).astype(int)+3,[h,w])
            hits=np.argwhere(mask[y0:y1,x0:x1])+[y0,x0]
            for y,x in hits[::3]:
                ray=Vector(fwd+(x+.5-w/2)/focal*right-(y+.5-h/2)/focal*up).normalized()
                hit,_,_,lens_d=lens.ray_cast(Vector(eye),ray)
                if hit is None:continue
                hit,_,face,support_d=support.ray_cast(Vector(eye),ray)
                if hit is None or not -.003<lens_d-support_d<.12:continue
                tri=faces[face]
                weight=1/(.015+np.linalg.norm(v[tri]-np.array(hit),axis=1))
                sums[tri]+=weight[:,None]*np.array(ray)*min(.06,lens_d-support_d+.009)
                weights[tri]+=weight
        move=sums/np.maximum(1,weights[:,None])
        for axis in range(3):
            a=v[:,axis]
            move[(a==a.min())|(a==a.max()),axis]=0
            move[:,axis]=np.clip(a+move[:,axis],a.min(),a.max())-a
        p["vertices"]=(np.asarray(p["vertices"])+move[:,[0,2,1]]).round(6).tolist()
        print(idx,k,np.count_nonzero(weights))
(assets/(target+"-mesh.json")).write_text(json.dumps(rows,separators=(",",":")))

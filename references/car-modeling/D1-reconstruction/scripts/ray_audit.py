"""Blender BVH ray distances from the authored surface to the camera survey."""
import json
import sys
from pathlib import Path
import numpy as np
from mathutils import Vector
from mathutils.bvhtree import BVHTree

assets=Path(__file__).resolve().parents[1]/"assets"
samples=np.load(assets/"measurement-rays.npz")
for name in sys.argv[sys.argv.index("--")+1:]:
    path=assets/(name+("" if name=="authored-parts" else "-mesh")+".json")
    rows=json.loads(path.read_text())
    audit={}
    distances=[]
    total=hits=0
    for p in rows:
        idx=p["index"]
        center,size=samples[f"b{idx}"]
        v=((np.array(p["vertices"])+p["centre"])[:,[0,2,1]]-center)/size
        bvh=BVHTree.FromPolygons(v.tolist(),p["triangles"],all_triangles=True)
        residual=[];count=0
        for j in range(6):
            rays=samples[f"r{idx}_{j}"]
            origin=Vector(rays[0])
            for target in rays[1:]:
                count+=1
                hit,_,_,_=bvh.ray_cast(origin,(Vector(target)-origin).normalized())
                if hit is not None:
                    residual.append(float(np.linalg.norm((np.array(hit)-target)*size)))
        distances.extend(residual)
        total+=count;hits+=len(residual)
        audit[str(idx)]={"samples":count,"hits":len(residual)}
        if residual:audit[str(idx)].update(median=float(np.median(residual)),p90=float(np.percentile(residual,90)))
    result=dict(parts=audit,rays=total,hits=hits,coverage=hits/total,
                medianStuds=float(np.median(distances)),p90Studs=float(np.percentile(distances,90)))
    (assets/(name+"-ray-audit.json")).write_text(json.dumps(result,indent=2))
    print(name,result["coverage"],result["medianStuds"],result["p90Studs"])

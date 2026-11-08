"""Measure a Blender master against visible, independently measured camera rays.

blender -b master.blend --python-exit-code 1 --python blender_surface_error.py
    -- --rays survey.npz --out results.json

NPZ arrays: origin[N,3], target[N,3] in Blender world space, part[N] integers.
Mesh objects identify their part with an integer SourcePartIndex property.
All distances use the master's units. Missing rays are counted separately.
"""
import argparse
import json
import sys
from pathlib import Path
import bpy
import numpy as np
from mathutils import Vector
from mathutils.bvhtree import BVHTree


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument("--rays",type=Path,required=True)
    parser.add_argument("--out",type=Path,required=True)
    args=parser.parse_args(sys.argv[sys.argv.index("--")+1:])
    with np.load(args.rays,allow_pickle=False) as a:
        origins,targets,roles=a["origin"],a["target"],a["part"]
    assert origins.shape==targets.shape==(len(roles),3)
    assert np.isfinite(origins).all() and np.isfinite(targets).all()
    deps=bpy.context.evaluated_depsgraph_get()
    errors=[];report={};seen=set()
    for obj in bpy.context.scene.objects:
        if obj.type!="MESH" or "SourcePartIndex" not in obj:continue
        role=int(obj["SourcePartIndex"])
        if role in seen:raise ValueError(f"Duplicate part ID {role}")
        seen.add(role)
        ob=obj.evaluated_get(deps)
        mesh=ob.to_mesh()
        try:
            mesh.calc_loop_triangles()
            tree=BVHTree.FromPolygons([ob.matrix_world@v.co for v in mesh.vertices],
                    [t.vertices[:] for t in mesh.loop_triangles],all_triangles=True)
        finally:ob.to_mesh_clear()
        selected=np.where(roles==role)[0]
        local=[]
        for i in selected:
            origin=Vector(origins[i]);target=Vector(targets[i])
            point,_,_,_=tree.ray_cast(origin,(target-origin).normalized())
            if point is not None:local.append((point-target).length)
        entry={"samples":len(selected),"hits":len(local)}
        if local:entry.update(median=float(np.median(local)),p90=float(np.percentile(local,90)))
        report[role]=entry
        errors.extend(local)
    missing=set(map(int,roles))-seen
    if missing:raise ValueError(f"Missing target parts: {sorted(missing)}")
    if not errors:raise ValueError("No measured surface hits")
    result={"samples":len(roles),"hits":len(errors),"median":float(np.median(errors)),
            "p90":float(np.percentile(errors,90)),"parts":report}
    args.out.write_text(json.dumps(result,indent=2),encoding="utf-8")
    print("Survey",result["hits"],"/",result["samples"],"median",result["median"],"p90",result["p90"])


if __name__=="__main__":main()

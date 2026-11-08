"""Fit new panel surfaces from visible depth intervals on the optical bench.

Each tile photographs the same isolated part behind a different occluder.
Only pixels surviving a measured depth cut contribute to the fitted surface.
No source vertices, triangle indices or normals are inputs.
"""
import argparse
import json
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage as ndi
from fit_views import ASSETS, BASE, FOCAL, source_box, tile


def depth_field(frame, resolution):
    rgb = np.asarray(Image.open(ASSETS/(frame["name"]+".png")).convert("RGB"), dtype=float)
    bg = np.median(rgb[:4], axis=(0,1))
    mask = np.max(abs(rgb-bg),axis=2)>18
    axis = np.linspace(-.515,.515,resolution)
    u,v = np.meshgrid(axis,axis)
    depth = np.full_like(u,np.nan)
    cuts = np.linspace(-.56,.56,30)
    for k,cut in enumerate(cuts):
        x,y=tile(k+1)
        # A point on the cutting plane is at world Z=360 for every tile.
        px=702.5+(x+3.65*u)*FOCAL/520
        py=324.5-(y+3.65*v)*FOCAL/520
        visible=ndi.map_coordinates(mask.astype(float),[py,px],order=1)>.45
        depth[visible]=cut+(cuts[1]-cuts[0])/2
    finite=np.isfinite(depth)
    # Bilateral averaging within a shallow depth interval keeps deep recesses separate.
    smooth=np.zeros_like(u)
    weight=np.zeros_like(u)
    for dy in range(-2,3):
        for dx in range(-2,3):
            other=np.roll(depth,(dy,dx),axis=(0,1))
            valid=finite & np.isfinite(other) & (abs(other-depth)<.082)
            w=np.exp(-(dx*dx+dy*dy)/5)*valid
            smooth+=np.nan_to_num(other)*w
            weight+=w
    depth=np.divide(smooth,weight,out=np.full_like(u,np.nan),where=weight>0)
    return u,v,depth


def patches(index,resolution):
    frames=json.loads((ASSETS/f"slices-{index}.json").read_text())
    chunks=[]
    for frame in frames:
        u,v,z=depth_field(frame,resolution)
        rot=np.asarray(frame["mat"][3:]).reshape(3,3)
        coords=np.stack((u,v,z),axis=2).reshape(-1,3)@rot
        base=np.arange(resolution**2).reshape(resolution,resolution)[:-1,:-1].ravel()
        faces=np.vstack((np.column_stack((base,base+1,base+resolution+1)),
                         np.column_stack((base,base+resolution+1,base+resolution))))
        pts=coords[faces]
        valid=np.isfinite(pts).all(axis=(1,2))
        faces,pts=faces[valid],pts[valid]
        # Do not bridge between front and back surfaces across an opening.
        shallow=np.linalg.norm(pts-pts[:,[0]],axis=2).max(axis=1)<.080
        faces,pts=faces[shallow],pts[shallow]
        n=np.cross(pts[:,1]-pts[:,0],pts[:,2]-pts[:,0])
        dominant=abs(n@rot[2])>.72*np.max(abs(n),axis=1)
        faces=faces[dominant]
        ids, local=np.unique(faces,return_inverse=True)
        chunks.append((coords[ids],local.reshape(-1,3)))
        if np.allclose(rot[2],[1,0,0]) and index in (10,12,14,15,18,19,26):
            chunks.append((coords[ids]*[-1,1,1],local.reshape(-1,3)[:,::-1]))
    verts,tris=[],[]
    offset=0
    for points,faces in chunks:
        verts.append(points)
        tris.append(faces+offset)
        offset+=len(points)
    return np.vstack(verts),np.vstack(tris)


if __name__=="__main__":
    cli=argparse.ArgumentParser()
    cli.add_argument("name")
    cli.add_argument("indices",nargs="+",type=int)
    cli.add_argument("--resolution",default=59,type=int)
    args=cli.parse_args()
    source={p["index"]:p for p in json.loads((BASE/"source-parts.json").read_text())["parts"]}
    output={}
    for idx in args.indices:
        verts,tris=patches(idx,args.resolution)
        center,size=source_box(source[idx])
        output[str(idx)]=dict(vertices=((verts*size+center)[:,[0,2,1]]).round(6).tolist(),triangles=tris.tolist())
    (ASSETS/(args.name+".json")).write_text(json.dumps(output,separators=(",",":")))

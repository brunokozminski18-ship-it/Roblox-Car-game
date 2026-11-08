"""Estimate visible panel planes from calibrated depth, then fit authored face normals."""
import json
import sys
import numpy as np
from scipy.spatial import cKDTree
from metric_depth import ASSETS, BASE, calibrated_views, source_box
from fuse_charts import clean_chart


def survey_normals(idx,center,size):
    cloud=[];directions=[]
    for cam,rot,_ in calibrated_views(idx,stride=1):
        z,edge=clean_chart(cam[:,:,2])
        # Use a long baseline to suppress 8-bit brightness quantization.
        safe=edge>.025
        pos=cam.copy()
        pos[:,:,2]=z
        xyz=((pos@rot)*size+center)[:,:,[0,2,1]]
        dx=np.roll(xyz,-5,axis=1)-np.roll(xyz,5,axis=1)
        dy=np.roll(xyz,-5,axis=0)-np.roll(xyz,5,axis=0)
        nd=np.cross(dx,dy);length=np.linalg.norm(nd,axis=2)
        for axis in (0,1):
            safe &= abs(np.roll(z,5,axis=axis)-np.roll(z,-5,axis=axis))<.14
        good=safe & np.isfinite(length) & (length>1e-8)
        good &= (np.indices(good.shape)[0]%3==0) & (np.indices(good.shape)[1]%3==0)
        cloud.append(xyz[good])
        directions.append(nd[good]/length[good,None])
    return np.vstack(cloud),np.vstack(directions)


if __name__=="__main__":
    source={p["index"]:p for p in json.loads((BASE/"source-parts.json").read_text())["parts"]}
    rows=json.loads((ASSETS/(sys.argv[1]+"-mesh.json")).read_text())
    for p in rows:
        idx=p["index"]
        if idx not in (10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30):continue
        center,size=source_box(source[idx])
        cloud,dirs=survey_normals(idx,center,size)
        if len(cloud)<10:continue
        vertices=np.array(p["vertices"])+p["centre"]
        tris=np.asarray(p["triangles"])
        normals=np.asarray(p["normals"])
        distances,neighbors=cKDTree(cloud).query(vertices[tris].mean(1),k=min(48,len(cloud)))
        near=dirs[neighbors]
        dots=np.einsum("fki,fi->fk",near,normals)
        w=np.exp(-(distances/.10)**2)*np.maximum(.015,abs(dots))**3
        new=(near*(w*np.sign(dots))[:,:,None]).sum(1)
        magnitude=np.linalg.norm(new,axis=1)
        good=(magnitude>.001)&(distances[:,0]<.13)
        new[good]/=magnitude[good,None]
        normals[good]=new[good]
        p["normals"]=normals.round(6).tolist()
    (ASSETS/(sys.argv[2]+"-mesh.json")).write_text(json.dumps(rows,separators=(",",":")))

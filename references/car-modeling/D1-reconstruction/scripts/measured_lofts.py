"""Rebuild continuous cross-car trim as separate measured convex sections."""
import json
import sys
import numpy as np
from scipy import ndimage as ndi
from metric_depth import ASSETS, BASE, calibrated_views, source_box


def measured_sections(idx):
    charts=[]
    for j,(camera,rot,_) in enumerate(calibrated_views(idx,stride=1)):
        mask=ndi.binary_erosion(np.isfinite(camera[:,:,2]),iterations=1)
        charts.append((camera[mask]@rot))
    points=np.vstack(charts)
    # Each candidate is tested on the six surveys and five reserved silhouettes.
    angles=np.arange(48)*2*np.pi/48
    directions=np.stack((np.cos(angles),np.sin(angles)),axis=1)
    xvals=np.linspace(-.5,.5,61)
    sections=[]
    for x in xvals:
        near=points[abs(points[:,0]-x)<.009,1:]
        if len(near)<10:
            nearest=np.argpartition(abs(points[:,0]-x),40)[:40]
            near=points[nearest,1:]
        support=np.percentile(near@directions.T,99.15,axis=0)
        center=(np.percentile(near,97,axis=0)+np.percentile(near,3,axis=0))/2
        margin=np.maximum(.0002,support-directions@center)
        dp=directions@directions.T
        distance=np.min(margin[None,:]/np.where(dp>1e-5,dp,np.nan),axis=1,where=dp>1e-5,initial=np.inf)
        sections.append(np.c_[np.full(len(directions),x),center+distance[:,None]*directions])
    v=np.vstack(sections);n=len(directions);f=[]
    for j in range(len(xvals)-1):
        for a in range(n):
            b=(a+1)%n
            f.extend([[j*n+a,j*n+b,(j+1)*n+b],[j*n+a,(j+1)*n+b,(j+1)*n+a]])
    for a in range(1,n-1):
        f.append([0,a+1,a]);offset=(len(xvals)-1)*n;f.append([offset,offset+a,offset+a+1])
    return v,f


src={p["index"]:p for p in json.loads((BASE/"source-parts.json").read_text())["parts"]}
out={}
for idx in map(int,sys.argv[2:]):
    v,f=measured_sections(idx);center,size=source_box(src[idx])
    out[str(idx)]=dict(vertices=((v*size+center)[:,[0,2,1]]).round(6).tolist(),triangles=f,smooth_steps=0)
(ASSETS/(sys.argv[1]+".json")).write_text(json.dumps(out,separators=(",",":")))

"""Use only well-supported, upward-facing bonnet samples; keep panel apertures."""
import json
import numpy as np
from scipy import ndimage as ndi
from scipy.spatial import cKDTree
from metric_depth import ASSETS, BASE, calibrated_views, source_box


def fit(part, source):
    center,size=source_box(source)
    cam,rot,_=next(calibrated_views(18,stride=1))
    good=ndi.binary_erosion(np.isfinite(cam[:,:,2]),iterations=3)
    points=((cam[good]@rot)*size+center)[:,[0,2,1]]
    v=np.asarray(part["vertices"])+part["centre"]
    d,near=cKDTree(points[:,:2]).query(v[:,:2],k=30)
    samples=points[near]
    z=np.median(samples[:,:,2],axis=1)
    dv=z-v[:,2]
    faces=np.asarray(part["triangles"])
    norms=np.abs(np.array(part["normals"])[:,2])
    upward=np.zeros(len(v))
    for col in range(3):
        np.maximum.at(upward,faces[:,col],norms)
    trusted=(v[:,1]<-1.6)&(v[:,2]>1.9)&(d[:,0]<.055)&(np.ptp(samples[:,:,2],axis=1)<.14)&(abs(dv)<.21)&(upward>.67)
    movement=np.where(trusted,np.clip(dv,-.1,.1),0)
    local=np.array(part["vertices"])
    local[:,2]+=movement
    part["vertices"]=local.round(6).tolist()
    print("Bonnet vertices fitted:",np.count_nonzero(movement), "of",len(v))


if __name__=="__main__":
    rows=json.loads((ASSETS/"boundary-mesh.json").read_text())
    source=next(p for p in json.loads((BASE/"source-parts.json").read_text())["parts"] if p["index"]==18)
    fit(next(p for p in rows if p["index"]==18),source)
    (ASSETS/"bonnet-mesh.json").write_text(json.dumps(rows,separators=(",",":")))

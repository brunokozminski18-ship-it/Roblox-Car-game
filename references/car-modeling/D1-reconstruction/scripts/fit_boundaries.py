"""Fit local mesh vertices to registered colour boundaries with multiview constraints."""
import json
import sys
import numpy as np
from PIL import Image
from scipy import ndimage as ndi
from scipy.spatial import cKDTree
from compare_studio import ASSETS, masks, projected_region


def fit(part, role, views, refs, baseline):
    xyz = (np.asarray(part["vertices"])+part["centre"])[:,[0,2,1]]
    system = np.broadcast_to(np.eye(3)*.8,(len(xyz),3,3)).copy()
    rhs = np.zeros_like(xyz)
    for j in views:
        eye, forward, right, up = refs["camera"+str(j)]
        paths = ([f"studio-{label}-{j}.png" for label in (baseline,"original")] if j<5 else
                 [f"tail-{label}-{j-5}.png" for label in (baseline,"source")])
        pair = [masks(np.asarray(Image.open(ASSETS/path).convert("RGB")),trim=True)[role] for path in paths]
        roi = projected_region(role,j,pair[0].shape,pose=eye)
        boundaries = []
        for binary in pair:
            binary = ndi.median_filter(binary.astype("uint8"),size=3).astype(bool)
            boundaries.append(np.argwhere((binary^ndi.binary_erosion(binary)) & roi))
        own, ref = boundaries
        delta = xyz-eye
        depth = delta@forward
        h,w = pair[0].shape
        focal = h/2/np.tan(np.deg2rad(17.5))
        pix = np.c_[h/2-focal*(delta@up)/depth,w/2+focal*(delta@right)/depth]
        d, nearest = cKDTree(own).query(pix)
        measured = own[nearest]
        e, target = cKDTree(ref).query(measured)
        goal = ref[target]-measured
        weight = np.exp(-(d/5)**2) * (e<14)
        if role=="intake" and j==2:weight[xyz[:,0]<0]=0
        # Enforce only image-plane displacement; independent views constrain depth.
        system += weight[:,None,None]*(np.eye(3)-np.outer(forward,forward))
        rhs += (weight*depth/focal)[:,None]*(goal[:,1,None]*right-goal[:,0,None]*up)
    shift = np.linalg.solve(system,rhs[:,:,None])[:,:,0]
    shift *= np.minimum(1,.045/np.maximum(1e-12,np.linalg.norm(shift,axis=1)))[:,None]
    # Preserve the bounding frame used by the existing Studio assembly.
    for axis in range(3):
        a=xyz[:,axis]
        shift[(a==a.min())|(a==a.max()),axis]=0
        shift[:,axis]=np.clip(a+shift[:,axis],a.min(),a.max())-a
    part["vertices"] = (np.asarray(part["vertices"])+shift[:,[0,2,1]]).round(6).tolist()


if __name__ == "__main__":
    baseline, output, *selected = sys.argv[1:] or ["plane-trim","boundary"]
    rows=json.loads((ASSETS/(baseline+"-mesh.json")).read_text())
    refs=np.load(ASSETS/"trim-masks.npz")
    roles={10:("headlamp",[0,1]),26:("taillamp",[3]),18:("paint",range(5)),19:("glass",range(5))}
    if "12" in selected:roles[12]=("vent",[0,1,4])
    if "15" in selected:roles[15]=("intake",[2])
    if all((ASSETS/f"tail-{baseline}-{j}.png").exists() for j in range(3)):
        roles[26]=("taillamp",[3,5,6,7])
    for p in rows:
        if p["index"] in roles and (not selected or str(p["index"]) in selected):
            role,views=roles[p["index"]]
            fit(p,role,views,refs,baseline)
    (ASSETS/(output+"-mesh.json")).write_text(json.dumps(rows,separators=(",",":")))

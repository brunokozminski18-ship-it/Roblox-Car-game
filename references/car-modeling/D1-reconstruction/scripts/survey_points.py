"""Sample camera rays against optically measured surfaces for physical QA."""
import json
import numpy as np
from metric_depth import ASSETS,BASE,calibrated_views,source_box
from scipy import ndimage as ndi

records={}
parts=json.loads((BASE/"source-parts.json").read_text())["parts"]
for p in parts:
    if p["class"]!="MeshPart":continue
    idx=p["index"]
    center,size=source_box(p)
    records[f"b{idx}"]=np.stack((center,size))
    for j,(camera,rot,g) in enumerate(calibrated_views(idx,stride=4)):
        good=ndi.binary_erosion(np.isfinite(camera[:,:,2]),iterations=1)
        points=(camera[good]@rot)[::3]
        tile=np.array([(j%3-1)*23,(.5-j//3)*16.4+.7])
        origin=np.r_[-tile,520.]@rot/13.2
        records[f"r{idx}_{j}"]=np.vstack((origin,points)).astype(np.float32)
np.savez_compressed(ASSETS/"measurement-rays.npz",**records)

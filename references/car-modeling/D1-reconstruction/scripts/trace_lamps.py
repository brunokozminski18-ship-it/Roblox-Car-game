"""Trace visible lamp islands in the assembled vehicle and lift them onto optical depth."""
import json
import numpy as np
from scipy import ndimage as ndi
from scipy.spatial import Delaunay, cKDTree
from skimage.measure import find_contours, approximate_polygon
from metric_depth import ASSETS, BASE, calibrated_views, source_box


def trace(part, source, image_index, refs):
    index = part["index"]
    center, size = source_box(source)
    eye, forward, right, up = refs["camera"+str(image_index)]
    mask = refs[f"mask{index}_{image_index}"]
    h, w = mask.shape
    focal = h / 2 / np.tan(np.deg2rad(17.5))
    chart = []
    for coords, rotation, _ in calibrated_views(index, stride=2):
        valid = ndi.binary_erosion(np.isfinite(coords[:,:,2]))
        chart.append(coords[valid] @ rotation * size + center)
    delta = np.vstack(chart) - eye
    z = delta @ forward
    projected = np.c_[h/2-focal*(delta@up)/z, w/2+focal*(delta@right)/z]
    depth_tree = cKDTree(projected)
    labels, count = ndi.label(mask)
    verts, faces = [], []
    for i in range(1, count+1):
        island = labels == i
        if island.sum() < 100:
            continue
        # Only trace connected components overlapping this part's surveyed location.
        yx = np.argwhere(island)
        if np.median(depth_tree.query(yx)[0]) > 3:
            continue
        contour = [approximate_polygon(c, .85)[:-1] for c in find_contours(island,.5)]
        interior = yx[(yx[:,0]%5==0) & (yx[:,1]%5==0)]
        pixels = np.unique(np.vstack([*contour,interior]), axis=0)
        triangles = Delaunay(pixels).simplices
        outside = ndi.distance_transform_edt(~island)
        for weights in [[1/3]*3,[.5,.5,0],[0,.5,.5],[.5,0,.5]]:
            samples = (pixels[triangles]*np.array(weights)[None,:,None]).sum(axis=1)
            triangles = triangles[ndi.map_coordinates(outside,samples.T,order=1)<1.05]
        dist, neighbors = depth_tree.query(pixels,k=18)
        # Near-depth quartile selects the exterior sheet where both sides project together.
        d = np.percentile(z[neighbors], 25, axis=1)
        ray = forward + (pixels[:,1,None]-w/2)*right/focal - (pixels[:,0,None]-h/2)*up/focal
        world = eye + ray*d[:,None]
        faces.extend((triangles+len(verts)).tolist())
        verts.extend(world[:,[0,2,1]].tolist())
    assert verts and faces
    verts, faces = np.asarray(verts), np.asarray(faces)
    normals = np.cross(verts[faces[:,1]]-verts[faces[:,0]],verts[faces[:,2]]-verts[faces[:,0]])
    flip = np.einsum("ij,ij->i",normals,eye[[0,2,1]]-verts[faces].mean(axis=1))<0
    faces[flip] = faces[flip,::-1]
    normals[flip] *= -1
    normals /= np.maximum(1e-12,np.linalg.norm(normals,axis=1))[:,None]
    middle = (verts.max(axis=0)+verts.min(axis=0))/2
    part.update(centre=middle.tolist(),size=np.ptp(verts,axis=0).tolist(),
                vertices=(verts-middle).round(6).tolist(),triangles=faces.tolist(),normals=normals.round(5).tolist())


if __name__ == "__main__":
    rows = json.loads((ASSETS/"plane-trim-mesh.json").read_text())
    source = {p["index"]:p for p in json.loads((BASE/"source-parts.json").read_text())["parts"]}
    refs = np.load(ASSETS/"trim-masks.npz")
    for p in rows:
        if p["index"] in (10,26):
            trace(p,source[p["index"]],0 if p["index"]==10 else 5,refs)
    (ASSETS/"lamp-chart-mesh.json").write_text(json.dumps(rows,separators=(",",":")))

"""Project authored vertices towards locally planar measured surfaces."""
import json
import numpy as np
from scipy.spatial import cKDTree
from metric_depth import ASSETS, calibrated_views, source_box, BASE
from scipy import ndimage as ndi


def corrections(part, source):
    center, size = source_box(source)
    points = []
    for cam, rotation, _ in calibrated_views(part["index"], stride=2):
        depth = cam[:, :, 2]
        valid = ndi.binary_erosion(np.isfinite(depth), iterations=2)
        points.extend(((cam[valid] @ rotation * size + center)[:, [0, 2, 1]]))
    cloud = np.asarray(points)
    verts = np.asarray(part["vertices"]) + part["centre"]
    dist, idx = cKDTree(cloud).query(verts, k=32)
    neighborhood = cloud[idx]
    mean = neighborhood.mean(axis=1)
    centered = neighborhood - mean[:, None, :]
    eig, basis = np.linalg.eigh(centered.transpose(0, 2, 1) @ centered / 32)
    normal = basis[:, :, 0]
    signed = np.einsum("ij,ij->i", mean - verts, normal)
    reliable = (eig[:, 0] < .06 * eig[:, 1]) & (dist[:, 0] < .14)
    shift = (np.clip(signed, -.075, .075) * reliable)[:, None] * normal
    # Lock bounds so Studio's generated MeshPart centre stays registered.
    for axis in range(3):
        extreme = (verts[:, axis] == verts[:, axis].min()) | (verts[:, axis] == verts[:, axis].max())
        shift[extreme, axis] = 0
        shift[:, axis] = np.clip(verts[:, axis] + shift[:, axis], verts[:, axis].min(), verts[:, axis].max()) - verts[:, axis]
    return shift


if __name__ == "__main__":
    source = {p["index"]: p for p in json.loads((BASE/"source-parts.json").read_text())["parts"]}
    rows = json.loads((ASSETS/"contact-mesh.json").read_text())
    shifts = {p["index"]: corrections(p, source[p["index"]]) for p in rows if p["index"] in (10,11,12,13,15,16,18,19,21,22,23,24,25,26)}
    for label, fraction in [("plane-half", .5), ("plane-full", 1.)]:
        trial = [dict(p) for p in rows]
        for p in trial:
            if p["index"] in shifts:
                p["vertices"] = (np.asarray(p["vertices"]) + fraction*shifts[p["index"]]).round(6).tolist()
        (ASSETS/(label+"-mesh.json")).write_text(json.dumps(trial,separators=(",",":")))

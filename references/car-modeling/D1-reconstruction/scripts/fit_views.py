"""Fit independently triangulated visual hulls to calibrated Studio silhouettes.

Fit and validation use disjoint camera directions. Coordinates are normalized
in each measured part box before fitting, to retain thin and narrow features.
"""
import argparse
import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage as ndi
from skimage.measure import marching_cubes

BASE = Path(__file__).resolve().parents[1]
ASSETS = BASE / "assets"
FOCAL = 325 / np.tan(np.deg2rad(2))
ORIGIN = np.array([-60.1920051574707, 0, 31.513320922851564])
HOLDOUT = [7, 15, 24, 33, 43]


def tile(index):
    col, row = (index - 1) % 6, (index - 1) // 6
    return (col - 2.5) * 11, (2 - row) * 6.6


def project(points, index, rot):
    t = (points @ rot.T) * 3.65
    x, y = tile(index)
    scale = FOCAL / (520 - t[:, 2])
    return np.stack((702.5 + (t[:, 0] + x) * scale,
                     324.5 - (t[:, 1] + y) * scale), axis=0)


def source_box(p):
    cf = np.asarray(p["cf"])
    sz = abs(cf[3:].reshape(3, 3)) @ np.asarray(p["size"])
    return cf[:3] - ORIGIN, sz


def raster(points, triangles, index, rot, crop):
    xy = (project(points, index, rot).T - crop + .5) * 2
    image = Image.new("1", (220, 220))
    draw = ImageDraw.Draw(image)
    for tri in np.asarray(triangles):
        draw.polygon([tuple(a) for a in xy[tri]], fill=1)
    return np.asarray(image.resize((110, 110), Image.Resampling.NEAREST))


def observations(frames, images, index):
    cx, cy = project(np.zeros((1, 3)), index, np.eye(3)).ravel()
    crop = np.array([round(cx) - 55, round(cy) - 55])
    x, y = crop
    result = []
    for frame, img in zip(frames, images):
        patch = img[y:y+110, x:x+110]
        background = np.median(patch[:3], axis=(0, 1))
        mask = np.abs(patch - background).max(axis=2) > 18
        signed = ndi.distance_transform_edt(mask) - ndi.distance_transform_edt(~mask)
        result.append((np.array(frame["mat"][3:]).reshape(3, 3), mask, signed))
    return crop, result


def fit(index, obs, crop, resolution, slack, tolerance):
    axis = np.linspace(-.525, .525, resolution, dtype=np.float32)
    grid = np.stack(np.meshgrid(axis, axis, axis, indexing="ij"), axis=-1)
    points = grid.reshape(-1, 3)
    constraints = []
    for fid, (rot, mask, field) in enumerate(obs):
        if fid in HOLDOUT or mask.sum() < 10:
            continue
        xy = project(points, index, rot) - crop[:, None]
        constraints.append(ndi.map_coordinates(field, xy[::-1], order=1,
                           mode="constant", cval=-40).astype(np.float32))
    fields = np.stack(constraints)
    rank = min(slack, len(fields)-1)
    distances = np.partition(fields, rank, axis=0)[rank].reshape(grid.shape[:-1])
    distances = ndi.gaussian_filter(distances, .55) + tolerance
    for axis_id in range(3):
        distances = np.minimum(distances, (.502 - abs(grid[...,axis_id])) * 65)
    if distances.max() < 0:
        return None
    verts, faces, _, _ = marching_cubes(distances, level=0, allow_degenerate=False)
    return verts * (axis[1]-axis[0]) + axis[0], faces


def score(points, triangles, index, crop, obs):
    result = []
    for fid in HOLDOUT:
        if fid >= len(obs):
            continue
        rot, truth, _ = obs[fid]
        pred = raster(points, triangles, index, rot, crop)
        result.append(round(float((pred & truth).sum() / max(1, (pred | truth).sum())), 4))
    return result


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--frames", type=int, default=46)
    ap.add_argument("--resolution", type=int, default=48)
    ap.add_argument("--slack", type=int, default=1)
    ap.add_argument("--tolerance", type=float, default=.8)
    ap.add_argument("--name", default="fit1")
    ap.add_argument("--indices", nargs="*", type=int)
    ap.add_argument("--evaluate", type=Path)
    args = ap.parse_args()
    frames = json.loads((ASSETS/f"cameras-{args.frames}.json").read_text())
    images = [np.asarray(Image.open(ASSETS/(f["name"]+".png")).convert("RGB"), dtype=np.int16) for f in frames]
    baseline = json.loads((ASSETS/"authored-parts.json").read_text())
    source = {p["index"]:p for p in json.loads((BASE/"source-parts.json").read_text())["parts"]}
    candidate = {} if not args.evaluate else {p["index"]:p for p in json.loads(args.evaluate.read_text())}
    fitted, report = {}, {}
    for p in baseline:
        index = p["index"]
        if args.indices and index not in args.indices:
            continue
        center, size = source_box(source[index])
        crop, obs = observations(frames, images, index)
        def normalized(part):
            return ((np.array(part["vertices"]) + part["centre"])[:, [0, 2, 1]] - center) / size
        before = score(normalized(p), p["triangles"], index, crop, obs)
        if args.evaluate:
            q = candidate[index]
            after = score(normalized(q), q["triangles"], index, crop, obs)
        else:
            shape = fit(index, obs, crop, args.resolution, args.slack, args.tolerance)
            if shape is None:
                continue
            points, tris = shape
            after = score(points, tris, index, crop, obs)
            fitted[str(index)] = {"vertices": ((points * size + center)[:,[0,2,1]]).round(6).tolist(),
                                  "triangles": tris.tolist()}
        report[str(index)] = dict(before=before, after=after)
    if fitted:
        (ASSETS/(args.name+".json")).write_text(json.dumps(fitted,separators=(",",":")))
    (ASSETS/(args.name+"-scores.json")).write_text(json.dumps(report,indent=2))
    print([(i,round(np.mean(v["before"]),3),round(np.mean(v["after"]),3)) for i,v in report.items()])


if __name__ == "__main__":
    main()

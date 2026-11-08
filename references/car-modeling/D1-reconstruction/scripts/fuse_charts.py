"""Join optical surface measurements while preserving openings in thin panels."""
import argparse
import json

import numpy as np
from scipy import ndimage as ndi
from skimage.measure import marching_cubes
from metric_depth import ASSETS, BASE, FOCAL, calibrated_views, source_box


def clean_chart(z):
    good=np.isfinite(z)
    support=ndi.convolve(good.astype(float),np.ones((3,3)),mode="constant")
    good &= support>=5
    z=np.where(good,z,0.)
    # Average only within the same local relief, preserving recess boundaries.
    numerator=z.copy()
    denominator=np.ones_like(z)
    for dy in (-3,-2,-1,0,1,2,3):
        for dx in (-3,-2,-1,0,1,2,3):
            other=np.roll(z,(dy,dx),axis=(0,1))
            valid=np.roll(good,(dy,dx),axis=(0,1)) & good
            w=np.exp(-((other-z)/.025)**2 - (dx*dx+dy*dy)/12)*valid
            numerator+=other*w
            denominator+=w
    z=numerator/denominator
    nearest=ndi.distance_transform_edt(~good,return_distances=False,return_indices=True)
    z=z[tuple(nearest)]
    # Signed 2D outline distance in normalized part coordinates.
    edge=(ndi.distance_transform_edt(good)-ndi.distance_transform_edt(~good))/235
    return z,edge


def fuse(index,resolution,thickness,carve=False,openings=False):
    axis=np.linspace(-.53,.53,resolution,dtype=np.float32)
    points=np.stack(np.meshgrid(axis,axis,axis,indexing="ij"),axis=-1).reshape(-1,3)
    field=np.full(len(points),-1.,dtype=np.float32)
    free_space=np.ones_like(field)
    for j,(coords,rot,_) in enumerate(calibrated_views(index,stride=1)):
        height,edge=clean_chart(coords[:,:,2])
        cam=points@rot.T
        tile=np.array([(j%3-1)*23,(.5-j//3)*16.4+.7])
        cx,cy=np.array([702.5,324.5])+tile*[1,-1]*FOCAL/520
        scale=FOCAL/(520-13.2*cam[:,2])
        x=702.5+(13.2*cam[:,0]+tile[0])*scale-(round(cx)-185)
        y=324.5-(13.2*cam[:,1]+tile[1])*scale-(round(cy)-144)
        co=np.stack((y,x))
        relief=ndi.map_coordinates(height,co,order=1,mode="nearest")
        outline=ndi.map_coordinates(edge,co,order=1,mode="constant",cval=-1.)
        delta=relief-cam[:,2]
        # A thin inward slab seals the individual survey charts at shared edges.
        surface=np.minimum(np.minimum(delta+.003,thickness-delta),outline)
        field=np.maximum(field,surface)
        if carve:
            # A visible top-facing aperture must remain open even when a neighbouring
            # side survey contributes a grazing slab. Keep the far underside intact.
            near_threshold=-.25 if j==0 else .075
            permitted=np.minimum(outline+.006,delta+.011)
            free_space=np.minimum(free_space,np.maximum(permitted,near_threshold-cam[:,2]))
        elif openings and j in (0,1,4):
            silhouette=edge>0
            holes=ndi.binary_fill_holes(silhouette)&~silhouette
            if holes.any():
                border=(ndi.distance_transform_edt(~holes)-ndi.distance_transform_edt(holes))/235
                allowed=ndi.map_coordinates(border,co,order=1,mode="constant",cval=1.)
                threshold=-.15 if j==0 else .16
                free_space=np.minimum(free_space,np.maximum(allowed+.003,threshold-cam[:,2]))
    field=np.minimum(field,free_space)
    field=field.reshape((resolution,)*3)
    field=ndi.gaussian_filter(field,.55)
    for i in range(3):
        coord=np.reshape(axis,tuple(resolution if j==i else 1 for j in range(3)))
        field=np.minimum(field,.502-np.abs(coord))
    v,f,_,_=marching_cubes(field,0,allow_degenerate=False)
    return v*(axis[1]-axis[0])+axis[0],f


if __name__=="__main__":
    cli=argparse.ArgumentParser()
    cli.add_argument("name")
    cli.add_argument("indices",type=int,nargs="+")
    cli.add_argument("--resolution",type=int,default=78)
    cli.add_argument("--thickness",type=float,default=.030)
    cli.add_argument("--carve",action="store_true")
    cli.add_argument("--openings",action="store_true")
    args=cli.parse_args()
    source={p["index"]:p for p in json.loads((BASE/"source-parts.json").read_text())["parts"]}
    out={}
    for idx in args.indices:
        verts,faces=fuse(idx,args.resolution,args.thickness,args.carve,args.openings)
        center,size=source_box(source[idx])
        out[str(idx)]=dict(vertices=((verts*size+center)[:,[0,2,1]]).round(6).tolist(),triangles=faces.tolist())
    (ASSETS/(args.name+".json")).write_text(json.dumps(out,separators=(",",":")))

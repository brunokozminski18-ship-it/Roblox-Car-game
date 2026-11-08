"""Calibrated optical measurement and independent remeshing of visible surfaces.

Studio renders each reference on six axes with spatially uniform white lighting.
A strip of white targets of known depth is included in every frame. The same
renderer's grayscale response is inverted before backprojection into part space.
"""
import argparse
import json
from functools import lru_cache
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage as ndi
from fit_views import ASSETS, BASE, FOCAL, source_box

DIRS = np.array([[0,1,0],[1,0,0],[0,0,-1],[0,0,1],[-1,0,0],[0,-1,0]],float)
STANDARDS=np.array([-6.8,-5.,-3.3,-1.5,0.,1.5,3.3,5.,6.8])


@lru_cache(maxsize=1)
def standard_curves():
    """Fit on even-index known planes. Odd planes stay available for validation."""
    modes=[]
    for mode in (0,1):
        curves=[]
        for i in range(0,len(STANDARDS),2):
            a=np.asarray(Image.open(ASSETS/f"standard-{mode}-{i}.png").convert("L"),dtype=float)
            h,w=a.shape
            yy,xx=np.mgrid[0:h:4,0:w:4]
            angle2=((xx-(w-1)/2)**2+(yy-(h-1)/2)**2)/(h/2/np.tan(np.deg2rad(2)))**2
            curves.append(np.polynomial.polynomial.polyfit(angle2.ravel(),a[::4,::4].ravel(),2))
        modes.append(curves)
    return modes


def rotation(direction):
    up=np.array([0.,0.,1.]) if abs(direction[1])>.995 else np.array([0.,1.,0.])
    right=np.cross(up,direction)
    right/=np.linalg.norm(right)
    return np.array([right,np.cross(direction,right),direction])


def calibrated_views(index, radial=1, stride=2, name="rgbd", directions=DIRS):
    gray=np.asarray(Image.open(ASSETS/f"{name}-{index}.png").convert("L"), dtype=float)
    k=np.arange(61)
    swatch_x=np.rint(702.5+(k-30)*1.05*FOCAL/520).astype(int)
    y=round(324.5+17*FOCAL/520)
    levels=np.array([np.median(gray[y-3:y+4,x-3:x+4]) for x in swatch_x])
    z=(k/60-.5)*15
    radii=np.sqrt(1+radial*((k-30)**2*1.05**2+17**2)/520**2)
    camera_distance=(520-z)*radii
    good=np.r_[np.diff(levels)>0,True] & (levels>0)
    inverse_path=ASSETS/f"invert-{index}.png"
    inverse=None
    if name=="rgbd" and inverse_path.exists():
        inverse=np.asarray(Image.open(inverse_path).convert("L"),dtype=float)
        inverse_levels=np.array([np.median(inverse[y-3:y+4,x-3:x+4]) for x in swatch_x])
        inverse_dist=(520-(k/60-.5)*18)*radii
        inv_good=np.r_[np.diff(inverse_levels)<0,True] & (inverse_levels>0)
    for view,direction in enumerate(directions):
        tile=np.array([(view%3-1)*23,(.5-view//3)*16.4+.7])
        cx,cy=np.array([702.5,324.5])+tile*[1,-1]*FOCAL/520
        rows,cols=np.mgrid[round(cy)-144:round(cy)+145:stride,round(cx)-185:round(cx)+186:stride]
        rows=np.clip(rows,0,610)
        g=gray[rows,cols]
        rayx=(cols-702.5)/FOCAL
        rayy=(324.5-rows)/FOCAL
        dist=np.interp(g,levels[good],camera_distance[good])
        if inverse is not None:
            g2=inverse[rows,cols]
            near=np.interp(g2,inverse_levels[inv_good][::-1],inverse_dist[inv_good][::-1])
            # Dark-object exposure is more sensitive in the near half of the box.
            w=np.clip((g-115)/65,0,1)
            dist=(1-w)*dist+w*near
        radius2=rayx**2+rayy**2
        dist/=np.sqrt(1+radial*radius2)
        if inverse is not None and (ASSETS/"standard-1-8.png").exists():
            def apparent(level,mode):
                if mode==0:return np.interp(level,levels[good],camera_distance[good])
                return np.interp(level,inverse_levels[inv_good][::-1],inverse_dist[inv_good][::-1])
            knots=[]
            for ca,cb in zip(*standard_curves()):
                l0=np.polynomial.polynomial.polyval(radius2,ca)
                l1=np.polynomial.polynomial.polyval(radius2,cb)
                mix=np.clip((l0-115)/65,0,1)
                knots.append(520-((1-mix)*apparent(l0,0)+mix*apparent(l1,1))/np.sqrt(1+radius2))
            raw=520-dist
            corrected=raw.copy()
            anchors=STANDARDS[::2]
            for i in range(len(knots)-1):
                inside=((raw>=knots[i]) | (i==0)) & ((raw<knots[i+1]) | (i==len(knots)-2))
                t=(raw-knots[i])/np.maximum(.1,knots[i+1]-knots[i])
                corrected[inside]=(anchors[i]+t*(anchors[i+1]-anchors[i]))[inside]
            dist=520-corrected
        camera=np.stack((rayx*dist-tile[0],rayy*dist-tile[1],520-dist),axis=2)/13.2
        camera[g<=3]=np.nan
        yield camera,rotation(direction),g


def triangulate(index, stride,radial,extra=False):
    chunks=[]
    base_views=list(calibrated_views(index,radial,stride))
    for coords,rot,g in base_views:
        points=coords@rot
        rows,cols=coords.shape[:2]
        base=np.arange(rows*cols).reshape(rows,cols)[:-1,:-1].ravel()
        triangles=np.vstack((np.c_[base,base+cols+1,base+1],np.c_[base,base+cols,base+cols+1]))
        pts=points.reshape(-1,3)[triangles]
        valid=np.isfinite(pts).all(axis=(1,2))
        triangles,pts=triangles[valid],pts[valid]
        max_jump=np.max(np.linalg.norm(pts-pts[:,[0]],axis=2),axis=1)
        # Reject discontinuities at silhouettes and between depth layers.
        keep=max_jump < .038 + stride*.006
        triangles,pts=triangles[keep],pts[keep]
        n=np.cross(pts[:,1]-pts[:,0],pts[:,2]-pts[:,0])
        # Use the least foreshortened measurement at a panel junction.
        keep=abs(n@rot[2]) > .66*np.max(abs(n),axis=1)
        triangles=triangles[keep]
        ids,inv=np.unique(triangles,return_inverse=True)
        chunks.append((points.reshape(-1,3)[ids],inv.reshape(-1,3)))
    verts,tris=[],[]
    offset=0
    for xyz,faces in chunks:
        verts.append(xyz)
        tris.append(faces+offset)
        offset+=len(xyz)
    return np.vstack(verts),np.vstack(tris)


if __name__=="__main__":
    cli=argparse.ArgumentParser()
    cli.add_argument("name")
    cli.add_argument("indices",nargs="+",type=int)
    cli.add_argument("--radial",type=float,default=1)
    cli.add_argument("--stride",type=int,default=3)
    args=cli.parse_args()
    source={p["index"]:p for p in json.loads((BASE/"source-parts.json").read_text())["parts"]}
    out={}
    for idx in args.indices:
        pts,faces=triangulate(idx,args.stride,args.radial)
        center,size=source_box(source[idx])
        out[str(idx)]=dict(vertices=((pts*size+center)[:,[0,2,1]]).round(6).tolist(),triangles=faces.tolist())
    (ASSETS/(args.name+".json")).write_text(json.dumps(out,separators=(",",":")))

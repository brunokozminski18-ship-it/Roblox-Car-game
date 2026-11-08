"""Triangulate measured, face-on contours for D1's thin sheet-like details."""
import json
import sys
import numpy as np
from scipy import ndimage as ndi
from scipy.spatial import Delaunay
from skimage.measure import find_contours, approximate_polygon
from metric_depth import ASSETS, BASE, calibrated_views, source_box
from fuse_charts import clean_chart

# Face-on optical charts for each silhouette. A paired housing is measured on
# both sides. The central hood vents form two separated regions in the top chart.
CHARTS={10:[1,4],11:[1,4],12:[0],13:[1,4],14:[0],15:[1,4],17:[1,4],
        26:[1,4],29:[1,4]}


def trace(index):
    chunks=[]
    for j,(cam,rot,g) in enumerate(calibrated_views(index,stride=1)):
        if j not in CHARTS[index]:continue
        z,edge=clean_chart(cam[:,:,2])
        mask=edge>0
        if j in (1,4):mask &= z>-.055
        labels,count=ndi.label(mask)
        for q in range(1,count+1):
            region=labels==q
            if region.sum()<35:continue
            # Trace the outer and inner pixel boundaries, and retain curvature
            # samples inside. Dense voxel extraction loses the narrow lamp tips.
            contours=find_contours(np.pad(region,1),.5)
            xy=[approximate_polygon(a-1,1.05)[:-1] for a in contours]
            sampled=region & (np.indices(mask.shape)[0]%6==0) & (np.indices(mask.shape)[1]%6==0)
            xy.append(np.array(np.where(sampled)).T)
            pixels=np.unique(np.vstack(xy).round(3),axis=0)
            if len(pixels)<4:continue
            tri=Delaunay(pixels).simplices
            pts=pixels[tri]
            keep=np.ones(len(tri),dtype=bool)
            dist=ndi.distance_transform_edt(~region)
            for bary in ((1/3,1/3,1/3),(.5,.5,0),(0,.5,.5),(.5,0,.5)):
                at=(pts*np.array(bary)[None,:,None]).sum(1)
                keep &= ndi.map_coordinates(dist,at.T,order=1)<=1.1
            tri=tri[keep]
            core=ndi.binary_erosion(region,iterations=2)
            if not core.any():core=region
            nearest=ndi.distance_transform_edt(~core,return_distances=False,return_indices=True)
            ij=np.clip(np.rint(pixels).astype(int),[0,0],np.array(region.shape)-1)
            row,col=nearest[:,ij[:,0],ij[:,1]]
            depth=z[row,col]
            # Subpixel image coordinates at measured depth.
            tile=np.array([(j%3-1)*23,(.5-j//3)*16.4+.7])
            focal=325/np.tan(np.deg2rad(2))
            cx,cy=np.array([702.5,324.5])+tile*[1,-1]*focal/520
            py=pixels[:,0]+round(cy)-144
            px=pixels[:,1]+round(cx)-185
            scale=(520-13.2*depth)/focal
            world=np.c_[((px-702.5)*scale-tile[0])/13.2,
                        ((324.5-py)*scale-tile[1])/13.2,depth]@rot
            if len(tri):chunks.append((world,tri))
    verts=[];faces=[];offset=0
    for v,f in chunks:
        verts.append(v);faces.append(f+offset);offset+=len(v)
    return np.vstack(verts),np.vstack(faces)


if __name__=="__main__":
    if sys.argv[1]=="wrap":
        CHARTS[10]=[1,4,2]
        CHARTS[12]=[0,2]
        CHARTS[26]=[1,4,3]
    src={p["index"]:p for p in json.loads((BASE/"source-parts.json").read_text())["parts"]}
    out={}
    for idx in map(int,sys.argv[2:]):
        v,f=trace(idx);center,size=source_box(src[idx])
        out[str(idx)]=dict(vertices=((v*size+center)[:,[0,2,1]]).round(6).tolist(),
                           triangles=f.tolist(),smooth_steps=0)
    (ASSETS/(sys.argv[1]+".json")).write_text(json.dumps(out,separators=(",",":")))

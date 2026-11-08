"""Registered Studio photo comparison. Colour classes are optical estimates."""
import json
import sys
import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage as ndi
from scipy.spatial import ConvexHull
from fit_views import ASSETS, BASE, source_box
from proof import CAMERAS


def masks(img, trim=False):
    r,g,b=np.moveaxis(img.astype(float),-1,0)
    paint=(r>54)&(r>1.40*g)&(g>.28*r)&(b<.68*g)
    glass=(b>110)&(b>1.34*r)&(b>1.13*g)&(g>.96*r)
    front=(r>222)&(g>218)&(b>186)
    rear=(r>200)&(r>1.42*g)&(g>.32*r)&(b>.79*g)&(b>.34*r)&(b<1.21*g)
    out=dict(paint=paint,glass=glass,headlamp=front,taillamp=rear)
    if trim:
        out["intake"]=(r<42)&(g<53)&(b<68)&(b>1.12*g)&(g>1.06*r)
        out["vent"]=(r<119)&(g<130)&(b>g*.91)&(b>r*.95)
    return out


def region(ref,own):
    both=masks(ref)["paint"] | masks(own)["paint"]
    labels,n=ndi.label(ndi.binary_closing(both,iterations=3))
    sizes=np.bincount(labels.ravel());sizes[0]=0
    central=labels==sizes.argmax()
    yy,xx=np.where(central)
    return (max(0,yy.min()-34),min(ref.shape[0],yy.max()+35),
            max(0,xx.min()-38),min(ref.shape[1],xx.max()+39))


def projected_region(key,view,shape,pose=None):
    parts=json.loads((BASE/"source-parts.json").read_text())["parts"]
    allowed=dict(glass=[19],headlamp=[10],taillamp=[26],paint=[18],intake=[15],vent=[12])[key]
    eye=np.array(list(CAMERAS.values())[view] if pose is None else pose,dtype=float)
    if view==4 and pose is None:eye[2]=0
    target=np.array([0,2.4,-.01 if view==4 else 0])
    f=target-eye;f/=np.linalg.norm(f)
    right=np.cross(f,[0,1,0]);right/=np.linalg.norm(right)
    up=np.cross(right,f)
    h,w=shape
    focal=h/2/np.tan(np.deg2rad(17.5))
    area=Image.new("1",(w,h))
    draw=ImageDraw.Draw(area)
    corners=np.array([[a,b,c] for a in [-.5,.5] for b in [-.5,.5] for c in [-.5,.5]])
    for p in parts:
        if p["index"] not in allowed:continue
        center,sz=source_box(p)
        vec=center+corners*sz-eye
        pts=np.c_[w/2+focal*(vec@right)/(vec@f),h/2-focal*(vec@up)/(vec@f)]
        draw.polygon([tuple(t) for t in pts[ConvexHull(pts).vertices]],fill=1)
    return ndi.binary_dilation(np.asarray(area),iterations=3)


def compare(name):
    scores={}
    evidence=Image.new("RGB",(1250,440),(32,36,43))
    draw=ImageDraw.Draw(evidence)
    for i,view in enumerate(["front","front 3/4","side","rear 3/4","top"]):
        ref=np.array(Image.open(ASSETS/f"studio-original-{i}.png").convert("RGB"))
        own=np.array(Image.open(ASSETS/f"studio-{name}-{i}.png").convert("RGB"))
        y0,y1,x0,x1=region(ref,own)
        a,b=masks(ref[y0:y1,x0:x1]),masks(own[y0:y1,x0:x1])
        scores[view]={}
        for k in a:
            # Neighbouring cars and distant sky can be visible along the margins.
            if (k=="headlamp" and i not in (0,1)) or (k=="taillamp" and i!=3): continue
            roi=projected_region(k,i,ref.shape[:2])[y0:y1,x0:x1]
            a[k] &= roi;b[k] &= roi
            union=(a[k]|b[k]).sum()
            if a[k].sum()<100 or not union: continue
            scores[view][k]=round(float((a[k]&b[k]).sum()/union),4)
        for j,img in enumerate((ref,own)):
            thumb=Image.fromarray(img[y0:y1,x0:x1])
            thumb.thumbnail((244,181),Image.Resampling.LANCZOS)
            evidence.paste(thumb,(250*i+(250-thumb.width)//2,213*j+(185-thumb.height)//2))
            draw.text((250*i+7,213*j+188),("D1  |  " if j==0 else "Rekonstrukcja  |  ")+view,fill="white")
    evidence.save(ASSETS/("compare-"+name+".jpg"),quality=95)
    (ASSETS/("compare-"+name+".json")).write_text(json.dumps(scores,indent=2))
    print(name,scores)


if __name__=="__main__":
    for arg in sys.argv[1:]:compare(arg)

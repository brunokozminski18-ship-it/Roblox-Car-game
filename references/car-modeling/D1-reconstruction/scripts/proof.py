"""Five registered cameras and a software z-buffer for rapid iteration checks."""
import json
import sys
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw
from fit_views import ASSETS

CAMERAS = {"front":(0,4.8,-12), "front34":(7,5,-9), "side":(10,2.7,0),
           "rear34":(-7,5,9), "top":(0,22,-.01)}
COLORS = {}


def render(parts, camera, view):
    eye=np.asarray(camera,dtype=float)
    target=np.array([0,2.4,0])
    if view=="top": target[2]=-.02
    forward=target-eye
    forward/=np.linalg.norm(forward)
    right=np.cross(forward,[0,1,0])
    right/=np.linalg.norm(right)
    up=np.cross(right,forward)
    focal=325/np.tan(np.deg2rad(17.5))
    height,width=325,703
    image=np.zeros((height,width,3),np.uint8)+[38,45,57]
    depth=np.full((height,width),np.inf)
    for p in parts:
        points=(np.asarray(p["vertices"])+p["centre"])[:,[0,2,1]]
        dif=points-eye
        d=dif@forward
        pix=np.c_[width/2+focal*.5*(dif@right)/d,height/2-focal*.5*(dif@up)/d]
        base=np.array([int(p["color"][i:i+2],16) for i in (1,3,5)])
        for tri in np.asarray(p["triangles"]):
            xy=pix[tri]
            a,b,c=xy
            det=(b[1]-c[1])*(a[0]-c[0])+(c[0]-b[0])*(a[1]-c[1])
            if abs(det)<.001: continue
            x0,y0=np.maximum(xy.min(0).astype(int),0)
            x1,y1=np.minimum(np.ceil(xy.max(0)).astype(int)+1,[width,height])
            if x1<=x0 or y1<=y0: continue
            yy,xx=np.mgrid[y0:y1,x0:x1]
            w0=((b[1]-c[1])*(xx+.5-c[0])+(c[0]-b[0])*(yy+.5-c[1]))/det
            w1=((c[1]-a[1])*(xx+.5-c[0])+(a[0]-c[0])*(yy+.5-c[1]))/det
            w2=1-w0-w1
            z=1/(w0/d[tri[0]]+w1/d[tri[1]]+w2/d[tri[2]])
            sel=(w0>=0)&(w1>=0)&(w2>=0)&(z<depth[y0:y1,x0:x1])
            a,b,c=points[tri]
            normal=np.cross(b-a,c-a)
            normal/=max(1e-12,np.linalg.norm(normal))
            if np.dot(normal,eye-a)<0: normal=-normal
            light=.86+.32*np.dot(normal,[.35,.85,-.39])
            col=np.clip(base*light,0,255)
            if p["material"]=="Neon": col=np.minimum(255,base*1.75)
            image[y0:y1,x0:x1][sel]=col
            depth[y0:y1,x0:x1][sel]=z[sel]
    return Image.fromarray(image.astype(np.uint8))


if __name__=="__main__":
    names=sys.argv[1:]
    proof=Image.new("RGB",(5*300,(len(names)+1)*185),(30,35,42))
    draw=ImageDraw.Draw(proof)
    for i,(view,cam) in enumerate(CAMERAS.items()):
        for j,name in enumerate(["source"]+names):
            if j==0: img=Image.open(ASSETS/("source-"+view+".png")).convert("RGB").resize((703,325))
            else:
                parts=json.loads((ASSETS/(name+".json")).read_text())
                img=render(parts,cam,view)
            img=img.crop((120,12,583,325)).resize((275,160),Image.Resampling.LANCZOS)
            proof.paste(img,(300*i,185*j))
            draw.text((300*i+4,185*j+161),name+" / "+view,fill="white")
    proof.save(ASSETS/"iteration-proof.jpg",quality=94)

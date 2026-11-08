"""Material observations and original camera bases for contact fitting."""
import numpy as np
from PIL import Image
from compare_studio import ASSETS,masks

views=[(0,4.8,-12),(7,5,-9),(10,2.7,0),(-7,5,9),(0,22,0),(0,3.3,12),(7,4,9),(-4,6,10)]
out={}
for i,eye in enumerate(views):
    eye=np.array(eye,dtype=float)
    target=np.array([0,2.4,-.01 if i==4 else 0])
    forward=target-eye;forward/=np.linalg.norm(forward)
    right=np.cross(forward,[0,1,0]);right/=np.linalg.norm(right)
    up=np.cross(right,forward)
    out["camera"+str(i)]=np.stack((eye,forward,right,up))
    file=f"studio-original-{i}" if i<5 else f"tail-source-{i-5}"
    pixels=np.array(Image.open(ASSETS/(file+".png")).convert("RGB"))
    r,g,b=np.moveaxis(pixels.astype(float),-1,0)
    m=masks(pixels)
    out[f"mask10_{i}"]=m["headlamp"]
    out[f"mask26_{i}"]=m["taillamp"]
    out[f"mask12_{i}"]=(r<119)&(g<130)&(b>g*.91)&(b>r*.95)
np.savez_compressed(ASSETS/"trim-masks.npz",**out)

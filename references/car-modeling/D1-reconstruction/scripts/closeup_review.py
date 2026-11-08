"""Check lamp and glass masks in fresh close-up cameras, independent of fitting."""
import json
import sys
import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage as ndi
from scipy.spatial import ConvexHull
from compare_studio import ASSETS, BASE, masks, source_box


POSES=[((0,3.15,-8.7),(0,2.1,-3.4)),((3.85,3.25,-6.9),(2.05,2.32,-3.5)),
       ((6.7,2.75,-.4),(1.6,2.4,-.45)),((3.7,3.45,7.4),(1.38,2.55,3.65)),
       ((0,6.8,-6),(0,2.65,-2.35))]
ROLES=[("headlamp",10),("headlamp",10),("glass",19),("taillamp",26),("paint",18)]
PARTS={p["index"]:p for p in json.loads((BASE/"source-parts.json").read_text())["parts"]}


def view_mask(img,j):
    eye,target=map(np.asarray,POSES[j])
    forward=target-eye; forward/=np.linalg.norm(forward)
    right=np.cross(forward,[0,1,0]);right/=np.linalg.norm(right)
    up=np.cross(right,forward)
    h,w=img.shape[:2];f=h/2/np.tan(np.deg2rad(17.5))
    role,index=ROLES[j];center,size=source_box(PARTS[index])
    corners=np.array([[x,y,z] for x in [-.5,.5] for y in [-.5,.5] for z in [-.5,.5]])
    delta=center+corners*size-eye
    # A corner behind the near plane cannot be used as an image coordinate.
    roi=Image.new("1",(w,h),color=1 if (delta@forward).min()<.1 else 0)
    if (delta@forward).min()>=.1:
        xy=np.c_[w/2+f*(delta@right)/(delta@forward),h/2-f*(delta@up)/(delta@forward)]
        ImageDraw.Draw(roi).polygon([tuple(k) for k in xy[ConvexHull(xy).vertices]],fill=1)
    return masks(img)[role]&ndi.binary_dilation(np.asarray(roi),iterations=2)


def compare(labels):
    board=Image.new("RGB",(1500,170*(1+len(labels))),(33,38,45))
    draw=ImageDraw.Draw(board); scores={}
    for j in range(5):
        reference=None
        for row,label in enumerate(["reference",*labels]):
            image=Image.open(ASSETS/f"detail-{label}-{j}.png").convert("RGB")
            m=view_mask(np.asarray(image),j)
            if reference is None: reference=m
            else:
                scores.setdefault(label,[]).append(round(float((m&reference).sum()/(m|reference).sum()),5))
            image.thumbnail((298,141))
            board.paste(image,(300*j,170*row))
            draw.text((300*j+5,170*row+143),f"{label} | {ROLES[j][0]}",fill="white")
    board.save(ASSETS/"detail-comparison.jpg",quality=94)
    (ASSETS/"detail-comparison.json").write_text(json.dumps(scores,indent=2))
    print(scores)


if __name__=="__main__":
    compare(sys.argv[1:])

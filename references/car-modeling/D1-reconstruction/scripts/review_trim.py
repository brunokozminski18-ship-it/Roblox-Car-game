"""Measure assembled vent and door intake silhouettes inside their projected bounds."""
import json
import sys
import numpy as np
from PIL import Image
from compare_studio import ASSETS, masks, projected_region


def review(label):
    scores={}
    for role,views in [("intake",[2]),("vent",[0,1,4])]:
        for j in views:
            pair=[]
            for name in ["original",label]:
                pixels=np.asarray(Image.open(ASSETS/f"studio-{name}-{j}.png").convert("RGB"))
                pair.append(masks(pixels,trim=True)[role]&projected_region(role,j,pixels.shape[:2]))
            a,b=pair
            scores[f"{role}-{j}"]=round(float((a&b).sum()/(a|b).sum()),5)
    return scores


if __name__=="__main__":
    result={label:review(label) for label in sys.argv[1:]}
    (ASSETS/"trim-results.json").write_text(json.dumps(result,indent=2))
    print(result)

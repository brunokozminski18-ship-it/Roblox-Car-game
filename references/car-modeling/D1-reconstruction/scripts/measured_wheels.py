"""Revolve the measured ten flat rim sectors and tyre cross-section."""
import json
import sys
import numpy as np
from scipy.spatial import cKDTree
from metric_depth import ASSETS, BASE, calibrated_views, source_box

source={p["index"]:p for p in json.loads((BASE/"source-parts.json").read_text())["parts"]}
corners=np.array([[.5*np.sin(a)/np.cos(np.pi/10),.5*np.cos(a)] for a in np.arange(10)*np.pi/5])


def ring(i,t,r):
    return ((1-t)*corners[i%10]+t*corners[(i+1)%10])*r


def surface(index):
    cam,rot,_=list(calibrated_views(index,stride=1))[1]
    pts=(cam@rot).reshape(-1,3)
    pts=pts[np.isfinite(pts[:,0])]
    return pts,cKDTree(pts[:,1:])


def rim():
    points,tree=surface(1)
    rs=[0,.30,.32,.36,.40,.45,.55,.70,.85,.90,.95,1.]
    vertices,faces=[],[]
    def strip(va,vb,vc,vd):
        ix=len(vertices)
        vertices.extend((va,vb,vc,vd))
        if np.linalg.norm(np.cross(np.subtract(vb,va),np.subtract(vc,va)))>1e-8:
            faces.append([ix,ix+1,ix+2])
        if np.linalg.norm(np.cross(np.subtract(vc,va),np.subtract(vd,va)))>1e-8:
            faces.append([ix,ix+2,ix+3])
    charts=[]
    for t0,t1 in [(0,.5),(.5,1)]:
        lookup=[]
        for r in rs:
            endpoint=[]
            for t in (t0+.035,t1-.035):
                xy=[ring(i,t,min(r,.983)) for i in range(10)]
                _,j=tree.query(xy)
                endpoint.append(np.median(points[j,0]))
            lookup.append(np.clip(endpoint,-.5,.5))
        charts.append(np.array(lookup))
    for i in range(10):
        for h,(a,b) in enumerate(((0,.5),(.5,1))):
            values=charts[h]
            rows=[[np.r_[depth,ring(i,t,r)] for depth,t in zip(row,(a,b))]
                  for row,r in zip(values,rs)]
            for old,new in zip(rows,rows[1:]):
                strip(old[0],old[1],new[1],new[0])
            nextchart=charts[1-h]
            other=[np.r_[q[0],ring(i,b,r)] for q,r in zip(nextchart,rs)]
            for j in range(len(rs)-1):
                strip(rows[j][1],other[j],other[j+1],rows[j+1][1])
    return np.asarray(vertices),faces


def tire():
    # Printed front contour ratio, measured again on the outer-facing view.
    cam,rot,_=list(calibrated_views(6,stride=1))[1]
    pts=(cam@rot).reshape(-1,3)
    pts=pts[np.isfinite(pts[:,0]) & (pts[:,0]>.45)]
    flat=pts[abs(pts[:,2])<.10,1]
    ratio=round(2*float(np.percentile(abs(flat),1)),3)
    vertices=[]
    faces=[]
    for x,r in [(-.5,1),(.5,1),(.5,ratio),(-.5,ratio)]:
        vertices.extend([np.r_[x,corner*r] for corner in corners])
    for j in range(3):
        for i in range(10):
            a=j*10+i;b=j*10+(i+1)%10
            faces.extend([[a,b,b+10],[a,b+10,a+10]])
    # Inner/back face of the reference tyre is a solid decagon in rear-axial view.
    for i in range(1,9): faces.append([0,i+1,i])
    return np.asarray(vertices),faces,ratio


def rim_periphery():
    points=[]
    for j,(cam,rot,_) in enumerate(calibrated_views(1,stride=1)):
        if j in (1,4):continue
        p=(cam@rot).reshape(-1,3)
        points.extend(p[np.isfinite(p[:,0])])
    p=np.asarray(points)
    angle=np.mod(np.arctan2(p[:,1]*np.cos(np.pi/10),p[:,2]),np.pi/5)
    rho=2*np.hypot(p[:,1]*np.cos(np.pi/10),p[:,2])
    rho*=np.cos(angle-np.pi/10)/np.cos(np.pi/10)
    verts=[];faces=[]
    for i in range(10):
        for a,b in ((0,.5),(.5,1.)):
            start=len(verts);axles=np.linspace(-.5,.5,14)
            for x in axles:
                for t in (a,b):
                    angle_probe=(a+.055 if t==a else b-.055)*np.pi/5
                    cost=((p[:,0]-x)/.025)**2+((angle-angle_probe)/.043)**2
                    near=np.argpartition(cost,24)[:24]
                    r=np.clip(np.percentile(rho[near],82),0,1)
                    verts.append(np.r_[x,ring(i,t,r)])
            for s in range(len(axles)-1):
                k=start+2*s
                faces.extend([[k,k+1,k+3],[k,k+3,k+2]])
    return np.asarray(verts),np.asarray(faces)


out={}
rim_v,rim_f=rim()
if "--periphery" in sys.argv:
    wall,wall_faces=rim_periphery()
    rim_f=list(rim_f)+list((wall_faces+len(rim_v)).tolist())
    rim_v=np.vstack((rim_v,wall))
tire_v,tire_f,ratio=tire()
for group,seed,vertices,faces in [
    ([1,2,3,4],1,rim_v,rim_f),([6,7,8,9],6,tire_v,tire_f)]:
    template=np.array(source[seed]["cf"][3:]).reshape(3,3)
    for idx in group:
        rotation=np.array(source[idx]["cf"][3:]).reshape(3,3)@template.T
        center,size=source_box(source[idx])
        xyz=(vertices@rotation.T)*size+center
        out[str(idx)]=dict(vertices=xyz[:,[0,2,1]].round(7).tolist(),triangles=faces,analytic=True)
(ASSETS/("wheel-radial.json" if "--periphery" in sys.argv else "wheel-profile.json")).write_text(json.dumps(out,separators=(",",":")))
print("Measured tyre opening ratio:",ratio,"rim triangles:",len(rim_f))

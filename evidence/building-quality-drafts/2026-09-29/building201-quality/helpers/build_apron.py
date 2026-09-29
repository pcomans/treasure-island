# Bounded B201 render-only apron: clip original LAND planes; never bridge breaklines.
from pathlib import Path
import json,math,hashlib,struct
R=Path(__file__).resolve().parents[3]
records=[r for p in (R/'generated/world/chunks').glob('*.json') for r in json.loads(p.read_text())['records']]
w=next(r for r in records if r['object_key']=='building:w34313545:wall');v=w['vertices'];a=v[:3];b=v[111:114];L=math.hypot(b[0]-a[0],b[2]-a[2]);t=((b[0]-a[0])/L,(b[2]-a[2])/L);n=(-t[1],t[0]);center=((a[0]+b[0])/2,(a[2]+b[2])/2)
def local(p):return ((p[0]-center[0])*t[0]+(p[2]-center[1])*t[1],(p[0]-center[0])*n[0]+(p[2]-center[1])*n[1])
def clip(poly,fn):
 out=[]
 for i,A in enumerate(poly):
  B=poly[(i+1)%len(poly)];fa=fn(A);fb=fn(B)
  if fa>=0:out.append(A)
  if (fa>=0)!=(fb>=0):
   u=fa/(fa-fb);out.append(tuple(A[k]+u*(B[k]-A[k]) for k in range(3)))
 return out
bounds=[lambda p:local(p)[0]+L/2,lambda p:L/2-local(p)[0],lambda p:local(p)[1]-.025,lambda p:7.025-local(p)[1]]
lands=[];overlays=[]
for r in records:
 if r['feature_kind'] not in ['land_ground','major_area','road_path']:continue
 vs=list(zip(*[iter(r['vertices'])]*3));ids=r['indices']
 for k in range(0,len(ids),3):
  tri=[vs[i] for i in ids[k:k+3]];poly=tri
  for fn in bounds:
   if poly:poly=clip(poly,fn)
  if len(poly)<3:continue
  (lands if r['feature_kind']=='land_ground' else overlays).append((r['object_key'],k//3,tri,poly))
# Keep existing road/path visuals exposed: subtract their actual triangle footprints.
road_keys={r['object_key'] for r in records if r['feature_kind']=='road_path'}
clipped=[]
for key,i,tri,poly in lands:
 pieces=[poly]
 for okey,oi,otri,op in overlays:
  if okey not in road_keys:continue
  sign=1 if sum(op[j][0]*op[(j+1)%len(op)][2]-op[(j+1)%len(op)][0]*op[j][2] for j in range(len(op)))>0 else -1
  next_pieces=[]
  for piece in pieces:
   inside=piece
   for j,A in enumerate(op):
    B=op[(j+1)%len(op)];fn=lambda p:sign*((B[0]-A[0])*(p[2]-A[2])-(B[2]-A[2])*(p[0]-A[0]))
    if not inside:break
    outside=clip(inside,lambda p:-fn(p))
    if len(outside)>=3:next_pieces.append(outside)
    inside=clip(inside,fn)
  pieces=next_pieces
 for piece in pieces:clipped.append((key,i,tri,piece))
lands=clipped

def height(p,tri):
 A,B,C=tri;den=(B[2]-C[2])*(A[0]-C[0])+(C[0]-B[0])*(A[2]-C[2])
 if abs(den)<1e-10:return None
 u=((B[2]-C[2])*(p[0]-C[0])+(C[0]-B[0])*(p[2]-C[2]))/den;vv=((C[2]-A[2])*(p[0]-C[0])+(A[0]-C[0])*(p[2]-C[2]))/den
 return u*A[1]+vv*B[1]+(1-u-vv)*C[1]
max_above=0.0;owners=set()
for key,i,tri,poly in lands:
 for okey,oi,otri,op in overlays:
  signed=sum(op[j][0]*op[(j+1)%len(op)][2]-op[(j+1)%len(op)][0]*op[j][2] for j in range(len(op)));sign=1 if signed>0 else -1
  intersection=poly
  for j,A in enumerate(op):
   B=op[(j+1)%len(op)]
   if intersection:intersection=clip(intersection,lambda p:sign*((B[0]-A[0])*(p[2]-A[2])-(B[2]-A[2])*(p[0]-A[0])))
  if len(intersection)<3:continue
  area=abs(sum(intersection[j][0]*intersection[(j+1)%len(intersection)][2]-intersection[(j+1)%len(intersection)][0]*intersection[j][2] for j in range(len(intersection))))*.5
  if area<1e-7:continue
  owners.add(okey)
  for p in intersection:
   h=height(p,otri)
   if h is not None:max_above=max(max_above,h-p[1])
lift=max_above+.004
assert lift<.05,('Unexpected surface separation',lift)
faces=[];source=[]
for key,i,tri,poly in lands:
 for j in range(1,len(poly)-1):
  A,B,C=poly[0],poly[j],poly[j+1];cross_y=(B[2]-A[2])*(C[0]-A[0])-(B[0]-A[0])*(C[2]-A[2])
  if abs(cross_y)<1e-8:continue
  if cross_y>0:B,C=C,B
  converted=[[struct.unpack('f',struct.pack('f',x))[0] for x in [p[0],p[1]+lift,p[2]]] for p in [A,B,C]]
  ca,cb,cc=converted;cy=(cb[2]-ca[2])*(cc[0]-ca[0])-(cb[0]-ca[0])*(cc[2]-ca[2])
  if abs(cy)<1e-12:continue
  if cy>0:converted=[ca,cc,cb]
  faces.extend(converted);source.append([key,i])
result={'scope':'render-only exact source LAND-plane apron, uniform clearance over actual intersecting visible areas/roads','source_wall_sha256':hashlib.sha256(json.dumps(w,sort_keys=True).encode()).hexdigest(),'land_triangles':len(lands),'render_triangles':len(faces)//3,'uniform_land_lift_m':lift,'maximum_existing_overlay_above_land_m':max_above,'minimum_overlay_clearance_m':.004,'overlay_owners':sorted(owners),'faces':faces,'source_triangles':source}
p=R/'game/tests/building201_quality/apron.json';p.write_text(json.dumps(result,indent=2)+'\n');print({k:v for k,v in result.items() if k not in ['faces','source_triangles']})

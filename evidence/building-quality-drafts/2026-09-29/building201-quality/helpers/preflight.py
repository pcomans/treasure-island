from pathlib import Path
import json,math,hashlib,subprocess
R=Path(__file__).resolve().parents[3]; P=Path(__file__).resolve().parent
records=[r for p in (R/'generated/world/chunks').glob('*.json') for r in json.loads(p.read_text())['records']]
w=next(r for r in records if r['object_key']=='building:w34313545:wall');v=w['vertices'];a=v[:3];b=v[9*12+3:9*12+6];L=math.hypot(b[0]-a[0],b[2]-a[2]);t=((b[0]-a[0])/L,(b[2]-a[2])/L);n=(-t[1],t[0]);c=((a[0]+b[0])/2,(a[2]+b[2])/2)
lands=[]
for r in records:
 if r['feature_kind']!='land_ground':continue
 vs=list(zip(*[iter(r['vertices'])]*3));ids=r['indices']
 for j in range(0,len(ids),3):lands.append((r['object_key'],j//3,*[vs[i] for i in ids[j:j+3]]))
def ground(p):
 out=[];x,z=p
 for key,i,A,B,C in lands:
  den=(B[2]-C[2])*(A[0]-C[0])+(C[0]-B[0])*(A[2]-C[2])
  if abs(den)<1e-10:continue
  u=((B[2]-C[2])*(x-C[0])+(C[0]-B[0])*(z-C[2]))/den;vv=((C[2]-A[2])*(x-C[0])+(A[0]-C[0])*(z-C[2]))/den
  if min(u,vv,1-u-vv)>-1e-6:out.append((u*A[1]+vv*B[1]+(1-u-vv)*C[1],key,i))
 assert out,p
 return max(out)
def point(x,d):return(c[0]+t[0]*x+n[0]*d,c[1]+t[1]*x+n[1]*d)
def dist(p,A,B):
 dx=B[0]-A[0];dz=B[1]-A[1];den=dx*dx+dz*dz;u=max(0,min(1,((p[0]-A[0])*dx+(p[1]-A[1])*dz)/den)) if den else 0
 return math.hypot(p[0]-A[0]-u*dx,p[1]-A[1]-u*dz)
poses=[('whole',(-8.000708,-214.743366),(64.282,5.8,-253.463)),('near',point(25,12),(point(25,0)[0],6.3,point(25,0)[1]))];rows=[]
for name,p,target in poses:
 gy,key,tri=ground(p);d=math.hypot(target[0]-p[0],target[2]-p[1]);pitch=math.atan2(target[1]-gy-2,d);ux=(target[0]-p[0])/d;uz=(target[2]-p[1])/d;cam=(p[0]-ux*5.5*math.cos(pitch),p[1]-uz*5.5*math.cos(pitch));camy=gy+2-5.5*math.sin(pitch)
 nearest=(1e9,'')
 for r in records:
  if r['feature_kind']!='building_wall':continue
  vv=r['vertices'];segs=[((vv[j],vv[j+2]),(vv[j+3],vv[j+5])) for j in range(0,len(vv),12)]
  for k in range(21):
   q=(p[0]+(cam[0]-p[0])*k/20,p[1]+(cam[1]-p[1])*k/20);inside=False
   for A,B in segs:
    if (A[1]>q[1])!=(B[1]>q[1]) and q[0]<(B[0]-A[0])*(q[1]-A[1])/(B[1]-A[1])+A[0]:inside=not inside
    dd=dist(q,A,B)
    if dd<nearest[0]:nearest=(dd,r['object_key'])
   assert not inside,(name,r['object_key'])
 assert nearest[0]>.5 and camy-ground(cam)[0]>1.0 and -60<math.degrees(pitch)<25
 rows.append({'id':name,'anchor':p,'land':[gy,key,tri],'pitch':math.degrees(pitch),'camera_land_clearance':camy-ground(cam)[0],'all_wall_footprint_min_clearance':nearest})
posts=[]
width=115.512661489-1.4
for i in range(16):
 x=-width/2+1.1+i*(width-2.2)/15;posts.append(ground(point(x,1.80)))
for i in range(25):
 for j in range(5):ground(point(-115.512661489/2+i*115.512661489/24,.025+j*1.75))
result={'poses':rows,'post_ground_y_range':[min(p[0] for p in posts),max(p[0] for p in posts)],'apron_land_samples':125,'render_contact':'all new opaque details retain existing B201 render2/eligible-wall semantics with final-face contacts; source wall/roof untouched; draped apron deliberately render1/no collision','limitations':'native camera/capsule and contact congruence guarded in first render; no mechanics acceptance'}
(P/'preflight.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
for f in ['game/tests/building201_quality/candidate.gd','game/tests/building201_quality/capture.gd','game/tests/building201_quality/surface.gdshader',str(P/'run_capture.py')]:
 q=subprocess.run(['git','diff','--no-index','--check','/dev/null',f],capture_output=True,text=True);assert not q.stdout+q.stderr,q.stdout+q.stderr

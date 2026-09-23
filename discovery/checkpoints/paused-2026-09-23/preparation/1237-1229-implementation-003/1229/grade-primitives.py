"""Bounded 1221 composition + actual outward-footprint grade; no engine calls."""
from pathlib import Path
import json, math, hashlib
WORK=Path(__file__).resolve().parent
REPO=Path('/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1237-1229-implementation-003/staged')
def sha(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def write(p,v):p.write_text(json.dumps(v,indent=2)+'\n')
chunk=REPO/'generated/world/chunks/x_-2__z_-4.json'; records=json.loads(chunk.read_text())['records']
wall=next(r for r in records if r['object_key']=='building:w96665911:wall')
adjacent_records=json.loads((REPO/'generated/world/chunks/x_-1__z_-4.json').read_text())['records']
def merged(prefix):
 selected=[r for r in records+adjacent_records if r['object_key'].startswith(prefix)]
 result=dict(object_key=selected[0]['object_key'],collision_kind=selected[0]['collision_kind'],vertices=[],indices=[],triangle_owners=[],source_record_keys=[])
 for r in selected:
  offset=len(result['vertices'])//3;result['vertices']+=r['vertices'];result['indices'] += [i+offset for i in r['indices']];result['triangle_owners'] += [{'object_key':r['object_key'],'triangle':i} for i in range(len(r['indices'])//3)];result['source_record_keys'].append(r['object_key'])
 return result
land=merged('land:w26767313:');area=merged('area:r17241151:')
def height(record,x,z):
 hits=[];v=record['vertices']
 for j in range(0,len(record['indices']),3):
  a,b,c=[v[i*3:i*3+3] for i in record['indices'][j:j+3]]
  den=(b[2]-c[2])*(a[0]-c[0])+(c[0]-b[0])*(a[2]-c[2])
  if abs(den)<1e-10:continue
  u=((b[2]-c[2])*(x-c[0])+(c[0]-b[0])*(z-c[2]))/den
  q=((c[2]-a[2])*(x-c[0])+(a[0]-c[0])*(z-c[2]))/den
  if min(u,q,1-u-q)>=-1e-8:hits.append((u*a[1]+q*b[1]+(1-u-q)*c[1],j//3))
 assert hits, (record['object_key'],x,z)
 return max(hits)
def point(f,s,d,y=0):return [f['start'][0]+f['tangent'][0]*s+f['normal'][0]*d,y,f['start'][2]+f['tangent'][2]*s+f['normal'][2]*d]
def wallbottom(f,s):
 for run in f['runs']:
  a=wall['vertices'][run*12:run*12+3];b=wall['vertices'][run*12+3:run*12+6]
  start=(a[0]-f['start'][0])*f['tangent'][0]+(a[2]-f['start'][2])*f['tangent'][2]
  length=sum((b[i]-a[i])*f['tangent'][i]for i in [0,2])
  if start-1e-6<=s<=start+length+1e-6:return a[1]+(b[1]-a[1])*(s-start)/length
 raise ValueError(s)
def local_basis(f,station):
 for run in f['runs']:
  a=wall['vertices'][run*12:run*12+3];b=wall['vertices'][run*12+3:run*12+6]
  s0=sum((a[i]-f['start'][i])*f['tangent'][i]for i in [0,2]);s1=sum((b[i]-f['start'][i])*f['tangent'][i]for i in [0,2])
  if s0-1e-7<=station<=s1+1e-7:
   length=math.hypot(b[0]-a[0],b[2]-a[2]);t=[(b[0]-a[0])/length,0,(b[2]-a[2])/length];n=[-t[2],0,t[0]]
   if sum(n[i]*wall['normals'][run*12+i]for i in [0,2])<0:n=[-x for x in n]
   return dict(source_run=run,start=a,end=b,tangent=t,normal=n,length_m=length),length*(station-s0)/(s1-s0)
 raise ValueError(('source station',station))
def samples(f,station,width,d0,d1):
 out=[]
 basis,local=local_basis(f,station)
 for s,d in [(station-width/2,d0),(station+width/2,d0),(station+width/2,d1),(station-width/2,d1),(station,(d0+d1)/2)]:
  p=point(basis,local+s-station,d);lh,li=height(land,p[0],p[2]);ah,ai=height(area,p[0],p[2])
  out.append(dict(xz=[p[0],p[2]],station_m=s,outward_m=d,land_y=lh,land_triangle=li,land_source=land['triangle_owners'][li],visible_area_y=ah,area_triangle=ai,area_source=area['triangle_owners'][ai],source_wall_bottom_y=wallbottom(f,sum((point(basis,local+s-station,0)[i]-f['start'][i])*f['tangent'][i]for i in [0,2]))))
 return out
def complete_extrema(record,poly):
 # Convex footprint clipped against each actual source triangle; extrema occur at clipped vertices.
 def cross(a,b):return a[0]*b[1]-a[1]*b[0]
 def sub(a,b):return [a[0]-b[0],a[1]-b[1]]
 values=[];v=record['vertices']
 for j in range(0,len(record['indices']),3):
  tri=[v[i*3:i*3+3]for i in record['indices'][j:j+3]];a,b,c=tri
  u=sub([b[0],b[2]],[a[0],a[2]]);q=sub([c[0],c[2]],[a[0],a[2]]);den=cross(u,q)
  if abs(den)<1e-12:continue
  tri2=[[p[0],p[2]]for p in tri]
  if den<0:tri2.reverse()
  part=poly[:]
  for i,aa in enumerate(tri2):
   bb=tri2[(i+1)%3];edge=sub(bb,aa);out=[]
   for k,p in enumerate(part):
    pp=part[(k+1)%len(part)];fa=cross(edge,sub(p,aa));fb=cross(edge,sub(pp,aa))
    if fa>=-1e-9:out.append(p)
    if (fa>=-1e-9)!=(fb>=-1e-9):
     t=fa/(fa-fb);out.append([p[0]+t*(pp[0]-p[0]),p[1]+t*(pp[1]-p[1])])
   part=out
   if not part:break
  if len(part)<3:continue
  for p in part:
   d=sub(p,[a[0],a[2]]);values.append(a[1]+cross(d,q)/den*(b[1]-a[1])+cross(u,d)/den*(c[1]-a[1]))
 assert values
 return [min(values),max(values)]
def grade(f,label,station,width,d0,d1):
 rows=samples(f,station,width,d0,d1)
 poly=[x['xz']for x in rows[:4]];lb=complete_extrema(land,poly);ab=complete_extrema(area,poly)
 g=dict(label=label,station_m=station,width_m=width,outward_depth_m=[d0,d1],samples=rows,land_min_y=lb[0],land_max_y=lb[1],visible_max_y=ab[1],complete_affine_extrema=dict(LAND=lb,area=ab))
 grounds.append(g);return g

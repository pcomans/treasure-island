"""File geometry/grade/capture preflight; no engine, no native PASS claim."""
from pathlib import Path
import json,math,hashlib,ast,re,struct
W=Path(__file__).resolve().parent
R=Path('/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1237-1229-implementation-003/staged')
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
config_path=R/'game/resources/facades/northpoint_1237_study.json';cfg=json.loads(config_path.read_text());chunk=R/'generated/world/chunks/x_-1__z_-4.json';records=json.loads(chunk.read_text())['records'];wall=next(x for x in records if x['object_key']=='building:w96665904:wall')
ground_evidence=json.loads((W/'ground-footprints.json').read_text())
review_path=Path('/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/next-two-family-reference-preparation-002/independent-source-001/REVIEW.md')
checks=[]
def check(value,label):checks.append(dict(ok=bool(value),label=label))
def sub(a,b):return [x-y for x,y in zip(a,b)]
def add(a,b):return [x+y for x,y in zip(a,b)]
def mul(a,s):return [x*s for x in a]
def dot(a,b):return sum(x*y for x,y in zip(a,b))
def cross(a,b):return [a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
def unit(a):return mul(a,1/math.sqrt(dot(a,a)))
def verts(row):return [row['vertices'][i:i+3] for i in range(0,len(row['vertices']),3)]
def tris(row):
 v=verts(row);return [[v[i] for i in row['indices'][j:j+3]] for j in range(0,len(row['indices']),3)]
def height(triangles,x,z):
 hits=[]
 for i,(a,b,c) in enumerate(triangles):
  den=(b[2]-c[2])*(a[0]-c[0])+(c[0]-b[0])*(a[2]-c[2])
  if abs(den)<1e-12:continue
  u=((b[2]-c[2])*(x-c[0])+(c[0]-b[0])*(z-c[2]))/den;q=((c[2]-a[2])*(x-c[0])+(a[0]-c[0])*(z-c[2]))/den
  if min(u,q,1-u-q)>=-1e-7:hits.append((u*a[1]+q*b[1]+(1-u-q)*c[1],i))
 return max(hits) if hits else None
allchunks=[];solid=[];lands={};areas={}
manifest=json.loads((R/'generated/world/manifest.json').read_text())
for item in manifest['files']:
 if not item['path'].startswith('chunks/') or not item['path'].endswith('.json'):continue
 path=R/'generated/world'/item['path'];data=json.loads(path.read_text());allchunks.append((path,sha(path)))
 for row in data['records']:
  if row['collision_kind']=='world_solid':solid.append((row['object_key'],tris(row)))
  if row['feature_kind']=='land_ground':lands[row['object_key']]=tris(row)
  if row['object_key'] in cfg['ground']['sampled_area_keys']:areas[row['object_key']]=tris(row)
land=[t for k in cfg['ground']['sampled_land_keys'] for t in lands[k]];area=[t for k in cfg['ground']['sampled_area_keys'] for t in areas[k]]


bodies=[]
for key,triangles in solid:
 points=[p for t in triangles for p in t];bodies.append((key,triangles,[min(p[i] for p in points) for i in range(3)],[max(p[i] for p in points) for i in range(3)]))
def ray(origin,target,extension=0.0):
 delta=sub(target,origin);length=math.sqrt(dot(delta,delta));direction=unit(delta);target=add(target,mul(direction,extension));length+=extension;hits=[]
 for key,triangles,lo,hi in bodies:
  if any(max(origin[i],target[i])<lo[i]-.001 or min(origin[i],target[i])>hi[i]+.001 for i in range(3)):continue
  for i,(a,b,c) in enumerate(triangles):
   e1=sub(b,a);e2=sub(c,a);h=cross(direction,e2);det=dot(e1,h)
   if abs(det)<1e-9:continue
   inv=1/det;s=sub(origin,a);u=inv*dot(s,h)
   if u<0 or u>1:continue
   q=cross(s,e1);v=inv*dot(direction,q)
   if v<0 or u+v>1:continue
   t=inv*dot(e2,q)
   if 1e-6<t<=length+1e-6:hits.append((t,key,i))
 return min(hits) if hits else None

# TARGET_CHECKS
roof=next(x for x in records if x['object_key']=='building:w96665904:roof')
check(cfg['mapped_runs']==[1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13] and cfg['protected_runs']==[0, 8, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26],'Exact independent candidate and protected partition')
check(len(wall['vertices'])==324 and len(wall['indices'])==162 and len(roof['vertices'])==51 and len(roof['indices'])==45,'Exact target wall roof cardinality')
check(sha(review_path)==cfg['source_association']['sha256']=='834ab568a5da1bd689f3983594ac82d2f66b1fca7900aaa4798af1a142d10165','Accepted independent association pin')
for f in cfg['target']['frames']:
 check(abs(dot(f['tangent'],f['normal']))<1e-10,'Orthonormal target-local chord '+f['id'])
 for key in ['upper_windows','lower_windows','entries','screens']:
  for e in f[key]:
   half=e['width_m']/2+.11 if key!='screens' else e['width_m']/2
   check(e['local_station_m']-half>=0 and e['local_station_m']+half<=e['basis']['length_m'],f['id']+' complete '+key+' inside source run')
 for e in f['entries']:
  for sc in f['screens']:check(abs(e['station_m']-sc['station_m'])>(1.20+sc['width_m'])/2+.1,'Screen clears1.2m approach '+e['ground_label'])
for g in ground_evidence['samples']:
 for point in g['samples']:
  l=height(land,*point['xz']);a=height(area,*point['xz']);check(l is not None and a is not None and abs(l[0]-point['land_y'])<1e-8 and abs(a[0]-point['visible_area_y'])<1e-8,g['label']+' exact source ground samples')
for i,t in enumerate(cfg['public_roof']['triangles']):check(all(all(math.isfinite(x)for x in v)for v in t) and dot(cross(sub(t[1],t[0]),sub(t[2],t[0])),cross(sub(t[1],t[0]),sub(t[2],t[0])))>1e-12,'Nondegenerate roof cue '+str(i))
# Closed-strip outwardness independent of the emitter's supplied normals.
roof_triangles=cfg['public_roof']['triangles']+cfg['shallow_band']['triangles']+cfg['roof_termination']['triangles']
for start in range(0,len(roof_triangles),12):
 strip=roof_triangles[start:start+12];allv=[v for t in strip for v in t];interior=[sum(v[j]for v in allv)/len(allv)for j in range(3)]
 for i,t in enumerate(strip):
  normal=cross(sub(t[1],t[0]),sub(t[2],t[0]));center=[sum(v[j]for v in t)/3 for j in range(3)]
  check(dot(normal,sub(center,interior))>1e-10,'Closed roof outward normal and reversed Godot clockwise indices '+str(start+i))
meshes=[(e['ground_label'],e['path_mesh'])for f in cfg['target']['frames']for e in f['entries']]+list(cfg['local_ground'].items())
ground_rows=[]
for label,m in meshes:
 deltas=[]
 for tri in m['top_triangles']:
  for weights in [(1,0,0),(0,1,0),(0,0,1),(1/3,1/3,1/3)]:
   p=[sum(tri[i][j]*weights[i]for i in range(3))for j in range(3)];lh=height(land,p[0],p[2]);ah=height(area,p[0],p[2]);check(lh is not None and ah is not None,label+' frozen support coverage')
   if lh and ah:deltas.append([p[1]-lh[0],p[1]-ah[0]])
 ground_rows.append(dict(label=label,triangles=len(m['top_triangles']),above_land_range=[min(x[0]for x in deltas),max(x[0]for x in deltas)],above_area_range=[min(x[1]for x in deltas),max(x[1]for x in deltas)],collision='none'))
# Record source-only camera feasibility; actual spring arm, support and pixels remain native checks.
camera_rows=[]
for v in json.loads((W/'view-plan.json').read_text())['views']:
 x,z=v['xz'];g=height(land,x,z);check(g is not None,'Proposed player support '+v['id'])
 if g is None:continue
 pivot=[x,g[0]+2,z];forward=unit(sub(v['target'],pivot));camera=sub(pivot,mul(forward,5.5));under=height(land,camera[0],camera[2]);segment=ray(pivot,camera);hit=ray(camera,v['target'],.02)
 okay=under is not None and camera[1]-under[0]>.2 and segment is None and hit is not None and hit[1] in ['building:w96665904:wall','building:w96665904:roof'];check(okay,'Source-only stock-camera placement '+v['id']);camera_rows.append(dict(id=v['id'],camera=camera,target_hit=hit,segment_hit=segment,source_camera_clear=okay))
result=dict(ok=all(x['ok']for x in checks),scope='Bounded file geometry/ground/source-camera preflight only; no native runtime or independent acceptance',checks=checks,failures=[x['label']for x in checks if not x['ok']],ground_meshes=ground_rows,camera_preflight=camera_rows,input_hashes={str(p):sha(p)for p in [config_path,chunk,review_path,W/'ground-footprints.json',W/'roof-ground-layout.json',W/'view-plan.json']})
(W/'PREFLIGHT_RESULT.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({k:result[k]for k in ['ok','failures','ground_meshes','camera_preflight']},indent=2))

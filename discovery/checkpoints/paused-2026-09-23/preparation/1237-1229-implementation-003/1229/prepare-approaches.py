"""Eight1221 paths, clipped to frozen LAND and joined to Mariner road edge."""
from pathlib import Path
import json,math,hashlib,collections
W=Path(__file__).resolve().parent
R=Path('/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1237-1229-implementation-003/staged')
ORIGINAL=R/'game/resources/facades'
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
rows=json.loads((R/'generated/world/chunks/x_-2__z_-4.json').read_text())['records']
records={x['object_key']:x for x in rows}
adj=json.loads((R/'generated/world/chunks/x_-1__z_-4.json').read_text())['records']
def merge(prefix):
 out=dict(object_key=prefix,vertices=[],indices=[],source_keys=[])
 for row in rows+adj:
  if not row['object_key'].startswith(prefix):continue
  off=len(out['vertices'])//3;out['vertices']+=row['vertices'];out['indices'] += [i+off for i in row['indices']];out['source_keys']+=row.get('source_keys',[])
 return out
land=merge('land:w26767313:');area=merge('area:r17241151:');road=merge('roads:')
cfg=json.loads((ORIGINAL/'northpoint_1229_study.json').read_text())
def cross(a,b):return a[0]*b[1]-a[1]*b[0]
def sub(a,b):return [a[0]-b[0],a[1]-b[1]]
def tris(record):
 v=record['vertices'];return [[v[i*3:i*3+3] for i in record['indices'][j:j+3]] for j in range(0,len(record['indices']),3)]
lt=tris(land);at=tris(area);rt=tris(road)
def sample(triangles,p):
 hit=[]
 for j,(a,b,c) in enumerate(triangles):
  den=(b[2]-c[2])*(a[0]-c[0])+(c[0]-b[0])*(a[2]-c[2])
  if abs(den)<1e-12:continue
  u=((b[2]-c[2])*(p[0]-c[0])+(c[0]-b[0])*(p[1]-c[2]))/den
  v=((c[2]-a[2])*(p[0]-c[0])+(a[0]-c[0])*(p[1]-c[2]))/den
  if min(u,v,1-u-v)>=-2e-8:hit.append((u*a[1]+v*b[1]+(1-u-v)*c[1],j))
 return max(hit) if hit else None
def ccw(poly):
 return poly if sum(cross(poly[i],poly[(i+1)%len(poly)]) for i in range(len(poly)))>0 else list(reversed(poly))
def clip(poly,fn):
 out=[]
 for i,a in enumerate(poly):
  b=poly[(i+1)%len(poly)];fa=fn(a);fb=fn(b);ina=fa>=-1e-9;inb=fb>=-1e-9
  if ina:out.append(a)
  if ina!=inb:
   t=fa/(fa-fb);out.append([a[0]+(b[0]-a[0])*t,a[1]+(b[1]-a[1])*t])
 clean=[]
 for p in out:
  if not clean or math.dist(clean[-1],p)>1e-7:clean.append(p)
 if len(clean)>1 and math.dist(clean[0],clean[-1])<1e-7:clean.pop()
 return clean

def interval(p,n,tri):
 poly=ccw([[v[0],v[2]] for v in tri]);lo=0.;hi=24.
 for i,a in enumerate(poly):
  b=poly[(i+1)%3];edge=sub(b,a);c=cross(edge,sub(p,a));s=cross(edge,n)
  if abs(s)<1e-12:
   if c < -1e-8:return None
  elif s>0:lo=max(lo,-c/s)
  else:hi=min(hi,-c/s)
 if hi>=lo-1e-8:return lo,hi
 return None

def road_entry(p,n):
 # A point-tangent triangle has no road interior: exclude zero-width intervals.
 intervals=[(v[0],v[1],i) for i,t in enumerate(rt) if (v:=interval(p,n,t)) is not None and v[1]-v[0]>1e-6]
 intervals.sort();assert intervals and intervals[0][0]>1.0
 entry=intervals[0][0];exit=intervals[0][1];ids=[intervals[0][2]]
 for a,b,i in intervals[1:]:
  if a>exit+1e-6:break
  exit=max(exit,b);ids.append(i)
 return dict(entry_depth_m=entry,exit_depth_m=exit,road_triangles=ids)

def point(frame,station,depth):
 return [frame['start'][0]+frame['tangent'][0]*station+frame['normal'][0]*depth,frame['start'][2]+frame['tangent'][2]*station+frame['normal'][2]*depth]

evidence=[];top_count=0
for frame in cfg['target']['frames']:
 for entry in frame['entries']:
  center=entry['station_m'];width=1.32;s0=center-width/2;s1=center+width/2;n=[frame['normal'][0],frame['normal'][2]]
  assoc=[]
  for station in [s0,center,s1]:
   p=point(frame,station,0);hit=road_entry(p,n);edge=point(frame,station,hit['entry_depth_m']);inside=point(frame,station,hit['entry_depth_m']+.02)
   hit.update(station_m=station,edge_xz=edge,overlap_endpoint_xz=inside,land_at_edge=sample(lt,edge),area_at_edge=sample(at,edge),road_at_edge=sample(rt,edge),overlap_land=sample(lt,inside),overlap_road=sample(rt,inside))
   assoc.append(hit)
  d0=assoc[0]['entry_depth_m'];d1=assoc[2]['entry_depth_m']
  domain=ccw([point(frame,s0,.12),point(frame,s1,.12),point(frame,s1,d1+.02),point(frame,s0,d0+.02)])
  start=[frame['start'][0],frame['start'][2]];tangent=[frame['tangent'][0],frame['tangent'][2]]
  def station(p):return sum(x*y for x,y in zip(sub(p,start),tangent))
  def depth(p):return sum(x*y for x,y in zip(sub(p,start),n))
  def boundary_depth(p):return d0+(d1-d0)*(station(p)-s0)/width
  def q(p):return depth(p)-boundary_depth(p)
  def xyz(p):
   h=sample(lt,p);assert h is not None
   alpha=max(0.,min(1.,(q(p)+.75)/.75))
   return [round(p[0],6),round(h[0]+.024+.058*alpha,6),round(p[1],6)]
  polygons=[]
  for index,triangle in enumerate(lt):
   polygon=domain[:];tri2=ccw([[p[0],p[2]] for p in triangle])
   for i,a in enumerate(tri2):
    b=tri2[(i+1)%3];polygon=clip(polygon,lambda p,a=a,b=b:cross(sub(b,a),sub(p,a)))
    if len(polygon)<3:break
   if len(polygon)<3:continue
   # Split at start/end of a 75cm visual bias transition into existing road skin.
   for low,high in [(None,-.75),(-.75,0.),(0.,None)]:
    part=polygon[:]
    if low is not None:part=clip(part,lambda p,low=low:q(p)-low)
    if len(part)<3:continue
    if high is not None:part=clip(part,lambda p,high=high:high-q(p))
    if len(part)<3:continue
    if abs(sum(cross(part[i],part[(i+1)%len(part)]) for i in range(len(part))))<1e-8:continue
    polygons.append((index,part))
  tops=[]
  for _,poly in polygons:
   for j in range(1,len(poly)-1):
    triangle=[xyz(poly[0]),xyz(poly[j]),xyz(poly[j+1])]
    if abs(cross(sub([triangle[1][0],triangle[1][2]],[triangle[0][0],triangle[0][2]]),sub([triangle[2][0],triangle[2][2]],[triangle[0][0],triangle[0][2]])))>1e-8:tops.append(triangle)
  boundary=[]
  candidates=[p for _,poly in polygons for p in poly]
  for i,a in enumerate(domain):
   b=domain[(i+1)%4];edge=sub(b,a);length2=sum(v*v for v in edge)
   items=[(0.,a),(1.,b)]
   for p in candidates:
    f=sum(x*y for x,y in zip(sub(p,a),edge))/length2
    if -1e-7<=f<=1+1e-7 and abs(cross(edge,sub(p,a)))<1e-6:items.append((max(0,min(1,f)),p))
   unique={round(f,9):p for f,p in items}
   ordered=sorted(unique.items())
   for j in range(len(ordered)-1):
    a3=xyz(ordered[j][1]);b3=xyz(ordered[j+1][1])
    if math.dist(a3,b3)>1e-6:boundary.append([a3,b3])
  mesh=dict(top_triangles=tops,boundary_segments=boundary,thickness_m=.04)
  entry.pop('path_corners');entry['path_mesh']=mesh
  entry['path_connection']=dict(source_surface='roads:x_-2__z_-4',source_way='pending_actual_OSM_edge_association',source_name='pending_actual_OSM_edge_association',sidewalk_caveat='No separate pedestrian strip intersects these eight approaches in the frozen source.',width_m=width,outward_start_m=.12,edge_depths_m=[x['entry_depth_m'] for x in assoc],overlap_m=.02,visual_transition_length_m=.75,collision='none')
  vertices={tuple(v) for tri in tops for v in tri};checks=[]
  for tri in tops:
   for weights in [(1,0,0),(0,1,0),(0,0,1),(1/3,1/3,1/3)]:
    p=[sum(tri[i][j]*weights[i] for i in range(3)) for j in range(3)];xz=[p[0],p[2]];lh=sample(lt,xz);ah=sample(at,xz);rh=sample(rt,xz)
    checks.append(dict(xyz=p,land=lh,area=ah,road=rh,above_land_m=p[1]-lh[0],above_area_m=p[1]-ah[0],above_road_m=None if rh is None else p[1]-rh[0],expected_surface_y=xyz(xz)[1]))
  evidence.append(dict(entry=entry['ground_label'],source_chain=frame['runs'],source_road=road['object_key'],source_road_kind=road['feature_kind'],source_road_collision=road['collision_kind'],road_source_keys=road['source_keys'],associations=assoc,old_outward_end_m=2.75,new_outward_ends_m=[d0+.02,d1+.02],top_triangle_count=len(tops),boundary_segment_count=len(boundary),sampled_vertices_and_centroids=checks))
  top_count+=len(tops)
record=dict(scope='Eight render-only 1221 approaches to the actual generated Mariner road edge; no separately generated sidewalk here.',source_chunk_sha256=sha(R/'generated/world/chunks/x_-2__z_-4.json'),land_key=land['object_key'],area_key=area['object_key'],road_key=road['object_key'],original_001_grade_sha256=sha(W/'ground-footprints.json'),paths=evidence,terrain_collision_unchanged=True,visual_bias_transition='Base path LAND+24mm, last75cm blends to existing road LAND+78mm plus4mm visual separation; not a new colliding landing/stair.')
(W/'approach-ground-evidence.json').write_text(json.dumps(record,indent=2)+'\n')
cfg['ground']['evidence_sha256']=sha(W/'approach-ground-evidence.json')
cfg['ground']['paths']='Eight narrow render-only approaches triangulated on actual LAND, ending20mm inside the existing generated Mariner road boundary; source surfaces untouched.'
(R/'game/resources/facades/northpoint_1229_study.json').write_text(json.dumps(cfg,indent=2)+'\n')
print(json.dumps({'eight_paths':len(evidence),'top_triangles':top_count,'edge_depths':{x['entry']:x['new_outward_ends_m'] for x in evidence},'palette':cfg['materials']['siding_rgb']},indent=2))

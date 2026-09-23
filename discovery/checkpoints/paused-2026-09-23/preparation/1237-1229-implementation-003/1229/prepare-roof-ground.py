"""1221-only public roof bands and observed entry/footway/parking layout; no engine."""
from pathlib import Path
import json,math,collections,hashlib,struct,xml.etree.ElementTree as ET
W=Path(__file__).resolve().parent;R=Path('/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1237-1229-implementation-003/staged');config=R/'game/resources/facades/northpoint_1229_study.json'
# Reuse exact working LAND clipping/road ray primitives without running the eight-path donor.
s=(W/'prepare-approaches.py').read_text();ns={'__file__':str(W/'prepare-approaches.py')};exec(s[:s.index('evidence=[];top_count=0')],ns)
cfg=json.loads(config.read_text());clip,ccw,sample,cross,sub,road_entry=[ns[x]for x in ['clip','ccw','sample','cross','sub','road_entry']];lt,at,rt=ns['lt'],ns['at'],ns['rt']
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
f=cfg['target']['frames'][1];origin=[f['start'][0],f['start'][2]];t=[f['tangent'][0],f['tangent'][2]];n=[f['normal'][0],f['normal'][2]]
def P(s,d):return [origin[i]+t[i]*s+n[i]*d for i in range(2)]
def S(p):return sum((p[i]-origin[i])*t[i]for i in range(2))
def D(p):return sum((p[i]-origin[i])*n[i]for i in range(2))
def localpoint(frame,s,d):return [frame['start'][0]+frame['tangent'][0]*s+frame['normal'][0]*d,frame['start'][2]+frame['tangent'][2]*s+frame['normal'][2]*d]
start=S([cfg['target']['frames'][0]['start'][i]for i in [0,2]])+.35;end=S([cfg['target']['frames'][-1]['end'][i]for i in [0,2]])-.35
walk_near=3.0;walk_far=4.15
# Target source-road corner steps require the finite measured buried overlap.
overlap_m=None # assigned from this target's actual source-road sections below
# Break only where the actual road triangulation can change its first edge.
breaks={start,end}
for tri in rt:
 for v in tri:
  p=[v[0],v[2]];station=S(p)
  if start<station<end and 0<D(p)<24:breaks.add(station)
# One-sided edge sections avoid interpolating across a road-corner point touch.
# Between projected source vertices, the controlling triangle edge is affine.
profile=[]
for left,right in zip(sorted(breaks),sorted(breaks)[1:]):
 width=right-left
 if width<=1e-7:continue
 q0=left+width*.25;q1=left+width*.75
 h0=road_entry(P(q0,0),n);h1=road_entry(P(q1,0),n)
 slope=(h1['entry_depth_m']-h0['entry_depth_m'])/(q1-q0)
 for station,hit in [(left,h0),(right,h1)]:
  depth=h0['entry_depth_m']+slope*(station-q0)
  profile.append(dict(station_m=station,**{**hit,'entry_depth_m':depth},edge_xz=P(station,depth),edge_section_m=[left,right]))
# Actual native coordinate scale and measured corner jumps determine overlap.
max_jump=max((abs(a['entry_depth_m']-b['entry_depth_m'])for a,b in zip(profile,profile[1:])if abs(a['station_m']-b['station_m'])<1e-7),default=0.)
coordinate_ulp_m=2.**(math.floor(math.log2(max(abs(x)for row in profile for x in row['edge_xz'])))-23)
max_edge_slope=max(abs((b['entry_depth_m']-a['entry_depth_m'])/(b['station_m']-a['station_m']))for a,b in zip(profile,profile[1:])if b['station_m']-a['station_m']>1e-7)
# Steep corner edges amplify Float32 station error; include that measured slope.
overlap_m=math.ceil((max_jump+4*coordinate_ulp_m*(1+max_edge_slope)+.001)*1000)/1000
# Actual source-way association, independent of a nearby map overlay label.
osm=ET.parse(R/'data/osm/treasure-island-2026-08-27.osm').getroot();nodes={x.attrib['id']:x for x in osm.findall('node')};ways={}
for way in osm.findall('way'):
 key='w'+way.attrib['id']
 if key not in ns['road']['source_keys']:continue
 tags={x.attrib['k']:x.attrib['v']for x in way.findall('tag')};points=[]
 for nd in way.findall('nd'):
  node=nodes[nd.attrib['ref']];lat=float(node.attrib['lat']);lon=float(node.attrib['lon']);points.append([6378137*math.radians(lon+122.37099)*math.cos(math.radians(37.82376155)),-6378137*math.radians(lat-37.82376155)])
 ways[key]=(tags,points)
def distance(p,a,b):
 v=sub(b,a);q=max(0,min(1,sum(x*y for x,y in zip(sub(p,a),v))/sum(x*x for x in v)));return math.dist(p,[a[i]+q*v[i]for i in range(2)])
for row in profile:
 hits=[]
 for key,(tags,points)in ways.items():
  hits.append((min(distance(row['edge_xz'],a,b)for a,b in zip(points,points[1:])),key,tags.get('name',''),tags.get('highway','')))
 dist,key,name,kind=min(hits);row.update(nearest_source_way=key,source_name=name,highway=kind,edge_to_centerline_m=dist)
# Bind this target's road edge to frozen source ribbons; retain aggregate
# triangle ownership rather than importing another site's nearby-path claim.
widths={'tertiary':8,'residential':6,'unclassified':6,'service':4,'pedestrian':4,'track':3,'cycleway':3,'platform':3,'footway':2,'path':2}
for row in profile:
 supporting=[]
 for key,(tags,points) in ways.items():
  dist=min(distance(row['edge_xz'],a,b) for a,b in zip(points,points[1:]))
  width=widths.get(tags.get('highway',''),6)
  if dist<=width/2+.003: supporting.append(dict(source_way=key,name=tags.get('name',''),highway=tags.get('highway',''),centerline_distance_m=dist,half_width_m=width/2))
 edge_hit=sample(rt,row['edge_xz']); inward=[row['edge_xz'][i]+n[i]*.001 for i in range(2)]; inward_hit=sample(rt,inward)
 assert supporting and (edge_hit is not None or inward_hit is not None),(row,supporting)
 row.update(exact_edge_sample=edge_hit,inward_1mm_sample=inward_hit,inward_1mm_xz=inward)
 row.update(supporting_source_ribbons=supporting,attribution='Actual aggregate road triangle boundary; candidate source ribbons from frozen width semantics, no per-triangle way metadata')

# Convex regions are clipped at every actual LAND plane and optional road-bias break.
def drape(regions):
 triangles=[]
 for domain,edge_fn in regions:
  domain=ccw(domain)
  def xyz(p):
   h=sample(lt,p);assert h
   alpha=0. if edge_fn is None else max(0.,min(1.,(D(p)-edge_fn(p)+.75)/.75))
   return [round(p[0],6),round(h[0]+.024+.058*alpha,6),round(p[1],6)]
  for triangle in lt:
   polygon=domain[:];tri2=ccw([[v[0],v[2]]for v in triangle])
   for i,a in enumerate(tri2):
    b=tri2[(i+1)%3];polygon=clip(polygon,lambda p,a=a,b=b:cross(sub(b,a),sub(p,a)))
    if len(polygon)<3:break
   if len(polygon)<3:continue
   parts=[polygon]
   if edge_fn is not None:
    parts=[]
    for low,high in [(None,-.75),(-.75,0.),(0.,None)]:
     part=polygon[:]
     if low is not None:part=clip(part,lambda p,low=low:D(p)-edge_fn(p)-low)
     if len(part)>=3 and high is not None:part=clip(part,lambda p,high=high:high-D(p)+edge_fn(p))
     if len(part)>=3:parts.append(part)
   for part in parts:
    for i in range(1,len(part)-1):
     tri=[xyz(part[0]),xyz(part[i]),xyz(part[i+1])]
     if abs(cross(sub([tri[1][0],tri[1][2]],[tri[0][0],tri[0][2]]),sub([tri[2][0],tri[2][2]],[tri[0][0],tri[0][2]])))>1e-8:triangles.append(tri)
 counts=collections.Counter();directed={}
 for tri in triangles:
  for i,a in enumerate(tri):
   b=tri[(i+1)%3];key=tuple(sorted((tuple(a),tuple(b))));counts[key]+=1;directed[key]=[a,b]
 assert all(c<=2 for c in counts.values())
 boundary=[directed[k]for k,c in counts.items()if c==1]
 return dict(top_triangles=triangles,boundary_segments=boundary,thickness_m=.04)

walk=drape([([P(start,walk_near),P(end,walk_near),P(end,walk_far),P(start,walk_far)],None)])
parking_regions=[]
for a,b in zip(profile,profile[1:]):
 s0=a['station_m'];s1=b['station_m'];d0=a['entry_depth_m'];d1=b['entry_depth_m']
 if s1-s0<=1e-7:continue
 if s0>=end:continue
 s1=min(s1,end);d1=d0+(d1-d0)*(s1-s0)/(b['station_m']-a['station_m'])
 edge=lambda p,s0=s0,s1=s1,d0=d0,d1=d1:d0+(d1-d0)*(S(p)-s0)/(s1-s0)
 parking_regions.append(([P(s0,walk_far),P(s1,walk_far),P(s1,d1+overlap_m),P(s0,d0+overlap_m)],edge))
parking=drape(parking_regions)
# Reuse K's source-road overlap solution only on this freshly sampled outer rim.
# This changes repeated Y values only; the actual burial and exposed surface
# clearances are checked from final Float32 triangles before FILE_READY.
outer={}
for segment in parking['boundary_segments']:
 for vertex in segment:
  xz=[vertex[0],vertex[2]];station=S(xz)
  for a,b in zip(profile,profile[1:]):
   if b['station_m']-a['station_m']>1e-7 and a['station_m']-1e-5<=station<=b['station_m']+1e-5:
    edge=a['entry_depth_m']+(b['entry_depth_m']-a['entry_depth_m'])*(station-a['station_m'])/(b['station_m']-a['station_m'])
    if abs(D(xz)-edge-overlap_m)<1e-5:
     hit=sample(rt,xz);assert hit is not None,dict(xz=xz,station=station,depth=D(xz),edge=edge,profile_interval=[a,b],actual_road_entry=road_entry(P(station,0),n))
     outer[tuple(vertex)]=[vertex[0],round(hit[0]-.002,6),vertex[2]]
assert outer
rim_changes=[dict(before=list(a),after=b,road=sample(rt,[a[0],a[2]]))for a,b in outer.items()]
parking['top_triangles']=[[outer.get(tuple(v),v)for v in tri]for tri in parking['top_triangles']]
parking['boundary_segments']=[[outer.get(tuple(v),v)for v in segment]for segment in parking['boundary_segments']]

# Actual1221 narrow road-profile sections can collapse at native coordinates.
# Remove only collapsed/duplicate added parking triangles and derive its skin
# boundary from those same surviving Float32 tops before the common skirt emitter.
F=lambda x:struct.unpack('<f',struct.pack('<f',x))[0]
original_parking_top_count=len(parking['top_triangles']);native_tops=[];seen=set()
for tri in parking['top_triangles']:
 nt=[tuple(F(x)for x in v)for v in tri]
 area=abs(cross(sub([nt[1][0],nt[1][2]],[nt[0][0],nt[0][2]]),sub([nt[2][0],nt[2][2]],[nt[0][0],nt[0][2]])))
 key=tuple(sorted(nt))
 if area<=1e-8 or key in seen:continue
 seen.add(key);native_tops.append([list(v)for v in nt])
counts=collections.Counter();directed={}
for tri in native_tops:
 for i,a in enumerate(tri):
  b=tri[(i+1)%3];key=tuple(sorted((tuple(a),tuple(b))));counts[key]+=1;directed[key]=[a,b]
assert all(c<=2 for c in counts.values())
parking['top_triangles']=native_tops
parking['boundary_segments']=[directed[k]for k,c in counts.items()if c==1]
parking['native_cleanup']={'original_top_triangles':original_parking_top_count,'surviving_top_triangles':len(native_tops),'scope':'Only collapsed/duplicate added parking triangles; no source world triangle changed.'}

entries=[]
for frame in cfg['target']['frames']:
 for entry in frame['entries']:
  station=entry['local_station_m'];basis=entry['basis'];width=1.20;ends=[];corners=[]
  for s in [station-width/2,station+width/2]:
   atwall=localpoint(basis,s,0);normal=[basis['normal'][0],basis['normal'][2]];depth=(walk_near-D(atwall))/sum(x*y for x,y in zip(normal,n));ends.append(depth)
   corners.append(localpoint(basis,s,.12));corners.append(localpoint(basis,s,depth))
  domain=[corners[0],corners[2],corners[3],corners[1]];entry.pop('path_corners',None);entry['path_mesh']=drape([(domain,None)])
  entry['path_connection']=dict(kind='1221_inferred_continuous_footway',width_m=width,outward_start_m=.12,end_depths_m=ends,walk_global_depth_m=walk_near,road_source_way=profile[0]['nearest_source_way'],road_name=profile[0]['source_name'],boundary_status='production_inference supported by visible footway/parking hierarchy; source OSM has no separate pedestrian/parking surface here',collision='none')
  entries.append(dict(label=entry['ground_label'],domain_xz=domain,end_depths_m=ends))
cfg['local_ground']={'FootwaySurface':walk,'ParkingSurface':parking}
cfg['ground']['paths']='Four narrow actual-grade entries meet one continuous observed-type footway, then a bounded parking surface meets exact generated Mariner road; unobserved source ground beyond the bounded frontage is retained. All added ground render-only; boundary dimensions are production inference.'
cfg['materials']['parking_rgb']=[.54,.55,.52];cfg['materials']['footway_rgb']=[.65,.65,.59]

# Joined roof is authored separately from the exact source footprint. No three-prism caps.
roof_bands=[];roof_triangles=[]
layout=dict(source_chunk_sha256=sha(R/'generated/world/chunks/x_-2__z_-4.json'),source_osm_sha256=sha(R/'data/osm/treasure-island-2026-08-27.osm'),global_frame=dict(origin_xz=origin,tangent_xz=t,normal_xz=n,station_limits_m=[start,end],footway_depth_m=[walk_near,walk_far]),source_road_profile=profile,entries=entries,source_collision_unchanged=True,ground_source_chunks=["x_-2__z_-4","x_-1__z_-4"],parking_outer_rim_changes=rim_changes,parking_overlap_m=overlap_m,road_corner_max_jump_m=max_jump,road_edge_max_depth_per_station=max_edge_slope,native_coordinate_ulp_m=coordinate_ulp_m,ground_top_triangles=dict(footway=len(walk['top_triangles']),parking=len(parking['top_triangles']),entries=sum(len(e['path_mesh']['top_triangles'])for f in cfg['target']['frames']for e in f['entries'])),roof_bands=roof_bands,scope='First coherent1221-only source/ground/roof geometry; no engine/native/visual acceptance')
(W/'roof-ground-layout.json').write_text(json.dumps(layout,indent=2)+'\n');cfg['ground']['layout_evidence_sha256']=sha(W/'roof-ground-layout.json');cfg['ground'].pop('evidence_sha256',None);cfg['ground']['footprint_evidence_sha256']=sha(W/'ground-footprints.json');config.write_text(json.dumps(cfg,indent=2)+'\n')
print(json.dumps(dict(road_way=profile[0]['nearest_source_way'],road_name=profile[0]['source_name'],edge_profile_vertices=len(profile),ground_top_triangles=layout['ground_top_triangles'],roof_triangles=len(roof_triangles),path_depths={x['label']:x['end_depths_m']for x in entries}),indent=2))

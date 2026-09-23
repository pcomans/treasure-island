from pathlib import Path
import json,math,runpy,hashlib
W=Path(__file__).resolve().parent;R=Path('/Volumes/Macintosh_HD/Users/user302070/code/treasure-island-1237-1229-study-v1')
q=runpy.run_path(str(W/'prepare-target-queries.py'))
sub,add,mul,dot,cross,unit,tris,height=[q[k]for k in ['sub','add','mul','dot','cross','unit','tris','height']]
ns=dict(globals());donor=(W.parent/'1221-mechanics-001/route-preflight.py').read_text();exec(donor[donor.index('def length(v):'):donor.index('capsule_radius=.35;')],ns)
def assess(context,spec):
 cfg=context['cfg'];native=context['actual'];source_solids=context['solids'];f=spec['frame'];aim=spec['target'];cam=spec['camera'];foot=cam['player'];hit=spec['first_hit'];ns['land']=context['land']
 centre=hit['position'];normal=unit(hit['normal'])
 # Godot's actual front ray normal faces the camera; raw triangle cross product has opposite winding here.
 if dot(normal,sub(cam['camera'],centre))<0:normal=mul(normal,-1)
 right=unit(cross(normal,[0,1,0]));up=unit(cross(right,normal))
 axes=[right,up,normal];ranges=[[-.6,.6],[-.325,.325],[-.025,.055]]
 def clip(poly,origin,axis,limit):
  out=[]
  if not poly:return out
  prev=poly[-1];pd=dot(sub(prev,origin),axis)-limit
  for q in poly:
   qd=dot(sub(q,origin),axis)-limit
   if (qd>=0)!=(pd>=0):out.append(add(prev,mul(sub(q,prev),pd/(pd-qd))))
   if qd>=0:out.append(q)
   prev=q;pd=qd
  return out
 def area(poly,a=right,b=up):
  uv=[[dot(sub(q,centre),a),dot(sub(q,centre),b)]for q in poly]
  return abs(sum(uv[i][0]*uv[(i+1)%len(uv)][1]-uv[(i+1)%len(uv)][0]*uv[i][1]for i in range(len(uv)))/2)if len(uv)>2 else 0
 def boxclip(t):
  p=t
  for axis,interval in zip(axes,ranges):
   p=clip(p,centre,axis,interval[0]);p=clip(p,centre,mul(axis,-1),-interval[1])
  return p
 # Check the whole image-plane cone, not only centre/corner rays. Stop before the receiving skin at normal .010m.
 skin_centre=centre
 corners=[add(add(skin_centre,mul(right,a)),mul(up,b))for a,b in [(-.6,-.325),(.6,-.325),(.6,.325),(-.6,.325)]]
 camera=cam['camera'];planes=[]
 for i,q in enumerate(corners):
  axis=unit(cross(sub(q,camera),sub(corners[(i+1)%4],camera)))
  if dot(sub(skin_centre,camera),axis)<0:axis=mul(axis,-1)
  planes.append((camera,axis,0))
 planes.extend([(centre,normal,.001),(camera,mul(normal,-1),.001)])
 def coneclip(t):
  p=t
  for origin,axis,limit in planes:p=clip(p,origin,axis,limit)
  return p
 meshes=[]
 for label,m in native['meshes'].items():
  if label.startswith('Exact'):continue
  meshes.append((label,[[m['vertices'][i]for i in m['indices'][n:n+3]]for n in range(0,len(m['indices']),3)]))
 boxhits=[];conehits=[];skin_area=0
 for label,triangles in meshes:
  for index,t in enumerate(triangles):
   poly=boxclip(t);a=area(poly)
   if a>1e-9:
    boxhits.append({'label':label,'triangle':index,'projected_overlap_m2':a,'y_range':[min(q[1]for q in poly),max(q[1]for q in poly)]})
    if label=='ProjectedUpperSiding' and abs(sum(dot(sub(q,centre),normal)for q in t)/3)<.001:skin_area+=a
   poly=coneclip(t);a=area(poly)
   if a>1e-9:conehits.append({'label':label,'triangle':index,'projected_overlap_m2':a,'y_range':[min(q[1]for q in poly),max(q[1]for q in poly)]})
 # All source records, including noncolliding visible areas/roads, filtered only by full cone bounds.
 cone_points=[camera,*corners];bounds=[[min(q[i]for q in cone_points)-.001,max(q[i]for q in cone_points)+.001]for i in range(3)]
 world_candidates=0;world_tris=0
 for item in json.loads((R/'generated/world/manifest.json').read_text())['files']:
  if not item['path'].startswith('chunks/')or not item['path'].endswith('.json'):continue
  for row in json.loads((R/'generated/world'/item['path']).read_text())['records']:
   for index,t in enumerate(tris(row)):
    if any(max(q[i]for q in t)<bounds[i][0]or min(q[i]for q in t)>bounds[i][1]for i in range(3)):continue
    world_tris+=1;poly=coneclip(t);a=area(poly)
    if a>1e-9:conehits.append({'label':row['object_key'],'triangle':index,'projected_overlap_m2':a})
 # Projection is offset from source wall; bind the whole rectangle to the actual observed local run interval.
 stations=[dot(sub(q,f['start']),f['tangent'])for q in corners]
 run_coverage=[{'runs':f['runs'],'station_interval_m':[min(stations),max(stations)],'source_length_m':f['length_m'],'covered_area_m2':skin_area}]
 forward=unit(sub(aim,camera));cr=unit(cross(forward,[0,1,0]));cu=cross(cr,forward)
 pixels=[]
 for q in corners:
  d=sub(q,camera);z=dot(d,forward);pixels.append([720+450*dot(d,cr)/z/math.tan(math.radians(35)),450-450*dot(d,cu)/z/math.tan(math.radians(35))])
 distance=math.sqrt(dot(sub(centre,foot),sub(centre,foot)))
 # Single static stock-capsule versus actual LAND and solids. No route or trace loop is executed.

 low=add(foot,[0,.35,0]);high=add(foot,[0,1.45,0]);nearest_land=min(ns['segment_triangle'](low,high,*t)for t in ns['land'])-.35
 nearest_solid=[]
 for body in source_solids:
  if body['key'].startswith('land:'):continue
  if any(body['bounds'][i][1]<min(low[i],high[i])-.43 or body['bounds'][i][0]>max(low[i],high[i])+.43 for i in range(3)):continue
  d=min(ns['segment_triangle'](low,high,*t)for t in body['triangles'])-.35
  nearest_solid.append({'key':body['key'],'role':body['role'],'clearance_m':d})
 expected_runs=cfg['mapped_runs']
 checks=[{'label':'Complete .78m2 mapped receiving skin within projection depth','ok':abs(skin_area-.78)<.0001},{'label':'Whole source receiver rectangle covered by exact observed run','ok':len(run_coverage)==1 and all(run in expected_runs for run in run_coverage[0]['runs']) and min(stations)>=0 and max(stations)<=f['length_m'] and abs(run_coverage[0]['covered_area_m2']-.78)<.0001},{'label':'Only mapped siding intersects full projection box','ok':all(x['label']=='ProjectedUpperSiding'for x in boxhits)},{'label':'Entire camera-to-skin rectangle cone clear of all target and relevant world triangles','ok':not conehits},{'label':'Whole tag rectangle framed at stock FOV70','ok':all(0<x<1440 and 0<y<900 for x,y in pixels)},{'label':'Stock camera segment and actual LAND clearance','ok':cam['segment_hit']is None and cam['clearance']>.1 and -60<cam['pitch']<25},{'label':'Player to receiver range below5.7/6m','ok':distance<5.7},{'label':'Static capsule LAND qualification and no nearby source/detail penetration','ok':nearest_land>=-.002 and all(x['clearance_m']>=0 for x in nearest_solid)}]

 return {'ok':all(x['ok']for x in checks),'checks':checks,'box_intersections':boxhits,'cone_intersections':conehits,'skin_area_m2':skin_area,'source_run_coverage':run_coverage,'range_m':distance,'corners':corners,'camera':cam,'capsule_land_clearance_m':nearest_land,'nearby_solids':nearest_solid,'spec':spec}
for target,context in q['contexts'].items():
 candidates=[x for x in context['spray_rows']if x['role']=='ProjectedUpperSiding'and x['query_feasible']]
 results=[]
 for candidate in candidates:
  result=assess(context,candidate);results.append(result)
  if result['ok']:break
 data={'ok':bool(results)and results[-1]['ok'],'attempts':results,'scope':'Full stock decal box and view cone, actual002 meshes and frozen world. File proposal only.'}
 (W/target/'FOOTPRINT_PREFLIGHT.json').write_text(json.dumps(data,indent=2)+'\n')
 print(target,'footprint',data['ok'],[[x['label']for x in r['checks']if not x['ok']]for r in results])

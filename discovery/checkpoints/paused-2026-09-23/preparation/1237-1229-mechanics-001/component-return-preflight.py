from pathlib import Path
import json,math,runpy
W=Path(__file__).resolve().parent
q=runpy.run_path(str(W/'prepare-target-queries.py'))
sub,add,mul,dot,cross,unit,height=[q[k] for k in ['sub','add','mul','dot','cross','unit','height']]
ns=dict(globals());donor=(W.parent/'1221-mechanics-001/route-preflight.py').read_text();exec(donor[donor.index('def length(v):'):donor.index('capsule_radius=.35;')],ns);segment_triangle=ns['segment_triangle']
def simulate(normal,phases):
 p=[0.,0.,0.];v=[0.,0.,0.];rows=[]
 for actions,n in phases:
  speed=20 if 'run'in actions else 4 if actions else 0
  for _ in range(n):
   for j in [0,2]:
    goal=normal[j]*speed;step=(30 if actions else 40)/60;v[j]+=max(-step,min(step,goal-v[j]));p[j]+=v[j]/60
   rows.append({'offset':p.copy(),'velocity':v.copy(),'actions':actions})
 return rows
for t,c in q['contexts'].items():
 plan=json.loads((W/t/'route-plan.json').read_text());evidence=[];failures=[]
 for route in plan['routes']:
  f=route['frame'];normal=f['normal'];stop=route['expected_block_depth_m'];station=route['station_m'];entry=route['retreat']['expected_road_membership'];wanted=route['start_depth_m']-stop if entry else 1.5
  # Walk beyond observed entry enclosure/canopy post junction before stock run acceleration.
  walk_clear_depth=9.0 if t=="1240" and route["id"]=="near-3-door-1" else 3.2
  walkframes=math.ceil(max(0,walk_clear_depth-stop)/4*60)+5 if entry else 0
  candidates=[]
  for n in range(1,241):
   phases=([(['move_back'],walkframes)] if walkframes else [])+[(['move_back','run'] if entry else ['move_back'],n),([],30)]
   rows=simulate(normal,phases);progress=dot(rows[-1]['offset'],normal);candidates.append((abs(progress-wanted),n,rows,phases))
  _,n,rows,phases=min(candidates,key=lambda x:x[0]);origin=q['point'](f,station,0,stop)
  path=[origin];checks=[]
  for i,row in enumerate(rows):
   p=add(origin,row['offset']);g=height(c['land'],p[0],p[2]);bad=[]
   if g is None:bad.append('LAND absent');p[1]=origin[1]
   else:p[1]=g[0]
   low=add(p,[0,.35,0]);high=add(p,[0,1.45,0]);nearest=[]
   for body in c['solids']:
    if body['key'].startswith('land:'):continue
    if any(body['bounds'][j][1]<min(low[j],high[j])-.36 or body['bounds'][j][0]>max(low[j],high[j])+.36 for j in range(3)):continue
    clear=min(segment_triangle(low,high,*tr)for tr in body['triangles'])-.35
    if clear<.10:nearest.append({'key':body['key'],'role':body['role'],'clearance_m':clear})
    if clear<-.00005:bad.append('physical capsule overlap '+body['role'])
   lc=min(segment_triangle(low,high,*tr)for tr in c['land'])-.35
   if lc<-.002:bad.append('LAND capsule qualification')
   pivot=add(p,[0,2,0]);camera=add(pivot,mul(normal,5.5));under=height(c['land'],camera[0],camera[2]);camhit=c['ray'](pivot,camera)
   if camhit is not None or under is None or camera[1]-under[0]<=.1:bad.append('camera clearance')
   checks.append({'row':i+1,'foot':p,'nearest':nearest,'land_capsule_clearance_m':lc,'camera_hit':camhit,'failures':bad});path.append(p)
   failures.extend(route['id']+': '+b for b in bad)
  endpoint=path[-1];depth=dot(sub(endpoint,f['start']),normal);interval=route['retreat']['depth_interval_m']
  if not interval[0]<=depth<=interval[1]:failures.append(route['id']+': endpoint depth')
  if entry and height(c['roads'],endpoint[0],endpoint[2])is None:failures.append(route['id']+': endpoint road absent')
  route['retreat']['segments']=[{'actions':a,'input_frames':count}for a,count in phases[:-1]]
  route['retreat']['input_frames']=sum(count for _,count in phases[:-1]);route['retreat']['planned_path_xz']=[[p[0],p[2]]for p in path]
  route['retreat']['path_scope']='Explicit inferred component-wise stock return curve; unchanged half-width/capsule clearance, independently swept actual source002 geometry. Approach remains original straight corridor.'
  evidence.append({'id':route['id'],'phases':phases,'component_rows':rows,'geometry_rows':checks,'endpoint_depth_m':depth,'road_membership':height(c['roads'],endpoint[0],endpoint[2]),'station_drift_m':dot(rows[-1]['offset'],f['tangent'])})
 plan['scope']=plan['scope'].replace('same-corridor return','explicit component-wise curved return')
 plan['physical_rows_max']=sum(r['input_frames']+r['brake_frames']+r['retreat']['input_frames']+r['retreat']['brake_frames']for r in plan['routes'])
 (W/t/'route-plan.json').write_text(json.dumps(plan,indent=2)+'\n')
 result={'ok':not failures,'failures':sorted(set(failures)),'routes':evidence,'scope':'Per-physics-row component recurrence and full capsule/LAND/camera sweep of explicit return paths; no native claim.'}
 (W/t/'COMPONENT_RETURN_PREFLIGHT.json').write_text(json.dumps(result,indent=2)+'\n');print(t,result['ok'],result['failures'])

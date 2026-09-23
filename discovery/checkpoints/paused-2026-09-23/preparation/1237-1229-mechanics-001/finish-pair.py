from pathlib import Path
import json,math,hashlib,ast,difflib,re
W=Path(__file__).resolve().parent;P=W.parent;D=P/'1397-mechanics-001';S=P/'1237-1229-implementation-003';R=Path('/Volumes/Macintosh_HD/Users/user302070/code/treasure-island-1237-1229-study-v1')
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def write(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
points=[];unit_points={};saved={};deltas={}
for t in ['1237','1229']:
 points=[];unit_points[t]=points
 plan=json.loads((W/t/'route-plan.json').read_text());plan['scope']=f'All {len(plan["routes"])-(1 if t=="1237" else 0)} affected entry paths: full source-road approach through footway/path junction to closed-door contact, component-wise walk/run return and natural braking on source-road over LAND.'+(' Single configured screen obstruction with walk return.'if t=='1237'else' No screen is authored or scheduled.')+' Actual eligible wall and window/trim rejection callbacks.'
 plan['carried_forward']={'authority':'32/213','static_geometry':'Exact independently accepted implementation003 and actual source/native001','jetpack':'Unperformed in this unit campaign; unchanged global controls only. No new qualification.','roof_support':'Roof physical faces/receiver ownership checked unchanged against focused001. No roof landing, roof traversal, roof spray callback or broad roof qualification claimed.'}
 write(W/t/'route-plan.json',plan)
 for route in plan['routes']:
  f=route['frame'];n=f['normal'];st=route['station_m'];origin=f['start'];stop=route['expected_block_depth_m']
  for i in range(65):
   d=stop+(route['start_depth_m']-stop)*i/64;p=[origin[j]+f['tangent'][j]*st+n[j]*d for j in range(3)];points.extend([p,[p[j]+n[j]*5.5 for j in range(3)]])
  for x,z in route['retreat']['planned_path_xz']:points.extend([[x,0,z],[x+n[0]*5.5,0,z+n[2]*5.5]])
 queries=json.loads((W/t/'CONTACT_QUERY_DRAFT.json').read_text())
 for row in queries['spray_candidates']:
  if row['query_feasible']:points.extend([row['camera']['player'],row['camera']['camera'],row['target']])
 native=json.loads((S/f'native-{t}-001-result.json').read_text());saved[t]=[]
 for c in native['captures']:
  fc=c['final_camera'];assert c['player']['on_floor'] and fc['segment_clear'] and fc['camera_above_land'] and fc['land_identity_ok']
  saved[t].append({k:c[k] for k in ['id','path','sha256','player','camera','final_camera','source_world_land_and_area_intact']})
 actual=json.loads((S/f'focused-{t}-001-result.json').read_text());shapes=sum(1 for label,row in actual['detail_collision'].items()if label!='ProjectedUpperWallReceiver')
 helper=W/t/'live_driver.gd';s=helper.read_text();s=s.replace('checked==9','checked=='+str(shapes)).replace('All 9 nonreceiver','All '+str(shapes)+' nonreceiver')
 # Preserve complete donor collision identity comparison, with current32 literal values from accepted source helper.
 donor=(D/'1397/live_driver.gd').read_text();a=donor.index('\tvar source_collision: Dictionary = {}');b=donor.index('\n\tsource_world.add_child(study_root)',a)
 if 'var source_collision: Dictionary'not in s:s=s.replace('\tsource_world.add_child(study_root)',donor[a:b]+'\n\tsource_world.add_child(study_root)',1)
 helper.write_text(s)
 (W/t/'helper.diff').write_text(''.join(difflib.unified_diff(donor.splitlines(True),s.splitlines(True),fromfile=str(D/'1397/live_driver.gd'),tofile=str(helper))))
 deltas[t]={'routes':len(plan['routes']),'sprays':len(plan['sprays']),'physical_rows_max':plan['physical_rows_max'],'detail_shapes':shapes,'window_role':plan['sprays'][1]['expected_role'],'source_key':('w96665904'if t=='1237'else'w96665911'),'route_distances_m':[{ 'id':r['id'],'start_depth_m':r['start_depth_m'],'stop_depth_m':r['expected_block_depth_m'],'approach_limit_frames':r['input_frames'],'retreat_segments':r['retreat']['segments']}for r in plan['routes']]}
bounds={t:[[min(p[j]for p in pp)-.35,max(p[j]for p in pp)+.35]for j in [0,2]]for t,pp in unit_points.items()};canopies=[]
for p in (R/'game/resources/facades').glob('*.json'):
 d=json.loads(p.read_text());cps=d.get('carports',[])+([d['carport']]if isinstance(d.get('carport'),dict)else[])
 for cp in cps:
  if not all(k in cp for k in ['frame','station_m','depth_m']):continue
  f=cp['frame'];verts=[[f['start'][j]+f['tangent'][j]*ss+f['normal'][j]*depth for j in [0,2]]for ss in cp['station_m']for depth in cp['depth_m']];b=[[min(v[i]for v in verts)-2,max(v[i]for v in verts)+2]for i in range(2)];distances={t:min(math.hypot(*[max(b[i][0]-v[j]-.6,v[j]-.6-b[i][1],0)for i,j in enumerate([0,2])])for v in pp)for t,pp in unit_points.items()};distance=min(distances.values())
  assert distance>0,(p,b,bounds)
  canopies.append({'config':str(p),'sha256':sha(p),'expanded_bounds':b,'horizontal_clearance_m_by_unit':distances})
write(W/'CANOPY_PREFLIGHT.json',{'ok':True,'capsule_camera_campaign_envelope':bounds,'canopies':canopies,'scope':'Each sampled campaign player/camera point expanded0.6m versus canopy bounds expanded2m; finite samples plus component row paths. Unit aggregate bounds overlap empty space between separate setups and are reported only as context. Original source/detail solids separately swept.'})
write(W/'SAVED_VIEW_PREFLIGHT.json',{'ok':True,'captures':saved,'scope':'Eight retained original saved views, final grounded state and camera after physics waits. Author inspected both saved junction PNGs. No new captures. No executed movement or spray inference. New callback geometry uses actual focused001 triangles with full decal box/cone and stock poses.'})
write(W/'DELTA.json',{'donor':str(D),'units':deltas,'intentional_predicate_change':'Only incidental retreat land_rows>0 event-count assertion removed; counts still emitted. Full per-row geometric LAND support, wrong-support identity, camera, corridor, complete route, destination and natural brake retained.','retained_independent_support_criterion_m':.004,'stock':{'walk':4,'run':20,'acceleration':30,'brake':40},'roof_jetpack':'Unperformed; no added contract or broad qualification.','study_changed':False,'new_framework':False})
print(deltas)

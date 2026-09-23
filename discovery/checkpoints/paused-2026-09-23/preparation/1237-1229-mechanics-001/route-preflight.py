from pathlib import Path
import json,math,runpy,hashlib
W=Path(__file__).resolve().parent
q=runpy.run_path(str(W/'prepare-target-queries.py'))
sub,add,mul,dot,cross,unit,height=[q[k]for k in ['sub','add','mul','dot','cross','unit','height']]
ns=dict(globals());donor=(W.parent/'1221-mechanics-001/route-preflight.py').read_text();exec(donor[donor.index('def length(v):'):donor.index('capsule_radius=.35;')],ns);segment_triangle=ns['segment_triangle']
for target,c in q['contexts'].items():
 checks=[];routes=[];evidence=[]
 def check(v,label):checks.append({'ok':bool(v),'label':label})
 for item in c['entries']+c['extra']:
  f=item['frame'];station=item['station_m'];startdepth=item['proposed_start_depth_m'];hit=item['first_body_ray'];isentry='expected_door_first'in item
  normal_dot=abs(dot(hit['normal'],f['normal']));stop=dot(sub(hit['position'],f['start']),f['normal'])+.35/normal_dot+.0001
  # At20m/s stock run, finite outbound time selected to end within the actual road band; actual membership must pass independently.
  if item['label']=='screen':
   vertices=[v for body in c['solids']if body['role']=='LocalPrivacyScreens'for tr in body['triangles']if min(dot(sub(v,f['start']),f['tangent'])for v in tr)<station+.35 and max(dot(sub(v,f['start']),f['tangent'])for v in tr)>station-.35 and min(v[1]for v in tr)<item['proposed_start'][1]+1.5 and max(v[1]for v in tr)>item['proposed_start'][1]+.3 for v in tr]
   stop=max(dot(sub(v,f['start']),f['normal'])for v in vertices)+.3501
  retreat_distance=startdepth-stop;run=isentry;speed=20.0 if run else 4.0;retreat_distance=retreat_distance if isentry else 1.5
  def predicted(n):
   velocity=[0.,0.,0.];offset=[0.,0.,0.]
   for active,frames in [(True,n),(False,30)]:
    for _ in range(frames):
     for j in [0,2]:
      goal=f['normal'][j]*speed if active else 0.;step=(30. if active else 40.)/60
      velocity[j]+=max(-step,min(step,goal-velocity[j]));offset[j]+=velocity[j]/60
   return dot(offset,f['normal'])
  frames=min(range(1,241),key=lambda n:abs(predicted(n)-retreat_distance))
  lo=startdepth-.65 if isentry else stop+1.0;hi=startdepth+.65 if isentry else stop+2.2
  route={'id':item['label'],'frame':{**f,'id':item['label'],'runs':f.get('runs',[f.get('source_run')])},'station_m':station,'setup_position_xz':[item['proposed_start'][0],item['proposed_start'][2]],'start_depth_m':startdepth,'expected_block_depth_m':stop,'input_frames':math.ceil((startdepth-stop)/4*60)+50,'brake_frames':30,'expected_shape':hit['shape'],'expected_role':''if hit['role']=='source'else hit['role'],'expected_key':hit['key'],'receiver_mode':'original_wall'if hit['role']=='source'else'authored_detail','minimum_progress_m':startdepth-stop-.2,'maximum_station_drift_m':.15,'expected_depth_interval_m':[stop-.08,stop+.08],'marker':'','ground_label':item['label'],'inspection_target':hit['position'],'stop_on_expected_contact':True,'source_corridor':{'construction_frame_start':f['start'],'construction_tangent':f['tangent'],'construction_normal':f['normal'],'centre_station_m':station,'half_width_m':.60 if isentry else .55,'capsule_radius_m':.35},'retreat':{'input_frames':frames,'brake_frames':30,'actions':['move_back','run']if run else['move_back'],'minimum_progress_m':retreat_distance-.65 if isentry else 1.0,'maximum_progress_m':retreat_distance+.65 if isentry else 2.2,'depth_interval_m':[lo,hi],'expected_road_membership':isentry},'source_road_depth_samples_m':item.get('source_road_depth_samples_m',[])}
  if isentry:check(all(height(c['roads'],q['point'](f,station,0,d)[0],q['point'](f,station,0,d)[2])is not None for d in [lo,hi]),item['label']+' entire proposed endpoint interval on actual road overlay')
  samples=[]
  for i in range(25):
   depth=stop+(max(startdepth,hi)-stop)*i/24;p=q['point'](f,station,0,depth);g=height(c['land'],p[0],p[2]);check(g is not None,item['label']+' LAND coverage')
   if g is None:continue
   p[1]=g[0];low=add(p,[0,.35,0]);high=add(p,[0,1.45,0]);near=[]
   for body in c['solids']:
    if body['key'].startswith('land:'):continue
    if any(body['bounds'][j][1]<min(low[j],high[j])-.36 or body['bounds'][j][0]>max(low[j],high[j])+.36 for j in range(3)):continue
    distance=min(segment_triangle(low,high,*tr)for tr in body['triangles'])-.35
    if distance<.05:near.append({'key':body['key'],'role':body['role'],'clearance_m':distance})
   check(all(x['clearance_m']>=-.00005 for x in near),item['label']+' sampled capsule clears nonland before analytic contact')
   land_clear=min(segment_triangle(low,high,*tr)for tr in c['land'])-.35;check(land_clear>=-.002,item['label']+' sampled capsule LAND solver qualification')
   pivot=add(p,[0,2,0]);camera=add(pivot,mul(f['normal'],5.5));under=height(c['land'],camera[0],camera[2]);hitcam=c['ray'](pivot,camera)
   check(hitcam is None and under is not None and camera[1]-under[0]>.1,item['label']+' stock horizontal camera path and LAND clearance')
   samples.append({'depth_m':depth,'foot':p,'nearest_nonland':near,'capsule_land_clearance_m':land_clear,'camera_hit':hitcam,'camera_above_land':None if under is None else camera[1]-under[0]})
  routes.append(route);evidence.append({'id':item['label'],'samples':samples})
 footprint=json.loads((W/target/'FOOTPRINT_PREFLIGHT.json').read_text());assert footprint['ok'];positive=footprint['attempts'][-1]['spec'];sprays=[]
 for role in ['ProjectedUpperSiding',('BlueOpaqueGlazing' if target=='1237' else 'DarkOpaqueGlazing'),'PaleCompleteTrim']:
  choices=[positive]if role=='ProjectedUpperSiding'else[x for x in c['spray_rows']if x['role']==role and x['query_feasible']]
  check(bool(choices),'Reachable stock callback query '+role)
  if not choices:continue
  chosen=choices[0];hit=chosen['first_hit'];sprays.append({'id':role,'frame':chosen['frame'],'station_m':chosen['station_m'],'start_depth_m':chosen['start_depth_m'],'setup_position_xz':chosen['setup_position_xz'],'target':chosen['target'],'expected_key':hit['key'],'expected_shape':hit['shape'],'expected_role':role,'expected_result':chosen['expected_result'],'maximum_attempt_distance_m':5.7,'marker':'01-actual-eligible-wall-spray'if role=='ProjectedUpperSiding'else''})
 result={'ok':all(x['ok']for x in checks),'checks':checks,'failures':[x['label']for x in checks if not x['ok']],'route_geometry':evidence,'stock_speed_binding':{'walk':4.0,'run':20.0,'acceleration':30.0,'braking':40.0,'source':'Actual controller defaults and retained donor actual stock_settings_before'},'scope':'File-only planned capsule/support/camera and actual emitted query checks; native dynamic evidence pending.'}
 (W/target/'ROUTE_PREFLIGHT.json').write_text(json.dumps(result,indent=2)+'\n')
 plan={'scope':'Three inferred entries and one changed screen/post/original-wall blocking route each; contact then same-corridor return, entries use stockrun to actual source-road overlay over LAND. Four reachable stock spray callbacks. Global unchanged jetpack/spray and exact roof/canopy source/nonreceiver metadata reused; no roof callback or new jetpack phase.','routes':routes,'sprays':sprays,'carried_forward':{'authority':'31/213','static_geometry':'Exact visually and technically accepted002','jetpack':'Unchanged global behavior; not exercised by this unit driver','roof_support':'Exact unchanged native physical geometry/ownership; no unit landing/walking claim'},'physical_rows_max':sum(r['input_frames']+r['brake_frames']+r['retreat']['input_frames']+r['retreat']['brake_frames']for r in routes)}
 (W/target/'route-plan.json').write_text(json.dumps(plan,indent=2)+'\n');print(target,'routefile',result['ok'],sorted(set(result['failures'])),plan['physical_rows_max'])

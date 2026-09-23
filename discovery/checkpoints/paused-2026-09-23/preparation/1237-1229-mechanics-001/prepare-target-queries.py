"""Bounded target-local contact/road queries from actual002 emitted geometry; no engine."""
from pathlib import Path
import json,math,hashlib
W=Path(__file__).resolve().parent;S=W.with_name('1237-1229-implementation-003');R=Path('/Volumes/Macintosh_HD/Users/user302070/code/treasure-island-1237-1229-study-v1')
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
donor=(W.parent/'1221-mechanics-001/route-preflight.py').read_text()
base=(W.parent/'1238-northpoint-study-002/file-preflight.py').read_text();ns={'math':math};exec(base[base.index('def sub('):base.index('allchunks=[]')],ns)
sub,add,mul,dot,cross,unit,tris,height=[ns[k]for k in ['sub','add','mul','dot','cross','unit','tris','height']]
contexts={}
for t,stem,key in [('1237','northpoint_1237_study','w96665904'),('1229','northpoint_1229_study','w96665911')]:
 cfg=json.loads((R/f'game/resources/facades/{stem}.json').read_text());actualpath=S/f'focused-{t}-001-result.json';actual=json.loads(actualpath.read_text());assert actual['ok'];solids=[];lands={};roads=[]
 def include(key,shape,role,triangles):
  points=[p for tr in triangles for p in tr];bounds=[[min(p[i]for p in points),max(p[i]for p in points)]for i in range(3)];solids.append(dict(key=key,shape=shape,role=role,triangles=triangles,bounds=bounds))
 for item in json.loads((R/'generated/world/manifest.json').read_text())['files']:
  if not item['path'].startswith('chunks/')or not item['path'].endswith('.json'):continue
  for row in json.loads((R/'generated/world'/item['path']).read_text())['records']:
   if row['collision_kind']=='world_solid':include(row['object_key'],0,'source',tris(row))
   if row['feature_kind']=='land_ground':lands[row['object_key']]=tris(row)
   if row['object_key'].startswith('roads:'):roads+=tris(row)
 labels=['ObservedPublicRoof','ProjectedUpperClosures','PaleCompleteTrim','BlueOpaqueGlazing','DarkOpaqueGlazing','MaroonClosedDoors','LocalPrivacyScreens','PaleDrainageAndFascia','DoorHardware']
 labels=[label for label in labels if label in actual['detail_collision']]
 for shape,label in enumerate(labels):
  if label not in actual['meshes']:
   assert actual['detail_collision'][label]['triangles']==0;continue
  m=actual['meshes'][label];include('prototype:building:'+key+':wall',shape,label,[[m['vertices'][i]for i in m['indices'][j:j+3]]for j in range(0,len(m['indices']),3)])
 m=actual['meshes']['ProjectedUpperSiding'];include('building:'+key+':wall',0,'ProjectedUpperSiding',[[m['vertices'][i]for i in m['indices'][j:j+3]]for j in range(0,len(m['indices']),3)])
 land=[tr for k in cfg['ground']['sampled_land_keys']for tr in lands[k]]
 local=dict(globals());exec(donor[donor.index('def ray('):donor.index('checks=[]')],local);ray=local['ray']
 def point(f,s,y,d):
  p=add(add(f['start'],mul(f['tangent'],s)),mul(f['normal'],d));p[1]=y;return p
 entries=[]
 for frame in cfg['target']['frames']:
  for e in frame['entries']:
   f=e['basis'];station=e['local_station_m']
   if t=='1240' and frame['id']=='near-2':
    original=f;origin=point(f,station,f['start'][1],0);normal=unit(add(f['normal'],mul(f['tangent'],.08)));tangent=unit(sub(f['tangent'],mul(f['normal'],.08)))
    f={**f,'start':origin,'normal':normal,'tangent':tangent,'source_frame':original,'source_entry_station_m':station,'route_inference':'Straight approach skews outward0.08m along source tangent per1m depth, staying within narrow entry path then passing actual posts; not source wall orientation.'};station=0.0
   road_depths=[]
   for i in range(16,121):
    depth=i*.25;p=point(f,station,0,depth)
    if height(roads,p[0],p[2])is not None:road_depths.append(depth)
   assert road_depths,e['ground_label'];startdepth=road_depths[0]+1.0;p=point(f,station,0,startdepth);p[1]=height(land,p[0],p[2])[0];origin=add(p,[0,.9,0]);hit=ray(origin,point(f,station,origin[1],0))
   entries.append({'label':e['ground_label'],'frame':f,'station_m':station,'source_road_depth_samples_m':road_depths,'proposed_start_depth_m':startdepth,'proposed_start':p,'first_body_ray':hit,'expected_door_first':hit is not None and hit['role']=='MaroonClosedDoors','route_scope':'Grounded road-to-entry contact, same-corridor entry-to-road walk/run return; road triangle membership is separate from supporting LAND owner.'})

 extra=[]
 # One changed-screen obstruction in its actual slat column, not its open gap.
 proposals=[]
 if any(f["screens"] for f in cfg["target"]["frames"]):
  frame=next(f for f in cfg['target']['frames']if f['screens']);sc=frame['screens'][0];sf=sc['basis'];count=max(2,int(math.floor((sc['width_m']-.16)/.115)));station=sc['local_station_m']-sc['width_m']/2+.13+(sc['width_m']-.26)*(count//2)/(count-1)
  proposals=[('screen',sf,station,sc['depth_m']+2.4,'LocalPrivacyScreens')]
 for label,f,station,depth,role in proposals:
  p=point(f,station,0,depth);p[1]=height(land,p[0],p[2])[0];o=add(p,[0,.9,0]);hit=ray(o,point(f,station,o[1],-.15));extra.append({'label':label,'frame':f,'station_m':station,'proposed_start_depth_m':depth,'proposed_start':p,'first_body_ray':hit,'expected_role_first':hit is not None and hit['role']==role})

 spray_rows=[]
 f=cfg['target']['frames'][1]
 def cam(p,target):
  pivot=add(p,[0,2,0]);forward=unit(sub(target,pivot));camera=sub(pivot,mul(forward,5.5));under=height(land,camera[0],camera[2]);return {'player':p,'pivot':pivot,'camera':camera,'clearance':None if under is None else camera[1]-under[0],'segment_hit':ray(pivot,camera),'pitch':math.degrees(math.atan2(forward[1],math.hypot(forward[0],forward[2])))}
 # Named finite targets derive from actual configured features/triangles. Query feasibility is not native success.
 candidates=[]
 for ff in cfg['target']['frames']:
  for window in ff['upper_windows']:
   basis=window['basis'];station=window['local_station_m'];basis={**basis,'runs':[basis['source_run']]}
   candidates.append(('ProjectedUpperSiding',basis,station,4.35,point(basis,station,cfg['facade']['story_band_y']+.43,.06),'placed'))
 for ff in cfg['target']['frames']:
  for window in ff['lower_windows']:
   basis=window['basis'];basis={**basis,'runs':[basis['source_run']]};station=window['local_station_m']
   for role in [('BlueOpaqueGlazing' if window['glazing']=='blue' else 'DarkOpaqueGlazing'),'PaleCompleteTrim']:
    body=next(b for b in solids if b['role']==role)
    centres=[]
    for tri in body['triangles']:
     q=[sum(v[j]for v in tri)/3 for j in range(3)];normal=unit(cross(sub(tri[1],tri[0]),sub(tri[2],tri[0])))
     ss=dot(sub(q,basis['start']),basis['tangent']);dd=dot(sub(q,basis['start']),basis['normal'])
     if abs(ss-station)<window['width_m']/2+.15 and abs(q[1]-window['center_y'])<window['height_m']/2+.15 and abs(dot(normal,basis['normal']))>.9:centres.append((q,ss,dd))
    for q,ss,dd in centres[:12]:candidates.append((role,basis,ss,max(3.5,dd+2.5),q,'receiver_rejection'))
 for cp in cfg['carports'][:1]:
  cf=cp['frame'];station=sum(cp['station_m'])/2;depth=sum(cp['depth_m'])/2
  candidates.append(('CarportRoof',cf,station,depth+(3.5 if t=='1240'else 2.5),point(cf,station,cp['roof_y']-.09,depth),'receiver_rejection'))
 for role,f,station,depth,target,result in candidates:
  p=point(f,station,0,depth);lh=height(land,p[0],p[2]);
  if lh is None:continue
  p[1]=lh[0];c=cam(p,target);direction=unit(sub(target,c['camera']));hit=ray(c['camera'],add(c['camera'],mul(direction,1000)));distance=None if hit is None else math.sqrt(dot(sub(hit['position'],p),sub(hit['position'],p)))
  okay=hit is not None and hit['role']==role and distance<5.7 and c['segment_hit']is None and c['clearance']is not None and c['clearance']>.1 and -60<c['pitch']<25
  spray_rows.append({'role':role,'frame':f,'station_m':station,'start_depth_m':depth,'setup_position_xz':[p[0],p[2]],'target':target,'expected_result':result,'first_hit':hit,'camera':c,'player_hit_distance':distance,'query_feasible':okay})
 result={'at_geometry':'actual focused002','ready':False,'target':t,'entries':entries,'obstructions':extra,'spray_candidates':spray_rows,'inputs':{str(actualpath):sha(actualpath),str(R/f'game/resources/facades/{stem}.json'):sha(R/f'game/resources/facades/{stem}.json')},'remaining':'Full capsule/camera route sweep, bounded runtime fields and spray full-volume checks; no engine claim'}
 (W/t/'CONTACT_QUERY_DRAFT.json').write_text(json.dumps(result,indent=2)+'\n');print(t,[(r['label'],r['expected_door_first'],r['proposed_start_depth_m'],None if r['first_body_ray']is None else r['first_body_ray']['role'])for r in entries])

 contexts[t]={k:globals()[k]for k in ["cfg","actual","solids","land","entries","extra","spray_rows","ray","point","roads"]}

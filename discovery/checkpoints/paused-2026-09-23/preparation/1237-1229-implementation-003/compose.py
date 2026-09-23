from pathlib import Path
import json,math,copy,hashlib,subprocess
W=Path(__file__).parent;P=W.parent;R=Path('/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1237-1229-implementation-003/staged');D=P/'1221-implementation-001';DR=Path('/Volumes/Macintosh_HD/Users/user302070/code/treasure-island-1221-mariner-study-v1');A=P/'next-two-family-reference-preparation-002';H=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
for spec in json.load(open(W/'targets.json')):
 out=W/spec['address'];ns={'__file__':str(out/'grade-primitives.py')};exec((out/'grade-primitives.py').read_text(),ns)
 wall,land,area,grade,point,local_basis=[ns[x]for x in ['wall','land','area','grade','point','local_basis']];frames=[];grounds=[];ns['grounds']=grounds;top=wall['top_elevation_m'];base=wall['flat_base_elevation_m']
 for ci,runs in enumerate(spec['groups']):
  a=wall['vertices'][runs[0]*12:runs[0]*12+3];b=wall['vertices'][runs[-1]*12+3:runs[-1]*12+6];length=math.hypot(b[0]-a[0],b[2]-a[2]);t=[(b[0]-a[0])/length,0,(b[2]-a[2])/length];n=[-t[2],0,t[0]]
  assert sum(n[i]*wall['normals'][runs[0]*12+i]for i in [0,2])>.999
  f=dict(id=f'near-{ci+1}',runs=runs,start=a,end=b,length_m=length,tangent=t,normal=n,top_y=top,opening_eligible_station_m=[0,length],roof_source_end=b,roof_source_length_m=length,upper_windows=[],lower_windows=[],entries=[],screens=[],pipes=[])
  def station(run,s):
   v=wall['vertices'][run*12:run*12+3];return sum((v[i]-a[i])*t[i]for i in [0,2])+s
  for run in runs:
   for local,width in spec['upper'].get(str(run),[]):f['upper_windows'].append(dict(station_m=station(run,local),width_m=width,height_m=1.18,center_y=top-1.22,glazing='blue'))
   for local in spec['doors'].get(str(run),[]):
    s=station(run,local);g=grade(f,f'{f["id"]}-door-{len(f["entries"])+1}',s,1.15,.022,.19);f['entries'].append(dict(station_m=s,width_m=.94,height_m=2.10,bottom_y=g['visible_max_y']+.012,ground_label=g['label'],door_tone='green',threshold_inference='Closed entry at actual local grade; production inference'))
   for local in spec['lower'].get(str(run),[]):
    s=station(run,local);g=grade(f,f'{f["id"]}-lower-{len(f["lower_windows"])+1}',s,1.52,.01,.204);f['lower_windows'].append(dict(station_m=s,width_m=1.30,height_m=1.05,center_y=g['visible_max_y']+1.3,glazing='blue'))
   for local in spec['screens'].get(str(run),[]):
    s=station(run,local);g=grade(f,f'{f["id"]}-screen-{len(f["screens"])+1}',s,1.20,.22,1.25);f['screens'].append(dict(station_m=s,width_m=1.10,height_m=1.12,solid_lower_height_m=.58,depth_m=1.20,bottom_y=g['land_min_y']-.035,ground_label=g['label'],return_length_m=.82))
  # Drainage at observed field ends; small bound modules, not a repeated arbitrary pipe schedule.
  for s in [.20,length-.20]:
   basis,local=local_basis(f,s);lh=ns['height'](land,*[point(basis,local,.16)[i]for i in [0,2]])[0];f['pipes'].append(dict(station_m=s,bottom_y=lh+.04,top_y=top-.10))
  for key in ['upper_windows','lower_windows','entries','screens','pipes']:
   for e in f[key]:e['basis'],e['local_station_m']=local_basis(f,e['station_m'])
  frames.append(f)
 donor=json.load(open(DR/'game/resources/facades/mariner_1221_study.json'));materials=copy.deepcopy(donor['materials']);materials.update(siding_rgb=[.68,.69,.62]if spec['address']=='1205'else[.67,.66,.59]if spec['address']=='1226'else[.64,.65,.60],trim_rgb=[.85,.86,.80],screen_rgb=[.48,.44,.35],door_rgb=[.10,.22,.17],blue_glass_rgb=[.27,.35,.39],dark_glass_rgb=[.15,.20,.21])
 mapped=sorted(sum(spec['groups'],[])+spec['continuity']);cfg=dict(schema_version='ti.'+spec['name'].replace('_','-')+'/1',target=dict(source_key=spec['key'],address=spec['address']+' '+spec['street'],date='March2025',frames=frames),mapped_runs=mapped,protected_runs=[i for i in range(len(wall['vertices'])//12)if i not in mapped],source_association=dict(sha256=H(A/'independent-source-001/REVIEW.md')),truth_boundary=copy.deepcopy(donor['truth_boundary']),inference=dict(module_scale_count_cadence='production_inference',scope='Independent bounded observed-front PASS; tiny runs are field continuity, hidden canopies/ramps/stairs/rear excluded; obscured opening schedules intentionally sparse.'),facade=dict(story_band_y=base+2.75,fascia_center_y=top+.016,gutter_center_y=top+.085,upper_projection_m=.06,roof_low_rgb=spec['rooflow'],roof_high_rgb=spec['roofhigh']),materials=materials,siding=copy.deepcopy(donor['siding']),carports=[],ground=dict(land_key=land['object_key'],sampled_land_keys=land['source_record_keys'],sampled_area_keys=area['source_record_keys'],sampled_road_keys=['roads:'+spec['chunk'],'roads:'+spec['adj']],land_collision_kind=land['collision_kind'],visible_area_key=area['object_key'],visible_area_collision_kind=area['collision_kind'],source_chunk_sha256=H(R/'generated/world/chunks'/(spec['chunk']+'.json')),samples=grounds,paths='Render-only bounded actual local grade; original support unchanged'))
 def solid_strip(fr,topquad):
  low=[[v[0],v[1]-.045,v[2]]for v in topquad];center=[sum(v[j]for v in topquad+low)/8 for j in range(3)];out=[]
  for q in [topquad,low]+[[topquad[i],low[i],low[(i+1)%4],topquad[(i+1)%4]]for i in range(4)]:
   for tr in [[q[0],q[1],q[2]],[q[0],q[2],q[3]]]:
    a=[tr[1][j]-tr[0][j]for j in range(3)];b=[tr[2][j]-tr[0][j]for j in range(3)];n=[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]];c=[sum(v[j]for v in tr)/3 for j in range(3)]
    if sum(n[j]*(c[j]-center[j])for j in range(3))<0:tr=[tr[0],tr[2],tr[1]]
    out.append(tr)
  return out
 roofs=[];bands=[]
 for f in frames:
  L=f['length_m'];roofs+=solid_strip(f,[point(f,.04,-3.05,top+.47),point(f,L-.04,-3.05,top+.47),point(f,L-.04,.20,top+.12),point(f,.04,.20,top+.12)])
  if spec['band']:bands+=solid_strip(f,[point(f,.04,.075,base+3.18),point(f,L-.04,.075,base+3.18),point(f,L-.04,.57,base+2.70),point(f,.04,.57,base+2.70)])
 cfg['public_roof']=dict(triangles=roofs,inference='Planar shallow observed front strips only, closed45mm thickness; hidden original roof remains exact')
 cfg['shallow_band']=dict(triangles=bands,inference='Broad sloped front story band only for1205/1226;1397 thin donor edge; all dimensions production inference')
 (out/'ground-footprints.json').write_text(json.dumps(cfg['ground'],indent=2)+'\n');cfg['ground'].pop('samples');cfg['ground']['evidence_sha256']=H(out/'ground-footprints.json');(R/'game/resources/facades'/(spec['name']+'.json')).write_text(json.dumps(cfg,indent=2)+'\n')
 for n in ['prepare-approaches.py','prepare-roof-ground.py']:
  s=(D/n).read_text().replace(str(DR),str(R)).replace('mariner_1221_study',spec['name']).replace('x_-2__z_-3','__TARGET__').replace('x_-1__z_-3','__ADJ__').replace('__TARGET__',spec['chunk']).replace('__ADJ__',spec['adj'])
  (out/n).write_text(s)
 print(spec['address'],'frames',len(frames),'doors',sum(len(f['entries'])for f in frames),'roofs',len(roofs),'bands',len(bands))

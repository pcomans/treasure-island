from pathlib import Path
import json,hashlib,collections
W=Path(__file__).parent;R=Path('/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1237-1229-implementation-003/staged');H=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
for spec in json.load(open(W/'targets.json')):
 out=W/spec['address'];s=(out/'prepare-approaches.py').read_text();ns={'__file__':str(out/'prepare-approaches.py')};exec(s[:s.index('evidence=[];top_count=0')],ns)
 cfg=ns['cfg'];f=cfg['target']['frames'][1];origin=[f['start'][0],f['start'][2]];t=[f['tangent'][0],f['tangent'][2]];n=[f['normal'][0],f['normal'][2]]
 def P(s,d):return [origin[i]+t[i]*s+n[i]*d for i in range(2)]
 def S(p):return sum((p[i]-origin[i])*t[i]for i in range(2))
 def D(p):return sum((p[i]-origin[i])*n[i]for i in range(2))
 ns.update(collections=collections,D=D)
 source=(out/'prepare-roof-ground.py').read_text();exec(source[source.index('def drape('):source.index('\nwalk=drape')],ns);drape=ns['drape']
 start=S([cfg['target']['frames'][0]['start'][i]for i in [0,2]])+.35;end=S([cfg['target']['frames'][-1]['end'][i]for i in [0,2]])-.35
 walk_near=3.0;walk_far=4.15
 walk=drape([([P(start,walk_near),P(end,walk_near),P(end,walk_far),P(start,walk_far)],None)])
 entries=[]
 def point(b,s,d):return [b['start'][0]+b['tangent'][0]*s+b['normal'][0]*d,b['start'][2]+b['tangent'][2]*s+b['normal'][2]*d]
 for fr in cfg['target']['frames']:
  for e in fr['entries']:
   b=e['basis'];s=e['local_station_m'];corners=[];ends=[]
   for st in [s-.6,s+.6]:
    at=point(b,st,0);bn=[b['normal'][0],b['normal'][2]];depth=(walk_near-D(at))/sum(x*y for x,y in zip(bn,n));assert depth>.3;ends.append(depth);corners.extend([point(b,st,.12),point(b,st,depth+.025)])
   domain=[corners[0],corners[2],corners[3],corners[1]];e['path_mesh']=drape([(domain,None)]);e['path_connection']=dict(kind=spec['address']+'_inferred_local_footway',width_m=1.2,outward_start_m=.12,end_depths_m=ends,collision='none',boundary_status='Visible entry/footway motif; bounded dimensions are production inference. No added parking or source-road join.')
   entries.append(dict(label=e['ground_label'],domain_xz=domain,end_depths_m=ends))
 cfg['local_ground']={'FootwaySurface':walk};cfg['materials'].update(footway_rgb=[.61,.61,.55],parking_rgb=[.5,.5,.47]);cfg['ground']['paths']='Short actual-LAND-draped render-only entry paths join bounded footway; no new parking. LAND and visible area sampled separately; existing roads and source world remain exact.'
 layout=dict(scope='Bounded actual-grade entry/footway only; original road, parking context, terrain, area and collision unchanged',entries=entries,global_frame=dict(origin_xz=origin,tangent_xz=t,normal_xz=n,station_limits_m=[start,end],footway_depth_m=[walk_near,walk_far]),source_chunk_sha256=H(R/'generated/world/chunks'/(spec['chunk']+'.json')),source_collision_unchanged=True,ground_top_triangles=dict(footway=len(walk['top_triangles']),entries=sum(len(e['path_mesh']['top_triangles'])for f in cfg['target']['frames']for e in f['entries'])))
 (out/'roof-ground-layout.json').write_text(json.dumps(layout,indent=2)+'\n');cfg['ground']['layout_evidence_sha256']=H(out/'roof-ground-layout.json');(R/'game/resources/facades'/(spec['name']+'.json')).write_text(json.dumps(cfg,indent=2)+'\n');print(spec['address'],layout['ground_top_triangles'])

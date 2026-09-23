from pathlib import Path
import json,hashlib,re,datetime
W=Path(__file__).resolve().parent;P=W.parent;M=Path('/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1237-1229-implementation-003/frozen-main');R=W/'staged';S=P/'1205-1226-1397-implementation-001';S2=P/'1205-1226-1397-implementation-002';DR=M.with_name('treasure-island-1205-1226-1397-study-v1');A=P/'next-two-family-reference-preparation-002'
# Read-only source overlay, not a checkout; only new target files are regular staged files.
R.mkdir(exist_ok=True)
for rel in ['generated','addons','project.godot']:
 (R/rel).symlink_to(M/rel,target_is_directory=(M/rel).is_dir())
for rel in ['game/scripts/world/facades','game/resources/facades']:
 dest=R/rel;dest.mkdir(parents=True,exist_ok=True)
 for f in (M/rel).iterdir():(dest/f.name).symlink_to(f,target_is_directory=f.is_dir())
# Other siblings stay immutable references for complete helper/source inspection.
for rel in ['game','game/scripts','game/scripts/world','game/resources']:
 for f in (M/rel).iterdir():
  dst=R/rel/f.name
  if not dst.exists():dst.symlink_to(f,target_is_directory=f.is_dir())
sp=[dict(address='1237',street='Northpoint',key='w96665904',name='northpoint_1237_study',chunk='x_-1__z_-4',adj='x_-2__z_-4',groups=[[1,2],[4,5,6,7],[9,10,11,12,13]],continuity=[3],upper={1:[[1.3,1.6]],2:[[1.7,1.8]],4:[[1.8,1.8]],5:[[1.6,1.8],[4.2,1.8]],7:[[1.9,1.8]],9:[[1.0,1.4]],11:[[1.5,1.9],[4.9,.9]],13:[[1.8,1.7]]},doors={4:[3.15],5:[3.15],11:[3.25]},lower={4:[1.2],5:[1.1],11:[1.3]},screens={5:[4.75]},rooflow=[.38,.38,.33],roofhigh=[.61,.60,.52],band=False),dict(address='1229',street='Northpoint',key='w96665911',name='northpoint_1229_study',chunk='x_-2__z_-4',adj='x_-1__z_-4',groups=[[2],[4,5,6],[8]],continuity=[],upper={2:[[1.7,.85],[5.0,.8],[9.1,1.7],[12,1.6]],4:[[1.7,1.9],[4.5,1.7]],5:[[1.7,1.9],[5.4,1.8]],8:[[2,1.9],[6,1.6],[10.5,.8]]},doors={4:[3.2],5:[3.5]},lower={4:[1.1],5:[1.0,6.8]},screens={},rooflow=[.39,.38,.32],roofhigh=[.62,.60,.51],band=False)]
(W/'FIRST_SOURCE_EDIT.json').write_text(json.dumps({'at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'first staged material source edit; no checkout/engine'},indent=2)+'\n')
(W/'targets.json').write_text(json.dumps(sp,indent=2)+'\n')
for v in sp:
 out=W/v['address'];out.mkdir();(out/'.gdignore').write_text('');(out/'target.json').write_text(json.dumps(v,indent=2)+'\n')
 def adapt(s):
  for a,b in [(str(DR),str(R)),(str(S2/'1397'),str(out)),(str(S/'1397'),str(out)),('gateview_1397_study',v['name']),('w96215670',v['key']),('Gateview1397','Northpoint'+v['address']),('GATEVIEW1397','NORTHPOINT'+v['address']),('ti.gateview-1397-study/1','ti.'+v['name'].replace('_','-')+'/1'),('1397 Gateview',v['address']+' Northpoint'),('/private/tmp/1205-1226-1397-study-002/1397','/private/tmp/1237-1229-study-001/'+v['address'])]:s=s.replace(a,b)
  return s.replace('x_-1__z_-3','__TARGET__').replace('x_-2__z_-3','__ADJ__').replace('__TARGET__',v['chunk']).replace('__ADJ__',v['adj'])
 wall=next(r for r in json.load(open(M/'generated/world/chunks'/(v['chunk']+'.json')))['records']if r['object_key']==f"building:{v['key']}:wall");mapped=sorted(sum(v['groups'],[])+v['continuity']);prot=[i for i in range(len(wall['vertices'])//12)if i not in mapped]
 s=adapt((DR/'game/scripts/world/facades/gateview_1397_study.gd').read_text());s=re.sub(r'const TARGET_RUNS := .*','const TARGET_RUNS := '+json.dumps(mapped),s);s=re.sub(r'const PROTECTED_RUNS := .*','const PROTECTED_RUNS := '+json.dumps(prot),s);s=re.sub(r'const EXPECTED_CHUNK_SHA256 := .*','const EXPECTED_CHUNK_SHA256 := "'+hashlib.sha256((M/'generated/world/chunks'/(v['chunk']+'.json')).read_bytes()).hexdigest()+'"',s);s=s.replace('1397 only',v['address']+' only').replace('Isolated 1397 art','Isolated '+v['address']+' art');(R/'game/scripts/world/facades'/(v['name']+'.gd')).write_text(s)
 for n in ['grade-primitives.py','file-preflight.py','focused_source.gd','live_driver.gd']:(out/n).write_text(adapt((S2/'1397'/n).read_text()))
for name in ['compose.py','ground.py','cameras.py','routing-preflight.py']:
 s=(S/name).read_text().replace(str(DR),str(R));s=s.replace("A=P/'next-family-reference-preparation-001'","A=P/'next-two-family-reference-preparation-002'");s=s.replace("A/'independent-review-001/REVIEW.md'","A/'independent-source-001/REVIEW.md'")
 if name=='compose.py':s=s.replace('source_association=dict(path=str(A/\'independent-source-001/REVIEW.md\'),sha256=', 'source_association=dict(sha256=')
 (W/name).write_text(s)
print('staged targets created')

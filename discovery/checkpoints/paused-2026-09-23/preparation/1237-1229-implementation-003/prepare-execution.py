from pathlib import Path
import json,re,hashlib,ast,difflib,datetime
W=Path(__file__).resolve().parent;P=W.parent;M=Path('/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1237-1229-implementation-003/frozen-main');R=M.with_name('treasure-island-1237-1229-study-v1');S=P/'1205-1226-1397-implementation-002';OLD=M.with_name('treasure-island-1205-1226-1397-study-v1');BASE='fdfc100704200e6570b654a4e6a4fccc9a1a61be';sp=json.load(open(W/'targets.json'));sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
# Current32 producers measured in the already accepted authority chain.
world=json.load(open(P/'1397-1226-live-preparation-001/baseline-world.json'));(W/'WORLD_EXPECTATIONS.json').write_text(json.dumps(dict(world,authority='32/213',producer=str(P/'1397-1226-live-preparation-001/baseline-world.json'),producer_sha256=sha(P/'1397-1226-live-preparation-001/baseline-world.json')),indent=2)+'\n')
for v in sp:
 p=W/v['address']/'live_driver.gd';s=p.read_text();s=s.replace('e.mesh_instances==1244 and e.surfaces==1259 and e.triangles==173181 and e.static_bodies==494 and e.shapes==633','e.mesh_instances==1260 and e.surfaces==1275 and e.triangles==176165 and e.static_bodies==496 and e.shapes==646').replace('31/213','32/213').replace('base31','base32').replace('Current31','Current32').replace('capture-time31','capture-time32');p.write_text(s)
for n in ['run-reviewed-chain.py','release.py']:(W/n).write_bytes((S/n).read_bytes())
s=(S/'run-stage.py').read_text().replace(str(OLD),str(R)).replace('915f8a2595cb3184fba7008b97ff73f9bc028117',BASE)
a="[cache,repo/'game/scripts/world/facades/bayside_1205_study.gd.uid',repo/'game/scripts/world/facades/bayside_1226_study.gd.uid',repo/'game/scripts/world/facades/gateview_1397_study.gd.uid']";assert a in s;s=s.replace(a,"[cache,repo/'game/scripts/world/facades/northpoint_1237_study.gd.uid',repo/'game/scripts/world/facades/northpoint_1229_study.gd.uid']")
s=s.replace("assert actual()==pins,'Source drift before run'","assert actual()==pins,'Source drift before run'\nmaterialized=json.loads((p/'materialization-inputs.json').read_text())\nassert all(digest(repo/rel)==row['sha256'] for rel,row in materialized.items()),'Materialized source drift'")
(W/'run-stage.py').write_text(s)
engine=json.load(open(P/'1205-1226-1397-implementation-001/run-plan.json'))['import-001']['argv'][0];imp=W/'import-001-execution.json';cache=R/'.godot/global_script_class_cache.cfg';uids=[R/'game/scripts/world/facades'/(v['name']+'.gd.uid')for v in sp];plan={'import-001':dict(argv=[engine,'--headless','--path',str(R),'--editor','--import'],cwd=str(R),dependent_inputs=[],prerequisites=[])}
for v in sp:
 a=v['address']
 for kind in ['focused','native']:
  n=f'{kind}-{a}-001';helper=W/a/('live_driver.gd'if kind=='native'else'focused_source.gd');result=W/(n+'-result.json');prefix=[engine,'--headless']if kind=='focused'else[engine,'--display-driver','macos','--rendering-method','forward_plus','--rendering-driver','metal','--audio-driver','Dummy','--resolution','1440x900']
  q=dict(argv=prefix+['--path',str(R),'--script',str(helper),'--']+(['--probe-mode=stills']if kind=='native'else[])+['--output='+str(result)],cwd=str(R),dependent_inputs=[str(imp),str(cache)]+list(map(str,uids)),prerequisites=[str(imp)],import_receipt=str(imp),result=str(result))
  if kind=='native':
   f=W/f'focused-{a}-001-execution.json';q['prerequisites'].append(str(f));q['dependent_inputs'] += [str(f),str(W/f'focused-{a}-001-result.json')];q.update(image_dir='/private/tmp/1237-1229-study-001/'+a+'/images',durable_image_dir=str(W/a/'capture/images'))
  plan[n]=q
(W/'run-plan.json').write_text(json.dumps(plan,indent=2)+'\n')
classes={}
for f in (M/'game').rglob('*.gd'):
 for c in re.findall(r'^class_name\s+(\w+)',f.read_text(),re.M):assert c not in classes;classes[c]='res://'+str(f.relative_to(M))
(W/'cache-preflight.json').write_text(json.dumps(dict(required_classes=classes,expected_import_created_uids=list(map(str,uids)),new_classes_added=False),indent=2)+'\n')
# Complete tracked game/plugin/generated inputs are hashed in place, not copied as broad manifests.
inputs={}
for rel in ['game','addons','generated']:
 for f in (M/rel).rglob('*'):
  if f.is_file():inputs[str(f.relative_to(M))]=dict(source=str(f),sha256=sha(f))
inputs['project.godot']=dict(source=str(M/'project.godot'),sha256=sha(M/'project.godot'))
for v in sp:
 for rel in ['game/scripts/world/facades/'+v['name']+'.gd','game/resources/facades/'+v['name']+'.json']:
  f=W/'staged'/rel;inputs[rel]=dict(source=str(f),sha256=sha(f))
(W/'materialization-inputs.json').write_text(json.dumps(inputs,indent=2)+'\n')
print('prepared execution',len(inputs),'input files',len(classes),'canonical classes')

from pathlib import Path
from datetime import datetime,timezone
import sys,json,hashlib,subprocess,time,os,re
p=Path(__file__).resolve().parent
settings=json.loads((p/'execution-settings.json').read_text());repo=Path(settings['repo'])
def digest(q):
 try:return hashlib.sha256(Path(q).read_bytes()).hexdigest()
 except OSError:return None
def read(q):return json.loads(Path(q).read_text())
assert os.environ.get('TI_1397_1226_ENGINE_GO')==settings['base'],'New exact ROOT package GO required'
gitdir=Path((repo/'.git').read_text().strip().removeprefix('gitdir: '))
assert (gitdir / 'HEAD').read_text().strip() == 'fdfc100704200e6570b654a4e6a4fccc9a1a61be'
name=sys.argv[1]
plan=read(p/'run-plan.json');spec=plan[name]
receipt=p/(name+'-execution.json');log=p/(name+'.log')
assert not receipt.exists() and not log.exists(),'Never overwrite an attempt'
pins=read(p/'execution-input-pins.json');assert digest(settings['source_pin_map'])==settings['source_pin_map_sha256']
pins.update(read(settings['source_pin_map']));actual=lambda:{k:digest(k) for k in pins}
assert actual()==pins,'Frozen input drift before run'
assert subprocess.check_output(['/usr/bin/git','rev-parse','HEAD'],cwd=repo,text=True,env={**os.environ,'GIT_OPTIONAL_LOCKS':'0'}).strip()==settings['base']
cache_receipt=read(Path(settings['reused_import_receipt']))
assert cache_receipt['status']=='terminal' and cache_receipt['exit_code']==0 and cache_receipt['pid_absent'] and cache_receipt['class_discovery_ok'] and not cache_receipt['log_errors']
assert digest(repo/'.godot/global_script_class_cache.cfg')==cache_receipt['class_cache_sha256']==settings['canonical_cache_sha256'],'Reused canonical73 cache drift'
assert set(cache_receipt['import_output_uids'])==set(read(p/'cache-preflight.json')['expected_new_uid_outputs']),'Exact imported four UID outputs required'
for relative,h in cache_receipt['import_output_uids'].items():
 assert h is not None and (repo/relative).is_file() and digest(repo/relative)==h,'Reused actual UID output drift'
focused=read(Path('/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1397-1226-live-continuation-001/focused-002-execution.json'));assert focused['status']=='terminal' and focused['exit_code']==0 and focused['pins_unchanged'] and focused['pid_absent'] and focused['result_ok'],'Fresh focused equivalence required before package chain'
assert not focused['log_errors'] and digest(Path('/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1397-1226-live-continuation-001/focused-002-result.json'))==focused['result_sha256'] and read(Path('/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1397-1226-live-continuation-001/focused-002-result.json'))['ok'],'Actual focused result required'
assert read(Path('/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1397-1226-live-continuation-001/SLOT_RELEASE-focused-002-native-registry-001-native-loader-001.json'))['slot_released'],'Source slot release required'
if name=='source-component-001':
 assert all(digest(k)==h for k,h in read(p/'reused-cache-pins.json').items()),'Complete actual cache drift before first package stage'
units=read(p/'unit-packet-prerequisites.json')
assert len(units)==2 and {unit['unit'] for unit in units}=={'1397','1226'},'Exact shared1397/1226 prerequisites required'
for unit in units:
 assert unit['status']=='independently_passed' and all(digest(k)==h for k,h in unit['bindings'].items()),'Real first-five independent readiness required'
assert all(digest(q)==h for q,h in read(p/'MAIN_GUARD.json')['pins'].items()),'Immutable MAIN index/ref/source byte guard drift'
readiness=read(p/'readiness-binding.json');assert all(digest(k)==h for k,h in readiness['bindings'].items()),'Independent readiness/source decision drift'
for prerequisite in spec['requires']:
 r=read(p/(prerequisite+'-execution.json'));assert r['ok'] and r['status']=='terminal' and r['pid_absent'],prerequisite+' has not passed and released'
for prerequisite in spec.get('prerequisite_receipts',[]):
 r=read(prerequisite);assert r['status']=='terminal' and r['exit_code']==0 and r['pins_unchanged'] and r['pid_absent'] and not r['log_errors'] and r.get('result_ok',True) and r.get('class_discovery_ok',True),'Actual prior source receipt required'
ps=subprocess.check_output(['/bin/ps','-axo','pid=,ppid=,comm='],text=True)
engine_rows=[line.strip() for line in ps.splitlines() if re.search(r'godot|treasure.?island.*playable',line,re.I)]
assert not engine_rows,'Another engine owns the slot: '+str(engine_rows)
for q in spec.get('new_output_paths',[]):assert not Path(q).exists(),'Fresh output required: '+q
for q in spec.get('output_directories',[]):assert Path(q).is_dir() and os.access(q,os.W_OK) and not any(Path(q).iterdir()),'Empty writable prepared output directory required: '+q
if name.startswith(('mounted-','release-')):
 bound=read(p/'actual-app-binding.json');assert digest(p/'run-plan.bound-app.json')==bound['bound_plan_sha256']
 assert all(digest(k)==v for k,v in bound['app_pins'].items()),'Exact candidate app drift'
 spec=read(p/'run-plan.bound-app.json')[name]
assert all('<ACTUAL_' not in arg for arg in spec['argv']),'Run bind-export.py after successful export'
r={'argv':spec['argv'],'cwd':spec['cwd'],'started_at':datetime.now(timezone.utc).isoformat(),'pins_before':pins,'prerequisites':spec['requires']}
started=time.monotonic()
with log.open('w') as output:
 proc=subprocess.Popen(spec['argv'],cwd=spec['cwd'],stdout=output,stderr=subprocess.STDOUT)
 r.update(pid=proc.pid,status='running');receipt.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({'pid':proc.pid,'receipt':str(receipt),'argv':spec['argv']}),flush=True)
 r['fatal_entry_load_observation']=None
 if '--script' in spec['argv']:
  entry=spec['argv'][spec['argv'].index('--script')+1]
  while proc.poll() is None:
   fatal=next((line for line in log.read_text().splitlines() if 'ERROR: Failed to load script "'+entry+'" with error' in line),None)
   if fatal:
    r['fatal_entry_load_observation']={'first_observed_at':datetime.now(timezone.utc).isoformat(),'line':fatal,'configured_entry_script':entry,'owned_pid':proc.pid,'action':'SIGTERM owned engine only'}
    proc.terminate()
    break
   time.sleep(.1)
 r['exit_code']=proc.wait()
body=log.read_text();r.update(status='terminal',ended_at=datetime.now(timezone.utc).isoformat(),elapsed_seconds=time.monotonic()-started,pins_after=actual(),log_sha256=digest(log))
r['pins_unchanged']=r['pins_before']==r['pins_after']
r['log_errors']=[x for x in body.splitlines() if any(t in x for t in ['SCRIPT ERROR','ERROR:','FAIL:','Parse Error','Compile Error'])]
r['warnings']=[x for x in body.splitlines() if 'WARNING:' in x or 'Warning:' in x]
r['markers']={marker:marker in body for marker in spec['success_markers']}
try:os.kill(proc.pid,0);r['pid_absent']=False
except ProcessLookupError:r['pid_absent']=True
r['app_unchanged']=True
if name.startswith(('mounted-','release-')):r['app_unchanged']=all(digest(k)==v for k,v in bound['app_pins'].items())
r['class_discovery_ok']=True
if name in ['import-001','export-001']:
 cache=repo/'.godot/global_script_class_cache.cfg';entries=re.findall(r'\{[^{}]*\}',cache.read_text()) if cache.is_file() else []
 required=read(p/'cache-preflight.json')['required_classes']
 r['class_cache_sha256']=digest(cache) if cache.is_file() else None
 r['import_output_uids']={path:(digest(repo/path) if (repo/path).is_file() else None) for path in read(p/'cache-preflight.json')['expected_new_uid_outputs']}
 r['class_discovery']={key:[entry for entry in entries if re.search(r'\"class\"\s*:\s*&?\"'+re.escape(key)+r'\"',entry)] for key in required}
 r['class_discovery_ok']=all(len(r['class_discovery'][key])==1 and '\"'+path+'\"' in r['class_discovery'][key][0] for key,path in required.items()) and len(entries)==len(required) and all('res://build/' not in entry for entry in entries)
r['result_ok']=not spec.get('result')
if spec.get('result'):
 try:r['result_ok']=Path(spec['result']).is_file() and read(spec['result']).get('ok',False) and read(spec['result']).get('measured_world')==settings['planned_world']
 except (OSError,ValueError):r['result_ok']=False
if spec.get('result') and Path(spec['result']).is_file():r['result_sha256']=digest(spec['result'])
r['ok']=r['result_ok'] and r['class_discovery_ok'] and r['exit_code']==0 and r['pins_unchanged'] and r['pid_absent'] and not r['log_errors'] and all(r['markers'].values()) and r['app_unchanged']
receipt.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({k:r[k] for k in ['pid','exit_code','elapsed_seconds','pins_unchanged','log_errors','warnings','markers','pid_absent','class_discovery_ok','result_ok','ok']}),flush=True);print(body[-3000:])
sys.exit(0 if r['ok'] else 1)

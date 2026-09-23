from pathlib import Path
from datetime import datetime,timezone
import sys,json,hashlib,subprocess,time,os,re
p=Path(__file__).resolve().parent
binding=json.loads((p/'base-binding.json').read_text())
assert os.environ.get('TI_1397_1226_ENGINE_GO') == binding.get('base_commit') and binding.get('repo') and binding.get('base_commit'), 'ROOT binding and explicit engine GO required'
repo=Path(binding['repo'])
def digest(q):
 try:return hashlib.sha256(Path(q).read_bytes()).hexdigest()
 except OSError:return None
name=sys.argv[1];plan=json.loads((p/'source-run-plan.json').read_text())[name]
receipt=p/(name+'-execution.json');log=p/(name+'.log')
assert not receipt.exists() and not log.exists(),'Never overwrite an attempt'
pins=json.loads((p/'source-pins.json').read_text());actual=lambda:{k:digest(k) for k in pins}
assert actual()==pins,'Source drift before run'
gitdir=Path((repo/'.git').read_text().strip()[8:])
assert (gitdir / 'HEAD').read_text().strip() == 'fdfc100704200e6570b654a4e6a4fccc9a1a61be', 'Exact candidate base required'
if name=='import-001':assert not (repo/'.godot').exists(),'Fresh candidate import cache required'
for prerequisite in plan.get('preparation_prerequisites',[]):
 f=json.loads(Path(prerequisite).read_text());assert f['status']=='terminal' and f['exit_code']==0 and f['engine'] is False,'Successful non-engine preparation prerequisite required'
inputs={x:digest(x) for x in plan.get('dependent_inputs',[])}
for prerequisite in plan.get('prerequisites',[]):
 f=json.loads(Path(prerequisite).read_text());assert f['status']=='terminal' and f['exit_code']==0 and f['pins_unchanged'] and f['pid_absent'] and not f['log_errors'] and f.get('class_discovery_ok',True),'Successful terminal prerequisite required'
if name!='import-001':
 prior=json.loads(Path('/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1397-1226-live-preparation-001/import-001-execution.json').read_text())
 generated={str(repo/'.godot/global_script_class_cache.cfg'):prior['class_cache_sha256']}
 required_uids=json.loads((p/'cache-preflight.json').read_text())['expected_new_uid_outputs']
 assert set(prior['import_output_uids'])==set(required_uids),'Exact actual imported UID output paths required'
 for relative in required_uids:
  expected=prior['import_output_uids'][relative]
  assert isinstance(expected,str) and len(expected)==64,'Successful actual imported UID hash required'
  generated[str(repo/relative)]=expected
 assert {path:digest(path) for path in generated}==generated,'Imported canonical cache or actual UID outputs changed before focused run'
 inputs.update(generated)
ps=subprocess.check_output(['/bin/ps','-axo','pid=,ppid=,comm='],text=True)
engine_rows=[line.strip() for line in ps.splitlines() if re.search(r'godot|treasure.?island.*playable',line,re.I)]
assert not engine_rows,'Another engine owns the slot: '+str(engine_rows)
for arg in plan['argv']:
 if arg.startswith('--output='):assert not Path(arg.split('=',1)[1]).exists(),'Fresh result required'
if plan.get('result'):assert not Path(plan['result']).exists(),'Fresh result required'
r={'argv':plan['argv'],'cwd':plan['cwd'],'started_at':datetime.now(timezone.utc).isoformat(),'pins_before':pins,'dependent_inputs_before':inputs}
started=time.monotonic()
with log.open('w') as output:
 proc=subprocess.Popen(plan['argv'],cwd=plan['cwd'],stdout=output,stderr=subprocess.STDOUT)
 r.update(pid=proc.pid,status='running');receipt.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({'pid':proc.pid,'receipt':str(receipt),'argv':plan['argv']}),flush=True)
 r['fatal_entry_load_observation']=None
 if name!='import-001':
  entry=plan['argv'][plan['argv'].index('--script')+1]
  while proc.poll() is None:
   fatal=next((line for line in log.read_text().splitlines() if 'ERROR: Failed to load script "'+entry+'" with error' in line),None)
   if fatal:
    r['fatal_entry_load_observation']={'first_observed_at':datetime.now(timezone.utc).isoformat(),'line':fatal,'configured_entry_script':entry,'owned_pid':proc.pid,'action':'SIGTERM owned engine only'}
    proc.terminate()
    break
   time.sleep(.1)
 r['exit_code']=proc.wait()
r.update(status='terminal',ended_at=datetime.now(timezone.utc).isoformat(),elapsed_seconds=time.monotonic()-started,pins_after=actual(),dependent_inputs_after={x:digest(x) for x in inputs},log_sha256=digest(log))
r['pins_unchanged']=r['pins_before']==r['pins_after'] and r['dependent_inputs_before']==r['dependent_inputs_after'];lines=log.read_text().splitlines();r['log_errors']=[x for x in lines if any(t in x for t in ['SCRIPT ERROR','ERROR:','FAIL:'])];r['warnings']=[x for x in lines if 'WARNING:' in x]
try:os.kill(proc.pid,0);r['pid_absent']=False
except ProcessLookupError:r['pid_absent']=True
r['class_discovery_ok']=True
if name=='import-001':
 cache=repo/'.godot/global_script_class_cache.cfg';entries=re.findall(r'\{[^{}]*\}',cache.read_text()) if cache.is_file() else []
 required=json.loads((p/'cache-preflight.json').read_text())['required_classes']
 r['class_cache_sha256']=digest(cache) if cache.is_file() else None
 r['import_output_uids']={path:digest(repo/path) for path in json.loads((p/'cache-preflight.json').read_text())['expected_new_uid_outputs']}
 r['class_discovery']={key:[entry for entry in entries if re.search(r'"class"\s*:\s*&?"'+re.escape(key)+r'"',entry)] for key in required}
 r['class_discovery_ok']=all(len(r['class_discovery'][key])==1 and '"'+path+'"' in r['class_discovery'][key][0] for key,path in required.items()) and len(entries)==len(required) and all('res://build/' not in entry for entry in entries) and all(value is not None for value in r['import_output_uids'].values())
r['result_ok']=True
if plan.get('result'):
 result=Path(plan['result']);r['result_exists']=result.is_file();r['result_sha256']=digest(result) if result.is_file() else None
 try:r['result_ok']=r['result_exists'] and json.loads(result.read_text()).get('ok') is True
 except (ValueError,OSError):r['result_ok']=False
receipt.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps({k:r[k] for k in ['pid','exit_code','elapsed_seconds','pins_unchanged','log_errors','warnings','pid_absent','class_discovery_ok','result_ok']}),flush=True);print(log.read_text()[-3000:])
sys.exit(0 if r['exit_code']==0 and r['pins_unchanged'] and r['pid_absent'] and not r['log_errors'] and r['class_discovery_ok'] and r['result_ok'] else 1)

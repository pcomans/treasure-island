"""Single owned release stage; adapted from the prior six-stage batch chain."""
from pathlib import Path
import datetime, hashlib, json, os, re, subprocess, sys, time
BASE=Path(__file__).resolve().parent
read=lambda p:json.loads(Path(p).read_text())
digest=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
settings=read(BASE/'settings.json'); repo=Path(settings['repo']); plan=read(BASE/'run-plan.json')
assert settings['final_source_release_ready'], 'Final corrected source/native gates pending'
readiness=read(BASE/'native-readiness.json')
assert readiness['ok'] and all(digest(p)==h for p,h in readiness['bindings'].items()), 'Final native evidence drift'
name=sys.argv[1]; stage=plan[name]; receipt=BASE/(name+'-execution.json')
harness=read(BASE/'harness-pins.json')
assert all(digest(BASE/p)==h for p,h in harness.items()), 'External release harness drift'
assert not receipt.exists() and not (BASE/(name+'.log')).exists(), 'Retain prior results/logs; choose a fresh attempt directory'
assert all(digest(repo/p)==h for p,h in read(BASE/'source-pins.json').items()), 'Frozen source changed'
for prior in stage.get('requires',[]): assert read(BASE/(prior+'-execution.json'))['ok'], prior
for path in stage.get('new_output_paths',[]): assert not Path(path).exists(), path
for path in stage.get('output_directories',[]): Path(path).mkdir(parents=True,exist_ok=True)
def engines():
 return [x.strip() for x in subprocess.check_output(['ps','-axo','pid=,comm='],text=True).splitlines() if re.search(r'Godot|Treasure.?Island.*Playable',x,re.I)]
assert not engines(), engines()
argv=stage['argv'][:]
app_binding=None
if name not in ['source-component-001','export-001']:
 app_binding=read(BASE/'app-binding.json')
 assert app_binding['signature_ok'] and digest(BASE/'signature.log')==app_binding['signature_log_sha256']
 assert digest(BASE/'bundle-native-checks-001.json')==app_binding['bundle_checks_sha256']
 def exact_app():
  app=Path(app_binding['app']);actual={str(f.relative_to(app)) for f in app.rglob('*') if f.is_file()}
  return actual==set(app_binding['files']) and all(digest(app/p)==v['sha256'] and (app/p).stat().st_size==v['bytes'] and ((app/p).stat().st_mode & 0o777)==v['mode'] for p,v in app_binding['files'].items())
 assert exact_app(), 'Signed bundle drift before stage'
 argv=[x.replace('<ACTUAL_EXPORTED_PCK_SHA256>',app_binding['pck_sha256']) for x in argv]
assert not any('<' in x for x in argv), 'Unbound release input'
explicit_log=Path(argv[argv.index('--log-file')+1]) if '--log-file' in argv else None
if explicit_log: assert not explicit_log.exists(), 'Fresh engine log required'
proc=None; code=None; errors=[]; started=time.monotonic()
try:
 with (BASE/(name+'.log')).open('w') as log:
  proc=subprocess.Popen(argv,cwd=stage['cwd'],stdout=log,stderr=subprocess.STDOUT)
  try: code=proc.wait(timeout=stage.get('timeout_seconds',600))
  except subprocess.TimeoutExpired:
   errors.append('timeout');proc.terminate()
   try:code=proc.wait(timeout=10)
   except subprocess.TimeoutExpired:proc.kill();code=proc.wait()
except Exception as e:errors.append(repr(e))
finally:
 if proc and proc.poll() is None:proc.kill();code=proc.wait()
 text=(BASE/(name+'.log')).read_text() if (BASE/(name+'.log')).exists() else ''
 if explicit_log and explicit_log.exists(): text+='\n'+explicit_log.read_text()
 errors += [s for s in text.splitlines() if 'ERROR:' in s or 'SCRIPT ERROR:' in s or 'Parse Error:' in s or 'Compile Error' in s or 'FAIL:' in s]
 for marker in stage.get('success_markers',[]):
  if marker not in text: errors.append('Missing marker: '+marker)
 if not all(digest(repo/p)==h for p,h in read(BASE/'source-pins.json').items()):errors.append('Source drift after stage')
 if not all(digest(BASE/p)==h for p,h in harness.items()):errors.append('External harness drift after stage')
 if app_binding and not exact_app():errors.append('Signed bundle drift after stage')
 live=engines();result={'stage':name,'terminal':code,'errors':errors,'pid':proc.pid if proc else None,'slot_released':not live,'engines_after':live,'elapsed_seconds':time.monotonic()-started,'ended_utc':datetime.datetime.now(datetime.timezone.utc).isoformat()}
 result['harness_pins']=harness
 result['app_binding_sha256']=digest(BASE/'app-binding.json') if app_binding else None
 result['ok']=code==0 and not errors and not live;receipt.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
sys.exit(0 if result['ok'] else 1)

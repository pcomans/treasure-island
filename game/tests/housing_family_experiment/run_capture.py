"""One owned source-render child, adapted from the proven accepted34 runner."""
from pathlib import Path
import sys,subprocess,json,time,datetime,os,re
ROOT=Path(__file__).resolve().parents[3]
GODOT=ROOT.parent/'treasure-island/.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot'
run=ROOT/'evidence/housing-family-experiment'/sys.argv[1]
run.mkdir(parents=True,exist_ok=False)
manifest=Path(sys.argv[2]).resolve();out=run/'images'
proc=None;code=None;errors=[];start=time.monotonic()
def engines():
 rows=subprocess.check_output(['ps','-axo','pid=,comm='],text=True).splitlines()
 return [r.strip() for r in rows if re.search(r'Godot|Treasure.?Island.*Playable',r,re.I)]
def alive(pid):
 try: os.kill(pid,0);return True
 except ProcessLookupError:return False
try:
 assert not engines(),engines()
 cmd=[str(GODOT),'--path',str(ROOT),'--rendering-method','forward_plus','--rendering-driver','metal','--display-driver','macos','--audio-driver','Dummy','--resolution','1440x900','--script',str(ROOT/'game/tests/housing_family_experiment/capture.gd'),'--','--manifest='+str(manifest),'--output='+str(out)]
 with (run/'engine.log').open('w') as log:
  proc=subprocess.Popen(cmd,stdout=log,stderr=subprocess.STDOUT)
  (run/'live-process.json').write_text(json.dumps({'pid':proc.pid,'command':cmd},indent=2))
  try:code=proc.wait(timeout=500)
  except subprocess.TimeoutExpired:
   errors.append('timeout');proc.terminate()
   try:code=proc.wait(timeout=10)
   except subprocess.TimeoutExpired:proc.kill();code=proc.wait()
except BaseException as e:errors.append(repr(e))
finally:
 if proc and proc.poll() is None:proc.kill();code=proc.wait()
 census=engines();released=not census and (proc is None or not alive(proc.pid))
 log=(run/'engine.log').read_text() if (run/'engine.log').exists() else ''
 script_errors=[l for l in log.splitlines() if 'ERROR:' in l or 'Parse Error:' in l]
 receipt={}
 try:receipt=json.loads((out/'capture-receipt.json').read_text())
 except BaseException as e:errors.append('missing receipt '+repr(e))
 result={'terminal':code,'errors':errors,'engine_errors':script_errors,'receipt_ok':receipt.get('ok',False),'elapsed_seconds':time.monotonic()-start,'pid':proc.pid if proc else None,'slot_released':released,'engines_after':census,'ended_utc':datetime.datetime.now(datetime.timezone.utc).isoformat()}
 result['ok']=code==0 and not errors and not script_errors and result['receipt_ok'] and released
 (run/'result.json').write_text(json.dumps(result,indent=2)+'\n')
 print(json.dumps(result,indent=2))
sys.exit(0 if result['ok'] else 1)

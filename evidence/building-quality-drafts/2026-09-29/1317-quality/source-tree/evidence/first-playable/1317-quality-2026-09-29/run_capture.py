import subprocess,time,json,os,sys
from pathlib import Path
root=Path('/Users/user302070/code/treasure-island-1317-quality'); attempt=sys.argv[1]; out=root/'evidence/first-playable/1317-quality-2026-09-29'/attempt;log=out.parent/(attempt+'-engine.log')
cmd=['/Users/user302070/code/treasure-island/.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot','--path',str(root),'--display-driver','macos','--rendering-method','forward_plus','--rendering-driver','metal','--audio-driver','Dummy','--resolution','1440x900','--fixed-fps','60','--script','game/tests/d5_1317_quality_candidate_capture.gd','--','--output='+str(out)]
receipt=log.parent/(attempt+'-process.json');result_path=log.parent/(attempt+'-result.json')
assert not any(p.exists() for p in [out,log,receipt,result_path]), 'Attempt paths already exist'
with log.open('x') as f:
 p=subprocess.Popen(cmd,stdout=f,stderr=subprocess.STDOUT);print('PID',p.pid,flush=True)
 (log.parent/(attempt+'-process.json')).write_text(json.dumps({'pid':p.pid,'argv':cmd}))
 try:code=p.wait(timeout=360)
 except subprocess.TimeoutExpired:
  p.terminate()
  try:code=p.wait(timeout=10)
  except subprocess.TimeoutExpired:p.kill();code=p.wait()
 try:os.kill(p.pid,0);alive=True
 except ProcessLookupError:alive=False
 result={'pid':p.pid,'terminal':code,'exited':not alive,'log':str(log)};(log.parent/(attempt+'-result.json')).write_text(json.dumps(result));print(result)

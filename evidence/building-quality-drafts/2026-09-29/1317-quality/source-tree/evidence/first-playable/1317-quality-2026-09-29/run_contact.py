import subprocess,time,json,os,sys
from pathlib import Path
root=Path('/Users/user302070/code/treasure-island-1317-quality'); attempt=sys.argv[1]; input_map=Path(sys.argv[2]).resolve(); input_hash=sys.argv[3]; out=root/'evidence/first-playable/1317-quality-2026-09-29'/attempt;log=out.parent/(attempt+'-engine.log')
cmd=['/Users/user302070/code/treasure-island/.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot','--path',str(root),'--display-driver','macos','--rendering-method','forward_plus','--rendering-driver','metal','--audio-driver','Dummy','--resolution','1440x900','--fixed-fps','60','--script','game/tests/d5_1317_quality_contact.gd','--','--output='+str(out),'--input-map='+str(input_map),'--input-map-sha256='+input_hash]
if len(sys.argv)>4:
 assert sys.argv[4]=='--remaining-upper'
 cmd.append(sys.argv[4])
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
 errors=[line for line in log.read_text().splitlines() if any(token in line for token in ['SCRIPT ERROR:', 'Shader compilation failed', 'Parse Error:', 'ERROR:'])]; census=[line for line in subprocess.check_output(['ps','-axo','pid=,command='],text=True).splitlines() if '/Godot.app/Contents/MacOS/Godot ' in line]; result={'pid':p.pid,'terminal':code,'exited':not alive,'log':str(log),'engine_errors':errors,'engines_after':census};(log.parent/(attempt+'-result.json')).write_text(json.dumps(result));print(result)

sys.exit(0 if code==0 and not alive and not errors and not census else 1)

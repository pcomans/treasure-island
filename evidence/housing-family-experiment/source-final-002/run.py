from pathlib import Path
import subprocess,sys,json,time,os,re
root=Path.cwd();out=Path(__file__).resolve().parent;name=sys.argv[1]
rows=subprocess.check_output(['ps','-axo','pid=,comm='],text=True).splitlines()
assert not [r for r in rows if re.search(r'Godot|Treasure.?Island.*Playable',r,re.I)]
cmd=[str(root.parent/'treasure-island/.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot'),'--headless','--path',str(root),'--script','res://game/tests/'+name+'.gd']
begin=time.monotonic()
with (out/(name+'.log')).open('w') as log:
 p=subprocess.Popen(cmd,stdout=log,stderr=subprocess.STDOUT)
 print('PID',p.pid,flush=True)
 (out/(name+'-process.json')).write_text(json.dumps({'pid':p.pid,'command':cmd},indent=2)+'\n')
 try:code=p.wait(timeout=300)
 except subprocess.TimeoutExpired:p.terminate();code=p.wait(timeout=10)
text=(out/(name+'.log')).read_text();errors=[s for s in text.splitlines() if 'ERROR:' in s or 'Parse Error:' in s]
rows=subprocess.check_output(['ps','-axo','pid=,comm='],text=True).splitlines();engines=[r for r in rows if re.search(r'Godot|Treasure.?Island.*Playable',r,re.I)]
result={'terminal':code,'engine_errors':errors,'pid':p.pid,'slot_released':not engines,'elapsed_seconds':time.monotonic()-begin,'ok':code==0 and not errors and not engines}
(out/(name+'-result.json')).write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result));print(text[-5000:]);sys.exit(0 if result['ok'] else 1)

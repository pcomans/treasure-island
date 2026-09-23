from pathlib import Path
from datetime import datetime,timezone
import hashlib,os,subprocess,json,re,sys
W=Path(__file__).resolve().parent
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
stages=sys.argv[1:]
assert stages and len(set(stages))==len(stages) and all(n in json.loads((W/'source-run-plan.json').read_text()) for n in stages)
release_path=W/('SLOT_RELEASE-'+'-'.join(stages)+'.json')
assert not release_path.exists(),'Never overwrite invocation release'
receipts={n:json.loads((W/(n+'-execution.json')).read_text()) for n in stages if (W/(n+'-execution.json')).exists()}
assert receipts,'Actual owned receipt required'
owned=[]
for name,r in receipts.items():
 assert r['status']=='terminal'
 try:os.kill(r['pid'],0);absent=False
 except ProcessLookupError:absent=True
 owned.append({'stage':name,'pid':r['pid'],'exit_code':r['exit_code'],'elapsed_seconds':r['elapsed_seconds'],'fresh_pid_absent':absent,'receipt_sha256':sha(W/(name+'-execution.json')),'log_sha256':sha(W/(name+'.log')),'pins_unchanged':r['pins_unchanged']})
ps=subprocess.check_output(['/bin/ps','-axo','pid=,ppid=,comm='],text=True)
rows=[x.strip() for x in ps.splitlines() if re.search(r'godot|treasure.?island.*playable',x,re.I)]
record={'at':datetime.now(timezone.utc).isoformat(),'stages':owned,'engine_processes':rows,'slot_released':all(x['fresh_pid_absent'] for x in owned) and not rows,'result_files_present':[n for n in [n+'-result.json' for n in stages] if (W/n).exists()],'retry':False}
release_path.write_text(json.dumps(record,indent=2)+'\n')
print(json.dumps({'sha256':sha(release_path),**record}));assert record['slot_released']

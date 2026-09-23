from pathlib import Path
import json,hashlib,subprocess,sys,shutil,datetime
W=Path(__file__).resolve().parent
assert sys.argv[1:]==['--root-authorized-isolated-materialization']
b=json.loads((W/'base-binding.json').read_text());Q=Path(b['repo']);S=W/'source'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
# Approved identity comparison is before the first destination write.
assert b['base_commit']=='fdfc100704200e6570b654a4e6a4fccc9a1a61be'
assert subprocess.check_output(['/usr/bin/git','--no-optional-locks','rev-parse','HEAD'],cwd=Q,text=True).strip()==b['base_commit']
assert subprocess.run(['/usr/bin/git','symbolic-ref','-q','HEAD'],cwd=Q,stdout=subprocess.DEVNULL).returncode==1
assert not subprocess.check_output(['/usr/bin/git','--no-optional-locks','status','--porcelain=v1'],cwd=Q,text=True).strip()
assert not(Q/'.godot').exists() and not(W/'MATERIALIZED.json').exists()
selected=json.loads((W/'selected-files.json').read_text());staged=json.loads((W/'staged-source-pins.json').read_text())
assert all(sha(Path(p))==h for p,h in staged.items())
copied=[]
for staged_path,h in staged.items():
 source=Path(staged_path);rel=str(source.relative_to(S));p=Q/rel
 assert sha(source)==h
 if p.is_file() and sha(p)==h:continue
 # Reuse existing reviewed bytes, including any skipped-smudge resources; no network hydration.
 p.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(source,p);copied.append(rel)
pins=json.loads((W/'source-pins.json').read_text());assert all(Path(p).is_file() and sha(Path(p))==h for p,h in pins.items())
(W/'MATERIALIZED.json').write_text(json.dumps({'at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'base_commit':b['base_commit'],'destination':str(Q),'selected':selected,'actual_copied_paths':copied,'source_pins_sha256':sha(W/'source-pins.json'),'engine':False},indent=2)+'\n')
print('MATERIALIZED',sha(W/'MATERIALIZED.json'))

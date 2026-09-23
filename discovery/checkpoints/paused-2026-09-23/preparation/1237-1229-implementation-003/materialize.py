"""Prepared only; execute solely after independent readiness and exact ROOT GO."""
from pathlib import Path
import json,hashlib,subprocess,os,shutil,datetime
W=Path(__file__).resolve().parent;M=Path('/Volumes/Macintosh_HD/Users/user302070/code/treasure-island');R=M.with_name('treasure-island-1237-1229-study-v1');BASE='fdfc100704200e6570b654a4e6a4fccc9a1a61be';sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
assert not R.exists(),'Inspect any existing checkout; never retry blindly'
pins=json.loads((W/'source-pins.json').read_text());assert all(sha(p)==h for p,h in pins.items())
inputs=json.loads((W/'materialization-inputs.json').read_text());assert all(sha(v['source'])==v['sha256']for v in inputs.values())
env=os.environ.copy();env['GIT_LFS_SKIP_SMUDGE']='1'
cmd=['git','-c','filter.lfs.required=false','-c','filter.lfs.smudge=','-c','filter.lfs.process=','worktree','add','--detach',str(R),BASE]
r=subprocess.run(cmd,cwd=M,env=env,capture_output=True,text=True);receipt=dict(at=datetime.datetime.now(datetime.timezone.utc).isoformat(),argv=cmd,exit_code=r.returncode,stdout=r.stdout,stderr=r.stderr)
(W/'materialization-raw.json').write_text(json.dumps(receipt,indent=2)+'\n')
# A hook exit is not a missing checkout: inspect once before any further action.
assert R.is_dir() and (R/'.git').is_file(),receipt
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=R,text=True).strip()==BASE
assert not subprocess.check_output(['git','status','--porcelain'],cwd=R,text=True).strip()
for rel,v in inputs.items():
 dst=R/rel;src=Path(v['source'])
 if str(src).startswith(str(W/'staged')+'/'):
  assert not dst.exists();dst.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(src,dst)
 else:
  assert dst.is_file(),rel
  if sha(dst)!=v['sha256']:
   pointer=dst.read_text()
   assert pointer.startswith('version https://git-lfs.github.com/spec/v1\n') and 'oid sha256:'+v['sha256'] in pointer and 'size '+str(src.stat().st_size) in pointer,rel
   shutil.copyfile(src,dst) # Existing exactly bound bytes only; no hydration/network/global config.
assert all(sha(R/rel)==v['sha256']for rel,v in inputs.items())
for q in json.loads((W/'run-plan.json').read_text()).values():
 if 'image_dir' in q:
  p=Path(q['image_dir']);assert not p.exists();p.mkdir(parents=True);(p.parent/'.gdignore').write_text('')
(R/'build').mkdir(exist_ok=True);(R/'build/.gdignore').write_text('')
receipt.update(materialized=True,source_inputs_equal=True,engine_executed=False);(W/'MATERIALIZED.json').write_text(json.dumps(receipt,indent=2)+'\n')

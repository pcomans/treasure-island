from pathlib import Path
import json,hashlib,sys,ast,re,datetime
W=Path(__file__).resolve().parent
R=Path('/Volumes/Macintosh_HD/Users/user302070/code/treasure-island-1397-1226-live-candidate-v1')
read=lambda f:json.loads(Path(f).read_text())
sha=lambda f:hashlib.sha256(Path(f).read_bytes()).hexdigest()
assert sys.argv[1:]==['--root-authorized-package-main-overlay']
exec((W/'identity-guard.py').read_text(),globals())
assert not (W/'MATERIALIZED.json').exists(),'Never repeat a completed materialization'
assert all(sha(q)==h for q,h in read(W/'execution-input-pins.json').items())
assert all(sha(q)==h for q,h in read(W/'MAIN_GUARD.json')['pins'].items())
before=read(W/'source-before-package-pins.json');after=read(W/'package-source-pins.json')
assert all(sha(q)==h for q,h in before.items())
main=R/'game/scripts/main.gd'
assert set(before)==set(after) and [q for q in before if before[q]!=after[q]]==[str(main)]
assert sha(W/'main-before-package.gd')==before[str(main)] and sha(W/'proposed-main.gd')==after[str(main)]
main.write_bytes((W/'proposed-main.gd').read_bytes())
assert all(sha(q)==h for q,h in after.items())
assert all(sha(q)==h for q,h in read(W/'MAIN_GUARD.json')['pins'].items())
r=dict(status='PACKAGE_MAIN_MATERIALIZED',at=datetime.datetime.now(datetime.timezone.utc).isoformat(),base=APPROVED_BASE,main_before=before[str(main)],main_after=after[str(main)],source_map_sha256=sha(W/'package-source-pins.json'),source_count=len(after),engine_invoked=False)
(W/'MATERIALIZED.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r))

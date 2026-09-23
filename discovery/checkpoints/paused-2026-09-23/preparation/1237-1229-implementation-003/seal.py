from pathlib import Path
import json,hashlib,ast,re,difflib,datetime,subprocess
W=Path(__file__).resolve().parent;M=Path('/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1237-1229-implementation-003/frozen-main');h=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();sp=json.load(open(W/'targets.json'));inputs=json.load(open(W/'materialization-inputs.json'));assert all(h(Path(v['source']))==v['sha256'] for v in inputs.values())
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=M,text=True).strip()=='fdfc100704200e6570b654a4e6a4fccc9a1a61be'
checks=[];diff='';sources=[]
for v in sp:
 out=W/v['address'];pf=json.load(open(out/'PREFLIGHT_RESULT.json'));assert pf['ok'] and all(h(Path(p))==s for p,s in pf['input_hashes'].items());cfg=json.load(open(W/'staged/game/resources/facades'/(v['name']+'.json')));assert 'path' not in cfg['source_association'];assert not cfg['shallow_band']['triangles'] and not cfg['carports'];assert len(json.load(open(out/'view-plan.json'))['views'])==4
 gd=(W/'staged/game/scripts/world/facades'/(v['name']+'.gd')).read_text();assert not re.search(r'^class_name',gd,re.M);assert 'load(SELF_PATH).new()'in gd and '_append_roof(cfg.roof_termination.triangles, "PaleDrainageAndFascia")'in gd
 for rel in ['game/scripts/world/facades/'+v['name']+'.gd','game/resources/facades/'+v['name']+'.json']:
  p=W/'staged'/rel;sources.append(p);diff+=''.join(difflib.unified_diff([],p.read_text().splitlines(True),fromfile='/dev/null',tofile='b/'+rel))
 checks.append(dict(unit=v['address'],file_checks=len(pf['checks']),mapped=cfg['mapped_runs'],protected=cfg['protected_runs'],views=4,closed_roof_triangles=len(cfg['public_roof']['triangles']),attached_termination_triangles=len(cfg['roof_termination']['triangles']),broad_band_triangles=0))
selected=[p for p in W.rglob('*') if p.is_file() and not p.is_symlink() and 'staged' not in p.relative_to(W).parts and p.suffix in ['.py','.gd','.json']]+sources
for p in selected:
 if p.suffix=='.py':ast.parse(p.read_text())
 assert all(line.rstrip()==line for line in p.read_text().splitlines()),p
(W/'source.diff').write_text(diff)
(W/'FILE_CHECKS.json').write_text(json.dumps(dict(ok=True,units=checks,selected_whitespace_and_python_ast=len(selected),base_inputs=len(inputs),external_registration='No copied global class; canonical builder preload and explicit source Script construction retained',engine_executed=False),indent=2)+'\n')
pins={v['source']:v['sha256'] for v in inputs.values()}
for p in W.rglob('*'):
 if p.is_file() and not p.is_symlink() and 'staged' not in p.relative_to(W).parts and p.name not in ['FILE_READY.json','source-pins.json','FILE_READY.md','RETRO-next_family_reference_prep.md']:pins[str(p)]=h(p)
for p in sources:pins[str(p)]=h(p)
review=W.parent/'next-two-family-reference-preparation-002/independent-source-001/REVIEW.md';pins[str(review)]=h(review)
for p in (review.parent.parent/'images').glob('*.png'):pins[str(p)]=h(p)
(W/'source-pins.json').write_text(json.dumps(dict(sorted(pins.items())),indent=2)+'\n')
ready=dict(status='FILE_READY_PENDING_INDEPENDENT_READINESS_AND_EXACT_ROOT_GO',at=datetime.datetime.now(datetime.timezone.utc).isoformat(),first_source_edit=json.load(open(W/'FIRST_SOURCE_EDIT.json')),base='fdfc100704200e6570b654a4e6a4fccc9a1a61be',capture_authority='32/213',proposed_checkout='/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1237-1229-implementation-003/frozen-main-1237-1229-study-v1',staged_overlay='Read-only MAIN symlinks plus four new regular target files; not a checkout or runnable project',units=checks,bindings={n:h(W/n)for n in ['source-pins.json','materialization-inputs.json','run-plan.json','FILE_CHECKS.json','source.diff']},materialize_argv=['/usr/bin/python3','-B',str(W/'materialize.py')],import_focused_argv=['/usr/bin/python3','-B',str(W/'run-reviewed-chain.py'),'import-001','focused-1237-001','focused-1229-001'],native_argv=['/usr/bin/python3','-B',str(W/'run-reviewed-chain.py'),'native-1237-001','native-1229-001'],engine_executed=False,recognition_credit=0)
(W/'FILE_READY.json').write_text(json.dumps(ready,indent=2)+'\n');print('READY',h(W/'FILE_READY.json'),'PINS',h(W/'source-pins.json'),'checks',checks)

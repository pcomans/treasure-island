from pathlib import Path
import json,hashlib,subprocess,re,ast,datetime,difflib
W=Path(__file__).resolve().parent;S=W/'source';M=Path('/Volumes/Macintosh_HD/Users/user302070/code/treasure-island');B='fdfc100704200e6570b654a4e6a4fccc9a1a61be';Q=Path(json.loads((W/'base-binding.json').read_text())['repo']);sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());save=lambda p,v:p.write_text(json.dumps(v,indent=2)+'\n')
assert subprocess.check_output(['/usr/bin/git','--no-optional-locks','rev-parse','HEAD'],cwd=M,text=True).strip()==B
runner=(W/'run-stage.py').read_text();assert runner.count("== '"+B+"'")==1
assert not Q.exists(),'No candidate checkout yet; do not overwrite an existing one'
# Check all actual current source consumers before writing the final maps.
reg=S/'game/resources/facades/facade-runtime-registry.json';contracts=S/'game/resources/facades/facade-runtime-adapter-contracts.json';assert read(reg)['units']==read(M/'game/resources/facades/facade-runtime-registry.json')['units'];catalog='discovery/facades/facade-recognition-catalog.json';assert sha(S/catalog)==sha(M/catalog)
for rel,pairs in [('game/tests/headless_facade_recognition_registry_contract.gd',{'EXPECTED_REGISTRY_SHA256':sha(reg)}),('game/tests/headless_facade_runtime_registry_loader_contract.gd',{'EXPECTED_REGISTRY_SHA256':sha(reg),'EXPECTED_ADAPTER_CONTRACT_SHA256':sha(contracts)})]:
 s=(S/rel).read_text()
 for name,h in pairs.items():assert re.search(r'const '+name+r' := "([a-f0-9]{64})"',s)[1]==h
for stem in ['gateview_1397','bayside_1226']:
 adapter=S/('game/scripts/world/facades/'+stem+'_live_replacement.gd');ap='res://'+str(adapter.relative_to(S));ah=sha(adapter)
 for rel in ['tools/build_facade_recognition_registry.mjs','game/tests/headless_facade_recognition_registry_contract.gd','game/scripts/world/facades/facade_runtime_registry_loader.gd']:
  text=(S/rel).read_text();assert ah in text and ap.removeprefix('res://') in text
 for name in ['project.binary','project.godot']:assert adapter.read_text().count('FileAccess.file_exists("res://'+name+'")')==1
for p in W.glob('*.py'):ast.parse(p.read_text())
selected=read(W/'selected-files.json');assert all(sha(S/rel)==h for rel,h in selected.items())
whitespace=[]
for rel in selected:
 p=S/rel;old=M/rel if(M/rel).exists()else Path('/dev/null');r=subprocess.run(['/usr/bin/git','diff','--no-index','--check',str(old),str(p)],capture_output=True,text=True)
 if r.stdout.strip()or r.stderr.strip():whitespace.append({'path':rel,'stdout':r.stdout,'stderr':r.stderr})
assert not whitespace,whitespace
staged={str(p):sha(p)for p in sorted(S.rglob('*'))if p.is_file()};save(W/'staged-source-pins.json',staged)
# These are prospective destination bindings, not claims that Q exists.
pins={str(Q/Path(p).relative_to(S)):h for p,h in staged.items()}
external=['base-binding.json','source-run-plan.json','cache-preflight.json','SOURCE_EVIDENCE_BINDINGS.json','source-preparation.json','baseline-world.json','unit-expectations.json','callback-baseline-binding.json','accepted-registry-before.json','focused_live_contract.gd','observed_builder.gd','comparison/current-chunk-builder.gd','comparison/study-1397.gd','comparison/study-1226.gd','run-reviewed-chain.py','run-stage.py','release.py']
for rel in external:pins[str(W/rel)]=sha(W/rel)
for p in read(W/'source-preparation.json')['receipts']:pins[p]=sha(Path(p))
save(W/'source-pins.json',pins)
status=subprocess.check_output(['/usr/bin/git','--no-optional-locks','status','--porcelain=v1'],cwd=M,text=True);uids={line[3:]:sha(M/line[3:])for line in status.splitlines()};assert len(uids)==4 and all(line.startswith('?? ')and line.endswith('.gd.uid')for line in status.splitlines())
save(W/'MAIN-preservation.json',{'HEAD':B,'index_sha256':sha(M/'.git/index'),'untracked_uids':uids,'status':status})
checks={'engine_invoked':False,'candidate_materialized':False,'staged_files':len(staged),'selected_files':len(selected),'all213_unit_records_equal':True,'catalog_byte_equal':True,'new_recognition_credit':0,'native_current_hashes':'PASS','three_format_probe_consumers':'PASS','selected_whitespace':'PASS','python_ast':'PASS','world_baseline':read(W/'baseline-world.json'),'world_proposal':read(W/'expected-world.json'),'same_chunk_callbacks':{'1397':42,'1226':140}};save(W/'FILE_CHECKS.json',checks)
argv=['/usr/bin/env','TI_1397_1226_ENGINE_GO='+B,'/usr/bin/python3','-B',str(W/'run-reviewed-chain.py'),'import-001','focused-001','native-registry-001','native-loader-001']
save(W/'FILE_READY.json',{'status':'FILE_READY_PENDING_INDEPENDENT_REVIEW_MATERIALIZATION_AND_ROOT_ENGINE_GO','at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'base':B,'authority':'32/213','credit':0,'frozen_study_authority':'31/213','units':['physical-building:w96215670','physical-building:w96215685'],'source_root':str(S),'future_candidate':str(Q),'selected':selected,'staged_source_pins_sha256':sha(W/'staged-source-pins.json'),'prospective_source_pins_sha256':sha(W/'source-pins.json'),'file_checks_sha256':sha(W/'FILE_CHECKS.json'),'argv':argv,'cwd':str(W),'pending':['independent source readiness','root-authorized isolated materialization and actual source-map verification','separate exact root engine GO','actual source/live equivalence and registry/loader results','candidate package,role6,seventh'],'actual_nonengine':read(W/'source-preparation.json')})
print('FILE_READY',sha(W/'FILE_READY.json'),'PINS',sha(W/'source-pins.json'),'SELECTED',len(selected),'STAGED',len(staged))

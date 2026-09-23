from pathlib import Path
import json,hashlib,ast,re
from datetime import datetime,timezone
W=Path(__file__).resolve().parent;P=W.parent;S=P/'1237-1229-implementation-003';D=P/'1397-mechanics-001';R=Path('/Volumes/Macintosh_HD/Users/user302070/code/treasure-island-1237-1229-study-v1')
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
def write(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
checks={};pins=json.loads((S/'source-pins.json').read_text());assert all(sha(k)==v for k,v in pins.items());checks['prior_frozen_source_exact']=True
materialized=json.loads((S/'materialization-inputs.json').read_text())
for rel,row in materialized.items():
 p=R/rel;assert sha(p)==row['sha256'];pins[str(p)]=sha(p)
for row in json.loads((S/'materialization-continuation-001.json').read_text())['copies']:
 assert sha(row['destination'])==row['sha256'];pins[row['destination']]=row['sha256']
imp=json.loads((S/'import-001-execution.json').read_text())
for p,h in imp['post_import_outputs'].items():assert sha(p)==h;pins[p]=h
checks['materialized_sources_and_eight_continuation_files_exact']=True;checks['canonical_import_cache_uids_exact']=True
for t in ['1237','1229']:
 plan=json.loads((W/t/'route-plan.json').read_text());assert len(plan['routes'])==(4 if t=='1237'else 2) and len(plan['sprays'])==3
 for n in ['FOOTPRINT_PREFLIGHT.json','ROUTE_PREFLIGHT.json','COMPONENT_RETURN_PREFLIGHT.json']:assert json.loads((W/t/n).read_text())['ok']
 c=json.loads((W/t/'COMPONENT_RETURN_PREFLIGHT.json').read_text())
 for route,rows in zip(plan['routes'],c['routes']):
  assert route['id']==rows['id'];assert route['brake_frames']==route['retreat']['brake_frames']==30
  assert all(not row['failures']for row in rows['geometry_rows']);assert rows['geometry_rows']
  assert all(abs(rows['component_rows'][-1]['velocity'][j])<1e-9 for j in [0,2])
 s=(W/t/'live_driver.gd').read_text();donor=(D/'1397/live_driver.gd').read_text()
 def part(txt,fn):
  a=txt.index('func '+fn+'(');b=txt.find('\nfunc ',a+5);return txt[a:b if b>=0 else None].strip()
 for fn in ['_route_attempt','_retreat_attempt','_corridor_rows','_return_path_rows','_decal_full_footprint','_player_land_state','_trace_phase']:
  assert part(s,fn)==part(donor,fn).replace(' and land_rows>0',''),(t,fn)
 assert 'class_name'not in s and 'checked==9'in s and ' and land_rows>0'not in s
 assert 'var source_collision: Dictionary = {}'in s
 assert s.count('func _capture_activation(')==1 and s.count('func _activation_state(')==1
 checks[t]={'full_route_and_return_geometry':True,'unchanged_donor_movement_support_camera_decal_functions_except_event_assertion':True,'global_class_declarations':0,'routes':len(plan['routes']),'sprays':len(plan['sprays']),'max_physics_rows':plan['physical_rows_max']}
controller=(R/'game/scripts/player/player_controller.gd').read_text()
for name,value in [('walk_speed_mps',4.0),('run_speed_mps',20.0),('acceleration_mps2',30.0),('braking_mps2',40.0)]:assert 'var '+name+' := '+str(value)in controller
for p in W.rglob('*'):
 if not p.is_file() or p.suffix not in ['.gd','.py','.json','.md']:continue
 if p.suffix=='.py':ast.parse(p.read_text())
 assert all(line.rstrip()==line for line in p.read_text().splitlines()),str(p)
checks['selected_file_whitespace_and_python_parse_only']=True;checks['engine_test_build_git_main_mutation']=False
for p in [S/'MATERIALIZED.json',S/'materialization-inputs.json',S/'materialization-continuation-001.json',S/'SLOT_RELEASE-native-1237-001-native-1229-001.json',S/'independent-actual-source-001/REVIEW.md',S/'independent-actual-native-001/REVIEW.md',S/'visual-review-001/REVIEW.md',P/'1397-first-five-preparation-001/FILE_READY.json',D/'1397/live_driver.gd',D/'run-1397.py',D/'run-stage.py',D/'release.py',D/'finalize-1397.py',D/'review-actual-support_event_diagnosis.py',P/'1221-mechanics-001/route-preflight.py',P/'1238-northpoint-study-002/file-preflight.py']:
 pins[str(p)]=sha(p)
for p in (P/'next-two-family-reference-preparation-002').rglob('*'):
 if p.is_file():pins[str(p)]=sha(p)
for t in ['1237','1229']:
 for kind in ['native','focused']:
  for suffix in ['-execution.json','-result.json']:p=S/(f'{kind}-{t}-001'+suffix);pins[str(p)]=sha(p)
 for p in (S/t/'capture/images').glob('*.png'):pins[str(p)]=sha(p)
 for p in [S/t/'live_driver.gd',R/f'game/scripts/world/facades/northpoint_{t}_study.gd',R/f'game/resources/facades/northpoint_{t}_study.json']:pins[str(p)]=sha(p)
write(W/'FILE_CHECKS.json',{'ok':True,'checks':checks,'scope':'Static file preparation only; no engine/script execution or independent acceptance.'})
for p in W.rglob('*'):
 if p.is_file() and p.name not in ['source-pins.json','FILE_READY.json']:pins[str(p)]=sha(p)
assert all('/code/treasure-island/'not in p or '/.tools/godot/'in p for p in pins),'Mutable MAIN input dependency'
write(W/'source-pins.json',dict(sorted(pins.items())))
write(W/'FILE_READY.json',{'status':'FILE_READY_PENDING_INDEPENDENT_MEDIUM_READINESS_AND_ROOT_GO','at':datetime.now(timezone.utc).isoformat(),'author':'next_pair_mechanics_preparation','model':'gpt-6-astra','effort':'low','cwd':str(W),'source_checkout':str(R),'base':'fdfc100704200e6570b654a4e6a4fccc9a1a61be','authority':'32/213','intended_invocations':[['/usr/bin/python3','-B',str(W/'run-1237.py')],['/usr/bin/python3','-B',str(W/'run-1229.py')]],'invocation_boundary':'Each native stage requires exact ROOT GO and owned release; no import/materializer or automatic second-stage dispatch. Retain same actual handle on timeout.','pins_sha256':sha(W/'source-pins.json'),'pin_count':len(pins),'delta_sha256':sha(W/'DELTA.json'),'checks_sha256':sha(W/'FILE_CHECKS.json'),'retro':str(W/'discovery/RETRO_LOG.md'),'no_engine_executed':True,'no_MAIN_or_QS_edits':True,'recognition_credit':0})
print('FILE_READY',sha(W/'FILE_READY.json'),'PINS',sha(W/'source-pins.json'),len(pins))

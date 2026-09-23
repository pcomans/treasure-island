# File-only completion of pending actual/review bindings; run only after independent PASS.
from pathlib import Path
import json,hashlib,sys
p=Path(__file__).resolve().parent
read=lambda q:json.loads(Path(q).read_text())
sha=lambda q:hashlib.sha256(Path(q).read_bytes()).hexdigest()
authorization=Path(sys.argv[1]);a=read(authorization)
assert a['status']=='independently_passed' and a['units']==['1397','1226']
assert a['prepared_input_map_sha256']==sha(p/'execution-input-pins.json')
assert all(sha(q)==h for q,h in read(p/'execution-input-pins.json').items())
assert read(p/'MATERIALIZED.json')['status']=='PACKAGE_MAIN_MATERIALIZED'
assert sha(p/'proposed-main.gd')==read(p/'MATERIALIZED.json')['main_after']
assert a['independent_source_review'] in a['bindings'] and a['independent_preparation_review'] in a['bindings']
assert all(sha(q)==h for q,h in a['bindings'].items())
for n in ['execution-settings.json','unit-packet-prerequisites.json','readiness-binding.json','reused-cache-pins.json']:
 assert not (p/n).exists(),'Never replace an actual readiness binding'
settings=read(p/'execution-settings.template.json');source=Path(settings['reused_import_receipt']).parent;continuation=Path('/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1397-1226-live-continuation-001')
assert sha(settings['source_pin_map'])==settings['source_pin_map_sha256']
assert all(sha(q)==h for q,h in read(settings['source_pin_map']).items())
for n in ['focused-002','native-registry-001','native-loader-001']:
 r=read(continuation/(n+'-execution.json'))
 assert r['status']=='terminal' and r['exit_code']==0 and r['pins_unchanged'] and r['pid_absent'] and not r['log_errors'] and r['result_ok']
 assert str(continuation/(n+'-execution.json')) in a['bindings'],'Independent actual seal must bind each terminal receipt'
assert read(continuation/'SLOT_RELEASE-focused-002-native-registry-001-native-loader-001.json')['slot_released']
assert str(continuation/'SLOT_RELEASE-focused-002-native-registry-001-native-loader-001.json') in a['bindings']
focused=read(continuation/'focused-002-result.json');assert focused['ok'] and focused['measured_world']==settings['planned_world']
assert sha(continuation/'focused-002-result.json')==read(continuation/'focused-002-execution.json')['result_sha256']
imp=read(settings['reused_import_receipt']);assert imp['status']=='terminal' and imp['exit_code']==0 and imp['class_discovery_ok']
repo=Path(settings['repo']);settings['canonical_cache_sha256']=imp['class_cache_sha256']
cache={str(repo/'.godot/global_script_class_cache.cfg'):imp['class_cache_sha256']}
assert len(imp['import_output_uids'])==4
cache.update({str(repo/q):h for q,h in imp['import_output_uids'].items()});assert all(sha(q)==h for q,h in cache.items())
units=read(p/'unit-packet-prerequisites.template.json')
for unit in units:
 assert unit['closure'] in a['bindings'] and all(sha(q)==h for q,h in unit['bindings'].items())
 unit['status']='independently_passed';unit['independent_review']=a['independent_preparation_review']
 unit['bindings'].update(a['bindings'])
def dump(n,o):(p/n).write_text(json.dumps(o,indent=2)+'\n')
dump('execution-settings.json',settings);dump('unit-packet-prerequisites.json',units);dump('reused-cache-pins.json',cache)
bindings={**a['bindings'],str(authorization):sha(authorization),str(p/'execution-settings.json'):sha(p/'execution-settings.json'),str(p/'unit-packet-prerequisites.json'):sha(p/'unit-packet-prerequisites.json'),str(p/'reused-cache-pins.json'):sha(p/'reused-cache-pins.json')}
dump('readiness-binding.json',dict(status='BOUND_ACTUAL_AND_INDEPENDENT_PASS',bindings=bindings,engine_invoked=False))
print(sha(p/'readiness-binding.json'))

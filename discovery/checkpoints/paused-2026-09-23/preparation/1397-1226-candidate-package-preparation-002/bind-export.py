# File-only post-export binding; never manufactures an app or a successful receipt.
from pathlib import Path
import json,hashlib,subprocess,datetime
p=Path(__file__).resolve().parent
settings=json.loads((p/'execution-settings.json').read_text());app=Path(settings['app']);binary=app/'Contents/MacOS/Treasure Island First Playable';pck=app/'Contents/Resources/Treasure Island First Playable.pck'
def sha(q):return hashlib.sha256(q.read_bytes()).hexdigest()
def read(q):return json.loads(q.read_text())
assert not (p/'actual-app-binding.json').exists() and not (p/'bundle-native-checks-001.json').exists(),'Preserve each original binding attempt'
export_receipt=read(Path(settings['candidate_export_receipt']))
assert export_receipt['status']=='terminal' and export_receipt['exit_code']==0 and export_receipt['pins_unchanged'] and export_receipt['pid_absent'] and not export_receipt['log_errors']
source_receipt=read(Path(settings['reused_source_receipt']))
source_result=read(Path(settings['reused_source_result']))
assert sha(Path(settings['reused_source_result']))==source_receipt['result_sha256']
assert source_result['authority']==settings['authority']
assert source_receipt['status']=='terminal' and source_receipt['exit_code']==0 and source_receipt['pins_unchanged'] and source_receipt['pid_absent'] and not source_receipt['log_errors'] and source_result['ok']
pins=read(p/'execution-input-pins.json');pins.update(read(Path(settings['source_pin_map'])));assert all(sha(Path(k))==v for k,v in pins.items())
assert source_result['measured_world']==settings['planned_world']
checks={}
commands={
'signature':['/usr/bin/codesign','--verify','--deep','--strict','--verbose=4',str(app)],
'arm64':['/usr/bin/codesign','--verify','--strict','--arch','arm64',str(app)],
'x86_64':['/usr/bin/codesign','--verify','--strict','--arch','x86_64',str(app)],
'architectures':['/usr/bin/lipo','-archs',str(binary)],
'entitlements':['/usr/bin/codesign','--display','--entitlements',':-',str(app)],
'xattrs':['/usr/bin/xattr','-lr',str(app)],
'info':['/usr/bin/plutil','-convert','json','-o','-',str(app/'Contents/Info.plist')],
'privacy':['/usr/bin/plutil','-convert','json','-o','-',str(app/'Contents/Resources/PrivacyInfo.xcprivacy')]}
for name,argv in commands.items():
 result=subprocess.run(argv,capture_output=True,text=True);checks[name]={'argv':argv,'exit_code':result.returncode,'stdout':result.stdout,'stderr':result.stderr}
(p/'bundle-native-checks-001.json').write_text(json.dumps(checks,indent=2)+'\n')
assert all(x['exit_code']==0 for x in checks.values()),'Inspect preserved signature/privacy errors'
assert set(checks['architectures']['stdout'].split())=={'x86_64','arm64'}
entitlement_argv=['/usr/bin/plutil','-convert','json','-o','-','-']
parsed=subprocess.run(entitlement_argv,input=checks['entitlements']['stdout'],capture_output=True,text=True)
checks['entitlements_native_json']={'argv':entitlement_argv,'stdin_source':'codesign entitlements stdout recorded above','exit_code':parsed.returncode,'stdout':parsed.stdout,'stderr':parsed.stderr}
(p/'bundle-native-checks-001.json').write_text(json.dumps(checks,indent=2)+'\n')
assert parsed.returncode==0,'Inspect preserved native entitlement parse error'
entitlements=json.loads(parsed.stdout);assert entitlements=={},'No new entitlement'
info=json.loads(checks['info']['stdout']);assert info['CFBundleIdentifier']=='local.treasure-island.first-playable' and info['CFBundleExecutable']=='Treasure Island First Playable'
privacy=json.loads(checks['privacy']['stdout']);assert privacy=={'NSPrivacyTracking':False}
assert 'com.apple.quarantine' not in checks['xattrs']['stdout']
app_pins={str(q):sha(q) for q in sorted(app.rglob('*')) if q.is_file()};assert len(app_pins)==7,'Inspect unexpected bundle tree instead of accepting it silently'
plan=read(p/'run-plan.json');text=json.dumps(plan,indent=2).replace('<ACTUAL_EXPORTED_PCK_SHA256>',sha(pck))+'\n';(p/'run-plan.bound-app.json').write_text(text)
r={'at':datetime.datetime.now(datetime.timezone.utc).isoformat(),'app':str(app),'app_pins':app_pins,'pck_sha256':sha(pck),'bound_plan_sha256':sha(p/'run-plan.bound-app.json'),'source_input_map_sha256':sha(p/'execution-input-pins.json'),'measured_world':source_result['measured_world'],'bundle_checks_sha256':sha(p/'bundle-native-checks-001.json'),'entitlements':entitlements,'privacy':privacy,'authority':settings['authority'],'credit_granted':False,'candidate_export_receipt_sha256':sha(Path(settings['candidate_export_receipt'])),'source_measurement_scope':source_result['scope']+' Signed-app outcomes pending.'}
(p/'actual-app-binding.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r,indent=2))

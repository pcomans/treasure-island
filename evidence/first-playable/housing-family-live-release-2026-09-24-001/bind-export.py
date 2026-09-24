"""Bind the exact exported signed bundle before any mounted or app stage."""
from pathlib import Path
import hashlib,json,subprocess
P=Path(__file__).resolve().parent
read=lambda p:json.loads(Path(p).read_text())
hashfile=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
assert read(P/'export-001-execution.json')['ok']
assert not (P/'app-binding.json').exists()
plan=read(P/'run-plan.json');app=Path(plan['export-001']['argv'][-1])
binary=app/'Contents/MacOS/Treasure Island First Playable'
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
(P/'bundle-native-checks-001.json').write_text(json.dumps(checks,indent=2)+'\n')
assert all(x['exit_code']==0 for x in checks.values()),'Inspect preserved signature/privacy errors'
assert set(checks['architectures']['stdout'].split())=={'x86_64','arm64'}
entitlement_argv=['/usr/bin/plutil','-convert','json','-o','-','-']
parsed=subprocess.run(entitlement_argv,input=checks['entitlements']['stdout'],capture_output=True,text=True)
checks['entitlements_native_json']={'argv':entitlement_argv,'stdin_source':'codesign entitlements stdout recorded above','exit_code':parsed.returncode,'stdout':parsed.stdout,'stderr':parsed.stderr}
(P/'bundle-native-checks-001.json').write_text(json.dumps(checks,indent=2)+'\n')
assert parsed.returncode==0,'Inspect preserved native entitlement parse error'
entitlements=json.loads(parsed.stdout);assert entitlements=={},'No new entitlement'
info=json.loads(checks['info']['stdout']);assert info['CFBundleIdentifier']=='local.treasure-island.first-playable' and info['CFBundleExecutable']=='Treasure Island First Playable'
privacy=json.loads(checks['privacy']['stdout']);assert privacy=={'NSPrivacyTracking':False}
assert 'com.apple.quarantine' not in checks['xattrs']['stdout']

result=subprocess.run(['/usr/bin/codesign','--verify','--deep','--strict','--verbose=2',str(app)],capture_output=True,text=True)
(P/'signature.log').write_text(result.stdout+result.stderr)
assert result.returncode==0,'Signature verification failed'
files={str(f.relative_to(app)):{'sha256':hashfile(f),'bytes':f.stat().st_size,'mode':f.stat().st_mode & 0o777} for f in sorted(app.rglob('*')) if f.is_file()}
pck=app/'Contents/Resources/Treasure Island First Playable.pck';binary=app/'Contents/MacOS/Treasure Island First Playable'
assert pck.is_file() and binary.is_file()
binding={'app':str(app),'files':files,'pck':str(pck),'pck_sha256':hashfile(pck),'binary':str(binary),'binary_sha256':hashfile(binary),'signature_ok':True,'bundle_checks_sha256':hashfile(P/'bundle-native-checks-001.json'),'signature_log_sha256':hashfile(P/'signature.log')}
(P/'app-binding.json').write_text(json.dumps(binding,indent=2)+'\n')
print('Exact exported bundle signature and identities bound')

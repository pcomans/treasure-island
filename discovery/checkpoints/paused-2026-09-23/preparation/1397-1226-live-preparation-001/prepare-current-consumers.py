from pathlib import Path
import json,hashlib,re,shutil,ast,difflib
P=Path('/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001');D=P/'1397-live-preparation-001';W=P/'1397-1226-live-preparation-001';S=W/'source';M=Path('/Volumes/Macintosh_HD/Users/user302070/code/treasure-island');Q=Path('/Volumes/Macintosh_HD/Users/user302070/code/treasure-island-1397-1226-live-candidate-v1');BASE='fdfc100704200e6570b654a4e6a4fccc9a1a61be';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text());save=lambda p,v:p.write_text(json.dumps(v,indent=2)+'\n')
reg=S/'game/resources/facades/facade-runtime-registry.json';contracts=S/'game/resources/facades/facade-runtime-adapter-contracts.json'
for rel,names in [('game/tests/headless_facade_recognition_registry_contract.gd',{'EXPECTED_REGISTRY_SHA256':sha(reg)}),('game/tests/headless_facade_runtime_registry_loader_contract.gd',{'EXPECTED_REGISTRY_SHA256':sha(reg),'EXPECTED_ADAPTER_CONTRACT_SHA256':sha(contracts)})]:
 p=S/rel;s=p.read_text()
 for name,value in names.items():s,n=re.subn(r'(const '+name+r' := ")[a-f0-9]{64}',r'\g<1>'+value,s);assert n==1
 p.write_text(s)
for name in ['run-stage.py','run-reviewed-chain.py','release.py','materialize-source.py']:
 p=W/name;p.write_text(p.read_text().replace('TI_1397_ENGINE_GO','TI_1397_1226_ENGINE_GO'))
# Strict complete order remains a single import/focused/registry/loader proposal.
plan=read(W/'source-run-plan.json');oldrepo=read(D/'base-binding.json')['repo']
for name,v in plan.items():
 v['argv']=[x.replace(str(D),str(W)).replace(oldrepo,str(Q))for x in v['argv']];v['cwd']=str(Q);v['purpose']='Shared1397+1226 live-source integration only; current32 authority and all213 unit records unchanged. No credit/package acceptance.'
 for key in ['dependent_inputs','prerequisites','preparation_prerequisites']:v[key]=[x.replace(str(D),str(W))for x in v.get(key,[])]
 if 'result'in v:v['result']=v['result'].replace(str(D),str(W))
save(W/'source-run-plan.json',plan);save(W/'base-binding.json',{'repo':str(Q),'base_commit':BASE,'materialization_status':'PENDING_ROOT_AUTHORIZATION','staged_source':str(S),'capture_source_base':'915f8a2595cb3184fba7008b97ff73f9bc028117'})
files={}
for packet in ['1397-first-five-preparation-001','1226-first-five-preparation-001']:
 for name in ['FILE_READY.json','packet-pins.json']:
  p=P/packet/name;files[str(p)]=sha(p)
 for p in (P/packet).glob('units/*/candidate-closure.json'):files[str(p)]=sha(p)
for p in [P/'1226-spray-continuation-001/independent-actual-001/REVIEW.md']:
 if p.exists():files[str(p)]=sha(p)
save(W/'SOURCE_EVIDENCE_BINDINGS.json',{'1397_first_five':'root-accepted','1226_source_mechanics_visual':'root-accepted','1226_first_five_packet_review':'pending independent decision','unit_ids':['physical-building:w96215670','physical-building:w96215685'],'capture_authority':31,'candidate_authority':32,'files':files,'limits':'1397 finite663 route rows/3callbacks;1226 original movement rawHOLD retained with925 derived qualified rows plus separate fresh3sprayPASS. No continuous all-PASS movie or grounded roof/jetpack claim. Package/seventh pending.'})
classes={}
for p in S.rglob('*.gd'):
 m=re.search(r'^class_name\s+(\w+)',p.read_text(),re.M)
 if m:assert m[1]not in classes;classes[m[1]]='res://'+str(p.relative_to(S))
newuids=['game/scripts/world/facades/'+stem+suffix+'.gd.uid'for stem in ['gateview_1397','bayside_1226']for suffix in ['_live_factory','_live_replacement']];save(W/'cache-preflight.json',{'required_classes':classes,'expected_new_uid_outputs':newuids,'cache_not_created':not(Q/'.godot').exists(),'materialization_pending':True})
selected={str(p.relative_to(S)):sha(p)for p in S.rglob('*')if p.is_file()and(not(M/p.relative_to(S)).is_file()or sha(p)!=sha(M/p.relative_to(S)))};save(W/'selected-files.json',selected);diff=''
for rel in selected:
 old=(M/rel).read_text()if(M/rel).exists()else'';diff+=''.join(difflib.unified_diff(old.splitlines(True),(S/rel).read_text().splitlines(True),fromfile='MAIN/'+rel,tofile='shared/'+rel))
(W/'selected-source.diff').write_text(diff)
package=read(W/'package-consumer-plan.json');package.update(status='PENDING_ACTUAL_SHARED_SOURCE_AND_PACKAGE_READINESS',proposed_world=read(W/'expected-world.json'),registry_sha256=sha(reg),contracts_sha256=sha(contracts),production_loader_sha256=sha(S/'game/scripts/world/facades/facade_runtime_registry_loader.gd'),units=['1397','1226'],package_required_changes=['Both exact study/live specs and actual focused result; prior32 unchanged','One complete shared candidate package and later exact-current app, not one export per unit','Current main smoke world scalars and both attachment calls; actual output-derived131+new resource bindings','Separate role6/seventh per unit; no old application relabeling']);save(W/'package-consumer-plan.json',package)
print('shared final consumers',len(selected),len(classes),sha(reg),sha(contracts))

# File-only actual six-role assembly after separate exact-app independent PASS.
from pathlib import Path
import json,hashlib,sys,argparse
p=Path(__file__).resolve().parent
read=lambda q:json.loads(Path(q).read_text())
sha=lambda q:hashlib.sha256(Path(q).read_bytes()).hexdigest()
a=argparse.ArgumentParser();a.add_argument('--review',required=True);a.add_argument('--review-sha256',required=True);a.add_argument('--check',required=True);a.add_argument('--check-sha256',required=True);a.add_argument('--independent-pass-authorized',action='store_true');args=a.parse_args()
assert args.independent_pass_authorized,'Named ROOT acceptance of exact independent package PASS required'
assert sha(args.review)==args.review_sha256 and sha(args.check)==args.check_sha256
assert not (p/'ROLE6_HANDOFF.json').exists(),'Never overwrite finalization'
settings=read(p/'execution-settings.json');app=read(p/'actual-app-binding.json');assert all(sha(q)==h for q,h in app['app_pins'].items())
plan=read(p/'run-plan.json')
for n in plan:
 r=read(p/(n+'-execution.json'));assert r['status']=='terminal' and r['ok'] and r['pid_absent'] and r['pins_unchanged'] and r['exit_code']==0
 assert sha(p/(n+'.log'))==r['log_sha256']
release=read(p/'SLOT_RELEASE.json');assert release['slot_released'] and not release['engine_processes']
source=read(p/'source-component-001-result.json');assert source['ok'] and source['measured_world']==settings['planned_world']
def ref(q):
 q=Path(q);return dict(path=q.name,path_base=str(q.parent),sha256=sha(q),bytes=q.stat().st_size,original_locator=str(q),byte_identical=True)
results={}
for unit in read(p/'unit-packet-prerequisites.json'):
 n=unit['unit'];u=p/'units'/n;assert not (u/'package-verification-receipt.json').exists()
 r=read(u/'package-verification-receipt.template.json')
 assert r['repair_lineage'] and all(sha(x['path'])==x['sha256'] for x in r['repair_lineage']),'Preserve actual failed/repair lineage'
 r.update(owner_decision='PASS',independent_exact_app_review_pending=False,independent_exact_app_decision='PASS',independent_review=ref(args.review),independent_check=ref(args.check),candidate_app_locator=settings['app'],candidate_app_relative_path='export-001/Treasure Island First Playable.app',candidate_app_relative_path_base=str(p),pck_sha256=app['pck_sha256'],app_file_pins=app['app_pins'],app_binding_document_sha256=sha(p/'actual-app-binding.json'),app_binding=ref(p/'actual-app-binding.json'),app_hash_semantics='App is a directory bound by the exact regular-file map; PCK hash is separate.',source_world=source['measured_world'],unit_actual_attachment=dict(physical_unit_id=unit['physical_unit_id'],source_and_mounted_marker='PROJECTED_FAMILY_PACKAGE_ATTACHMENT: source='+unit['physical_unit_id'].split(':')[-1],signed_marker='MAC_EXPORT_'+n+'_ATTACHMENT: valid=true'),signature_privacy_binding=ref(p/'bundle-native-checks-001.json'),terminal_slot_releases=[ref(p/'SLOT_RELEASE.json')],owner_receipts=[ref(p/(stage+'-execution.json')) for stage in plan],owner_logs=[ref(p/(stage+'.log')) for stage in plan],repair_lineage=r['repair_lineage'],coverage_split='Source and signed runs establish ordinary target attachments; mounted run establishes exact components. Historical study motion/visual limits remain separate.')
 # Marker presence was required by terminal stage success, and is joined explicitly for this unit.
 for stage in ['source-component-001','mounted-component-001']:
  assert read(p/(stage+'-execution.json'))['markers'][r['unit_actual_attachment']['source_and_mounted_marker']]
 for stage in ['release-headless-smoke-001','release-native-smoke-001']:
  assert read(p/(stage+'-execution.json'))['markers'][r['unit_actual_attachment']['signed_marker']]
 attachments={}
 for stage in ['source-component-001','mounted-component-001','release-headless-smoke-001','release-native-smoke-001']:
  marker=r['unit_actual_attachment']['source_and_mounted_marker'] if stage=='mounted-component-001' else r['unit_actual_attachment']['signed_marker']
  lines=[line for line in (p/(stage+'.log')).read_text().splitlines() if line.startswith(marker)]
  assert len(lines)==1,'One actual unit attachment line required: '+stage+' '+n
  attachments[stage]=dict(raw_lines=lines,log=ref(p/(stage+'.log')),receipt=ref(p/(stage+'-execution.json')))
 r['unit_actual_attachment']=attachments
 (u/'package-verification-receipt.json').write_text(json.dumps(r,indent=2)+'\n')
 closure=read(unit['closure']);closure['seven_acceptance_bindings_prepared']['package_verification_receipt_sha256']=sha(u/'package-verification-receipt.json');closure['package_verification_pending']=False;closure['actual_pck_sha256']=app['pck_sha256'];closure['actual_app_sha256']=None;closure['actual_app_file_pins']=app['app_pins'];closure['status']='SIX_ROLES_BOUND_SEVENTH_AND_AUTHORITY_PENDING';closure['current_source_attachment']=dict(status='EXISTING_INDEPENDENT_SOURCE_PASS_BOUND',readiness_binding=ref(p/'readiness-binding.json'))
 (u/'candidate-closure.json').write_text(json.dumps(closure,indent=2)+'\n');results[n]=dict(sixth=ref(u/'package-verification-receipt.json'),closure=ref(u/'candidate-closure.json'),six_bindings=closure['seven_acceptance_bindings_prepared'],image_tree_digest=unit['image_tree_digest'],image_tree_document_sha256=unit['image_tree_document_sha256'])
(p/'ROLE6_HANDOFF.json').write_text(json.dumps(results,indent=2)+'\n');print(sha(p/'ROLE6_HANDOFF.json'))

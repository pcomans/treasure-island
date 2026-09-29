from pathlib import Path
import json,hashlib,sys
p=Path(__file__).resolve().parent;stage=sys.argv[1];binding=json.loads((p/'app-binding.json').read_text());lines=(p/(stage+'.log')).read_text().splitlines();prefix='MAC_EXPORT_HOUSING_FAMILY_TARGETS: '
records=[(s.split(prefix,1)[1],json.loads(s.split(prefix,1)[1])) for s in lines if prefix in s]
full=[(s,d) for s,d in records if d.get('record_kind')=='actual_signed_family_snapshot'];assert len(full)==1,len(full)
s,d=full[0];h=hashlib.sha256(s.encode()).hexdigest();reuse=[x for _,x in records if x.get('record_kind')=='reuse_initial_signed_family_snapshot'];assert reuse and all(x['ok'] and x['snapshot_json_sha256']==h for x in reuse)
assert d['ok'] and d['pck_sha256']==binding['pck_sha256'] and len(d['units'])==33
repo=Path(json.loads((p/'settings.json').read_text())['repo']);ids=[]
for u in d['units']:
 ids.append(u['source_key']);assert u['normal_loader_owned'] and u['build_valid'] and u['receiver_key']=='building:'+u['source_key']+':wall'
 for key in ['config','chunk']:
  f=repo/u[key]['path'].removeprefix('res://');assert hashlib.sha256(f.read_bytes()).hexdigest()==u[key]['sha256']
 for role,v in u['roles'].items():
  for m in v['meshes']: assert m['visible'] and m['surfaces']>0 and m['visual_layer']>0
  for b in v['bodies']:
   assert b['collision_layer']==(5 if role=='wall' else 1) and b['spray_receiver']==(role=='wall')
   assert b['source_keys']==[u['source_key']] and b['object_key']=='building:'+u['source_key']+(':'+'roof' if role=='roof' else ':wall')
   assert b['shapes'] and all(x['shape_present'] and not x['disabled'] for x in b['shapes'])
assert len(set(ids))==33 and sorted(ids)==d['actual_sources']
(p/(stage+'-snapshot.json')).write_text(json.dumps(d,indent=2)+'\n');result={'ok':True,'scope':'Independent derived check of raw signed snapshot; exact-app native and privacy successful','full_records':len(full),'reuse_records':len(reuse),'snapshot_raw_json_sha256':h,'raw_log_sha256':hashlib.sha256((p/(stage+'.log')).read_bytes()).hexdigest(),'pck_sha256':binding['pck_sha256'],'actual_units':len(ids),'stdout_bytes':(p/(stage+'.log')).stat().st_size};(p/(stage+'-snapshot-check.json')).write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))

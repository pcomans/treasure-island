from pathlib import Path
import json,math
ROOT=Path(__file__).resolve().parents[3]
manifest=json.loads((ROOT/'game/tests/housing_family_experiment/all23.json').read_text())
errors=[];count=0
for target in manifest['targets']:
 cfg=json.loads((ROOT/target['config'].replace('res://','')).read_text()); chunk=json.loads((ROOT/target['chunk'].replace('res://','')).read_text())
 assert cfg['target']['source_key']==target['source_key']
 wall=next(r for r in chunk['records'] if r['object_key']=='building:'+target['source_key']+':wall');v=wall['vertices']
 for f in cfg['target']['frames']:
  for group in ['upper_windows','lower_windows','entries']:
   for m in f.get(group,[]):
    basis=m.get('basis',f);t=basis['tangent'];a=basis['start'];s=m.get('local_station_m',m['station_m']);point=[a[0]+t[0]*s,a[2]+t[2]*s];width=.92 if group=='entries' else m['width_m'];covered=0
    for r in f['runs']:
     ca=[v[r*12],v[r*12+2]];cb=[v[r*12+3],v[r*12+5]];length=math.dist(ca,cb);ct=[(cb[i]-ca[i])/length for i in range(2)];delta=[point[i]-ca[i] for i in range(2)]
     if ct[0]*t[0]+ct[1]*t[2]<.995 or abs(delta[0]*-ct[1]+delta[1]*ct[0])>.05:continue
     cs=sum(delta[i]*ct[i] for i in range(2));covered+=max(0,min(length,cs+width/2)-max(0,cs-width/2))
    count+=1
    if covered<width-.06:errors.append((target['source_key'],f['id'],group,m['station_m'],round(width-covered,3)))
 print(target['source_key'], 'identity/source records matched')
print('Complete scheduled motifs',count,'containment failures',len(errors))
for e in errors:print(e)
raise SystemExit(bool(errors))

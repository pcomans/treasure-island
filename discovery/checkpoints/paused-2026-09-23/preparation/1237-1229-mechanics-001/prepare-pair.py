from pathlib import Path
import json,re
W=Path(__file__).resolve().parent;P=W.parent;D=P/'1397-mechanics-001';S=P/'1237-1229-implementation-003';R=Path('/Volumes/Macintosh_HD/Users/user302070/code/treasure-island-1237-1229-study-v1')
s=(D/'prepare-target-queries.py').read_text().replace("W.with_name('1205-1226-1397-implementation-002')","W.with_name('1237-1229-implementation-003')").replace('treasure-island-1205-1226-1397-study-v1',R.name).replace("[('1397','gateview_1397_study','w96215670')]","[('1237','northpoint_1237_study','w96665904'),('1229','northpoint_1229_study','w96665911')]").replace("R/'game/resources/facades/gateview_1397_study.json'","R/f'game/resources/facades/{stem}.json'").replace("focused-{t}-002", "focused-{t}-001").replace("  if frame['id']not in ['near-2','near-4']:continue\n",'').replace("frame['entries'][:1]","frame['entries']")
a=s.index(" frame=next(f for f in cfg['target']['frames']if f['screens'])");b=s.index(' for label,f,station,depth,role in proposals:',a)
section=s[a:b];section=' proposals=[]\n if any(f["screens"] for f in cfg["target"]["frames"]):\n'+''.join(' '+line+'\n'for line in section.rstrip().splitlines());s=s[:a]+section+s[b:]
# Bind positive query to exact local runs, not an aggregate bent facade plane.
a=s.index(" stations=[f['length_m']");b=s.index(" for role in ['BlueOpaqueGlazing'",a)
s=s[:a]+''' for ff in cfg['target']['frames']:
  for window in ff['upper_windows']:
   basis=window['basis'];station=window['local_station_m'];basis={**basis,'runs':[basis['source_run']]}
   candidates.append(('ProjectedUpperSiding',basis,station,4.35,point(basis,station,cfg['facade']['story_band_y']+.43,.06),'placed'))
'''+s[b:]
(W/'prepare-target-queries.py').write_text(s)
for name in ['footprint-preflight.py','route-preflight.py','component-return-preflight.py']:
 s=(D/name).read_text().replace('treasure-island-1205-1226-1397-study-v1',R.name)
 (W/name).write_text(s)
plans={}
def replace_fn(s,ref,name):
 a=s.index('func '+name+'(');b=s.find('\nfunc ',a+5);aa=ref.index('func '+name+'(');bb=ref.find('\nfunc ',aa+5)
 return s[:a]+ref[aa:bb if bb>=0 else None]+s[b if b>=0 else len(s):]
for t in ['1237','1229']:
 ref=(S/t/'live_driver.gd').read_text();s=(D/'1397/live_driver.gd').read_text()
 for name in ['PROTOTYPE','CONFIG_PATH','CHUNK_PATH','WALL_KEY','ROOF_KEY','LAND_KEY','AREA_KEY','ROAD_KEY','GROUND_MESH_NAMES']:
  line=re.search('^const '+name+r' := .*$',ref,re.M)[0];s=re.sub('^const '+name+r' := .*$',lambda _:line,s,flags=re.M)
 for name,value in [('WORK',str(W/t)),('OUTPUT','/private/tmp/1237-1229-mechanics-001/'+t)]:s=re.sub('^const '+name+r' := .*$',lambda _:'const '+name+' := '+json.dumps(value),s,flags=re.M)
 cfg=json.loads((R/f'game/resources/facades/northpoint_{t}_study.json').read_text());s=re.sub('^const LAND_KEYS := .*$',lambda _:'const LAND_KEYS := '+json.dumps(cfg['ground']['sampled_land_keys']),s,flags=re.M)
 a=s.index('const VIEWS');b=s.index('\n]',a)+2;aa=ref.index('const VIEWS');bb=ref.index('\n]',aa)+2;s=s[:a]+ref[aa:bb]+s[b:]
 for fn in ['_load_current_world','_surface_state']:s=replace_fn(s,ref,fn)
 s=s.replace('1397-mechanics.avi',t+'-mechanics.avi').replace('Gateview1397','Northpoint'+t).replace('1397 finite two-entry and screen contact',t+' finite affected door/path/footway routes and configured screen contact')
 s=s.replace(str(P/'1205-1226-1397-implementation-002/focused-1397-002-result.json'),str(S/f'focused-{t}-001-result.json'))
 # Accepted1226 lesson: geometry/support remains mandatory; direct land slide events remain observations.
 assert s.count(' and land_rows>0')==1;s=s.replace(' and land_rows>0','')
 (W/t/'live_driver.gd').write_text(s)
 row=json.loads((S/'run-plan.json').read_text())[f'native-{t}-001'];argv=row['argv'];argv[argv.index('--script')+1]=str(W/t/'live_driver.gd');argv[argv.index('--probe-mode=stills')]='--probe-mode=mechanics';name=f'native-mechanics-{t}-001';argv[-1]='--output='+str(W/(name+'-result.json'));movie='/private/tmp/1237-1229-mechanics-001/'+t+'/'+t+'-mechanics.avi';at=argv.index('--script');argv[at:at]=['--fixed-fps','60','--write-movie',movie]
 row.update(result=str(W/(name+'-result.json')),image_dir='/private/tmp/1237-1229-mechanics-001/'+t+'/images',durable_image_dir=str(W/t/'capture/images'),movie=movie)
 for suffix in ['-execution.json','-result.json']:
  path=str(S/(f'native-{t}-001'+suffix));row['dependent_inputs'].append(path)
  if suffix=='-execution.json':row['prerequisites'].append(path)
 plans[name]=row
 s=(D/'run-1397.py').read_text().replace('native-mechanics-1397-001',name).replace('/private/tmp/1397-mechanics-001/1397-mechanics.avi',movie).replace('finalize-1397.py','finalize-'+t+'.py').replace('Fresh1397','Fresh'+t)
 (W/('run-'+t+'.py')).write_text(s)
 s=(D/'finalize-1397.py').read_text().replace(str(D/'1397'),str(W/t)).replace('/private/tmp/1397-mechanics-001','/private/tmp/1237-1229-mechanics-001/'+t).replace('1397-mechanics.avi',t+'-mechanics.avi').replace('native-mechanics-1397-001',name)
 (W/('finalize-'+t+'.py')).write_text(s)
 Path(row['image_dir']).mkdir(parents=True,exist_ok=True)
(W/'run-plan.json').write_text(json.dumps(plans,indent=2)+'\n')
s=(D/'run-stage.py').read_text().replace('treasure-island-1205-1226-1397-study-v1',R.name).replace('915f8a2595cb3184fba7008b97ff73f9bc028117','fdfc100704200e6570b654a4e6a4fccc9a1a61be')
# No import stage is offered. Preserve successful exact imported cache/UID prerequisites.
s=s.replace("name=sys.argv[1];plan=", "name=sys.argv[1];assert name in ['native-mechanics-1237-001','native-mechanics-1229-001'];plan=")
(W/'run-stage.py').write_text(s);(W/'release.py').write_bytes((D/'release.py').read_bytes())

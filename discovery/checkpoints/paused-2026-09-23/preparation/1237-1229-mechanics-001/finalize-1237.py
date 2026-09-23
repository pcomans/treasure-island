"""Preserve writer-terminal native AVI and exact existing MJPEG payloads; no re-encoding."""
from pathlib import Path
import json,struct,hashlib,shutil
W=Path('/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1237-1229-mechanics-001/1237');N=Path('/private/tmp/1237-1229-mechanics-001/1237');P=N/'1237-mechanics.avi';sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
r=json.loads((W.parent/'native-mechanics-1237-001-execution.json').read_text());assert r['status']=='terminal' and r['pid_absent'] and r['pins_unchanged'],'Actual writer terminal/input preservation required; rawFAIL originals remain evidence'
release=json.loads((W.parent/'SLOT_RELEASE-native-mechanics-1237-001.json').read_text());assert release['slot_released'] and not release['engine_processes'],'Engine release required before offline finalization'
D=W/'capture';D.mkdir(parents=True,exist_ok=True);durable_movie=D/P.name
assert not durable_movie.exists(),'Never overwrite a durable original'
shutil.copyfile(P,durable_movie);assert sha(P)==sha(durable_movie)
raw_copy={'original':str(P),'durable':str(durable_movie),'sha256':sha(P)}
(W/'raw-movie-retained.json').write_text(json.dumps(raw_copy,indent=2)+'\n')
result_path=W.parent/'native-mechanics-1237-001-result.json';m=json.loads(result_path.read_text())if result_path.is_file()else dict(failures=['No native result produced'],captures=[],motion={})
data=P.read_bytes();assert data[:4]==b'RIFF' and data[8:12]==b'AVI ';frames=[];header={}
def chunks(start,end):
 offset=start
 while offset+8<=end:
  tag=data[offset:offset+4];length=struct.unpack_from('<I',data,offset+4)[0];payload=offset+8;stop=payload+length;assert stop<=len(data),(offset,tag,length)
  if tag in [b'LIST',b'RIFF']:chunks(payload+4,stop)
  elif tag==b'avih':
   values=struct.unpack_from('<10I',data,payload);header.update(microseconds_per_frame=values[0],total_frames=values[4],width=values[8],height=values[9])
  elif tag in [b'00dc',b'00db']:
   assert data[payload:payload+2]==b'\xff\xd8';frames.append({'offset':payload,'bytes':length})
  offset=stop+(length%2)
chunks(12,len(data));assert len(frames)==header['total_frames']
indices=[]
if m.get('motion',{}):
 lo,hi=m['motion']['drawn_range'];indices=sorted(set(round(lo+(hi-lo)*i/8)for i in range(9)));assert 0<=min(indices)<=max(indices)<len(frames)
out=N/'avi-frame-samples';assert not out.exists();out.mkdir();samples=[]
for index in indices:
 frame=frames[index];path=out/f'avi-index-{index:04d}.jpg';path.write_bytes(data[frame['offset']:frame['offset']+frame['bytes']]);samples.append({'zero_based_avi_index':index,'path':str(path),'sha256':sha(path),'byte_offset':frame['offset'],'bytes':frame['bytes'],'kind':'Exact original native MJPEG payload; no decode/re-encode'})
final={'movie':{'path':str(P),'sha256':sha(P),'physical_bytes':len(data),'riff_declared_end':8+struct.unpack_from('<I',data,4)[0],**header},'terminal_receipt_sha256':sha(W.parent/'native-mechanics-1237-001-execution.json'),'actual_raw_exit':r['exit_code'],'actual_raw_failures':m['failures'],'captures':m['captures'],'motion':m.get('motion',{}),'extracted_frames':samples,'selection_scope':'Up to nine original MJPEG payload samples from the recorded mechanics draw interval. Actual saved PNG IDs and reached/performed route/spray records below determine partial or completed scope. Samples do not establish continuous video review or encoded/draw/physics parity; separate setup poses are not continuous traversal.','parser_lineage':'Complete existing Maceo lateral-sign-repair001/1394 RIFF parser; only current paths and evidence scope adapted.','container_limit':'Retain declared/physical size differences; no generic-player/conformance claim.'}
# Derive output scope from actual completed records, even after early failure.
route_plan=json.loads((W/'route-plan.json').read_text());reached={'saved_capture_ids':[str(c['id'])for c in m.get('captures',[])if c.get('saved_success',False)and c.get('sha256')], 'route_attempts':[], 'spray_attempts':[], 'unreached_route_ids':[], 'unreached_spray_ids':[]}
for actual_key,planned_key,missing_key in [('route_attempts','routes','unreached_route_ids'),('spray_attempts','sprays','unreached_spray_ids')]:
 attempts=m.get(actual_key,[]);reached[actual_key]=[dict(id=str(a['label']),record_state=str(a.get('record_state','incomplete')),performed=bool(a.get('performed',False)),ok=bool(a.get('ok',False)))for a in attempts];seen={str(a['label'])for a in attempts};reached[missing_key]=[str(s['id'])for s in route_plan[planned_key]if str(s['id'])not in seen]
final['reached_scope']=reached
final['prior_evidence_scope']=route_plan['carried_forward']
assert not (W/'motion-finalization.json').exists();copies=[raw_copy]
for source in sorted(out.glob('*.jpg')):
 target=D/source.relative_to(N);target.parent.mkdir(parents=True,exist_ok=True);assert not target.exists();shutil.copyfile(source,target);assert sha(source)==sha(target);copies.append({'original':str(source),'durable':str(target),'sha256':sha(source)})
final['byte_equal_durable_copies']=copies;final['png_copies_retained_in_terminal_receipt']=r.get('retained_original_images',[])
(W/'motion-finalization.json').write_text(json.dumps(final,indent=2)+'\n');print(json.dumps({'movie':final['movie'],'raw_exit':r['exit_code'],'pngs':len(m['captures']),'sample_indices':indices,'durable':str(D)},indent=2))

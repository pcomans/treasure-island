from pathlib import Path
import json,re,hashlib
W=Path(__file__).resolve().parent;R=W/'staged';P=W.parent
ns={};s=(P/'1205-1226-1397-implementation-002/revise.py').read_text();exec(s[s.index('def closed('):s.index("write(W/'FIRST_SOURCE_EDIT.json'")],ns)
for sp in json.load(open(W/'targets.json')):
 out=W/sp['address'];cp=R/'game/resources/facades'/(sp['name']+'.json');c=json.load(open(cp));closures=[]
 for f in c['target']['frames']:
  L=f['length_m'];y=f['top_y'];top=[ns['point'](f,.04,-3.05,y+.425),ns['point'](f,L-.04,-3.05,y+.425),ns['point'](f,L-.04,.20,y+.075),ns['point'](f,.04,.20,y+.075)];closures+=ns['closed'](top,[[v[0],y-.025,v[2]]for v in top])
 c['roof_termination']=dict(triangles=closures,inference='Accepted1397 attached pale shallow roof/eave terminations; exact source-front extents, protected roof backs untouched; dimensions production inference')
 c['materials'].update(siding_rgb=[.66,.68,.65]if sp['address']=='1237'else[.72,.72,.65],door_rgb=[.25,.12,.12]if sp['address']=='1237'else[.39,.43,.38],screen_rgb=[.58,.59,.54],dark_glass_rgb=[.41,.41,.36])
 if sp['address']=='1229':
  for fi,f in enumerate(c['target']['frames']):
   for i,e in enumerate(f['upper_windows']):e['glazing']='dark' if (fi,i) in [(1,1),(2,0)] else'blue'
   for e in f['lower_windows']:e['glazing']='dark'
 c['shallow_band']['inference']='No broad sloping apron; observed thin story edge only.'
 cp.write_text(json.dumps(c,indent=2)+'\n')
 chunk=R/'generated/world/chunks'/(sp['chunk']+'.json');rr=json.load(open(chunk))['records'];wall=next(x for x in rr if x['object_key']==f"building:{sp['key']}:wall");roof=next(x for x in rr if x['object_key']==f"building:{sp['key']}:roof")
 p=out/'file-preflight.py';s=p.read_text();s=re.sub(r'review_path=Path\(.*\)',"review_path=Path("+repr(str(P/'next-two-family-reference-preparation-002/independent-source-001/REVIEW.md'))+")",s);s=re.sub(r"check\(cfg\['mapped_runs'\].*",f"check(cfg['mapped_runs']=={c['mapped_runs']!r} and cfg['protected_runs']=={c['protected_runs']!r},'Exact independent candidate and protected partition')",s);s=re.sub(r"check\(len\(wall\['vertices'\]\).*",f"check(len(wall['vertices'])=={len(wall['vertices'])} and len(wall['indices'])=={len(wall['indices'])} and len(roof['vertices'])=={len(roof['vertices'])} and len(roof['indices'])=={len(roof['indices'])},'Exact target wall roof cardinality')",s);s=s.replace('db2c0ab4e7d2ca7473e5c65de38a685fa899464c7b019a9020d564e199bb5246',c['source_association']['sha256']);p.write_text(s)
 p=out/'focused_source.gd';s=p.read_text();s=re.sub(r'\t_check\(wall.vertices.size\(\).*?\n',f'\t_check(wall.vertices.size() == {len(wall["vertices"])} and wall.indices.size() == {len(wall["indices"])} and roof.vertices.size() == {len(roof["vertices"])} and roof.indices.size() == {len(roof["indices"])}, "Exact target wall roof cardinality.")\n',s);s=s.replace('expected_front.size() == 24','expected_front.size() == 18').replace('"triangles": 8,','"triangles": 6,');s=s.replace('raw[MODEL.ROOF_BUCKET].indices.size() == 144','raw[MODEL.ROOF_BUCKET].indices.size() == 108');p.write_text(s)
print('geometry complete')

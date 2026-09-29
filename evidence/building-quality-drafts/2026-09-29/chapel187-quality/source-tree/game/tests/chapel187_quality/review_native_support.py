"""Retained B3 lower-cap/native-face diagnostic; no invented acceptance threshold."""
from pathlib import Path
import sys,json,math
def sub(a,b):return tuple(a[i]-b[i] for i in range(3))
def dot(a,b):return sum(a[i]*b[i] for i in range(3))
def mul(a,t):return tuple(v*t for v in a)
def add(a,b):return tuple(a[i]+b[i] for i in range(3))
def dist(P,a,b,c):
 ab=sub(b,a);ac=sub(c,a);ap=sub(P,a);d1=dot(ab,ap);d2=dot(ac,ap)
 if d1<=0 and d2<=0:return math.dist(P,a)
 bp=sub(P,b);d3=dot(ab,bp);d4=dot(ac,bp)
 if d3>=0 and d4<=d3:return math.dist(P,b)
 vc=d1*d4-d3*d2
 if vc<=0 and d1>=0 and d3<=0:return math.dist(P,add(a,mul(ab,d1/(d1-d3))))
 cp=sub(P,c);d5=dot(ab,cp);d6=dot(ac,cp)
 if d6>=0 and d5<=d6:return math.dist(P,c)
 vb=d5*d2-d1*d6
 if vb<=0 and d2>=0 and d6<=0:return math.dist(P,add(a,mul(ac,d2/(d2-d6))))
 va=d3*d6-d5*d4
 if va<=0 and d4-d3>=0 and d5-d6>=0:return math.dist(P,add(b,mul(sub(c,b),(d4-d3)/((d4-d3)+(d5-d6)))))
 den=va+vb+vc
 if abs(den)<1e-20:return float('inf')
 return math.dist(P,add(a,add(mul(ab,vb/den),mul(ac,vc/den))))

P=Path(sys.argv[1]);rows=json.loads((P/'native-motion-trace.json').read_text())['rows'];g=json.loads((P/'native-faces.json').read_text())
def transform(t,p):return [t['origin'][i]+sum(t['basis'][j][i]*p[j] for j in range(3)) for i in range(3)]
triangles=[]
for name,m in g.items():
 if 'collision_faces' not in m:raise ValueError('Missing actual collision faces; historical get_faces arrays cannot establish native support')
 v=m['collision_faces']
 for i in range(0,len(v),3):
  t=v[i:i+3];triangles.append((name,i//3,t,[min(x[j] for x in t) for j in range(3)],[max(x[j] for x in t) for j in range(3)]))
values=[]
for row in rows:
 if row.get('setup_active',False):continue
 if not row['floor'] or row['support'].get('key') not in ['building:w291189336:roof','building:w291189336:wall']:continue
 radius=row['capsule_radius'];p=transform(row['node_transform'],transform(row['shape_local_transform'],[0,-row['capsule_height']/2+radius,0]));near=[]
 for name,index,t,lo,hi in triangles:
  if any(p[j]<lo[j]-.5 or p[j]>hi[j]+.5 for j in range(3)):continue
  near.append((dist(p,*t)-radius,name,index))
 if near:
  gap,name,index=min(near);values.append({'frame':row['frame'],'phase':row['phase'],'gap_m':gap,'mesh':name,'triangle':index})
setup_classified=all('setup_active' in r for r in rows)
setup_rows=[r for r in rows if r.get('setup_active',False)]
motion_rows=[r for r in rows if not r['setup_active']] if setup_classified else []
result={'scope':'Lower-sphere/native-triangle diagnostic, not whole capsule proof or independent acceptance. All-row node/server maximum includes intentional setup warps; only explicitly classified motion rows support a motion-specific maximum.','frames':len(rows),'maximum_frame_gap':max((b['frame']-a['frame'] for a,b in zip(rows,rows[1:])),default=0),'all_same_tick':all(r['same_tick'] for r in rows),'node_server_max_error_m':max((math.dist(r['position'],r['server_transform']['origin']) for r in rows),default=0),'setup_classified':setup_classified,'setup_frames':len(setup_rows) if setup_classified else None,'motion_node_server_max_error_m':max((math.dist(r['position'],r['server_transform']['origin']) for r in motion_rows),default=0) if setup_classified else None,'setup_node_server_max_error_m':max((math.dist(r['position'],r['server_transform']['origin']) for r in setup_rows),default=0) if setup_classified else None,'shape_transforms_match':all(r['shape_local_transform']==r['shape_server_transform'] for r in rows),'lower_cap_samples':values}
(P/'native-support-diagnostic.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k!='lower_cap_samples'}))

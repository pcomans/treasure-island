from pathlib import Path
import json,math
W=Path(__file__).parent
for spec in json.load(open(W/'targets.json')):
 out=W/spec['address'];ns={'__file__':str(out/'file-preflight.py')};s=(out/'file-preflight.py').read_text();exec(s[:s.index('# TARGET_CHECKS')],ns)
 cfg,wall,land,ray,height,sub,add,mul,dot,cross,unit=[ns[k]for k in ['cfg','wall','land','ray','height','sub','add','mul','dot','cross','unit']];f=cfg['target']['frames'][1]
 def point(fr,s,d,y=0):p=add(add(fr['start'],mul(fr['tangent'],s)),mul(fr['normal'],d));p[1]=y;return p
 def station(p):return dot(sub(p,f['start']),f['tangent'])
 def target_at(s,y):
  candidates=[]
  for run in f['runs']:
   a=wall['vertices'][run*12:run*12+3];b=wall['vertices'][run*12+3:run*12+6];lo=station(a);hi=station(b)
   if lo<=s<=hi:p=add(a,mul(sub(b,a),(s-lo)/(hi-lo)));p[1]=y;return p,run
  raise ValueError(s)
 envelope=[]
 for run in cfg['mapped_runs']:envelope += [wall['vertices'][run*12+i*3:run*12+i*3+3]for i in range(4)]
 envelope += [v for k in ['public_roof','shallow_band']for tri in cfg[k]['triangles']for v in tri]
 envelope += [v for tri in cfg['local_ground']['FootwaySurface']['top_triangles']for v in tri]
 for fr in cfg['target']['frames']:
  for e in fr['screens']:
   for ds in [-e['width_m']/2,e['width_m']/2]:
    for d in [.15,e['depth_m']+.1]:
     for y in [e['bottom_y'],e['bottom_y']+e['height_m']]:envelope.append(point(e['basis'],e['local_station_m']+ds,d,y))
 def projection(pos,target,points,avatar=False):
  g=height(land,pos[0],pos[2])
  if not g:return dict(eligible=False,reason='No LAND')
  pivot=[pos[0],g[0]+2,pos[2]];forward=unit(sub(target,pivot));cam=sub(pivot,mul(forward,5.5));right=unit(cross(forward,[0,1,0]));up=cross(right,forward)
  def screen(p):
   delta=sub(p,cam);dep=dot(delta,forward);return [720+450*dot(delta,right)/dep/math.tan(math.radians(35)),450-450*dot(delta,up)/dep/math.tan(math.radians(35))]
  pix=[screen(p)for p in points];b=[min(x[0]for x in pix),min(x[1]for x in pix),max(x[0]for x in pix),max(x[1]for x in pix)];ratio=[(b[2]-b[0])/1440,(b[3]-b[1])/900];under=height(land,cam[0],cam[2]);hit=ray(cam,target,.02);seg=ray(pivot,cam);ab=None;overlap=False
  if avatar:
   aa=[screen([pos[0]+dx,g[0]+yy,pos[2]+dz])for dx in [-.45,.45]for dz in [-.45,.45]for yy in [0,1.85]];ab=[min(x[0]for x in aa),min(x[1]for x in aa),max(x[0]for x in aa),max(x[1]for x in aa)];overlap=not(ab[2]<b[0]or ab[0]>b[2]or ab[3]<b[1]or ab[1]>b[3])
  okay=all(dot(sub(p,cam),forward)>0 for p in points)and 0<=b[0]<b[2]<=1440 and 0<=b[1]<b[3]<=900 and .12<=ratio[0]<=.96 and .035<=ratio[1]<=.96 and under and cam[1]-under[0]>.2 and not seg and hit and hit[1]in[wall['object_key'],wall['object_key'].replace(':wall',':roof')]and not overlap
  return dict(eligible=bool(okay),xz=[pos[0],pos[2]],target=target,camera=cam,bounds=b,ratios=ratio,segment_hit=seg,target_hit=hit,avatar_bounds=ab,conservative_avatar_overlap=overlap)
 mid=(station(cfg['target']['frames'][0]['start'])+station(cfg['target']['frames'][-1]['end']))/2;aim_station=max(.8,min(f['length_m']-.8,mid));target,run=target_at(aim_station,f['top_y']-1.6);rows=[]
 for depth in ([20.,22.,24.,26.,28.] if spec['address']=='1397' else [24.,25.,26.,28.,32.,36.,40.,44.]):
  for offset in ([0.,-10.,10.,-20.,20.,-30.,30.] if spec['address']=='1397' else [0.,-5.,5.]):rows.append(projection(point(f,mid+offset,depth),target,envelope))
 choices=[r for r in rows if r['eligible']];assert choices,(spec['address'],'whole',rows);whole=choices[0]
 (out/'whole-camera-preflight.json').write_text(json.dumps(dict(scope='Finite unchanged stock70degree camera feasibility against exact source and conservative complete addition envelope; actual native render unrun',rows=rows,selected=whole),indent=2)+'\n')
 # Bounded door/approach/footway junction, no invented road join.
 e=f['entries'][0];points=[]
 def clip(poly,axis,bound,greater):
  result=[]
  if not poly:return result
  a=poly[-1];da=(dot(sub(a,f['start']),axis)-bound)*(1 if greater else-1)
  for b in poly:
   db=(dot(sub(b,f['start']),axis)-bound)*(1 if greater else-1)
   if(db>=0)!=(da>=0):result.append(add(a,mul(sub(b,a),da/(da-db))))
   if db>=0:result.append(b)
   a,da=b,db
  return result
 lo=e['station_m']-1.1;hi=e['station_m']+1.1
 for tri in e['path_mesh']['top_triangles']+cfg['local_ground']['FootwaySurface']['top_triangles']:
  poly=tri
  for axis,bound,g in [(f['tangent'],lo,True),(f['tangent'],hi,False),(f['normal'],-.05,True),(f['normal'],4.4,False)]:poly=clip(poly,axis,bound,g)
  if len(poly)>=3:points+=poly
 for ds in [-.65,.65]:
  for y in [e['bottom_y']-.04,e['bottom_y']+e['height_m']+.15]:
   for d in [0,.18]:points.append(point(e['basis'],e['local_station_m']+ds,d,y))
 aim,arun=target_at(min(f['length_m']-.8,e['station_m']+2.3),e['bottom_y']+1.35);rows=[]
 for offset in [5.,7.,9.,-5.,-7.]:
  for depth in [7.,9.,11.,13.]:rows.append(projection(point(f,e['station_m']+offset,depth),aim,points,True))
 choices=[r for r in rows if r['eligible']];assert choices,(spec['address'],'junction',rows);junction=choices[0]
 (out/'junction-camera-preflight.json').write_text(json.dumps(dict(scope='Finite actual source door/path/footway clipping with conservative avatar separation',rows=rows,selected=junction),indent=2)+'\n')
 near=projection(point(f,aim_station,14),target,[target]);views=[dict(id='01-whole-front-baseline',xz=whole['xz'],target=whole['target'],run=run,public_front=True,baseline=True,sun=[-52,-28,0]),dict(id='02-whole-front-candidate',xz=whole['xz'],target=whole['target'],run=run,public_front=True,baseline=False,sun=[-52,-28,0]),dict(id='03-roof-entry-candidate',xz=near['xz'],target=target,run=run,public_front=False,baseline=False,sun=[-26,126,0]),dict(id='04-door-path-footway-junction',xz=junction['xz'],target=junction['target'],run=arun,public_front=False,baseline=False,sun=[-52,-28,0],junction=True,junction_station_min=lo,junction_station_max=hi,junction_depth_min=-.05,junction_depth_max=4.4)]
 (out/'view-plan.json').write_text(json.dumps(dict(views=views,scope='Exact unchanged stock poses; actual pixels/native contacts unrun'),indent=2)+'\n')
 p=out/'live_driver.gd';s=p.read_text();a=s.index('const VIEWS');b=s.index('\n]',a)+2;lines=[]
 for v in views:
  vals=[]
  for k,x in v.items():val='Vector3('+','.join(map(repr,x))+')'if k in ['sun','target']else'Vector2('+','.join(map(repr,x))+')'if k=='xz'else json.dumps(x);vals.append(json.dumps(k)+':'+val)
  lines.append('\t{'+','.join(vals)+'}')
 p.write_text(s[:a]+'const VIEWS := [\n'+',\n'.join(lines)+'\n]'+s[b:]);print(spec['address'],'whole',whole['xz'],'junction',junction['xz'])

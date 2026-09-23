from pathlib import Path
import json
W=Path(__file__).parent;R=Path('/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1237-1229-implementation-003/staged')
for spec in json.load(open(W/'targets.json')):
 p=R/'game/resources/facades'/(spec['name']+'.json');c=json.load(open(p));rows=[]
 for f in c['target']['frames']:
  candidates=[.5+.25*i for i in range(int((f['length_m']-1)/.25))]
  usable=[s for s in candidates if all(abs(s-e['station_m'])>e['width_m']/2+.25 for e in f['upper_windows'])and all(abs(s-e['station_m'])>.18 for e in f['pipes'])]
  assert usable;chosen=min(usable,key=lambda s:abs(s-f['length_m']/2));f['routing_station_m']=chosen;rows.append(dict(frame=f['id'],station_m=chosen,scope='Plain upper field, clear of complete window trim and drainage; actual native routing remains unrun'))
 p.write_text(json.dumps(c,indent=2)+'\n');d=W/spec['address']/'live_driver.gd';s=d.read_text().replace('var station: float = float(frame.length_m) / 2.0','var station: float = float(frame.routing_station_m)').replace('Six read-only stock-mask rays','Two read-only stock-mask rays per target field');d.write_text(s)
 (W/spec['address']/'routing-station-preflight.json').write_text(json.dumps(dict(ok=True,rows=rows),indent=2)+'\n')

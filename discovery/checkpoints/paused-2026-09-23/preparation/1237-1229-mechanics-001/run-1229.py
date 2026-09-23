from pathlib import Path
import subprocess,json,hashlib,sys
C=Path(__file__).resolve().parent
M=C
name='native-mechanics-1229-001'
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
pins=json.loads((C/'source-pins.json').read_text())
assert all(sha(k)==v for k,v in pins.items()),'Continuation input drift'
assert not (M/(name+'-execution.json')).exists(),'Fresh1229 required'
assert not (M/('SLOT_RELEASE-'+name+'.json')).exists(),'Fresh single-stage release required'
code=0
try:
 code=subprocess.run(['/usr/bin/python3','-B',str(M/'run-stage.py'),name],cwd=str(M)).returncode
finally:
 if (M/(name+'-execution.json')).exists():
  release=subprocess.run(['/usr/bin/python3','-B',str(M/'release.py'),name],cwd=str(M)).returncode
  if not code:code=release
  movie=Path('/private/tmp/1237-1229-mechanics-001/1229/1229-mechanics.avi')
  if movie.is_file():
   finalize=subprocess.run(['/usr/bin/python3','-B',str(C/'finalize-1229.py')],cwd=str(C)).returncode
   if not code:code=finalize
sys.exit(code)

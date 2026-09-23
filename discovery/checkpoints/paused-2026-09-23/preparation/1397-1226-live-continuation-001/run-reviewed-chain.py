from pathlib import Path
import subprocess,sys,json
w=Path(__file__).resolve().parent
stages=sys.argv[1:]
assert stages and len(set(stages))==len(stages) and all(x in json.loads((w/'source-run-plan.json').read_text()) for x in stages)
assert not (w/('SLOT_RELEASE-'+'-'.join(stages)+'.json')).exists(),'Never overwrite a prior invocation release'
code=0
try:
 for name in stages:
  code=subprocess.run(['/usr/bin/python3','-B',str(w/'run-stage.py'),name]).returncode
  if code:break
finally:
 if any((w/(n+'-execution.json')).exists() for n in stages):
  release=subprocess.run(['/usr/bin/python3','-B',str(w/'release.py'),*stages]).returncode
  if not code:code=release
sys.exit(code)

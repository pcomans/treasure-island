from pathlib import Path
import subprocess,sys,json
w=Path(__file__).resolve().parent
stages=sys.argv[1:]
assert stages and all(x in json.loads((w/'run-plan.json').read_text()) for x in stages)
code=0
try:
 for name in stages:
  code=subprocess.run(['/usr/bin/python3','-B',str(w/'run-stage.py'),name]).returncode
  if code:break
  if name=="export-001":
   code=subprocess.run(["/usr/bin/python3","-B",str(w/"bind-export.py")]).returncode
   if code:break
finally:
 if any((w/(n+'-execution.json')).exists() for n in json.loads((w/'run-plan.json').read_text())):
  release=subprocess.run(['/usr/bin/python3','-B',str(w/'release.py')]).returncode
  if not code:code=release
sys.exit(code)

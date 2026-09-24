from pathlib import Path
import subprocess,sys
p=Path(__file__).resolve().parent
for name in sys.argv[1:]:
 code=subprocess.run([sys.executable,str(p/'run-stage.py'),name]).returncode
 if code:sys.exit(code)
 if name=='export-001':
  code=subprocess.run([sys.executable,str(p/'bind-export.py')]).returncode
  if code:sys.exit(code)

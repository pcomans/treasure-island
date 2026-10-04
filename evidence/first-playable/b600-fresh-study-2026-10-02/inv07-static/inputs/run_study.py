"""One owned B600 study engine child, adapted from the Hawkins run_capture runner.

Usage: python3 run_study.py <fresh-run-name> <import|static|capture|full>
Refuses to start while any Godot/app engine is alive, records the live PID,
waits to terminal, then records exit code, engine census and slot release,
including the missing-receipt path.
"""
from pathlib import Path
import sys, subprocess, json, time, datetime, os, re, shutil

ROOT = Path(__file__).resolve().parents[3]
GODOT = Path('/Volumes/Macintosh_HD/Users/user302070/code/treasure-island/.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot')
STUDY = ROOT / 'game/tests/b600_fresh_study'
EVIDENCE = ROOT / 'evidence/first-playable/b600-fresh-study-2026-10-02'
run_name, mode = sys.argv[1], sys.argv[2]
assert mode in ('import', 'static', 'capture', 'full'), mode
run = EVIDENCE / run_name
run.mkdir(parents=True, exist_ok=False)
out = run / 'images'
snapshot = run / 'inputs'
snapshot.mkdir()
for path in [STUDY / 'study.gd', STUDY / 'static_check.gd', STUDY / 'manifest.json', STUDY / 'run_study.py',
             ROOT / 'game/scripts/world/facades/b600_fresh_study_model.gd']:
    shutil.copy2(path, snapshot / path.name)

def engines():
    rows = subprocess.check_output(['ps', '-axo', 'pid=,comm='], text=True).splitlines()
    return [r.strip() for r in rows if re.search(r'Godot|Treasure.?Island.*Playable', r, re.I)]

def alive(pid):
    try:
        os.kill(pid, 0)
        return True
    except ProcessLookupError:
        return False

proc = None; code = None; errors = []; start = time.monotonic()
census_before = engines()
try:
    assert not census_before, census_before
    if mode == 'import':
        cmd = [str(GODOT), '--headless', '--editor', '--path', str(ROOT), '--quit']
    elif mode == 'static':
        cmd = [str(GODOT), '--headless', '--path', str(ROOT), '--script', str(STUDY / 'static_check.gd'), '--', '--output=' + str(out)]
    else:
        cmd = [str(GODOT), '--path', str(ROOT), '--rendering-method', 'forward_plus', '--rendering-driver', 'metal',
               '--display-driver', 'macos', '--audio-driver', 'Dummy', '--resolution', '1440x900',
               '--script', str(STUDY / 'study.gd'), '--', '--manifest=' + str(STUDY / 'manifest.json'),
               '--output=' + str(out), '--mode=' + mode]
    with (run / 'engine.log').open('w') as log:
        proc = subprocess.Popen(cmd, stdout=log, stderr=subprocess.STDOUT)
        (run / 'live-process.json').write_text(json.dumps({'pid': proc.pid, 'command': cmd, 'started_utc': datetime.datetime.now(datetime.timezone.utc).isoformat()}, indent=2))
        try:
            code = proc.wait(timeout=620)
        except subprocess.TimeoutExpired:
            errors.append('timeout'); proc.terminate()
            try:
                code = proc.wait(timeout=10)
            except subprocess.TimeoutExpired:
                proc.kill(); code = proc.wait()
except BaseException as e:
    errors.append(repr(e))
finally:
    if proc and proc.poll() is None:
        proc.kill(); code = proc.wait()
    census = engines(); released = not census and (proc is None or not alive(proc.pid))
    log = (run / 'engine.log').read_text(errors='replace') if (run / 'engine.log').exists() else ''
    script_errors = [l for l in log.splitlines() if 'ERROR:' in l or 'Parse Error:' in l or 'SCRIPT ERROR' in l]
    receipt = {}
    receipt_name = {'static': 'static-receipt.json', 'capture': 'capture-receipt.json', 'full': 'capture-receipt.json'}.get(mode)
    if receipt_name:
        try:
            receipt = json.loads((out / receipt_name).read_text())
        except BaseException as e:
            errors.append('missing receipt ' + repr(e))
    result = {'mode': mode, 'terminal': code, 'errors': errors, 'engine_errors': script_errors[:200],
              'receipt_ok': receipt.get('ok', False) if receipt_name else None,
              'receipt_failure': receipt.get('failure', receipt.get('failures')) if receipt_name else None,
              'elapsed_seconds': time.monotonic() - start, 'pid': proc.pid if proc else None,
              'pid_alive_after': (alive(proc.pid) if proc else False), 'slot_released': released,
              'engines_before': census_before, 'engines_after': census,
              'ended_utc': datetime.datetime.now(datetime.timezone.utc).isoformat()}
    result['ok'] = code == 0 and not errors and not script_errors and (result['receipt_ok'] if receipt_name else True) and released
    (run / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))
sys.exit(0 if result['ok'] else 1)

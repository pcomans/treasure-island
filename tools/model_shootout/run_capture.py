"""Fixed Mac/Forward+ study renderer; private inputs and outputs stay in a packet."""
from pathlib import Path
import argparse
import datetime
import json
import shutil
import subprocess
import time


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("variant", choices=("variant-x", "variant-y"))
    parser.add_argument("phase", choices=("preview", "final"))
    parser.add_argument("--packet-root", required=True, type=Path,
                        help="Private packet containing render/<variant>/model.gd")
    default_godot = Path(__file__).resolve().parents[2] / ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot"
    parser.add_argument("--godot", type=Path, default=default_godot)
    parser.add_argument("--study", choices=("housing", "mersea"), default="housing")
    args = parser.parse_args()
    code_root = Path(__file__).resolve().parent
    root = args.packet_root.expanduser().resolve() / "render"
    godot = args.godot.expanduser().resolve()
    source = root / args.variant / "model.gd"
    if not source.is_file() or not godot.is_file():
        parser.error("Existing private model.gd and Godot executable are required")
    # Execute the exact maintained project from the private packet, keeping caches
    # outside the clone. Never overwrite a different project or an old result.
    project = root / "project"
    project.mkdir(parents=True, exist_ok=True)
    for name in ("capture.gd", "project.godot"):
        src, dest = code_root / "project" / name, project / name
        if dest.exists() and dest.read_bytes() != src.read_bytes():
            parser.error("Private project differs from maintained driver: " + str(dest))
        if not dest.exists():
            shutil.copy2(src, dest)
    out = root / args.variant / args.phase
    out.mkdir(exist_ok=False)
    shutil.copy2(source, out / "model.gd")
    cmd = [str(godot), "--path", str(project), "--rendering-method", "forward_plus",
           "--display-driver", "macos", "--resolution", "1440x900", "--script",
           str(project / "capture.gd"), "--", str(out / "model.gd"), str(out)]
    if args.study != "housing":
        cmd.append(args.study)
    start = time.monotonic()
    begin = datetime.datetime.now(datetime.timezone.utc).isoformat()
    proc, code, error = None, None, None
    timed_out = False
    try:
        with (out / "engine.log").open("w") as log:
            proc = subprocess.Popen(cmd, stdout=log, stderr=subprocess.STDOUT)
            (out / "process.json").write_text(json.dumps({"command": cmd, "pid": proc.pid,
                                                         "started_utc": begin}, indent=2))
            print("PID " + str(proc.pid), flush=True)
            try:
                code = proc.wait(timeout=180)
            except subprocess.TimeoutExpired:
                timed_out = True
                proc.terminate()
                try:
                    code = proc.wait(timeout=10)
                except subprocess.TimeoutExpired:
                    proc.kill()
                    code = proc.wait()
    except (OSError, KeyboardInterrupt) as exc:
        error = type(exc).__name__ + ": " + str(exc)
    finally:
        if proc is not None and proc.poll() is None:
            proc.terminate()
            try:
                code = proc.wait(timeout=10)
            except subprocess.TimeoutExpired:
                proc.kill()
                code = proc.wait()
        log_text = (out / "engine.log").read_text() if (out / "engine.log").exists() else ""
        errors = [line for line in log_text.splitlines()
                  if any(token in line for token in ("SCRIPT ERROR:", "ERROR:", "Parse Error"))]
        result = {"command": cmd, "started_utc": begin,
                  "ended_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
                  "elapsed_seconds": time.monotonic() - start,
                  "pid": proc.pid if proc else None, "terminal": code,
                  "timed_out": timed_out, "error": error, "engine_errors": errors,
                  "owned_process_exited": proc is not None and proc.poll() is not None,
                  "images": {n: (out / n).is_file() for n in
                             ("01-frontal.png", "02-three-quarter.png", "03-near.png")}}
        result["ok"] = (code == 0 and not timed_out and error is None and not errors
                        and result["owned_process_exited"] and all(result["images"].values())
                        and "TASTE_CAPTURE_COMPLETE" in log_text)
        (out / "result.json").write_text(json.dumps(result, indent=2))
        print(json.dumps(result, indent=2), flush=True)
    return 0 if result["ok"] else 1


if __name__ == "__main__":
    raise SystemExit(main())

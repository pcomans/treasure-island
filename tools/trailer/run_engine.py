"""Runs one Godot invocation for a trailer shot and reports its real end.

Adapted from the Isle House capture's run_native_slot.py
(tools/cinematics/isle-house on codex/isle-house-trailer-repro): it takes the
native engine slot's lock, refuses to start beside any other Godot (or Weston)
process, owns exactly the process it starts, stops on a script or shader error
or after a bounded time, and prints the terminal PID status and a process
census. A capture counts only with the driver's final SHOT_COMPLETE line.

  python3 tools/trailer/run_engine.py LOG TIMEOUT_S [--require-complete] -- ENGINE ARGS...

It never kills anything it did not start. A long quiet start is normal: Metal
compiles the first frames' pipelines for minutes on a fresh cache, so leave a
run that is still within its time alone rather than restarting it.
"""

import argparse
import fcntl
import os
from pathlib import Path
import selectors
import signal
import subprocess
import sys
import time

REPO = Path(__file__).resolve().parents[2]
LOCK_PATH = Path(os.environ.get("TRAILER_ENGINE_LOCK", "/private/tmp/treasure-island-native-engine-A.lock"))


def render_processes():
    result = subprocess.run(["/bin/ps", "-axo", "pid,comm"], check=True, text=True, capture_output=True)
    found = []
    for line in result.stdout.splitlines()[1:]:
        pid, _, command = line.strip().partition(" ")
        if Path(command.strip()).name.lower() in {"godot", "weston"}:
            found.append(f"{pid} {command.strip()}")
    return found


def run(args):
    command = [str(REPO / "tools/godot"), *args.flags]
    with LOCK_PATH.open("a") as lock, open(args.log, "x", buffering=1) as log:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            print(f"Engine slot lock {LOCK_PATH} is held by another run.", flush=True)
            return 2

        def note(message):
            print(message, flush=True)
            log.write(message + "\n")

        competing = render_processes()
        if competing:
            note(f"Refusing to start while other Godot processes exist: {competing}")
            return 2
        note("COMMAND " + " ".join(command))
        started = time.monotonic()
        proc = subprocess.Popen(command, cwd=REPO, start_new_session=True,
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        note(f"Engine slot acquired. Owned process PID {proc.pid}")
        complete = False
        result = 1
        try:
            with selectors.DefaultSelector() as selector:
                selector.register(proc.stdout, selectors.EVENT_READ)
                partial = b""
                while True:
                    if time.monotonic() - started > args.timeout:
                        raise TimeoutError(f"engine run exceeded its {args.timeout:.0f} s limit")
                    if not selector.select(timeout=1):
                        continue
                    packet = os.read(proc.stdout.fileno(), 16384)
                    if not packet:
                        if partial:
                            note(partial.decode(errors="replace"))
                        break
                    partial += packet
                    lines = partial.split(b"\n")
                    partial = lines.pop()
                    for line in lines:
                        message = line.decode(errors="replace")
                        note(message)
                        complete |= message.startswith("SHOT_COMPLETE ")
                        if "SHADER ERROR" in message or "SCRIPT ERROR" in message:
                            raise RuntimeError("Godot reported a shader or script error")
            result = proc.wait(timeout=30)
            if result == 0 and args.require_complete and not complete:
                note("Engine exited without the driver's SHOT_COMPLETE line.")
                result = 1
        except BaseException as error:
            note(f"Stopping: {error}")
            if proc.poll() is None:
                os.killpg(proc.pid, signal.SIGTERM)
                try:
                    proc.wait(timeout=15)
                except subprocess.TimeoutExpired:
                    os.killpg(proc.pid, signal.SIGKILL)
                    proc.wait(timeout=5)
            result = 1
        finally:
            try:
                os.kill(proc.pid, 0)
                gone = False
            except ProcessLookupError:
                gone = True
            survivors = render_processes()
            note(f"Terminal PID {proc.pid} status={proc.returncode}; gone={gone}; "
                 f"render census={survivors}; elapsed={time.monotonic() - started:.1f}s")
        return result if gone and not survivors else 1


if __name__ == "__main__":
    if "--" not in sys.argv:
        sys.exit("usage: run_engine.py LOG TIMEOUT_S [--require-complete] -- ENGINE ARGS...")
    separator = sys.argv.index("--")
    parser = argparse.ArgumentParser()
    parser.add_argument("log")
    parser.add_argument("timeout", type=float)
    parser.add_argument("--require-complete", action="store_true")
    parsed = parser.parse_args(sys.argv[1:separator])
    parsed.flags = sys.argv[separator + 1:]
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(143))
    sys.exit(run(parsed))

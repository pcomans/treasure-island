import argparse
import fcntl
import os
from pathlib import Path
import selectors
import signal
import subprocess
import sys
import time


LOCK_PATH = Path("/private/tmp/treasure-island-native-engine-A.lock")


def processes():
    result = subprocess.run(
        ["/bin/ps", "-axo", "pid,comm"], check=True, text=True, capture_output=True
    )
    return [line.strip() for line in result.stdout.splitlines()[1:]
            if Path(line.strip().split(maxsplit=1)[-1]).name.lower() in
            {"godot", "weston", "flock"}]


def run(args):
    path = Path(args.project)
    bin_path = path / ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot"
    env = os.environ.copy()
    env["GODOT_BIN"] = str(bin_path)
    command = [str(path / "tools/godot"), "--path", str(path), *args.flags[1:]]
    if not bin_path.is_file() or args.flags[:1] != ["--"]:
        raise ValueError("Expected the isolated native binary and -- before engine flags")
    with LOCK_PATH.open("a") as lock, open(args.log, "x", buffering=1) as log:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)

        def note(message):
            print(message, flush=True)
            log.write(message + "\n")

        competing = processes()
        if competing:
            note(f"Refusing to start while other render processes exist: {competing}")
            return 2
        started = time.monotonic()
        proc = subprocess.Popen(command, cwd=path, env=env, start_new_session=True,
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        note(f"Native slot A acquired. Owned process PID {proc.pid}")
        try:
            with selectors.DefaultSelector() as selector:
                selector.register(proc.stdout, selectors.EVENT_READ)
                partial = b""
                while True:
                    if time.monotonic() - started > args.timeout:
                        raise TimeoutError("Engine invocation exceeded its bounded runtime")
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
                        if "SHADER ERROR" in message or "SCRIPT ERROR" in message:
                            raise RuntimeError("Stopped on Godot shader or script error")
            result = proc.wait(timeout=5)
        except BaseException as error:
            note(f"Stopping: {error}")
            if proc.poll() is None:
                os.killpg(proc.pid, signal.SIGTERM)
                try:
                    proc.wait(timeout=10)
                except subprocess.TimeoutExpired:
                    os.killpg(proc.pid, signal.SIGKILL)
                    proc.wait(timeout=5)
            result = 1
        finally:
            survivors = processes()
            try:
                os.kill(proc.pid, 0)
            except ProcessLookupError:
                gone = True
            else:
                gone = False
            note(f"Terminal PID {proc.pid} status={proc.returncode}; gone={gone}; "
                 f"render census={survivors}; elapsed={time.monotonic() - started:.1f}s")
        return result if gone and not survivors else 1


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("project")
    parser.add_argument("log")
    parser.add_argument("timeout", type=float)
    separator = sys.argv.index("--")
    args = parser.parse_args(sys.argv[1:separator])
    args.flags = sys.argv[separator:]
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(143))
    sys.exit(run(args))

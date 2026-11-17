"""Checks a trailer shot file before any engine starts (format: README.md).

Prints "NAME FPS WIDTH HEIGHT FRAMES" for render-shot.sh, or exits 2 with the
problem. game/tests/shared/trailer_shot.gd checks the same file again in full.
"""

import json
from pathlib import Path
import sys


def numbers(value, count):
    return isinstance(value, list) and len(value) == count and all(
        isinstance(v, (int, float)) and not isinstance(v, bool) for v in value)


def check(path):
    shot = json.loads(Path(path).read_text())
    fps = shot.get("fps", 30)
    width, height = shot.get("resolution", [1920, 1080])
    duration, handle = float(shot["duration"]), float(shot.get("handle", 0.5))
    keys = shot["camera"]["keys"]
    if fps not in (30, 60):
        raise ValueError("fps must be 30 or 60")
    if duration <= 0 or handle < 0:
        raise ValueError("duration must be > 0 and handle >= 0")
    if width % 2 or height % 2 or width < 64 or height < 64:
        raise ValueError("resolution must be even and at least 64 x 64")
    if len(keys) < 2:
        raise ValueError("the camera needs at least two keys")
    for key in keys:
        if not ("t" in key and numbers(key.get("position"), 3) and numbers(key.get("target"), 3)):
            raise ValueError("every camera key needs t, position [x,y,z] and target [x,y,z]")
    if any(a["t"] >= b["t"] for a, b in zip(keys, keys[1:])):
        raise ValueError("camera key times must increase")
    chester = shot.get("chester")
    if chester is not None and not numbers(chester.get("at"), 2):
        raise ValueError("chester.at must be [x, z]")
    name = str(shot.get("name") or Path(path).stem).replace(" ", "_")
    return f"{name} {fps} {width} {height} {round((duration + 2 * handle) * fps)}"


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("usage: check_shot.py SHOT.json")
    try:
        print(check(sys.argv[1]))
    except (OSError, ValueError, KeyError, TypeError) as error:
        print(f"{sys.argv[1]}: {error}", file=sys.stderr)
        sys.exit(2)

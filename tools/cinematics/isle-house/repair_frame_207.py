"""Remove a single confirmed renderer flare using the same-pose native proof."""

import argparse
from pathlib import Path
import subprocess

import numpy as np

WIDTH, HEIGHT, FRAME_COUNT = 1920, 1080, 900
FRAME = 207
CENTER_X, CENTER_Y = 608, 548
CORE, OUTER = 122, 170


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("clean_still", type=Path)
    parser.add_argument("target", type=Path)
    args = parser.parse_args()
    if args.source.stat().st_size != WIDTH * HEIGHT * FRAME_COUNT * 3 or args.target.exists():
        parser.error("Expected a full RGB24 source and a new destination.")
    rendered = subprocess.check_output(["ffmpeg", "-nostdin", "-v", "error", "-xerror",
                                        "-i", str(args.clean_still), "-frames:v", "1",
                                        "-pix_fmt", "rgb24", "-f", "rawvideo", "-"])
    clean = np.frombuffer(rendered, dtype=np.uint8).reshape(HEIGHT, WIDTH, 3)
    subprocess.run(["/bin/cp", "-c", str(args.source), str(args.target)], check=True)
    output = np.memmap(args.target, dtype=np.uint8, mode="r+",
                       shape=(FRAME_COUNT, HEIGHT, WIDTH, 3))
    y = slice(CENTER_Y - OUTER, CENTER_Y + OUTER + 1)
    x = slice(CENTER_X - OUTER, CENTER_X + OUTER + 1)
    r = np.hypot(np.arange(-OUTER, OUTER + 1)[:, None], np.arange(-OUTER, OUTER + 1)[None, :])
    fade = np.clip((OUTER - r) / (OUTER - CORE), 0, 1)
    weight = (fade * fade * (3.0 - 2.0 * fade))[..., None]
    native = output[FRAME, y, x]
    output[FRAME, y, x] = np.rint(native * (1.0 - weight) + clean[y, x] * weight)
    output.flush()


if __name__ == "__main__":
    main()

"""Finish a map-eased native capture as a 30-second Isle House trailer."""

import argparse
import os
from pathlib import Path
from tempfile import TemporaryDirectory

import numpy as np

from face_shape import ease
from finish_capture import nadir_bias, translated_rgb
from finish_contact import EYES_FIRST, encode_rgb24, ffprobe, packet_timing, soften_eye_highlights
from finish_no_glow import (FRAME_BYTES, H, LAST_NATIVE, W, LATCH_TOP, MOUTH_CORNERS,
                            bend_smile, bounds, cue, rounded_filter)


# Advance the same gesture by 68 frames. The native wink uses the matching cue origin.
GESTURE_ADVANCE = 68
MOUTH_FIRST = 844 - GESTURE_ADVANCE


def read_anchors(path):
    rows = np.loadtxt(path, delimiter=",", ndmin=2)
    if rows.shape != (LAST_NATIVE - EYES_FIRST + 1, 8) or not np.isfinite(rows).all():
        raise ValueError("Expected a complete native face track with seven finite anchors per frame")
    if not np.array_equal(rows[:, 0], np.arange(EYES_FIRST, LAST_NATIVE + 1)):
        raise ValueError("The native face track must cover frames 711–899 in order")
    if (np.any(rows[:, 1] >= rows[:, 2]) or np.any(rows[:, 4] >= rows[:, 5])
            or np.any(rows[:, [1, 2, 4, 5, 6]] < 16)
            or np.any(rows[:, [1, 2, 4, 5, 6]] >= W - 16)
            or np.any(rows[:, [3, 7]] < 16) or np.any(rows[:, [3, 7]] >= H - 16)):
        raise ValueError("Expected ordered face anchors inside the native picture")
    return rows[:, 1:].astype(np.float32)


def mouth_marks(pixels, anchors, frame):
    _, _, _, left, right, latch_x, latch_y = anchors
    scale = (right - left) / (MOUTH_CORNERS[1] - MOUTH_CORNERS[0])
    if not 0.45 < scale < 1.10:
        raise ValueError(f"Unexpected projected smile scale {scale:.3f} at frame {frame}")
    center_x, center_y = round(float(latch_x)), round(float(latch_y))
    sample = pixels[center_y - 11:center_y + 13, center_x - 5:center_x + 6].mean(axis=1)
    brass = (sample[:, 0] > 165) & (sample[:, 1] > 135) & (sample[:, 0] - sample[:, 2] > 60)
    hits = np.flatnonzero(brass[:-2] & brass[1:-1] & brass[2:])
    if not len(hits):
        raise ValueError(f"Could not locate the projected brass latch near {center_x},{center_y} at frame {frame}")
    latch_top = center_y - 11 + hits[0]
    rail_y = int(latch_top + 7 * scale)
    edge = np.diff(pixels[rail_y - 2:rail_y + 3].mean(axis=(0, 2)))
    corners = []
    for expected, sign in ((left, -1), (right, 1)):
        center = round(float(expected))
        search = sign * edge[center - 7:center + 8]
        local = int(np.argmax(search))
        corners.append(center - 7 + local + 0.5 if search[local] > 10.0 else expected)
    return np.array([*corners, latch_top], dtype=np.float32)


def express(source, patch, anchors, frame):
    pixels = source.copy()
    smile, _, idle = cue(frame + GESTURE_ADVANCE)
    if smile:
        left, right, latch = patch
        scale = (right - left) / (MOUTH_CORNERS[1] - MOUTH_CORNERS[0])
        fit = (scale, scale, left - scale * MOUTH_CORNERS[0], latch - scale * LATCH_TOP)
        bend_smile(pixels, fit, smile, idle)
    strength = float(ease((frame - EYES_FIRST) / 8))
    if strength:
        left, right, eye_y = anchors[:3]
        scale = (right - left) / 117.0
        boxes = (bounds(source, x, eye_y, scale, (left + right) / 2.0, side)
                 for side, x in enumerate((left, right)))
        soften_eye_highlights(pixels, source, boxes, strength)
    return pixels


def finish(native, output, nadir):
    count = LAST_NATIVE + 1
    raw = native / "frames.rgb"
    if raw.stat().st_size != count * FRAME_BYTES:
        raise ValueError(f"Expected exactly {count} native 1920 × 1080 RGB24 frames")
    source = np.memmap(raw, dtype=np.uint8, mode="r", shape=(count, H, W, 3))
    anchors = read_anchors(native / "face-track.csv")
    tracking = rounded_filter(np.stack([
        mouth_marks(source[frame], anchors[frame - EYES_FIRST], frame)
        for frame in range(MOUTH_FIRST, count)
    ]))

    def frames():
        for frame, pixels in enumerate(source):
            if 28 <= frame <= nadir:
                pixels = translated_rgb(pixels, *nadir_bias(frame))
            if frame >= EYES_FIRST:
                patch = tracking[frame - MOUTH_FIRST] if frame >= MOUTH_FIRST else None
                pixels = express(pixels, patch, anchors[frame - EYES_FIRST], frame)
            yield pixels

    encode_rgb24(output, frames())
    report = ffprobe(output, "-show_streams", "-show_format")
    streams = report["streams"]
    expected = {"codec_name": "h264", "width": W, "height": H, "avg_frame_rate": "30/1",
                "time_base": "1/30000", "pix_fmt": "yuv420p", "color_range": "tv",
                "color_space": "bt709", "color_transfer": "bt709", "color_primaries": "bt709"}
    if len(streams) != 1 or any(streams[0].get(key) != value for key, value in expected.items()):
        raise ValueError("Expected a single 1920 × 1080 H.264 BT.709 stream at 30 fps")
    timing = sorted((packet["pts"], packet["duration"]) for packet in packet_timing(output))
    if timing != [(frame * 1000, 1000) for frame in range(count)]:
        raise ValueError("The encoded trailer has a missing frame or unexpected timing")
    if abs(float(report["format"]["duration"]) - count / 30) > 0.000001:
        raise ValueError("Expected a 30-second final container")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("native", type=Path, help="directory containing frames.rgb and face-track.csv")
    parser.add_argument("output", type=Path)
    parser.add_argument("--last-nadir-frame", type=int, default=0)
    args = parser.parse_args()
    if args.last_nadir_frame and not 28 <= args.last_nadir_frame < 87:
        parser.error("Use the measured end of the near-nadir renderer offset")
    if not (args.native / "frames.rgb").is_file() or not (args.native / "face-track.csv").is_file():
        parser.error("Provide the completed native output directory from map-eased")
    output = args.output.absolute()
    if output.suffix.lower() != ".mp4" or output.exists() or output.is_symlink() or not output.parent.is_dir():
        parser.error("Use a new .mp4 in an existing output directory")
    with TemporaryDirectory(prefix="isle-house-eased-", dir=output.parent) as scratch:
        staged = Path(scratch) / "trailer.mp4"
        finish(args.native, staged, args.last_nadir_frame)
        os.link(staged, output)
    print("Verified 900 uninterrupted 1920 × 1080 BT.709 frames at 30 fps")


if __name__ == "__main__":
    main()

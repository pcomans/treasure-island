"""Finish the native Chester repair and rejoin the preserved aerial prefix."""

import argparse
import json
import os
from pathlib import Path
import subprocess
from tempfile import TemporaryDirectory

import numpy as np

import face_shape as wide
from finish_no_glow import (FRAME_BYTES, H, LAST, LAST_NATIVE, W, bend_smile,
                            cue, developed, mouth_fit, mouth_marks, observe,
                            open_png, rounded_filter)

CAPTURE_START = 590
JOIN = 600
MOUTH_FIRST = 844
EYES_FIRST = 711


def ffprobe(path, *flags):
    result = subprocess.run(["ffprobe", "-v", "error", *flags, "-of", "json", str(path)],
                            check=True, capture_output=True)
    return json.loads(result.stdout)


def coding(path):
    row = ffprobe(path, "-select_streams", "v:0", "-show_data_hash", "sha256",
                  "-show_entries", "stream=codec_name,width,height,pix_fmt,profile,level,"
                  "time_base,color_range,color_space,color_transfer,color_primaries,extradata_hash")["streams"][0]
    return row


def packet_timing(path):
    report = ffprobe(path, "-select_streams", "v:0", "-show_data_hash", "sha256",
                     "-show_entries", "packet=pts,dts,duration,flags,data_hash")
    return report["packets"]


def clean_prefix(original, target):
    packets = packet_timing(original)
    if (len(packets) != LAST + 1
            or sorted(p["pts"] for p in packets) != list(range(0, (LAST + 1) * 1000, 1000))
            or packets[JOIN]["pts"] != JOIN * 1000 or "K" not in packets[JOIN]["flags"]):
        raise ValueError("The original aerial MP4 must have 966 frames and a clean keyframe at frame 600.")
    subprocess.run(["ffmpeg", "-nostdin", "-n", "-v", "error", "-i", str(original),
                    "-map", "0:v:0", "-frames:v", str(JOIN), "-c:v", "copy",
                    "-movflags", "+faststart", str(target)], check=True)
    prefix = packet_timing(target)
    if prefix != packets[:JOIN]:
        raise RuntimeError("Cannot preserve the exact original opening packet sequence")
    print(f"Confirmed {JOIN} exact encoded prefix packets through the original IDR boundary", flush=True)


def marks(pixels, frame):
    # The left eye remains open through the right-eye wink. It is enough to
    # seed the search for the actual gold latch and the two front bevels.
    eyes = observe(pixels, frame)
    source_eye = eyes[0] if eyes[0] is not None else eyes[1]
    if source_eye is None:
        raise ValueError(f"No native face anchor at frame {frame}")
    return mouth_marks(pixels, [source_eye, source_eye], frame)


def reduce_native_eye_whites(pixels, source, frame):
    strength = float(wide.ease((frame - EYES_FIRST) / 8))
    if strength:
        soften_eye_highlights(pixels, source, observe(source, min(frame, LAST_NATIVE)), strength)


def soften_eye_highlights(pixels, source, boxes, strength):
    # Only lower existing native near-white pixels. The native eye material
    # already drew the aperture, dark pupil, eyelashes and the brown lids.
    for box in boxes:
        if box is None:
            continue
        left, right, top, bottom = np.rint(box).astype(int)
        section = np.s_[top:bottom+1, left:right+1]
        base = source[section].astype(np.float32)
        white = np.clip((base.min(axis=2) - 204.) / 51., 0., 1.)
        neutral = wide.ease((32. - np.ptp(base, axis=2)) / 14.)
        shoulder = 19. * strength * white**2 * neutral
        pixels[section] = np.minimum(pixels[section], np.rint(base - shoulder[..., None])).astype(np.uint8)


def express(source, patch, frame):
    amount, _, idle = cue(frame)
    result = source.copy()
    if amount:
        bend_smile(result, mouth_fit(patch), amount, idle)
    reduce_native_eye_whites(result, source, frame)
    return result

def proof(native, output):
    output.mkdir(exist_ok=False)
    settled = developed(open_png(native / "frame-0899.png"), LAST_NATIVE, 0)
    for f in (715, 730, 744, 750, 767, 783, 850, 861, 875, 877, 880, 888, 899, 965):
        n = min(f, LAST_NATIVE)
        source = settled if n == LAST_NATIVE else developed(open_png(native / f"frame-{n:04d}.png"), n, 0)
        result = express(source, marks(source, n) if cue(f)[0] else None, f)
        wide.png(output / f"frame-{f:04d}.png", result)


def encode_tail(raw, tail):
    src = np.memmap(raw, dtype=np.uint8, mode="r", shape=(LAST_NATIVE - CAPTURE_START + 1, H, W, 3))
    actual_marks = []
    for frame in range(MOUTH_FIRST, LAST_NATIVE + 1):
        image = developed(src[frame-CAPTURE_START], frame, 0)
        actual_marks.append(marks(image, frame))
    tracking = rounded_filter(np.stack(actual_marks))
    settled = developed(src[-1], LAST_NATIVE, 0)

    def frames():
        for frame in range(JOIN, LAST + 1):
            native = min(frame, LAST_NATIVE)
            source = settled if native == LAST_NATIVE else developed(src[native - CAPTURE_START], native, 0)
            if frame >= EYES_FIRST:
                patch = tracking[native - MOUTH_FIRST] if frame >= MOUTH_FIRST else None
                source = express(source, patch, frame)
            yield source

    encode_rgb24(tail, frames())


def encode_rgb24(output, frames):
    convert = ("scale=in_range=pc:out_range=tv:out_color_matrix=bt709"
               ":flags=accurate_rnd+full_chroma_int,format=yuv420p,setsar=1"
               ",setparams=range=limited:color_primaries=bt709:color_trc=bt709:colorspace=bt709")
    command = ["ffmpeg", "-nostdin", "-n", "-hide_banner", "-loglevel", "warning",
               "-stats", "-stats_period", "5", "-f", "rawvideo", "-pixel_format", "rgb24",
               "-video_size", f"{W}x{H}", "-framerate", "30", "-i", "-", "-vf", convert,
               "-an", "-c:v", "libx264", "-preset", "slow", "-crf", "18", "-g", "60",
               "-profile:v", "high", "-level:v", "4.1", "-maxrate", "18M", "-bufsize", "18M",
               "-color_range", "tv", "-colorspace", "bt709", "-color_trc", "bt709",
               "-color_primaries", "bt709", "-video_track_timescale", "30000", "-movflags", "+faststart", str(output)]
    with subprocess.Popen(command, stdin=subprocess.PIPE) as ffmpeg:
        assert ffmpeg.stdin is not None
        try:
            for source in frames:
                ffmpeg.stdin.write(source.tobytes())
        finally:
            ffmpeg.stdin.close()
        if ffmpeg.wait():
            raise RuntimeError("Tail render encode failed")


def splice(original, prefix, tail, output, work):
    if coding(original) != coding(prefix) or coding(original) != coding(tail):
        raise RuntimeError("New tail differs in H.264 codec headers or color metadata, refusing packet concat")
    entries = work / "concat.txt"
    entries.write_text("file prefix.mp4\nfile tail.mp4\n")
    subprocess.run(["ffmpeg", "-nostdin", "-n", "-v", "error", "-f", "concat", "-auto_convert", "0",
                    "-safe", "0", "-i", str(entries), "-map", "0:v:0", "-c", "copy",
                    "-video_track_timescale", "30000", "-movflags", "+faststart", str(output)], check=True)
    joined = packet_timing(output)
    base = packet_timing(original)
    if (len(joined) != LAST + 1 or joined[:JOIN] != base[:JOIN]
            or sorted(p["pts"] for p in joined) != list(range(0, (LAST + 1) * 1000, 1000))
            or "K" not in joined[JOIN]["flags"] or joined[JOIN]["pts"] != JOIN * 1000):
        raise RuntimeError("Final container must preserve the exact original opening packets and every frame timestamp")
    print(f"Final file retains {JOIN} packet SHA256/PTS/DTS values exactly", flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("native", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--original", type=Path)
    parser.add_argument("--work", type=Path)
    parser.add_argument("--proof", action="store_true")
    args = parser.parse_args()
    if args.proof:
        proof(args.native, args.output)
        return
    output = args.output.absolute()
    if args.original is None or not args.original.is_file():
        parser.error("Provide the existing aerial MP4 with --original.")
    if args.work is None or args.work.exists() or args.work.is_symlink() or args.work.absolute() == output:
        parser.error("Provide a fresh --work directory separate from the output.")
    if output.suffix.lower() != ".mp4" or output.exists() or output.is_symlink() or not output.parent.is_dir():
        parser.error("Use a new .mp4 in an existing output directory.")
    if not args.native.is_file() or args.native.stat().st_size != (LAST_NATIVE - CAPTURE_START + 1) * FRAME_BYTES:
        parser.error("Native RGB24 input must comprise exactly frames 590–899.")
    args.work.mkdir()
    prefix, tail = args.work / "prefix.mp4", args.work / "tail.mp4"
    clean_prefix(args.original, prefix)
    encode_tail(args.native, tail)
    # Verify the splice before publishing. Keep staging on the output filesystem
    # so the hard link can publish atomically without overwriting another file.
    with TemporaryDirectory(prefix="isle-house-tail-", dir=output.parent) as scratch:
        staged = Path(scratch) / "trailer.mp4"
        splice(args.original, prefix, tail, staged, args.work)
        os.link(staged, output)


if __name__ == "__main__":
    main()

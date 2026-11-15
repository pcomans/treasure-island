"""Build the 32.2-second website trailer from the clean 30-second camera capture."""

import argparse
import json
import os
from pathlib import Path
import subprocess
import sys
from tempfile import TemporaryDirectory

RIG = Path(__file__).resolve().parent
FFMPEG = ["ffmpeg", "-nostdin", "-hide_banner", "-loglevel", "error", "-xerror", "-n"]
COPY_VIDEO = ["-map", "0:v:0", "-an", "-c:v", "copy", "-video_track_timescale", "30000",
              "-movflags", "+faststart"]
BASE_FRAMES, TOTAL_FRAMES = 900, 966
WIDE_START, EARLY_START = 711, 844


def run(command):
    subprocess.run(command, check=True)


def stream(path):
    result = subprocess.check_output([
        "ffprobe", "-v", "error", "-select_streams", "v:0", "-show_data", "-show_streams",
        "-of", "json", str(path),
    ])
    streams = json.loads(result)["streams"]
    if not streams:
        raise ValueError(f"No video stream in {path}.")
    return streams[0]


def verify_format(path, count):
    data = stream(path)
    expected = {"codec_name": "h264", "width": 1920, "height": 1080, "pix_fmt": "yuv420p",
                "r_frame_rate": "30/1", "time_base": "1/30000", "nb_frames": str(count)}
    for key, value in expected.items():
        if data.get(key) != value:
            raise ValueError(f"{path}: expected {key}={value}, found {data.get(key)}.")
    return data


def verify_presentation(path, count):
    result = subprocess.check_output([
        "ffprobe", "-v", "error", "-select_streams", "v:0", "-show_packets",
        "-show_entries", "packet=pts,dts", "-of", "json", str(path),
    ])
    packets = json.loads(result)["packets"]
    timestamps = sorted(packet.get("pts", -1) for packet in packets)
    decode_times = [packet.get("dts", 0) for packet in packets]
    if timestamps != list(range(0, count * 1000, 1000)) or any(
        after <= before for before, after in zip(decode_times, decode_times[1:])
    ):
        raise ValueError(f"{path.name}: no clean {count}-frame cut at 30 fps. "
                         "The encoder split did not preserve presentation order.")


def decode(path, start, count, target, png=False):
    seconds, remainder = divmod(start, 30)
    options = ["-update", "1"] if png else ["-f", "rawvideo"]
    run([*FFMPEG, "-ss", str(seconds), "-i", str(path), "-an",
         "-vf", f"trim=start_frame={remainder},setpts=PTS-STARTPTS", "-frames:v", str(count),
         "-fps_mode", "passthrough", "-pix_fmt", "rgb24", *options, str(target)])


def python(script, *args):
    run([sys.executable, "-B", str(RIG / script), *(str(arg) for arg in args)])


def encode(raw, target, count):
    run([str(RIG / "encode.sh"), str(raw), str(target), str(count)])


def join(prefix, ending, count, target, work):
    # Match the configuration record before copying packets into one MP4 track.
    a = verify_format(prefix, count)
    b = verify_format(ending, TOTAL_FRAMES - count)
    if a["extradata"] != b["extradata"]:
        raise ValueError("The H.264 parameters differ. Encode the base with the supplied encode.sh.")
    # Use fixed local file names so the concat file never contains user paths.
    (work / "prefix.mp4").symlink_to(prefix)
    (work / "ending.mp4").symlink_to(ending)
    script = work / "join.ffconcat"
    script.write_text(f"ffconcat version 1.0\nfile prefix.mp4\nduration {count / 30:.6f}\n"
                      f"file ending.mp4\nduration {(TOTAL_FRAMES - count) / 30:.6f}\n")
    run([*FFMPEG, "-f", "concat", "-auto_convert", "0", "-i", str(script), *COPY_VIDEO, str(target)])
    verify_format(target, TOTAL_FRAMES)
    verify_presentation(target, TOTAL_FRAMES)


def replace_ending(source, edited_rgb, start, target, work):
    prefix = work / "copied.mp4"
    ending = work / "edited.mp4"
    run([*FFMPEG, "-i", str(source), *COPY_VIDEO, "-frames:v", str(start), str(prefix)])
    verify_presentation(prefix, start)
    encode(edited_rgb, ending, TOTAL_FRAMES - start)
    join(prefix, ending, start, target, work)


def prepare_wide(clean, work):
    still = work / "neutral.png"
    decode(clean, BASE_FRAMES - 1, 1, still, png=True)
    tag = work / "tag.rgb"
    python("animate_face.py", still, tag)
    first_tag = work / "tag.mp4"
    encode(tag, first_tag, TOTAL_FRAMES - BASE_FRAMES)
    first_cut = work / "first-cut.mp4"
    first = work / "first"
    first.mkdir()
    join(clean, first_tag, BASE_FRAMES, first_cut, first)

    wide = work / "wide"
    wide.mkdir()
    source, edited = wide / "source.rgb", wide / "edited.rgb"
    decode(first_cut, WIDE_START, TOTAL_FRAMES - WIDE_START, source)
    python("animate_wide.py", source, edited)
    result = work / "wide.mp4"
    replace_ending(first_cut, edited, WIDE_START, result, wide)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("clean_base", type=Path, help="The 900-frame camera capture after portrait correction")
    parser.add_argument("output", type=Path, help="New trailer .mp4 path")
    parser.add_argument("--wide-base", type=Path, help="Reuse the 966-frame wide-smile cut before the timing change")
    args = parser.parse_args()
    clean = args.clean_base.resolve(strict=True)
    output = args.output.resolve()
    if output.suffix.lower() != ".mp4" or output.exists() or not output.parent.is_dir():
        parser.error("Use a new .mp4 in an existing output directory.")
    verify_format(clean, BASE_FRAMES)
    wide = args.wide_base.resolve(strict=True) if args.wide_base is not None else None
    if wide is not None:
        verify_format(wide, TOTAL_FRAMES)

    with TemporaryDirectory(prefix="isle-house-edit-", dir=output.parent) as directory:
        work = Path(directory)
        if wide is None:
            wide = prepare_wide(clean, work)
        shifted = work / "shifted"
        shifted.mkdir()
        source, tracking, edited = (shifted / name for name in ("source.rgb", "tracking.rgb", "edited.rgb"))
        decode(wide, EARLY_START, TOTAL_FRAMES - EARLY_START, source)
        decode(clean, EARLY_START, BASE_FRAMES - EARLY_START, tracking)
        python("shift_gesture.py", source, tracking, edited)
        staged = shifted / "trailer.mp4"
        replace_ending(wide, edited, EARLY_START, staged, shifted)
        os.link(staged, output)
    print(f"Wrote {output} ({TOTAL_FRAMES} frames at 30 fps).")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        raise SystemExit(str(error)) from error

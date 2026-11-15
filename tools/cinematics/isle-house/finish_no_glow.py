"""Compose the approved earlier smile and wink directly from a fresh native capture."""

import argparse
import os
from pathlib import Path
import subprocess
import sys
from tempfile import TemporaryDirectory

import numpy as np

import face_shape as wide
import finish_capture as camera


W, H = 1920, 1080
FIRST, LAST_NATIVE, LAST = 711, 899, 965
PORTRAIT, ADVANCE = 900, 60
X0, X1, Y0, Y1 = 645, 1275, 250, 660
EXPANDED_Y, EXPANDED_X = np.mgrid[235:675,635:1285].astype(np.float32)
MATTE_THRESHOLD = 182
# Measured at the matched latest-main no-glow portrait; these are the
# inside of the stock eye rims, not the larger old bloom footprint.
EYE_Y = np.array([318, 321, 324, 328, 333, 340, 348, 356, 364,
                  372, 380, 388, 396, 403, 408, 411, 413])
EYE_LEFT = (
    [900, 888, 879, 875, 870, 865, 862, 859, 856, 855, 855, 856, 859, 870, 881, 893, 908],
    [1013, 1000, 994, 989, 985, 981, 977, 975, 972, 972, 972, 973, 975, 979, 990, 1004, 1018],
)
EYE_RIGHT = (
    [910, 923, 928, 932, 938, 943, 947, 949, 949, 949, 949, 947, 946, 939, 929, 916, 909],
    [1023, 1031, 1038, 1042, 1048, 1054, 1059, 1062, 1064, 1066, 1066, 1065, 1061, 1050, 1038, 1026, 1019],
)
EYE_BOUNDS = np.array([[854, 948, 320, 411], [971, 1065, 321, 411]])
# Coordinates of the approved canonical smile lie along the front bevels.
MOUTH_CORNERS = (659.5, 1259.5)
LATCH_TOP = 513.
FRAME_BYTES = W * H * 3


def cue(frame):
    t = (frame + ADVANCE - PORTRAIT) / 30
    smile = wide.ease((t - .12) / .56) * (1 - .10 * wide.ease((t - 1.73) / .35))
    wink = wide.ease((t - 1.08) / .14) * (1 - wide.ease((t - 1.36) / .21))
    idle = smile * wide.ease(t / .30) * np.sin(t * 5.05)
    return float(smile), float(wink), float(idle)


def developed(raw, frame, nadir):
    if 28 <= frame <= nadir:
        return camera.translated_rgb(raw, *camera.nadir_bias(frame))
    if frame > camera.PORTRAIT_START:
        return camera.portrait_rgb(raw, frame)
    return raw


def guide(frame):
    lx, rx, cy = [np.interp(frame, wide.TRACK[:, 0], wide.TRACK[:, k]) for k in (1, 2, 3)]
    return lx, rx, cy, (rx - lx) / 117


def bounds(image, cx, cy, scale, split, side):
    dx = 55 * scale + 2
    dy = 53 * scale + 5
    left, right = max(0, int(cx - dx)), min(W, int(cx + dx + 1))
    top, bottom = max(0, int(cy - dy)), min(H, int(cy + dy + 1))
    if side == 0:
        right = min(right, int(split))
    else:
        left = max(left, int(split))
    pixels = image[top:bottom, left:right]
    bright = pixels.min(axis=2) >= MATTE_THRESHOLD
    yy, xx = np.nonzero(bright)
    if len(xx) < 5:
        return None
    return np.array([xx.min() + left, xx.max() + left, yy.min() + top, yy.max() + top], dtype=np.float32)


def observe(image, frame):
    lx, rx, cy, scale = guide(frame)
    return tuple(bounds(image, cx, cy, scale, (lx + rx) / 2, side)
                 for side, cx in enumerate((lx, rx)))


def eye_fit(observed, frame):
    lx, rx, cy, scale = guide(frame)
    fits = []
    for side, (actual, settled) in enumerate(zip(observed, EYE_BOUNDS)):
        if actual is None:
            fits.append([lx if side == 0 else rx, cy, scale, scale, 0.])
            continue
        actual_width = float(actual[1] - actual[0] + 1)
        actual_height = float(actual[3] - actual[2] + 1)
        sx = actual_width / (settled[1] - settled[0] + 1)
        sy = min(actual_height / (settled[3] - settled[2] + 1), 1.09*sx)
        cx0, cy0 = wide.CANONICAL[side]
        cx = actual[:2].mean() + sx * (cx0 - settled[:2].mean())
        ey = actual[3] - sy * (settled[3] - cy0)
        tolerance = 1.72 if scale < .21 else 1.47
        valid = .52 * scale < sx < tolerance * scale and .53 * scale < sy < tolerance * scale
        fits.append([cx, ey, sx, sy, float(valid)] if valid
                    else [lx if side == 0 else rx, cy, scale, scale, 0.])
    return np.asarray(fits, dtype=np.float32)


def mouth_marks(image, observed, frame):
    _, _, cy, scale = guide(frame)
    if any(hit is None for hit in observed):
        raise ValueError(f"Missing face tracking at frame {frame}")
    eye_bottom = float(np.asarray(observed)[:, 3].mean())
    y0 = int(eye_bottom + 96.5 * scale - 16)
    tab = image[y0:y0+34, 952:969].mean(axis=1)
    warm = (tab[:, 0] > 165) & (tab[:, 1] > 135) & (tab[:, 0] - tab[:, 2] > 60)
    hits = np.flatnonzero(warm[:-2] & warm[1:-1] & warm[2:])
    if not len(hits):
        raise ValueError(f"Missing latch tracking at frame {frame}; expected near y={y0 + 16}, eye guide={cy}")
    latch = y0 + hits[0]
    row = int(latch + 7 * scale)
    brightness = image[row-2:row+3].mean(axis=(0, 2))
    gradient = np.diff(brightness)
    corners = []
    for x, direction in ((660, -1), (1259, 1)):
        guess = int(960 + (x - 960) * scale)
        first = guess - 14
        corners.append(first + np.argmax(gradient[first:guess+15] * direction) + .5)
    return np.asarray([*corners, latch], dtype=np.float32)


def mouth_fit(marks):
    left, right, latch = marks
    scale = (right-left) / (MOUTH_CORNERS[1]-MOUTH_CORNERS[0])
    if not .85 < scale < 1.04:
        raise ValueError(f"Unexpected smile tracking scale {scale:.3f}")
    return scale, scale, left-scale*MOUTH_CORNERS[0], latch-scale*LATCH_TOP


def bend_smile(pixels, fit, amount, idle):
    sx, sy, tx, ty = fit
    canonical = pixels.copy()
    sampled = wide.sample(pixels, EXPANDED_X * sx + tx, EXPANDED_Y * sy + ty)
    canonical[235:675, 635:1285] = np.clip(np.rint(sampled), 0, 255).astype(np.uint8)
    altered = wide.smile(canonical, wide.prepare_layers(canonical), amount, idle)
    difference = altered - canonical[Y0:Y1, X0:X1].astype(np.float32)
    x0, x1 = int(np.floor(X0 * sx + tx)) - 1, int(np.ceil(X1 * sx + tx)) + 1
    y0, y1 = int(np.floor(Y0 * sy + ty)) - 1, int(np.ceil(Y1 * sy + ty)) + 1
    yy, xx = np.mgrid[y0:y1, x0:x1].astype(np.float32)
    dx = (xx - tx) / sx - X0
    dy = (yy - ty) / sy - Y0
    offset = wide.sample(difference, dx, dy)
    pixels[y0:y1, x0:x1] = np.clip(np.rint(pixels[y0:y1, x0:x1] + offset), 0, 255).astype(np.uint8)


def rounded_filter(positions):
    padded = np.pad(positions, ((1, 1), (0, 0)), mode="edge")
    return .2 * padded[:-2] + .6 * padded[1:-1] + .2 * padded[2:]


def apply_eyes(pixels, source, fits, gaze, wink, metrics=None):
    for side, (tx, ty, sx, sy, valid) in enumerate(fits):
        if not valid:
            continue
        x0, x1 = max(0, int(tx - sx*56 - 2)), min(W, int(tx + sx*56 + 3))
        y0, y1 = max(0, int(ty - sy*60 - 2)), min(H, int(ty + sy*60 + 3))
        yy, xx = np.mgrid[y0:y1, x0:x1].astype(np.float32)
        cx, cy = wide.CANONICAL[side]
        x = (xx - tx) / sx + cx
        y = (yy - ty) / sy + cy
        left = np.interp(y, EYE_Y, EYE_LEFT[side])
        right = np.interp(y, EYE_Y, EYE_RIGHT[side])
        distance = np.minimum(x-left, right-x)
        matte = wide.edge(distance, 1.9/sx) * wide.edge(y-EYE_Y[0], 2.1/sy) * wide.edge(EYE_Y[-1]-y, 2.1/sy)
        original = source[y0:y1, x0:x1].astype(np.float32)

        inside = original[(matte > .95) & (distance > 4.0)]
        bright = inside[inside.min(axis=1) >= MATTE_THRESHOLD]
        if len(bright) < 5:
            continue
        sorted_bright = bright[np.argsort(bright.mean(axis=1))]
        middle = sorted_bright[int(.48*len(bright)):max(1, int(.76*len(bright)))]
        # Preserve the plate's neutrality and keep headroom for visible shading.
        white = np.median(middle, axis=0)
        white *= min(1., 235. / max(white))
        dark = inside[np.argsort(inside.mean(axis=1))[:max(3, int(len(inside)*.13))]]
        ink = np.clip(np.median(dark, axis=0), 16, 98)
        nx = np.clip((x - (left + right)*.5) / np.maximum((right-left)*.5, 4.), -1, 1)
        ny = (y - cy) / 49.5

        dx, dy = (x-cx)/19.8, (y-cy+.4)/34.5
        angle = np.arctan2(-dy, dx*(1 if side else -1))
        wedge = (angle > .34) & (angle < 1.0) & (np.hypot(dx, dy) > .31)
        iris = wide.edge((1.-np.hypot(dx, dy))*20, 1.7/sx) * (~wedge)
        dome = np.sqrt(np.clip(1. - nx*nx - ny*ny, 0., 1.))
        sclera = white + (5.5*dome - 4.5*nx - 2.5*ny - 3.0)[..., None]
        shine = 11. * np.exp(-((dx+.23)/.32)**2 - ((dy+.14)/.31)**2)
        pupil = ink + (5.*np.clip(dy, -1., 1.) + shine)[..., None]
        target = wide.mix(sclera, pupil, iris)
        weight = matte * wide.ease((distance+1.)/5.) * gaze
        result = wide.mix(original, target, weight)

        if side == 1 and wink > 0:
            # Use the full anatomical bulb for the eyelid. The normal eye
            # matte can be shorter when Chester's original upper lid rests low.
            bottom = ty + sy * (411. - cy)
            lid_y = (yy - bottom)/sx + 411.
            lid_left = np.interp(lid_y, EYE_Y, EYE_LEFT[side])
            lid_right = np.interp(lid_y, EYE_Y, EYE_RIGHT[side])
            lid_dist = np.minimum(x - lid_left, lid_right - x)
            lid_bulb = wide.edge(lid_dist, 1.85/sx)
            lid_bulb *= wide.edge(lid_y-EYE_Y[0], 2.1/sx) * wide.edge(EYE_Y[-1]-lid_y, 2.1/sx)
            lid_nx = np.clip((x-(lid_left+lid_right)*.5)/np.maximum((lid_right-lid_left)*.5, 4.), -1, 1)
            lid_ny = (lid_y-cy)/49.5
            lid_dome = np.sqrt(np.clip(1. - lid_nx*lid_nx - lid_ny*lid_ny, 0., 1.))
            grain = (np.sin(lid_y*.28 + lid_nx*2.4) + .36*np.sin(lid_y*.57 - lid_nx*3.3))*2.
            wood = (.68 + .37*lid_dome - .10*lid_nx - .10*lid_ny)[...,None] * [165.,105.,65.]
            wood += grain[...,None]
            meet = cy + 6. + (1.-lid_nx*lid_nx)*7.4
            upper = cy - 53.5 + wink*(meet - (cy - 53.5))
            lower = cy + 54.5 - wink*(cy + 54.5 - meet)
            lid = np.maximum(wide.edge(upper-lid_y, 2.2/sx), wide.edge(lid_y-lower, 2.2/sx))
            # Cover the genuine antialiased white rim as the lids meet.
            edge_white = wide.ease((original.min(axis=2)-92.)/91.)
            edge_white *= ((lid_dist > -5.5/sx) & (lid_y >= EYE_Y[0]-5/sx)
                           & (lid_y <= EYE_Y[-1]+4/sx))
            closed_matte = np.maximum(lid_bulb*lid, edge_white*wide.ease((wink-.72)/.28))
            result = wide.mix(result, wood, closed_matte)
            rim_distance = np.minimum(np.abs(lid_y-upper), np.abs(lid_y-lower))
            seam = wide.edge(2.5-rim_distance, 2./sx)*lid_bulb*wide.ease((wink-.09)/.23)
            result = wide.mix(result, np.array([43.,27.,18.]), seam)

        pixels[y0:y1, x0:x1] = np.clip(np.rint(result), 0, 255).astype(np.uint8)
        if metrics is not None:
            metrics.append((side, white.round(1).tolist(), ink.round(1).tolist()))


def shot(source, eyes, marks, frame, metrics=None):
    pixels = source.copy()
    smile, wink, idle = cue(frame)
    if smile:
        bend_smile(pixels, mouth_fit(marks), smile, idle)
    gaze = float(wide.ease((frame - FIRST) / 4))
    apply_eyes(pixels, source, eyes, gaze, wink, metrics)
    return pixels


def open_png(path):
    result = subprocess.run(
        ["ffmpeg", "-nostdin", "-v", "error", "-i", str(path),
         "-frames:v", "1", "-pix_fmt", "rgb24", "-f", "rawvideo", "-"],
        check=True, capture_output=True)
    return np.frombuffer(result.stdout, dtype=np.uint8).reshape(H, W, 3)


def preview(source, out):
    out.mkdir(exist_ok=False)
    settled = developed(open_png(source / "frame-0899.png"), LAST_NATIVE, 0)
    reference = observe(settled, LAST_NATIVE)
    if any(value is None for value in reference):
        raise ValueError(f"Could not measure the settled no-glow eye plate: {reference}")
    baseline = mouth_marks(settled, reference, LAST_NATIVE)
    for frame in [715, 730, 740, 850, 861, 875, 877, 880, 888, 899, 965]:
        local = min(frame, LAST_NATIVE)
        file = source / f"frame-{local:04d}.png"
        if not file.exists():
            continue
        image = settled if local == LAST_NATIVE else developed(open_png(file), local, 0)
        observed = observe(image, local)
        eyes = eye_fit(observed, local)
        marks = mouth_marks(image, observed, local) if cue(frame)[0] else baseline
        metrics = []
        finished = shot(image, eyes, marks, frame, metrics)
        print(frame, "color (eye / sclera / pupil)", metrics,
              "track", np.round(eyes, 3).tolist(), "mouth marks", marks.tolist(), flush=True)
        wide.png(out / f"neutral-{frame:04d}.png", image)
        wide.png(out / f"edited-{frame:04d}.png", finished)


def encode(source, out, nadir):
    count = LAST_NATIVE + 1
    if source.stat().st_size != count * FRAME_BYTES:
        raise ValueError(f"Expected exactly {count} native RGB24 frames")
    raw = np.memmap(source, dtype=np.uint8, mode="r", shape=(count, H, W, 3))
    settled = developed(raw[LAST_NATIVE], LAST_NATIVE, nadir)
    reference = observe(settled, LAST_NATIVE)
    if any(value is None for value in reference):
        raise ValueError(f"Missing final stock eye measurements: {reference}")
    eye_track, mouth_track = [], []
    for frame in range(FIRST, LAST_NATIVE + 1):
        source_frame = developed(raw[frame], frame, nadir)
        observed = observe(source_frame, frame)
        eye_track.append(eye_fit(observed, frame))
        if frame >= 844:
            mouth_track.append(mouth_marks(source_frame, observed, frame))
    eye_track = np.stack(eye_track)
    for eye in range(2):
        eye_track[:, eye, :4] = rounded_filter(eye_track[:, eye, :4])
    mouth_track = rounded_filter(np.stack(mouth_track))
    baseline = mouth_track[-1]
    print("Measured full moving face, writing MP4 with 966 frames", flush=True)

    convert = ("scale=in_range=pc:out_range=tv:out_color_matrix=bt709"
               ":flags=accurate_rnd+full_chroma_int,format=yuv420p,setsar=1"
               ",setparams=range=limited:color_primaries=bt709:color_trc=bt709:colorspace=bt709")
    command = ["ffmpeg", "-nostdin", "-n", "-hide_banner", "-loglevel", "warning",
               "-stats", "-stats_period", "10", "-f", "rawvideo", "-pixel_format", "rgb24",
               "-video_size", f"{W}x{H}", "-framerate", "30", "-i", "-", "-vf", convert,
               "-an", "-c:v", "libx264", "-preset", "slow", "-crf", "18", "-g", "60",
               "-profile:v", "high", "-level:v", "4.1", "-maxrate", "18M", "-bufsize", "18M",
               "-color_range", "tv", "-colorspace", "bt709", "-color_trc", "bt709",
               "-color_primaries", "bt709", "-video_track_timescale", "30000", "-movflags", "+faststart", str(out)]
    with subprocess.Popen(command, stdin=subprocess.PIPE) as ffmpeg:
        assert ffmpeg.stdin is not None
        try:
            for frame in range(LAST + 1):
                local = min(frame, LAST_NATIVE)
                pixels = settled if local == LAST_NATIVE else developed(raw[local], local, nadir)
                if frame >= FIRST:
                    eyes = eye_track[local - FIRST]
                    marks = mouth_track[local - 844] if local >= 844 else baseline
                    pixels = shot(pixels, eyes, marks, frame)
                ffmpeg.stdin.write(pixels.tobytes())
        finally:
            ffmpeg.stdin.close()
        if ffmpeg.wait():
            raise RuntimeError("MP4 encoding failed")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("out", type=Path)
    parser.add_argument("--preview", action="store_true")
    parser.add_argument("--last-nadir-frame", type=int, default=0)
    args = parser.parse_args()
    if args.last_nadir_frame and not 28 <= args.last_nadir_frame < 87:
        parser.error("The correction is only valid through identification of the nadir transition.")
    if args.preview:
        preview(args.source, args.out)
    else:
        out = args.out.absolute()
        if out.suffix.lower() != ".mp4" or out.exists() or out.is_symlink() or not out.parent.is_dir():
            parser.error("Use a new .mp4 in an existing output directory.")
        # Keep a failed encode away from the requested destination. The hard
        # link publishes within the same directory without replacing a file.
        with TemporaryDirectory(prefix="isle-house-", dir=out.parent) as scratch:
            staged = Path(scratch) / "trailer.mp4"
            encode(args.source, staged, args.last_nadir_frame)
            os.link(staged, out)

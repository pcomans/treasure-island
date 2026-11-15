"""Pixel corrections for the map hold and final portrait framing."""

import math

import numpy as np

WIDTH, HEIGHT = 1920, 1080
OPENING_FRAMES = 27
PORTRAIT_START = 777
PORTRAIT_END = 876
PORTRAIT_SCALE = 0.80


def ease(value):
    t = min(1.0, max(0.0, value))
    return t**3 * (t * (t * 6.0 - 15.0) + 10.0)


def nadir_bias(frame):
    """Screen sample offset lost while the renderer held the exact nadir."""
    seconds = (frame - OPENING_FRAMES) / 30.0
    advance = ease(seconds / 13.1)
    dive = ease(seconds / 12.9)
    track = ease((seconds - 1.6) / 10.0)
    x = -348.0 * advance
    z = 945.0 * advance
    aim_x = -122.0 * track
    aim_z = 632.0 * track
    aim_y = 16.0 * track
    altitude = 26000.0 * (116.0 / 26000.0)**dive
    initial_lens = 2700.0 / 52000.0
    final_lens = math.tan(math.radians(46.0 / 2.0))
    lens = initial_lens * (final_lens / initial_lens)**ease((seconds - 1.1) / 8.9)
    pixels_per_metre = 540.0 / (lens * (altitude - aim_y))
    return -(x - aim_x) * pixels_per_metre, -(z - aim_z) * pixels_per_metre


def translated_rgb(pixels, dx, dy):
    columns = np.clip(np.arange(WIDTH, dtype=np.float32) + dx, 0, WIDTH - 1)
    rows = np.clip(np.arange(HEIGHT, dtype=np.float32) + dy, 0, HEIGHT - 1)
    left = columns.astype(np.int32)
    top = rows.astype(np.int32)
    right = np.minimum(left + 1, WIDTH - 1)
    bottom = np.minimum(top + 1, HEIGHT - 1)
    horizontal_part = (columns - left).astype(np.float32)[None, :, None]
    vertical_part = (rows - top).astype(np.float32)[:, None, None]
    along_rows = pixels[:, left] * (1 - horizontal_part) + pixels[:, right] * horizontal_part
    return np.rint(along_rows[top] * (1 - vertical_part) +
                   along_rows[bottom] * vertical_part).astype(np.uint8)


def cubic_axis(pixels, coordinates, axis):
    """Resample an axis with a four-tap separable cubic kernel."""
    index = np.floor(coordinates).astype(np.int32)
    fraction = (coordinates - index).astype(np.float32)
    square = fraction * fraction
    cube = square * fraction
    weights = [
        -0.5 * fraction + square - 0.5 * cube,
        1.0 - 2.5 * square + 1.5 * cube,
        0.5 * fraction + 2.0 * square - 1.5 * cube,
        -0.5 * square + 0.5 * cube,
    ]
    weight_shape = [1, 1, 1]
    weight_shape[axis] = -1
    result = np.zeros(pixels.shape, dtype=np.float32)
    for offset, weight in zip((-1, 0, 1, 2), weights):
        samples = np.clip(index + offset, 0, pixels.shape[axis] - 1)
        result += np.take(pixels, samples, axis=axis) * weight.reshape(weight_shape)
    return result


def portrait_rgb(pixels, frame):
    weight = ease((frame - PORTRAIT_START) / (PORTRAIT_END - PORTRAIT_START))
    scale = 1.0 + (PORTRAIT_SCALE - 1.0) * weight
    # Center horizontally. Anchor the top so the crop lifts toward the eyes.
    columns = (np.arange(WIDTH, dtype=np.float32) + 0.5) * scale - 0.5
    columns += WIDTH * (1.0 - scale) / 2.0
    rows = (np.arange(HEIGHT, dtype=np.float32) + 0.5) * scale - 0.5
    across = cubic_axis(pixels, columns, 1)
    resized = cubic_axis(across, rows, 0)
    return np.clip(np.rint(resized), 0, 255).astype(np.uint8)

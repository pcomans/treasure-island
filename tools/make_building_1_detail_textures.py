"""Writes Building 1's small detail-pattern textures (programmatic, original):
greyscale multipliers the public stucco shader (building_1_public_stucco.gdshader,
detail_pattern) applies over its paint, sampled with the mesh's UV. Image rows run
from world-low (top row) to world-high, as the meshes' v grows with height.
usage: python3 -I tools/make_building_1_detail_textures.py game/resources/textures/world/building_1_detail"""
import os, struct, sys, zlib


def png(path, w, h, value_at):
    rows = []
    for r in range(h):
        row = bytearray([0])
        for c in range(w):
            v = max(0, min(255, round(value_at(c, r) * 255)))
            row += bytes((v, v, v))
        rows.append(bytes(row))
    def chunk(t, d):
        return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xffffffff)
    data = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0)) + chunk(b"IDAT", zlib.compress(b"".join(rows), 9)) + chunk(b"IEND", b"")
    open(path, "wb").write(data)


out = sys.argv[1]
os.makedirs(out, exist_ok=True)


# Incised line: one period (v 0..1, world-up) with the groove in its lowest fifth: a
# lit lower lip, the groove's floor, the shadow under the upper lip, the lip's edge.
def incised(c, r):
    v = (r + 0.5) / 64.0
    if v < 0.04: return 0.88
    if v < 0.11: return 0.66
    if v < 0.2: return 0.46
    if v < 0.23: return 1.04
    return 1.0
png(os.path.join(out, "b1_incised_line.png"), 8, 64, incised)


# Canopy fascia, foot (v 0) to top (v 1): a stack of five thin rolls between a dark
# lower arris and a lit upper one, each roll lit on top and shaded underneath.
def fascia(c, r):
    v = (r + 0.5) / 128.0
    if v < 0.04: return 0.62
    if v > 0.96: return 1.06
    p = ((v - 0.04) / 0.92) * 5.0 % 1.0
    if p < 0.16: return 0.6
    if p < 0.3: return 0.82
    if p > 0.86: return 1.07
    return 1.0
png(os.path.join(out, "b1_canopy_fascia.png"), 8, 128, fascia)


# Dentil course: one period along u (a block, then the gap behind it), the band's
# height in v; the gaps shade darker towards the top, under the course above.
def dentils(c, r):
    u = (c + 0.5) / 32.0
    v = (r + 0.5) / 32.0
    if u < 0.6:
        if v < 0.08: return 0.8
        if u > 0.55: return 0.82
        return 1.0
    return 0.62 - 0.14 * v
png(os.path.join(out, "b1_dentils.png"), 32, 32, dentils)
print("written to", out)

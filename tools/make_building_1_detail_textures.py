"""Writes Building 1's hairline detail pattern (programmatic, original): a greyscale
multiplier the public stucco shader (building_1_public_stucco.gdshader,
detail_pattern) applies over its paint, sampled with the mesh's UV. Bold relief is
modelled; only hairline scoring is drawn. Image rows run
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


print("written to", out)

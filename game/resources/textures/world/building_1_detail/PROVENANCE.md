# Building 1 detail patterns

Small programmatic textures for Building 1's fine linear detail, written by
`tools/make_building_1_detail_textures.py` on 2026-11-20. Original greyscale
multipliers drawn in code, not taken from any photograph. The public stucco
shader multiplies its paint by them through the mesh's UV. Lossless and
mipmapped, so fine lines average to a steady tone with distance instead of
switching or shimmering.

- `b1_incised_line.png` (8 x 64): one period of an incised horizontal line.
- `b1_canopy_fascia.png` (8 x 128): the canopy fascia's stack of five thin rolls.
- `b1_dentils.png` (32 x 32): one block and gap of a dentil course.

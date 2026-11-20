# Building 1 detail patterns

A small programmatic texture for Building 1's hairline scoring, written by
`tools/make_building_1_detail_textures.py` on 2026-11-20. An original greyscale
multiplier drawn in code, not taken from any photograph. The public stucco
shader multiplies its paint by it through the mesh's UV. Lossless and
mipmapped, so hairlines average to a steady tone with distance. Bold relief
(rolls, reeds, dentils, copings) is modelled, not drawn.

- `b1_incised_line.png` (8 x 64): one period of an incised horizontal line.

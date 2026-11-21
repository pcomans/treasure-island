# Building 1 detail patterns

A small programmatic texture for Building 1's hairline scoring, written by
`tools/make_building_1_detail_textures.py` on 2026-11-20. An original greyscale
multiplier drawn in code, not taken from any photograph. The public stucco
shader multiplies its paint by it through the mesh's UV. Lossless and
mipmapped, so hairlines average to a steady tone with distance. Bold relief
(rolls, reeds, dentils, copings) is modelled, not drawn.

- `b1_incised_line.png` (8 x 64): one period of an incised horizontal line.
- `b1_weathering_map.res` (384 x 472 half floats, 0.25 m cells) and its web copy
  `b1_weathering_map.res.web` (192 x 236, 0.5 m cells, which web builds carry in
  its place): Building 1's plan-view weathering map, baked by
  `tools/bake_building_1_weathering.gd` from the hero model's own geometry and
  `game/resources/facades/building_1_weathering.json` (2026-11-21), not from any
  photograph.

# Street clutter model provenance

## Street-clutter kit (`street_clutter_kit.glb`)

- Made in this project, no third-party asset: `tools/build_street_clutter_kit.mjs`
  writes it from the procedural kit in `tools/lib/street-clutter-kit.mjs`
  (deterministic; rebuild and commit it with any kit change).
- Contents: one node and mesh per detail level (`_lod0` near, `_lod1` far) of nine
  generic parked-car bodies (crossover, suv, sedan, fastback, hatchback, wagon,
  pickup, utility, van), a traffic cone and an A-frame barricade. Each vertex
  carries its part (glass, tyre, lamp, ...) in UV.x and baked occlusion in UV.y;
  there are no materials or textures in the file. `street_clutter.gdshader`
  colours the parts at runtime, and a parked car's paint is its MultiMesh
  instance data (`game/scripts/world/street_clutter_kit.gd`).
- Shapes and sizes are production inference: typical 2020s Bay Area cars photographed
  parked in the pilot zones (Sep and Nov 2025 Street View), generic rather than any
  make; no reference photo was used as a texture.
- Import: no generated LODs (the kit has its own two levels), no light baking,
  attribute compression off so the part and occlusion UVs stay exact.

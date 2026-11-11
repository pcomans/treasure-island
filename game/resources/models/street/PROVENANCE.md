# Street clutter model provenance

## Street-clutter kit (`street_clutter_kit.glb`)

- Made in this project, no third-party asset: `tools/build_street_clutter_kit.mjs`
  writes it from the procedural kit in `tools/lib/street-clutter-kit.mjs`
  (deterministic; rebuild and commit it with any kit change).
  `tools/check_godot_world_determinism.mjs` (part of `tools/test.sh`) rebuilds it
  in memory and fails when the committed file differs from that build, as it
  does for `generated/world`.
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

## Yard kit (`street_yard_kit.glb`)

- Made in this project, no third-party asset: `tools/build_street_yard_kit.mjs`
  writes it from the procedural kit in `tools/lib/street-yard-meshes.mjs` (the
  registry, footprints and container-wall layout are in
  `tools/lib/street-yard-kit.mjs`). Deterministic; rebuild and commit it with any
  kit change. `tools/check_godot_world_determinism.mjs` rebuilds it in memory and
  fails when the committed file differs.
- Contents: two detail levels (`_lod0`, `_lod1`) of the large yard clutter:
  shipping containers (10, 20 and 40 ft, high cube, a roll-up door conversion, a
  40 ft office), self-storage shed row modules (bays and ends of three widths),
  fabric shed modules (four spans), plastic-covered berm and soil-ridge modules,
  material piles (gravel, rubble, soil, tarp-covered; three shapes each),
  equipment (crawler excavator, wheel loader, crane mats, hollow cylinder
  sections), RVs (class A, class C, travel trailer, fifth wheel), a coach and a
  shuttle bus, box trucks, a step van (and the car kit's cargo van, re-encoded),
  food trucks, trailers (cargo, utility, semi, mobile office), boats on
  trailers, the Pier 1 barge hull modules, crawler cranes (boom raised or
  lowered), a deckhouse and deck loads, a water barrier and a pole flag; and for
  every heap (pile, berm and windrow module) its collision floor (`_floor`), a
  height field laid over its near mesh with no triangle steeper than 45
  degrees; and, last, for every vehicle a player drives (the vans, box trucks,
  food-truck step van and class A and C RVs; 2026-11-11) its chassis without
  wheels (`_chassis_lod0`), its front tyre and, where twin rear tyres differ, its
  rear one round their centres (`_tyre_lod0`, `_tyre_rear_lod0`) and two empty
  nodes at its right-hand wheel centres (`_axle_front`, `_axle_rear`), as the
  car kit has for the cars. Each vertex carries
  its part in UV.x and baked occlusion in UV.y (a flag's face carries texture
  coordinates instead, for `street_pole_flag.png`); no materials or textures in
  the file. `street_yard.gdshader` colours the parts and
  draws corrugation, ribs and weathering at runtime
  (`game/scripts/world/street_yard_kit.gd`).
- Shapes and sizes are trade sizes (ISO containers, 10 ft storage units, US
  vehicle classes) and production inference from the dated 2023-2025 Street View
  and the May 2026 aerial of the yards (large-clutter research, 2026-11-04),
  generic rather than any make; no reference photo was used as a texture.
- Import: as the clutter kit (no generated LODs, no light baking, attribute
  compression off so the part and occlusion UVs stay exact).

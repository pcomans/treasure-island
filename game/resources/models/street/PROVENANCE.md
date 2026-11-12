# Street clutter model provenance

## Street-clutter kit (`street_clutter_kit.glb`)

- Made in this project, no third-party asset: `tools/build_street_clutter_kit.mjs`
  writes it from the procedural kit in `tools/lib/street-clutter-kit.mjs`
  (deterministic; rebuild and commit it with any kit change).
  `tools/check_godot_world_determinism.mjs` (part of `tools/test.sh`) rebuilds it
  in memory and fails when the committed file differs from that build, as it
  does for `generated/world`.
- Contents: nine generic parked-car bodies (crossover, suv, sedan, fastback,
  hatchback, wagon, pickup, utility, van), each as `car_<body>_lod0` (near, wheels
  and all), `_lod1` (far), `_shadow` (the far body a little inside the surface:
  what casts the car's shadow while a nearer level draws), `_chassis_lod0` and
  `_tyre_lod0` (the near body without wheels and one wheel, for a driven car),
  `_hull0` to `_hull2` (the points of the convex pieces a parked or driven car
  collides as: its drawn outline's corners within 1.5 cm, the roof flat out to
  its rails; reworked 2026-11-12) and two axle markers; then a traffic cone, an
  A-frame barricade, a dumpster and a
  stock-tank planter at two levels each. The cars come from
  `tools/lib/street-car-kit.mjs` and `street-car-parts.mjs` (rebuilt 2026-11-09):
  one smooth body surface per car with its regions cut in along their outlines,
  normals taken from the surface. Each vertex carries its part (glass, tyre,
  lamp, ...) in UV.x, (part + 0.5) / 32, and baked occlusion in UV.y (a tyre
  vertex its place across the tyre's section); there are no materials or
  textures in the file. `street_clutter.gdshader` colours the parts at runtime,
  and a parked car's paint is its MultiMesh instance data
  (`game/scripts/world/street_clutter_kit.gd`).
- Shapes and sizes are production inference: typical 2020s Bay Area cars photographed
  parked in the pilot zones (Sep and Nov 2025 Street View), generic rather than any
  make; no reference photo was used as a texture.
- Import: no generated LODs (the kit has its own levels), no light baking,
  attribute compression off so the part and occlusion UVs stay exact.

## Car hero kit (`street_car_hero_kit.glb`)

- Made in this project, no third-party asset: `tools/build_street_car_hero_kit.mjs`
  writes it from the same car generator (`tools/lib/street-car-kit.mjs`
  `carHeroKitMeshes`), deterministic; the determinism check rebuilds it as it
  does the clutter kit.
- Contents: the nine bodies' hero level, four meshes each: `car_<body>_hero_body`
  (shell with panel gaps, lamp bowls and projectors, cabin with seats, dashboard
  and steering wheel, underbody), `_hero_glass` (the see-through panes and lamp
  lenses, drawn with `street_car_glass.gdshader`), `_hero_tyre` (one wheel:
  tyre, rim with spokes, hub and lug nuts) and `_hero_brake` (disc and caliper),
  and three markers where a driver sits and holds the wheel
  (`car_<body>_driver_seat`, `_driver_hand_left`, `_driver_hand_right`, for
  `game/scripts/vehicles/car_driver.gd`; 2026-11-12). Fittings shared by every
  body (filler door, door handles, number plates, side reflectors, third brake
  light) are modelled once in `street-car-parts.mjs` and draped onto each body.
  The driven car and the few parked cars nearest the camera draw it
  (`game/scripts/vehicles/car_hero_level.gd`); a wheel and a brake are drawn four
  times each.
- Desktop only: the Web preset in `export_presets.cfg` leaves this file out and
  `street_clutter_kit.gd` `hero_level_enabled()` turns the level off there, so
  the web build draws the near and far levels with their opaque glass.
- Generic "typical 2020s" cars: no make, badge, logo or licence number; no
  texture, no reference photo. Import as the clutter kit.

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
  degrees. Each vertex carries
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

# NAIP unknown-to-shrub integration

**PASS for deterministic source integration and runtime contracts.** The accepted 2022-05-18 NAIP annotations contain 22 `unknown` points. All 22 now produce fixed-location, terrain-grounded, visual-only shrubs; zero were rejected and none was snapped or jittered.

## Before → after

| Contract | Before | After |
| --- | ---: | ---: |
| Total vegetation | 102 | 124 |
| Shrubs | 19 | 41 |
| NAIP unknown shrub placements | 0 | 22 |
| `plant_bushDetailed.glb` placements | 8 | 13 |
| `plant_bushLarge.glb` placements | 5 | 17 |
| `plant_bushSmall.glb` placements | 6 | 11 |
| Curated assets / MultiMesh batches | 15 / 19 | 15 / 19 |
| Rendered source triangles | 18,858 | 20,178 |
| Added collision bodies/shapes | 0 / 0 | 0 / 0 |

The annotation input SHA-256 is `03f858180c6ff0d25b974b1fbb0fc82a91139afe91e83b2e3291ef2dd49ade11`. Current generated content is `fc80e6dcc8a4717be015115e922cb95f70b353e5f8bb0c561bf094d113887832`; `vegetation.json` is `e843ac78c4f5ba769241f330f83b41fd8431fbe06073c9ffd4907c413baad32f`.

## Exact placement outcome

`generated/world/vegetation.json` is the authoritative machine-readable audit. It records `input_count=22`, `placed_count=22`, `rejected_count=0`, every accepted annotation ID, fixed projected locations, deterministic variation, and the empty rejection array. Minimum observed NAIP-row clearances are `19.267 m` shoreline, `14.450 m` terrain/shoreline overlay, `0.102 m` road, and `1.109 m` building. The road/building values are positive exterior distances: accepted satellite points use a documented 1 mm exterior threshold rather than the procedural pass's 4–5 m aesthetic buffer.

Seven fixed points are inside the procedural aesthetic buffer but outside the actual serialized surfaces. Their exact deterministic outcomes are retained in `audit.naip_unknown_annotations.procedural_buffer_exceptions`:

| Annotation | Procedural buffer | Observed | Outcome |
| --- | --- | ---: | --- |
| `ti-naip-20220518-px1840-py1011` | building 5 m | 1.109 m | placed at fixed source location |
| `ti-naip-20220518-px1937-py1180` | road 4 m | 0.728 m | placed at fixed source location |
| `ti-naip-20220518-px1855-py1450` | road 4 m | 0.360 m | placed at fixed source location |
| `ti-naip-20220518-px1451-py1510` | road 4 m | 3.202 m | placed at fixed source location |
| `ti-naip-20220518-px2206-py1571` | road 4 m | 3.907 m | placed at fixed source location |
| `ti-naip-20220518-px2232-py1616` | road 4 m | 2.973 m | placed at fixed source location |
| `ti-naip-20220518-px2261-py1661` | road 4 m | 0.102 m | placed at fixed source location |

## Verification

- `node tools/validate_godot_world.mjs generated/world` — pass; 124 vegetation instances and all coherent-surface/foundation gates valid.
- `node tools/check_godot_world_determinism.mjs` — pass; two clean generations, 46 files byte-for-byte identical, vegetation SHA-256 `e843ac78...`.
- Godot `validate_generated_world.gd` — pass; exact generated content `fc80e6dc...`.
- Godot `full_runtime_integration.gd` — pass; 124 instances, 15 assets, 19 collision-free batches, 20,178 instanced triangles, plus real walk/run/jetpack/landing/spray/recovery/reload gates.

No screenshot render or Mac export was performed for this bounded source/runtime change.

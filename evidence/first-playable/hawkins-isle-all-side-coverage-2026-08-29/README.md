# Hawkins + Isle House all-side coverage proof

Date: 2026-08-29

Status: **independent art review complete — ACCEPT_WITH_DOCUMENTED_LIMITATION; ready for the next playable build within the field-only/untouched-part limits**

Independent review: [`HAWKINS_ISLE_ALL_SIDE_ART_REVIEW.md`](../../../discovery/facades/HAWKINS_ISLE_ALL_SIDE_ART_REVIEW.md)

## Implemented contract

| Target | Before | After |
| --- | --- | --- |
| Hawkins `building:w1249412093:wall` | Accepted WSW/SE fields and modules plus the already implemented conservative all-side field fallback | Runtime unchanged: all `22` exterior runtime quads keep smooth base fields; WSW/SE keep `12` fluted upper quads; ENE/NNW keep `10` plain upper quads; the exposed step keeps one plain field; ENE/NNW/step remain module-free |
| Isle House high `building-composite:w1249412094:w1282547786:wall` | Homogeneous fields on runs `5..9` (`10` quads); complete accepted modules on SE runs `5..7` | Homogeneous podium/tower fields on exterior runs `0..9` plus tower-only fields on shared runs `10..12` (`13` run segments / `23` quads); the accepted SE module schedule and layout hash remain unchanged |
| Isle House low `building-composite:w1249412094:w1282547787:wall` | No facade attachment | Unchanged: no facade, field, module, or material attachment |

No generated/OSM record, massing, footprint, roof, collision, navigation, foundation, terrain, or spray surface was changed. No new architectural module was added. Short Isle facets `0`, `8`, and `12`, the shared lower edge at `y=19.103`, and every part boundary remain protected.

## Render proof

The project-local Godot 4.7.2 harness ran with macOS Forward+/Metal at `1440x900` on `Apple M1 Pro (Apple7)`. [`capture-manifest.json`](capture-manifest.json) records exact receiver/source identities, facade signatures, run scopes, requested and realized transforms, file sizes, dimensions, and SHA-256 hashes.

The `12` declared images comprise close and ordinary-distance views of:

- Hawkins accepted front, conservative ENE field, and unobserved/module-free NNW field;
- Isle House accepted SE front, newly field-covered WSW/SW runs `0..4`, and shared tower-only/module-free runs `10..12`.

The shared Isle pair uses deterministic jetpack-reachable airborne poses after the headless jetpack contract passed, because the low receiver physically occludes those tower-only faces from grounded close views. The first ambiguous grounded ENE pair was superseded and removed; it is not in the manifest.

Mechanical validation confirmed exactly `12` PNGs on disk and in the manifest, unique paths, nonzero byte sizes, `1440x900` dimensions, matching SHA-256 hashes, and all six target/role combinations represented at close and ordinary distances.

## Verification

Passed locally:

- headless editor import and `headless_scene_parse.gd`;
- focused `headless_hawkins_facade_contract.gd` and `headless_isle_house_facade_contract.gd`;
- `headless_gameplay_contract.gd`, `headless_world_material_contract.gd`, and `validate_generated_world.gd`;
- `node tools/validate_godot_world.mjs generated/world`;
- `full_runtime_integration.gd`;
- `automated_route_qa.gd` standard ferry route;
- `automated_route_qa.gd -- --whole-island-route` five-region walk/run/jetpack route;
- `hawkins_isle_all_side_capture.gd` with the real macOS/Metal renderer.

Headless runs emitted the known sandbox-only inability to write `user://logs` and macOS CA-certificate warnings. Every listed contract exited `0`; the Metal capture did not emit those warnings.

## Limitations and follow-up

- Hawkins ENE/NNW and the exposed step intentionally remain homogeneous and module-free; admissible evidence does not authorize openings, fluting, ribbing, signs, service details, or copied front schedules.
- Isle runs `0..4` intentionally remain homogeneous and module-free. A later module pass requires exact side-local U mapping, complete module definitions, run containment, ordinary-distance proof, and independent review.
- Isle runs `8..12` remain module-blocked, and the low part remains unknown/out of scope.
- These images prove live attachment scope and readable field coverage. They do not create a new art-acceptance verdict or authorize massing/silhouette changes.

## Independent review result

The independent gameplay art review accepts the owner-requested coverage improvement with documented limitations. Hawkins ENE/NNW/step and the Isle high non-front/shared sides remain intentionally homogeneous and module-free; Isle House low remains untouched and has no art-acceptance verdict. The review also records that this suite contains no changed-light capture of the newly covered receiver normals and that Hawkins' requested `40 m` WSW view realized `12 m`. See the linked review for the four separate scope verdicts and exact screenshot accounting.

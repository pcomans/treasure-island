# Batch 06 bounded prototype set 01

Status: **ready for independent visual review; not self-accepted**

This immutable evidence set records three standalone, target-specific facade prototype scenes. None is attached to a live receiver. The scenes contain only render geometry: five homogeneous material fields and six complete bounded opening modules, with zero collision and zero navigation.

## Evidence-based selection

Exactly three non-reference-blocked targets were selected from the final observation and run-mapping evidence:

1. `w34313564`: official SSE, NNW and ENE coverage; 15 of 20 exact mapped runs / 228.991 m.
2. `w34313515`: official WSW and NNW coverage; two complete outer source-edge groups, 14 of 48 exact mapped runs / 165.100 m.
3. `w291196370`: official SSE and ENE coverage; two exact outer source-edge groups, 9 of 36 exact mapped runs / 97.893 m.

`w34313525` was deferred from this first set because its two retained chains are partial source-edge slices and cover only 7 of 30 runs. `w34313520` has one-side coverage, while `r133351` remains relation-ownership complex. Reference-blocked `w1222514695` and `w1222720021` have no assets, scenes or modules.

## Prototype inventory

| Target | Homogeneous material fields | Complete bounded modules | Explicit placement bounds |
|---|---|---|---|
| `w34313564` | separate tan SSE, pale NNW/ENE, and pale plinth fields | `W34313564-HWIN`, `W34313564-PDOOR` | mapped groups on runs 5–19; module-specific subsets are in the registry |
| `w34313515` | pale smooth painted field | `W34313515-BAY`, a complete three-tier window group with full surround | WSW runs 0–8 and NNW runs 43–47 |
| `w291196370` | cool gray-blue horizontal siding field | `W291196370-WINSTACK`, `W291196370-ENTRY`, `W291196370-SERVICE` | SSE runs 8–10 and ENE runs 17–22 by motif ownership |

Every module owns its entire opening, full frame/mullions where applicable, and uninterrupted target-field surround. Module opposite-edge continuity is explicitly false. No window, door or service opening is embedded in a seamless whole-wall tile, and there are no architectural pattern tiles.

Material and module dimensions are reversible proof assumptions because no accepted physical calibration exists. Declared scale values and uncertainty bands are recorded in `game/resources/facades/batch_06_prototype_registry.json` and each capture manifest.

## Native evidence

The native macOS capture used Godot 4.7.2, Forward+, Metal, Apple M1 Pro, and a 1440×900 viewport. Each target has:

- `01-close.png`: close material/module detail;
- `02-ordinary-distance.png`: controlled ordinary gameplay-distance scale;
- `03-changed-light-oblique.png`: oblique depth and changed-light/alias control.

All nine PNGs were inspected for evidence validity. Each is nonempty, correctly labeled, shows the intended target prototype, and retains visibly complete module boundaries. The siding course field remains stable at ordinary distance and oblique light. This check does **not** accept color, dimensions, cadence, resemblance or final art direction.

## Mechanical result

- Focused Batch 06 structural contract: PASS.
- Native Forward+/Metal capture: PASS, 9 images.
- Scene/gameplay/material/generated-world validators: PASS.
- Accepted Hawkins, Building 3, Isle House, current YMCA projection, full runtime, ferry route and whole-island route: PASS.
- Batch 02 and Batch 04 focused contracts: PASS.
- Batch 03 focused contract: FAIL on its stale pinned hash for `ti_ymca_primary.tres`. This is unrelated to Batch 06: the file now uses the independently accepted YMCA wall-tangent shader, the current Batch 02 contract and dedicated YMCA projection contract both pass, and Batch 06 does not edit either file.
- Generated-data diff: empty; manifest remains `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`.

The recurring sandbox log-rotation and macOS CA-certificate warnings appeared in headless runs but did not change any exit result.

## Known limits

- No prototype is placed on world geometry, so these images are not gameplay or whole-building evidence.
- Exact material grain/course scale, opening dimensions, cadence and live placement remain unaccepted.
- `W34313515-VRECESS` is deliberately not built in this first set because lower and roof-transition depth ownership remains occlusion-sensitive.
- The `w34313564` pipe/vent cluster is omitted because it is unique-placement-only; ramps, stairs, rails and yard objects are excluded.
- The `w291196370` service-side color variation is not asserted as a separate live region; signs, access geometry and yard objects are excluded.
- Unobserved elevations remain outside the prototype claim.

Independent review should judge target-specific material character, value hierarchy, module proportions, alias behavior and whether these reversible scale assumptions are worth calibrating on their exact receivers. No final artistic verdict is asserted here.

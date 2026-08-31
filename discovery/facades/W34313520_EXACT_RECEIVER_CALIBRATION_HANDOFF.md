# `w34313520` detached exact-receiver calibration handoff

Date: **2026-08-30**  
Status: **mechanically complete; ready for independent exact-receiver art review; not self-accepted**  
Receiver: `building:w34313520:wall`  
Review prerequisite: `W34313520_STANDALONE_PROTOTYPE_ART_REVIEW.md` independently accepted `W34313520-MAT-PALE` and `W34313520-BAY` for bounded SSE calibration with documented limitations and no correction.

## Decision boundary

This is a detached exact-receiver proposal only. It does not alter the live receiver, generated world, runtime builder, inventory, accepted materials, collision/navigation/spray, lifecycle, or other buildings. Separate verdicts remain required for (1) this field assignment and exact scale, (2) this single placement, (3) any future live integration, (4) completed elevation, and (5) whole-building resemblance.

## Exact field proposal

| Material | Asset kind | Side / region | Exact runs | Length | Height | Projection / scale | Evidence and survey status |
|---|---|---|---|---:|---:|---|---|
| `W34313520-MAT-PALE` | `homogeneous_material_tile` | SSE / `observed_long_SSE_outer_elevation` | `6,7,8,9,10` | `68.156 m` | `11.000..11.137 m` | world wall-tangent XZ + world Y; `1 unit = 1 m`; primary `0.95 m`, secondary `0.29 m`; aperiodic, no finite repeat | Reference-observed family plus exact generated-geometry join; assignment/scale are production inference, not surveyed |

Exact run lengths are `25.045`, `31.789`, `4.494`, `3.915`, and `2.913 m`. World-position projection resolves `0.0 m` phase discontinuity at joins `6→7→8→9→10`. The `56.834 m` runs `6+7` macro evidence span exposes long-range behavior. The accepted standalone material bytes and authored parameter values are unchanged.

## Exact single-placement proposal

| Placement | Complete motif | Side / region | Run | Along-run center / anchor | Legal center envelope | Resolved wall anchor | Evidence and truth flags |
|---|---|---|---:|---|---|---|---|
| `CAL-SSE-BAY-01` | `W34313520-BAY` (`module_atlas`) | SSE / `observed_long_SSE_outer_elevation` | `7` | `15.894477 m`; fraction `0.5`; center `5.35 m` above base | `4.750..27.038953 m`; declared uncertainty `±11.144477 m` | `(-145.981995, 3.065000, 107.455994)`; module origin `(-145.953735, 8.415000, 107.508919)` | `production_inference_within_reference_observed_region`; surveyed dimensions/coordinates/count/cadence all `false`; completed elevation and whole building `false` |

Run `7` is the longest flat-base member of the observed chain (`31.789 × 11.000 m`). Its midpoint is the least presumptive deterministic exemplar anchor, and the full maximum accepted BAY width remains within that one run throughout the declared legal center domain. This is exactly one calibration exemplar, not evidence for one real bay or any cadence.

The complete BAY preserves all independently accepted standalone bytes and topology: three tiers, `15` meshes / `15` surfaces / `180` triangles, zero module-owned field/backing meshes, and zero collision/navigation/spray ownership. Local X follows run tangent, local Y is world up, and local Z follows the outward wall normal.

## Mechanical result

- Exact detached field overlay: `1` mesh / `1` surface / `10` triangles over five generated wall quads.
- One detached complete BAY: `15` meshes / `15` surfaces / `180` triangles.
- Total detached overlay: `16 / 16 / 190`; no physics or runtime ownership.
- Actual receiver children stay `2 → 2`; actual receiver accepted-material metadata stays `{}`.
- Loaded runtime stays `871 / 878 / 50,093 / 466` meshes/surfaces/triangles/collider-pairs before and after.
- Generated topology stays `729 / 736 / 48,389 / 466` meshes/surfaces/triangles/collider-pairs.

## Review packet

Evidence: `evidence/first-playable/batch-06-w34313520-exact-receiver-calibration-2026-08-30/`

Seven native Forward+/Metal views cover the exact `6→7` field join, `56.834 m` macro field span, straight and oblique complete BAY, ordinary all-run SSE, wider building context, and changed light. `capture-manifest.json` records exact geometry, resolved transform, cameras, lighting, renderer, hashes and isolation. `verification-results.txt` records the focused and regression gates.

The independent reviewer should return separate decisions for:

1. `W34313520-MAT-PALE` assignment and meter scale across exactly runs `6..10`;
2. `CAL-SSE-BAY-01` at the exact registered transform;
3. whether either is eligible for a later bounded live-integration proof.

The reviewer must not promote real coordinates/dimensions/scale/count/cadence, completed SSE elevation, cross-side transfer, other runs/facets, live attachment, lifecycle acceptance, or whole-building resemblance.

## Remaining `REFERENCE_BLOCKED` scope

All runs outside `6..10`; protected runs `20..21`; all other sides and short/re-entrant facets; inset glazed/entry wing; lower/recess field; doors/entries; occluded ground and exact endpoints; roof/massing; real material dimensions; real BAY dimensions/coordinate/count/cadence; completed elevation; cross-side transfer; and whole-building resemblance.

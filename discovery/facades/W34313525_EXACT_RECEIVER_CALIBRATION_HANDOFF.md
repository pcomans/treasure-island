# W34313525 detached exact-receiver calibration handoff

Date: 2026-08-30  
Status: `native_capture_complete_pending_independent_exact_receiver_art_review`  
Decision authority: independent art reviewer only  
Live integration: **not performed or authorized**

## Audit result

The exact generated wall record in `x_1__z_-1` confirms the complete side-bounded eligibility accepted by the standalone review. No narrowing was necessary.

- SSE central: exact ordered runs `8,9,10,11,12`, `75.310910 m`, `377.392952 m²`, exact terrain-varying heights `5.000..5.037 m`.
- NNW central: exact ordered runs `26,27`, `15.936560 m`, `80.510358 m²`, exact terrain-varying heights `5.000..5.106 m`.
- Exact total proposed field: `7` runs, `91.247470 m`, `457.903310 m²`.
- All other runs and sides remain blocked or outside evidence scope.

The target-specific exact MAT-PALE trial changes only projection from the accepted standalone proof plane to exact wall-tangent world metres. Every authored field parameter is preserved byte-for-byte from the standalone value set: primary/secondary scale `0.88/0.31 m`, roughness `0.82`, relief `0.009`, color variation `0.018`. Measured phase delta is `0.0 m` at every within-side join. No opposite-side continuity is claimed.

## Exact placement table

| Placement | Motif / kind | Side / exact run | Along-run center | Expected module origin `(x,y,z) m` | Mechanical center domain | Evidence/truth status |
|---|---|---|---:|---|---|---|
| `CAL-SSE-ROLLUP-PALE-01` | complete `module_atlas` | SSE run `9` | `13.862233 m` (`0.5`) | `(307.809835, 5.566, -70.494612)` | `2.600000..25.124466 m` | stylized/reference-derived production inference; dimensions/coordinate/count/cadence unsurveyed |
| `CAL-SSE-ROLLUP-GRAY-01` | complete `module_atlas` | SSE run `10` | `16.003442 m` (`0.5`) | `(334.134335, 5.561, -84.600612)` | `2.600000..29.406884 m` | stylized/reference-derived production inference; dimensions/coordinate/count/cadence unsurveyed |
| `CAL-NNW-PERSONNEL-01` | complete `module_atlas` | NNW run `26` | `4.269684 m` (`0.5`) | `(291.735165, 4.920, -133.563388)` | `0.825000..7.714369 m` | stylized/reference-derived production inference; dimensions/coordinate/count/cadence unsurveyed |
| `CAL-NNW-HIGH-GROUP-01` | complete opaque unresolved `module_atlas` proxy | NNW run `27` | `3.698596 m` (`0.5`) | `(284.711665, 7.408, -129.799888)` | `2.400000..4.997191 m` | window-or-grille unresolved; stylized/reference-derived production inference; dimensions/coordinate/count/cadence unsurveyed |

These are exactly four one-off calibration exemplars—one per accepted module type. Midpoints are reversible mechanical choices, not observed coordinates. No real sequence, count or cadence is inferred. PERSONNEL deliberately uses the NNW-eligible family to improve truthful multi-side coverage; that does not imply cross-side transfer beyond its explicit standalone eligibility.

ROLLUP and PERSONNEL nominal geometry is ground-adjacent. The maximum unmeasured height uncertainty could cross the base at the selected accepted nominal center; the registry explicitly records `uncertainty_height_envelope_contained: false` and makes no maximum-envelope fit claim. HIGH-GROUP's full height uncertainty is contained. This limitation is reviewable rather than hidden.

## Deterministic detached contract

- Exact field: `2` meshes / `2` surfaces / `14` triangles.
- Accepted standalone modules: `38 / 38 / 456`.
- Total detached overlay: `40 / 40 / 470`.
- Module-owned host field/backing: `0` meshes.
- Collision/navigation/spray: `0 / 0 / 0`.
- Parent: capture/test harness sibling only; never the receiver.
- Live receiver children: `2→2`; accepted-field metadata `{}`→`{}`.
- Loaded-world topology: `38 chunks / 886 meshes / 894 surfaces / 50,273 triangles / 466 static bodies / 466 shapes` before and after.
- Generated world: unchanged; `git diff -- generated` is empty.

## Evidence

Evidence root: `evidence/first-playable/batch-06-w34313525-exact-receiver-calibration-2026-08-30`

The 14-frame native set provides all five exact field joins, complete close views for the two rollups/PERSONNEL/HIGH-GROUP, ordinary SSE and NNW views, a building/multi-side context, and changed-light coverage for both sides and every material family. All PNGs are `1440×900`, captured by Godot `4.7.2-stable (official)` Forward+/Metal on Apple M1 Pro, and were individually inspected for validity. The first SSE context framing exposed an occluder; only the harness camera distances were corrected before the final deterministic set. No art, transform, registry or receiver changed.

Key hashes:

- calibration registry: `ba22916618510f610719606c1c18f84b8965bbd76fe74eddc5430745470bbddd`
- detached helper: `a9ff1f94274509cdb39c6208117c59b84ba67598ff8a59a1eb57bf30a4b03532`
- exact trial material: `d8a4500d3f3ec036b5e0b4c4273caf0644abdc3bda626fb831e2989d63559752`
- capture harness: `a963cdf2669f126bfb36b15c63ff63a792d3a618d2b2cd53fc86625230a98d1a`
- capture manifest: `2d5bb60145357287c4b45ad10bccfc74ad73e0abd658851868c42cf332e8a0ec`
- calibration contract: `ceaaff0c3d4387affa5beb04b7bb6278418e69fce1459c967acce805d5b0320c`
- evidence contract: `e6e55f493eeecdbeb4baa2589c3dc2a5e8b1a134b7fce9d5898d9dfe66d9ddd8`

## Preserved decision boundary

This handoff does not claim surveyed dimensions, scale, colors, coordinates, real counts, cadence, sequence, complete SSE/NNW elevations, cross-side motif transfer, architectural-pattern tiling, unique elevation, resolved HIGH-GROUP semantics, or whole-building resemblance. It does not authorize live attachment or lifecycle promotion.

Ready for independent detached exact-receiver art review: **yes**.  
Self-accepted: **no**.

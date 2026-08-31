# `w34313520` detached exact-receiver field and BAY calibration

Captured: **2026-08-30**  
Renderer: **Godot 4.7.2 / Forward+ / Metal / Apple M1 Pro**  
Review status: **ready for independent detached exact-receiver art review; not self-accepted**

## Bounded proposal

This package proposes the independently accepted standalone `W34313520-MAT-PALE` field on the exact generated SSE chain `6, 7, 8, 9, 10` and exactly one complete independently accepted `W34313520-BAY` exemplar. Both are detached capture/test overlays: neither is attached to the live receiver.

| Scope | Side / region | Exact ordered run(s) | Physical receiver span | Proposed anchor | Truth status |
|---|---|---|---:|---|---|
| `W34313520-MAT-PALE` | SSE / observed long outer elevation | `6,7,8,9,10` | `68.156 m`; height `11.000..11.137 m` | World-position wall-tangent projection, no per-run phase reset | Assignment and material scale are production inference, not surveyed |
| `CAL-SSE-BAY-01` / `W34313520-BAY` | SSE / same observed region | run `7` only | run `31.789 m × 11.000 m` | midpoint `15.894477 m`, fraction `0.5`; wall anchor `(-145.982, 3.065, 107.456)` | One stylized/reference-derived exemplar; dimensions, coordinate, count and cadence are not surveyed |

The BAY midpoint is deliberately located on the longest flat-base eligible run. Its full maximum accepted width remains inside run `7` throughout the mechanically eligible center domain `4.750..27.038953 m`; because the reference does not locate the bay, the declared center uncertainty is that full legal domain (`15.894477 ± 11.144477 m`), not a measured error bar. No second bay or facade cadence is inferred.

## Field scale and continuity

- One Godot unit equals one metre.
- The field shader projects world vertex XZ onto the exact wall tangent and pairs it with world Y: `vec2(dot(VERTEX.xz, wall_tangent_from_NORMAL_xz), VERTEX.y)`.
- The accepted standalone material parameters are preserved: primary scale `0.95 m`, secondary scale `0.29 m`, roughness `0.80`, relief `0.01`, color variation `0.016`.
- Runs `6..10` are collinear and use one outward normal, so shared world-position projection has `0.0 m` measured phase delta at all four run joins.
- The complete proposed field spans `68.156 m`; the dedicated macro frame shows `56.834 m` across runs `6` and `7`, well above the requested `30 m` review span.
- Run `6` follows the exact terrain-interpolated base (`2.928 → 3.065 m`), making its wall height `11.137 → 11.000 m`. Runs `7..10` are exactly `11.000 m` high.

The exact trial material is a target-specific projection adapter. It preserves the accepted standalone field's authored parameters and shader family; the accepted standalone `.tres` bytes remain unchanged.

## Complete module and isolation contract

`W34313520-BAY` remains a complete bounded `module_atlas` motif, not a seamless wall tile. It has three complete tiers and `15` render meshes / `15` surfaces / `180` triangles. It owns zero host-field or backing meshes. Nominal `6.8 × 9.4 m`, uncertainty bounds `4.8..9.5 × 7.6..10.5 m`, and the `5.35 m` center above base are reversible production assumptions, not survey measurements.

The detached helper adds one exact field mesh (`1` surface / `10` triangles) and that one accepted BAY, for `16` meshes / `16` surfaces / `190` triangles total. It is parented to the capture/test scene, never the receiver. It adds no collision, navigation or spray nodes.

The actual loaded receiver remains unchanged:

- receiver children `2 → 2`;
- accepted-material metadata `{}` → `{}`;
- loaded world `871 meshes / 878 surfaces / 50,093 triangles / 466 collider pairs` before and after overlay;
- generated world `729 records / 729 meshes / 736 surfaces / 48,389 triangles / 466 collider pairs`;
- generated chunk and manifest, builder, accepted-field helper, inventory, current live adapters and all accepted standalone assets remain byte-identical.

## Native evidence matrix

| Image | Review use |
|---|---|
| `images/01-close-field-run06-07-junction.png` | Close view of exact run `6→7` continuity with no material phase reset. |
| `images/02-macro-field-runs06-07.png` | `56.834 m` field span exposing macro behavior and one deliberately sparse exemplar. |
| `images/03-close-complete-bay.png` | Straight close view of all three complete BAY tiers on run `7`. |
| `images/04-oblique-complete-bay.png` | Oblique depth/contact view proving shallow assembly and no module backing panel. |
| `images/05-ordinary-sse-exact-scope.png` | Ordinary gameplay-height view covering every proposed run `6..10`. |
| `images/06-building-context.png` | Wider building context that keeps the single-exemplar limitation visible. |
| `images/07-changed-light-field-and-bay.png` | Alternate-light oblique field/BAY view for material response and relief. |

All seven PNGs are fresh native `1440 × 900` Forward+/Metal captures. Executor inspection was limited to evidence validity: nonblank output, target visibility, complete motif, field continuity, ordinary/context scale, changed light, and scope labels. It did not assign an art verdict.

Reproduce with:

```text
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/w34313520_exact_receiver_calibration_capture.gd
```

The capture manifest records every source hash, exact and resolved run/placement value, renderer, camera, light, image checksum and isolation count.

## Preserved blockers

- Runs `0..5` and `11..33`, protected runs `20..21`, ENE/WSW/NNW, short/re-entrant facets, the inset glazed/entry wing, lower/recess field, occluded ground, exact observed endpoints, doors, entries, roof and massing receive no field or BAY claim.
- No BAY cadence, second exemplar, real count, exact surveyed coordinate, surveyed physical scale, completed SSE elevation or cross-side transfer is proposed.
- No architectural-pattern tile, unique elevation, live attachment, lifecycle promotion or whole-building resemblance is accepted here.

This package is ready for a separate independent detached exact-receiver art review. It does not authorize live attachment.

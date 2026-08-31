# `w34313525` detached exact-receiver calibration

Captured: **2026-08-30**  
Renderer: **Godot 4.7.2 / Forward+ / Metal / Apple M1 Pro**  
Review status: **native capture complete; ready for independent detached exact-receiver art review; not self-accepted**

## Exact bounded proposal

The independently accepted standalone pale field remains a `homogeneous_material_tile`. The four opening assets remain complete reusable `module_atlas` motifs. This package is a detached capture/test sibling of the loaded world and does not attach to the live receiver.

| Scope | Side / region | Exact run(s) | Exact physical receiver | Proposal status |
|---|---|---|---:|---|
| `CAL-FIELD-SSE-PALE-01` / `W34313525-MAT-PALE` | SSE central outer service elevation | `8,9,10,11,12` | `75.310910 m`, `377.392952 m²`, heights `5.000..5.037 m` | Scale/assignment are production inference, not surveyed |
| `CAL-FIELD-NNW-PALE-01` / `W34313525-MAT-PALE` | NNW central outer service elevation | `26,27` | `15.936560 m`, `80.510358 m²`, heights `5.000..5.106 m` | Scale/assignment are production inference, not surveyed |
| `CAL-SSE-ROLLUP-PALE-01` | SSE / run `9` | run `27.724466 m`, height `5.010→5.000 m` | midpoint `13.862233 m`; complete pale rollup | One exemplar; coordinate/count/cadence unsurveyed |
| `CAL-SSE-ROLLUP-GRAY-01` | SSE / run `10` | run `32.006884 m`, height `5.000→5.020 m` | midpoint `16.003442 m`; complete gray rollup | One exemplar; coordinate/count/cadence unsurveyed |
| `CAL-NNW-PERSONNEL-01` | NNW / run `26` | run `8.539369 m`, height `5.102→5.000 m` | midpoint `4.269684 m`; complete personnel door | One exemplar; coordinate/count/cadence unsurveyed |
| `CAL-NNW-HIGH-GROUP-01` | NNW / run `27` | run `7.397191 m`, height `5.000→5.106 m` | midpoint `3.698596 m`; complete opaque proxy | Window-versus-grille unresolved; coordinate/count/cadence unsurveyed |

The module midpoints use separate eligible runs and are illustrative production inferences only. They do not encode a real sequence. Their exact wall anchors, module origins, tangents, normals, nominal envelopes, uncertainty bounds and mechanical center domains are recorded in the registry and capture manifest.

## Material and phase contract

- One Godot unit equals one metre.
- Primary/secondary field scales remain the independently accepted standalone values `0.88 m / 0.31 m`; roughness `0.82`, relief `0.009`, color variation `0.018` are unchanged.
- The target-specific exact trial uses `vec2(dot(VERTEX.xz, wall_tangent_from_NORMAL_xz), VERTEX.y)`. Generated UVs remain present for geometry audit but are ignored by the shader.
- Shared world-position projection produces measured `0.0 m` join-phase delta across SSE `8→9→10→11→12` and NNW `26→27`. No phase-continuity or cross-side-transfer claim is made between opposite sides.
- The SSE ordinary macro frame spans over `30 m`; the exact SSE scope itself is `75.310910 m`. NNW scale and its single join are reviewed separately.

## Complete modules and isolation

The four module instances are detached directly from the accepted standalone scene without changing child geometry or materials:

- `ROLLUP-PALE`: `13` meshes / `13` surfaces / `156` triangles;
- `ROLLUP-GRAY`: `13 / 13 / 156`;
- `PERSONNEL`: `5 / 5 / 60`;
- unresolved opaque `HIGH-GROUP`: `7 / 7 / 84`.

Modules total `38 / 38 / 456`. Two exact field meshes add `2 / 2 / 14`, making the detached overlay `40 meshes / 40 surfaces / 470 triangles`. Modules own zero field or backing meshes and the overlay adds zero collision, navigation or spray nodes.

The actual loaded receiver stayed unchanged at `2→2` children and `{}`→`{}` accepted-material metadata. Loaded-world topology was identical before and after the sibling overlay: `38 chunks / 886 meshes / 894 surfaces / 50,273 triangles / 466 static bodies / 466 shapes`. Generated data stayed at `729 records / 729 meshes / 736 surfaces / 48,389 triangles / 466 collider pairs`.

## Native evidence

| Image | Independent review use |
|---|---|
| `images/01-sse-field-join-08-09.png` | Exact SSE `8→9` field join. |
| `images/02-sse-field-join-09-10.png` | Exact SSE `9→10` field join. |
| `images/03-sse-field-join-10-11.png` | Exact SSE `10→11` field join. |
| `images/04-sse-field-join-11-12.png` | Exact SSE `11→12` field join. |
| `images/05-nnw-field-join-26-27.png` | Exact NNW `26→27` field join and side context. |
| `images/06-close-rollup-pale.png` | Complete pale rollup close/oblique view. |
| `images/07-close-rollup-gray.png` | Complete gray rollup close/oblique view. |
| `images/08-close-personnel.png` | Complete personnel module close/ordinary view. |
| `images/09-close-high-group.png` | Complete opaque HIGH-GROUP proxy close/oblique view. |
| `images/10-ordinary-sse-macro.png` | Both SSE rollups at ordinary scale across more than `30 m` of exact field. |
| `images/11-ordinary-nnw-macro.png` | NNW PERSONNEL/HIGH-GROUP and full two-run field context. |
| `images/12-building-multiside-context.png` | Aerial building context locating both bounded opposite-side regions without implying facade completion. |
| `images/13-changed-light-sse.png` | Changed light covering SSE field, frame, pale and gray rollup families. |
| `images/14-changed-light-nnw.png` | Changed light covering NNW field, frame, personnel and opaque proxy families. |

All 14 PNGs are fresh native `1440×900` captures. The executor inspected every final image for nonblank output, framing, exact receiver visibility, module completeness, ordinary scale, join/macro coverage and changed light. This was evidence validity inspection only, not an art verdict.

Reproduce with:

```text
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/w34313525_exact_receiver_calibration_capture.gd
```

## Preserved blockers

- No other runs or sides, protected runs `6,7,17,18,24,25,28,29`, ENE/WSW ends, short or re-entrant facets, projecting eave/rafters, deep recesses/massing, irregular repairs, ramps, bollards, utilities, signs, yard clutter or exact observed endpoints receive a claim.
- No surveyed dimensions, material scale, coordinate, count, cadence or sequence is claimed.
- The HIGH-GROUP face remains an opaque unresolved window-or-grille proxy.
- No architectural pattern tile, unique elevation, completed SSE/NNW elevation, cross-side transfer, live attachment, lifecycle promotion or whole-building acceptance is claimed.

This package is ready for a separate independent detached exact-receiver art review. It does not authorize live attachment.

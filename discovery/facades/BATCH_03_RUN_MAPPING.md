# Batch 03 observed-side to generated-run mapping

Checked: **2026-08-29**  
Scope: the three evidence-bearing Batch 03 targets; local frozen evidence only. This document records geometry/provenance and authorizes no runtime edit or unique module.

## Result

The three wall records contain **78 runs**. **30** are mapped at high confidence and **48** remain explicitly unmapped. Exact endpoint, elevation, normal, ownership and observation data are enumerated below and in the companion JSON.

| Target | High-confidence mapping | Exact safe material scope | Blocker |
|---|---|---|---|
| Treasure Island Personnel Support Detachment | PSD-OUTER-EAST `8,9,10,11,12` (partial_observed_side, 49.234 m); PSD-OUTER-NORTH `13,14,15,16,17` (partial_observed_side, 51.429 m) | No live attachment. Dark grid, glazing and varying opaque infill cannot be assigned receiver-wide without calibrated bay scale and an exact infill schedule. | Outer south runs 4..7 and west runs 0..3 are unobserved. Entrances and doors remain hidden at the base. No grid module or damaged-pane state is authorized. |
| Fire Training Facility Building 600 | B600-WSW-PALE-FIELD `0,1,2,3,4,5,6,7,8,9` (material_only_safe, 104.122 m) | Warm light cream-to-pale-gray homogeneous albedo/roughness background only on WSW runs 0..9. Coarse relief requires scale calibration; no windows, doors, red portal, lettering, opening, arch, underside, bollards or modules. | ENE runs 13..22 and NNW run 23 are unobserved. Foliage-hidden WSW window cadence and ordinary doors remain unknown. The uniform 6 m receiver is not confirmation of the low-wing/portal silhouette. |
| San Francisco Fire Station 48 | FS48-WSW-PALE-FACETS `0,1,2,3,5,6,8,9` (material_only_safe, 58.016 m); FS48-OUTER-NNW `24,25` (material_only_safe, 18.141 m) | Light muted sage-gray to pale warm-gray matte homogeneous value field only on mapped runs. Keep normals/relief flat until substrate and scale are calibrated; no high-window modules, divisions, apparatus doors, entries, signs or hidden-side propagation. | SSE and ENE sides are unobserved. NNW run 7 and runs 16..17 are reentrant/notch faces, not the outer public NNW edge. Operational openings, apparatus doors, entrances, street address, substrate and physical scale remain unknown. Default 6 m fallback massing remains unresolved and unchanged. |

## Mapping detail

### Treasure Island Personnel Support Detachment — `r133347`

Receiver `building:r133347:wall` in `x_0__z_1`; 28 runs, 250.796 m.

- `PSD-OUTER-EAST`: **partial_observed_side**, runs `8, 9, 10, 11, 12`, 49.234 m, contiguous. Runs 8..12 exactly reconstruct outer way w34313505 source edge 1. The public east viewpoint is in the outward half-plane and the ledger establishes a broad, partly occluded east elevation. Facing error 10.8–37.6°.
- `PSD-OUTER-NORTH`: **partial_observed_side**, runs `13, 14, 15, 16, 17`, 51.429 m, contiguous. Runs 13..17 exactly reconstruct outer way w34313505 source edge 2. The north/northeast viewpoint is in the outward half-plane and establishes the north elevation/east corner, with fence and vegetation occlusion. Facing error 25.8–57°.

Safe material scope: No live attachment. Dark grid, glazing and varying opaque infill cannot be assigned receiver-wide without calibrated bay scale and an exact infill schedule.

Unknowns: Outer south runs 4..7 and west runs 0..3 are unobserved. Entrances and doors remain hidden at the base. No grid module or damaged-pane state is authorized.

| Run | Owner ring / source edge | Start XZ → end XZ (m) | Bottom / top Y (m) | Length | Bearing | Outward normal / azimuth | Class |
|---:|---|---|---|---:|---:|---|---|
| 0 | outer_exterior / w34313505:3 | `221.332, 264.311` → `224, 279.287` | `4.051, 4.051` / `10.051, 10.051` | 15.212 | 169.9° | `-0.984, 0.175` / 259.9° | unmapped |
| 1 | outer_exterior / w34313505:3 | `224, 279.287` → `225.317, 286.683` | `4.051, 4.051` / `10.051, 10.051` | 7.512 | 169.9° | `-0.984, 0.175` / 259.9° | unmapped |
| 2 | outer_exterior / w34313505:3 | `225.317, 286.683` → `225.552, 288` | `4.051, 4.051` / `10.051, 10.051` | 1.338 | 169.9° | `-0.984, 0.175` / 259.9° | unmapped |
| 3 | outer_exterior / w34313505:3 | `225.552, 288` → `229.967, 312.78` | `4.051, 4.051` / `10.051, 10.051` | 25.17 | 169.9° | `-0.984, 0.175` / 259.9° | unmapped |
| 4 | outer_exterior / w34313505:0 | `229.967, 312.78` → `231.492, 312.508` | `4.051, 4.051` / `10.051, 10.051` | 1.549 | 79.9° | `0.176, 0.984` / 169.9° | unmapped |
| 5 | outer_exterior / w34313505:0 | `231.492, 312.508` → `256, 308.139` | `4.051, 3.756` / `10.051, 10.051` | 24.894 | 79.9° | `0.176, 0.984` / 169.9° | unmapped |
| 6 | outer_exterior / w34313505:0 | `256, 308.139` → `270.435, 305.565` | `3.756, 3.72` / `10.051, 10.051` | 14.663 | 79.9° | `0.176, 0.984` / 169.9° | unmapped |
| 7 | outer_exterior / w34313505:0 | `270.435, 305.565` → `280.607, 303.752` | `3.72, 3.612` / `10.051, 10.051` | 10.332 | 79.9° | `0.176, 0.984` / 169.9° | unmapped |
| 8 | outer_exterior / w34313505:1 | `280.607, 303.752` → `279.342, 296.658` | `3.612, 3.777` / `10.051, 10.051` | 7.206 | 349.9° | `0.984, -0.176` / 79.9° | partial_observed_side (`PSD-OUTER-EAST`) |
| 9 | outer_exterior / w34313505:1 | `279.342, 296.658` → `277.797, 288` | `3.777, 3.878` / `10.051, 10.051` | 8.795 | 349.9° | `0.984, -0.176` / 79.9° | partial_observed_side (`PSD-OUTER-EAST`) |
| 10 | outer_exterior / w34313505:1 | `277.797, 288` → `274.498, 269.502` | `3.878, 3.947` / `10.051, 10.051` | 18.79 | 349.9° | `0.984, -0.176` / 79.9° | partial_observed_side (`PSD-OUTER-EAST`) |
| 11 | outer_exterior / w34313505:1 | `274.498, 269.502` → `272.091, 256` | `3.947, 4.051` / `10.051, 10.051` | 13.715 | 349.9° | `0.984, -0.176` / 79.9° | partial_observed_side (`PSD-OUTER-EAST`) |
| 12 | outer_exterior / w34313505:1 | `272.091, 256` → `271.963, 255.283` | `4.051, 4.051` / `10.051, 10.051` | 0.728 | 349.9° | `0.984, -0.176` / 79.9° | partial_observed_side (`PSD-OUTER-EAST`) |
| 13 | outer_exterior / w34313505:2 | `271.963, 255.283` → `267.944, 256` | `4.051, 4.051` / `10.051, 10.051` | 4.082 | 259.9° | `-0.176, -0.984` / 349.9° | partial_observed_side (`PSD-OUTER-NORTH`) |
| 14 | outer_exterior / w34313505:2 | `267.944, 256` → `256, 258.13` | `4.051, 4.051` / `10.051, 10.051` | 12.132 | 259.9° | `-0.176, -0.984` / 349.9° | partial_observed_side (`PSD-OUTER-NORTH`) |
| 15 | outer_exterior / w34313505:2 | `256, 258.13` → `253.408, 258.592` | `4.051, 4.051` / `10.051, 10.051` | 2.633 | 259.9° | `-0.176, -0.984` / 349.9° | partial_observed_side (`PSD-OUTER-NORTH`) |
| 16 | outer_exterior / w34313505:2 | `253.408, 258.592` → `224, 263.836` | `4.051, 4.051` / `10.051, 10.051` | 29.872 | 259.9° | `-0.176, -0.984` / 349.9° | partial_observed_side (`PSD-OUTER-NORTH`) |
| 17 | outer_exterior / w34313505:2 | `224, 263.836` → `221.332, 264.311` | `4.051, 4.051` / `10.051, 10.051` | 2.71 | 259.9° | `-0.176, -0.984` / 349.9° | partial_observed_side (`PSD-OUTER-NORTH`) |
| 18 | inner_courtyard / w34313506:3 | `243.86, 281.588` → `256, 279.643` | `4.051, 4.051` / `10.051, 10.051` | 12.295 | 80.9° | `0.158, 0.987` / 170.9° | unmapped |
| 19 | inner_courtyard / w34313506:3 | `256, 279.643` → `260.119, 278.983` | `4.051, 4.022` / `10.051, 10.051` | 4.172 | 80.9° | `0.158, 0.987` / 170.9° | unmapped |
| 20 | inner_courtyard / w34313506:0 | `260.119, 278.983` → `260.796, 283.204` | `4.022, 3.967` / `10.051, 10.051` | 4.275 | 170.9° | `-0.987, 0.159` / 260.8° | unmapped |
| 21 | inner_courtyard / w34313506:0 | `260.796, 283.204` → `261.429, 287.143` | `3.967, 3.953` / `10.051, 10.051` | 3.99 | 170.9° | `-0.987, 0.159` / 260.8° | unmapped |
| 22 | inner_courtyard / w34313506:1 | `261.429, 287.143` → `256.08, 288` | `3.953, 3.974` / `10.051, 10.051` | 5.417 | 260.9° | `-0.158, -0.987` / 350.9° | unmapped |
| 23 | inner_courtyard / w34313506:1 | `256.08, 288` → `256, 288.013` | `3.974, 3.974` / `10.051, 10.051` | 0.081 | 260.8° | `-0.158, -0.987` / 350.9° | unmapped |
| 24 | inner_courtyard / w34313506:1 | `256, 288.013` → `255.985, 288.015` | `3.974, 3.974` / `10.051, 10.051` | 0.015 | 262.4° | `-0.158, -0.987` / 350.9° | unmapped |
| 25 | inner_courtyard / w34313506:1 | `255.985, 288.015` → `245.17, 289.748` | `3.974, 4.051` / `10.051, 10.051` | 10.953 | 260.9° | `-0.158, -0.987` / 350.9° | unmapped |
| 26 | inner_courtyard / w34313506:2 | `245.17, 289.748` → `244.89, 288` | `4.051, 4.002` / `10.051, 10.051` | 1.77 | 350.9° | `0.987, -0.159` / 80.8° | unmapped |
| 27 | inner_courtyard / w34313506:2 | `244.89, 288` → `243.86, 281.588` | `4.002, 4.051` / `10.051, 10.051` | 6.494 | 350.9° | `0.987, -0.159` / 80.8° | unmapped |

### Fire Training Facility Building 600 — `w34313548`

Receiver `building:w34313548:wall` in `x_1__z_-2`; 24 runs, 243.359 m.

- `B600-WSW-PALE-FIELD`: **material_only_safe**, runs `0, 1, 2, 3, 4, 5, 6, 7, 8, 9`, 104.122 m, contiguous. Runs 0..9 exactly reconstruct WSW source edge 3. Both observations identify this long side; foliage blocks a module schedule but the pale background field is consistent across the chain. Facing error 1.5–54.3°.
- `B600-PORTAL`: **unmapped/blocked**. Candidate SSE side runs `10, 11, 12` are not portal ownership. The recorded portal is visible from B600-SV01, but the actual viewpoint lies behind the generated SSE wall plane. The portal may project, straddle the corner or depend on absent geometry, and foundation splits do not isolate its footprint. Exact portal run ownership is therefore not proven.

Safe material scope: Warm light cream-to-pale-gray homogeneous albedo/roughness background only on WSW runs 0..9. Coarse relief requires scale calibration; no windows, doors, red portal, lettering, opening, arch, underside, bollards or modules.

Unknowns: ENE runs 13..22 and NNW run 23 are unobserved. Foliage-hidden WSW window cadence and ordinary doors remain unknown. The uniform 6 m receiver is not confirmation of the low-wing/portal silhouette.

| Run | Owner ring / source edge | Start XZ → end XZ (m) | Bottom / top Y (m) | Length | Bearing | Outward normal / azimuth | Class |
|---:|---|---|---|---:|---:|---|---|
| 0 | outer_exterior / w34313548:3 | `268.366, -374.918` → `271.94, -367.94` | `3.66, 3.725` / `10.064, 10.064` | 7.84 | 152.9° | `-0.89, 0.456` / 242.9° | material_only_safe (`B600-WSW-PALE-FIELD`) |
| 1 | outer_exterior / w34313548:3 | `271.94, -367.94` → `280.105, -352` | `3.725, 3.96` / `10.064, 10.064` | 17.91 | 152.9° | `-0.89, 0.456` / 242.9° | material_only_safe (`B600-WSW-PALE-FIELD`) |
| 2 | outer_exterior / w34313548:3 | `280.105, -352` → `282.779, -346.779` | `3.96, 4.06` / `10.064, 10.064` | 5.866 | 152.9° | `-0.89, 0.456` / 242.9° | material_only_safe (`B600-WSW-PALE-FIELD`) |
| 3 | outer_exterior / w34313548:3 | `282.779, -346.779` → `288, -336.585` | `4.06, 4.057` / `10.064, 10.064` | 11.453 | 152.9° | `-0.89, 0.456` / 242.9° | material_only_safe (`B600-WSW-PALE-FIELD`) |
| 4 | outer_exterior / w34313548:3 | `288, -336.585` → `293.617, -325.617` | `4.057, 4.012` / `10.064, 10.064` | 12.323 | 152.9° | `-0.89, 0.456` / 242.9° | material_only_safe (`B600-WSW-PALE-FIELD`) |
| 5 | outer_exterior / w34313548:3 | `293.617, -325.617` → `296.495, -320` | `4.012, 3.988` / `10.064, 10.064` | 6.311 | 152.9° | `-0.89, 0.456` / 242.9° | material_only_safe (`B600-WSW-PALE-FIELD`) |
| 6 | outer_exterior / w34313548:3 | `296.495, -320` → `304.456, -304.456` | `3.988, 3.769` / `10.064, 10.064` | 17.464 | 152.9° | `-0.89, 0.456` / 242.9° | material_only_safe (`B600-WSW-PALE-FIELD`) |
| 7 | outer_exterior / w34313548:3 | `304.456, -304.456` → `312.884, -288` | `3.769, 4.064` / `10.064, 10.064` | 18.489 | 152.9° | `-0.89, 0.456` / 242.9° | material_only_safe (`B600-WSW-PALE-FIELD`) |
| 8 | outer_exterior / w34313548:3 | `312.884, -288` → `315.294, -283.294` | `4.064, 4.064` / `10.064, 10.064` | 5.287 | 152.9° | `-0.89, 0.456` / 242.9° | material_only_safe (`B600-WSW-PALE-FIELD`) |
| 9 | outer_exterior / w34313548:3 | `315.294, -283.294` → `315.832, -282.245` | `4.064, 4.064` / `10.064, 10.064` | 1.179 | 152.8° | `-0.89, 0.456` / 242.9° | material_only_safe (`B600-WSW-PALE-FIELD`) |
| 10 | outer_exterior / w34313548:0 | `315.832, -282.245` → `320, -284.38` | `4.064, 4.064` / `10.064, 10.064` | 4.683 | 62.9° | `0.456, 0.89` / 152.9° | unmapped |
| 11 | outer_exterior / w34313548:0 | `320, -284.38` → `327.067, -288` | `4.064, 4.064` / `10.064, 10.064` | 7.94 | 62.9° | `0.456, 0.89` / 152.9° | unmapped |
| 12 | outer_exterior / w34313548:0 | `327.067, -288` → `331.457, -290.249` | `4.064, 4.064` / `10.064, 10.064` | 4.933 | 62.9° | `0.456, 0.89` / 152.9° | unmapped |
| 13 | outer_exterior / w34313548:1 | `331.457, -290.249` → `328.339, -296.339` | `4.064, 4.064` / `10.064, 10.064` | 6.842 | 332.9° | `0.89, -0.456` / 62.9° | unmapped |
| 14 | outer_exterior / w34313548:1 | `328.339, -296.339` → `320, -312.623` | `4.064, 4.064` / `10.064, 10.064` | 18.295 | 332.9° | `0.89, -0.456` / 62.9° | unmapped |
| 15 | outer_exterior / w34313548:1 | `320, -312.623` → `317.502, -317.502` | `4.064, 3.961` / `10.064, 10.064` | 5.481 | 332.9° | `0.89, -0.456` / 62.9° | unmapped |
| 16 | outer_exterior / w34313548:1 | `317.502, -317.502` → `316.222, -320` | `3.961, 3.996` / `10.064, 10.064` | 2.807 | 332.9° | `0.89, -0.456` / 62.9° | unmapped |
| 17 | outer_exterior / w34313548:1 | `316.222, -320` → `306.664, -338.664` | `3.996, 4.064` / `10.064, 10.064` | 20.969 | 332.9° | `0.89, -0.456` / 62.9° | unmapped |
| 18 | outer_exterior / w34313548:1 | `306.664, -338.664` → `299.835, -352` | `4.064, 4.064` / `10.064, 10.064` | 14.983 | 332.9° | `0.89, -0.456` / 62.9° | unmapped |
| 19 | outer_exterior / w34313548:1 | `299.835, -352` → `295.827, -359.827` | `4.064, 4.064` / `10.064, 10.064` | 8.794 | 332.9° | `0.89, -0.456` / 62.9° | unmapped |
| 20 | outer_exterior / w34313548:1 | `295.827, -359.827` → `288, -375.112` | `4.064, 4.025` / `10.064, 10.064` | 17.172 | 332.9° | `0.89, -0.456` / 62.9° | unmapped |
| 21 | outer_exterior / w34313548:1 | `288, -375.112` → `284.99, -380.99` | `4.025, 3.938` / `10.064, 10.064` | 6.604 | 332.9° | `0.89, -0.456` / 62.9° | unmapped |
| 22 | outer_exterior / w34313548:1 | `284.99, -380.99` → `284.001, -382.922` | `3.938, 3.92` / `10.064, 10.064` | 2.17 | 332.9° | `0.89, -0.456` / 62.9° | unmapped |
| 23 | outer_exterior / w34313548:2 | `284.001, -382.922` → `268.366, -374.918` | `3.92, 3.66` / `10.064, 10.064` | 17.565 | 242.9° | `-0.456, -0.89` / 332.9° | unmapped |

### San Francisco Fire Station 48 — `w764313741`

Receiver `building:w764313741:wall` in `x_0__z_-2`; 26 runs, 187.957 m.

- `FS48-WSW-PALE-FACETS`: **material_only_safe**, runs `0, 1, 2, 3, 5, 6, 8, 9`, 58.016 m, direct facets inside an explicit contiguous envelope. Three WSW source edges 0, 2 and 4 form the stepped public west-side facets recorded from Avenue I. Embedded return runs 4 and 7 remain unmapped. Occlusion supports only a restrained pale homogeneous value field. Facing error 56.6–79.5°.
- `FS48-OUTER-NNW`: **material_only_safe**, runs `24, 25`, 18.141 m, contiguous. Runs 24..25 exactly reconstruct outer NNW source edge 11 at the WSW/NNW public corner. Other same-normal reentrant edges are topologically separate and remain unmapped. Facing error 27.2–36.4°.

Safe material scope: Light muted sage-gray to pale warm-gray matte homogeneous value field only on mapped runs. Keep normals/relief flat until substrate and scale are calibrated; no high-window modules, divisions, apparatus doors, entries, signs or hidden-side propagation.

Unknowns: SSE and ENE sides are unobserved. NNW run 7 and runs 16..17 are reentrant/notch faces, not the outer public NNW edge. Operational openings, apparatus doors, entrances, street address, substrate and physical scale remain unknown. Default 6 m fallback massing remains unresolved and unchanged.

| Run | Owner ring / source edge | Start XZ → end XZ (m) | Bottom / top Y (m) | Length | Bearing | Outward normal / azimuth | Class |
|---:|---|---|---|---:|---:|---|---|
| 0 | outer_exterior / w764313741:0 | `125.223, -364.588` → `128, -359.294` | `3.448, 3.442` / `9.501, 9.501` | 5.978 | 152.3° | `-0.886, 0.465` / 242.3° | material_only_safe (`FS48-WSW-PALE-FACETS`) |
| 1 | outer_exterior / w764313741:0 | `128, -359.294` → `130.509, -354.509` | `3.442, 3.431` / `9.501, 9.501` | 5.403 | 152.3° | `-0.886, 0.465` / 242.3° | material_only_safe (`FS48-WSW-PALE-FACETS`) |
| 2 | outer_exterior / w764313741:0 | `130.509, -354.509` → `131.826, -352` | `3.431, 3.444` / `9.501, 9.501` | 2.834 | 152.3° | `-0.886, 0.465` / 242.3° | material_only_safe (`FS48-WSW-PALE-FACETS`) |
| 3 | outer_exterior / w764313741:0 | `131.826, -352` → `140.013, -336.391` | `3.444, 3.336` / `9.501, 9.501` | 17.626 | 152.3° | `-0.886, 0.465` / 242.3° | material_only_safe (`FS48-WSW-PALE-FACETS`) |
| 4 | outer_exterior / w764313741:1 | `140.013, -336.391` → `146.872, -339.998` | `3.336, 3.44` / `9.501, 9.501` | 7.75 | 62.3° | `0.465, 0.885` / 152.3° | unmapped |
| 5 | outer_exterior / w764313741:2 | `146.872, -339.998` → `147.259, -339.259` | `3.44, 3.435` / `9.501, 9.501` | 0.834 | 152.4° | `-0.886, 0.465` / 242.3° | material_only_safe (`FS48-WSW-PALE-FACETS`) |
| 6 | outer_exterior / w764313741:2 | `147.259, -339.259` → `150.873, -332.372` | `3.435, 3.49` / `9.501, 9.501` | 7.778 | 152.3° | `-0.886, 0.465` / 242.3° | material_only_safe (`FS48-WSW-PALE-FACETS`) |
| 7 | outer_exterior / w764313741:3 | `150.873, -332.372` → `143.583, -328.543` | `3.49, 3.346` / `9.501, 9.501` | 8.234 | 242.3° | `-0.465, -0.885` / 332.3° | unmapped |
| 8 | outer_exterior / w764313741:4 | `143.583, -328.543` → `148.066, -320` | `3.346, 3.414` / `9.501, 9.501` | 9.648 | 152.3° | `-0.886, 0.465` / 242.3° | material_only_safe (`FS48-WSW-PALE-FACETS`) |
| 9 | outer_exterior / w764313741:4 | `148.066, -320` → `151.743, -312.991` | `3.414, 3.501` / `9.501, 9.501` | 7.915 | 152.3° | `-0.886, 0.465` / 242.3° | material_only_safe (`FS48-WSW-PALE-FACETS`) |
| 10 | outer_exterior / w764313741:5 | `151.743, -312.991` → `154.369, -314.369` | `3.501, 3.501` / `9.501, 9.501` | 2.966 | 62.3° | `0.465, 0.886` / 152.3° | unmapped |
| 11 | outer_exterior / w764313741:5 | `154.369, -314.369` → `160, -317.323` | `3.501, 3.501` / `9.501, 9.501` | 6.359 | 62.3° | `0.465, 0.886` / 152.3° | unmapped |
| 12 | outer_exterior / w764313741:5 | `160, -317.323` → `165.104, -320` | `3.501, 3.501` / `9.501, 9.501` | 5.763 | 62.3° | `0.465, 0.886` / 152.3° | unmapped |
| 13 | outer_exterior / w764313741:5 | `165.104, -320` → `172.328, -323.789` | `3.501, 3.501` / `9.501, 9.501` | 8.157 | 62.3° | `0.465, 0.886` / 152.3° | unmapped |
| 14 | outer_exterior / w764313741:6 | `172.328, -323.789` → `169.389, -329.389` | `3.501, 3.501` / `9.501, 9.501` | 6.324 | 332.3° | `0.885, -0.465` / 62.3° | unmapped |
| 15 | outer_exterior / w764313741:6 | `169.389, -329.389` → `163.904, -339.842` | `3.501, 3.501` / `9.501, 9.501` | 11.805 | 332.3° | `0.885, -0.465` / 62.3° | unmapped |
| 16 | outer_exterior / w764313741:7 | `163.904, -339.842` → `160, -337.795` | `3.501, 3.501` / `9.501, 9.501` | 4.408 | 242.3° | `-0.464, -0.886` / 332.4° | unmapped |
| 17 | outer_exterior / w764313741:7 | `160, -337.795` → `155.41, -335.389` | `3.501, 3.501` / `9.501, 9.501` | 5.182 | 242.3° | `-0.464, -0.886` / 332.4° | unmapped |
| 18 | outer_exterior / w764313741:8 | `155.41, -335.389` → `151.84, -342.179` | `3.501, 3.501` / `9.501, 9.501` | 7.671 | 332.3° | `0.885, -0.465` / 62.3° | unmapped |
| 19 | outer_exterior / w764313741:9 | `151.84, -342.179` → `156.245, -344.495` | `3.501, 3.501` / `9.501, 9.501` | 4.977 | 62.3° | `0.465, 0.885` / 152.3° | unmapped |
| 20 | outer_exterior / w764313741:10 | `156.245, -344.495` → `154.955, -346.955` | `3.501, 3.501` / `9.501, 9.501` | 2.778 | 332.3° | `0.886, -0.464` / 62.4° | unmapped |
| 21 | outer_exterior / w764313741:10 | `154.955, -346.955` → `152.309, -352` | `3.501, 3.501` / `9.501, 9.501` | 5.697 | 332.3° | `0.886, -0.464` / 62.4° | unmapped |
| 22 | outer_exterior / w764313741:10 | `152.309, -352` → `143.946, -367.946` | `3.501, 3.501` / `9.501, 9.501` | 18.006 | 332.3° | `0.886, -0.464` / 62.4° | unmapped |
| 23 | outer_exterior / w764313741:10 | `143.946, -367.946` → `141.288, -373.015` | `3.501, 3.501` / `9.501, 9.501` | 5.724 | 332.3° | `0.886, -0.464` / 62.4° | unmapped |
| 24 | outer_exterior / w764313741:11 | `141.288, -373.015` → `128, -366.045` | `3.501, 3.473` / `9.501, 9.501` | 15.005 | 242.3° | `-0.465, -0.886` / 332.3° | material_only_safe (`FS48-OUTER-NNW`) |
| 25 | outer_exterior / w764313741:11 | `128, -366.045` → `125.223, -364.588` | `3.473, 3.448` / `9.501, 9.501` | 3.136 | 242.3° | `-0.465, -0.886` / 332.3° | material_only_safe (`FS48-OUTER-NNW`) |

## Hard exclusions

- Personnel Support inner courtyard runs `18..27` are unmapped and hard-protected from all exterior material/module propagation.
- Building 600's red portal is not assigned to runs `10..12`; the actual viewpoint is behind the generated SSE wall plane and the portal likely depends on projecting/straddling geometry. No portal module or massing inference is authorized.
- Fire Station 48 same-normal reentrant NNW runs `7,16,17` are not the public outer NNW edge. Apparatus doors, lower openings, SSE/ENE sides, street address and real massing remain unknown.
- No unique module is authorized. Window/grid cadence and physical scale remain missing.

## Validation

The local validator compared all 78 run records with their frozen chunk vertices, endpoint elevations and normals; reconstructed every frozen OSM source edge from its run chain; checked partitions, mapping uniqueness, contiguity/envelopes, the 85° facing tolerance, source run/triangle counts, the courtyard exclusion and all preserved blockers.

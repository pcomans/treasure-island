# Batch 04 observed-side to generated-run mapping

Checked: **2026-08-29**  
Scope: seven evidence-bearing Batch 04 targets; frozen local evidence only. This is geometry/provenance, not a runtime edit, asset approval, or unique-module authorization.

## Result

The seven wall records contain **204 runs**. **53** have an observation-to-run mapping (44 high-confidence and 9 medium-confidence provenance-only); **151** remain explicitly unmapped. Only **36** runs across three targets are candidate live homogeneous-material scopes after independent review.

| Target | Exact mapped observation scope | Exact safe live scope | Principal blocker |
|---|---|---|---|
| US Dept of Labor Job Corps Dormitory Building 369 | D369-OUTERMOST-WSW-FIELD `0,1,2,3,4,5` (material_only_safe, high) | `0,1,2,3,4,5` — Smooth light warm-gray/off-white homogeneous albedo and restrained roughness on runs 0..5 only. | The five visible facade tiers conflict with the frozen fallback 6 m receiver and remain unresolved; mapping is not a story-count or height decision. |
| 449 Avenue H | 449H-HISTORICAL-ENE-LONG `10,11,12,13,14,15,16` (partial_observed_side, high_geometry_medium-high_historical_identity) | None — historical_only_no_current_attachment | September 2025 shows a cleared redevelopment lot; historical facade evidence must not be represented as current. |
| 850 Avenue H | 850H-EAST-END-CANDIDATE `12,13` (partial_observed_side, medium_not_runtime_safe) | None — blocked_no_high-confidence_material_scope | The west/Avenue H contributor panorama is excluded and supports no claim. |
| 810 Avenue D | 810D-HISTORICAL-SW-FRONT `0` (full_observed_side, high_geometry_and_historical_identity) | None — historical_only_no_current_attachment | March 2025 completely encloses the site; current survival versus removal is unknown. |
| Bldg 461 | B461-DISTANT-SE-EAST-CHAIN `4,5,6,7,8,9,10` (partial_observed_side, medium_not_runtime_safe) | None — blocked_no_high-confidence_material_scope | Identity and all facade readings remain medium because the only official observation is distant and Google displayed 1298 Avenue M. |
| 1318 Gateview Avenue | 1318G-FRONT-PRIMARY-FACETS `0,1,4,5,7,8,10,12,15,16,24` (full_observed_side, high); 1318G-REAR-ENE `18,19,20,21,22` (partial_observed_side, high); 1318G-OUTER-NNW-END `23` (partial_observed_side, high) | `0,1,4,5,7,8,10,12,15,16,18,19,20,21,22,23,24` — Flat cool gray-blue homogeneous albedo/roughness on mapped primary front facets, rear edge and outer end only. | Exact unit widths, alternating entry/window schedule, canopy breaks and physical siding scale remain unknown; geometry alone cannot establish modules. |
| 1212 Mariner Drive | 1212M-FRONT-PRIMARY-FACETS `14,15,16,17,19,20,21,22,24,25,26,27` (full_observed_side, high); 1212M-OUTER-ENE-END `13` (partial_observed_side, high) | `13,14,15,16,17,19,20,21,22,24,25,26,27` — Flat cool gray-blue homogeneous albedo/roughness on mapped public-front primary facets and outer ENE end only. | The recorded rear-long-side description cannot be reconciled to generated SSE rear edges 12, 14 and 16 from the actual viewpoint; those runs remain unmapped. |

## Mapping detail

### US Dept of Labor Job Corps Dormitory Building 369 — `w291189926`

Receiver `building:w291189926:wall` in `x_0__z_1`; 72 runs / 487.83 m; generated base/top 3.39/9.39 m. Temporal state: **current_observation_with_unresolved_massing_conflict**.

Recorded observations:

- `D369-SV01` — official_panorama; September 2025; panorama `NztWn9fwLieghDTyI_iEyQ`; viewpoint WGS84 `37.819319, -122.3712241` / world XZ `-20.585, 494.542`; heading 56.0°; Seven Seas Avenue southwest of the footprint, looking northeast; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8193228,-122.3711959&heading=56&pitch=0&fov=75).
- `D369-NO01` — no_official_coverage; no official capture date; panorama `none`; viewpoint WGS84 `37.8200821, -122.3699753` / world XZ `89.224, 409.595`; heading 234.0°; requested east-side view; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8200821,-122.3699753&heading=234&pitch=0&fov=75).

Mapped scopes:

- `D369-OUTERMOST-WSW-FIELD` — **material_only_safe** / high; runs `0, 1, 2, 3, 4, 5`; source edges `5`; 49.124 m; contiguous. Runs 0..5 exactly reconstruct source edge 5, the outermost WSW long face nearest the public southwest viewpoint. Parallel WSW chains at source edges 13 and 21 are recessed/interior wings and are not allowed to inherit this observation. Facing error 5.5–52.7°; panorama-heading error 22.8–22.8°.

**Safe runtime scope:** Smooth light warm-gray/off-white homogeneous albedo and restrained roughness on runs 0..5 only.

**Preserved unknowns:**

- The five visible facade tiers conflict with the frozen fallback 6 m receiver and remain unresolved; mapping is not a story-count or height decision.
- Parallel WSW source-edge chains 13 and 21, all recess/courtyard faces, remaining long side, ends and exact bay schedule remain unmapped.
- The observed southeast/end corner does not pass the generated outward-half-plane test for source edge 0 from the recorded viewpoint, so its blue-gray field is not attached.

**Explicit blocked chains:**

- Source edges `13,21`, runs `34,35,36,37,38,39,52,53,54,55,56`: parallel recessed/interior WSW chains; geometry alone cannot prove observation ownership.
- Source edges `0`, runs `11,12`: reported end corner, but recorded viewpoint lies behind generated source-edge-0 wall plane.

| Run | Owner ring / source edge | Start XZ → end XZ (m) | Bottom / top Y (m) | Length | Bearing | Outward normal / azimuth | Class |
|---:|---|---|---|---:|---:|---|---|
| 0 | outer_exterior / w291189926:5 | `-13.084, 447.399` → `-12.765, 448.0` | `3.39, 3.39` / `9.39, 9.39` | 0.68 | 152.0° | `-0.883, 0.469` / 242.0° | material_only_safe (`D369-OUTERMOST-WSW-FIELD`) |
| 1 | outer_exterior / w291189926:5 | `-12.765, 448.0` → `-8.339, 456.339` | `3.39, 3.39` / `9.39, 9.39` | 9.441 | 152.0° | `-0.883, 0.469` / 242.0° | material_only_safe (`D369-OUTERMOST-WSW-FIELD`) |
| 2 | outer_exterior / w291189926:5 | `-8.339, 456.339` → `0.0, 472.052` | `3.39, 3.184` / `9.39, 9.39` | 17.789 | 152.0° | `-0.883, 0.469` / 242.0° | material_only_safe (`D369-OUTERMOST-WSW-FIELD`) |
| 3 | outer_exterior / w291189926:5 | `0.0, 472.052` → `2.756, 477.244` | `3.184, 3.141` / `9.39, 9.39` | 5.878 | 152.0° | `-0.883, 0.469` / 242.0° | material_only_safe (`D369-OUTERMOST-WSW-FIELD`) |
| 4 | outer_exterior / w291189926:5 | `2.756, 477.244` → `4.218, 480.0` | `3.141, 3.143` / `9.39, 9.39` | 3.12 | 152.1° | `-0.883, 0.469` / 242.0° | material_only_safe (`D369-OUTERMOST-WSW-FIELD`) |
| 5 | outer_exterior / w291189926:5 | `4.218, 480.0` → `9.945, 490.791` | `3.143, 3.39` / `9.39, 9.39` | 12.217 | 152.0° | `-0.883, 0.469` / 242.0° | material_only_safe (`D369-OUTERMOST-WSW-FIELD`) |
| 6 | outer_exterior / w291189926:4 | `9.945, 490.791` → `8.178, 491.726` | `3.39, 3.39` / `9.39, 9.39` | 1.999 | 242.1° | `-0.468, -0.884` / 332.1° | unmapped |
| 7 | outer_exterior / w291189926:3 | `8.178, 491.726` → `11.229, 497.526` | `3.39, 3.39` / `9.39, 9.39` | 6.554 | 152.3° | `-0.885, 0.466` / 242.2° | unmapped |
| 8 | outer_exterior / w291189926:2 | `11.229, 497.526` → `12.97, 496.591` | `3.39, 3.39` / `9.39, 9.39` | 1.976 | 61.8° | `0.473, 0.881` / 151.8° | unmapped |
| 9 | outer_exterior / w291189926:1 | `12.97, 496.591` → `13.825, 498.175` | `3.39, 3.39` / `9.39, 9.39` | 1.8 | 151.6° | `-0.88, 0.475` / 241.6° | unmapped |
| 10 | outer_exterior / w291189926:1 | `13.825, 498.175` → `16.109, 502.402` | `3.39, 3.39` / `9.39, 9.39` | 4.805 | 151.6° | `-0.88, 0.475` / 241.6° | unmapped |
| 11 | outer_exterior / w291189926:0 | `16.109, 502.402` → `32.0, 493.965` | `3.39, 3.346` / `9.39, 9.39` | 17.992 | 62.0° | `0.469, 0.883` / 152.0° | unmapped |
| 12 | outer_exterior / w291189926:0 | `32.0, 493.965` → `50.349, 484.223` | `3.346, 3.39` / `9.39, 9.39` | 20.775 | 62.0° | `0.469, 0.883` / 152.0° | unmapped |
| 13 | outer_exterior / w291189926:33 | `50.349, 484.223` → `58.304, 480.0` | `3.39, 3.39` / `9.39, 9.39` | 9.006 | 62.0° | `0.469, 0.883` / 152.0° | unmapped |
| 14 | outer_exterior / w291189926:33 | `58.304, 480.0` → `64.0, 476.976` | `3.39, 3.39` / `9.39, 9.39` | 6.449 | 62.0° | `0.469, 0.883` / 152.0° | unmapped |
| 15 | outer_exterior / w291189926:33 | `64.0, 476.976` → `65.614, 476.119` | `3.39, 3.39` / `9.39, 9.39` | 1.827 | 62.0° | `0.469, 0.883` / 152.0° | unmapped |
| 16 | outer_exterior / w291189926:32 | `65.614, 476.119` → `70.447, 473.553` | `3.39, 3.39` / `9.39, 9.39` | 5.472 | 62.0° | `0.469, 0.883` / 152.0° | unmapped |
| 17 | outer_exterior / w291189926:32 | `70.447, 473.553` → `89.074, 463.662` | `3.39, 3.39` / `9.39, 9.39` | 21.09 | 62.0° | `0.469, 0.883` / 152.0° | unmapped |
| 18 | outer_exterior / w291189926:31 | `89.074, 463.662` → `86.498, 458.809` | `3.39, 3.39` / `9.39, 9.39` | 5.494 | 332.0° | `0.883, -0.469` / 62.0° | unmapped |
| 19 | outer_exterior / w291189926:30 | `86.498, 458.809` → `88.353, 457.818` | `3.39, 3.39` / `9.39, 9.39` | 2.103 | 61.9° | `0.471, 0.882` / 151.9° | unmapped |
| 20 | outer_exterior / w291189926:29 | `88.353, 457.818` → `87.599, 456.401` | `3.39, 3.39` / `9.39, 9.39` | 1.605 | 332.0° | `0.883, -0.47` / 62.0° | unmapped |
| 21 | outer_exterior / w291189926:29 | `87.599, 456.401` → `85.144, 451.785` | `3.39, 3.36` / `9.39, 9.39` | 5.228 | 332.0° | `0.883, -0.47` / 62.0° | unmapped |
| 22 | outer_exterior / w291189926:28 | `85.144, 451.785` → `83.359, 452.731` | `3.36, 3.387` / `9.39, 9.39` | 2.02 | 242.1° | `-0.468, -0.884` / 332.1° | unmapped |
| 23 | outer_exterior / w291189926:27 | `83.359, 452.731` → `80.848, 448.0` | `3.387, 3.263` / `9.39, 9.39` | 5.356 | 332.0° | `0.883, -0.469` / 62.0° | unmapped |
| 24 | outer_exterior / w291189926:27 | `80.848, 448.0` → `75.007, 436.993` | `3.263, 3.181` / `9.39, 9.39` | 12.461 | 332.0° | `0.883, -0.469` / 62.0° | unmapped |
| 25 | outer_exterior / w291189926:27 | `75.007, 436.993` → `64.0, 416.253` | `3.181, 3.39` / `9.39, 9.39` | 23.48 | 332.0° | `0.883, -0.469` / 62.0° | unmapped |
| 26 | outer_exterior / w291189926:27 | `64.0, 416.253` → `63.912, 416.088` | `3.39, 3.39` / `9.39, 9.39` | 0.187 | 331.9° | `0.883, -0.469` / 62.0° | unmapped |
| 27 | outer_exterior / w291189926:27 | `63.912, 416.088` → `63.866, 416.0` | `3.39, 3.39` / `9.39, 9.39` | 0.099 | 332.4° | `0.883, -0.469` / 62.0° | unmapped |
| 28 | outer_exterior / w291189926:27 | `63.866, 416.0` → `59.828, 408.392` | `3.39, 3.336` / `9.39, 9.39` | 8.613 | 332.0° | `0.883, -0.469` / 62.0° | unmapped |
| 29 | outer_exterior / w291189926:26 | `59.828, 408.392` → `55.019, 410.941` | `3.336, 3.353` / `9.39, 9.39` | 5.443 | 242.1° | `-0.468, -0.884` / 332.1° | unmapped |
| 30 | outer_exterior / w291189926:25 | `55.019, 410.941` → `54.148, 409.294` | `3.353, 3.333` / `9.39, 9.39` | 1.863 | 332.1° | `0.884, -0.467` / 62.2° | unmapped |
| 31 | outer_exterior / w291189926:24 | `54.148, 409.294` → `48.828, 412.121` | `3.333, 3.352` / `9.39, 9.39` | 6.024 | 242.0° | `-0.469, -0.883` / 332.0° | unmapped |
| 32 | outer_exterior / w291189926:23 | `48.828, 412.121` → `49.752, 413.858` | `3.352, 3.373` / `9.39, 9.39` | 1.967 | 152.0° | `-0.883, 0.469` / 242.0° | unmapped |
| 33 | outer_exterior / w291189926:22 | `49.752, 413.858` → `48.468, 414.537` | `3.373, 3.378` / `9.39, 9.39` | 1.452 | 242.1° | `-0.468, -0.884` / 332.1° | unmapped |
| 34 | outer_exterior / w291189926:21 | `48.468, 414.537` → `49.244, 416.0` | `3.378, 3.39` / `9.39, 9.39` | 1.656 | 152.1° | `-0.883, 0.469` / 242.0° | unmapped |
| 35 | outer_exterior / w291189926:21 | `49.244, 416.0` → `54.36, 425.64` | `3.39, 3.39` / `9.39, 9.39` | 10.913 | 152.0° | `-0.883, 0.469` / 242.0° | unmapped |
| 36 | outer_exterior / w291189926:21 | `54.36, 425.64` → `64.0, 443.805` | `3.39, 3.3` / `9.39, 9.39` | 20.564 | 152.0° | `-0.883, 0.469` / 242.0° | unmapped |
| 37 | outer_exterior / w291189926:21 | `64.0, 443.805` → `65.454, 446.546` | `3.3, 3.267` / `9.39, 9.39` | 3.103 | 152.1° | `-0.883, 0.469` / 242.0° | unmapped |
| 38 | outer_exterior / w291189926:21 | `65.454, 446.546` → `66.226, 448.0` | `3.267, 3.278` / `9.39, 9.39` | 1.646 | 152.0° | `-0.883, 0.469` / 242.0° | unmapped |
| 39 | outer_exterior / w291189926:21 | `66.226, 448.0` → `71.638, 458.197` | `3.278, 3.39` / `9.39, 9.39` | 11.544 | 152.0° | `-0.883, 0.469` / 242.0° | unmapped |
| 40 | outer_exterior / w291189926:20 | `71.638, 458.197` → `64.0, 462.253` | `3.39, 3.39` / `9.39, 9.39` | 8.648 | 242.0° | `-0.469, -0.883` / 332.0° | unmapped |
| 41 | outer_exterior / w291189926:20 | `64.0, 462.253` → `51.976, 468.638` | `3.39, 3.39` / `9.39, 9.39` | 13.614 | 242.0° | `-0.469, -0.883` / 332.0° | unmapped |
| 42 | outer_exterior / w291189926:19 | `51.976, 468.638` → `48.989, 463.011` | `3.39, 3.315` / `9.39, 9.39` | 6.371 | 332.0° | `0.883, -0.469` / 62.0° | unmapped |
| 43 | outer_exterior / w291189926:19 | `48.989, 463.011` → `41.022, 448.0` | `3.315, 3.39` / `9.39, 9.39` | 16.994 | 332.0° | `0.883, -0.469` / 62.0° | unmapped |
| 44 | outer_exterior / w291189926:19 | `41.022, 448.0` → `37.893, 442.107` | `3.39, 3.39` / `9.39, 9.39` | 6.672 | 332.0° | `0.883, -0.469` / 62.0° | unmapped |
| 45 | outer_exterior / w291189926:19 | `37.893, 442.107` → `33.423, 433.684` | `3.39, 3.39` / `9.39, 9.39` | 9.536 | 332.0° | `0.883, -0.469` / 62.0° | unmapped |
| 46 | outer_exterior / w291189926:18 | `33.423, 433.684` → `32.0, 434.441` | `3.39, 3.39` / `9.39, 9.39` | 1.612 | 242.0° | `-0.47, -0.883` / 332.0° | unmapped |
| 47 | outer_exterior / w291189926:18 | `32.0, 434.441` → `28.446, 436.333` | `3.39, 3.39` / `9.39, 9.39` | 4.026 | 242.0° | `-0.47, -0.883` / 332.0° | unmapped |
| 48 | outer_exterior / w291189926:17 | `28.446, 436.333` → `27.505, 434.563` | `3.39, 3.39` / `9.39, 9.39` | 2.005 | 332.0° | `0.883, -0.469` / 62.0° | unmapped |
| 49 | outer_exterior / w291189926:16 | `27.505, 434.563` → `22.009, 437.48` | `3.39, 3.39` / `9.39, 9.39` | 6.222 | 242.0° | `-0.469, -0.883` / 332.0° | unmapped |
| 50 | outer_exterior / w291189926:15 | `22.009, 437.48` → `22.906, 439.161` | `3.39, 3.39` / `9.39, 9.39` | 1.905 | 151.9° | `-0.882, 0.471` / 241.9° | unmapped |
| 51 | outer_exterior / w291189926:14 | `22.906, 439.161` → `21.763, 439.773` | `3.39, 3.39` / `9.39, 9.39` | 1.297 | 241.8° | `-0.472, -0.882` / 331.8° | unmapped |
| 52 | outer_exterior / w291189926:13 | `21.763, 439.773` → `26.13, 448.0` | `3.39, 3.39` / `9.39, 9.39` | 9.314 | 152.0° | `-0.883, 0.469` / 242.0° | unmapped |
| 53 | outer_exterior / w291189926:13 | `26.13, 448.0` → `28.165, 451.835` | `3.39, 3.39` / `9.39, 9.39` | 4.341 | 152.0° | `-0.883, 0.469` / 242.0° | unmapped |
| 54 | outer_exterior / w291189926:13 | `28.165, 451.835` → `32.0, 459.06` | `3.39, 3.39` / `9.39, 9.39` | 8.18 | 152.0° | `-0.883, 0.469` / 242.0° | unmapped |
| 55 | outer_exterior / w291189926:13 | `32.0, 459.06` → `39.261, 472.739` | `3.39, 3.338` / `9.39, 9.39` | 15.487 | 152.0° | `-0.883, 0.469` / 242.0° | unmapped |
| 56 | outer_exterior / w291189926:13 | `39.261, 472.739` → `40.387, 474.861` | `3.338, 3.39` / `9.39, 9.39` | 2.402 | 152.0° | `-0.883, 0.469` / 242.0° | unmapped |
| 57 | outer_exterior / w291189926:12 | `40.387, 474.861` → `33.462, 478.538` | `3.39, 3.352` / `9.39, 9.39` | 7.841 | 242.0° | `-0.469, -0.883` / 332.0° | unmapped |
| 58 | outer_exterior / w291189926:12 | `33.462, 478.538` → `32.0, 479.314` | `3.352, 3.357` / `9.39, 9.39` | 1.655 | 242.0° | `-0.469, -0.883` / 332.0° | unmapped |
| 59 | outer_exterior / w291189926:12 | `32.0, 479.314` → `30.708, 480.0` | `3.357, 3.345` / `9.39, 9.39` | 1.463 | 242.0° | `-0.469, -0.883` / 332.0° | unmapped |
| 60 | outer_exterior / w291189926:12 | `30.708, 480.0` → `21.622, 484.824` | `3.345, 3.39` / `9.39, 9.39` | 10.287 | 242.0° | `-0.469, -0.883` / 332.0° | unmapped |
| 61 | outer_exterior / w291189926:11 | `21.622, 484.824` → `19.061, 480.0` | `3.39, 3.256` / `9.39, 9.39` | 5.462 | 332.0° | `0.883, -0.469` / 62.0° | unmapped |
| 62 | outer_exterior / w291189926:11 | `19.061, 480.0` → `12.45, 467.55` | `3.256, 3.246` / `9.39, 9.39` | 14.096 | 332.0° | `0.883, -0.469` / 62.0° | unmapped |
| 63 | outer_exterior / w291189926:11 | `12.45, 467.55` → `2.07, 448.0` | `3.246, 3.39` / `9.39, 9.39` | 22.135 | 332.0° | `0.883, -0.469` / 62.0° | unmapped |
| 64 | outer_exterior / w291189926:11 | `2.07, 448.0` → `1.352, 446.648` | `3.39, 3.39` / `9.39, 9.39` | 1.531 | 332.0° | `0.883, -0.469` / 62.0° | unmapped |
| 65 | outer_exterior / w291189926:11 | `1.352, 446.648` → `0.0, 444.102` | `3.39, 3.39` / `9.39, 9.39` | 2.883 | 332.0° | `0.883, -0.469` / 62.0° | unmapped |
| 66 | outer_exterior / w291189926:11 | `0.0, 444.102` → `-1.53, 441.22` | `3.39, 3.39` / `9.39, 9.39` | 3.263 | 332.0° | `0.883, -0.469` / 62.0° | unmapped |
| 67 | outer_exterior / w291189926:10 | `-1.53, 441.22` → `-6.366, 443.781` | `3.39, 3.39` / `9.39, 9.39` | 5.472 | 242.1° | `-0.468, -0.884` / 332.1° | unmapped |
| 68 | outer_exterior / w291189926:9 | `-6.366, 443.781` → `-7.246, 442.122` | `3.39, 3.39` / `9.39, 9.39` | 1.878 | 332.1° | `0.884, -0.468` / 62.1° | unmapped |
| 69 | outer_exterior / w291189926:8 | `-7.246, 442.122` → `-12.75, 445.05` | `3.39, 3.39` / `9.39, 9.39` | 6.234 | 242.0° | `-0.47, -0.883` / 332.0° | unmapped |
| 70 | outer_exterior / w291189926:7 | `-12.75, 445.05` → `-11.853, 446.742` | `3.39, 3.39` / `9.39, 9.39` | 1.915 | 152.1° | `-0.884, 0.468` / 242.1° | unmapped |
| 71 | outer_exterior / w291189926:6 | `-11.853, 446.742` → `-13.084, 447.399` | `3.39, 3.39` / `9.39, 9.39` | 1.395 | 241.9° | `-0.471, -0.882` / 331.9° | unmapped |

### 449 Avenue H — `w34313512`

Receiver `building:w34313512:wall` in `x_0__z_0`; 20 runs / 226.094 m; generated base/top 3.619/13.619 m. Temporal state: **historical_only_may_2011;september_2025_cleared_lot**.

Recorded observations:

- `449H-SV01-current` — official_panorama_current_site; September 2025; panorama `tUuvbI3y3fgy-R_XCvHdDQ`; viewpoint WGS84 `37.8231121, -122.3685646` / world XZ `213.269, 72.296`; heading 253.0°; northeast/east of frozen footprint, looking west-southwest; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.823153,-122.3685837&heading=253&pitch=0&fov=75).
- `449H-SV02-historical` — official_panorama_historical; May 2011; panorama `d4T0RdF4AE250u-CoH7tYw`; viewpoint WGS84 `37.8231534, -122.3685542` / world XZ `214.183, 67.699`; heading 253.0°; east/northeast of footprint, looking west-southwest; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.823153,-122.3685837&heading=253&pitch=0&fov=75).

Mapped scopes:

- `449H-HISTORICAL-ENE-LONG` — **partial_observed_side** / high_geometry_medium-high_historical_identity; runs `10, 11, 12, 13, 14, 15, 16`; source edges `1`; 78.909 m; contiguous. Runs 10..16 exactly reconstruct the only ENE long source edge and face the May 2011 east/northeast viewpoint. Current September 2025 evidence is a cleared lot and supplies no facade. Facing error 5.9–71.9°; panorama-heading error 22.4–22.4°.

**Safe runtime scope:** No live/current facade attachment. Runs 10..16 are a May 2011 historical-only geometry scope if an explicit frozen-era representation is later approved.

**Preserved unknowns:**

- September 2025 shows a cleared redevelopment lot; historical facade evidence must not be represented as current.
- Google address labels differ from frozen 449 Avenue H; address reconciliation remains medium.
- Opposite long side, ends, historical module scale/cadence and current replacement are unknown.

| Run | Owner ring / source edge | Start XZ → end XZ (m) | Bottom / top Y (m) | Length | Bearing | Outward normal / azimuth | Class |
|---:|---|---|---|---:|---:|---|---|
| 0 | outer_exterior / w34313512:3 | `155.858, 56.278` → `159.991, 64.0` | `3.619, 3.537` / `13.619, 13.619` | 8.758 | 151.8° | `-0.882, 0.472` / 241.8° | unmapped |
| 1 | outer_exterior / w34313512:3 | `159.991, 64.0` → `159.994, 64.006` | `3.537, 3.536` / `13.619, 13.619` | 0.007 | 153.4° | `-0.882, 0.472` / 241.8° | unmapped |
| 2 | outer_exterior / w34313512:3 | `159.994, 64.006` → `160.0, 64.017` | `3.536, 3.535` / `13.619, 13.619` | 0.013 | 151.4° | `-0.882, 0.472` / 241.8° | unmapped |
| 3 | outer_exterior / w34313512:3 | `160.0, 64.017` → `171.149, 84.851` | `3.535, 3.458` / `13.619, 13.619` | 23.63 | 151.8° | `-0.882, 0.472` / 241.8° | unmapped |
| 4 | outer_exterior / w34313512:3 | `171.149, 84.851` → `177.114, 96.0` | `3.458, 3.465` / `13.619, 13.619` | 12.644 | 151.9° | `-0.882, 0.472` / 241.8° | unmapped |
| 5 | outer_exterior / w34313512:3 | `177.114, 96.0` → `182.303, 105.697` | `3.465, 3.619` / `13.619, 13.619` | 10.998 | 151.8° | `-0.882, 0.472` / 241.8° | unmapped |
| 6 | outer_exterior / w34313512:3 | `182.303, 105.697` → `192.0, 123.818` | `3.619, 3.274` / `13.619, 13.619` | 20.552 | 151.8° | `-0.882, 0.472` / 241.8° | unmapped |
| 7 | outer_exterior / w34313512:3 | `192.0, 123.818` → `193.088, 125.852` | `3.274, 3.244` / `13.619, 13.619` | 2.307 | 151.9° | `-0.882, 0.472` / 241.8° | unmapped |
| 8 | outer_exterior / w34313512:0 | `193.088, 125.852` → `195.367, 124.633` | `3.244, 3.241` / `13.619, 13.619` | 2.585 | 61.9° | `0.472, 0.882` / 151.8° | unmapped |
| 9 | outer_exterior / w34313512:0 | `195.367, 124.633` → `223.187, 109.744` | `3.241, 3.353` / `13.619, 13.619` | 31.554 | 61.8° | `0.472, 0.882` / 151.8° | unmapped |
| 10 | outer_exterior / w34313512:1 | `223.187, 109.744` → `218.68, 101.32` | `3.353, 3.323` / `13.619, 13.619` | 9.554 | 331.9° | `0.882, -0.472` / 61.8° | partial_observed_side (`449H-HISTORICAL-ENE-LONG`) |
| 11 | outer_exterior / w34313512:1 | `218.68, 101.32` → `215.833, 96.0` | `3.323, 3.401` / `13.619, 13.619` | 6.034 | 331.8° | `0.882, -0.472` / 61.8° | partial_observed_side (`449H-HISTORICAL-ENE-LONG`) |
| 12 | outer_exterior / w34313512:1 | `215.833, 96.0` → `207.525, 80.475` | `3.401, 3.465` / `13.619, 13.619` | 17.608 | 331.8° | `0.882, -0.472` / 61.8° | partial_observed_side (`449H-HISTORICAL-ENE-LONG`) |
| 13 | outer_exterior / w34313512:1 | `207.525, 80.475` → `198.709, 64.0` | `3.465, 3.611` / `13.619, 13.619` | 18.685 | 331.8° | `0.882, -0.472` / 61.8° | partial_observed_side (`449H-HISTORICAL-ENE-LONG`) |
| 14 | outer_exterior / w34313512:1 | `198.709, 64.0` → `196.37, 59.63` | `3.611, 3.619` / `13.619, 13.619` | 4.957 | 331.8° | `0.882, -0.472` / 61.8° | partial_observed_side (`449H-HISTORICAL-ENE-LONG`) |
| 15 | outer_exterior / w34313512:1 | `196.37, 59.63` → `192.0, 51.462` | `3.619, 3.594` / `13.619, 13.619` | 9.264 | 331.9° | `0.882, -0.472` / 61.8° | partial_observed_side (`449H-HISTORICAL-ENE-LONG`) |
| 16 | outer_exterior / w34313512:1 | `192.0, 51.462` → `185.957, 40.17` | `3.594, 3.49` / `13.619, 13.619` | 12.807 | 331.8° | `0.882, -0.472` / 61.8° | partial_observed_side (`449H-HISTORICAL-ENE-LONG`) |
| 17 | outer_exterior / w34313512:2 | `185.957, 40.17` → `181.382, 42.618` | `3.49, 3.486` / `13.619, 13.619` | 5.189 | 241.8° | `-0.472, -0.882` / 331.8° | unmapped |
| 18 | outer_exterior / w34313512:2 | `181.382, 42.618` → `160.0, 54.061` | `3.486, 3.619` / `13.619, 13.619` | 24.251 | 241.8° | `-0.472, -0.882` / 331.8° | unmapped |
| 19 | outer_exterior / w34313512:2 | `160.0, 54.061` → `155.858, 56.278` | `3.619, 3.619` / `13.619, 13.619` | 4.698 | 241.8° | `-0.472, -0.882` / 331.8° | unmapped |

### 850 Avenue H — `w34313546`

Receiver `building:w34313546:wall` in `x_0__z_-2`; 25 runs / 237.592 m; generated base/top 3.247/7.247 m. Temporal state: **current_official_observations_medium_identity**.

Recorded observations:

- `850H-EX01` — excluded_contributor_panorama; no official capture date; panorama `none`; viewpoint WGS84 `37.8268578, -122.3710464` / world XZ `-4.959, -344.673`; heading 78.0°; west/Avenue H request; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8268578,-122.3710464&heading=78&pitch=0&fov=75).
- `850H-SV01` — official_panorama; September 2025; panorama `U1HtZQlUKomn07I4TT93ug`; viewpoint WGS84 `37.8271222, -122.3698007` / world XZ `104.577, -374.106`; heading 240.0°; east of footprint, looking southwest toward east/end area; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8271144,-122.369789&heading=240&pitch=0&fov=75).
- `850H-SV02` — official_panorama_container_occluded; March 2025; panorama `QO4Mk2OE0ky1D7lGPsSciQ`; viewpoint WGS84 `37.827312, -122.3701921` / world XZ `70.16, -395.234`; heading 205.0°; north of footprint, looking south-southwest toward north side; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8273062,-122.3701219&heading=205&pitch=0&fov=75).

Mapped scopes:

- `850H-EAST-END-CANDIDATE` — **partial_observed_side** / medium_not_runtime_safe; runs `12, 13`; source edges `5`; 11.167 m; contiguous. Runs 12..13 reconstruct source edge 5 and face the recorded east viewpoint. Other ENE-oriented edges are short notch/return facets and are not assigned. Medium target ownership prevents live authorization. Facing error 6.1–28.4°; panorama-heading error 15.0–15.0°.

**Safe runtime scope:** No live material or module attachment.

**Preserved unknowns:**

- The west/Avenue H contributor panorama is excluded and supports no claim.
- North source-edge chain 10 / runs 19..22 is container-blocked; its facade remains unknown and unmapped.
- Exact target ownership of the exposed east/end wall, long sides, window pairs, door and repair patch remains medium or unknown.

**Explicit blocked chains:**

- Source edges `10`, runs `19,20,21,22`: north side is almost completely blocked by containers.
- Source edges `3,7,9`, runs `8,9,16,18`: same/near-normal short facets and notches; geometry alone cannot assign the exposed wall.

| Run | Owner ring / source edge | Start XZ → end XZ (m) | Bottom / top Y (m) | Length | Bearing | Outward normal / azimuth | Class |
|---:|---|---|---|---:|---:|---|---|
| 0 | outer_exterior / w34313546:12 | `16.267, -338.439` → `16.971, -336.971` | `3.122, 3.131` / `7.247, 7.247` | 1.628 | 154.4° | `-0.902, 0.432` / 244.4° | unmapped |
| 1 | outer_exterior / w34313546:12 | `16.971, -336.971` → `22.616, -325.181` | `3.131, 3.247` / `7.247, 7.247` | 13.072 | 154.4° | `-0.902, 0.432` / 244.4° | unmapped |
| 2 | outer_exterior / w34313546:0 | `22.616, -325.181` → `32.0, -330.348` | `3.247, 3.247` / `7.247, 7.247` | 10.712 | 61.2° | `0.482, 0.876` / 151.2° | unmapped |
| 3 | outer_exterior / w34313546:0 | `32.0, -330.348` → `38.83, -334.109` | `3.247, 3.247` / `7.247, 7.247` | 7.797 | 61.2° | `0.482, 0.876` / 151.2° | unmapped |
| 4 | outer_exterior / w34313546:1 | `38.83, -334.109` → `44.649, -332.649` | `3.247, 3.247` / `7.247, 7.247` | 5.999 | 104.1° | `-0.243, 0.97` / 194.1° | unmapped |
| 5 | outer_exterior / w34313546:1 | `44.649, -332.649` → `52.803, -330.602` | `3.247, 3.247` / `7.247, 7.247` | 8.407 | 104.1° | `-0.243, 0.97` / 194.1° | unmapped |
| 6 | outer_exterior / w34313546:2 | `52.803, -330.602` → `64.0, -336.364` | `3.247, 3.247` / `7.247, 7.247` | 12.593 | 62.8° | `0.458, 0.889` / 152.7° | unmapped |
| 7 | outer_exterior / w34313546:2 | `64.0, -336.364` → `86.7, -348.046` | `3.247, 3.247` / `7.247, 7.247` | 25.53 | 62.8° | `0.458, 0.889` / 152.7° | unmapped |
| 8 | outer_exterior / w34313546:3 | `86.7, -348.046` → `84.665, -352.0` | `3.247, 3.231` / `7.247, 7.247` | 4.447 | 332.8° | `0.889, -0.458` / 62.7° | unmapped |
| 9 | outer_exterior / w34313546:3 | `84.665, -352.0` → `81.6, -357.953` | `3.231, 3.186` / `7.247, 7.247` | 6.696 | 332.8° | `0.889, -0.458` / 62.7° | unmapped |
| 10 | outer_exterior / w34313546:4 | `81.6, -357.953` → `96.0, -365.356` | `3.186, 3.078` / `7.247, 7.247` | 16.191 | 62.8° | `0.457, 0.889` / 152.8° | unmapped |
| 11 | outer_exterior / w34313546:4 | `96.0, -365.356` → `98.685, -366.736` | `3.078, 3.12` / `7.247, 7.247` | 3.019 | 62.8° | `0.457, 0.889` / 152.8° | unmapped |
| 12 | outer_exterior / w34313546:5 | `98.685, -366.736` → `96.0, -371.956` | `3.12, 3.018` / `7.247, 7.247` | 5.87 | 332.8° | `0.889, -0.457` / 62.8° | partial_observed_side (`850H-EAST-END-CANDIDATE`) |
| 13 | outer_exterior / w34313546:5 | `96.0, -371.956` → `93.577, -376.666` | `3.018, 2.982` / `7.247, 7.247` | 5.297 | 332.8° | `0.889, -0.457` / 62.8° | partial_observed_side (`850H-EAST-END-CANDIDATE`) |
| 14 | outer_exterior / w34313546:6 | `93.577, -376.666` → `83.467, -371.467` | `2.982, 3.058` / `7.247, 7.247` | 11.368 | 242.8° | `-0.457, -0.889` / 332.8° | unmapped |
| 15 | outer_exterior / w34313546:6 | `83.467, -371.467` → `76.694, -367.983` | `3.058, 3.091` / `7.247, 7.247` | 7.617 | 242.8° | `-0.457, -0.889` / 332.8° | unmapped |
| 16 | outer_exterior / w34313546:7 | `76.694, -367.983` → `71.567, -377.946` | `3.091, 2.936` / `7.247, 7.247` | 11.205 | 332.8° | `0.889, -0.458` / 62.7° | unmapped |
| 17 | outer_exterior / w34313546:8 | `71.567, -377.946` → `68.147, -376.188` | `2.936, 2.953` / `7.247, 7.247` | 3.845 | 242.8° | `-0.457, -0.889` / 332.8° | unmapped |
| 18 | outer_exterior / w34313546:9 | `68.147, -376.188` → `65.403, -381.531` | `2.953, 2.87` / `7.247, 7.247` | 6.006 | 332.8° | `0.89, -0.457` / 62.8° | unmapped |
| 19 | outer_exterior / w34313546:10 | `65.403, -381.531` → `64.0, -380.812` | `2.87, 2.877` / `7.247, 7.247` | 1.577 | 242.9° | `-0.456, -0.89` / 332.9° | unmapped |
| 20 | outer_exterior / w34313546:10 | `64.0, -380.812` → `57.458, -377.458` | `2.877, 2.9` / `7.247, 7.247` | 7.352 | 242.9° | `-0.456, -0.89` / 332.9° | unmapped |
| 21 | outer_exterior / w34313546:10 | `57.458, -377.458` → `32.0, -364.409` | `2.9, 3.154` / `7.247, 7.247` | 28.607 | 242.9° | `-0.456, -0.89` / 332.9° | unmapped |
| 22 | outer_exterior / w34313546:10 | `32.0, -364.409` → `22.273, -359.423` | `3.154, 3.102` / `7.247, 7.247` | 10.93 | 242.9° | `-0.456, -0.89` / 332.9° | unmapped |
| 23 | outer_exterior / w34313546:11 | `22.273, -359.423` → `20.149, -352.0` | `3.102, 3.098` / `7.247, 7.247` | 7.721 | 196.0° | `-0.961, -0.275` / 286.0° | unmapped |
| 24 | outer_exterior / w34313546:11 | `20.149, -352.0` → `16.267, -338.439` | `3.098, 3.122` / `7.247, 7.247` | 14.106 | 196.0° | `-0.961, -0.275` / 286.0° | unmapped |

### 810 Avenue D — `w96698660`

Receiver `building:w96698660:wall` in `x_-1__z_-1`; 6 runs / 51.994 m; generated base/top 3.298/7.298 m. Temporal state: **historical_only_may_2011;march_2025_fully_enclosed**.

Recorded observations:

- `810D-SV01-current` — official_panorama_current_site_occluded; March 2025; panorama `le1q7oLYgiyaWBAv2NBF2w`; viewpoint WGS84 `37.8242274, -122.3727145` / world XZ `-151.638, -51.858`; heading 33.0°; southwest of footprint, looking northeast; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8242283,-122.3727535&heading=33&pitch=0&fov=75).
- `810D-SV02-historical` — official_panorama_historical; May 2011; panorama `IYcYMdJYTtaGjJVxo7eraA`; viewpoint WGS84 `37.8241971, -122.3727396` / world XZ `-153.845, -48.485`; heading 33.0°; southwest of footprint, looking northeast; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8242283,-122.3727535&heading=33&pitch=0&fov=75).

Mapped scopes:

- `810D-HISTORICAL-SW-FRONT` — **full_observed_side** / high_geometry_and_historical_identity; runs `0`; source edges `3`; 18.667 m; contiguous. Run 0 exactly reconstructs source edge 3 and faces the historical southwest viewpoint. The oblique southeast-side report cannot be assigned to generated edge 0 because the viewpoint is behind that wall plane. Facing error 10.3–10.3°; panorama-heading error 4.3–4.3°.

**Safe runtime scope:** No live/current facade attachment. Run 0 is a May 2011 historical-only scope if a frozen-era representation is later approved.

**Preserved unknowns:**

- March 2025 completely encloses the site; current survival versus removal is unknown.
- The observed oblique southeast long side does not pass the generated source-edge-0 outward-half-plane test from the recorded viewpoint and remains unmapped.
- Rear, opposite long side, module dimensions and course scale remain unknown.

**Explicit blocked chains:**

- Source edges `0`, runs `1`: historically reported oblique side, but viewpoint lies behind generated wall plane; no safe exact ownership.

| Run | Owner ring / source edge | Start XZ → end XZ (m) | Bottom / top Y (m) | Length | Bearing | Outward normal / azimuth | Class |
|---:|---|---|---|---:|---:|---|---|
| 0 | outer_exterior / w96698660:3 | `-151.418, -72.029` → `-133.7, -66.152` | `3.246, 3.298` / `7.298, 7.298` | 18.667 | 108.4° | `-0.315, 0.949` / 198.4° | full_observed_side (`810D-HISTORICAL-SW-FRONT`) |
| 1 | outer_exterior / w96698660:0 | `-133.7, -66.152` → `-131.396, -73.12` | `3.298, 3.298` / `7.298, 7.298` | 7.339 | 18.3° | `0.949, 0.314` / 108.3° | unmapped |
| 2 | outer_exterior / w96698660:1 | `-131.396, -73.12` → `-146.031, -77.969` | `3.298, 3.259` / `7.298, 7.298` | 15.417 | 288.3° | `0.314, -0.949` / 18.3° | unmapped |
| 3 | outer_exterior / w96698660:1 | `-146.031, -77.969` → `-149.105, -78.987` | `3.259, 3.26` / `7.298, 7.298` | 3.238 | 288.3° | `0.314, -0.949` / 18.3° | unmapped |
| 4 | outer_exterior / w96698660:2 | `-149.105, -78.987` → `-151.142, -72.858` | `3.26, 3.246` / `7.298, 7.298` | 6.459 | 198.4° | `-0.949, -0.315` / 288.4° | unmapped |
| 5 | outer_exterior / w96698660:2 | `-151.142, -72.858` → `-151.418, -72.029` | `3.246, 3.246` / `7.298, 7.298` | 0.874 | 198.4° | `-0.949, -0.315` / 288.4° | unmapped |

### Bldg 461 — `w34313569`

Receiver `building:w34313569:wall` in `x_-1__z_-4`; 27 runs / 207.182 m; generated base/top 3.525/11.525 m. Temporal state: **november_2025_distant_medium_identity**.

Recorded observations:

- `B461-EX01` — excluded_contributor_panorama; no official capture date; panorama `none`; viewpoint WGS84 `37.8313388, -122.3718321` / world XZ `-74.047, -843.496`; heading 34.0°; closer northwest-side request; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8313388,-122.3718321&heading=34&pitch=0&fov=75).
- `B461-EX02` — excluded_contributor_panorama; no official capture date; panorama `none`; viewpoint WGS84 `37.83121, -122.3721663` / world XZ `-103.434, -829.158`; heading 52.0°; closer west-side request; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.83121,-122.3721663&heading=52&pitch=0&fov=75).
- `B461-SV01` — official_panorama_distant; November 2025; panorama `JMpuxlpS4Re0BFnlc7D1pA`; viewpoint WGS84 `37.8310653, -122.370838` / world XZ `13.366, -813.05`; heading 312.0°; east/southeast of footprint, looking northwest; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8310739,-122.370928&heading=312&pitch=0&fov=75).

Mapped scopes:

- `B461-DISTANT-SE-EAST-CHAIN` — **partial_observed_side** / medium_not_runtime_safe; runs `4, 5, 6, 7, 8, 9, 10`; source edges `11,0`; 86.02 m; contiguous. Runs 4..7 reconstruct source edge 11 and runs 8..10 reconstruct adjoining source edge 0. Both chains face the east/southeast viewpoint and match the ledger long-elevation/end description, but distance and identity remain medium. Facing error 38.7–78.6°; panorama-heading error 2.3–2.3°.

**Safe runtime scope:** No live material or module attachment.

**Preserved unknowns:**

- Identity and all facade readings remain medium because the only official observation is distant and Google displayed 1298 Avenue M.
- Two closer contributor panoramas are excluded and support no claim.
- Short same-facing source edge 5 / runs 20..21 is topologically separate and remains unmapped; opposite sides, base, entrances and substrate remain unknown.

**Explicit blocked chains:**

- Source edges `5`, runs `20,21`: short same-facing/reentrant chain; geometry does not prove it belongs to the distant observed elevation.

| Run | Owner ring / source edge | Start XZ → end XZ (m) | Bottom / top Y (m) | Length | Bearing | Outward normal / azimuth | Class |
|---:|---|---|---|---:|---:|---|---|
| 0 | outer_exterior / w34313569:9 | `-78.655, -862.598` → `-70.528, -857.472` | `3.223, 3.438` / `11.525, 11.525` | 9.609 | 122.2° | `-0.533, 0.846` / 212.2° | unmapped |
| 1 | outer_exterior / w34313569:9 | `-70.528, -857.472` → `-66.476, -854.917` | `3.438, 3.384` / `11.525, 11.525` | 4.79 | 122.2° | `-0.533, 0.846` / 212.2° | unmapped |
| 2 | outer_exterior / w34313569:10 | `-66.476, -854.917` → `-64.0, -852.148` | `3.384, 3.322` / `11.525, 11.525` | 3.715 | 138.2° | `-0.745, 0.667` / 228.2° | unmapped |
| 3 | outer_exterior / w34313569:10 | `-64.0, -852.148` → `-63.838, -851.967` | `3.322, 3.318` / `11.525, 11.525` | 0.243 | 138.2° | `-0.745, 0.667` / 228.2° | unmapped |
| 4 | outer_exterior / w34313569:11 | `-63.838, -851.967` → `-48.55, -847.45` | `3.318, 3.197` / `11.525, 11.525` | 15.941 | 106.5° | `-0.283, 0.959` / 196.4° | partial_observed_side (`B461-DISTANT-SE-EAST-CHAIN`) |
| 5 | outer_exterior / w34313569:11 | `-48.55, -847.45` → `-32.0, -842.561` | `3.197, 3.128` / `11.525, 11.525` | 17.257 | 106.5° | `-0.283, 0.959` / 196.4° | partial_observed_side (`B461-DISTANT-SE-EAST-CHAIN`) |
| 6 | outer_exterior / w34313569:11 | `-32.0, -842.561` → `-23.848, -840.152` | `3.128, 2.889` / `11.525, 11.525` | 8.5 | 106.5° | `-0.283, 0.959` / 196.4° | partial_observed_side (`B461-DISTANT-SE-EAST-CHAIN`) |
| 7 | outer_exterior / w34313569:11 | `-23.848, -840.152` → `-13.612, -837.128` | `2.889, 2.791` / `11.525, 11.525` | 10.673 | 106.5° | `-0.283, 0.959` / 196.4° | partial_observed_side (`B461-DISTANT-SE-EAST-CHAIN`) |
| 8 | outer_exterior / w34313569:0 | `-13.612, -837.128` → `-9.008, -854.992` | `2.791, 2.85` / `11.525, 11.525` | 18.448 | 14.5° | `0.968, 0.25` / 104.5° | partial_observed_side (`B461-DISTANT-SE-EAST-CHAIN`) |
| 9 | outer_exterior / w34313569:0 | `-9.008, -854.992` → `-6.686, -864.0` | `2.85, 2.983` / `11.525, 11.525` | 9.302 | 14.5° | `0.968, 0.25` / 104.5° | partial_observed_side (`B461-DISTANT-SE-EAST-CHAIN`) |
| 10 | outer_exterior / w34313569:0 | `-6.686, -864.0` → `-5.214, -869.711` | `2.983, 2.967` / `11.525, 11.525` | 5.898 | 14.5° | `0.968, 0.25` / 104.5° | partial_observed_side (`B461-DISTANT-SE-EAST-CHAIN`) |
| 11 | outer_exterior / w34313569:1 | `-5.214, -869.711` → `-17.993, -873.145` | `2.967, 3.276` / `11.525, 11.525` | 13.232 | 285.0° | `0.26, -0.966` / 15.1° | unmapped |
| 12 | outer_exterior / w34313569:1 | `-17.993, -873.145` → `-32.0, -876.91` | `3.276, 3.225` / `11.525, 11.525` | 14.504 | 285.0° | `0.26, -0.966` / 15.1° | unmapped |
| 13 | outer_exterior / w34313569:1 | `-32.0, -876.91` → `-34.087, -877.47` | `3.225, 3.189` / `11.525, 11.525` | 2.161 | 285.0° | `0.26, -0.966` / 15.1° | unmapped |
| 14 | outer_exterior / w34313569:1 | `-34.087, -877.47` → `-49.187, -881.528` | `3.189, 3.087` / `11.525, 11.525` | 15.636 | 285.0° | `0.26, -0.966` / 15.1° | unmapped |
| 15 | outer_exterior / w34313569:1 | `-49.187, -881.528` → `-54.218, -882.88` | `3.087, 3.119` / `11.525, 11.525` | 5.209 | 285.0° | `0.26, -0.966` / 15.1° | unmapped |
| 16 | outer_exterior / w34313569:2 | `-54.218, -882.88` → `-56.153, -875.867` | `3.119, 3.279` / `11.525, 11.525` | 7.275 | 195.4° | `-0.964, -0.266` / 285.4° | unmapped |
| 17 | outer_exterior / w34313569:3 | `-56.153, -875.867` → `-64.0, -878.286` | `3.279, 3.323` / `11.525, 11.525` | 8.211 | 287.1° | `0.295, -0.956` / 17.1° | unmapped |
| 18 | outer_exterior / w34313569:3 | `-64.0, -878.286` → `-64.243, -878.361` | `3.323, 3.315` / `11.525, 11.525` | 0.254 | 287.2° | `0.295, -0.956` / 17.1° | unmapped |
| 19 | outer_exterior / w34313569:4 | `-64.243, -878.361` → `-65.324, -875.11` | `3.315, 3.351` / `11.525, 11.525` | 3.426 | 198.4° | `-0.949, -0.316` / 288.4° | unmapped |
| 20 | outer_exterior / w34313569:5 | `-65.324, -875.11` → `-64.0, -874.638` | `3.351, 3.394` / `11.525, 11.525` | 1.406 | 109.6° | `-0.336, 0.942` / 199.6° | unmapped |
| 21 | outer_exterior / w34313569:5 | `-64.0, -874.638` → `-59.741, -873.118` | `3.394, 3.374` / `11.525, 11.525` | 4.522 | 109.6° | `-0.336, 0.942` / 199.6° | unmapped |
| 22 | outer_exterior / w34313569:6 | `-59.741, -873.118` → `-60.769, -869.745` | `3.374, 3.452` / `11.525, 11.525` | 3.526 | 196.9° | `-0.956, -0.292` / 287.0° | unmapped |
| 23 | outer_exterior / w34313569:7 | `-60.769, -869.745` → `-64.0, -869.749` | `3.452, 3.49` / `11.525, 11.525` | 3.231 | 270.1° | `0.001, -1.0` / 0.1° | unmapped |
| 24 | outer_exterior / w34313569:7 | `-64.0, -869.749` → `-76.808, -869.767` | `3.49, 3.157` / `11.525, 11.525` | 12.808 | 270.1° | `0.001, -1.0` / 0.1° | unmapped |
| 25 | outer_exterior / w34313569:8 | `-76.808, -869.767` → `-78.293, -864.0` | `3.157, 3.231` / `11.525, 11.525` | 5.955 | 194.4° | `-0.968, -0.249` / 284.4° | unmapped |
| 26 | outer_exterior / w34313569:8 | `-78.293, -864.0` → `-78.655, -862.598` | `3.231, 3.223` / `11.525, 11.525` | 1.448 | 194.5° | `-0.968, -0.249` / 284.4° | unmapped |

### 1318 Gateview Avenue — `w95934092`

Receiver `building:w95934092:wall` in `x_-3__z_-2`; 26 runs / 163.714 m; generated base/top 2.522/8.522 m. Temporal state: **current_official_observations**.

Recorded observations:

- `1318G-SV01` — official_panorama; March 2025; panorama `qGPa9ZjJlrtlQpnP52eiAA`; viewpoint WGS84 `37.8267503, -122.3776812` / world XZ `-588.366, -332.706`; heading 126.0°; west/northwest of footprint, looking southeast toward public/front side; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8267942,-122.3776632&heading=126&pitch=0&fov=75).
- `1318G-SV02` — official_panorama; November 2025; panorama `GmuTsOm1-FO47a4FOWEQHA`; viewpoint WGS84 `37.8266407, -122.3769985` / world XZ `-528.336, -320.506`; heading 245.0°; east of footprint, looking west-southwest toward rear side; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8266681,-122.3770043&heading=245&pitch=0&fov=75).

Mapped scopes:

- `1318G-FRONT-PRIMARY-FACETS` — **full_observed_side** / high; runs `0, 1, 4, 5, 7, 8, 10, 12, 15, 16, 24`; source edges `1,3,5,7,9,11,13`; 47.508 m; non-contiguous primary facets with each source-edge chain validated independently. The seven mapped source edges are the repeated direct WSW-facing front facets and all face the public Gateview viewpoint. Interleaved NNW/SSE returns are different source edges and are not guessed into the front sequence. Facing error 34.9–73.9°; panorama-heading error 0.9–0.9°.
- `1318G-REAR-ENE` — **partial_observed_side** / high; runs `18, 19, 20, 21, 22`; source edges `15`; 47.512 m; contiguous. Runs 18..22 exactly reconstruct rear source edge 15 and face the Avenue B viewpoint. Lower regions remain privacy-fence occluded. Facing error 21.7–55.8°; panorama-heading error 3.7–3.7°.
- `1318G-OUTER-NNW-END` — **partial_observed_side** / high; runs `23`; source edges `14`; 12.601 m; contiguous. Run 23 reconstructs the outer NNW end edge adjoining the rear. Same-normal short front notches at source edges 4, 8 and 12 remain excluded. Facing error 65.4–65.4°; panorama-heading error 38.7–38.7°.

**Safe runtime scope:** Flat cool gray-blue homogeneous albedo/roughness on mapped primary front facets, rear edge and outer end only.

**Preserved unknowns:**

- Exact unit widths, alternating entry/window schedule, canopy breaks and physical siding scale remain unknown; geometry alone cannot establish modules.
- Short NNW notch runs 6, 11 and 25 and SSE return runs 2, 3, 9, 13, 14 and 17 remain unmapped.
- Foreground fences, bins, cars, satellite dishes, trellises and tenant additions remain excluded.

**Explicit blocked chains:**

- Source edges `4,8,12`, runs `6,11,25`: short same-normal notches; not the outer NNW end.
- Source edges `0,2,6,10`, runs `2,3,9,13,14,17`: SSE returns/opposite end; no exact feature/module ownership.

| Run | Owner ring / source edge | Start XZ → end XZ (m) | Bottom / top Y (m) | Length | Bearing | Outward normal / azimuth | Class |
|---:|---|---|---|---:|---:|---|---|
| 0 | outer_exterior / w95934092:11 | `-566.885, -323.801` → `-564.922, -320.0` | `2.116, 2.182` / `8.522, 8.522` | 4.278 | 152.7° | `-0.888, 0.459` / 242.7° | full_observed_side (`1318G-FRONT-PRIMARY-FACETS`) |
| 1 | outer_exterior / w95934092:11 | `-564.922, -320.0` → `-563.596, -317.433` | `2.182, 2.229` / `8.522, 8.522` | 2.889 | 152.7° | `-0.888, 0.459` / 242.7° | full_observed_side (`1318G-FRONT-PRIMARY-FACETS`) |
| 2 | outer_exterior / w95934092:10 | `-563.596, -317.433` → `-558.64, -320.0` | `2.229, 2.295` / `8.522, 8.522` | 5.581 | 62.6° | `0.46, 0.888` / 152.6° | unmapped |
| 3 | outer_exterior / w95934092:10 | `-558.64, -320.0` → `-557.063, -320.817` | `2.295, 2.317` / `8.522, 8.522` | 1.776 | 62.6° | `0.46, 0.888` / 152.6° | unmapped |
| 4 | outer_exterior / w95934092:9 | `-557.063, -320.817` → `-556.641, -320.0` | `2.317, 2.331` / `8.522, 8.522` | 0.92 | 152.7° | `-0.889, 0.458` / 242.7° | full_observed_side (`1318G-FRONT-PRIMARY-FACETS`) |
| 5 | outer_exterior / w95934092:9 | `-556.641, -320.0` → `-553.176, -313.281` | `2.331, 2.454` / `8.522, 8.522` | 7.56 | 152.7° | `-0.889, 0.458` / 242.7° | full_observed_side (`1318G-FRONT-PRIMARY-FACETS`) |
| 6 | outer_exterior / w95934092:8 | `-553.176, -313.281` → `-559.621, -309.952` | `2.454, 2.368` / `8.522, 8.522` | 7.254 | 242.7° | `-0.459, -0.889` / 332.7° | unmapped |
| 7 | outer_exterior / w95934092:7 | `-559.621, -309.952` → `-557.723, -306.277` | `2.368, 2.435` / `8.522, 8.522` | 4.136 | 152.7° | `-0.889, 0.459` / 242.7° | full_observed_side (`1318G-FRONT-PRIMARY-FACETS`) |
| 8 | outer_exterior / w95934092:7 | `-557.723, -306.277` → `-556.35, -303.618` | `2.435, 2.425` / `8.522, 8.522` | 2.993 | 152.7° | `-0.889, 0.459` / 242.7° | full_observed_side (`1318G-FRONT-PRIMARY-FACETS`) |
| 9 | outer_exterior / w95934092:6 | `-556.35, -303.618` → `-549.589, -307.103` | `2.425, 2.468` / `8.522, 8.522` | 7.606 | 62.7° | `0.458, 0.889` / 152.7° | unmapped |
| 10 | outer_exterior / w95934092:5 | `-549.589, -307.103` → `-545.676, -299.533` | `2.468, 2.44` / `8.522, 8.522` | 8.522 | 152.7° | `-0.888, 0.459` / 242.7° | full_observed_side (`1318G-FRONT-PRIMARY-FACETS`) |
| 11 | outer_exterior / w95934092:4 | `-545.676, -299.533` → `-552.35, -296.082` | `2.44, 2.398` / `8.522, 8.522` | 7.513 | 242.7° | `-0.459, -0.888` / 332.7° | unmapped |
| 12 | outer_exterior / w95934092:3 | `-552.35, -296.082` → `-548.929, -289.459` | `2.398, 2.373` / `8.522, 8.522` | 7.454 | 152.7° | `-0.889, 0.459` / 242.7° | full_observed_side (`1318G-FRONT-PRIMARY-FACETS`) |
| 13 | outer_exterior / w95934092:2 | `-548.929, -289.459` → `-544.0, -292.002` | `2.373, 2.405` / `8.522, 8.522` | 5.546 | 62.7° | `0.459, 0.889` / 152.7° | unmapped |
| 14 | outer_exterior / w95934092:2 | `-544.0, -292.002` → `-541.982, -293.043` | `2.405, 2.385` / `8.522, 8.522` | 2.271 | 62.7° | `0.459, 0.889` / 152.7° | unmapped |
| 15 | outer_exterior / w95934092:1 | `-541.982, -293.043` → `-540.953, -291.047` | `2.385, 2.361` / `8.522, 8.522` | 2.246 | 152.7° | `-0.889, 0.458` / 242.7° | full_observed_side (`1318G-FRONT-PRIMARY-FACETS`) |
| 16 | outer_exterior / w95934092:1 | `-540.953, -291.047` → `-540.18, -289.548` | `2.361, 2.338` / `8.522, 8.522` | 1.687 | 152.7° | `-0.889, 0.458` / 242.7° | full_observed_side (`1318G-FRONT-PRIMARY-FACETS`) |
| 17 | outer_exterior / w95934092:0 | `-540.18, -289.548` → `-529.901, -294.858` | `2.338, 2.224` / `8.522, 8.522` | 11.57 | 62.7° | `0.459, 0.888` / 152.7° | unmapped |
| 18 | outer_exterior / w95934092:15 | `-529.901, -294.858` → `-532.367, -299.633` | `2.224, 2.299` / `8.522, 8.522` | 5.374 | 332.7° | `0.888, -0.459` / 62.7° | partial_observed_side (`1318G-REAR-ENE`) |
| 19 | outer_exterior / w95934092:15 | `-532.367, -299.633` → `-542.889, -320.0` | `2.299, 2.522` / `8.522, 8.522` | 22.924 | 332.7° | `0.888, -0.459` / 62.7° | partial_observed_side (`1318G-REAR-ENE`) |
| 20 | outer_exterior / w95934092:15 | `-542.889, -320.0` → `-543.268, -320.732` | `2.522, 2.522` / `8.522, 8.522` | 0.824 | 332.6° | `0.888, -0.459` / 62.7° | partial_observed_side (`1318G-REAR-ENE`) |
| 21 | outer_exterior / w95934092:15 | `-543.268, -320.732` → `-544.0, -322.15` | `2.522, 2.522` / `8.522, 8.522` | 1.596 | 332.7° | `0.888, -0.459` / 62.7° | partial_observed_side (`1318G-REAR-ENE`) |
| 22 | outer_exterior / w95934092:15 | `-544.0, -322.15` → `-551.708, -337.07` | `2.522, 2.281` / `8.522, 8.522` | 16.793 | 332.7° | `0.888, -0.459` / 62.7° | partial_observed_side (`1318G-REAR-ENE`) |
| 23 | outer_exterior / w95934092:14 | `-551.708, -337.07` → `-562.901, -331.281` | `2.281, 2.127` / `8.522, 8.522` | 12.601 | 242.7° | `-0.459, -0.888` / 332.7° | partial_observed_side (`1318G-OUTER-NNW-END`) |
| 24 | outer_exterior / w95934092:13 | `-562.901, -331.281` → `-560.685, -326.995` | `2.127, 2.202` / `8.522, 8.522` | 4.825 | 152.7° | `-0.888, 0.459` / 242.7° | full_observed_side (`1318G-FRONT-PRIMARY-FACETS`) |
| 25 | outer_exterior / w95934092:12 | `-560.685, -326.995` → `-566.885, -323.801` | `2.202, 2.116` / `8.522, 8.522` | 6.974 | 242.7° | `-0.458, -0.889` / 332.7° | unmapped |

### 1212 Mariner Drive — `w96215649`

Receiver `building:w96215649:wall` in `x_-1__z_-3`; 28 runs / 115.696 m; generated base/top 2.65/8.65 m. Temporal state: **current_official_observations**.

Recorded observations:

- `1212M-SV01` — official_panorama; March 2025; panorama `moV9e3E7bv5UpjOrgfOOKA`; viewpoint WGS84 `37.8291812, -122.373034` / world XZ `-179.732, -603.313`; heading 172.0°; north of footprint, looking south toward public/front side; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8291464,-122.3730796&heading=172&pitch=0&fov=75).
- `1212M-SV02` — official_panorama; September 2025; panorama `Z0fcNvA78OpNIXJaa9A79A`; viewpoint WGS84 `37.8291852, -122.3727577` / world XZ `-155.436, -603.758`; heading 230.0°; northeast/east of footprint, looking southwest toward rear/end side; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8291844,-122.3727735&heading=230&pitch=0&fov=75).

Mapped scopes:

- `1212M-FRONT-PRIMARY-FACETS` — **full_observed_side** / high; runs `14, 15, 16, 17, 19, 20, 21, 22, 24, 25, 26, 27`; source edges `0,1,2,4,5,6,8,9,10`; 43.92 m; non-contiguous primary facets with each source-edge chain validated independently. The mapped NNW source edges are the direct repeated public-front facets and face the Mariner Drive viewpoint. ENE run 18 and WSW run 23 are embedded notch/return faces and are not guessed into the unit sequence. Facing error 1.3–54.9°; panorama-heading error 9.5–9.5°.
- `1212M-OUTER-ENE-END` — **partial_observed_side** / high; runs `13`; source edges `17`; 10.979 m; contiguous. Run 13 reconstructs the outer ENE end and is in the outward half-plane of the September 2025 east/northeast viewpoint. Short ENE notch run 18 remains excluded. Facing error 65.6–65.6°; panorama-heading error 41.0–41.0°.

**Safe runtime scope:** Flat cool gray-blue homogeneous albedo/roughness on mapped public-front primary facets and outer ENE end only.

**Preserved unknowns:**

- The recorded rear-long-side description cannot be reconciled to generated SSE rear edges 12, 14 and 16 from the actual viewpoint; those runs remain unmapped.
- Narrow notch runs 18 and 23, opposite WSW end runs 0..2, small return facets and all unit boundaries/modules remain unknown.
- 1212 and 1318 are not treated as texture-identical; physical siding scale and unit alternates remain unresolved.

**Explicit blocked chains:**

- Source edges `12,14,16`, runs `3,4,6,7,10,11,12`: ledger rear-long-side label fails generated outward-half-plane reconciliation from actual viewpoint.
- Source edges `3,7`, runs `18,23`: short ENE/WSW notches; do not guess front/end ownership.
- Source edges `11`, runs `0,1,2`: opposite WSW end unobserved.

| Run | Owner ring / source edge | Start XZ → end XZ (m) | Bottom / top Y (m) | Length | Bearing | Outward normal / azimuth | Class |
|---:|---|---|---|---:|---:|---|---|
| 0 | outer_exterior / w96215649:11 | `-202.233, -577.854` → `-201.723, -576.0` | `2.623, 2.626` / `8.65, 8.65` | 1.923 | 164.6° | `-0.964, 0.265` / 254.6° | unmapped |
| 1 | outer_exterior / w96215649:11 | `-201.723, -576.0` → `-199.624, -568.376` | `2.626, 2.614` / `8.65, 8.65` | 7.908 | 164.6° | `-0.964, 0.265` / 254.6° | unmapped |
| 2 | outer_exterior / w96215649:11 | `-199.624, -568.376` → `-199.34, -567.345` | `2.614, 2.633` / `8.65, 8.65` | 1.069 | 164.6° | `-0.964, 0.265` / 254.6° | unmapped |
| 3 | outer_exterior / w96215649:12 | `-199.34, -567.345` → `-192.0, -569.361` | `2.633, 2.65` / `8.65, 8.65` | 7.612 | 74.6° | `0.265, 0.964` / 164.6° | unmapped |
| 4 | outer_exterior / w96215649:12 | `-192.0, -569.361` → `-185.518, -571.141` | `2.65, 2.65` / `8.65, 8.65` | 6.722 | 74.6° | `0.265, 0.964` / 164.6° | unmapped |
| 5 | outer_exterior / w96215649:13 | `-185.518, -571.141` → `-185.852, -572.377` | `2.65, 2.65` / `8.65, 8.65` | 1.28 | 344.9° | `0.965, -0.261` / 74.9° | unmapped |
| 6 | outer_exterior / w96215649:14 | `-185.852, -572.377` → `-172.667, -576.0` | `2.65, 2.65` / `8.65, 8.65` | 13.674 | 74.6° | `0.265, 0.964` / 164.6° | unmapped |
| 7 | outer_exterior / w96215649:14 | `-172.667, -576.0` → `-171.835, -576.229` | `2.65, 2.65` / `8.65, 8.65` | 0.863 | 74.6° | `0.265, 0.964` / 164.6° | unmapped |
| 8 | outer_exterior / w96215649:15 | `-171.835, -576.229` → `-171.773, -576.0` | `2.65, 2.65` / `8.65, 8.65` | 0.237 | 164.9° | `-0.964, 0.264` / 254.7° | unmapped |
| 9 | outer_exterior / w96215649:15 | `-171.773, -576.0` → `-171.536, -575.138` | `2.65, 2.65` / `8.65, 8.65` | 0.894 | 164.6° | `-0.964, 0.264` / 254.7° | unmapped |
| 10 | outer_exterior / w96215649:16 | `-171.536, -575.138` → `-168.397, -576.0` | `2.65, 2.65` / `8.65, 8.65` | 3.255 | 74.6° | `0.265, 0.964` / 164.6° | unmapped |
| 11 | outer_exterior / w96215649:16 | `-168.397, -576.0` → `-160.0, -578.307` | `2.65, 2.65` / `8.65, 8.65` | 8.708 | 74.6° | `0.265, 0.964` / 164.6° | unmapped |
| 12 | outer_exterior / w96215649:16 | `-160.0, -578.307` → `-157.028, -579.123` | `2.65, 2.65` / `8.65, 8.65` | 3.082 | 74.6° | `0.265, 0.964` / 164.6° | unmapped |
| 13 | outer_exterior / w96215649:17 | `-157.028, -579.123` → `-159.938, -589.709` | `2.65, 2.528` / `8.65, 8.65` | 10.979 | 344.6° | `0.964, -0.265` / 74.6° | partial_observed_side (`1212M-OUTER-ENE-END`) |
| 14 | outer_exterior / w96215649:0 | `-159.938, -589.709` → `-160.0, -589.693` | `2.528, 2.528` / `8.65, 8.65` | 0.064 | 255.5° | `-0.263, -0.965` / 344.8° | full_observed_side (`1212M-FRONT-PRIMARY-FACETS`) |
| 15 | outer_exterior / w96215649:0 | `-160.0, -589.693` → `-163.077, -588.852` | `2.528, 2.534` / `8.65, 8.65` | 3.19 | 254.7° | `-0.263, -0.965` / 344.8° | full_observed_side (`1212M-FRONT-PRIMARY-FACETS`) |
| 16 | outer_exterior / w96215649:1 | `-163.077, -588.852` → `-169.831, -586.993` | `2.534, 2.547` / `8.65, 8.65` | 7.005 | 254.6° | `-0.265, -0.964` / 344.6° | full_observed_side (`1212M-FRONT-PRIMARY-FACETS`) |
| 17 | outer_exterior / w96215649:2 | `-169.831, -586.993` → `-173.752, -585.913` | `2.547, 2.554` / `8.65, 8.65` | 4.067 | 254.6° | `-0.265, -0.964` / 344.6° | full_observed_side (`1212M-FRONT-PRIMARY-FACETS`) |
| 18 | outer_exterior / w96215649:3 | `-173.752, -585.913` → `-174.201, -587.528` | `2.554, 2.534` / `8.65, 8.65` | 1.676 | 344.5° | `0.964, -0.268` / 74.5° | unmapped |
| 19 | outer_exterior / w96215649:4 | `-174.201, -587.528` → `-177.146, -586.715` | `2.534, 2.539` / `8.65, 8.65` | 3.055 | 254.6° | `-0.266, -0.964` / 344.6° | full_observed_side (`1212M-FRONT-PRIMARY-FACETS`) |
| 20 | outer_exterior / w96215649:5 | `-177.146, -586.715` → `-182.855, -585.145` | `2.539, 2.55` / `8.65, 8.65` | 5.921 | 254.6° | `-0.265, -0.964` / 344.6° | full_observed_side (`1212M-FRONT-PRIMARY-FACETS`) |
| 21 | outer_exterior / w96215649:5 | `-182.855, -585.145` → `-184.594, -584.667` | `2.55, 2.568` / `8.65, 8.65` | 1.803 | 254.6° | `-0.265, -0.964` / 344.6° | full_observed_side (`1212M-FRONT-PRIMARY-FACETS`) |
| 22 | outer_exterior / w96215649:6 | `-184.594, -584.667` → `-188.789, -583.52` | `2.568, 2.612` / `8.65, 8.65` | 4.349 | 254.7° | `-0.264, -0.965` / 344.7° | full_observed_side (`1212M-FRONT-PRIMARY-FACETS`) |
| 23 | outer_exterior / w96215649:7 | `-188.789, -583.52` → `-188.287, -581.694` | `2.612, 2.608` / `8.65, 8.65` | 1.894 | 164.6° | `-0.964, 0.265` / 254.6° | unmapped |
| 24 | outer_exterior / w96215649:8 | `-188.287, -581.694` → `-191.189, -580.893` | `2.608, 2.638` / `8.65, 8.65` | 3.011 | 254.6° | `-0.266, -0.964` / 344.6° | full_observed_side (`1212M-FRONT-PRIMARY-FACETS`) |
| 25 | outer_exterior / w96215649:9 | `-191.189, -580.893` → `-192.0, -580.67` | `2.638, 2.647` / `8.65, 8.65` | 0.841 | 254.6° | `-0.265, -0.964` / 344.6° | full_observed_side (`1212M-FRONT-PRIMARY-FACETS`) |
| 26 | outer_exterior / w96215649:9 | `-192.0, -580.67` → `-198.276, -578.945` | `2.647, 2.632` / `8.65, 8.65` | 6.509 | 254.6° | `-0.265, -0.964` / 344.6° | full_observed_side (`1212M-FRONT-PRIMARY-FACETS`) |
| 27 | outer_exterior / w96215649:10 | `-198.276, -578.945` → `-202.233, -577.854` | `2.632, 2.623` / `8.65, 8.65` | 4.105 | 254.6° | `-0.266, -0.964` / 344.6° | full_observed_side (`1212M-FRONT-PRIMARY-FACETS`) |

## Hard exclusions

- 449 Avenue H and 810 Avenue D are historical-only. Their mapped runs authorize no current/live attachment.
- Dormitory 369 remains a five-visible-tier versus fallback-6 m massing conflict; no tier, story, height or geometry decision is made.
- 850 Avenue H north runs `19..22` remain container-blocked and unknown; the west contributor panorama is excluded.
- Bldg 461 remains medium-confidence at distance and has no live-safe material scope.
- 1318 Gateview and 1212 Mariner primary facets are mapped exactly, but no unit modules, cadence, physical scale, short returns or notches are inferred.
- 1212 Mariner rear SSE chains are not mapped because the actual recorded viewpoint lies behind their generated wall planes.
- No unique module is authorized for any target.

## Validation

The local validator compared all **204** run records to the frozen chunk vertices, endpoint elevations, indices and normals; reconstructed source-edge ownership from the frozen OSM node rings; checked one-time run partitions, source counts, claimed continuity/facet chains, the **85° outward-half-plane tolerance**, the **60° panorama-heading tolerance**, historical/current separation, excluded contributors and every preserved blocked chain. All declared checks pass.


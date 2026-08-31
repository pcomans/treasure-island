# Batch 02 observed-side to generated-run mapping

Checked: **2026-08-29**  
Scope: six targets; Oasis excluded; local frozen evidence only. This document records geometry/provenance and does not authorize runtime edits.

## Result

The six frozen wall records contain **202 runs**. **52** are mapped at high confidence and **150** remain explicitly unmapped. All run endpoints, lengths, bearings, normals, ownership, classifications and observation metadata are enumerated in the companion JSON.

| Target | High-confidence mapping | Exact safe live-attachment scope | Blocker |
|---|---|---|---|
| Building 2 | B2-WSW-END `0,1,3,4,5,6,7,8,10,12,13,14,15` (full_observed_side, 87.087 m) | No live attachment. Exact cream, glazing, pylon, central and relief subregions are unresolved. | Return runs 2, 9 and 11 are inside the observed end envelope but their own faces are not established. Same-normal run 37 belongs to the opposite-end notch. |
| 490 Avenue of the Palms | P490-WSW `0,1,2,3,4,5,6,7` (partial_observed_side, 82.427 m) | No live attachment. Thin brick, white, greige and terrace subregions do not coincide with proven run boundaries. | NW runs 23..25 retain only medium endpoint/ownership confidence. Apparent six visible stories versus frozen five remains unresolved. |
| Star View Court | SVC-ENE `13,14,15,16,17,18,19,20,21,22` (partial_observed_side, 107.862 m) | No live attachment. Grey-base vertical extent and opening subregions remain unresolved. | NW/WSW entrance corner remains medium-confidence and unmapped. Apparent six visible stories versus frozen seven remains unresolved. |
| Maceo May | MM-OUTER-SSE-SE `7,8,9,10` (partial_observed_side, 46.882 m); MM-OUTER-ENE `11,12,13,14,15,16` (partial_observed_side, 56.019 m) | No live attachment. Rib region extent and physical pitch remain unresolved; courtyard runs 21..39 are prohibited. | Outer runs 0..6 and 17..20 are not established by the observations. Inner courtyard runs 21..39 are a hard exclusion from outer-facade propagation. |
| Navy Chapel Building 187 | NC-SSE-GABLE `9,10` (material_only_safe, 16.362 m) | Warm-cream homogeneous background only on runs 9..10; no openings, gable modules, signage or long-side propagation. | The distant oblique does not establish exact ownership of the partial adjacent long side. |
| Treasure Island Community YMCA | Y-SSE `3,4,5,6,7` (full_observed_side, 72.979 m); Y-ENE-SERVICE `8,9,10,11` (material_only_safe, 28.067 m) | Aggregate/background material only on runs 3..11; no openings, mural, low-wing artwork or modules. | Same-normal runs 15..18 are a reentrant/back chain, not the public SSE side. NNW campus condition and mural/low-wing footprint ownership remain unknown. |

## Mapping detail

### Building 2 — `w24274434`

Receiver `building:w24274434:wall` in `x_1__z_2`; 46 runs, 387.263 m. Outer ring owner `w24274434`.

- `B2-WSW-END`: **full_observed_side**, runs `0, 1, 3, 4, 5, 6, 7, 8, 10, 12, 13, 14, 15`, 87.087 m, direct facets within explicit contiguous envelope. Canonical source edges 0..6 form the WSW monumental end envelope. Runs 2, 9 and 11 are embedded returns and remain unknown; run 37 is a same-normal face in the opposite-end notch. Facing error 1.1–60.7°.

Safe runtime scope: No live attachment. Exact cream, glazing, pylon, central and relief subregions are unresolved.

Unknowns: Return runs 2, 9 and 11 are inside the observed end envelope but their own faces are not established. Same-normal run 37 belongs to the opposite-end notch.

| Run | Owner ring / source edge | Start XZ → end XZ (m) | Length | Bearing | Outward normal / azimuth | Class |
|---:|---|---|---:|---:|---|---|
| 0 | outer_exterior / w24274434:0 | `213.831, 572.789` → `215.538, 576` | 3.637 | 152° | `-0.883, 0.469` / 242° | full_observed_side (`B2-WSW-END`) |
| 1 | outer_exterior / w24274434:0 | `215.538, 576` → `216.329, 577.487` | 1.684 | 152° | `-0.883, 0.469` / 242° | full_observed_side (`B2-WSW-END`) |
| 2 | outer_exterior / w24274434:1 | `216.329, 577.487` → `217.12, 577.064` | 0.897 | 61.9° | `0.471, 0.882` / 151.9° | unmapped |
| 3 | outer_exterior / w24274434:2 | `217.12, 577.064` → `219.143, 580.857` | 4.299 | 151.9° | `-0.882, 0.471` / 241.9° | full_observed_side (`B2-WSW-END`) |
| 4 | outer_exterior / w24274434:2 | `219.143, 580.857` → `224, 589.962` | 10.319 | 151.9° | `-0.882, 0.471` / 241.9° | full_observed_side (`B2-WSW-END`) |
| 5 | outer_exterior / w24274434:2 | `224, 589.962` → `230.275, 601.725` | 13.332 | 151.9° | `-0.882, 0.471` / 241.9° | full_observed_side (`B2-WSW-END`) |
| 6 | outer_exterior / w24274434:2 | `230.275, 601.725` → `233.621, 608` | 7.111 | 151.9° | `-0.882, 0.471` / 241.9° | full_observed_side (`B2-WSW-END`) |
| 7 | outer_exterior / w24274434:2 | `233.621, 608` → `241.406, 622.594` | 16.541 | 151.9° | `-0.882, 0.471` / 241.9° | full_observed_side (`B2-WSW-END`) |
| 8 | outer_exterior / w24274434:2 | `241.406, 622.594` → `247.949, 634.861` | 13.903 | 151.9° | `-0.882, 0.471` / 241.9° | full_observed_side (`B2-WSW-END`) |
| 9 | outer_exterior / w24274434:3 | `247.949, 634.861` → `246.982, 635.373` | 1.094 | 242.1° | `-0.468, -0.884` / 332.1° | unmapped |
| 10 | outer_exterior / w24274434:4 | `246.982, 635.373` → `249.4, 639.915` | 5.146 | 152° | `-0.883, 0.47` / 242° | full_observed_side (`B2-WSW-END`) |
| 11 | outer_exterior / w24274434:5 | `249.4, 639.915` → `254.526, 637.176` | 5.812 | 61.9° | `0.471, 0.882` / 151.9° | unmapped |
| 12 | outer_exterior / w24274434:6 | `254.526, 637.176` → `256, 639.939` | 3.132 | 151.9° | `-0.882, 0.471` / 241.9° | full_observed_side (`B2-WSW-END`) |
| 13 | outer_exterior / w24274434:6 | `256, 639.939` → `256.021, 639.979` | 0.045 | 152.3° | `-0.882, 0.471` / 241.9° | full_observed_side (`B2-WSW-END`) |
| 14 | outer_exterior / w24274434:6 | `256.021, 639.979` → `256.033, 640` | 0.024 | 150.3° | `-0.882, 0.471` / 241.9° | full_observed_side (`B2-WSW-END`) |
| 15 | outer_exterior / w24274434:6 | `256.033, 640` → `259.758, 646.983` | 7.914 | 151.9° | `-0.882, 0.471` / 241.9° | full_observed_side (`B2-WSW-END`) |
| 16 | outer_exterior / w24274434:7 | `259.758, 646.983` → `272.83, 640` | 14.82 | 61.9° | `0.471, 0.882` / 151.9° | unmapped |
| 17 | outer_exterior / w24274434:7 | `272.83, 640` → `288, 631.896` | 17.199 | 61.9° | `0.471, 0.882` / 151.9° | unmapped |
| 18 | outer_exterior / w24274434:7 | `288, 631.896` → `305.4, 622.6` | 19.728 | 61.9° | `0.471, 0.882` / 151.9° | unmapped |
| 19 | outer_exterior / w24274434:7 | `305.4, 622.6` → `320, 614.8` | 16.553 | 61.9° | `0.471, 0.882` / 151.9° | unmapped |
| 20 | outer_exterior / w24274434:7 | `320, 614.8` → `332.729, 608` | 14.431 | 61.9° | `0.471, 0.882` / 151.9° | unmapped |
| 21 | outer_exterior / w24274434:7 | `332.729, 608` → `345.254, 601.309` | 14.2 | 61.9° | `0.471, 0.882` / 151.9° | unmapped |
| 22 | outer_exterior / w24274434:8 | `345.254, 601.309` → `340.637, 592.671` | 9.794 | 331.9° | `0.882, -0.471` / 61.9° | unmapped |
| 23 | outer_exterior / w24274434:9 | `340.637, 592.671` → `338.615, 593.75` | 2.292 | 241.9° | `-0.471, -0.882` / 331.9° | unmapped |
| 24 | outer_exterior / w24274434:10 | `338.615, 593.75` → `337.093, 590.907` | 3.225 | 331.8° | `0.882, -0.472` / 61.8° | unmapped |
| 25 | outer_exterior / w24274434:10 | `337.093, 590.907` → `335.441, 587.817` | 3.504 | 331.9° | `0.882, -0.472` / 61.8° | unmapped |
| 26 | outer_exterior / w24274434:11 | `335.441, 587.817` → `335.001, 588.051` | 0.498 | 242° | `-0.469, -0.883` / 332° | unmapped |
| 27 | outer_exterior / w24274434:12 | `335.001, 588.051` → `328.584, 576` | 13.653 | 332° | `0.883, -0.47` / 62° | unmapped |
| 28 | outer_exterior / w24274434:12 | `328.584, 576` → `325.602, 570.398` | 6.346 | 332° | `0.883, -0.47` / 62° | unmapped |
| 29 | outer_exterior / w24274434:12 | `325.602, 570.398` → `320, 559.877` | 11.919 | 332° | `0.883, -0.47` / 62° | unmapped |
| 30 | outer_exterior / w24274434:12 | `320, 559.877` → `314.484, 549.516` | 11.738 | 332° | `0.883, -0.47` / 62° | unmapped |
| 31 | outer_exterior / w24274434:12 | `314.484, 549.516` → `311.546, 544` | 6.25 | 332° | `0.883, -0.47` / 62° | unmapped |
| 32 | outer_exterior / w24274434:12 | `311.546, 544` → `304.286, 530.365` | 15.447 | 332° | `0.883, -0.47` / 62° | unmapped |
| 33 | outer_exterior / w24274434:13 | `304.286, 530.365` → `304.902, 530.031` | 0.701 | 61.5° | `0.477, 0.879` / 151.5° | unmapped |
| 34 | outer_exterior / w24274434:14 | `304.902, 530.031` → `303.884, 528.116` | 2.169 | 332° | `0.883, -0.469` / 62° | unmapped |
| 35 | outer_exterior / w24274434:14 | `303.884, 528.116` → `302.405, 525.333` | 3.152 | 332° | `0.883, -0.469` / 62° | unmapped |
| 36 | outer_exterior / w24274434:15 | `302.405, 525.333` → `297.226, 528.094` | 5.869 | 241.9° | `-0.47, -0.882` / 331.9° | unmapped |
| 37 | outer_exterior / w24274434:16 | `297.226, 528.094` → `298.29, 530.098` | 2.269 | 152° | `-0.883, 0.469` / 242° | unmapped |
| 38 | outer_exterior / w24274434:17 | `298.29, 530.098` → `288, 535.576` | 11.657 | 242° | `-0.47, -0.883` / 332° | unmapped |
| 39 | outer_exterior / w24274434:17 | `288, 535.576` → `272.176, 544` | 17.927 | 242° | `-0.47, -0.883` / 332° | unmapped |
| 40 | outer_exterior / w24274434:17 | `272.176, 544` → `256, 552.611` | 18.325 | 242° | `-0.47, -0.883` / 332° | unmapped |
| 41 | outer_exterior / w24274434:17 | `256, 552.611` → `237.585, 562.415` | 20.862 | 242° | `-0.47, -0.883` / 332° | unmapped |
| 42 | outer_exterior / w24274434:17 | `237.585, 562.415` → `224, 569.647` | 15.39 | 242° | `-0.47, -0.883` / 332° | unmapped |
| 43 | outer_exterior / w24274434:17 | `224, 569.647` → `219.855, 571.854` | 4.696 | 242° | `-0.47, -0.883` / 332° | unmapped |
| 44 | outer_exterior / w24274434:18 | `219.855, 571.854` → `218.905, 570.084` | 2.009 | 331.8° | `0.881, -0.473` / 61.8° | unmapped |
| 45 | outer_exterior / w24274434:19 | `218.905, 570.084` → `213.831, 572.789` | 5.75 | 241.9° | `-0.47, -0.882` / 331.9° | unmapped |

### 490 Avenue of the Palms — `w1272162518`

Receiver `building:w1272162518:wall` in `x_-1__z_1`; 26 runs, 305.1 m. Outer ring owner `w1272162518`.

- `P490-WSW`: **partial_observed_side**, runs `0, 1, 2, 3, 4, 5, 6, 7`, 82.427 m, contiguous. All eight foundation-split runs reconstruct canonical WSW source edge 0. The imagery covers most of the elevation but does not prove endpoint-complete facade ownership. Facing error 0.3–55.2°.

Safe runtime scope: No live attachment. Thin brick, white, greige and terrace subregions do not coincide with proven run boundaries.

Unknowns: NW runs 23..25 retain only medium endpoint/ownership confidence. Apparent six visible stories versus frozen five remains unresolved.

| Run | Owner ring / source edge | Start XZ → end XZ (m) | Length | Bearing | Outward normal / azimuth | Class |
|---:|---|---|---:|---:|---|---|
| 0 | outer_exterior / w1272162518:0 | `-276.395, 273.963` → `-275.55, 275.55` | 1.798 | 152° | `-0.883, 0.47` / 242° | partial_observed_side (`P490-WSW`) |
| 1 | outer_exterior / w1272162518:0 | `-275.55, 275.55` → `-268.926, 288` | 14.102 | 152° | `-0.883, 0.47` / 242° | partial_observed_side (`P490-WSW`) |
| 2 | outer_exterior / w1272162518:0 | `-268.926, 288` → `-264.437, 296.437` | 9.557 | 152° | `-0.883, 0.47` / 242° | partial_observed_side (`P490-WSW`) |
| 3 | outer_exterior / w1272162518:0 | `-264.437, 296.437` → `-256, 312.296` | 17.964 | 152° | `-0.883, 0.47` / 242° | partial_observed_side (`P490-WSW`) |
| 4 | outer_exterior / w1272162518:0 | `-256, 312.296` → `-253.325, 317.325` | 5.696 | 152° | `-0.883, 0.47` / 242° | partial_observed_side (`P490-WSW`) |
| 5 | outer_exterior / w1272162518:0 | `-253.325, 317.325` → `-251.901, 320` | 3.03 | 152° | `-0.883, 0.47` / 242° | partial_observed_side (`P490-WSW`) |
| 6 | outer_exterior / w1272162518:0 | `-251.901, 320` → `-242.212, 338.212` | 20.629 | 152° | `-0.883, 0.47` / 242° | partial_observed_side (`P490-WSW`) |
| 7 | outer_exterior / w1272162518:0 | `-242.212, 338.212` → `-237.678, 346.732` | 9.651 | 152° | `-0.883, 0.47` / 242° | partial_observed_side (`P490-WSW`) |
| 8 | outer_exterior / w1272162518:1 | `-237.678, 346.732` → `-224, 339.645` | 15.405 | 62.6° | `0.46, 0.888` / 152.6° | unmapped |
| 9 | outer_exterior / w1272162518:1 | `-224, 339.645` → `-198.359, 326.359` | 28.879 | 62.6° | `0.46, 0.888` / 152.6° | unmapped |
| 10 | outer_exterior / w1272162518:1 | `-198.359, 326.359` → `-192, 323.064` | 7.162 | 62.6° | `0.46, 0.888` / 152.6° | unmapped |
| 11 | outer_exterior / w1272162518:1 | `-192, 323.064` → `-187.857, 320.917` | 4.666 | 62.6° | `0.46, 0.888` / 152.6° | unmapped |
| 12 | outer_exterior / w1272162518:2 | `-187.857, 320.917` → `-188.332, 320` | 1.033 | 332.6° | `0.888, -0.46` / 62.6° | unmapped |
| 13 | outer_exterior / w1272162518:2 | `-188.332, 320` → `-189.584, 317.584` | 2.721 | 332.6° | `0.888, -0.46` / 62.6° | unmapped |
| 14 | outer_exterior / w1272162518:2 | `-189.584, 317.584` → `-192, 312.921` | 5.252 | 332.6° | `0.888, -0.46` / 62.6° | unmapped |
| 15 | outer_exterior / w1272162518:2 | `-192, 312.921` → `-200.506, 296.506` | 18.488 | 332.6° | `0.888, -0.46` / 62.6° | unmapped |
| 16 | outer_exterior / w1272162518:2 | `-200.506, 296.506` → `-204.913, 288` | 9.58 | 332.6° | `0.888, -0.46` / 62.6° | unmapped |
| 17 | outer_exterior / w1272162518:2 | `-204.913, 288` → `-211.427, 275.427` | 14.16 | 332.6° | `0.888, -0.46` / 62.6° | unmapped |
| 18 | outer_exterior / w1272162518:2 | `-211.427, 275.427` → `-221.494, 256` | 21.88 | 332.6° | `0.888, -0.46` / 62.6° | unmapped |
| 19 | outer_exterior / w1272162518:2 | `-221.494, 256` → `-222.349, 254.349` | 1.859 | 332.6° | `0.888, -0.46` / 62.6° | unmapped |
| 20 | outer_exterior / w1272162518:2 | `-222.349, 254.349` → `-224, 251.164` | 3.587 | 332.6° | `0.888, -0.46` / 62.6° | unmapped |
| 21 | outer_exterior / w1272162518:2 | `-224, 251.164` → `-233.271, 233.271` | 20.152 | 332.6° | `0.888, -0.46` / 62.6° | unmapped |
| 22 | outer_exterior / w1272162518:2 | `-233.271, 233.271` → `-236.245, 227.531` | 6.465 | 332.6° | `0.888, -0.46` / 62.6° | unmapped |
| 23 | outer_exterior / w1272162518:3 | `-236.245, 227.531` → `-256, 250.377` | 30.203 | 220.9° | `-0.756, -0.654` / 310.9° | unmapped |
| 24 | outer_exterior / w1272162518:3 | `-256, 250.377` → `-260.862, 256` | 7.434 | 220.8° | `-0.756, -0.654` / 310.9° | unmapped |
| 25 | outer_exterior / w1272162518:3 | `-260.862, 256` → `-276.395, 273.963` | 23.747 | 220.9° | `-0.756, -0.654` / 310.9° | unmapped |

### Star View Court — `w1212173437`

Receiver `building:w1212173437:wall` in `x_-1__z_0`; 26 runs, 293.024 m. Outer ring owner `w1212173437`.

- `SVC-ENE`: **partial_observed_side**, runs `13, 14, 15, 16, 17, 18, 19, 20, 21, 22`, 107.862 m, contiguous. Runs 13..22 exactly reconstruct canonical ENE source edge 2 and face the east-side public viewpoint. Coverage is broad, not endpoint-complete. Facing error 0.7–81.2°.

Safe runtime scope: No live attachment. Grey-base vertical extent and opening subregions remain unresolved.

Unknowns: NW/WSW entrance corner remains medium-confidence and unmapped. Apparent six visible stories versus frozen seven remains unresolved.

| Run | Owner ring / source edge | Start XZ → end XZ (m) | Length | Bearing | Outward normal / azimuth | Class |
|---:|---|---|---:|---:|---|---|
| 0 | outer_exterior / w1212173437:0 | `-229.29, 217.212` → `-225.731, 224` | 7.664 | 152.3° | `-0.886, 0.464` / 242.4° | unmapped |
| 1 | outer_exterior / w1212173437:0 | `-225.731, 224` → `-225.136, 225.136` | 1.282 | 152.4° | `-0.886, 0.464` / 242.4° | unmapped |
| 2 | outer_exterior / w1212173437:0 | `-225.136, 225.136` → `-224, 227.302` | 2.446 | 152.3° | `-0.886, 0.464` / 242.4° | unmapped |
| 3 | outer_exterior / w1212173437:0 | `-224, 227.302` → `-214.13, 246.13` | 21.258 | 152.3° | `-0.886, 0.464` / 242.4° | unmapped |
| 4 | outer_exterior / w1212173437:0 | `-214.13, 246.13` → `-208.955, 256` | 11.144 | 152.3° | `-0.886, 0.464` / 242.4° | unmapped |
| 5 | outer_exterior / w1212173437:0 | `-208.955, 256` → `-203.123, 267.123` | 12.559 | 152.3° | `-0.886, 0.464` / 242.4° | unmapped |
| 6 | outer_exterior / w1212173437:0 | `-203.123, 267.123` → `-192.178, 288` | 23.572 | 152.3° | `-0.886, 0.464` / 242.4° | unmapped |
| 7 | outer_exterior / w1212173437:0 | `-192.178, 288` → `-192.117, 288.117` | 0.132 | 152.5° | `-0.886, 0.464` / 242.4° | unmapped |
| 8 | outer_exterior / w1212173437:0 | `-192.117, 288.117` → `-192, 288.34` | 0.252 | 152.3° | `-0.886, 0.464` / 242.4° | unmapped |
| 9 | outer_exterior / w1212173437:0 | `-192, 288.34` → `-187.901, 296.16` | 8.829 | 152.3° | `-0.886, 0.464` / 242.4° | unmapped |
| 10 | outer_exterior / w1212173437:1 | `-187.901, 296.16` → `-172.348, 288` | 17.564 | 62.3° | `0.465, 0.886` / 152.3° | unmapped |
| 11 | outer_exterior / w1212173437:1 | `-172.348, 288` → `-160, 281.521` | 13.945 | 62.3° | `0.465, 0.886` / 152.3° | unmapped |
| 12 | outer_exterior / w1212173437:1 | `-160, 281.521` → `-147.1, 274.753` | 14.568 | 62.3° | `0.465, 0.886` / 152.3° | unmapped |
| 13 | outer_exterior / w1212173437:2 | `-147.1, 274.753` → `-156.882, 256` | 21.151 | 332.5° | `0.887, -0.462` / 62.5° | partial_observed_side (`SVC-ENE`) |
| 14 | outer_exterior / w1212173437:2 | `-156.882, 256` → `-157.951, 253.951` | 2.311 | 332.4° | `0.887, -0.462` / 62.5° | partial_observed_side (`SVC-ENE`) |
| 15 | outer_exterior / w1212173437:2 | `-157.951, 253.951` → `-160, 250.023` | 4.43 | 332.5° | `0.887, -0.462` / 62.5° | partial_observed_side (`SVC-ENE`) |
| 16 | outer_exterior / w1212173437:2 | `-160, 250.023` → `-168.92, 232.92` | 19.289 | 332.5° | `0.887, -0.462` / 62.5° | partial_observed_side (`SVC-ENE`) |
| 17 | outer_exterior / w1212173437:2 | `-168.92, 232.92` → `-173.573, 224` | 10.061 | 332.5° | `0.887, -0.462` / 62.5° | partial_observed_side (`SVC-ENE`) |
| 18 | outer_exterior / w1212173437:2 | `-173.573, 224` → `-179.89, 211.89` | 13.659 | 332.5° | `0.887, -0.462` / 62.5° | partial_observed_side (`SVC-ENE`) |
| 19 | outer_exterior / w1212173437:2 | `-179.89, 211.89` → `-190.265, 192` | 22.433 | 332.5° | `0.887, -0.462` / 62.5° | partial_observed_side (`SVC-ENE`) |
| 20 | outer_exterior / w1212173437:2 | `-190.265, 192` → `-190.86, 190.86` | 1.286 | 332.4° | `0.887, -0.462` / 62.5° | partial_observed_side (`SVC-ENE`) |
| 21 | outer_exterior / w1212173437:2 | `-190.86, 190.86` → `-192, 188.673` | 2.466 | 332.5° | `0.887, -0.462` / 62.5° | partial_observed_side (`SVC-ENE`) |
| 22 | outer_exterior / w1212173437:2 | `-192, 188.673` → `-196.984, 179.119` | 10.776 | 332.5° | `0.887, -0.462` / 62.5° | partial_observed_side (`SVC-ENE`) |
| 23 | outer_exterior / w1212173437:3 | `-196.984, 179.119` → `-207.908, 192` | 16.889 | 220.3° | `-0.763, -0.647` / 310.3° | unmapped |
| 24 | outer_exterior / w1212173437:3 | `-207.908, 192` → `-224, 210.975` | 24.88 | 220.3° | `-0.763, -0.647` / 310.3° | unmapped |
| 25 | outer_exterior / w1212173437:3 | `-224, 210.975` → `-229.29, 217.212` | 8.178 | 220.3° | `-0.763, -0.647` / 310.3° | unmapped |

### Maceo May — `r19685981`

Receiver `building:r19685981:wall` in `x_-1__z_1`; 40 runs, 328.838 m. Outer ring owner `w1001544694`; protected inner owner `w1436064964`.

- `MM-OUTER-SSE-SE`: **partial_observed_side**, runs `7, 8, 9, 10`, 46.882 m, contiguous. Outer-ring source edges 1..2 form the public SSE/SE corner and match the documented 130.9 to 155.1 degree handoff. Run 7 is a 4.683 m grazing return and uses the documented 95 degree exception. Facing error 31.2–92.8°.
- `MM-OUTER-ENE`: **partial_observed_side**, runs `11, 12, 13, 14, 15, 16`, 56.019 m, contiguous. Outer-ring source edge 3 is a continuous ENE chain facing the Seven Seas viewpoint. Facing error 16.8–78.2°.

Safe runtime scope: No live attachment. Rib region extent and physical pitch remain unresolved; courtyard runs 21..39 are prohibited.

Unknowns: Outer runs 0..6 and 17..20 are not established by the observations. Inner courtyard runs 21..39 are a hard exclusion from outer-facade propagation.

| Run | Owner ring / source edge | Start XZ → end XZ (m) | Length | Bearing | Outward normal / azimuth | Class |
|---:|---|---|---:|---:|---|---|
| 0 | outer_exterior / w1001544694:0 | `-182.238, 299.689` → `-178.676, 306.676` | 7.843 | 153° | `-0.891, 0.454` / 243° | unmapped |
| 1 | outer_exterior / w1001544694:0 | `-178.676, 306.676` → `-171.886, 320` | 14.954 | 153° | `-0.891, 0.454` / 243° | unmapped |
| 2 | outer_exterior / w1001544694:0 | `-171.886, 320` → `-167.873, 327.873` | 8.837 | 153° | `-0.891, 0.454` / 243° | unmapped |
| 3 | outer_exterior / w1001544694:0 | `-167.873, 327.873` → `-160, 343.321` | 17.339 | 153° | `-0.891, 0.454` / 243° | unmapped |
| 4 | outer_exterior / w1001544694:0 | `-160, 343.321` → `-157.07, 349.07` | 6.453 | 153° | `-0.891, 0.454` / 243° | unmapped |
| 5 | outer_exterior / w1001544694:0 | `-157.07, 349.07` → `-155.577, 352` | 3.288 | 153° | `-0.891, 0.454` / 243° | unmapped |
| 6 | outer_exterior / w1001544694:0 | `-155.577, 352` → `-149.615, 363.697` | 13.129 | 153° | `-0.891, 0.454` / 243° | unmapped |
| 7 | outer_exterior / w1001544694:1 | `-149.615, 363.697` → `-145.544, 361.382` | 4.683 | 60.4° | `0.494, 0.869` / 150.4° | partial_observed_side (`MM-OUTER-SSE-SE`) |
| 8 | outer_exterior / w1001544694:2 | `-145.544, 361.382` → `-137.409, 352` | 12.418 | 40.9° | `0.756, 0.655` / 130.9° | partial_observed_side (`MM-OUTER-SSE-SE`) |
| 9 | outer_exterior / w1001544694:2 | `-137.409, 352` → `-128, 341.15` | 14.361 | 40.9° | `0.756, 0.655` / 130.9° | partial_observed_side (`MM-OUTER-SSE-SE`) |
| 10 | outer_exterior / w1001544694:2 | `-128, 341.15` → `-117.898, 329.5` | 15.42 | 40.9° | `0.756, 0.655` / 130.9° | partial_observed_side (`MM-OUTER-SSE-SE`) |
| 11 | outer_exterior / w1001544694:3 | `-117.898, 329.5` → `-122.728, 320` | 10.657 | 333.1° | `0.891, -0.453` / 63.1° | partial_observed_side (`MM-OUTER-ENE`) |
| 12 | outer_exterior / w1001544694:3 | `-122.728, 320` → `-124.505, 316.505` | 3.921 | 333° | `0.891, -0.453` / 63.1° | partial_observed_side (`MM-OUTER-ENE`) |
| 13 | outer_exterior / w1001544694:3 | `-124.505, 316.505` → `-128, 309.629` | 7.713 | 333.1° | `0.891, -0.453` / 63.1° | partial_observed_side (`MM-OUTER-ENE`) |
| 14 | outer_exterior / w1001544694:3 | `-128, 309.629` → `-135.289, 295.289` | 16.086 | 333.1° | `0.891, -0.453` / 63.1° | partial_observed_side (`MM-OUTER-ENE`) |
| 15 | outer_exterior / w1001544694:3 | `-135.289, 295.289` → `-138.995, 288` | 8.177 | 333° | `0.891, -0.453` / 63.1° | partial_observed_side (`MM-OUTER-ENE`) |
| 16 | outer_exterior / w1001544694:3 | `-138.995, 288` → `-143.284, 279.562` | 9.465 | 333.1° | `0.891, -0.453` / 63.1° | partial_observed_side (`MM-OUTER-ENE`) |
| 17 | outer_exterior / w1001544694:4 | `-143.284, 279.562` → `-159.615, 288` | 18.382 | 242.7° | `-0.459, -0.888` / 332.7° | unmapped |
| 18 | outer_exterior / w1001544694:4 | `-159.615, 288` → `-160, 288.199` | 0.433 | 242.7° | `-0.459, -0.888` / 332.7° | unmapped |
| 19 | outer_exterior / w1001544694:4 | `-160, 288.199` → `-160.412, 288.412` | 0.464 | 242.7° | `-0.459, -0.888` / 332.7° | unmapped |
| 20 | outer_exterior / w1001544694:4 | `-160.412, 288.412` → `-182.238, 299.689` | 24.567 | 242.7° | `-0.459, -0.888` / 332.7° | unmapped |
| 21 | inner_courtyard / w1436064964:5 | `-166.208, 305.555` → `-160, 302.032` | 7.138 | 60.4° | `0.494, 0.87` / 150.4° | unmapped |
| 22 | inner_courtyard / w1436064964:5 | `-160, 302.032` → `-157.617, 300.68` | 2.74 | 60.4° | `0.494, 0.87` / 150.4° | unmapped |
| 23 | inner_courtyard / w1436064964:5 | `-157.617, 300.68` → `-157.925, 300.156` | 0.608 | 329.6° | `0.862, -0.507` / 59.5° | unmapped |
| 24 | inner_courtyard / w1436064964:5 | `-157.925, 300.156` → `-157.3, 299.867` | 0.689 | 65.2° | `0.421, 0.907` / 155.1° | unmapped |
| 25 | inner_courtyard / w1436064964:6 | `-157.3, 299.867` → `-151.327, 311.327` | 12.923 | 152.5° | `-0.887, 0.462` / 242.5° | unmapped |
| 26 | inner_courtyard / w1436064964:6 | `-151.327, 311.327` → `-146.806, 320` | 9.781 | 152.5° | `-0.887, 0.462` / 242.5° | unmapped |
| 27 | inner_courtyard / w1436064964:6 | `-146.806, 320` → `-143.258, 326.806` | 7.675 | 152.5° | `-0.887, 0.462` / 242.5° | unmapped |
| 28 | inner_courtyard / w1436064964:6 | `-143.258, 326.806` → `-143.952, 327.14` | 0.77 | 244.3° | `-0.433, -0.901` / 334.3° | unmapped |
| 29 | inner_courtyard / w1436064964:7 | `-143.952, 327.14` → `-142.475, 329.856` | 3.092 | 151.5° | `-0.878, 0.478` / 241.4° | unmapped |
| 30 | inner_courtyard / w1436064964:7 | `-142.475, 329.856` → `-138.703, 328.665` | 3.956 | 72.5° | `0.301, 0.954` / 162.5° | unmapped |
| 31 | inner_courtyard / w1436064964:7 | `-138.703, 328.665` → `-137.986, 329.986` | 1.503 | 151.5° | `-0.879, 0.477` / 241.5° | unmapped |
| 32 | inner_courtyard / w1436064964:8 | `-137.986, 329.986` → `-136.619, 332.506` | 2.867 | 151.5° | `-0.879, 0.477` / 241.5° | unmapped |
| 33 | inner_courtyard / w1436064964:8 | `-136.619, 332.506` → `-144.506, 342.135` | 12.447 | 219.3° | `-0.774, -0.634` / 309.3° | unmapped |
| 34 | inner_courtyard / w1436064964:8 | `-144.506, 342.135` → `-147.549, 342.079` | 3.044 | 271.1° | `0.018, -1` / 1° | unmapped |
| 35 | inner_courtyard / w1436064964:8 | `-147.549, 342.079` → `-148.404, 340.404` | 1.881 | 333° | `0.891, -0.455` / 62.9° | unmapped |
| 36 | inner_courtyard / w1436064964:9 | `-148.404, 340.404` → `-158.828, 320` | 22.913 | 332.9° | `0.891, -0.455` / 62.9° | unmapped |
| 37 | inner_courtyard / w1436064964:9 | `-158.828, 320` → `-159.225, 319.225` | 0.871 | 332.9° | `0.891, -0.455` / 62.9° | unmapped |
| 38 | inner_courtyard / w1436064964:9 | `-159.225, 319.225` → `-160, 317.707` | 1.704 | 333° | `0.891, -0.455` / 62.9° | unmapped |
| 39 | inner_courtyard / w1436064964:9 | `-160, 317.707` → `-166.208, 305.555` | 13.646 | 332.9° | `0.891, -0.455` / 62.9° | unmapped |

### Navy Chapel Building 187 — `w291189336`

Receiver `building:w291189336:wall` in `x_-1__z_2`; 34 runs, 153.581 m. Outer ring owner `w291189336`.

- `NC-SSE-GABLE`: **material_only_safe**, runs `9, 10`, 16.362 m, contiguous. Runs 9..10 exactly reconstruct canonical SSE gable source edge 5. Distance supports only a generic warm-cream material field, not module geometry. Facing error 20.4–28.3°.

Safe runtime scope: Warm-cream homogeneous background only on runs 9..10; no openings, gable modules, signage or long-side propagation.

Unknowns: The distant oblique does not establish exact ownership of the partial adjacent long side.

| Run | Owner ring / source edge | Start XZ → end XZ (m) | Length | Bearing | Outward normal / azimuth | Class |
|---:|---|---|---:|---:|---|---|
| 0 | outer_exterior / w291189336:0 | `-128.635, 625.488` → `-128, 626.687` | 1.357 | 152.1° | `-0.884, 0.468` / 242.1° | unmapped |
| 1 | outer_exterior / w291189336:0 | `-128, 626.687` → `-124.924, 632.501` | 6.578 | 152.1° | `-0.884, 0.468` / 242.1° | unmapped |
| 2 | outer_exterior / w291189336:1 | `-124.924, 632.501` → `-118.013, 628.849` | 7.817 | 62.1° | `0.467, 0.884` / 152.2° | unmapped |
| 3 | outer_exterior / w291189336:2 | `-118.013, 628.849` → `-117.61, 629.61` | 0.861 | 152.1° | `-0.884, 0.468` / 242.1° | unmapped |
| 4 | outer_exterior / w291189336:2 | `-117.61, 629.61` → `-115.691, 633.235` | 4.102 | 152.1° | `-0.884, 0.468` / 242.1° | unmapped |
| 5 | outer_exterior / w291189336:3 | `-115.691, 633.235` → `-114.645, 632.679` | 1.185 | 62° | `0.47, 0.883` / 152° | unmapped |
| 6 | outer_exterior / w291189336:4 | `-114.645, 632.679` → `-110.778, 640` | 8.28 | 152.2° | `-0.884, 0.467` / 242.2° | unmapped |
| 7 | outer_exterior / w291189336:4 | `-110.778, 640` → `-105.67, 649.67` | 10.936 | 152.2° | `-0.884, 0.467` / 242.2° | unmapped |
| 8 | outer_exterior / w291189336:4 | `-105.67, 649.67` → `-104.937, 651.058` | 1.57 | 152.2° | `-0.884, 0.467` / 242.2° | unmapped |
| 9 | outer_exterior / w291189336:5 | `-104.937, 651.058` → `-96, 646.332` | 10.11 | 62.1° | `0.467, 0.884` / 152.2° | material_only_safe (`NC-SSE-GABLE`) |
| 10 | outer_exterior / w291189336:5 | `-96, 646.332` → `-90.473, 643.41` | 6.252 | 62.1° | `0.467, 0.884` / 152.2° | material_only_safe (`NC-SSE-GABLE`) |
| 11 | outer_exterior / w291189336:6 | `-90.473, 643.41` → `-92.275, 640` | 3.857 | 332.1° | `0.884, -0.467` / 62.2° | unmapped |
| 12 | outer_exterior / w291189336:6 | `-92.275, 640` → `-93.563, 637.563` | 2.756 | 332.1° | `0.884, -0.467` / 62.2° | unmapped |
| 13 | outer_exterior / w291189336:6 | `-93.563, 637.563` → `-96, 632.951` | 5.216 | 332.1° | `0.884, -0.467` / 62.2° | unmapped |
| 14 | outer_exterior / w291189336:6 | `-96, 632.951` → `-100.268, 624.875` | 9.134 | 332.1° | `0.884, -0.467` / 62.2° | unmapped |
| 15 | outer_exterior / w291189336:7 | `-100.268, 624.875` → `-99.028, 624.218` | 1.403 | 62.1° | `0.468, 0.884` / 152.1° | unmapped |
| 16 | outer_exterior / w291189336:8 | `-99.028, 624.218` → `-101.332, 619.855` | 4.934 | 332.2° | `0.884, -0.467` / 62.2° | unmapped |
| 17 | outer_exterior / w291189336:9 | `-101.332, 619.855` → `-96, 617.038` | 6.03 | 62.2° | `0.467, 0.884` / 152.2° | unmapped |
| 18 | outer_exterior / w291189336:9 | `-96, 617.038` → `-94.904, 616.46` | 1.239 | 62.2° | `0.467, 0.884` / 152.2° | unmapped |
| 19 | outer_exterior / w291189336:10 | `-94.904, 616.46` → `-96, 614.389` | 2.343 | 332.1° | `0.884, -0.468` / 62.1° | unmapped |
| 20 | outer_exterior / w291189336:10 | `-96, 614.389` → `-98.211, 610.211` | 4.727 | 332.1° | `0.884, -0.468` / 62.1° | unmapped |
| 21 | outer_exterior / w291189336:10 | `-98.211, 610.211` → `-98.615, 609.446` | 0.865 | 332.2° | `0.884, -0.468` / 62.1° | unmapped |
| 22 | outer_exterior / w291189336:11 | `-98.615, 609.446` → `-104.99, 612.808` | 7.207 | 242.2° | `-0.466, -0.885` / 332.2° | unmapped |
| 23 | outer_exterior / w291189336:12 | `-104.99, 612.808` → `-106.626, 609.702` | 3.511 | 332.2° | `0.885, -0.466` / 62.2° | unmapped |
| 24 | outer_exterior / w291189336:13 | `-106.626, 609.702` → `-107.918, 610.381` | 1.46 | 242.3° | `-0.465, -0.885` / 332.3° | unmapped |
| 25 | outer_exterior / w291189336:14 | `-107.918, 610.381` → `-109.177, 608` | 2.693 | 332.1° | `0.884, -0.467` / 62.2° | unmapped |
| 26 | outer_exterior / w291189336:14 | `-109.177, 608` → `-110.442, 605.606` | 2.708 | 332.1° | `0.884, -0.467` / 62.2° | unmapped |
| 27 | outer_exterior / w291189336:15 | `-110.442, 605.606` → `-114.978, 608` | 5.129 | 242.2° | `-0.467, -0.884` / 332.2° | unmapped |
| 28 | outer_exterior / w291189336:15 | `-114.978, 608` → `-124.994, 613.287` | 11.326 | 242.2° | `-0.467, -0.884` / 332.2° | unmapped |
| 29 | outer_exterior / w291189336:16 | `-124.994, 613.287` → `-122.471, 618.074` | 5.411 | 152.2° | `-0.885, 0.466` / 242.2° | unmapped |
| 30 | outer_exterior / w291189336:17 | `-122.471, 618.074` → `-123.376, 618.552` | 1.023 | 242.2° | `-0.467, -0.884` / 332.2° | unmapped |
| 31 | outer_exterior / w291189336:18 | `-123.376, 618.552` → `-121.662, 621.803` | 3.675 | 152.2° | `-0.884, 0.467` / 242.2° | unmapped |
| 32 | outer_exterior / w291189336:19 | `-121.662, 621.803` → `-128, 625.152` | 7.168 | 242.1° | `-0.467, -0.884` / 332.2° | unmapped |
| 33 | outer_exterior / w291189336:19 | `-128, 625.152` → `-128.635, 625.488` | 0.718 | 242.1° | `-0.467, -0.884` / 332.2° | unmapped |

### Treasure Island Community YMCA — `w34313547`

Receiver `building:w34313547:wall` in `x_0__z_-2`; 30 runs, 267.24 m. Outer ring owner `w34313547`.

- `Y-SSE`: **full_observed_side**, runs `3, 4, 5, 6, 7`, 72.979 m, contiguous. Runs 3..7 exactly reconstruct the complete canonical SSE source edge 1 and face the 9th Street viewpoint. Facing error 11.5–48.8°.
- `Y-ENE-SERVICE`: **material_only_safe**, runs `8, 9, 10, 11`, 28.067 m, contiguous. Runs 8..11 exactly reconstruct canonical ENE source edge 2 and face the Avenue M service-end viewpoint. Evidence supports material character only. Facing error 21.6–58.5°.

Safe runtime scope: Aggregate/background material only on runs 3..11; no openings, mural, low-wing artwork or modules.

Unknowns: Same-normal runs 15..18 are a reentrant/back chain, not the public SSE side. NNW campus condition and mural/low-wing footprint ownership remain unknown.

| Run | Owner ring / source edge | Start XZ → end XZ (m) | Length | Bearing | Outward normal / azimuth | Class |
|---:|---|---|---:|---:|---|---|
| 0 | outer_exterior / w34313547:0 | `182.176, -287.633` → `185.461, -281.461` | 6.992 | 152° | `-0.883, 0.47` / 242° | unmapped |
| 1 | outer_exterior / w34313547:0 | `185.461, -281.461` → `192, -269.172` | 13.92 | 152° | `-0.883, 0.47` / 242° | unmapped |
| 2 | outer_exterior / w34313547:0 | `192, -269.172` → `195.137, -263.276` | 6.679 | 152° | `-0.883, 0.47` / 242° | unmapped |
| 3 | outer_exterior / w34313547:1 | `195.137, -263.276` → `203.981, -267.981` | 10.018 | 62° | `0.47, 0.883` / 152° | full_observed_side (`Y-SSE`) |
| 4 | outer_exterior / w34313547:1 | `203.981, -267.981` → `224, -278.631` | 22.676 | 62° | `0.47, 0.883` / 152° | full_observed_side (`Y-SSE`) |
| 5 | outer_exterior / w34313547:1 | `224, -278.631` → `241.611, -288` | 19.948 | 62° | `0.47, 0.883` / 152° | full_observed_side (`Y-SSE`) |
| 6 | outer_exterior / w34313547:1 | `241.611, -288` → `256, -295.655` | 16.299 | 62° | `0.47, 0.883` / 152° | full_observed_side (`Y-SSE`) |
| 7 | outer_exterior / w34313547:1 | `256, -295.655` → `259.565, -297.551` | 4.038 | 62° | `0.47, 0.883` / 152° | full_observed_side (`Y-SSE`) |
| 8 | outer_exterior / w34313547:2 | `259.565, -297.551` → `256, -304.253` | 7.591 | 332° | `0.883, -0.47` / 62° | material_only_safe (`Y-ENE-SERVICE`) |
| 9 | outer_exterior / w34313547:2 | `256, -304.253` → `250.532, -314.532` | 11.643 | 332° | `0.883, -0.47` / 62° | material_only_safe (`Y-ENE-SERVICE`) |
| 10 | outer_exterior / w34313547:2 | `250.532, -314.532` → `247.624, -320` | 6.193 | 332° | `0.883, -0.47` / 62° | material_only_safe (`Y-ENE-SERVICE`) |
| 11 | outer_exterior / w34313547:2 | `247.624, -320` → `246.384, -322.331` | 2.64 | 332° | `0.883, -0.47` / 62° | material_only_safe (`Y-ENE-SERVICE`) |
| 12 | outer_exterior / w34313547:3 | `246.384, -322.331` → `242, -320` | 4.965 | 242° | `-0.47, -0.883` / 332° | unmapped |
| 13 | outer_exterior / w34313547:3 | `242, -320` → `224, -310.427` | 20.387 | 242° | `-0.47, -0.883` / 332° | unmapped |
| 14 | outer_exterior / w34313547:3 | `224, -310.427` → `223.003, -309.897` | 1.129 | 242° | `-0.47, -0.883` / 332° | unmapped |
| 15 | outer_exterior / w34313547:4 | `223.003, -309.897` → `219.84, -315.84` | 6.732 | 332° | `0.883, -0.47` / 62° | unmapped |
| 16 | outer_exterior / w34313547:4 | `219.84, -315.84` → `217.627, -320` | 4.712 | 332° | `0.883, -0.47` / 62° | unmapped |
| 17 | outer_exterior / w34313547:4 | `217.627, -320` → `208.726, -336.726` | 18.947 | 332° | `0.883, -0.47` / 62° | unmapped |
| 18 | outer_exterior / w34313547:4 | `208.726, -336.726` → `207.703, -338.651` | 2.18 | 332° | `0.883, -0.47` / 62° | unmapped |
| 19 | outer_exterior / w34313547:5 | `207.703, -338.651` → `192, -330.292` | 17.789 | 242° | `-0.47, -0.883` / 332° | unmapped |
| 20 | outer_exterior / w34313547:5 | `192, -330.292` → `189.07, -328.732` | 3.319 | 242° | `-0.47, -0.883` / 332° | unmapped |
| 21 | outer_exterior / w34313547:6 | `189.07, -328.732` → `192, -323.229` | 6.234 | 152° | `-0.883, 0.47` / 242° | unmapped |
| 22 | outer_exterior / w34313547:6 | `192, -323.229` → `193.122, -321.122` | 2.387 | 152° | `-0.883, 0.47` / 242° | unmapped |
| 23 | outer_exterior / w34313547:6 | `193.122, -321.122` → `193.719, -320` | 1.271 | 152° | `-0.883, 0.47` / 242° | unmapped |
| 24 | outer_exterior / w34313547:6 | `193.719, -320` → `204.24, -300.24` | 22.386 | 152° | `-0.883, 0.47` / 242° | unmapped |
| 25 | outer_exterior / w34313547:6 | `204.24, -300.24` → `204.599, -299.566` | 0.764 | 152° | `-0.883, 0.47` / 242° | unmapped |
| 26 | outer_exterior / w34313547:7 | `204.599, -299.566` → `202.392, -298.392` | 2.5 | 242° | `-0.47, -0.883` / 332° | unmapped |
| 27 | outer_exterior / w34313547:7 | `202.392, -298.392` → `192, -292.861` | 11.772 | 242° | `-0.47, -0.883` / 332° | unmapped |
| 28 | outer_exterior / w34313547:7 | `192, -292.861` → `182.866, -288` | 10.347 | 242° | `-0.47, -0.883` / 332° | unmapped |
| 29 | outer_exterior / w34313547:7 | `182.866, -288` → `182.176, -287.633` | 0.782 | 242° | `-0.47, -0.883` / 332° | unmapped |

## Preserved conflicts and exclusions

- 490 Avenue of the Palms: apparent six visible stories versus frozen five is not resolved.
- Star View Court: apparent six visible stories versus frozen seven is not resolved.
- Maceo May inner courtyard runs `21..39` are hard-protected and unmapped.
- Chapel long-side ownership remains unknown because the observation is distant/oblique.
- YMCA mural and low-wing ownership remain unknown; no artwork/module assignment is allowed.

## Validation

The companion JSON declares the exact validation contract. The final local validator compared all 202 run records back to their frozen chunk vertices/normals/elevations, checked partitions and single mapping ownership, checked contiguous chains/envelopes, checked panorama-facing geometry, and verified the fixed record/triangle counts.


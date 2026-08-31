# Batch 06 observed-side receiver mapping

Checked: **2026-08-29**  
Scope: eight Batch 06 sources; canonical local observation-to-deterministic-run geometry join only. No material/module assignment, prototype, generated-data edit or live attachment is authorized.

## Result

The receiver geometry remains **8 targets / 261 runs / 2412.208 m generated perimeter**. The final one-time partition is **64 mapped / 99 unmapped / 98 protected**, covering all 261 runs exactly once. Summed rounded runs are **769.007 m mapped / 875.997 m unmapped / 767.209 m protected = 2412.213 m**; the 0.005 m delta is only the accumulation of per-run three-decimal rounding. Two reference-blocked targets remain at zero mapped. Candidate, prototype and live counts remain zero.

| # | Source | Receiver / chunk | Runs / m | Final partition (mapped / unmapped / protected) | Mapped m | Evidence state |
|---:|---|---|---:|---:|---:|---|
| 1 | `w1222514695` | `building:w1222514695:wall` / `x_-1__z_3` | 5 / 26.589 | 0 / 0 / 5 | 0 | complete zero mapped reference blocked |
| 2 | `w1222720021` | `building:w1222720021:wall` / `x_0__z_2` | 10 / 25.26 | 0 / 0 / 10 | 0 | complete zero mapped reference blocked |
| 3 | `w34313515` | `building:w34313515:wall` / `x_-1__z_1` | 48 / 546.656 | 14 / 17 / 17 | 165.1 | complete bounded geometry join |
| 4 | `w34313520` | `building:w34313520:wall` / `x_-1__z_0` | 34 / 376.239 | 5 / 27 / 2 | 68.156 | complete bounded geometry join |
| 5 | `w34313525` | `building:w34313525:wall` / `x_1__z_-1` | 30 / 354.736 | 7 / 15 / 8 | 91.247 | complete bounded geometry join |
| 6 | `w34313564` | `building:w34313564:wall` / `x_0__z_-3` | 20 / 282.68 | 15 / 4 / 1 | 228.991 | complete bounded geometry join |
| 7 | `w291196370` | `building:w291196370:wall` / `x_0__z_-3` | 36 / 258.421 | 9 / 8 / 19 | 97.893 | complete bounded geometry join |
| 8 | `r133351` | `building:r133351:wall` / `x_-2__z_-2` | 78 / 541.627 | 14 / 28 / 36 | 117.62 | complete bounded geometry join |

## Mapping boundary

- Canonical observation ledger: `discovery/facades/BATCH_06_STREETVIEW_OBSERVATIONS.md`, SHA-256 `259e562e69b1186912fce2dfb466f4512fbc69cc8e64562574971c0a8c40028b`.
- Deterministic manifest: file SHA-256 `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`; content SHA-256 `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`. Current chunks and all eight wall records still match the hashes established by the two prior non-interactive deterministic builds.
- A run is mapped only when target identity/orientation evidence joins to exact source-edge ownership and passes both the 85° outward-facing and 60° panorama-heading gates.
- Mapping is geometry/evidence provenance only. Every run remains on the shared placeholder; no appearance, homogeneous-material safety, module, scale, opening, or live-attachment claim is made.
- Relation-inner faces, the boundary-clip facet, hidden/unobserved elevations, similarly oriented re-entrant chains, uncertain endpoints/corners, and adjacent-volume ambiguity are protected or unmapped.

## Target detail

### Unnamed frozen source — `w1222514695`

Receiver `building:w1222514695:wall` in `x_-1__z_3`; 5 runs / 26.589 m; base/top 3.034 / 9.034 m; height rule `default_6m` 6 m. Final partition: **0 mapped / 0 unmapped / 5 protected**; mapped length **0 m**.

Generated identity: `generated/world/chunks/x_-1__z_3.json` SHA-256 `a67aa41bbab215a4b5675d82bcad71de8650fc6379a189ce7ed571a169220403`; wall-record SHA-256 `b825ccbef30a73cba84dc4fd1eb903d9015e952069997c25f2a0c6217e05eccd`.

**Evidence:**

- `B06-1222514695-SV01` — September 2025; official panorama no target identifiable coverage; low target identity; No target-identifiable wall; foreground building and landscaping block or overlap the target area. No run mapping authorized.

**Mapped groups:**

- None. This target is reference-blocked and remains zero mapped.

**Protected / unresolved:**

- All five runs are protected because official coverage does not identify a target wall.
- Run 0 is additionally a playable-boundary clip facet and cannot inherit a facade claim from the clipped shelter source.
- Exact partitions: mapped `none`; unmapped `none`; protected `0–4`.

| Run | Source ownership | Start XZ → end XZ (m) | Length | Bearing | Outward normal / azimuth | Final state / evidence |
|---:|---|---|---:|---:|---|---|
| 0 | `boundary w26767313 edge null` | `-118.514, 791.295` → `-115.561, 796.826` | 6.27 | 151.9° | `-0.882, 0.471` / 241.9° | protected unmapped |
| 1 | `outer w1222514695 edge 1` | `-115.561, 796.826` → `-109.905, 792.556` | 7.087 | 52.9° | `0.603, 0.798` / 142.9° | protected unmapped |
| 2 | `outer w1222514695 edge 2` | `-109.905, 792.556` → `-111.365, 789.895` | 3.035 | 331.2° | `0.877, -0.481` / 61.3° | protected unmapped |
| 3 | `outer w1222514695 edge 3` | `-111.365, 789.895` → `-112.895, 787.101` | 3.185 | 331.3° | `0.877, -0.48` / 61.3° | protected unmapped |
| 4 | `outer w1222514695 edge 4` | `-112.895, 787.101` → `-118.514, 791.295` | 7.012 | 233.3° | `-0.598, -0.801` / 323.3° | protected unmapped |

### Unnamed frozen source — `w1222720021`

Receiver `building:w1222720021:wall` in `x_0__z_2`; 10 runs / 25.26 m; base/top 5.415 / 11.415 m; height rule `default_6m` 6 m. Final partition: **0 mapped / 0 unmapped / 10 protected**; mapped length **0 m**.

Generated identity: `generated/world/chunks/x_0__z_2.json` SHA-256 `886f4e6ecfbf570dac9cb36f682a089a0cfe51b735692e3220df4d5b4ac3d7b6`; wall-record SHA-256 `41849fa21a0309e737b292d745cbdeea913e933f95595186695225e5328131c5`.

**Evidence:**

- `B06-1222720021-SV01` — September 2025; official panorama no target identifiable coverage; low target identity; Curved foreground building blocks the target area; no tower facade is identifiable. No run mapping authorized.
- `B06-1222720021-SV02` — May 2019; official panorama no target identifiable coverage; low target identity; Construction/industrial context only; no target-identifiable observation tower. No run mapping authorized.

**Mapped groups:**

- None. This target is reference-blocked and remains zero mapped.

**Protected / unresolved:**

- All ten runs are protected because neither official panorama identifies the target tower.
- The generated default-height wall prism does not prove the tower silhouette or true facade topology.
- Exact partitions: mapped `none`; unmapped `none`; protected `0–9`.

| Run | Source ownership | Start XZ → end XZ (m) | Length | Bearing | Outward normal / azimuth | Final state / evidence |
|---:|---|---|---:|---:|---|---|
| 0 | `outer w1222720021 edge 0` | `10.473, 722.647` → `11.426, 724.574` | 2.15 | 153.7° | `-0.896, 0.444` / 243.6° | protected unmapped |
| 1 | `outer w1222720021 edge 0` | `11.426, 724.574` → `11.844, 725.419` | 0.943 | 153.7° | `-0.896, 0.444` / 243.6° | protected unmapped |
| 2 | `outer w1222720021 edge 1` | `11.844, 725.419` → `14.825, 726.465` | 3.159 | 109.3° | `-0.331, 0.944` / 199.3° | protected unmapped |
| 3 | `outer w1222720021 edge 2` | `14.825, 726.465` → `17.797, 724.94` | 3.34 | 62.8° | `0.457, 0.89` / 152.8° | protected unmapped |
| 4 | `outer w1222720021 edge 3` | `17.797, 724.94` → `18.703, 722.035` | 3.043 | 17.3° | `0.955, 0.298` / 107.3° | protected unmapped |
| 5 | `outer w1222720021 edge 4` | `18.703, 722.035` → `17.34, 719.263` | 3.089 | 333.8° | `0.897, -0.441` / 63.8° | protected unmapped |
| 6 | `outer w1222720021 edge 5` | `17.34, 719.263` → `16.892, 719.108` | 0.474 | 289.1° | `0.328, -0.945` / 19.1° | protected unmapped |
| 7 | `outer w1222720021 edge 5` | `16.892, 719.108` → `14.359, 718.228` | 2.682 | 289.2° | `0.328, -0.945` / 19.1° | protected unmapped |
| 8 | `outer w1222720021 edge 6` | `14.359, 718.228` → `11.378, 719.753` | 3.348 | 242.9° | `-0.455, -0.89` / 332.9° | protected unmapped |
| 9 | `outer w1222720021 edge 7` | `11.378, 719.753` → `10.473, 722.647` | 3.032 | 197.4° | `-0.954, -0.299` / 287.4° | protected unmapped |

### Unnamed frozen source — `w34313515`

Receiver `building:w34313515:wall` in `x_-1__z_1`; 48 runs / 546.656 m; base/top 3.357 / 14.357 m; height rule `osm_height` 11 m. Final partition: **14 mapped / 17 unmapped / 17 protected**; mapped length **165.1 m**.

Generated identity: `generated/world/chunks/x_-1__z_1.json` SHA-256 `b8696d4feb4157d39969ec039e610af572f25510d712c802d4a96943d6069c8c`; wall-record SHA-256 `178c30d142d78a396d997a12fd5770f9405f7c7d1d559b13c7cc83ac1e578ba6`.

**Evidence:**

- `B06-34313515-SV01` — September 2025; official panorama target identified; high coordinate identity; Long WSW-facing outer elevation. Mapping-eligible only at the bounded groups below.
- `B06-34313515-SV02` — September 2025; official panorama target identified; high coordinate identity; Long NNW-facing outer elevation and limited return. Mapping-eligible only at the bounded groups below.

**Mapped groups:**

- `B06-34313515-WSW-OUTER`: runs `0–8`; source edges `0`; 97.649 m; confidence `high_coordinate_identity_and_outer_edge_ownership`; evidence `B06-34313515-SV01` (September 2025). Observed WSW outer elevation geometry only. Checks: B06-34313515-SV01: facing 12.3–67.3°, heading 5.5–58.1°.
- `B06-34313515-NNW-OUTER`: runs `43–47`; source edges `13`; 67.451 m; confidence `high_coordinate_identity_and_outer_edge_ownership`; evidence `B06-34313515-SV02` (September 2025). Observed NNW outer elevation geometry only. Checks: B06-34313515-SV02: facing 71.7–82°, heading 29.7–40°.

**Protected / unresolved:**

- Runs 18–20 and 29–33 are similarly oriented re-entrant NNW chains that the outer-elevation observation cannot distinguish.
- Runs 23–26 and 36–40 are return/re-entrant SSE chains whose exact corner and chain ownership is not proved by the limited return context.
- Exact partitions: mapped `0–8, 43–47`; unmapped `9–17, 21–22, 27–28, 34–35, 41–42`; protected `18–20, 23–26, 29–33, 36–40`.

| Run | Source ownership | Start XZ → end XZ (m) | Length | Bearing | Outward normal / azimuth | Final state / evidence |
|---:|---|---|---:|---:|---|---|
| 0 | `outer w34313515 edge 0` | `-123.526, 235.335` → `-117.899, 245.899` | 11.969 | 152° | `-0.883, 0.47` / 242° | mapped `B06-34313515-WSW-OUTER` / `B06-34313515-SV01` |
| 1 | `outer w34313515 edge 0` | `-117.899, 245.899` → `-112.518, 256` | 11.445 | 152° | `-0.883, 0.47` / 242° | mapped `B06-34313515-WSW-OUTER` / `B06-34313515-SV01` |
| 2 | `outer w34313515 edge 0` | `-112.518, 256` → `-106.777, 266.777` | 12.211 | 152° | `-0.883, 0.47` / 242° | mapped `B06-34313515-WSW-OUTER` / `B06-34313515-SV01` |
| 3 | `outer w34313515 edge 0` | `-106.777, 266.777` → `-96, 287.009` | 22.923 | 152° | `-0.883, 0.47` / 242° | mapped `B06-34313515-WSW-OUTER` / `B06-34313515-SV01` |
| 4 | `outer w34313515 edge 0` | `-96, 287.009` → `-95.655, 287.655` | 0.732 | 151.9° | `-0.883, 0.47` / 242° | mapped `B06-34313515-WSW-OUTER` / `B06-34313515-SV01` |
| 5 | `outer w34313515 edge 0` | `-95.655, 287.655` → `-95.472, 288` | 0.391 | 152.1° | `-0.883, 0.47` / 242° | mapped `B06-34313515-WSW-OUTER` / `B06-34313515-SV01` |
| 6 | `outer w34313515 edge 0` | `-95.472, 288` → `-84.534, 308.534` | 23.266 | 152° | `-0.883, 0.47` / 242° | mapped `B06-34313515-WSW-OUTER` / `B06-34313515-SV01` |
| 7 | `outer w34313515 edge 0` | `-84.534, 308.534` → `-78.426, 320` | 12.991 | 152° | `-0.883, 0.47` / 242° | mapped `B06-34313515-WSW-OUTER` / `B06-34313515-SV01` |
| 8 | `outer w34313515 edge 0` | `-78.426, 320` → `-77.617, 321.519` | 1.721 | 152° | `-0.883, 0.47` / 242° | mapped `B06-34313515-WSW-OUTER` / `B06-34313515-SV01` |
| 9 | `outer w34313515 edge 1` | `-77.617, 321.519` → `-74.764, 320` | 3.232 | 62° | `0.47, 0.883` / 152° | unmapped |
| 10 | `outer w34313515 edge 1` | `-74.764, 320` → `-66.45, 315.574` | 9.419 | 62° | `0.47, 0.883` / 152° | unmapped |
| 11 | `outer w34313515 edge 2` | `-66.45, 315.574` → `-73.704, 301.971` | 15.416 | 331.9° | `0.882, -0.471` / 61.9° | unmapped |
| 12 | `outer w34313515 edge 3` | `-73.704, 301.971` → `-64, 296.801` | 10.995 | 62° | `0.47, 0.883` / 152° | unmapped |
| 13 | `outer w34313515 edge 3` | `-64, 296.801` → `-47.481, 288` | 18.717 | 62° | `0.47, 0.883` / 152° | unmapped |
| 14 | `outer w34313515 edge 3` | `-47.481, 288` → `-32, 279.752` | 17.541 | 62° | `0.47, 0.883` / 152° | unmapped |
| 15 | `outer w34313515 edge 3` | `-32, 279.752` → `-25.333, 276.2` | 7.554 | 62° | `0.47, 0.883` / 152° | unmapped |
| 16 | `outer w34313515 edge 4` | `-25.333, 276.2` → `-32, 263.682` | 14.183 | 332° | `0.883, -0.47` / 62° | unmapped |
| 17 | `outer w34313515 edge 4` | `-32, 263.682` → `-34.232, 259.491` | 4.748 | 332° | `0.883, -0.47` / 62° | unmapped |
| 18 | `outer w34313515 edge 5` | `-34.232, 259.491` → `-36.928, 260.928` | 3.055 | 241.9° | `-0.47, -0.883` / 332° | protected unmapped |
| 19 | `outer w34313515 edge 5` | `-36.928, 260.928` → `-64, 275.351` | 30.674 | 242° | `-0.47, -0.883` / 332° | protected unmapped |
| 20 | `outer w34313515 edge 5` | `-64, 275.351` → `-81.996, 284.939` | 20.391 | 242° | `-0.47, -0.883` / 332° | protected unmapped |
| 21 | `outer w34313515 edge 6` | `-81.996, 284.939` → `-85.801, 277.801` | 8.089 | 331.9° | `0.882, -0.47` / 61.9° | unmapped |
| 22 | `outer w34313515 edge 6` | `-85.801, 277.801` → `-88.802, 272.171` | 6.38 | 331.9° | `0.882, -0.47` / 61.9° | unmapped |
| 23 | `outer w34313515 edge 7` | `-88.802, 272.171` → `-70.332, 262.332` | 20.927 | 62° | `0.47, 0.883` / 152° | protected unmapped |
| 24 | `outer w34313515 edge 7` | `-70.332, 262.332` → `-64, 258.959` | 7.174 | 62° | `0.47, 0.883` / 152° | protected unmapped |
| 25 | `outer w34313515 edge 7` | `-64, 258.959` → `-58.445, 256` | 6.294 | 62° | `0.47, 0.883` / 152° | protected unmapped |
| 26 | `outer w34313515 edge 7` | `-58.445, 256` → `-41.029, 246.723` | 19.733 | 62° | `0.47, 0.883` / 152° | protected unmapped |
| 27 | `outer w34313515 edge 8` | `-41.029, 246.723` → `-45.788, 237.788` | 10.123 | 332° | `0.883, -0.47` / 62° | unmapped |
| 28 | `outer w34313515 edge 8` | `-45.788, 237.788` → `-49.277, 231.238` | 7.421 | 332° | `0.883, -0.47` / 62° | unmapped |
| 29 | `outer w34313515 edge 9` | `-49.277, 231.238` → `-64, 239.082` | 16.682 | 242° | `-0.47, -0.883` / 332° | protected unmapped |
| 30 | `outer w34313515 edge 9` | `-64, 239.082` → `-95.757, 256` | 35.982 | 242° | `-0.47, -0.883` / 332° | protected unmapped |
| 31 | `outer w34313515 edge 9` | `-95.757, 256` → `-96, 256.13` | 0.276 | 241.9° | `-0.47, -0.883` / 332° | protected unmapped |
| 32 | `outer w34313515 edge 9` | `-96, 256.13` → `-96.278, 256.278` | 0.315 | 242° | `-0.47, -0.883` / 332° | protected unmapped |
| 33 | `outer w34313515 edge 9` | `-96.278, 256.278` → `-97.023, 256.675` | 0.844 | 241.9° | `-0.47, -0.883` / 332° | protected unmapped |
| 34 | `outer w34313515 edge 10` | `-97.023, 256.675` → `-97.383, 256` | 0.765 | 331.9° | `0.883, -0.47` / 62° | unmapped |
| 35 | `outer w34313515 edge 10` | `-97.383, 256` → `-103.741, 244.051` | 13.535 | 332° | `0.883, -0.47` / 62° | unmapped |
| 36 | `outer w34313515 edge 11` | `-103.741, 244.051` → `-96, 239.928` | 8.771 | 62° | `0.47, 0.883` / 152° | protected unmapped |
| 37 | `outer w34313515 edge 11` | `-96, 239.928` → `-66.094, 224` | 33.883 | 62° | `0.47, 0.883` / 152° | protected unmapped |
| 38 | `outer w34313515 edge 11` | `-66.094, 224` → `-64, 222.885` | 2.372 | 62° | `0.47, 0.883` / 152° | protected unmapped |
| 39 | `outer w34313515 edge 11` | `-64, 222.885` → `-61.614, 221.614` | 2.703 | 62° | `0.47, 0.883` / 152° | protected unmapped |
| 40 | `outer w34313515 edge 11` | `-61.614, 221.614` → `-56.003, 218.626` | 6.357 | 62° | `0.47, 0.883` / 152° | protected unmapped |
| 41 | `outer w34313515 edge 12` | `-56.003, 218.626` → `-56.915, 216.915` | 1.939 | 331.9° | `0.883, -0.47` / 62° | unmapped |
| 42 | `outer w34313515 edge 12` | `-56.915, 216.915` → `-63.996, 203.62` | 15.063 | 332° | `0.883, -0.47` / 62° | unmapped |
| 43 | `outer w34313515 edge 13` | `-63.996, 203.62` → `-64, 203.622` | 0.004 | 243.4° | `-0.47, -0.883` / 332° | mapped `B06-34313515-NNW-OUTER` / `B06-34313515-SV02` |
| 44 | `outer w34313515 edge 13` | `-64, 203.622` → `-88.874, 216.874` | 28.184 | 242° | `-0.47, -0.883` / 332° | mapped `B06-34313515-NNW-OUTER` / `B06-34313515-SV02` |
| 45 | `outer w34313515 edge 13` | `-88.874, 216.874` → `-96, 220.67` | 8.074 | 242° | `-0.47, -0.883` / 332° | mapped `B06-34313515-NNW-OUTER` / `B06-34313515-SV02` |
| 46 | `outer w34313515 edge 13` | `-96, 220.67` → `-102.25, 224` | 7.082 | 242° | `-0.47, -0.883` / 332° | mapped `B06-34313515-NNW-OUTER` / `B06-34313515-SV02` |
| 47 | `outer w34313515 edge 13` | `-102.25, 224` → `-123.526, 235.335` | 24.107 | 242° | `-0.47, -0.883` / 332° | mapped `B06-34313515-NNW-OUTER` / `B06-34313515-SV02` |

### Unnamed frozen source — `w34313520`

Receiver `building:w34313520:wall` in `x_-1__z_0`; 34 runs / 376.239 m; base/top 3.065 / 14.065 m; height rule `osm_height` 11 m. Final partition: **5 mapped / 27 unmapped / 2 protected**; mapped length **68.156 m**.

Generated identity: `generated/world/chunks/x_-1__z_0.json` SHA-256 `b935890b89202fa181248552176364668e506a7630f0024ec86f12a084743d86`; wall-record SHA-256 `9cca96a89ae37fa189099289e5b6f956c300bf3d8051f4986971861f9e038ce5`.

**Evidence:**

- `B06-34313520-SV01` — September 2025; official panorama target identified; high target identity direction with requested seed coordinate; Long SSE-facing outer elevation; exact resolved camera coordinate was not retained. Mapping-eligible only at the bounded groups below.

**Mapped groups:**

- `B06-34313520-SSE-OUTER`: runs `6–10`; source edges `1`; 68.156 m; confidence `high_target_identity_and_source_edge_ownership_requested_seed_coordinate`; evidence `B06-34313520-SV01` (September 2025). Observed long SSE outer elevation geometry only. Checks: B06-34313520-SV01: facing 21.1–69.5°, heading 7–41.4°.

**Protected / unresolved:**

- Runs 20–21 form a similarly oriented inset SSE chain; the observation does not prove whether the glazed wing/recess belongs to this exact receiver chain.
- Exact partitions: mapped `6–10`; unmapped `0–5, 11–19, 22–33`; protected `20–21`.

| Run | Source ownership | Start XZ → end XZ (m) | Length | Bearing | Outward normal / azimuth | Final state / evidence |
|---:|---|---|---:|---:|---|---|
| 0 | `outer w34313520 edge 0` | `-213.102, 68.745` → `-207.403, 79.403` | 12.086 | 151.9° | `-0.882, 0.471` / 241.9° | unmapped |
| 1 | `outer w34313520 edge 0` | `-207.403, 79.403` → `-198.53, 96` | 18.82 | 151.9° | `-0.882, 0.471` / 241.9° | unmapped |
| 2 | `outer w34313520 edge 0` | `-198.53, 96` → `-196.255, 100.255` | 4.825 | 151.9° | `-0.882, 0.471` / 241.9° | unmapped |
| 3 | `outer w34313520 edge 0` | `-196.255, 100.255` → `-192, 108.215` | 9.026 | 151.9° | `-0.882, 0.471` / 241.9° | unmapped |
| 4 | `outer w34313520 edge 0` | `-192, 108.215` → `-185.107, 121.107` | 14.619 | 151.9° | `-0.882, 0.471` / 241.9° | unmapped |
| 5 | `outer w34313520 edge 0` | `-185.107, 121.107` → `-182.088, 126.754` | 6.403 | 151.9° | `-0.882, 0.471` / 241.9° | unmapped |
| 6 | `outer w34313520 edge 1` | `-182.088, 126.754` → `-160, 114.948` | 25.045 | 61.9° | `0.471, 0.882` / 151.9° | mapped `B06-34313520-SSE-OUTER` / `B06-34313520-SV01` |
| 7 | `outer w34313520 edge 1` | `-160, 114.948` → `-131.964, 99.964` | 31.789 | 61.9° | `0.471, 0.882` / 151.9° | mapped `B06-34313520-SSE-OUTER` / `B06-34313520-SV01` |
| 8 | `outer w34313520 edge 1` | `-131.964, 99.964` → `-128, 97.846` | 4.494 | 61.9° | `0.471, 0.882` / 151.9° | mapped `B06-34313520-SSE-OUTER` / `B06-34313520-SV01` |
| 9 | `outer w34313520 edge 1` | `-128, 97.846` → `-124.547, 96` | 3.915 | 61.9° | `0.471, 0.882` / 151.9° | mapped `B06-34313520-SSE-OUTER` / `B06-34313520-SV01` |
| 10 | `outer w34313520 edge 1` | `-124.547, 96` → `-121.978, 94.627` | 2.913 | 61.9° | `0.471, 0.882` / 151.9° | mapped `B06-34313520-SSE-OUTER` / `B06-34313520-SV01` |
| 11 | `outer w34313520 edge 2` | `-121.978, 94.627` → `-123.597, 91.597` | 3.435 | 331.9° | `0.882, -0.471` / 61.9° | unmapped |
| 12 | `outer w34313520 edge 2` | `-123.597, 91.597` → `-128, 83.353` | 9.346 | 331.9° | `0.882, -0.471` / 61.9° | unmapped |
| 13 | `outer w34313520 edge 2` | `-128, 83.353` → `-130.939, 77.851` | 6.238 | 331.9° | `0.882, -0.471` / 61.9° | unmapped |
| 14 | `outer w34313520 edge 3` | `-130.939, 77.851` → `-154.384, 90.384` | 26.585 | 241.9° | `-0.471, -0.882` / 331.9° | unmapped |
| 15 | `outer w34313520 edge 3` | `-154.384, 90.384` → `-160, 93.386` | 6.368 | 241.9° | `-0.471, -0.882` / 331.9° | unmapped |
| 16 | `outer w34313520 edge 3` | `-160, 93.386` → `-164.891, 96` | 5.546 | 241.9° | `-0.471, -0.882` / 331.9° | unmapped |
| 17 | `outer w34313520 edge 3` | `-164.891, 96` → `-178.712, 103.388` | 15.672 | 241.9° | `-0.471, -0.882` / 331.9° | unmapped |
| 18 | `outer w34313520 edge 4` | `-178.712, 103.388` → `-182.665, 96` | 8.379 | 331.9° | `0.882, -0.472` / 61.8° | unmapped |
| 19 | `outer w34313520 edge 4` | `-182.665, 96` → `-185.175, 91.31` | 5.319 | 331.8° | `0.882, -0.472` / 61.8° | unmapped |
| 20 | `outer w34313520 edge 5` | `-185.175, 91.31` → `-160, 77.855` | 28.545 | 61.9° | `0.471, 0.882` / 151.9° | protected unmapped |
| 21 | `outer w34313520 edge 5` | `-160, 77.855` → `-137.393, 65.773` | 25.633 | 61.9° | `0.471, 0.882` / 151.9° | protected unmapped |
| 22 | `outer w34313520 edge 6` | `-137.393, 65.773` → `-138.341, 64` | 2.011 | 331.9° | `0.882, -0.472` / 61.8° | unmapped |
| 23 | `outer w34313520 edge 6` | `-138.341, 64` → `-145.509, 50.6` | 15.197 | 331.9° | `0.882, -0.472` / 61.8° | unmapped |
| 24 | `outer w34313520 edge 7` | `-145.509, 50.6` → `-147.854, 51.854` | 2.659 | 241.9° | `-0.471, -0.882` / 331.9° | unmapped |
| 25 | `outer w34313520 edge 7` | `-147.854, 51.854` → `-160, 58.347` | 13.773 | 241.9° | `-0.471, -0.882` / 331.9° | unmapped |
| 26 | `outer w34313520 edge 7` | `-160, 58.347` → `-170.573, 64` | 11.989 | 241.9° | `-0.471, -0.882` / 331.9° | unmapped |
| 27 | `outer w34313520 edge 7` | `-170.573, 64` → `-192, 75.455` | 24.297 | 241.9° | `-0.471, -0.882` / 331.9° | unmapped |
| 28 | `outer w34313520 edge 7` | `-192, 75.455` → `-193.88, 76.46` | 2.132 | 241.9° | `-0.471, -0.882` / 331.9° | unmapped |
| 29 | `outer w34313520 edge 8` | `-193.88, 76.46` → `-197.566, 69.566` | 7.818 | 331.9° | `0.882, -0.472` / 61.8° | unmapped |
| 30 | `outer w34313520 edge 8` | `-197.566, 69.566` → `-200.543, 64` | 6.312 | 331.9° | `0.882, -0.472` / 61.8° | unmapped |
| 31 | `outer w34313520 edge 8` | `-200.543, 64` → `-201.363, 62.467` | 1.739 | 331.9° | `0.882, -0.472` / 61.8° | unmapped |
| 32 | `outer w34313520 edge 9` | `-201.363, 62.467` → `-204.229, 64` | 3.25 | 241.9° | `-0.472, -0.882` / 331.8° | unmapped |
| 33 | `outer w34313520 edge 9` | `-204.229, 64` → `-213.102, 68.745` | 10.062 | 241.9° | `-0.472, -0.882` / 331.8° | unmapped |

### Unnamed frozen source — `w34313525`

Receiver `building:w34313525:wall` in `x_1__z_-1`; 30 runs / 354.736 m; base/top 3.711 / 8.711 m; height rule `osm_height` 5 m. Final partition: **7 mapped / 15 unmapped / 8 protected**; mapped length **91.247 m**.

Generated identity: `generated/world/chunks/x_1__z_-1.json` SHA-256 `a952756b1c6d8d547669dffb89723c2be81d6c9a4b3afd2ae7f2dc3702a82b0d`; wall-record SHA-256 `9b54bb161241b80a0025feb6fa2ab00442d837368c300099f1d0d5ae6405a19a`.

**Evidence:**

- `B06-34313525-SV01` — March 2025; official panorama target identified; high coordinate identity; Substantial NNW-facing/inset service elevation. Mapping-eligible only at the bounded groups below.
- `B06-34313525-SV02` — March 2025; official panorama target identified; high coordinate identity; Broad opposite SSE-facing public/service elevation; camera-side address label is not a frozen target address. Mapping-eligible only at the bounded groups below.

**Mapped groups:**

- `B06-34313525-SSE-CENTRAL`: runs `8–12`; source edges `1`; 75.311 m; confidence `high_coordinate_identity_partial_source_edge`; evidence `B06-34313525-SV02` (March 2025). Observed central portion of the long SSE outer source edge only. Checks: B06-34313525-SV02: facing 3.5–80.5°, heading 28.4–52.3°.
- `B06-34313525-NNW-CENTRAL`: runs `26–27`; source edges `5`; 15.936 m; confidence `high_coordinate_identity_partial_source_edge`; evidence `B06-34313525-SV01` (March 2025). Observed central portion of the NNW outer source edge only. Checks: B06-34313525-SV01: facing 18–24.7°, heading 16.8–25.8°.

**Protected / unresolved:**

- Runs 6–7 and 24–25/28–29 are same-edge endpoint pieces outside the retained panorama-heading gate; the evidence does not prove their corner ownership.
- Runs 17–18 are a deep re-entrant SSE chain and remain protected even though their normals face the observer.
- Exact partitions: mapped `8–12, 26–27`; unmapped `0–5, 13–16, 19–23`; protected `6–7, 17–18, 24–25, 28–29`.

| Run | Source ownership | Start XZ → end XZ (m) | Length | Bearing | Outward normal / azimuth | Final state / evidence |
|---:|---|---|---:|---:|---|---|
| 0 | `outer w34313525 edge 0` | `239.041, -105.258` → `244.004, -96` | 10.504 | 151.8° | `-0.881, 0.472` / 241.8° | unmapped |
| 1 | `outer w34313525 edge 0` | `244.004, -96` → `248.19, -88.19` | 8.861 | 151.8° | `-0.881, 0.472` / 241.8° | unmapped |
| 2 | `outer w34313525 edge 0` | `248.19, -88.19` → `256, -73.618` | 16.533 | 151.8° | `-0.881, 0.472` / 241.8° | unmapped |
| 3 | `outer w34313525 edge 0` | `256, -73.618` → `259.356, -67.356` | 7.105 | 151.8° | `-0.881, 0.472` / 241.8° | unmapped |
| 4 | `outer w34313525 edge 0` | `259.356, -67.356` → `261.155, -64` | 3.808 | 151.8° | `-0.881, 0.472` / 241.8° | unmapped |
| 5 | `outer w34313525 edge 0` | `261.155, -64` → `268.833, -49.676` | 16.252 | 151.8° | `-0.881, 0.472` / 241.8° | unmapped |
| 6 | `outer w34313525 edge 1` | `268.833, -49.676` → `279.268, -55.268` | 11.839 | 61.8° | `0.472, 0.881` / 151.8° | protected unmapped |
| 7 | `outer w34313525 edge 1` | `279.268, -55.268` → `288, -59.947` | 9.907 | 61.8° | `0.472, 0.881` / 151.8° | protected unmapped |
| 8 | `outer w34313525 edge 1` | `288, -59.947` → `295.563, -64` | 8.581 | 61.8° | `0.472, 0.881` / 151.8° | mapped `B06-34313525-SSE-CENTRAL` / `B06-34313525-SV02` |
| 9 | `outer w34313525 edge 1` | `295.563, -64` → `320, -77.095` | 27.724 | 61.8° | `0.472, 0.881` / 151.8° | mapped `B06-34313525-SSE-CENTRAL` / `B06-34313525-SV02` |
| 10 | `outer w34313525 edge 1` | `320, -77.095` → `348.212, -92.212` | 32.007 | 61.8° | `0.472, 0.881` / 151.8° | mapped `B06-34313525-SSE-CENTRAL` / `B06-34313525-SV02` |
| 11 | `outer w34313525 edge 1` | `348.212, -92.212` → `352, -94.242` | 4.298 | 61.8° | `0.472, 0.881` / 151.8° | mapped `B06-34313525-SSE-CENTRAL` / `B06-34313525-SV02` |
| 12 | `outer w34313525 edge 1` | `352, -94.242` → `354.381, -95.518` | 2.701 | 61.8° | `0.472, 0.881` / 151.8° | mapped `B06-34313525-SSE-CENTRAL` / `B06-34313525-SV02` |
| 13 | `outer w34313525 edge 2` | `354.381, -95.518` → `354.123, -96` | 0.547 | 331.8° | `0.882, -0.472` / 61.8° | unmapped |
| 14 | `outer w34313525 edge 2` | `354.123, -96` → `353.383, -97.383` | 1.569 | 331.9° | `0.882, -0.472` / 61.8° | unmapped |
| 15 | `outer w34313525 edge 2` | `353.383, -97.383` → `352, -99.965` | 2.929 | 331.8° | `0.882, -0.472` / 61.8° | unmapped |
| 16 | `outer w34313525 edge 2` | `352, -99.965` → `347.575, -108.23` | 9.375 | 331.8° | `0.882, -0.472` / 61.8° | unmapped |
| 17 | `outer w34313525 edge 3` | `347.575, -108.23` → `352, -110.602` | 5.021 | 61.8° | `0.472, 0.881` / 151.8° | protected unmapped |
| 18 | `outer w34313525 edge 3` | `352, -110.602` → `362.778, -116.379` | 12.229 | 61.8° | `0.472, 0.881` / 151.8° | protected unmapped |
| 19 | `outer w34313525 edge 4` | `362.778, -116.379` → `356.547, -128` | 13.186 | 331.8° | `0.881, -0.473` / 61.8° | unmapped |
| 20 | `outer w34313525 edge 4` | `356.547, -128` → `354.96, -130.96` | 3.359 | 331.8° | `0.881, -0.473` / 61.8° | unmapped |
| 21 | `outer w34313525 edge 4` | `354.96, -130.96` → `352, -136.481` | 6.264 | 331.8° | `0.881, -0.473` / 61.8° | unmapped |
| 22 | `outer w34313525 edge 4` | `352, -136.481` → `343.791, -151.791` | 17.372 | 331.8° | `0.881, -0.473` / 61.8° | unmapped |
| 23 | `outer w34313525 edge 4` | `343.791, -151.791` → `339.793, -159.248` | 8.461 | 331.8° | `0.881, -0.473` / 61.8° | unmapped |
| 24 | `outer w34313525 edge 5` | `339.793, -159.248` → `320, -148.642` | 22.456 | 241.8° | `-0.472, -0.881` / 331.8° | protected unmapped |
| 25 | `outer w34313525 edge 5` | `320, -148.642` → `295.527, -135.527` | 27.766 | 241.8° | `-0.472, -0.881` / 331.8° | protected unmapped |
| 26 | `outer w34313525 edge 5` | `295.527, -135.527` → `288, -131.494` | 8.539 | 241.8° | `-0.472, -0.881` / 331.8° | mapped `B06-34313525-NNW-CENTRAL` / `B06-34313525-SV01` |
| 27 | `outer w34313525 edge 5` | `288, -131.494` → `281.48, -128` | 7.397 | 241.8° | `-0.472, -0.881` / 331.8° | mapped `B06-34313525-NNW-CENTRAL` / `B06-34313525-SV01` |
| 28 | `outer w34313525 edge 5` | `281.48, -128` → `256, -114.346` | 28.908 | 241.8° | `-0.472, -0.881` / 331.8° | protected unmapped |
| 29 | `outer w34313525 edge 5` | `256, -114.346` → `239.041, -105.258` | 19.241 | 241.8° | `-0.472, -0.881` / 331.8° | protected unmapped |

### Unnamed frozen source — `w34313564`

Receiver `building:w34313564:wall` in `x_0__z_-3`; 20 runs / 282.68 m; base/top 3.752 / 8.752 m; height rule `osm_height` 5 m. Final partition: **15 mapped / 4 unmapped / 1 protected**; mapped length **228.991 m**.

Generated identity: `generated/world/chunks/x_0__z_-3.json` SHA-256 `6dfa4b8f4b91f309b313428829e37cedd13e4067ff94f896a8e2e5ef05002a1d`; wall-record SHA-256 `59733d067c69238653f169983605f1b7a8197846412338a84513f985b03d685f`.

**Evidence:**

- `B06-34313564-SV01` — September 2025; official panorama target identified; high coordinate identity; Broad central SSE-facing elevation. Mapping-eligible only at the bounded groups below.
- `B06-34313564-SV02` — September 2025; official panorama target identified; high coordinate identity partial occlusion; NNW-facing elevation, partly occluded by fencing, container, vehicles and vegetation. Mapping-eligible only at the bounded groups below.
- `B06-34313564-SV03` — September 2025; official panorama target identified; high coordinate identity; ENE short end plus the eastern SSE return. Mapping-eligible only at the bounded groups below.

**Mapped groups:**

- `B06-34313564-SSE-CENTRAL`: runs `7–9`; source edges `1`; 49.373 m; confidence `high_coordinate_identity_and_source_edge_ownership`; evidence `B06-34313564-SV01` (September 2025). Observed central SSE geometry only. Checks: B06-34313564-SV01: facing 16.7–68.6°, heading 11.4–40.5°.
- `B06-34313564-SSE-EAST-RETURN`: runs `5–6`; source edges `1`; 38.278 m; confidence `high_coordinate_identity_and_source_edge_ownership`; evidence `B06-34313564-SV03` (September 2025). Observed eastern SSE return geometry only. Checks: B06-34313564-SV03: facing 83–84.5°, heading 21.1–22.6°.
- `B06-34313564-ENE-END`: runs `10–13`; source edges `2`; 43.442 m; confidence `high_coordinate_identity_and_source_edge_ownership`; evidence `B06-34313564-SV03` (September 2025). Observed ENE end geometry only. Checks: B06-34313564-SV03: facing 40.2–74.6°, heading 12.1–46.5°.
- `B06-34313564-NNW-OUTER`: runs `14–19`; source edges `3`; 97.898 m; confidence `high_coordinate_identity_partial_occlusion`; evidence `B06-34313564-SV02` (September 2025). Observed NNW geometry only; evidence is partly occluded. Checks: B06-34313564-SV02: facing 13.3–64.9°, heading 9.1–58.9°.

**Protected / unresolved:**

- Run 4 is the SSE source-edge endpoint outside the retained evidence gate; SV01 heading is too oblique and SV03 viewpoint-facing error exceeds the 85° contract.
- Exact partitions: mapped `5–19`; unmapped `0–3`; protected `4`.

| Run | Source ownership | Start XZ → end XZ (m) | Length | Bearing | Outward normal / azimuth | Final state / evidence |
|---:|---|---|---:|---:|---|---|
| 0 | `outer w34313564 edge 0` | `-15.546, -623.45` → `-7.292, -608` | 17.517 | 151.9° | `-0.882, 0.471` / 241.9° | unmapped |
| 1 | `outer w34313564 edge 0` | `-7.292, -608` → `-4.753, -603.247` | 5.389 | 151.9° | `-0.882, 0.471` / 241.9° | unmapped |
| 2 | `outer w34313564 edge 0` | `-4.753, -603.247` → `0, -594.351` | 10.086 | 151.9° | `-0.882, 0.471` / 241.9° | unmapped |
| 3 | `outer w34313564 edge 0` | `0, -594.351` → `4.924, -585.134` | 10.45 | 151.9° | `-0.882, 0.471` / 241.9° | unmapped |
| 4 | `outer w34313564 edge 1` | `4.924, -585.134` → `13.963, -589.963` | 10.248 | 61.9° | `0.471, 0.882` / 151.9° | protected unmapped |
| 5 | `outer w34313564 edge 1` | `13.963, -589.963` → `32, -599.599` | 20.45 | 61.9° | `0.471, 0.882` / 151.9° | mapped `B06-34313564-SSE-EAST-RETURN` / `B06-34313564-SV03` |
| 6 | `outer w34313564 edge 1` | `32, -599.599` → `47.725, -608` | 17.828 | 61.9° | `0.471, 0.882` / 151.9° | mapped `B06-34313564-SSE-EAST-RETURN` / `B06-34313564-SV03` |
| 7 | `outer w34313564 edge 1` | `47.725, -608` → `64, -616.695` | 18.452 | 61.9° | `0.471, 0.882` / 151.9° | mapped `B06-34313564-SSE-CENTRAL` / `B06-34313564-SV01` |
| 8 | `outer w34313564 edge 1` | `64, -616.695` → `82.668, -626.668` | 21.165 | 61.9° | `0.471, 0.882` / 151.9° | mapped `B06-34313564-SSE-CENTRAL` / `B06-34313564-SV01` |
| 9 | `outer w34313564 edge 1` | `82.668, -626.668` → `91.273, -631.265` | 9.756 | 61.9° | `0.471, 0.882` / 151.9° | mapped `B06-34313564-SSE-CENTRAL` / `B06-34313564-SV01` |
| 10 | `outer w34313564 edge 2` | `91.273, -631.265` → `89.877, -633.877` | 2.962 | 331.9° | `0.882, -0.471` / 61.9° | mapped `B06-34313564-ENE-END` / `B06-34313564-SV03` |
| 11 | `outer w34313564 edge 2` | `89.877, -633.877` → `86.606, -640` | 6.942 | 331.9° | `0.882, -0.471` / 61.9° | mapped `B06-34313564-ENE-END` / `B06-34313564-SV03` |
| 12 | `outer w34313564 edge 2` | `86.606, -640` → `78.734, -654.734` | 16.705 | 331.9° | `0.882, -0.471` / 61.9° | mapped `B06-34313564-ENE-END` / `B06-34313564-SV03` |
| 13 | `outer w34313564 edge 2` | `78.734, -654.734` → `70.802, -669.581` | 16.833 | 331.9° | `0.882, -0.471` / 61.9° | mapped `B06-34313564-ENE-END` / `B06-34313564-SV03` |
| 14 | `outer w34313564 edge 3` | `70.802, -669.581` → `64, -665.947` | 7.712 | 241.9° | `-0.471, -0.882` / 331.9° | mapped `B06-34313564-NNW-OUTER` / `B06-34313564-SV02` |
| 15 | `outer w34313564 edge 3` | `64, -665.947` → `51.004, -659.004` | 14.734 | 241.9° | `-0.471, -0.882` / 331.9° | mapped `B06-34313564-NNW-OUTER` / `B06-34313564-SV02` |
| 16 | `outer w34313564 edge 3` | `51.004, -659.004` → `32, -648.851` | 21.546 | 241.9° | `-0.471, -0.882` / 331.9° | mapped `B06-34313564-NNW-OUTER` / `B06-34313564-SV02` |
| 17 | `outer w34313564 edge 3` | `32, -648.851` → `15.432, -640` | 18.784 | 241.9° | `-0.471, -0.882` / 331.9° | mapped `B06-34313564-NNW-OUTER` / `B06-34313564-SV02` |
| 18 | `outer w34313564 edge 3` | `15.432, -640` → `0, -631.756` | 17.496 | 241.9° | `-0.471, -0.882` / 331.9° | mapped `B06-34313564-NNW-OUTER` / `B06-34313564-SV02` |
| 19 | `outer w34313564 edge 3` | `0, -631.756` → `-15.546, -623.45` | 17.626 | 241.9° | `-0.471, -0.882` / 331.9° | mapped `B06-34313564-NNW-OUTER` / `B06-34313564-SV02` |

### Unnamed frozen source — `w291196370`

Receiver `building:w291196370:wall` in `x_0__z_-3`; 36 runs / 258.421 m; base/top 3.987 / 9.987 m; height rule `osm_height` 6 m. Final partition: **9 mapped / 8 unmapped / 19 protected**; mapped length **97.893 m**.

Generated identity: `generated/world/chunks/x_0__z_-3.json` SHA-256 `6dfa4b8f4b91f309b313428829e37cedd13e4067ff94f896a8e2e5ef05002a1d`; wall-record SHA-256 `d3ebf05089e9b7ba8f22d4e47ecd8bcae135851d2c94a059d452987110a5b85c`.

**Evidence:**

- `B06-291196370-SV01` — September 2025; official panorama target identified; high coordinate identity; Clear SSE-facing public elevation. Mapping-eligible only at the bounded groups below.
- `B06-291196370-SV02` — September 2025; official panorama target identified; high coordinate identity; ENE end and oblique long-side/service-yard return. Mapping-eligible only at the bounded groups below.
- `B06-291196370-SV03` — date not retained; official panorama target not identifiable; low target identity; West-side attempt; the target is not identifiable behind an unrelated cylindrical utility structure and site equipment, so it supplies no facade claim. No run mapping authorized.

**Mapped groups:**

- `B06-291196370-SSE-PUBLIC`: runs `8–10`; source edges `1`; 43.304 m; confidence `high_coordinate_identity_and_source_edge_ownership`; evidence `B06-291196370-SV01` (September 2025). Observed SSE public-elevation geometry only. Checks: B06-291196370-SV01: facing 5.4–59.4°, heading 9.8–31.5°.
- `B06-291196370-ENE-OUTER`: runs `17–22`; source edges `8`; 54.589 m; confidence `high_coordinate_identity_and_source_edge_ownership`; evidence `B06-291196370-SV02` (September 2025). Observed ENE outer/end geometry only. Checks: B06-291196370-SV02: facing 50.4–75.5°, heading 22.6–47.7°.

**Protected / unresolved:**

- Runs 11–16 are adjacent short/service facets whose ownership the oblique end context cannot distinguish.
- Runs 23–35 are yard-hidden, re-entrant, north-side or short facets; the official west-side attempt did not identify the target and makes no facade claim.
- Exact partitions: mapped `8–10, 17–22`; unmapped `0–7`; protected `11–16, 23–35`.

| Run | Source ownership | Start XZ → end XZ (m) | Length | Bearing | Outward normal / azimuth | Final state / evidence |
|---:|---|---|---:|---:|---|---|
| 0 | `outer w291196370 edge 0` | `114.056, -728.803` → `116.389, -724.389` | 4.993 | 152.1° | `-0.884, 0.467` / 242.2° | unmapped |
| 1 | `outer w291196370 edge 0` | `116.389, -724.389` → `127.167, -704` | 23.062 | 152.1° | `-0.884, 0.467` / 242.2° | unmapped |
| 2 | `outer w291196370 edge 0` | `127.167, -704` → `127.455, -703.455` | 0.616 | 152.1° | `-0.884, 0.467` / 242.2° | unmapped |
| 3 | `outer w291196370 edge 0` | `127.455, -703.455` → `128, -702.425` | 1.165 | 152.1° | `-0.884, 0.467` / 242.2° | unmapped |
| 4 | `outer w291196370 edge 0` | `128, -702.425` → `138.522, -682.522` | 22.513 | 152.1° | `-0.884, 0.467` / 242.2° | unmapped |
| 5 | `outer w291196370 edge 0` | `138.522, -682.522` → `144.084, -672` | 11.902 | 152.1° | `-0.884, 0.467` / 242.2° | unmapped |
| 6 | `outer w291196370 edge 0` | `144.084, -672` → `149.588, -661.588` | 11.777 | 152.1° | `-0.884, 0.467` / 242.2° | unmapped |
| 7 | `outer w291196370 edge 0` | `149.588, -661.588` → `149.941, -660.921` | 0.755 | 152.1° | `-0.884, 0.467` / 242.2° | unmapped |
| 8 | `outer w291196370 edge 1` | `149.941, -660.921` → `160, -666.238` | 11.378 | 62.1° | `0.467, 0.884` / 152.2° | mapped `B06-291196370-SSE-PUBLIC` / `B06-291196370-SV01` |
| 9 | `outer w291196370 edge 1` | `160, -666.238` → `170.9, -672` | 12.329 | 62.1° | `0.467, 0.884` / 152.2° | mapped `B06-291196370-SSE-PUBLIC` / `B06-291196370-SV01` |
| 10 | `outer w291196370 edge 1` | `170.9, -672` → `188.226, -681.158` | 19.597 | 62.1° | `0.467, 0.884` / 152.2° | mapped `B06-291196370-SSE-PUBLIC` / `B06-291196370-SV01` |
| 11 | `outer w291196370 edge 2` | `188.226, -681.158` → `188.164, -681.292` | 0.148 | 335.2° | `0.908, -0.418` / 65.3° | protected unmapped |
| 12 | `outer w291196370 edge 3` | `188.164, -681.292` → `190.451, -682.505` | 2.589 | 62.1° | `0.469, 0.883` / 152° | protected unmapped |
| 13 | `outer w291196370 edge 4` | `190.451, -682.505` → `188.164, -686.836` | 4.898 | 332.2° | `0.884, -0.467` / 62.2° | protected unmapped |
| 14 | `outer w291196370 edge 5` | `188.164, -686.836` → `191.734, -688.728` | 4.04 | 62.1° | `0.468, 0.884` / 152.1° | protected unmapped |
| 15 | `outer w291196370 edge 6` | `191.734, -688.728` → `189.325, -693.292` | 5.161 | 332.2° | `0.884, -0.467` / 62.2° | protected unmapped |
| 16 | `outer w291196370 edge 7` | `189.325, -693.292` → `185.773, -691.422` | 4.014 | 242.2° | `-0.466, -0.885` / 332.2° | protected unmapped |
| 17 | `outer w291196370 edge 8` | `185.773, -691.422` → `183.576, -695.576` | 4.699 | 332.1° | `0.884, -0.467` / 62.2° | mapped `B06-291196370-ENE-OUTER` / `B06-291196370-SV02` |
| 18 | `outer w291196370 edge 8` | `183.576, -695.576` → `179.122, -704` | 9.529 | 332.1° | `0.884, -0.467` / 62.2° | mapped `B06-291196370-ENE-OUTER` / `B06-291196370-SV02` |
| 19 | `outer w291196370 edge 8` | `179.122, -704` → `172.508, -716.508` | 14.149 | 332.1° | `0.884, -0.467` / 62.2° | mapped `B06-291196370-ENE-OUTER` / `B06-291196370-SV02` |
| 20 | `outer w291196370 edge 8` | `172.508, -716.508` → `162.2, -736` | 22.05 | 332.1° | `0.884, -0.467` / 62.2° | mapped `B06-291196370-ENE-OUTER` / `B06-291196370-SV02` |
| 21 | `outer w291196370 edge 8` | `162.2, -736` → `161.439, -737.439` | 1.628 | 332.1° | `0.884, -0.467` / 62.2° | mapped `B06-291196370-ENE-OUTER` / `B06-291196370-SV02` |
| 22 | `outer w291196370 edge 8` | `161.439, -737.439` → `160.255, -739.679` | 2.534 | 332.1° | `0.884, -0.467` / 62.2° | mapped `B06-291196370-ENE-OUTER` / `B06-291196370-SV02` |
| 23 | `outer w291196370 edge 9` | `160.255, -739.679` → `160, -739.544` | 0.289 | 242.1° | `-0.469, -0.883` / 332° | protected unmapped |
| 24 | `outer w291196370 edge 9` | `160, -739.544` → `157.696, -738.321` | 2.608 | 242° | `-0.469, -0.883` / 332° | protected unmapped |
| 25 | `outer w291196370 edge 10` | `157.696, -738.321` → `154.188, -744.956` | 7.505 | 332.1° | `0.884, -0.467` / 62.2° | protected unmapped |
| 26 | `outer w291196370 edge 11` | `154.188, -744.956` → `137.244, -736` | 19.165 | 242.1° | `-0.467, -0.884` / 332.2° | protected unmapped |
| 27 | `outer w291196370 edge 11` | `137.244, -736` → `128, -731.114` | 10.456 | 242.1° | `-0.467, -0.884` / 332.2° | protected unmapped |
| 28 | `outer w291196370 edge 11` | `128, -731.114` → `124.344, -729.182` | 4.135 | 242.1° | `-0.467, -0.884` / 332.2° | protected unmapped |
| 29 | `outer w291196370 edge 12` | `124.344, -729.182` → `123.253, -731.253` | 2.341 | 332.2° | `0.885, -0.466` / 62.2° | protected unmapped |
| 30 | `outer w291196370 edge 12` | `123.253, -731.253` → `122.321, -733.022` | 1.999 | 332.2° | `0.885, -0.466` / 62.2° | protected unmapped |
| 31 | `outer w291196370 edge 13` | `122.321, -733.022` → `121.266, -732.466` | 1.193 | 242.2° | `-0.467, -0.884` / 332.2° | protected unmapped |
| 32 | `outer w291196370 edge 14` | `121.266, -732.466` → `120.044, -734.781` | 2.618 | 332.2° | `0.884, -0.467` / 62.2° | protected unmapped |
| 33 | `outer w291196370 edge 15` | `120.044, -734.781` → `114.654, -731.931` | 6.097 | 242.1° | `-0.467, -0.884` / 332.2° | protected unmapped |
| 34 | `outer w291196370 edge 16` | `114.654, -731.931` → `115.823, -729.727` | 2.495 | 152.1° | `-0.883, 0.469` / 242° | protected unmapped |
| 35 | `outer w291196370 edge 17` | `115.823, -729.727` → `114.056, -728.803` | 1.994 | 242.4° | `-0.463, -0.886` / 332.4° | protected unmapped |

### Unnamed frozen source — `r133351`

Receiver `building:r133351:wall` in `x_-2__z_-2`; 78 runs / 541.627 m; base/top 2.927 / 5.927 m; height rule `osm_levels` 3 m. Final partition: **14 mapped / 28 unmapped / 36 protected**; mapped length **117.62 m**.

Generated identity: `generated/world/chunks/x_-2__z_-2.json` SHA-256 `3a07310461da7d9e76667412c6ca18dac8bdea89923cd8392436421882132ef9`; wall-record SHA-256 `0fa04cd85da26e8c376bd1531d8bb8554675067a478ca792827023969aad8fd5`.

**Evidence:**

- `B06-133351-SV01` — March 2025; official panorama target identified; medium high coordinate relation identity; Central SSE/public frontage. Mapping-eligible only at the bounded groups below.
- `B06-133351-SV02` — March 2025; official panorama target identified; medium high coordinate relation identity; Eastern public-frontage/end context. Mapping-eligible only at the bounded groups below.
- `B06-133351-SV03` — March 2025; official panorama target identified; medium high coordinate relation identity; Western public/side frontage and material-transition context. Mapping-eligible only at the bounded groups below.
- `B06-133351-SV04` — March 2025; official panorama occlusion context only; medium relation identity occlusion only; Occlusion context only; trees and fencing hide the target edge. No run mapping authorized.

**Mapped groups:**

- `B06-133351-WESTERN-PUBLIC-OUTER`: runs `0–6`; source edges `0, 1`; 57.314 m; confidence `medium_high_relation_identity_and_outer_member_ownership`; evidence `B06-133351-SV03` (March 2025). Observed western public/side outer-member geometry only. Checks: B06-133351-SV03: facing 55.9–76.6°, heading 1.1–14.7°.
- `B06-133351-CENTRAL-EASTERN-SSE`: runs `21–22, 25, 27–28, 38, 41`; source edges `12, 14, 16, 20, 22`; 60.306 m; confidence `medium_high_relation_identity_and_outer_member_ownership`; evidence `B06-133351-SV01, B06-133351-SV02` (March 2025). Observed central/eastern SSE primary outer-member facets only. Checks: B06-133351-SV01: facing 8–58.2°, heading 0.1–55.8°; B06-133351-SV02: facing 13.1–67.5°, heading 3.2–48.5°.

**Protected / unresolved:**

- Runs 7–20 and 23–43 selected here are short, return, recessed, transition or end facets whose adjacent ownership the public views do not distinguish.
- Runs 72–77 are relation-inner courtyard faces and are hard-protected regardless of similar orientation.
- The medium-high coordinate identity does not prove exact membership of adjacent physical volumes beyond the retained primary outer facets.
- Exact partitions: mapped `0–6, 21–22, 25, 27–28, 38, 41`; unmapped `44–71`; protected `7–20, 23–24, 26, 29–37, 39–40, 42–43, 72–77`.

| Run | Source ownership | Start XZ → end XZ (m) | Length | Bearing | Outward normal / azimuth | Final state / evidence |
|---:|---|---|---:|---:|---|---|
| 0 | `outer w34313562 edge 0` | `-328.221, -507.055` → `-327.082, -504.918` | 2.422 | 151.9° | `-0.882, 0.471` / 241.9° | mapped `B06-133351-WESTERN-PUBLIC-OUTER` / `B06-133351-SV03` |
| 1 | `outer w34313562 edge 0` | `-327.082, -504.918` → `-320, -491.638` | 15.05 | 151.9° | `-0.882, 0.471` / 241.9° | mapped `B06-133351-WESTERN-PUBLIC-OUTER` / `B06-133351-SV03` |
| 2 | `outer w34313562 edge 0` | `-320, -491.638` → `-315.952, -484.048` | 8.602 | 151.9° | `-0.882, 0.471` / 241.9° | mapped `B06-133351-WESTERN-PUBLIC-OUTER` / `B06-133351-SV03` |
| 3 | `outer w34313562 edge 0` | `-315.952, -484.048` → `-313.794, -480` | 4.587 | 151.9° | `-0.882, 0.471` / 241.9° | mapped `B06-133351-WESTERN-PUBLIC-OUTER` / `B06-133351-SV03` |
| 4 | `outer w34313562 edge 0` | `-313.794, -480` → `-306.898, -467.069` | 14.655 | 151.9° | `-0.882, 0.471` / 241.9° | mapped `B06-133351-WESTERN-PUBLIC-OUTER` / `B06-133351-SV03` |
| 5 | `outer w34313562 edge 1` | `-306.898, -467.069` → `-304.823, -463.177` | 4.411 | 151.9° | `-0.882, 0.471` / 241.9° | mapped `B06-133351-WESTERN-PUBLIC-OUTER` / `B06-133351-SV03` |
| 6 | `outer w34313562 edge 1` | `-304.823, -463.177` → `-301.253, -456.482` | 7.587 | 151.9° | `-0.882, 0.471` / 241.9° | mapped `B06-133351-WESTERN-PUBLIC-OUTER` / `B06-133351-SV03` |
| 7 | `outer w34313562 edge 2` | `-301.253, -456.482` → `-306.661, -453.677` | 6.092 | 242.6° | `-0.46, -0.888` / 332.6° | protected unmapped |
| 8 | `outer w34313562 edge 3` | `-306.661, -453.677` → `-305.517, -451.451` | 2.503 | 152.8° | `-0.89, 0.457` / 242.8° | protected unmapped |
| 9 | `outer w34313562 edge 4` | `-305.517, -451.451` → `-306.203, -451.106` | 0.768 | 243.3° | `-0.449, -0.893` / 333.3° | protected unmapped |
| 10 | `outer w34313562 edge 5` | `-306.203, -451.106` → `-304.56, -448` | 3.514 | 152.1° | `-0.884, 0.468` / 242.1° | protected unmapped |
| 11 | `outer w34313562 edge 5` | `-304.56, -448` → `-298.828, -437.172` | 12.252 | 152.1° | `-0.884, 0.468` / 242.1° | protected unmapped |
| 12 | `outer w34313562 edge 5` | `-298.828, -437.172` → `-297.612, -434.875` | 2.599 | 152.1° | `-0.884, 0.468` / 242.1° | protected unmapped |
| 13 | `outer w34313562 edge 6` | `-297.612, -434.875` → `-291, -438.371` | 7.479 | 62.1° | `0.467, 0.884` / 152.2° | protected unmapped |
| 14 | `outer w34313562 edge 7` | `-291, -438.371` → `-288, -432.898` | 6.241 | 151.3° | `-0.877, 0.481` / 241.3° | protected unmapped |
| 15 | `outer w34313562 edge 7` | `-288, -432.898` → `-287.351, -431.714` | 1.35 | 151.3° | `-0.877, 0.481` / 241.3° | protected unmapped |
| 16 | `outer w34313562 edge 8` | `-287.351, -431.714` → `-265.799, -443.191` | 24.417 | 62° | `0.47, 0.883` / 152° | protected unmapped |
| 17 | `outer w34313562 edge 9` | `-265.799, -443.191` → `-268.248, -448` | 5.397 | 333° | `0.891, -0.454` / 63° | protected unmapped |
| 18 | `outer w34313562 edge 9` | `-268.248, -448` → `-270.187, -451.807` | 4.272 | 333° | `0.891, -0.454` / 63° | protected unmapped |
| 19 | `outer w34313562 edge 10` | `-270.187, -451.807` → `-257.797, -458.441` | 14.054 | 61.8° | `0.472, 0.882` / 151.8° | protected unmapped |
| 20 | `outer w34313562 edge 11` | `-257.797, -458.441` → `-256.223, -455.681` | 3.177 | 150.3° | `-0.869, 0.495` / 240.3° | protected unmapped |
| 21 | `outer w34313562 edge 12` | `-256.223, -455.681` → `-256, -455.798` | 0.252 | 62.3° | `0.464, 0.886` / 152.4° | mapped `B06-133351-CENTRAL-EASTERN-SSE` / `B06-133351-SV01, B06-133351-SV02` |
| 22 | `outer w34313562 edge 12` | `-256, -455.798` → `-245.425, -461.336` | 11.937 | 62.4° | `0.464, 0.886` / 152.4° | mapped `B06-133351-CENTRAL-EASTERN-SSE` / `B06-133351-SV01, B06-133351-SV02` |
| 23 | `outer w34313562 edge 13` | `-245.425, -461.336` → `-244.474, -459.526` | 2.045 | 152.3° | `-0.885, 0.465` / 242.3° | protected unmapped |
| 24 | `outer w34313562 edge 13` | `-244.474, -459.526` → `-242.611, -455.981` | 4.005 | 152.3° | `-0.885, 0.465` / 242.3° | protected unmapped |
| 25 | `outer w34313562 edge 14` | `-242.611, -455.981` → `-232.649, -461.38` | 11.331 | 61.5° | `0.476, 0.879` / 151.6° | mapped `B06-133351-CENTRAL-EASTERN-SSE` / `B06-133351-SV01, B06-133351-SV02` |
| 26 | `outer w34313562 edge 15` | `-232.649, -461.38` → `-235.463, -466.813` | 6.119 | 332.6° | `0.888, -0.46` / 62.6° | protected unmapped |
| 27 | `outer w34313562 edge 16` | `-235.463, -466.813` → `-224, -472.789` | 12.927 | 62.5° | `0.462, 0.887` / 152.5° | mapped `B06-133351-CENTRAL-EASTERN-SSE` / `B06-133351-SV01, B06-133351-SV02` |
| 28 | `outer w34313562 edge 16` | `-224, -472.789` → `-221.455, -474.115` | 2.87 | 62.5° | `0.462, 0.887` / 152.5° | mapped `B06-133351-CENTRAL-EASTERN-SSE` / `B06-133351-SV01, B06-133351-SV02` |
| 29 | `outer w34313562 edge 17` | `-221.455, -474.115` → `-224, -479.011` | 5.518 | 332.5° | `0.887, -0.461` / 62.5° | protected unmapped |
| 30 | `outer w34313562 edge 17` | `-224, -479.011` → `-224.338, -479.662` | 0.734 | 332.6° | `0.887, -0.461` / 62.5° | protected unmapped |
| 31 | `outer w34313562 edge 17` | `-224.338, -479.662` → `-224.514, -480` | 0.381 | 332.5° | `0.887, -0.461` / 62.5° | protected unmapped |
| 32 | `outer w34313562 edge 17` | `-224.514, -480` → `-226.432, -483.689` | 4.158 | 332.5° | `0.887, -0.461` / 62.5° | protected unmapped |
| 33 | `outer w34313562 edge 18` | `-226.432, -483.689` → `-224, -485.044` | 2.784 | 60.9° | `0.487, 0.874` / 150.9° | protected unmapped |
| 34 | `outer w34313562 edge 18` | `-224, -485.044` → `-222.537, -485.859` | 1.675 | 60.9° | `0.487, 0.874` / 150.9° | protected unmapped |
| 35 | `outer w34313562 edge 19` | `-222.537, -485.859` → `-220.976, -483.024` | 3.236 | 151.2° | `-0.876, 0.482` / 241.2° | protected unmapped |
| 36 | `outer w34313562 edge 19` | `-220.976, -483.024` → `-219.311, -480` | 3.452 | 151.2° | `-0.876, 0.482` / 241.2° | protected unmapped |
| 37 | `outer w34313562 edge 19` | `-219.311, -480` → `-214.429, -471.132` | 10.123 | 151.2° | `-0.876, 0.482` / 241.2° | protected unmapped |
| 38 | `outer w34313562 edge 20` | `-214.429, -471.132` → `-204.713, -476.297` | 11.004 | 62° | `0.469, 0.883` / 152° | mapped `B06-133351-CENTRAL-EASTERN-SSE` / `B06-133351-SV01, B06-133351-SV02` |
| 39 | `outer w34313562 edge 21` | `-204.713, -476.297` → `-206.673, -480` | 4.19 | 332.1° | `0.884, -0.468` / 62.1° | protected unmapped |
| 40 | `outer w34313562 edge 21` | `-206.673, -480` → `-207.588, -481.73` | 1.957 | 332.1° | `0.884, -0.468` / 62.1° | protected unmapped |
| 41 | `outer w34313562 edge 22` | `-207.588, -481.73` → `-198.795, -486.461` | 9.985 | 61.7° | `0.474, 0.881` / 151.7° | mapped `B06-133351-CENTRAL-EASTERN-SSE` / `B06-133351-SV01, B06-133351-SV02` |
| 42 | `outer w34313562 edge 23` | `-198.795, -486.461` → `-205.282, -498.718` | 13.868 | 332.1° | `0.884, -0.468` / 62.1° | protected unmapped |
| 43 | `outer w34313562 edge 23` | `-205.282, -498.718` → `-210.56, -508.691` | 11.284 | 332.1° | `0.884, -0.468` / 62.1° | protected unmapped |
| 44 | `outer w34313562 edge 24` | `-210.56, -508.691` → `-219.178, -504.116` | 9.757 | 242° | `-0.469, -0.883` / 332° | unmapped |
| 45 | `outer w34313562 edge 25` | `-219.178, -504.116` → `-222.15, -509.415` | 6.076 | 330.7° | `0.872, -0.489` / 60.7° | unmapped |
| 46 | `outer w34313562 edge 26` | `-222.15, -509.415` → `-224, -508.394` | 2.113 | 241.1° | `-0.483, -0.876` / 331.1° | unmapped |
| 47 | `outer w34313562 edge 26` | `-224, -508.394` → `-232.016, -503.971` | 9.155 | 241.1° | `-0.483, -0.876` / 331.1° | unmapped |
| 48 | `outer w34313562 edge 27` | `-232.016, -503.971` → `-224.207, -489.032` | 16.857 | 152.4° | `-0.886, 0.463` / 242.4° | unmapped |
| 49 | `outer w34313562 edge 28` | `-224.207, -489.032` → `-228.015, -487.039` | 4.298 | 242.4° | `-0.464, -0.886` / 332.4° | unmapped |
| 50 | `outer w34313562 edge 29` | `-228.015, -487.039` → `-233.299, -496.479` | 10.818 | 330.8° | `0.873, -0.488` / 60.8° | unmapped |
| 51 | `outer w34313562 edge 30` | `-233.299, -496.479` → `-246.744, -489.256` | 15.262 | 241.8° | `-0.473, -0.881` / 331.8° | unmapped |
| 52 | `outer w34313562 edge 30` | `-246.744, -489.256` → `-248.362, -488.386` | 1.837 | 241.7° | `-0.473, -0.881` / 331.8° | unmapped |
| 53 | `outer w34313562 edge 31` | `-248.362, -488.386` → `-251.29, -493.719` | 6.084 | 331.2° | `0.877, -0.481` / 61.3° | unmapped |
| 54 | `outer w34313562 edge 32` | `-251.29, -493.719` → `-256, -491.251` | 5.317 | 242.3° | `-0.464, -0.886` / 332.4° | unmapped |
| 55 | `outer w34313562 edge 32` | `-256, -491.251` → `-261.297, -488.475` | 5.98 | 242.3° | `-0.464, -0.886` / 332.4° | unmapped |
| 56 | `outer w34313562 edge 33` | `-261.297, -488.475` → `-258.386, -483.099` | 6.114 | 151.6° | `-0.879, 0.476` / 241.6° | unmapped |
| 57 | `outer w34313562 edge 34` | `-258.386, -483.099` → `-264.17, -480` | 6.562 | 241.8° | `-0.472, -0.881` / 331.8° | unmapped |
| 58 | `outer w34313562 edge 34` | `-264.17, -480` → `-268.006, -477.945` | 4.352 | 241.8° | `-0.472, -0.881` / 331.8° | unmapped |
| 59 | `outer w34313562 edge 35` | `-268.006, -477.945` → `-266.423, -474.984` | 3.358 | 151.9° | `-0.882, 0.471` / 241.9° | unmapped |
| 60 | `outer w34313562 edge 36` | `-266.423, -474.984` → `-278.909, -468.293` | 14.166 | 241.8° | `-0.472, -0.881` / 331.8° | unmapped |
| 61 | `outer w34313562 edge 37` | `-278.909, -468.293` → `-285.187, -480` | 13.284 | 331.8° | `0.881, -0.473` / 61.8° | unmapped |
| 62 | `outer w34313562 edge 37` | `-285.187, -480` → `-286.169, -481.831` | 2.078 | 331.8° | `0.881, -0.473` / 61.8° | unmapped |
| 63 | `outer w34313562 edge 37` | `-286.169, -481.831` → `-287.069, -483.511` | 1.906 | 331.8° | `0.881, -0.473` / 61.8° | unmapped |
| 64 | `outer w34313562 edge 38` | `-287.069, -483.511` → `-288, -485.246` | 1.969 | 331.8° | `0.881, -0.473` / 61.8° | unmapped |
| 65 | `outer w34313562 edge 38` | `-288, -485.246` → `-297.338, -502.662` | 19.761 | 331.8° | `0.881, -0.473` / 61.8° | unmapped |
| 66 | `outer w34313562 edge 38` | `-297.338, -502.662` → `-302.344, -512` | 10.595 | 331.8° | `0.881, -0.473` / 61.8° | unmapped |
| 67 | `outer w34313562 edge 38` | `-302.344, -512` → `-306.019, -518.855` | 7.778 | 331.8° | `0.881, -0.473` / 61.8° | unmapped |
| 68 | `outer w34313562 edge 39` | `-306.019, -518.855` → `-318.916, -512` | 14.606 | 242° | `-0.469, -0.883` / 332° | unmapped |
| 69 | `outer w34313562 edge 39` | `-318.916, -512` → `-320, -511.424` | 1.228 | 242° | `-0.469, -0.883` / 332° | unmapped |
| 70 | `outer w34313562 edge 39` | `-320, -511.424` → `-321.229, -510.771` | 1.392 | 242° | `-0.469, -0.883` / 332° | unmapped |
| 71 | `outer w34313562 edge 39` | `-321.229, -510.771` → `-328.221, -507.055` | 7.918 | 242° | `-0.469, -0.883` / 332° | unmapped |
| 72 | `inner w34313563 edge 0` | `-277.379, -465.499` → `-268.05, -470.353` | 10.516 | 62.5° | `0.462, 0.887` / 152.5° | protected unmapped |
| 73 | `inner w34313563 edge 1` | `-268.05, -470.353` → `-267.228, -468.772` | 1.782 | 152.5° | `-0.887, 0.461` / 242.5° | protected unmapped |
| 74 | `inner w34313563 edge 1` | `-267.228, -468.772` → `-262.809, -460.278` | 9.575 | 152.5° | `-0.887, 0.461` / 242.5° | protected unmapped |
| 75 | `inner w34313563 edge 2` | `-262.809, -460.278` → `-272.139, -455.425` | 10.517 | 242.5° | `-0.462, -0.887` / 332.5° | protected unmapped |
| 76 | `inner w34313563 edge 3` | `-272.139, -455.425` → `-275.026, -460.974` | 6.255 | 332.5° | `0.887, -0.461` / 62.5° | protected unmapped |
| 77 | `inner w34313563 edge 3` | `-275.026, -460.974` → `-277.379, -465.499` | 5.1 | 332.5° | `0.887, -0.461` / 62.5° | protected unmapped |

## Validation

- **PASS:** 261 unique source/run tokens; 64 mapped + 99 unmapped + 98 protected = 261.
- Rounded-run length partition: 769.007 + 875.997 + 767.209 = 2412.213 m; generated perimeter 2412.208 m; rounding delta 0.005 m.
- Maximum mapped viewpoint-facing error: 84.5° ≤ 85°; maximum mapped panorama-heading error: 58.9° ≤ 60°.
- The two reference-blocked targets have zero mapped runs; all six relation-inner runs and the one boundary-clip run are protected.
- No inventory/lifecycle, material, module, prototype, runtime, generated data, test, launch, capture, download or external research was changed.

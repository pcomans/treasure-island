# Batch 05 observed-side to generated-run mapping

Checked: **2026-08-29**  
Scope: all eight Batch 05 targets; local frozen evidence only. This document records geometry/provenance and does not authorize prototypes, generated-data edits, runtime attachment, modules or unique elevations.

## Result

The eight frozen wall records contain **162 runs / 1219.222 m**. **86** runs are reconciled to observations: **45** are high-confidence flat homogeneous-material candidates and **41** are constrained geometry/context only. **76** remain explicitly unmapped. Candidate scope is **45 runs / 355.781 m across 5 targets**. No prototype or live attachment exists.

| Target | Exact mappings | Candidate material runs | Attachment state | Primary blocker |
|---|---|---|---|---|
| 800 Avenue I `w34313545` | 800I-PUBLIC-WSW 0,1,2,3,4,5,6,7,8,9 (material_only_safe, 115.513 m); 800I-SERVICE-ENE-PRIMARY 15,16,18,19,20,22,24,27,28,30,31,32,33,34 (partial_observed_side, 115.524 m) | 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 | candidate_only_no_prototype_no_live_attachment | SSE source edge 1/runs 10-14 fails public-view outward-half-plane reconciliation. Intervening returns and NNW chains remain unassigned. |
| 148 12th Street `w95934119` | 14812-NNW-LONG 10,11,12,13 (material_only_safe, 46.262 m); 14812-WSW-END 0,1,2 (material_only_safe, 23.765 m) | 0, 1, 2, 10, 11, 12, 13 | candidate_only_no_prototype_no_live_attachment | SSE/ENE source edges 1-2/runs 3-9 are unobserved. |
| 1113 Keppler Court `w96665921` | 1113K-FRONT-NNE-PRIMARY 11,12,14,15,16,17,18 (material_only_safe, 58.334 m); 1113K-REAR-SSW-CONTEXT 0,2,3,4,5,8,9 (partial_observed_side, 58.340 m) | 11, 12, 14, 15, 16, 17, 18 | candidate_only_no_prototype_no_live_attachment | Short WNW/ESE returns runs 1,6,7,13,19-21 lack exact feature ownership. ESE source edge 5/run 10 is unobserved. |
| 1220 Bayside Drive `w96215652` | 1220B-FRONT-SW-PRIMARY 0,1,3,4,6,7,8,10,11 (material_only_safe, 57.063 m) | 0, 1, 3, 4, 6, 7, 8, 10, 11 | candidate_only_no_prototype_no_live_attachment | All interleaved short facets remain unassigned. Rear source edges 8,10,12,14/runs 13-14,16-18,20-21,23 have no official coverage. |
| 1227 Northpoint Drive `w96215653` | 1227N-FRONT-E-PRIMARY 4,5,6,7,9,10,11,13,14,15,16 (material_only_safe, 43.932 m); 1227N-OUTER-NORTH-END 17 (material_only_safe, 10.913 m); 1227N-DISTANT-W-REAR-CONTEXT 1,2,18,20,21 (partial_observed_side, 43.921 m) | 4, 5, 6, 7, 9, 10, 11, 13, 14, 15, 16, 17 | candidate_only_no_prototype_no_live_attachment | Short north/south facets runs 8,12,19 retain unknown ownership. South/end facets runs 0,3 are unobserved. |
| 1432 Halibut Court `w95934093` | 1432H-HISTORICAL-SSE-FRONT-PRIMARY 2,5,6,9 (historical_only_observed_side, 32.865 m); 1432H-HISTORICAL-WSW-OUTER-END 0,1 (historical_only_observed_side, 13.175 m) | none | historical_only_no_current_attachment | Same-facing short facets runs 7,8,16 are not proven outer-end ownership. Historic rear/east and other returns runs 3,4,10-15,17 remain unobserved/unassigned. |
| 1118 Hutchins Court `w96665885` | 1118H-ROW-NNE-CONTEXT 5,6,7 (provenance_only_ambiguous, 27.897 m); 1118H-ROW-ESE-END-CONTEXT 3,4 (provenance_only_ambiguous, 10.998 m) | none | blocked_no_high_confidence_target_material_scope | SSW rear and WNW end runs 0-2,8-11 are unobserved. |
| 1120 Reeves Court `w96665923` | 1120R-NW-REAR-CONTEXT 6,7 (provenance_only_ambiguous, 26.555 m); 1120R-NE-END-CONTEXT 4,5 (provenance_only_ambiguous, 10.556 m) | none | blocked_no_high_confidence_target_material_scope | SE-facing Reeves/front runs 2,3 are unobserved. Opposite-end runs 0,1 are not independently assignable; SV03 is context only. |

## Mapping detail

### 800 Avenue I — `w34313545`

Receiver `building:w34313545:wall` in `x_0__z_-2`; 40 runs / 410.748 m; base/top 3.402 / 8.402 m; height rule `osm_height` 5 m; levels tag 1. Temporal state: **september_2025_current**. Identity confidence: **high**.

**Recorded observations:**

- `800I-SV01` — official_panorama; September 2025; pano `DpzvxoYoYw9a0HnRRm8nnA`; viewpoint WGS84 `37.8263185, -122.3692567` / world XZ `152.411, -284.638`; heading 263°; east/service side; containers/screens obscure most facade; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.826317,-122.369251&heading=263&pitch=0&fov=75).
- `800I-SV02` — official_panorama; September 2025; pano `JUHhZAv7E6uzbk6wiFsTog`; viewpoint WGS84 `37.8254958, -122.3701556` / world XZ `73.37, -193.056`; heading 27°; long WSW-facing public elevation; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.825489,-122.3701307&heading=27&pitch=0&fov=75).

**Mapped scopes:**

- `800I-PUBLIC-WSW` — **material_only_safe / high**; runs `0, 1, 2, 3, 4, 5, 6, 7, 8, 9`; source edges `0`; 115.513 m; contiguous. Facing error 16.4–79.5°; heading error 36.2–36.2°. Legal: Flat light warm-gray/cream homogeneous albedo/roughness candidate after prototype and independent review. Forbidden: No modules, unique elevations, openings, unit/cadence inference, physical scale, hidden sides, short-facet propagation, massing/geometry, collision/navigation/spray, generated data, or generated-U phase.
- `800I-SERVICE-ENE-PRIMARY` — **partial_observed_side / high_geometry_coverage_occluded**; runs `15, 16, 18, 19, 20, 22, 24, 27, 28, 30, 31, 32, 33, 34`; source edges `2, 4, 6, 8, 10, 12`; 115.524 m; disjoint primary facets. Facing error 8.2–83.1°; heading error 16.3–16.3°. Legal: Geometry/provenance only; no material attachment. Forbidden: Containers/screens and all service details/returns remain excluded. No modules, unique elevations, openings, unit/cadence inference, physical scale, hidden sides, short-facet propagation, massing/geometry, collision/navigation/spray, generated data, or generated-U phase.

**Attachment state:** candidate_only_no_prototype_no_live_attachment. Only named flat homogeneous candidates after separate prototype and independent visual review; zero live attachments. No modules, unique elevations, openings, unit/cadence inference, physical scale, hidden sides, short-facet propagation, massing/geometry, collision/navigation/spray, generated data, or generated-U phase.

**Blocked / unknown:**

- SSE source edge 1/runs 10-14 fails public-view outward-half-plane reconciliation.
- Intervening returns and NNW chains remain unassigned.
- north/northwest and inner service yard
- canopy/sign regions and exact bay cadence/endpoints

| Run | Source edge | Start XZ → end XZ (m) | Bottom start/end → top start/end Y (m) | Length | Bearing | Outward normal / azimuth | Class / confidence | Attachment |
|---:|---:|---|---|---:|---:|---|---|---|
| 0 | 0 | `37.01, -304.375` → `40.975, -296.975` | `3.288, 3.264` → `8.402, 8.402` | 8.395 | 151.8° | `-0.881, 0.472` / 241.8° | material_only_safe / high (`800I-PUBLIC-WSW`) | candidate_only_no_prototype_no_attachment |
| 1 | 0 | `40.975, -296.975` → `45.782, -288` | `3.264, 3.198` → `8.402, 8.402` | 10.181 | 151.8° | `-0.881, 0.472` / 241.8° | material_only_safe / high (`800I-PUBLIC-WSW`) | candidate_only_no_prototype_no_attachment |
| 2 | 0 | `45.782, -288` → `52.137, -276.137` | `3.198, 3.292` → `8.402, 8.402` | 13.458 | 151.8° | `-0.881, 0.472` / 241.8° | material_only_safe / high (`800I-PUBLIC-WSW`) | candidate_only_no_prototype_no_attachment |
| 3 | 0 | `52.137, -276.137` → `62.923, -256` | `3.292, 3.3` → `8.402, 8.402` | 22.844 | 151.8° | `-0.881, 0.472` / 241.8° | material_only_safe / high (`800I-PUBLIC-WSW`) | candidate_only_no_prototype_no_attachment |
| 4 | 0 | `62.923, -256` → `63.299, -255.299` | `3.3, 3.306` → `8.402, 8.402` | 0.795 | 151.8° | `-0.881, 0.472` / 241.8° | material_only_safe / high (`800I-PUBLIC-WSW`) | candidate_only_no_prototype_no_attachment |
| 5 | 0 | `63.299, -255.299` → `64, -253.99` | `3.306, 3.296` → `8.402, 8.402` | 1.485 | 151.8° | `-0.881, 0.472` / 241.8° | material_only_safe / high (`800I-PUBLIC-WSW`) | candidate_only_no_prototype_no_attachment |
| 6 | 0 | `64, -253.99` → `74.461, -234.461` | `3.296, 3.271` → `8.402, 8.402` | 22.154 | 151.8° | `-0.881, 0.472` / 241.8° | material_only_safe / high (`800I-PUBLIC-WSW`) | candidate_only_no_prototype_no_attachment |
| 7 | 0 | `74.461, -234.461` → `80.065, -224` | `3.271, 3.325` → `8.402, 8.402` | 11.867 | 151.8° | `-0.881, 0.472` / 241.8° | material_only_safe / high (`800I-PUBLIC-WSW`) | candidate_only_no_prototype_no_attachment |
| 8 | 0 | `80.065, -224` → `85.623, -213.623` | `3.325, 3.381` → `8.402, 8.402` | 11.772 | 151.8° | `-0.881, 0.472` / 241.8° | material_only_safe / high (`800I-PUBLIC-WSW`) | candidate_only_no_prototype_no_attachment |
| 9 | 0 | `85.623, -213.623` → `91.554, -202.551` | `3.381, 3.355` → `8.402, 8.402` | 12.56 | 151.8° | `-0.881, 0.472` / 241.8° | material_only_safe / high (`800I-PUBLIC-WSW`) | candidate_only_no_prototype_no_attachment |
| 10 | 1 | `91.554, -202.551` → `96, -204.932` | `3.355, 3.374` → `8.402, 8.402` | 5.043 | 61.8° | `0.472, 0.882` / 151.8° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 11 | 1 | `96, -204.932` → `123.838, -219.838` | `3.374, 3.402` → `8.402, 8.402` | 31.578 | 61.8° | `0.472, 0.882` / 151.8° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 12 | 1 | `123.838, -219.838` → `128, -222.066` | `3.402, 3.402` → `8.402, 8.402` | 4.721 | 61.8° | `0.472, 0.882` / 151.8° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 13 | 1 | `128, -222.066` → `131.611, -224` | `3.402, 3.402` → `8.402, 8.402` | 4.096 | 61.8° | `0.472, 0.882` / 151.8° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 14 | 1 | `131.611, -224` → `151.699, -234.756` | `3.402, 3.293` → `8.402, 8.402` | 22.786 | 61.8° | `0.472, 0.882` / 151.8° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 15 | 2 | `151.699, -234.756` → `147.187, -243.187` | `3.293, 3.271` → `8.402, 8.402` | 9.562 | 331.8° | `0.882, -0.472` / 61.8° | partial_observed_side / high_geometry_coverage_occluded (`800I-SERVICE-ENE-PRIMARY`) | provenance_only_no_attachment |
| 16 | 2 | `147.187, -243.187` → `141.737, -253.369` | `3.271, 3.402` → `8.402, 8.402` | 11.549 | 331.8° | `0.882, -0.472` / 61.8° | partial_observed_side / high_geometry_coverage_occluded (`800I-SERVICE-ENE-PRIMARY`) | provenance_only_no_attachment |
| 17 | 3 | `141.737, -253.369` → `138.993, -251.899` | `3.402, 3.402` → `8.402, 8.402` | 3.113 | 241.8° | `-0.472, -0.882` / 331.8° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 18 | 4 | `138.993, -251.899` → `136.796, -256` | `3.402, 3.402` → `8.402, 8.402` | 4.652 | 331.8° | `0.881, -0.472` / 61.8° | partial_observed_side / high_geometry_coverage_occluded (`800I-SERVICE-ENE-PRIMARY`) | provenance_only_no_attachment |
| 19 | 4 | `136.796, -256` → `133.728, -261.728` | `3.402, 3.402` → `8.402, 8.402` | 6.498 | 331.8° | `0.881, -0.472` / 61.8° | partial_observed_side / high_geometry_coverage_occluded (`800I-SERVICE-ENE-PRIMARY`) | provenance_only_no_attachment |
| 20 | 4 | `133.728, -261.728` → `132.266, -264.456` | `3.402, 3.402` → `8.402, 8.402` | 3.095 | 331.8° | `0.881, -0.472` / 61.8° | partial_observed_side / high_geometry_coverage_occluded (`800I-SERVICE-ENE-PRIMARY`) | provenance_only_no_attachment |
| 21 | 5 | `132.266, -264.456` → `134.711, -265.77` | `3.402, 3.402` → `8.402, 8.402` | 2.776 | 61.7° | `0.473, 0.881` / 151.8° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 22 | 6 | `134.711, -265.77` → `130.226, -274.152` | `3.402, 3.402` → `8.402, 8.402` | 9.506 | 331.8° | `0.882, -0.472` / 61.8° | partial_observed_side / high_geometry_coverage_occluded (`800I-SERVICE-ENE-PRIMARY`) | provenance_only_no_attachment |
| 23 | 7 | `130.226, -274.152` → `133.823, -276.078` | `3.402, 3.402` → `8.402, 8.402` | 4.08 | 61.8° | `0.472, 0.882` / 151.8° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 24 | 8 | `133.823, -276.078` → `128.793, -285.484` | `3.402, 3.33` → `8.402, 8.402` | 10.666 | 331.9° | `0.882, -0.472` / 61.8° | partial_observed_side / high_geometry_coverage_occluded (`800I-SERVICE-ENE-PRIMARY`) | provenance_only_no_attachment |
| 25 | 9 | `128.793, -285.484` → `133.491, -288` | `3.33, 3.332` → `8.402, 8.402` | 5.329 | 61.8° | `0.472, 0.882` / 151.8° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 26 | 9 | `133.491, -288` → `141.807, -292.453` | `3.332, 3.402` → `8.402, 8.402` | 9.433 | 61.8° | `0.472, 0.882` / 151.8° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 27 | 10 | `141.807, -292.453` → `138.544, -298.544` | `3.402, 3.402` → `8.402, 8.402` | 6.91 | 331.8° | `0.882, -0.472` / 61.8° | partial_observed_side / high_geometry_coverage_occluded (`800I-SERVICE-ENE-PRIMARY`) | provenance_only_no_attachment |
| 28 | 10 | `138.544, -298.544` → `130.71, -313.17` | `3.402, 3.144` → `8.402, 8.402` | 16.592 | 331.8° | `0.882, -0.472` / 61.8° | partial_observed_side / high_geometry_coverage_occluded (`800I-SERVICE-ENE-PRIMARY`) | provenance_only_no_attachment |
| 29 | 11 | `130.71, -313.17` → `128.353, -311.901` | `3.144, 3.11` → `8.402, 8.402` | 2.677 | 241.7° | `-0.474, -0.88` / 331.7° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 30 | 12 | `128.353, -311.901` → `128, -312.561` | `3.11, 3.098` → `8.402, 8.402` | 0.748 | 331.9° | `0.882, -0.472` / 61.8° | partial_observed_side / high_geometry_coverage_occluded (`800I-SERVICE-ENE-PRIMARY`) | provenance_only_no_attachment |
| 31 | 12 | `128, -312.561` → `125.406, -317.406` | `3.098, 3.064` → `8.402, 8.402` | 5.496 | 331.8° | `0.882, -0.472` / 61.8° | partial_observed_side / high_geometry_coverage_occluded (`800I-SERVICE-ENE-PRIMARY`) | provenance_only_no_attachment |
| 32 | 12 | `125.406, -317.406` → `124.017, -320` | `3.064, 3.084` → `8.402, 8.402` | 2.942 | 331.8° | `0.882, -0.472` / 61.8° | partial_observed_side / high_geometry_coverage_occluded (`800I-SERVICE-ENE-PRIMARY`) | provenance_only_no_attachment |
| 33 | 12 | `124.017, -320` → `114.247, -338.247` | `3.084, 3.402` → `8.402, 8.402` | 20.698 | 331.8° | `0.882, -0.472` / 61.8° | partial_observed_side / high_geometry_coverage_occluded (`800I-SERVICE-ENE-PRIMARY`) | provenance_only_no_attachment |
| 34 | 12 | `114.247, -338.247` → `111.128, -344.072` | `3.402, 3.352` → `8.402, 8.402` | 6.607 | 331.8° | `0.882, -0.472` / 61.8° | partial_observed_side / high_geometry_coverage_occluded (`800I-SERVICE-ENE-PRIMARY`) | provenance_only_no_attachment |
| 35 | 13 | `111.128, -344.072` → `96, -335.97` | `3.352, 3.307` → `8.402, 8.402` | 17.161 | 241.8° | `-0.472, -0.882` / 331.8° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 36 | 13 | `96, -335.97` → `66.183, -320` | `3.307, 3.402` → `8.402, 8.402` | 33.824 | 241.8° | `-0.472, -0.882` / 331.8° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 37 | 13 | `66.183, -320` → `64, -318.831` | `3.402, 3.402` → `8.402, 8.402` | 2.476 | 241.8° | `-0.472, -0.882` / 331.8° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 38 | 13 | `64, -318.831` → `61.482, -317.482` | `3.402, 3.402` → `8.402, 8.402` | 2.857 | 241.8° | `-0.472, -0.882` / 331.8° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 39 | 13 | `61.482, -317.482` → `37.01, -304.375` | `3.402, 3.288` → `8.402, 8.402` | 27.761 | 241.8° | `-0.472, -0.882` / 331.8° | unmapped / none | blocked_unmapped_shared_placeholder_only |

### 148 12th Street — `w95934119`

Receiver `building:w95934119:wall` in `x_-2__z_-1`; 14 runs / 140.054 m; base/top 2.507 / 7.507 m; height rule `osm_height` 5 m; levels tag —. Temporal state: **march_2025_current**. Identity confidence: **high**.

**Recorded observations:**

- `148-12-SV01` — official_panorama; March 2025; pano `FdRJYtmB5yaqpgv76DvtMg`; viewpoint WGS84 `37.8256327, -122.3758242` / world XZ `-425.078, -208.295`; heading 174°; long NNW-facing elevation; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8256201,-122.3758225&heading=174&pitch=0&fov=75).
- `148-12-SV02` — official_panorama; March 2025; pano `o5S-wBfoGnE8GtfVFrTVMA`; viewpoint WGS84 `37.8253514, -122.3761863` / world XZ `-456.918, -176.981`; heading 82°; WSW end and long-side return; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8253306,-122.3761412&heading=82&pitch=0&fov=75).

**Mapped scopes:**

- `14812-NNW-LONG` — **material_only_safe / high**; runs `10, 11, 12, 13`; source edges `3`; 46.262 m; contiguous. Facing error 6.4–41.8°; heading error 14.7–14.7°. Legal: Flat aged light-gray/off-white homogeneous albedo/roughness candidate after prototype and independent review. Forbidden: No modules, unique elevations, openings, unit/cadence inference, physical scale, hidden sides, short-facet propagation, massing/geometry, collision/navigation/spray, generated data, or generated-U phase. Lower facade remains occluded.
- `14812-WSW-END` — **material_only_safe / high**; runs `0, 1, 2`; source edges `0`; 23.765 m; contiguous. Facing error 43.3–66.6°; heading error 39–39°. Legal: Flat aged light-gray/off-white homogeneous albedo/roughness candidate after prototype and independent review. Forbidden: No modules, unique elevations, openings, unit/cadence inference, physical scale, hidden sides, short-facet propagation, massing/geometry, collision/navigation/spray, generated data, or generated-U phase. Lower facade remains occluded.

**Attachment state:** candidate_only_no_prototype_no_live_attachment. Only named flat homogeneous candidates after separate prototype and independent visual review; zero live attachments. No modules, unique elevations, openings, unit/cadence inference, physical scale, hidden sides, short-facet propagation, massing/geometry, collision/navigation/spray, generated data, or generated-U phase.

**Blocked / unknown:**

- SSE/ENE source edges 1-2/runs 3-9 are unobserved.
- lower facade and openings
- clerestory cadence, damage distribution and endpoints

| Run | Source edge | Start XZ → end XZ (m) | Bottom start/end → top start/end Y (m) | Length | Bearing | Outward normal / azimuth | Class / confidence | Attachment |
|---:|---:|---|---|---:|---:|---|---|---|
| 0 | 0 | `-442.066, -175.445` → `-438.812, -169.188` | `2.169, 2.152` → `7.507, 7.507` | 7.053 | 152.5° | `-0.887, 0.461` / 242.5° | material_only_safe / high (`14812-WSW-END`) | candidate_only_no_prototype_no_attachment |
| 1 | 0 | `-438.812, -169.188` → `-434.034, -160` | `2.152, 2.249` → `7.507, 7.507` | 10.356 | 152.5° | `-0.887, 0.461` / 242.5° | material_only_safe / high (`14812-WSW-END`) | candidate_only_no_prototype_no_attachment |
| 2 | 0 | `-434.034, -160` → `-431.101, -154.361` | `2.249, 2.293` → `7.507, 7.507` | 6.356 | 152.5° | `-0.887, 0.461` / 242.5° | material_only_safe / high (`14812-WSW-END`) | candidate_only_no_prototype_no_attachment |
| 3 | 1 | `-431.101, -154.361` → `-420.255, -160` | `2.293, 2.461` → `7.507, 7.507` | 12.224 | 62.5° | `0.461, 0.887` / 152.5° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 4 | 1 | `-420.255, -160` → `-416, -162.212` | `2.461, 2.507` → `7.507, 7.507` | 4.796 | 62.5° | `0.461, 0.887` / 152.5° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 5 | 1 | `-416, -162.212` → `-411.392, -164.608` | `2.507, 2.507` → `7.507, 7.507` | 5.194 | 62.5° | `0.461, 0.887` / 152.5° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 6 | 1 | `-411.392, -164.608` → `-390.055, -175.701` | `2.507, 2.507` → `7.507, 7.507` | 24.048 | 62.5° | `0.461, 0.887` / 152.5° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 7 | 2 | `-390.055, -175.701` → `-393.56, -182.44` | `2.507, 2.507` → `7.507, 7.507` | 7.596 | 332.5° | `0.887, -0.461` / 62.5° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 8 | 2 | `-393.56, -182.44` → `-398.531, -192` | `2.507, 2.507` → `7.507, 7.507` | 10.775 | 332.5° | `0.887, -0.461` / 62.5° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 9 | 2 | `-398.531, -192` → `-401.02, -196.785` | `2.507, 2.507` → `7.507, 7.507` | 5.394 | 332.5° | `0.887, -0.461` / 62.5° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 10 | 3 | `-401.02, -196.785` → `-410.223, -192` | `2.507, 2.489` → `7.507, 7.507` | 10.373 | 242.5° | `-0.461, -0.887` / 332.5° | material_only_safe / high (`14812-NNW-LONG`) | candidate_only_no_prototype_no_attachment |
| 11 | 3 | `-410.223, -192` → `-416, -188.997` | `2.489, 2.455` → `7.507, 7.507` | 6.511 | 242.5° | `-0.461, -0.887` / 332.5° | material_only_safe / high (`14812-NNW-LONG`) | candidate_only_no_prototype_no_attachment |
| 12 | 3 | `-416, -188.997` → `-422.255, -185.745` | `2.455, 2.366` → `7.507, 7.507` | 7.05 | 242.5° | `-0.461, -0.887` / 332.5° | material_only_safe / high (`14812-NNW-LONG`) | candidate_only_no_prototype_no_attachment |
| 13 | 3 | `-422.255, -185.745` → `-442.066, -175.445` | `2.366, 2.169` → `7.507, 7.507` | 22.329 | 242.5° | `-0.461, -0.887` / 332.5° | material_only_safe / high (`14812-NNW-LONG`) | candidate_only_no_prototype_no_attachment |

### 1113 Keppler Court — `w96665921`

Receiver `building:w96665921:wall` in `x_-2__z_-2`; 22 runs / 144.427 m; base/top 2.454 / 8.454 m; height rule `osm_height` 6 m; levels tag 2. Temporal state: **2018_2019_front_november_2025_distant_rear**. Identity confidence: **high**.

**Recorded observations:**

- `1113K-SV01` — official_panorama; February 2018; pano `wwffTkz2DyE-wnlL73JVtA`; viewpoint WGS84 `37.8275988, -122.3768666` / world XZ `-516.737, -427.161`; heading 175°; broad front context; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8276235,-122.376855&heading=175&pitch=0&fov=75).
- `1113K-SV02` — official_panorama_exact_address; April 2019; pano `tgMj9xpYL0zAAAwf82nR8g`; viewpoint WGS84 `37.8273143, -122.3768473` / world XZ `-515.04, -395.49`; heading 184°; close NNE public/front; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8272912,-122.376818&heading=184&pitch=0&fov=75).
- `1113K-SV03` — official_panorama_distant; November 2025; pano `BrOH3kQaEK0IOVN30IM9FQ`; viewpoint WGS84 `37.8268889, -122.3771306` / world XZ `-539.951, -348.135`; heading 49°; distant SSW/rear; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82689,-122.3771609&heading=49&pitch=0&fov=75).

**Mapped scopes:**

- `1113K-FRONT-NNE-PRIMARY` — **material_only_safe / high**; runs `11, 12, 14, 15, 16, 17, 18`; source edges `6, 8`; 58.334 m; disjoint primary facets. Facing error 5.4–50.6°; heading error 5–30.5°. Legal: Flat cool gray-blue homogeneous albedo/roughness candidate after prototype and independent review. Forbidden: No modules, unique elevations, openings, unit/cadence inference, physical scale, hidden sides, short-facet propagation, massing/geometry, collision/navigation/spray, generated data, or generated-U phase.
- `1113K-REAR-SSW-CONTEXT` — **partial_observed_side / high_geometry_medium_appearance**; runs `0, 2, 3, 4, 5, 8, 9`; source edges `0, 2, 4`; 58.340 m; disjoint primary facets. Facing error 5.2–52.1°; heading error 4.2–4.2°. Legal: Geometry/provenance only; no rear material attachment. Forbidden: Distant/fence-hidden rear and all unit/opening inference excluded. No modules, unique elevations, openings, unit/cadence inference, physical scale, hidden sides, short-facet propagation, massing/geometry, collision/navigation/spray, generated data, or generated-U phase.

**Attachment state:** candidate_only_no_prototype_no_live_attachment. Only named flat homogeneous candidates after separate prototype and independent visual review; zero live attachments. No modules, unique elevations, openings, unit/cadence inference, physical scale, hidden sides, short-facet propagation, massing/geometry, collision/navigation/spray, generated data, or generated-U phase.

**Blocked / unknown:**

- Short WNW/ESE returns runs 1,6,7,13,19-21 lack exact feature ownership.
- ESE source edge 5/run 10 is unobserved.
- hidden lower rear
- unit widths/alternates, ends and module scale

| Run | Source edge | Start XZ → end XZ (m) | Bottom start/end → top start/end Y (m) | Length | Bearing | Outward normal / azimuth | Class / confidence | Attachment |
|---:|---:|---|---|---:|---:|---|---|---|
| 0 | 0 | `-539.969, -381.353` → `-526.981, -377.401` | `2.454, 2.408` → `8.454, 8.454` | 13.576 | 106.9° | `-0.291, 0.957` / 196.9° | partial_observed_side / high_geometry_medium_appearance (`1113K-REAR-SSW-CONTEXT`) | provenance_only_no_attachment |
| 1 | 1 | `-526.981, -377.401` → `-527.421, -375.965` | `2.408, 2.399` → `8.454, 8.454` | 1.502 | 197° | `-0.956, -0.293` / 287° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 2 | 2 | `-527.421, -375.965` → `-521.756, -374.244` | `2.399, 2.353` → `8.454, 8.454` | 5.921 | 106.9° | `-0.291, 0.957` / 196.9° | partial_observed_side / high_geometry_medium_appearance (`1113K-REAR-SSW-CONTEXT`) | provenance_only_no_attachment |
| 3 | 2 | `-521.756, -374.244` → `-512, -371.28` | `2.353, 2.454` → `8.454, 8.454` | 10.196 | 106.9° | `-0.291, 0.957` / 196.9° | partial_observed_side / high_geometry_medium_appearance (`1113K-REAR-SSW-CONTEXT`) | provenance_only_no_attachment |
| 4 | 2 | `-512, -371.28` → `-497.213, -366.787` | `2.454, 2.454` → `8.454, 8.454` | 15.455 | 106.9° | `-0.291, 0.957` / 196.9° | partial_observed_side / high_geometry_medium_appearance (`1113K-REAR-SSW-CONTEXT`) | provenance_only_no_attachment |
| 5 | 2 | `-497.213, -366.787` → `-496.935, -366.703` | `2.454, 2.454` → `8.454, 8.454` | 0.29 | 106.8° | `-0.291, 0.957` / 196.9° | partial_observed_side / high_geometry_medium_appearance (`1113K-REAR-SSW-CONTEXT`) | provenance_only_no_attachment |
| 6 | 3 | `-496.935, -366.703` → `-496.777, -367.223` | `2.454, 2.454` → `8.454, 8.454` | 0.543 | 16.9° | `0.957, 0.291` / 106.9° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 7 | 3 | `-496.777, -367.223` → `-496.038, -369.653` | `2.454, 2.454` → `8.454, 8.454` | 2.54 | 16.9° | `0.957, 0.291` / 106.9° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 8 | 4 | `-496.038, -369.653` → `-494.741, -369.259` | `2.454, 2.454` → `8.454, 8.454` | 1.356 | 106.9° | `-0.291, 0.957` / 196.9° | partial_observed_side / high_geometry_medium_appearance (`1113K-REAR-SSW-CONTEXT`) | provenance_only_no_attachment |
| 9 | 4 | `-494.741, -369.259` → `-483.693, -365.902` | `2.454, 2.41` → `8.454, 8.454` | 11.547 | 106.9° | `-0.291, 0.957` / 196.9° | partial_observed_side / high_geometry_medium_appearance (`1113K-REAR-SSW-CONTEXT`) | provenance_only_no_attachment |
| 10 | 5 | `-483.693, -365.902` → `-480.554, -376.221` | `2.41, 2.362` → `8.454, 8.454` | 10.786 | 16.9° | `0.957, 0.291` / 106.9° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 11 | 6 | `-480.554, -376.221` → `-486.094, -377.906` | `2.362, 2.406` → `8.454, 8.454` | 5.791 | 286.9° | `0.291, -0.957` / 16.9° | material_only_safe / high (`1113K-FRONT-NNE-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 12 | 6 | `-486.094, -377.906` → `-494.315, -380.407` | `2.406, 2.391` → `8.454, 8.454` | 8.593 | 286.9° | `0.291, -0.957` / 16.9° | material_only_safe / high (`1113K-FRONT-NNE-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 13 | 7 | `-494.315, -380.407` → `-494.878, -378.547` | `2.391, 2.41` → `8.454, 8.454` | 1.943 | 196.8° | `-0.957, -0.29` / 286.9° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 14 | 8 | `-494.878, -378.547` → `-512, -383.756` | `2.41, 2.379` → `8.454, 8.454` | 17.897 | 286.9° | `0.291, -0.957` / 16.9° | material_only_safe / high (`1113K-FRONT-NNE-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 15 | 8 | `-512, -383.756` → `-512.187, -383.813` | `2.379, 2.377` → `8.454, 8.454` | 0.195 | 287° | `0.291, -0.957` / 16.9° | material_only_safe / high (`1113K-FRONT-NNE-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 16 | 8 | `-512.187, -383.813` → `-512.803, -384` | `2.377, 2.382` → `8.454, 8.454` | 0.644 | 286.9° | `0.291, -0.957` / 16.9° | material_only_safe / high (`1113K-FRONT-NNE-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 17 | 8 | `-512.803, -384` → `-536.724, -391.276` | `2.382, 2.454` → `8.454, 8.454` | 25.003 | 286.9° | `0.291, -0.957` / 16.9° | material_only_safe / high (`1113K-FRONT-NNE-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 18 | 8 | `-536.724, -391.276` → `-536.926, -391.338` | `2.454, 2.454` → `8.454, 8.454` | 0.211 | 287.1° | `0.291, -0.957` / 16.9° | material_only_safe / high (`1113K-FRONT-NNE-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 19 | 9 | `-536.926, -391.338` → `-537.042, -390.958` | `2.454, 2.454` → `8.454, 8.454` | 0.397 | 197° | `-0.957, -0.291` / 286.9° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 20 | 9 | `-537.042, -390.958` → `-539.162, -384` | `2.454, 2.454` → `8.454, 8.454` | 7.274 | 196.9° | `-0.957, -0.291` / 286.9° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 21 | 9 | `-539.162, -384` → `-539.969, -381.353` | `2.454, 2.454` → `8.454, 8.454` | 2.767 | 197° | `-0.957, -0.291` / 286.9° | unmapped / none | blocked_unmapped_shared_placeholder_only |

### 1220 Bayside Drive — `w96215652`

Receiver `building:w96215652:wall` in `x_-2__z_-3`; 26 runs / 145.344 m; base/top 2.345 / 8.345 m; height rule `osm_height` 6 m; levels tag 2. Temporal state: **march_2025_front_only_no_official_rear**. Identity confidence: **high**.

**Recorded observations:**

- `1220B-SV01` — official_panorama_exact_address; March 2025; pano `y_1iTmB2k8lf_QeGek_yjQ`; viewpoint WGS84 `37.8296212, -122.3761997` / world XZ `-458.096, -652.293`; heading 1°; south/southwest public front; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8296496,-122.3762263&heading=1&pitch=0&fov=75).
- `1220B-EX01` — excluded_contributor_no_official_coverage; —; pano `—`; viewpoint WGS84 `37.8307151, -122.376857` / world XZ `-515.893, -774.066`; heading 140°; rear request; coverage evidence only; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8307151,-122.376857&heading=140&pitch=0&fov=75).

**Mapped scopes:**

- `1220B-FRONT-SW-PRIMARY` — **material_only_safe / high**; runs `0, 1, 3, 4, 6, 7, 8, 10, 11`; source edges `0, 2, 4, 6`; 57.063 m; disjoint primary facets. Facing error 0.3–67.2°; heading error 9.4–9.4°. Legal: Flat warm-gray/beige homogeneous albedo/roughness candidate after prototype and independent review. Forbidden: No modules, unique elevations, openings, unit/cadence inference, physical scale, hidden sides, short-facet propagation, massing/geometry, collision/navigation/spray, generated data, or generated-U phase. No short-facet ownership.

**Attachment state:** candidate_only_no_prototype_no_live_attachment. Only named flat homogeneous candidates after separate prototype and independent visual review; zero live attachments. No modules, unique elevations, openings, unit/cadence inference, physical scale, hidden sides, short-facet propagation, massing/geometry, collision/navigation/spray, generated data, or generated-U phase.

**Blocked / unknown:**

- All interleaved short facets remain unassigned.
- Rear source edges 8,10,12,14/runs 13-14,16-18,20-21,23 have no official coverage.
- rear and opposite end
- unit identities/alternates, privacy structures, cadence and module scale

| Run | Source edge | Start XZ → end XZ (m) | Bottom start/end → top start/end Y (m) | Length | Bearing | Outward normal / azimuth | Class / confidence | Attachment |
|---:|---:|---|---|---:|---:|---|---|---|
| 0 | 0 | `-484.229, -691.455` → `-480, -688.533` | `2.307, 2.241` → `8.345, 8.345` | 5.14 | 124.6° | `-0.569, 0.823` / 214.7° | material_only_safe / high (`1220B-FRONT-SW-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 1 | 0 | `-480, -688.533` → `-472.341, -683.24` | `2.241, 2.088` → `8.345, 8.345` | 9.31 | 124.6° | `-0.569, 0.823` / 214.7° | material_only_safe / high (`1220B-FRONT-SW-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 2 | 1 | `-472.341, -683.24` → `-473.396, -681.726` | `2.088, 2.096` → `8.345, 8.345` | 1.845 | 214.9° | `-0.82, -0.572` / 304.9° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 3 | 2 | `-473.396, -681.726` → `-471.549, -680.451` | `2.096, 2.059` → `8.345, 8.345` | 2.244 | 124.6° | `-0.568, 0.823` / 214.6° | material_only_safe / high (`1220B-FRONT-SW-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 4 | 2 | `-471.549, -680.451` → `-461.789, -673.711` | `2.059, 2.345` → `8.345, 8.345` | 11.861 | 124.6° | `-0.568, 0.823` / 214.6° | material_only_safe / high (`1220B-FRONT-SW-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 5 | 3 | `-461.789, -673.711` → `-460.787, -675.158` | `2.345, 2.345` → `8.345, 8.345` | 1.76 | 34.7° | `0.822, 0.569` / 124.7° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 6 | 4 | `-460.787, -675.158` → `-456.216, -672` | `2.345, 2.345` → `8.345, 8.345` | 5.556 | 124.6° | `-0.568, 0.823` / 214.6° | material_only_safe / high (`1220B-FRONT-SW-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 7 | 4 | `-456.216, -672` → `-451.357, -668.643` | `2.345, 2.345` → `8.345, 8.345` | 5.906 | 124.6° | `-0.568, 0.823` / 214.6° | material_only_safe / high (`1220B-FRONT-SW-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 8 | 4 | `-451.357, -668.643` → `-449.655, -667.466` | `2.345, 2.345` → `8.345, 8.345` | 2.069 | 124.7° | `-0.568, 0.823` / 214.6° | material_only_safe / high (`1220B-FRONT-SW-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 9 | 5 | `-449.655, -667.466` → `-450.666, -666.008` | `2.345, 2.345` → `8.345, 8.345` | 1.774 | 214.7° | `-0.822, -0.57` / 304.7° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 10 | 6 | `-450.666, -666.008` → `-448, -664.165` | `2.345, 2.345` → `8.345, 8.345` | 3.241 | 124.7° | `-0.569, 0.823` / 214.7° | material_only_safe / high (`1220B-FRONT-SW-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 11 | 6 | `-448, -664.165` → `-438.347, -657.492` | `2.345, 2.34` → `8.345, 8.345` | 11.735 | 124.7° | `-0.569, 0.823` / 214.7° | material_only_safe / high (`1220B-FRONT-SW-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 12 | 7 | `-438.347, -657.492` → `-432.191, -666.397` | `2.34, 2.345` → `8.345, 8.345` | 10.826 | 34.7° | `0.823, 0.569` / 124.7° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 13 | 8 | `-432.191, -666.397` → `-440.311, -672` | `2.345, 2.345` → `8.345, 8.345` | 9.865 | 304.6° | `0.568, -0.823` / 34.6° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 14 | 8 | `-440.311, -672` → `-444.387, -674.813` | `2.345, 2.345` → `8.345, 8.345` | 4.952 | 304.6° | `0.568, -0.823` / 34.6° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 15 | 9 | `-444.387, -674.813` → `-443.508, -676.082` | `2.345, 2.345` → `8.345, 8.345` | 1.544 | 34.7° | `0.822, 0.57` / 124.7° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 16 | 10 | `-443.508, -676.082` → `-443.75, -676.25` | `2.345, 2.345` → `8.345, 8.345` | 0.295 | 304.8° | `0.569, -0.823` / 34.7° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 17 | 10 | `-443.75, -676.25` → `-448, -679.188` | `2.345, 2.345` → `8.345, 8.345` | 5.167 | 304.7° | `0.569, -0.823` / 34.7° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 18 | 10 | `-448, -679.188` → `-454.957, -683.997` | `2.345, 2.241` → `8.345, 8.345` | 8.457 | 304.7° | `0.569, -0.823` / 34.7° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 19 | 11 | `-454.957, -683.997` → `-455.854, -682.706` | `2.241, 2.259` → `8.345, 8.345` | 1.572 | 214.8° | `-0.821, -0.57` / 304.8° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 20 | 12 | `-455.854, -682.706` → `-463.8, -688.2` | `2.259, 1.985` → `8.345, 8.345` | 9.66 | 304.7° | `0.569, -0.823` / 34.7° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 21 | 12 | `-463.8, -688.2` → `-467.206, -690.554` | `1.985, 2.053` → `8.345, 8.345` | 4.14 | 304.6° | `0.569, -0.823` / 34.7° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 22 | 13 | `-467.206, -690.554` → `-466.362, -691.778` | `2.053, 2.047` → `8.345, 8.345` | 1.487 | 34.6° | `0.823, 0.568` / 124.6° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 23 | 14 | `-466.362, -691.778` → `-478.311, -700.027` | `2.047, 2.286` → `8.345, 8.345` | 14.52 | 304.6° | `0.568, -0.823` / 34.6° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 24 | 15 | `-478.311, -700.027` → `-480, -697.581` | `2.286, 2.297` → `8.345, 8.345` | 2.972 | 214.6° | `-0.823, -0.568` / 304.6° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 25 | 15 | `-480, -697.581` → `-484.229, -691.455` | `2.297, 2.307` → `8.345, 8.345` | 7.444 | 214.6° | `-0.823, -0.568` / 304.6° | unmapped / none | blocked_unmapped_shared_placeholder_only |

### 1227 Northpoint Drive — `w96215653`

Receiver `building:w96215653:wall` in `x_-2__z_-4`; 22 runs / 115.841 m; base/top 1.952 / 7.952 m; height rule `osm_height` 6 m; levels tag 2. Temporal state: **march_2025_front_and_distant_ambiguous_rear**. Identity confidence: **high_front_medium_rear**.

**Recorded observations:**

- `1227N-SV01` — official_panorama_exact_address; March 2025; pano `kTg6yZ_s4Mxm8SssPFhnfg`; viewpoint WGS84 `37.8309911, -122.3745776` / world XZ `-315.463, -804.79`; heading 224°; east/front and outer north end; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.830976,-122.3745747&heading=224&pitch=0&fov=75).
- `1227N-SV02` — official_panorama_distant_multiple_rows; March 2025; pano `3GnbRQIwA2Bqn39tvao7wg`; viewpoint WGS84 `37.8305929, -122.3754959` / world XZ `-396.21, -760.462`; heading 81°; distant west/rear context; medium target specificity; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8305871,-122.3754849&heading=81&pitch=0&fov=75).

**Mapped scopes:**

- `1227N-FRONT-E-PRIMARY` — **material_only_safe / high**; runs `4, 5, 6, 7, 9, 10, 11, 13, 14, 15, 16`; source edges `3, 4, 5, 7, 8, 9, 11, 12, 13`; 43.932 m; disjoint primary facets. Facing error 27.6–71°; heading error 10.8–10.8°. Legal: Flat cool-gray homogeneous albedo/roughness candidate after prototype and independent review. Forbidden: No modules, unique elevations, openings, unit/cadence inference, physical scale, hidden sides, short-facet propagation, massing/geometry, collision/navigation/spray, generated data, or generated-U phase. Carport ownership excluded.
- `1227N-OUTER-NORTH-END` — **material_only_safe / high**; runs `17`; source edges `14`; 10.913 m; contiguous. Facing error 73.2–73.2°; heading error 31.6–31.6°. Legal: Flat cool-gray homogeneous albedo/roughness candidate after prototype and independent review. Forbidden: No modules, unique elevations, openings, unit/cadence inference, physical scale, hidden sides, short-facet propagation, massing/geometry, collision/navigation/spray, generated data, or generated-U phase. No end/gable module.
- `1227N-DISTANT-W-REAR-CONTEXT` — **partial_observed_side / medium_target_specific_multirow**; runs `1, 2, 18, 20, 21`; source edges `1, 15, 17`; 43.921 m; disjoint primary facets. Facing error 3.8–33.5°; heading error 6.6–6.6°. Legal: Geometry/provenance only; no rear material attachment. Forbidden: Multiple-row/carport ambiguity. No modules, unique elevations, openings, unit/cadence inference, physical scale, hidden sides, short-facet propagation, massing/geometry, collision/navigation/spray, generated data, or generated-U phase.

**Attachment state:** candidate_only_no_prototype_no_live_attachment. Only named flat homogeneous candidates after separate prototype and independent visual review; zero live attachments. No modules, unique elevations, openings, unit/cadence inference, physical scale, hidden sides, short-facet propagation, massing/geometry, collision/navigation/spray, generated data, or generated-U phase.

**Blocked / unknown:**

- Short north/south facets runs 8,12,19 retain unknown ownership.
- South/end facets runs 0,3 are unobserved.
- rear target ownership among multiple rows
- carport ownership, south end, unit identities/cadence and module scale

| Run | Source edge | Start XZ → end XZ (m) | Bottom start/end → top start/end Y (m) | Length | Bearing | Outward normal / azimuth | Class / confidence | Attachment |
|---:|---:|---|---|---:|---:|---|---|---|
| 0 | 0 | `-346.397, -769.869` → `-344.462, -769.791` | `1.911, 1.919` → `7.952, 7.952` | 1.937 | 92.3° | `-0.04, 0.999` / 182.3° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 1 | 1 | `-344.462, -769.791` → `-344.539, -768` | `1.919, 1.921` → `7.952, 7.952` | 1.793 | 182.5° | `-0.999, -0.043` / 272.5° | partial_observed_side / medium_target_specific_multirow (`1227N-DISTANT-W-REAR-CONTEXT`) | provenance_only_no_attachment |
| 2 | 1 | `-344.539, -768` → `-345.078, -755.342` | `1.921, 1.952` → `7.952, 7.952` | 12.669 | 182.4° | `-0.999, -0.043` / 272.5° | partial_observed_side / medium_target_specific_multirow (`1227N-DISTANT-W-REAR-CONTEXT`) | provenance_only_no_attachment |
| 3 | 2 | `-345.078, -755.342` → `-334.174, -754.874` | `1.952, 1.952` → `7.952, 7.952` | 10.914 | 92.5° | `-0.043, 0.999` / 182.5° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 4 | 3 | `-334.174, -754.874` → `-333.998, -759.227` | `1.952, 1.952` → `7.952, 7.952` | 4.357 | 2.3° | `0.999, 0.04` / 92.3° | material_only_safe / high (`1227N-FRONT-E-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 5 | 4 | `-333.998, -759.227` → `-333.735, -766.006` | `1.952, 1.952` → `7.952, 7.952` | 6.784 | 2.2° | `0.999, 0.039` / 92.2° | material_only_safe / high (`1227N-FRONT-E-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 6 | 5 | `-333.735, -766.006` → `-333.625, -768` | `1.952, 1.952` → `7.952, 7.952` | 1.997 | 3.2° | `0.998, 0.055` / 93.2° | material_only_safe / high (`1227N-FRONT-E-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 7 | 5 | `-333.625, -768` → `-333.559, -769.201` | `1.952, 1.952` → `7.952, 7.952` | 1.203 | 3.1° | `0.998, 0.055` / 93.2° | material_only_safe / high (`1227N-FRONT-E-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 8 | 6 | `-333.559, -769.201` → `-334.878, -769.257` | `1.952, 1.952` → `7.952, 7.952` | 1.32 | 272.4° | `0.042, -0.999` / 2.4° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 9 | 7 | `-334.878, -769.257` → `-334.702, -773.208` | `1.952, 1.952` → `7.952, 7.952` | 3.955 | 2.6° | `0.999, 0.044` / 92.5° | material_only_safe / high (`1227N-FRONT-E-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 10 | 8 | `-334.702, -773.208` → `-334.438, -779.698` | `1.952, 1.949` → `7.952, 7.952` | 6.495 | 2.3° | `0.999, 0.041` / 92.4° | material_only_safe / high (`1227N-FRONT-E-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 11 | 9 | `-334.438, -779.698` → `-334.262, -783.784` | `1.949, 1.945` → `7.952, 7.952` | 4.09 | 2.5° | `0.999, 0.043` / 92.5° | material_only_safe / high (`1227N-FRONT-E-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 12 | 10 | `-334.262, -783.784` → `-333.119, -783.728` | `1.945, 1.95` → `7.952, 7.952` | 1.144 | 92.8° | `-0.049, 0.999` / 182.8° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 13 | 11 | `-333.119, -783.728` → `-332.994, -787.006` | `1.95, 1.946` → `7.952, 7.952` | 3.28 | 2.2° | `0.999, 0.038` / 92.2° | material_only_safe / high (`1227N-FRONT-E-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 14 | 11 | `-332.994, -787.006` → `-332.943, -788.348` | `1.946, 1.945` → `7.952, 7.952` | 1.343 | 2.2° | `0.999, 0.038` / 92.2° | material_only_safe / high (`1227N-FRONT-E-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 15 | 12 | `-332.943, -788.348` → `-332.679, -794.827` | `1.945, 1.94` → `7.952, 7.952` | 6.484 | 2.3° | `0.999, 0.041` / 92.4° | material_only_safe / high (`1227N-FRONT-E-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 16 | 13 | `-332.679, -794.827` → `-332.504, -798.767` | `1.94, 1.937` → `7.952, 7.952` | 3.944 | 2.5° | `0.999, 0.045` / 92.6° | material_only_safe / high (`1227N-FRONT-E-PRIMARY`) | candidate_only_no_prototype_no_attachment |
| 17 | 14 | `-332.504, -798.767` → `-343.407, -799.224` | `1.937, 1.893` → `7.952, 7.952` | 10.913 | 272.4° | `0.042, -0.999` / 2.4° | material_only_safe / high (`1227N-OUTER-NORTH-END`) | candidate_only_no_prototype_no_attachment |
| 18 | 15 | `-343.407, -799.224` → `-344.023, -784.908` | `1.893, 1.905` → `7.952, 7.952` | 14.329 | 182.5° | `-0.999, -0.043` / 272.5° | partial_observed_side / medium_target_specific_multirow (`1227N-DISTANT-W-REAR-CONTEXT`) | provenance_only_no_attachment |
| 19 | 16 | `-344.023, -784.908` → `-345.781, -784.986` | `1.905, 1.898` → `7.952, 7.952` | 1.76 | 272.5° | `0.044, -0.999` / 2.5° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 20 | 17 | `-345.781, -784.986` → `-346.238, -773.762` | `1.898, 1.907` → `7.952, 7.952` | 11.233 | 182.3° | `-0.999, -0.041` / 272.4° | partial_observed_side / medium_target_specific_multirow (`1227N-DISTANT-W-REAR-CONTEXT`) | provenance_only_no_attachment |
| 21 | 17 | `-346.238, -773.762` → `-346.397, -769.869` | `1.907, 1.911` → `7.952, 7.952` | 3.896 | 182.3° | `-0.999, -0.041` / 272.4° | partial_observed_side / medium_target_specific_multirow (`1227N-DISTANT-W-REAR-CONTEXT`) | provenance_only_no_attachment |

### 1432 Halibut Court — `w95934093`

Receiver `building:w95934093:wall` in `x_-2__z_-1`; 18 runs / 110.809 m; base/top 2.771 / 8.771 m; height rule `osm_height` 6 m; levels tag —. Temporal state: **may_2011_historical_building_march_2025_cleared_site**. Identity confidence: **medium_high_historical**.

**Recorded observations:**

- `1432H-SV01-current` — official_panorama_current_cleared_site; March 2025; pano `VVYoE1kb2gHZtUgVXqLkWA`; viewpoint WGS84 `37.8247226, -122.3751776` / world XZ `-368.221, -106.984`; heading 14°; empty grass/concrete pad; no standing target; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8247278,-122.3751386&heading=14&pitch=0&fov=75).
- `1432H-SV02-historical` — official_panorama_historical; May 2011; pano `TIe_SHu9hj0VKcEz2bBI7g`; viewpoint WGS84 `37.82471, -122.3751972` / world XZ `-369.945, -105.581`; heading 14°; historical south/front and west end; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8247278,-122.3751386&heading=14&pitch=0&fov=75).

**Mapped scopes:**

- `1432H-HISTORICAL-SSE-FRONT-PRIMARY` — **historical_only_observed_side / high_geometry_medium_high_historical_identity**; runs `2, 5, 6, 9`; source edges `1, 3, 5`; 32.865 m; disjoint primary facets. Facing error 48.9–70.2°; heading error 18.8–18.8°. Legal: Historical geometry/provenance only; no current or whole-run material candidate. Forbidden: Current site cleared; cream/brick/garage vertical regions do not align to proven whole-run fields. No modules, unique elevations, openings, unit/cadence inference, physical scale, hidden sides, short-facet propagation, massing/geometry, collision/navigation/spray, generated data, or generated-U phase.
- `1432H-HISTORICAL-WSW-OUTER-END` — **historical_only_observed_side / high_geometry_medium_high_historical_identity**; runs `0, 1`; source edges `0`; 13.175 m; contiguous. Facing error 61.7–68.8°; heading error 16–16°. Legal: Historical geometry/provenance only; no current or whole-run material candidate. Forbidden: Current site cleared; same-facing short facets remain excluded. No modules, unique elevations, openings, unit/cadence inference, physical scale, hidden sides, short-facet propagation, massing/geometry, collision/navigation/spray, generated data, or generated-U phase.

**Attachment state:** historical_only_no_current_attachment. No current/live material scope. No modules, unique elevations, openings, unit/cadence inference, physical scale, hidden sides, short-facet propagation, massing/geometry, collision/navigation/spray, generated data, or generated-U phase.

**Blocked / unknown:**

- Same-facing short facets runs 7,8,16 are not proven outer-end ownership.
- Historic rear/east and other returns runs 3,4,10-15,17 remain unobserved/unassigned.
- no current facade
- historic rear/east, use/levels, dimensions, cadence and module scale

| Run | Source edge | Start XZ → end XZ (m) | Bottom start/end → top start/end Y (m) | Length | Bearing | Outward normal / azimuth | Class / confidence | Attachment |
|---:|---:|---|---|---:|---:|---|---|---|
| 0 | 0 | `-373.409, -132.954` → `-370.96, -128` | `2.735, 2.729` → `8.771, 8.771` | 5.526 | 153.7° | `-0.896, 0.443` / 243.7° | historical_only_observed_side / high_geometry_medium_high_historical_identity (`1432H-HISTORICAL-WSW-OUTER-END`) | historical_geometry_only_no_current_attachment |
| 1 | 0 | `-370.96, -128` → `-367.571, -121.143` | `2.729, 2.679` → `8.771, 8.771` | 7.649 | 153.7° | `-0.896, 0.443` / 243.7° | historical_only_observed_side / high_geometry_medium_high_historical_identity (`1432H-HISTORICAL-WSW-OUTER-END`) | historical_geometry_only_no_current_attachment |
| 2 | 1 | `-367.571, -121.143` → `-357.344, -126.208` | `2.679, 2.724` → `8.771, 8.771` | 11.413 | 63.7° | `0.444, 0.896` / 153.6° | historical_only_observed_side / high_geometry_medium_high_historical_identity (`1432H-HISTORICAL-SSE-FRONT-PRIMARY`) | historical_geometry_only_no_current_attachment |
| 3 | 2 | `-357.344, -126.208` → `-358.232, -128` | `2.724, 2.737` → `8.771, 8.771` | 2 | 333.6° | `0.896, -0.444` / 63.6° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 4 | 2 | `-358.232, -128` → `-359.859, -131.285` | `2.737, 2.741` → `8.771, 8.771` | 3.666 | 333.7° | `0.896, -0.444` / 63.6° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 5 | 3 | `-359.859, -131.285` → `-352, -135.165` | `2.741, 2.752` → `8.771, 8.771` | 8.765 | 63.7° | `0.443, 0.897` / 153.7° | historical_only_observed_side / high_geometry_medium_high_historical_identity (`1432H-HISTORICAL-SSE-FRONT-PRIMARY`) | historical_geometry_only_no_current_attachment |
| 6 | 3 | `-352, -135.165` → `-350.705, -135.804` | `2.752, 2.771` → `8.771, 8.771` | 1.444 | 63.7° | `0.443, 0.897` / 153.7° | historical_only_observed_side / high_geometry_medium_high_historical_identity (`1432H-HISTORICAL-SSE-FRONT-PRIMARY`) | historical_geometry_only_no_current_attachment |
| 7 | 4 | `-350.705, -135.804` → `-348.554, -131.446` | `2.771, 2.771` → `8.771, 8.771` | 4.86 | 153.7° | `-0.897, 0.443` / 243.7° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 8 | 4 | `-348.554, -131.446` → `-348.287, -130.906` | `2.771, 2.771` → `8.771, 8.771` | 0.602 | 153.7° | `-0.897, 0.443` / 243.7° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 9 | 5 | `-348.287, -130.906` → `-338.21, -135.893` | `2.771, 2.771` → `8.771, 8.771` | 11.243 | 63.7° | `0.444, 0.896` / 153.6° | historical_only_observed_side / high_geometry_medium_high_historical_identity (`1432H-HISTORICAL-SSE-FRONT-PRIMARY`) | historical_geometry_only_no_current_attachment |
| 10 | 6 | `-338.21, -135.893` → `-340.162, -139.838` | `2.771, 2.771` → `8.771, 8.771` | 4.402 | 333.7° | `0.896, -0.443` / 63.7° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 11 | 6 | `-340.162, -139.838` → `-344.322, -148.25` | `2.771, 2.771` → `8.771, 8.771` | 9.384 | 333.7° | `0.896, -0.443` / 63.7° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 12 | 7 | `-344.322, -148.25` → `-347.918, -146.48` | `2.771, 2.771` → `8.771, 8.771` | 4.008 | 243.8° | `-0.442, -0.897` / 333.8° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 13 | 8 | `-347.918, -146.48` → `-349.29, -149.252` | `2.771, 2.771` → `8.771, 8.771` | 3.093 | 333.7° | `0.896, -0.444` / 63.6° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 14 | 9 | `-349.29, -149.252` → `-352, -147.911` | `2.771, 2.771` → `8.771, 8.771` | 3.024 | 243.7° | `-0.443, -0.896` / 333.7° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 15 | 9 | `-352, -147.911` → `-372.038, -137.997` | `2.771, 2.743` → `8.771, 8.771` | 22.356 | 243.7° | `-0.443, -0.896` / 333.7° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 16 | 10 | `-372.038, -137.997` → `-370.305, -134.491` | `2.743, 2.739` → `8.771, 8.771` | 3.911 | 153.7° | `-0.897, 0.443` / 243.7° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 17 | 11 | `-370.305, -134.491` → `-373.409, -132.954` | `2.739, 2.735` → `8.771, 8.771` | 3.464 | 243.7° | `-0.444, -0.896` / 333.6° | unmapped / none | blocked_unmapped_shared_placeholder_only |

### 1118 Hutchins Court — `w96665885`

Receiver `building:w96665885:wall` in `x_-2__z_-2`; 12 runs / 77.779 m; base/top 2.351 / 8.351 m; height rule `osm_height` 6 m; levels tag 2. Temporal state: **april_2019_neighbor_labeled_views**. Identity confidence: **medium_target_specific**.

**Recorded observations:**

- `1118H-SV01` — official_panorama_neighbor_label_1116; April 2019; pano `XU1w3TFYLhKboWObJpe76A`; viewpoint WGS84 `37.8279285, -122.3764638` / world XZ `-481.319, -463.863`; heading 287°; row ESE end/return; displayed neighbor 1116; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8279184,-122.3764576&heading=287&pitch=0&fov=75).
- `1118H-SV02` — official_panorama_neighbor_label_1114; April 2019; pano `I2Dk_vOGXwebdfpTi5JLzg`; viewpoint WGS84 `37.8282512, -122.3767328` / world XZ `-504.972, -499.786`; heading 166°; row NNE public side; displayed neighbor 1114; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8282685,-122.3767654&heading=166&pitch=0&fov=75).

**Mapped scopes:**

- `1118H-ROW-NNE-CONTEXT` — **provenance_only_ambiguous / medium_address_boundary**; runs `5, 6, 7`; source edges `2`; 27.897 m; contiguous. Facing error 2.2–60.7°; heading error 11.9–11.9°. Legal: Geometry/provenance only; no target-specific material attachment. Forbidden: 1114/1118 boundary unresolved. No modules, unique elevations, openings, unit/cadence inference, physical scale, hidden sides, short-facet propagation, massing/geometry, collision/navigation/spray, generated data, or generated-U phase.
- `1118H-ROW-ESE-END-CONTEXT` — **provenance_only_ambiguous / medium_address_boundary**; runs `3, 4`; source edges `1`; 10.998 m; contiguous. Facing error 41.4–59.2°; heading error 51.8–51.8°. Legal: Geometry/provenance only; no target-specific material attachment. Forbidden: 1116/1118 boundary unresolved. No modules, unique elevations, openings, unit/cadence inference, physical scale, hidden sides, short-facet propagation, massing/geometry, collision/navigation/spray, generated data, or generated-U phase.

**Attachment state:** blocked_no_high_confidence_target_material_scope. No current/live material scope. No modules, unique elevations, openings, unit/cadence inference, physical scale, hidden sides, short-facet propagation, massing/geometry, collision/navigation/spray, generated data, or generated-U phase.

**Blocked / unknown:**

- SSW rear and WNW end runs 0-2,8-11 are unobserved.
- exact 1118 unit/address boundary
- rear/end, target material, cadence and module scale

| Run | Source edge | Start XZ → end XZ (m) | Bottom start/end → top start/end Y (m) | Length | Bearing | Outward normal / azimuth | Class / confidence | Attachment |
|---:|---:|---|---|---:|---:|---|---|---|
| 0 | 0 | `-513.8, -476.609` → `-512, -476.067` | `2.351, 2.351` → `8.351, 8.351` | 1.88 | 106.8° | `-0.288, 0.958` / 196.7° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 1 | 0 | `-512, -476.067` → `-490.426, -469.574` | `2.351, 2.104` → `8.351, 8.351` | 22.53 | 106.7° | `-0.288, 0.958` / 196.7° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 2 | 0 | `-490.426, -469.574` → `-487.096, -468.572` | `2.104, 2.081` → `8.351, 8.351` | 3.477 | 106.7° | `-0.288, 0.958` / 196.7° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 3 | 1 | `-487.096, -468.572` → `-485.226, -474.774` | `2.081, 2.089` → `8.351, 8.351` | 6.478 | 16.8° | `0.957, 0.289` / 106.8° | provenance_only_ambiguous / medium_address_boundary (`1118H-ROW-ESE-END-CONTEXT`) | provenance_only_no_attachment |
| 4 | 1 | `-485.226, -474.774` → `-483.921, -479.102` | `2.089, 2.121` → `8.351, 8.351` | 4.52 | 16.8° | `0.957, 0.289` / 106.8° | provenance_only_ambiguous / medium_address_boundary (`1118H-ROW-ESE-END-CONTEXT`) | provenance_only_no_attachment |
| 5 | 2 | `-483.921, -479.102` → `-486.905, -480` | `2.121, 2.177` → `8.351, 8.351` | 3.116 | 286.7° | `0.288, -0.958` / 16.7° | provenance_only_ambiguous / medium_address_boundary (`1118H-ROW-NNE-CONTEXT`) | provenance_only_no_attachment |
| 6 | 2 | `-486.905, -480` → `-506.196, -485.804` | `2.177, 2.351` → `8.351, 8.351` | 20.145 | 286.7° | `0.288, -0.958` / 16.7° | provenance_only_ambiguous / medium_address_boundary (`1118H-ROW-NNE-CONTEXT`) | provenance_only_no_attachment |
| 7 | 2 | `-506.196, -485.804` → `-510.635, -487.14` | `2.351, 2.351` → `8.351, 8.351` | 4.636 | 286.8° | `0.288, -0.958` / 16.7° | provenance_only_ambiguous / medium_address_boundary (`1118H-ROW-NNE-CONTEXT`) | provenance_only_no_attachment |
| 8 | 3 | `-510.635, -487.14` → `-512, -482.598` | `2.351, 2.351` → `8.351, 8.351` | 4.743 | 196.7° | `-0.958, -0.288` / 286.7° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 9 | 3 | `-512, -482.598` → `-512.781, -480` | `2.351, 2.351` → `8.351, 8.351` | 2.713 | 196.7° | `-0.958, -0.288` / 286.7° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 10 | 3 | `-512.781, -480` → `-513.117, -478.883` | `2.351, 2.351` → `8.351, 8.351` | 1.166 | 196.7° | `-0.958, -0.288` / 286.7° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 11 | 3 | `-513.117, -478.883` → `-513.8, -476.609` | `2.351, 2.351` → `8.351, 8.351` | 2.374 | 196.7° | `-0.958, -0.288` / 286.7° | unmapped / none | blocked_unmapped_shared_placeholder_only |

### 1120 Reeves Court — `w96665923`

Receiver `building:w96665923:wall` in `x_-2__z_-3`; 8 runs / 74.220 m; base/top 2.144 / 8.144 m; height rule `osm_height` 6 m; levels tag —. Temporal state: **january_2023_gateview_side_context_no_front**. Identity confidence: **medium_target_specific**.

**Recorded observations:**

- `1120R-SV01` — official_panorama_no_1120_label; January 2023; pano `nGJC_da78eTfX_I7bzioog`; viewpoint WGS84 `37.8290594, -122.3766738` / world XZ `-499.784, -589.754`; heading 191°; north/rear and end context; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8290483,-122.3765868&heading=191&pitch=0&fov=75).
- `1120R-SV02` — official_panorama_no_1120_label; January 2023; pano `YWCbQWgG3xXBD4vgISBvZA`; viewpoint WGS84 `37.8289166, -122.3768151` / world XZ `-512.209, -573.858`; heading 102°; closer north/rear context behind fence; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8289051,-122.3768274&heading=102&pitch=0&fov=75).
- `1120R-SV03` — official_panorama_context_only; January 2023; pano `KutMYle4h8SilNovRTRCSg`; viewpoint WGS84 `37.828758, -122.3769332` / world XZ `-522.594, -556.202`; heading 0°; broad context; no assignable front detail; [recorded request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8286408,-122.3766416&heading=0&pitch=0&fov=75).

**Mapped scopes:**

- `1120R-NW-REAR-CONTEXT` — **provenance_only_ambiguous / medium_target_identity**; runs `6, 7`; source edges `3`; 26.555 m; contiguous. Facing error 7.5–22.1°; heading error 8.6–22.5°. Legal: Geometry/provenance only; no target-specific material attachment. Forbidden: No 1120 label; lower rear hidden. No modules, unique elevations, openings, unit/cadence inference, physical scale, hidden sides, short-facet propagation, massing/geometry, collision/navigation/spray, generated data, or generated-U phase.
- `1120R-NE-END-CONTEXT` — **provenance_only_ambiguous / medium_target_identity_grazing**; runs `4, 5`; source edges `2`; 10.556 m; contiguous. Facing error 82.3–84.2°; heading error 59–59°. Legal: Geometry/provenance only; no target-specific material attachment. Forbidden: Grazing end context and no 1120 label. No modules, unique elevations, openings, unit/cadence inference, physical scale, hidden sides, short-facet propagation, massing/geometry, collision/navigation/spray, generated data, or generated-U phase.

**Attachment state:** blocked_no_high_confidence_target_material_scope. No current/live material scope. No modules, unique elevations, openings, unit/cadence inference, physical scale, hidden sides, short-facet propagation, massing/geometry, collision/navigation/spray, generated data, or generated-U phase.

**Blocked / unknown:**

- SE-facing Reeves/front runs 2,3 are unobserved.
- Opposite-end runs 0,1 are not independently assignable; SV03 is context only.
- Reeves/front/south side
- exact 1120 ownership, lower entry sequence, cadence and module scale

| Run | Source edge | Start XZ → end XZ (m) | Bottom start/end → top start/end Y (m) | Length | Bearing | Outward normal / azimuth | Class / confidence | Attachment |
|---:|---:|---|---|---:|---:|---|---|---|
| 0 | 0 | `-506.256, -559.041` → `-500.828, -555.172` | `2.108, 2.144` → `8.144, 8.144` | 6.666 | 125.5° | `-0.58, 0.814` / 215.5° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 1 | 0 | `-500.828, -555.172` → `-497.665, -552.918` | `2.144, 2.144` → `8.144, 8.144` | 3.884 | 125.5° | `-0.58, 0.814` / 215.5° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 2 | 1 | `-497.665, -552.918` → `-484.231, -571.769` | `2.144, 2.144` → `8.144, 8.144` | 23.148 | 35.5° | `0.814, 0.58` / 125.5° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 3 | 1 | `-484.231, -571.769` → `-482.251, -574.548` | `2.144, 2.14` → `8.144, 8.144` | 3.412 | 35.5° | `0.814, 0.58` / 125.5° | unmapped / none | blocked_unmapped_shared_placeholder_only |
| 4 | 2 | `-482.251, -574.548` → `-484.291, -576` | `2.14, 2.097` → `8.144, 8.144` | 2.504 | 305.4° | `0.58, -0.815` / 35.4° | provenance_only_ambiguous / medium_target_identity_grazing (`1120R-NE-END-CONTEXT`) | provenance_only_no_attachment |
| 5 | 2 | `-484.291, -576` → `-490.85, -580.67` | `2.097, 2.015` → `8.144, 8.144` | 8.052 | 305.5° | `0.58, -0.815` / 35.4° | provenance_only_ambiguous / medium_target_identity_grazing (`1120R-NE-END-CONTEXT`) | provenance_only_no_attachment |
| 6 | 3 | `-490.85, -580.67` → `-494.177, -576` | `2.015, 1.992` → `8.144, 8.144` | 5.734 | 215.5° | `-0.815, -0.58` / 305.4° | provenance_only_ambiguous / medium_target_identity (`1120R-NW-REAR-CONTEXT`) | provenance_only_no_attachment |
| 7 | 3 | `-494.177, -576` → `-506.256, -559.041` | `1.992, 2.108` → `8.144, 8.144` | 20.821 | 215.5° | `-0.815, -0.58` / 305.4° | provenance_only_ambiguous / medium_target_identity (`1120R-NW-REAR-CONTEXT`) | provenance_only_no_attachment |

## Hard exclusions

- **1432 Halibut Court:** May 2011 mappings are historical geometry only. March 2025 shows a cleared site; no current facade or live scope exists.
- **1118 Hutchins Court:** views display neighboring 1114/1116 labels. The mapped row/end context does not prove 1118 unit ownership.
- **1120 Reeves Court:** rear/end context is medium identity; Reeves/front/south is unobserved and `1120R-SV03` adds no assignable front detail.
- **1220 Bayside Drive:** the contributor rear result is excluded; no official rear coverage supports a mapping.
- **1227 Northpoint Drive:** distant rear context remains multi-row/carport ambiguous. Carport ownership and short-facet ownership are not inferred.
- Across every target, unit identity, cadence, module scale, unique elevation, short-facet propagation, hidden side and generated-U phase remain blocked.

## Validation

Status: **pass**. Targets/runs: 8 / 162; mapped plus unmapped: 162; maximum source-edge midpoint distance: 0.000516 m (limit 0.003 m).

- frozen IDs/counts/endpoints/elevations/lengths/bearings/normals match.
- source-edge midpoint ownership <= 0.003 m.
- partitions complete/disjoint.
- mapped runs pass 85-degree facing and 60-degree heading checks.
- candidate runs are exactly high-confidence material_only_safe mappings.
- temporal/identity/coverage blockers preserved.
- zero modules/prototypes/live attachments.

Authoritative companion: `discovery/facades/BATCH_05_RUN_MAPPING.json`. Source observations: `discovery/facades/BATCH_05_STREETVIEW_OBSERVATIONS.md`. Reference index: `discovery/facades/BATCH_05_REFERENCE_INDEX.md`.

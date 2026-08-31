# San Francisco Fire Station 48 facade reference specification

Checked: **2026-08-29**
Mode: **research and implementation handoff only**
Target: **`w764313741` / `building:w764313741:wall`**

## Handoff verdict

The frozen source confirms **San Francisco Fire Station 48** on one direct 26-run receiver. It supplies city/state/country but **no street address**; do not invent one. May 2019 and September 2025 official views establish a restrained pale wall/high-window family on NNW and WSW sides, but operational openings, exact cadence, substrate, height and run mapping remain blocked. The generated `6 m` height is a fallback and nothing may be copied from Building 600.

## Evidence labels and exact receiver

Use `verified_fact`, `reference_observation`, `production_inference`, and `unknown` distinctly.

| Item | Exact value | Status |
|---|---|---|
| Identity/location | San Francisco Fire Station 48; San Francisco, CA, US; no frozen street address | exact frozen tags |
| Source | way `764313741`, version `4`, `2022-03-25T17:56:41Z` | exact snapshot |
| Frozen tags | `amenity=fire_station`, `building=yes`, operator San Francisco Fire Department, operator Wikidata `Q7414030` | identity/use only |
| Logical/wall/roof | `building:w764313741`; `building:w764313741:wall`; `building:w764313741:roof` | direct receiver |
| Chunk/runtime | `x_0__z_-2`; `WorldRoot/PlayableWorld/Buildings/x_0__z_-2__building_w764313741_wall/building_w764313741_wall` | exact naming derivation |
| Materials | wall `plaster_grey_04`; roof `bitumen`; no override | shared placeholders |

### Generated contract

- `default_6m`, `6 m`; base/top `3.501 / 9.501 m`; lowest foundation vertex `3.336 m`. The fallback is not real-world height/story evidence.
- Area `1039.692 m²`; serialized perimeter `187.955 m`; visible wall `187.957 m`.
- Wall `26` runs, `104` vertices / `52` triangles; roof `12` vertices / `10` triangles; no shared-part walls.
- Facing totals: NE `58.004 m`; SE `35.972 m`; SW `58.015 m`; NW `35.966 m`.
- Exact orientation groups: ENE `62.3° 3/25.800 m`, `62.4° 4/32.204`; SSE `152.3° 6/35.972`; WSW `242.3° 8/58.015`; NNW `332.3° 3/26.375`, `332.4° 2/9.590`.
- Wall is opaque `world_solid` and sole spray receiver; roof is opaque collider/non-spray. U restarts per run.

## Provenance, coverage and unknowns

| ID | Source | Supports | Excludes |
|---|---|---|---|
| `L01` | frozen OSM + receiver/generated records, checked 2026-08-29 | identity/use/operator/receiver/topology | street address, appearance, real height/story count |
| `FS48-SV01` | official Google Street View panorama `UQGBH77cFgLZE2Utr1MI4Q`, May 2019; exact URL below | NNW side/service-yard context | fence/vehicles obscure ground level |
| `FS48-SV02` | official Google Street View panorama `U1HtZQlUKomn07I4TT93ug`, September 2025; exact URL below | WSW side and NNW corner | fence/parked vehicles; no exact endpoints |

### Observed / unobserved and provenance

- `FS48-SV01`: https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82750,-122.36945&heading=180&pitch=0&fov=75; actual viewpoint `37.8274909,-122.3694629`; accessed 2026-08-29; displayed **May 2019**; north of footprint looking south `180°`; NNW side/service-yard context.
- `FS48-SV02`: https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82712,-122.36979&heading=125&pitch=0&fov=70; actual viewpoint `37.8271222,-122.3698007`; accessed 2026-08-29; displayed **September 2025**; west/northwest on Avenue I looking southeast `125°`; WSW side and NNW corner.

Observed: portions of NNW and WSW sides. Unobserved: SSE and ENE, exact endpoints, and most ground-level openings behind vehicles, chain-link/privacy fence, containers and equipment.

Visible facts: one low occupied level; flat/very shallow roof behind thin parapet/edge; dominant light muted sage-gray to pale warm-gray wall value; small high horizontal rectangular windows/openings with dark cool glazing/voids and pale surrounds; broad solid fields; faint vertical divisions/pilaster-like lines. Exact stucco, painted block, panel or siding substrate is not distinguishable. No complete apparatus bay, garage door, public entry, station number sign, canopy, decorative band or lower opening was established.

The one-story reading weakly conflicts with treating the default `6 m` as literal measured massing; it does not authorize a height change. Google imagery was transiently viewed; no image, crop, screenshot, copied pixel, download, redistribution or repository asset was retained.

## Material/motif/scale, classifications and seams

### Production material hierarchy and scale

Reversible **production inferences**, not sampled colors or measured dimensions:

| Region | PBR brief | Scale/confidence |
|---|---|---|
| `FS48-PALE-WALL` | light muted sage-gray/pale warm-gray dielectric field, about 45–68% reflectance; roughness `0.70–0.90`; almost flat normal until substrate is known | texture feature scale unknown; material scale blocked |
| `FS48-HWIN` | dark cool glazing/void, roughness `0.16–0.32`, metallic `0`; pale matte surround roughness `0.62–0.84`; no baked reflection/interior | width `0.8–1.5 m`, height `0.35–0.70 m`, low confidence |
| `FS48-DIVISION` | faint vertical line/pilaster in close wall value; do not bake as a repeat until structural/product role is proven | spacing `2.0–4.5 m`, very low confidence |

The default `6 m` receiver is not the module ruler. No lower-opening or apparatus scale may be inferred.

### Motif grammar

- `FS48-HWIN`: one complete high horizontal window with full pale surround and protective wall margin.
- `FS48-SOLID`: uninterrupted pale wall bay bounded only where evidence is clear.
- Faint divisions are possible seam controls, not a proven repeating module. Apparatus doors, public entry, signs and service doors are excluded.

| Output | Status | Gate |
|---|---|---|
| `homogeneous_material_tile` | **reference-ready, calibration blocked** | pale value/finish observed; exact substrate and physical repeat unknown |
| `architectural_pattern_tile` | blocked | faint divisions do not prove a period and occlusion hides cadence |
| `module_atlas` | **candidate brief ready, generation blocked** | `FS48-HWIN` complete-unit rule ready; dimensions/variants uncalibrated |
| `unique_elevation` | blocked | operational openings, SSE/ENE and exact run schedule unknown |

Legal seams are uninterrupted pale wall field or a verified full control-joint/bay boundary after closer evidence. Forbidden seams cut any high window/frame, inferred division, parapet, corner, occluded door/bay, fence line or attached volume; generated U resets remain illegal. Cardinal/orientation family is not a schedule key.

## Godot BOM

| ID | Reserved path | Status |
|---|---|---|
| `MAT` | `res://game/resources/materials/world/fire_station_48/fire_station_48_primary.tres` | pale-wall brief ready; calibration blocked |
| `MAT-SECONDARY` | `res://game/resources/materials/world/fire_station_48/fire_station_48_secondary.tres` | high-window surround/glazing brief; calibration blocked |
| `MOD` | `res://game/scenes/world/facades/fire_station_48/fire_station_48_modules.tscn` | reserve `FS48-HWIN`; geometry blocked |
| `LAYOUT` | `res://game/resources/facades/fire_station_48_layout.json` | exact-run schedule; blocked |
| `ATTACH` | `res://game/scenes/world/facades/fire_station_48/fire_station_48_facade.tscn` | later noncolliding child |

## Geometry boundary and invariant example

Only observed PBR fields and complete shallow render-only modules may be facade-owned. Height/stories, roof/silhouette, footprint, deep/structural openings, collision, spray, navigation, foundations/terrain and generated/source contracts remain invariant.

```text
before: building:w764313741:wall is a default-6 m, 26-run opaque spray
        receiver using shared plaster_grey_04.

after:  that exact receiver, fallback height, footprint, roof, runs, collision,
        spray owner, foundation, source ID and generated bytes remain unchanged;
        only evidence-backed fields/modules may be added to mapped run chains.
```

## Acceptance checklist and blockers

- [x] Every current visual claim cites exact official panorama URL/ID/date/direction/coverage.
- [ ] Exact receiver/path/chunk, `default_6m`, `26 / 187.957 m`, wall `52` and roof `10` triangles remain.
- [ ] No street address, measured height/story count, fire-bay motif or signage is invented.
- [ ] Exact endpoint chains drive layout; no U reset/orientation family creates phase.
- [ ] Complete motifs and seam products remain intact.
- [ ] Visual child adds no physics/navigation/spray ownership.
- [ ] No Building 600 transfer and no massing/roof/footprint/foundation/terrain/collision/spray/generated change.

Observed value hierarchy/high-window family is specified. Substrate, calibrated scale, lower/operational openings, SSE/ENE sides, real height and exact run ownership remain blocked.

## Normalized handoff

```yaml
schema_version: codex.building-texture-research/1
job: {job_id: fire_station_48_facade_reference_spec, checked_date: 2026-08-29, intended_use: observed_partial_facade_brief, target_asset_kind: module_atlas}
target: {canonical_name: San Francisco Fire Station 48, local_object_ids: [w764313741, building:w764313741, building:w764313741:wall], identity_confidence: high, receiver_path: WorldRoot/PlayableWorld/Buildings/x_0__z_-2__building_w764313741_wall/building_w764313741_wall}
sources:
  - {id: L01, authority: project, url_or_local_path: discovery/FACADE_RECEIVER_INVENTORY.json, checked_date: 2026-08-29, page_or_section: facade-receiver:w764313741, supports: [identity, use, receiver, topology], does_not_support: [street_address, appearance, measured_height], image_reuse_permission: not_needed, stored_in_repo: false}
  - {id: FS48-SV01, authority: secondary, url_or_local_path: "https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82750,-122.36945&heading=180&pitch=0&fov=75", checked_date: 2026-08-29, page_or_section: pano_UQGBH77cFgLZE2Utr1MI4Q_May_2019, supports: [NNW_wall_value, high_windows, service_context], does_not_support: [lower_openings, exact_runs, dimensions], image_reuse_permission: observation_only, stored_in_repo: false}
  - {id: FS48-SV02, authority: secondary, url_or_local_path: "https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82712,-122.36979&heading=125&pitch=0&fov=70", checked_date: 2026-08-29, page_or_section: pano_U1HtZQlUKomn07I4TT93ug_September_2025, supports: [WSW_wall_value, NNW_corner, high_windows], does_not_support: [operational_openings, exact_runs, dimensions], image_reuse_permission: observation_only, stored_in_repo: false}
reference_roles: {identity_context: [L01, FS48-SV01, FS48-SV02], massing: [L01], pattern_region: [FS48-SV01, FS48-SV02], cadence_and_seams: [FS48-SV01, FS48-SV02], material_surface: [FS48-SV01, FS48-SV02], scale: [L01, FS48-SV01, FS48-SV02], rejection_example: []}
pattern_regions:
  - {region_id: WSW_NNW_OBSERVED, local_scope: subsets_of_242_3_and_332_3_332_4_families_exact_endpoints_unknown, periodicity: no_period_proven, must_not_share_tile_with: [SSE_ENE_UNOBSERVED, OCCLUDED_LOWER_OPENINGS]}
motif_inventory:
  - {motif_id: FS48-HWIN, completeness_rule: full_high_horizontal_window_pale_surround_and_protective_wall_margin, size_m: {width: [0.8, 1.5], height: [0.35, 0.70]}, confidence: low}
motif_sequences: []
repeat_blueprint: {region_id: WSW_NNW_OBSERVED, smallest_cell_status: not_proven_due_occlusion, period_tokens_horizontal: null, period_tokens_vertical: [solid_lower_field, high_window_register, thin_parapet_edge], period_m: {x: null, y: null}, cell_contents_full_motifs: [FS48-HWIN], edge_fragments: {left: [], right: [], top: [], bottom: []}, edge_compositions_expected: {left_plus_right: [complete_window_surround], top_plus_bottom: [], corners: []}, legal_seam_zones: [uninterrupted_pale_field, verified_full_control_joint_boundary], forbidden_seam_zones: [generated_U_resets, high_windows, frames, inferred_divisions, parapet, corners, occluded_doors_or_bays, fence_lines, attached_volumes], fallback_if_not_proven: module_atlas}
material_brief: {surface_family: pale_unknown_substrate_wall, base_color: light_muted_sage_gray_to_pale_warm_gray, finish: matte, relief_direction_and_frequency: nearly_flat_until_substrate_known, roughness: [0.70, 0.90], variation_and_weathering: restrained_nonphotographic_only, maps_requested: [albedo, roughness], maps_forbidden: [height_displacement, baked_lighting, photographic_reflections, baked_fence_or_vehicle_shadows], tile_scale_status: unknown_requires_calibration, tile_scale_m: {x: null, y: null}}
excluded_architectural_features: [{feature: height_stories_roof_silhouette_structural_openings, owner: geometry, reason: invariant}]
uncertainty:
  - {unknown: substrate_scale_cadence_and_endpoint_mapping, impact: no_final_material_module_or_placement, safe_fallback: shared_placeholder, stop_if_required: true}
  - {unknown: operational_openings_SSE_ENE_and_real_height, impact: no_unique_elevation_or_cross_side_transfer, safe_fallback: shared_placeholder, stop_if_required: true}
hard_mismatch_gates:
  - {scope: identity, reject_if: receiver_is_not_building_w764313741_wall, proof_required: exact_metadata}
  - {scope: geometry, reject_if: massing_collision_spray_foundation_or_generated_contract_changes, proof_required: exact_receiver_audit}
research_verdict: {ready_for_generation: false, recommended_output_kind: module_atlas, blockers: [substrate_and_scale_unknown, exact_cadence_unknown, endpoint_map_missing, operational_openings_occluded, SSE_ENE_unobserved, default_height_not_measurement, street_address_unknown]}
```

## Final status

- Identity/receiver: **ready**.
- Pale field/high-window research subset: **reference-ready; final generation blocked**.
- Unique placement/operational sides: **blocked**.

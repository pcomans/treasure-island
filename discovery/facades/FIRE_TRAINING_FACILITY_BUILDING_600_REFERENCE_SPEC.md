# Fire Training Facility Building 600 / 750 Avenue M facade reference specification

Checked: **2026-08-29**
Mode: **research and implementation handoff only**
Target: **`w34313548` / `building:w34313548:wall`**

## Handoff verdict

The frozen source confirms **San Francisco Fire Dept Treasure Island Training Facility Building 600**, **750 Avenue M**, with old name **US Naval Station Treasure Island Shipboard Firefighting School**, on one direct 24-run receiver. Official September 2025 views establish a pale coarse long-wall field, one horizontal-window family and a unique dark-red south entry portal. Material/window research is reference-ready; exact placement is blocked, and the deep arched portal remains geometry-dependent without authorizing a massing change.

## Evidence labels and exact receiver

Use `verified_fact`, `reference_observation`, `production_inference`, and `unknown` distinctly.

| Item | Exact value | Status |
|---|---|---|
| Identity/address | San Francisco Fire Dept Treasure Island Training Facility Building 600; 750 Avenue M | exact frozen tags |
| Source | way `34313548`, version `6`, `2026-05-21T20:17:25Z` | exact snapshot |
| Frozen tags | `building=yes`, `height=6`, old name above, `source=Yahoo` | identity/massing only |
| Logical/wall/roof | `building:w34313548`; `building:w34313548:wall`; `building:w34313548:roof` | direct receiver |
| Chunk/runtime | `x_1__z_-2`; `WorldRoot/PlayableWorld/Buildings/x_1__z_-2__building_w34313548_wall/building_w34313548_wall` | exact naming derivation |
| Materials | wall `plaster_grey_04`; roof `bitumen`; no override | shared placeholders |

### Generated contract

- `osm_height`, `6 m`; base/top `4.064 / 10.064 m`; lowest foundation vertex `3.660 m`.
- Area `1828.339 m²`; serialized/visible perimeter `243.359 m`.
- Wall `24` runs, `96` vertices / `48` triangles; roof `4` vertices / `2` triangles; no shared-part walls.
- Four exact orientation families: ENE `62.9°`, runs-count/length `10 / 104.117 m`; SSE `152.9°`, `3 / 17.556 m`; WSW `242.9°`, `10 / 104.122 m`; NNW `332.9°`, `1 / 17.565 m`.
- Wall is opaque `world_solid` and sole spray receiver; roof is opaque collider/non-spray. U restarts per run.

## Provenance, coverage and unknowns

| ID | Source | Supports | Excludes |
|---|---|---|---|
| `L01` | frozen OSM + receiver/generated records, checked 2026-08-29 | identity/address/old name/height/receiver/topology | facade appearance |
| `B600-SV01` | official Google Street View panorama `ifdNQ-gh7K1ryx3rVMvW2w`, September 2025; exact URL below | SSE entry portal and start of WSW long side | no exact endpoints/dimensions |
| `B600-SV02` | official Google Street View panorama `t8V4SOhQFPRXL_vukoMRog`, September 2025; exact URL below | WSW long side | heavy tree occlusion; no exact bay schedule |

### Observed / unobserved and provenance

- `B600-SV01`: https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8262806,-122.3677375&heading=25&pitch=0&fov=75; actual viewpoint `37.8262806,-122.3677375`; accessed 2026-08-29; displayed **September 2025**; south/southwest approach looking north-northeast `25°`; unique SSE entry and start of WSW side.
- `B600-SV02`: https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82672,-122.36800&heading=80&pitch=0&fov=75; actual viewpoint `37.8267255,-122.3679894`; accessed 2026-08-29; displayed **September 2025**; west of footprint looking east `80°`; WSW long side, heavily tree-occluded.

Observed: SSE entrance end and most of WSW long side. Unobserved: ENE long side, NNW end, foliage-hidden bays, most ground line, ordinary doors and exact receiver endpoints.

Visible facts: warm light cream-to-pale-gray coarse mineral/block-like wall field (exact substrate unknown); one occupied row of medium horizontal windows with cool muted blue-gray glazing and pale surrounds; a thin flat/dark roof-edge line; and an exceptional saturated dark-red arched drive-through portal/canopy. The portal has large pale `SFFD FIRE FIGHTING SCHOOL` lettering, a dark finely ribbed/slatted-looking underside, heavy light-gray bollards, and a red vertical element marked `600`. Portal opening, canopy depth, arch, columns, bollards and equipment behind it are geometry/prop-owned. No repeatable belt band or wall rib was established.

The ordinary wing reads as one low occupied level plus a taller portal, which conflicts weakly with treating the uniform `6 m` receiver as a literal facade profile. Preserve current massing; do not flatten the portal into a painted motif or change silhouette without separate approval. Google imagery was transiently viewed; no image, crop, screenshot, copied pixel, download, redistribution or repository asset was retained.

## Material/motif/scale, classification and seams

### Production material hierarchy and scale

Reversible **production inferences**, not sampled colors or measured dimensions:

| Region | PBR brief | Scale/confidence |
|---|---|---|
| `B600-PALE-WALL` | warm cream/pale gray dielectric field, about 55–75% reflectance; roughness `0.75–0.92`; low-amplitude coarse mineral/block-like normal only; no baked shadows | visible coarse units `0.20–0.50 m`, low confidence; substrate unknown |
| `B600-WINDOW` | cool muted blue-gray glazing, roughness `0.14–0.30`, metallic `0`; pale matte surround roughness `0.65–0.85`; no baked reflections/interiors | opening width `1.2–2.0 m`, height `0.6–1.0 m`, low confidence |
| `B600-RED-PORTAL` | saturated dark red painted surface, roughly 8–20% diffuse reflectance; roughness `0.52–0.76`; pale lettering separate decal/material | complete unique south region; approximate `4.5–6.0 m` height only, low confidence |
| `B600-UNDERSIDE` | near-dark fine rib/slat direction along portal depth; roughness `0.62–0.82` | geometry-owned underside; exact pitch unknown |

Window spacing/count cannot be estimated through foliage. The `6 m` height is receiver calibration, not module scale.

### Motif grammar

- `B600-WIN`: one full horizontal window, full pale surround and protective wall margin.
- `B600-SOLID`: uninterrupted pale wall field between openings, only where both boundaries are visible.
- `B600-PORTAL`: entire red arch + lettering + marked pier + opening composition, unique to the SSE end; never tile or repeat.

| Output | Status | Gate |
|---|---|---|
| `homogeneous_material_tile` | **reference-ready, calibration blocked** | pale coarse field observed; exact substrate/metres-per-repeat unknown |
| `architectural_pattern_tile` | blocked | foliage hides count/spacing; no smallest repeat proven |
| `module_atlas` | **candidate brief ready, generation blocked** | `B600-WIN` is complete grammar; physical bounds and full variants uncalibrated |
| `unique_elevation` | **portal composition specified, implementation blocked** | unique SSE portal is non-repeat; exact endpoints and deep geometry unresolved |

Legal seams are inside uninterrupted pale field or at the verified full outer edge of `B600-WIN`. Forbidden seams cut a window/frame, portal, arch, lettering, `600`, opening, dark underside, bollard, roof edge, corner or tree-occluded bay; generated U resets are never joints. Long ENE/WSW families cannot inherit the same schedule merely because their lengths match.

## Godot BOM

| ID | Reserved path | Status |
|---|---|---|
| `MAT` | `res://game/resources/materials/world/fire_training_b600/fire_training_primary.tres` | pale-wall brief ready; calibration blocked |
| `MAT-SECONDARY` | `res://game/resources/materials/world/fire_training_b600/fire_training_secondary.tres` | red portal/underside/lettering briefs; geometry-dependent |
| `MOD` | `res://game/scenes/world/facades/fire_training_b600/fire_training_modules.tscn` | reserve `B600-WIN`; portal excluded until geometry decision |
| `LAYOUT` | `res://game/resources/facades/fire_training_b600_750_avenue_m_layout.json` | exact-run schedule; blocked |
| `ATTACH` | `res://game/scenes/world/facades/fire_training_b600/fire_training_facade.tscn` | later noncolliding child |

## Geometry boundary and invariant example

Only observed PBR fields and complete shallow visual modules may be facade-owned. Height, roof/silhouette, footprint, deep/structural openings, collision, spray, terrain/foundation, navigation and generated/source contracts remain invariant.

```text
before: building:w34313548:wall is a 6 m-high, 24-run opaque spray receiver
        using shared plaster_grey_04.

after:  that exact wall, roof, height, footprint, runs, collision, spray owner,
        foundations, source ID and generated bytes remain unchanged; a later
        child may add only evidence-backed fields/modules on mapped run chains.
```

## Acceptance checklist and blockers

- [x] Each current visual claim cites exact official panorama URL/ID/date/direction/coverage.
- [ ] Exact target/path/chunk, `6 m`, `24 / 243.359 m`, wall `48` and roof `2` triangles remain.
- [ ] Exact endpoints drive layout; no generated U reset/cardinal family creates phase.
- [ ] Complete motifs and seam products remain intact.
- [ ] Visual child adds no physics/navigation/spray ownership.
- [ ] No fire/training/old-name tag becomes style/signage evidence.
- [ ] No massing/roof/footprint/foundation/terrain/collision/spray/generated change.

Observed hierarchy is specified. Exact physical scale/window cadence, foliage-hidden bays, ENE/NNW sides and endpoint ownership remain blocked. The unique portal additionally requires a separately approved geometry treatment.

## Normalized handoff

```yaml
schema_version: codex.building-texture-research/1
job: {job_id: fire_training_b600_facade_reference_spec, checked_date: 2026-08-29, intended_use: observed_partial_facade_brief, target_asset_kind: unique_elevation}
target: {canonical_name: Fire Training Facility Building 600 / 750 Avenue M, local_object_ids: [w34313548, building:w34313548, building:w34313548:wall], identity_confidence: high, receiver_path: WorldRoot/PlayableWorld/Buildings/x_1__z_-2__building_w34313548_wall/building_w34313548_wall}
sources:
  - {id: L01, authority: project, url_or_local_path: discovery/FACADE_RECEIVER_INVENTORY.json, checked_date: 2026-08-29, page_or_section: facade-receiver:w34313548, supports: [identity, address, massing, receiver, topology], does_not_support: [appearance], image_reuse_permission: not_needed, stored_in_repo: false}
  - {id: B600-SV01, authority: secondary, url_or_local_path: "https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8262806,-122.3677375&heading=25&pitch=0&fov=75", checked_date: 2026-08-29, page_or_section: pano_ifdNQ-gh7K1ryx3rVMvW2w_September_2025, supports: [south_portal, WSW_start, identity], does_not_support: [exact_dimensions, exact_runs, hidden_bays], image_reuse_permission: observation_only, stored_in_repo: false}
  - {id: B600-SV02, authority: secondary, url_or_local_path: "https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82672,-122.36800&heading=80&pitch=0&fov=75", checked_date: 2026-08-29, page_or_section: pano_t8V4SOhQFPRXL_vukoMRog_September_2025, supports: [WSW_pale_wall, horizontal_window_family], does_not_support: [exact_window_count, exact_runs, foliage_hidden_bays], image_reuse_permission: observation_only, stored_in_repo: false}
reference_roles: {identity_context: [L01, B600-SV01], massing: [L01], pattern_region: [B600-SV01, B600-SV02], cadence_and_seams: [B600-SV01, B600-SV02], material_surface: [B600-SV01, B600-SV02], scale: [L01, B600-SV01, B600-SV02], rejection_example: []}
pattern_regions:
  - {region_id: WSW_OBSERVED, local_scope: subset_of_242_9_degree_family_exact_endpoints_unknown, periodicity: no_period_proven, must_not_share_tile_with: [ENE_UNOBSERVED, NNW_UNOBSERVED, SSE_PORTAL]}
  - {region_id: SSE_PORTAL, local_scope: subset_of_152_9_degree_family_exact_endpoints_unknown, periodicity: unique_nonrepeat, must_not_share_tile_with: [all_other_regions]}
motif_inventory:
  - {motif_id: B600-WIN, completeness_rule: full_horizontal_window_pale_surround_and_protective_wall_margin, size_m: {width: [1.2, 2.0], height: [0.6, 1.0]}, confidence: low}
  - {motif_id: B600-PORTAL, completeness_rule: entire_arch_lettering_marked_pier_opening_and_dark_underside_composition, size_m: {width: null, height: [4.5, 6.0]}, confidence: low, owner: unique_elevation_plus_geometry}
motif_sequences: []
repeat_blueprint: {region_id: WSW_OBSERVED, smallest_cell_status: not_proven_due_foliage, period_tokens_horizontal: null, period_tokens_vertical: [pale_wall, horizontal_window_row, roof_edge], period_m: {x: null, y: null}, cell_contents_full_motifs: [B600-WIN], edge_fragments: {left: [], right: [], top: [], bottom: []}, edge_compositions_expected: {left_plus_right: [complete_window_surround], top_plus_bottom: [], corners: []}, legal_seam_zones: [uninterrupted_pale_field, full_outer_window_module_edge], forbidden_seam_zones: [generated_U_resets, windows, portal, arch, lettering, number_600, opening, underside, bollards, roof_edge, corners, occluded_bays], fallback_if_not_proven: module_atlas}
material_brief: {surface_family: pale_coarse_mineral_or_block_like_field, base_color: warm_light_cream_to_pale_gray, finish: coarse_matte, relief_direction_and_frequency: low_amplitude_units_0_20_to_0_50m_unconfirmed, roughness: [0.75, 0.92], variation_and_weathering: restrained_nonphotographic_only, maps_requested: [albedo, normal, roughness], maps_forbidden: [height_displacement, baked_lighting, photographic_reflections, baked_tree_shadows], tile_scale_status: low_confidence_requires_calibration, tile_scale_m: {x: [0.2, 0.5], y: [0.2, 0.5]}}
excluded_architectural_features: [{feature: height_roof_silhouette_structural_openings, owner: geometry, reason: invariant}]
uncertainty:
  - {unknown: substrate_scale_window_count_spacing_and_endpoint_mapping, impact: no_final_material_module_or_placement, safe_fallback: shared_placeholder, stop_if_required: true}
  - {unknown: ENE_NNW_and_foliage_hidden_bays, impact: no_transfer_from_observed_sides, safe_fallback: shared_placeholder, stop_if_required: true}
  - {unknown: portal_depth_silhouette_resolution, impact: unique_entry_not_implementable_as_facade_only, safe_fallback: unchanged_receiver, stop_if_required: true}
hard_mismatch_gates:
  - {scope: identity, reject_if: receiver_is_not_building_w34313548_wall, proof_required: exact_metadata}
  - {scope: geometry, reject_if: massing_collision_spray_foundation_or_generated_contract_changes, proof_required: exact_receiver_audit}
research_verdict: {ready_for_generation: false, recommended_output_kind: module_atlas, blockers: [scale_uncalibrated, exact_window_schedule_unknown, endpoint_map_missing, ENE_NNW_unobserved, unique_portal_geometry_unresolved]}
```

## Final status

- Identity/receiver: **ready**.
- Pale field/window research subset: **reference-ready; final generation blocked**.
- Unique portal/placement: **blocked by geometry and endpoint reconciliation**.

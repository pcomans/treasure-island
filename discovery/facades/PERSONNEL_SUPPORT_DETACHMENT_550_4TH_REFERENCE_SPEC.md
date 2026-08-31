# Treasure Island Personnel Support Detachment / 550 4th Street facade reference specification

Checked: **2026-08-29**
Mode: **research and implementation handoff only**
Target: **relation `r133347` / `building:r133347:wall`**

## Handoff verdict

The frozen source confirms **Treasure Island Personnel Support Detachment**, **550 4th Street**, as one direct multipolygon receiver with a protected inner courtyard. Official June 2021 and September 2025 views establish a dark two-tier grid/material hierarchy on broad east and north outer elevations. They do not establish the infill sequence, exact dimensions, south/west sides, any courtyard face or exact run mapping. Conservative material and complete-bay prototyping is reference-ready; placement and all hidden regions remain blocked.

## Evidence labels and exact identity

Use `verified_fact`, `reference_observation`, `production_inference`, and `unknown` distinctly.

| Item | Exact value | Status |
|---|---|---|
| Identity/address | Treasure Island Personnel Support Detachment; 550 4th Street | exact frozen relation tags |
| Source | relation `133347`, version `2`, `2017-04-25T16:17:43Z`; `building=abandoned`, `building:levels=2` | currentness not claimed |
| Relation members | outer way `w34313505`; inner way `w34313506` | exact topology |
| Logical/wall/roof | `building:r133347`; `building:r133347:wall`; `building:r133347:roof` | direct receiver |
| Chunk/runtime | `x_0__z_1`; `WorldRoot/PlayableWorld/Buildings/x_0__z_1__building_r133347_wall/building_r133347_wall` | exact naming derivation |
| Materials | shared wall `plaster_grey_04`; roof `bitumen`; no override | placeholders |

### Generated ring and mesh contract

- `osm_levels`, `6 m` from two frozen levels; base/top `4.051 / 10.051 m`; lowest foundation vertex `3.612 m`.
- Area `2396.133 m²`; serialized perimeter `250.793 m`; visible wall `250.796 m`.
- Wall `28` runs, `112` vertices / `56` triangles; roof `8` vertices / `8` triangles.
- Serialized ring split derived from endpoint continuity: **outer runs `0..17`, `201.334 m`**; **inner courtyard runs `18..27`, `49.462 m`**. Every layout entry must declare `outer` or `inner`; orientation alone cannot transfer motifs between rings.
- Orientation groups across both rings: E `79.9° 5/49.234 m`, `80.8° 2/8.264`; S `169.9° 4/51.438`, `170.9° 2/16.466`; W `259.9° 4/49.232`, `260.8° 2/8.264`; N `349.9° 5/51.430`, `350.9° 4/16.466`.
- Wall is opaque `world_solid`/spray receiver; roof is opaque collider/non-spray. U restarts per run.

## Provenance and coverage

| ID | Source | Supports | Excludes |
|---|---|---|---|
| `L01` | frozen OSM relation/members + inventory/generated records, checked 2026-08-29 | exact identity, address, rings, levels, receiver and scale | appearance/current abandonment |
| `PSD-SV01` | official Google Street View panorama `GAuBhldmLlZOQwXj8qav3w`, June 2021; exact URL below | broad east-facing outer elevation | lower facade partly fenced/landscaped; no exact runs |
| `PSD-SV02` | official Google Street View panorama `_rk3B0PasMLUEPCQCA_sJw`, September 2025; exact URL below | north-facing outer elevation/east corner | fence/vegetation; no exact runs |

### Observed / unobserved and provenance

- `PSD-SV01`: https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82145,-122.36730&heading=255&pitch=0&fov=75; actual viewpoint `37.82138,-122.3674429`; accessed 2026-08-29; displayed **June 2021**; east of footprint looking west `255°`; broad E-facing outer elevation.
- `PSD-SV02`: https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82170,-122.36815&heading=205&pitch=0&fov=80; actual viewpoint `37.8219027,-122.3677643`; accessed 2026-08-29; displayed **September 2025**; north/northeast approach looking southwest `205°`; N-facing outer elevation and east corner.

Observed: broad **east and north outer** elevations. Unobserved: south and west outer elevations, entrances/doors hidden at the base, exact run endpoints, and **every inner-courtyard face/runs `18..27`**. Public-road evidence must never propagate into the courtyard.

Directly visible facts: a dense near-charcoal structural/mullion grid; cool gray/blue-gray glazing; near-black lower opaque panels; muted gray-tan opaque or shadowed fields; two facade tiers beneath a thin dark projecting roof edge; a shallow upper transom/clerestory row over a taller lower window/panel row; regular narrow vertical grid cadence with varying infill; heavily obscured dark base; and a rooftop screened/louvered equipment volume visible in 2021. Some panes/openings appear dark, missing or broken in 2021, but damage is not a reusable motif. No complete entry, projecting canopy, decorative belt, masonry course or ribbed material was established.

The two visible tiers are compatible with the frozen two-level tag, but neither the `6 m` height nor rooftop screen geometry is visually measured. Google imagery was viewed transiently; no image, crop, screenshot, copied pixel, download, redistribution or repository asset was retained.

## Material/motif/scale and output classes

### Production material hierarchy and physical scale

These are reversible, physically plausible **production inferences**, not sampled panorama colors or measured dimensions:

| Region | PBR brief | Scale/confidence |
|---|---|---|
| `PSD-GRID` | near-charcoal matte painted frame; neutral-to-cool value about 8–16% reflectance; dielectric/metallic `0`; roughness `0.62–0.82`; restrained edge wear only | mullion/pier face `0.10–0.25 m`, low confidence |
| `PSD-GLAZING` | cool blue-gray transparent/dark glazing; roughness `0.12–0.28`, metallic `0`; no baked sky/reflection or interior lighting | lower pane height `1.4–2.2 m`, medium-low confidence |
| `PSD-OPAQUE` | near-black opaque lower infill, about 5–12% reflectance; roughness `0.55–0.78`; subtle broad variation, no photographic damage | one full grid cell, scale coupled to bay |
| `PSD-MUTED-INFILL` | aged gray-tan/cool-gray opaque field, about 25–45% reflectance; roughness `0.68–0.88` | alternate infill state; dimensions unknown |

Provisional bay width `1.0–1.8 m`, lower tier `1.4–2.2 m`, upper transom `0.35–0.70 m`; all are perspective-based low/medium-low confidence and require calibration before final asset generation. The `6 m / 2 levels` receiver is not the module ruler.

### Motif grammar

- `PSD-VBAY`: dark base -> lower glazing/opaque/muted infill -> upper transom, bounded by both vertical grid members.
- `PSD-OPAQUE-BAY`: one complete opaque infill state with full grid surround; blocked until panel boundaries are closer-proven.
- `PSD-TRANSOM`: one complete upper transom cell with its frame; never tile independently of the vertical bay cadence.
- Infill alternates are state variants, not a proven repeating string. Broken/dark panes are excluded variants. Rooftop screen is geometry-owned.

| Output | Status | Gate |
|---|---|---|
| `homogeneous_material_tile` | **reference-ready, generation blocked** | grid/opaque/glazing fields identified; substrate and calibrated metres/texel unknown |
| `architectural_pattern_tile` | blocked | varying infill and no complete global period; smallest repeat unproved |
| `module_atlas` | **candidate brief ready, generation blocked** | `PSD-VBAY`/`PSD-TRANSOM` are complete-unit grammar; bounds and state catalog incomplete |
| `unique_elevation` | blocked | east/north sequence not reconciled to exact outer endpoints; other sides/courtyard unobserved |

Legal seams are uninterrupted opaque field or a verified complete outer grid-bay boundary. Forbidden: cuts through mullion, transom, pane, infill, base, roof edge, corner, damaged opening or potential door; generated U resets; outer/inner boundary; courtyard corners; receiver top/foundation; and every unobserved feature. Never wrap a phase around the east/north corner without endpoint proof.

## Godot BOM

| ID | Reserved path | Status |
|---|---|---|
| `MAT-OUTER` | `res://game/resources/materials/world/personnel_support_detachment/psd_outer.tres` | material brief ready; calibrated generation blocked |
| `MAT-INNER` | `res://game/resources/materials/world/personnel_support_detachment/psd_inner.tres` | blocked; no outer inheritance |
| `MOD` | `res://game/scenes/world/facades/personnel_support_detachment/psd_modules.tscn` | reserve `PSD-VBAY`, `PSD-TRANSOM`, variant metadata; geometry blocked |
| `LAYOUT` | `res://game/resources/facades/personnel_support_detachment_550_4th_layout.json` | must include ring role + exact runs |
| `ATTACH` | `res://game/scenes/world/facades/personnel_support_detachment/psd_facade.tscn` | later noncolliding child |

## Geometry boundary and before -> after

Only evidence-backed PBR and complete shallow visual modules may be facade-owned. Height/levels, roof/silhouette, outer/inner topology and hole, structural openings, collision, spray, terrain/foundations, navigation and generated/source contracts are excluded.

```text
before: building:r133347:wall is one 6 m-high opaque spray receiver with outer
        runs 0..17, inner courtyard runs 18..27 and shared plaster_grey_04.

after:  that exact two-ring wall, roof, two-level mass, 28 runs, collision,
        spray owner, foundations, source/member IDs and generated bytes remain
        unchanged; only observed ring-aware fields/modules may be added, and no
        outer schedule is projected into the courtyard.
```

## Acceptance checklist and blockers

- [x] Every current visual claim cites exact panorama URL/ID/date/direction/coverage and identifies outer versus inner evidence.
- [ ] Relation/member IDs, receiver/path/chunk, `6 m`, `28 / 250.796 m`, wall `56` and roof `8` triangles remain exact.
- [ ] Layout asserts outer `0..17` versus inner `18..27`; cardinal normal/U reset never selects or phases a module.
- [ ] Complete modules and edge products survive seams; no outer/inner crossing.
- [ ] Visual child has no physics/navigation/spray ownership; underlying wall remains spray owner.
- [ ] `building=abandoned` is not treated as present condition.
- [ ] No massing/roof/ring/footprint/foundation/terrain/collision/spray/generated change.

Outer material/grid hierarchy is specified; calibrated physical scale, complete infill states and exact outer endpoint mapping remain blocked. Inner courtyard appearance is completely unknown and cannot inherit public-facing evidence.

## Normalized handoff

```yaml
schema_version: codex.building-texture-research/1
job: {job_id: personnel_support_detachment_facade_reference_spec, checked_date: 2026-08-29, intended_use: ring_aware_observed_outer_brief, target_asset_kind: module_atlas}
target: {canonical_name: Treasure Island Personnel Support Detachment / 550 4th Street, local_object_ids: [r133347, w34313505, w34313506, building:r133347, building:r133347:wall], identity_confidence: high, receiver_path: WorldRoot/PlayableWorld/Buildings/x_0__z_1__building_r133347_wall/building_r133347_wall}
sources:
  - {id: L01, authority: project, url_or_local_path: discovery/FACADE_RECEIVER_INVENTORY.json, checked_date: 2026-08-29, page_or_section: facade-receiver:r133347, supports: [identity, address, rings, receiver, scale], does_not_support: [appearance, current_abandonment], image_reuse_permission: not_needed, stored_in_repo: false}
  - {id: PSD-SV01, authority: secondary, url_or_local_path: "https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82145,-122.36730&heading=255&pitch=0&fov=75", checked_date: 2026-08-29, page_or_section: pano_GAuBhldmLlZOQwXj8qav3w_June_2021, supports: [east_outer_grid, material_hierarchy, tiering], does_not_support: [exact_runs, dimensions, hidden_base, courtyard], image_reuse_permission: observation_only, stored_in_repo: false}
  - {id: PSD-SV02, authority: secondary, url_or_local_path: "https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82170,-122.36815&heading=205&pitch=0&fov=80", checked_date: 2026-08-29, page_or_section: pano__rk3B0PasMLUEPCQCA_sJw_September_2025, supports: [north_outer_grid, east_corner, material_hierarchy], does_not_support: [exact_runs, dimensions, courtyard], image_reuse_permission: observation_only, stored_in_repo: false}
reference_roles: {identity_context: [L01, PSD-SV01, PSD-SV02], massing: [L01], pattern_region: [PSD-SV01, PSD-SV02], cadence_and_seams: [PSD-SV01, PSD-SV02], material_surface: [PSD-SV01, PSD-SV02], scale: [L01, PSD-SV01, PSD-SV02], rejection_example: []}
pattern_regions:
  - {region_id: OUTER_EAST_NORTH_OBSERVED, local_scope: subset_of_runs_0_to_17_endpoint_map_unknown, periodicity: varying_grid_bays, must_not_share_tile_with: [INNER, OUTER_SOUTH_WEST_UNOBSERVED]}
  - {region_id: OUTER_SOUTH_WEST_UNOBSERVED, local_scope: subset_of_runs_0_to_17_endpoint_map_unknown, periodicity: unknown, must_not_share_tile_with: [OUTER_EAST_NORTH_OBSERVED, INNER]}
  - {region_id: INNER, local_scope: runs_18_to_27, periodicity: unknown, must_not_share_tile_with: [OUTER_EAST_NORTH_OBSERVED, OUTER_SOUTH_WEST_UNOBSERVED]}
motif_inventory:
  - {motif_id: PSD-VBAY, completeness_rule: full_vertical_grid_bay_including_both_mullions_base_lower_infill_and_upper_transom, size_m: {width: [1.0, 1.8], height: null}, confidence: low_medium}
  - {motif_id: PSD-TRANSOM, completeness_rule: full_upper_cell_and_frame_kept_in_vertical_bay_phase, size_m: {width: [1.0, 1.8], height: [0.35, 0.70]}, confidence: low_medium}
motif_sequences: []
repeat_blueprint: {region_id: OUTER_EAST_NORTH_OBSERVED, smallest_cell_status: no_global_repeat_proven, period_tokens_horizontal: null, period_tokens_vertical: [base, lower_infill, upper_transom], period_m: {x: null, y: null}, cell_contents_full_motifs: [PSD-VBAY], edge_fragments: {left: [], right: [], top: [], bottom: []}, edge_compositions_expected: {left_plus_right: [complete_bounding_mullion], top_plus_bottom: [], corners: []}, legal_seam_zones: [uninterrupted_opaque_field, verified_full_grid_bay_boundary], forbidden_seam_zones: [generated_U_resets, mullions, transoms, panes, infills, base, roof_edge, corners, damaged_openings, potential_doors, outer_inner_boundary, courtyard_corners, unobserved_motifs], fallback_if_not_proven: module_atlas}
material_brief: {surface_family: dark_framed_glazing_and_opaque_infill, base_color: [near_charcoal_grid, cool_blue_gray_glazing, near_black_lower_opaque, muted_gray_tan_infill], finish: [matte_painted_grid, smooth_glazing, matte_opaque_panels], relief_direction_and_frequency: regular_vertical_grid_with_upper_transom_register, roughness: {grid: [0.62, 0.82], glazing: [0.12, 0.28], opaque: [0.55, 0.88]}, variation_and_weathering: restrained_nonphotographic_only, maps_requested: [albedo, normal_if_substrate_proven, roughness, opacity_for_glazing], maps_forbidden: [height_displacement, baked_lighting, photographic_reflections, canonical_damage], tile_scale_status: perspective_estimate_requires_calibration, tile_scale_m: {x: [1.0, 1.8], y: null}}
excluded_architectural_features: [{feature: height_levels_roof_ring_topology_structural_openings, owner: geometry, reason: invariant}]
uncertainty:
  - {unknown: exact_outer_infill_sequence_dimensions_substrate_and_endpoint_mapping, impact: no_unique_placement_or_final_generation, safe_fallback: shared_placeholder, stop_if_required: true}
  - {unknown: inner_courtyard_appearance, impact: no_inner_material_or_modules, safe_fallback: shared_placeholder, stop_if_required: true}
hard_mismatch_gates:
  - {scope: identity, reject_if: receiver_or_relation_member_is_wrong, proof_required: exact_relation_and_runtime_metadata}
  - {scope: module, reject_if: outer_schedule_applied_to_inner_ring, proof_required: ring_role_layout_audit}
  - {scope: geometry, reject_if: ring_massing_collision_spray_foundation_or_generated_contract_changes, proof_required: exact_receiver_audit}
research_verdict: {ready_for_generation: false, recommended_output_kind: module_atlas, blockers: [physical_scale_uncalibrated, infill_states_incomplete, outer_endpoint_map_missing, south_west_unobserved, inner_ring_unobserved]}
```

## Final status

- Identity/ring-aware receiver: **ready**.
- Material/module research subset: **reference-ready; final generation blocked**.
- Unique placement and inner courtyard: **blocked**.

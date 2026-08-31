# Navy Chapel Building 187 / 51 California Avenue facade reference specification

Checked: **2026-08-29**
Mode: **research and implementation handoff only**
Target: **`w291189336` / `building:w291189336:wall`**

## Handoff verdict

The frozen source confirms **Navy Chapel Building 187**, **51 California Avenue**, as a standalone place-of-worship footprint with one compact but irregular 34-run receiver. Official Sep 2025 Street View supports a conservative warm-cream material prototype and an SSE gable/entry module vocabulary. Exact modules and placement remain blocked by viewing distance, landscaping, unverified pane/door counts, partial long-side coverage and unreconciled endpoints.

## Confirmed identity and exact receiver

Claims are labeled `verified_fact`, `reference_observation`, `production_inference`, or `unknown`.

| Item | Exact value | Status |
|---|---|---|
| Name/address | Navy Chapel Building 187; 51 California Avenue | exact frozen tags; no city/postcode added |
| Use description | `amenity=place_of_worship`; non-denominational wedding chapel | exact frozen tags; not appearance evidence |
| Source | way `291189336`, version `3`, timestamp `2017-12-08T04:11:03Z`; `height=10` | exact |
| Logical/wall/roof | `building:w291189336`; `building:w291189336:wall`; `building:w291189336:roof` | exact |
| Chunk/runtime | `x_-1__z_2`; `WorldRoot/PlayableWorld/Buildings/x_-1__z_2__building_w291189336_wall/building_w291189336_wall` | exact current naming derivation |
| Current materials | shared wall `plaster_grey_04`; roof `bitumen`; no override | placeholder only |

### Receiver contract

- `osm_height`, `10 m`; base/top `4.040 / 14.040 m`; lowest foundation vertex `3.921 m`.
- Source area `862.410 m²`; serialized perimeter `153.582 m`; generated wall `153.581 m`.
- `34` exterior-foundation runs, wall `136` vertices / `68` triangles; roof `20` vertices / `18` triangles. No part/shared wall.
- Facing totals: ENE `42.745 m`, SSE `34.035 m`, WSW `42.769 m`, NNW `34.032 m`. The footprint has discontiguous returns/notches within these buckets; cardinal matching is not a layout.
- Opaque `world_solid` spray wall; roof collider not spray receiver. U restarts per run.

## Provenance, observation, and unknown coverage

| ID | Source | Supports | Excludes |
|---|---|---|---|
| `L01` | frozen OSM + receiver inventory/generated records, checked 2026-08-29 | exact identity/address/use/receiver/scale | appearance/style |
| `SV` | `discovery/facades/BATCH_02_STREETVIEW_OBSERVATIONS.md`, Navy Chapel section; checked 2026-08-29, capture Sep 2025 | SSE gable/entry, partial long side, broad material hierarchy and coverage limits | no stored/reused imagery; no exact endpoints/pane counts/other sides |

Exact official request: `NC-SV01` <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.81773,-122.37165&heading=300&pitch=7&fov=80> (`-9-3R6HngS2KcuZw9K3C_w`, **Sep 2025**), southeast on California Avenue looking northwest; complete SSE gabled entrance and partial long side. The same panorama was inspected at pitch `8`, FOV `55`. No imagery retained.

### Observed

- Public gabled entrance maps to the SSE family (`152.0°-152.2°`); the oblique provides only partial adjacent-long-side evidence.
- Dominant warm off-white/cream painted field with pale trim. Distance cannot distinguish stucco, painted board/siding or another substrate.
- SSE gable has one tall narrow vertically divided multi-pane window group above a shallow projecting entrance/porch. Paired pale/tan doors with sidelights or narrow glazing appear likely, but leaf/mullion counts are unverified.
- Small rectangular side windows occupy the gable field; the observed wing has repeated tall narrow window groups in complete pale surrounds.
- Dark grey-brown roof and square belfry/tower with pyramidal cap and visible cross. Gable, roof, belfry, cross and porch depth are geometry-owned.
- Reads as one tall hall with low ancillary wing, not a numeric stacked-story schedule.

### Unobserved

NNW rear, complete ENE/WSW long sides, rear doors, exact endpoints and small details remain unknown. Do not invent denominational symbols beyond the observed cross, stained-glass colors, arches, columns or exact siding courses.

## Region, motif, scale, classification, and seams

| Region | Scope | Status |
|---|---|---|
| SSE observed | SSE orientation family, exact discontiguous runs unresolved | gable/entry vocabulary; endpoint blocked |
| partial long side | exact family/run ownership unresolved | tall narrow window-group evidence only |
| unobserved/occluded | all remaining runs | placeholder/no modules |
| foundation/roof | below `4.040`, top `14.040` | geometry-owned |

`production_inference` cream-field starting band: base-color value `0.72-0.86` linear, roughness `0.62-0.84`, matte/low-satin; pale trim `0.76-0.90`, roughness `0.52-0.74`; dark roof appearance is evidence but roof remains excluded. No directional relief until substrate is resolved. Smallest-repeat finding: no facade-scale period; use complete `NC-GABLE-W`, `NC-ENTRY`, tentative `NC-SIDE-W`, and `NC-SMALL-W`. Module dimensions/pane pattern are low-confidence and not authorable from this distance; `10 m` is receiver calibration only.

| Output | Status | Required proof |
|---|---|---|
| `homogeneous_material_tile` | **spec-ready prototype** | warm-cream painted field; substrate remains generic |
| `architectural_pattern_tile` | **rejected** | no complete period or verified long-side cadence |
| `module_atlas` | **blocked** | pane/door counts and dimensions insufficient |
| `unique_elevation` | **blocked** | exact endpoints and three incomplete sides |

Legal seams: uninterrupted cream field and full verified trim/module boundaries. Forbidden: cuts through gable window/panes, doors/sidelights, porch/trim, small/side windows, gable rake/eave/corner, belfry or cross; all U resets. Never mirror the entrance to the rear.

## Godot BOM

| ID | Reserved path | Status |
|---|---|---|
| `MAT` | `res://game/resources/materials/world/navy_chapel_187/navy_chapel_primary.tres` | warm-cream generic painted field; prototype-ready |
| `MAT-SECONDARY` | `res://game/resources/materials/world/navy_chapel_187/navy_chapel_trim.tres` | pale trim; prototype-ready |
| `MOD` | `res://game/scenes/world/facades/navy_chapel_187/navy_chapel_modules.tscn` | GABLE-W, ENTRY, SIDE-W, SMALL-W | blocked by detail/dimensions |
| `LAYOUT` | `res://game/resources/facades/navy_chapel_187_layout.json` | exact-run schedule; blocked |
| `ATTACH` | `res://game/scenes/world/facades/navy_chapel_187/navy_chapel_facade.tscn` | render-only child; blocked |

## Geometry boundary and invariant before -> after

Facade pass may own observed PBR fields and complete shallow visual modules. It may not change height, roofline/steeple/silhouette, footprint, deep recesses/structural openings, collision, spray, terrain/foundation, navigation, access, generated data, or source contracts.

```text
before: building:w291189336:wall is one 10 m-high, 34-run opaque spray receiver
        using shared plaster_grey_04.

after:  that exact wall, roof, height, footprint, runs, collision, spray owner,
        foundations, source ID and generated bytes remain unchanged; a later
        noncolliding child adds only observed materials and complete shallow
        modules to exact endpoint-mapped run chains.
```

## Executable acceptance gates

- [x] Each appearance claim cites exact panorama URL/ID/date/direction/coverage.
- [ ] Exact `w291189336`, path/chunk, `10 m`, `34 / 153.581 m`, wall `68` and roof `18` triangles remain.
- [ ] Exact endpoints select layout; discontiguous same-normal runs/U resets do not imply continuity.
- [ ] No symbol, sign, entrance or roof motif is inferred from chapel use.
- [ ] Complete modules/edge products remain intact at seams.
- [ ] Render-only child has no collision/navigation/spray ownership; underlying wall remains hit owner.
- [ ] No height/roof/silhouette/footprint/foundation/terrain/collision/spray/generated-contract change.
- [ ] Independent review keeps occlusion/unknown and whole-object verdicts explicit.

## Explicit blockers

Only the SSE gable and a partial long side are observed. Exact endpoint map, substrate, pane/door counts, products and physical module scale are blocked by distance/landscaping. NNW, complete ENE/WSW and rear-door grammar are unknown.

## Normalized handoff

```yaml
schema_version: codex.building-texture-research/1
job: {job_id: navy_chapel_building_187_facade_reference_spec, checked_date: 2026-08-29, intended_use: conservative_material_handoff, target_asset_kind: homogeneous_material_tile}
target: {canonical_name: Navy Chapel Building 187 / 51 California Avenue, local_object_ids: [w291189336, building:w291189336, building:w291189336:wall], identity_confidence: high, receiver_path: WorldRoot/PlayableWorld/Buildings/x_-1__z_2__building_w291189336_wall/building_w291189336_wall}
sources:
  - {id: L01, authority: project, url_or_local_path: discovery/FACADE_RECEIVER_INVENTORY.json, checked_date: 2026-08-29, page_or_section: facade-receiver:w291189336, supports: [identity, address, receiver, scale], does_not_support: [appearance], image_reuse_permission: not_needed, stored_in_repo: false}
  - {id: SV, authority: secondary, url_or_local_path: discovery/facades/BATCH_02_STREETVIEW_OBSERVATIONS.md, checked_date: 2026-08-29, page_or_section: Navy_Chapel, supports: [SSE_material, gable_entry_motifs, partial_long_side, seams], does_not_support: [exact_endpoints, exact_pane_door_counts, other_sides], image_reuse_permission: observation_only, stored_in_repo: false}
reference_roles: {identity_context: [L01], massing: [L01], pattern_region: [SV], cadence_and_seams: [SV], material_surface: [SV], scale: [L01, SV], rejection_example: []}
pattern_regions: [{region_id: SSE_OBSERVED, local_scope: SSE_family_endpoints_unreconciled, periodicity: nonperiodic, must_not_share_tile_with: [NNW_UNOBSERVED]}]
motif_inventory: [NC_GABLE_W, NC_ENTRY, NC_SIDE_W_TENTATIVE, NC_SMALL_W]
motif_sequences: []
repeat_blueprint: {region_id: SSE_OBSERVED, smallest_cell_status: rejected_nonperiodic, period_tokens_horizontal: null, period_tokens_vertical: null, period_m: {x: null, y: null}, cell_contents_full_motifs: [NC_GABLE_W, NC_ENTRY, NC_SMALL_W], edge_fragments: {left: [], right: [], top: [], bottom: []}, edge_compositions_expected: {left_plus_right: [], top_plus_bottom: [], corners: []}, legal_seam_zones: [uninterrupted_cream, complete_trim_boundary], forbidden_seam_zones: [generated_U_resets, windows, panes, doors, porch, gable, belfry, cross, corners], fallback_if_not_proven: unique_elevation}
material_brief: {surface_family: generic_warm_cream_painted_field_substrate_unknown, base_color: value_0.72_to_0.86_linear, finish: matte_to_low_satin, relief_direction_and_frequency: none_until_substrate_resolved, roughness: 0.62_to_0.84, variation_and_weathering: subtle_only, maps_requested: [albedo, roughness, optional_subtle_normal], maps_forbidden: [height_displacement, baked_lighting, photographic_reflections, invented_siding_courses], tile_scale_status: color_finish_ready_relief_blocked, tile_scale_m: {x: null, y: null}}
excluded_architectural_features: [{feature: roof_steeple_silhouette_structural_openings, owner: geometry, reason: invariant}]
uncertainty: [{unknown: module_details_dimensions_endpoints_and_three_sides, impact: material_prototype_only, safe_fallback: cream_field_without_modules, stop_if_required: true}]
hard_mismatch_gates:
  - {scope: identity, reject_if: receiver_is_not_building_w291189336_wall, proof_required: exact_metadata}
  - {scope: evidence, reject_if: symbol_or_style_is_inferred_from_use, proof_required: observation_ledger}
  - {scope: geometry, reject_if: roof_silhouette_collision_spray_foundation_or_generated_contract_changes, proof_required: exact_receiver_audit}
research_verdict: {ready_for_generation: true_for_conservative_material_prototype_only, recommended_output_kind: homogeneous_material_tile, blockers: [module_detail, endpoint_map, three_incomplete_sides]}
```

## Final status

- Identity/receiver: **ready**.
- Conservative cream material prototype: **specification-ready**.
- Opening modules and unique elevation: **blocked**.

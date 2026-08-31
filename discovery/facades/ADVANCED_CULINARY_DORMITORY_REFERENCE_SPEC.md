# Advanced Culinary Dormitory / 487–489 4th Street facade reference specification

Checked: **2026-08-29**
Mode: **research and implementation handoff only**
Target: **`w34313514` / `building:w34313514:wall`**

## Handoff verdict

The frozen source joins way `w34313514` to the name **Advanced Culinary Dormitory** and address **487–489 4th Street**, but its own source note says the distant sign may have been misread. The official coverage pass found no frontage elevation and could not reconcile current visual identity. Treat the receiver join as exact, the current name as low confidence, and every target-specific facade output as blocked.

## Evidence labels and exact receiver

Use `verified_fact`, `reference_observation`, `production_inference`, and `unknown` distinctly.

| Item | Exact value | Status |
|---|---|---|
| Frozen name/address | Advanced Culinary Dormitory; 487–489 4th Street | exact tag-to-way join; real-world identity low confidence |
| Source | way `34313514`, version `3`, `2011-05-01T10:26:03Z` | exact snapshot |
| Frozen tags | `building=residential`, `source=Yahoo`; source note: `I may have misread what the sign said from the distance ;)` | explicit identity warning; no appearance support |
| Logical/wall/roof | `building:w34313514`; `building:w34313514:wall`; `building:w34313514:roof` | direct receiver |
| Chunk/runtime | `x_0__z_1`; `WorldRoot/PlayableWorld/Buildings/x_0__z_1__building_w34313514_wall/building_w34313514_wall` | exact naming derivation |
| Materials | wall `plaster_grey_04`; roof `bitumen`; no override | shared placeholders |

### Generated contract

- `default_6m`, `6 m`; base/top `3.719 / 9.719 m`; lowest foundation vertex `3.346 m`. The fallback is not real-world height/story evidence.
- Area `1460.746 m²`; serialized perimeter `313.904 m`; visible wall `313.900 m`.
- Wall `44` runs, `176` vertices / `88` triangles; roof `24` vertices / `22` triangles; no shared-part walls.
- Facing totals: ENE `81.030 m`; SSE `75.917 m`; WSW `81.065 m`; NNW `75.888 m`.
- Exact groups: ENE `62.0° 4/34.814 m`, `62.1° 7/46.216`; SSE `152.0° 8/54.340`, `152.1° 4/21.577`; WSW `242.0° 1/4.499`, `242.1° 9/70.333`, `242.2° 3/6.232`; NNW `332.0° 2/8.794`, `332.1° 5/63.684`, `332.2° 1/3.410`.
- Wall is opaque `world_solid` and sole spray receiver; roof is opaque collider/non-spray. U restarts per run.

## Provenance, coverage and unknowns

| ID | Source | Supports | Excludes |
|---|---|---|---|
| `L01` | frozen OSM + receiver/generated records, checked 2026-08-29 | exact source join/receiver/topology and explicit identity warning | confirmed real-world identity, appearance, measured height/stories |
| `SV` | `discovery/facades/BATCH_03_STREETVIEW_OBSERVATIONS.md`, checked 2026-08-29 | official frontage coverage failure | no current identity or facade appearance |

Observed sides: **none**. Unobserved: all ENE, SSE, WSW and NNW families. Exact request `ACD-NO01`, https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82105,-122.36975&heading=330&pitch=0&fov=75, returned no Street View imagery at the 4th Street frontage. Coverage mode showed no official frontage road line, and distant context could not establish current identity or appearance. There is no target panorama ID or capture date.

Present use, materials, story/cadence, windows/doors/entries, signs, balconies, canopies, dimensions and condition remain unknown; the fallback `6 m` height was not validated. Do not reproduce the uncertain name as signage or author from the word “dormitory.” Google imagery was viewed transiently; no image, crop, screenshot, copied pixel, download, redistribution or repository asset was retained.

## Material/motif/scale, classifications and seams

The only physical receiver scale is generated geometry; `6 m` is low-confidence real-world scale.

| Output | Status | Gate |
|---|---|---|
| `homogeneous_material_tile` | blocked | identity reconciliation plus coherent observed field |
| `architectural_pattern_tile` | blocked | identity reconciliation plus complete repeat/boundaries |
| `module_atlas` | blocked | identity reconciliation plus complete observed motifs/scale |
| `unique_elevation` | blocked | confirmed target and observed elevation on exact endpoints |

Future legal seams require uninterrupted homogeneous field, complete repeat cell or complete module boundary. Forbidden seams include U resets, motif interiors, corners, receiver top/foundation and every feature not confidently joined to this receiver. Similar long side totals do not establish shared schedules.

## Godot BOM

| ID | Reserved path | Status |
|---|---|---|
| `MAT` | `res://game/resources/materials/world/advanced_culinary_dormitory/culinary_dorm_primary.tres` | blocked |
| `MAT-SECONDARY` | `res://game/resources/materials/world/advanced_culinary_dormitory/culinary_dorm_secondary.tres` | blocked |
| `MOD` | `res://game/scenes/world/facades/advanced_culinary_dormitory/culinary_dorm_modules.tscn` | blocked |
| `LAYOUT` | `res://game/resources/facades/advanced_culinary_dormitory_487_489_4th_layout.json` | exact-run schedule; blocked |
| `ATTACH` | `res://game/scenes/world/facades/advanced_culinary_dormitory/culinary_dorm_facade.tscn` | later noncolliding child |

## Geometry boundary and invariant example

Only evidence-backed PBR fields and complete shallow render-only modules may be facade-owned after identity reconciliation. Height/stories, roof/silhouette, footprint, deep/structural openings, collision, spray, navigation, foundations/terrain and generated/source contracts remain invariant.

```text
before: building:w34313514:wall is a default-6 m, 44-run opaque spray receiver
        using shared plaster_grey_04; its frozen human-readable name is disputed.

after:  that exact receiver, fallback height, footprint, roof, runs, collision,
        spray owner, foundation, source ID and generated bytes remain unchanged;
        only independently joined, evidence-backed fields/modules may be added.
```

## Acceptance checklist and blockers

- [ ] Independent observation reconciles the real building to exact receiver `w34313514` before any appearance work.
- [ ] Every visual claim cites exact official panorama URL/ID/date/direction/coverage.
- [ ] Exact receiver/path/chunk, `default_6m`, `44 / 313.900 m`, wall `88` and roof `22` triangles remain.
- [ ] Neither the disputed name nor `building=residential` becomes motif/style/story evidence.
- [ ] Exact endpoint chains drive layout; no U reset/orientation family creates phase.
- [ ] Visual child adds no physics/navigation/spray ownership.
- [ ] No massing/roof/footprint/foundation/terrain/collision/spray/generated change.

Absent official frontage evidence leaves current identity unresolved and blocks appearance, measured height/stories, motif scale and exact side/run ownership.

## Normalized handoff

```yaml
schema_version: codex.building-texture-research/1
job: {job_id: advanced_culinary_dormitory_facade_reference_spec, checked_date: 2026-08-29, intended_use: disputed_identity_blocked_receiver_handoff, target_asset_kind: unique_elevation}
target: {canonical_name: Advanced Culinary Dormitory / 487-489 4th Street, local_object_ids: [w34313514, building:w34313514, building:w34313514:wall], identity_confidence: low, receiver_path: WorldRoot/PlayableWorld/Buildings/x_0__z_1__building_w34313514_wall/building_w34313514_wall}
sources:
  - {id: L01, authority: project, url_or_local_path: discovery/FACADE_RECEIVER_INVENTORY.json, checked_date: 2026-08-29, page_or_section: facade-receiver:w34313514, supports: [source_join, receiver, topology, identity_warning], does_not_support: [confirmed_real_world_identity, appearance, measured_height], image_reuse_permission: not_needed, stored_in_repo: false}
  - {id: SV, authority: secondary, url_or_local_path: discovery/facades/BATCH_03_STREETVIEW_OBSERVATIONS.md, checked_date: 2026-08-29, page_or_section: Advanced_Culinary_Dormitory, supports: [official_coverage_failure], does_not_support: [current_identity, appearance, capture_date], image_reuse_permission: observation_only, stored_in_repo: false}
reference_roles: {identity_context: [L01, SV], massing: [L01], pattern_region: [SV], cadence_and_seams: [SV], material_surface: [SV], scale: [L01, SV], rejection_example: []}
pattern_regions: [{region_id: ALL_WALLS, local_scope: exact_44_runs, periodicity: unknown, must_not_share_tile_with: []}]
motif_inventory: []
motif_sequences: []
repeat_blueprint: {region_id: ALL_WALLS, smallest_cell_status: unknown, period_tokens_horizontal: null, period_tokens_vertical: null, period_m: {x: null, y: null}, cell_contents_full_motifs: [], edge_fragments: {left: [], right: [], top: [], bottom: []}, edge_compositions_expected: {left_plus_right: [], top_plus_bottom: [], corners: []}, legal_seam_zones: [], forbidden_seam_zones: [generated_U_resets, unobserved_or_unjoined_motifs], fallback_if_not_proven: unique_elevation}
material_brief: {surface_family: unknown, base_color: unknown, finish: unknown, relief_direction_and_frequency: unknown, roughness: unknown, variation_and_weathering: unknown, maps_requested: [], maps_forbidden: [height_displacement, baked_lighting, photographic_reflections], tile_scale_status: unknown, tile_scale_m: {x: null, y: null}}
excluded_architectural_features: [{feature: height_stories_roof_silhouette_structural_openings, owner: geometry, reason: invariant}]
uncertainty:
  - {unknown: real_world_identity, impact: appearance_cannot_be_authored, safe_fallback: shared_placeholder, stop_if_required: true}
  - {unknown: appearance_story_count_scale_and_endpoint_mapping, impact: no_output_ready, safe_fallback: shared_placeholder, stop_if_required: true}
hard_mismatch_gates:
  - {scope: identity, reject_if: reference_building_not_independently_reconciled_to_w34313514, proof_required: exact_spatial_and_visual_join}
  - {scope: geometry, reject_if: massing_collision_spray_foundation_or_generated_contract_changes, proof_required: exact_receiver_audit}
research_verdict: {ready_for_generation: false, recommended_output_kind: null, blockers: [identity_reconciliation_unresolved, absent_official_frontage_evidence, no_endpoint_mapping, no_material_or_scale_evidence, default_height_not_measurement]}
```

## Final status

- Exact source-to-receiver join: **ready**.
- Real-world identity and facade outputs: **blocked by absent official frontage evidence**.

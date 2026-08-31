# Education Center Building 29A / 550 Avenue H facade reference specification

Checked: **2026-08-29**
Mode: **research and implementation handoff only**
Target: **`w109905031` / `building:w109905031:wall`**

## Handoff verdict

The frozen source confirms **Education Center Building 29A**, **550 Avenue H**, on one direct 16-run receiver. March 2025 official views reach its NNW and WSW/NNW area, but full-height storage containers, fence and vehicles completely occlude the facade. Occlusion is not appearance evidence. All target-specific outputs remain blocked.

## Evidence labels and exact receiver

Use `verified_fact`, `reference_observation`, `production_inference`, and `unknown` distinctly.

| Item | Exact value | Status |
|---|---|---|
| Identity/address | Education Center Building 29A; 550 Avenue H | exact frozen tags |
| Source | way `109905031`, version `2`, `2011-04-25T07:08:37Z` | exact snapshot |
| Frozen tags | `building=abandoned`, `building:levels=1`, `source=Yahoo` | identity/massing only; current condition unproved |
| Logical/wall/roof | `building:w109905031`; `building:w109905031:wall`; `building:w109905031:roof` | direct receiver |
| Chunk/runtime | `x_0__z_-1`; `WorldRoot/PlayableWorld/Buildings/x_0__z_-1__building_w109905031_wall/building_w109905031_wall` | exact naming derivation |
| Materials | wall `plaster_grey_04`; roof `bitumen`; no override | shared placeholders |

### Generated contract

- `osm_levels`, `3 m` from one frozen level; base/top `3.490 / 6.490 m`; lowest foundation vertex `3.360 m`.
- Area `890.062 m²`; serialized perimeter `166.313 m`; visible wall `166.314 m`.
- Wall `16` runs, `64` vertices / `32` triangles; roof `8` vertices / `6` triangles; no shared-part walls.
- Four exact orientation families: ENE `62.3°`, `2 / 18.525 m`; SSE `152.3°`, `7 / 64.638 m`; WSW `242.3°`, `2 / 18.520 m`; NNW `332.3°`, `5 / 64.631 m`.
- Wall is opaque `world_solid` and sole spray receiver; roof is opaque collider/non-spray. U restarts per run.

## Provenance, coverage and unknowns

| ID | Source | Supports | Excludes |
|---|---|---|---|
| `L01` | frozen OSM + receiver/generated records, checked 2026-08-29 | identity/address/one-level receiver/topology | present abandonment, appearance |
| `EC29A-SV01` | official Google Street View panorama `o96ZjQzRGjybIV2jQd6hDw`, March 2025; exact URL below | NNW viewpoint reconciliation and complete occlusion | no target facade appearance |
| `EC29A-SV02` | official Google Street View panorama `emqMw-XLaeQ03pPhEs3v-Q`, March 2025; exact URL below | WSW/NNW corner-area reconciliation and complete occlusion | no target facade appearance |

### Observed / unobserved and provenance

- `EC29A-SV01`: https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82468,-122.36890&heading=150&pitch=0&fov=75; actual viewpoint `37.8246956,-122.3689247`; accessed 2026-08-29; displayed **March 2025**; north of footprint looking southeast `150°`; NNW side hidden by full-height containers/fence.
- `EC29A-SV02`: https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82452,-122.36925&heading=100&pitch=0&fov=75; actual viewpoint `37.8245475,-122.3692554`; accessed 2026-08-29; displayed **March 2025**; west/northwest looking east `100°`; WSW/NNW corner area hidden by the same container wall.

Usable observed facade sides: **none**. Occluded viewpoint areas: NNW and WSW/NNW corner. ENE and SSE were not viewed. Containers, their corrugation/doors/signs, fence and parked vehicles are foreground objects, never facade motifs. The sliver above them is not a measured roof edge.

Material fields, openings, entry cadence, signs, vents, foundation exposure, dimensions, weathering and current condition remain unknown; `3 m / 1 level` was neither confirmed nor contradicted. Do not transfer 29B–29E appearance. Google imagery was transiently viewed; no image, crop, screenshot, copied pixel, download, redistribution or repository asset was retained.

## Material/motif/scale, classifications and seams

The `3 m / 1 level` receiver is generated from frozen source data, not a measured facade module.

| Output | Status | Gate |
|---|---|---|
| `homogeneous_material_tile` | blocked | coherent observed field and bounded PBR/scale |
| `architectural_pattern_tile` | blocked | complete repeat and boundary products |
| `module_atlas` | blocked | complete motifs and physical bounds |
| `unique_elevation` | blocked | observed elevation on exact endpoint chain |

Future legal seams require uninterrupted homogeneous field, complete repeat cell or complete module boundary. Forbidden seams include U resets, motif interiors, corners, receiver top/foundation and unobserved features. Same-normal returns are separate placement chains unless endpoint reconciliation proves continuity.

## Godot BOM

| ID | Reserved path | Status |
|---|---|---|
| `MAT` | `res://game/resources/materials/world/education_center_b29a/education_center_primary.tres` | blocked |
| `MAT-SECONDARY` | `res://game/resources/materials/world/education_center_b29a/education_center_secondary.tres` | blocked |
| `MOD` | `res://game/scenes/world/facades/education_center_b29a/education_center_modules.tscn` | blocked |
| `LAYOUT` | `res://game/resources/facades/education_center_b29a_550_avenue_h_layout.json` | exact-run schedule; blocked |
| `ATTACH` | `res://game/scenes/world/facades/education_center_b29a/education_center_facade.tscn` | later noncolliding child |

## Geometry boundary and invariant example

Only observed PBR fields and complete shallow render-only modules may be facade-owned. Height/level, roof/silhouette, footprint, deep/structural openings, collision, spray, navigation, foundations/terrain and generated/source contracts remain invariant.

```text
before: building:w109905031:wall is a 3 m-high, one-level, 16-run opaque
        spray receiver using shared plaster_grey_04.

after:  that exact receiver, height/level, footprint, roof, runs, collision,
        spray owner, foundation, source ID and generated bytes remain unchanged;
        only evidence-backed fields/modules may be added to mapped run chains.
```

## Acceptance checklist and blockers

- [ ] Every visual claim cites exact official panorama URL/ID/date/direction/coverage.
- [ ] Exact receiver/path/chunk, `3 m / 1 level`, `16 / 166.314 m`, wall `32` and roof `6` triangles remain.
- [ ] Frozen `abandoned` is not treated as present condition.
- [ ] No facade transfer from other 29-series buildings.
- [ ] Exact endpoint chains drive layout; no U reset/orientation family creates phase.
- [ ] Visual child adds no physics/navigation/spray ownership.
- [ ] No massing/roof/footprint/foundation/terrain/collision/spray/generated change.

Complete public-side occlusion blocks appearance, present condition, physical motif scale and exact side/run ownership.

## Normalized handoff

```yaml
schema_version: codex.building-texture-research/1
job: {job_id: education_center_b29a_facade_reference_spec, checked_date: 2026-08-29, intended_use: occluded_exact_receiver_handoff, target_asset_kind: unique_elevation}
target: {canonical_name: Education Center Building 29A / 550 Avenue H, local_object_ids: [w109905031, building:w109905031, building:w109905031:wall], identity_confidence: high, receiver_path: WorldRoot/PlayableWorld/Buildings/x_0__z_-1__building_w109905031_wall/building_w109905031_wall}
sources:
  - {id: L01, authority: project, url_or_local_path: discovery/FACADE_RECEIVER_INVENTORY.json, checked_date: 2026-08-29, page_or_section: facade-receiver:w109905031, supports: [identity, address, massing, receiver, topology], does_not_support: [appearance, present_abandonment], image_reuse_permission: not_needed, stored_in_repo: false}
  - {id: EC29A-SV01, authority: secondary, url_or_local_path: "https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82468,-122.36890&heading=150&pitch=0&fov=75", checked_date: 2026-08-29, page_or_section: pano_o96ZjQzRGjybIV2jQd6hDw_March_2025, supports: [NNW_viewpoint_reconciliation, complete_occlusion], does_not_support: [facade_appearance], image_reuse_permission: observation_only, stored_in_repo: false}
  - {id: EC29A-SV02, authority: secondary, url_or_local_path: "https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82452,-122.36925&heading=100&pitch=0&fov=75", checked_date: 2026-08-29, page_or_section: pano_emqMw-XLaeQ03pPhEs3v-Q_March_2025, supports: [WSW_NNW_corner_reconciliation, complete_occlusion], does_not_support: [facade_appearance], image_reuse_permission: observation_only, stored_in_repo: false}
reference_roles: {identity_context: [L01], massing: [L01], pattern_region: [SV], cadence_and_seams: [SV], material_surface: [SV], scale: [L01, SV], rejection_example: []}
pattern_regions: [{region_id: ALL_WALLS, local_scope: exact_16_runs, periodicity: unknown, must_not_share_tile_with: []}]
motif_inventory: []
motif_sequences: []
repeat_blueprint: {region_id: ALL_WALLS, smallest_cell_status: unknown, period_tokens_horizontal: null, period_tokens_vertical: null, period_m: {x: null, y: null}, cell_contents_full_motifs: [], edge_fragments: {left: [], right: [], top: [], bottom: []}, edge_compositions_expected: {left_plus_right: [], top_plus_bottom: [], corners: []}, legal_seam_zones: [], forbidden_seam_zones: [generated_U_resets, unobserved_motifs], fallback_if_not_proven: unique_elevation}
material_brief: {surface_family: unknown, base_color: unknown, finish: unknown, relief_direction_and_frequency: unknown, roughness: unknown, variation_and_weathering: unknown, maps_requested: [], maps_forbidden: [height_displacement, baked_lighting, photographic_reflections], tile_scale_status: unknown, tile_scale_m: {x: null, y: null}}
excluded_architectural_features: [{feature: height_level_roof_silhouette_structural_openings, owner: geometry, reason: invariant}]
uncertainty: [{unknown: appearance_present_condition_and_endpoint_mapping, impact: no_output_ready, safe_fallback: shared_placeholder, stop_if_required: true}]
hard_mismatch_gates:
  - {scope: identity, reject_if: receiver_is_not_building_w109905031_wall, proof_required: exact_metadata}
  - {scope: geometry, reject_if: massing_collision_spray_foundation_or_generated_contract_changes, proof_required: exact_receiver_audit}
research_verdict: {ready_for_generation: false, recommended_output_kind: null, blockers: [complete_public_side_occlusion, ENE_SSE_unviewed, present_condition_unknown, no_endpoint_mapping, no_material_or_scale_evidence]}
```

## Final status

- Identity/receiver: **ready**.
- Facade outputs: **blocked by complete public-side occlusion**.

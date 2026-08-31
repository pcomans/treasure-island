# US Dept of Labor Job Corps Food Service Building 368 facade reference specification

Checked: **2026-08-29**
Mode: **research and implementation handoff only**
Target: **`w34313521` / `building:w34313521:wall`**

## Handoff verdict

The frozen source confirms **US Dept of Labor Job Corps Food Service Building 368**, **575 Avenue D**, on one direct 36-run receiver. The official coverage pass found no target elevation; a contributor path was explicitly excluded. Its frozen `amenity=restaurant` tag and name do not establish present use, signage or appearance. All target-specific facade outputs are blocked.

## Evidence labels and exact receiver

Use `verified_fact`, `reference_observation`, `production_inference`, and `unknown` distinctly.

| Item | Exact value | Status |
|---|---|---|
| Identity/address | US Dept of Labor Job Corps Food Service Building 368; 575 Avenue D | exact frozen tags |
| Source | way `34313521`, version `4`, `2018-01-25T17:34:27Z` | exact snapshot |
| Frozen tags | `amenity=restaurant`, `building=yes`, `height=6`, `source=Yahoo` | identity/massing only; current use unproved |
| Logical/wall/roof | `building:w34313521`; `building:w34313521:wall`; `building:w34313521:roof` | direct receiver |
| Chunk/runtime | `x_-1__z_0`; `WorldRoot/PlayableWorld/Buildings/x_-1__z_0__building_w34313521_wall/building_w34313521_wall` | exact naming derivation |
| Materials | wall `plaster_grey_04`; roof `bitumen`; no override | shared placeholders |

### Generated contract

- `osm_height`, `6 m`; base/top `3.091 / 9.091 m`; lowest foundation vertex `2.633 m`.
- Area `5237.902 m²`; serialized perimeter `352.797 m`; visible wall `352.795 m`.
- Wall `36` runs, `144` vertices / `72` triangles; roof `12` vertices / `10` triangles; no shared-part walls.
- Exact orientation families: ENE `62.3°`, `11 / 98.029 m`; SSE `152.3°`, `6 / 78.362 m`; WSW `242.3°`, `9 / 98.034 m`; NNW `332.3°`, `10 / 78.370 m`.
- Wall is opaque `world_solid` and sole spray receiver; roof is opaque collider/non-spray. U restarts per run.

## Provenance, coverage and unknowns

| ID | Source | Supports | Excludes |
|---|---|---|---|
| `L01` | frozen OSM + receiver/generated records, checked 2026-08-29 | identity/address/tagged height/receiver/topology | appearance, present use or signage |
| `SV` | `discovery/facades/BATCH_03_STREETVIEW_OBSERVATIONS.md`, checked 2026-08-29 | two official coverage failures and contributor-path exclusion | no appearance or capture date |

Observed official sides: **none**. Unobserved: all ENE, SSE, WSW and NNW families. Exact requests:

- `B368-NO01`: https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82220,-122.37140&heading=270&pitch=0&fov=75 — no Street View imagery at the Avenue D request.
- `B368-NO02`: https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8221941,-122.3730943&heading=65&pitch=0&fov=75 — no official Street View panorama at the Seven Seas Avenue request.

Coverage exposed a July 2023 **TyFlow io contributor** path at `37.8221758,-122.3730929`, panorama `CIHM0ogKEICAgICpvKnjkAE` (type `!1e10`). It was excluded and supports no claim. No official target panorama ID/capture date exists. Material fields, story/cadence, windows, service/loading doors, entries, canopies, kitchen exhaust, signage, dimensions and condition are unknown; `6 m` was not visually validated.

No image, crop, screenshot, copied pixel, download, redistribution or repository asset was retained. Contributor imagery must not be transcribed or paraphrased.

## Material/motif/scale, classifications and seams

The `6 m` receiver height is not an observed story/bay dimension.

| Output | Status | Gate |
|---|---|---|
| `homogeneous_material_tile` | blocked | coherent observed field and bounded PBR/scale |
| `architectural_pattern_tile` | blocked | complete repeat and boundary products |
| `module_atlas` | blocked | complete motifs and physical bounds |
| `unique_elevation` | blocked | observed elevation on exact endpoint chain |

Future legal seams require uninterrupted homogeneous field, a complete repeat cell or complete module boundary. Forbidden seams include U resets, opening/sign/vent interiors, corners, receiver top/foundation and unobserved features. The four directional families are not interchangeable schedules.

## Godot BOM

| ID | Reserved path | Status |
|---|---|---|
| `MAT` | `res://game/resources/materials/world/job_corps_food_service_b368/food_service_primary.tres` | blocked |
| `MAT-SECONDARY` | `res://game/resources/materials/world/job_corps_food_service_b368/food_service_secondary.tres` | blocked |
| `MOD` | `res://game/scenes/world/facades/job_corps_food_service_b368/food_service_modules.tscn` | blocked |
| `LAYOUT` | `res://game/resources/facades/job_corps_food_service_b368_575_avenue_d_layout.json` | exact-run schedule; blocked |
| `ATTACH` | `res://game/scenes/world/facades/job_corps_food_service_b368/food_service_facade.tscn` | later noncolliding child |

## Geometry boundary and invariant example

Only observed PBR fields and complete shallow render-only modules may be facade-owned. Height, roof/silhouette, footprint, deep/structural openings, collision, spray, navigation, foundations/terrain and generated/source contracts remain invariant.

```text
before: building:w34313521:wall is a 6 m-high, 36-run opaque spray receiver
        using shared plaster_grey_04.

after:  that exact receiver, height, footprint, roof, runs, collision, spray
        owner, foundations, source ID and generated bytes remain unchanged;
        only evidence-backed fields/modules may be added to mapped run chains.
```

## Acceptance checklist and blockers

- [ ] Every visual claim cites exact official panorama URL/ID/date/direction/coverage.
- [ ] Exact receiver/path/chunk, `6 m`, `36 / 352.795 m`, wall `72` and roof `10` triangles remain.
- [ ] Frozen restaurant/name tags are not treated as current-use, signage or motif evidence.
- [ ] Exact endpoint chains drive layout; no U reset/orientation family creates phase.
- [ ] Complete motifs and seam products remain intact.
- [ ] Visual child adds no physics/navigation/spray ownership.
- [ ] No massing/roof/footprint/foundation/terrain/collision/spray/generated change.

Absent approved official public-elevation evidence blocks appearance, current use, physical motif scale and exact side/run ownership.

## Normalized handoff

```yaml
schema_version: codex.building-texture-research/1
job: {job_id: job_corps_food_service_b368_facade_reference_spec, checked_date: 2026-08-29, intended_use: blocked_exact_receiver_handoff, target_asset_kind: unique_elevation}
target: {canonical_name: US Dept of Labor Job Corps Food Service Building 368 / 575 Avenue D, local_object_ids: [w34313521, building:w34313521, building:w34313521:wall], identity_confidence: high, receiver_path: WorldRoot/PlayableWorld/Buildings/x_-1__z_0__building_w34313521_wall/building_w34313521_wall}
sources:
  - {id: L01, authority: project, url_or_local_path: discovery/FACADE_RECEIVER_INVENTORY.json, checked_date: 2026-08-29, page_or_section: facade-receiver:w34313521, supports: [identity, address, massing, receiver, topology], does_not_support: [appearance, current_use, signage], image_reuse_permission: not_needed, stored_in_repo: false}
  - {id: SV, authority: secondary, url_or_local_path: discovery/facades/BATCH_03_STREETVIEW_OBSERVATIONS.md, checked_date: 2026-08-29, page_or_section: Food_Service_B368, supports: [official_coverage_failure, contributor_path_exclusion], does_not_support: [appearance, capture_date], image_reuse_permission: observation_only, stored_in_repo: false}
reference_roles: {identity_context: [L01], massing: [L01], pattern_region: [SV], cadence_and_seams: [SV], material_surface: [SV], scale: [L01, SV], rejection_example: []}
pattern_regions: [{region_id: ALL_WALLS, local_scope: exact_36_runs, periodicity: unknown, must_not_share_tile_with: []}]
motif_inventory: []
motif_sequences: []
repeat_blueprint: {region_id: ALL_WALLS, smallest_cell_status: unknown, period_tokens_horizontal: null, period_tokens_vertical: null, period_m: {x: null, y: null}, cell_contents_full_motifs: [], edge_fragments: {left: [], right: [], top: [], bottom: []}, edge_compositions_expected: {left_plus_right: [], top_plus_bottom: [], corners: []}, legal_seam_zones: [], forbidden_seam_zones: [generated_U_resets, unobserved_motifs], fallback_if_not_proven: unique_elevation}
material_brief: {surface_family: unknown, base_color: unknown, finish: unknown, relief_direction_and_frequency: unknown, roughness: unknown, variation_and_weathering: unknown, maps_requested: [], maps_forbidden: [height_displacement, baked_lighting, photographic_reflections], tile_scale_status: unknown, tile_scale_m: {x: null, y: null}}
excluded_architectural_features: [{feature: height_roof_silhouette_structural_openings, owner: geometry, reason: invariant}]
uncertainty: [{unknown: appearance_current_use_and_endpoint_mapping, impact: no_output_ready, safe_fallback: shared_placeholder, stop_if_required: true}]
hard_mismatch_gates:
  - {scope: identity, reject_if: receiver_is_not_building_w34313521_wall, proof_required: exact_metadata}
  - {scope: geometry, reject_if: massing_collision_spray_foundation_or_generated_contract_changes, proof_required: exact_receiver_audit}
research_verdict: {ready_for_generation: false, recommended_output_kind: null, blockers: [absent_approved_official_elevation, excluded_contributor_only_path, current_use_unknown, no_endpoint_mapping, no_material_or_scale_evidence]}
```

## Final status

- Identity/receiver: **ready**.
- Facade outputs: **blocked by absent approved official elevation**.

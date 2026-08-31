# Education Center Building 29B / 768 Avenue H facade reference specification

Checked: **2026-08-29**
Mode: **research and implementation handoff only**
Target: **`w34313523` / `building:w34313523:wall`**

## Handoff verdict

The frozen source confirms **Education Center Building 29B**, **768 Avenue H**, on one direct 20-run receiver. March and September 2025 official views border the footprint but expose only a green corrugated perimeter/container enclosure and redevelopment context—not the facade. Current survival versus total occlusion/removal remains unknown. All target-specific facade outputs are blocked.

## Evidence labels and exact receiver

Use `verified_fact`, `reference_observation`, `production_inference`, and `unknown` distinctly.

| Item | Exact value | Status |
|---|---|---|
| Identity/address | Education Center Building 29B; 768 Avenue H | exact frozen tags |
| Source | way `34313523`, version `4`, `2011-05-01T10:26:03Z` | snapshot; currentness not claimed |
| Frozen tags | `building=abandoned`, `building:levels=1`, `source=Yahoo` | identity/massing only |
| Logical/wall/roof | `building:w34313523`; `building:w34313523:wall`; `building:w34313523:roof` | direct standalone receiver |
| Chunk/runtime | `x_0__z_-1`; `WorldRoot/PlayableWorld/Buildings/x_0__z_-1__building_w34313523_wall/building_w34313523_wall` | exact naming derivation |
| Materials | wall `plaster_grey_04`; roof `bitumen`; no override | shared placeholders |

### Generated contract

- `osm_levels`, `3 m` from one frozen level; base/top `3.515 / 6.515 m`; lowest foundation vertex `3.393 m`.
- Area `850.367 m²`; serialized perimeter `163.382 m`; visible wall `163.385 m`.
- Wall `20` runs, `80` vertices / `40` triangles; roof `10` vertices / `8` triangles; no shared-part walls.
- Exact groups: ENE `62.3° 4/16.939 m`; SSE `152.3° 7/64.751`; WSW `242.3° 4/16.950`; NNW `332.3° 5/64.746`.
- Wall is opaque `world_solid` and sole spray receiver; roof is opaque collider/non-spray. U restarts per run; V is world y / 10.

## Provenance, coverage and unknowns

| ID | Source | Supports | Excludes |
|---|---|---|---|
| `L01` | frozen OSM + inventory/generated records, checked 2026-08-29 | identity/address/level/receiver/topology | appearance and present abandonment |
| `EC29B-SV01` | official Google Street View panorama `gnRrpIe5wBUEXwYoTcE6NQ`, March 2025; exact URL below | 8th Street viewpoint/footprint reconciliation | facade fully screened |
| `EC29B-SV02` | official Google Street View panorama `xPpjSLPIE2h--fbX_TB8OA`, September 2025; exact URL below | Avenue H viewpoint/footprint reconciliation | facade fully screened |

### Observed / unobserved and provenance

- `EC29B-SV01`: https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8247245,-122.3684129&heading=224&pitch=0&fov=75; panorama `gnRrpIe5wBUEXwYoTcE6NQ`; actual viewpoint `37.8247579,-122.3683720`; accessed 2026-08-29; displayed **March 2025**; 651 8th Street, looking southwest `224°`.
- `EC29B-SV02`: https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8244589,-122.3694416&heading=95&pitch=0&fov=75; panorama `xPpjSLPIE2h--fbX_TB8OA`; actual viewpoint `37.8244829,-122.3694778`; accessed 2026-08-29; displayed **September 2025**; 753 Avenue H, looking east `95°`.

Usable observed facade sides: **none**. The NNW/ENE area and WSW/SSE area are blocked by a tall green corrugated perimeter/container wall, gates, fencing, utility poles, parking and redevelopment/construction context. These are site/foreground facts, never facade vocabulary. Current existence is `unknown`: the views do not distinguish full occlusion from removal.

All facade materials, color/value, roof edge, openings, entry, signs, cadence, scale, condition and endpoint mapping remain unknown. The `3 m / 1 level` contract was not visually confirmed or contradicted. Google imagery was transiently viewed; no image, crop, screenshot, copied pixel, download, redistribution or repository asset was retained.

## Material, motif, scale, classifications and seams

The `3 m / 1 level` receiver is not a measured module. No coherent material field, motif, physical span or smallest repeat is established.

| Output | Status | Gate |
|---|---|---|
| `homogeneous_material_tile` | blocked | observed coherent field and bounded PBR/scale |
| `architectural_pattern_tile` | blocked | proven complete period and edge products |
| `module_atlas` | blocked | complete observed motifs and physical bounds |
| `unique_elevation` | blocked | observed schedule reconciled to exact endpoints |

Future legal seams require uninterrupted homogeneous field, verified full unit or complete module boundary. Forbidden seams include generated U resets, motif interiors, corners, receiver top/foundation, same-normal discontiguous chains and every unobserved feature.

## Godot bill of materials

| ID | Reserved path | Status |
|---|---|---|
| `MAT` | `res://game/resources/materials/world/education_center_b29b/education_center_b29b_primary.tres` | blocked |
| `MAT-SECONDARY` | `res://game/resources/materials/world/education_center_b29b/education_center_b29b_secondary.tres` | blocked |
| `MOD` | `res://game/scenes/world/facades/education_center_b29b/education_center_b29b_modules.tscn` | blocked |
| `LAYOUT` | `res://game/resources/facades/education_center_b29b_768_avenue_h_layout.json` | exact-run schedule; blocked |
| `ATTACH` | `res://game/scenes/world/facades/education_center_b29b/education_center_b29b_facade.tscn` | later noncolliding child |

## Geometry boundary and invariant example

Only observed PBR fields and complete shallow render-only modules may be facade-owned. Height/level, roof/silhouette, footprint, structural openings, collision, spray, navigation, foundation/terrain and generated/source contracts remain invariant.

```text
before: building:w34313523:wall is a 3 m-high, one-level, 20-run opaque spray
        receiver using shared plaster_grey_04.

after:  that exact wall, roof, height/level, footprint, runs, collision, spray
        owner, foundation, source ID and generated bytes remain unchanged; only
        evidence-backed fields/modules may be added to exact mapped endpoints.
```

## Acceptance checklist and blockers

- [ ] Each visual claim cites exact official panorama URL/ID/date/direction/coverage.
- [ ] Exact receiver/path/chunk, `3 m`, `20 / 163.385 m`, wall `40` and roof `8` triangles remain.
- [ ] Present abandonment and facade language are not inferred from frozen tags or Building 29A.
- [ ] Exact endpoints—not cardinal groups/U resets—drive any layout.
- [ ] Complete motifs and seam products remain intact.
- [ ] Visual child adds no physics/navigation/spray ownership.
- [ ] No massing/roof/footprint/foundation/terrain/collision/spray/generated change.

Current official-side occlusion/redevelopment conflict blocks material/motif grammar, physical scale and exact run ownership. Building 29A and site containers remain hard exclusions.

## Normalized handoff

```yaml
schema_version: codex.building-texture-research/1
job: {job_id: education_center_b29b_facade_reference_spec, checked_date: 2026-08-29, intended_use: occluded_redevelopment_receiver_handoff, target_asset_kind: unique_elevation}
target: {canonical_name: Education Center Building 29B / 768 Avenue H, local_object_ids: [w34313523, building:w34313523, building:w34313523:wall], identity_confidence: high, receiver_path: WorldRoot/PlayableWorld/Buildings/x_0__z_-1__building_w34313523_wall/building_w34313523_wall}
sources:
  - {id: L01, authority: project, url_or_local_path: discovery/FACADE_RECEIVER_INVENTORY.json, checked_date: 2026-08-29, page_or_section: facade-receiver:w34313523, supports: [identity, address, massing, receiver, topology], does_not_support: [appearance, present_abandonment], image_reuse_permission: not_needed, stored_in_repo: false}
  - {id: EC29B-SV01, authority: secondary, url_or_local_path: "https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8247245,-122.3684129&heading=224&pitch=0&fov=75", checked_date: 2026-08-29, page_or_section: pano_gnRrpIe5wBUEXwYoTcE6NQ_March_2025, supports: [site_reconciliation, facade_occlusion], does_not_support: [facade_appearance, current_existence], image_reuse_permission: observation_only, stored_in_repo: false}
  - {id: EC29B-SV02, authority: secondary, url_or_local_path: "https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8244589,-122.3694416&heading=95&pitch=0&fov=75", checked_date: 2026-08-29, page_or_section: pano_xPpjSLPIE2h--fbX_TB8OA_September_2025, supports: [site_reconciliation, facade_occlusion, redevelopment_context], does_not_support: [facade_appearance, current_existence], image_reuse_permission: observation_only, stored_in_repo: false}
reference_roles: {identity_context: [L01, EC29B-SV01, EC29B-SV02], massing: [L01], pattern_region: [], cadence_and_seams: [], material_surface: [], scale: [L01], rejection_example: [EC29B-SV01, EC29B-SV02]}
pattern_regions: [{region_id: ALL_WALLS, local_scope: exact_20_runs, periodicity: unknown, must_not_share_tile_with: []}]
motif_inventory: []
motif_sequences: []
repeat_blueprint: {region_id: ALL_WALLS, smallest_cell_status: unknown, period_tokens_horizontal: null, period_tokens_vertical: null, period_m: {x: null, y: null}, cell_contents_full_motifs: [], edge_fragments: {left: [], right: [], top: [], bottom: []}, edge_compositions_expected: {left_plus_right: [], top_plus_bottom: [], corners: []}, legal_seam_zones: [], forbidden_seam_zones: [generated_U_resets, discontiguous_normal_groups, unobserved_motifs], fallback_if_not_proven: unique_elevation}
material_brief: {surface_family: unknown, base_color: unknown, finish: unknown, relief_direction_and_frequency: unknown, roughness: unknown, variation_and_weathering: unknown, maps_requested: [], maps_forbidden: [height_displacement, baked_lighting, photographic_reflections], tile_scale_status: unknown, tile_scale_m: {x: null, y: null}}
excluded_architectural_features: [{feature: height_level_roof_silhouette_structural_openings, owner: geometry, reason: invariant}]
uncertainty: [{unknown: all_appearance_scale_and_endpoint_mapping, impact: no_output_ready, safe_fallback: shared_placeholder, stop_if_required: true}]
hard_mismatch_gates:
  - {scope: identity, reject_if: receiver_is_not_building_w34313523_wall, proof_required: exact_metadata}
  - {scope: geometry, reject_if: massing_collision_spray_foundation_or_generated_contract_changes, proof_required: exact_receiver_audit}
research_verdict: {ready_for_generation: false, recommended_output_kind: null, blockers: [complete_official_side_occlusion, current_existence_unknown, redevelopment_conflict, no_endpoint_mapping, no_material_or_scale_evidence, no_29A_inheritance]}
```

## Final status

- Identity/receiver: **ready**.
- Facade outputs: **blocked by complete official-side occlusion/redevelopment conflict**.

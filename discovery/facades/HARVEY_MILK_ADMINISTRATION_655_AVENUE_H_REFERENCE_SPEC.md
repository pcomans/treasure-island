# Harvey Milk Memorial Administration Building / 655 Avenue H facade reference specification

Checked: **2026-08-29**
Mode: **research and implementation handoff only**
Target: **`w34313513` / `building:w34313513:wall`**

## Handoff verdict

The frozen source confirms the exact name **Harvey Milk Memorial Administration Building, Job Corps Center** and address **655 Avenue H** on one direct 50-run receiver. The official coverage pass found no target elevation. All target-specific facade outputs are blocked; keep the shared placeholder rather than infer from the public/memorial/Job Corps names or the two-level tag.

## Evidence labels

`verified_fact` is exact project/frozen-source evidence; `reference_observation` is visible in an identified official panorama; `production_inference` is reversible authoring judgment; `unknown` is forbidden as appearance truth.

## Confirmed identity and exact receiver

| Item | Exact value | Status |
|---|---|---|
| Frozen identity/address | Harvey Milk Memorial Administration Building, Job Corps Center; 655 Avenue H | exact; no city/postcode added |
| Source | way `34313513`, version `9`, timestamp `2019-10-01T11:08:19Z` | exact snapshot; currentness not claimed |
| Frozen tags | `building=public`, `building:levels=2`, `height=9`; `source=Yahoo` | identity/massing only; not appearance |
| Logical/wall/roof | `building:w34313513`; `building:w34313513:wall`; `building:w34313513:roof` | direct standalone receiver |
| Chunk/runtime path | `x_0__z_0`; `WorldRoot/PlayableWorld/Buildings/x_0__z_0__building_w34313513_wall/building_w34313513_wall` | exact naming derivation |
| Current materials | wall `building_wall -> plaster_grey_04`; roof `building_roof -> bitumen`; no override | shared placeholders |

### Generated contract and topology

- Height rule `osm_height`, `9 m`; base/top `4.190 / 13.190 m`; lowest foundation vertex `3.748 m`.
- Area `3531.789 m²`; serialized perimeter `276.467 m`; visible wall `276.468 m`.
- Wall `50` exterior-foundation runs, `200` vertices / `100` triangles; roof `24` vertices / `22` triangles. No shared-above-lower-part runs.
- Facing totals: NE `55.743 m`, SE `79.369 m`, S `4.436 m`, SW `50.436 m`, W `3.165 m`, NW `83.318 m`.
- Exact orientation groups: `61.8°` ENE `13/55.743 m`; SSE `151.6° 2/2.718`, `151.8° 9/76.651`, `159.8° 1/2.453`; SSW `191.4° 1/1.983`, `212.3° 2/1.769`; WSW `236.6° 1/2.013`, `241.8° 7/46.655`; W `259.7° 1/1.731`, `276.7° 1/1.435`; WNW `298.9° 1/1.894`; NNW `328.6° 1/1.731`, `331.8° 9/77.162`, `331.9° 1/2.531`.
- Wall is opaque `world_solid`, `receiver_kind=building_wall`, and the sole spray receiver; roof is an opaque non-spray collider. U restarts per run; V is world elevation / 10.

## Provenance and coverage

| ID | Source | Supports | Excludes |
|---|---|---|---|
| `L01` | frozen OSM and `discovery/FACADE_RECEIVER_INVENTORY.json`, checked 2026-08-29 | exact name/address/tags/receiver/massing/topology | appearance and present condition |
| `SV` | `discovery/facades/BATCH_03_STREETVIEW_OBSERVATIONS.md`, checked 2026-08-29 | two official coverage failures and excluded ambiguous distant context | no facade appearance or capture date |

### Observed / unobserved

Observed sides: **none**. Unobserved: all ENE, SSE/returns, WSW and NNW families. Exact official requests:

- `HMA-NO01`: https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82178,-122.36915&heading=150&pitch=0&fov=80 — no Street View imagery at the footprint request.
- `HMA-NO02`: https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82165,-122.36830&heading=300&pitch=0&fov=85 — no Street View imagery at the nearest 4th Street/Avenue H frontage request.

Coverage mode showed no official road line on the target frontage. A distant official view could not be reconciled to the footprint and was excluded. No capture date or target panorama ID exists for these failures. All material regions, doors, windows, panels, signs, entrance, service conditions, roof transitions, cadence, dimensions and weathering are `unknown`. The `9 m / 2 levels` massing was neither confirmed nor contradicted.

Google imagery was viewed transiently in the existing browser. No image, crop, screenshot, copied pixel, download, redistribution or repository asset was retained; the URLs and coverage outcomes are observation provenance only.

## Material, motif, scale, output and seams

One Godot unit equals one metre, but `9 m / 2 levels` is not an observed story cadence. No PBR band, motif, physical module scale or smallest repeat is established.

| Output | Status | Gate |
|---|---|---|
| `homogeneous_material_tile` | blocked | coherent observed field with bounded PBR/scale |
| `architectural_pattern_tile` | blocked | proven complete period and edge/corner products |
| `module_atlas` | blocked | complete observed motifs and physical bounds |
| `unique_elevation` | blocked | observed extent reconciled to exact run endpoints |

Future legal seams require uninterrupted homogeneous field, verified complete unit boundary or complete-module surround. Forbidden seams include generated U resets, discontiguous same-normal jumps, corners/returns, motif interiors, receiver top/foundation and every unobserved feature.

## Godot bill of materials

| ID | Reserved path | Gate |
|---|---|---|
| `MAT` | `res://game/resources/materials/world/harvey_milk_admin/harvey_milk_admin_primary.tres` | blocked pending material evidence |
| `MAT-SECONDARY` | `res://game/resources/materials/world/harvey_milk_admin/harvey_milk_admin_secondary.tres` | blocked pending distinct region |
| `MOD` | `res://game/scenes/world/facades/harvey_milk_admin/harvey_milk_admin_modules.tscn` | blocked pending complete motifs |
| `LAYOUT` | `res://game/resources/facades/harvey_milk_admin_655_avenue_h_layout.json` | blocked pending exact run map |
| `ATTACH` | `res://game/scenes/world/facades/harvey_milk_admin/harvey_milk_admin_facade.tscn` | later noncolliding child only |

## Geometry boundary and representative invariant

Only evidence-backed surface PBR and complete shallow render-only modules may be facade-owned. Height/levels, roof/silhouette, footprint/returns, structural openings, collision, spray eligibility, foundations, terrain, navigation and generated/source contracts remain unchanged.

```text
before: building:w34313513:wall is one 9 m-high, 50-run opaque spray receiver
        using shared plaster_grey_04.

after:  that exact wall, roof, height, two-level tag, footprint, 50 runs,
        collision, spray owner, foundations, source ID and generated bytes remain
        unchanged; only evidence-backed render-only fields/modules may be added
        on endpoint-reconciled runs, while every unobserved run stays unchanged.
```

## Executable acceptance checklist

- [ ] Every visual claim cites an exact official panorama URL/ID, access/capture date, direction and coverage.
- [ ] Exact target/path/chunk, `9 m`, `50 / 276.468 m`, wall `100` and roof `22` triangles remain unchanged.
- [ ] Exact endpoint chains drive layout; cardinal groups and U resets never create facade phase.
- [ ] Every module and repeat edge product is complete; no motif is created/resized/duplicated/deleted at a seam.
- [ ] Render-only child has no collider/navigation/spray ownership; underlying wall remains spray hit owner.
- [ ] No public/memorial/Job Corps identity tag is used as appearance evidence.
- [ ] No massing, roof, silhouette, footprint, foundation, terrain, collision, spray or generated-data change occurs.
- [ ] Independent reviewer keeps material, module, receiver and whole-object verdicts separate.

## Explicit blockers

Absent official public-elevation evidence blocks every target-specific output, exact run mapping, material product, cadence and physical module scale. The old source tag and 2019 OSM timestamp do not establish present condition.

## Normalized handoff

```yaml
schema_version: codex.building-texture-research/1
job: {job_id: harvey_milk_admin_facade_reference_spec, checked_date: 2026-08-29, intended_use: blocked_exact_receiver_handoff, target_asset_kind: unique_elevation}
target: {canonical_name: Harvey Milk Memorial Administration Building Job Corps Center, local_object_ids: [w34313513, building:w34313513, building:w34313513:wall], identity_confidence: high, receiver_path: WorldRoot/PlayableWorld/Buildings/x_0__z_0__building_w34313513_wall/building_w34313513_wall}
sources:
  - {id: L01, authority: project, url_or_local_path: discovery/FACADE_RECEIVER_INVENTORY.json, checked_date: 2026-08-29, page_or_section: facade-receiver:w34313513, supports: [identity, address, massing, receiver, topology], does_not_support: [appearance], image_reuse_permission: not_needed, stored_in_repo: false}
  - {id: SV, authority: secondary, url_or_local_path: discovery/facades/BATCH_03_STREETVIEW_OBSERVATIONS.md, checked_date: 2026-08-29, page_or_section: Harvey_Milk, supports: [official_coverage_failure], does_not_support: [appearance, capture_date], image_reuse_permission: observation_only, stored_in_repo: false}
reference_roles: {identity_context: [L01], massing: [L01], pattern_region: [SV], cadence_and_seams: [SV], material_surface: [SV], scale: [L01, SV], rejection_example: []}
pattern_regions: [{region_id: ALL_WALLS, local_scope: exact_50_runs, periodicity: unknown, must_not_share_tile_with: []}]
motif_inventory: []
motif_sequences: []
repeat_blueprint: {region_id: ALL_WALLS, smallest_cell_status: unknown, period_tokens_horizontal: null, period_tokens_vertical: null, period_m: {x: null, y: null}, cell_contents_full_motifs: [], edge_fragments: {left: [], right: [], top: [], bottom: []}, edge_compositions_expected: {left_plus_right: [], top_plus_bottom: [], corners: []}, legal_seam_zones: [], forbidden_seam_zones: [generated_U_resets, discontiguous_normal_groups, all_unobserved_motifs], fallback_if_not_proven: unique_elevation}
material_brief: {surface_family: unknown, base_color: unknown, finish: unknown, relief_direction_and_frequency: unknown, roughness: unknown, variation_and_weathering: unknown, maps_requested: [], maps_forbidden: [height_displacement, baked_lighting, photographic_reflections], tile_scale_status: unknown, tile_scale_m: {x: null, y: null}}
excluded_architectural_features: [{feature: height_levels_roof_silhouette_footprint_structural_openings, owner: geometry, reason: invariant}]
uncertainty: [{unknown: all_facade_appearance_and_endpoint_mapping, impact: no_output_ready, safe_fallback: shared_placeholder, stop_if_required: true}]
hard_mismatch_gates:
  - {scope: identity, reject_if: receiver_is_not_building_w34313513_wall, proof_required: exact_metadata}
  - {scope: geometry, reject_if: massing_collision_spray_foundation_terrain_or_generated_contract_changes, proof_required: exact_receiver_audit}
research_verdict: {ready_for_generation: false, recommended_output_kind: null, blockers: [absent_official_public_elevation, no_endpoint_mapping, no_material_or_scale_evidence]}
```

## Final status

- Identity/receiver: **ready**.
- Facade outputs: **blocked by absent official public-elevation evidence**.

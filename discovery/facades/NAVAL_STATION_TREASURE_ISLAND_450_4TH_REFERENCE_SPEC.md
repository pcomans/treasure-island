# Naval Station Treasure Island / 450 4th Street facade reference specification

Checked: **2026-08-29**
Mode: **research and implementation handoff only**
Target: **`w34313544` / `building:w34313544:wall`**

## Handoff verdict

The frozen source confirms **Naval Station Treasure Island**, **450 4th Street**, as one direct 31-run receiver. The official coverage pass found no target-identifiable elevation. Its name, height and Wikidata tag establish identity context only; all target-specific facade outputs are blocked.

## Evidence labels and identity

Use `verified_fact`, `reference_observation`, `production_inference`, and `unknown` without collapsing them.

| Item | Exact value | Status |
|---|---|---|
| Identity/address | Naval Station Treasure Island; 450 4th Street | frozen exact tags |
| Source | way `34313544`, version `9`, `2023-09-15T13:41:50Z` | snapshot; currentness not claimed |
| Tags | `building=yes`, `height=7`, `wikidata=Q15261196`, `source=Yahoo` | no appearance evidence |
| Logical/wall/roof | `building:w34313544`; `building:w34313544:wall`; `building:w34313544:roof` | exact direct receiver |
| Chunk/runtime | `x_0__z_1`; `WorldRoot/PlayableWorld/Buildings/x_0__z_1__building_w34313544_wall/building_w34313544_wall` | exact naming derivation |
| Materials | wall `plaster_grey_04`; roof `bitumen`; no override | shared placeholders |

### Generated contract

- `osm_height`, `7 m`; base/top `3.475 / 10.475 m`; lowest foundation vertex `3.347 m`.
- Area `1809.176 m²`; serialized perimeter `188.863 m`; visible wall `188.865 m`.
- Wall `31` runs, `124` vertices / `62` triangles; roof `19` vertices / `17` triangles; no shared-part runs.
- Facing totals: N `2.702`, NE `30.633`, SE `64.091`, SW `28.137`, W `2.794`, NW `60.507 m`.
- Orientation groups: NNE `11.4° 2/1.354 m`, `30.5° 1/0.878`; ENE `61.8° 4/29.755`; SSE `151.8° 6/64.091`; WSW `241.8° 4/28.137`, `256.9° 2/1.439`; W `276.3° 1/1.355`; WNW `295.5° 1/1.345`; NW `314.2° 1/1.350`; NNW `331.8° 7/56.465`, `333.5° 1/1.347`; N `352.4° 1/1.349`.
- Wall is opaque `world_solid` and the spray receiver; roof is an opaque non-spray collider. U restarts per run; V is world elevation / 10.

## Provenance and observed coverage

| ID | Source | Supports | Excludes |
|---|---|---|---|
| `L01` | frozen OSM + receiver/generated records, checked 2026-08-29 | identity, address, height, receiver, topology | appearance/current condition |
| `SV` | `discovery/facades/BATCH_03_STREETVIEW_OBSERVATIONS.md`, checked 2026-08-29 | official frontage coverage failure | no facade appearance or capture date |

Observed sides: **none**. Unobserved: the complete irregular ENE, SSE, WSW/returns and NNW families. Exact request `NSTI-NO01`, https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82075,-122.37045&heading=60&pitch=0&fov=85, returned no Street View imagery at the 4th Street frontage. Coverage mode showed no official line there, and distant official-road context exposed no target-identifiable elevation. No target panorama ID or capture date exists.

All 31 runs, materials, openings, entrance, signs, service conditions, cadence, dimensions and weathering remain `unknown`; the generated `7 m` height was neither confirmed nor contradicted. Navy/legacy/Wikidata context does not authorize a style or module family. Google imagery was viewed transiently; no image, crop, screenshot, copied pixel, download, redistribution or repository asset was retained.

## Material, motif, scale, classification and seams

One unit equals one metre; the `7 m` height is receiver calibration, not a measured story or module schedule.

| Output | Status | Gate |
|---|---|---|
| `homogeneous_material_tile` | blocked | observed coherent surface/PBR/scale |
| `architectural_pattern_tile` | blocked | complete period and boundary products |
| `module_atlas` | blocked | complete motifs and bounded dimensions |
| `unique_elevation` | blocked | observed schedule on exact run endpoints |

Future legal seams: uninterrupted homogeneous field, verified unit boundary, complete-module surround. Forbidden: generated U resets, chamfer/return jumps, motif interiors, corners, top/foundation and unobserved content.

## Godot BOM

| ID | Reserved path | Status |
|---|---|---|
| `MAT` | `res://game/resources/materials/world/naval_station_ti/naval_station_primary.tres` | blocked |
| `MAT-SECONDARY` | `res://game/resources/materials/world/naval_station_ti/naval_station_secondary.tres` | blocked |
| `MOD` | `res://game/scenes/world/facades/naval_station_ti/naval_station_modules.tscn` | blocked |
| `LAYOUT` | `res://game/resources/facades/naval_station_ti_450_4th_layout.json` | exact-run schedule; blocked |
| `ATTACH` | `res://game/scenes/world/facades/naval_station_ti/naval_station_facade.tscn` | later noncolliding child only |

## Geometry boundary and before -> after

Facade work may own only evidence-backed PBR and complete shallow render-only modules. Height, roof/silhouette, footprint/returns, structural openings, collision, spray, terrain/foundations, navigation and source/generated contracts remain invariant.

```text
before: building:w34313544:wall is a 7 m-high, 31-run opaque spray receiver
        using shared plaster_grey_04.

after:  that exact wall, roof, height, footprint, runs, collision, spray owner,
        foundations, source ID and generated bytes remain unchanged; only
        observed endpoint-mapped fields/modules may be added as visual children.
```

## Acceptance checklist and blockers

- [ ] Exact panorama URL/ID/date/direction/coverage supports each visual claim.
- [ ] Exact target/path/chunk, `7 m`, `31 / 188.865 m`, wall `62` and roof `17` triangles remain.
- [ ] Exact endpoint chains—not normal buckets or U resets—drive layout.
- [ ] Complete motifs and boundary products survive every seam.
- [ ] No visual child adds collider/navigation/spray ownership; wall remains hit owner.
- [ ] No appearance is inferred from naval/name/Wikidata tags.
- [ ] No massing/roof/footprint/foundation/terrain/collision/spray/generated-data change.

Absent official public-elevation evidence blocks appearance, physical scale and run mapping. The highly faceted north/return groups prohibit a cardinal-only layout.

## Normalized handoff

```yaml
schema_version: codex.building-texture-research/1
job: {job_id: naval_station_ti_facade_reference_spec, checked_date: 2026-08-29, intended_use: blocked_exact_receiver_handoff, target_asset_kind: unique_elevation}
target: {canonical_name: Naval Station Treasure Island / 450 4th Street, local_object_ids: [w34313544, building:w34313544, building:w34313544:wall], identity_confidence: high, receiver_path: WorldRoot/PlayableWorld/Buildings/x_0__z_1__building_w34313544_wall/building_w34313544_wall}
sources:
  - {id: L01, authority: project, url_or_local_path: discovery/FACADE_RECEIVER_INVENTORY.json, checked_date: 2026-08-29, page_or_section: facade-receiver:w34313544, supports: [identity, address, massing, receiver, topology], does_not_support: [appearance], image_reuse_permission: not_needed, stored_in_repo: false}
  - {id: SV, authority: secondary, url_or_local_path: discovery/facades/BATCH_03_STREETVIEW_OBSERVATIONS.md, checked_date: 2026-08-29, page_or_section: Naval_Station, supports: [official_coverage_failure], does_not_support: [appearance, capture_date], image_reuse_permission: observation_only, stored_in_repo: false}
reference_roles: {identity_context: [L01], massing: [L01], pattern_region: [SV], cadence_and_seams: [SV], material_surface: [SV], scale: [L01, SV], rejection_example: []}
pattern_regions: [{region_id: ALL_WALLS, local_scope: exact_31_runs, periodicity: unknown, must_not_share_tile_with: []}]
motif_inventory: []
motif_sequences: []
repeat_blueprint: {region_id: ALL_WALLS, smallest_cell_status: unknown, period_tokens_horizontal: null, period_tokens_vertical: null, period_m: {x: null, y: null}, cell_contents_full_motifs: [], edge_fragments: {left: [], right: [], top: [], bottom: []}, edge_compositions_expected: {left_plus_right: [], top_plus_bottom: [], corners: []}, legal_seam_zones: [], forbidden_seam_zones: [generated_U_resets, returns, unobserved_motifs], fallback_if_not_proven: unique_elevation}
material_brief: {surface_family: unknown, base_color: unknown, finish: unknown, relief_direction_and_frequency: unknown, roughness: unknown, variation_and_weathering: unknown, maps_requested: [], maps_forbidden: [height_displacement, baked_lighting, photographic_reflections], tile_scale_status: unknown, tile_scale_m: {x: null, y: null}}
excluded_architectural_features: [{feature: height_roof_silhouette_structural_openings, owner: geometry, reason: invariant}]
uncertainty: [{unknown: all_appearance_and_endpoint_mapping, impact: no_output_ready, safe_fallback: shared_placeholder, stop_if_required: true}]
hard_mismatch_gates:
  - {scope: identity, reject_if: receiver_is_not_building_w34313544_wall, proof_required: exact_metadata}
  - {scope: geometry, reject_if: massing_collision_spray_foundation_or_generated_contract_changes, proof_required: exact_receiver_audit}
research_verdict: {ready_for_generation: false, recommended_output_kind: null, blockers: [absent_official_public_elevation, no_endpoint_mapping, no_material_or_scale_evidence]}
```

## Final status

- Identity/receiver: **ready**.
- Facade outputs: **blocked by absent official public-elevation evidence**.

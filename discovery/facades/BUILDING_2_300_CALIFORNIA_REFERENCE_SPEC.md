# Building 2 / 300 California Avenue facade reference specification

Checked: **2026-08-29**
Mode: **research and implementation handoff only**
Target source: **`w24274434`**
Current wall receiver: **`building:w24274434:wall`**

## Handoff verdict

The target is the frozen-source **Building 2** hangar at **300 California Avenue, CA**, historically named the **Hall of Transportation**. Its exact standalone receiver and irregular 46-run boundary are confirmed. Official May 2019 Street View supports a warm-cream material prototype and a non-repeating WSW monumental-end vocabulary. Exact placement is **blocked** because the WSW observation has not been reconciled to generated run endpoints; the relief artwork, other three sides, and module dimensions remain unknown. Neither heritage tags nor Building 3 establish appearance.

## Evidence labels

- `verified_fact`: frozen OSM, generated-world, or locally recorded authoritative project evidence.
- `reference_observation`: visible in a dated, identified panorama in the Batch 02 ledger.
- `production_inference`: reversible mapping or implementation choice.
- `unknown`: not established and forbidden as appearance truth.

## Confirmed identity and exact receiver

| Item | Exact value | Status |
|---|---|---|
| Canonical identity | Building 2 | frozen OSM `name`; high exact-source confidence |
| Address | 300 California Avenue, CA | frozen tags contain number/street/state; no city/postcode is added |
| Historic identity | `old_name:1938-1940=Hall of Transportation`; `start_date=1938`; hangar | frozen tags; not appearance evidence |
| Architect / heritage | William P. Day and George Kelham; NRHP `08000081`, criteria `A;C`, inscription `2008-02-26` | frozen tags; not facade evidence |
| Source | way `24274434`, key `w24274434`, version `12`, timestamp `2026-08-21T23:22:40Z` | exact snapshot |
| Frozen massing tags | `height=20`, `building:levels=2` | both retained; height drives generation |
| Logical / wall / roof | `building:w24274434`; `building:w24274434:wall`; `building:w24274434:roof` | exact generated keys |
| Chunk | `x_1__z_2` | exact |
| Runtime wall path | `WorldRoot/PlayableWorld/Buildings/x_1__z_2__building_w24274434_wall/building_w24274434_wall` | exact current naming derivation |
| Current materials | wall `building_wall -> plaster_grey_04`; roof `building_roof -> bitumen` | shared placeholders, never reference evidence |
| Target override | none | verified by local search |

### Generated mass, mesh, and receiver contract

- Height rule `osm_height`, height `20 m`; flat base `3.560 m`; top `23.560 m`; lowest foundation vertex `3.198 m`.
- Source area `8417.475 m²`; serialized perimeter `387.262 m`; generated visible wall length `387.263 m`.
- Wall: `46` exterior-foundation runs, `184` vertices, `92` triangles, one material surface. No shared-above-lower-part runs.
- Roof: `20` vertices, `18` triangles; opaque `world_solid`, not a spray receiver.
- Wall: opaque `world_solid`, `receiver_kind=building_wall`, current collision body in `spray_receiver_wall`.
- U restarts on every wall run; V is world elevation / 10. Generated U is never facade cadence.

### Exact orientation/run scope

| Facing bucket | Exact total | Contiguous run groups |
|---|---:|---|
| ENE | `89.206 m` | `22`, `24..25`, `27..32`, `34..35`, `44` |
| SSE | `104.341 m` | `2`, `11`, `16..21`, `33` |
| WSW | `89.356 m` | `0..1`, `3..8`, `10`, `12..15`, `37` |
| NNW | `104.361 m` | `9`, `23`, `26`, `36`, `38..43`, `45` |

The footprint contains many recesses/chamfers. Same-facing groups are discontiguous and cannot be merged into a semantic side. Any later unique layout must list exact run indices and continuous endpoint chains from the generated record.

## Source and provenance ledger

| ID | Source | Checked | Supports | Does not support / reuse |
|---|---|---|---|---|
| `L01` | `data/osm/treasure-island-2026-08-27.osm`, way `w24274434` | 2026-08-29 | name, partial address, history, levels/height, architect/heritage | no facade appearance; project-held ODbL data |
| `L02` | `discovery/FACADE_RECEIVER_INVENTORY.json` and `.md`; generated logical/chunk records | 2026-08-29 | exact receiver, runs, scale, materials, UV/collision constraints | no real materials/cadence |
| `L03` | `discovery/ISLAND_EVIDENCE.md` | 2026-08-29 | Building 2/3 historic-hangar recognition context | no permission to copy Building 3 appearance |
| `SV` | `discovery/facades/BATCH_02_STREETVIEW_OBSERVATIONS.md`, Building 2 section | 2026-08-29; Google capture May 2019 | WSW material hierarchy, monumental glazing, central bay, pylons, vents, ledge, coverage limits | observation only; no imagery stored/reused; no run endpoints or exact dimensions |

### Official observation requests

| ID | Exact URL | Resolved panorama / coverage |
|---|---|---|
| `B2-SV01` | <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.81782,-122.36865&heading=58&pitch=6&fov=75> | `MGLja7KGZ2kmIQSXa35Pgg`, May 2019; southwest approach looking northeast, partly occluded WSW end |
| `B2-SV02` | <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8179703,-122.3685661&heading=52&pitch=5&fov=70> | `lnRMuxXwh_bOj4Vg7NCoxw`, May 2019; complete WSW end; same panorama also inspected at heading `95`, pitch `7`, FOV `75` |

## Observed and unobserved facade coverage

### Observed

- `reference_observation`: the complete monumental public end, mapped with high confidence to the WSW orientation family (`241.9°-242.0°`). Only minor adjoining-long-side portions are visible.
- Dominant warm pale cream/yellow painted mineral- or masonry-like field; matte to low-satin, mildly diffuse-streaked. Exact substrate/product is unknown.
- Two very large rectangular gridded translucent-glazing or glass-block fields: cool dark-grey mullion grids, many pale blue-grey panes, a narrow dark horizontal pane band, and darker low openings/panes.
- Unique central bay: tall muted blue-grey panel/recess, pale sculptural relief above, and dark ground entry/personnel doors below. Relief details are not legible enough to reproduce.
- Cream shoulder pylons each contain a narrow pale blue-grey vertical inset/louver-like field. Small square vents puncture the upper cream field. A shallow ledge caps the glazing.
- The facade reads as one monumental hall end, not a conventional two-row window stack. The broad shallow crown/profile is geometry-owned and does not settle `building:levels=2`.

### Unobserved

ENE opposite end, both long-side schedules, service/loading conditions, and every exact generated-run endpoint remain unobserved. Exact products, pane construction, relief artwork, dimensions and adjoining-side cadence are unknown.

## Material regions, motif grammar, and physical scale

| Region | Exact scope | Status |
|---|---|---|
| `WSW-MONUMENTAL` | WSW family only; exact subset of its discontiguous groups unresolved | observed composition; endpoint mapping blocked |
| `CREAM-FIELD` | uninterrupted WSW cream regions only | homogeneous tile candidate; do not assume other sides |
| `WSW-GRID-L/R` | each full glazing field including complete jamb/head/base | non-repeating unique regions |
| `WSW-CENTRAL/PYLONS` | complete central bay and each complete pylon inset | unique modules; relief blocked |
| `UNOBSERVED` | every other wall run | shared placeholder; no unique modules |
| `FOUNDATION-EXT` | terrain extension below `y=3.560` | geometry-owned; no doors/windows |
| `ROOF/SILHOUETTE` | top at `y=23.560` and roof profile | geometry-owned, excluded |

`production_inference` PBR starting points: cream base-color value about `0.68-0.82` linear, roughness `0.68-0.88`; blue-grey inset/panel value `0.30-0.48`, roughness `0.52-0.72`; mullions value `0.08-0.18`, roughness `0.35-0.58`; translucent panes value `0.38-0.58`, roughness `0.22-0.45`, with no baked reflection. These are plausible authoring bands, not measured colors.

Smallest-repeat finding: no facade-scale translation period is proved. Treat each glass grid, the central composition, pylon inset and vent as a **complete module**, and the observed WSW sequence as a `unique_elevation`. Physical-scale confidence is low until endpoint reconciliation: authoritative height is `20 m`; module widths, pane pitch and door sizes are not defensibly measurable from the panorama. Use metre-space receiver coordinates and reject any asset whose dimensions are chosen only to fill a run.

## Output classification and seam blueprint

| Output kind | Status | Rationale / next gate |
|---|---|---|
| `homogeneous_material_tile` | **spec-ready for WSW prototype** | warm-cream field has coherent appearance/PBR bounds; review against both panoramas before reuse |
| `architectural_pattern_tile` | **rejected** | no complete facade period; panes/mullions belong inside full glazing modules |
| `module_atlas` | **grammar-ready, dimension-blocked** | `B2-GRID-L/R`, `B2-CENTRAL`, `B2-PYLON-INSET`, `B2-VENT`; central relief cannot contain invented artwork |
| `unique_elevation` | **appearance-specified, placement-blocked** | WSW composition known, exact discontiguous run endpoints and dimensions unknown |

Legal seams: uninterrupted warm-cream field; verified full outer edge of a complete glazing field or pylon inset; ordinary field between complete modules; explicit endpoint after reconciliation. Forbidden seams: generated U resets; every mullion, pane, glazing surround, dark pane band, door, relief, vent, pylon inset, ledge, corner/chamfer and curved crown termination; every discontiguous same-normal jump. Never mirror the WSW elevation to ENE.

## Godot bill of materials

| ID | Reserved path | Role | Gate |
|---|---|---|---|
| `MAT-PRIMARY` | `res://game/resources/materials/world/building_2/building_2_primary.tres` | WSW warm-cream matte/low-satin field | prototype-ready; WSW-only until continuity proof |
| `MAT-SECONDARY` | `res://game/resources/materials/world/building_2/building_2_blue_grey.tres` | blue-grey panels/pylon insets | prototype-ready with separate value/roughness |
| `MAT-GLAZING` | `res://game/resources/materials/world/building_2/building_2_translucent_glazing.tres` | pale blue-grey panes; no baked reflection | module-use only; transmission behavior reviewer-gated |
| `MOD` | `res://game/scenes/world/facades/building_2/building_2_modules.tscn` | full grids, central bay, pylon inset, vent | grammar-ready; dimensions/endpoints and relief blocked |
| `LAYOUT` | `res://game/resources/facades/building_2_300_california_layout.json` | exact-run unique schedule | blocked pending endpoint map |
| `ATTACH` | `res://game/scenes/world/facades/building_2/building_2_300_california_facade.tscn` | noncolliding child of exact wall | blocked until evidence/reviewer gates pass |

## Geometry-versus-texture boundary

A later facade pass may own evidence-backed scalar/PBR fields and complete shallow render-only modules. It may not change the `20 m` height, two-level tag interpretation, footprint, roofline/silhouette, recess depth, structural openings, collision, spray eligibility, foundations, terrain, navigation, source IDs, generated bytes, or OSM contracts.

```text
before: building:w24274434:wall is one 20 m-high opaque spray receiver with
        46 terrain-founded runs and shared plaster_grey_04.

after:  the exact wall, roof, height, footprint, 46 runs, collision, spray
        target, source ID and generated bytes remain unchanged; a later
        noncolliding child may add only observed materials and complete modules
        on endpoint-mapped run chains, leaving every unobserved run unchanged.
```

## Executable acceptance checklist

- [x] Every visual claim cites an exact Batch 02 panorama URL/ID, access/capture date, direction and coverage.
- [ ] Target remains exact `w24274434` / `building:w24274434:wall` in `x_1__z_2`.
- [ ] Height/base/top, `46` runs / `387.263 m`, `92` wall triangles and `18` roof triangles remain exact.
- [ ] Layout uses exact run indices/endpoints; no phase reset occurs at generated subdivisions or same-normal gaps.
- [ ] Material and pattern proofs preserve left/right, top/bottom and corner products without creating/resizing/duplicating/deleting motifs.
- [ ] Every module is complete, render-only, shallow, noncolliding, and inside the wall silhouette.
- [ ] Underlying wall remains sole collider/spray owner and decals remain visible.
- [ ] No Building 3 appearance is transferred without direct Building 2 observation.
- [ ] No massing, roof, footprint, foundation, terrain, collision, spray, navigation or generated-data change occurs.
- [ ] Independent review keeps material, module, receiver and whole-object verdicts separate.

## Explicit unknowns and blockers

- WSW is observed but exact member runs/endpoints are unreconciled; other three facade families remain unknown.
- Exact substrate, pane construction, module dimensions, relief artwork and service/loading conditions are unknown.
- `height=20` and `building:levels=2` coexist; this brief preserves both and does not turn their quotient into facade cadence.
- Building 3 similarity is a research question, not evidence or reuse permission.

## Normalized research handoff

```yaml
schema_version: codex.building-texture-research/1
job: {job_id: building_2_300_california_facade_reference_spec, checked_date: 2026-08-29, intended_use: WSW_material_and_unique_elevation_handoff, target_asset_kind: unique_elevation}
target:
  canonical_name: Building 2 / 300 California Avenue
  local_object_ids: [w24274434, building:w24274434, building:w24274434:wall]
  identity_confidence: high
  receiver_path: WorldRoot/PlayableWorld/Buildings/x_1__z_2__building_w24274434_wall/building_w24274434_wall
sources:
  - {id: L01, authority: project, url_or_local_path: data/osm/treasure-island-2026-08-27.osm, checked_date: 2026-08-29, page_or_section: way_w24274434, supports: [identity, address, massing_tags], does_not_support: [facade_appearance], image_reuse_permission: not_needed, stored_in_repo: false}
  - {id: SV, authority: secondary, url_or_local_path: discovery/facades/BATCH_02_STREETVIEW_OBSERVATIONS.md, checked_date: 2026-08-29, page_or_section: Building_2, supports: [WSW_materials, WSW_modules, seams, coverage], does_not_support: [other_sides, run_endpoints, exact_dimensions, relief_artwork], image_reuse_permission: observation_only, stored_in_repo: false}
reference_roles: {identity_context: [L01], massing: [L01, L02], pattern_region: [SV], cadence_and_seams: [SV], material_surface: [SV], scale: [L02, SV], rejection_example: []}
pattern_regions:
  - {region_id: WSW_MONUMENTAL, local_scope: WSW_orientation_family_exact_runs_unreconciled, periodicity: nonperiodic, must_not_share_tile_with: [ENE, SSE, NNW]}
  - {region_id: UNOBSERVED, local_scope: all_other_runs, periodicity: unknown, must_not_share_tile_with: [WSW_MONUMENTAL]}
motif_inventory: [B2_GRID_L, B2_GRID_R, B2_CENTRAL, B2_PYLON_INSET, B2_VENT]
motif_sequences: []
repeat_blueprint: {region_id: WSW_MONUMENTAL, smallest_cell_status: rejected_nonperiodic, period_tokens_horizontal: null, period_tokens_vertical: null, period_m: {x: null, y: null}, cell_contents_full_motifs: [B2_GRID_L, B2_GRID_R, B2_CENTRAL, B2_PYLON_INSET, B2_VENT], edge_fragments: {left: [], right: [], top: [], bottom: []}, edge_compositions_expected: {left_plus_right: [], top_plus_bottom: [], corners: []}, legal_seam_zones: [uninterrupted_cream, verified_complete_module_outer_edge], forbidden_seam_zones: [generated_U_resets, mullions, panes, doors, relief, vents, ledges, corners, discontiguous_same_normal_groups], fallback_if_not_proven: unique_elevation}
material_brief: {surface_family: painted_mineral_or_masonry_like, base_color: warm_pale_cream_yellow_value_0.68_to_0.82_linear, finish: matte_to_low_satin, relief_direction_and_frequency: mild_diffuse_streaking_no_measured_period, roughness: 0.68_to_0.88, variation_and_weathering: mild_only, maps_requested: [albedo, roughness, subtle_normal], maps_forbidden: [height_displacement, baked_lighting, photographic_reflections], tile_scale_status: plausible_not_measured, tile_scale_m: {x: null, y: null}}
excluded_architectural_features:
  - {feature: massing_roofline_silhouette_structural_openings, owner: geometry, reason: invariant}
uncertainty:
  - {unknown: WSW_exact_run_endpoints_and_module_dimensions, impact: unique_placement_blocked, safe_fallback: material_prototype_only, stop_if_required: true}
  - {unknown: ENE_SSE_NNW_appearance, impact: no_unique_modules_on_those_sides, safe_fallback: shared_placeholder, stop_if_required: true}
hard_mismatch_gates:
  - {scope: identity, reject_if: receiver_is_not_building_w24274434_wall, proof_required: runtime_metadata}
  - {scope: geometry, reject_if: massing_roof_collision_spray_foundation_terrain_or_generated_contract_changes, proof_required: exact_receiver_audit}
research_verdict: {ready_for_generation: true_for_WSW_material_prototype_only, recommended_output_kind: homogeneous_material_tile, blockers: [unique_elevation_run_endpoints, module_dimensions, relief_artwork, other_three_sides]}
```

## Final research status

- Identity and exact receiver: **ready**.
- WSW warm-cream material prototype: **specification-ready**.
- WSW module vocabulary: **grammar-ready; dimensions blocked**.
- Exact unique-elevation integration and other sides: **blocked**.

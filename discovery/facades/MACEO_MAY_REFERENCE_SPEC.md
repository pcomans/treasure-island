# Maceo May facade reference specification

Checked: **2026-08-29**
Mode: **research and implementation handoff only**
Target: **relation `r19685981` / wall `building:r19685981:wall`**

## Handoff verdict

Maceo May resolves by exact frozen name to one direct multipolygon apartment receiver. It has no frozen address and contains a large inner courtyard ring inside the same wall object. Official Sep 2025 imagery supports distinct ENE white-grid/graphite and SSE ribbed/rust/curtain-wall vocabularies. Exact placement is blocked by unreconciled outer endpoints; the WSW/NNW and entire inner courtyard remain unknown and must not inherit outer evidence.

## Evidence labels

`verified_fact`, `reference_observation`, `production_inference`, and `unknown` remain separate. Public-facing outer elevation evidence never automatically applies to the inner courtyard ring.

## Confirmed identity and exact receiver

| Item | Exact value | Status |
|---|---|---|
| Name | Maceo May | exact frozen relation name |
| Address | none in frozen source | preserve absence |
| Source | relation `19685981`, version `1`, timestamp `2025-10-07T00:49:31Z`; `building=apartments`, `building:levels=6` | exact |
| Relation rings | outer way `w1001544694`; inner way `w1436064964` | exact multipolygon topology |
| Local public evidence | six-story structure completed January 2023 | `ISLAND_EVIDENCE S22`; coarse massing only |
| Logical/wall/roof | `building:r19685981`; `building:r19685981:wall`; `building:r19685981:roof` | exact |
| Chunk/runtime | `x_-1__z_1`; `WorldRoot/PlayableWorld/Buildings/x_-1__z_1__building_r19685981_wall/building_r19685981_wall` | exact current naming derivation |
| Current materials | shared wall `plaster_grey_04`; roof `bitumen`; no target override | placeholder only |

### Generated mass, mesh, and ring contract

- `osm_levels`, `18 m`; base/top `4.430 / 22.430 m`; lowest foundation vertex `2.093 m`.
- Source area `2378.411 m²`; perimeter/visible wall `328.836 m`.
- Wall `40` exterior-foundation runs, `160` vertices / `80` triangles. Roof `16` vertices / `16` triangles.
- Serialized wall order: **outer ring runs `0..20`, `218.589 m`**; **inner courtyard runs `21..39`, `110.247 m`**. No shared building-part wall.
- Outer chains: WSW `0..6` `71.842 m`; SSE `7` `4.683 m`; SE `8..10` `42.199 m`; ENE `11..16` `56.020 m`; NNW `17..20` `43.846 m`.
- Inner ring is a single continuous closed chain `21..39`, but contains eleven distinct normal groups. It must be labeled `inner` in every layout entry; an outer motif may not wrap into it by orientation.
- Wall is opaque `world_solid`/spray receiver; roof is opaque collider and not spray receiver. U restarts per run.

## Provenance and observed coverage

| ID | Source | Supports | Excludes |
|---|---|---|---|
| `L01` | frozen OSM relation/members and receiver inventory/generated records; checked 2026-08-29 | name, missing address, rings, levels, receiver, exact scale | facade appearance |
| `L02` | `discovery/ISLAND_EVIDENCE.md`, `S22` | completion and six-story coarse massing | facade materials/modules |
| `SV` | `discovery/facades/BATCH_02_STREETVIEW_OBSERVATIONS.md`, Maceo May section; checked 2026-08-29, capture Sep 2025 | ENE and SSE appearance, six-row cadence, modules and seams | no image retention/reuse; no exact endpoints, WSW/NNW or courtyard truth |

Exact official requests: `MM-SV01` <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82095,-122.37220&heading=275&pitch=7&fov=78> (`kEX8mV7OsuHLoA4oK69_KA`, broad ENE); `MM-SV02` <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82060,-122.37225&heading=320&pitch=7&fov=78> (`OKiASMGBFciyCsC9neeygg`, SSE entrance). Both display **Sep 2025**; no imagery retained.

### Observed

- Broad Seven Seas view maps to ENE families (`59.5°-63.1°`); Cravath entrance maps to SSE/SE (`130.9°-155.1°`). Exact relation-run endpoints are unresolved.
- ENE: warm-white smooth rectilinear grid framing repeated bays; recessed near-charcoal panels and dark head/louver fields around grey-green glazing; graphite ground band with narrow windows and solid/service doors.
- SSE: very-light grey/white fine vertical-rib field, muted rust-red frames and horizontal accent siding, warm pale-grey projected bay, charcoal ground/entry regions.
- Rust-framed windows have broad fixed plus narrow operable panes; small square vents occur above some windows. Ground curtain glazing spans bays between full-height pale columns.
- Unique entrance has a recessed glazed door, address beginning `55`, and one vertical `MACEO MAY` sign. Glyphs beyond visible `55` are not verified.
- Broad ENE reads ground plus five upper rows, consistent with six frozen levels. Projected bays/returns/recess depth remain geometry-owned.

### Unobserved

WSW/rear, NNW/north end, the entire inner courtyard ring `21..39`, and all exact outer endpoints/dimensions remain unobserved. Any private/courtyard door, balcony, walkway, screen or service condition is prohibited without evidence.

## Material regions, motifs, scale, and output classes

| Region | Exact scope | Status |
|---|---|---|
| `OUTER-ENE` | ENE outer runs `11..16`; exact subregions unresolved | white-grid/graphite grammar observed |
| `OUTER-SSE/SE` | outer runs `7..10`; exact subregions unresolved | ribbed/rust/curtain-wall entrance grammar observed |
| `OUTER-OTHER` | remaining runs `0..20` | placeholder/no unique module |
| `INNER` | runs `21..39` | unobserved unless explicitly proved; never inherit outer schedule |
| `FOUNDATION/ROOF` | below `4.430`, top `22.430` | geometry-owned |

`production_inference` starting bands: warm-white value `0.74-0.88` / roughness `0.55-0.78`; graphite value `0.06-0.16` / roughness `0.48-0.70`; ribbed light field value `0.70-0.86` / roughness `0.60-0.82`; rust accent value `0.25-0.40` / roughness `0.55-0.76`; pale concrete value `0.48-0.64` / roughness `0.72-0.90`; glazing `0.18-0.36`, no baked reflection. Plausible, not measured.

Smallest-repeat finding: ENE and SSE are separate non-interchangeable regions. Use complete `MM-ENE-W`, `MM-SSE-W`, `MM-GROUND-N`, `MM-CW`, and unique `MM-ENTRY55`; `MM-RIB` is a homogeneous directional material, not a facade tile. Rib pitch and module dimensions are unknown; `18 m` receiver height is calibration only.

| Kind | Status | Gate |
|---|---|---|
| `homogeneous_material_tile` | **spec-ready prototypes** | distinct white, graphite, ribbed, rust and pale-concrete materials; rib pitch review required |
| `architectural_pattern_tile` | **rejected facade-wide** | ENE and SSE grammars differ; no full period proved |
| `module_atlas` | **grammar-ready, scale-blocked** | complete window/ground/curtain-wall/entry families |
| `unique_elevation` | **blocked** | 40-run reconciliation, unobserved sides/courtyard and projected geometry |

Legal seams: uninterrupted white/graphite/rib field, verified rib valley, or full module surround. Forbidden: cuts through windows/operable panes, dark heads, white grid frames, rust trim/siding, rib termination, vent, column, curtain-wall mullion, entrance/address/name sign, projected bay or corner; all U resets and any outer/inner jump. ENE and SSE never share one pattern.

## Godot BOM

| ID | Reserved path | Status |
|---|---|---|
| `MAT-ENE` | `res://game/resources/materials/world/maceo_may/maceo_may_ene_white.tres` | ENE white grid field; prototype-ready |
| `MAT-GRAPHITE` | `res://game/resources/materials/world/maceo_may/maceo_may_graphite.tres` | ENE/ground dark field; prototype-ready |
| `MAT-RIB` | `res://game/resources/materials/world/maceo_may/maceo_may_sse_rib.tres` | SSE vertical rib; prototype-ready, pitch blocked |
| `MAT-RUST` | `res://game/resources/materials/world/maceo_may/maceo_may_rust.tres` | SSE frames/accent; prototype-ready |
| `MAT-INNER` | `res://game/resources/materials/world/maceo_may/maceo_may_inner.tres` | blocked; cannot assume sameness |
| `MOD` | `res://game/scenes/world/facades/maceo_may/maceo_may_modules.tscn` | ENE-W, SSE-W, GROUND-N, CW, ENTRY55 | grammar-ready; dimensions/endpoints blocked |
| `LAYOUT` | `res://game/resources/facades/maceo_may_layout.json` | must include ring role + exact runs; blocked |
| `ATTACH` | `res://game/scenes/world/facades/maceo_may/maceo_may_facade.tscn` | noncolliding child; blocked |

## Geometry boundary and before -> after

Only evidence-backed PBR fields and shallow complete visual modules are facade-owned. Height/story/roof/silhouette, ring topology and hole, deep balcony/walkway/recess geometry, collision, spray, terrain/foundation, navigation and generated/source contracts are excluded.

```text
before: building:r19685981:wall is one 18 m-high opaque spray receiver with
        outer runs 0..20, inner courtyard runs 21..39, and shared plaster.

after:  that exact wall, roof, six-level mass, two rings, 40 runs, collision,
        spray owner, foundations, source ID and generated bytes remain unchanged;
        a noncolliding child may add observed material/modules only to explicit
        ring-aware endpoint chains. No outer schedule is projected into courtyard.
```

## Acceptance checklist

- [x] Exact panorama ledger supports each visual claim and identifies outer versus inner coverage.
- [ ] Missing frozen address remains explicit.
- [ ] Exact relation/member IDs, receiver/chunk/path, `18 m`, `40 / 328.836 m`, wall `80` and roof `16` triangles remain exact.
- [ ] Layout asserts outer `0..20` versus inner `21..39`; cardinal normal alone cannot select a run.
- [ ] Generated U resets and relation-ring boundary never reset or continue a motif implicitly.
- [ ] Complete modules/edge products survive all seams; no motif changes at a boundary.
- [ ] Visual child has no collider/navigation/spray ownership; underlying wall remains spray hit owner.
- [ ] No story, massing, roof, ring, footprint, terrain, foundation, collision, spray or generated-data change.
- [ ] Reviewer separately judges outer facade, inner unknowns, exact receiver and whole object.

## Explicit blockers

- No frozen address.
- ENE/SSE outer appearance is observed; exact outer run endpoints and dimensions remain blocked.
- Inner courtyard visibility/material/module grammar is unknown and cannot inherit public-facing evidence.
- Exact balconies, screens, entrances, glazing, roof profile, dimensions and private/rear conditions are unknown.

## Normalized handoff

```yaml
schema_version: codex.building-texture-research/1
job: {job_id: maceo_may_facade_reference_spec, checked_date: 2026-08-29, intended_use: ring_aware_ENE_SSE_material_and_module_handoff, target_asset_kind: module_atlas}
target: {canonical_name: Maceo May, local_object_ids: [r19685981, building:r19685981, building:r19685981:wall], identity_confidence: high, receiver_path: WorldRoot/PlayableWorld/Buildings/x_-1__z_1__building_r19685981_wall/building_r19685981_wall}
sources:
  - {id: L01, authority: project, url_or_local_path: discovery/FACADE_RECEIVER_INVENTORY.json, checked_date: 2026-08-29, page_or_section: facade-receiver:r19685981, supports: [identity, missing_address, rings, receiver, scale], does_not_support: [appearance], image_reuse_permission: not_needed, stored_in_repo: false}
  - {id: L02, authority: project, url_or_local_path: discovery/ISLAND_EVIDENCE.md, checked_date: 2026-08-29, page_or_section: S22, supports: [six_story_massing, completion], does_not_support: [appearance], image_reuse_permission: not_needed, stored_in_repo: false}
  - {id: SV, authority: secondary, url_or_local_path: discovery/facades/BATCH_02_STREETVIEW_OBSERVATIONS.md, checked_date: 2026-08-29, page_or_section: Maceo_May, supports: [outer_ENE_SSE_materials, modules, seams, six_rows], does_not_support: [exact_endpoints, WSW, NNW, INNER], image_reuse_permission: observation_only, stored_in_repo: false}
reference_roles: {identity_context: [L01], massing: [L01, L02], pattern_region: [SV], cadence_and_seams: [SV], material_surface: [SV], scale: [L01, SV], rejection_example: []}
pattern_regions:
  - {region_id: OUTER_ENE, local_scope: runs_11_to_16_endpoints_unreconciled, periodicity: local_bays_non_global, must_not_share_tile_with: [OUTER_SSE, INNER]}
  - {region_id: OUTER_SSE, local_scope: runs_7_to_10_endpoints_unreconciled, periodicity: nonperiodic_entrance_region, must_not_share_tile_with: [OUTER_ENE, INNER]}
  - {region_id: INNER, local_scope: runs_21_to_39, periodicity: unknown, must_not_share_tile_with: [OUTER]}
motif_inventory: [MM_ENE_W, MM_SSE_W, MM_GROUND_N, MM_CW, MM_ENTRY55]
motif_sequences: []
repeat_blueprint: {region_id: OUTER_OBSERVED, smallest_cell_status: rejected_cross_region, period_tokens_horizontal: null, period_tokens_vertical: six_visible_levels_on_ENE_only, period_m: {x: null, y: null}, cell_contents_full_motifs: [MM_ENE_W, MM_SSE_W, MM_GROUND_N, MM_CW, MM_ENTRY55], edge_fragments: {left: [], right: [], top: [], bottom: []}, edge_compositions_expected: {left_plus_right: [], top_plus_bottom: [], corners: []}, legal_seam_zones: [uninterrupted_field, verified_rib_valley, complete_module_surround], forbidden_seam_zones: [generated_U_resets, windows, grid_frames, rust_trim, rib_terminations, curtain_mullions, entry_sign, corners, outer_inner_boundary], fallback_if_not_proven: unique_elevation}
material_brief: {surface_family: ENE_white_graphite_plus_SSE_light_rib_rust_concrete, base_color: separate_value_bands_documented_above, finish: clean_region_specific, relief_direction_and_frequency: vertical_rib_pitch_unknown, roughness: 0.48_to_0.90_by_region, variation_and_weathering: minimal, maps_requested: [albedo, roughness, shallow_normal], maps_forbidden: [height_displacement, baked_lighting, photographic_reflections], tile_scale_status: plausible_not_measured, tile_scale_m: {x: null, y: null}}
excluded_architectural_features: [{feature: massing_roof_ring_topology_deep_balconies_walkways, owner: geometry, reason: invariant}]
uncertainty:
  - {unknown: outer_exact_endpoints_and_dimensions, impact: unique_layout_blocked, safe_fallback: material_prototypes_only, stop_if_required: true}
  - {unknown: inner_courtyard_facade, impact: no_inner_modules_or_material_claim, safe_fallback: shared_placeholder, stop_if_required: true}
hard_mismatch_gates:
  - {scope: identity, reject_if: receiver_or_relation_ring_is_wrong, proof_required: exact_relation_and_runtime_metadata}
  - {scope: module, reject_if: outer_schedule_is_applied_to_inner_ring, proof_required: ring_role_and_endpoint_layout_audit}
  - {scope: geometry, reject_if: ring_massing_roof_collision_spray_foundation_or_generated_contract_changes, proof_required: exact_receiver_audit}
research_verdict: {ready_for_generation: true_for_outer_material_prototypes_only, recommended_output_kind: homogeneous_material_tile, blockers: [exact_outer_endpoints, dimensions, rib_pitch, WSW_NNW_unobserved, inner_ring_unobserved, missing_frozen_address]}
```

## Final status

- Identity/ring-aware receiver: **ready**.
- ENE/SSE material prototypes: **specification-ready**.
- Outer module vocabulary: **grammar-ready; scale blocked**.
- Exact outer layout and all inner-courtyard appearance: **blocked**.

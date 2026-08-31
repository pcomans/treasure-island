# Star View Court facade reference specification

Checked: **2026-08-29**
Mode: **research and implementation handoff only**
Target: **`w1212173437` / `building:w1212173437:wall`**

## Handoff verdict

Star View Court resolves by exact frozen name to one direct 26-run apartment receiver, but the frozen source has **no address**. Official Sep/Nov 2025 imagery supports warm-white and grey-base materials, mixed complete window modules, and one unique named entrance. Exact layout remains blocked by unreconciled endpoints, unobserved SSE/rear/courtyard conditions, and an apparent six-visible-level versus frozen seven-level conflict. The `21 m` receiver remains unchanged.

## Evidence labels

Use `verified_fact`, `reference_observation`, `production_inference`, and `unknown` exactly as defined by the building-texture workflow. A missing address or conflicting story source remains explicit.

## Confirmed identity and receiver

| Item | Exact value | Status |
|---|---|---|
| Name | Star View Court | exact frozen `name` |
| Address | none in frozen source | do not fill from recollection or nearby streets |
| Source | way `1212173437`, version `4`, timestamp `2025-04-06T04:37:54Z`; `building=apartments`, `building:levels=7` | exact |
| Local public evidence | completed May 2024; published sources differ between six and seven stories | `ISLAND_EVIDENCE S22`; coarse massing only |
| Logical/wall/roof | `building:w1212173437`; `building:w1212173437:wall`; `building:w1212173437:roof` | exact |
| Chunk/runtime | `x_-1__z_0`; `WorldRoot/PlayableWorld/Buildings/x_-1__z_0__building_w1212173437_wall/building_w1212173437_wall` | exact current naming derivation |
| Current material | shared `plaster_grey_04`; roof `bitumen`; no override | placeholder only |

### Generated contract

- `osm_levels`, `21 m`; base/top `4.485 / 25.485 m`; lowest foundation vertex `1.619 m`.
- Source area `4548.448 m²`; perimeter/visible wall `293.025 m`.
- Wall `26` exterior-foundation runs, `104` vertices / `52` triangles; roof `4` vertices / `2` triangles. No shared part walls.
- Opaque spray-receiver wall and non-spray opaque roof collider; U restarts per run.
- Continuous chains: WSW runs `0..9`, `89.139 m`; SSE `10..12`, `46.076 m`; ENE `13..22`, `107.862 m`; NW `23..25`, `49.948 m`.

## Provenance and coverage

| ID | Source | Supports | Excludes |
|---|---|---|---|
| `L01` | frozen OSM + receiver inventory/generated records, checked 2026-08-29 | name, no-address state, receiver, seven-level generated contract | facade appearance |
| `L02` | `discovery/ISLAND_EVIDENCE.md`, `S22` | completion and six-versus-seven conflict | facade language or authority to change massing |
| `SV` | `discovery/facades/BATCH_02_STREETVIEW_OBSERVATIONS.md`, Star View Court section; checked 2026-08-29 | ENE/NW/partial WSW materials, modules, entrance, seams and visible six-row evidence | no image storage/reuse; no exact endpoints or rear/courtyard truth |

Exact official requests: `SVC-SV01` <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82198,-122.37395&heading=110&pitch=7&fov=78> (`zyHYcw8pVTx2iEKy0KR32w`, **Nov 2025**, NW named entrance and partial WSW); `SVC-SV02` <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82170,-122.37255&heading=275&pitch=7&fov=78> (`XinlFktyE0_U2KP7tU6mfg`, **Sep 2025**, broad ENE and ground entrances). Viewed only in official Street View; no pixels retained.

### Observed

- Broad ENE maps to the `62.5°` family; named entrance maps to the NW/WSW corner (`310.3°/242.4°`) with medium endpoint confidence.
- Warm white/very-light grey smooth upper field with subtle control joints; near-charcoal frames/deep reveals; muted green-grey glazing.
- ENE base has medium-grey vertical textured tile/brick-like strips between complete tall ground windows/doors.
- Entrance `SVC-ENTRY78`: light raw-concrete/grey portal, full-height lobby glazing, thin dark canopy/sign band reading `STAR VIEW COURT`, and one large `78` identifier.
- Upper opening families are narrow portrait, paired/wide rectangles and larger vertical stacks. Order is irregular; local bays align vertically but no global period exists.
- Recessed joints and offsets divide regions. Flat parapets, tower/wing height changes and courtyard projection are geometry-owned. Weathering is minimal.
- ENE visibly reads ground plus five upper rows: six apparent levels, not authority to change the seven-level receiver.

### Unobserved

Complete SSE, much of WSW, rear/courtyard faces, exact endpoints and dimensions remain unknown. Do not infer an address from the visible `78`; it is an observed entrance identifier only.

## Region, material, motif, scale, and output status

| Region | Scope | Status |
|---|---|---|
| ENE observed | family runs `13..22`; exact subregion endpoints unresolved | white upper/grey base and mixed modules observed |
| NW entrance / partial WSW | NW `23..25`, WSW `0..9`; exact corner ownership unresolved | unique entrance and partial context only |
| unobserved chains | all other runs | placeholder; no unique modules |
| foundation | below base `4.485` | geometry only; no motifs |
| roof/silhouette | top `25.485` | geometry-owned |

`production_inference` bands: warm-white value `0.74-0.88` linear / roughness `0.55-0.78`; grey textured base value `0.26-0.42` / roughness `0.70-0.90` with shallow vertical normal; charcoal frames `0.04-0.12` / roughness `0.30-0.50`; glazing `0.20-0.38`, no baked reflection; raw-concrete portal `0.48-0.64` / roughness `0.72-0.90`. Plausible, not sampled.

Smallest-repeat finding: no global architectural tile. Use complete `SVC-W-N/M/W`, `SVC-BASE-W/D`, and unique `SVC-ENTRY78`. Physical widths/heights and textured-base pitch remain unknown; exact metre-scale receiver bounds are calibration only and the six visible rows cannot be stretched to seven.

| Output | Status | Gate |
|---|---|---|
| `homogeneous_material_tile` | **spec-ready prototypes** | separate white upper and grey textured base |
| `architectural_pattern_tile` | **rejected facade-wide** | irregular order; control joints do not prove a module period |
| `module_atlas` | **grammar-ready, scale-blocked** | complete upper/base families; entrance remains unique |
| `unique_elevation` | **blocked** | exact endpoints, unobserved sides and story conflict |

Legal seams are uninterrupted white/grey field, verified full control joints that split no motif, and complete-module surrounds. Forbidden seams cut windows, frames/reveals, ground glazing/doors, textured-base terminations, portal, canopy/name band, `78`, corners/parapets or any generated U reset. Never tile the irregular sequence.

## Godot BOM

| ID | Reserved path | Status |
|---|---|---|
| `MAT-WHITE` | `res://game/resources/materials/world/star_view_court/star_view_primary.tres` | warm-white upper field; prototype-ready |
| `MAT-BASE` | `res://game/resources/materials/world/star_view_court/star_view_grey_base.tres` | vertical-textured base; prototype-ready, pitch review needed |
| `MAT-CONCRETE` | `res://game/resources/materials/world/star_view_court/star_view_entry_concrete.tres` | entrance portal only; prototype-ready |
| `MOD` | `res://game/scenes/world/facades/star_view_court/star_view_modules.tscn` | W-N/M/W, BASE-W/D, ENTRY78 | grammar-ready; scale/endpoints blocked |
| `LAYOUT` | `res://game/resources/facades/star_view_court_layout.json` | blocked pending exact run map |
| `ATTACH` | `res://game/scenes/world/facades/star_view_court/star_view_facade.tscn` | later render-only child; blocked |

## Geometry boundary and representative invariant

Facade-owned after evidence: PBR fields and complete shallow visual modules. Excluded: deciding six versus seven stories; height, roof/silhouette, footprint, deep balcony/recess/opening geometry, collision, spray, terrain/foundation, navigation and generated/source contracts.

```text
before: building:w1212173437:wall is the exact 21 m / seven-level generated
        opaque spray receiver with 26 runs and shared plaster_grey_04.

after:  that exact wall, roof, seven-level mass, footprint, run chain, collision,
        spray owner, foundations, source ID and generated bytes remain unchanged;
        only endpoint-mapped observed fields and complete render-only modules may
        be added. The result does not settle the public six-versus-seven conflict.
```

## Executable acceptance gates

- [x] Every visual claim has an exact panorama URL/ID/date/direction/coverage record.
- [ ] No address is invented; any observed map label is kept separate from frozen address state.
- [ ] Exact chunk/path, `21 m`, `26 / 293.025 m`, wall `52` and roof `2` triangles remain unchanged.
- [ ] Exact run endpoints/continuous side coordinates drive layout; U resets do not.
- [ ] All modules and edge compositions remain complete; no motif is created/resized/duplicated/deleted at a seam.
- [ ] No child collider/spray owner/navigation/physics; decal hits remain on underlying wall.
- [ ] No six- or seven-story appearance claim is used to alter massing or squeeze cadence.
- [ ] Reviewer separates facade-language acceptance from whole-object story conflict.

## Blockers

- ENE/NW/partial WSW appearance is observed; exact run endpoints and module dimensions remain blocked.
- Complete SSE, rear/courtyard and most WSW remain unknown.
- Frozen address is missing.
- Six-versus-seven public evidence conflict prevents a definitive real story-count claim; current seven-level mass remains invariant.
- Exact roof, balconies, glazing, ground condition, private/rear facades and module scale are unknown.

## Normalized handoff

```yaml
schema_version: codex.building-texture-research/1
job: {job_id: star_view_court_facade_reference_spec, checked_date: 2026-08-29, intended_use: ENE_NW_material_and_module_handoff, target_asset_kind: module_atlas}
target: {canonical_name: Star View Court, local_object_ids: [w1212173437, building:w1212173437, building:w1212173437:wall], identity_confidence: high, receiver_path: WorldRoot/PlayableWorld/Buildings/x_-1__z_0__building_w1212173437_wall/building_w1212173437_wall}
sources:
  - {id: L01, authority: project, url_or_local_path: discovery/FACADE_RECEIVER_INVENTORY.json, checked_date: 2026-08-29, page_or_section: facade-receiver:w1212173437, supports: [identity, missing_address, receiver, scale], does_not_support: [appearance], image_reuse_permission: not_needed, stored_in_repo: false}
  - {id: L02, authority: project, url_or_local_path: discovery/ISLAND_EVIDENCE.md, checked_date: 2026-08-29, page_or_section: S22, supports: [completion, six_vs_seven_story_conflict], does_not_support: [appearance], image_reuse_permission: not_needed, stored_in_repo: false}
  - {id: SV, authority: secondary, url_or_local_path: discovery/facades/BATCH_02_STREETVIEW_OBSERVATIONS.md, checked_date: 2026-08-29, page_or_section: Star_View_Court, supports: [ENE_NW_materials, modules, entrance, seams, six_visible_levels], does_not_support: [exact_endpoints, dimensions, SSE, rear_courtyard], image_reuse_permission: observation_only, stored_in_repo: false}
reference_roles: {identity_context: [L01], massing: [L01, L02], pattern_region: [SV], cadence_and_seams: [SV], material_surface: [SV], scale: [L01, SV], rejection_example: []}
pattern_regions:
  - {region_id: ENE_OBSERVED, local_scope: runs_13_to_22_endpoints_unreconciled, periodicity: irregular, must_not_share_tile_with: [UNOBSERVED_SSE_REAR]}
  - {region_id: ENTRY_NW, local_scope: runs_23_to_25_and_WSW_corner_ownership_unresolved, periodicity: unique, must_not_share_tile_with: [OTHER_ENTRANCES]}
motif_inventory: [SVC_W_N, SVC_W_M, SVC_W_W, SVC_BASE_W, SVC_BASE_D, SVC_ENTRY78]
motif_sequences: []
repeat_blueprint: {region_id: ENE_OBSERVED, smallest_cell_status: rejected_irregular, period_tokens_horizontal: null, period_tokens_vertical: local_stack_alignment_only, period_m: {x: null, y: null}, cell_contents_full_motifs: [SVC_W_N, SVC_W_M, SVC_W_W, SVC_BASE_W, SVC_BASE_D], edge_fragments: {left: [], right: [], top: [], bottom: []}, edge_compositions_expected: {left_plus_right: [], top_plus_bottom: [], corners: []}, legal_seam_zones: [uninterrupted_field, verified_control_joint, complete_module_surround], forbidden_seam_zones: [generated_U_resets, windows, reveals, base_terminations, entry_sign_number, corners], fallback_if_not_proven: unique_elevation}
material_brief: {surface_family: smooth_white_upper_plus_vertical_grey_base, base_color: separate_value_bands_documented_above, finish: clean_minimal_weathering, relief_direction_and_frequency: vertical_base_texture_pitch_unmeasured, roughness: 0.55_to_0.90_by_region, variation_and_weathering: minimal, maps_requested: [albedo, roughness, shallow_normal], maps_forbidden: [height_displacement, baked_lighting, photographic_reflections], tile_scale_status: plausible_not_measured, tile_scale_m: {x: null, y: null}}
excluded_architectural_features: [{feature: story_count_height_roof_silhouette_and_deep_modules, owner: geometry, reason: invariant_and_story_conflict}]
uncertainty:
  - {unknown: exact_endpoints_and_module_dimensions, impact: unique_layout_blocked, safe_fallback: material_prototypes_only, stop_if_required: true}
  - {unknown: six_vs_seven_story_truth, impact: whole_object_claim_blocked, safe_fallback: preserve_frozen_seven_level_receiver, stop_if_required: true}
hard_mismatch_gates:
  - {scope: identity, reject_if: receiver_is_not_building_w1212173437_wall_or_address_is_invented, proof_required: exact_metadata}
  - {scope: geometry, reject_if: story_massing_roof_collision_spray_foundation_or_generated_contract_changes, proof_required: exact_receiver_audit}
research_verdict: {ready_for_generation: true_for_material_prototypes_only, recommended_output_kind: homogeneous_material_tile, blockers: [exact_endpoints, dimensions, unobserved_SSE_rear_courtyard, six_vs_seven_story_conflict, missing_frozen_address]}
```

## Final status

- Identity/receiver: **ready**.
- Material prototypes: **specification-ready**.
- Module vocabulary: **grammar-ready; scale blocked**.
- Exact unique layout: **blocked**.
- Whole-object story claim: **blocked by conflicting evidence**.

# Treasure Island Community YMCA facade reference specification

Checked: **2026-08-29**
Mode: **research and implementation handoff only**
Target: **`w34313547` / `building:w34313547:wall`**

## Handoff verdict

The exact named sports-centre footprint resolves to a direct 30-run receiver, but the frozen source has **no address**. Official Sep 2025 imagery supports a rough dark aggregate main-wall material, a complete SSE entry vocabulary and sparse ENE service modules. Exact layout remains blocked by unreconciled endpoints, WSW absence and NNW occlusion. A May 2019 mural-wing view has unresolved footprint ownership and is excluded from target modules.

## Confirmed identity and receiver

Use `verified_fact`, `reference_observation`, `production_inference`, and `unknown` labels.

| Item | Exact value | Status |
|---|---|---|
| Name | Treasure Island Community YMCA | exact frozen name |
| Address | none in frozen source | preserve absence |
| Source | way `34313547`, version `6`, timestamp `2024-02-20T01:39:43Z` | exact |
| Frozen tags | `brand=YMCA`, `leisure=sports_centre`, `height=9`, `check_date=2024-02-19` | identity/use context only; no appearance claim |
| Logical/wall/roof | `building:w34313547`; `building:w34313547:wall`; `building:w34313547:roof` | exact |
| Chunk/runtime | `x_0__z_-2`; `WorldRoot/PlayableWorld/Buildings/x_0__z_-2__building_w34313547_wall/building_w34313547_wall` | exact naming derivation |
| Current materials | shared wall `plaster_grey_04`; roof `bitumen`; no override | placeholder only |

### Generated contract and exact run topology

- `osm_height`, `9 m`; base/top `4.102 / 13.102 m`; lowest foundation vertex `3.711 m`.
- Source area `2723.733 m²`; serialized perimeter `267.238 m`; visible wall `267.240 m`.
- Wall `30` foundation runs, `120` vertices / `60` triangles; roof `8` vertices / `6` triangles. No shared part wall.
- Footprint is re-entrant: WSW chains `0..2` (`27.591 m`) and `21..25` (`33.042 m`); SSE `3..7` (`72.978 m`); ENE `8..11` (`28.068 m`) and `15..18` (`32.571 m`); NNW `12..14` (`26.482 m`), `19..20` (`21.109 m`), `26..29` (`25.401 m`).
- Same-facing chains separated by a return are not one facade. U resets per run. Wall is opaque spray receiver; roof is non-spray collider.

## Provenance and coverage

| ID | Source | Supports | Excludes |
|---|---|---|---|
| `L01` | frozen OSM + inventory/generated records, checked 2026-08-29 | name, missing address, use/brand tags, exact receiver/scale | appearance and current signage |
| `SV` | `discovery/facades/BATCH_02_STREETVIEW_OBSERVATIONS.md`, YMCA section; checked 2026-08-29 | SSE/ENE/partial NNW materials, entry/service/louver modules, coverage and mural-ownership warning | no imagery storage/reuse; no exact endpoints/WSW/mural rights |

Exact official requests: `Y-SV01` <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82605,-122.36825&heading=330&pitch=6&fov=78> (`d0oKpsvA2eE-WM-C7gVokA`, **Sep 2025**, complete SSE entry); `Y-SV02` <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82645,-122.36785&heading=245&pitch=5&fov=78> (`BM2ooxp-6GhmR934Ah2PVA`, **Sep 2025**, ENE service end); `Y-SV03` <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82688,-122.36855&heading=155&pitch=5&fov=78> (`NVAmGBSgPlk8h5g-8-od9g`, **May 2019**, partial NNW/campus). No imagery retained.

### Observed

- Complete public entry maps to SSE (`152.0°`); service end maps to ENE (`62.0°`). NNW is partial/occluded and its low-wing ownership is uncertain.
- Main gym wall is dark warm-grey/brown rough exposed-aggregate or pebbled precast field with thin cool blue-grey vertical strips/joints dividing broad panels. Exact aggregate size/panel construction is unknown.
- SSE has a low projected warm-white vestibule/portal, thin blue-grey canopy/fascia and complete glazed door/sidelight bank. Small left-side lettering is not legible enough to reproduce.
- ENE is nearly blank: one small high light-grey metal louver and one dark-blue service/personnel door, partly screened.
- Thin dark/cool coping and flat/very shallow roof appearance are geometry-owned. Main volume reads as one tall gym/hall without stacked rows.
- May 2019 NNW context shows a low warm-white wing, long window band and colorful mural; low-confidence ownership and older date make all three invalid target-wide vocabulary.

### Unobserved

WSW, much of NNW main wall, exact low-wing ownership, exact endpoints, aggregate/panel scale and small lettering remain unknown. No logo or mural module is authorized.

## Material/motif/scale and output status

| Region | Scope | Status |
|---|---|---|
| SSE observed | runs `3..7`, exact subregions/endpoints unresolved | aggregate + unique entry vocabulary |
| ENE observed | runs `8..11` or `15..18`, exact ownership unresolved | sparse louver/service-door vocabulary |
| NNW partial | chains `12..14`, `19..20`, `26..29`; ownership unresolved | no target module from mural wing |
| unobserved/re-entrant chains | all other runs | placeholder/no unique modules |
| foundation/roof | below `4.102`, top `13.102` | geometry-owned |

`production_inference` starting bands: aggregate value `0.16-0.30` linear, roughness `0.82-0.96`, low-frequency granular normal without displacement; joint strips value `0.28-0.44`, roughness `0.58-0.78`; warm-white entry value `0.72-0.88`, roughness `0.55-0.78`; blue door/fascia value `0.12-0.26`, roughness `0.42-0.66`. Plausible, not sampled.

Smallest-repeat finding: `Y-AGG` is homogeneous; vertical panel joints require explicit world-space placement and are not a tile period. Complete modules are `Y-ENTRY`, `Y-SERVICE-D`, and `Y-LOUVER`. Dimensions/aggregate scale are unmeasured; `9 m` is receiver calibration only.

| Output | Status | Gate |
|---|---|---|
| `homogeneous_material_tile` | **spec-ready prototype** | dark aggregate main field; granular scale reviewer-gated |
| `architectural_pattern_tile` | **rejected** | panel joints need explicit placement; no repeating facade cell |
| `module_atlas` | **grammar-ready, scale-blocked** | ENTRY, SERVICE-D and LOUVER only; no mural/sign module |
| `unique_elevation` | **blocked** | endpoint mapping, WSW and NNW ownership/occlusion |

Legal seams: uninterrupted aggregate/white field, verified full panel-joint line, complete module surround. Forbidden: cuts through joints, louver, service door, entry glazing/mullions, canopy/fascia, lettering, coping, window band or mural; U resets and re-entrant jumps. Do not distribute entry or mural.

## Godot BOM

| ID | Reserved path | Status |
|---|---|---|
| `MAT-AGG` | `res://game/resources/materials/world/ti_ymca/ti_ymca_primary.tres` | rough dark aggregate; prototype-ready |
| `MAT-WHITE` | `res://game/resources/materials/world/ti_ymca/ti_ymca_entry_white.tres` | warm-white entry field; prototype-ready |
| `MAT-BLUE` | `res://game/resources/materials/world/ti_ymca/ti_ymca_blue_metal.tres` | door/fascia accents; prototype-ready |
| `MOD` | `res://game/scenes/world/facades/ti_ymca/ti_ymca_modules.tscn` | ENTRY, SERVICE-D, LOUVER; no mural | grammar-ready; dimensions/endpoints blocked |
| `LAYOUT` | `res://game/resources/facades/ti_ymca_layout.json` | exact-chain schedule; blocked |
| `ATTACH` | `res://game/scenes/world/facades/ti_ymca/ti_ymca_facade.tscn` | render-only child; blocked |

## Geometry boundary and invariant example

Evidence-backed PBR and complete shallow render-only modules may be facade-owned. Height, roof/silhouette, footprint/re-entrant mass, deep openings, collision, spray, terrain/foundation, navigation/access, generated data and source contracts are excluded.

```text
before: building:w34313547:wall is one 9 m-high opaque spray receiver with
        30 runs on a re-entrant footprint and shared plaster_grey_04.

after:  that exact wall, roof, footprint, run topology, collision, spray owner,
        foundations, source ID and generated bytes remain unchanged; a later
        noncolliding child adds only observed materials/complete modules to
        explicitly mapped contiguous chains, never across a re-entrant return.
```

## Acceptance checklist

- [x] Exact panorama URL/ID/date/direction/coverage supports each appearance claim.
- [ ] Missing frozen address remains explicit; brand does not invent signage.
- [ ] Exact target/path/chunk, `9 m`, `30 / 267.240 m`, wall `60` and roof `6` triangles remain.
- [ ] Exact run chains/endpoints control layout; no U reset or same-normal gap creates phase.
- [ ] All modules and seam products remain complete.
- [ ] Render-only child adds no collision/navigation/spray ownership; underlying wall remains decal hit owner.
- [ ] No roof/height/silhouette/footprint/foundation/terrain/collision/spray/generated-data change.
- [ ] Reviewer separates observed entrance/sign evidence, receiver behavior and whole-object verdict.

## Explicit blockers

No frozen address. SSE/ENE appearance is observed, but exact run endpoints, physical module/aggregate scale, WSW and most NNW remain blocked. The May 2019 low wing/mural has uncertain footprint ownership and cannot be authored.

## Normalized handoff

```yaml
schema_version: codex.building-texture-research/1
job: {job_id: treasure_island_community_ymca_facade_reference_spec, checked_date: 2026-08-29, intended_use: SSE_ENE_material_and_module_handoff, target_asset_kind: module_atlas}
target: {canonical_name: Treasure Island Community YMCA, local_object_ids: [w34313547, building:w34313547, building:w34313547:wall], identity_confidence: high, receiver_path: WorldRoot/PlayableWorld/Buildings/x_0__z_-2__building_w34313547_wall/building_w34313547_wall}
sources:
  - {id: L01, authority: project, url_or_local_path: discovery/FACADE_RECEIVER_INVENTORY.json, checked_date: 2026-08-29, page_or_section: facade-receiver:w34313547, supports: [identity, missing_address, receiver, scale], does_not_support: [appearance, current_signage], image_reuse_permission: not_needed, stored_in_repo: false}
  - {id: SV, authority: secondary, url_or_local_path: discovery/facades/BATCH_02_STREETVIEW_OBSERVATIONS.md, checked_date: 2026-08-29, page_or_section: Treasure_Island_Community_YMCA, supports: [SSE_ENE_materials, entry_service_louver, seams], does_not_support: [exact_endpoints, WSW, mural_ownership_or_content], image_reuse_permission: observation_only, stored_in_repo: false}
reference_roles: {identity_context: [L01], massing: [L01], pattern_region: [SV], cadence_and_seams: [SV], material_surface: [SV], scale: [L01, SV], rejection_example: []}
pattern_regions:
  - {region_id: SSE_OBSERVED, local_scope: runs_3_to_7_endpoints_unreconciled, periodicity: nonperiodic_entry, must_not_share_tile_with: [NNW_MURAL_UNCERTAIN]}
  - {region_id: ENE_OBSERVED, local_scope: one_of_runs_8_to_11_or_15_to_18_unresolved, periodicity: sparse_nonperiodic, must_not_share_tile_with: [WSW_UNOBSERVED]}
motif_inventory: [Y_ENTRY, Y_SERVICE_D, Y_LOUVER]
motif_sequences: []
repeat_blueprint: {region_id: MAIN_VOLUME, smallest_cell_status: homogeneous_material_only, period_tokens_horizontal: null, period_tokens_vertical: null, period_m: {x: null, y: null}, cell_contents_full_motifs: [Y_ENTRY, Y_SERVICE_D, Y_LOUVER], edge_fragments: {left: [], right: [], top: [], bottom: []}, edge_compositions_expected: {left_plus_right: [], top_plus_bottom: [], corners: []}, legal_seam_zones: [uninterrupted_aggregate, verified_panel_joint, complete_module_surround], forbidden_seam_zones: [generated_U_resets, reentrant_jumps, entry, louver, door, lettering, mural, coping], fallback_if_not_proven: unique_elevation}
material_brief: {surface_family: rough_dark_exposed_aggregate_or_pebbled_precast, base_color: warm_grey_brown_value_0.16_to_0.30_linear, finish: very_matte_rough, relief_direction_and_frequency: granular_scale_unknown_no_displacement, roughness: 0.82_to_0.96, variation_and_weathering: low_region_variation, maps_requested: [albedo, roughness, normal], maps_forbidden: [height_displacement, baked_lighting, photographic_reflections], tile_scale_status: plausible_not_measured, tile_scale_m: {x: null, y: null}}
excluded_architectural_features: [{feature: massing_roof_silhouette_deep_openings, owner: geometry, reason: invariant}]
uncertainty: [{unknown: exact_endpoints_scale_WSW_NNW_and_mural_ownership, impact: material_prototype_and_module_grammar_only, safe_fallback: aggregate_field_without_unique_content, stop_if_required: true}]
hard_mismatch_gates:
  - {scope: identity, reject_if: receiver_is_not_building_w34313547_wall_or_address_is_invented, proof_required: exact_metadata}
  - {scope: evidence, reject_if: YMCA_brand_is_used_as_facade_or_signage_proof, proof_required: observation_ledger}
  - {scope: geometry, reject_if: massing_roof_collision_spray_foundation_or_generated_contract_changes, proof_required: exact_receiver_audit}
research_verdict: {ready_for_generation: true_for_material_prototype_only, recommended_output_kind: homogeneous_material_tile, blockers: [exact_endpoints, module_scale, WSW, NNW_occlusion, mural_ownership, missing_frozen_address]}
```

## Final status

- Identity/receiver: **ready**.
- Aggregate/entry material prototypes: **specification-ready**.
- SSE/ENE module vocabulary: **grammar-ready; scale blocked**.
- Exact unique layout and NNW mural content: **blocked**.

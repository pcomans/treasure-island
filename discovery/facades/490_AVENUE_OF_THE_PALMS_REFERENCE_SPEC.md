# 490 Avenue of the Palms facade reference specification

Checked: **2026-08-29**
Mode: **research and implementation handoff only**
Target source: **`w1272162518`**
Current wall receiver: **`building:w1272162518:wall`**

## Handoff verdict

The exact named condominium and complete frozen address resolve to one standalone 26-run receiver. Official Nov 2025 Street View supports separate warm-white, thin-brick, greige and charcoal/glazing materials plus a WSW module vocabulary. Exact layout remains blocked by unreconciled run endpoints, unobserved ENE/SSE schedules, deep terrace geometry, and a six-visible-level versus five-level receiver conflict. This brief preserves the `15 m` five-level receiver and never resolves the discrepancy through texture cadence.

## Evidence labels

`verified_fact` is exact local authoritative data; `reference_observation` is visible in an identified dated panorama; `production_inference` is reversible implementation judgment; `unknown` is forbidden as appearance truth.

## Confirmed identity and exact receiver

| Item | Exact value | Status |
|---|---|---|
| Identity / address | 490 Avenue of the Palms; 490 Avenue of the Palms, San Francisco, CA 94130 | exact frozen name and complete address |
| Source | way `1272162518`, key `w1272162518`, version `3`, timestamp `2025-11-16T03:53:10Z` | exact snapshot |
| Frozen tags | `building=condominium`, `building:levels=5` | exact; no facade appearance |
| Local massing evidence | six-story building; temporary occupancy 2025-10-07 | locally recorded official source `S11`; gross massing only |
| Logical / wall / roof | `building:w1272162518`; `building:w1272162518:wall`; `building:w1272162518:roof` | exact |
| Chunk / runtime path | `x_-1__z_1`; `WorldRoot/PlayableWorld/Buildings/x_-1__z_1__building_w1272162518_wall/building_w1272162518_wall` | exact current naming derivation |
| Current materials | wall `plaster_grey_04`; roof `bitumen` | shared placeholder only; no target override |

### Generated mass, mesh, and side contract

- `osm_levels` height `15 m`; flat base/top `0.818 / 15.818 m`; lowest foundation vertex `0.606 m`.
- Source area `5310.559 m²`; perimeter and total visible wall length `305.101 m`.
- Wall `26` exterior-foundation runs, `104` vertices, `52` triangles; no shared-part walls. Roof `4` vertices / `2` triangles.
- Opaque `world_solid` wall, `receiver_kind=building_wall`, sole spray receiver; roof is collider but not spray receiver.
- Exact continuous side chains: WSW runs `0..7`, `82.428 m`; SSE `8..11`, `56.112 m`; ENE `12..22`, `105.178 m`; NW `23..25`, `61.384 m`.
- U restarts at every run; use side/world coordinates, never UV resets, for architectural phase.

## Provenance ledger

| ID | Source | Supports | Excludes |
|---|---|---|---|
| `L01` | frozen OSM way and receiver inventory/generated records; checked 2026-08-29 | exact identity, address, receiver, levels, scale, runs, materials | real facade appearance |
| `L02` | `discovery/ISLAND_EVIDENCE.md`, `S11`; checked 2026-08-29 | six-story gross-massing caution and occupancy date | facade materials/modules; no massing-change authority |
| `SV` | `discovery/facades/BATCH_02_STREETVIEW_OBSERVATIONS.md`, 490 section; checked 2026-08-29, captures Nov 2025 | WSW/NW coverage, material hierarchy, modules, apparent six-level stack, seams | no stored/reused imagery; no exact endpoints/dimensions/ENE schedule |

No Street View image, screenshot, crop, downloaded pixel data, upload, or redistribution is authorized or stored.

Exact official requests: `P490-SV01` <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82115,-122.37405&heading=70&pitch=6&fov=75> (`bjPnIkM1MVTV2DXoZa2jRw`, WSW entry); `P490-SV02` <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82155,-122.37430&heading=125&pitch=7&fov=78> (`92eDcHBL7oSzMdVAC4wfkA`, north corner); `P490-SV03` <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82072,-122.37398&heading=45&pitch=7&fov=78> (`_7_jhPOXMBLR2zGQkhH2hw`, southern WSW); `P490-SV04` <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82178,-122.37372&heading=160&pitch=7&fov=78> (`qezst3shU9xoH-7A1tk_FQ`, NW/north). All display **Nov 2025**.

## Observed and unobserved facade coverage

### Observed

- `reference_observation`: most of WSW runs-family appearance and a NW/north oblique. Exact endpoints are not mapped; ENE/rear, complete SSE, courtyard/interior faces remain unknown.
- Clean/new hierarchy of warm-white smooth panel/render, dark taupe/grey thin brick, muted tan/greige accents, near-charcoal metal frames, and muted blue-green/grey glazing. No distressed/stained treatment.
- Upper families: narrow portrait, paired medium and broad near-floor-to-ceiling windows; white frames around some stacks, brick piers/deep framed voids around others. Order is non-global and non-periodic.
- Deep multi-bay terrace/balcony recesses occur inside brick frames. Depth, soffits and rails are geometry-owned.
- Ground is mostly warm white with punched windows, full-height glazed bays and occasional greige panels. The observed recessed entrance includes glazed doors and one `490` identifier.
- Thin white slab/belt bands separate some regions. The tall Avenue A corner visibly reads ground plus five upper occupied rows: six apparent levels, a conflict with the frozen five-level receiver.

### Unobserved

ENE/rear, complete SSE end, courtyard/interior faces, exact side endpoints, dimensions, terrace depth and corner phase remain unobserved. Lower-looking connected/adjacent north volumes have unresolved footprint ownership.

## Material/motif grammar and physical scale

| Region | Scope | Status |
|---|---|---|
| `WSW-WHITE/BRICK/GREIGE` | WSW chain family `0..7`, exact endpoint subregions unresolved | observed material hierarchy and nonperiodic modules |
| `NW-OBLIQUE` | NW family `23..25`, exact ownership/endpoints unresolved | material/corner context only |
| `UNOBSERVED` | all unmapped runs | shared placeholder; no unique module |
| `FOUNDATION-EXT` | below base `y=0.818` | geometry-owned, no openings |
| `ROOF/SILHOUETTE` | top `y=15.818` | geometry-owned |

`production_inference` starting bands: white field value `0.72-0.88` linear / roughness `0.55-0.78`; taupe-grey thin brick value `0.18-0.34` / roughness `0.72-0.90` with shallow normal only; greige value `0.42-0.58` / roughness `0.58-0.78`; charcoal frames value `0.05-0.13` / roughness `0.28-0.48`; glazing value `0.20-0.38` with no baked reflection. These are plausible, not sampled.

Smallest-repeat finding: no global translation cell exists; use complete `P490-W-N/M/W`, `P490-BRICK-BAY`, `P490-GROUND-GLAZED`, unique `P490-ENTRY`, and side-specific `P490-TERRACE`. Physical module dimensions are not defensibly calibrated; height `15 m` and exact run lengths are receiver constraints, not permission to compress six observed rows into five.

## Output classification, seams, and BOM

| Kind | Status | Gate |
|---|---|---|
| `homogeneous_material_tile` | **spec-ready prototypes** | separate white, brick and greige materials; no cross-region sharing |
| `architectural_pattern_tile` | **rejected facade-wide** | no true repeat; thin-brick material can tile only at full-unit boundaries |
| `module_atlas` | **grammar-ready, scale-blocked** | complete window/ground/entry families; terrace face only, not depth |
| `unique_elevation` | **blocked** | exact endpoints, unobserved sides and story/massing conflict |

Legal seams: uninterrupted white/greige field, full thin-brick unit boundaries, and boundaries around complete modules; slab bands only with continuous world-space phase. Forbidden: cuts through windows/mullions/surrounds, brick piers/corners, greige terminations, belts, terrace void/rail/soffit, entry recess/door or `490`; generated U resets; wrapping WSW sequence to ENE.

| ID | Reserved path | Role/status |
|---|---|---|
| `MAT-WHITE` | `res://game/resources/materials/world/490_avenue_palms/490_primary.tres` | warm-white panel/render; prototype-ready |
| `MAT-BRICK` | `res://game/resources/materials/world/490_avenue_palms/490_thin_brick.tres` | dark taupe/grey thin brick; prototype-ready |
| `MAT-GREIGE` | `res://game/resources/materials/world/490_avenue_palms/490_greige.tres` | muted accent field; prototype-ready |
| `MOD` | `res://game/scenes/world/facades/490_avenue_palms/490_modules.tscn` | W-N/M/W, brick bay, ground glazing, entry, terrace face | grammar-ready; dimensions blocked |
| `LAYOUT` | `res://game/resources/facades/490_avenue_of_the_palms_layout.json` | exact-run schedule; blocked |
| `ATTACH` | `res://game/scenes/world/facades/490_avenue_palms/490_facade.tscn` | noncolliding child; blocked until all gates pass |

## Geometry-versus-texture and before -> after

Facade-owned: evidence-backed PBR fields and complete shallow render-only modules. Geometry-owned/excluded: story count, `15 m` height, roofline/silhouette, footprint, deep balconies/recesses/openings, collision, spray, foundation/terrain, navigation and generated contracts.

```text
before: building:w1272162518:wall is a 15 m / five-level generated opaque
        spray receiver with 26 runs and shared plaster_grey_04.

after:  that exact five-level wall, roof, footprint, 26 runs, collision, spray
        owner, foundations, source ID and generated bytes remain unchanged;
        a noncolliding child may add only endpoint-mapped observed facade fields
        and complete modules. It does not claim to supply the locally recorded
        sixth story.
```

## Acceptance checklist

- [x] Exact panorama URL/ID, access/capture date, direction and coverage support every visual claim.
- [ ] Exact receiver/path/chunk and `15 m`, `26 / 305.101 m`, wall `52` triangles, roof `2` triangles remain unchanged.
- [ ] Layout maps only exact run chains and does not phase-reset at subdivisions.
- [ ] Every motif is complete; every repeat edge/corner product is predicted and unchanged.
- [ ] Render-only child adds no collision/navigation/spray ownership; underlying wall remains decal target.
- [ ] No sixth-story motif is squeezed into, overlaid above, or implied outside the five-level receiver.
- [ ] No roof, silhouette, story, footprint, terrain, foundation, generated-data, source-ID or gameplay contract changes.
- [ ] Reviewer separately grades material, modules, exact receiver, and whole-object massing mismatch.

## Explicit unknowns/blockers

- WSW/NW material/module grammar is observed; exact endpoint placement and physical dimensions remain blocked.
- ENE/rear, complete SSE, courtyard/interior faces and ownership of lower-looking north volumes remain unknown.
- Six-story local official evidence conflicts with frozen/generated five levels; whole-building fidelity is blocked under the invariant.
- Any balcony depth, roof profile, ground program, private/rear condition, transparency or interior is unknown.

## Normalized research handoff

```yaml
schema_version: codex.building-texture-research/1
job: {job_id: 490_avenue_of_the_palms_facade_reference_spec, checked_date: 2026-08-29, intended_use: WSW_material_and_module_handoff, target_asset_kind: module_atlas}
target: {canonical_name: 490 Avenue of the Palms, local_object_ids: [w1272162518, building:w1272162518, building:w1272162518:wall], identity_confidence: high, receiver_path: WorldRoot/PlayableWorld/Buildings/x_-1__z_1__building_w1272162518_wall/building_w1272162518_wall}
sources:
  - {id: L01, authority: project, url_or_local_path: discovery/FACADE_RECEIVER_INVENTORY.json, checked_date: 2026-08-29, page_or_section: facade-receiver:w1272162518, supports: [identity, address, receiver, scale], does_not_support: [appearance], image_reuse_permission: not_needed, stored_in_repo: false}
  - {id: L02, authority: project, url_or_local_path: discovery/ISLAND_EVIDENCE.md, checked_date: 2026-08-29, page_or_section: S11, supports: [six_story_massing_conflict], does_not_support: [appearance], image_reuse_permission: not_needed, stored_in_repo: false}
  - {id: SV, authority: secondary, url_or_local_path: discovery/facades/BATCH_02_STREETVIEW_OBSERVATIONS.md, checked_date: 2026-08-29, page_or_section: 490_Avenue_of_the_Palms, supports: [WSW_NW_materials, modules, seams, six_visible_levels], does_not_support: [exact_endpoints, dimensions, ENE, complete_SSE], image_reuse_permission: observation_only, stored_in_repo: false}
reference_roles: {identity_context: [L01], massing: [L01, L02], pattern_region: [SV], cadence_and_seams: [SV], material_surface: [SV], scale: [L01, SV], rejection_example: []}
pattern_regions: [{region_id: WSW_OBSERVED, local_scope: runs_0_to_7_exact_subregions_unreconciled, periodicity: nonperiodic, must_not_share_tile_with: [ENE_UNOBSERVED, SSE_UNOBSERVED]}]
motif_inventory: [P490_W_N, P490_W_M, P490_W_W, P490_BRICK_BAY, P490_GROUND_GLAZED, P490_ENTRY, P490_TERRACE]
motif_sequences: []
repeat_blueprint: {region_id: WSW_OBSERVED, smallest_cell_status: rejected_irregular_sequence, period_tokens_horizontal: null, period_tokens_vertical: local_vertical_stacks_only, period_m: {x: null, y: null}, cell_contents_full_motifs: [P490_W_N, P490_W_M, P490_W_W, P490_BRICK_BAY, P490_GROUND_GLAZED, P490_ENTRY], edge_fragments: {left: [], right: [], top: [], bottom: []}, edge_compositions_expected: {left_plus_right: [], top_plus_bottom: [], corners: []}, legal_seam_zones: [uninterrupted_white_or_greige, full_brick_unit, complete_module_boundary], forbidden_seam_zones: [generated_U_resets, windows, brick_piers, belts, terraces, entry, identifier, corners], fallback_if_not_proven: unique_elevation}
material_brief: {surface_family: white_render_plus_taupe_thin_brick_plus_greige_panels, base_color: separate_value_bands_documented_above, finish: clean_low_weathering, relief_direction_and_frequency: thin_brick_only_no_measured_unit, roughness: 0.55_to_0.90_by_region, variation_and_weathering: minimal, maps_requested: [albedo, roughness, shallow_normal], maps_forbidden: [height_displacement, baked_lighting, photographic_reflections], tile_scale_status: plausible_not_measured, tile_scale_m: {x: null, y: null}}
excluded_architectural_features: [{feature: sixth_story_and_all_massing_roof_silhouette, owner: geometry, reason: invariant_and_story_conflict}]
uncertainty:
  - {unknown: exact_run_endpoints_and_module_dimensions, impact: unique_layout_blocked, safe_fallback: material_prototypes_only, stop_if_required: true}
  - {unknown: six_story_real_vs_five_level_receiver, impact: whole_object_fidelity_blocked, safe_fallback: preserve_receiver, stop_if_required: true}
hard_mismatch_gates:
  - {scope: identity, reject_if: receiver_is_not_building_w1272162518_wall, proof_required: exact_metadata}
  - {scope: geometry, reject_if: sixth_story_or_any_massing_collision_spray_foundation_terrain_change, proof_required: exact_receiver_audit}
research_verdict: {ready_for_generation: true_for_material_prototypes_only, recommended_output_kind: homogeneous_material_tile, blockers: [exact_endpoints, module_dimensions, unobserved_ENE_SSE, terrace_geometry, six_vs_five_story_massing_conflict]}
```

## Final status

- Identity/receiver: **ready**.
- Material prototypes: **specification-ready**.
- WSW module vocabulary: **grammar-ready; physical scale blocked**.
- Exact unique layout: **blocked**.
- Whole-object claim: **blocked by six-story versus five-level invariant**.

# Oasis / 401 California Avenue facade reference specification

Checked: **2026-08-29**
Mode: **research and implementation handoff only**
Target: **`w291189918` / `building:w291189918:wall`**

## Handoff verdict

The frozen venue is **Oasis - pizzeria & event venue**, addressed **401 California Avenue, 94130**, on one irregular 34-run receiver. Official Sep 2025 Street View shows a distant low light building at the frozen footprint with medium-confidence WSW/SSE mapping, but no legible Oasis/restaurant/`401` identity. Whole-target authoring remains **blocked**. At most, a conservative warm-cream field prototype may proceed after an independent identity-to-footprint reconciliation. The generated `default_6m` height is not measured.

## Confirmed identity and receiver

Apply `verified_fact`, `reference_observation`, `production_inference`, and `unknown` labels.

| Item | Exact value | Status |
|---|---|---|
| Frozen name | Oasis - pizzeria & event venue | exact; currentness not claimed |
| Address | 401 California Avenue, 94130 | frozen number/street/postcode; no city/state added |
| Source/use | way `291189918`, version `2`, timestamp `2025-11-07T19:02:35Z`; `amenity=restaurant`, `cuisine=pizza` | exact tags; no facade truth |
| Height tags | no height or levels | exact absence; generator uses fallback |
| Logical/wall/roof | `building:w291189918`; `building:w291189918:wall`; `building:w291189918:roof` | exact |
| Chunk/runtime | `x_0__z_1`; `WorldRoot/PlayableWorld/Buildings/x_0__z_1__building_w291189918_wall/building_w291189918_wall` | exact naming derivation |
| Current materials | wall `plaster_grey_04`; roof `bitumen`; no target override | placeholder only |

### Generated contract and run topology

- Height rule `default_6m`, height `6 m`; base/top `3.630 / 9.630 m`; lowest foundation vertex `3.304 m`.
- Source area `1732.837 m²`; serialized perimeter `216.119 m`; generated wall `216.121 m`.
- Wall `34` foundation runs, `136` vertices / `68` triangles; roof `16` vertices / `14` triangles; no shared part walls.
- Facing totals: ENE `69.976 m`, SSE `38.096 m`, WSW `69.968 m`, NNW `38.081 m`. Multiple discontiguous/re-entrant groups share these normals; exact endpoints, not bucket labels, must drive any schedule.
- Wall is opaque `world_solid` spray receiver; roof is non-spray collider. U restarts every run.

## Provenance and coverage

| ID | Source | Supports | Excludes |
|---|---|---|---|
| `L01` | frozen OSM + receiver inventory/generated records, checked 2026-08-29 | exact frozen identity/address/use, missing height, receiver/scale | present branding, facade appearance |
| `SV` | `discovery/facades/BATCH_02_STREETVIEW_OBSERVATIONS.md`, Oasis section; checked 2026-08-29, capture Sep 2025 | distant low/light/dark hierarchy and medium-confidence footprint mapping | no imagery storage/reuse; no present identity/branding/opening counts/endpoints |

Exact official requests: `OAS-SV01` <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8190093,-122.3709789&heading=65&pitch=5&fov=72> (`wWF9QvLiOmqohwnoD77DTg`, distant likely WSW); `OAS-SV02` <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.81882,-122.37080&heading=55&pitch=4&fov=68> (`-pPwIOsi3zTgQd5N_VaeqQ`, distant WSW/SSE oblique). Both display **Sep 2025**. Avenue D had no usable official coverage. No imagery retained.

### Observed

- `mapping inference — medium confidence`: the low building across the fenced lot occupies the frozen footprint/orientation region; likely WSW (`242.0°-242.1°`) plus partial SSE return.
- Distant, apparently single-story profile behind trees/fence/paved lot; dominant light warm cream/off-white wall and dark grey-blue shallow roof/edge. Substrate/roof material unresolved.
- Central portion appears to contain a broad horizontal glazing/door field under a low dark fascia/canopy-like edge, flanked by opaque cream walls. Counts and continuity are unreadable.
- No `Oasis`, pizzeria, event-venue or `401` sign is legible. No brand color/artwork is established.
- Low profile does not numerically contradict a tall single-story/default `6 m` receiver and does not validate the fallback.

### Unobserved

ENE/rear, NNW, complete SSE, entrance/signage program, exact address-to-building association beyond the frozen join, openings/canopy dimensions and run endpoints remain unknown.

## Material/motif/scale and output status

| Region | Scope | Status |
|---|---|---|
| likely WSW / partial SSE | exact runs/endpoints unresolved; medium-confidence mapping | broad color/value hierarchy only |
| unobserved/service/rear | every other run | placeholder/no unique modules |
| foundation/roof | below `3.630`, top `9.630` | geometry-owned |

`production_inference` tentative cream-field band: value `0.70-0.86` linear, roughness `0.60-0.84`, matte/low-satin, no directional relief because substrate is unresolved. This is not target-ready until identity reconciliation. No facade repeat is proved; `OAS-CENTRAL-GLAZED` and `OAS-DARK-FASCIA` remain hypotheses, not modules. Exact physical scale is unavailable; default `6 m` is a game fallback only.

| Output | Status | Gate |
|---|---|---|
| `homogeneous_material_tile` | **conditional prototype only** | warm-cream field after independent footprint/identity reconciliation |
| `architectural_pattern_tile` | **blocked/rejected** | no period visible |
| `module_atlas` | **blocked** | glazing/door/fascia counts and identity unresolved |
| `unique_elevation` | **blocked** | distant occlusion, identity, three sides and endpoints |

Only legal seam now: uninterrupted light opaque field after identity reconciliation. Forbidden: central glazing/door field, possible fascia/canopy, roof edge, tree-obscured opening, corner, any sign area, U reset or re-entrant jump. Never mirror the distant layout.

## Godot BOM

| ID | Reserved path | Status |
|---|---|---|
| `MAT` | `res://game/resources/materials/world/oasis_401/oasis_primary.tres` | tentative cream field; blocked pending identity reconciliation |
| `MAT-SECONDARY` | `res://game/resources/materials/world/oasis_401/oasis_secondary.tres` | blocked |
| `MOD` | `res://game/scenes/world/facades/oasis_401/oasis_modules.tscn` | no supported complete motifs; blocked |
| `LAYOUT` | `res://game/resources/facades/oasis_401_california_layout.json` | exact-run dated schedule; blocked |
| `ATTACH` | `res://game/scenes/world/facades/oasis_401/oasis_facade.tscn` | render-only child; blocked |

## Geometry boundary and before -> after

Facade-owned after evidence: PBR fields and complete shallow visual modules. Excluded: replacing default height, story count, roof/silhouette, footprint/patio mass, deep opening/canopy geometry, collision, spray, terrain/foundation, navigation/access, generated data/source contracts.

```text
before: building:w291189918:wall is a default-6 m, 34-run opaque spray
        receiver using shared plaster_grey_04.

after:  that exact fallback-height wall, roof, footprint, runs, collision, spray
        owner, foundations, source ID and generated bytes remain unchanged;
        a later noncolliding child adds only capture-dated observed materials and
        complete modules on endpoint-mapped run chains, without claiming current
        branding or measured massing.
```

## Acceptance checklist

- [x] Exact panorama URL/ID/access and capture date/direction/coverage supports each visual/current-brand claim.
- [ ] Frozen name/address and capture-dated observed signage are kept separate.
- [ ] Exact target/path/chunk, default `6 m`, `34 / 216.121 m`, wall `68` and roof `14` triangles remain.
- [ ] Exact endpoints drive layout; no U reset/re-entrant same-normal jump creates phase.
- [ ] Sign letters and all modules remain complete; no motif is composed or changed at a seam.
- [ ] Render-only child adds no collision/navigation/spray ownership; underlying wall stays hit owner.
- [ ] No fallback-height, roof, silhouette, footprint, foundation, terrain, collision, spray or generated-data change.
- [ ] Reviewer labels the panorama capture date and separates facade language from current venue status and massing fidelity.

## Explicit blockers

- Distant broad hierarchy is observed, but present identity remains medium-confidence and no branding is legible.
- Current venue/name/signage cannot be claimed beyond panorama capture date.
- `default_6m` is not measured massing; whole-object fidelity remains limited.
- Patio/canopy/roof/sign/door/service grammar and dimensions are unknown.

## Normalized handoff

```yaml
schema_version: codex.building-texture-research/1
job: {job_id: oasis_401_california_facade_reference_spec, checked_date: 2026-08-29, intended_use: blocked_distant_observation_handoff, target_asset_kind: unique_elevation}
target: {canonical_name: Oasis - pizzeria & event venue / 401 California Avenue, local_object_ids: [w291189918, building:w291189918, building:w291189918:wall], identity_confidence: high, receiver_path: WorldRoot/PlayableWorld/Buildings/x_0__z_1__building_w291189918_wall/building_w291189918_wall}
sources:
  - {id: L01, authority: project, url_or_local_path: discovery/FACADE_RECEIVER_INVENTORY.json, checked_date: 2026-08-29, page_or_section: facade-receiver:w291189918, supports: [frozen_identity, address, missing_height, receiver, scale], does_not_support: [appearance, current_branding], image_reuse_permission: not_needed, stored_in_repo: false}
  - {id: SV, authority: secondary, url_or_local_path: discovery/facades/BATCH_02_STREETVIEW_OBSERVATIONS.md, checked_date: 2026-08-29, page_or_section: Oasis, supports: [distant_low_light_dark_hierarchy, medium_confidence_WSW_SSE_mapping], does_not_support: [present_identity, branding, openings, exact_endpoints, currentness_beyond_capture], image_reuse_permission: observation_only, stored_in_repo: false}
reference_roles: {identity_context: [L01], massing: [L01], pattern_region: [SV], cadence_and_seams: [SV], material_surface: [SV], scale: [L01, SV], rejection_example: []}
pattern_regions: [{region_id: LIKELY_WSW_SSE, local_scope: exact_runs_unreconciled_medium_identity_confidence, periodicity: unknown, must_not_share_tile_with: [UNOBSERVED_SIDES]}]
motif_inventory: []
motif_sequences: []
repeat_blueprint: {region_id: LIKELY_WSW_SSE, smallest_cell_status: unknown_no_period_visible, period_tokens_horizontal: null, period_tokens_vertical: null, period_m: {x: null, y: null}, cell_contents_full_motifs: [], edge_fragments: {left: [], right: [], top: [], bottom: []}, edge_compositions_expected: {left_plus_right: [], top_plus_bottom: [], corners: []}, legal_seam_zones: [uninterrupted_light_field_after_identity_reconciliation], forbidden_seam_zones: [generated_U_resets, reentrant_jumps, central_glazing, possible_fascia, signs, corners, tree_occluded_openings], fallback_if_not_proven: shared_placeholder}
material_brief: {surface_family: tentative_warm_cream_opaque_field_substrate_unknown, base_color: value_0.70_to_0.86_linear, finish: matte_to_low_satin, relief_direction_and_frequency: none_supported, roughness: 0.60_to_0.84, variation_and_weathering: unresolved, maps_requested: [albedo, roughness], maps_forbidden: [height_displacement, baked_lighting, photographic_reflections, invented_branding], tile_scale_status: blocked_by_identity, tile_scale_m: {x: null, y: null}}
excluded_architectural_features: [{feature: fallback_height_story_roof_silhouette_deep_canopy_or_patio, owner: geometry, reason: invariant}]
uncertainty:
  - {unknown: present_identity_branding_openings_and_exact_endpoints, impact: whole_target_authoring_blocked, safe_fallback: shared_placeholder, stop_if_required: true}
  - {unknown: measured_height, impact: whole_object_fidelity_limited, safe_fallback: preserve_default_6m, stop_if_required: true}
hard_mismatch_gates:
  - {scope: identity, reject_if: receiver_is_not_building_w291189918_wall, proof_required: exact_metadata}
  - {scope: evidence, reject_if: branding_is_claimed_current_beyond_capture_date, proof_required: dated_panorama_ledger}
  - {scope: geometry, reject_if: height_roof_collision_spray_foundation_or_generated_contract_changes, proof_required: exact_receiver_audit}
research_verdict: {ready_for_generation: false, recommended_output_kind: null, blockers: [identity_to_footprint_reconciliation, distant_occlusion, no_legible_branding, exact_endpoints, unobserved_sides, default_6m_massing_unknown]}
```

## Final status

- Frozen identity/receiver: **ready**.
- Whole-target facade and all modules/current branding: **blocked**.
- Conditional warm-cream material prototype: **not target-ready until identity reconciliation**.

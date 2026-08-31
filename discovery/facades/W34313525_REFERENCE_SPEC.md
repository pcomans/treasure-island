# `w34313525` facade reference specification

Checked: **2026-08-29**
Target: **unnamed `w34313525` / `building:w34313525:wall`**
Mode: **research and implementation handoff only**

## Receiver-first verdict

Two March 2025 official views identify opposite long chains of the coordinate-matched one-storey industrial/service complex and support an aged pale field plus complete roll-up door, personnel door and high-window/grille modules. Opening sequence is irregular, repair patches are nonperiodic, and the projecting eave/rafters are geometry-owned. ENE/WSW ends, deep re-entrants, exact chain ownership and physical scale remain blocked.

## Exact identity and receiver

| Item | Exact local evidence |
|---|---|
| Source | OSM way `34313525`, v4, `2018-01-22T18:55:35Z`; `building=yes`, `height=5`, `building:levels=1`, historic `source=Yahoo`; no name/address/use |
| Objects/chunk | logical `building:w34313525`; wall `building:w34313525:wall`; roof `building:w34313525:roof`; `x_1__z_-1` |
| Meters | area `6,959.954 m²`; serialized/visible perimeter `354.736 / 354.736 m`; height/base/top `5 / 3.711 / 8.711 m` |
| Topology | `30` exterior runs, no shared runs; ENE `9/63.061 m`; SSE `9/114.306`; WSW `6/63.063`; NNW `6/114.306` |
| Runtime | wall `building_wall -> plaster_grey_04`, opaque/sole spray receiver; roof `building_roof -> bitumen`, opaque collider/non-spray |

## Provenance and coverage

| Evidence ID | Exact official source | Coverage / limit |
|---|---|---|
| `B06-W34313525-SV01` | [pano `UvBZHe3Bqcdd_bfgw5ML5A`](https://www.google.com/maps/@?api=1&map_action=pano&pano=UvBZHe3Bqcdd_bfgw5ML5A&heading=153&pitch=2&fov=78), actual `37.8250217,-122.3677734`, SE, **March 2025** | NNW-facing/inset service elevation |
| `B06-W34313525-SV02` | [pano `wqlnQ3qiVXNBEqONq51bXA`](https://www.google.com/maps/@?api=1&map_action=pano&pano=wqlnQ3qiVXNBEqONq51bXA&heading=0&pitch=2&fov=78), actual `37.8242289,-122.3676035`, north, **March 2025** | opposite SSE public/service elevation; displayed `750 6th St` is camera context, not target address |
| `B06-LOCAL-W34313525` | [`FACADE_RECEIVER_INVENTORY.json`](../FACADE_RECEIVER_INVENTORY.json), [`NEXT_FACADE_BATCH_06.md`](NEXT_FACADE_BATCH_06.md), [`BATCH_06_STREETVIEW_OBSERVATIONS.md`](BATCH_06_STREETVIEW_OBSERVATIONS.md) | exact local contract plus observation bounds |

Observed: substantial NNW/inset and SSE chains. Unobserved/ambiguous: ENE/WSW ends, deep re-entrants, exact corners/endpoints. Footprint identity is high; chain ownership and canonical name/use remain unresolved. No imagery is stored.

## Material regions, physical scale and complete motifs

- `W34313525-MAT-PALE`: aged pale warm off-white/light-gray smooth painted masonry/render/panel-like field, matte; only subordinate nonsemantic wear.
- `W34313525-REPAIR`: broad irregular gray repaint/repair areas are target condition regions, never a repeating stain/tile.
- `W34313525-ROLLUP-PALE` and `ROLLUP-GRAY`: one complete roll-up opening, full outer frame, full slat field and uninterrupted surrounding wall; distinct visible colors/states stay separate.
- `W34313525-PERSONNEL`: one complete plain gray/pale service door with full frame/surround.
- `W34313525-HIGH-GROUP`: one complete high horizontal window or grille group with full dark frame and surrounding wall.

The one-storey/5 m receiver is broadly compatible, not dimensional facade evidence. Door/window/grille dimensions, slat/course pitch, alternates, repair bounds and field grain scale are unknown. The shallow projecting roof/eave/canopy with visible rafters/joists is geometry/edge work, not a wall tile or shallow coplanar module.

| Output | Status |
|---|---|
| `homogeneous_material_tile` | **reference-ready, scale-calibration required** for pale aged field; repair patches excluded |
| `architectural_pattern_tile` | **blocked**; opening widths/sequences vary and eave cadence is geometry-owned |
| `module_atlas` | **reference-ready, placement/scale-blocked** for complete roll-up/personnel/high groups |
| `unique_elevation` | **two-side concept-ready, footprint-mapping-blocked** |

Legal seams: uninterrupted pale field or full outer boundary of a complete door/window/grille module. Forbidden: U reset; roll-up slats/frame; personnel door; glazing/grille; repair boundary; projecting eave/rafter/roof edge; corner/re-entrant; utility/sign/yard clutter; occlusion. Edge products must reconstruct complete motifs, never partial doors/windows.

Do not repeat repair patches as camouflage, regularize a door grid, copy signs/numbers/vehicles/yard objects, flatten eaves/rafters, infer hidden ends, or transfer neighboring industrial modules.

## Reserved Godot BOM and geometry boundary

| ID | Planned path / status |
|---|---|
| `MAT` | `res://game/resources/materials/world/w34313525/` — pale field and separate door/frame studies |
| `ATLAS/MOD` | `res://game/resources/textures/buildings/w34313525/w34313525_modules`; `res://game/scenes/world/facades/w34313525/w34313525_modules.tscn` — complete openings only |
| `LAYOUT/ATTACH` | `res://game/resources/facades/w34313525_layout.json`; `res://game/scenes/world/facades/w34313525/w34313525_facade.tscn` — blocked |

```text
before: building:w34313525:wall is the exact 5 m/one-level, 30-run spray receiver.
after:  source/height/story/silhouette/roof/eave geometry/footprint/foundation,
        terrain/topology/collision/navigation/spray and generated data remain;
        only accepted shallow visuals may attach after exact chain mapping.
```

## Acceptance gates and blockers

- [ ] Preserve `30 / 354.736 m`, `5 m / 1`, base/top, chunk, no-shared-run and roles.
- [ ] Calibrate material/slat/module scale at exact receiver before acceptance.
- [ ] Keep repair shapes localized/nonrepeating and every atlas motif complete.
- [ ] Keep eave/rafters, ramps, bollards and yard objects out of wall textures/modules.
- [ ] Reconcile irregular footprint endpoints before any placement; hidden ends/re-entrants stay placeholder.
- [ ] Whole-object recognition is reviewed separately and remains blocked by incomplete coverage/massing detail.

Prototype: **bounded-ready**. Live: **blocked**. Whole object: **reference/placement-blocked**.

```yaml
schema_version: codex.building-texture-research/1
target: {canonical_name: null, id: w34313525, receiver: 'building:w34313525:wall', identity_confidence: high_coordinate_match}
sources: [B06-LOCAL-W34313525, B06-W34313525-SV01, B06-W34313525-SV02]
observed_regions: [NNW_inset_service, SSE_public_service]
unobserved_regions: [ENE_end, WSW_end, deep_reentrants, exact_corners_endpoints]
outputs: {homogeneous_material_tile: reference_ready_scale_blocked, architectural_pattern_tile: blocked, module_atlas: reference_ready_placement_scale_blocked, unique_elevation: two_side_concept_ready_mapping_blocked}
smallest_cell: {status: nonperiodic_complete_modules, modules: [W34313525-ROLLUP-PALE, W34313525-ROLLUP-GRAY, W34313525-PERSONNEL, W34313525-HIGH-GROUP]}
legal_seams: [uninterrupted_pale_field, complete_module_outer_boundary]
forbidden_seams: [generated_U_reset, rollup_slats_frame, door, glazing_grille, repair_boundary, eave_rafter, roof_edge, corner_reentrant, utility_sign_occlusion]
research_verdict: {ready_for_generation: true, ready_subset: [aged_pale_field_scale_study, complete_opening_atlas_study], ready_for_attachment: false, blockers: [physical_scale_unknown, irregular_sequence, exact_chain_mapping_missing, hidden_ends_reentrants]}
```

# `w34313564` facade reference specification

Checked: **2026-08-29**
Target: **unnamed `w34313564` / `building:w34313564:wall`**
Mode: **research and implementation handoff only**

## Receiver-first verdict

Three September 2025 official views identify SSE, NNW and ENE sides of the coordinate-matched low industrial/workshop footprint. They establish a side-specific tan SSE field, separate pale NNW/ENE field, pale plinth and bounded horizontal-window/personnel-door modules. WSW, exact endpoints, physical scale and heavily occluded sequences remain unknown. Separate material/module prototypes are bounded-ready; architectural repeat, attachment and whole-object acceptance are blocked.

## Exact identity and receiver

| Item | Exact local evidence |
|---|---|
| Source | OSM way `34313564`, v3, `2018-01-22T18:58:54Z`; `building=yes`, `height=5`, historic `source=Yahoo`; no name/address/use/levels |
| Objects/chunk | logical `building:w34313564`; wall `building:w34313564:wall`; roof `building:w34313564:roof`; `x_0__z_-3` |
| Meters | area `4,252.864 m²`; serialized/visible perimeter `282.680 / 282.680 m`; height/base/top `5 / 3.752 / 8.752 m` |
| Topology | `20` exterior runs, no shared runs; ENE `4/43.442 m`; SSE `6/97.899`; WSW `4/43.441`; NNW `6/97.898` |
| Runtime | wall `building_wall -> plaster_grey_04`, opaque/sole spray receiver; roof `building_roof -> bitumen`, opaque collider/non-spray |

## Provenance and observed sides

| Evidence ID | Exact official source | Coverage / limit |
|---|---|---|
| `B06-W34313564-SV01` | [pano `z7JOW1qm_DGB3FXeBE7oHw`](https://www.google.com/maps/@?api=1&map_action=pano&pano=z7JOW1qm_DGB3FXeBE7oHw&heading=0&pitch=2&fov=78), actual `37.8291186,-122.3703179`, north, **September 2025** | broad SSE long elevation |
| `B06-W34313564-SV02` | [pano `7GUI5RM_iDh47j88zam-QQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=7GUI5RM_iDh47j88zam-QQ&heading=180&pitch=2&fov=78), actual `37.8299288,-122.3705773`, south, **September 2025** | NNW long elevation, heavily occluded |
| `B06-W34313564-SV03` | [pano `UUw64NHfqJrDCbPV7I_vvQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=UUw64NHfqJrDCbPV7I_vvQ&heading=270&pitch=2&fov=78), actual `37.8294143,-122.3697845`, west, **September 2025** | ENE short end plus SSE return |
| `B06-LOCAL-W34313564` | [`FACADE_RECEIVER_INVENTORY.json`](../FACADE_RECEIVER_INVENTORY.json), [`NEXT_FACADE_BATCH_06.md`](NEXT_FACADE_BATCH_06.md), [`BATCH_06_STREETVIEW_OBSERVATIONS.md`](BATCH_06_STREETVIEW_OBSERVATIONS.md) | exact local contract plus observation bounds |

Observed: SSE, NNW and ENE. Unobserved: WSW, some corner/yard transitions and exact endpoints. Footprint identity is high; displayed `710 13th St`, `14th St` and Avenue M are camera context, not frozen target addresses. No imagery is stored.

## Material hierarchy, scale and complete motifs

- `W34313564-MAT-TAN`: muted ochre/tan smooth painted masonry/render/panel-like SSE field, matte.
- `W34313564-MAT-PALE`: off-white/light-gray NNW/ENE field. The strong side difference is preserved as a separate region, not normalized as lighting.
- `W34313564-MAT-PLINTH`: pale off-white/gray raised base/plinth, independently bounded.
- `W34313564-HWIN`: one full dark-brown/gray horizontal multi-pane window group with complete frame and uninterrupted surround.
- `W34313564-PDOOR`: one full plain pale/gray personnel door, frame and surround.
- `W34313564-PIPE`: visible pipe/vent cluster may become one unique module only after exact placement; it is never repeatable.

The low one-storey read is broadly compatible with the `5 m` receiver, not a measured level contract. Window/door/plinth dimensions, pane pitch, spacing, material grain and finish scale are unknown. Ramps, stairs, rails, landings and projecting eave/roof edge are geometry/props, not wall texture.

| Output | Status |
|---|---|
| `homogeneous_material_tile` | **reference-ready, scale-calibration required** for separate tan, pale and plinth fields |
| `architectural_pattern_tile` | **blocked**; window spacing/door interruptions and side-color change defeat a proven cell |
| `module_atlas` | **reference-ready, placement/scale-blocked** for complete window/door; pipe cluster unique-only |
| `unique_elevation` | **SSE/NNW/ENE concept-ready, mapping-blocked**; WSW absent |

Legal seams: uninterrupted same-color field, uninterrupted plinth, or complete opening-module outer boundary. Forbidden: U reset; window/door; plinth transition; pipe/vent; eave/roof edge; corner; ramp/stair/rail overlap; fence/container/vehicle/vegetation; color transition. Every boundary product must stay within one material family or reassemble the same complete motif.

Do not merge tan/pale sides, bake ramps/rails/containers into wall art, repeat pipes, infer WSW, or transfer `w291196370` material/modules.

## Reserved Godot BOM and geometry boundary

| ID | Planned path / status |
|---|---|
| `MAT` | `res://game/resources/materials/world/w34313564/` — tan, pale and plinth fields |
| `ATLAS/MOD` | `res://game/resources/textures/buildings/w34313564/w34313564_modules`; `res://game/scenes/world/facades/w34313564/w34313564_modules.tscn` |
| `LAYOUT/ATTACH` | `res://game/resources/facades/w34313564_layout.json`; `res://game/scenes/world/facades/w34313564/w34313564_facade.tscn` — blocked |

```text
before: building:w34313564:wall is the exact 5 m, 20-run placeholder spray receiver.
after:  source/height/silhouette/roof/footprint/plinth and access geometry/foundation,
        terrain/topology/collision/navigation/spray/generated contracts remain;
        only side-correct accepted shallow visuals may later attach after mapping.
```

## Acceptance gates and blockers

- [ ] Preserve `20 / 282.680 m`, `5 m`, base/top, chunk, no-shared-run and material roles.
- [ ] Keep tan SSE, pale NNW/ENE and plinth as separate propagation regions.
- [ ] Calibrate physical scale and preserve complete window/door boundaries.
- [ ] Exclude WSW, occluded bounds and geometry/yard objects.
- [ ] Exact ordered endpoints precede placement; U resets/normals do not authorize cadence.
- [ ] Whole-object review remains separate; three-side material evidence is not whole-building acceptance.

Prototype: **bounded-ready**. Live: **blocked by scale/endpoints/WSW**. Whole object: **reference/placement-blocked**.

```yaml
schema_version: codex.building-texture-research/1
target: {canonical_name: null, id: w34313564, receiver: 'building:w34313564:wall', identity_confidence: high_coordinate_match}
sources: [B06-LOCAL-W34313564, B06-W34313564-SV01, B06-W34313564-SV02, B06-W34313564-SV03]
observed_regions: [SSE_tan, NNW_pale, ENE_pale]
unobserved_regions: [WSW, occluded_corner_yard_transitions, exact_endpoints]
outputs: {homogeneous_material_tile: reference_ready_scale_blocked, architectural_pattern_tile: blocked, module_atlas: reference_ready_placement_scale_blocked, unique_elevation: three_side_concept_ready_mapping_blocked}
smallest_cell: {status: nonperiodic_complete_modules, modules: [W34313564-HWIN, W34313564-PDOOR, W34313564-PIPE]}
legal_seams: [uninterrupted_same_color_field, uninterrupted_plinth, complete_opening_boundary]
forbidden_seams: [generated_U_reset, window, door, plinth_transition, pipe_vent, eave_roof_edge, corner, access_geometry, occlusion, color_transition]
research_verdict: {ready_for_generation: true, ready_subset: [tan_pale_plinth_scale_studies, complete_window_door_atlas_study], ready_for_attachment: false, blockers: [physical_scale_unknown, endpoint_mapping_missing, WSW_unobserved, NNW_occlusion]}
```

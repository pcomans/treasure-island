# 1318 Gateview Avenue facade reference specification

Checked: **2026-08-29**  
Target: **unnamed residential `w95934092` / `building:w95934092:wall`**  
Mode: **research and implementation handoff only**

## Verdict

The frozen address/use and footprint are high-confidence. March and November 2025 official views cover the front long elevation/end and rear long elevation, supporting a **target-specific siding material set and front/rear/end module atlas**. Google displays `1327` across the street, not on the target. Exact unit-to-run placement is blocked until the 26-run reentrant chain is reconciled; small returns/endpoints remain unknown.

## Exact identity and receiver

| Item | Exact value |
|---|---|
| Source | unnamed residential building, 1318 Gateview Avenue; way `95934092`, v5, `2020-07-09T13:50:42Z`; levels `2`, height `6 m` |
| IDs/path | `building:w95934092`; wall `building:w95934092:wall`; roof `building:w95934092:roof`; chunk `x_-3__z_-2`; `WorldRoot/PlayableWorld/Buildings/x_-3__z_-2__building_w95934092_wall/building_w95934092_wall` |
| Contract | base/top `2.522 / 8.522 m`; lowest `2.116`; area `734.700 m²`; serialized/visible `163.715 / 163.714 m` |
| Mesh/groups | wall `26` runs `104v/52tri`; roof `16v/14tri`; ENE `62.7° 5/47.512`; SSE `152.6° 2/7.357`, `152.7° 4/26.993`; WSW `242.7° 11/47.508`; NNW `332.7° 4/34.343` m |
| Roles | wall `plaster_grey_04`, opaque `world_solid`, sole spray receiver; roof `bitumen`, opaque collider/non-spray |

## Provenance and coverage

| ID | Exact official source | Coverage |
|---|---|---|
| `1318-SV-FRONT` | [request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8267942,-122.3776632&heading=126&pitch=0&fov=75); pano `qGPa9ZjJlrtlQpnP52eiAA`; actual `37.8267503,-122.3776812`; **Mar 2025**; southeast `126°` | public/front long elevation and end |
| `1318-SV-REAR` | [request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8266681,-122.3770043&heading=245&pitch=0&fov=75); pano `GmuTsOm1-FO47a4FOWEQHA`; actual `37.8266407,-122.3769985`; **Nov 2025**; southwest `245°` | rear long elevation |

Small returns and exact endpoints are unobserved. No imagery was stored or redistributed.

## Facts, inference and unknowns

Observed: two-storey attached-townhouse facade; light cool gray-blue horizontal siding; white trim, gutters and downspouts; muted-brown low gable roof. Front units use upper sliders and ground door/front-window/privacy-enclosure combinations under a shallow multi-bay porch canopy with gable accents and posts. The end gable has stacked windows. Rear units have upper sliders; lower zones are partly hidden by fences. Trellis/add-on conditions are excluded from the base family.

Reversible PBR/scale estimates: siding reflectance `45–65%`, roughness `0.65–0.85`, course `0.12–0.22 m`; white trim `70–90%`, roughness `0.55–0.78`; roof `20–35%`, roughness `0.80–0.95`; glazing `0.12–0.28`; candidate unit width `3.5–5.5 m`, **low confidence**. Exact unit widths/counts, door alternation, lower rear grammar, endpoint ownership and porch projection are unknown.

## Output classification and seam grammar

| Output | Status / smallest cell |
|---|---|
| `homogeneous_material_tile` | **reference-ready** for gray-blue siding, white trim and muted roof fields |
| `architectural_pattern_tile` | **blocked**; attached units vary and complete cyclic period is not proven |
| `module_atlas` | **reference-ready, placement-blocked**: `1318-FRONT-UNIT`, `1318-REAR-UNIT`, unique `1318-END-GABLE`, `1318-SOLID-SIDING`; preserve each complete unit/opening group |
| `unique_elevation` | **reference-ready in sequence concept, placement-blocked** by exact unit/run mapping and small returns |

Legal seams: homogeneous siding and confirmed complete unit boundaries. Forbidden: window/door, canopy/gable/post, privacy wing, end-gable motif, gutter/downspout, corner/reentrant return, top/foundation or U reset. Never transfer modules to 1212 Mariner: it lacks this pronounced porch-canopy grammar.

## Godot BOM

| ID | Planned role |
|---|---|
| `MAT-SIDING`, `MAT-WHITE`, `MAT-ROOF`, `MAT-GLASS` | `res://game/resources/materials/world/1318_gateview/`; target-specific PBR materials |
| `ATLAS-UNITS` | `res://game/resources/textures/buildings/1318_gateview/1318_gateview_modules`; complete front/rear/end RGBA modules/maps |
| `MOD-UNIT`, `MOD-END`, `MOD-CANOPY` | `res://game/scenes/world/facades/1318_gateview/1318_gateview_modules.tscn`; shallow noncolliding render geometry only |
| `LAYOUT` | `res://game/resources/facades/1318_gateview_layout.json`; blocked pending ordered endpoint map |
| `ATTACH` | `res://game/scenes/world/facades/1318_gateview/1318_gateview_facade.tscn`; later visual child |

## Invariant example

```text
before: building:w95934092:wall is the 6 m/two-level, 26-run spray receiver.
after:  the same receiver, story count, silhouette, roof, footprint, structural
        openings, topology, foundation, physics, spray, terrain and source/generated
        contracts remain; complete target-specific visual modules attach only after mapping.
```

## Acceptance gates

- [ ] Reviewer opens both 2025 sources and confirms front/end vs rear coverage and that `1327` labels the opposite building.
- [ ] Target-specific porch-canopy grammar is not shared with 1212 Mariner.
- [ ] IDs/path/chunk, `6 m / 2`, `26 / 163.714 m`, wall `52` and roof `14` triangles remain.
- [ ] Every atlas cell contains complete unit/opening trim; fences/trellises are not baked as architecture.
- [ ] Ordered source endpoints map units before placement; reentrant/small returns and U resets never set cadence.
- [ ] No massing, structural opening, collider/navigation/spray/generated change.

```yaml
schema_version: codex.building-texture-research/1
target: {id: w95934092, receiver: 'building:w95934092:wall', identity_confidence: high}
sources: [L01, 1318-SV-FRONT, 1318-SV-REAR]
observed_regions: [front_long, front_end, rear_long]
unobserved_regions: [small_returns, exact_endpoints, lower_rear_behind_fences]
outputs: {homogeneous_material_tile: reference_ready, architectural_pattern_tile: blocked, module_atlas: reference_ready_placement_blocked, unique_elevation: sequence_reference_ready_placement_blocked}
smallest_cell: {status: variable_complete_unit, modules: [1318-FRONT-UNIT, 1318-REAR-UNIT, 1318-END-GABLE, 1318-SOLID-SIDING]}
legal_seams: [homogeneous_siding, verified_complete_unit_boundary]
forbidden_seams: [opening, canopy, gable_accent, post, privacy_wing, end_gable, gutter, downspout, corner, generated_U_reset]
research_verdict: {ready_for_generation: true, ready_subset: [materials, unit_module_atlas, sequence_plan], ready_for_attachment: false}
```

## Final status

- Target-specific materials/modules/sequence concept: **implementation-ready**.
- Exact attachment: **blocked by unit-to-run mapping and small-return ownership**.

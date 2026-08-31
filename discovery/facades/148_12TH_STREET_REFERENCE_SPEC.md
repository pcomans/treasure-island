# 148 12th Street facade reference specification

Checked: **2026-08-29**  
Target: **unnamed `w95934119` / `building:w95934119:wall`**  
Mode: **research and implementation handoff only**

## Receiver-first verdict

The frozen address and two March 2025 official views establish the compact footprint with high confidence. The long north elevation supports aged horizontal-cladding material and complete clerestory-group research; lower facade, south/east sides and exact endpoints remain blocked by foreground walls, gates, containers and vehicles.

## Exact identity and receiver

| Item | Exact local evidence |
|---|---|
| Source | way `95934119`, v5, `2026-04-23T18:34:33Z`; `building=yes`, height `5 m`; no levels/name/use |
| IDs/path | `building:w95934119`; wall `building:w95934119:wall`; roof `building:w95934119:roof`; chunk `x_-2__z_-1`; `WorldRoot/PlayableWorld/Buildings/x_-2__z_-1__building_w95934119_wall/building_w95934119_wall` |
| Meters | base/top `2.507 / 7.507`; lowest foundation `2.152`; area `1099.411 m²`; serialized/visible `140.054 / 140.054 m` |
| Mesh/groups | wall `14` runs `56v/28tri`; roof `4v/2tri`; ENE `62.5° 3/23.765`; SSE `152.5° 4/46.262`; WSW `242.5° 3/23.765`; NNW `332.5° 4/46.262` m |
| Materials/roles | wall `plaster_grey_04`, opaque `world_solid`, sole spray receiver; roof `bitumen`, opaque collider/non-spray; no shared parts |

## Provenance and coverage

| ID | Exact official source | Coverage |
|---|---|---|
| `148-12-SV01` | [request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8256201,-122.3758225&heading=174&pitch=0&fov=75); pano `FdRJYtmB5yaqpgv76DvtMg`; actual `37.8256327,-122.3758242`; **March 2025**; south `174°` | long north-facing elevation |
| `148-12-SV02` | [request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8253306,-122.3761412&heading=82&pitch=0&fov=75); pano `o5S-wBfoGnE8GtfVFrTVMA`; actual `37.8253514,-122.3761863`; **March 2025**; east `82°` | west end and long-side return |

South/east elevations and exact endpoints are unobserved. No imagery is retained.

## Facts, materials, modules and seams

Observed: one low industrial/storage storey with near-flat/shallow roof; aged light-gray/off-white horizontal cladding/siding with dark streaking, peeling and uneven repainting; nearly continuous upper clerestory of many small rectangular panes in pale frames; varying group widths and dark/opaque/aged panes. Lower facade is largely hidden. One oblique dark service/roll-up-like opening lacks a complete boundary and is not a module. Foreground block wall, chain-link, containers, vehicles and trees are excluded.

Reversible inference: light field reflectance `45–70%`, roughness `0.72–0.92`, cladding course `0.12–0.25 m`; pale frame `60–80%`, roughness `0.55–0.78`; glazing roughness `0.15–0.35`; candidate clerestory group width `1.5–4 m`, low confidence. Substrate, lower openings, pane states, physical period and side mapping remain unknown.

Complete modules: `148-12-CLERESTORY-BAY` is one full clerestory group with frame and surrounding cladding; `148-12-SOLID` is uninterrupted aged cladding with low-frequency nonsemantic weathering. Missing/dark panes are condition variants, not repeat tokens.

| Output | Status / rationale |
|---|---|
| `homogeneous_material_tile` | **reference-ready** for aged horizontal field; avoid semantic damage repetition |
| `architectural_pattern_tile` | **blocked** because group widths/pane states do not prove a complete period |
| `module_atlas` | **reference-ready, placement-blocked** for complete clerestory groups and solid field |
| `unique_elevation` | **north-sequence reference-ready, placement-blocked**; lower/south/east/endpoint evidence absent |

Legal seams: uninterrupted cladding or verified complete clerestory-group boundary. Forbidden: U reset, glazing/frame, roof edge, possible service opening, corner, foreground wall/gate/container, or a weathering cut that changes an opening.

## Reserved Godot BOM

| ID | Planned path / status |
|---|---|
| `MAT-AGED`, `MAT-FRAME`, `MAT-GLASS` | `res://game/resources/materials/world/148_12th_street/` — reference-ready fields |
| `ATLAS` | `res://game/resources/textures/buildings/148_12th_street/148_12th_street_modules` — clerestory/solid atlas |
| `MOD` | `res://game/scenes/world/facades/148_12th_street/148_12th_street_modules.tscn` — shallow noncolliding modules |
| `LAYOUT` | `res://game/resources/facades/148_12th_street_layout.json` — blocked pending endpoints/lower facade |
| `ATTACH` | `res://game/scenes/world/facades/148_12th_street/148_12th_street_facade.tscn` — blocked visual child |

## Boundary and invariant example

```text
before: building:w95934119:wall is the 5 m, 14-run opaque spray receiver.
after:  exact height, silhouette, roof, footprint, openings, runs, foundation,
        terrain, physics, spray, OSM and generated contracts remain; only observed
        complete render-only fields/modules may later attach to ordered endpoints.
```

## Acceptance gates

- [ ] Exact official provenance and observed/unobserved sides precede appearance claims.
- [ ] IDs/path/chunk, `5 m`, `14 / 140.054 m`, wall `28` and roof `2` triangles remain.
- [ ] Observed one-storey reading is recorded as observation, not a source-level change; no name/use is invented.
- [ ] Ordered endpoints—not four equal/opposing groups or U resets—drive placement.
- [ ] Dark/missing panes and streaking remain nonperiodic condition variation; lower obstruction is not baked.
- [ ] Visual children add no collider/navigation/spray role; massing/source/generated data remain unchanged.

```yaml
schema_version: codex.building-texture-research/1
target: {id: w95934119, receiver: 'building:w95934119:wall', identity_confidence: high}
sources: [L01, 148-12-SV01, 148-12-SV02]
observed_regions: [north_long, west_end_and_return]
unobserved_regions: [south, east, lower_facade_behind_foreground, exact_endpoints]
outputs: {homogeneous_material_tile: reference_ready, architectural_pattern_tile: blocked, module_atlas: reference_ready_placement_blocked, unique_elevation: north_sequence_reference_ready_placement_blocked}
smallest_cell: {status: complete_module_only, modules: [148-12-CLERESTORY-BAY, 148-12-SOLID]}
legal_seams: [uninterrupted_cladding, verified_complete_clerestory_boundary]
forbidden_seams: [generated_U_reset, glazing, frame, roof_edge, possible_service_opening, corner, foreground_wall_gate_container, semantic_weathering_cut]
research_verdict: {ready_for_generation: true, ready_subset: [aged_material, clerestory_atlas, north_sequence_plan], ready_for_attachment: false, blockers: [lower_facade_occluded, south_east_unobserved, physical_scale_low_confidence, endpoint_mapping_missing]}
```

## Final status

- Aged material/clerestory prototypes: **implementation-ready**.
- Whole elevation/live attachment: **blocked by lower/south/east coverage and endpoint mapping**.

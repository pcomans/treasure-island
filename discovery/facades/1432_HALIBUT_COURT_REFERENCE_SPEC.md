# 1432 Halibut Court facade reference specification

Checked: **2026-08-29**  
Target: **unnamed `w95934093` / `building:w95934093:wall`**  
Mode: **research and implementation handoff only**

## Receiver-first verdict

The frozen footprint has a strong lifecycle conflict: March 2025 shows an empty grass/concrete-pad site, while official May 2011 imagery shows a two-storey garage/residential block at the footprint. Historical front specification is defensible only for an explicitly frozen-era representation; current facade authoring and attachment are blocked by removal.

## Exact identity and receiver

| Item | Exact local evidence |
|---|---|
| Source | way `95934093`, v4, `2020-07-09T13:50:42Z`; `building=yes`, height `6 m`; no name/use/levels |
| IDs/path | `building:w95934093`; wall `building:w95934093:wall`; roof `building:w95934093:roof`; chunk `x_-2__z_-1`; `WorldRoot/PlayableWorld/Buildings/x_-2__z_-1__building_w95934093_wall/building_w95934093_wall` |
| Meters | base/top `2.771 / 8.771`; lowest foundation `2.679`; area `475.327 m²`; serialized/visible `110.807 / 110.809 m` |
| Mesh | wall `18` runs `72v/36tri`; roof `12v/10tri`; standalone/no shared parts |
| Normal groups | ENE `63.6° 3/8.759`, `63.7° 2/13.786`; SSE `153.6° 2/22.656`, `153.7° 2/10.209`; WSW `243.7° 5/22.548`; NNW `333.6° 1/3.464`, `333.7° 2/25.380`, `333.8° 1/4.008` m |
| Roles | wall `plaster_grey_04`, opaque `world_solid`, sole spray receiver; roof `bitumen`, opaque collider/non-spray |

## Provenance and temporal coverage

Both views use [this official request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8247278,-122.3751386&heading=14&pitch=0&fov=75).

| ID | Panorama/date | Coverage |
|---|---|---|
| `1432H-SV01-current` | `VVYoE1kb2gHZtUgVXqLkWA`; actual `37.8247226,-122.3751776`; **March 2025**; north `14°` | frozen footprint is empty grass/concrete-pad area; no standing target |
| `1432H-SV02-historical` | `TIe_SHu9hj0VKcEz2bBI7g`; actual `37.8247100,-122.3751972`; **May 2011**; north `14°` | former south/front elevation and west end |

Google displayed 1431 across the court; historical footprint identity is medium-high. Rear/north, east end, dimensions and endpoints are unobserved. No imagery is stored.

## Historical facts, materials, modules and seams

May 2011: two-storey block; cream/off-white smooth stucco/render upper field with sparse dark horizontal windows; base of three muted salmon/dusty-red garage doors separated by red-brown brick piers/fields; white external metal stair to recessed upper entry/balcony with warm red-brown walls/door; muted gray-brown hipped roof with white eave/gutter. Stair, balcony/recess, garage openings and roof are geometry-owned. Upper openings are sparse/asymmetric; no global period.

Reversible inference: cream reflectance `60–80%`, roughness `0.72–0.90`; red-brown brick `20–40%`, roughness `0.78–0.94`, unit scale unknown; salmon doors `30–50%`, roughness `0.60–0.82`; candidate garage opening width `2.4–3.2 m`, low confidence. Exact products/dimensions are unknown.

`1432H-FRONT-BLOCK` is the entire three-garage/stair/upper-entry composition as a unique elevation, never a repeat; `1432H-UPPER-WIN` is one complete window/surround; `1432H-CREAM-FIELD` and `1432H-BRICK-FIELD` are homogeneous regions.

| Output | Status |
|---|---|
| `homogeneous_material_tile` | **historical reference-ready** for cream/brick/door fields |
| `architectural_pattern_tile` | **blocked**; asymmetric block has no period |
| `module_atlas` | **historical reference-ready, placement-blocked** for complete upper window/fields; garage/stair not shallow modules |
| `unique_elevation` | **historical front reference-ready, attachment-blocked** by lifecycle choice/endpoints/unobserved sides |

Legal seams: uninterrupted cream/brick or full outer boundary of unique front block. Forbidden: U reset, garage/brick pier/stair/rail/balcony/recess/entry/window/eave/hip/corner. No current facade may be invented.

## Reserved Godot BOM

| ID | Planned path / status |
|---|---|
| `MAT` | `res://game/resources/materials/world/1432_halibut/` — historical cream/brick/door fields |
| `ATLAS` | `res://game/resources/textures/buildings/1432_halibut/1432_halibut_modules` — historical upper-window/field atlas |
| `MOD` | `res://game/scenes/world/facades/1432_halibut/1432_halibut_modules.tscn` — shallow upper-window only; garage/stair blocked as geometry |
| `LAYOUT` | `res://game/resources/facades/1432_halibut_layout.json` — ordered endpoints required |
| `ATTACH` | `res://game/scenes/world/facades/1432_halibut/1432_halibut_facade.tscn` — later visual child |

## Boundary and invariant example

```text
before: building:w95934093:wall is the 6 m, 18-run opaque spray receiver.
after:  exact height, silhouette, roof, footprint, openings, topology, foundation,
        terrain, physics, spray, OSM and generated contracts remain; no use/story
        is invented and only observed complete visuals may later attach.
```

## Acceptance gates

- [ ] Every output is labelled **May 2011 historical**; reviewer confirms the March 2025 empty site and 1431-across-court label.
- [ ] IDs/path/chunk, `6 m`, `18 / 110.809 m`, wall `36` and roof `10` triangles remain.
- [ ] No residential use/level/family is inferred from address or adjacency.
- [ ] Garage/stair/balcony/recess/hip remain geometry-owned; no current facade is fabricated.
- [ ] Ordered endpoints preserve all split groups/short facets; U resets never set cadence.
- [ ] Visual children add no physics/navigation/spray role or massing/source/generated change.

```yaml
schema_version: codex.building-texture-research/1
target: {id: w95934093, receiver: 'building:w95934093:wall', identity_confidence: high}
sources: [L01, 1432H-SV01-current, 1432H-SV02-historical]
temporal_state: {historic: standing_building_may_2011, current: empty_site_march_2025}
observed_regions: [historic_south_front, historic_west_end, current_empty_footprint]
unobserved_regions: [historic_rear_north, historic_east_end, exact_endpoints]
outputs: {homogeneous_material_tile: historical_reference_ready, architectural_pattern_tile: blocked, module_atlas: historical_reference_ready_placement_blocked, unique_elevation: historical_front_reference_ready_attachment_blocked}
smallest_cell: {status: nonperiodic_unique_block, modules: [1432H-FRONT-BLOCK, 1432H-UPPER-WIN, 1432H-CREAM-FIELD, 1432H-BRICK-FIELD]}
legal_seams: [uninterrupted_cream, uninterrupted_brick, full_unique_front_boundary]
forbidden_seams: [generated_U_reset, garage, brick_pier, stair, rail, balcony, recess, entry, window, eave, hip, corner]
research_verdict: {ready_for_generation: true, ready_subset: [historical_materials, historical_upper_window_atlas, historical_front_plan], ready_for_attachment: false, blockers: [removed_current_site, lifecycle_choice_required, rear_east_unobserved, ordered_run_mapping_missing]}
```

## Final status

- Historical May 2011 specification: **implementation-ready for an explicitly historical prototype**.
- Current facade/live attachment: **blocked by March 2025 removal and lifecycle decision**.

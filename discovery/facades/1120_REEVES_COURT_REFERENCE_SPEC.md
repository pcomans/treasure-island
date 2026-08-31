# 1120 Reeves Court facade reference specification

Checked: **2026-08-29**  
Target: **unnamed `w96665923` / `building:w96665923:wall`**  
Mode: **research and implementation handoff only**

## Receiver-first verdict

Three January 2023 official requests provide Gateview-side row context but display no 1120 address. Identity is medium and the Reeves/front side is unobserved. Conservative cool-gray siding and a provisional upper-window study are defensible; target-specific lower/front modules and placement are blocked.

## Exact identity and receiver

| Item | Exact local evidence |
|---|---|
| Source | way `96665923`, v4, `2020-07-09T13:50:42Z`; `building=yes`, height `6 m`; no name/use/levels |
| IDs/path | `building:w96665923`; wall `building:w96665923:wall`; roof `building:w96665923:roof`; chunk `x_-2__z_-3`; `WorldRoot/PlayableWorld/Buildings/x_-2__z_-3__building_w96665923_wall/building_w96665923_wall` |
| Meters | base/top `2.144 / 8.144`; lowest foundation `1.992`; area `280.259 m²`; serialized/visible `74.221 / 74.220 m` |
| Mesh/groups | wall `8` runs `32v/16tri`; roof `4v/2tri`; NE `35.4° 2/10.556`; SE `125.5° 2/26.560`; SW `215.5° 2/10.550`; NW `305.4° 2/26.555` m |
| Roles | wall `plaster_grey_04`, opaque `world_solid`, sole spray receiver; roof `bitumen`, opaque collider/non-spray; no shared parts |

## Provenance and coverage

| ID | Exact official source | Coverage / limit |
|---|---|---|
| `1120R-SV01` | [request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8290483,-122.3765868&heading=191&pitch=0&fov=75); pano `nGJC_da78eTfX_I7bzioog`; actual `37.8290594,-122.3766738`; **January 2023**; south `191°` | north/rear and end context |
| `1120R-SV02` | [request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8289051,-122.3768274&heading=102&pitch=0&fov=75); pano `YWCbQWgG3xXBD4vgISBvZA`; actual `37.8289166,-122.3768151`; **January 2023**; ESE `102°` | closer north/rear behind wood fence |
| `1120R-SV03` | [request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8286408,-122.3766416&heading=0&pitch=0&fov=75); pano `KutMYle4h8SilNovRTRCSg`; snapped actual `37.8287580,-122.3769332`; **January 2023**; north `0°` | broad context; no independently assignable front detail |

Reeves/front/south side, ground entry sequence, opposite end and exact endpoints are unobserved. No imagery is stored.

## Facts, cautious inference, modules and seams

Visible row reads as two storeys, an observation compatible with but not altering the `6 m` source. Medium cool-gray horizontal siding, white window trim/downspouts, shallow dark gray-brown gable and broad upper sliders are visible. Lower windows are fence-hidden; round lights/vents and a shallow dark hood have unresolved unit ownership. Fence/trees/blurred regions are excluded.

Reversible inference: siding reflectance `35–55%`, roughness `0.65–0.85`, course `0.12–0.22 m`; white trim `70–90%`; roof `15–30%`, roughness `0.80–0.95`; upper group width `1.4–2.4 m`, low confidence.

`1120R-SIDING` is conservative field. `1120R-UPPER-BAY` contains one full upper slider/surround/siding but is provisional pending 1120 unit ownership. No front/lower/fence/hood/fixture module.

| Output | Status |
|---|---|
| `homogeneous_material_tile` | **conservative reference-ready** for cool-gray siding/white trim |
| `architectural_pattern_tile` | **blocked**; no target period/complete lower grammar |
| `module_atlas` | **provisional upper-bay study, placement-blocked** |
| `unique_elevation` | **blocked** by medium identity and unobserved front/lower/end |

Legal seams: uninterrupted siding only until exact unit ownership. Forbidden: U reset/side midpoint, window/lower opening/hood/fixture/downspout/eave/gable/corner/fence/tree/blurred region.

## Reserved Godot BOM

| ID | Planned path / status |
|---|---|
| `MAT` | `res://game/resources/materials/world/1120_reeves/` — conservative siding/trim/roof fields |
| `ATLAS` | `res://game/resources/textures/buildings/1120_reeves/1120_reeves_modules` — provisional upper-bay study |
| `MOD` | `res://game/scenes/world/facades/1120_reeves/1120_reeves_modules.tscn` — blocked from attachment |
| `LAYOUT` | `res://game/resources/facades/1120_reeves_layout.json` — exact endpoints required |
| `ATTACH` | `res://game/scenes/world/facades/1120_reeves/1120_reeves_facade.tscn` — later visual child |

## Boundary and invariant example

```text
before: building:w96665923:wall is the 6 m, eight-run opaque spray receiver.
after:  exact height, silhouette, roof, footprint, openings, topology, foundation,
        terrain, physics, spray, OSM and generated contracts remain; no use/story
        is inferred and only observed complete visuals may attach after mapping.
```

## Acceptance gates

- [ ] Reviewer confirms all views are Gateview-side, no 1120 label appears and Reeves/front remains unobserved.
- [ ] IDs/path/chunk, `6 m`, `8 / 74.220 m`, wall `16` and roof `2` triangles remain.
- [ ] No residential use/level/court-family grammar is inferred.
- [ ] Only conservative siding/provisional upper-bay study is produced; no lower/front/unit placement occurs.
- [ ] Ordered endpoints preserve each two-run side; U reset never sets phase.
- [ ] Visual child adds no physics/navigation/spray role or massing/source/generated change.

```yaml
schema_version: codex.building-texture-research/1
target: {id: w96665923, receiver: 'building:w96665923:wall', identity_confidence: high}
sources: [L01, 1120R-SV01, 1120R-SV02, 1120R-SV03]
observed_regions: [north_rear_row_context, end_context]
unobserved_regions: [reeves_front_south, ground_entry_sequence, opposite_end, exact_1120_unit, exact_endpoints]
outputs: {homogeneous_material_tile: conservative_reference_ready, architectural_pattern_tile: blocked, module_atlas: provisional_upper_bay_study_placement_blocked, unique_elevation: blocked}
smallest_cell: {status: target_ownership_unproven, modules: [1120R-SIDING, 1120R-UPPER-BAY]}
legal_seams: [uninterrupted_siding]
forbidden_seams: [generated_U_reset, side_midpoint, window, lower_opening, hood, round_fixture, downspout, eave, gable, corner, fence, tree, blurred_region]
research_verdict: {ready_for_generation: true, ready_subset: [conservative_siding_material, provisional_upper_bay_study], ready_for_attachment: false, blockers: [no_direct_1120_address, front_and_lower_unobserved, exact_unit_ownership_unknown, endpoint_mapping_missing]}
```

## Final status

- Conservative material/provisional upper-bay study: **implementation-ready**.
- Target modules/attachment: **blocked by medium identity and absent front/lower coverage**.

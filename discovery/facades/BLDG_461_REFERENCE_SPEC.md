# Bldg 461 facade reference specification

Checked: **2026-08-29**  
Target: **`w34313569` / `building:w34313569:wall`**  
Mode: **research and implementation handoff only**

## Verdict

The frozen receiver/name join is exact, but no street address, use or level count exists. One distant November 2025 official view provides only **medium-confidence** spatial identity and supports a conservative gray material study. Window modules, story cadence, unique elevation and placement are blocked by distance, incomplete coverage and the irregular 27-run map.

## Exact receiver

| Item | Exact value |
|---|---|
| Source | `name=Bldg 461`; way `34313569`, v5, `2018-01-22T18:58:54Z`; `building=yes`, `height=8`, `source=Yahoo`; no address/use/levels |
| IDs/path | `building:w34313569`; wall `building:w34313569:wall`; roof `building:w34313569:roof`; chunk `x_-1__z_-4`; `WorldRoot/PlayableWorld/Buildings/x_-1__z_-4__building_w34313569_wall/building_w34313569_wall` |
| Contract | base/top `3.525 / 11.525 m`; lowest `2.791`; area `1957.242 m²`; serialized/visible `207.182 / 207.182 m` |
| Mesh | wall `27` runs `108v/54tri`; roof `12v/10tri`; no shared parts |
| Groups | N `0.1° 2/16.039`; NNE `15.1° 5/50.743`, `17.1° 2/8.466`; ESE `104.5° 3/33.648`; SSW `196.4° 4/52.372`, `199.6° 2/5.928`, `212.2° 2/14.399`; SW `228.2° 2/3.957`; WNW `284.4° 2/7.403`, `285.4° 1/7.275`, `287.0° 1/3.526`, `288.4° 1/3.426` m |
| Roles | wall `plaster_grey_04`, opaque `world_solid`, sole spray receiver; roof `bitumen`, opaque collider/non-spray |

## Provenance and coverage

| ID | Exact source | Coverage / exclusion |
|---|---|---|
| `B461-SV01` | [official request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8310739,-122.370928&heading=312&pitch=0&fov=75); pano `JMpuxlpS4Re0BFnlc7D1pA`; actual `37.8310653,-122.3708380`; **Nov 2025**; northwest `312°` | distant southeast/east long side and east/end; medium footprint identity |
| `B461-EX01` | [request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8313388,-122.3718321&heading=34&pitch=0&fov=75) | contributor imagery excluded; supports nothing |
| `B461-EX02` | [request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.83121,-122.3721663&heading=52&pitch=0&fov=75) | contributor imagery excluded; supports nothing |

Opposite side, bases, entrances and endpoints are unobserved. No imagery is retained.

## Observed facts, cautious inference and unknowns

Visible: one tall industrial-looking storey with flat/parapet profile compatible with but not measuring the frozen `8 m`; medium cool-gray field; dark vertical divisions and thin roof edge; pale warm-gray/tan end/service volume. A lighter coarse lower/inset region and a short row of small vertical windows are possible but uncertain at this distance. No door, loading bay, canopy, sign or exact opening count is established.

Only reversible swatches are allowed: medium gray reflectance `25–45%`, roughness `0.72–0.90`; possible lighter region `40–60%`, roughness `0.78–0.92`. A possible window cell `0.5–0.9 m` wide by `0.8–1.4 m` high is **low confidence and not generation authority**. Substrate, lower-region existence, openings, story count, scale and side mapping remain unknown.

## Output and seams

| Output | Status |
|---|---|
| `homogeneous_material_tile` | **reference-ready only for conservative medium-gray and pale-end swatches** |
| `architectural_pattern_tile` | **blocked**; no repeat verified |
| `module_atlas` | **blocked**; suspected window row is too distant/uncertain |
| `unique_elevation` | **blocked** by medium identity, distance, missing sides/endpoints |

Legal seams: only homogeneous gray/pale field. Forbidden: suspected windows/divisions, end transition, corners, roof edge, foundation/top and U resets. Do not render `461` signage; none is observed.

## Godot BOM

| ID | Planned role |
|---|---|
| `MAT-GRAY`, `MAT-END` | `res://game/resources/materials/world/bldg_461/`; cautious PBR swatches |
| `ATLAS-WINDOWS` | reserved `res://game/resources/textures/buildings/bldg_461/bldg_461_modules`; **blocked** |
| `MOD` | `res://game/scenes/world/facades/bldg_461/bldg_461_modules.tscn`; **blocked** |
| `LAYOUT` | `res://game/resources/facades/bldg_461_layout.json`; blocked pending closer evidence/canonical map |
| `ATTACH` | `res://game/scenes/world/facades/bldg_461/bldg_461_facade.tscn`; blocked visual child |

## Boundary, example and gates

```text
before: building:w34313569:wall is the 8 m, 27-run opaque spray receiver.
after:  every massing, roof, footprint, topology, physics, spray, foundation,
        terrain, OSM and generated invariant remains; only unattached neutral
        gray/end material candidates are available.
```

- [ ] Reviewer confirms Nov 2025 source, distant coverage and medium identity.
- [ ] No window/door/loading/sign module is fabricated; excluded contributor views are unused.
- [ ] IDs/path/chunk, `8 m`, `27 / 207.182 m`, wall `54` and roof `10` triangles remain.
- [ ] Neutral material contains no baked light/reflection/displacement.
- [ ] No layout/attachment without closer evidence and exact canonical run map.
- [ ] No silhouette/story/opening/physics/spray/generated change.

```yaml
schema_version: codex.building-texture-research/1
target: {id: w34313569, receiver: 'building:w34313569:wall', identity_confidence: medium}
sources: [L01, B461-SV01, B461-EX01, B461-EX02]
observed_regions: [distant_southeast_east_long, distant_east_end]
unobserved_regions: [opposite_side, bases, entrances, exact_endpoints]
outputs: {homogeneous_material_tile: conservative_reference_ready, architectural_pattern_tile: blocked, module_atlas: blocked, unique_elevation: blocked}
legal_seams: [homogeneous_field]
forbidden_seams: [suspected_window, vertical_division, end_transition, roof_edge, corner, receiver_top, foundation, generated_U_reset]
research_verdict: {ready_for_generation: true, ready_subset: [neutral_gray_and_end_swatches], ready_for_attachment: false}
```

## Final status

- Conservative material swatches: **implementation-ready**.
- Detailed facade/placement: **blocked by medium identity, distance, coverage and run mapping**.

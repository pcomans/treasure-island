# 449 Avenue H facade reference specification

Checked: **2026-08-29**  
Target: **unnamed `w34313512` / `building:w34313512:wall`**  
Mode: **research and implementation handoff only**

## Verdict

The frozen source is an unnamed two-level building at 449 Avenue H. Official imagery shows a matching historic building in May 2011 but a graded, fenced redevelopment lot in September 2025. Google labels the viewpoints **440** historically and **395** currently, so footprint reconciliation is medium-high but address reconciliation only medium. A **historical/frozen-era material and module set** is implementation-ready; any current-world representation or exact receiver placement is blocked.

## Exact identity and receiver

| Item | Exact value |
|---|---|
| Frozen identity | unnamed building, 449 Avenue H; way `34313512`, v5, `2018-01-22T18:55:34Z`; `building=abandoned`, levels `2`, height `10 m` |
| Logical/wall/roof | `building:w34313512`; `building:w34313512:wall`; `building:w34313512:roof` |
| Chunk/runtime | `x_0__z_0`; `WorldRoot/PlayableWorld/Buildings/x_0__z_0__building_w34313512_wall/building_w34313512_wall` |
| Generated contract | base/top `3.619 / 13.619 m`; lowest `3.241 m`; area `2693.822 m²`; serialized/visible `226.095 / 226.094 m` |
| Mesh/groups | wall `20` runs, `80v/40tri`; roof `4v/2tri`; ENE `61.8° 7/78.909 m`; SSE `151.8° 2/34.138`; WSW `241.8° 8/78.909`; NNW `331.8° 3/34.138` |
| Materials/roles | wall `plaster_grey_04`, opaque `world_solid`, sole spray receiver; roof `bitumen`, collider/non-spray |

## Provenance and temporal coverage

Both views use [this official request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.823153,-122.3685837&heading=253&pitch=0&fov=75).

| ID | Panorama / position / date | Supports |
|---|---|---|
| `449H-CURRENT` | `tUuvbI3y3fgy-R_XCvHdDQ`; actual `37.8231121,-122.3685646`; **Sep 2025** | graded fenced redevelopment lot; target building absent; Google label 395 |
| `449H-HIST` | `d4T0RdF4AE250u-CoH7tYw`; actual `37.8231534,-122.3685542`; **May 2011** | two-storey north/northeast long elevation; Google label 440 |

Opposite elevation, ends and exact endpoints are unobserved. No imagery was retained. `building=abandoned` is dated source context, not current proof.

## Historical facade grammar and material hierarchy

Observed in May 2011: light warm-beige/off-white horizontal siding/cladding; dark desaturated blue/blue-gray frames and trim; two nearly continuous window registers, with taller upper windows and lower shallow transoms over opaque siding; a blue-gray ledge/canopy line between registers; roof overhang with light underside members; ground blue-gray doors/service/glazed bays. Broken panes and condition damage are rejection examples, not base texture.

Reversible production estimates: siding reflectance `55–75%`, roughness `0.65–0.85`, course `0.12–0.22 m`; trim reflectance `15–30%`, roughness `0.55–0.75`; glass roughness `0.12–0.28`; candidate bay width `1.2–2.2 m`. All scale estimates are low confidence. Exact substrate, bay count/period, entrances, endpoints and other sides remain unknown.

## Output classification and seams

| Output | Status / rationale |
|---|---|
| `homogeneous_material_tile` | **historical reference-ready**: siding and blue-gray trim PBR fields |
| `architectural_pattern_tile` | **blocked**: no complete verified horizontal period or opposite edge |
| `module_atlas` | **historical reference-ready, placement-blocked**: `449H-TWO-TIER-BAY`, `449H-GROUND-DOOR` after-states, `449H-SOLID-SIDING` |
| `unique_elevation` | **blocked**: only one historic side, address-label conflict, exact endpoints absent, current building cleared |

Legal seams are siding field and complete bay/module boundaries. Forbidden seams cross a window/transom/door, ledge, overhang, corner, top/foundation or generated U reset. Never turn May 2011 evidence into a September 2025/current facade without a separately approved temporal choice.

## Godot BOM

| ID | Planned path / role |
|---|---|
| `MAT-SIDING`, `MAT-TRIM`, `MAT-GLASS` | `res://game/resources/materials/world/449_avenue_h/`; historical PBR materials |
| `ATLAS-HIST` | `res://game/resources/textures/buildings/449_avenue_h/449_avenue_h_historic_modules`; complete RGBA modules/maps |
| `MOD-HIST` | `res://game/scenes/world/facades/449_avenue_h/449_avenue_h_modules.tscn`; shallow noncolliding quads |
| `LAYOUT` | `res://game/resources/facades/449_avenue_h_layout.json`; blocked pending temporal/address/endpoint reconciliation |
| `ATTACH` | `res://game/scenes/world/facades/449_avenue_h/449_avenue_h_facade.tscn`; later visual child |

## Invariant before -> after

```text
before: building:w34313512:wall is the frozen 10 m/two-level, 20-run spray receiver.
after:  that receiver and all massing, roof, footprint, physics, spray, foundation,
        terrain, OSM and generated contracts remain unchanged; only a clearly
        historical material/module library is authored, unattached by default.
```

No facade work may alter silhouette, story count, structural openings, collision, navigation or spray eligibility. Shallow render-only modules are allowed after temporal and exact-chain approval.

## Acceptance gates

- [ ] Every output is labelled **May 2011 historical**, never current.
- [ ] Reviewer confirms September 2025 cleared-lot state and the 395/440/449 label conflict.
- [ ] IDs/path/chunk, `10 m / 2`, `20 / 226.094 m`, wall `40` and roof `2` triangles remain exact.
- [ ] Broken panes/damage and baked lighting/reflections are excluded.
- [ ] Complete motifs survive atlas edges; U resets/cardinal groups do not phase placement.
- [ ] No attachment occurs without approved temporal intent plus spatial endpoint map.
- [ ] Visual child has no physics/navigation/spray role; source/generated bytes remain unchanged.

## Normalized handoff

```yaml
schema_version: codex.building-texture-research/1
target: {id: w34313512, receiver: 'building:w34313512:wall', identity_confidence: medium}
sources: [L01, 449H-CURRENT, 449H-HIST]
observed_regions: [historic_north_northeast_long]
unobserved_regions: [opposite_long, ends, exact_endpoints, current_facade]
temporal_state: {historic: building_visible_may_2011, current: cleared_redevelopment_sep_2025}
outputs: {homogeneous_material_tile: historical_reference_ready, architectural_pattern_tile: blocked, module_atlas: historical_reference_ready_placement_blocked, unique_elevation: blocked}
legal_seams: [homogeneous_siding, complete_module_boundary]
forbidden_seams: [opening, transom, ledge, overhang, corner, receiver_top, foundation, generated_U_reset]
uncertainty: [address_label_conflict, exact_scale, repeat_period, endpoints, unobserved_sides, intended_time_state]
research_verdict: {ready_for_generation: true, ready_subset: [historic_materials, historic_module_atlas], ready_for_attachment: false}
```

## Final status

- Historical material/module prototypes: **implementation-ready**.
- Current facade and receiver attachment: **blocked by redevelopment, identity/temporal reconciliation and incomplete mapping**.

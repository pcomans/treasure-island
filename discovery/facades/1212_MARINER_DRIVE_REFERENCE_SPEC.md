# 1212 Mariner Drive facade reference specification

Checked: **2026-08-29**  
Target: **unnamed residential `w96215649` / `building:w96215649:wall`**  
Mode: **research and implementation handoff only**

## Verdict

The frozen address/use and official Google label `1212` give high identity confidence. March/September 2025 official views cover the complete front long elevation plus rear long elevation/end, supporting a **target-specific material and front/rear/end module set**. It is not the same grammar as 1318 Gateview: 1212 has no pronounced porch canopy. Exact attachment remains blocked by unit-to-run reconciliation, short facets and the unobserved opposite end/notches.

## Exact identity and receiver

| Item | Exact value |
|---|---|
| Source | unnamed residential building, 1212 Mariner Drive; way `96215649`, v5, `2018-01-25T19:29:04Z`; levels `2`, height `6 m` |
| IDs/path | `building:w96215649`; wall `building:w96215649:wall`; roof `building:w96215649:roof`; chunk `x_-1__z_-3`; `WorldRoot/PlayableWorld/Buildings/x_-1__z_-3__building_w96215649_wall/building_w96215649_wall` |
| Contract | base/top `2.650 / 8.650 m`; lowest `2.528`; area `490.003 m²`; serialized/visible `115.694 / 115.696 m` |
| Mesh/groups | wall `28` runs `112v/56tri`; roof `18v/16tri`; ENE `74.5° 1/1.676`, `74.6° 1/10.979`, `74.9° 1/1.280`; SSE `164.6° 7/43.916`; WSW `254.6° 4/12.794`, `254.7° 2/1.131`; NNW `344.6° 9/36.317`, `344.7° 1/4.349`, `344.8° 2/3.254` m |
| Roles | wall `plaster_grey_04`, opaque `world_solid`, sole spray receiver; roof `bitumen`, opaque collider/non-spray |

## Provenance and coverage

| ID | Exact official source | Coverage |
|---|---|---|
| `1212-SV-FRONT` | [request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8291464,-122.3730796&heading=172&pitch=0&fov=75); pano `moV9e3E7bv5UpjOrgfOOKA`; actual `37.8291812,-122.3730340`; **Mar 2025**; south `172°` | complete front long elevation |
| `1212-SV-REAR` | [request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8291844,-122.3727735&heading=230&pitch=0&fov=75); pano `Z0fcNvA78OpNIXJaa9A79A`; actual `37.8291852,-122.3727577`; **Sep 2025**; southwest `230°` | rear long elevation and one end |

Opposite end, notches and exact endpoints are unobserved. No imagery is retained.

## Facts, inference and unknowns

Observed: two-storey attached units; light cool gray-blue horizontal siding; white trim/gutters; gray-brown shallow gable roof. Front units have upper broad sliders and ground broad windows alternating with dark red-brown entries, plus short dark gray-blue privacy/bin wings. There is **no pronounced porch canopy**. Rear units have upper and smaller lower windows behind privacy fences; visible end has stacked windows.

Reversible estimates: siding reflectance `45–65%`, roughness `0.65–0.85`, course `0.12–0.22 m`; white trim `70–90%`, roughness `0.55–0.78`; roof `20–35%`, roughness `0.80–0.95`; glass `0.12–0.28`; candidate unit width `3.5–5.5 m`, **low confidence**. Exact unit widths/counts, alternation period, entry colors, hidden lower rear, opposite end, notches and endpoint ownership remain unknown.

## Output classification and seams

| Output | Status / smallest cell |
|---|---|
| `homogeneous_material_tile` | **reference-ready** for siding/white trim/roof/red-brown and dark privacy fields |
| `architectural_pattern_tile` | **blocked**; variable unit alternation is not a verified cyclic period |
| `module_atlas` | **reference-ready, placement-blocked**: `1212-FRONT-UNIT`, `1212-REAR-UNIT`, unique `1212-END`, `1212-SOLID-SIDING` |
| `unique_elevation` | **reference-ready in front/rear sequence concept, placement-blocked** by exact run/end/notch map |

Legal seams: homogeneous siding and verified complete unit boundaries. Forbidden: inside window/door/slider, privacy wing, end motif, gutter/downspout, notch/corner, top/foundation and generated U reset. Never borrow 1318 Gateview's porch canopy or unit schedule.

## Godot BOM

| ID | Planned role |
|---|---|
| `MAT-SIDING`, `MAT-WHITE`, `MAT-ROOF`, `MAT-ENTRY`, `MAT-PRIVACY`, `MAT-GLASS` | `res://game/resources/materials/world/1212_mariner/`; target-specific PBR materials |
| `ATLAS-UNITS` | `res://game/resources/textures/buildings/1212_mariner/1212_mariner_modules`; complete front/rear/end RGBA modules/maps |
| `MOD-UNIT`, `MOD-END`, `MOD-PRIVACY` | `res://game/scenes/world/facades/1212_mariner/1212_mariner_modules.tscn`; shallow noncolliding visuals |
| `LAYOUT` | `res://game/resources/facades/1212_mariner_layout.json`; blocked pending ordered endpoint map |
| `ATTACH` | `res://game/scenes/world/facades/1212_mariner/1212_mariner_facade.tscn`; later visual child |

## Invariant example

```text
before: building:w96215649:wall is the 6 m/two-level, 28-run spray receiver.
after:  receiver, story count, silhouette, roof, footprint, structural openings,
        topology, foundation, physics, spray, terrain and source/generated contracts
        remain; complete 1212-specific modules attach only after exact mapping.
```

## Acceptance gates

- [ ] Reviewer confirms both official dates, 1212 label and front vs rear/end coverage.
- [ ] 1212 remains a distinct family: no 1318 porch canopy or schedule is imported.
- [ ] IDs/path/chunk, `6 m / 2`, `28 / 115.696 m`, wall `56` and roof `16` triangles remain.
- [ ] Atlas cells preserve complete units/openings; fences/privacy wings are not baked into siding.
- [ ] Ordered endpoints map units before placement; short facets/notches/U resets never set cadence.
- [ ] Unobserved opposite end stays fallback; no massing/opening/physics/spray/generated change.

```yaml
schema_version: codex.building-texture-research/1
target: {id: w96215649, receiver: 'building:w96215649:wall', identity_confidence: high}
sources: [L01, 1212-SV-FRONT, 1212-SV-REAR]
observed_regions: [complete_front_long, rear_long, one_end]
unobserved_regions: [opposite_end, notches, exact_endpoints, lower_rear_behind_fences]
outputs: {homogeneous_material_tile: reference_ready, architectural_pattern_tile: blocked, module_atlas: reference_ready_placement_blocked, unique_elevation: sequence_reference_ready_placement_blocked}
smallest_cell: {status: variable_complete_unit, modules: [1212-FRONT-UNIT, 1212-REAR-UNIT, 1212-END, 1212-SOLID-SIDING]}
legal_seams: [homogeneous_siding, verified_complete_unit_boundary]
forbidden_seams: [opening, privacy_wing, end_motif, gutter, downspout, notch, corner, receiver_top, foundation, generated_U_reset]
research_verdict: {ready_for_generation: true, ready_subset: [materials, unit_module_atlas, sequence_plan], ready_for_attachment: false}
```

## Final status

- Target-specific materials/modules/sequence concept: **implementation-ready**.
- Exact attachment: **blocked by endpoint/run mapping and unobserved end/notches**.

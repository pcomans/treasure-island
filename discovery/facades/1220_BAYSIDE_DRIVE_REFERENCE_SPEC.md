# 1220 Bayside Drive facade reference specification

Checked: **2026-08-29**  
Target: **unnamed residential `w96215652` / `building:w96215652:wall`**  
Mode: **research and implementation handoff only**

## Receiver-first verdict

The frozen address and March 2025 exact-address panorama identify the public elevation with high confidence. It supports a target-specific warm-gray/beige siding and front-unit vocabulary. The rear attempt returned excluded contributor imagery; rear, opposite end, short facets and exact 26-run placement remain blocked.

## Exact identity and receiver

| Item | Exact local evidence |
|---|---|
| Source | way `96215652`, v5, `2018-01-25T19:29:05Z`; `building=residential`, levels `2`, height `6 m`; no name |
| IDs/path | `building:w96215652`; wall `building:w96215652:wall`; roof `building:w96215652:roof`; chunk `x_-2__z_-3`; `WorldRoot/PlayableWorld/Buildings/x_-2__z_-3__building_w96215652_wall/building_w96215652_wall` |
| Meters | base/top `2.345 / 8.345`; lowest foundation `1.985`; area `608.496 m²`; serialized/visible `145.346 / 145.344 m` |
| Mesh | wall `26` runs `104v/52tri`; roof `16v/14tri`; standalone/no shared parts |
| Normal groups | NE `34.6° 3/29.338`, `34.7° 5/27.719`; SE `124.6° 1/1.487`, `124.7° 3/14.129`; SW `214.6° 5/27.636`, `214.7° 4/29.426`; NW `304.6° 2/10.416`, `304.7° 1/1.774`, `304.8° 1/1.572`, `304.9° 1/1.845` m |
| Materials/roles | wall `plaster_grey_04`, opaque `world_solid`, sole spray receiver; roof `bitumen`, opaque collider/non-spray |

## Provenance and coverage

| ID | Exact official source | Coverage |
|---|---|---|
| `1220B-SV01` | [request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8296496,-122.3762263&heading=1&pitch=0&fov=75); pano `y_1iTmB2k8lf_QeGek_yjQ`; actual `37.8296212,-122.3761997`; **March 2025**; north `1°` | exact-address south/southwest public/front elevation |
| `1220B-EX01` | [request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8307151,-122.376857&heading=140&pitch=0&fov=75) | no official coverage; contributor panorama excluded; no rear claim |

North/rear, short facets, opposite end and exact endpoints are unobserved. No imagery is stored.

## Facts, materials, modules and seams

Observed: two storeys; light warm-gray/beige horizontal lap/vinyl-like siding; white opening trim/downspouts; shallow muted reddish-brown roof with white eave/gutter. Each front unit has a broad upper slider; ground level alternates broad windows with plain dark gray/green doors and narrow pale side panels. Short pale wood privacy/bin enclosures are separate geometry/props. No porch canopy, masonry belt, applied band/rib, storefront or large opening is established.

Reversible inference: siding reflectance `50–70%`, roughness `0.65–0.85`, course `0.12–0.22 m`; white trim `70–90%`, roughness `0.55–0.78`; roof `20–35%`, roughness `0.80–0.95`; unit width `3.5–5.5 m`, low confidence. Exact alternates, physical scale and endpoints remain unknown.

`1220B-FRONT-UNIT` contains one full unit with upper slider, ground window/door alternate, full trim/downspout ownership and siding; `1220B-SIDING` is uninterrupted field. No rear module exists.

| Output | Status |
|---|---|
| `homogeneous_material_tile` | **reference-ready** for target siding/trim/roof fields |
| `architectural_pattern_tile` | **blocked**; alternation/period incomplete |
| `module_atlas` | **front reference-ready, placement-blocked** |
| `unique_elevation` | **front-sequence reference-ready, placement-blocked**; rear/end absent |

Legal seams: uninterrupted siding or verified full unit boundary. Forbidden: U reset, opening/door, privacy enclosure, gutter/downspout/roof edge, corner/short facet, vehicle/tree and cross-house transfer.

## Reserved Godot BOM

| ID | Planned path / status |
|---|---|
| `MAT` | `res://game/resources/materials/world/1220_bayside/` — reference-ready fields |
| `ATLAS` | `res://game/resources/textures/buildings/1220_bayside/1220_bayside_modules` — complete front units |
| `MOD` | `res://game/scenes/world/facades/1220_bayside/1220_bayside_modules.tscn` — shallow render modules |
| `LAYOUT` | `res://game/resources/facades/1220_bayside_layout.json` — ordered endpoints required |
| `ATTACH` | `res://game/scenes/world/facades/1220_bayside/1220_bayside_facade.tscn` — later visual child |

## Boundary and invariant example

```text
before: building:w96215652:wall is the 6 m/two-level, 26-run spray receiver.
after:  exact massing, silhouette, roof, footprint, structural openings, runs,
        short facets, foundation, terrain, physics, spray, OSM and generated data
        remain; only independently observed complete visuals may later attach.
```

## Acceptance gates

- [ ] Every appearance claim has target-specific dated official provenance and exact coverage.
- [ ] IDs/path/chunk, `6 m / 2`, `26 / 145.344 m`, wall `52` and roof `14` triangles remain.
- [ ] No Gateview/Mariner/court family grammar is inherited.
- [ ] Four short NW groups and the `1.487 m` SE facet retain explicit endpoint ownership.
- [ ] Ordered endpoints—not normal grouping/U resets—drive placement; visual child has no physics/spray role.

```yaml
schema_version: codex.building-texture-research/1
target: {id: w96215652, receiver: 'building:w96215652:wall', identity_confidence: high}
sources: [L01, 1220B-SV01, 1220B-EX01]
observed_regions: [south_southwest_front]
unobserved_regions: [north_rear, opposite_end, short_facets, exact_endpoints]
outputs: {homogeneous_material_tile: reference_ready, architectural_pattern_tile: blocked, module_atlas: front_reference_ready_placement_blocked, unique_elevation: front_sequence_reference_ready_placement_blocked}
smallest_cell: {status: variable_complete_unit, modules: [1220B-FRONT-UNIT, 1220B-SIDING]}
legal_seams: [uninterrupted_siding, verified_complete_unit_boundary]
forbidden_seams: [generated_U_reset, opening, door, privacy_enclosure, gutter, downspout, roof_edge, short_facet, corner, cross_residential_reuse]
research_verdict: {ready_for_generation: true, ready_subset: [materials, front_unit_atlas, front_sequence_plan], ready_for_attachment: false, blockers: [rear_no_official_coverage, exact_alternates_unknown, short_facet_and_run_mapping_missing]}
```

## Final status

- Front materials/unit prototypes: **implementation-ready**.
- Rear/whole-building attachment: **blocked by excluded rear coverage and exact run mapping**.

# 1113 Keppler Court facade reference specification

Checked: **2026-08-29**  
Target: **named residential `w96665921` / `building:w96665921:wall`**  
Mode: **research and implementation handoff only**

## Receiver-first verdict

Frozen OSM and the close official frontage identify **1113 Keppler Court** with high confidence. 2018/2019 front views and a distant 2025 rear view support a target-specific two-storey siding/unit vocabulary. Exact front alternates, hidden rear-lower grammar, unit widths and the 22-run placement map remain blocked.

## Exact identity and receiver

| Item | Exact local evidence |
|---|---|
| Source | way `96665921`, v6, `2020-07-09T13:50:42Z`; `name=1113 Keppler Court`, `building=residential`, levels `2`, height `6 m` |
| IDs/path | `building:w96665921`; wall `building:w96665921:wall`; roof `building:w96665921:roof`; chunk `x_-2__z_-2`; `WorldRoot/PlayableWorld/Buildings/x_-2__z_-2__building_w96665921_wall/building_w96665921_wall` |
| Meters | base/top `2.454 / 8.454`; lowest foundation `2.353`; area `664.029 m²`; serialized/visible `144.427 / 144.427 m` |
| Mesh/groups | wall `22` runs `88v/44tri`; roof `10v/8tri`; NNE `16.9° 7/58.334`; ESE `106.9° 3/13.869`; SSW `196.9° 7/58.340`; WNW `286.9° 4/12.382`, `287.0° 1/1.502` m |
| Materials/roles | wall `plaster_grey_04`, opaque `world_solid`, sole spray receiver; roof `bitumen`, opaque collider/non-spray; standalone/no shared parts |

## Provenance and coverage

| ID | Exact official source | Coverage |
|---|---|---|
| `1113K-SV01` | [request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8276235,-122.376855&heading=175&pitch=0&fov=75); pano `wwffTkz2DyE-wnlL73JVtA`; actual `37.8275988,-122.3768666`; **February 2018**; south `175°` | broad front context |
| `1113K-SV02` | [request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8272912,-122.376818&heading=184&pitch=0&fov=75); pano `tgMj9xpYL0zAAAwf82nR8g`; actual `37.8273143,-122.3768473`; **April 2019**; south `184°` | close NNE/public/front elevation; displayed exact address |
| `1113K-SV03` | [request](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82689,-122.3771609&heading=49&pitch=0&fov=75); pano `BrOH3kQaEK0IOVN30IM9FQ`; actual `37.8268889,-122.3771306`; **November 2025**; northeast `49°` | distant SSW/rear elevation |

End/return details, lower rear behind fence and exact endpoints remain unobserved. No imagery is stored.

## Facts, materials, modules and seams

Observed: two storeys; muted cool gray-blue horizontal lap/vinyl-like siding; white trim/gutters/downspouts; shallow muted-gray shingle roof. Front units broadly repeat an upper slider over ground window plus dark burgundy/red-brown door, interrupted by dark blue-gray privacy/bin enclosures. Full-height trim/downspouts mark some candidate boundaries. Rear appears lighter under different lighting, with one upper group per unit; lower openings are fence-hidden. Trees, bins, fences and dishes are excluded. No porch canopy/masonry belt/rib/large opening is established.

Reversible inference: siding reflectance `40–60%`, roughness `0.65–0.85`, course `0.12–0.22 m`; white trim `70–90%`, roughness `0.55–0.78`; roof `20–35%`, roughness `0.80–0.95`; glazing `0.12–0.28`; candidate unit width `3.5–5.5 m`, low confidence. Exact alternates, physical scale and run ownership remain unknown.

Complete modules: `1113K-FRONT-UNIT` owns upper slider, ground window/burgundy-door state, privacy enclosure, full trim/downspout boundary and siding; `1113K-REAR-UNIT` owns complete upper/lower opening states but excludes fence/dishes; `1113K-SIDING` is uninterrupted field.

| Output | Status |
|---|---|
| `homogeneous_material_tile` | **reference-ready** for target siding/trim/roof fields |
| `architectural_pattern_tile` | **blocked**; exact door/window alternation is incomplete |
| `module_atlas` | **reference-ready, placement-blocked** for front/rear complete unit families |
| `unique_elevation` | **sequence reference-ready, placement-blocked** by unit widths/endpoints/hidden rear lower |

Legal seams: uninterrupted siding or verified complete unit boundary with full trim/downspout ownership. Forbidden: U reset, opening, door, privacy enclosure, gutter/downspout/eave, tree-occluded bay, fence/dish, corner/short return and cross-house reuse.

## Reserved Godot BOM

| ID | Planned path / status |
|---|---|
| `MAT` | `res://game/resources/materials/world/1113_keppler/` — reference-ready siding/trim/roof/glass fields |
| `ATLAS` | `res://game/resources/textures/buildings/1113_keppler/1113_keppler_modules` — front/rear unit atlas |
| `MOD` | `res://game/scenes/world/facades/1113_keppler/1113_keppler_modules.tscn` — shallow noncolliding modules |
| `LAYOUT` | `res://game/resources/facades/1113_keppler_layout.json` — ordered endpoints required |
| `ATTACH` | `res://game/scenes/world/facades/1113_keppler/1113_keppler_facade.tscn` — later visual child |

## Boundary and invariant example

```text
before: building:w96665921:wall is the 6 m/two-level, 22-run spray receiver.
after:  target ID, story/height, silhouette, roof, footprint, openings, topology,
        foundation, terrain, physics, spray, OSM and generated contracts remain;
        only independently observed complete visuals may attach after run mapping.
```

## Acceptance gates

- [ ] Target-specific official provenance and coverage support every visual claim.
- [ ] IDs/path/chunk, `6 m / 2`, `22 / 144.427 m`, wall `44` and roof `8` triangles remain.
- [ ] No 1318/1212/adjacent-court material, canopy, unit or cadence is inherited.
- [ ] The `1.502 m` WNW facet and every short return retain exact ownership.
- [ ] Ordered endpoints—not normals/U resets—drive placement; visual child has no physics/spray role.

```yaml
schema_version: codex.building-texture-research/1
target: {id: w96665921, receiver: 'building:w96665921:wall', identity_confidence: high}
sources: [L01, 1113K-SV01, 1113K-SV02, 1113K-SV03]
observed_regions: [front_public, distant_rear]
unobserved_regions: [end_returns, hidden_lower_rear, exact_endpoints]
outputs: {homogeneous_material_tile: reference_ready, architectural_pattern_tile: blocked, module_atlas: reference_ready_placement_blocked, unique_elevation: sequence_reference_ready_placement_blocked}
smallest_cell: {status: variable_complete_unit, modules: [1113K-FRONT-UNIT, 1113K-REAR-UNIT, 1113K-SIDING]}
legal_seams: [uninterrupted_siding, verified_complete_unit_boundary]
forbidden_seams: [generated_U_reset, opening, door, privacy_enclosure, gutter, downspout, eave, tree_occlusion, fence, dish, corner, cross_residential_reuse]
research_verdict: {ready_for_generation: true, ready_subset: [materials, front_rear_unit_atlas, sequence_plan], ready_for_attachment: false, blockers: [unit_width_and_alternates_unknown, hidden_lower_rear, ordered_run_mapping_missing]}
```

## Final status

- Materials/unit prototypes/sequence: **implementation-ready**.
- Exact attachment: **blocked by unit-boundary/run mapping and incomplete rear/end evidence**.

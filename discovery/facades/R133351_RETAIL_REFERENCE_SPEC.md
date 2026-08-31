# `r133351` retail-tagged relation facade reference specification

Checked: **2026-08-29**
Target: **unnamed relation `r133351` / `building:r133351:wall`**
Mode: **research and implementation handoff only**

## Receiver-first verdict

Three useful March 2025 official viewpoints align with central/eastern and western public-frontage regions of the large coordinate-matched one-storey complex. They support separate light central/eastern, olive western and red-brown lower fields plus a small complete-module set. Canonical retail identity, adjacent-volume ownership, north/courtyard/re-entrant coverage, exact wing/run membership, physical scale and any building-wide repeat remain unresolved. Region prototypes are bounded-ready; all placement and whole-object acceptance are relation-mapping-blocked.

## Exact identity and receiver

| Item | Exact local evidence |
|---|---|
| Source | OSM relation `133351`, v4, `2018-08-12T03:51:33Z`; `building=retail`, `building:levels=1`, `roof:levels=0`; no name/address |
| Objects/chunk | logical `building:r133351`; wall `building:r133351:wall`; roof `building:r133351:roof`; `x_-2__z_-2` |
| Meters | area `4,261.772 m²`; serialized/visible `541.623 / 541.627 m`; generated height/base/top `3 / 2.927 / 5.927 m` |
| Topology | outer multipolygon plus inner courtyard/opening; `78` exterior/inner wall runs, `33` orientation groups, no shared-above-lower-part runs; cardinal totals ENE `149.580 m`, SSE `121.232`, WSW `149.495`, NNW `121.320` |
| Runtime | wall `building_wall -> plaster_grey_04`, opaque/sole spray receiver; roof `building_roof -> bitumen`, opaque collider/non-spray |

## Provenance and coverage

| Evidence ID | Exact official source | Coverage / limit |
|---|---|---|
| `B06-R133351-SV01` | [pano `6UrJRtr2zB-nHk1sw6b0JQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=6UrJRtr2zB-nHk1sw6b0JQ&heading=0&pitch=2&fov=78), actual `37.8276946,-122.3736033`, north, **March 2025** | central SSE/public frontage |
| `B06-R133351-SV02` | [pano `gWJcXXKQ03dQoyUTMI1ZgQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=gWJcXXKQ03dQoyUTMI1ZgQ&heading=270&pitch=2&fov=78), actual `37.8279144,-122.3730815`, west, **March 2025** | eastern frontage/end context |
| `B06-R133351-SV03` | [pano `nCSxWglpB-ykqu4O_qiqzg`](https://www.google.com/maps/@?api=1&map_action=pano&pano=nCSxWglpB-ykqu4O_qiqzg&heading=0&pitch=2&fov=78), actual `37.8275870,-122.3744772`, north, **March 2025** | western frontage and material transition |
| `B06-R133351-SV04` | [pano `Ag47L6sJ9ouC_3uJUj7Rdw`](https://www.google.com/maps/@?api=1&map_action=pano&pano=Ag47L6sJ9ouC_3uJUj7Rdw&heading=90&pitch=2&fov=78), actual `37.8276063,-122.3743681`, east, **March 2025** | target mostly hidden; occlusion context only |
| `B06-R133351-EX01` | excluded contributor pano `CIHM0ogKEICAgICc7emG4QE` | no evidence; center/courtyard coverage unavailable |
| `B06-LOCAL-R133351` | [`FACADE_RECEIVER_INVENTORY.json`](../FACADE_RECEIVER_INVENTORY.json), [`NEXT_FACADE_BATCH_06.md`](NEXT_FACADE_BATCH_06.md), [`BATCH_06_STREETVIEW_OBSERVATIONS.md`](BATCH_06_STREETVIEW_OBSERVATIONS.md) | exact relation/receiver contract plus observation bounds |

Observed: central/eastern SSE public frontage, western public/side frontage, limited oblique ends. Unobserved/ambiguous: NNW/north, most inner courtyard/re-entrant chains, exact ends, short facets and relation endpoints. Footprint identity is **medium-high**; canonical identity and exact wing membership remain source-key-only. No imagery is stored.

## Material regions, physical scale and complete motifs

- `R133351-MAT-LIGHT`: light warm gray/beige/off-white smooth painted field on central/eastern public frontage, matte to low-satin.
- `R133351-MAT-OLIVE`: olive/green western-wing painted field, a distinct propagation region.
- `R133351-MAT-LOWER`: muted red-brown lower panel/base beneath some western windows, local only.
- `R133351-MAT-DARK`: dark brown/gray header/trim and muted blue-gray/dark glazing.
- `R133351-HWIN`: one complete broad multi-pane horizontal window group, full frame and uninterrupted outer surround.
- `R133351-ENTRY`: one complete recessed entrance/door bay only when both outer pier boundaries, full opening and depth ownership are visible; depth remains geometry-owned.
- `R133351-WEST-LOWER`: one complete western window plus its bounded red-brown lower panel and olive surround.

One visible storey is broadly compatible with the generated `3 m`, not proof of every relation volume or motif dimension. Window/pier/header/door dimensions, bay cadence, field scale and exact wing transitions are unknown. Columns/piers, recessed depth, parapet steps, courtyard opening and wing junctions are geometry/unique-region conditions. The adjacent charcoal volume is ownership-unknown and excluded.

| Output | Status |
|---|---|
| `homogeneous_material_tile` | **reference-ready, scale-calibration required** for separate light, olive and red-brown regions |
| `architectural_pattern_tile` | **blocked**; depths/colors/opening widths/transitions defeat a building-wide cell |
| `module_atlas` | **reference-ready, placement/scale-blocked** for complete window/entry/west-lower modules |
| `unique_elevation` | **central/east and west concepts ready, relation-mapping-blocked**; no all-building output |

Legal seams: uninterrupted same-color field, uninterrupted local red-brown base, or full verified outer boundary of a complete pier/window/entry module. Forbidden: U reset; glazing/frame/pier/door; parapet/eave; material/color transition; recessed-depth/wing junction; inner-courtyard boundary; corner/short facet; charcoal ownership boundary; vegetation/fence/sign. All edge products must stay within one region or reassemble the same complete module.

Do not convert `building=retail` into generic storefronts, assume charcoal-volume membership, extend olive/red-brown to unseen wings, infer north/courtyard openings, repeat signs, flatten columns/recesses, or attach an outer material to an inner chain.

## Reserved Godot BOM and geometry boundary

| ID | Planned path / status |
|---|---|
| `MAT` | `res://game/resources/materials/world/r133351/` — light/olive/lower/dark studies |
| `ATLAS/MOD` | `res://game/resources/textures/buildings/r133351/r133351_modules`; `res://game/scenes/world/facades/r133351/r133351_modules.tscn` |
| `LAYOUT/ATTACH` | `res://game/resources/facades/r133351_layout.json`; `res://game/scenes/world/facades/r133351/r133351_facade.tscn` — blocked by relation reconciliation |

```text
before: building:r133351:wall is the exact 3 m/one-level, 78-run placeholder receiver.
after:  relation rings, source/height/story/silhouette/roof/footprint/recess geometry,
        foundation/terrain/topology/collision/navigation/spray/generated contracts
        remain; only accepted region-correct shallow visuals may later attach.
```

## Acceptance gates and blockers

- [ ] Preserve `78 / 541.627 m`, 33 groups, outer/inner topology, `3 m / 1`, base/top and roles.
- [ ] Reconcile relation membership and ordered outer/inner endpoints before any attachment.
- [ ] Keep light, olive and red-brown fields separate and off every unseen/inner chain.
- [ ] Calibrate physical scale; atlas motifs remain complete and never flatten depth.
- [ ] Exclude charcoal volume, signs, tenant program and occluded/north/courtyard inventions.
- [ ] Whole-object resemblance remains separately blocked despite local material/module readiness.

Prototype: **bounded-ready**. Live: **relation-mapping-blocked**. Whole object: **reference/ownership-blocked**.

```yaml
schema_version: codex.building-texture-research/1
target: {canonical_name: null, id: r133351, receiver: 'building:r133351:wall', identity_confidence: medium_high_coordinate_match}
sources: [B06-LOCAL-R133351, B06-R133351-SV01, B06-R133351-SV02, B06-R133351-SV03, B06-R133351-SV04]
observed_regions: [central_eastern_SSE_light, western_public_olive, western_lower_red_brown, limited_oblique_ends]
unobserved_regions: [north_NNW, inner_courtyard_reentrants, exact_ends, short_facets, relation_endpoints]
outputs: {homogeneous_material_tile: reference_ready_scale_blocked, architectural_pattern_tile: blocked, module_atlas: reference_ready_placement_scale_blocked, unique_elevation: region_concepts_ready_relation_mapping_blocked}
smallest_cell: {status: nonperiodic_complete_modules, modules: [R133351-HWIN, R133351-ENTRY, R133351-WEST-LOWER]}
legal_seams: [uninterrupted_same_color_field, uninterrupted_red_brown_base, complete_module_boundary]
forbidden_seams: [generated_U_reset, glazing_frame_pier_door, parapet_eave, material_transition, depth_wing_junction, inner_courtyard, corner_short_facet, charcoal_unknown, occlusion_sign]
research_verdict: {ready_for_generation: true, ready_subset: [separate_region_scale_studies, complete_module_atlas_study], ready_for_attachment: false, blockers: [relation_membership_unknown, outer_inner_endpoint_mapping_missing, physical_scale_unknown, north_courtyard_unobserved, adjacent_volume_ownership_unknown]}
```

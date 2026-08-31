# `w291196370` facade reference specification

Checked: **2026-08-29**
Target: **unnamed `w291196370` / `building:w291196370:wall`**
Mode: **research and implementation handoff only**

## Receiver-first verdict

September 2025 official coverage identifies the SSE/public elevation and ENE end of the coordinate-matched industrial/commercial shell. It supports a cool gray-blue horizontal-siding field plus complete narrow-window, entry and service-opening modules. Divider spacing and openings are irregular; NNW, WSW, several yard facets, exact endpoints and physical siding scale remain unknown. Material/module prototypes are bounded-ready; placement and whole-object acceptance are blocked.

## Exact identity and receiver

| Item | Exact local evidence |
|---|---|
| Source | OSM way `291196370`, v3, `2018-01-22T18:58:55Z`; `building=yes`, `height=6`; no name/address/use/levels |
| Objects/chunk | logical `building:w291196370`; wall `building:w291196370:wall`; roof `building:w291196370:roof`; `x_0__z_-3` |
| Meters | area `3,376.114 m²`; serialized/visible `258.422 / 258.421 m`; height/base/top `6 / 3.987 / 9.987 m` |
| Topology | `36` exterior runs / `10` orientation groups, no shared runs; cardinal totals ENE `79.258 m`, SSE `49.934`, WSW `79.278`, NNW `49.951`; includes `0.148 m` ENE and other short facets |
| Runtime | wall `building_wall -> plaster_grey_04`, opaque/sole spray receiver; roof `building_roof -> bitumen`, opaque collider/non-spray |

## Provenance and coverage

| Evidence ID | Exact official source | Coverage / limit |
|---|---|---|
| `B06-W291196370-SV01` | [pano `MsbRyPTgD82h7159JNdQ9Q`](https://www.google.com/maps/@?api=1&map_action=pano&pano=MsbRyPTgD82h7159JNdQ9Q&heading=0&pitch=2&fov=78), actual `37.8295775,-122.3691511`, north, **September 2025** | clear SSE/public elevation |
| `B06-W291196370-SV02` | [pano `Spfk1idrxel-cLsXjCOREg`](https://www.google.com/maps/@?api=1&map_action=pano&pano=Spfk1idrxel-cLsXjCOREg&heading=270&pitch=2&fov=78), actual `37.8298881,-122.3685755`, west, **September 2025** | ENE end and limited oblique service return |
| `B06-W291196370-SV03` | official pano `fiSKZWmVwCWtFPfE_jhdVQ`, actual `37.8299267,-122.3701232` | target not identifiable behind unrelated utility/site equipment; no facade claim |
| `B06-LOCAL-W291196370` | [`FACADE_RECEIVER_INVENTORY.json`](../FACADE_RECEIVER_INVENTORY.json), [`NEXT_FACADE_BATCH_06.md`](NEXT_FACADE_BATCH_06.md), [`BATCH_06_STREETVIEW_OBSERVATIONS.md`](BATCH_06_STREETVIEW_OBSERVATIONS.md) | exact local contract plus observation bounds |

Observed: SSE, ENE and limited service return. Unobserved: NNW, WSW, several yard-obscured facets, endpoints. Identity is high for coordinate footprint but source-key-only for name/use; displayed `990/899 13th St`, Avenue M and tenant sign are not canonical identity. No imagery is stored.

## Material hierarchy, scale and complete motifs

- `W291196370-SIDING`: muted cool gray-blue horizontal siding/cladding, matte to low-satin; a grayer/greener service-side variation remains a separate calibration study.
- `W291196370-TRIM`: narrow white vertical dividers and pale roof/parapet edge; a divider is not automatically a unit boundary.
- `W291196370-WINSTACK`: complete narrow white-framed vertical window stack with full trim and siding surround.
- `W291196370-ENTRY`: complete dark personnel entry and immediate frame/surround; stairs/ramp/rails excluded.
- `W291196370-SERVICE`: complete pale gray-green roll-up/service opening with full frame and siding return.
- `W291196370-ACCENT`: short red-brown base/landing accents are localized regions, not global cadence.

The shell reads tall one-storey/internally subdivided and is broadly compatible with `6 m`, but level count is unproven. Siding course width, trim width, window/service dimensions, divider cadence and material scale are unknown. No module may be resized to fit a generated run.

| Output | Status |
|---|---|
| `homogeneous_material_tile` | **reference-ready, scale-calibration required** for horizontal siding field |
| `architectural_pattern_tile` | **blocked**; dividers recur but no stable opening/divider cell exists |
| `module_atlas` | **reference-ready, placement/scale-blocked** for complete window/entry/service modules |
| `unique_elevation` | **SSE/ENE concept-ready, mapping-blocked** |

Legal seams: uninterrupted siding or verified full divider/complete-module boundary. A divider boundary becomes legal only when course continuity and ownership are proved. Forbidden: U reset; siding course mismatch; divider interior; window/door/service opening; parapet edge; corner/short facet; ramp/stair/rail; fence/container/vehicle/sign; ambiguous yard overlap. Edge products must preserve course height and reconstruct complete motifs.

Do not transfer `w34313564` colors, repeat tenant signage, infer rear/west end, treat every divider as periodic, bake access/yard geometry into art, or stretch modules across short facets.

## Reserved Godot BOM and geometry boundary

| ID | Planned path / status |
|---|---|
| `MAT` | `res://game/resources/materials/world/w291196370/` — siding/trim/accent studies |
| `ATLAS/MOD` | `res://game/resources/textures/buildings/w291196370/w291196370_modules`; `res://game/scenes/world/facades/w291196370/w291196370_modules.tscn` |
| `LAYOUT/ATTACH` | `res://game/resources/facades/w291196370_layout.json`; `res://game/scenes/world/facades/w291196370/w291196370_facade.tscn` — blocked |

```text
before: building:w291196370:wall is the exact 6 m, 36-run placeholder spray receiver.
after:  source/height/silhouette/roof/footprint/opening and access geometry/foundation,
        terrain/topology/collision/navigation/spray/generated contracts remain;
        only accepted shallow visuals may later attach to exact observed chains.
```

## Acceptance gates and blockers

- [ ] Preserve `36 / 258.421 m`, ten groups/short facets, `6 m`, base/top, chunk and roles.
- [ ] Calibrate siding course/module scale on the exact wall; preserve course continuity.
- [ ] Atlas openings are complete; stairs/ramp/rails/sign/yard objects remain excluded.
- [ ] Exact ordered endpoints precede placement; NNW/WSW and ambiguous facets stay placeholder.
- [ ] Whole-object recognition remains separate and blocked by rear/end/massing detail.

Prototype: **bounded-ready**. Live: **blocked**. Whole object: **reference/placement-blocked**.

```yaml
schema_version: codex.building-texture-research/1
target: {canonical_name: null, id: w291196370, receiver: 'building:w291196370:wall', identity_confidence: high_coordinate_match}
sources: [B06-LOCAL-W291196370, B06-W291196370-SV01, B06-W291196370-SV02]
observed_regions: [SSE_public, ENE_end, limited_service_return]
unobserved_regions: [NNW, WSW, yard_obscured_facets, exact_endpoints]
outputs: {homogeneous_material_tile: reference_ready_scale_blocked, architectural_pattern_tile: blocked, module_atlas: reference_ready_placement_scale_blocked, unique_elevation: SSE_ENE_concept_ready_mapping_blocked}
smallest_cell: {status: nonperiodic_complete_modules, modules: [W291196370-WINSTACK, W291196370-ENTRY, W291196370-SERVICE]}
legal_seams: [uninterrupted_siding, verified_full_divider, complete_module_boundary]
forbidden_seams: [generated_U_reset, siding_course_mismatch, divider_interior, opening, parapet_edge, corner_short_facet, access_geometry, occlusion, tenant_sign]
research_verdict: {ready_for_generation: true, ready_subset: [siding_scale_study, complete_opening_atlas_study], ready_for_attachment: false, blockers: [siding_scale_unknown, divider_cadence_unknown, endpoint_mapping_missing, NNW_WSW_unobserved]}
```

# `w34313520` facade reference specification

Checked: **2026-08-29**
Target: **unnamed `w34313520` / `building:w34313520:wall`**
Mode: **research and implementation handoff only**

## Receiver-first verdict

One September 2025 official panorama identifies the standing coordinate-matched footprint and strongly supports the SSE pale institutional field plus complete stacked window/pier bays. All other sides, exact endpoints, ground openings, physical scale and ownership of a low glazed wing remain unknown. Material/bay prototypes are bounded-ready; live placement and whole-object resemblance are blocked.

## Exact identity and receiver

| Item | Exact local evidence |
|---|---|
| Source | OSM way `34313520`, v3, `2018-01-22T18:56:09Z`; `building=yes`, `height=11`, historic `source=Yahoo`; no name/address/use/levels |
| Objects/chunk | logical `building:w34313520`; wall `building:w34313520:wall`; roof `building:w34313520:roof`; `x_-1__z_0` |
| Meters | area `2,871.747 m²`; serialized/visible `376.238 / 376.239 m`; height `11 m`; base/top `3.065 / 14.065 m` |
| Topology | `34` exterior runs, no shared runs; ENE `7/46.774 m + 3/19.019`; SSE `7/122.335`; WSW `6/65.779`; NNW `2/13.312 + 9/109.020` |
| Runtime | wall `building_wall -> plaster_grey_04`, opaque/sole spray receiver; roof `building_roof -> bitumen`, opaque collider/non-spray |

## Provenance and coverage

| Evidence ID | Exact source | Coverage / limit |
|---|---|---|
| `B06-W34313520-SV01` | [official pano `9DMpaJdFAYWd6KRR3NBbKA`](https://www.google.com/maps/@?api=1&map_action=pano&pano=9DMpaJdFAYWd6KRR3NBbKA&heading=0&pitch=2&fov=78), requested `37.82245,-122.37290`, north, **September 2025** | long SSE-facing elevation; resolved camera coordinate was not retained |
| `B06-LOCAL-W34313520` | [`FACADE_RECEIVER_INVENTORY.json`](../FACADE_RECEIVER_INVENTORY.json), [`NEXT_FACADE_BATCH_06.md`](NEXT_FACADE_BATCH_06.md), [`BATCH_06_STREETVIEW_OBSERVATIONS.md`](BATCH_06_STREETVIEW_OBSERVATIONS.md) | exact local contract plus observation bounds |

Observed: SSE long elevation. Unobserved: ENE, WSW, NNW, short/re-entrant facets, exact endpoints/corners. Coordinate identity is **high**; canonical name/use remains source-key-only. The glazed/entry-like wing at view right has unresolved ownership and is excluded. No imagery is stored.

## Material families, scale, modules and seams

`W34313520-MAT-PALE` is pale warm gray/off-white smooth painted concrete/render-like field, matte to low-satin. `MAT-FRAME` is dark gray/blue frame and muted glazing. `MAT-LOWER` is a darker blue-gray lower/recess family with unresolved boundaries.

`W34313520-BAY` is one complete three-tier horizontal-window group with its full dark frames, pale pier boundaries and visible solid field. Entry/recess/wing fragments are not modules. Three visible tiers are broadly compatible with the `11 m` receiver but not a measured level count. Bay width, tier height, pier width, finish scale and roughness values are unknown; prototype scale must remain exposed for later exact-receiver calibration.

| Output | Status |
|---|---|
| `homogeneous_material_tile` | **reference-ready, scale-calibration required** for pale field |
| `architectural_pattern_tile` | **blocked**; no smallest bay period, alternates or seam products proven |
| `module_atlas` | **reference-ready, placement/scale-blocked** for complete `BAY` only |
| `unique_elevation` | **SSE concept-ready, mapping-blocked** by endpoints/occluded ground/wing ownership |

Legal seams: uninterrupted pale field or complete verified `BAY` outer boundary. Forbidden: U reset, glazing, mullion, pier, tier, roof edge, corner, entry/recess, landscaping/fence occlusion, lower transition, and uncertain wing junction. Every edge product must remain field-only or reconstruct the same complete bay. Do not copy `w34313515`, attach the glazed wing, infer hidden sides/doors, regularize bay alternates or flatten recess depth.

## Reserved Godot BOM and geometry boundary

| ID | Planned path / status |
|---|---|
| `MAT` | `res://game/resources/materials/world/w34313520/` — pale field/frame/glass studies |
| `ATLAS/MOD` | `res://game/resources/textures/buildings/w34313520/w34313520_modules`; `res://game/scenes/world/facades/w34313520/w34313520_modules.tscn` — complete bay only |
| `LAYOUT/ATTACH` | `res://game/resources/facades/w34313520_layout.json`; `res://game/scenes/world/facades/w34313520/w34313520_facade.tscn` — blocked |

```text
before: building:w34313520:wall is the exact 11 m, 34-run placeholder spray receiver.
after:  source/massing/roof/footprint/recess geometry/foundation/terrain/topology,
        collision/navigation/spray and generated data remain; only accepted shallow
        visuals may later attach to reconciled SSE runs.
```

## Acceptance gates and blockers

- [ ] Preserve SSE-only claim and unresolved pano camera coordinate.
- [ ] Preserve `34 / 376.239 m`, `11 m`, base/top, chunk and no-shared-run contract.
- [ ] Calibrate physical scale on receiver and prove complete bay edge products.
- [ ] Exclude wing/entry/recess until ownership/full bounds are proven.
- [ ] Map ordered endpoints before placement; keep ENE/WSW/NNW placeholder.
- [ ] Whole-object verdict remains blocked independently of material/module readiness.

Prototype: **bounded-ready**. Live: **blocked by scale/endpoints/other sides**. Whole object: **reference-blocked**.

```yaml
schema_version: codex.building-texture-research/1
target: {canonical_name: null, id: w34313520, receiver: 'building:w34313520:wall', identity_confidence: high_coordinate_match}
sources: [B06-LOCAL-W34313520, B06-W34313520-SV01]
observed_regions: [SSE_long]
unobserved_regions: [ENE, WSW, NNW, short_reentrant_facets, exact_endpoints, occluded_ground]
outputs: {homogeneous_material_tile: reference_ready_scale_blocked, architectural_pattern_tile: blocked, module_atlas: reference_ready_placement_scale_blocked, unique_elevation: SSE_concept_ready_mapping_blocked}
smallest_cell: {status: complete_module_only, modules: [W34313520-BAY]}
legal_seams: [uninterrupted_pale_field, complete_bay_boundary]
forbidden_seams: [generated_U_reset, glazing, mullion, pier, tier, roof_edge, corner, entry, recess, occlusion, uncertain_wing]
research_verdict: {ready_for_generation: true, ready_subset: [pale_field_scale_study, complete_bay_atlas_study], ready_for_attachment: false, blockers: [physical_scale_unknown, cadence_unknown, endpoint_mapping_missing, wing_ownership_unknown, other_sides_unobserved]}
```

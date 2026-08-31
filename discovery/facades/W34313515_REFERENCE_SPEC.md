# `w34313515` facade reference specification

Checked: **2026-08-29**
Target: **unnamed `w34313515` / `building:w34313515:wall`**
Mode: **research and implementation handoff only**

## Receiver-first verdict

Two September 2025 official views identify the coordinate-matched standing footprint with high confidence and support its WSW/NNW pale painted-field hierarchy plus complete window-bay and vertical-recess module families. No frozen name, address, use or level count exists. ENE/SSE chains, exact run endpoints, ground ownership, physical motif scale and a smallest global cadence remain unknown. Material/module prototypes are bounded-ready; placement, unique elevations, live attachment and whole-object resemblance remain blocked.

## Exact identity and receiver

| Item | Exact local evidence |
|---|---|
| Source | OSM way `34313515`, v3, `2018-01-25T17:34:27Z`; `building=yes`, `height=11`, historic `source=Yahoo`; no name/address/use/levels |
| Objects/chunk | logical `building:w34313515`; wall `building:w34313515:wall`; roof `building:w34313515:roof`; `x_-1__z_1` |
| Meters | area `4,185.713 m²`; serialized/visible perimeter `546.655 / 546.656 m`; height `11 m`; base/top `3.357 / 14.357 m` |
| Topology | `48` exterior runs, no shared runs; ENE `3/29.885 m + 8/67.778`; SSE `15/175.673`; WSW `9/97.649`; NNW `13/175.671` |
| Runtime | wall `building_wall -> plaster_grey_04`, opaque/sole spray receiver; roof `building_roof -> bitumen`, opaque collider/non-spray |

Generated U restarts per run and V is world-y based; neither is evidence of architectural phase.

## Provenance, observed sides and confidence

| Evidence ID | Exact official source | Coverage / limit |
|---|---|---|
| `B06-W34313515-SV01` | [pano `kEX8mV7OsuHLoA4oK69_KA`](https://www.google.com/maps/@?api=1&map_action=pano&pano=kEX8mV7OsuHLoA4oK69_KA&heading=36&pitch=2&fov=75), actual `37.8209027,-122.3722808`, NE, **September 2025** | high-confidence WSW long elevation |
| `B06-W34313515-SV02` | [pano `XinlFktyE0_U2KP7tU6mfg`](https://www.google.com/maps/@?api=1&map_action=pano&pano=XinlFktyE0_U2KP7tU6mfg&heading=110&pitch=2&fov=78), actual `37.8216329,-122.3727587`, SE, **September 2025** | high-confidence NNW long elevation and limited return |
| `B06-LOCAL-W34313515` | [`FACADE_RECEIVER_INVENTORY.json`](../FACADE_RECEIVER_INVENTORY.json), [`NEXT_FACADE_BATCH_06.md`](NEXT_FACADE_BATCH_06.md), [`BATCH_06_STREETVIEW_OBSERVATIONS.md`](BATCH_06_STREETVIEW_OBSERVATIONS.md) | exact local contract plus observation bounds |

Observed: WSW and NNW long elevations, limited corner return. Unobserved: ENE, SSE, re-entrant/short facets, exact endpoints and occluded ground. Coordinate-footprint identity is **high**; canonical name/use remains **source-key-only**. No imagery is stored.

## Material families, physical scale and motif grammar

- `W34313515-MAT-PALE`: pale warm gray/off-white smooth painted concrete/render-like field, matte to low-satin; only subordinate nonsemantic variation is legal.
- `W34313515-MAT-DARK`: cool dark-gray frames/mullions and muted blue-gray glazing; separate frame/glass channels, never baked shadows.
- `W34313515-MAT-LOWER`: darker lower/recess value family is observation-supported but **region-boundary blocked** by fencing/vegetation.
- `W34313515-BAY`: one complete broad horizontal window group across the visible three-tier stack, including its full dark frame/mullions and pale outer pier boundary. A fragment or single tier is not this module.
- `W34313515-VRECESS`: one complete vertical access/stair/open-bay recess from its two pale outer boundaries through the visible roof/lower transitions; only a fully visible instance qualifies.

The three-tier read and generated `11 m` wall are compatible but not a measured storey contract. Window width/height, pier width, tier height, bay/recess period and material grain are **unknown**. No accepted metre scale exists; prototypes must expose physical scale for later receiver calibration and cannot treat the `11 m` generated height as a measurement of visible motifs.

| Output | Classification / smallest-repeat rationale |
|---|---|
| `homogeneous_material_tile` | **reference-ready, scale-calibration required** for `MAT-PALE`; lower field remains boundary-blocked |
| `architectural_pattern_tile` | **blocked**; candidate bay rhythm has unknown alternates/period and no proven edge products |
| `module_atlas` | **reference-ready, placement/scale-blocked** for complete `BAY` and fully bounded `VRECESS` only |
| `unique_elevation` | **WSW/NNW concept-ready, mapping-blocked**; no combined/all-side elevation |

Legal seams: uninterrupted pale field or the verified full outer boundary of a complete `BAY`/`VRECESS`. Forbidden: generated U reset; glazing/mullion/pier; tier boundary; recess; unresolved lower transition; roof edge; corner; fence/vegetation occlusion; unseen side. Left/right, top/bottom and four-corner products must remain homogeneous field or reassemble the same complete bounded module; no partial window/recess may join.

Do not infer ENE/SSE language, regularize recess intervals, invent podium/belt/doors, turn three tiers into an approved story count, transfer from `w34313520`, or paint roof/recess depth as flat texture.

## Reserved Godot BOM

| ID | Planned path / status |
|---|---|
| `MAT` | `res://game/resources/materials/world/w34313515/` — pale field plus separate frame/glass studies |
| `ATLAS` | `res://game/resources/textures/buildings/w34313515/w34313515_modules` — complete bay/recess atlas, scale-blocked |
| `MOD` | `res://game/scenes/world/facades/w34313515/w34313515_modules.tscn` — shallow, noncolliding render modules only |
| `LAYOUT` | `res://game/resources/facades/w34313515_layout.json` — blocked pending ordered observed-side endpoints |
| `ATTACH` | `res://game/scenes/world/facades/w34313515/w34313515_facade.tscn` — blocked from live receiver |

## Geometry boundary and before -> after

```text
before: building:w34313515:wall is the exact 11 m, 48-run placeholder spray receiver.
after:  all source IDs, height, silhouette, roof, footprint, structural recesses,
        foundation/terrain, topology, collision/navigation and spray roles remain;
        only independently accepted shallow visuals may later attach to mapped sides.
```

## Acceptance gates and blockers

- [ ] Evidence IDs/dates/directions and WSW/NNW-only coverage remain attached to every claim.
- [ ] `48 / 546.656 m`, height/base/top, chunk, material roles and no-shared-run contract remain exact.
- [ ] Physical scale is calibrated on the exact receiver before material/module acceptance.
- [ ] Atlas contains complete `BAY`/`VRECESS`; no partial motif survives an edge.
- [ ] Ordered endpoint reconciliation precedes placement; ENE/SSE and occluded ground stay placeholder.
- [ ] Whole-object review remains separate and cannot pass from two material/module sides.

Primary blockers: physical scale, exact cadence/alternates, observed-side endpoints, lower-region ownership and two unseen sides. Prototype: **bounded-ready**. Live: **blocked**. Whole object: **reference/placement-blocked**.

```yaml
schema_version: codex.building-texture-research/1
target: {canonical_name: null, id: w34313515, receiver: 'building:w34313515:wall', identity_confidence: high_coordinate_match}
sources: [B06-LOCAL-W34313515, B06-W34313515-SV01, B06-W34313515-SV02]
observed_regions: [WSW_long, NNW_long, limited_return]
unobserved_regions: [ENE, SSE, short_reentrant_facets, exact_endpoints, occluded_ground]
outputs: {homogeneous_material_tile: reference_ready_scale_blocked, architectural_pattern_tile: blocked, module_atlas: reference_ready_placement_scale_blocked, unique_elevation: observed_sides_concept_ready_mapping_blocked}
smallest_cell: {status: complete_modules_only, modules: [W34313515-BAY, W34313515-VRECESS]}
legal_seams: [uninterrupted_pale_field, complete_module_outer_boundary]
forbidden_seams: [generated_U_reset, glazing, mullion, pier, tier, recess, unresolved_lower_transition, roof_edge, corner, occlusion]
research_verdict: {ready_for_generation: true, ready_subset: [pale_field_scale_study, complete_module_atlas_study], ready_for_attachment: false, blockers: [physical_scale_unknown, cadence_unknown, ordered_endpoint_mapping_missing, unseen_ENE_SSE]}
```

# Housing row family study

[housing_row_family.gd](../../scripts/world/facades/housing_row_family.gd) assembles shared fixed-width bays, terminal caps and canopy modules. It reuses the 1232 opening and entry helpers; dimensions and cadence are production inference. These are visual study layouts, not address-specific replacements or accepted live buildings.

The JSON files in this folder are inputs of the static-world bake. [export_presets.cfg](../../../export_presets.cfg) leaves them out of every exported pack, so nothing the exported game reads while it plays can be one of them.

Select [short_row.tres](short_row.tres) (3 bays, 2 canopy spans) or [long_row.tres](long_row.tres) (5 bays, 4 spans starting at bay 1). Duplicate a resource for another configuration rather than copying the builder. The resource fields are:

| Field | Meaning |
|---|---|
| `bay_count` | 1–8 fixed 6 m bays; openings retain their size. |
| `canopy_start` | Zero-based first covered bay. |
| `canopy_bays` | Number of covered bays; zero removes the canopy. Start plus extent must not exceed `bay_count`. |
| `walls`, `doors` | Semantic colors; each assembled instance has its own materials. |

Keep one family object to share its module meshes across instances. Duplicate the config before changing a loaded resource in memory:

```gdscript
var family = preload("res://game/scripts/world/facades/housing_row_family.gd").new()
var config = preload("res://game/resources/housing_family/short_row.tres").duplicate(true)
config.bay_count = 4
config.canopy_start = 1
config.canopy_bays = 3
config.walls = Color("3979b5")
config.doors = Color("ba3028")
var house = family.instantiate(config)
add_child(house)
house.position = Vector3(12, 0, -8)
house.rotation.y = deg_to_rad(90)
```

Coordinates are metres: the row begins at local X=0, grows along +X, fronts +Z and extends 8 m toward −Z. Place and rotate the root at scale 1; change bay count rather than stretching the root. Palette changes are applied at instantiation, so rebuild an instance after editing its config.

The family has no standalone demo; check it in the real island with `game/tests/shared/building_shots.gd` and `building_fit_test.gd`.

## Separate housing-instance experiment

The owner-authorized `experiment/housing-family-instances` branch starts at `9c7f2440d3db6a7f2d0a5d474c612c0362a01c16` for A/B comparison with MAIN. Its [canonical target inventory](../../../discovery/HOUSING_FAMILY_INSTANCES.md) records current photo-confirmed, written-only and imagery-insufficient coverage separately from the frozen 23-target A/B capture. The straight prototype needs stepped runs, target opening schedules and appropriate roof/canopy variants before site use; a matching palette or six-metre cadence alone does not establish a fit. Keep per-target identity/grade/geometry and independent acceptance checks even when geometry is shared.

## Opt-in unit details (live family, `housing_unit_detail.gd`)

The live producer, [housing_site_family.gd](../../scripts/world/facades/housing_site_family.gd), reads one JSON config per building (`w*.json` here, listed in `live_instances.json`). The keys below are opt-in: a config without them builds exactly as before. They were piloted on 1232 Northpoint Drive (`w96215673.json`, 2026-11-19), the only building that sets them. Add one only for a side a dated photo shows, and record the photo in the key's `evidence`.

| Key | Meaning |
|---|---|
| `window_blinds` | Blinds and curtains behind the glass of every front window: `rgbs`, `drops` (share of a pane covered from its head down; 0 none), `curtain_share`, `curtain_widths`, `curtain_rgbs`, `hem_shade`, `pleat_shade`, `roughness`, `metallic`, `receive_shadows` (false keeps them out of the reveal's shadow, as Dorm 369's blinds), `seed`. Visual only: no collision. |
| `utility_kit` + an entry's `utilities` | Kit items (`form` condenser, cabinet, enclosure or bin; `size_m` [w, h, d]; `rgb`) and per-door rows: `{"side": 1 or -1, "items": [...], "start_m": m, "ground_y": y}`. Items stand in a row along the wall from the door's trim, on the visible ground at `ground_y`; each has one plain box collider. The build fails if one would stand in the building or on a door landing (door width plus 0.25 m each side, 1.3 m deep). |
| a `pipes` entry's `"style": "downspout"` | A downspout instead of the plain pipe: gooseneck from the eave trim, straps, kick-out and splash block. It steps out round the storey band, or under a `lower_frontage_recess` bends back to the lower wall below the overhang. |
| `roof_plane` | The roof the roof details follow, one gable per footprint segment in the production roof's frame: `axis` and `normal` [x, z], `ridge_d`, `slope`, `segments` [{`ridge_offset`, `ridge_y`}], `cuts` [{`west_t`, `east_t`, `jog_d`}] between neighbours (a point lies before a cut where t <= `west_t` if d >= `jog_d`, else `east_t`) and `extent_t`. |
| `roof_vents` | Vent stacks and box vents along each segment's ridge: `spacing_m`, `jitter_m`, `offset_m` [min, max] from the ridge, `back_share`, `stack_share`, `margin_m`, `avoid` (existing vents), `rgb`, `seed`. |
| `gable_rakes` | `{"runs": [...], "overhang_m", "board_m", "soffit_drop_m", "edge_m"}`: the roof carried out over those gable runs, the roofing's edge `edge_m` past a rake board, a soffit under it, in place of those runs' eave trim; `top_rgb`, `board_rgb`, `soffit_rgb`. |
| `end_annexes` | A photographed block on an end wall: `run`, `from_m`/`to_m` along it, `depth_m` out, `base_y`, `top_y`, a two-leaf `door` {`out_m`, `width_m`, `height_m`, `bottom_y`, `rgb`} in its end face, `flues`, `roof_rgb`. It stands outside the frozen OSM footprint, so it needs a recorded owner exception: `osm_exception` {`reason`, `approved`, `photo`, `outline_xz`}, and the source on `ANNEX_EXCEPTION_SOURCES` in `housing_unit_detail.gd` (1232's north-end annex, owner 2026-11-19). Walls collide as walls, the rest as support. |
| `window_sill_out_m` | How far window sills stand out of the wall (default 0.26 m). |
| `window_glass` | `{"roughness", "metallic"}` of the panes (default 0.24, 0.22). |
| `siding_course_shadow` | 0-1: the lap shadow under each siding course (the siding shader's `course_shadow`, zero for every other building). |
| `vertical_seams: "corners"` | Trim boards only where the wall turns, not at every source-run split (`true` keeps the old behaviour). |
| `lower_frontage_recess.join_runs` | With the existing lower-frontage setback: neighbours come from the wall ring, so collinear runs in different frames meet without the 0.05 m terminal strips, and an unrecessed gable beside the setback is notched under the overhang. Corner boards split at the soffit. |
| `lower_frontage_recess.soffit_rgb` | The setback's soffit in its own colour instead of the trim's, such as the overhang's shadow line. |
| `lower_frontage_recess.shade_m`, `shade` | The lower wall's top `shade_m` in the overhang's shade: two strips of the siding darkened toward the soffit (`shade` the darkest factor). |
| `story_band` | `{"depth_m", "height_m"}`: a slimmer storey band board (default 0.20 x 0.09 m); `height_m` 0 draws none, leaving an overhang's soffit as the floor line. |
| a lower window's `"glazing": "sidelight"` | A full-height glazed sidelight beside a door. |
| carport `underside_rgb`, `joist_spacing_m`, `joist_rgb`, `fascia_top_rgb`, `post_bands`, `fascia_seam_m`, `fascia_seam_rgb` | A lighter soffit with cross joists, a weathered strip on the fascia, board joints across the fascias every `fascia_seam_m` and painted bands on the posts (`[[from_m, to_m, rgb], ...]` up from a post's foot, each stopping at the post's top). |

1232's own production roof and frontage (`northpoint_1232_quality_model.gd`) take theirs from `../facades/northpoint_1232_quality_revision.json`: `roof_segments` (the same segments and cuts as `roof_plane`), `frontage_parking_from_m` and `frontage_asphalt_rgb`.

`game/tests/headless_housing_unit_detail_contract.gd` checks these behaviours on 1232. Every detail kept here is per building; switching the set on for another building is that building's own change, with its own photos and reviews.

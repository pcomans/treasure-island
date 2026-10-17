# Modern mid-rise family

[midrise_family.gd](../../scripts/world/facades/midrise_family.gd) builds a flat-roofed courtyard apartment building over one frozen OSM footprint from a JSON config. It shares the [housing family installer](../../scripts/world/facades/housing_family_live_attachment.gd): register an instance in [live_instances.json](../housing_family/live_instances.json) with `"family": "midrise"`. Its grammar follows the accepted Maceo May study next door: pale render, recessed glazing with dark frames, a darker base, glazed lobbies and loggias, as reusable bays rather than baked geometry.

Instances: [w1272162518.json](w1272162518.json) (490 Avenue of the Palms) and [w1212173437.json](w1212173437.json) (Star View Court). Dimensions, cadence and unseen sides are production inference.

## How it builds

1. The wall record's runs give the footprint edges `e0`… in ring order (`target.edge_normals` must match them). The frozen land triangles give the terrain. The ground floor sits `floor.above_terrain` above the median terrain along `floor.anchor_edge`, the photographed street side. Lower terrain elsewhere exposes the plinth; higher terrain meets the walls, and ground-storey sills rise to 0.25 m above it with their heads kept.
2. Each block is the footprint clipped by `clip` constraints, all relative to a footprint edge `k`: `min`/`max` inward distance, `s_min`/`s_max` station cuts across the edge, and `taper` `[s0, d0, s1, d1]`, a line between two (station, depth) points (`taper_keep: "outer"` keeps the outside). Blocks must not overlap; together they normally tile the footprint.
3. Walls appear only where a block rises above its neighbours or the ground, so the outer ring stays the footprint. Each exposed block edge is a face keyed `e<k>` (within 2.5 m of footprint edge k and facing the same way), `court` (above neighbouring roofs only) or `return` (other ground-reaching faces). `faces` maps these keys, or `default`, to a scheme.
4. Roofs are flat at the top storey, with a parapet (`parapet.h`, `parapet.t`) or a glass `railing` on exposed edges. `roof_items` are boxes in edge coordinates (`edge`, station range `s`, depth range `d`, `h`): `pv` rows, penthouses, plant or planters.
5. `aprons` pave set-back strips between a block face and the footprint line, on the terrain.

## Blocks

| Field | Meaning |
|---|---|
| `id` | Unique name. |
| `storeys` | Storey count; heights come from `levels.ground_h` and `levels.storey_h` unless the block sets `ground_h`/`storey_h`. |
| `clip` | Constraint list, see above. |
| `faces` | Face key to scheme name. |
| `parapet` | `h`, `t`; `kind: "railing"` with `curb` for decks. `h: 0` means no parapet. |
| `roof_material`, `roof_items` | Roof surface material and items. |

## Schemes

A scheme fills one face with bays. Single-bay `features` sit at their stations (footprint-edge stations on `e<k>` faces, face-local on `court`/`return`; negative counts from the end); `bays` and `blank` ranges override the filler between them. Filler bays split each gap at `module` without stretching openings.

| Field | Meaning |
|---|---|
| `material`, `ground_material`, `parapet_material` | Wall materials (palette keys). |
| `plinth` | `material` from the terrain up to `top` above the floor. |
| `base` | `material` for the lowest `storeys`. |
| `bands` | Horizontal stripes: `storey`, `offset`, `h`, `material`. |
| `end_pilasters` | Stripes `w` wide at both face ends, up to `to_storey`. |
| `window`, `window_storeys` | Upper-storey window `w`, `h`, `sill`, `depth`, `mullions`/`transoms` (fractions), `frame`, `frame_w`, `glass`; per-storey overrides by index. |
| `ground` | Ground-storey `kind`: `window`, `patio` (railing over a tall plinth), `storefront` (`pier`, `head`) or `blank`. |
| `stagger` | Deterministic window `offsets` and `mix` variants from `from_storey`. |

Feature types: `loggia` (`storeys`, `depth`, `pier`), `frame` (a multi-storey recess over `storeys` `[k0, k1]`), `band` (a dark vertical window/spandrel stack), `entry` (`door.kind` `unit`, `lobby` or `porch`, plus `canopy`, `landing` and `screens`), `garage`, `vents` and `corner` (a window aligned to the face end). A feature may also set `material`, `material_from`/`material_to`, `window`, `window_storeys`, `ground` and `upper`.

Entry landings are flat walkable pads at the highest terrain under them plus 0.1 m, with skirts of at most 40 degrees into the ground. Doors sit on the landing, so there are no steps to walk-test.

## Roles

Facade planes, reveals, glazing and doors are `wall` (spray receivers); roofs and the deck are `roof`; landings and aprons are `ground`; parapets, railings, canopies, slabs and roof items are `support`. The installer turns each role into one source-owned contact body. Check an instance in the real island with `game/tests/shared/building_shots.gd` and `building_fit_test.gd -- --native-producer housing-get-faces`.

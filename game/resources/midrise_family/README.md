# Modern mid-rise family

[midrise_family.gd](../../scripts/world/facades/midrise_family.gd) builds a flat-roofed courtyard apartment building over one frozen OSM footprint from a JSON config. Opt-in [outbuilding fields](#outbuilding-fields) also cover sheds, tanks and basins, trailers and pavilions. It shares the [housing family installer](../../scripts/world/facades/housing_family_live_attachment.gd): register an instance in [live_instances.json](../housing_family/live_instances.json) with `"family": "midrise"`. Its grammar follows the accepted Maceo May study next door: pale render, recessed glazing with dark frames, a darker base, glazed lobbies and loggias, as reusable bays rather than baked geometry.

Instances: [w1272162518.json](w1272162518.json) (490 Avenue of the Palms) and [w1212173437.json](w1212173437.json) (Star View Court). Dimensions, cadence and unseen sides are production inference.

## How it builds

1. The wall record's runs give the footprint edges `e0`… in ring order (`target.edge_normals` must match them). The frozen land triangles give the terrain. The ground floor sits `floor.above_terrain` above the median terrain along `floor.anchor_edge`, the photographed street side, or around the whole footprint for `"ring"`. Lower terrain elsewhere exposes the plinth; higher terrain meets the walls, and ground-storey sills rise to 0.25 m above it with their heads kept.
2. Each block is the footprint clipped by `clip` constraints, all relative to a footprint edge `k`: `min`/`max` inward distance, `s_min`/`s_max` station cuts across the edge, and `taper` `[s0, d0, s1, d1]`, a line between two (station, depth) points (`taper_keep: "outer"` keeps the outside). Blocks must not overlap; together they normally tile the footprint.
3. Walls appear only where a block rises above its neighbours or the ground, so the outer ring stays the footprint. Each exposed block edge is a face keyed `e<k>` (within 2.5 m of footprint edge k and facing the same way), `court` (above neighbouring roofs only) or `return` (other ground-reaching faces). `faces` maps these keys, or `default`, to a scheme.
4. Roofs are flat at the top storey, with a parapet (`parapet.h`, `parapet.t`) or a glass `railing` on exposed edges. `roof_items` are boxes in edge coordinates (`edge`, station range `s`, depth range `d`, `h`): `pv` rows, penthouses, plant or planters.
5. `aprons` pave set-back strips between a block face and the footprint line, on the terrain.

## Blocks

| Field | Meaning |
|---|---|
| `id` | Unique name. |
| `storeys` | Storey count; heights come from `levels.ground_h` and `levels.storey_h` unless the block sets `ground_h`/`storey_h`. |
| `floor_raise` | Raises this block's floor above the building floor (a trailer on a skirt). |
| `clip` | Constraint list, see above. |
| `faces` | Face key to scheme name. |
| `parapet` | `h`, `t`; `kind: "railing"` with `curb` for decks (`style: "pipe"` for a steel guard rail). `h: 0` means no parapet. |
| `roof` | Pitched roof (see below); flat when absent. |
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
| `window`, `window_storeys` | Upper-storey window `w`, `h`, `sill`, `depth`, `mullions`/`transoms` (fractions), `frame`, `frame_w`, `glass`; per-storey overrides by index. Opt-in `hood`: a box over the head (`depth`, `h`, `over` each side, `gap`, side `cheek` length and thickness `t`, `material`), support role; also on `ground` windows and storefronts. |
| `ground` | Ground-storey `kind`: `window`, `patio` (railing over a tall plinth), `storefront` (`pier`, `head`) or `blank`. |
| `stagger` | Deterministic window `offsets` and `mix` variants from `from_storey`. |

Feature types: `loggia` (`storeys`, `depth`, `pier`), `frame` (a multi-storey recess over `storeys` `[k0, k1]`), `band` (a dark vertical window/spandrel stack), `entry` (`door.kind` `unit`, `lobby` or `porch`, plus `canopy`, `landing` and `screens`), `garage`, `vents`, `corner` (a window aligned to the face end), and the opt-in `stair_bay` and `top_box` (see the outbuilding fields table). A feature may also set `material`, `material_from`/`material_to`, `window`, `window_storeys`, `ground` and `upper`.

Entry landings are flat walkable pads at the highest terrain under them plus 0.1 m, with skirts of at most 40 degrees into the ground. Doors sit on the landing, so there are no steps to walk-test.

## Outbuilding fields

All are opt-in; configs without them build as before. Materials are shared across instances by value and never changed after creation. Out-of-range values fail the build (`build_valid` false): `pitch_deg` outside (0, 60], roof `t` outside (0, 1] m, `overhang` outside [0, 3] m, `floor_raise` outside [0, 10] m, knee `h` outside (0, 4] m or `t` outside (0, 1] m, deck `t` outside (0, 2] m; so does any non-finite vertex.

| Field | Meaning |
|---|---|
| block `roof` | `form`: `gable` (ridge parallel to footprint edge `ridge_edge`), `mono` (falls toward edge `low_edge`) or `pyramid` (hip or pavilion); `pitch_deg`, `overhang`, slab thickness `t`, and `under`/`fascia` materials (the top is `roof_material`). The block outline must be convex; its walls stop at the eave and the gable or lean-to infill above it follows the roof. |
| parapet `style: "pipe"` | Posts and top and mid rails instead of glass panels, over the `curb` (tank tops, basin rims, roofs). |
| scheme `open` | Posts (`post_w`, `module`, `post_material`; `post_every` keeps one face start in n) instead of a wall, optionally over a `knee` wall (`h`, `t`, `material`, entrance `gap` in stations). |
| scheme `gable_material` | Material of the infill above the eave. |
| feature `vents` `windows: true` | Keeps the ground-storey window in the louvres' bay (louvres under windows). |
| target `holes` | Number of courtyard holes: further closed rings after the outer ring in the wall record. Each hole must lie wholly inside one flat block, which builds full-height courtyard walls (face key `hole`, else `default`), parapets and its roof around it. Absent means a single ring, as before. |
| block `deck` | A flat roof carried as a slab over `open` sides: thickness `t` and `material` of its underside and of the fascia on the open faces. |
| block `pergola` | Open timber pergola instead of a roof slab on a flat convex block (normally with `open` sides and no `deck` or `roof_items`): beams `beam_w` x `beam_h` round the outline under the roof line, and rafters `rafter_w` x `rafter_h` on them every `spacing`, at right angles to footprint edge `rafter_edge`, in `material` (default `timber`). Support role. A pergola block never hides a neighbouring block's wall, so the wall behind it reaches the ground. Out-of-range sizes fail the build. Pair it with an `apron` for a deck floor. |
| top-level `ext_stairs` | Straight open steel flights outside a wall: each entry runs along footprint edge `edge`, `gap` (0-0.5 m) out from it with clear width `w` (0.6-1.6 m), from grade at station `foot` up to a landing at floor `storey` (an upper floor) of block `block` that starts at station `top` and ends at `landing_end` (at least 0.8 m on), `landing_depth` (gap + w to 3 m) out from the wall, on two posts. Risers are about 0.18 m and goings must come out at 0.22-0.36 m. Treads, landing, stringers, the outer handrail, landing rails and posts are `support` in `material` (default `rail`; treads `tread_material`). The walking surface is a hidden collision-only `support` ramp through the tread nosings, flush with the landing. List the flight in the catalog `stairs` so the fit test walks it. Invalid input fails the build. |
| feature `ladder` | Caged steel ladder centred on the bay, from 0.3 m above grade to 1 m over the wall top (a fixture, not walkable). |
| entry `landing.at: "floor"` | Deck at the floor level with skirts to grade; with `ramp` (`dir` ±1 along the face, `w`, `slope`, default 1:12) a walkable ramp runs along the facade to grade. `rails` (default with a ramp) adds pipe rails. |
| roof item `cylinder` | Prism of `sides` (default 12) inscribed in the item's station/depth square. Items on pitched roofs stand on the slab. |
| feature `stair_bay` | Open recessed stair bay (at least two storeys): a full-height void `depth` (1.2–4 m, default 2.0) deep inside `pier` (default 0.2) from the feature ends, from the highest grade under its front and back lines up to `head` (default 0.35) below the roof, with a dark `back` wall, `side` reveals (default the wall), a `soffit`, a solid ground-floor guard `guard_h` (default 1.1) high, and per storey two stepped flights around a half landing under a floor landing (all `slab`). A visual recess, not a route; its back wall closes the collision footprint. A clear width under 2 m, a depth outside the range, back corners outside the block or no room between grade and roof fail the build. |
| feature `top_box` | Projecting box on an otherwise blank wall from `below` (default 0.15) under floor `storey` (default the top storey) up to the wall top, `project` (0.05–2 m, default 0.6) out from the wall, inset by `pier`, in `material` (default the scheme material), with one glazed band from its `window` (`sill`, `h`, `inset`, plus the usual glazing fields). It is `support`, so wall geometry stays inside the footprint. A width under 1 m or an out-of-range storey or projection fails the build. |

Parts are emitted into the same role buckets: posts, rails, ladders, pergola beams, fascia and roof undersides are `support`, knee walls and infill are `wall`, ramps are `ground`.

## Roles

Facade planes, reveals, glazing and doors are `wall` (spray receivers); roofs and the deck are `roof`; landings and aprons are `ground`; parapets, railings, canopies, slabs and roof items are `support`. The installer turns each role into one source-owned contact body. Check an instance in the real island with `game/tests/shared/building_shots.gd` and `building_fit_test.gd -- --native-producer housing-get-faces`.

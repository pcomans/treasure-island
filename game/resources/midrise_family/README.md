# Modern mid-rise family

[midrise_family.gd](../../scripts/world/facades/midrise_family.gd) builds a flat-roofed courtyard apartment building over one frozen OSM footprint from a JSON config. Opt-in [outbuilding fields](#outbuilding-fields) also cover sheds, tanks and basins, trailers and pavilions. It shares the [housing family installer](../../scripts/world/facades/housing_family_live_attachment.gd): register an instance in [live_instances.json](../housing_family/live_instances.json) with `"family": "midrise"`. Its grammar began with the Maceo May study: pale render, recessed glazing with dark frames, a darker base, glazed lobbies and loggias, as reusable bays rather than baked geometry.

The JSON files in this folder are inputs of the static-world bake. [export_presets.cfg](../../../export_presets.cfg) leaves them out of every exported pack, so nothing the exported game reads while it plays can be one of them.

Instances: [w1272162518.json](w1272162518.json) (490 Avenue of the Palms), [w1212173437.json](w1212173437.json) (Star View Court), [r19685981.json](r19685981.json) (Maceo May, whose [plan fields](#plan-fields) cover wings of different heights round a court, a curved wing and overhanging upper floors) and, with its [roof edges and parts](#roof-edges-and-parts), [r133351.json](r133351.json) (Building 33 F, Aracely Cafe). Dimensions and cadence are production inference; since 2026-11-03 unphotographed sides get no inferred detail ([AGENTS](../../../AGENTS.md#facade-recognizability-policy)).

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
| `grid` | Opt-in photo window grid in the shared [facade_grid](../../scripts/world/facades/facade_grid.gd) format (`columns`, `rows` per storey or `"*"`, optional `groups`/`blank_cells`, `source`). Columns are footprint-edge stations on `e<k>` faces (face-local on `court`/`return`); rows are relative to each storey's floor. Under a grid, every storey of every bay takes its windows from the grid: module filling, `window`/`ground` placement, `stagger` and `corner` alignment are not used, and `ground.kind: "storefront"`/`"patio"` become grid windows. A feature keeps its own openings only on the storeys it claims (a loggia's `storeys`, a frame's range, an entry's or garage's ground storey, all storeys of a `stair_bay` or `top_box`); its other storeys take grid windows. `ground.kind: "blank"`, `upper: "blank"` and `skip_storeys` still leave their storeys solid. A grid opening joined over storeys is kept only when none of them is claimed or blank. Ground-storey sills rise to 0.25 m above the local grade (heads kept; lights under 0.9 m dropped). Columns wholly beyond a face's ends are left to the scheme's other faces (a face with none is solid and is reported); the grid's rows, groups, cells and source are still validated on every face; columns that straddle a bay edge or a face end, or lose a joined storey, are reported in `midrise_skipped_features`. An invalid grid fails the build. Existing configs give some unphotographed faces an `inferred_from_side` copy; since 2026-11-03 no new copies are added (unphotographed faces stay as they are; see [AGENTS](../../../AGENTS.md#facade-recognizability-policy)). |
| `grid_unit` | The grid changes geometry only: grid windows use the same materials as the non-grid windows of their bay and storey (pane = the window spec's `glass`, default `glass`; frames, mullions, transoms, fields and spandrels = its `frame`, default `frame`), so materials stay as they are unless a scheme opts in through `materials` (assembly role to palette key). Every key must exist in the palette or the build fails naming it. Other fields: `depth` (reveal and pane depth, default the window spec's `depth`), `reveal` material, and `unit` (a [facade_assembly](../../scripts/world/facades/facade_assembly.gd) unit spec: `frame_w`, `mullion_w`, `transom_w`, `split`, `split_min_w`, `transoms`, `lower_field`, `member_d`). |

Feature types: `loggia` (`storeys`, `depth`, `pier`), `frame` (a multi-storey recess over `storeys` `[k0, k1]`), `band` (a dark vertical window/spandrel stack), `entry` (`door.kind` `unit`, `lobby` or `porch`, plus `canopy`, `landing` and `screens`), `garage`, `vents`, `corner` (a window aligned to the face end), and the opt-in `stair_bay` and `top_box` (see the outbuilding fields table). A feature may also set `material`, `material_from`/`material_to`, `window`, `window_storeys`, `ground` and `upper`.

Entry landings are flat walkable pads at the highest terrain under them plus 0.1 m, with skirts of at most 40 degrees into the ground. Doors sit on the landing, so there are no steps to walk-test.

## Outbuilding fields

All are opt-in; configs without them build as before. Materials are shared across instances by value and never changed after creation. Out-of-range values fail the build (`build_valid` false): `pitch_deg` outside (0, 60], roof `t` outside (0, 1] m, `overhang` outside [0, 3] m, `floor_raise` outside [0, 10] m, knee `h` outside (0, 4] m or `t` outside (0, 1] m, deck `t` outside (0, 2] m; so does any non-finite vertex.

| Field | Meaning |
|---|---|
| block `roof` | `form`: `gable` (ridge parallel to footprint edge `ridge_edge`), `mono` (falls toward edge `low_edge`) or `pyramid` (hip or pavilion); `pitch_deg`, `overhang`, slab thickness `t`, and `under`/`fascia` materials (the top is `roof_material`). The block outline must be convex; its walls stop at the eave and the gable or lean-to infill above it follows the roof. |
| parapet `style: "pipe"` | Posts and top and mid rails instead of glass panels, over the `curb` (tank tops, basin rims, roofs). |
| scheme `open` | Posts (`post_w`, `module`, `post_material`; `post_every` keeps one face start in n; `posts: false` leaves the side without posts, for a deck carried by its neighbours) instead of a wall, optionally over a `knee` wall (`h`, `t`, `material`, entrance `gap` in stations). |
| scheme `gable_material` | Material of the infill above the eave. |
| feature `vents` `windows: true` | Keeps the ground-storey window in the louvres' bay (louvres under windows). |
| target `holes` | Number of courtyard holes: further closed rings after the outer ring in the wall record. Each hole must lie wholly inside one flat block, which builds full-height courtyard walls (face key `hole`, else `default`), parapets and its roof around it. Absent means a single ring, as before. |
| block `deck` | A flat roof carried as a slab over `open` sides: thickness `t` and `material` of its underside and of the fascia on the open faces. A deck block hides a neighbouring block's wall only from its deck underside up, so a wall behind its open sides reaches the ground (and runs on through the slab band, closing the slab end). An invalid `t` fails the build even without open faces. |
| block `pergola` | Open timber pergola instead of a roof slab on a flat convex block (normally with `open` sides and no `deck` or `roof_items`): beams `beam_w` x `beam_h` round the outline under the roof line, and rafters `rafter_w` x `rafter_h` on them every `spacing`, at right angles to footprint edge `rafter_edge`, in `material` (default `timber`). Support role. A pergola block never hides a neighbouring block's wall, so the wall behind it reaches the ground. Out-of-range sizes fail the build. Pair it with an `apron` for a deck floor. |
| block `open_sided` | `true` marks an open-sided block (a canopy on posts with its own roof, normally with `open` faces). Like a pergola, it never hides a neighbouring block's wall, so the wall behind it reaches the ground; unlike a pergola, it keeps its roof slab. Absent or `false`: the block hides neighbouring walls as before. |
| top-level `ext_stairs` | Straight open steel flights outside a wall: each entry runs along footprint edge `edge`, `gap` (0-0.5 m) out from it with clear width `w` (0.6-1.6 m), from grade at station `foot` up to a landing at floor `storey` (an upper floor) of block `block` that starts at station `top` and ends at `landing_end` (at least 0.8 m on), `landing_depth` (gap + w to 3 m) out from the wall, on two posts. Risers are about 0.18 m and goings must come out at 0.22-0.36 m. `rails` (default true) adds the landing rails; the flight's outer handrail is always built. Treads, landing, stringers, the outer handrail, landing rails and posts are `support` in `material` (default `rail`; treads `tread_material`). The walking surface is a hidden collision-only `support` ramp through the tread nosings, flush with the landing. List the flight in the catalog `stairs` so the fit test walks it. Invalid input fails the build. |
| feature `ladder` | Caged steel ladder centred on the bay, from 0.3 m above grade to 1 m over the wall top (a fixture, not walkable). |
| entry `landing.at: "floor"` | Deck at the floor level with skirts to grade; with `ramp` (`dir` ±1 along the face, `w`, `slope`, default 1:12) a walkable ramp runs along the facade to grade. `rails` (default with a ramp) adds pipe rails. |
| roof item `cylinder` | Prism of `sides` (default 12) inscribed in the item's station/depth square. Items on pitched roofs stand on the slab. |
| feature `stair_bay` | Open recessed stair bay (at least two storeys): a full-height void `depth` (1.2–4 m, default 2.0) deep inside `pier` (default 0.2) from the feature ends, from the highest grade under its front and back lines up to `head` (default 0.35) below the roof, with a `back` wall (default `render`; set a dark material for a shadowed recess), `side` reveals (default the wall), a `soffit`, a solid ground-floor guard `guard_h` (default 1.1) high, and per storey two stepped flights around a half landing under a floor landing (all `slab`). A visual recess, not a route; its back wall closes the collision footprint. A clear width under 2 m, a depth outside the range, back corners outside the block or no room between grade and roof fail the build. |
| feature `top_box` | Projecting box on an otherwise blank wall from `below` (default 0.15) under floor `storey` (default the top storey) up to the wall top, `project` (0.05–2 m, default 0.6) out from the wall, inset by `pier`, in `material` (default the scheme material), with one glazed band from its `window` (`sill`, `h`, `inset`, plus the usual glazing fields). It is `support`, so wall geometry stays inside the footprint. A width under 1 m or an out-of-range storey or projection fails the build. |

Parts are emitted into the same role buckets: posts, rails, ladders, pergola beams, fascia and roof undersides are `support`, knee walls and infill are `wall`, ramps are `ground`.

## Plan fields

All are opt-in; configs without them build as before.

| Field | Meaning |
|---|---|
| block `outline_xz` | The block's plan as world `[x, z]` points instead of a clip of the footprint, for curved or notched plans. Every point lies inside the footprint or within 5 mm of it. Neighbouring blocks hide each other's walls only along edges that share a line within 2 mm, so give them the same points. |
| block `stacked` | The block floats from `floor_raise` up, free of the tiling: it may overlap the block under it and is left out of the overlap and area checks. Its walls start at its floor and it gets a `soffit` (palette key, default `soffit`) on its underside, so upper floors can overhang a smaller ground storey. A neighbour's wall behind it is hidden only from that floor up. |
| face key `p<i>` | Names outline edge `i` of a block in `faces`, ahead of `e<k>`, `court`, `return` and `default`, so each facet of a curved plan can take its own scheme. |
| target `holes_tiled` | With `holes`: no block owns the courtyard ring. A low deck block fills the court and the wings round it are blocks of their own heights, so the court walls are ordinary `court` faces above the deck. |
| top-level `round_columns` | Round columns, each `{"xz": [x, z], "r": 0.1-1, "top": 0.5-12, "material": "concrete", "sides": 16}`, from below grade to `top` above the building floor. Support role, so they stop the player. |

## Material and opening fields

All are opt-in; configs without them build as before.

| Field | Meaning |
|---|---|
| palette `texture`, `tile_m`, `offset_m` | A tiling albedo under `rgb` as a multiplier. The wall and roof UVs are metres, so `tile_m` `[u, v]` is the tile's size on the wall; `offset_m` slides it, to put a panel joint at a chosen height. `tile_m` wins over `uv_scale`, `offset_m` needs it, and a `tile_m` texture keeps the default filter, where a `uv_scale` one is filtered anisotropically. |
| window or `grid_unit` `box` | `{"project": 0.05-1, "t": 0.03-0.5, "material": ...}`: a frame `t` thick round the opening, standing `project` out from the wall, with its inner faces running back to the wall plane. Support role, so it stays clear of the spray receiver. |
| scheme `plaques` | Flat panels on a face, each `{"from": s, "to": s, "bottom": m, "top": m, "t": 0.03, "material": ...}`, heights above the block's floor: a building's name, its texture one opaque panel. Support role. |
| palette `receive_shadows` | `false` keeps cast shadows off a material: glass shows what it reflects, and shadow-map edges on it read as scallops. |
| window, `grid_unit` or lobby door `panels` | Opaque panels in a light, each `[u0, u1, y0, y1, material]` as fractions of the light: a louvre over a window, a spandrel between two panes. A grid unit repeats them in each joined storey. |

## Roof edges and parts

All opt-in; configs without them build as before. Coordinates in an edge's frame are stations `s` along footprint edge `edge` and depths `d` inward of it (negative: outside the outline). Invalid input fails the build.

| Field | Meaning |
|---|---|
| top-level `face_key` | `"overlap"` keys a face to an edge only where the face lies alongside that edge, not merely within 2.5 m of its infinite line, so the parallel jogs of a stepped frontage keep their own keys and stations. Default `"line"`. |
| top-level `wall_ring` | `{"insets": {"<edge>": metres}}` moves those footprint edges inward (up to 2.5 m) before the blocks are clipped: the walls stand behind a roof edge that stays on the outline. Clips, stations and keys still refer to the footprint edges. |
| top-level `eaves` | Roof edges over the set-back walls. Each entry takes consecutive footprint edges `edges` in ring order, heights `soffit` and `top` above the building floor, and a fascia section `profile` of `[in, y, material]` points from soffit to top (`in`: metres inward of the outline, so the section stays inside the footprint; a point's material paints the segment ending there). `roof_material` tops the strip back to the wall line (roof role), `soffit_material` and per-edge `soffit_edges` line it and `end_material` closes its ends (support role). Corners are mitred. Set `top` at or above the block's wall top. |
| block `roof.fascia_edges` | `{"<edge>": material}`: on a pitched block, the fascia of the sides facing as that footprint edge does. |
| eave `edge_materials` | `{"<edge>": {"<profile material>": material}}`: recolours one edge of an eave run, keeping its mitres. |
| ground window `lights` | Further windows in the same bay, each merged over the ground window spec (a clerestory over a window). |
| door `glazing` | Lobby or porch door: extra glazing fields (`glass`, `frame`). |
| palette `texture` | Image on the material. On a part `art` panel or slab face it is stretched over the panel; on other surfaces it tiles by world metres, `uv_scale` tiles per metre, unless `tile_m` sizes it ([below](#material-and-opening-fields)). `texture_alpha` blends it. |
| palette `specular` | The material's specular level, 0.5 by default; ground like lawn wants it low. |
| palette `emission` | Energy: the material lights itself, from its image when it has one. |

Top-level `parts` adds pieces a scheme has no field for. Heights for `box`, `glazing` and `art` are `y` (above the building floor) or `g` (above the highest grade under the part); `foot: true` runs the bottom into the ground.

| Part `kind` | Fields |
|---|---|
| `box` | `edge`, `s`, `d`, `material`, `role` (default support), `count`/`step` copies along the edge, `count_y`/`step_y` copies upward. |
| `glazing` | A framed layer at depth `d` over `s`: `glass`, `frame`, `frame_w`, `bar_w`, `mullions`, `transoms` as for a window. Wall role. |
| `art` | One image over `s` at depth `d` (a number, or `[bottom, top]` to lie on a sloped fascia), in a textured `material`. Wall role unless `role` says otherwise. |
| `slab` | Free-standing sign blade at `at` [x, z]: `w`, `h`, `t`, `yaw` degrees, `bow` (metres of curve in plan), `arch`, `material`, `face_material` (one image across the front). Support role. |
| `umbrella` | Patio umbrella at `at`: radius `r`, rim `h` above grade, `rise`, `valance`, `sides`, `material`, `pole_material`. Its canvas bellies out over a ring part way up. Support role. |
| `set` | One object from the top-level `sets`: `name`, stood at `at`, turned `yaw` degrees. A set is a list of boxes `[x0, x1, z0, z1, y0, y1, material]` from its centre and the ground, so a table or chair is written once and placed at any angle. Support role. |
| `disc` | Round can on a wall: `edge`, `s`, height span `y` or `g`, `d`, `depth`, `rim_material`; `material` shows its image fitted to the face, turned `spin` degrees. Support role. |
| `lights` | A string of bulbs `from` `to` ([x, z, height above the building floor]): `sag`, `every`, `material` (normally an emissive palette colour), `wire_material`. Visual only: nothing to stop a jetpack rise on. |
| `fence` | Solid fence along `path`: `h`, `post_every`, `post_material`, and `style` `boards` (`board`, `gap`) or `ribs` (`rib`, `rib_material`). Support role. |
| `pad` | Site paving over the simple polygon `poly`, `lift` above the frozen land, or, when each point carries a third value, spanning those heights above the building floor, like a ramp over a sloped edge. Visual only: like a road, it is drawn over the land the player walks on and has no collision. Keep `lift` clear of the area and road surfaces drawn there (0.02-0.05 and 0.08 m), and give overlapping pads their own lifts. |
| `path` | A walk `w` wide along the polyline `line`, built as pads. |

## Roles

Facade planes, reveals, glazing and doors are `wall` (spray receivers); roofs and the deck are `roof`; landings and aprons are `ground`; parapets, railings, canopies, slabs and roof items are `support`. The installer turns each role into one source-owned contact body. Check an instance in the real island with `game/tests/shared/building_shots.gd` and `building_fit_test.gd -- --native-producer housing-get-faces`.

# Site and asset inventory

Started 2026-11-05 at published main `6ba040d3`. The owner asked for the
building detail levels to cover lots, parks and individual objects too, so that
when there is spare time the team can pick, say, the excavators and improve
them. This is the list to pick from. Like the
[building-stage checklist](ISLAND_BUILDING_STAGE_CHECKLIST.md), it is a human
planning document: it adds no runtime gate, test, score file or reporting
framework, and nothing checks its rows. The generator config, the kit code and
the generated world remain the record of what exists.

## Levels

Sites and asset types use the five building levels of the
[zoom-in authoring pattern](../AGENTS.md#zoom-in-authoring-pattern), read by
analogy. A level counts only when the levels below it are sound, and the
[no-invented-detail rule](../AGENTS.md#facade-recognizability-policy) applies:
detail needs a dated photo.

**Sites** (parking lots, parks and plazas, pitches, yards, street-detail zones):

- **0** not built: only the generated OSM area, draped on the terrain with its
  class's generic ground material.
- **1** surface, outline and ground fit: the site's own ground layers, edges and
  levelling, checked against dated photos or aerials.
- **2** main contents and layout from dated photos: car rows, beds and paths,
  yard stock, fences, major props.
- **3** secondary items: small props, edges, markings, signage.
- **4** materials.
- **5** wear, grime, decals and finishing.

**Asset types** (one reusable model, with its variants):

- **1** blockout: silhouette and size.
- **2** the main parts that make it recognizable (an excavator's tracks, cab,
  boom, arm and bucket).
- **3** secondary parts (rails, lights, hoses, mirrors).
- **4** materials and textures.
- **5** decals, labels and wear.

For a plant, read the parts as trunk, crown and foliage form (2), then frond
skirts, bark and flower heads (3). For the avatar, read them as body, lid and
limbs (2), then bands, coins and shoes (3).

## How the ratings were made

- **est.** means "initial estimate from review records, 2026-11-05". No review
  has yet judged any of these rows in level terms, so every number here is an
  estimate. The estimate is the highest level whose content exists in the code
  and that a review verdict or owner comment accepted, with nothing recorded as
  open below it. Sources: RETRO_LOG and LEARNINGS entries, review verdicts
  quoted in commits, and owner feedback.
- **code** means the level was read from the generator and config on
  2026-11-05: no site work exists, so the row is 0.
- A blank level means **unrated**: no review record judges that asset's form.
  Placement checks and whole-site verdicts don't rate the props in them.
- No row is rated 4 or 5 yet. Where a review fixed a colour or a finish defect,
  the evidence column says so, but no review has judged an asset's materials or
  finish complete.

## Upkeep

When work adds or improves a site or an asset type, the change updates its row
in the same commit (AGENTS.md). Rollout branches update only their own rows, and
the integration push reconciles rows from parallel branches. Change a level
only on actual review evidence; replace "est." with the review's name when a
review judges the level itself.

**In progress on 2026-11-05.** These rollouts are adding or changing sites and
assets now, so their integrators fill in the rows (new rows for new kit props,
species and zones):

- `street/ground-rollout-20261105`: curbs, sidewalks, markings, crosswalks and
  wear island-wide (pilot step 1 extended to new zones).
- `street/objects-rollout-20261105`: signs and the other vertical street objects
  island-wide (lights, power poles, hydrants, cabinets, bus stops). Power poles
  and lines, bollards and the post box are OSM rows the generator records but
  doesn't build yet.
- `street/clutter-rollout-20261105`: parked cars, bins and benches island-wide.
- `street/shoreline-rollout-20261105`: riprap around the whole perimeter (today
  only the `west_ferry_pilot` segment).
- `street/vegetation-rollout-20261105`: ground tone, the Avenue N palms, and new
  tree and shrub models.

## Sites

### Street-detail zones

Every zone in [`tools/config/street-detail-zones.json`](../tools/config/street-detail-zones.json).
Yards carry their large-clutter research number (#1–#16), which the asset rows
below use. Place #8 is two zones.

| Site | Zone / OSM | Level | Evidence | Next level |
|---|---|---|---|---|
| Ferry arrival and Waterfront Plaza | `ferry_arrival_plaza`; w1428380754 | 3 est. | Pilot steps 1–5 visual and code PASS: plaza paving, kerbs, plaza lamps, the OSM hydrant. Set pieces (map board, wedge benches, baskets, young cypresses) checked against Sep 2025 photos (step 4 PASS). Chairs rebuilt (plaza-chairs PASS at `1be722c2`) | 4: matched materials. Open: crosswalk paint too fresh (83 % against about 53 % in the photo); the lawn's dry patch under the chairs, where the photos show green turf |
| Treasure Island Road, ferry crossing to Trade Winds | `treasure_island_road_south` | 3 est. | Step 1 visual: red west lane, double yellow, green east lane, continental crosswalk, kerb and gutter read as the Sep 2025 photo. Step 2: cobra lamps, signal masts, cabinets and name blades PASS | 4: materials (faded paint, worn crosswalks) |
| Trade Winds Avenue to Avenue of the Palms link | `trade_winds_palms_link` | 2 est. | Step 1 ground, step 2 lamps, step 3 Cultural Park screened fence (r5 PASS, web shot at the screen) | 3: the Trade Winds bike lane (parked in step 1) and the corridor's markings |
| Avenue of the Palms | `avenue_of_the_palms` | 3 est. | Step 1 parking lanes and mulch strips (strip order PASS at `25d2eeb5`); step 2 stop signs and name blades; step 4 curb cars PASS; step 5 palms and bed grasses PASS; Cityside panel fence (step 3) | 4: materials and paint wear |
| Building 1 forecourt | `building_1_forecourt`; w96665914 | 2 est. | Step 1 lot asphalt (two-tone fixed in round 2); step 2 fix round added the exit stop sign and lot lights (delta PASS); step 4 lot-stall cars PASS | 3: the planted island at the exit that the Sep 2025 photo shows (the stop sign stands on lot asphalt instead) |
| Cityside Park | `cityside_park`; w1428380753 | 3 est. | Whole-park visual PASS at `9807b468` and code PASS: lawn, stormwater beds, coastal gardens, paths, painted plazas, windrow gums and set pieces (Canopy of Sky, disc lamps, event poles, long benches, picnic tables, grills, log seats, pump station). Sidewalk-spill fix PASS | 4: materials |
| #1 Central self-storage complex | `yard_central_storage`; ground on w96698665 | 2 est. | Yards A visual rounds, code PASS at `a63b6188`: shed rows, container walls and rows, vehicle lot, screened and slatted fences, pole flags and floodlights | 3: secondary items (signage, small props) from the dated photos |
| #2 CityView Storage main lot | `yard_cityview_main` | 2 est. | Yards A (as #1): RV, truck, bus and boat rows, sheds, container-walled Avenue M side | 3: secondary items |
| #3 Avenue H truck and trailer lot | `yard_avenue_h_truck_lot` | 2 est. | Yards A (as #1): trucks, vans, trailers, containers; cones and barricades at the gate | 3: secondary items |
| #4 CityView Storage west lot | `yard_cityview_west` | 2 est. | Yards A (as #1): vans, trucks, RVs, trailers, boats, long white shed in stepped parts | 3: secondary items |
| #5 Treasure Island Drive-Up Self Storage | `yard_ti_drive_up` | 2 est. | Yards A (as #1): parallel shed rows on paved aisles, beige container walls | 3: secondary items |
| #6 City View Commissary | `yard_food_truck_commissary` | 2 est. | Yards A (as #1): food trucks, white fabric sheds, beige container wall | 3: secondary items |
| #7 Bay Area Concrete Recycling yard | `concrete_recycling_yard` | 2 est. | Yards B visual rounds 2–6 and B08/B09 deltas, code PASS at `8f24ca9e`: container walls, conveyors, aggregate piles, machines; owner-approved levelling | 3: secondary items |
| #8 8th Street and Avenue N yard (north) | `eighth_avenue_n_north_yard` | 2 est. | Yards B (as #7): trailers, work vehicles, mats and pipe sections, tarp piles on pale gravel | 3: the portable toilets the photos show (not in the kit) |
| #8 8th Street and Avenue N yard (south) | `eighth_avenue_n_south_yard` | 2 est. | Yards B (as #7): white fabric shed, vehicles and equipment behind slatted chain-link | 3: secondary items |
| #9 Avenue M contractor staging yard | `avenue_m_staging_yard` | 2 est. | Yards B (as #7): owner-approved soil mound with the excavator on top, plastic stockpile, trailers, RVs and work vehicles | 3: secondary items |
| #10 Pier 1 barges | `pier1_barges` | 2 est. | Yards B (as #7): crane and deck barges moored at Pier 1, deck cargo, pier-root fences | 3: deck detail from a closer dated photo |
| #11 Hangar earthworks pad | `hangar_earthworks_pad` | 2 est. | Yards B (as #7): levelled pale pad, continuous ring of black-plastic berms, ponds | 3: edges and small items |
| #12 9th Street and Avenue H construction site | `construction_9th_avenue_h` | 2 est. | Yards B (as #7): slab, office trailer, boxes, machines, panels with orange safety mesh | 3: secondary items |
| #13 Seven Seas Avenue Gate 5 staging yard | `gate5_staging_yard` | 2 est. | Yards B (as #7): bermed sand square, soil piles, cylinder sections, containers, fabric sheds | 3: secondary items |
| #14 505 Avenue N soil spread | `avenue_n_soil_spread` | 2 est. | Yards B (as #7): staggered windrows across the spread, OSM construction panels | 3: edges |
| #15 SFFD training facility yard | `fire_training_yard` | 2 est. | Yards B (as #7): rubble pile, white work vehicles | 3: secondary items |
| #16 Fenced Navy investigation lots | `navy_investigation_lots` | 2 est. | Yards B (as #7): the OSM barbed chain-link fence is its only content; the lots are grass and old slabs | 3: the old slabs, where a dated photo shows them |

### OSM parks, plazas and pitches

Every `leisure=park`, `leisure=common`, `leisure=pitch`, `leisure=playground`
and `leisure=sports_centre` area in the frozen snapshot
(`data/osm/treasure-island-2026-08-27.osm`). The snapshot maps no
`place=square` or pedestrian area, so its plazas are the parks named Plaza.
Centres are world metres (x east, z south) from the generated world.

| Site | OSM | Centre (x, z) | Level | Evidence | Next level |
|---|---|---|---|---|---|
| Waterfront Plaza | w1428380754 | (-107, 765) | see zone | Built as the `ferry_arrival_plaza` zone | (zone row) |
| Cityside Park | w1428380753 | (-258, 466) | see zone | Built as the `cityside_park` zone | (zone row) |
| Marina Plaza | r19585233 | (2, 740) | 0 code | Most of the Building 1 forecourt zone lies inside it; the rest is generic park ground | 1: its own surfaces and paths beyond the forecourt |
| Cultural Park | w1428380762 | (-83, 625) | 0 code | Generic park ground; its Sep 2025 screened site fence is built by the Trade Winds zone | 1: surface and outline from dated photos |
| Causeway Park | w1428380755 | (-47, 897) | 0 code | Generic park ground | 1 |
| Clipper Cove | w1428380764 | (67, 818) | 0 code | Generic park ground | 1 |
| Unnamed park | w775796578 | (-420, 55) | 0 code | Generic park ground | 1 |
| Unnamed common | w52721884 | (-105, -565) | 0 code | Generic ground | 1 |
| Treasure Island Playground | w545387425 | (-225, -410) | 0 code | Generic ground | 1 |
| Treasure Island Skate Park | w1061513876 | (439, -115) | 0 code | Paved ground-cover family (Mar17 ground cover) | 1: the bowls and ramps' ground fit |
| Tepper Little League Field #1 (sports centre) | w28353177 | (563, -9) | 0 code | Sports ground-cover family (Mar17) | 1: infield and outfield surfaces |
| Ketcham Little League Field #2 (sports centre) | w109022547 | (368, -261) | 0 code | Sports ground-cover family (Mar17) | 1 |
| Baseball pitch | w133809962 | (364, -233) | 0 code | Sports ground-cover family (Mar17) | 1 |
| Baseball pitch | w133809964 | (-11, 109) | 0 code | Sports ground-cover family (Mar17) | 1 |
| Gaelic Athletic Association Field A | w99060807 | (-121, -394) | 0 code | Sports ground-cover family (Mar17) | 1 |
| Gaelic Athletic Association Field B | w99060801 | (-1, -454) | 0 code | Sports ground-cover family (Mar17) | 1 |
| Basketball court | w28356842 | (-159, 18) | 0 code | Paved ground-cover family (Mar17) | 1: court surface; 2: hoops |
| Basketball court | w96665888 | (21, 163) | 0 code | Paved (Mar17) | 1; 2: hoops |
| Basketball court | w96665934 | (-7, 170) | 0 code | Paved (Mar17) | 1; 2: hoops |
| Basketball court | w1163035324 | (-252, -543) | 0 code | Paved (Mar17) | 1; 2: hoops |
| Basketball court | w1307988013 | (-371, 33) | 0 code | Paved (Mar17) | 1; 2: hoops |
| Tennis court | w1102656842 | (416, -103) | 0 code | Paved (Mar17) | 1: court surface; 2: net and fence |
| Boules pitch | w545387428 | (359, 632) | 0 code | Sports ground-cover family (Mar17) | 1 |

The Treasure Island Community YMCA (w34313547, `leisure=sports_centre`) is a
building and belongs to the building-stage checklist.

### OSM parking lots

Every `amenity=parking` area in the frozen snapshot. None has a name. Pilot
step 1's fix round gave every parking area the road asphalt, which is still the
generic material, so untouched lots stay 0.

| OSM | Parking tag | Centre (x, z) | Level | Evidence | Next level |
|---|---|---|---|---|---|
| w96665914 | surface | (-44, 756) | see zone | Built as the Building 1 forecourt zone (stalls, cars, lot lights) | (zone row) |
| w96698665 | surface | (-135, -143) | see zone | Its ground is yard #1's asphalt layer | (zone row) |
| w28356874 | surface | (-340, 141) | 0 code | Generic asphalt | 1: stall paint, edges and ground fit from dated photos |
| w28356892 | surface | (-32, 342) | 0 code | Generic asphalt | 1 |
| w95934095 | surface | (-448, -565) | 0 code | Generic asphalt | 1 |
| w95934109 | surface | (-488, -496) | 0 code | Generic asphalt | 1 |
| w95934133 | surface | (-513, -412) | 0 code | Generic asphalt | 1 |
| w95934134 | surface | (-595, -515) | 0 code | Generic asphalt | 1 |
| w95934141 | surface | (-553, -610) | 0 code | Generic asphalt | 1 |
| w96665901 | street_side | (-40, -527) | 0 code | Generic asphalt | 1 |
| w96698621 | surface | (174, -375) | 0 code | Generic asphalt | 1 |
| w96698661 | surface | (230, 181) | 0 code | Generic asphalt | 1 |
| w109022552 | surface | (43, 542) | 0 code | Generic asphalt; the z-fight fix `4f469784` layers it over the area it lies in | 1 |
| w850003199 | (none) | (10, 805) | 0 code | Generic asphalt | 1 |
| w1102659944 | (none) | (-286, -503) | 0 code | Generic asphalt | 1 |
| w1252737739 | street_side, asphalt | (260, -323) | 0 code | Generic asphalt | 1 |
| w1473022596 | (none) | (-620, -420) | 0 code | Generic asphalt | 1 |

## Asset types

Read from the kit code on main `6ba040d3`. "Where used" names zones by yard
number or zone id, and set pieces from
[`data/street_detail/set_pieces.json`](../data/street_detail/set_pieces.json).
A variant listed as "not placed" exists in the kit but nothing in the world uses
it yet.

### Yard kit

`YARD_KIT_PROPS` in [`tools/lib/street-yard-kit.mjs`](../tools/lib/street-yard-kit.mjs)
(meshes in `tools/lib/street-yard-meshes.mjs`, runtime
`game/scripts/world/street_yard_kit.gd`). The `equipment` prop's variants are
separate machines, so each has its own row. The kit's visual review (E02 and E08
rounds, then the heaps delta) worked from one gallery sheet per prop family;
the rows below are rated only where a record names the prop.

| Asset | Where used | Level | Evidence | Next level |
|---|---|---|---|---|
| Shipping container (20 ft, 40 ft, 40 ft high cube, 20 ft roll-up, 40 ft office, 10 ft) | #1–#6, #9, #10, #12, #13 (office only #1; 10 ft #1, #10; high cube and roll-up not placed) | 2 est. | Kit review fixes `15c75852`: container finish (corrugation that doesn't alias, lighter rarer rust, less grime) | 3: door hardware, castings and lock bars judged close up |
| Container wall (single, double) | #1, #2, #3, #5, #6, #7 (double only #7) | 2 est. | `15c75852`: forest green and beige walls; E08 sunlit frames confirmed the photo colours (kit RETRO) | 3: joints and corner castings close up |
| Storage shed row (double, single, wide) | #1, #2, #4, #5, #6 | | In the kit's family sheets; no prop-specific verdict recorded | Rate: compare with the dated yard photos |
| RV (class A, class C, travel trailer, fifth wheel) | #1, #2, #4, #6, #8 north, #9 | | No prop-specific verdict | Rate |
| Bus (coach, shuttle) | #2, #3, #4 | | No prop-specific verdict | Rate |
| Box truck (medium, large) | #1–#6, #8 north, #9, #10, #12, #13, #15 | | No prop-specific verdict | Rate |
| Van (cargo: the car kit's van body; step van) | #1–#6, #8, #9, #13, #15 | | No prop-specific verdict | Rate |
| Food truck (step van, trailer) | #6 | 2 est. | `15c75852` added the glazed serving window with its hood and ledge; E08 opposite-side frames confirmed it | 3: hatch, vents and hardware close up |
| Boat on trailer (runabout, cabin) | #2, #3, #4 | | No prop-specific verdict | Rate |
| Trailer (cargo, utility, semi, office) | #1–#4, #8, #9, #12, #13, #15 (office only #12) | | No prop-specific verdict | Rate |
| Fabric shed (10, 15, 20, 30 m spans) | #2, #6, #8 south, #13 (30 m span not placed) | | No prop-specific verdict | Rate |
| Excavator | #7, #8 south, #9, #12, #13 | 2 est. | Owner, 2026-11-05: the excavators "look pretty basic, which is absolutely fine". Rebuilt in review: banana boom, hanging arm, curled bucket (`15c75852`), then one arched boom (`32d3987e`, from E08) | 3: secondary parts that read at gameplay distance (rams, rails, lights, hoses, mirrors) |
| Wheel loader | #7, #8 south, #9, #12, #13 | 2 est. | Rebuilt after E02 with lift arms, Z-bar linkage and a hollow bucket (`15c75852`) | 3: secondary parts |
| Crane mats | #7, #8 north, #9, #10, #13 | | No prop-specific verdict | Rate |
| Cylinder section | #8 north, #13 | | No prop-specific verdict | Rate |
| Open bin (roll-off) | #9 | 2 est. | E02 review: faded blue, rusted through (`15c75852`, `8f9a7341`) | 3: rails, doors and hooks close up |
| Hopper | not placed | | No prop-specific verdict | Rate when placed |
| Conveyor | #7 | | No prop-specific verdict (the aerial gives only its plain form) | Rate |
| Water-filled barrier | #8 south, #13 | | No prop-specific verdict | Rate |
| Material pile (gravel, rubble, soil, tarp, soil ridge) | gravel #7; rubble #15; soil #12, #13; tarp #8 north; ridge #13, #14 | 2 est. | E02 and E08 fixes (rubble as broken concrete on dumped mounds, tarps draped with tyres, piles within their plans) and the heaps delta (r2) | 3: chunks, tyres and fold detail judged close up |
| Plastic berm (low, high) | #11 (high not placed) | 2 est. | `15c75852`: long low trapezoids; `32d3987e`: caps without a seam (E08) | 3: wrinkles and weights close up |
| Pole flag | set pieces by the central storage yard (#1) | | Added in the kit's finish round (`32d3987e`); no verdict recorded | Rate |
| Crane barge (crane barge, deck barge, pier crane) | #10 (pier crane not placed) | 2 est. | `15c75852` and `32d3987e`: hull and deck weathering, dull red deck, lowered boom; yards B rounds on #10 | 3: deck fittings and the crane's rigging |

### Clutter kit

[`tools/lib/street-clutter-kit.mjs`](../tools/lib/street-clutter-kit.mjs) (`CAR_BODIES`,
`CLUTTER_PROPS_KIT`), drawn by `game/scripts/world/street_clutter_builder.gd`.

| Asset | Where used | Level | Evidence | Next level |
|---|---|---|---|---|
| Parked-car bodies (crossover, SUV, sedan, fastback, hatchback, wagon, pickup, utility pickup, van) | Avenue of the Palms curbs, Building 1 forecourt lot; the van body also in the yards | 3 est. | Owner on the first car sheet: the kit "looks pretty good"; the sinking it showed was fixed (LEARNINGS). Step 4 visual PASS with wheel close-ups. Lamps, plates, grille, chrome trim and mirrors are modelled | 4: paint, glass and tyre materials |
| Traffic cone | set pieces: Avenue of the Palms, the #3 gate | | Step 4 PASS checked placement against the Nov 2025 photos only | Rate |
| A-frame barricade | set pieces: Avenue of the Palms, the #3 gate | | Step 4 PASS, placement only | Rate |

### Street furniture and objects kit

`PROPS` in [`game/scripts/world/street_furniture_kit.gd`](../game/scripts/world/street_furniture_kit.gd).

| Asset | Where used | Level | Evidence | Next level |
|---|---|---|---|---|
| Cobra-head street lamp | TI Road south, Trade Winds link, Avenue of the Palms | 2 est. | Step 2 visual PASS; lamp move confirmed on the web (delta PASS) | 3: luminaire and pole-base detail judged close up |
| Lot lamp | Building 1 forecourt | 2 est. | Step 2 fix round, delta PASS; its post-top lantern is inferred from a soft, low-resolution photo | 3: the head from a sharper dated photo |
| Plaza lamp | ferry plaza; two floodlight set pieces on 9th Street (#1) | | No prop-specific verdict | Rate |
| Signal mast | TI Road south | 3 est. | Step 2 visual: the signal heads held up in 2–3x native crops | 4: materials |
| Signal cabinet | TI Road south | 2 est. | Step 2: rendered 1.6x too bright and green against three dated photos, re-tinted in the fix round (PASS) | 3: door and pad detail close up |
| Stop sign | Avenue of the Palms all-way stops, the forecourt exit, OSM stop signs in the pilot zones | 3 est. | Step 2: sign faces held up in native crops | 4: materials |
| Street-name sign | TI Road south, Avenue of the Palms junctions | 3 est. | Step 2: name blades held up in native crops | 4: materials |
| Fire hydrant | the OSM hydrant at the ferry plaza | 3 est. | Step 2: the hydrant held up in native crops | 4: materials |
| Bus-stop sign | the OSM bus stop near Building 1 | | Step 2 checked its placement only | Rate |
| Concrete wedge bench | ferry plaza set pieces | | Step 4 PASS, placement only | Rate |
| Park bench | not placed (OSM benches outside the pilot zones; clutter rollout) | | Not built yet | Rate when placed |
| Waste basket | ferry plaza and Avenue of the Palms set pieces; one OSM basket | | Step 4 PASS, placement only | Rate |
| Map board | ferry plaza set piece | | Step 4 PASS, placement only; the map is an original drawing from the frozen OSM data | Rate |
| Adirondack chair | ferry plaza and Cityside set pieces | 2 est. | Owner: the blue chairs "need a lot of work". Rebuilt with the flat-topped back and water-facing row of photos 24 and 25, colour sampled against them, feet settled (plaza-chairs PASS at `1be722c2`) | 3: slat and joint detail close up |
| Bike rack | Avenue of the Palms set piece | | No prop-specific verdict | Rate |
| Canopy of Sky (artwork) | Cityside set piece | | Whole-park PASS only; the r04 view named for it was not framed on it | Rate against ph05 |
| Disc lamp | Cityside set pieces | | Whole-park PASS only | Rate |
| Event pole | Cityside set pieces | | Whole-park PASS only | Rate |
| Long bench | Cityside set pieces | | Whole-park PASS only | Rate |
| Long picnic table | Cityside set pieces | | Whole-park PASS only | Rate |
| BBQ grill | Cityside set pieces | | Whole-park PASS only | Rate |
| Log seat | Cityside set pieces | | Whole-park PASS only | Rate |
| Pump station | Cityside set piece | | Whole-park PASS only | Rate |

### Fence types

`TYPES` in [`game/scripts/world/street_fence_kit.gd`](../game/scripts/world/street_fence_kit.gd);
gate leaves and banners are parts of the same kit.

| Asset | Where used | Level | Evidence | Next level |
|---|---|---|---|---|
| Chain-link | #8 north, #10, #13, #15; OSM fences at #2 and #6 | | Added with the yards; no type-specific verdict | Rate |
| Chain-link with barbed wire | #16 (OSM w109042225), the #2 pen (OSM w1252737752) | | No type-specific verdict | Rate |
| Chain-link with windscreen | Trade Winds link (Cultural Park), #1, #2, #6, #9, #12 (orange safety mesh), #13 | 2 est. | Step 3 r2 and r5: screen tone sampled and fixed, no sparkle at distance (PASS). Orange mesh saturated and opaque after the kit review (`e556bc40`) | 3: posts, rails and ties close up |
| Chain-link with privacy slats | #1, #2, #4, #8 south | | No type-specific verdict | Rate |
| Temporary construction panel | Avenue of the Palms (Cityside panels), #12, #14 (OSM w1252737734) | 3 est. | Step 3 r2: panel frame, clamps and stands clear in native crops; distance haze fixed (r5 PASS) | 4: materials |
| Wood privacy fence | not placed | | Not used yet | Rate when placed |

### Shoreline riprap

[`tools/lib/shoreline-generation.mjs`](../tools/lib/shoreline-generation.mjs) with
`tools/config/shoreline.json`, drawn by `game/scripts/world/shoreline_builder.gd`.
All are used on the `west_ferry_pilot` segment, around the ferry plaza and under
the landing pier.

| Asset | Where used | Level | Evidence | Next level |
|---|---|---|---|---|
| Quarry stones (5 boulder prototypes: top row, crest, shoulder, heap) | `west_ferry_pilot` | 3 est. | Step 1b round 3 visual PASS (`ce56ab45`): quarried blocks with chipped corners and mixed sizes, lying on broad faces. Owner direction (`4a0f9151`): quarried and dumped, so sharp corners; texture and colour stay | 4: materials. Carried finish: small flat chips litter the shoulder; a dark sliver under one crest stone |
| Cobbles (inside band) | `west_ferry_pilot` | | No verdict | Rate |
| Pebbles (3 prototypes, below the waterline) | `west_ferry_pilot` | | No verdict | Rate |
| Driftwood log | `west_ferry_pilot` | 1 est. | Round 3 review: "a smooth, untextured pole resting across stone peaks" | 2: a log's form (broken ends, root flare, bends) |
| Plank | one near the ferry landing | | No verdict | Rate |

### Vegetation

`PROPS` in [`game/scripts/world/street_vegetation_kit.gd`](../game/scripts/world/street_vegetation_kit.gd).

| Asset | Where used | Level | Evidence | Next level |
|---|---|---|---|---|
| Mexican fan palm | Avenue of the Palms (both curbs), Building 1 set pieces | 2 est. | Step 5 visual PASS: crown green sampled against ih02 (about 74/93/54 against 69/84/52), fronds stable in both renderers | 3: skirt and boot detail close up (the review asked for a web close-up) |
| Canary Island date palm (variants 0–3) | Building 1 set pieces | 2 est. | Step 5 PASS: full arching crowns, knob texture graded (`947fff1f`, `39c13159`) | 3: leaf scars and knob close up |
| Monterey cypress, old (variants 0–1) | Building 1 set pieces | 1 est. | Step 5 review: reads as an umbrella tree with a slim, straight single trunk and a light canopy, against the dark, dense multi-stem cypresses in the dated photos | 2: a dense dark canopy on several stems, with a root flare |
| Monterey cypress, young (variants 2–4) | ferry plaza set pieces, Cityside beds | 2 est. | Step 5 PASS (feathered to the ground, `947fff1f`); Cityside plant reviews | 3 |
| Sydney blue gum, young | Cityside windrow plazas | 2 est. | Cityside plant reviews: crown reaching downwind, a narrow open silhouette at 40 m (`ce45ec4d`); delta PASS at `8d11df7f` | 3: spray and bark detail close up |
| Island oak, young | Cityside beds | 2 est. | Cityside plant reviews: three distinct, filled crowns (`8d11df7f`, delta PASS). Its form is inference: no dated photo | A dated photo first, then 3 |
| Clump grass | Avenue of the Palms mulch beds | 2 est. | Step 5 PASS | 3 |
| Cityside low-plant kit (14 species: pacific reedgrass, dense sedge, rush, bronze clump grass, blue-eyed grass, seaside daisy, sea thrift, seaside woolly sunflower, California sagebrush, shrubby sage, California buckwheat, seep monkeyflower, dune tansy, white umbel perennial) | Cityside beds | 2 est. | Plant review R01 REWORK, R04 PASS WITH FIXES, R10 fixes, delta PASS at `8d11df7f`; whole-park PASS. The white umbel's species is unconfirmed, so its form is inference | 3: flower heads and leaf detail close up. Split a species into its own row when it is improved |
| Monterey pine, residential (variants 0–2) | None yet: the vegetation rollout places them | 2 (visual-review-vegetation R03) | R03 REWORK, crown only: a round oak-like dome at 40 m with even terraces against p5. Crown rebuilt from boughs and plumes after that verdict, not yet reviewed | 3: a broken, open crown; a reviewed verdict on the rebuild |
| Monterey pine, wind-pruned (variants 3–5) | None yet: the vegetation rollout places them | 2 (visual-review-vegetation R03) | R03 PASS WITH FIXES: low domes on clear trunks (p2–p4) | 3: side-to-side impostor tone |
| Spreading broadleaf (variants 0–3) | None yet: the vegetation rollout places them | 3 (visual-review-vegetation R03) | R03: layered pads, limbs with forks and bark relief. Species unresolved, so the photographed form (c2–c4, b1–b8) | 4: joined, darker cloud masses and scattered bronze, reworked after the verdict and not yet reviewed |
| New Zealand Christmas tree | None yet: the vegetation rollout places them | 2 (visual-review-vegetation R03) | R03: pom-pom crown closed; stems were straight tubes stopping at the crown, reworked after the verdict and not yet reviewed | 3: stems and limbs running into the crown (b5), a lighter underside |
| Mature eucalyptus | None yet: the vegetation rollout places them at the Job Corps entrance | 2 (visual-review-veg-models form round) | Form round accepted at `1f4a5318`: rebuilt from its limbs against the owner's Job Corps photos (Nov 2026), tall and open with sky and pale limbs showing. Sizes estimated from a street light in the photo | 3: finer clumps in place of the remaining pads |
| Weeping tree | None yet: the vegetation rollout places them at the Job Corps entrance | 2 (visual-review-veg-models form round) | Form round accepted at `1f4a5318`: offset hanging masses, one dense dome and one open tree on a thick low fork. Species unresolved, so the photographed form | 3: its tone, and more twigs in the open tree's top |
| Norfolk Island pine, young | None yet: the vegetation rollout places them | 3 (visual-review-vegetation R03) | R03 PASS: close tiers, pointed leader (n1) | 4 |
| Canary Island date palm, mature (variants 4–5) | None yet: the vegetation rollout places them | 3 (visual-review-vegetation R03) | R03: shaggy trunk and drooping globe crown (sv01, sv02), far level rebaked from the crown alone | 4: crown tone and trunk pattern |
| Indian hawthorn | None yet: the vegetation rollout places them | 3 (visual-review-vegetation R03) | R03: fine leathery mound with pale pink clusters (s1) | 4 |
| Pittosporum tobira | None yet: the vegetation rollout places them | 2 (visual-review-vegetation R03) | R03: too dark, fine hair rather than broad glossy leaves (s2). Reworked with broad leaves after the verdict, not yet reviewed | 3 |
| Red-tipped shrub | None yet: the vegetation rollout places them | 3 (visual-review-vegetation R03) | R03: slender, dull red at the shoot tips only. Species unresolved (s2) | 4 |
| Conical shrub | None yet: the vegetation rollout places them | 3 (visual-review-vegetation R03) | R03: fine ogive with a soft point. Species unresolved (s3) | 4: impostor width |
| New Zealand flax | None yet: the vegetation rollout places them, in planters | 2 (visual-review-vegetation R03) | R03: broad arching straps, but nearly black in sun; lifted after the verdict, not yet reviewed | 3 |
| Clipped hedge (variants 0–1) | None yet: laid along a line by the vegetation rollout | 3 (visual-review-vegetation R03) | R03: rows of ragged leaf mats over a core, open stems on the residential hedge (h1), white flowers on the glossy one (h2) | 4: the residential far level |
| Pale-seeded shrub (variants 0–2) | None yet: the vegetation rollout places it on the Mersea ditch bank | 1 (visual-review-veg-models form round) | Accepted at `1f4a5318` as the bare form (variants 0, 1): crossed cards in the low-plant family, one level; dark twigs at 10–30 m where the bank reads pale in the owner's photos (Nov 2026). Species unconfirmed, so the photographed form. Variant 2, thick with pale seed on lighter stems, added after that verdict and not yet reviewed | 2: a review of variant 2 on straw ground |

### Player

| Asset | Where used | Level | Evidence | Next level |
|---|---|---|---|---|
| Chest avatar | the player (`game/scripts/player/chest_avatar.gd`, `chest_avatar_parts.gd`) | 3 est. | Visual PASS after the fix round and the eye delta (`230df569`); code PASS. Owner (`7b070b90`): "the run and its blend are loved", so the run gait is protected; only the walk cadence changed | 4: wood, iron and gold materials (the owner chose the deeper brown wood) |

## Not listed here

- Buildings: the [building-stage checklist](ISLAND_BUILDING_STAGE_CHECKLIST.md).
- Terrain, ground cover, roads, shoreline and lighting as island-wide layers: its
  [environment layers](ISLAND_BUILDING_STAGE_CHECKLIST.md#island-environment-layers).
- Non-playable context scenery (San Francisco billboards, Yerba Buena Island,
  the Bay Bridge model).
- OSM `landuse=grass`, `landuse=construction` and marina areas, except where a
  zone above builds one.

# Known issues and to-dos

This file lists the known issues and planned work for the game. It is kept current as work lands: when a fix reaches `main`, its item is removed.

Coordinates are world x, z in metres (z points south), as in `generated/world/`. Items marked "seen in review" are what a reviewer saw in screenshots, not measurements.

## Being fixed now (before the release, about 2026-11-11)

These are on branches in progress, not yet on `main`.

- **Yard ground z-fight:** the 8th St / Avenue N north yard (#8, pale gravel) and the fire training yard (#15, asphalt) overlap at the same height over about 219 m² near x 412, z −339.
- **Coplanar street-ground layers** (from a scan of the generated world, 2026-11-05):
  - the parking-lane surface lies on the road at 0.078 m (about 55 m² in three places);
  - the gutter and the asphalt wear both lie at 0.081 m (about 6.5 m²);
  - the gutter lies only 1 mm above the pedestrian path (about 16 m²).
- **Pier and apron colours:** the Pier 1 deck renders beige and the marina pier (OSM w1222505177) teal; both are grey concrete in photos. The Gate 5 driveway apron renders dark where Street View shows light concrete.
- **Bay Bridge missing from Pier 1:** looking east (heading about 130) from Pier 1, the bridge isn't visible (seen in review, by 2026-11-05).
- **Street detail island-wide.** Today the street-detail layers exist only along the pilot route (ferry → Treasure Island Rd → Avenue of the Palms → Building 1), in Cityside Park and in the clutter yards. The rollout covers:
  - shoreline riprap around the whole island (only one segment, by the ferry plaza, today);
  - curbs, sidewalks, road markings and crosswalks;
  - street signs, lights, power poles, hydrants, cabinets and bus stops;
  - parked cars, bins and benches;
  - vegetation, including the ground tone: the generic lawn reads bright green on unmaintained lots that are dry scrub in aerials.

  Everything is placed procedurally from rules backed by dated evidence.

## Known issues on main (not scheduled)

- A thin strip of water shows between the grass and the root of Pier 1 (seen in review, by 2026-11-05).
- **Web build** (Godot's Compatibility renderer):
  - it looks about 15% brighter than desktop (seen in review, by 2026-11-05); parked by the owner;
  - it draws no decals, which the owner accepted, so spraying is off there and the Mersea mural is drawn as a mesh instead;
  - glass looks paler and more reflective than on desktop (seen in review, by 2026-11-05).
- **Mersea mural colour:** in the real mural the ground reads charcoal or navy through the corrugation, and the mural fills more of the wall height (seen in review, by 2026-11-05).
- **Ferry plaza lawn:** its dry-patch noise reads brown where photos show green turf (seen in review, 2026-11-03).
- **Ferry plaza gravel:** the gravel "shards" on the dirt read as grey slate triangles up close (seen in review, 2026-11-03).

## Buildings

- A building side with no dated photo of that side stays plain on purpose; no detail is invented for it. A new dated photo of such a side lets it be detailed.
- Finish items (seen in review, by 2026-11-05):
  - the generic "noisy stone" placeholder texture is still on a few visible walls:
    - the Fire Station 48 NNW notch, kept by an earlier study decision; changing it needs an explicit decision;
    - the B225 WSW wall;
    - the Maceo May SW corner;
    - the ends of 1317;
  - the Exposition roofs render tan or olive; photos show grey shingle;
  - the 901 Avenue B mansard skirt is too shallow: about 12° where about 30° is needed;
  - Navy Chapel (OSM w291189336):
    - a blank side faces Avenue of the Palms / Bruton;
    - the recessed rear entries have no steps;
    - the belfry slots should be mid-grey slats;
  - Maceo May: the WSW ground-floor windows at its north end sit above a 2 m dip in the terrain, and its inner courtyard is untouched.

## Clutter yards: accepted 2026-11-05 with known gaps

From the yard reviews.

- **#7 concrete recycling yard:**
  - the aggregate cones stand 10–20 m east of where the aerial shows them, because the 2023 elevation data still has the old mound flank there;
  - the plant area along the east edge is less busy than in the aerial.
- **#8 8th St / Avenue N:**
  - the material band along Avenue N is a regular run of crane mats and pipe sections where the aerial shows mixed piles;
  - the yard follows the May 2026 aerial, which conflicts with a nearly empty Nov 2025 Street View;
  - there are no portable toilets: the yard kit has none.
- **#9 Avenue M:**
  - the mound's outline is more regular than the lobed one in the aerial, and the debris band along the south edge is lighter;
  - the green screen has no wind-relief cuts.
- **#12 9th St / Avenue H:** the rest grid dropped one small soil pile, and the orange mesh's colour and opacity could match better.
- **#13 Gate 5:** the rim's corner joints are 1.0–1.3 m. They pass the check that the player can't get shut in.
- **#14 Avenue N soil spread:** the soil rows stop short of the lot's west and north margins.
- **The first batch (#1–#6):**
  - the corrugated-panel stretch of the 9th St fence;
  - #4's block wall and slat colour;
  - #2's junk-yard contents;
  - #6's barrier panel;
  - the containers under the cypresses;
  - a corrugated gate drawn as screened chain-link.

## Deferred by the owner

- Drivable cars: after the release.
- Audio: the game has no sound; "not now".
- Fences island-wide from the map data: not picked for this release. Today only fences in the street-detail zones are built; the rest stay data.
- Mac notarization: later. It needs a paid Apple Developer membership.
- The pelican rider variant of the player: paused.

## Code and tooling cleanup (low priority)

- **World generator and validator:**
  - The terrain-override slope guard (`tools/lib/terrain-overrides.mjs`) checks the triangles of the 0.5 m sample grid, not the simplified triangles it writes out.
  - An `osm_way` fence rule with `offset_m` places its gates by distance along the unshifted OSM line, so they drift at bends (`tools/lib/street-fence-generation.mjs`).
  - The draped-area layer check in `tools/validate_godot_world.mjs` sums each pair's overlap over the chunk-clipped triangles, so slivers along a shared edge could add up to a false failure.
  - The yard-kit floor check tests floor vertices on the sides of the plan rectangle, not the mesh's actual open edges.
  - Yard props rest on a 3 m sample grid, which can miss ditches narrower than 3 m.
  - The parked-car `reject` check in `tools/lib/street-clutter-generation.mjs` scans every placed item for each car, which is slow. The parked-cars rollout is fixing it.
  - `tools/render_naip_generated_vegetation_comparison.mjs` is broken: it reads `generated/world/vegetation.json`, which no longer exists. Fix or remove it with its outputs in `source_assets/vegetation/naip_2022/`.
- **Tests:**
  - The startup test (`game/tests/headless_startup_configuration_contract.gd`) checks that a demolished building has a demolition record, but doesn't compare it with the evidence in `tools/config/demolished-buildings.json`.
  - `building_shots.gd`'s `_moving_view` turns off the player controller right after the last move, without waiting for the player to come to rest.
  - `building_shots.gd`'s `MOVE_ACTIONS` duplicates the action list in `world_harness.gd`'s `release_input`; share one list.
  - The fit test's spray `"expect": "receiver_rejection"` checks that something other than a receiver stopped the spray, not that it was a street prop.
- **Player:** the chest avatar's `WALK_SPEED` (4.0) is a copy of `player_controller.walk_speed_mps`; couple them.
- **Mersea mural mesh** (`game/scripts/world/facades/mersea_model.gd`):
  - the view pull in its shader assumes a perspective camera, with no orthographic branch;
  - the 0.23 m clip should share a constant with the bottom rail;
  - the `ROUGHNESS` comment says the sheet keeps its own finish, but the shader sets a constant.
- **Docs:**
  - README.md shows `building_fit_test.gd` run with `--headless`, which the test refuses.
  - AGENTS.md still calls the vegetation a low-poly placeholder.
  - PLAYTEST.md and HUMAN.md should point to the Mac build that CI publishes.
  - AGENTS.md should state the decal policy: decals are used freely, and their absence on the web is acceptable.

# Known issues and to-dos

This file lists the known issues and planned work for the game. It is kept current as work lands: when a fix reaches `main`, its item is removed.

Coordinates are world x, z in metres (z points south), as in `generated/world/`. Items marked "seen in review" are what a reviewer saw in screenshots, not measurements.

## Known issues on main (not scheduled)

- A thin strip of water shows between the grass and the root of Pier 1 from the land side (seen in review, by 2026-11-05; still there on 2026-11-06).
- The Clipper Cove marina past the playable boundary (OSM w644986117, x −9 to 162, z 804 to 1021) is a flat pale teal sheet on the water, plain in the island overviews (seen at integration, 2026-11-06; the same on the earlier `main`).
- **Web build** (Godot's Compatibility renderer):
  - it looks about 15% brighter than desktop (seen in review, by 2026-11-05); parked by the owner;
  - it draws no decals, which the owner accepted, so spraying is off there and the Mersea mural is drawn as a mesh instead;
  - glass looks paler and more reflective than on desktop (seen in review, by 2026-11-05);
  - it doesn't run on iPhone, which the owner accepted on 2026-11-06, so it isn't being worked on. Release `c7db08fc` fails on the owner's iPhone with Safari's "A problem repeatedly occurred"; the previous release, `9056ad03`, opened. The phone's Console log shows the cause: iOS killed the page's web content process at its 2,048 MB per-process limit (about 2.1 GB used), about 9 seconds after that process started and 7 seconds after the 291 MB pack arrived. A cut removing 71 MiB of unread data from the web pack (278 to 206 MiB) is committed but parked unmerged on the branch `web/memory-20261106`. It hasn't been run in a browser, and it probably isn't enough on its own.
- **Mersea mural colour:** in the real mural the ground reads charcoal or navy through the corrugation, and the mural fills more of the wall height (seen in review, by 2026-11-05).
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
- Mismatches the street reviews found against dated photos (seen in review, 2026-11-05):
  - **Mersea lot:** at Street View pano TKhpp heading 190 (Sep 2025) a white event tent renders as a solid grey building with a roll-up door and windows; at heading 330 a white tent with a hedge renders as a flat white box.
  - The Mersea venue's containers are green where the photo shows blue in front.
  - The Cravath Street building at heading 42 is a blank brown box where the photo shows a modern white and grey panelled facade.
  - The green-teal roof of w34313544 is paler than the aerial's duller colour (seen in review, 2026-11-06).

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

## Street detail rollouts: landed 2026-11-06 with known gaps

From the reviews of the shoreline, street ground, street objects, parked cars, vegetation ground layers and tree placement.

- **Stop signs placed by rule, for the owner to check.** The owner said to keep them and list them here. They follow the map's stop rules, but no dated photo lies within 30 m of the sign (checked on the merged world, 2026-11-06):
  - all-way stops: 11th Street (2), Avenue D (2), Avenue E (1);
  - minor stops: Avenue D (2), Avenue E, Avenue of the Palms, Bigelow Court, Bruton Street and Lester Court (1 each);
  - streets where only some signs have a photo nearby: all-way on 9th Street (2 of 4); minor on 13th Street (1 of 3), 3rd Street (1 of 2), 4th Street (5 of 7), 8th Street (1 of 4), Avenue I (3 of 4) and Avenue M (3 of 4).
- **Street ground:**
  - Avenue B (OSM w8921273): the left curb's red stretch from 262 to 274 m along the way is shorter than in the photos.
  - Gateview Avenue (OSM w52721875): the Mar 2025 photo at 1395 Gateview Ave shows a concrete walk behind the right curb, about 640 to 735 m along the way; the game draws a verge there.
  - The red on the far curbs is too strong on Gateview Avenue's left side and on 13th Street.
  - 1395 Gateview Ct: the photographed faded red curb round the lawn lies on the housing site's parking apron (asset w96215667), past where a street curb can go, so it isn't drawn.
  - Gateview Court (OSM w8916719): the curb ends at the court's corners read as short blocks.
  - The KEEP CLEAR legend at Trade Winds isn't painted.
  - Asphalt tone: photos show paler, sun-bleached roads than the game. Parked as a look pass.
- **Street objects:**
  - Signs stand off their photographed spots at Bayside Drive / Gateview Avenue, Gateview Court / Gateview Avenue and Northpoint Drive / Gateview Avenue.
  - In the matched view at 9th Street / Avenue B the stop sign is 8.3 m away; in the photo it is 4 to 5 m.
  - The signal masts at the north Seven Seas Avenue crossing stand farther off than in the photo.
  - The road is a different width from the photo at 4th Street / Avenue M, 4th Street / Avenue H and Seven Seas Avenue / Trade Winds.
  - Pole n11611760988 is on the map but not in the Mar 2025 photo at Gateview Court.
  - Bruton Street's south run of lamps is rule inference, with no photo.
  - The merge with the street ground left some rule lamps unplaced: Johnson Street's left side has 3 of 5, Seven Seas Avenue 40 of 43.
  - One all-way approach has no sign: n65324985 on the unnamed way w8921299. It wasn't signed before either.
  - The "NO STOPPING ANY TIME" sign on the plaza mast isn't placed.
  - Finish: the Muni flag post has no perforations, and the EV bay needs more weathering (rusty bollards, bent posts).
  - Power lines: check them for shimmer in motion; the near wires are about 1 px wide.
- **Mersea lot and strip:**
  - The lot light (OSM n11230361247) has one arm where the photo shows two.
  - The lamp's island is too short and has no planting.
  - The built east row stands 1 to 3 m farther from the east edge than the real cars, and one west car is 5.9 m along the row.
  - The dumpster group at heading 10 stands farther right than in the photo.
  - The dumpsters have no finish yet.
  - The Sep 2025 photos of the strip show no cars; its row comes from the May 2026 aerial.
- **Johnson St lot** (the one recorded exception to the OSM layout; L2 accepted, L3 open):
  - The tall pole with a dome camera at its south-west curb (owner photo, ditch 1) isn't built.
  - Its west part sits up to about 1.2 m below its middle: the terrain slopes where the real lot looks flat. The terrain stays as it is.
  - The west curb's drainage gap and the rock pile behind it (owner photo, ditch 3) aren't built.
  - A short white mark at each stall's aisle end in the May 2026 aerial stays undrawn: it can't be read at 0.24 m. An owner photo in a stall row would settle it.
  - The gravel shoulder reads as a graded path.
  - Far stall lines break into dashes at low angles, in every lot compared (Johnson St, Clipper Cove strip, Mersea field).
  - From directly above, a pale chip shows at the inner tip of the strip beside the south-west hatch (seen in review, 2026-11-06).
- **Parked cars:** Avenue I's review is held, so its cars are unjudged.
- **Shoreline:**
  - Two small dark tips remain at the north slipway: one at the grass corner of the ramp's head, one at its water end.
  - The offshore wave wall (OSM w1011830371) and the jetty's marker post aren't built, and neither is the pale concrete pad near x −373, z −855 that the aerial shows.
  - The north jetty's stone (OSM w26767328) and the riprap rim read darker than the aerial from overviews.
- **East span of the Bay Bridge:** the west cable sags differently from the photos, the tower shaft has no slot, and the span has a single material.
- **Ground tone:**
  - One large dirt patch lies in the residential straw belt, and the lawn band along the residential kerbs is too even.
  - The football pitch (OSM w1252737754) has no line markings, so it reads as a blank dark slab; the aerial shows them.
- **Trees and shrubs:**
  - The ditch's bank near the owner's photo spot is thinner than the photo; revisit it with the Johnson St lot.
  - The bank-top shrub line at `ditch-bank-up` sits on one contour with even height.
  - The ditch's foreground stones were removed, not fixed.
  - The thicket mounds at 1349 Gateview have hard outlines.
  - Broadleaf impostors step about +21% at the 110 m switch. A separate round is queued.
  - `california_sagebrush` and `california_buckwheat` stand in as forms at the ditch, the Mersea strip and the 1349 Gateview thicket. Their species are unconfirmed, so don't describe them as natives.
  - 36 trunks stand on yard pavement with no mulch pit, all on real crowns where checked.
  - The Keppler Court pine at (−292.8, −433.7) changed from variant 1 to 2 within its pin when the Johnson St lot landed: the lot dropped three crowns, and species hang on a crown's list index (see the cleanup item below).
- **Performance:** the fixes are not in this release. The diagnosis is at `perf-1-20261106`, and the work is paused on the branch `perf/bake-merge-20261106`. Before these layers the spawn drew about 24,600 draw calls and 3.8 million primitives at 1440 × 900 (`6ba040d3`). The ground-cover shader now runs six noise calls per fragment.

## Deferred by the owner

- Drivable cars: after the release.
- Audio: the game has no sound; "not now".
- Fences island-wide from the map data: not picked for this release. Today only fences in the street-detail zones are built; the rest stay data. The street reviews saw three that are missing: a container wall at 11th Street, a container wall at 4th Street / Avenue M, and wooden fences at 13th Street / Gateview Avenue, which hide a shelter in the photo.
- Mac notarization: later. It needs a paid Apple Developer membership.
- The pelican rider variant of the player: paused.

## Code and tooling cleanup (low priority)

- **World generator and validator:**
  - The terrain-override slope guard (`tools/lib/terrain-overrides.mjs`) checks the triangles of the 0.5 m sample grid, not the simplified triangles it writes out.
  - An `osm_way` fence rule with `offset_m` places its gates by distance along the unshifted OSM line, so they drift at bends (`tools/lib/street-fence-generation.mjs`).
  - The draped-area layer check in `tools/validate_godot_world.mjs` sums each pair's overlap over the chunk-clipped triangles, so slivers along a shared edge could add up to a false failure.
  - The yard-kit floor check tests floor vertices on the sides of the plan rectangle, not the mesh's actual open edges.
  - Yard props rest on a 3 m sample grid, which can miss ditches narrower than 3 m.
  - `tools/render_naip_generated_vegetation_comparison.mjs` is broken: it reads `generated/world/vegetation.json`, which no longer exists. Fix or remove it with its outputs in `source_assets/vegetation/naip_2022/`.
  - `tools/render_world_coverage_evidence.mjs` fails on an unknown demolished status.
- **Street objects generator** (findings at `f4a6f827`, line numbers of that commit):
  - `stepOffSlope` in `tools/lib/street-furniture-generation.mjs:722` tests a spot with the `bus_stop` kind's 1.5 m radius, so a flag could go quietly to `osm_unbuilt`.
  - `except_cells` (`:1498`) is keyed by station index, so a spacing change can remove a different lamp.
  - A stale `shelter_anchors` entry (`:743`) does nothing and says nothing.
  - `on_posts` (`:1283`) has no distance limit.
  - The comment on `reject` (`:518`) doesn't mention `options.pad`.
  - In `tools/lib/street-ground-generation.mjs:2316-2324`, `own_line: false` overstates `counts.stop_bars` and needs no crosswalk.
- **Street ground generator** (`tools/lib/street-ground-generation.mjs`, line numbers at `03f645ae`):
  - The storm drain walk carries its distance (`walked`) across every curb face in turn, so any curb edit moves drains island-wide: one 1.11 m curb edge moved about 80 % of them. Restarting it for each band, or phasing it per edge, would keep such changes local, at the price of one island-wide move.
  - Restore the rule that a lot's `pattern` needs `osm_exception`. The `exactKeys` call at `:497` now allows either without the other.
  - About 9.3 m² of sloped concrete chamfer remains around (−210, 165) at the Johnson St lot's road end.
- **Shoreline and vegetation generators:**
  - The rock ground's tone comes from shader defaults, not the segment's tone.
  - In `tools/lib/shoreline-generation.mjs`, the "Side walls" comment (`:1692`) and the shoreline config's note are stale. So are the comments at `:43` and `:2299`, which still say the player is recovered at the outline (the shore lift replaced that).
  - The ramp foot's seed (code review's low, at `07a0f9e5`).
  - The ditch's axis lives in two places: `marsh_axis` in `game/resources/materials/world/ground_cover/ground_cover.gdshader:85` and the `mersea_ditch` rules in `tools/config/street-detail-zones.json`.
  - Canopy placement ignores walk-up lanes: the generated audit's `walk_up_short` grew from 32 to 37 sides. S4's island test still passes all 174.
  - A canopy tree's species hangs on its crown's list index (`identity` in `tools/lib/street-detail-generation.mjs:1775`, at `03f645ae`), so dropping a crown reshuffles the species of the crowns after it. Hash on the crown's position instead.
- **Tests:**
  - The startup test (`game/tests/headless_startup_configuration_contract.gd`) checks that a demolished building has a demolition record, but doesn't compare it with the evidence in `tools/config/demolished-buildings.json`.
  - `building_shots.gd`'s `_moving_view` turns off the player controller right after the last move, without waiting for the player to come to rest.
  - `building_shots.gd`'s `MOVE_ACTIONS` duplicates the action list in `world_harness.gd`'s `release_input`; share one list.
  - `tools/godot` starts Weston without `--idle-time=0`, so a rendered run stalls after 300 s idle. Keep render plans under 280 s until it's fixed.
- **Player:**
  - The chest avatar's `WALK_SPEED` (4.0) is a copy of `player_controller.walk_speed_mps`; couple them.
  - The shore lift could use `to.y = maxf(from.y, floor + lift)`, and its "Recovered" toast wording could say what happened.
- **Mersea mural mesh** (`game/scripts/world/facades/mersea_model.gd`):
  - the view pull in its shader assumes a perspective camera, with no orthographic branch;
  - the 0.23 m clip should share a constant with the bottom rail;
  - the `ROUGHNESS` comment says the sheet keeps its own finish, but the shader sets a constant.
- **Docs:**
  - README.md shows `building_fit_test.gd` run with `--headless`, which the test refuses.
  - PLAYTEST.md and HUMAN.md should point to the Mac build that CI publishes.
  - AGENTS.md should state the decal policy: decals are used freely, and their absence on the web is acceptable.

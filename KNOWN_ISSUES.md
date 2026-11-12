# Known issues and to-dos

This file lists the known issues and planned work for the game. It is kept current as work lands: when a fix reaches `main`, its item is removed.

Coordinates are world x, z in metres (z points south), as in `generated/world/`. Items marked "seen in review" are what a reviewer saw in screenshots, not measurements.

## Known issues on main (not scheduled)

- A thin strip of water shows between the grass and the root of Pier 1 from the land side (seen in review, by 2026-11-05; still there on 2026-11-06).
- Avenue H, Avenue of the Palms by Cityside and Avenue M have humps in the road from the generator: 32 m land-grid corners standing on stockpiles that are gone (on Avenue H by the truck lot, two humps of about 2.2 and 2.4 m over the USGS raster; diagnosis on branch `diag/bumpy-road-20261108`, 2026-11-08). The owner chose to leave them, because a future island-wide change to road generation may replace this.
- The Clipper Cove marina basin past the playable boundary (OSM w644986117, x −9 to 162, z 804 to 1021) is open bay water: its floating docks and moored boats are not modelled (the flat teal sheet that stood in for them was folded into the bay water, 2026-11-07).
- **Web build** (Godot's Compatibility renderer):
  - it looks about 15% brighter than desktop (seen in review, by 2026-11-05); parked by the owner;
  - it draws no decals, which the owner accepted, so the Mersea mural is drawn as a mesh instead;
  - glass looks paler and more reflective than on desktop (seen in review, by 2026-11-05);
  - on iPhone it runs, but its memory headroom isn't known. Release `c7db08fc` (2026-11-06) was killed by iOS at its 2,048 MB per-process limit. PR #19 (`df3edb02`, 2026-11-09) combined the owner's PRs #14, #15, #17 and #18: VRAM-compressed world textures, no bake inputs in the web pack, superseded housing geometry pruned from the bake and 94 web textures capped at 512 px. Its description says the same tree reached play in Safari on a physical iPhone (iOS 27.0.1) in about 12 s, the owner confirmed touch walking and driving, and the page was still up at four minutes. No RAM trace was taken, and no later release has a recorded iPhone run; the live `e0267099`'s pack is 148,863,584 bytes.
- **Browser stall while running:** in Chrome the frames stall for about 330 ms twice during a short run from spawn (about 0.6 s and 1.7 s after the keys go down), on both `c7db08fc` and the merged build, so the merge didn't cause it. Physics then catches up in a burst. It isn't there at idle (197 frames in 5 s at spawn). The cause is unknown, and it isn't confirmed for a real player: it was seen with synthetic key events in headed Chrome on Weston.
- **Web slowdown in tree-heavy views, unattributed** (release 2026-11-08: `c1f1e796` against the live `2068b992`, both web builds timed alternately A, B, B, A in uncapped headed Chrome, Compatibility renderer, Radeon 780M; median frame time per view):
  - spawn 18.3–19.1 ms against 16.3 (the old build sits at the 60 fps cap there); the Johnson St lot from 45 m up 12.7–13.0 against 10.5–10.6; the lot's sidewalk 16.0–16.1 against 13.7–14.1; the Cityside Park wall 2.3–2.5 against 1.6; the residential street about 1 ms slower (12.7–13.4 against 11.8–12.7); Pier 1 and the ferry seen from the spawn about even. The new build stays slower in the readings taken with no other engine running;
  - time to play is about 1.8 s longer (28.9–29.8 s against 26.5–28.5 s), and the pack is 1.5 MiB bigger (348,092,024 bytes against 346,487,324);
  - suspects: first the young island oak rebuild. The views that slowed most have 13 to 36 young oaks within 150 m, while the street and Pier 1 have none within 400 m. Each oak's leaf cards went from a fixed 120 to 210 to cards sown over the crown at 0.66 card spacing, plus filler cards, stems and a shadow mesh. Second, the ferry terminal: its own desktop timing at the plaza went from 122 to 132 draw calls, 1,389,873 to 1,453,818 primitives and 3.07 to 3.43 ms in Compatibility, and from 234 to 244 draw calls, 3,742,573 to 3,806,518 primitives and 7.49 to 7.42 ms in Forward+. The web timings record no draw calls or primitives, and no other branch measured any;
  - next: attribute it and trim it.
- **Mersea mural colour:** in the real mural the ground reads charcoal or navy through the corrugation, and the mural fills more of the wall height (seen in review, by 2026-11-05).
- **Ferry plaza gravel:** the gravel "shards" on the dirt read as grey slate triangles up close (seen in review, 2026-11-03).

## Grass and small stones (`game/scripts/world/ground_dressing.gd`)

- The web build draws none: the dressing runs only on Forward+.
- No Metal run yet: every frame time so far is the Linux Radeon 780M. `medium` is the default until a Mac test says otherwise.
- On the rubble mound the broken pieces only stand from about 12 m out, where they break its outline; nearer, its texture carries it alone, since faceted pieces read as pits or lumps beside it (visual review, 2026-11-07).
- A stone's contact shadow is a skirt on the stone's own mesh, not darkening in the ground shader, because the yard surfaces it lies on have no ground shader of their own to darken.
- Ground that grows nothing near the camera still pays for its tufts' vertices (about 2.3 ms on the Radeon 780M at `high` over the bare sand pad at x 328, z 383): cells can't tell what the capture holds without a read back.
- Mid-range grass toward the sun turns to dark brown specks where the backlight fades (release glitter-cove-clip and lawn-south-spawn views, 2026-11-07).
- A line of dry tufts on Building 2's WSW forecourt follows a dark streak in the ground texture (release review, 2026-11-07).
- No close capture yet of the rubble mounds at `medium` density.

## Sky and light (`game/resources/materials/world/sky/bay_sky.gdshader`, `game/scenes/main.tscn`, 2026-11-09)

Couplings, for whoever changes one side:

- The sky's `sky_horizon_color` (a shader parameter of the sky material in `main.tscn`, still (0.74, 0.80, 0.86)) is the colour the fog and the distant horizon's haze copy; see the SF card's item under the distant horizon. `sky_top_color` and the two ground colours are also unchanged from the old `ProceduralSkyMaterial`, and the gradient is the same formula.
- The clouds are part of the radiance map, so they are in the ambient light, in the water's and windows' reflections and, a little, in the fog's colour at distance (aerial perspective 0.35). `cloud_cover`, `cloud_sun_gain` and `cloud_sky_gain` therefore move the ambient light as well as the picture.
- Below the horizon the radiance map shows the land's bounce light (`land_bounce_color` times the live sun and sky), not the two ground colours the visible sky keeps there. Ambient is now 60 % from that map (`ambient_light_sky_contribution` 0.6, energy 0.52): shade open to the sky is cooler, shade under an eave warmer. In the small look scene a cream wall's warm cast (red minus blue, 8-bit) went from 23 to 20 in grazing sun and from 21 to 12 in shade, and white stayed neutral. Retune the two together.
- The clouds move by the global shader uniform `sky_cloud_drift` (`project.godot`, set each frame by `game/scripts/world/sky_weather.gd`). The shader must not read `TIME` or `POSITION`: either makes Godot redraw and re-filter the radiance map every frame. `headless_gameplay_contract.gd` checks `TIME`.
- `sky_weather.gd`'s wraps (72 km of drift, 4.5 km of rise) are whole multiples of the shader's noise tiles (`WEATHER_TILE_M` 24 km, `CIRRUS_TILE_M` 36 km at twice the drift, `SHAPE_TILE_M` 9 km and half of it deep, `DETAIL_TILE_M` 2.25 km). Change them together, or the clouds jump when the drift wraps (after about 2.2 hours of play).
- The Compatibility renderer gives a sky shader its colour uniforms and the sun's colour sRGB-encoded and decodes the result itself, so the shader decodes and encodes there (`scene_color`, `sky_output`). Without that the web's clouds came out dark; with it a cloud's tone is within one 8-bit level of Forward+ in the small look scene.
- The shared test harness (`game/tests/shared/world_harness.gd`) holds the clouds still at their start, so screenshots of one view match from run to run. Play lets them drift.
- The sun's light, colour, energy and position are unchanged (2026-11-13 12:30 PST; `node tools/solar_position.mjs "2026-11-13 12:30"` gives its elevation and azimuth). The sky draws its disc and halo on `LIGHT0_DIRECTION`, the light's own direction.

Limits:

- The radiance map redraws every 10 s (`reflection_refresh_s`) and when the sun changes, spread over a few frames (the Sky's incremental mode), so reflections and ambient light trail the visible clouds by up to 10 s (at 9 m/s, about 90 m of cloud, a few degrees overhead). Mersea's reflection probes capture once at startup and keep the clouds of that moment.
- The clouds are drawn for a camera on the ground: they don't come nearer as the jetpack climbs, and from above their base (1.1 km) they would still be overhead.
- Cost on the Mac's Metal, Forward+, 1440 x 900, old and new look timed in alternating blocks in one island run (2026-11-09; median frame): west shore toward the city 7.92 to 9.09 ms, 9th Street 12.71 to 13.05 ms, Bayside Drive housing 8.50 to 9.74 ms, ferry spawn 142.9 to 142.8 ms. Of that, glow is 0.35 to 0.45 ms, the sky 0.2 to 0.5 ms and the shadow splits 0 to 0.3 ms (they also change the draw calls: 4,230 to 5,619 at the housing view, 9,223 to 8,533 at 9th Street). The owner accepted up to about 2 ms. If it has to come down: `glow_enabled = false`, the Sun's old splits (0.1, 0.2, 0.5, no blend, blur 0.25), or fewer `MARCH_STEPS`. Marching the clouds in the quarter-resolution pass was cheaper but showed blocky cloud edges.
- With the clouds drifting and the radiance map redrawn every quarter second instead of every 10 s, the median frame rose by 0.05 to 0.15 ms and the 95th percentile by up to 0.8 ms, so a redraw every 10 s is a few slower frames, not a steady cost.
- The web build marches the same 40 steps as native, at the view's own resolution, because the Compatibility renderer has no half-resolution sky pass. Its cost in a real browser hasn't been measured.
- Glow is on in both renderers (additive, intensity 0.35, threshold 1.0). Its cost in a real browser hasn't been measured either; the fallback is `glow_enabled = false` for the web in `main.gd`.
- The cumulus are smooth at their edges from close up (the march runs at half resolution), the cirrus is a stretched noise that can read as brush strokes high in the sky, and one weather tile repeats every 24 km.
- The sun's first shadow split now ends at 40 m (was 80 m) with the splits blended and `shadow_blur` 0.5: shadows within 40 m are finer, and those from 40 to 80 m and from 120 to 160 m fall in a coarser split than before.
- Not rebaked or retuned: the tree impostors (baked under the old ambient), the water's `glitter_gain`, the distant art's haze. None of their inputs moved except the ambient light's make-up.

## Lighting (`game/scenes/main.tscn`, the look pass of 2026-11-07)

- SSAO is on (radius 3 m, Medium) and hasn't been timed on the Mac's Metal. If the Mac test finds it slow, the fallback is `ssao_enabled = false` in `main.tscn`'s environment.
- Most far tree impostors were baked under the old look and not rebaked: with the leans retuned, their tone against the near models comes to about 6% (look pass, 2026-11-07). The release's recheck rebaked `canary_date_palm` 6 (14% off) and `nz_flax` 3 (19% off) and kept `pittosporum_tobira` 3 and 4 (within 2%).
- `nz_flax` 3's far card covers about 55% more than its LOD1 at the 60 m hand-over, and its sides read +60/+2/−52/+2 in the bake check against ±35 or less for variants 0 and 1. A lean retune would move the siblings too.
- SSAO and the grass haven't been timed together on native Forward+: add both, together, to the Mac test.
- No close capture yet of the rebaked `canary_date_palm` 6 and `nz_flax` 3 at their switch distances.
- `nz_flax` 3's impostor at about 68 m doesn't match its mid level: flat light strips against spiky fans (island-oak review, 2026-11-07).
- `canary_date_palm` 6's far view is slightly ball-like (island-oak review, 2026-11-07).

## Bay water (`game/resources/materials/world/water/bay_water.gdshader`)

- The water's rings scale with the camera's far plane. With gameplay's 26 km far plane (skybox, 2026-11-08) the outer ring lies down to water level from about 21.6 km up, flat from about 24.2 km, so it can't wall in the camera near the far plane's height. From there the water ends about 6 km out, less higher up, and sky shows below the horizon beyond it, at the far plane's limit.
- Scenery in the last few percent of a view's depth, below eye height, stands behind the outer ring (water pass, 2026-11-07). Every camera now sees as far as gameplay's 26 km (skybox, 2026-11-08), so the western span is well inside; only the distant horizon's land carried on behind its ridges reaches that far.
- Seen from the jetpack toward the sun, the far sun path is a solid white patch: from 120 to 160 m up, its largest clipped area is about 2% of the frame (`glitter_limit` 2.0, `glitter_gain` 2.0, under the merged sun of 2026-11-07). The owner accepted it on 2026-11-07 as what real water does, so it stays as reviewed. At ground level the path is a broken sheen.
- `glitter_gain` was tuned with the sun's specular at 1.0. The merged sun has `light_specular` 0.5 with more energy and exposure, so the sheen is weaker and the clipped core brighter (the clipping is owner-accepted). Note "tuned at specular 1.0" if it is retuned.
- Faint diagonal streaks show in the jetpack glitter; they were already on the water branch.

## Distant horizon (`game/scripts/world/fresh_bay_horizon.gd`, 2026-11-08)

- Judged from walking and driving height only (owner, 2026-11-08). From high on the jetpack, and in the raised island overviews, its land shows flat plateau tops and hard edges that nobody has reviewed.
- Between the east span's Oakland abutment (about 4.2 km out) and the horizon's Oakland shore (5.0 to 5.3 km) water can show; the owner accepted it (2026-11-08).
- Left from the first visual review (skybox-visual-review-r1, 2026-11-08):
  - the East Bay ridge, city and port cranes read too faint;
  - Alcatraz's cellhouse;
  - Angel Island against Marin;
  - the bare ridge between Telegraph Hill and the Golden Gate, which should read as low city.
- The SF card's haze is a set share (12 %, with its darks lifted) of the horizon colour, a copy of `main.tscn`'s sky horizon (the sky material's `sky_horizon_color`) and fog light colour (0.74, 0.80, 0.86), not the scene fog: if the look pass changes either, retune `city.gdshader`'s `haze` and `haze_share` with it. The rest of the distant art keeps the PR's own light veil.
- Follow-ups from the code review (skybox-code-review, 2026-11-08):
  - The Golden Gate Bridge is about 200 beams, each with its own material and draw call (the horizon is about 266 meshes; looking west it adds about 100 draw calls, +108 at the west shore's SF view on native). Batching the beams into one ArrayMesh would save about 100 of them without changing the look.
  - The sector textures have no mipmaps, yet `sector.gdshader` samples them with `textureLod(…, 2.0)`, so its "quiet" detail mix does nothing.
  - Dead code: `RADIUS` and the `radius` local and parameter of `_mainland_backing` in `fresh_bay_horizon.gd`, and the `ground_triangles` the eastern background collects but never reads.
  - `sector.gdshader:50` hard-codes `155.882136`, the south sector's start bearing.
  - The blockout JSON loads have no null check: a malformed file errors at build instead of failing clearly.
  - The 26 km far plane may make Forward+'s cluster slices coarser; not measured.

## Landing dust (`game/scripts/player/landing_poof.gd`, 2026-11-07)

- The dust's shader warm-up runs on the avatar's first physics tick; it isn't tied to the loading screen.
- Dust on dirt is faint.
- On the web (Compatibility) the dust is blobby.

## Ferry terminal (`game/scripts/world/ferry_terminal.gd`, 2026-11-07)

- In a narrow case a recovery lift can put the player inside the gangway.
- In the Compatibility renderer it costs about 0.36 ms more at the plaza (3.43 against 3.07 ms on the Radeon 780M).
- The gameplay contract probes the docked boat at one point; a second boat probe would be a stronger check.
- Seen head-on, the bow has a "tusk" shape (visual review).
- The ramp beside the walkway isn't built.
- The visual review flagged the rhythm of the breakwater's base.
- The boat's compartments, its starboard side and the bay-facing faces are inferred. The owner approved mirroring the port side to starboard.

## Drivable cars (`game/scripts/vehicles/`, 2026-11-08)

- There's no animation for getting in or out: the player appears in the seat, and beside the door (owner: none needed). At the wheel the driver is the chest avatar's own parts, a little smaller, with no legs and no steering (`car_driver.gd`), drawn only at the hero level: past 13 to 15 m, and on the web, the near level's opaque glass hides it (2026-11-12).
- The player stands on a car as drawn within about 2 cm: the collision pieces keep only the corners within 1.5 cm of the drawn outline, and the roof is flat out to its rails at the height 0.7 of the way out, so on a roof's crowned middle the feet stand about 1.7 cm into it and at its rails as much over it. A rounder roof let a knocked car roll over and on like a barrel (2026-11-12).
- Each car's dirt (0 just washed to 1 filthy) comes from its row id; about half the parked cars are nearly clean and a quarter clearly dirty. It dusts the paint, trim and rims, never the glass, and the yards' vehicles (their own kit) stay as they are (2026-11-12).
- `tools/check_street_car_meshes.mjs` still finds small faults on the rebuilt cars, all a few square centimetres or less: slivers turned inside out at lamp bowls, the cab-to-body step of the pickup and utility and the van's lining by its A pillars; a few see-through rays, mostly at the far level and the hero level's interior through its wheel arches; and groove ends 1 to 3 cm wide at the van's and wagon's nose corners and the fastback's trunk corner (2026-11-12).
- The storage yards' towed vehicles (travel and fifth-wheel RVs, the concession trailer, the trailers and the boats on trailers), their buses and their machines (excavators, wheel loaders) stay parked props: they can't be driven or shoved. Their vans, box trucks, food-truck step vans and class A and C RVs can, since 2026-11-11 (owner).
- A yard truck's or RV's collision is a few boxes read off its body (`drivable_car.gd` BODIES): up to a few tenths of a metre more than the body above a hood or a cab roof, and the cab's corners rounder than the boxes. Their handling numbers are arcade defaults: heavier and slower than a car, the same suspension, grip and mild anti-roll, so the tall ones tip over in a hard turn even at moderate speed (as the owner liked of the box trucks on 2026-11-08).
- No engine, tyre, crash or splash sounds (the game has no audio).
- The shoreline riprap is drawn only; cars (and shoved K-rails) roll down a smooth ground of their own over the stones (2026-11-10; in rows about 5 m apart since 2026-11-11), not the stones themselves: about 0.65 m over the underlay, so a car rides on the tallest stones and over the gaps between them, and a few of the crest's biggest boulders stand a little over it. Its climb starts up to 1.1 m inside the outline and keeps off drawn roads, paths and paint but for rare spots at the very edge (the code review found about 517 sample points, all within 1.15 m of the outline, where it stands more than 0.1 m over the land under them), so a car crawling to the edge rises off the grass in its last half metre. A car rolling in nose first stays on its wheels until it is clear of the rocks, so it goes a little deeper before it sinks.
- At the west_north / north_tip joint by the north tip, near (-373.5, -861.3), the cars' ground steps up by as much as 1.04 m over a few metres just inside the outline (sampled 0.25 m in), so a car driven straight off the edge there may bounce or stall; it can still be driven on, or put back on land with R.
- A car driven at the Yerba Buena causeway's crossing stops at the island's edge against an invisible barrier on open grass (2026-11-11); on foot the edge there is invisible too.
- On the west shore path a car drives level through the inland riprap, its wheels and lower body inside the stones (as on main).
- A car flipped farther than 60 m from the camera shows its open underside: the far detail level has no underbody, which saves triangles on every parked car; near cars are closed (2026-11-08).
- Cars draw three levels (2026-11-09): the hero level for the driven car and the six parked cars nearest the camera within 13 m (put back beyond 15 m), the near level to 60 m, the far level beyond. The hero level has see-through glass over a modelled cabin; the near and far levels have opaque dark glass, so a parked car's windows lose their see-through cabin at the 13 to 15 m hand-over, and a seventh car close by in a full car park stays at the near level. The web build has no hero level at all (its pack leaves `street_car_hero_kit.glb` out): there every car, the driven one too, draws the near level.
- A hero car's shadow comes from its shadow caster (the far body drawn 2.5 cm inside the surface), so small parts (mirrors, roof rails, spokes) cast no shadow of their own and the cabin gets no sunlight through the glass.
- The cars' glass is drawn after the opaque world without writing depth: two hero cars' panes seen through one another are tinted in the order of their distance from the camera to each car's middle, not pane by pane.
- A gate's two stout posts stay standing when a car scrapes past them through the opening; only the posts and panel stands of runs go down with their bays (2026-11-08).
- Where the land under a road dips, a fast car floats over the crests for a moment: on Seven Seas Avenue it dips about 0.9 m over 20 m.
- Body-colour car roofs are a touch rougher than the rest of the paint, parked cars' too, so the fixed sun doesn't flare white across them from a low view (2026-11-08).
- The chase camera's arm stops at street props as well as the world (so it never sits inside a parked car): a lamp post or palm between the car and the camera pulls the view in for a moment, and a sideways glance over kerbside cars passes just over their roofs (2026-11-08).
- A car pushes the pitch's ball with a scripted bumper push (the ball's own push model, `vehicle_manager.gd` `_push_loose`), not by contact alone: the hull's raked nose sits about a ball's height up, and without the push the car rode over the ball (2026-11-08).
- Taillights read a dull brownish red in shade (visual review, 2026-11-08).
- From raised views the dirt ramps still read as crisp blocks: hard straight shoulders, tyre-worn bands like planks and a skirt with a straight run to its ragged edge (visual review, 2026-11-08).
- The Job Corps perimeter isn't built yet. When its fence rule lands it needs `"breakable": false` in its params, so cars stop at it (owner, 2026-11-08); every other fence breaks bay by bay under a car.
- The car ramps in three empty lots (the 12th Street and Avenue D dirt lot, the north slab site and the former school lot by Aracely Cafe) are an invented gameplay feature the owner asked for, not something on the island.
- The cars' index of the drawn ground and ways is built twice at load, about 76 ms: once in `world_loader.gd` for the shoreline (`VisibleGround.new()` before `ShorelineBuilder`) and again in `vehicle_manager.gd` (`_visible_ground.build`) (code review, 2026-11-11).
- Not covered by any test: pausing while a car rolls down the riprap, `R` while a car is sinking, and a native run of the web smoke's water leg (code review, 2026-11-11).

## Touch controls (`game/scripts/ui/touch_controls.gd`, `touch_use_button.gd`, 2026-11-08)

- In a car, dragging the right side doesn't look round: the chase camera follows the car, and touch has no glance like the mouse's.
- Touch has no R: nothing resets a car to land or recovers the player on foot. A car on its roof rights itself, and one in the bay comes back on its own.
- On a touch browser with a keyboard, pausing, resizing or lifting RISE lets go of the handbrake (and the jetpack) even while a physical Space is held, until Space is pressed again (code review, 2026-11-08).

## Pause menu and confetti polish (`game/scripts/ui/hud.gd`, `game/scripts/world/goal_confetti.gd`, 2026-11-11)

Non-blocking notes from the reviews:

- The pause menu's unfocused buttons barely read as buttons: their fill is nearly the same as the panel's.
- The loading screen's Controls button still has the old see-through style.
- While the controls screen is open, the loading progress is hidden.
- On the web, the first goal may hitch once while the confetti shader compiles (not verified).
- Resuming (`_set_paused(false)` in `game/scripts/main.gd`) captures the mouse even when `capture_mouse_on_ready` is false, as the test harnesses set it (code review, 2026-11-11).
- `goal_confetti.gd`'s `on_screen` clamps the tone map's white only at 0.001 (`maxf(environment.tonemap_white, 0.001)`), not at 1.0 (code review, 2026-11-11).
- The gameplay contract's glancing walk past the ball (`_check_soccer_ball` in `headless_gameplay_contract.gd`) allows up to 3 m/s along the walk; the bound could be tightened to under 1.0 (code review, 2026-11-11).

## Yerba Buena Island (L1, `tools/lib/ybi-context-generation.mjs`, 2026-11-08)

- YBI reads hazier than the dated photos (the scene's haze floor); the owner kept the haze.
- Its housing is OSM's buildings only, so anything missing from the frozen snapshot is absent.
- The VTS station's lattice towers aren't modelled.
- In the May 2025 view the east grove is sparser than in the photo.
- The summit reservoir's bank form is approximate.
- The Point of Infinity's glint follows the fixed sun.
- In the Compatibility renderer (web) YBI costs up to 37% more frame time in the worst YBI-facing view.
- The plants' nominal heights are kept twice, in the street-vegetation kit and its Node mirror (`STREET_VEGETATION_PROPS`); the game checks that they agree only at load.
- The Point of Infinity draws its true geometry, so from Treasure Island its upper reach is fainter than a pixel (the owner's choice, 2026-11-08).

## Causeway join and token closure (`tools/lib/ybi-context-generation.mjs`, the `road_closure_barricade` prop, 2026-11-08)

All four were seen in the visual review (2026-11-08) and left as non-blocking:
- The barricades' shadows on the road have beaded edges, clearest from above. Rebuilding the rail stripes from shared edge points didn't change them, so they look like the sun's 800 m shadow range aliasing thin bars.
- Where the median's end cap meets YBI's grass strip, the left (southbound) yellow line has a short kink.
- The two signs' backs are plain grey.
- Up close, the bottom edge of the median's end cap looks slightly jagged.

## Bay Bridge (`game/scripts/world/bay_bridge_builder.gd`, 2026-11-08)

- The western span's towers have 3 X panels where the photos show 4, and no gusset nodes or top gallery.
- The western span's main cables are thin and grey, and its deck truss is faint.
- The transition girders are slightly light.
- Optional: a gap line near W2.
- The self-anchored span's deck reads at about 0.68 times the sky's value.
- The SAS tower's lit faces are dimmer than its cable fan.

## Buildings

- A building side with no dated photo of that side stays plain on purpose; no detail is invented for it. A new dated photo of such a side lets it be detailed.
- City Building 201 (w34313545), from the 2026-11-06 study:
  - the OSM service road along the WSW and SSE sides shows as a darker band where the photos show one worn surface. This is deliberate: the road stays represented, and the lot is darkened to meet it;
  - the lot mesh still carries the building's source key, so the fit test and close-ups count it in the building's box, which makes the box bigger than the building;
  - the lot's cracks go soft in the closest ground views, because the stain tile is about 25 px per metre.
  - OSM power pole n11545781132 is `excluded` (`inside_building`) in `street_detail.json`, so it isn't drawn; it falls about 0.5 m inside the frozen footprint at the ENE step;
  - the lower south apron dust strip is soft up close, and its dark slashes could read as a cast shadow (seen in review, 2026-11-07).

- **Owner shot list, Maceo May (OSM r19685981):** these walls have no dated photo, so they stay plain:
  - the court's west and north walls, its east wall below the top two window rows, and its south wall below the upper floors (an undated architect's photo shows the east wall, which doesn't count);
  - the middle of the north wall along the lane to Star View Court, seen only at a grazing angle from each end.

  A square-on walk down the lane, and the court walls if they can be reached, would let them be modelled.
- **490 Avenue of the Palms (OSM w1272162518):** only its east block's ground floor stands level with Garden Walk; the block's NNW end wall stays on the base floor with the wing beside it. Everything west of that still sits on the 2023 excavation (land 1.1-3.9 m, where Street View palms-wsw01, palms-n-corner02 and palms-nnw-end04 of Nov 2025 show flat ground about 4 m), so the podium's east end meets a bank and Johnson Street falls along the NNW end. The SSE end and the ENE wall also differ in detail from Street View wsw03 (Sep 2025) and owner photo n1 (Nov 2026). Its NNW end has three large glazed bands and a white ground band over a dark upper band in Street View palms-nnw-end04 (Nov 2025), but the game has plain storeys.
- **Star View Court (OSM w1212173437):** its walk side lacks the bed and the dark tile bays of owner photos n1 and n2 (Nov 2026), its stoops aren't modelled (n2: doors a few risers above the walk), and the bed along its north wall in Street View starview-nw01 (Nov 2025) is a concrete edge.
- **Garden Walk (w1249412095):** Johnson Street's sidewalk still crosses the walk's north mouth, where Street View starview-nw01 (Nov 2025) shows the aggregate running to the curb, and the drive apron at Maceo May's Seven Seas portal is asphalt where Street View ss02 (Jun 2026) shows concrete.
- Finish items (seen in review, by 2026-11-05):
  - the generic "noisy stone" placeholder texture is still on a few visible walls:
    - the Fire Station 48 NNW notch, kept by an earlier study decision; changing it needs an explicit decision;
    - the B225 WSW wall;
    - the ends of 1317;
  - the Exposition roofs render tan or olive; photos show grey shingle;
  - the 901 Avenue B mansard skirt is too shallow: about 12° where about 30° is needed;
  - Navy Chapel (OSM w291189336):
    - a blank side faces Avenue of the Palms / Bruton;
    - the recessed rear entries have no steps;
    - the belfry slots should be mid-grey slats;
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

## Wastewater plant construction site (OSM w775820810): landed 2026-11-08 with known gaps

From the site's reviews.

- The green screen is a flat, opaque matte, as on every fence of its shared type.
- The piles are smooth and evenly spread, not where the aerial's piles are.
- 13th St lacks the tall black fence, and the site fence stands behind the verge there.
- Gate 2 is narrowed to 5 m.
- The banners are plain.
- A dry-straw patch lies beside the piles.
- The K-rails stand off the fence, with gaps.
- Side effects: the switchyard fence w1242725090 is now solid, and tree c0041 moved 1.5 m.

## Athletic fields (2026-11-08, `pairc_na_ngael`, `rugby_field_b` and `soccer_pitch` zones)

The GAA pitch (OSM w99060807, Páirc na nGael), the rugby field (OSM w99060801,
"GAA Field B" in OSM) and the turf pitch (OSM w1252737754) got their fences,
lines, goals, nets and portable light towers, and the GAA field's spectator wall
and bleachers, from Mar to Nov 2025 Street View, the 2026-05-26 aerial and the SF GAA
photos of 2025 and Jun 2026. What isn't there yet:

- No dated photo fixes where these stand, so they aren't built: the GAA field's
  electronic scoreboard, its teal container concession stand, the blue
  timekeeper's booth and the low spectator rail along the touchline; the turf
  pitch's dark green shelters and benches on its apron (seen only from above).
- The GAA field's south-east bleachers stand 4 m north-west of the aerial's white
  block, to keep a carriageway's clearance from the service road beside them. The
  board wall is one run with no openings; one club photo (WW1_6858) may show an
  opening that the others don't.
- The turf pitch's windscreen fence stops 3 m short of the south corner (Avenue I
  at 8th Street) on both sides: no photo shows that corner, so it stays open.
- The fields' lights are portable light towers on trailers, which move. The rugby
  field's one stands where Street View caught it on Avenue H (Sep 2025), 3 m
  inside the fence, and the GAA field's one in its corner at 11th Street and
  Avenue H (Mar 2025), on the photo's bearing at an inferred 26 m, its heads
  turned over the GAA pitch by inference. The turf pitch's one stands on its
  Sep 2025 bearing from 9th Street at an inferred 37 m (no turf tower in Mar 2025,
  and neither aerial shows it). Their 9 and 9.5 m masts are estimates. Four
  dark spots on the turf's south-east apron in the 2026-05-26 aerial match
  nothing photographed, so they aren't modelled.
- The GAA and rugby fields' low concrete curb is photographed on Avenue H and
  11th and 13th Streets; along Avenue E and Avenue I it is assumed to continue.
- From raised views far off, the pitches' 10 cm lines break into dashes: the
  shared street paint has no minimum width on screen.
- A driven car breaks the fields' chain-link and windscreen fences bay by bay, as
  it does other kit fences: a broken bay's concrete curb stays drawn but is no
  longer solid, since the bay's box covered it. The ball-stop nets are
  `breakable: false`, so a car stops at them.
- The vehicle contract's field case (`_case_field_net` in
  `headless_vehicle_contract.gd`) checks only that some bay broke, not that its
  broken key (the fence breaker's `fence_id`, `"<street_detail_id>|<key>"`)
  belongs to the windscreen.
- Low, for later: the soccer goal's net depth is worked out in three places in
  `street_furniture_kit.gd` (its net, its frame's stays and its net walls) and
  wants one helper; the light tower's footprint
  (`tools/lib/street-furniture-generation.mjs`) is 2.8 m across where its
  outrigger pads reach 2.9 m.
- The rugby pitch's frame was moved 5.4 m east and 3.1 m south from the aerial,
  where the aerial's fence lies that far from OSM's; the GAA pitch needed no move.
- Not modelled: the containers, sheds and the school bus round the rugby field,
  and the GAA field's strip of containers and sheds by Avenue E.

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
  - Inferred from `tools/clip_audit.mjs`, not seen in a render: `major_area_amenity` and `major_area_paved` lie 1 mm apart over 10.7 m² at (235.4, 223.8), on the 4th Street lot's south edge, so they could fight on depth there.
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
- **Johnson St lot** (a recorded exception to the OSM layout, with the Mersea promenade; L2 accepted, L3 open):
  - The tall pole with a dome camera at its south-west curb (owner photo, ditch 1) isn't built.
  - Its west part sits up to about 1.2 m below its middle: the terrain slopes where the real lot looks flat. The terrain stays as it is.
  - The west curb's drainage gap and the rock pile behind it (owner photo, ditch 3) aren't built.
  - A short white mark at each stall's aisle end in the May 2026 aerial stays undrawn: it can't be read at 0.24 m. An owner photo in a stall row would settle it.
  - The gravel shoulder reads as a graded path.
  - Far stall lines break into dashes at low angles, in every lot compared (Johnson St, Clipper Cove strip, Mersea field).
  - From directly above, a pale chip shows at the inner tip of the strip beside the south-west hatch (seen in review, 2026-11-06).
- **4th Street lot** (OSM w96698661):
  - Its curbed islands and planted strips aren't built, only its stall rows, because a new curb moves storm drains island-wide (see the drain walk item under the street ground generator).
  - Four traced crowns on its west and south edges (c0015, c0016, c0017, c0023) stay unplanted, as they were: their trunks' wells would reach off the paving. The islands would settle them.
  - The trees' species is unresolved. `spreading_broadleaf` stands in, denser and darker than the open yellowing crowns of the Sep 2025 photos.
  - Crowns c0005, c0006 and c0007 are date palms on the May 2026 aerial alone; no dated street photo shows them.
  - Its trees stand in round mulch discs on open asphalt, where the real ones stand in planted islands, mostly long strips (seen in review, 2026-11-06).
  - Its asphalt is dark and clean; the real surface is pale and weathered (seen in review, 2026-11-06).
  - Its stall lines break up past about 50 m, as in the other lots (seen in review, 2026-11-06).
  - The long side of the 655 building (OSM w34313513) reads blank in the lot views, where the photos show dark glazing (seen in review, 2026-11-06).
  - Lot trees vary only through `spreading_broadleaf` variants 0 and 1. Variants 2 and 3 are the old wide forms, 12 to 14 m across at the kit's smallest scale against the photos' 6 to 8 m.
  - At its south-east corner the Sep 2025 photo at 351 Avenue H shows the Job Corps sign, its planting, a chain-link fence and the bus shelter about 8 m from the camera. None of the first three is built, and the shelter (OSM n1249019421) stands about 15 m east of that.

- **Mersea ditch and promenade** (owner video and track, 2026-11-06):
  - The owner's "boardwalk" is the wide paved promenade, a recorded exception to the OSM layout like the Johnson St lot. Its close footage stops at about z 236, so north of there, to the fence corner seen from the walk, it is plain surface and paint.
  - Shot list for the owner, to finish it: from about (-400, 236) north past the tent to Mersea's west side, looking both ways along the walk; the ditch's north end, from the 9th Street side.
  - The rust-steel sculpture on the lawn by the promenade isn't built. An owner 3D scan exists: https://www.kiriengine.app/share/download/bc9ac0d2f54245a6ae13a65ba1849253
  - Plants at the ditch and along the walk are described by form; their species are unconfirmed.
  - OSM's chain-link w1212173468 across the walk isn't built, by rule: the footage runs through its line, and the owner walked through it.
  - Mersea's tent w1001544698 is plain massing where the footage shows its glazed end; it is accepted work, left unchanged by this study.
  - The land grid keeps a hump about 0.45 m high in the road near s 128 (about (-408, 216)): those cells sit beside the tent's footprint, and splitting them would re-cut a foundation.
  - The Johnson St lot's asphalt reads bluer than the footage's from the road end (frame D4).
  - From the ditch side (frame D4 and the owner's bank photo) the cottage reads about 7 m further south than it stands, against the palm; it stays where the road frames put it.
  - A hairline of the old path's pale surface shows along the seal's seaward edge for about 7 m near s 15-21, and pale pinholes about a metre apart along the seal's joint at s 28.5: the path lies under the lots by a centimetre and its own triangles come through. Fixing it means a higher lift for every lot, or a new surface under this one.
  - The cottage's bay throws a soft shadow onto the wall under it, blurrier than the footage's (a sun-shadow resolution limit, smaller since the bay went shallow).
  - The ditch's mats and brush are crossed cards: at a walker's feet the slope reads as tufts over a painted thatch, not the owner's photo's deep tangle, and from straight above, on the jetpack, they show as small crosses. Accepted as a known limit (visual review, 2026-11-07); the planned ground-dressing work should address it.
  - The slope's 8,800 tussocks took the island's vegetation rows from about 31,500 to 37,800. Their cost hasn't been profiled.
  - Any land edit re-rolls the riprap: the Mersea study's terrain moved 27,193 shoreline stones a little, out to the far shore, because each stone's draw follows the ones before it. `shoreline.json` is packed, so its diff shows none of it.
  - In the Compatibility renderer vertex colours come out darker than in Forward+, so tinted cards and `shade_low` feet read dark on the web. The ditch's plants carry their tones in `marsh_atlas.png` to stay clear of it, except the dark scrub.
  - Mersea lot's cars: a planted low plant no longer takes a lot's stall, so two cars came back nearer the aerial's north-east gathering at about (-335, 78). A 0.44 m2 pocket by the field fence still bars the stall at (-330.8, 113.1), on the terrain the ditch re-meshed; its car moved 5 m along the row. That stall's cell name is shared with the stall at (-345.1, 204.4) (`island_lot_cars` cells aren't unique across the lot's rows), so the car at the Avenue A strip's west edge went 20 m along that edge to (-357.2, 183.4).
  - The ditch's water blocks stand level on a shoulder that falls 4% along them: their corners sit up to 0.11 m clear of the ground or 0.13 m into it.
  - The promenade's rock bank has one coarse body (`shoreline_builder.gd`): it hovers up to 1.68 m over bare land at the ramp's start and north end, where the stones thin out, and its two end faces are invisible walls.
  - The marsh's straw flecks look like flat splats at 2x zoom.
  - `street_paint.gdshader`'s kinds 13-15 use up the 16-slot stride (`PAINT_VARIANT_STRIDE`): a new paint kind means widening it.
  - The marsh's floor level and the tile sizes are constants in both `ground_cover.gdshader` and the configs (`terrain-overrides.json`, `ground-cover-map.mjs`); change them together.
  - The rock band's end-face note above and all the limits logged here stay.
- **Parked cars:** Avenue I's review is held, so its cars are unjudged.
- **Shoreline:**
  - Two small dark tips remain at the north slipway: one at the grass corner of the ramp's head, one at its water end.
  - The offshore wave wall (OSM w1011830371) and the jetty's marker post aren't built, and neither is the pale concrete pad near x −373, z −855 that the aerial shows.
  - The north jetty's stone (OSM w26767328) and the riprap rim read darker than the aerial from overviews.
- **East span of the Bay Bridge:** the west cable sags differently from the photos, the tower shaft has no slot, and the span has a single material.
- **Ground tone:**
  - One large dirt patch lies in the residential straw belt, and the lawn band along the residential kerbs is too even.
  - The pitch's concrete apron is drawn over the land like the parks' paving, 0.1 m up, but the ball rolls on the land, so on the apron it sinks about 0.1 m into the concrete (on the turf and its lines, 2 to 3 cm). No capture shows the ball on the apron yet.
  - From grazing distance the pitch's lines break into dashes, and they likely shimmer in motion.
  - Dark specks of turf show along the pitch lines' edges, where the shared white paint's wear mask cuts through.
  - The apron's joint grid runs on the world grid, diagonal to the turf edge.
  - South of Maceo May, at about x −196 to −146, z 278 to 300, the worn band may show as a dotted dirt line (unverified).
  - The 2026-11-07 release's merge left 1,833 ground-cover map cells that match no parent branch, where the paving-edge wear meets the new Mersea, Garden Walk and Aracely paving. That combined look hasn't been seen up close.
- **Trees and shrubs:**
  - The ditch's bank near the owner's photo spot is thinner than the photo; revisit it with the Johnson St lot.
  - The bank-top shrub line at `ditch-bank-up` sits on one contour with even height.
  - The ditch's foreground stones were removed, not fixed.
  - The thicket mounds at 1349 Gateview have hard outlines.
  - Broadleaf impostors step about +21% at the 110 m switch. A separate round is queued.
  - `california_sagebrush` and `california_buckwheat` stand in as forms at the ditch, the Mersea strip and the 1349 Gateview thicket. Their species are unconfirmed, so don't describe them as natives.
  - 36 trunks stand on yard pavement with no mulch pit, all on real crowns where checked.
  - The Keppler Court pine at (−292.8, −433.7) changed from variant 1 to 2 within its pin when the Johnson St lot landed: the lot dropped three crowns, and species hang on a crown's list index (see the cleanup item below).
  - Young island oak (rebuilt 2026-11-07):
    - oaks look dark at mid distance away from the sun;
    - oak crowns are 6–17% wider than nominal;
    - the collision capsules of leaning stems may catch the player;
    - the gum and oak foliage atlas bleeds slightly between cells in its mips.
- **Performance:** the building merge in the bake and the Mersea probe fix landed on 2026-11-06. Against `c7db08fc` at 1600 × 900 on the AMD Radeon 780M: Forward+ spawn 37 → 14 ms, overview 33 → 13, street 13 → 6, jetpack 11 → 6, Mersea 21 → 5.5; real Chrome spawn 25 → 15 ms, overview 24 → 13, street 15 → 10, jetpack 10.6 → 7, ferry 5.0 → 5.4. On the web, merged buildings no longer take distance culling, so housing stays visible at overview: 3,373 draws and 1.72 million triangles there, up from 2,769 and 0.78 million. Applying the old culling to them would save about 5 ms at that view and lose those areas again. Shadow distance is unchanged, and the ground-cover shader runs six noise calls per fragment.

## Building merge in the bake: known gaps

Exports and the web build load a baked world whose buildings are merged by `tools/merge_baked_buildings.gd`: the same triangles through far fewer draws, while the world generated at startup keeps its authored nodes. Compared at 72 fixed views on 2026-11-06 (shader time frozen):

- About 3.7% of pixels on desktop differ by one 8-bit level, because a vertex colour stores 8 bits per channel where a material's colour is a float. Only about 0.025% differ by more.
- Near-coplanar parts can tie differently on depth: a 1-pixel lip at the south porch of Chinook w95934105, and 8 pixels on a distant sign beyond Fire Station 48.
- Long straight edges and wire chairs flip a few edge samples, from float rounding of at most 0.05 mm in the merged positions.
- A shadow edge on the south side of Job Corps 368 (w34313521) lost a small notch; the cause is not established.
- **Web only:** Mersea's glass changed, from the exterior probe going ONCE rather than from the merge: in Compatibility the panes now show soft reflections where they read as flat and dark. On desktop the same change is at most 2 levels on the glass.

Not needed to ship, and not done:

- Housing support and retained ground meshes are left whole, because `StudyGeometry.retained_ground_contact` compares them with their collider face by face, in order: 2,668 of the 5,529 surfaces left. Combining only neighbouring surfaces inside a support mesh would keep that order and take its 2,211 surfaces to about 950.
- Merged surfaces keep tangents that nothing reads on about 86% of vertices (about 15 MB raw, estimated from the census), and 1.87 million vertices are still unindexed triangle soup.
- 1,852 hidden meshes stay in the bake.

Follow-ups from the code reviews (non-blocking at `e51de21d` and `d445887a`):

- `headless_bake_merge_contract.gd` has no fixtures for some kept cases: unsupported channels, per-instance settings, and parts with children or a script.

## Deferred by the owner

- Audio: the game has no sound. Sound effects are the next big thing (owner, 2026-11-08): the owner sources the samples, and integrating them starts when the owner hands them over.
- Fences island-wide from the map data: not picked for this release. Today only fences in the street-detail zones are built; the rest stay data. The street reviews saw three that are missing: a container wall at 11th Street, a container wall at 4th Street / Avenue M, and wooden fences at 13th Street / Gateview Avenue, which hide a shelter in the photo.
- Mac notarization: later. It needs a paid Apple Developer membership.
- The pelican rider variant of the player: paused.

## Code and tooling cleanup (low priority)

- **Web release smoke:** the run check gates on distance, not speed, since 2026-11-06 (the scripts are outside Git, last in `perf-2-bake-20261106/release/scripts`).
  - Why it changed: two timed speed samples failed, both because of the browser stall above. The old `speedTest` took speed from two reads 550 ms apart. Its first read landed right after the stall, either side of the physics catch-up burst by chance, so `d44205d8` read 23.7 to 24.4 m/s in three failed smokes against a limit of 17 to 21, and an older build once read 23.5, while per-frame traces showed a true steady speed of 19.5 to 20.0. Its replacement sampled between the two stalls, then failed its proof at 12.57 m/s on `c7db08fc` when the second stall reached its window.
  - The gate: total distance over `speedTest`'s unchanged hold must be 20.2 to 27.1 m. Stock settings give 20.90 m at a true 17 m/s and 25.46 m at 21; those are widened by the recorded spread at a true 20 m/s, 23.62 to 25.95 m over 13 smoke passes.
  - What it means: at the nominal hold these limits admit a true speed of about 16.4 to 22.5 m/s, and 15.3 to 23.2 across the holds recorded. That is looser than 17 to 21 at both ends, by about 2 m/s at the top, so it catches a broken run rather than a slightly wrong one. Walk speed moves under 7 m. `headless_gameplay_contract.gd` and `run_speed_mps` still guard the exact value.
  - Limit of the method: distance isn't fully independent of the stall. A stall that delays no timer costs about 3 m: traced runs at a true 20 m/s moved 20.4 to 21.7 m, just inside the lower limit.
  - The 550 ms speed and a steady reading stay in the log as recorded readings, not gates.
- **World generator and validator:**
  - The terrain-override slope guard (`tools/lib/terrain-overrides.mjs`) checks the triangles of the 0.5 m sample grid, not the simplified triangles it writes out.
  - An `osm_way` fence rule with `offset_m` places its gates by distance along the unshifted OSM line, so they drift at bends (`tools/lib/street-fence-generation.mjs`).
  - The draped-area layer check in `tools/validate_godot_world.mjs` sums each pair's overlap over the chunk-clipped triangles, so slivers along a shared edge could add up to a false failure.
  - The yard-kit floor check tests floor vertices on the sides of the plan rectangle, not the mesh's actual open edges.
  - Yard props rest on a 3 m sample grid, which can miss ditches narrower than 3 m.
  - A lot's car rows are named by aisle, side and distance along the row (`cell` in `tools/lib/street-clutter-generation.mjs`), not by the row, so rows of one lot on the same side with the same pitch share ids, and cars in both fail the build's unique row ids check. The 4th Street lot's stall widths and sides are arranged to avoid the clash. Adding the row to the id would reshuffle the Mersea lot's cars.
  - In `tools/lib/ground-cover-map.mjs:493`, `drawn[cell] = 1` also runs for `no_fill` rules, so a `no_fill` rule that is the only rule on a verge would cut that verge off from the ground behind it. It doesn't happen today.
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
  - The shoreline config's closures note (`tools/config/shoreline.json`) still describes the slipway's side walls as `ramp_wall_m` high; it is 0, and the slope's rock cut stands beside the slab. The config's sha256 is recorded in `generated/world/shoreline.json`, so change the note together with a world regeneration.
  - The ramp foot's seed (code review's low, at `07a0f9e5`).
  - The ditch's axis lives in two places: `marsh_axis` in `game/resources/materials/world/ground_cover/ground_cover.gdshader:85` and the `mersea_ditch` rules in `tools/config/street-detail-zones.json`.
  - Canopy placement ignores walk-up lanes: the generated audit's `walk_up_short` grew from 32 to 37 sides. S4's island test still passes all 174.
  - A canopy tree's species hangs on its crown's list index (`identity` in `tools/lib/street-detail-generation.mjs:1775`, at `03f645ae`), so dropping a crown reshuffles the species of the crowns after it. Hash on the crown's position instead.
- **Tests:**
  - The startup test (`game/tests/headless_startup_configuration_contract.gd`) checks that a demolished building has a demolition record, but doesn't compare it with the evidence in `tools/config/demolished-buildings.json`.
  - `building_shots.gd`'s `_moving_view` turns off the player controller right after the last move, without waiting for the player to come to rest.
  - `building_shots.gd`'s `MOVE_ACTIONS` duplicates the action list in `world_harness.gd`'s `release_input`; share one list.
  - Loading the baked scene or the web pack outside the normal game path reports a pre-existing script/scene load error for `hawkins_77_bruton_facade` (seen independently by two reviewers of the web-memory PRs, 2026-11-10/11; the PR #15 review found it the same on #14 and absent in the browser). The cause hasn't been looked at (code review).
- **r133351, the former school ring with Aracely Cafe** (seen in review, 2026-11-07):
  - the SSE planting is its weakest area: near-even dark balls, and red spikes that ref 22 does not show;
  - the 13th Street hedge is slightly flat, with a mild row rhythm;
  - the lawn pad by the west wing leaves a tan notch at its edge;
  - a hairline sliver remains at the end of the SSE walk;
  - the sidewalk and ramp pads are set to the generated kerb's heights by hand, so recheck them whenever that kerb moves;
  - the lawn pads are a patch over the lawn recipe's dry spots until the ground cover has a per-area lawn channel.
- **Mid-rise palette textures** (`game/scripts/world/facades/midrise_family.gd`, `_make_materials`): an entry's texture filter depends on its tiling field. A `tile_m` entry keeps the default filter and a `uv_scale` entry is filtered anisotropically, and an entry that gives both silently ignores `uv_scale`.
- **Garden Walk's `north_mouth` paving** (`tools/config/street-detail-zones.json`): with `reach_m` 2.7 it reaches about 2.5 m inside the `mersea_ditch` outline, where field rules skip the surface check. Nothing is planted there today, but a future ditch rule could plant on the paving.
- **Player:**
  - Holding C over the water or riprap repeats the shore lift about every 0.6 s, with a "Recovered" message each time (`game/scripts/player/player_controller.gd:134`, `game/scripts/player/recovery_controller.gd:7`, `:69`). Jittery only.
  - The chest avatar's `WALK_SPEED` (4.0) is a copy of `player_controller.walk_speed_mps`; couple them.
  - The shore lift could use `to.y = maxf(from.y, floor + lift)`, and its "Recovered" toast wording could say what happened.
- **Mersea mural mesh** (`game/scripts/world/facades/mersea_model.gd`):
  - the view pull in its shader assumes a perspective camera, with no orthographic branch;
  - the 0.23 m clip should share a constant with the bottom rail;
  - the `ROUGHNESS` comment says the sheet keeps its own finish, but the shader sets a constant.

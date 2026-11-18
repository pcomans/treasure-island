# Known issues and to-dos

This file lists the known issues and planned work for the game. It is kept current as work lands: when a fix reaches `main`, its item is removed.

Coordinates are world x, z in metres (z points south), as in `generated/world/`. Items marked "seen in review" are what a reviewer saw in screenshots, not measurements.

## Known issues on main (not scheduled)

- A thin strip of water shows between the grass and the root of Pier 1 from the land side (seen in review, by 2026-11-05; still there on 2026-11-06).
- Avenue H and Avenue M have humps in the road from the generator: 32 m land-grid corners standing on stockpiles that are gone (on Avenue H by the truck lot, two humps of about 2.2 and 2.4 m over the USGS raster; diagnosis on branch `diag/bumpy-road-20261108`, 2026-11-08). The owner chose to leave them, because a future island-wide change to road generation may replace this.
- Avenue of the Palms dips beside Cityside Park's north end, between 40 and 80 m along w1001544697, up to 1.6 m below the USGS raster (at 65 m the road is at 2.45 m, the raster 3.95 m): a 32 m land-grid corner, (-256, 288), stands in a 2023 pit (raster 0.44 m), and Cityside's terrain corridor keeps the road on that generated ground.
- The Clipper Cove marina basin past the playable boundary (OSM w644986117, x −9 to 162, z 804 to 1021) is open bay water: its floating docks and moored boats are not modelled (the flat teal sheet that stood in for them was folded into the bay water, 2026-11-07).
- **Web build** (Godot's Compatibility renderer):
  - it looks about 15% brighter than desktop (seen in review, by 2026-11-05); parked by the owner;
  - it draws no decals, which the owner accepted, so the Mersea mural is drawn as a mesh instead;
  - glass looks paler and more reflective than on desktop (seen in review, by 2026-11-05);
  - on iPhone it runs, but its memory headroom isn't known. Release `c7db08fc` (2026-11-06) was killed by iOS at its 2,048 MB per-process limit. PR #19 (`df3edb02`, 2026-11-09) combined the owner's PRs #14, #15, #17 and #18: VRAM-compressed world textures, no bake inputs in the web pack, superseded housing geometry pruned from the bake and 94 web textures capped at 512 px. Its description says the same tree reached play in Safari on a physical iPhone (iOS 27.0.1) in about 12 s, the owner confirmed touch walking and driving, and the page was still up at four minutes. No RAM trace was taken. Build 2047 crashed on the owner's iPhone after a while of play (2026-11-16); the owner played build 2177 (2026-11-17) with no crash so far; its memory on the device is unmeasured;
  - on an iPhone, iOS ends the page when its process passes 2,048 MB, confirmed from the phone's own log (2026-11-17). In the drive trace's runs on the owner's phone it came at the corner of the Avenue of the Palms and Johnson Street by Mersea at the default and at full resolution, and later at 50 %. The frame rate on the phone is low, about 13 to 37 fps, and follows how much is drawn;
  - three memory changes (2026-11-18), each measured alone against build 2272 on this machine in WebKit sized like the owner's iPhone: freeing the game data once play is ready (about 135 MiB less in the page's process), the building merge (GL buffers 43,761 → 38,003) and street detail in large batches (GL buffers 43,422 → 34,480); together they are not measured here. On the owner's iPhone (the owner's analysis agent with the trace builds, 2026-11-17/18): iOS ends the page's process at its 2,048 MB limit; on build 2272 the scripted drive was ended at 68 to 89 s at the default resolution; with street detail regrouped (that branch alone, with sound) the full route completed in 370.8 s at a median frame of 57 ms with 34,497 live GL buffers against 43,400, and the page was then ended right after the trace's resolution change to 100 %, which adds about 35 MB. The same agent's Mac measurement puts a small GL buffer at about 7 KB and expects about 135 MB from the pack release, about 40 MB from the building merge and up to about 25 MB from sharing equal materials, which follows in a later batch. The three changes together have not yet been measured on the phone;
  - the Options screen offers a 100 % resolution on the web too (owner, 2026-11-14: the same options as on desktop; the default is 67 %). On an iPhone, 100 % draws the world at the screen's full device pixels, and nobody has measured its memory against iOS's 2,048 MB limit per tab: a player who picks it may see the tab reload.
- **Resolution below 100 % (Options, 2026-11-14):** the wire shaders keep a minimum width in drawn pixels (`bay_bridge_wire.gdshader` and `street_wire.gdshader` size it from `VIEWPORT_SIZE`, which is the reduced 3D size), so at 50 % wires and lamp poles read about twice as thick; the facade and ground shaders that smooth their patterns by `fwidth` also work in those coarser pixels. At 50 % on desktop, FSR's sharpening also makes palm fronds crunchy with halos and small sign text unreadable (visual review, 2026-11-14). 100 %, the default, is unchanged.
- **Browser stall while running:** in Chrome the frames stall for about 330 ms twice during a short run from spawn (about 0.6 s and 1.7 s after the keys go down), on both `c7db08fc` and the merged build, so the merge didn't cause it. Physics then catches up in a burst. It isn't there at idle (197 frames in 5 s at spawn). The cause is unknown, and it isn't confirmed for a real player: it was seen with synthetic key events in headed Chrome on Weston.
- **Web stalls driving down Bruton Street, unattributed** (2026-11-13): in Chrome (Compatibility renderer, the dev machine's Radeon 780M, 1440 x 900), a car driven south-east down Bruton Street from its curb car `w1212176122_right_007` stalls three frames, of about 84, 334 and 101 ms, at the same places each time (about 40 m and 20 m short of the lamp `w1212176122_right_011`), on 86782d21 as on `feature/knock-over-lamps-20261113`, whether it knocks the lamps over or drives in the travel lane and hits nothing (`knock-over-lamps-20261113/runs/R24-web-lamps-B2`, `R27-web-lamps-B3`, `R28-web-lane-B`, `R29-web-lane-base`), and again on 4f05b7c9 with the reworked fall (`W05-web-lamps`: 334 and 101 ms); every other frame there is 25.4 ms. Most likely something seen there for the first time compiles or uploads; not traced.
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

## Wood-chip mulch (`game/scripts/world/mulch_ground.gd`, `mulch.gdshader`, 2026-11-17)

Every wood-mulch surface draws one shared chip tile (`tools/bake_mulch_chips.mjs`), graded per kind from its dated photos: the park outside Isle House's beds and basin, the park beds of Cityside, Garden Walk, Maceo May and the 9th Street lot strip, the Mersea promenade's bark, and the street planting strips, whose material the street trees' pits share. On desktop the ground dressing adds loose chips near the camera. What isn't there yet or is inferred:

- The loose chips are desktop only. The web build draws the mulch without them (the ground dressing runs only on Forward+), and the tree pits get none on desktop either: their meshes are street detail, which the dressing's captures don't copy.
- The loose chips are flat-shaded slivers, with no texture or relief of their own, so at 2 to 3 m they read as cut-outs.
- Loose chips stop within about 5 cm (half a texel of the chips capture, 1024 px over 96 m) of a kerb, path or the land drawn over a bed's edge. Where other ground lies within a millimetre under a bed (about 0.1 % of the beds' sample points in the 2026-11-16 world), the chips there go too.
- On desktop the chips capture costs about 0.3 ms on the GPU each time it renders, once every 22 m the camera travels with a bed within 48 m.
- On desktop the chips capture's target is 1024 px square in half floats, about 9 MB more graphics memory than the 512 px it had before chips were made to stop at ground over a bed, and it is allocated even when chips are off (at a level without chips, or with no bed near): then only its rendering is skipped (code review, 2026-11-17).
- Grass blades and stones within about a third of a metre (a colour-capture texel) of a bed take on some of the bed's brown: the colour capture draws the bed's mulch colour, and the grass and stones take theirs from it. Code review, 2026-11-17; close view `e1-bed-edge-lawn-2m` in `procedural-mulch-20261116/runs/R08c-round2`.
- One building's own site mulch keeps its old texture: the midrise family's `r133351.json` (`site_mulch`) draws `street_mulch.png` as part of that building's model, outside the world surfaces this mulch covers.
- One grade (`park_mulch`) covers Cityside's beds, Garden Walk's, Maceo May's and the 9th Street lot strip, set between Cityside's two Sep 2025 contributor photos (ph08 darker, ph04 paler in full sun). The 9th Street Street View (Sep 2025) shows a flatter, browner worn mulch, and no close photo shows Garden Walk's or Maceo May's bare mulch.
- The street strips' grade sits between ih02's Street View ratio to the sidewalk (0.53) and Cityside's ph08 (0.39 of the concrete beside it); Street View lifts shadows, so the ratio is uncertain. The tree pits draw the strips' material: no dated photo shows a pit's surface closely.
- Against the owner's video (f_090, 2026-11-15) the park's chips read warm and slightly mauve where the video's weathered chips are grey, and their speckle at 10 m is softer (luminance p10 to p90 68 to 161 against 61 to 170); the bed's mean matches (124, 114, 104 against 126, 115, 101). The independent visual review (2026-11-17) found the remaining gap in hue and mid-distance contrast.
- The stormwater basin's damp chips have been judged only from 10 m behind a lawn, not up close against the video's f_038 to f_058 (`d2-basin-near-2m` in R08c-round2 shows them at 2 m).
- The promenade's chips have brighter highlights than IMG_0960 shows; the footage's HLG tone mapping compresses highlights, so how much of that is real is unknown.
- The chip tile's height rides in its alpha, block-compressed with its colour (BC3 on desktop, ETC2 on phones), so the relief steps every 4 texels (5 mm) up close; not seen at gameplay distances.
- The web build (the Compatibility renderer, which phones run) draws a cheaper mulch: two trilinear reads a pixel where the desktop takes six anisotropic ones, and one value noise where it takes five, with a planted bed's far colour worked out only past 32 m and without its straw accents. It loses the light the chips' relief catches, so the park's bed is flatter there (8-pixel contrast 18 against the full shader's 33 on the same renderer at f_090's pose) and a little paler (mean 146, 134, 113 against 135, 123, 104), the fresher patches (their mean tint stays) and some grazing sharpness.
- On the web the beds read darker and more saturated beside their neighbours than on desktop: at IMG_0960's pose the promenade bark's median is 0.56 of the road's (65 against 117), against 1.10 on desktop and about 1.0 in the video, and the cheaper mulch leaves that as it was. The road there is 50 % brighter and neutral on the web, so the likely cause is how the Compatibility renderer lights rough surfaces, not the mulch's grade; not tuned, since the web's look isn't judged.
- In Forward+ the street trees' pits cost 2 more draw calls and 656 more triangles at spawn (41 pits of 16 triangles) than with their old material, since they moved to the shared mulch shader; the Compatibility renderer's counts are unchanged. Code review, 2026-11-17.
- No Metal, browser or iPhone run: every cost so far is the Linux Radeon 780M, with the web's cost taken in the native Compatibility renderer, where back-to-back runs drift by 4 to 18 %, so a frame-time change under about 0.5 ms can't be resolved there. On the web the chip tile takes about 0.35 MB of texture memory at the 512 px cap and `park_mulch.png`'s 0.17 MB is freed (`street_mulch.png` stays, for that building), about 0.17 MB more in all.

## Sky and light (`game/resources/materials/world/sky/bay_sky.gdshader`, `game/scenes/main.tscn`, 2026-11-09)

Couplings, for whoever changes one side:

- The sky's `sky_horizon_color` (a shader parameter of the sky material in `main.tscn`, still (0.74, 0.80, 0.86)) is the colour the fog and the distant horizon's haze copy; see the SF card's item under the distant horizon. `sky_top_color` and the two ground colours are also unchanged from the old `ProceduralSkyMaterial`, and the gradient is the same formula.
- The clouds are part of the radiance map, so they are in the ambient light, in the water's and windows' reflections and, a little, in the fog's colour at distance (aerial perspective 0.35). `cloud_cover`, `cloud_sun_gain` and `cloud_sky_gain` therefore move the ambient light as well as the picture.
- Below the horizon the radiance map shows the land's bounce light (`land_bounce_color` times the live sun and sky), not the two ground colours the visible sky keeps there. Ambient is now 60 % from that map (`ambient_light_sky_contribution` 0.6, energy 0.52): shade open to the sky is cooler, shade under an eave warmer. In the small look scene a cream wall's warm cast (red minus blue, 8-bit) went from 23 to 20 in grazing sun and from 21 to 12 in shade, and white stayed neutral. Retune the two together.
- The clouds move by the global shader uniform `sky_cloud_drift` (`project.godot`, set each frame by `game/scripts/world/sky_weather.gd`). The shader must not read `TIME` or `POSITION`: either makes Godot redraw and re-filter the radiance map every frame. `headless_gameplay_contract.gd` checks `TIME`.
- `sky_weather.gd`'s wraps (72 km of drift, 4.5 km of rise) are whole multiples of the shader's noise tiles (`WEATHER_TILE_M` 24 km, `CIRRUS_TILE_M` 36 km at twice the drift, `SHAPE_TILE_M` 9 km and half of it deep, `DETAIL_TILE_M` 2.25 km). Change them together, or the clouds jump when the drift wraps (after about 2.2 hours of play).
- The Compatibility renderer gives a sky shader its colour uniforms and the sun's colour sRGB-encoded and decodes the result itself, so the shader decodes and encodes there (`scene_color`, `sky_output`). Without that the web's clouds came out dark; with it a cloud's tone is within one 8-bit level of Forward+ in the small look scene.
- The shared test harness (`game/tests/shared/world_harness.gd`) holds the clouds still at their start, so screenshots of one view match from run to run. Play lets them drift.
- Since 2026-11-14 the Sun follows the time of day in play (`game/scripts/world/day_sun.gd`, `day_clock.gd`) all the way down and back up, and the light follows the sun's height (`game/scripts/world/day_light.gd`): the sun's colour and strength, the sky's colours and the clouds' afterglow, the ambient light, the fog, the exposure, the glow's cap, the distant horizon's brightness (as it falls the distant art greys and fades into the sky's horizon colour), the vegetation's specular, the stars, the parked cars' lamps and the darkness the night lights follow are curves over the sun's elevation, `main.tscn`'s daylight exactly from 30 degrees up. With no strength (from half a degree under the horizon) the Sun lights the sky alone, so its shadow splits stop rendering. The sun moves in steps of 10 s with it high, shorter near the horizon down to half a second, and 10 s again through the night floor (from 18 degrees under the horizon), its angles kept to 0.01 degree from 30 degrees up and 0.001 below; `main.tscn`'s Sun, the web build and every test and capture keep the recorded moment, 2026-11-13 12:30 PST (`node tools/solar_position.mjs "2026-11-13 12:30"` gives its elevation and azimuth), where the light writes nothing but the global uniforms, at the values project.godot gives them. Play starts at 12:30 island time on the island's date (owner, 2026-11-16: "always start the game during a time with nice lighting"), whatever the real time, and runs at real speed from there; Options' Now jumps to the real date and time, the night among them. At 12:30 the sun stands 28.6 degrees up at the winter solstice, just under the 30-degree full-day look (a tenth of the way to the 15-degree key's warmer light), and 73 degrees up at the summer one (12:30 PDT), where shadows are short. The sky draws its disc and halo on `LIGHT0_DIRECTION`, the light's own direction.

Limits:

- The time of day ships with dusk (its second batch, 2026-11-14) and the night (its third, 2026-11-15; owner: "a dark night with stars, a flashlight that turns on by itself and headlights on the car you drive... No glowing street lamps or lit windows"):
  - From 18 degrees under the horizon until dawn comes back past it the scene holds the night floor (`DayLight.NIGHT_FLOOR`; keys at 8 and 12 degrees lead down to it): a dark navy sky of stars, a little lighter at the horizon, and a faint cool fill, so buildings, trees and the distant hills are dark shapes against the sky and roads, kerbs and crossings are just told apart without a light. The fill was lifted once after review (ambient 0.42 to 0.9 at the floor): without a light the lower third of a frame from the gameplay camera sits at about 1.5 of 255 on Bruton Street's asphalt, 1 on the shore, 3 in a park and 6 on the chapel's lawn (measured 2026-11-15), so asphalt still reads near black. No moon is drawn, the stars are a fixed procedural field (no constellations, and they don't wheel with the hour), most faint and about one in twenty bright, and none twinkle; turning the camera they hold their brightness from frame to frame (2026-11-15).
  - The flashlight and the driven car's headlights (`game/scripts/world/night_lights.gd`) come on by themselves once it is dark (the look's darkness at 0.5, the sun about 5.5 degrees under the horizon) and go off again only under 0.35 (about 4 degrees), fading over 1.2 s; no key and no touch button. The flashlight is carried at the chest and points where the camera looks, its heading and part of its pitch, not where the chest faces, so the lit patch lies ahead of the chest on screen. The chest casts no shadow in it (owner, 2026-11-17): the light sits just in front of the closed lid's front edge, and speeding up into a run, with the chest leaning forward and its lid swinging open, that edge used to come within a few centimetres of the light, in front of it, and black out most of the beam in flickers. Once the flashlight is made, the chest's meshes are on their own render layer alone (layer 20), which the flashlight's shadow caster mask leaves out, so from then on Mersea's reflection probes, which draw layers 1 and 2, leave the chest out of their captures too. Its beam is a wide, soft-edged cone reaching about 20 m ahead on flat ground and out to 48 m, its light falling off gently with distance, with a faint wider spill round the player, and a small fill lights the chest's back and lid (only the chest: its own render layer) so it reads in front of the beam. A pale wall a few metres ahead still goes nearly white at the beam's centre: running up to the chapel's door, 2 to 3 m from its porch, about 29,000 pixels of a 1440 x 900 frame are at or over 250 of 255, and standing 6 m out about 10,600, mostly its white door (2026-11-15). It casts shadows unless the player's shadow option is Off; with shadows Off it lights through walls, as the headlights always do (what they light through a wall within 75 m is mostly hidden from the chase camera by the same wall). The headlights are two round cones without a low beam's flat cut-off. The night lights hang off the time of day's switch: `NightLights.wanted()` is `DayClock.enabled()` and not a test or capture run (`DayClock.scripted()`, which holds the recorded moment), so none are made on the web, with the switch off or in a test or capture (a driver opts in by making them, as it opts in to another moment with `DayClock.pin()`); one made with the switch off does nothing.
  - No capture shows a landing after a jetpack hop with the flashlight on: the hop burst taken for the chest's own shadow fix ends in the air (visual review, 2026-11-17).
  - Parked cars' day-running and tail lamps go out as the sun sets (from 6 degrees down to 1); the driven car keeps its own lit, and loses them again when the player gets out. Yard vehicles have no lit lamps. Street lamps and windows stay dark. The buildings' own glows follow the owner's "Keep real lamps, darken glass" (2026-11-15): Mersea's string lights, Aracely's bulbs, Building 201's lamp and the ferry pier's orange LED stay lit as small lamps, while the Hawkins tower's (77 Bruton) lobby glass, Building 201's bright sign and Aracely's cafe interior, which glow by day so they read, fade out between 3 degrees above the horizon and 3 below (`daylight_fill`). Each glowing building material carries its `night_role` (`lamp` or `daylight_fill`), set by its family builder or its palette entry, and the vehicle contract fails on one without. DaySun finds the fills once the world has loaded, with a walk over the buildings' geometry (about 30 ms once on the dev machine over the generated world's 10,563 nodes, 2026-11-15; not measured on the baked world exports load, whose buildings are merged into fewer nodes), so that world's merged materials are found too; nothing is found or written with the time of day off. By day (frozen shader time, the recorded moment) the five buildings' views were the same before and after but for 0 to 56 scattered pixels a view at up to 3 of 255, the renderer's own run-to-run spread. At night the cafe interior's glass is black, though its picture shows lit pendant lamps inside.
  - B201's lamps glow at night without lighting their surroundings (review note, 2026-11-15).
  - The Aracely Cafe's interior is dark at night (review note, 2026-11-15).
  - The white foam dots on the bay still show at dusk (to about 6 degrees under the horizon) and fade out with the night (none over a third of the way to white from 12 degrees down, against 675 such pixels at the second batch's floor in the raised view).
  - The distant horizon's art (the SF skyline, the East Bay, the Golden Gate) follows one factor down to 2 % at the floor (owner: one simple brightness factor): as it falls the art greys and fades part way into the sky's horizon colour, from 5 degrees to sunset a quarter to a third of the luminance of the horizon behind it (measured 2026-11-15), so the skyline reads as a hazy grey-brown silhouette and the East Bay hills, which face the setting sun, as hazy grey shapes rather than catching its warm light; no city lights.
  - The light warms only a little by 10 degrees (the sun's colour from noon's (1, 0.96, 0.89) to (1, 0.91, 0.78) at 15 degrees and (1, 0.81, 0.6) at 6): on the bay at 10 degrees the sun glitter's fringes turn cream (8-bit 205, 190, 172 where they were 247, 236, 220), but the sun's disc and the glitter's core still clip to white.
  - Once their afterglow fades (by about 4 degrees under the horizon) the clouds are lit by the darkening sky alone: dark grey shapes against the stars at night, with no city glow under them. Between the sun's last 2 degrees and civil dusk the sky turns lavender overhead where its blue top meets the pink horizon.
  - A tall object's long shadow still creeps in small hops as the sun sets: in half-second steps a 9.2 m lamp's shadow end moves 2 to 4 cm at 5 degrees and 14 to 29 cm at 2 degrees, where the shadow is 274 m long (9 to 18 px seen from 12 m beside its end). A sun moved every frame would redraw the radiance map all the time.
  - Ambient light and reflections follow a jump of the clock over 8 frames (the Sky's incremental mode): with the time slider dragged fast, or the clock run 1,800 times too fast, the ambient light catches up in small pulses every 8 frames.
  - Glass glints at a low sun as at noon (owner, 2026-11-15, of the Hawkins tower's glare from the ferry spawn at a 10-degree sun: keep it; windows across the bay glow at sunset): the Sun's specular is `main.tscn`'s at every height, and the glow's luminance cap stays daylight's 12 until the disc has set, coming down to the night's 3 by 3 degrees under the horizon. At 10 degrees on 21 December the tower shows a bright glare with a wide bloom over several columns of panes from the ferry spawn, and on 21 June Bruton Street's corner window a bright glint with a halo; the sun's disc and its path on the water bloom as at noon too (on 14 November at 10 degrees about a quarter more of the glitter clips to white than with the specular and cap cut, 23 and 24 % in two runs, its fringes' colour within 3 of 255). Both glints are a little smaller than in the capture the owner chose them from (about 83 % of its clipped pixels on the tower and 81 % at the window, 2026-11-15): that exploration render's sun at 10 degrees was 6 % stronger and less warm (energy 1.156 and colour (1, 0.886, 0.726), against 1.089 and (1, 0.854, 0.68) now), and with its sun on today's look both glints match it. Beside the disc the bloom lies over backlit crowns as a warm haze, about 6 of 255 brighter at 5 degrees on the west shore's path; the crowns' own sun specular stays where the pale-crown fix put it (`vegetation_sheen`; about 0.1 of 255 away from the disc).
  - Lamps that glow just after sunset (a building's lamps, a driven car's lamps), while the glow's cap is still daylight's 12, are unverified against that higher cap (review note, 2026-11-15).
  - Nothing casts a shadow beyond 800 m from the camera (560 m under 3 degrees), so raised views at a low sun look flat.
  - Mersea's reflection probes are captured again, while time runs, whenever the sun's height has moved 2 degrees (never through the night floor), at most every 5 s: on the dev machine a capture added up to about 10 ms to one or two frames of a view drawing at about 50 ms a frame (within that view's frame-to-frame spread), and at dusk it turns Mersea's windows from noon's blue-grey reflection to the dusk's. A held clock (the web's, and a test's or a capture's that pins its moments) keeps the reflections the world loaded with; a driver that runs the clock (`DayClock.start_at`, or a stand-in system clock) captures them again as play does.
  - Near trees and their far impostors were only compared by eye at a low sun (similar tone at 5 degrees, front-lit); no bake check was run under a low sun.
  - Cost at night on the dev machine's Radeon 780M (Forward+, 1440 x 900, GPU mean in alternating blocks in one process on a quiet machine, 2026-11-15): with no strength the Sun lights the sky alone, 23.2 ms from the ferry spawn at 22:00 against 26.6 with it lighting the island too (its shadow splits); so night frames are cheaper than noon's: on foot on Bruton Street 13.3 ms at night with the flashlight against 17.4 at noon, in a car on the same road 26.0 with headlights against 29.6. The flashlight with its spill and the chest's fill adds 0.6 ms on Bruton Street and 0.85 in a park, its shadow under 0.1 of that; the headlights nothing measurable. The Mac's cost is unmeasured.
  - Under 10 degrees the sun's shadows reach less of the shadow option's distance (`shadow_reach`: 0.75 at 6 degrees, 0.7 from 3 down; on Medium 560 m instead of 800), each nearer split keeping its own distance, so only the farthest shadows go: at a low sun the long shadows across the whole distance cost the most. On foot on Bruton Street at 5, 3 and 1 degrees that took the frame from 1.5 to 1.9 ms over noon's to within 0.2 of it, and from the ferry arrival view to within 0.5 (GPU mean, 2026-11-15). Shadows from 560 to 800 m out are gone at dusk.
  - The dusk and night looks were judged on the dev machine's Forward+ (Radeon 780M) only; the Mac's Metal hasn't shown them yet. The web keeps the recorded moment.
- The radiance map redraws every 10 s (`reflection_refresh_s`) and when the sun or its light changes, spread over a few frames (the Sky's incremental mode), so reflections and ambient light trail the visible clouds by up to 10 s (at 9 m/s, about 90 m of cloud, a few degrees overhead). Mersea's reflection probes keep the clouds of their last capture.
- Near the horizon the sun steps every half second, so the radiance map redraws about twice a second for about an hour round sunset and sunrise: up to about +0.9 ms mean GPU time on the dev machine's Radeon 780M (one of two timing pairs, 2026-11-14; the other showed none); the Mac's cost is unmeasured. On down through dusk to 18 degrees under the horizon it steps every 0.5 to 3.8 s (the light still changing), and through the night floor every 10 s, as the clouds' refresh does.
- The clouds are drawn for a camera on the ground: they don't come nearer as the jetpack climbs, and from above their base (1.1 km) they would still be overhead.
- Cost on the Mac's Metal, Forward+, 1440 x 900, old and new look timed in alternating blocks in one island run (2026-11-09; median frame): west shore toward the city 7.92 to 9.09 ms, 9th Street 12.71 to 13.05 ms, Bayside Drive housing 8.50 to 9.74 ms, ferry spawn 142.9 to 142.8 ms. Of that, glow is 0.35 to 0.45 ms, the sky 0.2 to 0.5 ms and the shadow splits 0 to 0.3 ms (they also change the draw calls: 4,230 to 5,619 at the housing view, 9,223 to 8,533 at 9th Street). The owner accepted up to about 2 ms. If it has to come down: `glow_enabled = false`, the Sun's old splits (0.1, 0.2, 0.5, no blend, blur 0.25), or fewer `MARCH_STEPS`. Marching the clouds in the quarter-resolution pass was cheaper but showed blocky cloud edges.
- With the clouds drifting and the radiance map redrawn every quarter second instead of every 10 s, the median frame rose by 0.05 to 0.15 ms and the 95th percentile by up to 0.8 ms, so a redraw every 10 s is a few slower frames, not a steady cost.
- The web build marches the same 40 steps as native, at the view's own resolution, because the Compatibility renderer has no half-resolution sky pass. Its cost in a real browser hasn't been measured.
- Glow is on in both renderers (additive, intensity 0.35, threshold 1.0). Its cost in a real browser hasn't been measured either; the fallback is `glow_enabled = false` for the web in `main.gd`.
- The cumulus are smooth at their edges from close up (the march runs at half resolution), the cirrus is a stretched noise that can read as brush strokes high in the sky, and one weather tile repeats every 24 km.
- The sun's first shadow split now ends at 16 m, then 40 m and 120 m (the owner's default of 2026-11-12; 40, 120 and 320 m from the 2026-11-09 sky pass until then, and 80 m first before that), with the splits blended and `shadow_blur` 0.5. What that trades is under the shadow quality option below.
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

## Breakwater birds (`game/scripts/world/breakwater_birds.gd`, 2026-11-15/16)

- Only on the ferry terminal's breakwater (OSM w1011830371), the wall the dated 2021 photos show with birds along its cap. The island's own riprap edge, which OSM also tags `man_made=breakwater`, and the north tip's rock jetty (w26767328) have none.
- Static scenery: no idle motion, no flight, no sound and no collision. The breakwater lies 79 to 93 m off the float, the pier and the island's edge, beyond the 10 m a lifted player may float from the shore (`recovery_controller.gd`), and a car sinks at the shore, so nothing reaches them or walks through them. If a player ever could, birds that take off as one comes near would be the smallest follow-up.
- One adult plumage per species: a western gull, a double-crested cormorant and a brown pelican with a dark hindneck. No juveniles, California gulls or Brandt's cormorants. Every bird has a standing and a sitting version (owner, 2026-11-15): the pelican lies as one photographed on Pismo Beach pier does, head on its shoulders and bill down its breast; the cormorant's is the low lying rest a few take among standing birds on a dated rock photo, so the rule gives it fewer resting cormorants than resting pelicans and gulls get.
- Seen face-on, the folded cormorant has a faint look of a goose, and the sitting gull's form is simple from the front (review notes, 2026-11-16).
- About a hundred birds (owner, 2026-11-15: "we can probably use twice as many birds"): the rule asks for 24 pelicans, 50 cormorants and 28 gulls, and the odd bird that finds no room in its cluster is left out. A few cormorants dry their wings (4 of 50 with the seed; the dated breakwater photo shows one or two in fifteen).
- No droppings on the cap, though real roosts are whitewashed: that would be a decal or a change to the breakwater's own material.
- Most face into the street trees' default wind direction (`vegetation_wind.gdshaderinc`), not any live wind.
- Their shadows on the water: the wall and the birds both cast, and the water takes a shadow only as the share of its light that comes from the sun (`bay_water.gdshader`'s `light()`). Near noon the sun is about 30 degrees off the wall's line, so the 3 m wall throws a band about 2.3 m wide beside it, while a bird's head and back fall 2.8 to 3.2 m out, just past that band, on sunlit water. Far down the wall the water's sky reflection outweighs the sun, so there the wall's band reads faint while the nearer bird shadows read dark. Nothing on the birds or the wall changes that; it would be a change to the water.
- Past 30 to 40 m from the camera their legs and feet draw in to a point inside the body, so no sub-pixel legs sparkle; every gameplay view is farther than that. Shadows keep the legs.
- The web's Compatibility renderer keeps a MultiMesh's custom data and colours as half floats and multiplies every vertex colour by the instance colour: the birds keep only each one's tone and size in the custom data, and every bird has a white instance colour (without one they rendered black).
- With MSAA both renderers take a pixel's vertex colour at its centre even when only one sample lies in a far bird's sub-pixel triangle, so where a triangle runs from one colour to another the colour is extrapolated past both. Unclamped, that lit two pixels of a far bird many times brighter than the cap at noon, dusk and night (2026-11-16); the shader now clamps the colour, and the dusk and night captures from the plaza shore, the gangway and the cap show no bird pixel brighter than the cap in either renderer.
- Cost on the dev machine's Radeon 780M (1440 x 900, the birds shown and hidden in alternating blocks in one run, 2026-11-16, 100 birds): in Forward+ the spawn 52.41 against 51.82 ms (within its noise), the ferry plaza's shore 7.37 against 7.30 ms, standing on the cap among them 5.04 against 4.87 ms; in the web's Compatibility renderer 38.87 against 38.73, 4.03 against 3.90 and 3.54 against 3.38 ms. 16, 24 and 40 more draw calls (eight MultiMeshes in each pass that sees them). About 107,500 instanced triangles then (about 110,900 after the 2026-11-16 polish), drawn once per pass: from the plaza shore the web renderer draws 611,000 primitives with them and 289,000 without. No level of detail: the time is small, but a weaker web device that struggles there would want a lower-poly bird for far views, which needs the MultiMeshes split along the cap. No texture. Not measured on the Mac or in a browser.

## Drivable cars (`game/scripts/vehicles/`, 2026-11-08)

- There's no animation for getting in or out: the player appears in the seat, and beside the door (owner: none needed). At the wheel the driver is the chest avatar's own parts, a little smaller, with no legs and no steering (`car_driver.gd`), drawn only at the hero level: past 13 to 15 m, and on the web, the near level's opaque glass hides it (2026-11-12). From the default chase camera, behind and above, the roof and the dark rear glass hide the driver in every body (the van has no rear windows): it shows from above as a drive starts and through the side glass on a mouse glance (owner capture set, 2026-11-13). The round-6 visual review did not check the van's or the utility truck's driver (2026-11-13).
- The player stands on a car as drawn within about 2 cm: the collision pieces keep only the corners within 1.5 cm of the drawn outline, and the roof is flat out to its rails at the height 0.7 of the way out, so on a roof's crowned middle the feet stand about 1.7 cm into it and at its rails as much over it. A rounder roof let a knocked car roll over and on like a barrel (2026-11-12). That is a car standing still: parked, or live and frozen where it stopped. A live car that moves (driven, shoved or rolling) collides as its two simple hulls (`drivable_car.gd` `_hulls`, what every live car collided as before 2026-11-13), so moving cars meet each other by those, and a player who lands on a car before it has come to rest and frozen (0.75 s at rest) stands on them until it does, then as drawn again (2026-11-13). Against the drawn body those hulls have the same underside, sides about 2 cm narrower, a roof within about 1 cm, a higher hood and a lower trunk or bed: on a moving car's hood the player stands 2.6 to 6.6 cm above the drawn hood at its middle and 7.5 to 11.4 cm near its front (crossover, SUV, sedan, fastback, hatchback, wagon and van; the utility truck about 4 cm, the pickup within 2.2 cm), and 2.4 to 7.8 cm into a trunk or bed (pickup 2.4, sedan 4.8, utility truck 7.8 cm) (code review probes, 2026-11-13: `code-review-car-crash-perf-20261113/runs/P1` and `P2`). Cars shoved side by side into a lot row come to rest about 4 cm into each other's drawn bodies and stay so once they freeze: the moving hulls are 0.98 of the body's width, and two frozen cars never push each other apart. The visual review measured 0.039 m on the fix in two runs, 0.008 m on acdf5c88 and about 0.002 m on 42507a21, there between its own collision hulls (2026-11-13: `visual-review-car-crash-perf-20261113/runs/R4-fix-motion2`, `R7-fix-lot-junctions`, `R3-acdf-motion2`, `R8-acdf-lot-junctions` and `R9-prev-42507a21-motion`, worked out by that folder's `scripts/dd.py`).
- Each car's dirt (0 just washed to 1 filthy) comes from its row id, mixed so the cars in a row differ: about three in four parked cars are nearly clean (under 0.2) and one in eleven dirty (over 0.5), against a half and a quarter before 2026-11-13 (owner: fewer dirty cars). Road dust rises from the sills to an uneven top, higher on a dirtier car and toward its rear, with a haze up the tail and, on a filthy car, a light film on the hood, roof and trunk: pale on dark paint, darker on light paint. It dusts the paint, trim and rims, never the glass; a car with no dirt is clean, no other street prop takes any, and the yards' vehicles (their own kit) stay as they are. No parked car's dirt is exactly 0, but half of them have less than about 0.011, which shows nothing. On light paint, dirt of about 0.6 hardly shows (visual review, 2026-11-13). From 1 to 2 m, a filthy car's film on its roof looks grainy (visual review, 2026-11-13).
- `tools/check_street_car_meshes.mjs` (in `tools/test.sh` since 2026-11-12) judges see-through cracks against the owner's display: a crack counts when at least a third of a pixel wide at the nearest distance its level is drawn from (hero and near 0.4 m, as a seventh parked car close by draws the near level; far 43 m; a pixel of about 2170 rows over 70 degrees), so a pinhole narrower than that passes. Faces smaller than 0.1 mm2 are not judged. Its normal check (the normal drawn at the near and hero levels within 5 degrees of the modelled surface's) covers each body's side from the nose corner's end to a third of the way round the tail's corner, from the sill to 86% of the wall's height; it leaves out the end faces with their lamps, the shoulder's roll into the lid and 6 cm either side of a pickup's slot. Outside it, the van's near level shows a zigzag in the reflection at its head lamps' outboard ends (about 34 degrees off over a few centimetres), and the sedan's and fastback's hero level a small dimple where the deck's shut line meets the shoulder at the C pillar's foot (2026-11-12). A turned-over sliver no taller than 3 mm is laid flat on its long edge rather than recut, which moves a window's or a lamp's outline there by up to 3 mm.
- The storage yards' towed vehicles (travel and fifth-wheel RVs, the concession trailer, the trailers and the boats on trailers), their buses and their machines (excavators, wheel loaders) stay parked props: they can't be driven or shoved. Their vans, box trucks, food-truck step vans and class A and C RVs can, since 2026-11-11 (owner).
- A yard truck's or RV's collision is a few boxes read off its body (`drivable_car.gd` BODIES): up to a few tenths of a metre more than the body above a hood or a cab roof, and the cab's corners rounder than the boxes. Their handling numbers are arcade defaults: heavier and slower than a car, the same suspension, grip and mild anti-roll, so the tall ones tip over in a hard turn even at moderate speed (as the owner liked of the box trucks on 2026-11-08).
- The shoreline riprap is drawn only; cars (and shoved K-rails) roll down a smooth ground of their own over the stones (2026-11-10; in rows about 5 m apart since 2026-11-11), not the stones themselves: about 0.65 m over the underlay, so a car rides on the tallest stones and over the gaps between them, and a few of the crest's biggest boulders stand a little over it. Its climb starts up to 1.1 m inside the outline and keeps off drawn roads, paths and paint but for rare spots at the very edge (the code review found about 517 sample points, all within 1.15 m of the outline, where it stands more than 0.1 m over the land under them), so a car crawling to the edge rises off the grass in its last half metre. A car rolling in nose first stays on its wheels until it is clear of the rocks, so it goes a little deeper before it sinks.
- At the west_north / north_tip joint by the north tip, near (-373.5, -861.3), the cars' ground steps up by as much as 1.04 m over a few metres just inside the outline (sampled 0.25 m in), so a car driven straight off the edge there may bounce or stall; it can still be driven on, or put back on land with R.
- A car driven at the Yerba Buena causeway's crossing stops at the island's edge against an invisible barrier on open grass (2026-11-11); on foot the edge there is invisible too.
- The bay's water sound, heard only by the water's edge (2026-11-14), also plays at that barrier: for those 52 m the island's outline crosses the causeway, not water, but the sound measures its distance from the outline (`game/scripts/audio/sound.gd` water_level).
- The rocks' rumble under a car's wheels (2026-11-14) also plays on the concrete north slipway: it follows the cars' ground over the riprap, which covers the slipway too (`game/scripts/audio/car_sound.gd` RIPRAP_KIND).
- On the west shore path a car drives level through the inland riprap, its wheels and lower body inside the stones (as on main).
- A car flipped farther than 60 m from the camera shows its open underside: the far detail level has no underbody, which saves triangles on every parked car; near cars are closed (2026-11-08).
- Cars draw three levels (2026-11-09): the hero level for the driven car and the six parked cars nearest the camera within 13 m (put back beyond 15 m), the near level to 60 m, the far level beyond. The hero level has see-through glass over a modelled cabin; the near and far levels have opaque dark glass, so a parked car's windows lose their see-through cabin at the 13 to 15 m hand-over, and a seventh car close by in a full car park stays at the near level. The web build has no hero level at all (its pack leaves `street_car_hero_kit.glb` out): there every car, the driven one too, draws the near level.
- A hero car's shadow comes from its shadow caster (the far body shrunk 2.5 cm toward the middle of its box), so small parts (mirrors, roof rails, spokes) cast no shadow of their own and the cabin gets no sunlight through the glass. In the kit gallery's views the edge of a hero car's shadow is stair-stepped (visual review, 2026-11-13).
- A pickup's and the utility's slot between cab and bed (5 cm wide, 6 cm deep) is drawn at the near and hero levels only; the far level has none (2026-11-12).
- At the near-to-far hand-over (43 to 60 m) the far level has the near level's spoked wheels, window pillars, lit lamp strips and mirrors, and a near car's shut lines and panel gaps fade into its paint between about 19 and 43 m, as they narrow below a pixel or two; the far level still has no plate frames, grille surrounds or cowl band, and its coarser windshield and rear glass cut their lower corners by a few centimetres, so a faint change remains there at the hand-over (2026-11-12); the geometry review also saw the roof rails, lamps and plates change there (fault 6, 2026-11-12).
- At the far level the dark underside shows as a sliver at the front corners below the bumper: the floor's edge follows the smooth outline, which the far level's two-station corner cuts inside; it is under a pixel wide on the owner's display (2026-11-12).
- The van's sliding door and the track behind it are dark lines laid 1.5 mm off the side, not cut grooves: they show in paint but not in the clay look, which leaves out colour (2026-11-12).
- Still open from the geometry review of 1201a12b (2026-11-12), only partly fixed in round 5: crumpled reflections at the foot of the rear pillars on the SUV, wagon, sedan and fastback, and a pinch at the hatchback's rear glass corner (fault 2); the SUV's D pillar at the near level, whose edge still zigzags and folds (fault 3, the owner's second spot). On the sedan's rear quarter beside the tail lamp the hero level's reflection ripples on dark paint (owner capture set, 2026-11-13).
- The hand-over from the hero to the near level at 13 to 15 m pops (fault 5): mirrors turn into boxes and door handles into dark bars, and the exhaust, fuel flap and side marker vanish; the near level's wheels have 16 sides against the hero level's 36, and the web build draws that level everywhere. Smaller ones (fault 7): a nick at the van's roof corner, the van's fuel flap drawn as an open U, slivers in the sedan's lamps, a facet on the pickup's cab at the near level, a notch in the hatchback's bumper and speckles in the pickup's bed. The round-6 visual review saw a fold at the rear top corner of the near-level pickup's cab, past the 13 to 15 m hand-over on the desktop and at any distance to 60 m on the web (2026-11-13).
- Three shape notes are left as they are (owner, 2026-11-13: none for now): the pickup's and utility's tail and step bumper, the utility's box body, and the van's windshield height, whose short windshield under a tall painted cap makes the van's front read boxy up close.
- The web pack's car kit grew from 2.5 to 8.2 MB, and the web build, with no hero level, draws every car within 60 m at the near level, about 13,700 triangles a body at that level against about 3,500 for main's cars; the kit also carries a near-identical `car_<body>_chassis_lod0` beside each `car_<body>_lod0`. Neither the web pack's size nor the iPhone's memory with this larger kit has been measured (code review, 2026-11-13).
- A car that is live but not driven (one a driven car has shoved) draws its hero level within 15 m whatever the six-car limit (`drivable_car.gd` `_build_visual`), so a crowd of shoved cars can draw more than six at once (code review, 2026-11-13). In the Avenue of the Palms kerb pile-up that was about 2,200 more draw calls and 0.6 M more primitives a frame than 42507a21, about 4 ms of drawing on the dev machine's Radeon 780M (2026-11-13).
- A crash into parked street cars (2026-11-13): on acdf5c88 a pile-up dropped the web build to 1 to 2.5 frames a second, as each moving car tested its drawn hull pieces against its neighbours' every tick (`vehicle_manager.gd` `_shove`, `street_fence_breaker.gd`), every car set moving built its driver figure (desktop) and read its hull meshes back from the renderer, and moving cars met as their drawn bodies. Measured since in Chrome (Compatibility renderer, the dev machine's Radeon 780M, 1440 x 900): a sedan driven into the Avenue of the Palms' kerb row and into the side of the ferry forecourt lot's row runs at a median frame of 25.2 and 25.1 ms (95th percentile 27.7 and 27.9 ms), as 42507a21 (25.4 and 25.0 ms, 28.4 and 29.0 ms), and a pile-up of yard vans the same. On the desktop (Forward+, the same machine, where those two views take about 58 ms a frame before any crash) the same pile-ups run at a median of 64.7 and 61.0 ms against 42507a21's 61.2 and 64.6 ms and acdf5c88's 444 and 837 ms; the kerb row's extra few milliseconds are the shoved cars' hero level (next item). `headless_car_pileup.gd` bounds the pile-up's physics tick against the run-up's. Not measured on an iPhone, in Safari or on the Mac.
- A car parked on a deck surface is drawn by its rows only: it never takes the hero level and can't be driven, as it isn't listed as swappable (`street_clutter_builder.gd`, code review, 2026-11-13).
- The cars' glass is drawn after the opaque world without writing depth: two hero cars' panes seen through one another are tinted in the order of their distance from the camera to each car's middle, not pane by pane.
- A gate's two stout posts stay standing when a car scrapes past them through the opening; only the posts and panel stands of runs go down with their bays (2026-11-08).
- Street lamps (2026-11-13): a car, a shoved or rolling car or a K-rail that meets a street lamp coming on at 4 m/s or more (its speed into the face of its box that meets the pole) knocks it over; slower, the lamp stops it as before, however hard the driver presses on. On the stock controls a crossover crept into a cobra lamp or started from up to 1 m short of it stops at it (1.5 to 3.7 m/s); from 1.5 m short on it knocks it over (4.6 m/s and up) (`knock-over-lamps-20261113/runs/R11-lamp-trials-B`). The threshold and the lamps' masses (cobra 180 kg, plaza 150, fork 110, lot 90, disc 70) are production inference; the car keeps its speed times its mass over its mass plus the lamp's (a crossover about 91 % against a cobra lamp, a K-rail about 83 %).
- A knocked-over lamp goes over where it stood (reworked after the visual review of 45a7dc2f, which saw it carried 17 to 22 m down the street on the bumper): its foot is knocked on a little and out to the side of the car's middle line it stood on, it tips about its foot toward that side and somewhat ahead, and the car that felled it passes through it and carries on. On the reviewer's five run-ups (10.4 to 15.5 m/s) its base came to rest 0.9 to 3.3 m from where it stood (before: 8.8 to 21.9 m) and it was frozen 2.1 to 6.4 s after the hit; a K-rail sent into a cobra lamp at 5.7 m/s fells it the same way (base 0.8 m away, frozen after 6.0 s) (`knock-over-lamps-20261113/runs/L15-lamp-types-slices34` against `L01-lamp-types-before`; the vehicle contract's at-speed lamp: base 2.2 m away, frozen after 3.1 s, `L17-contract-final2`). Nothing is left where it stood (no stump or footing), and the one lamp with name blades takes them with it.
- A felled lamp collides as the convex hulls of what is drawn of it in four slices up its height (the furniture kit's `fall_slices`, at most 34 points each), so a lying lamp rests on its drawn pole and head: its lowest drawn point within 2.4 cm of the ground under it on the five types (before: lot 4 cm and disc 2 cm into the ground, cobra 5 cm and plaza 7 cm held above it, the fork 8 cm into a bed). Rounded parts are kept as 16-sided, so a round head or disc rim lying between two of its sides can sit up to about 2 % of its radius into the ground. While six lamps fall together in the pile-up test's dense leg its mean physics tick is about 2 times the free run-up's (about 1 times with the old capsule-and-box debris; the bound is 4) (`L14c-pileup-slices34`).
- A felled lamp has no collision once frozen, so a car or the player passes through it lying there (known behaviour, as briefed: the debris meets the ground only; the owner may ask for a solid fallen lamp later).
- A felled lamp settles within 8 s of falling (or of waking): on the ground it is frozen with no collision; resting on something on the street-prop layer (a parked car, a fence) it is put to sleep instead, so it costs no physics and falls if that moves, then settles again. Laid across a parked car's roof it slept there; when that car was driven off at 3 to 4 m/s it woke at once and rode along on the roof rather than falling (`L15-lamp-types-slices34`, scene onroof); while it lies on a driven car it is woken by the car each time it is put to sleep, so it costs physics until the car is left (a left car comes to rest and freezes). The code reviewer's probe saw one fall to the ground when the car under it drove off (`code-review-knock-over-lamps-20261113-runs/probe1.log`). A lamp felled straight onto a parked car beside it on the stock controls was not caught: the one tried fell clear of the car (`L03-lamp-types-after`, scene propped).
- Whether a lamp falls is judged from the car's box and its straight-line motion over the next physics tick (`vehicle_reach.gd` `pole_contact`), so a car tipped far over, or one spinning hard into a lamp, may stop at it instead of knocking it over.
- A knocked-over lamp lying in view costs about 9 draw calls and 2.9 k primitives more on the desktop (a cobra lamp, shown against hidden in the same frame, `knock-over-lamps-20261113/runs/R19-captures-B2`); the standing lamps stay batched as before.
- Besides the street lamps, every pole-like prop of the street-furniture kit falls the same way (owner, 2026-11-14: "Sign posts, signal masts, utility poles and bollards", then "these all need to be breakable"), each at its own speed into the face of the car's box that meets it (the kit's `FELLABLE`; speeds and masses are production inference): the 181 sign posts (100 stop signs, 68 street-name posts, 8 Muni stop flags, Garden Walk's 4 DO NOT ENTER signs and the owner lot's tow-away sign) at 1.5 m/s, Garden Walk's 17 steel bollards at 2 m/s, Cityside Park's 8 event light poles at 4 m/s as the lamps, and only from 8 m/s the 15 signal masts, 245 utility poles and the pitches' 3 light towers on their trailers; slower, each stops the car as before. Their masses (sign posts 20 to 25 kg, bollards 50, event poles 220, masts 650, utility poles 550, light towers 1,300) leave a 1,750 kg crossover about 99, 97, 89, 73, 76 and 57 % of its speed; in the vehicle contract a car driven in at 16 m/s kept 99 % through a name post, a stop sign, a DO NOT ENTER sign and a Muni flag, 97 % through a bollard, 88 % through an event pole, 71 % through a mast, 74 % through a utility pole and 55 % through a light tower, each asking for one hit sound and no crash sound, and nudged at 1 to 5.5 m/s each stood and stopped it (`breakable-poles-20261114/runs/R18-poles-fix1`).
- A felled prop takes whatever it carries (name blades and their names, a mast's heads, arm sign and lamp, a utility pole's crossarms and lamp); a Muni stop's concrete pad stays where it stood. A felled mast rolls onto its arm (its weight a quarter of the way out along it). Every felled prop's lit parts go dark (the kit's lit surface, drawn shaded and darkened): of the props that fall, only a signal mast's green lens and pedestrian hand are lit; a lamp's lens is drawn unlit grey, standing or down, so nothing on a lamp changes. A light tower is met as its trailer's footprint and tips over about its far edge onto its side; while it tips, the car passes through its rising near side, as through a lamp. Come to rest on the ground, every felled prop, a lamp too, is lifted onto the ground drawn there: roads, paths and areas are drawn up to about 8 cm above the land's collision that the debris lies on, so before (visual review, 2026-11-14) a felled bollard lay about half sunk in Garden Walk's paving. At rest the lowest of its points in each 25 cm square under all of it looks down once, and only the land counts: a kerb, a step or a plinth is drawn where its collision is, so a point over one is left out (before, code review of 70c83450, a prop pressed against a kerb's face could have been lifted to the kerb's top). It is lifted as a whole by the deepest point, so one lying across two grounds drawn at different heights (paving and grass, or a long pole on a slope) lies on the higher and can stand up to that difference, at most about 8 cm, over the other. A felled prop also falls through the invisible ramps in front of the kerbs' faces (there so the stock player walks on and off a kerb; before, one in a gutter lay on such a ramp, up to a kerb's height over the gutter that is drawn), onto the gutter and against the kerb. In the contract one prop of each kind was lifted 0.003 to 0.110 m and the felled lamp, lying on a sidewalk's top, not at all; none lies deeper than 2 cm under the drawn land. A steel bollard let fall lying along a kerb's face over its gutter (case 7d) fell through the ramp, came to rest 4 mm into the face, was lifted 0.008 m and lies 0.000 m under and over the drawn land; with the look-down as it was (any first hit) the ramp 0.19 m over it lifted it 0.212 m, its lowest 0.204 m over the gutter, and before this change it landed on the ramp and rolled off it, 0.77 m from the face (`R24-kerb-drop`, `R26-kerb-old-lookdown`, `R25-kerb-before`; close views `breakable-poles-20261114/captures/C3/*_7_rest_grazing.png`, the gutter `captures/C4/kerb_*.png`).
- The street paint drawn beyond the road ribbon, the parking lanes and the gutter pans along the kerbs, stands about 8 cm over the land and is visual only and not in VisibleGround, so a felled prop lying on it is not lifted onto it: the bollard in case 7d lies on the land 0.008 m up, about 7 cm into the gutter pan drawn there (3.027 m against the land's 2.944 m; `captures/C4/kerb_3_foot_cap.png`); a thin sign post lying in a gutter or parking lane can sink out of sight along its length, leaving only its plate or blades showing. The contract's depth checks read VisibleGround too, so they do not see it. The avatar and the cars read the same index (not checked here).
- A felled utility pole's wire spans hang slack from each standing neighbour's insulators down to its crossarm, following it as it falls (sagging up to 7 % of their length as it goes over, against about 1 % standing) and lying on the ground between the two poles' feet near it, never under it; a span between two felled poles is gone (`captures/C3/wires_1_before.png`, `wires_2_after.png`). The wires have no collision, standing or down.
- Felling them costs little: down a power line knocking five poles over with their wires, the pile-up test's mean physics tick is 1.3 times the free run-up's, and its other legs are unchanged (free run-up 0.196 against 0.201 ms, pile-up 0.540 against 0.537 ms on 28b2e465, `R15-pileup-base3`, `R16-pileup-head3`); in Chrome (Compatibility renderer, the dev machine's Radeon 780M, 1440 x 900) a drive down Bruton Street that knocks a street-name post over runs at a median frame of 25.3 ms, the 2 s round the hit at most 25.5 ms, against 25.4 ms on 56e093e5, where the post stands (`W4-web-sign-head`, `W5-web-sign-base`); a crossover driven from a curb into a utility pole at 14.3 m/s knocks it over with its two wire spans and drives on at 10.8 m/s, and the 2 s round the hit run at a median of 25.3 ms and at most 25.8 ms, against at most 25.5 ms on 56e093e5, where the pole stands and stops the car (70c83450, `W9-web-pole-head`, `W10-web-pole-base`).
- What this changed for the lamps (code review of 95b4aac9): a felled lamp is lifted onto the drawn ground as above; the one lamp with name blades now lies on its blades' drawn shape (they had no slices of their own and collided as their box); its hit and fall sounds are as before. The reach's height test changed only for short props: a pole's foot must stand at or below the middle of the car's box, as a lamp's always had to, and its top must reach the box's bottom (new, so a 1 m bollard under a van's middle counts), so a lamp on a ledge beside a car's roof still stands (95b4aac9 had widened it to any overlap); no test drives a van at a bollard. A felled lamp now falls through the kerbs' invisible ramps too.
- Still solid: the EV charger bay's painted bollards and the bus shelter's flag post (parts of those props), the lot's monument sign, the storage yards' 3 flag poles (clutter-layer rows), the goals, the Canopy of Sky and the bollards modelled into the Building 600 and B201 models.
- Small trees (owner, 2026-11-13: "Could you just bend them out of the way"): a tree whose trunk as its row places it (its first collision capsule's radius times the row's scale) is under 0.127 m (the vegetation kit's `BENDING_TRUNK_RADIUS_M`) bends out of a driven, shoved or rolling car's or K-rail's way and springs back; every thicker tree stops it as before. That is 132 trees, all young plantings: 35 young gums, 86 young island oaks, the 10 smaller young cypresses in Cityside Park's beds and the young Norfolk pine at 1436 Chinook Court (trunks 0.044 to 0.122 m, the thickest the cypress `z3_trees:p00006`); 845 stop a car, the thinnest the pohutukawa `island_canopy:c0091` and `c0160` (0.133 m), then the plaza's young conical cypresses (0.148 m) and the palms (0.20 m and up) (`knock-over-lamps-20261113/runs/C11-captures-trees3`). The line and the lean's numbers are production inference. On foot every tree still stops the player.
- A bending tree turns stiffly about its foot (its own instance in each of its batches, so it adds no draw call), with no flex in its trunk, up to where its crown would meet the ground: about 60 to 68 degrees for the young gums and 32 to 50 for the oaks; the young cypresses and the Norfolk pine, feathered to the ground, lean 25 degrees, the lowest sprays on their far side dipping into the ground while they lean. A trunk under a car shows through the car's lower body from the side while the car is over it (it leans out at the car's side, not under its floor), and a low oak's or cypress's crown passes through the car like a shrub's leaves (`C14-captures-trees4`).
- A bent tree stays down while the car that bent it is over it (stopped with no input too) and, as far over as it went, while its crown would be on the chase camera's arm behind the car, so the view does not end up in a crown springing back; a tree left down behind a car parked just past it springs up once the camera moves off it. The arm passes the bending trees' trunks. Driving slowly along a row of the low ones (oaks, cypresses) the view can still pass through the upper crown of one leaning behind the car.
- Each tree a body meets takes 3 % of its speed: through Cityside Park's windrow of 12 young gums on the stock W the car holds about 12 m/s. Bending trees cost nothing measurable: the pile-up test's windrow leg runs at 0.9 times the free run-up's tick, and in Chrome the windrow drive's frames (median 25.5 ms, 95th percentile 25.9) match a drive beside it that touches no tree, on this branch and on 86782d21 (25.4 and 25.9) (`L14c-pileup-slices34`, `W02-web-trees`, `W03-web-control`, `W04-web-control-base`). Each of those drives has one frame of about 300 ms about 2 s in, at the turn out of the kerb on the Avenue of the Palms, on 86782d21 too.
- Where the land under a road dips, a fast car floats over the crests for a moment: on Seven Seas Avenue it dips about 0.9 m over 20 m.
- A body-colour car roof has the paint's own finish under the clear coat since the rebuild (2026-11-11), no longer the rougher roof of the old flat-roofed cars (2026-11-08). Only one roof was checked for glare, a black sedan's body-colour roof on the Avenue of the Palms (row `w1001544697_left_024`), looking toward the fixed sun: at 5 degrees down (low across it) and 15 degrees down (a standing player's camera height) it doesn't flare, and at 33 degrees down (the sun's mirror angle) the clear coat shows the sun as a small bright spot (2026-11-13). Other paint colours and the gloss black roofs were not checked.
- The chase camera's arm stops at street props as well as the world (so it never sits inside a parked car): a lamp post or palm between the car and the camera pulls the view in for a moment, and a sideways glance over kerbside cars passes just over their roofs (2026-11-08). It passes the trunks of the small trees that bend, as the car does (2026-11-13).
- A car pushes the pitch's ball with a scripted bumper push (the ball's own push model, `vehicle_manager.gd` `_push_loose`), not by contact alone: the hull's raked nose sits about a ball's height up, and without the push the car rode over the ball (2026-11-08).
- Taillights read a dull brownish red in shade (visual review, 2026-11-08).
- From raised views the dirt ramps still read as crisp blocks: hard straight shoulders, tyre-worn bands like planks and a skirt with a straight run to its ragged edge (visual review, 2026-11-08).
- The Job Corps perimeter (`job_corps_perimeter` zone, 2026-11-18) is `"breakable": false`, so a car stops at it (owner, 2026-11-08), as at the pitches' ball-stop nets; every other fence breaks bay by bay under a car. Its hangar-pad side is not built yet (see [its section](#job-corps-perimeter-fence-job_corps_perimeter-zone-2026-11-18)).
- The car ramps in three empty lots (the 12th Street and Avenue D dirt lot, the north slab site and the former school lot by Aracely Cafe) are an invented gameplay feature the owner asked for, not something on the island.
- The cars' index of the drawn ground and ways is built twice at load, about 76 ms: once in `world_loader.gd` for the shoreline (`VisibleGround.new()` before `ShorelineBuilder`) and again in `vehicle_manager.gd` (`_visible_ground.build`) (code review, 2026-11-11).
- Not covered by any test: pausing while a car rolls down the riprap, `R` while a car is sinking, and a native run of the web smoke's water leg (code review, 2026-11-11).

## Yard vehicle meshes (`tools/lib/street-yard-meshes.mjs`, `game/resources/models/street/street_yard_kit.glb`, 2026-11-17)

- The kit still draws surfaces of different parts in one plane in two places, which can flicker as the large box truck's cab windows did: the semi trailer's ends (about 0.3 m² at each end) and the step van's rear (about 0.06 m²). Nothing yet checks the kit for surfaces of different parts in one plane; the code review's offline pass (same-facing triangles of different parts within 2 mm of one plane) flags 30 meshes in all, these two among them and mostly downward faces at ground level, so such a check needs its hits sorted first (code review, 2026-11-17).
- A swept side (`sweptBody`) is cut by polygon clipping only when one of its window or door holes reaches past the side's outline; every other side keeps earcut. The clipping path assumes a simple side outline, one that doesn't cross itself. The travel trailer's and the fifth wheel's side outlines cross themselves at the wheel wells, where clipping drops a strip of paint that earcut draws, which is why they stay on the earcut path (their holes lie inside their outlines); a hole reaching past one of those outlines would send that side through clipping and lose the strip (code review, 2026-11-17).

## Sound (`game/scripts/audio/`, 2026-11-14)

- The audio is not in Git (see [README](README.md#sound)): a checkout or build without `TI_SFX_SOURCE` is silent, and so is a Mac build from GitHub Actions while the repository variable `TI_SFX_SOURCE` is unset.
- On the web the sounds cost page memory, as the browser holds every take decoded from startup: with the round-2 set the browser's renderer process took about 92 MiB more before the first click and 122 MiB more after it than the silent release (means of two pairs, integration run `R2-W05-web-memory`). The shipped set has 81 takes, 176 s at 44.1 kHz (79 mono, 2 stereo; durations read from the private set's file headers at ca17d45), and the web engine registers every take as two channels of 32-bit samples (integration review, 2026-11-14): about 62 MB decoded (59.2 MiB measured in Chrome, audio-no-copy-20261116). Registered with its own channel count, the set would hold 39 MiB, and at 22.05 kHz as well 20 MiB; Godot 4.7.2's registration (`godot_audio_sample_register_stream`) always makes two channels at the audio context's rate, so that needs another engine-script change. The owner accepted the cost ("Ship as is", 2026-11-14).
- On the web every play of a take shares the take's decoded AudioBuffer. Godot 4.7.2's sample playback copies the whole take into a new AudioBuffer for every play and every restart of a loop (`Sample.getAudioBuffer` returns `_duplicateAudioBuffer()`, by way of a JavaScript array as large): 426 and 439 copies (384 and 388 MiB) in two runs of iphone-memory-20261116's 6-minute memory route in Chrome. `tools/build-web.sh` patches the exported engine script to return the registered buffer, as Godot 4.8 does (godotengine/godot#124857); the build stops if the script no longer matches, and `tools/check-web-live.sh` checks the deployed engine script. With the patch the route makes no AudioBuffer after loading, the page's JS heap grows about 20 instead of 54 MiB a minute and peaks at 224 to 228 instead of 284 to 288 MiB, and the renderer's peak while driving fell from 1599 to 1604 MB to 1534 to 1566 MB, while its peak over the whole route (1625 to 1643 against 1643 to 1659 MB) moved within run-to-run noise (audio-no-copy-20261116, two runs each, Chrome only). The sound was checked by signal against main (levels, loops, pitch, overlapping plays of one take, stops and the pause), not by ear on a Mac or an iPhone. With Godot 4.8, drop the patch and its check.
- On the web a looping take restarts when its source's `ended` event reaches the page (Godot 4.7.2's sample playback), so each loop point has a short silence: in Chrome a median of 10 ms, up to about 30 ms while the page is busy, for the jet, rattle and engine loops, and under 1 ms for the wind bed when the page is idle (audio-no-copy-20261116, by signal). Nobody has listened for it. Upstream's current sample playback has the browser loop the source (`source.loop`) instead.
- On the live site after the 2026-11-14 release, the JS heap read 32.8, 33.2 and 33.4 MB after forced collections over 5.5 minutes with the engine loops running: 0.6 MB of garbage, not a leak. The car mostly sat against an obstacle, so this is not a reading under hard driving (integrator-batch-20261114a, stage 2).
- The Mac app now opens CoreAudio. On 2026-08-31 a Mac launch hung in CoreAudio while the host's audio daemon was stopped, which is why `project.godot` forced the Dummy driver until now. No check can see that hang again: the Mac CI launch runs `--headless` and every local run gets the Dummy driver from `tools/godot`, so a normal Finder launch on the owner's Mac is the only check.
- On an iPhone or iPad, only the owner's device can confirm the web's sound. Safari there starts a page's audio only from a tap (never the end of a slide, a look drag or a held button), which the start prompt's "Tap to play" now is; the shell also starts it from any later tap anywhere (2026-11-15). That was checked in headed Chromium with Safari's iOS rules emulated, not in Safari. The levels have not been confirmed by ear on the Mac.
- iOS: with the ring/silent switch on silent, Safari mutes web audio (its default audio session). The start prompt says so on an iPhone or iPad, "Turn off silent mode to hear sound" (owner, 2026-11-16); `navigator.audioSession.type = 'playback'` would override the switch on iOS 17 and later instead.
- iOS: Safari suspends or interrupts the audio when the page goes to the background or the device locks; it comes back on the next tap.
- Only the driven car has engine, tyre and landing sounds; a parked or shoved car sounds only when it hits something.
- The driven car's tyres squeal only with the handbrake, a hard brake, or at 90 % of its top speed or more (`CarSound.STEER_SQUEAL_SHARE`), so a car knocked sideways in a crash below that speed makes no squeal; the crash sound plays.
- The small trees a car bends make no sound, and the storage yards' ponds give no wet steps or splash: the water step plays only in the marsh water the ground shader draws (`game/scripts/world/standing_water.gd`).
- `car_tree_impact` plays about 5.4 dB under its planned level: its picked takes fall that far short of it (the processed manifest's `shortfall_db`).
- Web: after the page is minimised and shown again, Resume pauses again until the page has focus (a click in it), because the browser grants pointer lock only to a focused page (code review, 2026-11-14).
- Web, with a mouse: where the browser never grants pointer lock (an embedding frame without the permission, a kiosk, some Linux setups), "Click to play" starts play with the pointer free and a line saying the mouse won't turn the view, so the view cannot be turned with the mouse. After Esc, the pause menu's Resume asks for the lock again and, refused, stays paused, as before the start prompt (2026-11-15).
- The web start prompt's pointer lock in a real desktop browser and its tap on a real iPhone are confirmed only on the owner's devices: the checks ran in headed Chromium (Safari's iOS rules emulated) and in the headless contracts.
- The bay's water sound at the causeway barrier and the riprap rumble on the north slipway: see [Drivable cars](#drivable-cars-gamescriptsvehicles-2026-11-08).

## Mac notarization (`.github/workflows/mac-build.yml`, 2026-11-14)

- Release Mac builds are Developer ID signed and notarized from build 2084 on; build 2177 was the first signed on `macos-26-intel`. The sign job runs there, and both the Intel and the Apple Silicon checks must find Gatekeeper's acceptance and the stapled ticket before a release publishes (see [AGENTS](AGENTS.md#mac-builds)). The owner confirmed on their Mac (2026-11-17) that notarization works.
- Each release run waits for the owner's approval of the `mac-signing` environment, so nothing publishes until the owner approves the sign job.
- A run that cannot notarize (a refused credential, Apple's rejection, no verdict within 35 minutes, a failed staple) still publishes, with the build job's ad-hoc app, "not notarized" in the release title and the reason in the notes; after a browser download that app needs System Settings → Privacy & Security → "Open Anyway" ([README](README.md#build-for-the-mac)).

## Mac runners (`.github/workflows/mac-build.yml`, 2026-11-16)

- Releases depend on GitHub's Intel macOS runners: the sign job, the `itch` job and the "Check on an Intel Mac" job run on `macos-26-intel`. GitHub ends its Intel macOS images around August 2027 ([runner-images#13045](https://github.com/actions/runner-images/issues/13045)). From 2027-02-01 the workflow's first job warns in every run until they move: the sign and `itch` jobs back to `macos-26` (the `itch` job with butler's darwin-arm64 pin, in `INSTALL_LOG.md`), the Intel check removed or replaced.
- A shortage of Intel runners during signing still costs the owner's approval: GitHub's 15 minutes to find a runner start when the owner approves the sign job, and re-running it asks again.
- A release waits for the Apple Silicon check (owner, 2026-11-16). When GitHub has no Apple Silicon runner, nothing is published until "Re-run failed jobs" gets that check through, within a day of the build (the artifacts' retention); after that only a new run on `main`, built, signed and approved again, publishes.

## Touch controls (`game/scripts/ui/touch_controls.gd`, `touch_use_button.gd`, 2026-11-08)

- In a car, dragging the right side doesn't look round: the chase camera follows the car, and touch has no glance like the mouse's.
- Touch has no R: nothing resets a car to land or recovers the player on foot. A car on its roof rights itself, and one in the bay comes back on its own.
- On a touch browser with a keyboard, pausing, resizing or lifting RISE lets go of the handbrake (and the jetpack) even while a physical Space is held, until Space is pressed again (code review, 2026-11-08).

## Home screen and the start prompt's phone notes (`game/web/shell.html`, `tools/build-web.sh`, 2026-11-16)

- Checked only in headed Chromium 154: an iPhone 16 Pro as agent-browser emulates it (Safari's user agent, touch, 3x), Safari's page 402 x 716 upright and 874 x 370 sideways, the home screen app 402 x 874 and 874 x 402 with safe-area insets set through Chrome's DevTools protocol (62 top and 34 bottom upright; 62 left and right and 21 bottom sideways) and a page script standing in for its `navigator.standalone`; a Pixel 9; a 1440 x 900 desktop. Safari's own Add to Home Screen, the home screen app on a real iPhone (its status bar over the game, its real insets), an iPad, and Android's full screen and install on a real phone are not seen.
- The home screen hint also shows in Safari opened inside another app (SFSafariViewController), which reports Safari's user agent and may have no Add to Home Screen in its share sheet. In iOS 26's compact tab bar, Share is under the "⋯" button.
- The silent mode note follows WebKit's documented behaviour (web audio plays in a session the silent mode mutes), not a test on a device; on an iPad it assumes the Control Center's silent mode does the same.
- An iPhone's home screen app keeps its storage apart from Safari's (iOS's design, not checked here): expect its first launch to download the game again and its Options to start from the defaults.
- The touch controls read the safe-area insets when the page changes size (`touch_controls.gd`, `_layout` on `resized`). A phone's turn changes both at once; insets that changed without a resize would wait for the next one (seen only in emulation, when the insets were set after the turn).
- Sideways in Safari's 874 x 370 page, the start prompt's panel with both notes starts about 15 CSS px under the page's top edge, against about 24 with one line (it is centred in the page's top 44 %, as the prompt is designed). The second line's own height makes the difference, so spacing alone can't match the one-line margin.
- A web export made without `tools/build-web.sh` (Godot's own Export dialog) keeps the manifest link's placeholder, so the page asks for a manifest that isn't there (one 404 in the console). The project's web builds all go through `tools/build-web.sh`, which fills it in or fails.
- The game's feedback line (bottom centre, `hud.tscn`'s FeedbackPanel, 34 px up) isn't moved for the home indicator: in the home screen app upright, the bottom of its panel falls inside the 34 px band (by arithmetic, not seen). Touch play shows it only after a recovery ("Recovered").
- `tools/check-web-live.sh` checks the manifest's own file at both addresses, not the icons it names; the build's `tools/check_web_paths.py` checks those, and the 2026-11-16 local check loaded them at the root and under `/game/`.
- The home screen label is "Treasure Island" (the manifest's `short_name`, `apple-mobile-web-app-title`); an iPhone may shorten it under the icon, and Add to Home Screen lets the player rename it.

## Pause menu and confetti polish (`game/scripts/ui/hud.gd`, `game/scripts/world/goal_confetti.gd`, 2026-11-11)

Non-blocking notes from the reviews:

- The pause menu's unfocused buttons barely read as buttons: their fill is nearly the same as the panel's.
- The loading screen's Controls button still has the old see-through style.
- While the controls screen is open, the loading progress is hidden.
- On the web, the first goal may hitch once while the confetti shader compiles (not verified).
- Resuming (`_set_paused(false)` in `game/scripts/main.gd`) captures the mouse even when `capture_mouse_on_ready` is false, as the test harnesses set it (code review, 2026-11-11).
- The Options choices' and the start prompt's keyboard focus rings are checked by contrast in the contracts (at least 3:1 against the fill under them), not seen in any capture.
- `goal_confetti.gd`'s `on_screen` clamps the tone map's white only at 0.001 (`maxf(environment.tonemap_white, 0.001)`), not at 1.0 (code review, 2026-11-11).
- The gameplay contract's glancing walk past the ball (`_check_soccer_ball` in `headless_gameplay_contract.gd`) allows up to 3 m/s along the walk; the bound could be tightened to under 1.0 (code review, 2026-11-11).

## Loading screen (`game/scripts/main.gd`, `game/web/shell.html`, 2026-11-15)

Each startup step has its own line on the loading screen, which covers the island until play (`LOADING_STEPS` and `COMPILE_GROUPS` in `main.gd`; on the web the page first shows the download, or the load from this device, as a percentage, then **Saving the game on this device…** after a first download and **Starting the engine…**). Each line goes up before its step's work starts, and the work waits a frame so the line can be drawn. On the web the shaders are compiled a group of the world at a time, each group hidden until its frame, and the split costs about half a second of the load. What it can't show:

- On desktop the engine's own boot splash, with no line, stays up while the engine starts and loads the main scene (about 2.5 to 3.5 s on the devcontainer), before any game script runs. A line there would need a boot splash image of its own, and the web page shows that image during its download.
- No step shows how far along it is beyond its count. The island's load is one `load()` of the baked world, and each shader group's first frame compiles its shaders in one draw: the longest, the nearer half of the buildings, about 4 s on the web here. Counting further would mean a threaded load, or drawing a group's materials a few at a time.
- Nothing on the screen moves while a step runs, because each step holds the main thread (on the web the progress bar ends with the download).
- On the web the ferry group's line shows for only about 0.5 s (review note, 2026-11-15).
- A line is seen only once the frame that puts it up has been drawn, so the rest of that frame's work runs under the line before it. On the web about 2 s of the engine's own work on the newly loaded island, at the end of the load's frame, runs under **Loading the island…**. On a desktop's first launch the frame that puts up **Compiling shaders…** takes about 2 s under **Setting up the island…**, most likely the grass's first capture of the ground from above compiling its shaders.
- On a desktop the shaders are one step, **Compiling shaders…**: Godot compiles most of them as the island loads (on a first launch about 4.6 s of **Loading the island…**, which its second line says), and each group then draws in about 25 ms, so a line per group would only flicker. That compiling inside the island's load can't have a line of its own without a threaded load.

## Shader warm-up on the web (`game/scripts/world/shader_warm_up.gd`, `tools/web_shader_proof.sh`, 2026-11-17)

- The warm-up compiles every shader program the island draws while the game loads, before play; whether that costs memory headroom on an iPhone is not measured.
- The shader proof, which a web deploy now requires, adds about 20 minutes before each web deploy and needs this machine's GPU.
- About fifteen houses of the batch-06 siding family were not captured one by one for the shared-shader change (`ShaderWarmUp.shared_shader`).

## The web build's copy on the device (`game/web/shell.html`, `tiBuildFiles`, 2026-11-16)

The page keeps the build's 160 MB pack (about 134 MB travels, compressed) in the site's own storage (OPFS), one build at a time, and the next launch of the same build reads it from there; not on an iPhone or iPad, for now (below).

- Storing is off on an iPhone and iPad until it is measured on one. In WebKit on Linux (Playwright's WebKit 27.2 sized like an iPhone; integrator-batch-20261116f, runs K2 to K8), storing as the download arrives raises the browser's network process from about 250 to about 700 MiB for one or two seconds of the load: with the page's `tiBuildFiles` alone, 181 MiB with storing off against 481 to 509 MiB with it on over the local network, and 190 against 381 to 391 MiB at 100 Mbit/s, while the writes alone cost 67 MiB. The page's own process rose about 180 MiB on the first store of a session. iOS limits its networking process on its own, and the game's memory on an iPhone is unmeasured (the owner's play of build 2177 showed no crash so far). On an iPhone or iPad the pack downloads as before, into the one buffer the engine keeps, and no stored copy is read. `STORE_ON_IPHONE_AND_IPAD` in `game/web/shell.html` turns storing on there; for a test on a device, `?store=1` in the page's address turns it on and `?store=0` off, on any browser. The follow-up to evaluate is storing after play has started, from the buffer the engine keeps, instead of during the download; that store would have to end before the page frees the buffer once play is ready (next section), which the page does only once this tab's store has stopped writing.
- A whole store and a launch from the device have not run in WebKit: that test browser's quota for one site is about 50 MiB, so its store stops with QuotaExceededError after about 48 MiB.
- WebKit answers the page's `only-if-cached` request with the whole download from the network, not with a cache miss; the page takes that answer as its download (one request), and the HTTP cache keeps a copy there too.
- Storing needs file system writable streams: Safari 26, Chrome 86, Firefox 111. Older browsers download the pack on every launch, as before, unless their own HTTP cache keeps it.
- The two public addresses (https://play-grandtreasureisland.vercel.app/ and https://grandtreasureisland.vercel.app/game/) each keep their own copy, and so does a home screen app where storing is on, so each downloads the pack once per build.
- Chromium 154 on Linux, against a local server, has run all of it; WebKit only the first visits above, with its downloads read by a BYOB reader. On the owner's Mac (2026-11-17), a second launch of the web build skipped the download; the browser, and whether it read the stored copy or the browser's HTTP cache, are not recorded. Safari on a Mac or an iPhone (where storing is off), Firefox and Windows Chrome have not been confirmed to run it, nor has WebKit on Linux read a stored copy (without a BYOB reader the page copies each chunk in, and the chunks stay in memory until the next garbage collection).
- While a tab stores the pack it downloads it with `cache: 'no-store'`, after asking the HTTP cache for a copy it already has. When that store then fails (storage full, the tab closed during the download), the next launch downloads again even where the browser's HTTP cache would have kept the pack.
- A browser evicts the copy under storage pressure, and Safari deletes a site's script-writable storage after seven days of Safari use without a visit (WebKit, 2020; a home screen app keeps its own count of days); the next launch then downloads again.
- On a launch from the device the line reads **Loading the game…** for about 0.2 s before **Starting the engine…** (Chrome here): the engine's WebAssembly reports before the pack's source is known, and the line names no source until it is. **Loading the game from this device** is put up but not painted there, since the 160 MB read ends before the next frame; a slower device may show it. A download over the local network ends as fast, so it can go by without a painted percentage too.

## Freeing the game data once play is ready (`game/scripts/web/pack_release.gd`, `game/web/shell.html` `tiPackRelease`, 2026-11-18)

On the web the game data pack (161 MB) sat in the page's memory for the whole session, as the engine's file of it. Once play is ready the game names the pack's files it never reads again, and the page keeps only the rest, about 17.5 MB, and frees the pack's buffer: the baked world (86 MB), which the world loader reads once, and the imported files (textures, imported scenes, sounds) of the 322 imported resources the game holds at the start prompt, which it then holds for the session.

- Measured only on this machine: in Playwright's WebKit 27.2 sized like the owner's iPhone in Safari (874 x 292 CSS px at 3x), the web process's resident memory fell by 134 MiB at the start prompt and 135 MiB 60 s into the drive trace (means of three runs each way, `web-memory-20261118/pack`; 142 and 149 MiB by PSS), as freeing the 154 MiB buffer and keeping a 17 MiB copy should; WebAssembly, WebGL and sound memory did not change. On an iPhone it is not measured: JavaScriptCore frees a detached buffer's memory at once on Linux, and whether iOS counts it out of the page's footprint at once is not seen on a device.
- Through a whole drive trace with its triggers and every menu, the engine read nothing of the pack after play was ready but the release's own reading of the `.import` files, in WebKit sized like a phone with touch and in Chrome 154 as a 1440 x 900 desktop with a mouse, after storing the pack on the device (`web-memory-20261118/pack` runs R8 and R9; no shader program was compiled after loading in either, by `tools/web_trace/after_loading.mjs`). A later read of a released file (a new feature that loads the baked world again, or loads a held resource with a cache mode that skips Godot's cache) fails as a read error, and the browser's console names the file ("The game read ... of released game data").
- About 14 MB of what is kept was never read in that whole session: 73 JSON files (5.6 MB, mostly facade study geometry), the Bulgarian wall mural's `.dat` (2.3 MB), 11 imported textures (4.9 MB) and 65 scripts (1 MB). The web export could leave them out, once each is shown unused on the web.
- The held resources stay in memory for the session, including any the game would have let go later.

## Street detail in large batches (`game/scripts/world/street_detail_batches.gd`, 2026-11-18)

- Trees, plants, hedges, parked cars, cones and yard pieces go into one batch per mesh, level and 256 m cell (far impostors 1,024 m), each instance keeping the range its small cell gave it. Measured on this machine only, in WebKit sized like the owner's iPhone with the drive trace merged in for the measurement (corner route): GL buffers on the page 43,422 → 34,480, draw calls about 3,805 → 3,233, frame time unchanged within the runs' spread.
- Instances outside their distance band are still sent to the graphics chip and collapsed there, so the triangles submitted a frame rose from about 1.9 to about 3.2 million on the corner route; frame time did not get worse in the rig.
- Fences are drawn up to 91.4 m farther than before (median 40 m), never nearer (owner, 2026-11-18). Beyond their old distance they show posts and rails without their wire and windscreens, which still end at the old distance.
- Street furniture, the 312 street-name labels and the shoreline stones with generated LODs are not regrouped; they keep their own cells and batches.

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

## Shadow quality option (`game/scripts/settings/shadow_quality.gd`, 2026-11-12)

- Medium, the default, is main.tscn's Sun with project.godot's map and filter. Its splits are the owner's choice of 2026-11-12, after the player's own shadow looked chunky and a palm's pixelated on the Mac: the nearest split now ends at 16 m, then 40 m and 120 m. Near the player that gives about 2.2 by 4 cm of ground per shadow texel, where the old nearest split (40 m) gave 5.5 by 10 cm, coarser than the avatar's 8 to 9 cm legs (computed from the engine's split fit, with the sun 33 degrees up). The player's and nearby palms' shadows come out visibly cleaner, though not as clean as High's. In exchange, shadows from about 50 to 300 m are up to 2.5 times coarser than before (computed; past 120 m they share one split), clearest from the air. Its median GPU time per frame was 1.2 ms under to 0.1 ms over the old Medium's at nine fixed views (dev machine only: Radeon 780M, Forward+, 1440 x 900, other engines sharing the GPU). The barricades' beaded edges (below) had the same cause as the old chunkiness.
- High doubles the map, uses the soft-high filter and splits at 16, 48 and 200 m: about half of Medium's texel near the player, and a finer map at every distance. Its median GPU time was 1.3 to 4.4 ms over Medium's at the same views. Thin casters that Medium drops, such as the temporary fences' rails, now cast fine dotted lines. Not measured on the Mac.
- Low draws Medium's map and filter over two splits out to 200 m, so nothing farther casts. Its median GPU time was 0 to 2.8 ms under Medium's.
- The first frame after a level is chosen takes about 0.17 s longer (205 to 234 ms against 47 to 62 ms just before, on the dev machine), whichever level, whether or not the map's size changes. A review driver's two slower frames after other switches were its own image saves.
- The web build keeps its sun shadows off and offers no levels. In the Compatibility renderer (native, on the dev machine) turning them on also brightened every sunlit surface by about 40% (road 88 to 123 in sRGB) while Forward+ stayed the same, which looks like the shadowed sun drawn on top of the unshadowed one. The cause in the engine is not established.
- A level's shadow map size and soft-shadow filter are engine-wide, so they also reach building_shots.gd's neutral light; the shared capture harness always takes the default (`main.use_saved_settings = false`).
- The far-tree impostors were tone-matched under the old splits: `tools/vegetation/bake_impostors.gd` copies main.tscn's Sun, splits included, into the scene where it matches an impostor's tone to its near level. A re-bake from now on matches them under the new default; none has been done.

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
- **899 13th St (OSM w291196367), after the 2026-11-15 fix and its review round:** the ground round the shed is a clean lawn where the Sep 2025 Street View and the May 2026 aerial show a crowded contractor yard (parked cars, trailers, containers and stacked material behind chain-link); walls and roof have no corrugation; the roof is one flat warm grey-brown where the photos show rust patches over pale sheets (and the aerial reads greyer from above), and its rooftop unit and two stacks are not modelled; the canopy's underside is pale where the photos show a dark underside with purlins; the walls read slightly yellow in game light against the photos' pale greige; the double doors under the south canopy sit about 3 m closer to the WSW corner than in the Sep 2025 and Apr 2019 photos (a perspective-limited estimate), and the photos show bars between the corner and the doors and a dark glazed window beyond them, where the model has one barred window beyond the doors; a 1 px dashed light line ran along the annex-to-shed eave in the neutral top view, seen in review before the trim turned brown and not visible in the game-light overhead after (2026-11-15).
- **Open-sided mid-rise decks (OSM w291196366, w1222514685):** `midrise_family.gd` `_open_face` places posts every `module` from each face's start, so a face's last post can stand just beside the next face's corner post: six such pairs, 0.06 to 1.3 m apart, on w291196366's deck and two, 0.2 and 0.4 m apart, on w1222514685's pergola deck (2026-11-15). A new rule would move their geometry, so it waits for its own review.
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
- Where two small pitches meet end to end on the turf pitch, their goals stand
  back to back 1.64 m apart, centre to centre (`small_pitch_middle_a` and
  `small_pitch_west_b`, `small_pitch_middle_b` and `small_pitch_east_a`), and each
  net reaches 1.35 m behind its goal line, so the two nets pass through each other
  by about 1 m (the visual review of breakable-poles-20261114 saw it, 2026-11-14;
  the same rows on main, f72d6b21).
- Not modelled: the containers, sheds and the school bus round the rugby field,
  and the GAA field's strip of containers and sheds by Avenue E.

## Job Corps perimeter fence (`job_corps_perimeter` zone, 2026-11-18)

The OSM fence round the Treasure Island Job Corps Center (w1252737750, 2,113 m) is built on four sides as galvanised chain-link, 6 ft, the campus on its inside, `"breakable": false`: Seven Seas Avenue from the campus's south corner to the north-west corner, the north side with the Avenue D entrance and the north-east notch, 5th Street, and round the 4th Street lot to the 4th Street gate. One `osm_way` rule per side builds it, each naming its evidence: 1,627 m of fence in 8 runs. It opens only where the data opens every fence: Avenue D (w1473253277) and its two sidewalks (w1098437859, w1098437860) at the north entrance, and 5th Street at its locked gate (n2253031332).

- The hangar-pad side is not built. From the 4th Street gate along the pad's north-west edge and round the campus's south end (0 to 461 m along the way, about 442 m of fence) it stays data, so the campus is open there, the 4th Street gate included. Built, it shut ground in, which the clearance check's flood reports: a 0.76 m2 pocket between the pad's plastic berms (0.5 to 1.1 m from the line) and the fence, and single 0.2 m cells between the fence and the aerial's trees, which took the pad yard's own flood to its 10-cell threshold. Each such cell is a spot where the stock capsule stands clear and cannot walk out, so the flood stays as it is. The side can be built once the berms and those trees stand either against the line or clearly clear of it (1.3 m or more).
- The zone's shape is a 2 m marker in the campus's open north field: a pilot zone that reaches the way's line would build the pad side as OSM's default breakable fence.
- Height: the Sep 2025 views on Seven Seas Avenue (Dorm 369's old forecourt, the cafeteria) and the owner's Nov 2026 photo show it about 4 ft high. The kit's chain-link comes 6 or 8 ft, and its collision box is at least 1.83 m, so it stands 6 ft.
- Round the 4th Street lot (5th Street, Avenue H, 4th Street) the Sep 2025 views show temporary chain-link panels on feet; it is built as the same permanent chain-link. The Job Corps sign and its planting at the 351 Avenue H corner aren't built.
- By Dorm 369's old forecourt the fence follows OSM's line, about 6 m behind the back of the sidewalk, where the photos show it at the sidewalk's back.
- Not photographed: the north side with the Avenue D entrance and the north-east notch.
- OSM's inner fence w1164820773 stays unbuilt: tagged only barrier=fence, inside the campus with no dated photo, and 70 of its 133 m lie on Avenue D's east sidewalk and its kerbs.
- Cost (the fences layer built headless from the generated world): 96 more mesh instances (427 to 523) and 96 more surfaces, about 45,000 more vertices (about 1.6 MB), 547 more collision boxes. At the ferry spawn on the desktop renderer the layer draws 49 draw calls where it drew 40, and about 5,100 more primitives. Not measured on the web.

## The park outside Isle House (`isle_house_park` zone, 2026-11-15): study with known gaps

Built from the owner's video of 2026-11-15 (f_000 to f_114, kept outside Git) and the
2026-05-26 aerial. The frozen OSM snapshot leaves the lot untagged; the zone records the
owner's exception (`osm_exception`). What isn't there yet or is inferred:

- Not filmed, or only from far off, so drawn plain from the rest of the park: the
  frontage along Avenue of the Palms seen from the Isle House side, the mound's
  north-east side and top, the bed along Bruton Street's walk, the basin's inlets and
  edges, and the park sign's face. The bed triangle at the north tip, filmed from the
  cycle track's walk and from its edges (f_103, f_107, f_112), is planted throughout as
  the frames show it by the walk; its eastern inside is production inference.
- Estimated, not measured: the number and places of the young pines (a scatter rule,
  about one per 70 to 90 m² of bed), the lamps' 17 m spacing, the mound's 0.7 m rise,
  the sizes of the block benches and logs, the chairs' places, and the basin's outline.
- The park's north end has no level region of its own: Avenue of the Palms beside it
  lies on a straight profile over the 2023 raster's stockpile hump, 3.98 to 4.03 m from
  250 to 296 m along w1001544697 (`avenue_of_the_palms_hump` in
  tools/config/terrain-overrides.json), and the site's grade carries it on to the
  generated road by 318 m. The park's ground takes Cityside's site grade between the
  avenue, the cycle-track leg, the pump pad and the lawn: about 4.0 m beside the west
  sidewalk and the track, rising gently to about 4.4 m at the foot of the lawn mound
  (its top about 4.8 m), drawn 0.1 m higher; level as the video shows it (f_000 to
  f_005, f_103, f_107, f_112). Heights production inference. The lawn's neck reaches the
  west walk from about 292 to 304 m along the avenue (`north_tip_walk_lawn`,
  `walk_lawn`: f_000 to f_005, f_112); north of it the bed triangle is planted. Where
  the line between them crosses the bed, at about 292 to 296 m, is read from those
  frames, not measured.
- Isle House's land cells are untouched: the re-meshed cells beside them fan to their
  shared edge's corners (`scope.fan_beside` in tools/config/terrain-overrides.json). Over
  the last 4 m before that edge the land stands at most 7.7 cm off the edge's generated
  height where it was lowered (z 480 to 524, the most at z 512), and 8.7 to 9.2 cm above
  it at z 528 to 544, the generated slope there (about 2.3 %, as on main); no
  east-west grade in that band exceeds 3.6 %. The basin, beside Isle House's cell, is
  darker damp chips, not a hollow, and holds no water (the video was shot after rain).
- Cityside's north-west beds: the stormwater swale and forebay keep their heights, and
  the event plaza's north-east end beside them, with the grade round the swale and
  forebay held level at 4.2 m (`z7_forebay_grade`, the 2023 raster's level there, 3.97 to
  4.20 m). Against main (ba5ac01d): the forebay's floor (its land more than 1 m inside
  its outline) 1.9 cm lower, its drawn gravel 2.8 cm lower and its concrete rim 5.2 cm
  lower (3.78 m, beside the pump pad's 3.71 m), the swale's gravel 0.8 cm lower, the pump
  pad unchanged, the event plaza within 6 m of (-231, 488) 2.3 cm higher (the whole plaza
  0.8 cm). Inside the bioretention bed's outline the land is about 5 cm lower on average
  north of z 495 (its drawn mulch 5.1 cm) and about 35 cm lower south of it, on the old
  hump's flank by the cycle-track leg, up to 1.39 m (the mulch 37 cm, up to 1.22 m). Each
  sink's floor below the ground 1 to 2 m outside it (main in brackets): forebay 0.37 m
  (0.46), swale 0.12 m (0.14), bed 0.33 m (0.38); the ground beyond the forebay's north
  rim no longer climbs toward the old hump.
- Where the lowered stretch starts, at about 255 m along the avenue, its east parking
  lane has a hairline gap about 5 m long and up to 5 mm wide (x -184, z 467 to 472):
  two pieces of the draped lane meet a land-mesh corner a few millimetres apart, and the
  land shows through.
- The planting is the vegetation kit's stand-ins (silver cushions, buckwheat, small
  sagebrush, California fuchsia, rushes, red-stem shrubs, young pines and gum-like
  saplings), not the park's own species.
- Not built: the kerb strip of palms and upright grasses along the avenue frontage
  (it needs a street-ground change), the bike path's centre line and bike stencils,
  the yellow tactile pads at its crossings (the corner walk's among them, f_107), the
  white stepping pads in the east bed (f_025) and the orange delineator posts by the
  north tip (f_001 to f_005).
- The video shows cars parked at the avenue's west kerb by the park; the avenue's
  rule leaves that kerb clear.
- The chairs are the island's Adirondack chair in a pale powder blue (the park's own,
  f_103, f_107); Cityside's and the plaza's keep the azure of their photos.
- Follow-up (shared kit): the road-closure barricade and its sign (`street_furniture_kit.gd`
  `_closure_sign`) still tilt their collision boxes with the ground (`rest`), as the
  chairs did when they caught the stock player on a slope; not seen to catch yet.

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
  - At its south-east corner the Sep 2025 photo at 351 Avenue H shows the Job Corps sign, its planting, a chain-link fence and the bus shelter about 8 m from the camera. The fence is now the Job Corps perimeter's chain-link, where the photo shows temporary panels on feet; the sign and its planting aren't built, and the shelter (OSM n1249019421) stands about 15 m east of that.

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
- **Cityside Park promenade and strand garden** (2026-11-17):
  - Log seats render as plain pale solids, with no bark or end grain.
  - The strand garden's planting re-rolls as a whole when a bed's area changes, since its seed follows the bed's area: moving the two strand seats' nooks off the promenade moved 2,957 plants, all inside zones z8 and z9a.
  - A long bench, `set_piece:cityside_lawn_bench_3` at about (-308, 390), stands on the asphalt of the Avenue of the Palms bike path's band and would stop a car the way the two strand seats did; the clearance check's footway case (Tests, below) doesn't cover it.
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

Exports and the web build load a baked world whose buildings are merged by `tools/merge_baked_buildings.gd`: the same triangles through far fewer draws, while the world generated at startup keeps its authored nodes. Opaque surfaces whose plain materials differ only in colour join by colour, the colour moving into vertex colours; since 2026-11-18 other surfaces join those that share their material (or an equal copy), their vertex data byte for byte under one transform, and the merge by colour also takes housing support and ground meshes outside the two ground proofs (below). Merged surfaces hold at most 65,535 vertices. Building meshes have no LODs (0 of 16,666 source surfaces, measured in the bake).

On the web, main.gd culls each unmerged building part by its mesh's size (200 m up to 12 m, 500 m up to 50 m) and draws the merge by colour's own batches at any distance. Every part the merges newly take keeps the distance the web drew it to: a batch holds parts of one distance and carries their size (`PrebuiltWorld.DETAIL_SIZE_META`), measured from what the web culled before (a support or ground mesh whole, else what the merge by colour left of it), and a mesh that gives some surfaces up keeps its old box (`custom_aabb`) and size. A batch fades at its own box's centre's distance, where each part faded at its own: the 200 m and 500 m switches move by up to half the batch's extent, 50.6 m in the worst batch of the 2026-11-18 bake (`most_fade_shift_m` in the bake's log).

Measured on 2026-11-18, main's build 2272 (`fa943907`) against the merge's head, each with the web drive trace (`web/iphone-trace-memory-20261118`) merged in for the measurement only, silent builds, WebKit phone rig (874 × 292 at 3x, 3D scale 0.67, corner route), two runs each:

- Buildings in the web bake: 5,725 → 4,250 mesh surfaces, about 15,100 → 11,350 mesh buffers (the trace's own census: 13,983 → 10,259, of 256 bytes or less 4,616 → 2,211) and 2,665 → 640 materials, one uniform buffer each. GL buffers on the page at their peak: 43,761 → 38,003; their bytes 239.3 → 243.2 MB, or 868.9 → 779.5 MB counted in 16 KiB pages. The engine's video memory 440.5 → 444.4 MB.
- Draw calls on the drive: median 3,771 → about 3,560. Frame time: median 56 and 47 ms before, 45 and 47 ms after; the runs' spread is as large as any change.
- The baked world's scene file grew 85.7 → 86.3 MB (vertex colours and indices of the support parts), the web pack 158.8 → 159.4 MB.
- Pixels, at 49 fixed views of 24 buildings (every housing kit, the two ground-proof families, the landmarks) and the island views, on desktop (with a same-code rerun to set aside moving water, grass and trees) and in Compatibility with the web's culling (`building_shots.gd --web-distances`): the housing support parts that now join by colour (windows, doors, trims, canopy posts and beams) and the ground visuals differ by one 8-bit level on part of their pixels on desktop, one or two in Compatibility. That is main's 8-bit vertex-colour quantisation, now also on support and ground parts: a part's colour moves by at most half an 8-bit step before lighting. At most 4 pixels a view differ by more, at edges. Some views' skies differ by a level in bands, from the clouds' drift, as the two builds load in different frame counts.
- Far and night views, on 2026-11-18 after the merge's distance fix: from 30 m up at about 210 and 480 m across a garage-court block, a Bayside block and the midrise r19685981, and from 450 and 620 m above r19685981, in Compatibility with the web's culling, no part appears or goes (at most 14 pixels a view differ by more than 24 levels); close views of Isle House, Building 600, Building 1 and Building 3 differ by at most 1,238 pixels by one level. Desktop night pairs (the pier canopy's lamps, Aracely's lamp and daylight fill, Mersea's bulbs) match apart from the support parts' level; the web holds the recorded daytime, so it has no night. Two desktop runs of the same main build with different preceding views already differ by about 1,200 scattered pixels a view (the frame's last column and the asphalt), so a difference of that size between builds is not the merge.
- **Compatibility at island height:** seen from about 1.8 km straight down (the island top view), r19685981's lower rooftop solar panel shows where main showed the roof. It is drawn at any distance in both builds (it shows identically from 450 and 620 m); at 1.8 km the 24-bit depth buffer can't tell a few metres apart, so the draw order decides, and the merge changed it. The same kind of tie as the near-coplanar parts below.

Compared at 72 fixed views on 2026-11-06 (shader time frozen):

- About 3.7% of pixels on desktop differ by one 8-bit level, because a vertex colour stores 8 bits per channel where a material's colour is a float. Only about 0.025% differ by more.
- Near-coplanar parts can tie differently on depth: a 1-pixel lip at the south porch of Chinook w95934105, and 8 pixels on a distant sign beyond Fire Station 48.
- Long straight edges and wire chairs flip a few edge samples, from float rounding of at most 0.05 mm in the merged positions.
- A shadow edge on the south side of Job Corps 368 (w34313521) lost a small notch; the cause is not established.
- **Web only:** Mersea's glass changed, from the exterior probe going ONCE rather than from the merge: in Compatibility the panes now show soft reflections where they read as flat and dark. On desktop the same change is at most 2 levels on the glass.

Not needed to ship, and not done:

- The two housing families that keep the production ground (w96215674 and w96215673) keep their 458 support and ground meshes (520 surfaces) whole: `StudyGeometry.retained_ground_contact` compares them with their collider face by face, in order, and `StudyGeometry.retained_ground_meshes` names them for the merge.
- Per-house siding and roof colours are shader uniforms, so 397 shader-material surfaces (265 materials) and 54 housing support surfaces stay apart; about 300 would join if those colours moved into vertices (owner, 2026-11-18: not in this task). Sharing equal materials across buildings would free about 570 more uniform buffers (likewise not in this task).
- 2,895 merged surfaces in 867 batches stay apart by material (roughness, metallic, textures) or by the channels their parts carry; 524 of them hold 1 KiB of vertices or less.
- Also kept as authored: Mersea's 171 triplanar surfaces under their own transforms, 76 on reflection layers, 57 transparent and 27 scaled parts under their own transforms.
- Merged surfaces keep tangents that nothing reads on about 86% of vertices (about 15 MB raw, estimated from the census), and 1.87 million vertices are still unindexed triangle soup.
- 50 hidden meshes (89 buffers) stay in the bake.

Follow-ups from the code reviews (non-blocking at `e51de21d` and `d445887a`):

- `headless_bake_merge_contract.gd` has no fixtures for some kept cases: unsupported channels, per-instance settings, and parts with children or a script.

## Deferred by the owner

- Fences island-wide from the map data: not picked for this release. Today only fences in the street-detail zones are built; the rest stay data. The street reviews saw three that are missing: a container wall at 11th Street, a container wall at 4th Street / Avenue M, and wooden fences at 13th Street / Gateview Avenue, which hide a shelter in the photo.
- The pelican rider variant of the player: paused.

## Code and tooling cleanup (low priority)

- `game/scripts/world/day_sun.gd` finds a shader's glow by the text `EMISSION` in its code (`shader.code.contains("EMISSION")`), so a comment naming it would count (review note, 2026-11-15).
- `tools/test.sh`'s takes-dependent check (`grep -qE "${sfx_reads}"`, line 255) reads grep's status 2, an error, as no match, and its `Sound.manifest_path =` exemption also passes a test that sets `Sound.DEFAULT_MANIFEST_PATH`, the real takes (silent-checkout review notes, 2026-11-15).
- **Web release smoke:** the run check gates on distance, not speed, since 2026-11-06 (the scripts are outside Git, last in `perf-2-bake-20261106/release/scripts`).
  - Why it changed: two timed speed samples failed, both because of the browser stall above. The old `speedTest` took speed from two reads 550 ms apart. Its first read landed right after the stall, either side of the physics catch-up burst by chance, so `d44205d8` read 23.7 to 24.4 m/s in three failed smokes against a limit of 17 to 21, and an older build once read 23.5, while per-frame traces showed a true steady speed of 19.5 to 20.0. Its replacement sampled between the two stalls, then failed its proof at 12.57 m/s on `c7db08fc` when the second stall reached its window.
  - The gate: total distance over `speedTest`'s unchanged hold must be 20.2 to 27.1 m. Stock settings give 20.90 m at a true 17 m/s and 25.46 m at 21; those are widened by the recorded spread at a true 20 m/s, 23.62 to 25.95 m over 13 smoke passes.
  - What it means: at the nominal hold these limits admit a true speed of about 16.4 to 22.5 m/s, and 15.3 to 23.2 across the holds recorded. That is looser than 17 to 21 at both ends, by about 2 m/s at the top, so it catches a broken run rather than a slightly wrong one. Walk speed moves under 7 m. `headless_gameplay_contract.gd` and `run_speed_mps` still guard the exact value.
  - Limit of the method: distance isn't fully independent of the stall. A stall that delays no timer costs about 3 m: traced runs at a true 20 m/s moved 20.4 to 21.7 m, just inside the lower limit.
  - The 550 ms speed and a steady reading stay in the log as recorded readings, not gates.
  - The web starts paused behind its start prompt ("Click to play" / "Tap to play"), so every live leg must press it before it drives, walks or reads sound; a leg that doesn't sees a paused game.
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
  - `tools/check_street_detail_clearance.mjs`'s footway case covers only the paving of OSM footways (`highway=footway`) that a zone draws as a band, so a solid prop on another drawn band, such as the long bench on the Avenue of the Palms bike path (above), passes. It judges a prop by its foot (its row's position), not its body, so a prop whose foot stands just off a band and whose body reaches over the paving passes too (reviews, 2026-11-17).
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

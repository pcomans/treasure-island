# First-playable owner playtest

This is the short final review for the private Mac first playable. Automated evidence already proves the data/runtime contract; this playtest is for the things only a real rendered launch and the owner can decide.

Prior owner result, 2026-08-28: the owner confirmed in an earlier build that
the island itself is good, ordinary tag placement works, and held `Space`
behaves correctly as a continuous jetpack. The exact movement change in current
source keeps walking at `4 m/s` and raises the same held-Shift run from
`7 m/s` to `20 m/s` (about 45 mph), with a short acceleration/braking
ramp. That change still needs ordinary-play feedback in the exact current
package. Fire Station48 (`physical-building:w764313741`) adds one accepted physical unit: **15/213**, with **198 not evaluated**. All prior 14 acceptance records and 213 identities remain. Compiler `1.14.0`, catalog/registry v15 and contracts/loader v14 bind 14 active adapters, 23 plans and 17 package-ready plans. Owner package execution and independent review passed on the exact app `build/fire-station48-exact-current-001/Treasure Island First Playable.app`, with actual signed world `735/1023/1038/82,789/466/477`, all six attachments, stock movement/jetpack and separate mounted/privacy checks. PCK `8a5a42c73cc14008a30c9a86ef8187743e1328124d631bae2033a7c41683e012`; seven-file bundle `e8f6280660d251937a77bea97f2a4d8ec50e2f90245fbe24cec230fbdfdda13d`; executable `8136f070a79cb33eef25b496cdb042da9e6727e4ddb117ccdda4468332ed9cd1`. [Release closure](evidence/first-playable/fire-station48-current-release-2026-09-11-001/release-closure.json). Historical capture/candidate 14, 17 original images and sparse-motion/contact/setup limits remain unchanged. Native macOS smoke supplies no new OS pixels, manual-input/M1 acceptance or universal runtime claim. MAIN transfer, commit/push and ordinary no-argument launch remain pending in this preparation snapshot; HUMAN-001 remains owner-only.

## Start

First quit any older game window (`Esc`, then `Q` while paused). After its reviewed MAIN transfer, use `build/fire-station48-exact-current-001/Treasure Island First Playable.app` with no launch arguments for owner play. The project selects the case-sensitive `Dummy` audio driver itself. Historical and candidate apps retain separate identities.

Executable SHA-256 `8136f070a79cb33eef25b496cdb042da9e6727e4ddb117ccdda4468332ed9cd1`; PCK SHA-256 `8a5a42c73cc14008a30c9a86ef8187743e1328124d631bae2033a7c41683e012` (`69,170,808` bytes); seven-file identity `e8f6280660d251937a77bea97f2a4d8ec50e2f90245fbe24cec230fbdfdda13d`. Current package smoke supplies no new screenshots or manual acceptance.

### Historical B225 package identity (not current playtest bytes)

The historical B225 app's executable SHA-256 is
`c485010419591a9556e849e79755d7e816f840e31978c10b371be08a730e2d82`
(`170,963,648` bytes), its PCK SHA-256 is
`7315bba99efeeeb86be0bbf44876d391b9c1c95f1638318e0df2b7af367669bf`
(`66,073,188` bytes), and its canonical seven-file bundle identity SHA-256 is
`3f38c5dcd55b19f12cf7788e1069367075aa22f1b557c5b61288abdfdc30afe0`.
Its source contracts and full runtime passed the exact frozen generated
`729/739/48,389` and B225-stage active record-root `723/734/48,739`
mesh/surface/triangle totals, plus loaded
`735/952/967/67,716/466/466`
rows/meshes/surfaces/triangles/bodies/shapes and `4/20/30/40` movement values. Static
integrity, mounted-PCK audits, packaged headless smoke, and native Apple M2
Metal smoke passed. The later historical D2 authority was compiler `1.8.0`, catalog/runtime
registry v9, adapter contracts/loader API v8, and exact recognition `9/213`.
The exact 37-file packet tree is
`7b0de99e6f4afe07b1767c522517ace3dc1729a3f82f4b9b95716de9483cbd84`;
the independent [mechanical audit](evidence/reviews/d1-b225-postpromotion-v8-2026-09-05-INDEPENDENT_CONTRACT_AUDIT.md)
has SHA-256
`9c909d047786d4f7feab138b4d7c597bba1bac2adcf78cc8bcdfb568de0a0ec2`,
and the independent [visual review](evidence/reviews/d1-b225-postpromotion-v8-2026-09-05-INDEPENDENT_VISUAL_REVIEW.md)
has SHA-256
`881b04d696bfe842c39a220be5f4da3087f30d8ef8e9c0493c9c62067a826c99`.
Both pass for release with no additional recognition credit. None of those
technical checks is ordinary owner play; the verifier was Apple M2, while the
approved owner target remains Apple M1 Pro.

Wait for the full-world loading panel to disappear. A center reticle means the validated world is ready. If `WORLD LOAD BLOCKED` appears, record the code and message; do not treat the partial session as playable. The current load-failure panel has no in-app Exit control, a known workflow gap; quit the application through macOS.

## Controls

- `WASD`: walk at `4 m/s`; hold `Shift` for the fast run up to `20 m/s` (about 45 mph).
- Hold `Space`: rise with the endless jetpack; release it to float down slowly. `WASD` and `Shift` still steer in the air.
- Mouse: orbit the camera.
- Primary click: spray the center-reticle target. Stand within 6 m of an exterior building wall.
- `R`: recover to the latest safe position.
- `Esc`: pause/resume; the pause panel has Resume and Exit buttons.
- `F3`: show/hide runtime evidence.
- `Q` while paused: quit.

## Ten-minute acceptance pass

1. From the ferry-arrival spawn, confirm the cyan pill is fully above the surface immediately—there should be no visible one-meter settling fall or buried lower half. Walk across nearby road/area seams, then hold Shift long enough to reach the fast-run cap. Confirm the ramp feels responsive but controllable, releasing Shift returns smoothly toward walking speed, and releasing movement stops without an abrupt velocity cut. The player should remain surface-aligned.
2. The retained [normal-route log](evidence/first-playable/final-verification-2026-09-03-105408/logs/42_normal_route_after_export_guard.log) records historical source automation walking/running `262.349 m` continuously from the terrain-aware ferry through Waterfront Plaza to Trade Winds Avenue in about `18.1 s` wall time; the retained [whole-island route log](evidence/first-playable/final-verification-2026-09-03-105408/logs/43_whole_island_route_after_export_guard.log) records `3,449.107 m` of bounded traversal with real jetpack steering and generated-terrain landings at southwest, center, north, and east-perimeter anchors with no stall or recovery. Rise to the elevated angles that exposed the earlier defect: roads and public-space polygons should remain continuous without long triangular spikes, tears, or holes. Release to land, press `R`, and confirm the pill returns cleanly to the surface.
3. Inspect buildings on sloped ground. Roofs and top edges should stay level, while exterior wall/foundation bottoms reach the terrain without a bright floating gap. Then decide whether the island still reads as Treasure Island at ground level.
4. Inspect vegetation around the south, legacy grid, center, and north/west lawns. The south should have readable palm rows with a limited ornamental layer; broadleaf trees should be sparse, central conifers compact, and Waterfront Plaza, the ferry arrival, industrial lots, cyan terrain/shoreline overlays, shoreline sightlines, and large lawns mostly open. Plants are visual-only and should not alter movement or spray behavior.
5. Look toward Yerba Buena Island, the Bay Bridge, and San Francisco. Confirm that YBI reads as an irregular ridged island rather than a round mound, that its OSM shoreline meets the water, and that the coarse eastern bridge is readable light concrete rather than black. All three remain non-colliding context.
6. Spray an exterior building wall from close range. A source capture already proves one visible, upright, identity-matched eligible tag; confirm it in ordinary play and check that it does not bleed onto an adjacent surface. Try ground, roof, water/context, too-far, and empty-sky targets; each should reject without stopping movement. Pause/resume, toggle `F3`, and exit from the pause panel; relaunch once to confirm tags are session-only.

Record a simple result against bundle identity
`c62ae8d2878135ace2206755bbb7ee91fee47f68ec8cac4b334be233b710de26`:
`accepted`, or `blocked`
with location, action, expected result, observed result, and (if useful) a
screenshot. Acceptance requires both recognizable Treasure Island and a
playable walk/run/jetpack/spray experience; a successful automated suite,
source-project visual review, static package audit, or deterministic app smoke
alone is not enough.

## Safe cleanup

Close the app first. Exported apps are disposable only at their exact staging
paths under `build/`, including the current
`build/d5-1317-exact-current-001/`,
and historical `build/d5-1308-1394-quality-exact-current-001/`,
the historical
`build/d5-1308-1394-exact-current-001/`,
`build/d2-1444-quality-v2-current-2026-09-09-001/`,
`build/d2-1439-quality-v2-current-release-2026-09-09-001/`,
`build/building-1-wing-returns-v2-current-2026-09-08-001/`,
`build/d2-1441-postpromotion-v9-2026-09-07-001/`,
`build/d2-1441-production-v8-staging-2026-09-05-009/`,
`build/d1-b225-postpromotion-v8-2026-09-05-001/` and earlier
`build/b201-promotion-staging-2026-09-05-024605/`,
`build/b201-promotion-staging-2026-09-05-014223/` (withdrawn pre-final-evidence-bridge diagnostic),
`build/final-verification-staging-2026-09-03-111725/`,
`build/b201-promotion-staging-2026-09-05-002922/` (withdrawn pre-scope
diagnostic),
`build/b201-promotion-staging-2026-09-05-002336/` (withdrawn package-test
diagnostic),
`build/startup-repair-staging-2026-08-31-190724/`,
`build/car-speed-staging-2026-08-28-231815/`, and
`build/textured-world-final-staging-2026-08-28-224622/`; generated
world/evidence can be reproduced with the commands in [README.md](README.md).
For project-local Godot and npm dependency removal, follow the exact narrow
procedures in [INSTALL_LOG.md](INSTALL_LOG.md). Keep both frozen `data/osm/`
and `data/terrain/` sources.

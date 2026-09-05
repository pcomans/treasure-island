# First-playable owner playtest

This is the short final review for the private Mac first playable. Automated evidence already proves the data/runtime contract; this playtest is for the things only a real rendered launch and the owner can decide.

Prior owner result, 2026-08-28: the owner confirmed in an earlier build that
the island itself is good, ordinary tag placement works, and held `Space`
behaves correctly as a continuous jetpack. The exact movement change in current
source keeps walking at `4 m/s` and raises the same held-Shift run from
`7 m/s` to `20 m/s` (about 45 mph), with a short acceleration/braking
ramp. That change still needs ordinary-play feedback in the exact current
package. The historical `190724` package's plain native window proves the
startup repair on the verifier Mac, while B201 candidate `024605` is now
historical package evidence. The current B225 v8 package has deterministic
package/evidence closure and two independent release passes; none of these
establishes ordinary owner recognition, input, or acceptance on the Apple M1
Pro target.

## Start

First quit any older game window (`Esc`, then `Q` while paused); macOS
may otherwise focus an already-running historical copy. Open the sole current
handoff at
`build/d1-b225-postpromotion-v8-2026-09-05-001/Treasure Island First Playable.app`.
Do not add an `--audio-driver` launch argument: the repaired project already
selects the exact case-sensitive `Dummy` driver before Godot initializes
audio. The `190724` startup-repair, `231815` car-speed, and `224622`
textured-world apps are historical and must not be used to judge the current
result.

The current app's executable SHA-256 is
`c485010419591a9556e849e79755d7e816f840e31978c10b371be08a730e2d82`
(`170,963,648` bytes), its PCK SHA-256 is
`7315bba99efeeeb86be0bbf44876d391b9c1c95f1638318e0df2b7af367669bf`
(`66,073,188` bytes), and its canonical seven-file bundle identity SHA-256 is
`3f38c5dcd55b19f12cf7788e1069367075aa22f1b557c5b61288abdfdc30afe0`.
Source contracts and full runtime pass the exact frozen generated
`729/739/48,389` and current active record-root `723/734/48,739`
mesh/surface/triangle totals, plus loaded
`735/952/967/67,716/466/466`
rows/meshes/surfaces/triangles/bodies/shapes and `4/20/30/40` movement values. Static
integrity, mounted-PCK audits, packaged headless smoke, and native Apple M2
Metal smoke pass. Current authority is compiler `1.7.0`, catalog/runtime
registry v8, adapter contracts/loader v7, and exact recognition `8/213`.
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
2. The retained [normal-route log](evidence/first-playable/final-verification-2026-09-03-105408/logs/42_normal_route_after_export_guard.log) records current-source automation walking/running `262.349 m` continuously from the terrain-aware ferry through Waterfront Plaza to Trade Winds Avenue in about `18.1 s` wall time; the retained [whole-island route log](evidence/first-playable/final-verification-2026-09-03-105408/logs/43_whole_island_route_after_export_guard.log) records `3,449.107 m` of bounded traversal with real jetpack steering and generated-terrain landings at southwest, center, north, and east-perimeter anchors with no stall or recovery. Rise to the elevated angles that exposed the earlier defect: roads and public-space polygons should remain continuous without long triangular spikes, tears, or holes. Release to land, press `R`, and confirm the pill returns cleanly to the surface.
3. Inspect buildings on sloped ground. Roofs and top edges should stay level, while exterior wall/foundation bottoms reach the terrain without a bright floating gap. Then decide whether the island still reads as Treasure Island at ground level.
4. Inspect vegetation around the south, legacy grid, center, and north/west lawns. The south should have readable palm rows with a limited ornamental layer; broadleaf trees should be sparse, central conifers compact, and Waterfront Plaza, the ferry arrival, industrial lots, cyan terrain/shoreline overlays, shoreline sightlines, and large lawns mostly open. Plants are visual-only and should not alter movement or spray behavior.
5. Look toward Yerba Buena Island, the Bay Bridge, and San Francisco. Confirm that YBI reads as an irregular ridged island rather than a round mound, that its OSM shoreline meets the water, and that the coarse eastern bridge is readable light concrete rather than black. All three remain non-colliding context.
6. Spray an exterior building wall from close range. A source capture already proves one visible, upright, identity-matched eligible tag; confirm it in ordinary play and check that it does not bleed onto an adjacent surface. Try ground, roof, water/context, too-far, and empty-sky targets; each should reject without stopping movement. Pause/resume, toggle `F3`, and exit from the pause panel; relaunch once to confirm tags are session-only.

Record a simple result against
`d1-b225-postpromotion-v8-2026-09-05-001`: `accepted`, or `blocked`
with location, action, expected result, observed result, and (if useful) a
screenshot. Acceptance requires both recognizable Treasure Island and a
playable walk/run/jetpack/spray experience; a successful automated suite,
source-project visual review, static package audit, or deterministic app smoke
alone is not enough.

## Safe cleanup

Close the app first. Exported apps are disposable only at their exact staging
paths under `build/`, including current
`build/d1-b225-postpromotion-v8-2026-09-05-001/` and historical
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

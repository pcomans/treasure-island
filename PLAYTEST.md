# First-playable owner playtest

This is the short final review for the private Mac first playable. Automated evidence already proves the data/runtime contract; this playtest is for the things only a real rendered launch and the owner can decide.

Prior owner result, 2026-08-28: the owner confirmed in an earlier build that the island itself is good, ordinary tag placement works, and held `Space` behaves correctly as a continuous jetpack. The exact movement change in current source keeps walking at `4 m/s` and raises the same held-Shift run from `7 m/s` to `20 m/s` (about 45 mph), with a short acceleration/braking ramp. That change still needs ordinary-play feedback.

## Start

First quit any older game window (`Esc`, then `Q` while paused); macOS may otherwise focus an already-running historical copy. Open the sole current handoff at `build/car-speed-staging-2026-08-28-231815/Treasure Island First Playable.app`. The `224622` textured-world app predates the car-speed run change and must not be used to judge it. The current app's mounted PCK and package smokes independently pin the exact `4/20/30/40` movement values and unchanged world/content contract.

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
2. Current-source automation walked/ran `262.349 m` continuously from the terrain-aware ferry through Waterfront Plaza to Trade Winds Avenue in `18.101 s`, then a bounded whole-island run traveled `3,449.107 m` with real jetpack steering and landed on generated terrain at southwest, center, north, and east-perimeter anchors with no stall or recovery. Rise to the elevated angles that exposed the earlier defect: roads and public-space polygons should remain continuous without long triangular spikes, tears, or holes. Release to land, press `R`, and confirm the pill returns cleanly to the surface.
3. Inspect buildings on sloped ground. Roofs and top edges should stay level, while exterior wall/foundation bottoms reach the terrain without a bright floating gap. Then decide whether the island still reads as Treasure Island at ground level.
4. Inspect vegetation around the south, legacy grid, center, and north/west lawns. The south should have readable palm rows with a limited ornamental layer; broadleaf trees should be sparse, central conifers compact, and Waterfront Plaza, the ferry arrival, industrial lots, cyan terrain/shoreline overlays, shoreline sightlines, and large lawns mostly open. Plants are visual-only and should not alter movement or spray behavior.
5. Look toward Yerba Buena Island, the Bay Bridge, and San Francisco. Confirm that YBI reads as an irregular ridged island rather than a round mound, that its OSM shoreline meets the water, and that the coarse eastern bridge is readable light concrete rather than black. All three remain non-colliding context.
6. Spray an exterior building wall from close range. A source capture already proves one visible, upright, identity-matched eligible tag; confirm it in ordinary play and check that it does not bleed onto an adjacent surface. Try ground, roof, water/context, too-far, and empty-sky targets; each should reject without stopping movement. Pause/resume, toggle `F3`, and exit from the pause panel; relaunch once to confirm tags are session-only.

Record a simple result: `accepted`, or `blocked` with location, action, expected result, observed result, and (if useful) a screenshot. Acceptance requires both recognizable Treasure Island and a playable walk/run/jetpack/spray experience; a successful automated suite or app launch alone is not enough.

## Safe cleanup

Close the app first. Exported apps are disposable only at their exact staging paths under `build/`, including the current `build/car-speed-staging-2026-08-28-231815/` and historical `build/textured-world-final-staging-2026-08-28-224622/`; generated world/evidence can be reproduced with the commands in [README.md](README.md). For project-local Godot and npm dependency removal, follow the exact narrow procedures in [INSTALL_LOG.md](INSTALL_LOG.md). Keep both frozen `data/osm/` and `data/terrain/` sources.

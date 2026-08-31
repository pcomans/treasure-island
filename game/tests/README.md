# First-playable test suite

Run from the project root with the exact trusted, self-contained Godot binary recorded in [`INSTALL_LOG.md`](../../INSTALL_LOG.md):

```sh
GODOT=".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot"
"$GODOT" --version
"$GODOT" --headless --editor --path . --quit
"$GODOT" --headless --path . --script game/tests/headless_scene_parse.gd
"$GODOT" --headless --path . --script game/tests/headless_gameplay_contract.gd
"$GODOT" --headless --path . --script game/tests/headless_world_material_contract.gd
"$GODOT" --headless --path . --script game/tests/validate_generated_world.gd
"$GODOT" --headless --path . --script game/tests/full_runtime_integration.gd
"$GODOT" --headless --path . --script game/tests/automated_route_qa.gd
"$GODOT" --headless --path . --script game/tests/automated_route_qa.gd -- --whole-island-route
```

Expected Godot version: `4.7.2.stable.official.ed1daf0bf`. The first editor command refreshes the project-local import cache; it is not a gameplay or export test.

## What each test covers

- `headless_scene_parse.gd` parses all four owned gameplay scenes and their scripts without loading the generated island.
- `headless_gameplay_contract.gd` checks the input map including Space-bound jetpack lift; the exact `4 m/s` walk, `20 m/s` held-Shift run, `30 m/s²` acceleration, and `40 m/s²` braking defaults; unchanged jetpack defaults; absence of deferred vehicle behavior; boundary edge/hole cases; scene hierarchy; the exact SF billboard texture/hash/dimensions/transform/mesh/material/no-collision contract; physics/render layers; direct spring-arm camera child; and the 64-tag default.
- `headless_world_material_contract.gd` checks every textured semantic material key against its exact Poly Haven diffuse/OpenGL-normal/roughness paths, retained official source dimension, approved effective visual repeat, per-family subtle normal strength, generated runtime tangents, displacement opt-out, repeat mode, anisotropic mipmap filtering, and imported mipmaps.
- `validate_generated_world.gd` proves `FileAccess` can read through the intentional `generated/.gdignore` boundary, then enforces the fail-closed handoff: frozen OSM, USGS, and accepted NAIP input hashes, exact terrain dimensions/bounds/sample range/pins, artifact-index hash, exact `735 playable + 4 context` coverage, coherent-surface/foundation summaries, feature semantics, source references, boundary geometry, terrain-aware anchors, spawn containment, and the pinned `124`-placement vegetation seed/assets/order/counts/terrain support/no-YBI/overlay clearance. The independent Node validator additionally proves the `427`-source filled pavement base, exact OSM visual classification, pedestrian-within-base geometry, vehicle precedence, non-collision, `0.019–0.081 m` conformance envelope, unchanged collision hash, and all 17 paved parking sources; it also reconstructs every plant's serialized support triangle and checks each curated GLB.
- `full_runtime_integration.gd` instantiates the real `game/scenes/main.tscn`, waits for `world_ready`, proves the player is grounded before its first visible frame, validates the pinned vehicle/pedestrian/paved tints plus all eleven live Poly Haven texture identities, official source dimensions, approved effective repeats, per-family subtle normals, and finite tangent arrays, validates `124` logical plants across `15` assets and `19` collision-free MultiMesh batches, checks foot clearance at first reveal and throughout walk/run, inspects every live generated mesh/collider/source identity and overlay shadow mode, exercises sustained jetpack rise, air control, capped slow descent/landing, camera clamping, spring-arm compression, manual/boundary recovery, spray placement/rejection, tag eviction, continued movement, and a failed reload that removes the world and disables the player.
- `automated_route_qa.gd` starts the real player at the exact ferry spawn and steers actual camera-relative inputs without changing the player transform after startup. Its default fast gate walks/runs the terrain-aware 14-checkpoint Waterfront Plaza, Treasure Island Road, and Trade Winds Avenue route. The optional `--whole-island-route` mode continues with real run/jetpack input, lands on generated terrain at the same southwest, center, north, and east-perimeter anchors used by rendered QA, and fails on boundary escape, recovery, stalled progress, implausible per-frame movement, missed landings, or excess duration.

The current movement round exits `0` for scene parse, the focused input/controller contract, real full-runtime integration, both route modes, and the main-scene smoke with its `MAC_EXPORT_MOVEMENT` assertion. It remains bound to content SHA-256 `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164` and manifest SHA-256 `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`; geometry and world content are unchanged. The exact fresh app in [`car-speed-mac-run-2026-08-28-231815/`](../../evidence/first-playable/car-speed-mac-run-2026-08-28-231815/) passes the mounted-PCK audit, headless package smoke, and capped native Metal smoke. The retained [`textured-world-final-mac-run-2026-08-28-224622/`](../../evidence/first-playable/textured-world-final-mac-run-2026-08-28-224622/) package is now historical pre-tuning evidence; the retained rendered set remains valid for the unchanged presentation.

These automated checks do not establish ground-level visual quality, owner recognition of Treasure Island, or owner acceptance of the exported app. Those checks belong to [`PLAYTEST.md`](../../PLAYTEST.md).

## Automated continuous route QA

The normal headless command above is the fast, pixel-free route gate. On the pinned world it covers a `264.122 m` centerline and, with the current tuning, travels `262.349 m` in `18.101 s`. It reports actual distance, elapsed time, walk/run physics frames, checkpoint errors, airborne frames, recoveries, stalls, and final position before self-quitting. It exercises the real `PlayerController`; there are no between-checkpoint teleports or test-only movement calls. On the final approach it releases Shift at the slowdown distance derived from the live run, walk, and acceleration values, then releases movement and proves the real braking response can settle near the destination.

For one bounded whole-island traversal from that same ferry start, add `-- --whole-island-route`. The mode retains the road-following southern leg, then uses the existing unlimited jetpack to cross the long regional gaps and lands on generated ground at southwest, center, north, and east perimeter. It advances the test clock at `8x` with `480` physics ticks per second, preserving a `1/60 s` controller/physics step while leaving all player speeds unchanged. The current headless result traveled `3,449.107 m` in `52.013 s` wall time (`415.817 s` simulated), exercised walk/run/jetpack input, landed in all five regions, and recorded a maximum one-frame move of `0.348 m`, zero recoveries, zero boundary escapes, zero stalls, and no post-start transform writes. The `0.36 m` plausibility cap covers the exact vector length of `20 m/s` horizontal movement plus the unchanged `5 m/s` ascent at 60 Hz with a small physics tolerance.

For four optional screenshots from that same continuous run, use the normal Forward+/Metal renderer and an isolated output directory:

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot \
  --path . \
  --display-driver macos \
  --rendering-method forward_plus \
  --rendering-driver metal \
  --audio-driver Dummy \
  --resolution 1440x900 \
  --script game/tests/automated_route_qa.gd \
  -- --visual-evidence-output=/private/tmp/treasure-island-route-captures
```

The rendered form writes `route-*.png` and `route-capture-manifest.json`, but is not part of the headless pass and still does not replace owner visual acceptance. Exact retained headless output and the route's proof boundary are in [`evidence/first-playable/automated-route/`](../../evidence/first-playable/automated-route/).

After exporting, smoke the packaged main scene independently of the editor project:

```sh
APP_BINARY="build/car-speed-staging-2026-08-28-231815/Treasure Island First Playable.app/Contents/MacOS/Treasure Island First Playable"
"$APP_BINARY" --headless -- --mac-export-smoke
"$APP_BINARY" --max-fps 60 --rendering-method forward_plus --rendering-driver metal -- --mac-export-smoke
```

The smoke validates the exact foot-level ferry spawn/yaw plus packaged content hash/counts, grounded player-enable gate, exact `4/20 m/s` movement and `30/40 m/s²` response defaults, ambient/camera defaults, and all eleven live Poly Haven texture identities/effective repeats/filtering/normals, then scripts a held-Space ascent and released slow descent before exiting. It prints `MAC_EXPORT_VISUAL`, `MAC_EXPORT_MOVEMENT`, and `MAC_EXPORT_JETPACK` metrics and fails if all checks do not finish within 60 seconds of simulation time. The `semantic_palette` metric name is retained for log compatibility, but it now reports the semantic-material contract rather than the superseded flat-color palette. Use explicit `--max-fps 60` for deterministic non-headless Metal/Forward+ smoke on the target Mac. The first direct uncapped Metal run reached the exact world, visual, and movement assertions but hit `MAC_EXPORT_SMOKE_TIMEOUT` before jetpack; it is a non-pass diagnostic. The capped rerun reached jetpack rise `2.751 m`, descent `0.300 m`, and final `PASS`. Smoke mode ignores focus-out so its physics gate stays deterministic; normal gameplay still pauses on focus-out.

## Reproducible rendered-view capture

`rendered_visual_evidence_capture.gd` is an isolated source-project capture harness. It does not change the normal main scene or gameplay path. It loads the real fail-closed world, validates the exact current content/manifest/ferry transform, terrain anchors, vegetation counts, and full runtime counts, and captures five fixed regions, two elevated owner-comparison angles, two vegetation views, a real-controller eligible-wall tag, and two separately aimed horizon-context scenarios. Add `--vegetation-evidence-quick` after `--` to capture only the grounded and elevated vegetation pair. For every grounded scenario it spawns the real player above generated terrain, clears input, runs real physics until grounded with measured clearance, and only then disables gameplay for deterministic rendering. It also refuses to save a frame while the tree or Pause HUD is paused.

On this macOS Godot build, `--headless` selects a dummy renderer and cannot produce truthful screenshots. Run the bounded harness with the normal Forward+/Metal renderer:

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot \
  --path . \
  --display-driver macos \
  --rendering-method forward_plus \
  --rendering-driver metal \
  --audio-driver Dummy \
  --resolution 1440x900 \
  --script game/tests/rendered_visual_evidence_capture.gd
```

The default output is `evidence/first-playable/rendered-runtime-grounded/`. To use an isolated comparison directory, add a user argument after `--`, for example `-- --visual-evidence-output=/private/tmp/treasure-island-render-check`. The full harness writes thirteen PNGs plus `capture-manifest.json`; quick vegetation mode writes two. It prints one `VISUAL_CAPTURE` line per image and a final `PASS`, rejects blank/wrong-sized/paused/ungrounded images where grounding applies, validates tag identity and context projection/occlusion, and self-terminates within a conservative 180-second watchdog. The final complete pass is [`textured-world-final-rendered-2026-08-28-223242/`](../../evidence/first-playable/textured-world-final-rendered-2026-08-28-223242/).

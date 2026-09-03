# First-playable test suite

Run from the project root with the exact trusted, self-contained Godot binary recorded in [`INSTALL_LOG.md`](../../INSTALL_LOG.md):

```sh
GODOT=".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot"
"$GODOT" --version
"$GODOT" --headless --editor --path . --quit
"$GODOT" --headless --path . --script game/tests/headless_startup_configuration_contract.gd
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

- `headless_startup_configuration_contract.gd` checks that `project.godot` selects the exact case-sensitive `Dummy` audio driver before `AudioServer` initialization, that Godot loads and initializes that driver in the focused process, and that the packaged main-scene smoke oracle matches the accepted current `1,278 meshes / 1,288 surfaces / 55,067 triangles` runtime topology.
- `headless_scene_parse.gd` parses all four owned gameplay scenes and their scripts without loading the generated island.
- `headless_gameplay_contract.gd` checks the input map including Space-bound jetpack lift; the exact `4 m/s` walk, `20 m/s` held-Shift run, `30 m/s²` acceleration, and `40 m/s²` braking defaults; unchanged jetpack defaults; absence of deferred vehicle behavior; boundary edge/hole cases; scene hierarchy; the exact SF billboard texture/hash/dimensions/transform/mesh/material/no-collision contract; physics/render layers; direct spring-arm camera child; and the 64-tag default.
- `headless_world_material_contract.gd` checks every textured semantic material key against its exact Poly Haven diffuse/OpenGL-normal/roughness paths, retained official source dimension, approved effective visual repeat, per-family subtle normal strength, generated runtime tangents, displacement opt-out, repeat mode, anisotropic mipmap filtering, and imported mipmaps.
- `validate_generated_world.gd` proves `FileAccess` can read through the intentional `generated/.gdignore` boundary, then enforces the fail-closed handoff: frozen OSM, USGS, and accepted NAIP input hashes, exact terrain dimensions/bounds/sample range/pins, artifact-index hash, exact `735 playable + 4 context` coverage, coherent-surface/foundation summaries, feature semantics, source references, boundary geometry, terrain-aware anchors, spawn containment, and the pinned `124`-placement vegetation seed/assets/order/counts/terrain support/no-YBI/overlay clearance. The independent Node validator additionally proves the `427`-source filled pavement base, exact OSM visual classification, pedestrian-within-base geometry, vehicle precedence, non-collision, `0.019–0.081 m` conformance envelope, unchanged collision hash, and all 17 paved parking sources; it also reconstructs every plant's serialized support triangle and checks each curated GLB.
- `full_runtime_integration.gd` instantiates the real `game/scenes/main.tscn`, waits for `world_ready`, proves the player is grounded before its first visible frame, validates the pinned vehicle/pedestrian/paved tints plus all eleven live Poly Haven texture identities, official source dimensions, approved effective repeats, per-family subtle normals, and finite tangent arrays, validates `124` logical plants across `15` assets and `19` collision-free MultiMesh batches, checks foot clearance at first reveal and throughout walk/run, inspects every live generated mesh/collider/source identity and overlay shadow mode, exercises sustained jetpack rise, air control, capped slow descent/landing, camera clamping, spring-arm compression, manual/boundary recovery, spray placement/rejection, tag eviction, continued movement, and a failed reload that removes the world and disables the player.
- `automated_route_qa.gd` starts the real player at the exact ferry spawn and steers actual camera-relative inputs without changing the player transform after startup. Its default fast gate walks/runs the terrain-aware 14-checkpoint Waterfront Plaza, Treasure Island Road, and Trade Winds Avenue route. The optional `--whole-island-route` mode continues with real run/jetpack input, lands on generated terrain at the same southwest, center, north, and east-perimeter anchors used by rendered QA, and fails on boundary escape, recovery, stalled progress, implausible per-frame movement, missed landings, or excess duration.

The exact-current round exits `0` for startup/scene/input/material/generated
contracts, real full-runtime integration, both route modes, and the source
main-scene smoke. It remains bound to content SHA-256
`01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`
and manifest SHA-256
`e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`.
The generated record-owned topology is
`729 meshes / 739 surfaces / 48,389 triangles`; accepted visual
attachments bring the loaded total to
`1,278 meshes / 1,288 surfaces / 55,067 triangles`, with `466`
body/shape pairs. Exact app
[`111725`](../../evidence/first-playable/final-verification-2026-09-03-105408/)
passes the outside-project mounted-PCK audit and packaged headless smoke. Its
first retained Apple M2 native invocation timed out after
world/visual/movement readiness, while the byte-identical immediate warm-state
rerun passed. This is technical arm64 verifier-host evidence, not ordinary
Apple M1 Pro owner play. The `231815` and `224622` packages are historical.

These automated checks do not establish ground-level visual quality, owner recognition of Treasure Island, or owner acceptance of the exported app. Those checks belong to [`PLAYTEST.md`](../../PLAYTEST.md).

This README was reconciled after candidate `111725` was exported and is not
claimed to be byte-identical to the copy in the frozen 496-file source
inventory. The exact old/new README hashes and sizes, plus the verified
byte-identical comparison for the other 495 scoped source/config/generated
files, are retained in that candidate's final-verification evidence.

## Automated continuous route QA

The normal headless command above is the fast, pixel-free route gate. On the pinned world it covers a `264.122 m` centerline and, with the current tuning, travels `262.349 m` in about `18.1 s` wall time in the retained [normal-route log](../../evidence/first-playable/final-verification-2026-09-03-105408/logs/42_normal_route_after_export_guard.log). It reports actual distance, elapsed time, walk/run physics frames, checkpoint errors, airborne frames, recoveries, stalls, and final position before self-quitting. It exercises the real `PlayerController`; there are no between-checkpoint teleports or test-only movement calls. On the final approach it releases Shift at the slowdown distance derived from the live run, walk, and acceleration values, then releases movement and proves the real braking response can settle near the destination.

For one bounded whole-island traversal from that same ferry start, add `-- --whole-island-route`. The mode retains the road-following southern leg, then uses the existing unlimited jetpack to cross the long regional gaps and lands on generated ground at southwest, center, north, and east perimeter. It advances the test clock at `8x` with `480` physics ticks per second, preserving a `1/60 s` controller/physics step while leaving all player speeds unchanged. The current headless result traveled `3,449.107 m` in about `52.2 s` wall time (`415.817 s` simulated) in the retained [whole-island route log](../../evidence/first-playable/final-verification-2026-09-03-105408/logs/43_whole_island_route_after_export_guard.log), exercised walk/run/jetpack input, landed in all five regions, and recorded a maximum one-frame move of `0.348 m`, zero recoveries, zero boundary escapes, zero stalls, and no post-start transform writes. The `0.36 m` plausibility cap covers the exact vector length of `20 m/s` horizontal movement plus the unchanged `5 m/s` ascent at 60 Hz with a small physics tolerance.

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
APP_BINARY="build/final-verification-staging-2026-09-03-111725/Treasure Island First Playable.app/Contents/MacOS/Treasure Island First Playable"
"$APP_BINARY" --headless -- --mac-export-smoke
"$APP_BINARY" --max-fps 60 --rendering-method forward_plus --rendering-driver metal -- --mac-export-smoke
```

The smoke validates the exact foot-level ferry spawn/yaw plus packaged content
hash/counts, grounded player-enable gate, exact `4/20 m/s` movement and
`30/40 m/s²` response defaults, ambient/camera defaults, and all eleven live
Poly Haven texture identities/effective repeats/filtering/normals, then scripts
a held-Space ascent and released slow descent before exiting. It prints
`MAC_EXPORT_VISUAL`, `MAC_EXPORT_MOVEMENT`, and `MAC_EXPORT_JETPACK`
metrics and fails if all checks do not finish within 60 seconds of simulation
time. The `semantic_palette` metric name is retained for log compatibility,
but it now reports the semantic-material contract rather than the superseded
flat-color palette. Use explicit `--max-fps 60` for deterministic
non-headless Metal/Forward+ smoke. On exact candidate `111725`, the packaged
headless command passed in 8 seconds. The first retained capped Apple M2 Metal
run reached exact world, visual, and movement readiness but hit
`MAC_EXPORT_SMOKE_TIMEOUT` before jetpack after 42 wall seconds; it is a
non-pass diagnostic. The identical immediate warm-state rerun reached jetpack
rise `2.751 m`, descent `0.300 m`, and final `PASS` in 10 seconds. That
does not establish a cold-start pass, ordinary user input, or execution on the
Apple M1 Pro owner target. Smoke mode ignores focus-out so its physics gate
stays deterministic; normal gameplay still pauses on focus-out.

## Direct-mounted PCK content audit

`mounted_pck_content_audit.gd` is the project-owned replacement for the earlier disposable `/private/tmp` PCK auditors. Run it as an external script while the exact export PCK is mounted as `res://`; the script rejects a source-project fallback, missing or relative PCK paths, unknown/duplicate arguments, and any mismatch against independently recorded PCK, manifest, or generated-content SHA-256 values. Use the hashes from the candidate's immutable bundle inventory rather than copying values from the mounted package:

```sh
ROOT="$PWD"
GODOT="$ROOT/.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot"
PCK="$ROOT/build/UNUSED-UNIQUE-STAGING/Treasure Island First Playable.app/Contents/Resources/Treasure Island First Playable.pck"
AUDITOR="$ROOT/game/tests/mounted_pck_content_audit.gd"
(
  cd /private/tmp
  "$GODOT" --headless --main-pack "$PCK" --script "$AUDITOR" -- \
    --pck-audit-pck="$PCK" \
    --pck-audit-pck-sha256="<64-lowercase-hex-from-bundle-inventory>" \
    --pck-audit-manifest-sha256="e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3" \
    --pck-audit-content-sha256="01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
)
```

The outside-project working directory is mandatory: it prevents the source checkout's `project.godot` from remaining visible beside the mounted export and makes the auditor's `project.binary`-only boundary meaningful. The auditor does not internally prove that Godot's `--main-pack` operand is the same file as `--pck-audit-pck`; retain one shell `$PCK` variable and pass it to both operands exactly as shown so the mounted resource graph and raw-file identity cannot be accidentally split across artifacts.

The retained `startup-repair-staging-2026-08-31-190724` PCK is an expected negative fixture: from the mandatory outside-project working directory it fails with `PCK_AUDIT_FAIL [banned_path]` at `res://node_modules/earcut/package.json`. That result proves the reusable auditor catches the historical package leak; it is not an auditor implementation failure. A replacement export must exclude that path and pass against its own independently recorded hashes.

Exact candidate `111725` is that positive successor: its PCK SHA-256 is
`4d9e1d47f8777dbe2d7ca57f9a93d840a708dfcc35c18e99e54a77c36eeb266e`;
the outside-project invocation passes it as the single retained `$PCK` value
to both operands and exits `0`. The full command and output are retained in
the current final-verification evidence.

The direct-mount audit verifies the explicitly named PCK's hash; exported-project boundary; configured virtual-path exclusions and literal private-source fragments in the raw container bytes; every manifest-indexed generated file's byte count and SHA-256 after mounted access; the canonical `path\0sha256\0bytes\n` content identity; the exact generated file set; frozen coverage/spawn/chunk counts; vegetation and pavement semantics; all 18 Poly Haven maps; active skyline, bridge, and tag resources; packaged player movement values; and physical Space. The raw privacy scan does not claim a decompressed scan of every packaged resource; decompressed/hash/parse coverage is explicit for the manifest-indexed generated files and the separately checked resource graph. The auditor emits `PCK_CONTENT_AUDIT` plus `PASS` and exits `0`, or one `PCK_AUDIT_FAIL [code]` and exits nonzero. This is a static package-content/resource-graph gate; it does not replace packaged-main-scene smoke, native rendering, autonomous input review, or owner acceptance.

## Reproducible rendered-view capture

`rendered_visual_evidence_capture.gd` is an isolated source-project capture harness. It does not change the normal main scene or gameplay path. It loads the real fail-closed world; validates the exact content/manifest/ferry transform, terrain anchors, vegetation counts, the live corrected palm-material inventory (`7` batches / `8` surfaces, all non-metallic and high-roughness with `5` two-sided foliage surfaces), generated record-owned topology (`729 meshes / 739 surfaces / 48,389 triangles`), and exact-current total runtime topology (`1,278 meshes / 1,288 surfaces / 55,067 triangles`); and writes exactly twelve ordered native-renderer PNGs. The set covers ferry, north, center, southwest, east shoreline, the accepted Building 1 public curve, SF horizon, YBI/bridge, an eligible-wall tag, south vegetation ground, and one time-connected jetpack ascent/released-descent pair. Regional visual targets are capture-only ordinary-play reframes; the shared traversal-anchor source remains unchanged. Every static scenario discloses its fixed reset and is marked `movement_proof: false`; it must not be cited as traversal evidence. For grounded resets the harness spawns the real player above generated terrain, clears input, runs real physics until grounded with measured clearance, and only then disables gameplay for deterministic rendering.

Only `11-jetpack-ascent` and `12-jetpack-released-descent` are movement-proof frames. After the player settles at the fixed ferry anchor, the harness establishes the camera pose, enables the real `PlayerController`, and drives the public `jetpack` action through `Input`; it performs no player transform writes after input begins. After release it waits through the real transition and capped descent until frame `12` is at least `1.0 m` lower than frame `11`, while still airborne at the configured `-1.5 m/s` cap. The manifest records pressed/released input state, time-connected positions and physics frames, measured rise/drop and vertical velocity, recovery delta, motion samples, and the zero post-input-transform-write invariant. It also refuses to save any frame while the tree or Pause HUD is paused.

On this macOS Godot build, `--headless` selects a dummy renderer and cannot produce truthful screenshots. Run the bounded harness with the normal Forward+/Metal renderer:

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot \
  --path . \
  --max-fps 60 \
  --display-driver macos \
  --rendering-method forward_plus \
  --rendering-driver metal \
  --audio-driver Dummy \
  --resolution 1440x900 \
  --script game/tests/rendered_visual_evidence_capture.gd \
  -- --visual-evidence-output=evidence/first-playable/exact-current-visual-repair-YYYY-MM-DD-HHMMSS
```

The output argument is mandatory and must identify a directory that does not
yet exist; the harness refuses overwrite. It writes twelve original
`1440x900` PNGs plus `capture-manifest.json`, prints one
`VISUAL_CAPTURE` line per image and a final `PASS`, rejects
blank/wrong-sized/paused/invalid-grounding images, validates the exact ordered
IDs, palm materials, named-receiver sightlines, tag identity, context
projection/occlusion, and jetpack motion invariants, and self-terminates within
a conservative 180-second watchdog. The manifest binds the evidence to the
source-project file hashes actually executed and explicitly makes no
exported-package claim. The current objective capture is
[`exact-current-visual-repair-2026-09-03-104510/`](../../evidence/first-playable/exact-current-visual-repair-2026-09-03-104510/);
its independent review is `PASS_WITH_LIMITATION` and advances it to full
verification while keeping owner recognition pending. The independently
reviewed
[`exact-current-visual-qa-2026-09-03-095709/`](../../evidence/first-playable/exact-current-visual-qa-2026-09-03-095709/)
is the pre-repair comparison set, and the retained August set in
[`textured-world-final-rendered-2026-08-28-223242/`](../../evidence/first-playable/textured-world-final-rendered-2026-08-28-223242/)
remains historical pre-exact-current coverage.

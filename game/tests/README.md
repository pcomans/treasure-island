# First-playable test suite

Run from the project root with the exact trusted, self-contained Godot binary recorded in [`INSTALL_LOG.md`](../../INSTALL_LOG.md):

```sh
GODOT=".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot"
"$GODOT" --version
node tools/build_facade_recognition_registry.mjs --check
node tools/test_facade_recognition_registry.mjs
node tools/test_facade_runtime_loader_contract.mjs
"$GODOT" --headless --editor --path . --quit
"$GODOT" --headless --path . --script game/tests/headless_startup_configuration_contract.gd
"$GODOT" --headless --path . --script game/tests/headless_scene_parse.gd
"$GODOT" --headless --path . --script game/tests/headless_gameplay_contract.gd
"$GODOT" --headless --path . --script game/tests/headless_world_material_contract.gd
"$GODOT" --headless --path . --script game/tests/validate_generated_world.gd
"$GODOT" --headless --path . --script game/tests/headless_building_1_hero_model_contract.gd
"$GODOT" --headless --path . --script game/tests/headless_facade_recognition_registry_contract.gd
"$GODOT" --headless --path . --script game/tests/headless_facade_runtime_registry_loader_contract.gd
"$GODOT" --headless --path . --script game/tests/headless_d1_b225_standalone_cladding_repair_v1_contract.gd
"$GODOT" --headless --path . --script game/tests/headless_d1_b225_standalone_cladding_repair_v1_evidence_contract.gd
"$GODOT" --headless --path . --script game/tests/headless_d1_b225_postpromotion_v8_contract.gd
"$GODOT" --headless --path . --script game/tests/full_runtime_integration.gd
"$GODOT" --headless --path . --script game/tests/automated_route_qa.gd
"$GODOT" --headless --path . --script game/tests/automated_route_qa.gd -- --whole-island-route
```

Expected Godot version: `4.7.2.stable.official.ed1daf0bf`. The first editor command refreshes the project-local import cache; it is not a gameplay or export test.

The same no-write B225 v8 bridge also has a native rendering gate. It opens only
the bounded contract process and self-terminates; it does not capture evidence or
launch ordinary gameplay:

```sh
"$GODOT" --path . --display-driver macos --rendering-method forward_plus \
  --rendering-driver metal --audio-driver Dummy \
  --script game/tests/headless_d1_b225_postpromotion_v8_contract.gd
```

## What each test covers

- `headless_startup_configuration_contract.gd` checks that `project.godot` selects the exact case-sensitive `Dummy` audio driver before `AudioServer` initialization, that Godot loads and initializes that driver in the focused process, that the packaged main-scene smoke oracle matches current B225-integrated `952 meshes / 967 surfaces / 67,716 triangles` runtime topology, and that the packaged facade registry is exact v8 at `8/213`.
- `headless_scene_parse.gd` parses all four owned gameplay scenes and their scripts without loading the generated island.
- `headless_gameplay_contract.gd` checks the input map including Space-bound jetpack lift; the exact `4 m/s` walk, `20 m/s` held-Shift run, `30 m/s²` acceleration, and `40 m/s²` braking defaults; unchanged jetpack defaults; absence of deferred vehicle behavior; boundary edge/hole cases; scene hierarchy; the exact SF billboard texture/hash/dimensions/transform/mesh/material/no-collision contract; physics/render layers; direct spring-arm camera child; and the 64-tag default.
- `headless_world_material_contract.gd` checks every textured semantic material key against its exact Poly Haven diffuse/OpenGL-normal/roughness paths, retained official source dimension, approved effective visual repeat, per-family subtle normal strength, generated runtime tangents, displacement opt-out, repeat mode, anisotropic mipmap filtering, and imported mipmaps.
- `validate_generated_world.gd` proves `FileAccess` can read through the intentional `generated/.gdignore` boundary, then enforces the fail-closed handoff: frozen OSM, USGS, and accepted NAIP input hashes, exact terrain dimensions/bounds/sample range/pins, artifact-index hash, exact `735 playable + 4 context` coverage, coherent-surface/foundation summaries, feature semantics, source references, boundary geometry, terrain-aware anchors, spawn containment, and the pinned `124`-placement vegetation seed/assets/order/counts/terrain support/no-YBI/overlay clearance. The independent Node validator additionally proves the `427`-source filled pavement base, exact OSM visual classification, pedestrian-within-base geometry, vehicle precedence, non-collision, `0.019–0.081 m` conformance envelope, unchanged collision hash, and all 17 paved parking sources; it also reconstructs every plant's serialized support triangle and checks each curated GLB.
- `headless_building_1_hero_model_contract.gd` proves that all four `r16681702`/`w1222720021` wall and roof records retain separate identity and exact source-plan geometry while their generic vertical placeholders are superseded. It pins `11` hero meshes, `9,379` triangles, four congruent collider owners, wall-only spray ownership, deterministic rebuilds, and physical ray hits on the exposed `2/3/4`-story and tower-platform surfaces. Independent receipts now accept the main building and tower as two catalog units; legacy adapter/config pending labels remain capture-time provenance.
- `headless_facade_recognition_registry_contract.gd` and `headless_facade_runtime_registry_loader_contract.gd` enforce the coordinated catalog/runtime v8, contracts/loader v7, compiler `1.7.0`, exact seven-active/sixteen-total/ten-ready adapter inventory, physical-unit rollup, package closure, mutation rejection, and B225-only current-topology ownership.
- `headless_d1_b225_standalone_cladding_repair_v1_contract.gd` keeps the reviewed standalone geometry and evidence assets byte-exact while proving that its factory, scene, config, and UV helper remain unwired. The production path is a distinct receiver-relative adapter that reuses only the approved material/texture; the old candidate seam remains test-only. Its companion evidence contract keeps the frozen capture/review claims separate from that current lifecycle bridge.
- `headless_d1_b225_postpromotion_v8_contract.gd` layers current v8 authority over immutable B225 v7 production evidence. It proves the exact one-unit `7/213 -> 8/213` transition, frozen manifest/tree/review hashes, unchanged reviewed config/adapter/geometry, fail-closed ordinary construction, current `735/952/967/67,716/466/466` topology, and B201's relabeled pre-B225 parity.
- `full_runtime_integration.gd` instantiates the real `game/scenes/main.tscn`, waits for `world_ready`, proves the player is grounded before its first visible frame, validates the pinned vehicle/pedestrian/paved tints plus all eleven live Poly Haven texture identities, official source dimensions, approved effective repeats, per-family subtle normals, and finite tangent arrays, validates `124` logical plants across `15` assets and `19` collision-free MultiMesh batches, checks foot clearance at first reveal and throughout walk/run, inspects every live generated mesh/collider/source identity and overlay shadow mode, exercises sustained jetpack rise, air control, capped slow descent/landing, camera clamping, spring-arm compression, manual/boundary recovery, spray placement/rejection, tag eviction, continued movement, and a failed reload that removes the world and disables the player.
- `automated_route_qa.gd` starts the real player at the exact ferry spawn and steers actual camera-relative inputs without changing the player transform after startup. Its default fast gate walks/runs the terrain-aware 14-checkpoint Waterfront Plaza, Treasure Island Road, and Trade Winds Avenue route. The optional `--whole-island-route` mode continues with real run/jetpack input, lands on generated terrain at the same southwest, center, north, and east-perimeter anchors used by rendered QA, and fails on boundary escape, recovery, stalled progress, implausible per-frame movement, missed landings, or excess duration.

The exact-current source round exits `0` for compiler, Node and Godot
registry/loader, startup, scene, input, material, generated, standalone lifecycle,
B225 v8 bridge, real full-runtime integration, both route modes, and source
main-scene smoke gates. It remains bound to content SHA-256
`01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`
and manifest SHA-256
`e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`.
The frozen generated topology remains
`729 meshes / 739 surfaces / 48,389 triangles`. Four Building 1/tower records
are intercepted at runtime, and the accepted congruent Building 3 and paired
Navy Chapel replacements leave the pre-B201 active record-root nodes at `723 / 732 / 48,739`.
The accepted Building 1/tower hero contributes `13 / 13 / 10,711`, and the accepted Isle
House Variant C overlay contributes `7 / 11 / 2,242` without decorative
collision. The accepted Navy Chapel descendant hero contributes `6 / 6 / 540`
while replacing the same two structural owners. The B201 host partition adds
one record-root surface and its render-only attachment contributes
`6 / 6 / 2,064`. B225 adds one further host-partition surface plus two
render-only meshes/surfaces and `1,080` triangles. Exact-current record-root
topology is therefore `723 / 734 / 48,739`, while all `735` playable rows load
as `952 meshes / 967 surfaces / 67,716 triangles`, with `466` body/shape pairs.

The current postexport private handoff is
`build/d1-b225-postpromotion-v8-2026-09-05-001/Treasure Island First Playable.app`.
Its seven-file bundle identity is
`3f38c5dcd55b19f12cf7788e1069367075aa22f1b557c5b61288abdfdc30afe0`;
its PCK is
`7315bba99efeeeb86be0bbf44876d391b9c1c95f1638318e0df2b7af367669bf`
(`66,073,188` bytes). The source and mounted v8 package contracts, generic
mounted audit, packaged headless smoke, and bounded Apple M2 Metal smoke pass.
The 37-file packet and both independent release reviews also pass with no
additional recognition credit. This remains technical verifier-host evidence,
not ordinary Apple M1 Pro owner play or owner acceptance.

Retained app `024605` is the historical B201/v7 positive package fixture, not a
B225 v8 artifact. It contains the preceding `735/950/964/66,636/466/466`
runtime and has PCK SHA-256
`3425018ee32f645c3bf157deb9f9a548efe3c9e0bca1e40fd588318aa31f54d6`.
The `111725`, `231815`, and `224622` packages are also historical.

The current facade authority is compiler `1.7.0`, catalog/runtime registry v8,
and contracts/loader v7. It contains seven active adapters, sixteen total plans,
ten package-safe ready plans, and exact recognition `8/213`. Every active
adapter's review status is scoped only to runtime-asset original-detail
provenance; recognition acceptance derives from
the mapped physical unit's accepted claim plus an independent receipt. Isle
House and Navy Chapel preserve their shared `735/944/957/64,572/466/466`
snapshot under `pre_b201_integration_live_parity`; B201 preserves
`735/950/964/66,636/466/466` under `pre_b225_integration_live_parity`; only
B225's `735/952/967/67,716/466/466` contract uses
`current_integration_topology`. Node and Godot mutation suites reject missing,
wrong, extra, or multiply owned current-topology scope data on both generated
registry and plan surfaces.

The three `headless_d1_b201_live_attachment_*` validators are immutable B201
v7 evidence/package validators recorded in the B201 checksum ledger; their
then-current `7/213` and topology language is historical and they are not
current-source v8 gates. Likewise,
`headless_d1_b225_live_attachment_contract.gd` is the frozen prepromotion
candidate validator, while `headless_d1_b225_production_attachment_contract.gd`,
`headless_d1_b225_production_attachment_package_contract.gd`, and
`d1_b225_production_attachment_capture.gd` are frozen production-staging v7
validators/generator. Do not rewrite, repin, or rerun them as current authority;
use `headless_d1_b225_postpromotion_v8_contract.gd` for the acyclic current
bridge.

These automated checks do not establish ground-level visual quality, owner recognition of Treasure Island, or owner acceptance of the exported app. Those checks belong to [`PLAYTEST.md`](../../PLAYTEST.md).

The retained post-sanitization review binds an immutable 496-file review-time
snapshot, not live HEAD. In that dated snapshot this README had SHA-256
`9ebec1bc5b725b698897cb83dfb5509e48bb51dd5a122042e53df8ea7d1ca8e2`
at 18,503 bytes and the complete inventory had SHA-256
`6fa2989e4a7a9c9fc93f6cf519e67731088ff875c545592da6d68c14e576d98c`.
Later edits to this README are documentation-only and intentionally unbound by
that sealed snapshot. See the [first-playable evidence index](../../evidence/first-playable/README.md)
for the separate live-HEAD source binding.

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
APP_BINARY="build/d1-b225-postpromotion-v8-2026-09-05-001/Treasure Island First Playable.app/Contents/MacOS/Treasure Island First Playable"
"$APP_BINARY" --headless -- --mac-export-smoke
"$APP_BINARY" --max-fps 60 --rendering-method forward_plus --rendering-driver metal -- --mac-export-smoke
```

The smoke validates the exact foot-level ferry spawn/yaw plus packaged content
hash/counts, grounded player-enable gate, exact `4/20 m/s` movement and
`30/40 m/s²` response defaults, ambient/camera defaults, and all eleven live
Poly Haven texture identities/effective repeats/filtering/normals, then scripts
a held-Space ascent and released slow descent before exiting. It prints
`MAC_EXPORT_VISUAL`, `MAC_EXPORT_MOVEMENT`, and `MAC_EXPORT_JETPACK`
metrics and fails if all checks do not finish within 60 seconds of monotonic
wall time. The `semantic_palette` metric name is retained for log compatibility,
but it now reports the semantic-material contract rather than the superseded
flat-color palette. Use explicit `--max-fps 60` for deterministic
non-headless Metal/Forward+ smoke. On exact current B225 v8 candidate suffix
`001`, both the packaged headless run and bounded Apple M2 Metal run reached jetpack rise
`2.751 m`, descent `0.300 m`, and final `PASS`. The withdrawn pre-scope
candidate `002922` first-Metal timeout remains a non-authoritative diagnostic.
That does not establish ordinary user input or execution on the
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

For the current B225 v8 package, the target-specific mounted contract also runs
outside the source checkout and binds the same exact PCK operand and hash:

```sh
ROOT="$PWD"
GODOT="$ROOT/.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot"
PCK="$ROOT/build/d1-b225-postpromotion-v8-2026-09-05-001/Treasure Island First Playable.app/Contents/Resources/Treasure Island First Playable.pck"
PCK_SHA256="7315bba99efeeeb86be0bbf44876d391b9c1c95f1638318e0df2b7af367669bf"
(
  cd /private/tmp
  "$GODOT" --headless --main-pack "$PCK" \
    --script res://game/tests/headless_d1_b225_postpromotion_v8_package_contract.gd -- \
    --mounted-b225-v8-pck="$PCK" --mounted-b225-v8-pck-sha256="$PCK_SHA256"
)
```

For retained B201/v7 package `024605` only, the two historical target-specific
compiled auditors use the same mounted PCK and independently computed hash:

```sh
ROOT="$PWD"
GODOT="$ROOT/.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot"
PCK="$ROOT/build/b201-promotion-staging-2026-09-05-024605/Treasure Island First Playable.app/Contents/Resources/Treasure Island First Playable.pck"
PCK_SHA256="<64-lowercase-hex-from-bundle-inventory>"
(
  cd /private/tmp
  "$GODOT" --headless --main-pack "$PCK" \
    --script res://game/tests/headless_d1_b201_live_attachment_package_contract.gd -- \
    --mounted-b201-pck="$PCK" --mounted-b201-pck-sha256="$PCK_SHA256"
  "$GODOT" --headless --main-pack "$PCK" \
    --script res://game/tests/headless_building_1_registry_closure_mounted_contract.gd -- \
    --mounted-b1-pck="$PCK" --mounted-b1-pck-sha256="$PCK_SHA256"
)
```

For those frozen package bytes, the mounted B201 half proves the explicit PCK
identity, private exclusions, coordinated v7/v6 authority, exact eight-asset
registry/plan closure, and every remap-resolved executable/material resource;
the Building 1 half proves its matching v7 closure. Their source modes and
`950/964/66,636` smoke oracle are historical and must not be used against a B225
v8 export. The current v8 export has its fresh downstream package contract and
external receipt in the postpromotion packet. The editor-mounted/source distinction still prevents
private raw inputs or uncompiled `.tres` bytes from being misclassified.

The outside-project working directory is mandatory: it prevents the source checkout's `project.godot` from remaining visible beside the mounted export and makes the auditor's `project.binary`-only boundary meaningful. The auditor does not internally prove that Godot's `--main-pack` operand is the same file as `--pck-audit-pck`; retain one shell `$PCK` variable and pass it to both operands exactly as shown so the mounted resource graph and raw-file identity cannot be accidentally split across artifacts.

The retained `startup-repair-staging-2026-08-31-190724` PCK is an expected negative fixture: from the mandatory outside-project working directory it fails with `PCK_AUDIT_FAIL [banned_path]` at `res://node_modules/earcut/package.json`. That result proves the reusable auditor catches the historical package leak; it is not an auditor implementation failure. A replacement export must exclude that path and pass against its own independently recorded hashes.

Retained B201/v7 candidate `024605` is the historical positive package fixture;
it is not current B225 v8 source authority. Its PCK SHA-256 is
`3425018ee32f645c3bf157deb9f9a548efe3c9e0bca1e40fd588318aa31f54d6`;
the outside-project invocation passes it as the single retained `$PCK` value
to both operands and exits `0`. The full command and output are retained in
the B201 execution handoff; `014223` is withdrawn pre-final-evidence-bridge,
`002922` is withdrawn pre-scope, and `111725` remains historical
final-verification evidence.

The direct-mount audit verifies the explicitly named PCK's hash; exported-project boundary; configured virtual-path exclusions and literal private-source fragments in the raw container bytes; every manifest-indexed generated file's byte count and SHA-256 after mounted access; the canonical `path\0sha256\0bytes\n` content identity; the exact generated file set; frozen coverage/spawn/chunk counts; vegetation and pavement semantics; all 18 Poly Haven maps; active skyline, bridge, and tag resources; packaged player movement values; and physical Space. The raw privacy scan does not claim a decompressed scan of every packaged resource; decompressed/hash/parse coverage is explicit for the manifest-indexed generated files and the separately checked resource graph. The auditor emits `PCK_CONTENT_AUDIT` plus `PASS` and exits `0`, or one `PCK_AUDIT_FAIL [code]` and exits nonzero. This is a static package-content/resource-graph gate; it does not replace packaged-main-scene smoke, native rendering, autonomous input review, or owner acceptance.

## Reproducible rendered-view capture

`rendered_visual_evidence_capture.gd` is the frozen source-project harness for the earlier canonical 12-view capture-time world. It does not change the normal main scene or gameplay path. Its intentionally historical pins are active record-root topology (`723 meshes / 732 surfaces / 48,739 triangles`) and then-current total runtime topology (`735 playable rows / 944 meshes / 957 surfaces / 64,572 triangles / 466 bodies and shapes`); it must not be relabeled as a current-B201 capture gate. The retained set covers ferry, north, center, southwest, east shoreline, the Building 1 hero public curve, SF horizon, YBI/bridge, an eligible-wall tag, south vegetation ground, and one time-connected jetpack ascent/released-descent pair. Regional visual targets are capture-only ordinary-play reframes; the shared traversal-anchor source remains unchanged. Every static scenario discloses its fixed reset and is marked `movement_proof: false`; it must not be cited as traversal evidence.

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
exported-package claim. The historical pre-B201 objective capture is
[`exact-current-visual-repair-2026-09-03-104510/`](../../evidence/first-playable/exact-current-visual-repair-2026-09-03-104510/);
its independent review remains `PASS_WITH_LIMITATION` for those exact bytes
while keeping owner recognition pending. The independently
reviewed
[`exact-current-visual-qa-2026-09-03-095709/`](../../evidence/first-playable/exact-current-visual-qa-2026-09-03-095709/)
is the pre-repair comparison set, and the retained August set in
[`textured-world-final-rendered-2026-08-28-223242/`](../../evidence/first-playable/textured-world-final-rendered-2026-08-28-223242/)
remains historical pre-exact-current coverage.

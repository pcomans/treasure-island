# First-playable evidence index

Checked: 2026-09-03

This directory separates reproducible automated proof, native-launch proof, autonomous-review status, and owner feedback. Current source and packaged evidence are bound to generated content SHA-256 `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164` and manifest SHA-256 `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`. The active skyline is the single-color `2212x340` silhouette with SHA-256 `9c499ca3db08769142aac69b61e7d8fdf2aa84cd084b6716a19e7c504ba0b0c5`, on a `3900x600 m` billboard at `(-1875,264.85,4306.4)`. The sole current private handoff is `build/final-verification-staging-2026-09-03-111725/Treasure Island First Playable.app`; the `190724` startup-repair, `231815` car-speed, and `224622` textured-world apps are historical.

## Live HEAD source binding — 2026-09-03

The live scoped inventory retains the same 496 paths as the immutable
post-sanitization review-time snapshot. Exactly one row differs:
`game/tests/README.md` is now SHA-256
`0c15754b52a286a1a3f56fee62988594267236b3eb73e9c665306b0f5389ecd4`
at 19,029 bytes. The newly computed canonical
`path\0sha256\0bytes\n` identity over all 496 live rows is
`fa3b7479b7410e88180a6b4959c03adabf043792453d4332614e7d8914782c13`;
the same rows serialized in the sealed inventory's historical tab-delimited
TSV form hash to
`4b463d8dd42338193a12cced552f5298149f74090ec8fcb56fd7c17c6ee99c3f`.

Removing that documentation row leaves all other 495 rows byte-identical to
the retained snapshot. Their historical TSV aggregate remains
`dd70d46ce100951ac9ce7713bd771582dfe6787015b631cc12721b13f01fd0c0`;
their newly computed canonical NUL-delimited identity is
`7cb5cea8c3c9bc99f136dd2c9ae2c390f641c3c05667028f2f3239e0c59161bd`.
The words “current” and “current inventory” inside the dated sealed README and
post-sanitization review mean current at review time, when that complete TSV
inventory was `6fa2989e4a7a9c9fc93f6cf519e67731088ff875c545592da6d68c14e576d98c`
and the README row was `9ebec1bc5b725b698897cb83dfb5509e48bb51dd5a122042e53df8ea7d1ca8e2`
at 18,503 bytes. Later README edits are documentation-only and intentionally
unbound by that sealed snapshot. Product, project-configuration, generated,
source-asset, and exact candidate-app bytes are unchanged.

## Current result

- **Generated world: pass.** `739` unique OSM source rows resolve as `735` playable plus `4` context, with zero unresolved or duplicate rows across `38` chunks and `729` physical records. OSM remains authoritative for horizontal geometry; the frozen USGS crop supplies elevation.
- **Whole-island coverage evidence: pass.** The source polygon and playable derived edge coincide at 0.001 m precision. All `213` buildings have roof representation, both building parts have part roofs, all `427` roads/paths resolve to road geometry, and all `80` major areas have visible generated representation. Two clean renders are byte-identical.
- **USGS terrain source and derivation: pass.** The accepted `1669x2048` crop has `2,492,288` valid samples from `-1.080` to `104.756 m`; five in-bounds pins, exact source hash, bounds, locked raster ID, and 18 derived surface anchors are enforced. The rejected over-limit export is not retained. See [terrain provenance](../../data/terrain/README.md).
- **Coherent surfaces/foundations and pavement skin: pass.** Exact serialized land collision planes support every road/major-area/terrain-overlay triangle. The independent validator checked `206,339` road/area points and `14,904` exterior-foundation samples, with zero positive foundation gap, roof-flatness error, source-height deviation, or unsupported-water fallback segments. The visual-only pavement skin preserves all `208` vehicle-road sources plus `219` pedestrian sources without changing physical collision.
- **Ferry-arrival spawn: pass in current generated/runtime world.** The exact foot-level transform is `[-104.364, 3.457, 786.024]`, yaw `-0.119`; startup settles on collision while hidden and reveals only when grounded.
- **Audio-startup source repair: pass.** `project.godot` selects the exact case-sensitive `Dummy` driver before Godot initializes audio, which removes the affected CoreAudio startup dependency without removing any approved behavior because this milestone has no audio nodes, assets, or promise. The focused contract also pins the corrected package-smoke oracle at `1,278/1,288/55,067` meshes/surfaces/triangles.
- **Clean full-runtime headless suite: pass.** The real main scene loaded `38/38` chunks and `729` physical records, instantiated `1,278` meshes, `1,288` surfaces, `55,067` triangles, and `466` nonempty static body/shape pairs, revealed grounded at `0.000 m` clearance, kept walk/run clearance within `-0.002..+0.001 m`, landed/recovered at `0.000 m`, exercised camera, spray, tag eviction, and fail-closed reload behavior, then exited cleanly.
- **Deterministic visual-only vegetation: pass.** Seed `1414092337` produces `124` exactly grounded placements across all `15` curated Kenney GLBs in `19` MultiMesh batches, with zero added collision. The 102-placement procedural set is preserved and the 22 accepted NAIP shrub points are included with deterministic assets/transforms and no YBI placements. See [final rendered evidence](textured-world-final-rendered-2026-08-28-223242/README.md).
- **Semantic Poly Haven material contract: pass.** All 11 semantic material keys use their approved diffuse/OpenGL-normal/roughness identities and effective repeats, backed by 18 packaged 1K texture maps with repeat, anisotropic mipmaps, subtle normals, and displacement disabled.
- **Jetpack source runtime: pass.** Physical Space provides sustained capped ascent, walk/run steering remains active in air, release caps slow descent, a second mid-air press renews ascent, and the player lands without recovery. The strengthened source package-smoke path also exercises rise/release physics. See [jetpack evidence](jetpack/README.md).
- **Automated continuous route: pass across the whole island.** With the current movement tuning, the real player completed the `262.349 m` grounded ferry/road route and used real run/Space input to land at southwest, center, north, and east-perimeter anchors during a `3,449.107 m` whole-island route. Both recorded zero stalls, recoveries, boundary escapes, or post-start transform writes. The retained [coherent-surface route record](coherent-surface-route-2026-08-28-1458/README.md) remains historical geometry evidence from the earlier tuning.
- **Current exact-source visuals: pass with limitation.** The canonical `104510` set contains twelve ordered `1440×900` native Forward+/Metal source-project originals spanning ferry, north, center, southwest, east perimeter, Building 1, SF/YBI/bridge context, an eligible tag, south vegetation, and a time-connected public-input jetpack pair. Independent review advanced it to full verification while retaining sparse/generic massing, the cyan overlay edge, and owner-recognition limits. These are not package pixels. See [current visual evidence](exact-current-visual-repair-2026-09-03-104510/README.md) and its [independent review](exact-current-visual-repair-2026-09-03-104510/INDEPENDENT_REVIEW.md).
- **Superseded `095709` source-project visuals: historical point-in-time evidence.** Its internal README, manifest, and twelve PNG checksum entries remain byte-valid, but the ledger also pins the external capture harness as it existed before the later objective-ground-support repair. That one external entry now has expected current-tree drift; a whole-ledger check therefore reports exactly that mismatch. Do not rewrite or cite this superseded set as current—the canonical successor is `104510`.
- **Historical August source-project visuals: retained.** The older 13-frame textured-world set preserves its byte-specific material review, but it predates the exact-current facade/capture repair. See [historical rendered evidence](textured-world-final-rendered-2026-08-28-223242/README.md).
- **Current `111725` native export: technical pass with native-startup limitation.** The app has executable SHA-256 `49c7518acfb5443b0cee2f22d65a45405ab62c79a2112d7e770ca1c030eca594` (`170,963,648` bytes), PCK SHA-256 `4d9e1d47f8777dbe2d7ca57f9a93d840a708dfcc35c18e99e54a77c36eeb266e` (`55,816,660` bytes), and normalized seven-file inventory SHA-256 `7816c944b470a7542dea1030d9b09cd28c2ec25880fe5131f69bb60460089960` (`226,853,148` logical bytes). Export, raw PCK parsing, Universal architecture, strict deep/per-architecture signing, plist/privacy/xattr checks, outside-project mounted audit, and packaged headless smoke pass. The first retained Apple M2 native invocation timed out after world/visual/movement readiness; the identical warm-state rerun passed. Independent post-sanitization review cleared the publishable record as `PASS_WITH_LIMITATIONS`; owner/target/runtime limits remain. See [current package evidence](final-verification-2026-09-03-105408/README.md).
- **The `190724` startup-repair app is historical.** Its static checks and ordinary verifier-host window/render-loop observation remain valid for its own bytes. A later outside-project mounted audit intentionally retains its PCK as an expected `node_modules/earcut/package.json` banned-path negative. See [historical startup-repair evidence](startup-repair-mac-run-2026-08-31-190724/README.md).
- **The `231815` car-speed app is historical.** Its headless/capped-Metal packaged smokes and mounted-PCK audit remain valid for its own bytes, but it predates the final accepted facade attachment stack and the audio-startup repair. See [historical package evidence](car-speed-mac-run-2026-08-28-231815/README.md).
- **The `224622` app is historical.** It contains the same approved world and final textured presentation but predates the `20 m/s` Shift-run amendment, so it must not be used to judge current movement. See [historical pre-tuning package evidence](textured-world-final-mac-run-2026-08-28-224622/README.md).
- **The `224144` export is not current.** That earlier staging export failed only the stale, superseded flat-palette smoke assertion. It is retained only as historical diagnostic context and is not a handoff candidate.
- **Historical pre-placement evidence remains retained.** The preceding render and app use `1950x300 m` at `(-2500,132.5,750)` and are not current. See [historical render](owner-silhouette-rendered-2026-08-28-1921/README.md) and [historical package](owner-silhouette-mac-run-2026-08-28-192220/README.md).
- **Historical owner-outline evidence remains retained.** Its source Metal and private Mac package records remain valid only for the preceding outline and are not the current handoff. See [historical render](owner-skyline-rendered-2026-08-28-1900/README.md) and [historical package](owner-skyline-mac-run-2026-08-28-190242/README.md).
- **Owner acceptance of this exact app: pending.** Current source/static/package/deterministic-smoke evidence was produced on an Apple M2 verifier host, not the approved Apple M1 Pro owner target. Earlier owner feedback confirmed the island, ordinary tag placement, and held-Space jetpack behavior in prior builds. Ordinary mouse/keyboard play of exact candidate `111725` is still required, especially for Treasure Island recognition and fast-run/camera/jetpack/spray feel; source-project pixels and deterministic smokes do not substitute for that verdict.

The current package's headless and bounded Metal main-scene smokes are complete
with the first-in-sequence timeout/warm-pass limitation above. The required
acceptance step remains the ordinary play pass in
[`PLAYTEST.md`](../../PLAYTEST.md). Tight-gap camera polish and exhaustive
spray rejection/isolation remain optional unless that playtest reproduces a
blocker.

## Evidence files

- [`acceptance-audit.md`](acceptance-audit.md) — requirement-by-requirement verdict separating proven, incomplete, and owner-only acceptance items.
- [`exact-current-visual-repair-2026-09-03-104510/README.md`](exact-current-visual-repair-2026-09-03-104510/README.md) — canonical 12-view exact-source Metal/Forward+ set, hashes, physics/input evidence boundary, and independent `PASS_WITH_LIMITATION`.
- [`final-verification-2026-09-03-105408/README.md`](final-verification-2026-09-03-105408/README.md) — current `111725` package identity, source binding, complete source/package gates, first native timeout plus identical warm pass, and remaining owner/target/distribution gates.
- [`textured-world-final-rendered-2026-08-28-223242/README.md`](textured-world-final-rendered-2026-08-28-223242/README.md) — historical August 13-frame Metal/Forward+ art pass.
- [`startup-repair-mac-run-2026-08-31-190724/README.md`](startup-repair-mac-run-2026-08-31-190724/README.md) — historical repaired package identity, source/static and ordinary verifier-host launch proof, plus its later expected-negative PCK classification.
- [`car-speed-mac-run-2026-08-28-231815/README.md`](car-speed-mac-run-2026-08-28-231815/README.md) — historical pre-facade/pre-startup-repair package identity, mounted-PCK movement/world/privacy audit, packaged smokes, signatures, architecture, and plist facts.
- [`textured-world-final-mac-run-2026-08-28-224622/README.md`](textured-world-final-mac-run-2026-08-28-224622/README.md) — historical pre-tuning package identity and audit.
- [`spawn/README.md`](spawn/README.md) — frozen ferry source chain, projected coordinates, exact clearance proof, hashes, and clean follow-up test results.
- [`jetpack/README.md`](jetpack/README.md) — source input/controller behavior, live ascent/air-control/descent/landing metrics, and strengthened source package-smoke result.
- [`visual-qa/mac-run/README.md`](visual-qa/mac-run/README.md) — historical predecessor's full PCK inventory, visual/jetpack packaged smokes, architecture/signing/plist checks, and exact hashes.
- [`owner-bridge-connected-rendered-2026-08-28-1944-retry/README.md`](owner-bridge-connected-rendered-2026-08-28-1944-retry/README.md) — historical pre-texture bridge-connected skyline scale, placement, Metal frames, and exact hashes.
- [`owner-bridge-connected-mac-run-2026-08-28-194611/README.md`](owner-bridge-connected-mac-run-2026-08-28-194611/README.md) — historical pre-texture package identity and audit.
- [`owner-silhouette-mac-run-2026-08-28-192220/README.md`](owner-silhouette-mac-run-2026-08-28-192220/README.md) — historical pre-placement solid-silhouette package.
- [`jetpack/mac-run/README.md`](jetpack/mac-run/README.md) — historical pre-visual-refresh jetpack Mac app identity and package audit.
- [`automated-route/README.md`](automated-route/README.md) — frozen OSM route, continuous-controller method, exact headless metrics, retained output, and remaining geographic/visual limits.
- [`coherent-surface-route-2026-08-28-1458/README.md`](coherent-surface-route-2026-08-28-1458/README.md) — historical normal and whole-island route results for the unchanged geometry/controller.
- [`coherent-surface-rendered-2026-08-28-1458/README.md`](coherent-surface-rendered-2026-08-28-1458/README.md) — historical pre-texture grounded and owner-angle Metal/Forward+ frames.
- [`owner-skyline-rendered-2026-08-28-1900/README.md`](owner-skyline-rendered-2026-08-28-1900/README.md) — historical owner-outline scale, projected width, Metal frames, hashes, and context-isolation proof.
- [`vegetation-corrected-quick-rendered-2026-08-28-1556/README.md`](vegetation-corrected-quick-rendered-2026-08-28-1556/README.md) — historical 102-placement deterministic vegetation evidence.
- [`owner-skyline-mac-run-2026-08-28-190242/README.md`](owner-skyline-mac-run-2026-08-28-190242/README.md) — historical owner-outline app identity, exact hashes, owner-photo privacy audit, mounted-PCK inventory, signatures, and packaged-main-scene smoke.
- [`current-source-mac-run-2026-08-28-183204/README.md`](current-source-mac-run-2026-08-28-183204/README.md) — historical pre-skyline app identity and package proof.
- [`coherent-surface-coverage-2026-08-28-1458/README.md`](coherent-surface-coverage-2026-08-28-1458/README.md) — historical deterministic coverage render and validation outputs.
- [`coherent-surface-mac-run-2026-08-28-1500/README.md`](coherent-surface-mac-run-2026-08-28-1500/README.md) — historical pre-texture app identity and package audit.
- [`usgs-terrain-route-2026-08-28/README.md`](usgs-terrain-route-2026-08-28/README.md) — historical first terrain-aware route results.
- [`usgs-terrain-rendered-2026-08-28-1346/README.md`](usgs-terrain-rendered-2026-08-28-1346/README.md) — historical first USGS terrain/YBI/bridge frames and hashes.
- [`usgs-terrain-mac-run-2026-08-28-1400/README.md`](usgs-terrain-mac-run-2026-08-28-1400/README.md) — historical first USGS app identity and package results.
- [`rendered-runtime-grounded/README.md`](rendered-runtime-grounded/README.md) — eight corrected physics-grounded source-project frames, exact hashes, tag identity, context visibility, and explicit evidence limits.
- [`ybi-solid-rendered/README.md`](ybi-solid-rendered/README.md) — historical physics-grounded frames from the synthetic-YBI stage.
- [`spawn/mac-run/README.md`](spawn/mac-run/README.md) — historical ferry-only app identity, exact packaged manifest/spawn audit, signature checks, and headless startup.
- [`mac-run/README.md`](mac-run/README.md) — exact export command, build identity, artifact hashes, package audit, signing limits, and packaged launch results.
- [`coverage/whole-island-derived.png`](coverage/whole-island-derived.png) — clean north-up visual made from actual generated triangles.
- [`coverage/whole-island-diagnostic.svg`](coverage/whole-island-diagnostic.svg) — generated layers with the 256 m chunk grid.
- [`coverage/coverage-comparison-summary.json`](coverage/coverage-comparison-summary.json) — independent source-ledger, hash, physical-reference, category, context-isolation, and extent checks.
- [`coverage/determinism-report.json`](coverage/determinism-report.json) — two clean coverage renders compared byte-for-byte.
- [`runtime/headless-suite.log`](runtime/headless-suite.log) — sanitized exit codes and summaries for the complete four-test suite.
- [`runtime/full-runtime-headless.log`](runtime/full-runtime-headless.log) — raw sanitized full-runtime integration result.
- [`runtime/README.md`](runtime/README.md) — runtime measurements, corrections, and the precise proof boundary.

## Coverage totals

| Obligation | Count |
|---|---:|
| Unique source rows | 739 |
| Playable rows | 735 |
| Non-playable context rows | 4 |
| Land-boundary memberships | 1 |
| Terrain/shoreline memberships | 22 |
| Road/path memberships | 427 |
| Major-area memberships | 80 |
| Building memberships | 213 |
| Building-part memberships | 2 |
| Generated chunks | 38 |
| Physical records | 729 |
| Generated record-owned meshes / surfaces / triangles | 729 / 739 / 48,389 |
| Loaded total meshes / surfaces / triangles | 1,278 / 1,288 / 55,067 |
| Loaded static bodies / shapes | 466 / 466 |
| Collision-free vegetation instances / batches | 124 / 19 |
| Unresolved / duplicate source rows | 0 / 0 |

Membership categories overlap: ten playable rows belong to two categories, so the membership sum is not the unique-row total. The clean runtime reports `738` direct geometry source keys; the approved composite-only Isle House parent completes all `739` ledger obligations.

## Frozen source integrity

The manifest binds the world to the five existing OSM inputs plus the USGS terrain crop:

| Input | SHA-256 |
|---|---|
| Raw OSM snapshot | `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549` |
| Treasure Island extraction polygon | `43adbe335e87f0d839b56c2f5933ae97d35d4f588ce93bd09923a98620dd2b63` |
| Treasure Island proper PBF | `13984ed8f70c9d5d39d4ba14f83c7307eb75428af7b07df5774df29bda4ccaf9` |
| Source-ledger CSV | `fdf57f37f5507a7cb9b64a7fc530eabb22e29f3742324d5347c0f6b1949cb4cb` |
| Source-ledger summary | `49eb5c9fadd1b81b3fd687beb59cd9f917eb197069bcb993f5a0a3f2588d90d7` |
| USGS 3DEP TI+YBI crop | `3af54acdd116f3e253af8ece5ec501a08dff94cfca47b7f05f2c326c9ba33f3f` |

Acquisition, file roles, source counts, OpenStreetMap attribution, and ODbL terms are recorded in [`data/osm/README.md`](../../data/osm/README.md). USGS acquisition, datum, crop request, integrity pins, and public-domain status are in [`data/terrain/README.md`](../../data/terrain/README.md).

## Reproduce

From the project root:

```sh
node tools/validate_godot_world.mjs generated/world
node tools/check_godot_world_determinism.mjs
node tools/render_world_coverage_evidence.mjs --validate-only evidence/first-playable/coherent-surface-coverage-2026-08-28-1458

GODOT=".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot"
"$GODOT" --headless --path . --script game/tests/headless_startup_configuration_contract.gd
"$GODOT" --headless --path . --script game/tests/headless_scene_parse.gd
"$GODOT" --headless --path . --script game/tests/headless_gameplay_contract.gd
"$GODOT" --headless --path . --script game/tests/headless_world_material_contract.gd
"$GODOT" --headless --path . --script game/tests/validate_generated_world.gd
"$GODOT" --headless --path . --script game/tests/full_runtime_integration.gd
"$GODOT" --headless --path . --script game/tests/automated_route_qa.gd
"$GODOT" --headless --path . -- --mac-export-smoke

APP_BINARY="build/final-verification-staging-2026-09-03-111725/Treasure Island First Playable.app/Contents/MacOS/Treasure Island First Playable"
"$APP_BINARY" --headless -- --mac-export-smoke
"$APP_BINARY" --max-fps 60 --rendering-method forward_plus --rendering-driver metal -- --mac-export-smoke
```

The source command above passed. The exact `111725` headless package command
passed; the first retained bounded Metal invocation reached
world/visual/movement readiness and timed out before jetpack, while its
identical immediate warm-state rerun passed. Regeneration and export commands
are kept in the root [`README.md`](../../README.md). The owner's remaining
ground-level Apple M1 Pro acceptance pass is in
[`PLAYTEST.md`](../../PLAYTEST.md).

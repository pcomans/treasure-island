# Treasure Island First Playable

This private hobby game is now an implemented Godot 4.7.2/GDScript first-playable candidate for Apple-silicon macOS. It builds the complete approved Treasure Island exterior from the frozen OpenStreetMap snapshot, adds sparse deterministic premade vegetation, and supports third-person walking, fast running, endless jetpack lift, recovery, and one predefined spray tag on eligible exterior building walls. Walking remains `4 m/s`; held-Shift running now reaches `20 m/s` (about 45 mph) through the existing character controller. Cars, interiors, missions, NPCs, multiplayer, and public distribution are not part of this milestone.

## Resume on a new machine

This repository root is the Godot project root. Accepted work is on `main`; paused, unreviewed `r133351` work is preserved separately on `codex/r133351-paused-wip` and is not part of accepted `main`.

```sh
git clone https://github.com/pcomans/treasure-island.git
cd treasure-island
git switch main
git status --short --branch
```

Before restoring tools or opening Godot, read [AGENTS.md](AGENTS.md) and the [machine-migration handoff](discovery/MACHINE_MIGRATION_HANDOFF_2026-08-30.md). The handoff records the exact accepted Building 1 state, vetted toolchain restoration, focused smoke commands, evidence caveats, and paused-branch resume gates. The canonical facade skill is project-local at [.agents/skills/building-texture/SKILL.md](.agents/skills/building-texture/SKILL.md).

Human-only follow-ups are kept in the [owner action queue](HUMAN.md); that
queue narrows external gates and never pauses safe independent work.

## Current local B225 v8 release closure — 2026-09-05

The sole current working-tree/local release-ready private handoff is
`build/d1-b225-postpromotion-v8-2026-09-05-001/Treasure Island First Playable.app`.
The B225 v8 source and evidence are not yet committed or pushed, and `build/`
is ignored; a clone of current `main` does not reproduce or transfer this app.
Its canonical seven-file bundle identity is
`3f38c5dcd55b19f12cf7788e1069367075aa22f1b557c5b61288abdfdc30afe0`;
its executable is
`c485010419591a9556e849e79755d7e816f840e31978c10b371be08a730e2d82`
(`170,963,648` bytes), and its PCK is
`7315bba99efeeeb86be0bbf44876d391b9c1c95f1638318e0df2b7af367669bf`
(`66,073,188` bytes).

Current authority is compiler `1.7.0`, catalog/runtime registry v8, adapter
contracts/loader v7, and exact recognition `8/213`. The loaded topology is
`735/952/967/67,716/466/466` rows/meshes/surfaces/triangles/bodies/shapes.
The [37-file postpromotion packet](evidence/first-playable/d1-b225-postpromotion-v8-2026-09-05/capture-manifest.json)
has canonical tree SHA-256
`7b0de99e6f4afe07b1767c522517ace3dc1729a3f82f4b9b95716de9483cbd84`.
Its independent [mechanical audit](evidence/reviews/d1-b225-postpromotion-v8-2026-09-05-INDEPENDENT_CONTRACT_AUDIT.md)
(`9c909d047786d4f7feab138b4d7c597bba1bac2adcf78cc8bcdfb568de0a0ec2`)
and [full-resolution visual review](evidence/reviews/d1-b225-postpromotion-v8-2026-09-05-INDEPENDENT_VISUAL_REVIEW.md)
(`881b04d696bfe842c39a220be5f4da3087f30d8ef8e9c0493c9c62067a826c99`)
both return `PASS_FOR_RELEASE_NO_ADDITIONAL_CREDIT`. Technical verification
was performed on an Apple M2; ordinary recognition and mouse/keyboard play on
the approved Apple M1 Pro owner target remain pending and are not implied by
either audit. Candidate `024605` and its B201/v7 measurements below are retained
as historical package context, not as the current handoff.

The generated-data and exact-current source-runtime gates pass with USGS 3DEP
bare-earth terrain on both islands, coherent terrain-following roads/areas,
terrain-reaching building foundations, exactly grounded visual-only
vegetation, a grounded first visible player frame, jetpack, eligible-wall tag,
imported western bridge, and continuous route coverage. The current source uses
the owner-photo-derived single-color San Francisco silhouette
`sf_skyline_owner_silhouette_final.png` (`2212x340`, SHA-256
`9c499ca3db08769142aac69b61e7d8fdf2aa84cd084b6716a19e7c504ba0b0c5`)
on a `3900x600 m` billboard at `(-1875,264.85,4306.4)`, 250 m beyond
the western bridge's San Francisco endpoint. The frozen generated artifacts
remain `729 meshes / 739 surfaces / 48,389 triangles`. At load, four Building 1
and tower placeholder records are intercepted before generic visual/collision
construction, leaving a `725 / 735 / 48,059` placeholder-free record baseline.
Building 3's accepted congruent arched wall/roof replacement raises the active
record-owned triangle total to `48,825` without changing mesh, surface, or body
counts. Navy Chapel's accepted paired wall/roof replacement then supersedes its
two generic record meshes, leaving the pre-B201 active record-root topology at
`723 / 732 / 48,739`; its descendant hero geometry owns `6 / 6 / 540` with the
same two structural owners. The accepted four-component Building 1/tower hero owns
`13 / 13 / 10,711`; the accepted Isle House Variant C overlay owns
`7 / 11 / 2,242` without decorative collision. B201 preserves its 80 host
triangles while splitting its host into one additional surface and adds
`6 / 6 / 2,064` render-only attachment geometry, leaving its stage's
record-root topology at `723 / 733 / 48,739`. With the unchanged other runtime
attachments and context, all `735` playable rows load as
`950 meshes / 964 surfaces / 66,636 triangles`, with `466` body/shape pairs at
the B201 stage. B225 then splits its physical host into one additional
record-root surface and adds `2 / 2 / 1,080` render-only
meshes/surfaces/triangles. Current record-root topology is therefore
`723 / 734 / 48,739`, while total loaded topology changes by
`2 / 3 / 1,080` to `952 / 967 / 67,716`; collider counts remain `466 / 466`.
The Isle House and Navy Chapel derived contracts preserve their shared
pre-B201 `735/944/957/64,572/466/466` live-parity snapshot under exact scope
`pre_b201_integration_live_parity`; B201 now retains
`pre_b225_integration_live_parity`, while B225 alone carries exact-current
`current_integration_topology`. These replacements are present in the current
B225 v8 app above.
Movement remains `4/20 m/s` with `30/40 m/s²` acceleration/braking.

The previous B201 private handoff was
`build/b201-promotion-staging-2026-09-05-024605/Treasure Island First Playable.app`;
the following B201 verification summary is retained as historical package
context.
Two complete B201-stage source matrices (35 valid fast/core gates plus four slow
end-to-end gates per round), two 28-contract evidence sweeps, three
outside-project mounted-PCK audits,
strict signing/architecture/privacy checks, packaged headless smoke, and the
first bounded Apple M2 Metal smoke all passed. The smoke watchdog measured
60 seconds of monotonic wall time, so accelerated headless scheduling cannot
consume it early. A no-argument ordinary launch also started the exact B201
app on the verifier host. The packaged-test predecessors `014223` and `002922`
are withdrawn and retained only as non-authoritative diagnostics. B201 has a separate independently accepted five-view
and continuous-motion evidence set; the `104510`, `111725`, `190724`, `231815`,
`224622`, and August 13-frame records are historical. Ordinary owner
recognition and mouse/keyboard play on the approved Apple M1 Pro remain pending.

## Play from the project

Run these commands from the project root. The executable below is the exact trusted, self-contained project-local Godot install recorded in [INSTALL_LOG.md](INSTALL_LOG.md):

```sh
GODOT=".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot"
"$GODOT" --version
"$GODOT" --path .
```

The expected version is `4.7.2.stable.official.ed1daf0bf`. The game validates and builds all 38 chunks before enabling the player; wait for the loading panel to disappear and the center reticle to appear.

## Controls

| Input | Action |
|---|---|
| `W`, `A`, `S`, `D` | Walk relative to the camera |
| Hold `Shift` | Fast run at up to `20 m/s` (about 45 mph) |
| Hold `Space` | Rise with the jetpack; release to float down slowly |
| Mouse | Orbit the third-person camera |
| Primary mouse click | Spray the center-reticle target; only an opaque exterior building wall within 6 m is eligible |
| `R` | Recover to the latest safe position |
| `Esc` | Pause or resume and release/capture the mouse |
| `F3` | Toggle runtime evidence/debug text |
| `Q` while paused | Quit |

The pause panel also provides Resume and Exit buttons. Tags are session-only; at 64 active tags, the oldest is removed.

Horizontal movement keeps the simple constant tuning: `4 m/s` walk, `20 m/s` held-Shift run, `30 m/s²` acceleration, and `40 m/s²` braking. From rest the fast run reaches its cap in about `0.67 s`; releasing movement stops it from the cap in about `0.5 s`. Releasing Shift while continuing to move eases back toward walking speed. Jetpack tuning and all bindings are unchanged.

The ground now uses a deterministic 32 m USGS 3DEP bare-earth mesh clipped to the frozen OSM shorelines. Its serialized collision triangles are the single height authority for roads and public-space overlays. Buildings retain flat base/roof references and source heights while their exterior wall foundations split at terrain-triangle crossings and extend into the exact land surface. Treasure Island is playable/colliding while YBI remains non-playable and non-colliding. OSM is still authoritative for all horizontal geometry and the complete `739`-row inventory. Exact raster provenance, integrity pins, and sparse-tile handling are in [data/terrain/README.md](data/terrain/README.md).

The visual-only pavement skin keeps one filled union for all `427` OSM road/path sources, then overlays the `219` footway/path-like sources after subtracting the `208` vehicle-road sources at crossings. Seventeen `amenity=parking` polygons use a separate paved-area material key. The live eleven-key semantic material set is backed by six restrained Poly Haven CC0 families and 18 packaged 1K albedo, normal, and roughness maps: asphalt for vehicle roads, concrete for pedestrian and paved areas, sparse grass for land, plaster for walls, and bitumen for roofs. Collision, terrain, foundations, and source footprints are unchanged by this visual pass.

`generated/world/vegetation.json` deterministically places `124` premade Kenney Nature Kit instances with seed `1414092337`: `13` palms, `21` ornamental grasses, `41` shrubs, `28` broadleaf trees, and `21` conifers. The procedural 102-placement pass is unchanged; all `22` accepted NAIP `unknown` crown centers now add fixed-location shrubs whose approved asset, yaw, and scale derive only from the seed plus annotation ID. Every origin names its exact serialized land triangle/elevation. The annotation row retains shoreline, overlay, ferry, and QA-route buffers and has zero actual road/building overlap; its fixed source points use a documented 1 mm surface-exterior test instead of the procedural 4–5 m aesthetic buffer. YBI receives zero vegetation. Runtime rendering uses `19` shared-asset MultiMesh batches and adds no collision.

## Verified whole-island handoff

- Generated content SHA-256: `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`.
- Manifest file SHA-256: `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`.
- Vegetation file SHA-256: `e843ac78c4f5ba769241f330f83b41fd8431fbe06073c9ffd4907c413baad32f`.
- Initial spawn: the frozen OSM ferry arrival at foot-level local world `[-104.364, 3.457, 786.024]`, yaw `-0.119` radians toward the island interior. The hidden startup settles on collision before the player is revealed.
- `739` unique source rows: `735` playable and `4` non-playable context, with zero unresolved or duplicate rows.
- Overlapping playable memberships: `1` land boundary, `22` terrain/shoreline, `427` roads/paths, `80` major areas, `213` buildings, and `2` building parts.
- `38` generated chunks and `729` physical records for all `735` playable rows.
  Their frozen serialized
  topology remains `729 meshes / 739 surfaces / 48,389 triangles`. The B201-stage
  runtime used `723 / 733 / 48,739` record-root topology after intercepting the four
  Building 1/tower records, replacing the Building 3 and Navy Chapel wall/roof pairs,
  and partitioning the retained B201 host into two surfaces; the
  accepted Building 1/tower replacement owns `13 / 13 / 10,711` and four
  congruent body/shape pairs, while the accepted Isle House Variant C overlay
  owns `7 / 11 / 2,242` and no decorative collision. The accepted Navy Chapel
  hero owns `6 / 6 / 540` and replaces, rather than duplicates, two structural
  owners. The accepted B201 attachment owns `6 / 6 / 2,064` render-only
  geometry while its retained host remains the sole collider and spray owner.
  B225 retains those structural owners, splits its physical host into one
  additional record-root surface, and adds only its reviewed render attachment.
  The exact-current loaded source project instantiates `952`
  meshes, `967` surfaces, `67,716` triangles,
  and `466` nonempty static body/shape pairs. The additional `28`
  records are visual-only pedestrian pavement skins. Other facade attachments
  and pavement skins do not change physical collision. YBI, both bridges, and
  the SF billboard remain context-only and non-colliding.
- Vegetation stays outside the fixed OSM denominator/record counts: `124` logical instances, all `15` curated GLBs, `19` MultiMesh batches, `20,178` instanced source triangles, and zero added bodies/shapes. The unchanged procedural set retains minimum clearances of `4.017 m` from roads, `7.274 m` from buildings, `3.625 m` from terrain/shoreline overlays, and `25.517 m` from the shoreline edge. The fixed NAIP shrub row's minima are `0.102 m`, `1.109 m`, `14.450 m`, and `19.267 m` respectively, with all 22 points outside the actual road/building polygons and zero rejections.
- The independent Node audit checks `206,339` road/area sample points against exact land planes and `14,904` exterior-foundation samples; maximum positive foundation gap, roof flatness error, and source-height deviation are all `0`. The runtime's first visible player clearance is `0.000 m`; walk/run stays within `-0.002..+0.001 m`, and jetpack landing/recovery clearance is `0.000 m`.
- The standalone automated route drove the real player continuously from the ferry through Waterfront Plaza and along Trade Winds Avenue with the current movement tuning: `262.349 m` traveled across 14 terrain-aware checkpoints in about `18.1 s` wall time, with walk/run input, continuous grounding, and zero stalls, recoveries, boundary escapes, or discontinuities; see the retained [normal-route log](evidence/first-playable/final-verification-2026-09-03-105408/logs/42_normal_route_after_export_guard.log).
- Its bounded whole-island mode traveled `3,449.107 m` in about `52.2 s` wall time (`415.817 s` simulated), completed all five landings, stayed below a `0.348 m` maximum physics-tick step, and had zero stalls, recoveries, boundary escapes, or post-start transform writes; see the retained [whole-island route log](evidence/first-playable/final-verification-2026-09-03-105408/logs/43_whole_island_route_after_export_guard.log). The retained [coherent-surface route evidence](evidence/first-playable/coherent-surface-route-2026-08-28-1458/README.md) remains historical geometry evidence from the earlier movement tuning.
- The historical pre-B201 `1440×900` 12-view Forward+/Metal set covers
  ferry, north, center, southwest, east perimeter, Building 1,
  SF/YBI/bridge context, an eligible-wall tag, south vegetation, and a
  time-connected public-input jetpack ascent/descent pair. Independent review
  returned `PASS_WITH_LIMITATION`; it remains byte-valid source-project evidence
  for its own prior topology and does not establish current package pixels or
  owner recognition. Exact hashes and the proof boundary are in
  [the 104510 visual evidence](evidence/first-playable/exact-current-visual-repair-2026-09-03-104510/README.md).
  The August 13-frame textured-world set is historical for the later exact
  source.

See [the first-playable evidence index](evidence/first-playable/README.md) for the precise proof boundary and [the current coverage view](evidence/first-playable/coherent-surface-coverage-2026-08-28-1458/whole-island-derived.png).

## Regenerate and validate

The immutable OSM snapshot remains authoritative for horizontal geometry, while the pinned USGS crop is authoritative for bare-earth elevation. Source hashes and acquisition details are in [data/osm/README.md](data/osm/README.md) and [data/terrain/README.md](data/terrain/README.md). The commands below require Node `v26.7.0`, Osmium `1.19.1`, and dependencies restored from the committed lockfile.

```sh
npm ci --ignore-scripts --registry=https://registry.npmjs.org/ --cache=.tools/npm-cache
node tools/build_source_inventory.mjs
node tools/build_godot_world.mjs
node tools/validate_godot_world.mjs generated/world
node tools/check_godot_world_determinism.mjs
node tools/render_world_coverage_evidence.mjs
node tools/render_world_coverage_evidence.mjs --validate-only evidence/first-playable/coherent-surface-coverage-2026-08-28-1458
```

`build_source_inventory.mjs` rewrites only the derived source-ledger CSV and summary. `build_godot_world.mjs` atomically replaces `generated/world`, including canonical `vegetation.json`; the validator and two-clean-generation check compare that file byte-for-byte and should pass before running Godot. Re-rendering coverage atomically replaces the coverage evidence directory. Do not edit frozen source or generated world artifacts by hand.

The exact headless commands and their assertions are documented in [game/tests/README.md](game/tests/README.md).

## Export

The sole current private handoff is
`build/d1-b225-postpromotion-v8-2026-09-05-001/Treasure Island First Playable.app`.
It is the exact seven-file B225 v8 bundle identified by SHA-256
`3f38c5dcd55b19f12cf7788e1069367075aa22f1b557c5b61288abdfdc30afe0`.
Its executable is
`c485010419591a9556e849e79755d7e816f840e31978c10b371be08a730e2d82`
(`170,963,648` bytes), and its PCK is
`7315bba99efeeeb86be0bbf44876d391b9c1c95f1638318e0df2b7af367669bf`
(`66,073,188` bytes). The exact package, evidence, current authority, and two
independent no-additional-credit release receipts are bound in the
[mechanical audit](evidence/reviews/d1-b225-postpromotion-v8-2026-09-05-INDEPENDENT_CONTRACT_AUDIT.md)
and [visual review](evidence/reviews/d1-b225-postpromotion-v8-2026-09-05-INDEPENDENT_VISUAL_REVIEW.md).
This remains a private verifier-host technical release: Apple M2 verification
does not replace pending ordinary owner play on the approved Apple M1 Pro.

### Historical B201 package

The previous private handoff was
`build/b201-promotion-staging-2026-09-05-024605/Treasure Island First Playable.app`.
It was exported from the B201 promotion working tree after the deterministic
compiler and full source matrix passed. It contains
generated content SHA-256
`01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`,
manifest SHA-256
`e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`,
the generated `729/739/48,389`, runtime record-root `723/733/48,739`,
and loaded `950/964/66,636` topologies, B201-stage `7/213` recognition,
`4/20/30/40` movement defaults, all accepted facade attachments, and
project-level `Dummy` audio selection. Its executable SHA-256 is
`23f8f5cfda04749bb6e2b00659d5f9e46086c55c8dde0cc00d1b2f8b5235146c`
(`170,963,648` bytes); PCK SHA-256 is
`3425018ee32f645c3bf157deb9f9a548efe3c9e0bca1e40fd588318aa31f54d6`
(`65,708,948` bytes); canonical ASCII path-sorted seven-file inventory
SHA-256 is
`ef300ab3f97d077f3db61fad53094cbc3a540175e6475e549d5cd0a3ab9e8f98`
over `236,745,436` logical bytes. The persisted inventory artifacts are
`bundle-inventory.records` (the canonical identity above) and
`bundle-inventory.tsv` (SHA-256
`92ecdade90c53593dd68f9d19c28e99c56909d9ee794f4ee77164543115d7d69`).
The B201 source, capture, review, closure,
and checksum boundary is in
[the B201 evidence record](evidence/first-playable/d1-b201-live-attachment-2026-09-04/README.md).

The `111725` final-verification app is historical pre-B201/pre-current-hero
package evidence. Its exact hashes and limits remain valid only for its own
bytes in [the historical final-verification record](evidence/first-playable/final-verification-2026-09-03-105408/README.md).

The prior `190724` startup-repair app is historical. Its static and plain
native-launch observations remain valid for its own bytes, while its PCK is now
also an expected mounted-auditor `node_modules` negative; see
[the historical startup-repair record](evidence/first-playable/startup-repair-mac-run-2026-08-31-190724/README.md).
The `231815` car-speed package remains historical because it predates both
the accepted facade attachment stack and startup repair; its package-smoke and
mounted-PCK evidence remain valid only for its own bytes in
[the historical car-speed record](evidence/first-playable/car-speed-mac-run-2026-08-28-231815/README.md).
The still-earlier `224622` textured-world app is historical pre-tuning
evidence in [its Mac record](evidence/first-playable/textured-world-final-mac-run-2026-08-28-224622/README.md).

An earlier export in the `224144` staging directory failed only the superseded flat-palette smoke assertion. It is not current and must not be used for playtest or handoff.

### Current export procedure

Build another candidate with the approved `macOS Private` preset only when needed, always choosing a fresh unused staging directory rather than overwriting this handoff:

```sh
GODOT=".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot"
mkdir -p "build/final-verification-staging-YYYY-MM-DD-HHMMSS"
"$GODOT" --headless --path . --export-release "macOS Private" "build/final-verification-staging-YYYY-MM-DD-HHMMSS/Treasure Island First Playable.app"

APP_BINARY="build/final-verification-staging-YYYY-MM-DD-HHMMSS/Treasure Island First Playable.app/Contents/MacOS/Treasure Island First Playable"
"$APP_BINARY" --headless -- --mac-export-smoke
"$APP_BINARY" --max-fps 60 --rendering-method forward_plus --rendering-driver metal -- --mac-export-smoke
```

The packaged smoke starts the exported PCK's normal main scene and fails after
60 seconds of monotonic wall time if its checks do not finish. It exits nonzero if
the exact ferry spawn/yaw, approved hash, source-current `952/967/67,716`
topology, grounded player-enable gate, exact `4/20 m/s` speed and
`30/40 m/s²` response defaults, ambient/camera defaults, live eleven-key
Poly Haven texture identities/effective repeats/filtering/normals, Space-bound
jetpack rise, or capped slow descent drift. It retains the
`semantic_palette=pass` output field for log compatibility, but that field
now represents the current semantic-material contract rather than the
superseded flat-color palette. It prints separate `MAC_EXPORT_VISUAL`,
`MAC_EXPORT_MOVEMENT`, and `MAC_EXPORT_JETPACK` lines before passing.
Serialize resource-heavy Godot checks and use explicit `--max-fps 60` for
non-headless Metal/Forward+ smoke. For historical comparison, exact candidate
`024605` passed its first
packaged headless and first Apple M2 Metal invocations through world, visual,
movement, grounding, jetpack ascent, and capped descent. The earlier `014223`
package predates the final evidence-contract bridge repairs and is withdrawn;
the `002922` first-Metal timeout likewise remains a withdrawn pre-scope
diagnostic. Neither is evidence for the current B225 candidate.

Historical candidate `024605` passes strict deep and per-architecture ad-hoc
hardened-runtime signature verification and contains universal
`x86_64 arm64` slices. Only arm64 was exercised, on an Apple M2 verifier
host rather than the approved Apple M1 Pro target. The x86_64 slice is
statically present and strictly signed but unexecuted. The app is neither
Developer ID signed nor notarized, has no TeamIdentifier or entitlements,
requests no sensitive permissions in `Info.plist`, and is only for approved
private local use. A no-argument ordinary launch started these exact bytes on
the Apple M2 verifier host; that process observation is neither pixel review
nor owner play on the approved Apple M1 Pro.

Every active adapter's `review_status` is explicitly scoped only to original
runtime-asset detail provenance. Reference-recognition acceptance does not
derive from that field: it derives from the mapped physical unit's exact
`claim_status.reference_recognizable` value and an independent acceptance
receipt. The compiler, runtime loader, Node tests, Godot tests, and mounted B1,
B201, and B225 consumers fail closed on missing or contradictory scope, authority,
status, receipt, topology-scope, or exact asset-closure data.

An export or packaged smoke command succeeding is not owner acceptance. Check the precise exported-app proof in [the first-playable evidence index](evidence/first-playable/README.md), then follow [PLAYTEST.md](PLAYTEST.md).

## Project map and cleanup

- [Approved approach](discovery/APPROACH_PROPOSAL.md) and [decision log](discovery/DECISION_LOG.md)
- [Frozen OSM provenance and hashes](data/osm/README.md)
- [Frozen USGS terrain provenance and hashes](data/terrain/README.md)
- [Generated manifest](generated/world/manifest.json) and [coverage summary](generated/world/coverage-summary.json)
- [First-playable evidence](evidence/first-playable/README.md)
- [Current B225 postpromotion evidence](evidence/first-playable/d1-b225-postpromotion-v8-2026-09-05/capture-manifest.json)
- [Current B225 independent mechanical audit](evidence/reviews/d1-b225-postpromotion-v8-2026-09-05-INDEPENDENT_CONTRACT_AUDIT.md)
- [Current B225 independent visual review](evidence/reviews/d1-b225-postpromotion-v8-2026-09-05-INDEPENDENT_VISUAL_REVIEW.md)
- [Historical accepted B201 live evidence](evidence/first-playable/d1-b201-live-attachment-2026-09-04/README.md)
- [Historical pre-B201 exact-source 12-view evidence](evidence/first-playable/exact-current-visual-repair-2026-09-03-104510/README.md)
- [Historical pre-B201 final-verification Mac package evidence](evidence/first-playable/final-verification-2026-09-03-105408/README.md)
- [Jetpack source-runtime evidence](evidence/first-playable/jetpack/README.md)
- [Historical coherent-surface route evidence](evidence/first-playable/coherent-surface-route-2026-08-28-1458/README.md)
- [Historical August textured-world rendered evidence](evidence/first-playable/textured-world-final-rendered-2026-08-28-223242/README.md)
- [Historical startup-repair Mac export evidence](evidence/first-playable/startup-repair-mac-run-2026-08-31-190724/README.md)
- [Historical car-speed Mac export evidence](evidence/first-playable/car-speed-mac-run-2026-08-28-231815/README.md)
- [Historical pre-tuning textured-world Mac export evidence](evidence/first-playable/textured-world-final-mac-run-2026-08-28-224622/README.md)
- [Historical coherent-surface rendered evidence](evidence/first-playable/coherent-surface-rendered-2026-08-28-1458/README.md)
- [Historical bridge-connected skyline rendered evidence](evidence/first-playable/owner-bridge-connected-rendered-2026-08-28-1944-retry/README.md)
- [Historical bridge-connected Mac export evidence](evidence/first-playable/owner-bridge-connected-mac-run-2026-08-28-194611/README.md)
- [Historical pre-placement solid-silhouette rendered evidence](evidence/first-playable/owner-silhouette-rendered-2026-08-28-1921/README.md)
- [Historical owner-outline skyline rendered evidence](evidence/first-playable/owner-skyline-rendered-2026-08-28-1900/README.md)
- [Current corrected vegetation rendered evidence](evidence/first-playable/vegetation-corrected-quick-rendered-2026-08-28-1556/README.md)
- [Historical pre-placement solid-silhouette Mac export evidence](evidence/first-playable/owner-silhouette-mac-run-2026-08-28-192220/README.md)
- [Historical owner-outline Mac export evidence](evidence/first-playable/owner-skyline-mac-run-2026-08-28-190242/README.md)
- [Historical pre-skyline current-source Mac export evidence](evidence/first-playable/current-source-mac-run-2026-08-28-183204/README.md)
- [Historical pre-vegetation coherent-surface Mac export evidence](evidence/first-playable/coherent-surface-mac-run-2026-08-28-1500/README.md)
- [Historical full visual-QA Mac package audit](evidence/first-playable/visual-qa/mac-run/README.md)
- [Historical staged jetpack Mac export evidence](evidence/first-playable/jetpack/mac-run/README.md)
- [Historical ferry-only Mac export evidence](evidence/first-playable/spawn/mac-run/README.md)
- [Historical pre-ferry Mac export evidence](evidence/first-playable/mac-run/README.md)
- [Acceptance audit and remaining requirement gaps](evidence/first-playable/acceptance-audit.md)
- [Install provenance and narrow removal steps](INSTALL_LOG.md)

Disposable outputs have narrow boundaries: close the game/editor before cleanup; remove an exported app only from its exact staging path under `build/`; regenerate `generated/world` instead of hand-editing it; and use the reviewed Godot/npm removal procedures in [INSTALL_LOG.md](INSTALL_LOG.md). Do not delete the frozen `data/osm/` or `data/terrain/` inputs when cleaning build or tool output.

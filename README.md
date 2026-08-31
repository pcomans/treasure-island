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

The generated-data and clean source-runtime gates pass with USGS 3DEP bare-earth terrain on both islands, coherent terrain-following roads/areas, terrain-reaching building foundations, exactly grounded visual-only vegetation, a grounded first visible player frame, jetpack, eligible-wall tag, imported western bridge, and continuous route coverage. The current source uses the owner-photo-derived single-color San Francisco silhouette `sf_skyline_owner_silhouette_final.png` (`2212x340`, SHA-256 `9c499ca3db08769142aac69b61e7d8fdf2aa84cd084b6716a19e7c504ba0b0c5`) on a `3900x600 m` billboard at `(-1875,264.85,4306.4)`, 250 m beyond the western bridge's San Francisco endpoint. Focused contracts, full runtime, both continuous route modes, and the exact current package all pass with the `4/20 m/s` and `30/40 m/s²` movement defaults. The sole current private handoff is `build/car-speed-staging-2026-08-28-231815/Treasure Island First Playable.app`; the `224622` textured-world app is historical because it predates the movement amendment.

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
- `38` generated chunks and `729` physical records. The live runtime instantiates `729` meshes, `48,381` triangles, and `466` nonempty static collision shapes. The additional `28` records are visual-only pedestrian pavement skins; physical collision is unchanged. YBI, both bridges, and the SF billboard remain context-only and non-colliding.
- Vegetation stays outside the fixed OSM denominator/record counts: `124` logical instances, all `15` curated GLBs, `19` MultiMesh batches, `20,178` instanced source triangles, and zero added bodies/shapes. The unchanged procedural set retains minimum clearances of `4.017 m` from roads, `7.274 m` from buildings, `3.625 m` from terrain/shoreline overlays, and `25.517 m` from the shoreline edge. The fixed NAIP shrub row's minima are `0.102 m`, `1.109 m`, `14.450 m`, and `19.267 m` respectively, with all 22 points outside the actual road/building polygons and zero rejections.
- The independent Node audit checks `206,339` road/area sample points against exact land planes and `14,904` exterior-foundation samples; maximum positive foundation gap, roof flatness error, and source-height deviation are all `0`. The runtime's first visible player clearance is `0.000 m`; walk/run stays within `-0.002..+0.001 m`, and jetpack landing/recovery clearance is `0.000 m`.
- The standalone automated route drove the real player continuously from the ferry through Waterfront Plaza and along Trade Winds Avenue with the current movement tuning: `262.349 m` traveled across 14 terrain-aware checkpoints in `18.101 s`, with walk/run input, continuous grounding, and zero stalls, recoveries, boundary escapes, or discontinuities.
- Its bounded whole-island mode traveled `3,449.107 m` in `52.013 s` wall time (`415.817 s` simulated), completed all five landings, stayed below a `0.348 m` maximum physics-tick step, and had zero stalls, recoveries, boundary escapes, or post-start transform writes. The retained [coherent-surface route evidence](evidence/first-playable/coherent-surface-route-2026-08-28-1458/README.md) remains historical geometry evidence from the earlier movement tuning.
- The final `1440×900` 13-frame Forward+/Metal set includes five grounded regions, two elevated owner-comparison angles, a real-controller tag, SF/YBI/bridge context, two vegetation views, and the fixed NAIP shrub row. It received final art-direction `PASS` for all eleven semantic Poly Haven materials backed by 18 packaged 1K maps. Exact hashes and the proof boundary are in [the final textured-world rendered evidence](evidence/first-playable/textured-world-final-rendered-2026-08-28-223242/README.md).

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

The sole current private handoff is `build/car-speed-staging-2026-08-28-231815/Treasure Island First Playable.app`. It contains generated content SHA-256 `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`, manifest SHA-256 `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`, the current `4/20/30/40` movement defaults, the 124-instance vegetation pass, the 208-source vehicle plus 219-source pedestrian pavement skin, and all eleven semantic Poly Haven materials. Its exact package identity, mounted-PCK audit, smoke results, architecture, signing, and permission facts are in [the car-speed Mac evidence](evidence/first-playable/car-speed-mac-run-2026-08-28-231815/README.md).

The prior `build/textured-world-final-staging-2026-08-28-224622/Treasure Island First Playable.app` is historical because it predates the `20 m/s` Shift-run amendment. Its exact pre-tuning package facts remain in [the historical textured-world Mac evidence](evidence/first-playable/textured-world-final-mac-run-2026-08-28-224622/README.md).

An earlier export in the `224144` staging directory failed only the superseded flat-palette smoke assertion. It is not current and must not be used for playtest or handoff.

Build another candidate with the approved `macOS Private` preset only when needed, always choosing a fresh unused staging directory rather than overwriting this handoff:

```sh
GODOT=".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot"
mkdir -p "build/car-speed-staging-YYYY-MM-DD-HHMM"
"$GODOT" --headless --path . --export-release "macOS Private" "build/car-speed-staging-YYYY-MM-DD-HHMM/Treasure Island First Playable.app"

APP_BINARY="build/car-speed-staging-YYYY-MM-DD-HHMM/Treasure Island First Playable.app/Contents/MacOS/Treasure Island First Playable"
"$APP_BINARY" --headless -- --mac-export-smoke
"$APP_BINARY" --max-fps 60 --rendering-method forward_plus --rendering-driver metal -- --mac-export-smoke
```

The packaged smoke starts the exported PCK's normal main scene and fails after 60 seconds of simulation time if its checks do not finish. It exits nonzero if the exact ferry spawn/yaw, approved hash, counts, grounded player-enable gate, exact `4/20 m/s` speed and `30/40 m/s²` response defaults, ambient/camera defaults, live eleven-key Poly Haven texture identities/effective repeats/filtering/normals, Space-bound jetpack rise, or capped slow descent drift. It retains the `semantic_palette=pass` output field for log compatibility, but that field now represents the current semantic-material contract rather than the superseded flat-color palette. It prints separate `MAC_EXPORT_VISUAL`, `MAC_EXPORT_MOVEMENT`, and `MAC_EXPORT_JETPACK` lines before passing. Use explicit `--max-fps 60` for the non-headless Metal/Forward+ auto-close launch: the first uncapped direct Metal run reached the exact world, visual, and movement lines but hit `MAC_EXPORT_SMOKE_TIMEOUT` before jetpack, so it is not passing evidence. The capped rerun completed through jetpack and passed.

The current app passes strict deep ad-hoc hardened-runtime signature verification and contains universal `x86_64 arm64` slices. It is neither Developer ID signed nor notarized, has no TeamIdentifier or entitlements, requests no sensitive permissions in `Info.plist`, and is only for approved private local use. See [current package evidence](evidence/first-playable/car-speed-mac-run-2026-08-28-231815/README.md) and the [historical full package audit](evidence/first-playable/visual-qa/mac-run/README.md).

An export or packaged smoke command succeeding is not owner acceptance. Check the precise exported-app proof in [the first-playable evidence index](evidence/first-playable/README.md), then follow [PLAYTEST.md](PLAYTEST.md).

## Project map and cleanup

- [Approved approach](discovery/APPROACH_PROPOSAL.md) and [decision log](discovery/DECISION_LOG.md)
- [Frozen OSM provenance and hashes](data/osm/README.md)
- [Frozen USGS terrain provenance and hashes](data/terrain/README.md)
- [Generated manifest](generated/world/manifest.json) and [coverage summary](generated/world/coverage-summary.json)
- [First-playable evidence](evidence/first-playable/README.md)
- [Jetpack source-runtime evidence](evidence/first-playable/jetpack/README.md)
- [Historical coherent-surface route evidence](evidence/first-playable/coherent-surface-route-2026-08-28-1458/README.md)
- [Final textured-world rendered evidence](evidence/first-playable/textured-world-final-rendered-2026-08-28-223242/README.md)
- [Current car-speed Mac export evidence](evidence/first-playable/car-speed-mac-run-2026-08-28-231815/README.md)
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

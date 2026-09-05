# Treasure Island Game machine-migration handoff

Date: 2026-08-30
Portable migration: 2026-08-31
Repository: `https://github.com/pcomans/treasure-island.git`
Project layout: **the repository root is the Godot game root**
Resume revision: **the destination `origin/main` commit containing this handoff**

> **Post-migration status — 2026-09-03:** migration and exact toolchain
> restoration are complete. This document remains the authoritative dated
> baseline for the accepted Building 1 state, source boundaries, toolchain, and
> paused `r133351` branch, but its “next action” and clean-resume steps are
> historical. The exact at-export base provenance was `main` HEAD/origin
> `08219c9e11c8bd6ce681e48860bb906db07e82f7`, tree
> `a02b1c5b645c02d60a18d01e89f6e2f71bb7e04f`; the verified deliverable
> source and evidence were committed in `921be43`, and clean local and live
> `origin/main` have since been durably pushed. The current private app is
> `build/final-verification-staging-2026-09-03-111725/Treasure Island First Playable.app`;
> executable SHA-256
> `49c7518acfb5443b0cee2f22d65a45405ab62c79a2112d7e770ca1c030eca594`,
> PCK SHA-256
> `4d9e1d47f8777dbe2d7ca57f9a93d840a708dfcc35c18e99e54a77c36eeb266e`,
> seven-file inventory SHA-256
> `7816c944b470a7542dea1030d9b09cd28c2ec25880fe5131f69bb60460089960`.
> Current source/package results are in
> `evidence/first-playable/final-verification-2026-09-03-105408/`; the
> canonical twelve-view source-project evidence is
> `evidence/first-playable/exact-current-visual-repair-2026-09-03-104510/`.
> The earlier dirty-worktree preservation warning is historical: source and
> evidence are on pushed `main`, while the exact ignored candidate app remains
> local at the path above.

> **Post-B201 current status — 2026-09-05:** the sole current private handoff
> is
> `build/b201-promotion-staging-2026-09-05-024605/Treasure Island First Playable.app`.
> Its executable SHA-256 is
> `23f8f5cfda04749bb6e2b00659d5f9e46086c55c8dde0cc00d1b2f8b5235146c`
> (`170,963,648` bytes); PCK SHA-256 is
> `3425018ee32f645c3bf157deb9f9a548efe3c9e0bca1e40fd588318aa31f54d6`
> (`65,708,948` bytes); canonical seven-file inventory SHA-256 is
> `ef300ab3f97d077f3db61fad53094cbc3a540175e6475e549d5cd0a3ab9e8f98`
> over `236,745,436` logical bytes. Two complete current-source matrices
> (35 valid fast/core plus four slow end-to-end gates per round) and two
> 28-contract evidence sweeps,
> three outside-checkout mounted audits, packaged headless smoke, first bounded
> Metal smoke, and an ordinary no-argument launch pass on the Apple M2 verifier
> host. Current loaded topology is
> `735/950/964/66,636/466/466` and recognition is exact `7/213` under
> compiler `1.6`, catalog/registry v7, and contracts/loader v6. Active-adapter
> review status is provenance-only; reference recognition derives from the
> mapped physical-unit claim and independent receipt. Isle House and Navy
> Chapel retain shared pre-B201 derived parity under
> `pre_b201_integration_live_parity`; B201 uses
> `current_integration_topology`. Candidates `014223` and `002922` are
> withdrawn packaged-test/pre-scope diagnostic history. Owner recognition and ordinary mouse/keyboard play on
> the approved Apple M1 Pro remain pending. The dated 2026-09-03 app/topology
> paragraphs and resume commands below are historical unless this addendum
> explicitly restates them.

The historical 2026-09-03 topology distinction was: `729` physical/generated records render
`729 meshes / 739 surfaces / 48,389 triangles`; accepted visual attachments
bring the loaded total to `1,278 / 1,288 / 55,067`, with `466`
body/shape pairs. Verification ran on an Apple M2 arm64 host, not the approved
Apple M1 Pro owner target. Ordinary owner recognition and
walk/run/camera/jetpack/spray play on exact candidate `111725` remain
pending, as do x86_64 runtime coverage and any distribution
signing/notarization claim. The `190724`, `231815`, and August rendered
records are historical and retain only their own byte-specific facts.

## Owner goal and operating boundary

The owner wants a recognizable, complete Treasure Island first playable for private use: island-scale exterior coverage plus third-person walk/run, unlimited hold-to-rise jetpack, and one predefined spray interaction. Recognition and playability are co-primary. Building-specific facade work prioritizes recognizable ordinary-gameplay art over survey precision; reversible scale, count, cadence, and anchors may be labeled `production_inference`, while exact receiver/protected-scope and physics integrity stay mandatory.

For this project, the primary `/root` agent is an orchestrator only. It must delegate every edit, research action, test, capture, build, launch, installation, and other execution to a named bounded subagent. Read the repository-root `AGENTS.md` and this project's `AGENTS.md` before any work.

## Current accepted Building 1 state

Treasure Island Administration Building 1 / 1939 fair Pan Am building is source `r16681702`, exact receiver `building:r16681702:wall`.

- `B1-MAT-IVORY` is independently accepted `KEEP_WITH_DOCUMENTED_LIMITATION` on exactly public outer runs `0..56,58,60,93..96`: 63 runs / `206.908708 m` / `4350.511117 m²`.
- Exactly 45 complete live motifs are independently accepted: 8 `B1-WING-W`, 24 `B1-CENTRAL-W`, 2 `B1-PAV-W`, 6 `B1-BASE-O`, 1 `B1-DOOR-BLUE`, and 4 `B1-BAND`.
- The Building 1 render attachment is 354 meshes / 354 surfaces / 4338 triangles / zero colliders. The loaded world remains 729 records / 1278 meshes / 1288 surfaces / 55067 triangles / 466 collider pairs.
- Final review: `discovery/facades/TREASURE_ISLAND_BUILDING_1_RECOGNIZABILITY_ART_REVIEW.md`, SHA-256 `328973362b873b80ec8255c78ad7851369db850d3d9bc3f95b31064f83bb584c`.
- Evidence: `evidence/first-playable/treasure-island-building-1-recognizability-composition-2026-08-30/`.

Known limitations remain hard boundaries: coverage, material values, dimensions, anchors, vertical levels, count, cadence, sequence, and transition endpoints are unsurveyed production inference. `B1-BASE-O` remains an opaque unresolved opening family; the blue door is not the main entrance. Entrance/canopy/emblems, protected runs `57/59/61,62..92,97..109`, inner ring, separate tower `w1222720021`, east/rear conditions, generated 20 m massing, roof, terrain, collision, navigation, spray, completed elevations, as-built fidelity, and whole-building fidelity remain unaccepted or untouched.

The owner's requested stopping point is now reached. Do not begin another building. After migration, the next action is to verify the preserved commit on the new machine and launch the unchanged first playable for the owner only when explicitly requested.

## Processed facade state

The canonical source-by-source status, exact run ownership, accepted scopes, blocked scopes, and evidence links are in `discovery/FACADE_RECEIVER_INVENTORY.json` and `discovery/FACADE_RECEIVER_INVENTORY.md`.

Current accepted target-specific runtime receivers are Hawkins `w1249412093`, Building 3 `w34313540`, Isle House high `w1282547786`, Navy Chapel `w291189336`, Dormitory 369 `w291189926`, Treasure Island Community YMCA `w34313547`, `w34313564`, `w34313515`, `w291196370`, `w34313520`, `w34313525`, and Building 1 `r16681702`. Aggregate accepted exact fields are 9 receivers / 11 scopes / 130 runs / `1024.828178 m` / `10476.046427 m²`; accepted modules are 6 receivers / 62 placements / 546 meshes / 6552 triangles. Pending actual-world and recognizability review counts are zero.

## Toolchain and local resources

- Godot `4.7.2.stable.official.ed1daf0bf`, standard GDScript edition, Forward+, Metal on Apple Silicon.
- Current self-contained executable: `.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot`.
- Trusted archive/template hashes and installation procedure: `discovery/TRUSTED_INSTALL_PLAN.md`; completed installation audit: `INSTALL_LOG.md`.
- Node dependencies are project-pinned: `earcut@3.2.3` and `polygon-clipping@0.15.7` in `package.json`/lockfile.
- No active game, asset-library, generation, or live-service account is required to build, test, run, or continue the accepted project. Cloning the destination uses ordinary Git host access but requires no new project account. No facade round in this migration stack used browsing, downloads, uploads, image generation, or a new external resource.
- The canonical building-texture skill is the project-local `.agents/skills/building-texture/` tree at repository root. Its six tracked files are `SKILL.md`, `agents/openai.yaml`, three files under `references/`, and `scripts/build_proofs.mjs`; the recognizability-first revision changed the first five while retaining the existing proof script. A normal clone preserves it. Do not create a second editable copy elsewhere in the project.

## Clean resume procedure

1. Clone `https://github.com/pcomans/treasure-island.git`, enter the cloned directory, switch to `main`, and confirm `HEAD` equals `origin/main` with a clean tracked tree before opening Godot.
2. Read repository-root `AGENTS.md`, `discovery/DECISION_LOG.md`, this handoff, and the project-local `.agents/skills/building-texture/SKILL.md` plus the references it routes to.
3. Restore only the vetted self-contained Godot 4.7.2/toolchain using `discovery/TRUSTED_INSTALL_PLAN.md` and `INSTALL_LOG.md`; do not substitute another version silently.
4. Install only the lockfile-pinned Node dependencies if missing. No account login is required.
5. Refresh Godot import/UID state headlessly, then run the focused lifecycle and full-runtime commands below. The project-owned `.godot/` directory is disposable cache; source `.uid` sidecars are not.
6. Confirm `git status --short` remains clean before launching. Launch the playable game, not the editor, only on explicit owner request.

Commands and broader explanations are maintained in `game/tests/README.md`. Minimum migration smoke from the project root:

```sh
GODOT=".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot"
"$GODOT" --version
"$GODOT" --headless --editor --path . --quit
"$GODOT" --headless --path . --script game/tests/headless_building_1_recognizability_live_contract.gd
"$GODOT" --headless --path . --script game/tests/headless_building_1_recognizability_evidence_contract.gd
"$GODOT" --headless --path . --script game/tests/headless_batch_06_exact_receiver_trial_contract.gd
"$GODOT" --headless --path . --script game/tests/headless_accepted_material_run_trials_contract.gd
"$GODOT" --headless --path . --script game/tests/full_runtime_integration.gd
```

The ordinary and whole-island route commands are also in `game/tests/README.md`; both passed immediately before this lifecycle-only reconciliation. They need not be rerun merely because documentation/hash pins changed.

Historical evidence-ledger note: the package-local image and record entries remain sealed, but three point-in-time ledgers also name external working-tree inputs. The original exact-receiver-calibration ledger reports expected drift for the later-evolved shared calibration helper and capture harness; the standalone ledger reports expected drift for its later lifecycle-aware contract; and the recognizability asset inventory includes the then-present paused `r133351` registry as an unchanged isolation sentinel. On clean accepted `main`, use the focused current-state contracts above for migration verification. Do not rewrite the sealed historical ledgers merely to make them describe later lifecycle bytes, and fetch `codex/r133351-paused-wip` only when an isolated historical/WIP inspection actually needs those paused files.

## Paused `r133351` work — preserve separately, do not merge as accepted work

The following interrupted standalone implementation files are coherent enough to retain as WIP but have no native evidence or independent art review. Keep them out of the accepted-main preservation commit, preserve them separately, and do not resume or integrate them without a new explicit bounded assignment:

Preservation branch: `codex/r133351-paused-wip`, based on the accepted `main` commit containing this handoff. That branch should contain only the ten WIP implementation files below plus `discovery/facades/R133351_PAUSED_WIP_HANDOFF.md`. It is not an acceptance branch and must not be merged into `main` merely to migrate it.

| WIP file | SHA-256 |
|---|---|
| `discovery/facades/R133351_TARGET_SELECTION_AND_STANDALONE_SPEC.md` | `599a6d8e16528ce6db592145a9a18fe6509a7dccc42e98e6318e77da8712baf2` |
| `game/resources/facades/r133351_standalone_prototypes.json` | `ecde7b80ba595f61d03bfd21f57407956c3b8988e381f0457f95bfe1aa580ad9` |
| `game/resources/materials/world/r133351/r133351_frame.tres` | `e49560ac110ead76b38ea737599009843a2188a6853a9e825cf583f52e08f7a8` |
| `game/resources/materials/world/r133351/r133351_glass.tres` | `9341d310e5587a13844bb6ae12e9734f56caff4092b54cf013e8b2109125ab8f` |
| `game/resources/materials/world/r133351/r133351_light_field.tres` | `7e7a332b067268695eb102e82e35360322d5cf4fcb2c7c2d4f681351eb10d66e` |
| `game/resources/materials/world/r133351/r133351_lower_field.tres` | `6d2e7928f15d69864af25e1a0af36bc7082269eecd9600f20236cefaba69455a` |
| `game/resources/materials/world/r133351/r133351_olive_field.tres` | `c679dbd2002c4a9a66ef0727498f5b41f1cdd38e8d44ae30abf50fad2e6a9a8b` |
| `game/scenes/world/facades/batch_06/r133351_standalone_prototype_set.tscn` | `4bc35012542e0c6c6d8c1ebe2b18433c31b8cfcd57ff3a74c7ab6278d497df13` |
| `game/scripts/world/facades/r133351_standalone_prototypes.gd` | `34507e27e8cfe518c71a75c2a410b35e6cb335f2a88abbfb91624a537b1945f6` |
| `game/scripts/world/facades/r133351_standalone_prototypes.gd.uid` | `a7049d6d6a2c98606d6189ee22b77e06da5f7588383797c983e5bee4f392b2ee` |

`discovery/facades/R133351_RETAIL_REFERENCE_SPEC.md` is an older tracked reference record, not part of this paused WIP list.

To resume after migration, first verify the accepted `origin/main` state and fetch `origin/codex/r133351-paused-wip`. Read the branch handoff and the tracked retail reference/specification before changing anything. Continue in an isolated branch or worktree only after a new explicit bounded assignment. The first required lifecycle step is still native standalone evidence followed by independent art review; do not attach the prototype to a live receiver, promote lifecycle status, or merge it into accepted main before those gates pass.

## Preservation boundary

Destination `main` is a project-only migration snapshot: the game lives at repository root alongside its governing agreement and canonical `.agents/skills/building-texture/` skill. It preserves the project rule/decision/workflow updates and the complete reviewed Building 1 standalone, mapping, detached correction, live-field, recognizability, lifecycle, evidence, tests, handoffs, and this portable migration handoff. It excludes the ten paused `r133351` WIP files from `main` and excludes every unrelated outer-workspace file, photo, archive, app, note, cache, secret, and Git metadata path. The destination branch `codex/r133351-paused-wip` carries only the exact eleven separately preserved WIP paths described above.

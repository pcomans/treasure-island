# Exact-current final verification and private macOS package

## Result

**TECHNICAL PASS WITH NATIVE-STARTUP LIMITATION for the exact-current source
contract suite, continuous route coverage, fresh export, static bundle
integrity, direct-mounted PCK audit, packaged headless semantic smoke, and one
identical-command warm-state native Forward+/Metal smoke. Independent
post-sanitization review clears this publishable record as
`PASS_WITH_LIMITATIONS`.**

The retained current candidate is:

`$ROOT/build/final-verification-staging-2026-09-03-111725/Treasure Island First Playable.app`

The first retained native invocation reached Apple M2 Metal/Forward+, exact
world, visual, and movement readiness, then exited `1` on the unchanged
60-simulation-second smoke deadline before jetpack. The immediate rerun used
the byte-identical command and passed in warm state. This record therefore does
not claim a cold/first-run native semantic-smoke pass.

This record also does not claim ordinary owner play, owner visual/recognition
acceptance, execution on the approved Apple M1 Pro target, Developer ID
signing, notarization, or Gatekeeper distribution acceptance. The deterministic
smokes did not fabricate owner input. Each app process was terminated by its
bounded smoke workflow, and no Treasure Island/Godot process remained.

## Candidate identity

| Item | SHA-256 | Bytes |
|---|---:|---:|
| `Contents/MacOS/Treasure Island First Playable` | `49c7518acfb5443b0cee2f22d65a45405ab62c79a2112d7e770ca1c030eca594` | 170,963,648 |
| `Contents/Resources/Treasure Island First Playable.pck` | `4d9e1d47f8777dbe2d7ca57f9a93d840a708dfcc35c18e99e54a77c36eeb266e` | 55,816,660 |

The exact seven-file bundle has 226,853,148 logical bytes and canonical `path\0sha256\0bytes\n` inventory SHA-256 `7816c944b470a7542dea1030d9b09cd28c2ec25880fe5131f69bb60460089960`. See `checks/candidate-2-bundle-inventory.tsv`.

The bundle identifies `Treasure Island First Playable` version `0.1.0`, bundle ID `local.treasure-island.first-playable`, package type `APPL`, and platform `MacOSX`. Its executable is universal `x86_64 arm64`; the verifier host was Apple M2 arm64, while the approved owner target remains Apple M1 Pro. Only the arm64 slice was executed. Deep/strict whole-bundle and per-architecture code-signature verification passed. The signature is Godot's ad-hoc hardened-runtime signature with no TeamIdentifier and empty entitlements. The privacy manifest declares tracking false; no sensitive-permission usage-description key, quarantine attribute, or other extended attribute was present. This private artifact is not Developer ID signed or notarized.

Full CodeDirectory identities:

- arm64: `2afd4a14f28c020d2f767f6ef86470ace4e8d22f5b51382c999fb2edb2333c4d`
- x86_64: `91edec9bffd4260fc7cbe0cf5baa370fc9b5433c3cc0040d3b5ca67e88435c0e`

## Exact source binding

The export ran from branch `main` at HEAD/origin-main `08219c9e11c8bd6ce681e48860bb906db07e82f7`, tree `a02b1c5b645c02d60a18d01e89f6e2f71bb7e04f`, plus the preserved authorized working-tree work. Immediately before export:

- full tracked binary diff SHA-256: `f105c301003405fbf888b8b5fd5c8d7d0ad49a67f12b0c21ff0cc4e4c35fad72` from `git diff --binary --no-ext-diff | shasum -a 256`;
- export-impact binary diff SHA-256: `4693b5c4c133a8b6b18c8167c470aabfa921d732deec9bb65fafad402f72d97a` from the same command scoped to `export_presets.cfg project.godot game generated source_assets`;
- a sorted 496-file source inventory over tracked and untracked non-ignored files in those paths had SHA-256 `808dbdba8b90cc7b6c2b74cae52f3a5dd9bf0560e2ec827d9af6dd3f726c3872`.

The same 496-file inventory and both diff hashes matched immediately after
export. `checks/candidate-2-pre-export-provenance.txt`,
`checks/candidate-2-post-export-provenance.txt`, and the pre/post source
inventories retain the exact commands and rows. `game/tests/README.md` was
then clarified and later reconciled as documentation, so the candidate is
**not** claimed to match the subsequently edited full 496-file inventory.
`checks/candidate-2-post-sanitization-source-classification.md` and its
current inventory record the exact docs-only delta: the full current inventory
is
`6fa2989e4a7a9c9fc93f6cf519e67731088ff875c545592da6d68c14e576d98c`,
and the only changed row is `game/tests/README.md`, now SHA-256
`9ebec1bc5b725b698897cb83dfb5509e48bb51dd5a122042e53df8ea7d1ca8e2`
at 18,503 bytes versus the export snapshot's
`1cdbde5b6b3ad9c163f5c617431ea354c34f592c9da2a83051a1a77891695ba8`
at 16,362 bytes. The other 495 scoped source/config/generated records are
byte-identical, with filtered inventory SHA-256
`dd70d46ce100951ac9ce7713bd771582dfe6787015b631cc12721b13f01fd0c0`.

The generated manifest is 27,087 bytes with SHA-256 `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`. An independent raw PCK-v4 parser found 574 virtual files, exactly 47 generated-world files (46 indexed payloads plus the manifest), checked every indexed byte count/SHA-256 and PCK-directory MD5, and recomputed canonical generated-content SHA-256 `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164` from `path\0sha256\0bytes\n` records.

## Canonical current-source gates

All commands used `.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot`, which reported `4.7.2.stable.official.ed1daf0bf`. Commands are printed at the start of their retained logs.

| Gate | Result | Evidence |
|---|---|---|
| Engine, editor/import refresh, startup configuration | PASS | `logs/01_godot_version.log`, `logs/02_import_refresh.log`, `logs/03_startup_configuration.log`, `logs/40_final_import_refresh.log` |
| Scene, input/controller, material, generated-world contracts | PASS | `logs/04_scene_parse.log` through `logs/08_node_world_validator.log` |
| Building 1 current live/evidence contracts | PASS | `logs/35_building_1_live_after_export_guard.log`, `logs/36_building_1_evidence_after_export_guard.log` |
| Batch 06 and accepted-material aggregates | PASS | `logs/37_batch_06_after_pin_update.log`, `logs/38_accepted_material_after_export_guard.log` |
| YMCA wall-tangent contract | PASS | `logs/15_ymca_wall_tangent.log` |
| Exact visual-capture harness parse/check-only; no recapture | PASS | `logs/41_visual_harness_check_only_after_export_guard.log` |
| Full runtime integration | PASS | `logs/39_full_runtime_after_export_guard.log` |
| Ordinary ferry-to-Trade-Winds controller route | PASS | `logs/42_normal_route_after_export_guard.log` |
| Continuous whole-island controller route | PASS | `logs/43_whole_island_route_after_export_guard.log` |
| Source main-scene `--mac-export-smoke` | PASS | `logs/44_source_mac_export_smoke_after_export_guard.log` |

The final full-runtime run reported 729 generated meshes / 739 generated surfaces / 48,389 generated triangles and 1,278 total runtime meshes / 1,288 surfaces / 55,067 triangles, 466 bodies/shapes, 124 vegetation placements, 15 assets, 19 batches, and `load_ms=6332`. It exercised the real controller/camera/physics paths for grounded walk, run, airborne movement, held-input jetpack ascent, released capped descent, renewed ascent, landing, resumed movement, manual/boundary recovery, valid wall spray, invalid receiver rejection, the 64-tag pool, and eviction.

The ordinary route covered 262.349 m through 14 validated road checkpoints with zero recovery, stalls, or teleport. The whole-island route covered 3,449.107 m across ferry, southwest, center, north, and east-perimeter anchors using public walk/run/jetpack input with five landings, zero recovery/stalls/teleports, and a 0.348 m maximum step.

## Export and package gates

| Gate | Result | Evidence |
|---|---|---|
| Fresh non-overwriting release export | PASS, exit 0 | `logs/45_candidate_2_export.log` |
| Independent raw PCK/content computation | PASS, exit 0 | `logs/47_candidate_2_independent_pck_parse_corrected.log`, `checks/candidate-2-pck-generated-descriptors.tsv` |
| Exact bundle inventory | PASS, exit 0 | `logs/49_candidate_2_bundle_inventory_corrected.log`, `checks/candidate-2-bundle-inventory.tsv` |
| Plist, privacy, universal/native architecture | PASS, exit 0 | `logs/52_candidate_2_plist_privacy_architecture_final.log` |
| Deep/strict code signature, both slices, metadata, entitlements | PASS, exit 0 | `logs/54_candidate_2_codesign_final.log` |
| Extended attributes/quarantine | PASS, exit 0 | `logs/55_candidate_2_extended_attributes.log` |
| Outside-project direct-mounted PCK audit | PASS, exit 0 | `logs/56_candidate_2_mounted_pck_audit.log` |
| Packaged headless main-scene semantic smoke | PASS, exit 0, PID 47736, 8 s | `logs/57_candidate_2_packaged_headless_smoke.log` |
| First retained native arm64 Metal 4.0 / Forward+ invocation | DIAGNOSTIC, exit 1 after readiness, 42 s | `logs/59_candidate_2_native_metal_smoke.log` |
| Native arm64 Metal 4.0 / Forward+ warm-state smoke | PASS, exit 0, PID 49420, 10 s | `logs/60_candidate_2_native_metal_smoke_warm_rerun.log` |

Both successful package smokes reported the exact content identity, ferry spawn/yaw, 38/38 chunks, 735+4 coverage, 1,278/1,288/55,067 topology, 466 bodies/shapes, 124 vegetation placements, `4/20/30/40` movement defaults, ambient/camera/material assertions, jetpack rise `2.751 m`, ascent velocity `5.000 m/s`, released drop `0.300 m`, and minimum velocity `-1.500 m/s`.

## Preserved negative and superseded evidence

- `logs/09_hawkins_facade.log` is a historical point-in-time assertion, not a current aggregate gate. It expects later-accepted Building 1/Museum attachment state to remain absent and therefore exits 1. The exact-current positive replacements above pass Building 1 live/evidence, Batch 06, accepted-material, and full-runtime topology. No product change was made to satisfy the obsolete assertion.
- The retained 2026-08-31 `190724` PCK produced two useful negatives: `logs/20_old_pck_mounted_audit.log` proves a repository working directory violates the mount boundary; `logs/21_old_pck_mounted_audit_empty_cwd.log` reaches the correct boundary and fails `[banned_path]` at `res://node_modules/earcut/package.json`. The new export excludes `node_modules` and passes in `logs/56`.
- The first candidate at `build/final-verification-staging-2026-09-03-105408/` is preserved but superseded. Its static/PCK gates passed, while `logs/32_packaged_headless_smoke.log` exposed export-only raw-source/review hash guards. The smallest fix keeps exact raw hashes active in editor/source verification while export templates rely on the unchanged semantic registry, geometry, topology, mounted-PCK, and package-smoke gates. All affected current contracts were rerun before candidate 2.
- `logs/34_batch_06_after_export_guard.log` caught stale active test hash pins after that source edit; `logs/37_batch_06_after_pin_update.log` is the corrected pass. Sealed historical review documents/inventories were not rewritten.
- `logs/27_plist_privacy_architecture.log` has wrapper exit `0` but contains an unhandled Python `ImportError` and no semantic privacy pass. It is diagnostic, not a pass; `logs/28` supersedes it for candidate 1 and authoritative candidate-2 proof is `logs/52`.
- `logs/29_codesign.log` was a 2,970,741-byte superseded candidate-1 diagnostic. Its raw account-bearing copy is preserved in ignored private storage but deliberately removed from this publishable directory; candidate-2 `logs/54` is authoritative.
- `logs/46`, `48`, `50`, `51`, `53`, and `58` preserve verification-wrapper diagnostics (wrong TSV separators for a NUL-delimited hash, an assignment typo, two zero-match/`pipefail` cases, early-pipe CDHash extraction, and a pre-launch process-scan abort). Each is superseded by the next explicitly named passing gate and none changed the candidate. The raw step-58 output does not independently establish the scan match's cause.
- The first real capped native run, `logs/59_candidate_2_native_metal_smoke.log`, initialized Apple M2 Metal/Forward+, reached exact world, visual, and movement readiness, then hit the internal 60-simulation-second timeout before jetpack after 42 wall seconds. The one authorized identical idle/warm rerun, `logs/60`, reached the complete jetpack assertion and final PASS in 10 wall seconds. The timeout assertion was not weakened.

## PCK-auditor scope boundary

The auditor must run outside the repository and must receive one retained `$PCK` value as both Godot's `--main-pack` operand and its own `--pck-audit-pck` argument. It does not internally prove those two command-line operands are identical. The auditor checks the explicit raw PCK hash, virtual-path exclusions, literal private-source fragments in raw container bytes, mounted project/resource semantics, and the decompressed/hash/parse contract for every manifest-indexed generated file. It does not claim a decompressed privacy scan over every packaged resource.

The historical `190724` PCK is an expected negative: from the correct
outside-project working directory it fails `[banned_path]` at
`res://node_modules/earcut/package.json`. Candidate `111725` excludes
`node_modules` and is the positive successor. Raw container scanning covers
literal configured fragments; decompressed hashing/parsing covers the indexed
generated files, not every arbitrary packaged resource.

## Evidence sanitization and verifier system scope

Before normalization, the complete unsanitized evidence directory, both
incomplete `104116`/`104322` capture attempts, the startup-repair README,
and the superseded raw codesign log were checksum-preserved under ignored
`build/private-evidence-preservation-2026-09-03-115715/`. That private
directory contains account-bearing paths and must not be committed. Publishable
copies use `$ROOT` or repository-relative paths. The partial captures are not
canonical evidence; the retained visual target is `104510`.

`checks/same-boot-system-record-2026-09-03.md` records only `sw_vers`,
`sysctl -n kern.boottime`, and `uname -m`: macOS 26.2 build 25C56 on
`arm64`. It was captured after the verification run during the same boot,
not at launch time. Retained renderer output identifies the non-unique verifier
GPU as Apple M2 (Apple8); the approved owner target remains Apple M1 Pro.

The independent review in `INDEPENDENT_REVIEW.md` correctly blocked the
pre-sanitization publication set while finding the candidate technical gates
`PASS_WITH_LIMITATIONS`. That judgment is preserved. The fresh independent
review in `POST_SANITIZATION_REVIEW.md` verifies the normalized content,
candidate identity, provenance, privacy scan, result classification, and
regenerated noncircular ledger. Evidence publication is now independently
cleared with the limitations below.

## Remaining acceptance gates

- Ordinary owner play of this exact candidate on the approved Apple M1 Pro,
  including visual Treasure Island recognition and real local
  walk/run/camera/jetpack/spray feel, remains required.
- The frozen 12-view source-project visual set and its independent review remain separate from this package verification; this round did not recapture or claim that source screenshots are package pixels.
- Developer ID signing/notarization and Gatekeeper distribution acceptance are outside this private-local package scope.
- The universal bundle was natively exercised on Apple M2 arm64 only; x86_64
  is statically present and strictly signed but was not executed here.
- Independent post-sanitization review passed with limitations; see
  `POST_SANITIZATION_REVIEW.md`. This clears evidence publication, not the
  owner, target-hardware, cold-first-run, x86_64-runtime, or distribution gates.

# Independent final-candidate and evidence audit

**Reviewer:** Crash-forensics executor (`/root/crash_forensics`), acting only as independent verifier
**Date:** 2026-09-03
**Candidate:** `build/final-verification-staging-2026-09-03-111725/Treasure Island First Playable.app`
**Evidence:** this directory's README, manifest, 78-entry pre-review checksum ledger, source/package result tables, inventories, provenance records, and every retained raw log

No Godot process was run and the app was not launched for this review. Candidate inspection was limited to read-only hashing, file/PCK parsing, plist/architecture/signature inspection, and comparison with the retained raw evidence.

## Verdict

**BLOCKED_FOR_EVIDENCE_SANITIZATION — the candidate bytes pass their technical gates with runtime limitations, but the retained launch record violates the mandatory privacy/metadata contract and must not be sealed or published in its current form.**

The retained evidence supports the stated exact-current source gates, fresh export, seven-file app identity, direct-mounted PCK semantics, packaged headless smoke, and one identical-command warm-state Metal/Forward+ smoke. It does **not** support a cold/first-run native semantic-smoke pass: the first retained native invocation exited `1` on the unchanged internal smoke timeout after world, visual, and movement readiness, and only the immediate identical warm-state rerun completed jetpack and exited `0`.

`discovery/GODOT_IMPLEMENTATION_WORK_ORDER.md:321` requires a private launch record to include the local macOS version while omitting user/account path and unique device identity. Fifteen pre-existing files in this evidence directory contain an account-bearing absolute path, and no file records the local macOS product version. Because `checksums.sha256` authenticates those unsanitized files, an executor must sanitize the record, add the required OS version, regenerate manifest/README/ledgers as affected, and request a fresh independent audit. The renderer's non-unique GPU model string is useful hardware evidence and is not treated as a prohibited device identity. This review intentionally does not repeat the private path.

The affected publication files are `README.md`, `manifest.json`, `checks/candidate-2-pre-export-provenance.txt`, historical/superseded `logs/19`, `20`, `21`, `29`, `31`, and `32`, and candidate-2 `logs/53`, `54`, `56`, `57`, `59`, and `60`. Sanitization should replace only the account-bearing prefix with a documented repository placeholder or relative path; it must preserve commands, artifact identities, outcomes, and the useful renderer/GPU model.

Ordinary owner recognition and full local controls on this exact app remain unshown. The approved target is the owner's M1 Pro Mac, while retained evidence identifies a different arm64 host. Those are additional remaining acceptance gates, not reasons to rebuild bytes that otherwise match their technical record.

## Requirement-by-requirement result

| Requirement | Verdict | Independent finding |
| --- | --- | --- |
| Evidence ledger | **PASS FOR BYTE INTEGRITY; BLOCKED FOR PUBLICATION** | The pre-review ledger SHA-256 was `12d8e0c07c9696d86c608c06347d6e91a5c0567f7cafa0d21149496ab6a457bc`. All `78/78` entries verified, all paths were unique and local, no entry was missing, and the ledger did not hash itself. It faithfully authenticates records that violate the launch-record privacy contract, so it is not a final/sealed publication ledger. |
| Executable and PCK identity | **PASS** | Executable `49c7518acfb5443b0cee2f22d65a45405ab62c79a2112d7e770ca1c030eca594`, `170,963,648` bytes; PCK `4d9e1d47f8777dbe2d7ca57f9a93d840a708dfcc35c18e99e54a77c36eeb266e`, `55,816,660` bytes. Both independently match the candidate, README, manifest, and raw recheck. |
| Exact bundle inventory | **PASS** | Exactly seven regular files, zero symlinks/other nodes, `226,853,148` logical bytes. Recomputing sorted `path\0sha256\0bytes\n` records produced `7816c944b470a7542dea1030d9b09cd28c2ec25880fe5131f69bb60460089960`; every inventory row matched the live bundle. |
| Plist, privacy, and architecture | **PASS_WITH_LIMITATION** | Identity is `Treasure Island First Playable`, version `0.1.0`, ID `local.treasure-island.first-playable`, `APPL`, `MacOSX`. `PrivacyInfo.xcprivacy` contains `NSPrivacyTracking=false`; Info.plist has no checked sensitive-permission usage key; recursive xattrs are empty. The executable contains `x86_64 arm64`, but only arm64 was executed, not the approved target host. |
| Code signature | **PASS_WITH_SCOPE** | Whole-bundle deep/strict and both per-slice strict checks pass. Both slices are ad-hoc hardened-runtime, have no TeamIdentifier, and expose empty entitlements. Full CodeDirectory identities match: arm64 `2afd4a14f28c020d2f767f6ef86470ace4e8d22f5b51382c999fb2edb2333c4d`; x86_64 `91edec9bffd4260fc7cbe0cf5baa370fc9b5433c3cc0040d3b5ca67e88435c0e`. This is not Developer ID/distribution proof, as the README states. |
| Private launch-record contract | **BLOCKER** | The record omits the required local macOS version and publishes prohibited account-bearing absolute paths. The renderer/GPU model is not a unique device name and is not part of this finding. This is an evidence-publication defect even though the app itself contains no checked privacy-manifest or xattr defect. |
| Source binding | **PASS_WITH_PROVENANCE_LIMITATION** | Branch/HEAD/origin/tree independently remain `main` / `08219c9e11c8bd6ce681e48860bb906db07e82f7` / same / `a02b1c5b645c02d60a18d01e89f6e2f71bb7e04f`. Pre/post-export 496-file inventories are byte-identical at `808dbdba...`; the current recomputation matches final inventory `c3a9d5af...`, with exactly one post-export path change: documentation-only `game/tests/README.md`. No product/config/generated path changed. The dirty-source binding is an external retained ledger, not an embedded or independently reproducible build attestation. |
| Independent raw PCK structure/content | **PASS** | A fresh byte parser confirmed PCK v4 / Godot `4.7.2`, `574` unique directory entries, directory end exactly at PCK EOF, zero per-entry MD5 failures, and no duplicate paths. It independently found the exact `47` generated files (`46` indexed plus manifest), manifest `e501236d...` / `27,087` bytes, zero descriptor mismatches, and canonical generated identity `01af105e...` from `4,290` NUL-delimited input bytes. Configured banned roots/prefixes and private path/raw needles had zero hits; this remains a targeted scan, not a decompressed whole-package privacy claim. |
| Direct-mounted PCK audit | **PASS_WITH_DOCUMENTED_BOUNDARY** | `logs/56` records working directory `/private/tmp`; the same exact final-candidate PCK path is supplied to both `--main-pack` and `--pck-audit-pck`. Exit is `0`. Output binds the three expected hashes and reports `574` files, `47` generated, `38` chunks, rows `739/735/4`, 18 maps, 15/124 vegetation assets/placements, 22 NAIP shrubs, pavement `427/208/219`, movement `4/20/30/40`, physical Space, and zero configured private/banned hits. The auditor itself correctly disclaims internal operand-equality proof and whole-package decompressed privacy coverage. |
| Current source/runtime gates | **PASS_WITH_HISTORICAL_NEGATIVES** | The post-guard positive suite exits `0`. Full runtime reports generated `729/739/48,389` versus total runtime `1,278/1,288/55,067`, `466` bodies/shapes, real controller/camera/physics, valid/rejected spray behavior, tag cap/eviction, continuous ordinary route, and continuous five-region walk/run/jetpack route without teleport/recovery. `logs/09` is an obsolete pre-attachment assertion; `logs/34` is a caught stale test pin superseded by `logs/37`. |
| Packaged headless main scene | **PASS** | `logs/57` resolves PID `47736` to the exact candidate executable and records exit `0` in 8 s without watchdog timeout. It reports exact world identity/spawn, `38/38`, `735+4`, total topology, physics, vegetation, visual semantics, movement defaults, and jetpack rise/released descent. |
| Native Metal/Forward+ | **PASS_WITH_MATERIAL_LIMITATION** | `logs/59` and `logs/60` have byte-for-byte identical command and process-command strings against the exact candidate. First retained run PID `48373` reached Metal 4.0/Forward+, world, visual, and movement readiness, then exited `1` after the internal 60-simulation-second smoke deadline (42 wall seconds) before jetpack. Immediate warm run PID `49420` reached the same readiness plus jetpack and exited `0` in 10 s. No cache clear/reboot evidence establishes that the first invocation was truly cold, so only “first retained invocation” and “identical warm rerun” are justified. |
| Ordinary package play / recognition | **NOT_SHOWN** | Neither smoke is an ordinary owner session. Mouse camera, walk/run feel, complete jetpack/landing feel, spray eligible/rejected/resume behavior, pause/resume, and owner recognition on this exact package remain required. The separate 12-frame source-project review is not package-pixel evidence. |

## Privacy-safe mounted command contract

The following preserves the exact argument topology and hashes recorded in `logs/56_candidate_2_mounted_pck_audit.log` while replacing the prohibited local account path with `$REPO`; it was inspected, not rerun:

```sh
# working directory: /private/tmp
"$REPO/.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot" --headless \
  --main-pack "$REPO/build/final-verification-staging-2026-09-03-111725/Treasure Island First Playable.app/Contents/Resources/Treasure Island First Playable.pck" \
  --script "$REPO/game/tests/mounted_pck_content_audit.gd" -- \
  --pck-audit-pck="$REPO/build/final-verification-staging-2026-09-03-111725/Treasure Island First Playable.app/Contents/Resources/Treasure Island First Playable.pck" \
  --pck-audit-pck-sha256=4d9e1d47f8777dbe2d7ca57f9a93d840a708dfcc35c18e99e54a77c36eeb266e \
  --pck-audit-manifest-sha256=e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3 \
  --pck-audit-content-sha256=01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164
```

## Failure and claim reconciliation

No failing result for the current bytes was silently converted into an unconditional first-run pass:

- `logs/09`, `20`, and `21` are respectively an obsolete source assertion and two intentional historical-PCK negatives.
- `logs/32` belongs to superseded candidate 1. `logs/34` catches the resulting stale active hash pin before the corrected `logs/37` pass.
- `logs/46` and `48` directly expose verifier implementation errors; corrected `logs/47` and `49` pass and independent recomputation agrees.
- `logs/50`, `51`, `53`, and `58` are partial/aborted verifier outputs. The README's precise shell-cause labels are not independently derivable from those raw files, although final `logs/52`, `54`, and `59` plus this review's static checks close the affected artifact facts. In particular, raw `logs/58` proves only a pre-launch process-scan abort, not that the match was self-generated.
- `logs/27` contains an unhandled Homebrew-Python `ImportError` despite its aggregate row being exit `0`; this diagnostic is not named in the README. `logs/28` immediately provides the fail-fast plist/privacy/architecture pass for that superseded candidate, and candidate 2's `logs/52` plus independent inspection pass.
- `logs/59` is the one material current-candidate runtime discrepancy. It is preserved in the README and package results, but machine-readable `manifest.json` records only the successful warm run (with `warm_state_rerun: true`) and omits PID `48373` / exit `1`. Consumers must read the README/raw log to avoid overstating native first-run coverage.
- Codesign's `':'` entitlement-path deprecation warning is a verifier-command warning, not a signature failure.

The README's candidate identities, totals, successful exits, and explicit nonclaims agree with raw evidence. The only weakly supported prose is the exact causal naming of several ad hoc wrapper aborts; their replacement proofs make this an evidence-hygiene issue, not a candidate defect.

## Ranked decision

### Blocking completion of the approved first-playable goal

1. Sanitize every prohibited user/account path from the launch record, add the required local macOS version, regenerate affected summary/manifest/checksum records, and independently re-audit before calling the evidence final or sealed. Preserve the non-unique renderer/GPU model because it supports the hardware-scope claim.
2. Ordinary owner play and Treasure Island recognition on this exact candidate remain required.
3. If the approved M1 Pro target remains authoritative, that same session must execute these bytes there; the current arm64 evidence is not target-hardware coverage.

### Nonblocking but material

1. First-in-sequence native semantic completion is not reliable in this record: world/visual/movement loaded, but the smoke-only timer failed before jetpack, while an identical warm rerun passed. Preserve both outcomes and do not describe this as a cold-start pass.
2. x86_64 is present and strictly signed but unexecuted. That is outside the current Apple-silicon owner path unless compatibility becomes a requirement.

### Nonblocking evidence hygiene

1. Add first-run native failure fields to future machine-readable manifests rather than recording only the warm success.
2. Retain complete commands and aggregate statuses for verifier failures so their causal labels can be independently reconstructed.
3. Generate privacy-safe launch records at capture time using repository-relative placeholders and record the required OS product version before hashing evidence.

## Decision

**Do not seal or publish the current evidence directory.** The candidate itself does not need rebuilding solely because of this audit, but a separate executor must sanitize/regenerate the launch record and a fresh independent checksum/content audit must pass first. After that, advance these exact candidate bytes to the bounded ordinary owner/target-Mac acceptance session. Final acceptance remains open until owner recognition and ordinary exact-package controls pass, and the native record must continue to be described as first-in-sequence timeout plus identical warm-state PASS.

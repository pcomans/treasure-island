# Independent post-sanitization evidence review

**Reviewer:** Crash-forensics executor (`/root/crash_forensics`), acting only as independent verifier
**Date:** 2026-09-03
**Candidate:** `build/final-verification-staging-2026-09-03-111725/Treasure Island First Playable.app`

No Godot process was run and the app was not launched. The ignored private
backup was not used or trusted; it was checked only for exclusion from
publishable Git scope.

## Verdict

**PASS_WITH_LIMITATIONS — the post-sanitization publication blocker is
cleared.** The exact candidate and its normalized evidence support the stated
technical result. The earlier `INDEPENDENT_REVIEW.md` blocked the
pre-sanitization record correctly and remains historical; this review does not
rewrite that judgment.

The technical limitations remain material. The first retained Apple M2 arm64
Metal/Forward+ invocation exited `1` after world, visual, and movement
readiness; only its byte-identical immediate warm-state rerun reached jetpack
and exited `0`. Ordinary owner recognition and mouse/keyboard play on the
approved Apple M1 Pro remain pending. The x86_64 slice was not executed, and
Developer ID, notarization, Gatekeeper distribution, and package-pixel visual
claims remain unmade.

## Independent findings

| Requirement | Verdict | Finding |
| --- | --- | --- |
| Publishable checksum ledger | **PASS** | Before this review, all `85/85` unique local entries verified and exactly covered the evidence files other than the noncircular ledger itself. After adding this review and updating status records, the regenerated `86`-entry ledger again verifies completely and hashes no external path or itself. |
| Account-path privacy | **PASS_WITH_SCOPE** | The final changed/untracked publishable set contains `123` UTF-8 text files and `24` binary files. Configured account-bearing path needles have zero hits in the text set and zero hits in the exact candidate PCK raw bytes. This is not a decompressed scan of every arbitrary PCK resource. |
| Private preservation boundary | **PASS** | `build/private-evidence-preservation-2026-09-03-115715/` is ignored, absent from changed/untracked publishable scope, and explicitly marked private and unpublishable. Its contents were not inspected for this judgment. |
| Candidate identity | **PASS** | Independent recomputation matches executable `49c7518acfb5443b0cee2f22d65a45405ab62c79a2112d7e770ca1c030eca594` / `170,963,648` bytes, PCK `4d9e1d47f8777dbe2d7ca57f9a93d840a708dfcc35c18e99e54a77c36eeb266e` / `55,816,660` bytes, and seven-file / `226,853,148`-byte normalized inventory `7816c944b470a7542dea1030d9b09cd28c2ec25880fe5131f69bb60460089960`. Deep/strict whole-bundle and per-slice verification pass. |
| Architecture and host scope | **PASS_WITH_LIMITATION** | The executable contains `x86_64 arm64`; only arm64 ran. Retained renderer output identifies Apple M2 (Apple8), while Apple M1 Pro remains the untested owner target. The renderer model is useful non-unique hardware evidence, not a claimed device identity. |
| Same-boot system record | **PASS_WITH_LIMITATION** | The retained record truthfully reports macOS `26.2`, build `25C56`, `arm64`; current read-only queries match its boot timestamp. It was captured after the runs during the same boot, not at launch time, and says so. |
| Source binding | **PASS_WITH_PROVENANCE_LIMITATION** | The current 496-row inventory exactly matches the retained post-sanitization inventory `6fa2989e4a7a9c9fc93f6cf519e67731088ff875c545592da6d68c14e576d98c`. Relative to the export snapshot, only documentation file `game/tests/README.md` changed; the other 495 rows are byte-identical at filtered inventory `dd70d46ce100951ac9ce7713bd771582dfe6787015b631cc12721b13f01fd0c0`. This remains retained dirty-tree provenance, not an embedded build attestation. |
| Manifest, README, and result tables | **PASS_WITH_RETAINED_DIAGNOSTICS** | Candidate IDs, counts, topology, commands, exits, and nonclaims agree with raw logs. Step `27` is explicitly invalid despite wrapper exit `0`; every retained nonzero/aborted/expected-negative result is classified with its successor or boundary. The removed raw `logs/29_codesign.log` and partial `104116`/`104322` captures are absent from publishable scope. |
| Package execution evidence | **PASS_WITH_NATIVE-STARTUP LIMITATION** | Outside-project mounted PCK and packaged headless gates exit `0`. Native `logs/59` preserves the first readiness-then-timeout result; identical-command `logs/60` preserves the warm-state `PASS`. No cold/first-run native pass is claimed. |
| Current/historical boundaries | **PASS_WITH_HISTORICAL NOTE** | Canonical status identifies candidate `111725` and visual set `104510`; older packages and August visuals are historical. The superseded `095709` visual set's internal artifacts remain point-in-time evidence, while its one external capture-harness ledger entry has expected current-tree drift after the later repair. |

## Decision

The normalized evidence directory may be published as an independently checked
`PASS_WITH_LIMITATIONS` technical record. It must not be described as final
owner acceptance or as proof of cold-first-run reliability, M1 Pro execution,
x86_64 execution, ordinary packaged controls/recognition, package pixels, or
public distribution readiness.

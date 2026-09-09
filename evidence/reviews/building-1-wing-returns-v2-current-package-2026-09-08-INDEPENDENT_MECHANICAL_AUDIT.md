# Building 1 wing returns v2 — independent current-package mechanical audit

Reviewer: `handoff_state_review` · 2026-09-08

PASS_FOR_B1_RETURNS_V2_CURRENT_PACKAGE_MECHANICS_ONLY

The exact signed current app passes independent mounted-package checks and
complete headless/native internal release smoke. This gate licenses fresh release
capture and independent release visual review; it does not provide that visual
verdict. Recognition remains **9/213**, with **+0** credit.

## Frozen identities

- Authority audit: `building-1-wing-returns-v2-2026-09-08-INDEPENDENT_AUTHORITY_AUDIT.md`,
  SHA-256 `14b3e5e8b432b4feca522dd18b48d4a4bfbcd95f44e881ae381de39689f69469`.
- Artist stage handoff: task `work/b1-v2-release-001/current-package-stage-handoff.json`,
  SHA-256 `7a58071b1a36093348064f3bc4c650fc18db91770ee283705027e5efda17ea03`.
- Artist receipt: `/private/tmp/b1-returns-v2-current-package-proof-001/current-package-proof-receipt.json`,
  SHA-256 `d4397c9db8da2c183d21f727f7554f6b3fa9cdb1b6de84d414737b109801d8e9`.
- App: `build/building-1-wing-returns-v2-current-2026-09-08-001/Treasure Island First Playable.app`.
  Seven-file bundle identity `fd91b1c5598dc2fe436a756eb5fb7561c96989fe18734c59580de92b13fa4171`
  uses bytewise-sorted `relative_path|sha256|bytes` lines with terminating LF.
  Executable SHA-256 `ac0aa612c576e039b04b743c2da5783fd0736a7312be4c88e31210b672845031`;
  PCK SHA-256 `454b913537742c8b605f41db8730c860de3ab37d08c4a3bfab5e15dc40f69403`,
  **66,600,060 bytes**. All seven app files match the receipt before/after.
- Bridge: `game/tests/headless_building_1_wing_returns_v2_current_package_contract.gd`,
  SHA-256 `3fefb93de5bb6b5ac40f1e2ee82aba95c1426fe5a54d9aca3788b8f89dc5149c`.
- Verifier: `tools/verify_building_1_wing_returns_v2_current_package.py`,
  SHA-256 `8976887e525780512a4fd8a7efb7cddbd22737c1fa5df5a7a6d5ca423178f692`.

The verifier's 51 frozen paths/hashes exactly equal the authority handoff's
17 current inputs, five reviewed source inputs and 29 preserved lineage inputs.
Nine additional proof pins bind the editor, project/export configuration, mounted
privacy program and frozen earlier candidate programs. Before/after inputs match
the artist receipt exactly. Historical candidate proofs are not rewritten.

## Independent execution and observed facts

Executed the sealed verifier once with `python3 -B` and
`--output-root /private/tmp/b1-returns-v2-current-package-proof-independent-001`.
Every child command uses that fresh directory as its actual `cwd`; it resolves
to itself, is not a symlink, and contains no source project or game directory.
Mounted checks use the exact PCK and external review program. Both internal
smokes execute the exact signed app binary, without external script overrides.
Strict deep signature verification, both universal architectures, app identifier
and the exact non-tracking privacy manifest pass.

| Check | PID | Exit | Elapsed seconds |
| --- | ---: | ---: | ---: |
| `signature` | 18188 | 0 | 0.252 |
| `architectures` | 18191 | 0 | 0.023 |
| `plist_info` | 18193 | 0 | 0.010 |
| `plist_privacy` | 18195 | 0 | 0.006 |
| `mounted_current_graph` | 18197 | 0 | 1.956 |
| `mounted_privacy` | 18206 | 0 | 2.275 |
| `headless_smoke` | 18208 | 0 | 8.412 |
| `native_smoke` | 18225 | 0 | 8.979 |

The package contains 925 virtual files, 47 generated artifacts and 38 chunks,
with 735 playable plus four context rows. The existing privacy scanner reports
`private_paths=0 private_raw=0 banned=0`. Mounted B1 geometry is 13 meshes /
13 surfaces / 12,151 triangles, including 168 accepted center-reveal triangles
and 8,244 trim triangles. Existing actual mesh-array, material, collision and D2
ownership checks pass. Current registry/contracts are exact audited bytes;
B1 retains its two 11-asset closures and null behavior, while D2 retains its own
component/capture identities and reports the current whole-world triangle count.

Both internal release modes complete all ten expected telemetry phases and exit
zero. World topology is 735 / 959 / 974 / 70,692 / 466 / 466
(rows / meshes / surfaces / triangles / bodies / shapes). Headless/native world
load measurements are 5,861 / 5,695 ms. Both ground the player, rise 2.751 m at
5.000 m/s, and descend 0.300 m with minimum velocity −1.500 m/s. Movement and
visual defaults pass. The shipped main reaches its final success only after
checking all combined world/player/default predicates and jetpack behavior.

For each mode, the engine log and combined stdout/stderr log were separately
validated and their nonblank lines matched. Unexpected diagnostics, missing or
duplicate phases, stale topology, failed grounding/defaults, invalid jetpack
measurements and nonzero exit fail closed; all 17 existing negative controls
are rejected per mode. Process log hashes, engine log hashes, commands, cwd,
observed executable paths and elapsed measurements are retained in the receipt.
These elapsed observations are not a performance benchmark or defect diagnosis.

## Static review and boundaries

Twelve existing bridge methods are byte-identical to the frozen candidate
bridge. `_wing_material_semantics` has identical executable text with one extra
trailing separator newline; a blanket whole-method byte-identity claim would be
imprecise. `_run` updates sealed current pins/oracle and invokes the new
`_validate_current_graph`; no existing geometry/material/collision/ownership
method is weakened or removed. The graph checks exact JSON bytes and exported
resource remap availability. Executable source SHA fields remain provenance;
this audit does not equate compiled GDC bytes with source text. Full-world
construction is proved by the signed release's internal smoke, preserving the
editor-only raw-input validation boundary.

The retained initial artist preflight failure is a host `plistlib`/`pyexpat`
import failure, before package child checks. Its log SHA-256 is
`c9bb3e480fa0672660a25c64eeceee2c463a9cf40c14955771fcc349c2fa1c2d`.
The sealed verifier uses native `plutil` JSON conversion; this independent run
uses that exact harness without re-exporting or editing the app or product.

No fresh pixels were captured here. Earlier A/B images remain source renders,
not package pixels. Earlier candidate combined smoke exit 1 remains historical;
it is not relabeled as successful. This exact-current app now passes the complete
internal smoke. Existing independently verified source geometry, routes and
rehearsal captures were reused where unchanged, without repeating their suites.

Independent receipt: `/private/tmp/b1-returns-v2-current-package-proof-independent-001/current-package-proof-receipt.json`,
SHA-256 `7099f83ca19c6560ee9cb7b8b653d97739afa12e65295f2bd9c1d5ae0989957d`.
Driver: task `work/b1-v2-current-package-independent-001/driver.log`,
SHA-256 `742486897e5ae992be94a7bd41560585fd8ae6fcd893af09e2cd5876a8507ffa`.
Static findings: same task directory, `static-review-findings.json`,
SHA-256 `7ca2fd65cf7a8b7027cda3363de6689b9451caee82188b17e5a6b7b9393386b3`.

Exec session **36508** and all eight owned child processes are terminal exit 0;
last native PID **18225** exited 0. The heavy slot is released. No source,
program, app, authority or accepted evidence was edited. Next gate: fresh
exact-current release capture followed by independent release visual review.

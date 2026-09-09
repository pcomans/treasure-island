# Current B1 release evidence — independent mechanical audit

Reviewer: `handoff_state_review` · 2026-09-08

PASS_FOR_B1_RETURNS_V2_CURRENT_RELEASE_EVIDENCE_MECHANICS_ONLY

The frozen fresh source-render set passes independent sealed evidence replay,
strict inventory controls and capture-lineage review. This permits the separate
fresh release visual review; it does not supply that visual verdict. Recognition
remains **9/213, +0**. No recapture or source/package suite was run by this reviewer.

## Exact frozen set

- Root: `/private/tmp/b1-returns-v2-current-release-001`.
- `current-release-verification-receipt.json`, 35,660 bytes, SHA-256
  `b75d7943dee504ddc984d5a6c8fd954d11442e7b60f21637183dc9b2d77f42c3`.
- **46 PNGs + three manifests = 49 inputs**, 35,071,634 bytes. Canonical
  relative-path-string-sorted `path|sha256|bytes` lines with terminating LF yield
  `341b6545fc22b103813fcd5a65f5487388bdce521ab43b89d0c42b214b7a0272`.
  The exact 50-file tree including receipt is
  `422076e3f9f41042feab1e68c7e7f0be540a0bbb54a57dddd698824a74c7160c`,
  35,107,294 bytes; no extra file is present.
- Artist handoff: task `work/b1-v2-release-capture-001/current-release-evidence-handoff.json`,
  SHA-256 `77c9ce5a21f595151e85020dbe2869f9384179adf74e7ff53421034e413a9e96`.

Programs in task `work/b1-v2-release-capture-001`:

- Binding003 `current-release-binding.json`:
  `a9fb95a17c1cbe3b7d9e1d29465a5df3f08ac364d83b80aa58f8f0ea09993cdc`.
- Capture003 `building_1_wing_returns_v2_current_release_capture.gd`:
  `e93d3899ff05f1ce8f15b0bfb79a96fab06cab97b81a4073c30cc291d205c632`.
- New verifier `headless_building_1_wing_returns_v2_current_release_evidence_contract_004.gd`:
  `9a4b8c2110d429159a72c8dd970e5c22032b7e90023998f27d1c783d5198f6c8`.
  Verifier003 remains unchanged at
  `fb1f3b946367565ebaa16866b204d6c5247add17ca7029fed329f520cecc6c15`.

## Independent execution and narrow correction

Verifier004 changes only the inventory comparison call, its receipt basename
and the new comparator. It checks exactly 49 ordered entries, exactly three
fields per entry, exact string paths/hashes, nonnegative runtime integer byte
counts and exact expected integer or finite nonnegative integral floating byte
values. Fractions, coercible strings/bools, nonfinite or unsafe floating counts,
wrong schema/types/order/paths/hashes and missing/extra entries reject.

The independent comparator probe passed **23 checks** against actual reference
file hashes/lengths and malformed variants, PID 9363 exit 0. The sealed004
`--receipt-mode=verify` replay then passed, PID 9364 exit 0, 3.789 seconds, with
clean merged stdout/stderr. The existing receipt remained byte-identical.
Neither job loads the world or renders. Earlier capture-guard and source/package
findings are reused because their inputs/consumers remain unchanged.

## Fresh generation and exact reference mapping

The two reviewed capture drivers launch the sealed capture program; neither
copies reference files into the output. The first requires an absent output
directory before creating it. Its still job PID 4441 exits 0 with 22 PNGs and one
manifest. Initial north PID 4619 exits 1 before motion output because the driver
omits the inherited user argument `--fixed-fps-receipt=60`; the real engine
`--fixed-fps 60` is present. The continuation requires exactly those 23 current
still files, records their hashes and preserves them while capturing north
PID 5130 and south PID 5275, both exit 0. It restores only the required user
receipt. All four actual argv records preserve fixed60 before the user delimiter,
exact native driver/settings, source script, generator hash and fresh output.
Raw logs, PIDs and before/after snapshots support fresh generation; pixel equality
alone is not used to establish freshness.

All **118** frozen capture snapshot entries match before/after both capture
rounds and still match disk. The owner evidence snapshots also match before/after.
The nine handoff program files, all 49 accepted reference files and all fresh
inputs match their exact hashes/lengths. The 23 original current still files
remain unchanged through motion and evidence verification.

Comparison is keyed by each exact relative path. All **46 PNG pairs are byte
identical**; all remaining parsed values in the three manifests are equal after
excluding only the already-validated provenance/status metadata fields.
Observed geometry, camera, receiver bindings, still/motion telemetry and image
identity are not projected away. Sealed inherited light, grayscale, real spray,
roof landing, tower/rear/context and controller/pose checks pass at unchanged
tolerances (static 0.00005; motion 0.22 m; observed motion delta 0.0 m).

The initial003 evidence failure is the JSON FLOAT/runtime INT nested-container
comparison defect, not reference drift; it writes no receipt and remains retained.
An earlier manual zipped-comparison summary mispaired motion entries using
pathlib component order and claimed 22 equal PNGs/tree `6fc06fd8…`. That claim
was emitted in tool output/messages without a separate original summary artifact.
The handoff's `corrected_manual_handoff_error` and owner RETRO retain it
retrospectively; they are not relabeled as contemporaneous raw evidence.
The canonical path-keyed receipt and this independent comparison supersede it.

## Durable replay evidence and scope

Independent scratch: task `work/b1-v2-release-evidence-independent-001`.
`execution-receipts.json` binds both exact commands, cwd, PIDs, terminal exits,
elapsed time and complete log hashes; SHA-256
`d52068a27e2c5b0983f98b05ef8b749c768366e73d18f09a4b6c003592133e00`.
`lineage-and-path-keyed-checks.json` binds the static closure, preservation and
exact-path comparison findings; SHA-256
`34a18aab7debfd966fd457f7528ecb9e93adf914fdcc51be9f3914e91fdcf8e2`.
`inventory004-probe.gd`, SHA-256 `afa526941a8f396893f5d3a03781f8d25e81c66c6ef5cd4168534c4043ff3982`,
retains the bounded independent positive/malformed-entry controls.

The exact signed current package remains established by the earlier independent
package audit (`c6f4c47a…575ee7`) and full internal headless/native smoke receipts
pinned by binding003. These fresh images are **source renders with separate
package proof**, not package pixels. No accepted reference, raw manifest, sealed
program, product, app or authority was edited. Coordinator session **28507** and
both owned jobs are terminal exit 0; heavy slot released. Next gate: the separate
independent fresh release visual verdict.

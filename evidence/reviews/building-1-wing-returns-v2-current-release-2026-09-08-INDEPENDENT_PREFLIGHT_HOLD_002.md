# Current B1 release wrappers — independent preflight revision 002

Reviewer: `handoff_state_review` · 2026-09-08

HOLD_FOR_B1_RETURNS_V2_CURRENT_RELEASE_CAPTURE

The corrected guard accepts the canonical absolute-executable fixed60 launch,
but its whitespace parsing cannot distinguish an engine flag from flag text in
a script pathname. A real owned launch without a fixed-FPS engine argument
passes both fixed60 preflights when its script path contains ` --fixed-fps 60 `.
No capture is authorized by this note. The original HOLD note remains unchanged.

## Sealed revision reviewed

Task directory `work/b1-v2-release-capture-001`:

- `current-release-binding.json`: 25,116 bytes,
  SHA-256 `798953e00735f0456e75ee2643e2b82f75634a60ed09e3f9049ba074bc79fd32`.
- `building_1_wing_returns_v2_current_release_capture.gd`: 7,984 bytes,
  SHA-256 `10c9fd0aa81ae411e8c0abc731d3cd5d30c1f31243a159b801223b6b42828372`.
- `headless_building_1_wing_returns_v2_current_release_evidence_contract.gd`:
  15,529 bytes, SHA-256 `b6e3649c8063d8763560b82741f4f7376a3ec7d22ea0608e90f2e5f2b1967134`.
- `preflight-behavior-diff-002.json`, SHA-256
  `95c520ba0c08eff48c831172061c6a4235b095c26b202662eb47de565aa81a8c`.

Only `_release_preflight` changed among existing methods. Two shared helpers
observe the owned PID's `/bin/ps` command and parse fixed60. All eight shared
helpers have identical executable text across wrappers. Existing capture and
evidence overrides are unchanged. The binding adds only an explanatory metadata
field; prior source/app/authority/review/reference pins are unchanged, and
revision 001 files are retained under `revisions/001-held-fixed-args`.

## Independent no-render findings

Scratch subclasses disable inherited capture initialization and invoke the real
wrapper guards and validators. The canonical absolute-executable run accepts
valid fixed60 and current metadata. It rejects baseline recapture, missing/wrong
binding bytes, unsealed generator/constant inputs and invalid SHA strings.
Projection leaves both in-memory input dictionaries unchanged; changed observed
topology, camera FOV, receiver bindings and viewport still reject. Raw current
metadata is checked before projection. Wrong-typed dictionary metadata rejects,
but four such controls emit `SCRIPT ERROR` at the direct String/Dictionary `!=`
comparison (evidence wrapper line 293); explicit type rejection would avoid
relying on interpreter-error return behavior.

The actual launch controls are recorded separately:

| Actual engine invocation | Expected rejection | Result |
| --- | --- | --- |
| no fixed-FPS option | yes | both guards reject; PID 97522 exit 0 |
| `--fixed-fps 30` | yes | both guards reject; PID 97533 exit 0 |
| duplicate `--fixed-fps 60` | yes | both guards reject; PID 97541 exit 0 |
| marker only after user `--` | yes | both guards reject; PID 97652 exit 0 |
| no engine option; marker inside one script-path argument | yes | **both guards accept; PID 97663 probe exit 1** |

The last command's argument list contains no standalone engine fixed-FPS token.
Its single script argument is under `marker --fixed-fps 60 /preflight-probe.gd`.
Flattening `/bin/ps` output and splitting on spaces manufactures a flag boundary
inside that argument. Ordinary spaces in executable/script paths otherwise pass
the parser. Synthetic absent/30/duplicate/user-delimiter/lookalike/wrong-executable/
newline controls behave as expected; the embedded-path marker fails both the
synthetic control and the real owned-launch check.

A first probe used a relative executable spelling and was correctly rejected by
the exact executable-prefix guard. It is retained as an operator setup failure,
not reported as a product regression. The canonical absolute invocation then
reached all deferred controls. No world load, rendered evidence, accepted-manifest
rewrite or source/app/authority/program mutation occurred.

## Exact evidence and remaining correction

All paths below are in task `work/b1-v2-release-preflight-independent-002`.

- `negative-launch-receipts.json` records all five exact argv arrays, cwd, PIDs,
  terminal exits, elapsed times and raw log hashes; SHA-256
  `7db64a6627ec4ff41f3caebe6c1cfbbaf7cbedd79fe63e4677b864996105be64`.
- `absolute-positive-fixed60.log`, SHA-256
  `9790139c5480144395fbf7c05ea6f5630e7a45b7c4ad150c37daa6bfda253d56`,
  retains the path-parser failure and wrong-type metadata diagnostics.
- `positive-fixed60.log`, SHA-256
  `d1bf9e5c28fa043572ad5f713b044667c8aa9a780a1b890dde34b84da44acd5b`,
  retains the initial relative-executable setup failure.
- `owned launch probes/preflight-probe.gd`, SHA-256
  `6f156999903b26ef641c16bf57b813a0c2490d7a5136435175e79e3b317e464c`,
  retains the bounded controls and disabled capture entry points.

Preserve real argument boundaries or accept only a path-verified canonical launch
form whose interpretation is unambiguous; reject path-contained markers rather
than counting their words as options. Then reseal and rerun only the affected
launch/metadata controls. All probe processes are terminal: sessions 93694 and
59031 exited 1, coordinator session 39203 exited 0 after retaining the final
negative probe exit 1. The heavy slot is released. Recognition stays 9/213, +0;
46 fresh images and three manifests, source-render/package boundary and separate
release visual acceptance remain pending.

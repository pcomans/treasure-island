# W34313525 live fields and modules — actual-world review evidence

Status: `independently_accepted_live_keep_with_documented_limitation`

This native Godot 4.7.2 Forward+/Metal set shows the actual loaded receiver `building:w34313525:wall` after the bounded integration authorized by the independently accepted exact-receiver calibration review. Independent actual-world review `W34313525_LIVE_FIELDS_AND_MODULES_ART_REVIEW.md` returned `KEEP_WITH_DOCUMENTED_LIMITATION` for exactly the two live `W34313525-MAT-PALE` field scopes and four complete module-atlas exemplars below. Lifecycle reconciliation records that verdict without promoting either side to a completed elevation or the receiver to whole-building acceptance.

Exact live scope:

- `CAL-FIELD-SSE-PALE-01`: SSE runs 8..12, 75.310910 m / 377.392952 m², world-tangent 0.88 m primary and 0.31 m secondary scale, zero per-run phase reset.
- `CAL-FIELD-NNW-PALE-01`: NNW runs 26..27, 15.936560 m / 80.510358 m², the same scale with continuity only inside this separate scope.
- `CAL-SSE-ROLLUP-PALE-01`: run 9 midpoint, complete `W34313525-ROLLUP-PALE`.
- `CAL-SSE-ROLLUP-GRAY-01`: run 10 midpoint, complete `W34313525-ROLLUP-GRAY`.
- `CAL-NNW-PERSONNEL-01`: run 26 midpoint, complete `W34313525-PERSONNEL`.
- `CAL-NNW-HIGH-GROUP-01`: run 27 midpoint, complete opaque `W34313525-HIGH-GROUP`; window-versus-grille semantics remain unresolved.

The 15 PNGs cover all five in-scope joins, a close view of every motif, ordinary SSE and NNW views, the 75.311 m SSE macro span and full 15.937 m NNW scope, multi-side/building context, changed light on both sides/material families, and whole-island context. Every image was inspected as a contact sheet and individually represented in `capture-manifest.json`; framing, motif completeness, scale cues, contrast, and luminance variation are valid for review.

Runtime topology is 729 records / 924 meshes / 934 surfaces / 50,729 triangles / 466 collider pairs. Against the previously accepted live world, this is +38 meshes / +40 surfaces / +456 triangles / +0 collider pairs: two receiver material surfaces plus 38 render-only module meshes. Modules own zero field/backing meshes, collisions, navigation, or spray behavior.

Still blocked: surveyed scale/dimensions/coordinates/count/cadence/sequence, maximum uncertainty-envelope containment for every module, HIGH-GROUP semantic disambiguation, all other runs/sides/modules, complete SSE or NNW elevation, cross-side transfer, massing/detail ownership, and whole-building resemblance/acceptance.

The independent review is sealed at SHA-256 `d11041e1abf41fc11843d2f2631e4c33da25f8fc565f93e6ee822589ad229f45`. Its evidence-identity paragraph cites the original capture-time manifest/ledger snapshots; the current corrected manifest is `bf97fc1df3b80e7d90cda9d9ca2cc3586681c7d3f3192cf76040835f51e49a1a`, with all 15 PNG bytes unchanged. The current ledger below pins the corrected manifest, this lifecycle status, the current focused contract, and the independent review; its non-recursive hash is published in the lifecycle handoff and canonical inventory.

Reproduce from the repository root:

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/w34313525_live_integration_capture.gd
```

Machine-readable sources: `capture-manifest.json`, `runtime-topology-delta.json`, `verification-results.txt`, and `asset-inventory.sha256`.

# Batch 06 prototype set 01 — independent module-correction art review

**Reviewed:** 2026-08-30  
**Reviewer:** art director (`/root/art_director`), independent of prototype authoring, correction, capture, and mechanical validation  
**Predecessor evidence:** `evidence/first-playable/batch-06-prototype-set-01-2026-08-30/`  
**Correction evidence:** `evidence/first-playable/batch-06-prototype-set-01-correction-2026-08-30/`  
**Targets:** `w34313564`, `w34313515`, `w291196370`  
**Evidence role:** controlled standalone render-only module correction; not exact-receiver, live-attachment, gameplay, or whole-building evidence

## Final decision

**All six corrected complete modules: ACCEPT as standalone prototypes, with physical scale and cadence still unmeasured.**

The correction resolves the common blocker in the predecessor review. The proof wall now owns one continuous homogeneous field, while each module owns only its complete opening motif: frame, mullions, glazing, door/service leaf, and truthful shallow trim. The former full-envelope host-color backing slabs are absent. Consequently, there are no invented facade-scale panels, fixed tan/pale surround patches, or siding-course resets around the modules.

This is module acceptance only. It does not accept physical dimensions, exact positions, repetition cadence, a receiver-side assignment, live attachment, or whole-building resemblance. The five previously accepted homogeneous fields were not re-reviewed; the correction records their scene/resource hashes as byte-identical noninterference.

No opposite-edge seamless-tile criterion was applied. These are complete bounded modules, not seamless whole-wall tiles.

No asset, shader, material, scene, factory, registry, runtime, test, lifecycle inventory, generated data, or evidence file was changed by this review.

## Per-building verdicts

### `w34313564`

| Module | Declared kind | Standalone verdict | Absolute finding |
|---|---|---|---|
| `W34313564-HWIN` | complete horizontal multi-pane window module | **ACCEPT** | The full four-pane motif, dark outer frame, mullions, glazing, and shallow depth remain complete and proportionally plausible at close and ordinary views. The predecessor's forward tan envelope is gone: no fixed host-color patch, rectangular halo, ledge, or unsupported facade seam remains. Changed light preserves the opening silhouette and frame depth. Physical size and cadence remain reversible assumptions. |
| `W34313564-PDOOR` | complete personnel-door module | **ACCEPT** | The full pale/gray leaf and dark frame remain complete and human-readable. Removing the pale backing envelope eliminates the predecessor's raised panel and vertical host-color seam without removing the door's truthful frame relief. Physical size, placement, and access context remain unmeasured/unclaimed. |

The current registry/factory structurally support both modules on the tan and pale host IDs: neither module emits host-field geometry, and both host materials are allowed. That resolves the prior fixed-surround incompatibility. The images deliberately show `HWIN` over tan and `PDOOR` over pale only, so this review does **not** infer an unseen exact-receiver placement or visually accept either motif on a specific unshown run.

### `w34313515`

| Module | Declared kind | Standalone verdict | Absolute finding |
|---|---|---|---|
| `W34313515-BAY` | complete three-tier horizontal-window bay module | **ACCEPT** | All three tiers remain present, each with a complete broad three-pane window group, full dark frame/mullions, muted blue-gray glazing, and useful shallow shadow depth. The predecessor's nearly full-height forward pale slab is gone: the continuous host field now forms the outer pier, with no readable module-envelope panel at close, ordinary, or changed light. Physical tier spacing, overall dimensions, and cadence remain reversible assumptions. |

`W34313515-VRECESS` remains **REFERENCE_BLOCKED** and unbuilt. The correction neither claims nor supplies the occlusion-sensitive lower/roof depth required to bound that motif.

### `w291196370`

| Module | Declared kind | Standalone verdict | Absolute finding |
|---|---|---|---|
| `W291196370-WINSTACK` | complete narrow vertical window-stack module | **ACCEPT** | The full tall white frame, three dark panes, and dividing rails remain complete and readable. The former raised siding rectangle is absent. Host courses continue across the wall around the opening without a module-envelope reset. Exact size and position remain unmeasured. |
| `W291196370-ENTRY` | complete dark personnel-entry module | **ACCEPT** | The complete dark leaf and immediate pale frame remain readable at ordinary distance and retain plausible shallow depth under changed light. The former siding patch and its cast panel edge are gone; no stairs, ramp, rails, or signage have been invented. |
| `W291196370-SERVICE` | complete pale service-opening module | **ACCEPT** | The pale gray-green service leaf, full pale frame, and motif-owned horizontal leaf seams remain a coherent complete opening. The large predecessor siding surround is absent. One host-owned siding field now visibly continues around the service opening; the leaf seams do not masquerade as restarted host siding. Physical opening size and site placement remain unmeasured. |

The corrected close, ordinary, and changed-light views show one continuous siding-course phase around all three module envelopes. No course patch, doubled course, or facade-scale backing rectangle remains. This accepts continuous host-field ownership in the standalone proof, not course phase across generated run joins on the exact receiver.

## Scope-separated eligibility

| Target | Standalone modules | Exact-receiver eligibility | Live attachment | Whole-building resemblance |
|---|---|---|---|---|
| `w34313564` | `HWIN`, `PDOOR`: **ACCEPT** | **ELIGIBLE FOR A CONTROLLED TRIAL; NOT ACCEPTED ON A RECEIVER.** Two-host compatibility is structurally truthful, but exact physical scale, motif coordinates, cadence, wall-orientation projection, and side-specific evidence remain unresolved. Mapped side groups do not locate an opening. | **BLOCKED.** No accepted exact module placement/scale/cadence or receiver-boundary proof; WSW remains unseen. | **REFERENCE_BLOCKED.** The modules and three field families do not establish the unseen side, massing, eave/access geometry, or complete object. |
| `w34313515` | `BAY`: **ACCEPT**; `VRECESS`: **REFERENCE_BLOCKED** | **ELIGIBLE FOR A CONTROLLED BAY TRIAL; NOT ACCEPTED ON A RECEIVER.** Exact bay dimensions, coordinates, cadence, level registration, and orientation projection remain unresolved. `VRECESS` is not eligible. | **BLOCKED.** Exact module placement, lower-region ownership, receiver transitions, and ENE/SSE reference coverage remain absent. | **REFERENCE_BLOCKED.** One accepted standalone bay and two observed elevations do not establish other sides, recess language, or massing. |
| `w291196370` | `WINSTACK`, `ENTRY`, `SERVICE`: **ACCEPT** | **ELIGIBLE FOR A CONTROLLED TRIAL; NOT ACCEPTED ON A RECEIVER.** Exact dimensions, opening coordinates/cadence, run-transition ownership, wall projection, and receiver-wide siding-course phase must still be proved. | **BLOCKED.** No exact-receiver placement or accepted transition/boundary evidence exists. | **REFERENCE_BLOCKED.** Three opening families and one siding field do not establish the unseen sides, yard facets, access context, or complete massing. |

## Evidence coverage

All nine corrected `1440 x 900` Forward+/Metal PNGs and all nine corresponding rejected predecessor PNGs were inspected at native resolution. Root and per-target manifests for both evidence sets were read, along with the correction README, verification record, asset inventory, generated-data diff, dirty-scope audit, current registry/factory, and the three target observation/spec records. The corrected views retain the predecessor camera/light matrix, permitting direct visual comparison.

| Target / view | Rejected predecessor SHA-256 | Corrected SHA-256 | Independent correction finding |
|---|---|---|---|
| `w34313564` close | `0d41cb1c4cba58bd21a3ba40c781943eb90f9313d7b11e4968755c939fb0371f` | `533be68c3982a93f07f98118b5b20b9940c956d55a19447c394561065505468b` | Full HWIN/PDOOR motifs remain; tan and pale forward envelopes are gone. |
| `w34313564` ordinary | `9d5e3e6bf9c78201ef7457b119919287fcacecf9ac7f8527a3601f19e4c1bbb1` | `3201ccaaa1bf00bf34a29c126def968f7d46cb4d6305557ca14d7dcf14ccc35d` | Both motifs remain legible without unsupported full-envelope panel seams. |
| `w34313564` changed light | `71e06c309b672e87b41650c8713ff0a3cfc4a7b34d071209252b4a92fe228d7a` | `522c0ad9238c8e9d85204fdcf08de66e218f1dd8b3a24b6060c9f460f48069e8` | Frame/leaf depth survives the changed light; removed surrounds no longer cast false facade shadows. |
| `w34313515` close | `26eb16bb437bba4d56b54ffd8dce34ec4315c1fb55efde280b8bfaebdd801448` | `8ea1ae244dc2edc2fe0e45ef1f9334ed023cabf1a4f69aae87e81b16c9bb3e35` | Cropped close view confirms clean frame/glass depth with no pale backing ledge. |
| `w34313515` ordinary | `a226a8b9645e618928ea47b120da77b3071ab368f080e2ce1c6aa11699a09c10` | `f74221eac6c2dad09ace375c4ef744aa92508ed6ec2b80f96e10ebbc5a764478` | All three tiers remain complete; the former full-height rectangular panel boundary is absent. |
| `w34313515` changed light | `765f03c2de8109ea296223f61d4f2ed0f492f72ca6806750f4df4038664ceca6` | `4808997da6c7384fafa4ba916af3fc6de4294130f821b4fecdb1a5403ab66761` | Three-tier hierarchy and shallow frames remain readable without an invented facade slab. |
| `w291196370` close | `7bbe8cb431b80bdbed0d8b99255fa5439e1be1dbd9c6c37dfce12c27190cc16c` | `d6d3e144e1e0ff01899e5fab0ca06825591a14b57feb9548a88e4fea9f8e6a27` | All three complete motifs remain; former siding rectangles and course-phase resets are removed. |
| `w291196370` ordinary | `b4afdc3255a50569192cb0381397d7a20490740e1fef98e0f5a9ccb4b0b18069` | `b14c1ed89e04283b41733ea23527ba5b9095c74b29731f20be9e8498a6673071` | Window, entry, and service silhouettes remain readable over one continuous siding field. |
| `w291196370` changed light | `a2f39a449f3903e862b6ae25d9f89b295cbe7a5849b60d7428bad5363fa90720` | `030caaab8a38b571cdffa3c7c7b456d4421064c126bdfc13c610069d01ab6399` | Trim/leaf depth remains plausible; no module-background panel reappears under oblique light. |

The correction manifest's five unchanged field/resource identities agree with the predecessor inventory. Mechanical checks additionally establish zero module-owned field meshes and zero host-field phase resets, but the visual verdict rests on the native images rather than those assertions alone.

## Next eligible proof scopes

1. `W34313564-HWIN` and `W34313564-PDOOR` may advance to a target-specific controlled exact-receiver calibration only after selecting reference-backed coordinates. Include each actually claimed host-color/side combination, metre scale, ordinary player view, changed light, and accepted-to-placeholder/run-transition boundaries.
2. `W34313515-BAY` may advance to a controlled exact-receiver calibration with reference-backed tier registration and dimensions. Keep `VRECESS` blocked and keep other sides/runs unchanged.
3. `W291196370-WINSTACK`, `ENTRY`, and `SERVICE` may advance to a controlled exact-receiver calibration that proves exact coordinates, motif scale, and one continuous siding-course phase across the tested receiver runs and their boundaries.
4. No corrected module is accepted for live attachment or whole-building resemblance. No further standalone module correction brief is required from this evidence round.

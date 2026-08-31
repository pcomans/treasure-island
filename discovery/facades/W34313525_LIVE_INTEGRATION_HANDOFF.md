# w34313525 bounded live integration handoff

Date: 2026-08-30  
Executor: `/root/w34313515_executor`  
Current lifecycle state after independent review reconciliation: `independently_accepted_live_keep_with_documented_limitation`  
Runtime source: `building:w34313525:wall` only

## Exact live scope

| Kind | ID | Side | Exact run(s) | Reviewed anchor / scale | Live result |
|---|---|---|---|---|---|
| homogeneous field | `CAL-FIELD-SSE-PALE-01` / `W34313525-MAT-PALE` | SSE | `8,9,10,11,12` | `0.88 m × 0.31 m`, world-tangent, zero join-phase delta | one record-owned material surface; `75.310910 m / 377.392952 m²` |
| homogeneous field | `CAL-FIELD-NNW-PALE-01` / `W34313525-MAT-PALE` | NNW | `26,27` | `0.88 m × 0.31 m`, world-tangent, zero join-phase delta | one record-owned material surface; `15.936560 m / 80.510358 m²` |
| module atlas | `CAL-SSE-ROLLUP-PALE-01` | SSE | `9` | midpoint `13.862233 m` | complete render-only exemplar; 13 meshes |
| module atlas | `CAL-SSE-ROLLUP-GRAY-01` | SSE | `10` | midpoint `16.003442 m` | complete render-only exemplar; 13 meshes |
| module atlas | `CAL-NNW-PERSONNEL-01` | NNW | `26` | midpoint `4.269684 m` | complete render-only exemplar; 5 meshes |
| module atlas | `CAL-NNW-HIGH-GROUP-01` | NNW | `27` | midpoint `3.698596 m` | complete opaque unresolved window-or-grille proxy; 7 meshes |

No other run, side, or module is attached. The four module transforms compare exactly with the independently accepted detached registry. Modules own zero field/backing meshes, collision, navigation, or spray state.

## Runtime topology

The prior independently accepted loaded world was `729 records / 886 meshes / 894 surfaces / 50,273 triangles / 466 collider pairs`. The current loaded world is `729 / 924 / 934 / 50,729 / 466`, an exact delta of `+0 records / +38 meshes / +40 surfaces / +456 triangles / +0 collider pairs`. The `+40` surfaces are two record-owned material surfaces plus 38 module surfaces. Record-owned topology is now `729 meshes / 739 surfaces / 48,389 triangles`.

Generated source/data, standalone assets, the exact calibration registry/helper, terrain, massing, other buildings, materials, player behavior, and all 15 capture PNG bytes remain unchanged.

## Native evidence

Evidence root: `evidence/first-playable/w34313525-live-fields-and-modules-2026-08-30/`

- 15 native `1440×900` Godot 4.7.2 Forward+/Metal images.
- Five exact field-join views.
- Complete close views for ROLLUP-PALE, ROLLUP-GRAY, PERSONNEL, and opaque HIGH-GROUP.
- Ordinary/macro SSE and NNW views, multi-side building context, changed light on both supported sides/material families, and whole-island context.
- Every image was inspected for validity, intended receiver visibility, motif completeness, contact, backing/halo/z-fight, field continuity, macro behavior, and changed-light response.

The manifest and checksum ledger mechanically validate all images and protected runtime inputs. A bookkeeping-only correction changed the manifest's record-surface baseline from `736→737` and live count from `736→739`; it changed no PNG byte, art, transform, scope, or runtime byte. Current manifest SHA-256 is `bf97fc1df3b80e7d90cda9d9ca2cc3586681c7d3f3192cf76040835f51e49a1a`; the current lifecycle evidence ledger is `88fec3d4bbabca5bfd0822db2e70b09e3f8d1608b00a5c29096a9adb7a159d86`.

## Verification

All commands used project-local Godot `4.7.2.stable.official.ed1daf0bf` headlessly except the completed native capture harness:

- w34313525 standalone prototype contract: PASS.
- w34313525 detached exact-receiver contract: PASS.
- w34313525 live integration contract: PASS.
- w34313525 live capture evidence contract: PASS.
- accepted-material run contract: PASS.
- Batch 06 exact-receiver and prototype contracts: PASS.
- w34313515, w291196370, w34313520, and w34313564 accepted-live regressions: PASS.
- YMCA tangent-projection regression: PASS.
- generated-world validation: PASS (`735 playable + 4 context`, 38 chunks, unchanged manifest).
- scene parse, gameplay, and world-material contracts: PASS.
- full runtime integration: PASS (`729 / 924 / 934 / 50,729 / 466`).
- ordinary ferry-to-Trade-Winds route: PASS (`14 checkpoints`, `262.349 m`, zero recovery/stall).
- whole-island route: PASS (`5 regions`, `3,449.107 m`, zero teleport/recovery/stall).
- evidence ledger: all entries PASS; generated/accepted-asset protected diff: empty.

The repeated sandbox-only macOS CA-certificate and shared `user://logs` warnings did not affect any gate result.

## Truth boundary and lifecycle result

Scale, dimensions, coordinates, count, cadence, sequence, maximum uncertainty-envelope containment, cross-side transfer, other sides/runs, completed SSE/NNW elevations, and whole-building resemblance remain blocked. HIGH-GROUP remains an opaque unresolved proxy.

Independent review `W34313525_LIVE_FIELDS_AND_MODULES_ART_REVIEW.md` (SHA-256 `d11041e1abf41fc11843d2f2631e4c33da25f8fc565f93e6ee822589ad229f45`) returned `KEEP_WITH_DOCUMENTED_LIMITATION` for both field scopes, all four placements, and the aggregate, with no correction. The bounded bookkeeping reconciliation promotes exactly `2 scopes / 7 runs / 91.247470 m / 457.903310 m²` and `4 placements / 38 meshes / 38 surfaces / 456 triangles`; pending actual-world review is now zero. Runtime/art/registry/helper/manifest/PNG/generated bytes and topology remain unchanged.

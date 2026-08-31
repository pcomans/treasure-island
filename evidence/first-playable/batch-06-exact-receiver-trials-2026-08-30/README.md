# Batch 06 controlled exact-receiver field trials

Captured: **2026-08-30**  
Renderer: **Godot 4.7.2 / Forward+ / Metal / Apple M1 Pro**  
Status: **ready for independent exact-receiver gameplay art review; not self-accepted**

This evidence covers only four homogeneous-field runtime trials on three source-exact wall receivers. It is not module evidence, lifecycle acceptance, live-attachment acceptance, or whole-building resemblance proof.

## Exact trial scope

| Source / receiver | Field | Exact run groups | Length | Placeholder complement |
|---|---|---:|---:|---|
| `w34313564` / `building:w34313564:wall` | `W34313564-MAT-TAN` | `5..9` | `87.651 m` | runs `0..4` |
| `w34313564` / `building:w34313564:wall` | `W34313564-MAT-PALE` | `10..19` | `141.340 m` | runs `0..4` |
| `w34313515` / `building:w34313515:wall` | `W34313515-MAT-PALE` | `0..8`, `43..47` | `165.100 m` | runs `9..42` |
| `w291196370` / `building:w291196370:wall` | `W291196370-SIDING` | `8..10`, `17..22` | `97.893 m` | runs `0..7`, `11..16`, `23..35` |

The accepted standalone `W34313564-MAT-PLINTH` field has **zero runtime surfaces**. Its exact vertical extent and side bounds remain unresolved, and a run-only partition cannot isolate it without a prohibited geometry split.

All six complete modules have **zero runtime instances and zero runtime surfaces**: `W34313564-HWIN`, `W34313564-PDOOR`, `W34313515-BAY`, `W291196370-WINSTACK`, `W291196370-ENTRY`, and `W291196370-SERVICE`.

## Preserved contract

- Reviewed standalone field resources remain byte-identical.
- Target-specific trial materials change only the vertex projection to wall-tangent horizontal metres and world-vertical metres; all reviewed field parameters are copied exactly.
- The siding course phase is `VERTEX.y / 0.20 m`, independent of generated U and continuous across each accepted group.
- Generated geometry, vertices, indices, triangles, massing, terrain, foundations, collision, navigation, spray ownership, and source identity are unchanged.
- Runtime topology is `729 meshes / 736 disjoint surfaces / 48,389 triangles / 466 collider pairs`. The `+7` surface delta is exactly `+3` from the retained accepted Chapel/Dormitory/YMCA partitions and `+4` from these controlled trials.
- Render and collision triangle signature sets match on all three target receivers; no duplicate/coplanar render triangle was found.

## Evidence matrix

Each target has five `1440 × 900` images:

1. close field view;
2. ordinary gameplay-distance view on the second relevant orientation where applicable;
3. changed-light oblique view;
4. corner/orientation-transition view;
5. accepted-to-placeholder or placeholder-to-accepted transition view.

One additional whole-island aerial proves the clean `38/38` chunk load and runtime totals. All 16 images were inspected for nonblank native rendering, target visibility, camera diversity, and required boundary/orientation coverage only. No image was graded for art acceptance by the executor.

Exact camera transforms, light rotations, run endpoints, image hashes, material identities, topology attribution, plinth blocker, and zero-module declaration are in `capture-manifest.json`. The complete evidence and implementation hash list is in `asset-inventory.sha256`.

## Independent review handoff

The reviewer should grade only:

- `w34313564`: tan and pale physical-scale behavior, the run `9→10` tan/pale corner, pale orientation change `13→14`, and placeholder boundary `4→5`;
- `w34313515`: pale-field behavior on both mapped chains, the accepted wrap corner `47→0`, and the `8→9` placeholder boundary;
- `w291196370`: `0.20 m` siding course readability and phase, SSE/ENE orientation behavior, and the `10→11` / `22→23` placeholder boundaries.

The field scales remain reversible unmeasured assumptions. Do not infer plinth extent, windows, doors, bays, service openings, cadence, dividers, access geometry, unseen sides, massing, or whole-building resemblance from this set.

# `w291196370` three-motif live integration evidence

Status: `independently_accepted_live_exact_three_placements_KEEP_WITH_DOCUMENTED_LIMITATION`

This package proves that exactly three independently detached-placement-reviewed complete `module_atlas` motifs are attached to the actual generated receiver `building:w291196370:wall` without changing their reviewed transforms. A subsequent independent actual-world review accepted those exact live placements with `KEEP_WITH_DOCUMENTED_LIMITATION`:

| Placement | Motif | Face / region | Ordered run chain | Exact anchor | Uncertainty and truth status |
|---|---|---|---|---|---|
| `CAL-SSE-WINSTACK-01` | `W291196370-WINSTACK` | SSE / observed public elevation | `8..10` | run `8`, chain center `5.5 m` | `±2.0 m`; stylized/reference-derived production inference, not surveyed |
| `CAL-SSE-ENTRY-01` | `W291196370-ENTRY` | SSE / observed public elevation | `8..10` | run `10`, chain center `32.0 m` | `±3.0 m`; stylized/reference-derived production inference, not surveyed |
| `CAL-ENE-SERVICE-01` | `W291196370-SERVICE` | ENE / observed outer end | `17..22` | run `20`, chain center `39.5 m` | `±4.0 m`; stylized/reference-derived production inference, not surveyed |

The three rows are bounded exemplars, one per accepted standalone motif type. Their coordinates, dimensions, count, envelopes, and visible spacing do not establish surveyed scale, the real opening count, cadence, a completed SSE or ENE elevation, cross-side transfer, or whole-building resemblance.

## Reviewed geometry and placement identity

The live adapter reuses the reviewed detached module geometry without scale, dimension, transform, placement, or material reinterpretation:

- calibration registry SHA-256: `b30a8f19091288cde4b8e891ec40287ab28a73776588f96ee86fc5565cfc25b8`;
- reviewed detached geometry helper SHA-256: `ba621cffc5ee155e8b7c7338c3b5d444d1180dad6dbe11528219ada6de05dfdf`;
- independent detached placement review SHA-256: `967ab07d109096a743be01fb0bce959280967f5eab65c82ac0652eb5dcd3023b`;
- independent actual-world review SHA-256: `410ffa891bdebe92d689155b4c7986f7e9a07bef1028900cd0dac00bcb8222ca`;
- predecessor detached evidence manifest SHA-256: `5a92402a7a6742c5c67fa18e904c1af5055c9aaacf6e3001ebb20fb26e738df0`.

WINSTACK, ENTRY, and SERVICE remain three distinct complete `module_atlas` motifs, not seamless wall tiles. No module-owned field or backing mesh exists. The accepted `W291196370-SIDING` field remains continuous and solely owns every nonopening wall pixel on runs `8..10` and `17..22`.

## Mechanical result

The generated source world remains `729` meshes, `736` surfaces, `48,389` triangles, and `466` body/shape pairs. Before this integration the loaded world reported `847 / 854 / 49,805 / 466` meshes/surfaces/triangles/collider pairs.

This exact three-placement delta is:

- `3` module nodes: one WINSTACK, one ENTRY, and one SERVICE;
- `24` render-only mesh instances, `24` surfaces, and `288` triangles;
- `0` module-owned field meshes and `0` backing meshes;
- `0` collision, navigation, or spray nodes.

The loaded-world result is `729 records / 871 meshes / 878 surfaces / 50,093 triangles / 466 collider pairs`. The generated wall remains the sole collision and spray authority. The accepted siding receiver surface, exact run ownership, material, and continuous global course phase are unchanged. Placeholder runs `0..7`, `11..16`, and `23..35`, terrain, foundations, massing, roofs, player behavior, other buildings, prior modules, generated data, and existing materials are unchanged.

## Native evidence

Nine fresh 1440×900 images were captured from the actual loaded world using Godot 4.7.2, Forward+, Metal, and Apple M1 Pro:

1. `01-close-sse-winstack.png` — close actual-live WINSTACK on SSE run `8`;
2. `02-close-sse-entry.png` — close actual-live ENTRY on SSE run `10`;
3. `03-close-ene-service.png` — close actual-live SERVICE on ENE run `20`;
4. `04-ordinary-sse-public-context.png` — ordinary gameplay-height/distance SSE view containing WINSTACK and ENTRY;
5. `05-ordinary-ene-outer-context.png` — ordinary gameplay-height/distance ENE view containing SERVICE;
6. `06-sse-ene-multi-side-context.png` — supported-side building context containing all three motifs and visible protected facets;
7. `07-changed-light-oblique-sse.png` — the exact SSE pair under alternate light;
8. `08-changed-light-exact-ene-service-run20.png` — the exact ENE SERVICE/run-20 placement under alternate light, closing the detached review's explicit view-level gap;
9. `09-whole-island-load.png` — whole-island load/noninterference context.

The nine images were first inspected by the integration executor only for evidence validity. A separate independent art director subsequently graded the actual-world pixels and returned `KEEP_WITH_DOCUMENTED_LIMITATION` for every registered placement and the exact three-placement set in `discovery/facades/W291196370_LIVE_MODULES_ART_REVIEW.md`. No correction or revert was requested.

Renderer identity, exact transforms and inference labels, capture-time protected hashes, topology before/after, receiver ownership, camera/light settings, and per-image hashes are recorded in `capture-manifest.json`. Test and route results are recorded in `verification-results.txt`.

## Remaining truth boundary

- Exact real-world module scale, coordinates, total count, cadence, divider rhythm, and alternate sequence remain unmeasured or unknown.
- SERVICE is not transferred to SSE; WINSTACK and ENTRY are not transferred to ENE.
- NNW, WSW, short/service/yard facets, runs `0..7`, `11..16`, and `23..35`, and every additional opening own zero new module instances.
- Trim/accent cadence, stairs, ramp, rails, adjacent personnel openings, parapet/access/yard context, and other details remain excluded or reference-blocked.
- These three exemplars do not complete either observed elevation and do not establish facade-language or whole-building acceptance.
- The independent actual-world keep verdict accepts only these three fixed transforms. It does not relax any scale/coordinate/count/cadence, cross-side, completed-elevation, facade-language, or whole-building blocker above.

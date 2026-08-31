# `w34313515` four-BAY live integration evidence

Status: `independently_accepted_live_exact_four_placements_KEEP_WITH_DOCUMENTED_LIMITATION`

This package proves that exactly the four independently placement-approved `W34313515-BAY` exemplars are attached to the actual generated receiver `building:w34313515:wall` without changing their reviewed detached transforms. A subsequent independent actual-world review accepted those exact live placements with `KEEP_WITH_DOCUMENTED_LIMITATION`:

| Placement | Face / region | Ordered run chain | Exact anchor | Uncertainty and truth status |
|---|---|---|---|---|
| `CAL-WSW-BAY-01` | WSW / observed outer elevation | `0..8` | run `0`, chain center `6.0 m` | `±1.2 m`; stylized/reference-derived production inference, not surveyed |
| `CAL-WSW-BAY-02` | WSW / observed outer elevation | `0..8` | run `6`, chain center `71.5 m` | `±3.0 m`; stylized/reference-derived production inference, not surveyed |
| `CAL-NNW-BAY-01` | NNW / observed outer elevation | `43..47` | run `44`, chain center `14.0 m` | `±3.0 m`; stylized/reference-derived production inference, not surveyed |
| `CAL-NNW-BAY-02` | NNW / observed outer elevation | `43..47` | run `47`, chain center `55.5 m` | `±3.0 m`; stylized/reference-derived production inference, not surveyed |

The four rows are bounded exemplars. Their coordinates, count, and envelopes do not establish a surveyed schedule, the real total opening count, a cadence, a completed elevation, or whole-building resemblance.

## Reviewed geometry and placement identity

The live adapter reuses the reviewed detached module geometry without scale, dimension, transform, placement, or material reinterpretation:

- calibration registry SHA-256: `2d378a94da4b7badd334d5c00f926a26a4ff9109782abb18e4859301df4b5c1d`;
- reviewed detached geometry helper SHA-256: `1edfdf4b736a7b1cc2883569a4c09b48814cabf30e3056e9dac86152de22d5f1`;
- independent placement review SHA-256: `894873141bc589e51bb8ec65e06455461e17a809a18608253db59c7e49e5fedd`;
- independent actual-world review SHA-256: `cebfe328ec5372f8c0d440fcf59bb0b9bae7a490998ed373d8f5c5e418b5b94e`;
- predecessor detached evidence manifest SHA-256: `9b9e7e9d21539009cfc401f22017220bf3f2224061b57c0d48819325cab7f09b`.

`W34313515-BAY` remains a complete three-tier `module_atlas` motif, not a seamless wall tile. Each live exemplar contains the same 3 complete glazing groups, 12 frame bars, and 6 mullions as the reviewed detached output. No module-owned field or backing mesh exists.

## Mechanical result

The generated source world remains `729` meshes, `736` surfaces, `48,389` triangles, and `466` body/shape pairs. Before this integration the loaded world included the five previously accepted `w34313564` modules and reported `763 / 770 / 48,797 / 466` meshes/surfaces/triangles/collider pairs.

This exact BAY-only delta is:

- `4` module nodes, all `W34313515-BAY`;
- `84` render-only mesh instances, `84` surfaces, and `1,008` triangles;
- `0` module-owned field meshes and `0` backing meshes;
- `0` collision, navigation, or spray nodes.

The loaded-world result is `729 records / 847 meshes / 854 surfaces / 49,805 triangles / 466 collider pairs`. The generated wall remains the sole collision and spray authority. The accepted pale homogeneous field is still the sole non-opening field on runs `0..8` and `43..47`; its two receiver surfaces, material, and exact run ownership are unchanged. Placeholder runs `9..42`, terrain, foundations, massing, roofs, player behavior, other buildings, prior modules, generated data, and existing materials are unchanged.

## Native evidence

Seven fresh 1440×900 images were captured from the actual loaded world using Godot 4.7.2, Forward+, Metal, and Apple M1 Pro:

1. `01-close-wsw-bay.png` — close actual-live WSW run-0 BAY;
2. `02-close-nnw-bay.png` — close actual-live NNW run-44 BAY;
3. `03-ordinary-wsw-context.png` — gameplay-height/distance WSW run-6 context;
4. `04-ordinary-nnw-context.png` — gameplay-height/distance NNW context containing both NNW exemplars;
5. `05-wrap-corner-two-side-context.png` — WSW/NNW corner and multi-side view containing the two near-corner exemplars;
6. `06-changed-light-oblique-wsw-bay.png` — actual-live WSW run-6 BAY under the alternate light direction;
7. `07-whole-island-load.png` — whole-island load/noninterference context.

The seven images were first inspected by the integration executor only for evidence validity. A separate independent art director subsequently graded the actual-world pixels and returned `KEEP_WITH_DOCUMENTED_LIMITATION` for every registered placement and the exact four-placement set in `discovery/facades/W34313515_LIVE_MODULES_ART_REVIEW.md`. No correction or revert was requested.

Renderer identity, exact transforms and inference labels, protected input hashes, topology before/after, receiver ownership, camera/light settings, and per-image hashes are recorded in `capture-manifest.json`. Test and route results are recorded in `verification-results.txt`.

## Remaining truth boundary

- Exact real-world BAY coordinates, total count, cadence, tier registration, and physical dimensions remain unmeasured or unknown.
- ENE, SSE, re-entrant/short facets, and runs `9..42` own zero BAY instances.
- `W34313515-VRECESS`, lower/recess regions, doors, entry grammar, roof/recess depth, and other openings/details remain reference-blocked or unaccepted.
- These four exemplars do not complete either observed elevation and do not establish facade-language or whole-building acceptance.
- The independent actual-world keep verdict accepts only these four fixed transforms. It does not relax any coordinate/count/cadence, completed-elevation, facade-language, or whole-building blocker above.

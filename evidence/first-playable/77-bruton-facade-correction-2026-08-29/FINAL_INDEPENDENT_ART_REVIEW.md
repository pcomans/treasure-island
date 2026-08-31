# Final independent art review — Hawkins facade correction

Reviewed: **2026-08-29**  
Reviewer: `/root/hawkins_texture_v2_review` (independent of implementation)  
Target: Hawkins / 77 Bruton Street, exact receiver `building:w1249412093:wall`  
Decision: **ACCEPT_WITH_DOCUMENTED_MASSING_LIMITATION**

## Final decision

The finite correction round resolves both prior facade-language rejectors at directly comparable poses and introduces no new art defect. The standalone material/module system and its application to the exact current receiver pass the bounded Hawkins facade-language gate.

This is not acceptance of faithful whole-building resemblance. The current object is still the invariant `6.0 m` extrusion, while real Hawkins is a six-story main mass plus a lower companion volume. The accepted scope is the material hierarchy, complete module grammar, observed-side cadence, address recognition, and receiver behavior on that frozen mass.

## Evidence integrity and comparability

- Every entry in the correction `asset-inventory.sha256` verifies.
- A field-by-field comparison of the pilot and correction manifests confirms identical viewport, default sun, global FOV, and all five per-view player, camera, aim, ground, spring, side-position, distance, and changed-light transforms.
- Both suites are `1440 x 900`, Godot `4.7.2`, Forward+/Metal on Apple M1 Pro with the normal `70°` third-person camera.
- Target identity remains `building:w1249412093:wall`, source `w1249412093`; the corrected layout hash is `2debe810737a98fef19ceaa0bfe6ec241abf3cafdcac3aea8f005eed42cdd8e6` and facade signature is `6fc4d5aee82a5a496c3e77d3752fe07f18e798a1dba4364a3671fccc8d0d8161`.
- The owner reference was inspected through the existing private temporary conversion with the expected SHA-256 `6b6a0f95902bd48c57c4f69b6bd7b97346c672d71c1b300d394170f6447db5cd`. Per task boundary, no browsing or external imagery access was performed.

## Prior rejector resolution

### 1. Fine-flute sampling — **RESOLVED**

Before, `01`, `03`, `04`, and `05` showed sparse bright/dark dashes and broad diagonal moire produced by individual `64 mm` flute boxes. After correction:

- `01-address-close.png` shows a clean light pearlescent field with restrained continuous vertical response and no dashed sparkle, diagonal band, grid, or foundation-segment phase reset.
- `03-broad-gameplay-camera.png` lets the fine relief recede to the base coating at ordinary distance instead of producing a larger accidental pattern.
- `04-corner-oblique-gameplay.png` remains stable across the long observed sides and their corner; no oblique shimmer, clipping, or cadence restart appears.
- `05-address-changed-light.png` remains clean under the changed sun. The light response changes without exposing baked shading or reviving the rejected interference pattern.

The band-limited tangent-space normal is the correct representation for this subpixel-scale relief. Its attenuation is subordinate material behavior, not loss of a facade motif.

### 2. WSW opening grammar and ground cadence — **RESOLVED**

Before, the WSW lower half was a long blank grey band and `W-P` used a center-only vertical split. After correction:

- Every `W-P` is still a complete tall opening with full head, sill, and both jambs, now with one complete low horizontal transom/lower pane matching the owner-photo opening character.
- `03-broad-gameplay-camera.png` clearly shows a lower row of complete openings aligned to the main upper cadence rather than an undifferentiated base strip.
- The layout assigns `15` complete `G-W` modules to the main WSW region and `2` to the sparser companion region. `04-corner-oblique-gameplay.png` preserves that regional difference without wrapping the cadence around the address corner.
- No new lobby, sign, service, garage, or entrance program was copied onto WSW; the correction adds only the owner-supported generic ground-opening family.

## Separated verdicts

| Scope | Verdict | Basis |
|---|---|---|
| Standalone fluted/plain/base materials | **PASS** | Low-chroma dielectric palette, scalar roughness hierarchy, filtered fine relief, no baked light/reflection, and no facade-scale alias or macro repeat under either retained sun. |
| Standalone modules | **PASS** | `W-P`, `W-N`, `S-H`, `R-C`, `G-W`, lobby, paired door, service door, garage, sign, and band are complete bounded motifs; no frame, transom, sill, door, grille, or letter is edge-composed. |
| Exact current receiver — mechanical | **PASS_AS_EVIDENCED** | Exact target/hash/signature records, side-local placement, unchanged collision/generated geometry, and the live spray hit remain coherent. |
| Exact current receiver — art | **PASS** | Close, ordinary, oblique, sprayed, and changed-light frames preserve scale, cadence, hierarchy, recognition, and stable sampling without new defects. |
| Whole-building real-world resemblance | **BLOCKED_BY_CURRENT_MASSING_INVARIANT** | The accepted facade language is applied to a `6.0 m` extrusion and cannot reproduce the real six-story plus lower-companion volume, roofline, terrace, or story stack. |
| Overall facade-language verdict | **ACCEPT_WITH_DOCUMENTED_MASSING_LIMITATION** | All facade/material/module/receiver gates pass; only prohibited massing prevents a whole-building acceptance claim. |

## Remaining gate review

- Material hierarchy: **pass**. Light pearlescent upper field, darker smooth/ribbed base, charcoal frames, muted cool opaque glass, pale sills, and dark service/garage fields remain legible and clean.
- Albedo neutrality and changed-light behavior: **pass**. No fixed highlight, facade-depth shadow, AO band, scenery reflection, mirror response, heavy weathering, or stain appears.
- Scale and ordinary-camera readability: **pass**. The upper and lower modules read as openings at close and route distance; the fine flutes remain material-scale instead of becoming architecture-scale marks.
- Joins and motif integrity: **pass**. No clipped or resized module is visible at a side endpoint, corner, or foundation subdivision. The procedural field creates no tile edge, doubled rib, or four-way product.
- Address-side recognition: **pass**. `HAWKINS`, lobby/storefront, paired entrance, service door, and garage remain complete, distinct, one-off address elements in `01`, `02`, `04`, and `05`.
- Spray view: **pass**. `02-address-close-sprayed.png` visibly retains the tag on the facade, while the manifest records the underlying exact wall receiver and source identity.
- Unobserved-side restraint: **pass as evidenced by the hashed layout and retained contract record**. ENE and NNW remain material-only with empty window, connector, ground-region, and ground-module schedules; the correction does not claim unique rear/courtyard detail.
- New art defects: **none found**. The correction adds no aliasing, macro grid, over-strong normal, false metal, clipped motif, unauthorized address program, inconsistent cadence, or corner artifact.

## Per-view final findings

- `01-address-close.png`: stable fine field, corrected horizontal window subdivision, readable address hierarchy, and complete modules.
- `02-address-close-sprayed.png`: same art result plus verified spray projection on the unchanged exact receiver.
- `03-broad-gameplay-camera.png`: strongest correction evidence; the blank WSW base is replaced by a complete ground-opening cadence and the prior moire is absent.
- `04-corner-oblique-gameplay.png`: stable material sampling and intact modules across the observed corner; main-versus-companion WSW cadence remains regional rather than global.
- `05-address-changed-light.png`: no return of dashed sparkle or diagonal interference; palette and relief remain neutral under the changed sun.

## Residual limitation

The result remains a reference-bounded facade-language adaptation, not a rectified as-built elevation. It retains one adapted upper row, shallow opaque-glass proxies, production-estimate placement, material-only unobserved sides, and the frozen low mass. No further routine facade correction is indicated by this review; any future faithful whole-building Hawkins proposal is a separate massing decision outside this acceptance.

# Accepted material exact-run trials: independent gameplay art review

**Review date:** 2026-08-29

**Reviewer:** independent gameplay art reviewer (`/root/hawkins_reference_spec`); reviewer did not implement, author, or capture the trials

**Evidence:** [`accepted-material-run-trials-2026-08-29`](../../evidence/first-playable/accepted-material-run-trials-2026-08-29/README.md)

## Final decisions

| Building and exact live scope | Standalone material | Exact receiver | Whole object | Next playable build |
| --- | --- | --- | --- | --- |
| Navy Chapel `building:w291189336:wall`, runs `9,10`, `16.362 m` | **ACCEPT_WITH_DOCUMENTED_LIMITATION** | **ACCEPT_WITH_DOCUMENTED_LIMITATION** | **REJECT_REFERENCE_BLOCKED** | **May remain.** Keep only the warm-cream albedo/roughness background on runs `9,10`; no substrate, relief, opening, gable, symbol, porch, roof, or other-run claim. |
| Fire Station 48 `building:w764313741:wall`, runs `0,1,2,3,5,6,8,9,24,25`, `76.157 m` | **ACCEPT_WITH_DOCUMENTED_LIMITATION** | **REJECT_CORRECTABLE** | **REJECT_REFERENCE_BLOCKED** | **May not remain.** Return this exact live trial to the placeholder until the one correction below receives fresh close/ordinary/changed-light receiver proof and independent re-review. |
| Dormitory 369 `building:w291189926:wall`, runs `0..5`, `49.124 m` | **ACCEPT_WITH_DOCUMENTED_LIMITATION** | **ACCEPT_WITH_DOCUMENTED_LIMITATION** | **REJECT_REFERENCE_BLOCKED** | **May remain.** Keep only the smooth warm-wall albedo/roughness field on runs `0..5`; the five-tier/default-`6 m` conflict and every facade module remain unresolved. |
| Whole-island load | not applicable | not applicable | **ACCEPT_WITH_DOCUMENTED_LIMITATION** as load proof only | The `38 / 38`-chunk world loads with the three captured trials, but this aerial frame supplies no target-specific art acceptance. Fire Station's art rejection still controls its build decision. |

The result is two bounded live trials that may remain, one correctable exact-receiver rejection that may not remain, and zero whole-building art acceptances. A homogeneous field is not penalized for lacking windows; the whole-object verdicts are separated specifically so missing massing/modules are not misreported as material defects.

## Post-review implementation disposition

**Removal executor update, 2026-08-29:** the rejected Fire Station 48 exact-run attachment was removed from runtime after this independent decision. `building:w764313741:wall` is restored to one generated placeholder surface across all 26 runs; the rejected run list `0,1,2,3,5,6,8,9,24,25` now has no live accepted-material surface. Navy Chapel runs `9,10` and Dormitory 369 runs `0..5` remain exactly as accepted. The Fire Station material, shared shader, Batch 03 registry, prior rejection captures, generated data, geometry, collision, and spray ownership remain unchanged.

Current exclusion/restored-placeholder proof: [`fire-station-48-live-trial-removal-2026-08-29`](../../evidence/first-playable/fire-station-48-live-trial-removal-2026-08-29/README.md). This implementation disposition records compliance with the review; it does not alter the reviewer’s verdict or authorize the bounded correction described below.

**Lifecycle status, independently verified 2026-08-29:** [`FIRE_STATION_48_EXCLUSION_REVIEW.md`](FIRE_STATION_48_EXCLUSION_REVIEW.md) **ACCEPTS the exclusion/reversion and marks the current combined worktree ready to launch.** The rejected Fire attachment is absent at close, ordinary, and changed-light views; Fire has one generated placeholder surface over all `26` runs with no accepted-material metadata; Chapel and Dormitory remain on their exact accepted scopes; and the whole-island load gate passes. This lifecycle result does not change Fire's original `REJECT_CORRECTABLE` exact-receiver verdict, accept the placeholder or whole object, or authorize correction/reattachment.

## Review boundary and baseline

This review applies the absolute criteria from the building-texture skill. It does not compare the trials with gray placeholders as an acceptance standard. The prior standalone verdicts come from [`BATCH_02_04_MATERIAL_ART_REVIEW.md`](BATCH_02_04_MATERIAL_ART_REVIEW.md); this round adds live receiver, transition, changed-light, and whole-object evidence.

The reference/mapping contracts are:

- Navy Chapel: [`reference spec`](NAVY_CHAPEL_BUILDING_187_REFERENCE_SPEC.md), [`Batch 02 observation ledger`](BATCH_02_STREETVIEW_OBSERVATIONS.md), and [`Batch 02 run map`](BATCH_02_RUN_MAPPING.md);
- Fire Station 48: [`reference spec`](FIRE_STATION_48_REFERENCE_SPEC.md), [`Batch 03 observation ledger`](BATCH_03_STREETVIEW_OBSERVATIONS.md), and [`Batch 03 run map`](BATCH_03_RUN_MAPPING.md);
- Dormitory 369: [`reference spec`](JOB_CORPS_DORMITORY_BUILDING_369_REFERENCE_SPEC.md), [`Batch 04 observation ledger`](BATCH_04_STREETVIEW_OBSERVATIONS.md), and [`Batch 04 run map`](BATCH_04_RUN_MAPPING.md).

The implementation handoff and [`capture-manifest.json`](../../evidence/first-playable/accepted-material-run-trials-2026-08-29/capture-manifest.json) pin unchanged reviewed material hashes, exact run scopes, renderer, transforms, world counts, zero modules, and preserved geometry/physics/source contracts. Mechanical success is evidence, not an art verdict.

## Ten-image manifest accounting

Every manifest-indexed PNG is cited exactly once below. The close, ordinary, and changed-light camera-to-aim distances are approximately `7.1–7.6 m`, `24.0–24.2 m`, and `17.7–17.8 m`; all use a `50°` FOV.

| Manifest role | Exact PNG | Independent finding |
| --- | --- | --- |
| Chapel close live receiver | [`navy-chapel-187/01-close.png`](../../evidence/first-playable/accepted-material-run-trials-2026-08-29/images/navy-chapel-187/01-close.png) | Warm cream reads as a matte, nearly flat color/finish field. No seam, alias, false slit/window, relief, or facade-scale motif is visible in the close bound. |
| Chapel ordinary gameplay distance | [`navy-chapel-187/02-ordinary-gameplay-distance.png`](../../evidence/first-playable/accepted-material-run-trials-2026-08-29/images/navy-chapel-187/02-ordinary-gameplay-distance.png) | The cream field is coherent across the full accepted source-edge reconstruction, meets terrain cleanly, and ends at ordinary geometric boundaries without a coplanar artifact. The simple box remains unrecognizable as the observed chapel. |
| Chapel changed-light oblique | [`navy-chapel-187/03-changed-light-oblique.png`](../../evidence/first-playable/accepted-material-run-trials-2026-08-29/images/navy-chapel-187/03-changed-light-oblique.png) | Matte response remains stable and nonmetallic; the field cools with the new light without baked highlight/shadow or visible repetition. No substrate/relief conclusion follows. |
| Fire Station close live receiver | [`fire-station-48/01-close.png`](../../evidence/first-playable/accepted-material-run-trials-2026-08-29/images/fire-station-48/01-close.png) | Pale muted sage-gray hue, flat normal, and matte roughness are plausible locally. The framing is too narrow to reveal the long-wave repeat that fails at gameplay distance. |
| Fire Station ordinary gameplay distance | [`fire-station-48/02-ordinary-gameplay-distance.png`](../../evidence/first-playable/accepted-material-run-trials-2026-08-29/images/fire-station-48/02-ordinary-gameplay-distance.png) | **Failure evidence:** conspicuous broad vertical light/dark bands repeat across the long flat face. They read as unsupported facade panels/divisions rather than a phase-neutral flat wall, contradicting the declared flat substrate-neutral role. Terrain-following lower edges remain coherent and no duplicate triangle is visible. |
| Fire Station changed-light oblique | [`fire-station-48/03-changed-light-oblique.png`](../../evidence/first-playable/accepted-material-run-trials-2026-08-29/images/fire-station-48/03-changed-light-oblique.png) | Hue/value remain plausible and the flat normal produces no specular alias, but the broad spatial modulation survives as large-scale value drift. Changed light therefore does not cure the ordinary-distance rejection. |
| Dormitory close live receiver | [`dormitory-369/01-close.png`](../../evidence/first-playable/accepted-material-run-trials-2026-08-29/images/dormitory-369/01-close.png) | Smooth light warm-gray/off-white field reads matte and phase-neutral at close range, without false tier/window/slit, relief, or pixel instability. The pale lower strip is adjacent ground/context, not a daylight gap in the captured edge. |
| Dormitory ordinary gameplay distance | [`dormitory-369/02-ordinary-gameplay-distance.png`](../../evidence/first-playable/accepted-material-run-trials-2026-08-29/images/dormitory-369/02-ordinary-gameplay-distance.png) | Soft low-frequency variation is perceptible but remains subordinate rather than a panel register or focal repeat. The `49.124 m` accepted chain reads continuously, the terrain/path contact is closed, and no accepted-to-placeholder z-fight appears. The fallback-height box cannot express the observed five tiers. |
| Dormitory changed-light oblique | [`dormitory-369/03-changed-light-oblique.png`](../../evidence/first-playable/accepted-material-run-trials-2026-08-29/images/dormitory-369/03-changed-light-oblique.png) | Warm field remains a stable matte gray under the changed sun, with no moiré, false architectural motif, harsh phase reset, or relief reversal. The view reinforces the unresolved massing/recognizability failure. |
| Whole-island load proof | [`whole-island/whole-island-load.png`](../../evidence/first-playable/accepted-material-run-trials-2026-08-29/images/whole-island/whole-island-load.png) | Full island content is visibly present in one aerial render and the overlay records `38/38` chunks, `729` meshes, `732` surfaces, `48,389` triangles, and `466` collision bodies/shapes. Altitude and overlay make this load proof, not target art evidence. |

## Absolute target findings

### Navy Chapel

- **Reference/material identity:** The warm off-white/cream value and matte/low-satin response fit the only defensible substrate-neutral observation. It does not invent siding, stucco relief, stained glass, symbols, windows, or porch detail.
- **Scale/repetition/aliasing:** The declared `1.65 m` variation scale remains unmeasured. Within the exact `16.362 m` run scope, variation stays visually subordinate at close, ordinary, and changed light; no repeated facade-scale cell, seam, moiré, or false slit appears.
- **Exact-run transition:** Runs `9,10` reconstruct one source edge. Visible ends occur at geometric boundaries; no mid-face placeholder seam, coplanar overlap, or z-fight appears. The cream-versus-placeholder color change on other faces is a documented incomplete-facade state, not permission to propagate.
- **Terrain/geometry:** The field reaches the existing terrain-following bottom with no visible floating band. The trial changes no gable, roof, belfry, cross, porch, collision, or spray surface.
- **Whole object:** **REJECT_REFERENCE_BLOCKED.** The current simple receiver does not reproduce the observed gabled hall, entry, belfry/cross, long-side windows, or unknown sides. Those are geometry/module/reference blockers outside this homogeneous-field verdict.

### Fire Station 48

- **Reference/material identity:** The local pale sage-gray/warm-gray hue and matte `0.81` roughness remain plausible. Flat normals/zero relief correctly preserve the unresolved substrate limitation.
- **Scale/repetition/aliasing:** The exact receiver exposes a failure hidden by the smaller standalone panel. The shared painted-field shader's low-frequency albedo modulation becomes a repeating sequence of broad vertical value bands over the mapped long face. At roughly facade-bay scale, it implies divisions unsupported by the observation; this is a hard material-role failure even though it neither shimmers nor creates literal windows.
- **Exact-run transition:** Disjoint accepted and placeholder triangle sets show no coplanar overlap, and lower edges follow the original terrain profile. Those mechanical/geometry passes do not mitigate the unsupported bands.
- **Lighting:** The pale field remains nonmetallic and stable under the changed sun, but the large-scale modulation remains present as value drift. Lighting robustness therefore passes only for local response, not for the rejected pattern.
- **Whole object:** **REJECT_REFERENCE_BLOCKED.** The one-story/high-window reading, operational openings, SSE/ENE sides, substrate, true scale, address, and real massing remain unknown or unmapped; the plain fallback box is not recognizable as Fire Station 48.

#### One bounded correction; not authorized in this review

Make `fire_station_48_primary.tres` a genuinely phase-neutral flat albedo while preserving its current mean hue/value and roughness: set both `base_color` and `secondary_color` to their current component-wise midpoint `Color(0.595, 0.6275, 0.5825, 1)`, set `color_variation = 0.0`, retain `roughness_value = 0.81`, `relief_strength = 0.0`, and add no normal, joint, panel, opening, or motif. Then recapture the same exact receiver at close, ordinary, and changed-light oblique. This review does not authorize or perform that correction.

### Dormitory 369

- **Reference/material identity:** The light warm-gray/off-white matte field matches the observed dominant wall subset without importing the blue-gray end, green eave, windows, eyebrows, vents, or doors.
- **Scale/repetition/aliasing:** The declared `1.4 m` broad finish scale remains unmeasured. Low-frequency variation is detectable across the long receiver, but in these captures it remains soft and subordinate: it does not resolve into a stable panel grid, tier, window/slit cadence, moiré, or focal repeat. Acceptance is therefore exact-scope-only; no propagation to recessed/parallel chains.
- **Exact-run transition:** Runs `0..5` form one contiguous source edge. The field reads continuously across their terrain-varying bottoms; accepted/placeholder changes remain at protected ends/corners, with no visible duplicate face, z-fight, or harsh mid-face reset.
- **Lighting:** The field stays matte and readable under the changed sun with no relief inversion or metallic/specular artifact.
- **Whole object:** **REJECT_REFERENCE_BLOCKED.** The observed facade has five occupied tiers, window/eyebrow cadence, end color, and eave grammar while the receiver remains a fallback `6 m` box. The massing conflict and unmapped modules prevent a truthful whole-building result, but they do not require removal of this bounded homogeneous field.

## Preserved limitations and stop conditions

1. Navy Chapel substrate/relief, pane and door counts, complete long sides, modules, and other runs remain blocked.
2. Fire Station substrate, physical scale, normals, relief, high windows, divisions, operational openings, SSE/ENE, address, and true massing remain blocked. The exact live material additionally fails receiver art review until the one flat-albedo correction is independently accepted.
3. Dormitory substrate and physical scale remain unmeasured; the five-visible-tier/default-`6 m` conflict, blue-gray end, green accents, all openings, other chains, and unique elevation remain blocked.
4. No verdict authorizes new geometry, massing, story count, roof, terrain/foundation, collision, navigation, spray ownership, generated data, material propagation, modules, or asset edits.
5. Still captures show no visible z-fight or moiré but cannot prove absence of time-dependent shimmer. The existing runtime/route tests remain mechanical evidence only.

## Validation

- Manifest declaration, disk inventory, and this review each cover exactly `10` unique `1440×900` PNG paths: nine target views plus one whole-island view. Each receiver/view-kind pair occurs once.
- All ten PNG SHA-256 values match the top-level manifest. Each target's three nested capture records match the corresponding top-level records.
- All three reviewed material hashes, the shared shader hash, exact-run helper hash, world-builder hash, and generated-manifest hash match the manifest values reviewed on 2026-08-29.
- Before the required status edit, all `13` entries in [`ASSET_INVENTORY.sha256`](../../evidence/first-playable/accepted-material-run-trials-2026-08-29/ASSET_INVENTORY.sha256) passed, including the README, manifest, ten PNGs, and verification results. Updating only the mutable README status/link intentionally supersedes its capture-time hash; the inventory itself remains untouched under the review boundary.
- All local Markdown links in this review and the evidence README were checked after authoring.

## Final build gate

- **Navy Chapel:** exact-run material trial may remain, with documented substrate/relief and whole-object limitations.
- **Fire Station 48:** exact-run material trial may not remain; restore placeholder coverage until the one correction and independent receiver re-review pass.
- **Dormitory 369:** exact-run material trial may remain, with documented scale, tier/massing, and whole-object limitations.
- **Whole island:** load proof passes; it does not override the Fire Station rejection or accept any whole building.

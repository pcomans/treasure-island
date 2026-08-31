# Accepted homogeneous-material run trials — 2026-08-29

## Status

**Independent gameplay art review complete.** Navy Chapel and Dormitory 369 are `ACCEPT_WITH_DOCUMENTED_LIMITATION` on their exact live receiver scopes and may remain in the next playable build. Fire Station 48 is `REJECT_CORRECTABLE` on the exact receiver and may not remain until its broad vertical value-band repetition is removed and fresh receiver proof receives independent acceptance.

Independent review: [`ACCEPTED_MATERIAL_RUN_TRIALS_ART_REVIEW.md`](../../../discovery/facades/ACCEPTED_MATERIAL_RUN_TRIALS_ART_REVIEW.md)

**Superseded runtime state:** this directory retains the capture-time three-trial state because its Fire Station ordinary-distance image is the rejection evidence. The rejected Fire Station attachment has since been removed, returning all 26 receiver runs to the generated placeholder while Chapel and Dormitory remain exact. Current removal proof: [`fire-station-48-live-trial-removal-2026-08-29`](../fire-station-48-live-trial-removal-2026-08-29/README.md). The capture manifest, PNGs, verification record, and capture-time hash inventory below remain historical and are not rewritten as current-runtime evidence.

This evidence set proves that exactly three previously accepted-with-limitation homogeneous material resources are live on their approved generated wall-run scopes. The resources were not edited. No window, slit, door, trim, module, atlas, facade-scale motif, new geometry, or collision surface was added.

| Target | Exact receiver | Exact live runs | Mapped length | Reviewed resource (unchanged) |
|---|---|---:|---:|---|
| Navy Chapel | `building:w291189336:wall` (`w291189336`) | `9,10` | 16.362 m | `navy_chapel_primary.tres` — `4020e4c75350929359be9c16686ad80a2a0eac46918cc32746089694017a61a5` |
| Fire Station 48 | `building:w764313741:wall` (`w764313741`) | `0,1,2,3,5,6,8,9,24,25` | 76.157 m | `fire_station_48_primary.tres` — `515135c3d0da6bb8eb8681e69d7e3f7818d896d948fe5dcc7c2bd8c6d076b188` |
| Dormitory 369 | `building:w291189926:wall` (`w291189926`) | `0,1,2,3,4,5` | 49.124 m | `dormitory_b369_warm_field.tres` — `fb50d3989b7aa41421753ad4db5d195366d9a2c25c15087e5e3a2b7863c69602` |

## Runtime proof

The existing record-owned wall mesh is partitioned by its original triangle indices into two disjoint render surfaces only on each exact target: `placeholder_runs` and `accepted_material_runs`. All vertices, triangles, transforms, foundations, and collision faces remain the original generated data. The live whole-island result is:

- 38/38 chunks and 729 records loaded.
- 729 record-owned meshes and 732 surfaces: the exact `+3` is one second surface on each target above.
- 48,389 render triangles and 466 collision bodies/shapes, unchanged by the material partition.
- Each target has equal render/collision triangle counts and no duplicate or coplanar render triangle.
- Zero modules on all three targets; every non-approved run stays on the generated placeholder material.
- Generated/OSM bytes, terrain, massing, foundations, collision, spray, navigation, gameplay, and the five correction candidates are unchanged.

The machine-readable [capture manifest](capture-manifest.json) records source IDs, receiver IDs, run sets, lengths, material identities, camera/light transforms, device/runtime identity, per-image hashes, exact world counts, limitations, and protected scope. [Verification results](verification-results.txt) record the focused and full regression runs. [ASSET_INVENTORY.sha256](ASSET_INVENTORY.sha256) hashes every retained evidence artifact except the inventory itself.

## Metal captures

All images are 1440×900 live-world renders from Godot `4.7.2-stable (official)`, Forward+/Metal on `Apple M1 Pro (Apple7)`. Each target has a close view, an ordinary gameplay-distance view, and a changed-light oblique view. The aerial image proves the same run loaded the complete island.

- Navy Chapel: [close](images/navy-chapel-187/01-close.png), [ordinary distance](images/navy-chapel-187/02-ordinary-gameplay-distance.png), [changed-light oblique](images/navy-chapel-187/03-changed-light-oblique.png)
- Fire Station 48: [close](images/fire-station-48/01-close.png), [ordinary distance](images/fire-station-48/02-ordinary-gameplay-distance.png), [changed-light oblique](images/fire-station-48/03-changed-light-oblique.png)
- Dormitory 369: [close](images/dormitory-369/01-close.png), [ordinary distance](images/dormitory-369/02-ordinary-gameplay-distance.png), [changed-light oblique](images/dormitory-369/03-changed-light-oblique.png)
- Whole island: [38-chunk load proof](images/whole-island/whole-island-load.png)

## Preserved review limitations

- Navy Chapel is accepted only as a warm-cream homogeneous albedo/roughness background on runs 9..10. Substrate and relief remain blocked.
- Fire Station 48 is accepted only as a flat pale sage-gray/warm-gray albedo/roughness field on runs 0,1,2,3,5,6,8,9,24,25. Substrate, scale, normals, and relief remain blocked.
- Dormitory 369 is accepted only as a smooth warm-wall albedo/roughness field on runs 0..5. The five-visible-tier versus fallback-6-m discrepancy remains unresolved.
- The close frames intentionally emphasize the homogeneous field; the ordinary and oblique frames provide live-world scale and changed-light context. None authorizes architectural detail.

## Independent review handoff

Review the three images for each target at normal display scale and compare them with ordinary gameplay expectations. Confirm only whether the already-limited homogeneous material reads acceptably on the exact receiver scope under default and changed light. Do not infer approval for substrate, relief, facade modules, unlisted runs, or any neighboring receiver. Record the art decision outside this executor evidence; these images are mechanical evidence, not the decision itself.

## Independent review result

- **Navy Chapel:** standalone material and exact receiver `ACCEPT_WITH_DOCUMENTED_LIMITATION`; whole object `REJECT_REFERENCE_BLOCKED`; exact trial may remain.
- **Fire Station 48:** standalone material `ACCEPT_WITH_DOCUMENTED_LIMITATION`; exact receiver `REJECT_CORRECTABLE` because the ordinary-distance view exposes repeating broad vertical albedo bands unsupported by the flat-wall brief; whole object `REJECT_REFERENCE_BLOCKED`; exact trial may not remain.
- **Dormitory 369:** standalone material and exact receiver `ACCEPT_WITH_DOCUMENTED_LIMITATION`; whole object `REJECT_REFERENCE_BLOCKED`; exact trial may remain.
- **Whole-island image:** `ACCEPT_WITH_DOCUMENTED_LIMITATION` as load proof only.

The review preserves every substrate, normal, relief, physical-scale, tier/massing, unobserved-side, module, and exact-run limitation. It authorizes no correction or runtime edit.

# Fire Station 48 rejected live-trial removal — 2026-08-29

## Status

**Independent exclusion review: ACCEPT; current combined worktree is ready to launch.** Independent gameplay art review rejected the Fire Station 48 exact receiver because the reviewed homogeneous material produced unsupported repeating broad vertical value bands at facade scale. The live attachment has been removed, and independent review confirms the rejected appearance is absent at close, ordinary gameplay distance, and changed-light oblique views. This evidence proves exclusion and restoration of the generated placeholder; it is not Fire Station material or whole-building art acceptance. A future correction still requires separate authorization, capture, and review before reattachment.

Independent verdict and remaining correction brief: [`ACCEPTED_MATERIAL_RUN_TRIALS_ART_REVIEW.md`](../../../discovery/facades/ACCEPTED_MATERIAL_RUN_TRIALS_ART_REVIEW.md)

Independent exclusion/reversion verdict and final build gate: [`FIRE_STATION_48_EXCLUSION_REVIEW.md`](../../../discovery/facades/FIRE_STATION_48_EXCLUSION_REVIEW.md)

The rejected material resource, shared shader, Batch 03 registry entry, original prototype evidence, and rejection images remain intact for a later separately authorized correction. No correction was attempted in this round.

## Exact before → after

| State | Receiver | Accepted-material runs | Placeholder runs | Receiver surfaces | Whole-island surfaces |
|---|---|---|---|---:|---:|
| Before removal | `building:w764313741:wall` (`w764313741`) | `0,1,2,3,5,6,8,9,24,25` (76.157 m) | complement of those 10 runs | `placeholder_runs`, `accepted_material_runs` | 732 |
| After removal | `building:w764313741:wall` (`w764313741`) | none | `0..25` | `generated_record` | 731 |

After removal, Fire Station 48 is one record-owned generated wall mesh with one `building_wall` `StandardMaterial3D` surface. It has no accepted-material metadata, no accepted surface, and zero facade modules. Its original 52 render triangles, 52 collision triangles, transform, foundation, spray ownership, and generated geometry are unchanged. The focused contract found no duplicate or coplanar render triangles.

The complete loaded world remains 38/38 chunks, 729 records, 729 record-owned meshes, 731 disjoint surfaces, 48,389 render triangles, and 466 collision bodies/shapes. The `732 → 731` surface change is exactly the removed Fire Station partition; no mesh, triangle, or collider was added or removed.

## Preserved live trials

- Navy Chapel remains only on `building:w291189336:wall` runs `9,10` (16.362 m).
- Dormitory 369 remains only on `building:w291189926:wall` runs `0,1,2,3,4,5` (49.124 m).
- Their independent limitations remain in force. No other receiver or run was broadened or reduced.

## Retained rejected prototype

- Fire Station resource: `res://game/resources/materials/world/fire_station_48/fire_station_48_primary.tres` — `515135c3d0da6bb8eb8681e69d7e3f7818d896d948fe5dcc7c2bd8c6d076b188`
- Shared homogeneous shader: `res://game/resources/materials/world/batch_02/batch_02_homogeneous_field.gdshader` — `1918177080126199ddbfc0715a77b85a9355800479a098ec9b81c9726b7cc4d5`
- Batch 03 registry: `res://game/resources/facades/batch_03_material_registry.json` — `31983ae1529e6248e93ec8d231d2b870de3979778b35eef6019cd19e1a964516`
- Historical three-trial evidence is retained at [`accepted-material-run-trials-2026-08-29`](../accepted-material-run-trials-2026-08-29/README.md). Its Fire Station ordinary-distance image remains the rejection evidence; that historical manifest is not current-runtime proof.

## Metal exclusion captures

All images are 1440×900 live-world renders from Godot `4.7.2-stable (official)`, Forward+/Metal on `Apple M1 Pro (Apple7)`. The target views use the same representative run-2 receiver context as the rejected trial so the removed attachment and restored placeholder are directly auditable.

- [Close generated-placeholder exclusion](images/01-close-placeholder.png)
- [Ordinary gameplay-distance generated-placeholder exclusion](images/02-ordinary-placeholder.png)
- [Changed-light oblique generated-placeholder exclusion](images/03-changed-light-oblique-placeholder.png)
- [Whole-island post-removal load](images/04-whole-island-load.png)

The target images visibly show the generated plaster placeholder and an exclusion label. They are proof that the rejected accepted-material surface is absent, not an art review of the placeholder. The aerial image proves the same run loaded the full island and preserved the two independently accepted exact receivers.

The machine-readable [capture manifest](capture-manifest.json) records before/after scope, material lineage, exact runtime counts, invariants, camera/light transforms, renderer/device identity, and per-image hashes. [Verification results](verification-results.txt) record the focused and full regression gates. [ASSET_INVENTORY.sha256](ASSET_INVENTORY.sha256) hashes every retained evidence artifact except the inventory itself.

## Remaining correction brief

Do not edit or reattach the prototype without separate authorization. The independent reviewer requested a phase-neutral albedo at the current mean `Color(0.595, 0.6275, 0.5825, 1)`, `color_variation = 0.0`, roughness `0.81`, and relief `0.0`, with no normal, joint, panel, opening, or motif. Any corrected material must be recaptured on this exact receiver at close, ordinary, and changed-light oblique views and receive fresh independent acceptance before reattachment.

Chapel and Dormitory remain exact-run material acceptances only. This removal proof authorizes no architectural detail, substrate, relief, massing, other-side, module, or whole-object claim for any target.

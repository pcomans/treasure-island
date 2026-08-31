# Batch 03 controlled homogeneous material prototypes

Date: **2026-08-29**  
Scope: **three controlled material prototypes; zero live receiver attachments**  
Mechanical status: **pass**  
Visual status: **9 controlled Forward+/Metal proof images captured and independently reviewed**  
Review status: **independent_material_review_complete_live_receiver_review_pending**  
Art status: **2 `ACCEPT_WITH_LIMITATION`; 1 `REJECT_CORRECTABLE`; no live attachment accepted**

## Outcome

The three reference specs support bounded facade-scale-free material proofs, but not live placement. Exact observed material-region endpoints and physical module scale remain unresolved. The runtime builder, live receivers, generated source, collision, navigation, spray, massing, foundation, terrain and gameplay therefore remain unchanged.

| Target | Controlled field | Runtime status | Explicitly excluded architecture |
|---|---|---|---|
| Personnel Support Detachment `r133347` | observed outer east/north dark opaque structural/infill finish | prototype only | structural grid, window bays, glazing, courtyard and hidden sides |
| Fire Training Facility Building 600 `w34313548` | observed WSW pale coarse cream mineral field | prototype only | windows, red portal, arch, doors and hidden sides |
| Fire Station 48 `w764313741` | observed WSW/NNW pale sage-gray painted field | prototype only | high windows, apparatus doors, signage, operational openings and hidden sides |

Harvey Milk `w34313513`, Naval Station `w34313544`, Job Corps Food Service Building 368 `w34313521`, Education Center 29A `w109905031`, and Advanced Culinary `w34313514` remain explicit evidence-blocked exclusions with no resources and no attachment. Museum and Oasis remain unattached.

## Material contract

All three resources reuse the accepted project-owned `batch_02_homogeneous_field.gdshader` unchanged. The shader is opaque and dielectric, uses one local unit per metre, and derivative-filters procedural frequencies before aliasing. Personnel Support and Fire Station use the substrate-neutral painted-field branch with no normal relief; Building 600 uses low-amplitude coarse mineral variation. Every resource has nonzero multiscale value variation, but none contains a window, door, grid, bay, sign, atlas, unique elevation or other facade-scale motif.

The declared proof scales are reversible authoring assumptions, not observed measurements. `batch_03_material_registry.json` records exact identity, receiver, observed-side scope, official observation provenance, scale status, placement blockers and the five excluded targets.

## Verification

`verification-results.txt` records the exact commands and outcomes. The focused contract passes deterministic material loading, exact frozen receiver identity/geometry/foundation values, two-build equality, unchanged generic live material, zero facade/navigation additions, unchanged collision and spray ownership, accepted Hawkins/Building 3/Isle signatures, accepted Batch 02 hashes, all five exclusions, Museum/Oasis non-attachment and no builder/generated-data change.

The full previously passing editor/scene/gameplay/material/world/facade/runtime/route set also passes. Runtime remains `38` chunks, `729` meshes, `48,389` triangles, `466` bodies and `466` shapes. Generated content remains `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`; generated manifest SHA-256 remains `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`.

## Visual evidence status

All three manifests now contain close, ordinary-distance, and changed-light/oblique Forward+/Metal captures on the labeled `4.8 × 3.2 m` controlled panel. Independent review is recorded in [`discovery/facades/BATCH_02_04_MATERIAL_ART_REVIEW.md`](../../../discovery/facades/BATCH_02_04_MATERIAL_ART_REVIEW.md): Personnel Support's opaque dark field and Fire Station 48's flat pale field are accepted with explicit limits; Building 600 is rejected-correctable because its diagonal cellular quilting does not read as coarse mineral wall material.

The panels remain controlled material proofs, not gameplay or exact receiver evidence. Fire Station 48 is the only Batch 03 candidate with both a passing material verdict and an existing high-confidence safe run scope. Exact receiver, seam, and whole-object review remain pending.

## Known limitations

- None of the three fields is attached to a live receiver.
- Exact material-region endpoints are unresolved; no observed-side claim propagates to an unobserved side or the Personnel Support courtyard.
- Physical material scale and exact substrate remain unmeasured; all proof scales are reversible.
- The proof harness produces controlled panels, not gameplay evidence.
- Building 600 requires a corrected three-view manifest and independent re-review; Fire Station 48 still requires exact receiver proof before attachment acceptance.

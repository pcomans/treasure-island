# Batch 02 safe homogeneous material prototypes

Date: **2026-08-29**  
Scope: **six controlled material prototypes; zero live receiver attachments**  
Mechanical status: **pass**  
Visual status: **18 controlled Forward+/Metal proof images captured and independently reviewed**  
Art status: **5 `ACCEPT_WITH_LIMITATION`; 1 `REJECT_CORRECTABLE`; no live attachment accepted**

## Outcome

The six reference specs support material prototypes but do not support receiver-wide conservative use. Every observed material region still lacks exact generated-run endpoint reconciliation, and several physical surface scales are unmeasured. The implementation therefore adds one target-specific project-owned homogeneous proof material per target and does not change `world_chunk_builder.gd` or any live receiver.

| Target | Controlled field | Runtime status | Remaining evidence gate |
|---|---|---|---|
| Building 2 `w24274434` | WSW warm-cream mineral/masonry-like field | prototype only | WSW exact endpoints; material scale |
| 490 Avenue of the Palms `w1272162518` | WSW taupe thin-brick field | prototype only | exact subregion endpoints; brick unit measurement |
| Star View Court `w1212173437` | ENE grey vertically textured base | prototype only | exact base endpoints; texture pitch |
| Maceo May `r19685981` | outer-SSE fine vertical rib | prototype only; never inner courtyard | exact outer endpoints; rib pitch |
| Navy Chapel `w291189336` | SSE generic warm-cream painted field | prototype only | exact endpoints; substrate remains unknown |
| YMCA `w34313547` | observed SSE/ENE dark exposed-aggregate field | prototype only | exact endpoints; aggregate scale |

Oasis `w291189918` has no resource and no registry target. Museum `r16681702` remains unattached. Hawkins, Building 3, and Isle House retain their accepted deterministic signatures.

## Material contract

All six resources use the project-owned opaque dielectric shader `batch_02_homogeneous_field.gdshader`. It contains analytic derivative filtering (`fwidth`) so fine masonry, vertical texture, rib, and aggregate frequencies fade before aliasing. It has no texture/image dependency, displacement, transparency, time input, facade module, sign, opening, band, mural, canopy, or unique-elevation content. One local proof unit equals one metre.

The declared proof scales are reversible authoring assumptions, not observed measurements. They are recorded in `batch_02_material_registry.json` and must be calibrated before exact live placement.

## Verification

`verification-results.txt` records the exact command set and results. Every headless/editor/runtime/route validator exits `0`, including the new six-target contract and all accepted prior facade/massing contracts. Runtime remains `38` chunks, `729` meshes, `48,389` triangles, `466` bodies and `466` shapes. Generated content remains `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`; the generated manifest remains `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`.

`generated-data-diff.txt` proves no OSM or generated-world byte change. `asset-inventory.sha256` pins every new authored asset/test. Expected restricted-environment `user://logs` rotation and macOS CA-certificate warnings occur in headless Godot; all assertions and exit codes pass.

## Visual evidence status

All six manifests now contain close, ordinary-distance, and changed-light/oblique Forward+/Metal captures on the labeled `4.8 × 3.2 m` controlled proof panel. Independent review is recorded in [`discovery/facades/BATCH_02_04_MATERIAL_ART_REVIEW.md`](../../../discovery/facades/BATCH_02_04_MATERIAL_ART_REVIEW.md): Building 2, 490 Avenue of the Palms, Star View Court, Maceo May, and Navy Chapel are accepted as standalone material studies with explicit scale/receiver limitations; the YMCA aggregate is rejected-correctable because its checker/diamond repetition does not read as exposed aggregate.

These controlled panels are not gameplay, exact receiver, seam-on-building, or whole-object evidence. Only the Navy Chapel cream field has both a passing standalone verdict and a current high-confidence bounded run scope; a later exact receiver capture remains required.

## Known limitations

- No field is an in-game appearance claim, because no spec authorizes receiver-wide continuity.
- No screenshot can be treated as gameplay evidence; the proof receiver is controlled and explicitly labeled.
- Fine brick, vertical texture, rib and aggregate scales remain reviewer/calibration gates.
- No modules, facade-scale motifs, unobserved-side detail, or architecture are included.
- The YMCA correction requires a new three-view manifest and independent re-review; all live uses still require exact receiver proof.

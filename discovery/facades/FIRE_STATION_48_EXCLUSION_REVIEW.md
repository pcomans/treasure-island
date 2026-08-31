# Fire Station 48 rejected-trial exclusion review

**Review date:** 2026-08-29

**Reviewer:** independent exclusion-proof reviewer (`/root/hawkins_reference_spec`); the reviewer did not implement the removal, author the tests, or capture the evidence

**Evidence:** [`fire-station-48-live-trial-removal-2026-08-29`](../../evidence/first-playable/fire-station-48-live-trial-removal-2026-08-29/README.md)

## Final gate

| Scope | Verdict | Build disposition |
| --- | --- | --- |
| Fire Station 48 rejected accepted-material exclusion | **ACCEPT** | The rejected exact-run attachment is absent. Fire may ship in its restored generated-placeholder state. |
| Fire Station generated placeholder art | **OUT OF SCOPE — NOT ART ACCEPTED** | The placeholder is the restored baseline, not an accepted Fire material. Its conspicuous small-scale tile repetition remains visible and receives no aesthetic approval here. |
| Fire Station whole object | **REJECT_REFERENCE_BLOCKED remains in force** | No Fire facade, module, substrate, massing, or recognizability claim follows from reversion. |
| Navy Chapel exact-run trial continuity | **ACCEPT** as non-regression evidence | The prior `ACCEPT_WITH_DOCUMENTED_LIMITATION` verdict on runs `9,10` remains unchanged. |
| Dormitory 369 exact-run trial continuity | **ACCEPT** as non-regression evidence | The prior `ACCEPT_WITH_DOCUMENTED_LIMITATION` verdict on runs `0..5` remains unchanged. |
| Whole-island post-removal load | **ACCEPT** as load proof only | The combined worktree loads its complete recorded world after removal; the aerial image is not target art evidence. |

**Current combined-worktree decision: READY TO LAUNCH as the next playable build.** The sole rejected live material has been removed, the two independently accepted bounded trials remain exact, and the recorded full-world gates pass. This decision accepts the exclusion/reversion, not the Fire Station placeholder, retained prototype, correction, or whole building.

## Review boundary and lineage

The controlling prior verdict is [`ACCEPTED_MATERIAL_RUN_TRIALS_ART_REVIEW.md`](ACCEPTED_MATERIAL_RUN_TRIALS_ART_REVIEW.md): Fire Station 48's standalone homogeneous field was locally plausible, but its exact receiver was **REJECT_CORRECTABLE** because the long face exposed repeating broad vertical value bands unsupported by the observed building. Navy Chapel and Dormitory 369 were accepted only for their exact bounded homogeneous fields, and all three whole objects remained reference-blocked.

This review asks only whether that rejected Fire attachment was removed safely. It does not compare the restored placeholder against the real building as an acceptance standard. The retained Fire material and its one-correction brief remain available for a separately authorized correction and fresh independent review; neither is part of the current runtime gate.

### Absolute-review gate separation

| Gate | Disposition in this review |
| --- | --- |
| Numeric opposite-edge screen | **UNREVIEWED / not applicable.** No candidate texture is being selected. |
| Semantic repeat | **UNREVIEWED** for the placeholder and retained prototype. Visible placeholder repetition is documented but not graded; the rejected shader is not attached. |
| Material identity and neutral-light behavior | **UNREVIEWED** for the placeholder. No Fire material art claim is made. |
| Physical scale and map/channel coherence | **UNREVIEWED** for the placeholder. Reversion changes no material asset and supplies no finished scale claim. |
| Exact Godot receiver at close and ordinary gameplay views | **PASS for exclusion/reversion only.** The rejected appearance is absent in close, ordinary, and changed-light evidence, and the focused contract proves one all-run placeholder surface. |
| Whole-object resemblance | **FAIL / REJECT_REFERENCE_BLOCKED remains in force.** Reversion does not make the building recognizable. |
| Overall acceptance | **ACCEPT for exclusion/reversion; UNREVIEWED for placeholder art and Fire whole-object art.** |

## Four-image manifest accounting

Every PNG declared by [`capture-manifest.json`](../../evidence/first-playable/fire-station-48-live-trial-removal-2026-08-29/capture-manifest.json) is cited exactly once in this table. Each is a `1440×900` Forward+/Metal capture from Godot `4.7.2-stable (official)` on Apple M1 Pro (Apple7).

| Manifest ID and role | Exact PNG and SHA-256 | Independent finding |
| --- | --- | --- |
| `01-close-placeholder` — close generated-placeholder exclusion | [`01-close-placeholder.png`](../../evidence/first-playable/fire-station-48-live-trial-removal-2026-08-29/images/01-close-placeholder.png) — `1b0bf49e1786cc1aaef5035e4b15baaaa90834f046c113ad2b563ce3edb9d9a4` | The prior smooth pale-sage accepted field is absent. The frame instead shows the generated plaster placeholder across the sampled receiver and labels all `26` runs restored. Strong placeholder tiling is visible; that appearance is outside this exclusion verdict and is not accepted. |
| `02-ordinary-placeholder` — ordinary gameplay-distance exclusion | [`02-ordinary-placeholder.png`](../../evidence/first-playable/fire-station-48-live-trial-removal-2026-08-29/images/02-ordinary-placeholder.png) — `3cbc9ca5de5f9d383901eb67dc35691d4f08c04fd377b22ed10718d60fa066b7` | Direct comparison with the prior rejected ordinary-distance evidence shows that the broad vertical light/dark modulation no longer exists. One visually continuous placeholder field spans the long face; no pale-sage accepted patch or accepted-to-placeholder boundary appears. |
| `03-changed-light-oblique-placeholder` — changed-light oblique exclusion | [`03-changed-light-oblique-placeholder.png`](../../evidence/first-playable/fire-station-48-live-trial-removal-2026-08-29/images/03-changed-light-oblique-placeholder.png) — `3e65aa84d9207770b8aa77f74d57f8bf380bf18c5941ef7ae2d0b3e0d718c01b` | Under the changed sun and oblique angle, the Fire face remains the same generated placeholder family. The rejected material's broad bands do not reappear as lighting changes. The visible placeholder repeat is again excluded from art acceptance. |
| `04-whole-island-load` — whole-island post-removal load | [`04-whole-island-load.png`](../../evidence/first-playable/fire-station-48-live-trial-removal-2026-08-29/images/04-whole-island-load.png) — `3578335c58803d385be58e2ea45869db8132a7aad73bd81f67a9819dd4f1a279` | The complete island is visibly present and the capture overlay records `38/38` chunks, `729` meshes, `731` surfaces, `48,389` render triangles, and `466` collision bodies/shapes. At this altitude it proves load only; it cannot visually review Fire, Chapel, or Dormitory art. |

## Fire Station exclusion and receiver contract

The three target views establish the visible state change. The prior rejected ordinary frame showed a pale muted sage-gray field with persistent broad vertical light/dark bands on the long wall. The post-removal close, ordinary, and changed-light frames show the unrelated generated plaster placeholder instead. Therefore the specific rejected appearance is absent at each required distance/light condition.

The recorded focused contract and capture assertions provide the facts that still images cannot prove:

- receiver `building:w764313741:wall` (`w764313741`) has exactly one surface named `generated_record`;
- that surface uses one `StandardMaterial3D` whose resource name is `building_wall`, not `res://game/resources/materials/world/fire_station_48/fire_station_48_primary.tres`;
- placeholder coverage is exactly runs `0..25`; accepted-material runs are empty;
- the receiver has no `accepted_material_run_trial` metadata and zero facade modules;
- two deterministic builds agree, with `52` render triangles equal to `52` collision triangles, no duplicate/coplanar render triangles, and unchanged generated geometry, collision, and spray identity;
- the retained rejected `.tres`, shared shader, Batch 03 registry, generated chunk, and historical failure evidence retain their pinned hashes.

This is sufficient mechanical and visual exclusion proof. The placeholder's obvious repeating plaster pattern would require its own absolute art review if it were proposed as a finished material. Reverting to it here only removes a known failed live trial and restores the prior generic baseline.

## Chapel and Dormitory non-regression

The aerial capture does not resolve either material. Their preservation is instead established by the direct exact-run contract recorded in [`verification-results.txt`](../../evidence/first-playable/fire-station-48-live-trial-removal-2026-08-29/verification-results.txt) and the manifest:

- Navy Chapel remains the only accepted material on `building:w291189336:wall` runs `9,10`, exactly `16.362 m`;
- Dormitory 369 remains the only accepted material on `building:w291189926:wall` runs `0,1,2,3,4,5`, exactly `49.124 m`;
- the helper's exact target set is those two receivers only; their accepted resource hashes, run sets, two-surface partitions, metadata, render/collision equality, and deterministic rebuilds pass;
- full runtime attributes the two surfaces above the `729`-mesh baseline to Chapel and Dormitory only, producing `731` total surfaces after Fire removal.

Their earlier art verdicts and limitations are unchanged. Chapel gains no substrate, relief, opening, gable, symbol, porch, roof, other-run, or whole-object claim. Dormitory gains no measured scale, five-tier reconciliation, opening/eyebrow/eave grammar, other-chain, massing, or whole-object claim.

## Whole-island and regression gate

The recorded removal verification passes the focused accepted-run contract, Batch 03 material contract, full runtime integration, source-main Metal smoke, scene/gameplay/world-material/generated-world contracts, Hawkins/Building 3/Isle facade contracts, Batch 02/04 material contracts, material-correction protection, normal route, and whole-island route. The full recorded world is:

- `38/38` chunks;
- `729` records and `729` record-owned meshes;
- `731` disjoint surfaces;
- `48,389` render triangles;
- `466` static bodies and `466` shapes.

The exact `732 → 731` surface delta is the removed Fire accepted-material partition. Meshes, triangles, collision bodies/shapes, generated records, terrain/foundation behavior, navigation routes, and spray ownership do not change. No tests or captures were rerun by this independent reviewer; these are audited executor records, with visual review performed only on the frozen evidence.

## Preserved blockers and stop conditions

1. Fire Station's generated placeholder and whole object are not art accepted. The prior whole-object `REJECT_REFERENCE_BLOCKED` verdict remains.
2. Do not reattach `fire_station_48_primary.tres` until the separately authorized phase-neutral correction is captured on the same exact receiver and independently accepted.
3. Do not broaden Chapel beyond runs `9,10` or Dormitory beyond runs `0..5`; their exact-run and whole-object limitations remain controlling.
4. No result authorizes geometry, silhouette, massing, story count, roof, foundation/terrain, collision, navigation, spray, generated-data, module, registry, or other-receiver changes.
5. Still images cannot prove the absence of time-dependent shimmer. That limitation does not undermine removal of the rejected shader because the focused runtime contract proves that shader is not attached to Fire.

## Validation

- Manifest declaration, disk inventory, and this review cover exactly `4 / 4` unique PNG paths and roles: three Fire exclusion views plus one whole-island load view. No current PNG is omitted or double-counted.
- All four files exist at their declared paths, are `1440×900`, and match their manifest SHA-256 values listed above.
- Each manifest record has one unique ID, view kind, file path, camera/light transform, and hash. The manifest declares `capture_count: 4`.
- Before the required status edit, every entry in [`ASSET_INVENTORY.sha256`](../../evidence/first-playable/fire-station-48-live-trial-removal-2026-08-29/ASSET_INVENTORY.sha256) passed: README, manifest, four PNGs, and verification results. Updating only the mutable README lifecycle status/link intentionally supersedes its capture-time hash; the inventory remains frozen.
- The manifest's prior-review and prior-rejection-image hashes, retained material/shader/registry hashes, accepted-run helper hash, runtime builder hash, generated-manifest hash, and Fire generated-chunk hash agree with the recorded verification lineage.
- All local Markdown links in this review, the removal README, and the prior accepted-trials review were checked after authoring.

## Build decision

**READY TO LAUNCH.** The next playable build may contain the bounded Navy Chapel and Dormitory trials and Fire Station's restored baseline placeholder. It must not contain a Fire accepted-material attachment. The outstanding Fire correction is an optional future quality task, not a blocker to launching this reverted state.

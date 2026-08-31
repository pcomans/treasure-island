# Independent art review — Hawkins facade-language pilot

Reviewed: **2026-08-29**  
Reviewer: `/root/hawkins_texture_v2_review` (independent of implementation)  
Target: Hawkins / 77 Bruton Street, exact receiver `building:w1249412093:wall`  
Decision: **REJECT**

## Decision

The pilot does **not** pass the facade-language art gate. Its receiver identity, render-only attachment, complete-module boundaries, address-side uniqueness, conservative unobserved sides, neutral scalar palette, and spray behavior are well evidenced. Those mechanical and semantic-placement successes do not overcome two visible, non-massing failures:

1. The `64 mm` upper flute geometry aliases into discontinuous bright/dark dashes and diagonal moire bands. It reads as a screen-space artifact rather than the reference's fine, dense, continuous pearlescent rainscreen.
2. The observed WSW elevation is not represented with the owner-photo opening grammar. The ordinary gameplay view has a long blank ground band where the photo clearly shows complete ground-level openings, while the current `W-P` motif uses a center-only vertical split and omits the owner-photo's strong horizontal transom/operable-band character.

These faults are visible on the exact receiver and are independent of the known `6.0 m` massing limitation. Therefore the appropriate facade-language verdict is `REJECT`, not `ACCEPT_WITH_DOCUMENTED_MASSING_LIMITATION`.

## Reference basis and limitation

- The owner-private reference was inspected through the existing `/private/tmp/IMG_7170-reference.png` conversion. Its recorded `5712 x 4284` dimensions and SHA-256 `6b6a0f95902bd48c57c4f69b6bd7b97346c672d71c1b300d394170f6447db5cd` match the reference specification.
- The approved official Google Street View URL could not be reopened because no browser surface was available in this task. No substitute site was used and no Street View pixels were downloaded, copied, or retained. Address-side comparison is limited to the prior observational facts recorded in `HAWKINS_77_BRUTON_REFERENCE_SPEC.md`.
- Rejected texture candidates and the former grey-box appearance were not used as appearance benchmarks.

## Separated verdicts

| Scope | Verdict | Basis |
|---|---|---|
| Standalone material fields | **REJECT** | The scalar colors are plausible and albedo-neutral, but the explicit fine-flute geometry produces objectionable high-frequency dashes and diagonal moire under both retained sun directions. |
| Standalone module topology | **PASS** | Windows, connector, lobby, paired door, service door, garage, sign fascia/letters, spandrels, and band are complete bounded modules; no motif is completed by a texture edge or side boundary. |
| Standalone motif resemblance | **REJECT** | `W-P` is a center-vertical paired-lite assembly; the owner-photo WSW openings are tall assemblies whose visible character is dominated by a horizontal transom/lower operable band. |
| Exact current receiver — mechanical | **PASS_AS_EVIDENCED** | Manifest identity, layout/signature hashes, unchanged source geometry, side-local coordinates, no-collider overlay, render layer, and the live spray hit all point to `building:w1249412093:wall`. |
| Exact current receiver — art | **REJECT** | The flute artifact survives close, ordinary, oblique, and changed-light viewing; the observed WSW lower region is reduced to an overlong blank grey band. |
| Whole-building real-world resemblance | **BLOCKED_BY_CURRENT_MASSING_INVARIANT** | The current object remains a `6.0 m` extrusion, while real Hawkins is a six-story main mass plus a lower companion volume. This review does not authorize massing or gameplay changes. |
| Facade-language pilot overall | **REJECT** | The non-massing material and observed-side motif failures are sufficient rejectors. |

## Gate review

### Identity, seams, and module integrity

- Exact target identity: **pass**. `capture-manifest.json` pins `building:w1249412093:wall`, source `w1249412093`, layout hash `ccce9fd2c8027d25e95bb6750e5b23297786c747242eec607de5e4be41d1b4ef`, and facade signature `cf5b2a3aeb94e1482b1be9f9895f84463ce78e7ee6d1d38ee14e7833b8b8deff`.
- Evidence integrity: **pass**. Every entry in `asset-inventory.sha256` verifies.
- Legal/forbidden seams: **pass**. There is no facade bitmap or atlas-edge composition. Modules remain inside side and height bounds, and no corner-clipped jamb, mullion, sill, door, garage, sign, connector, or rib is visible.
- Foundation-subdivision cadence: **pass as evidenced**. Layout positions are side-local metres and do not restart at the receiver's twenty generated U resets; no restart is visible in the broad or oblique captures.
- Unobserved sides: **pass**. `side_ene` and `side_nnw` are material-only and contain no invented openings, doors, sign, garage, connector, balcony, or canopy.

### Material hierarchy and albedo

- Hierarchy: **pass**. A light upper field, darker smooth/ribbed base, charcoal frames, cool opaque glass, pale sills/spandrels, and dark service/garage language remain distinguishable.
- Albedo neutrality: **pass**. Materials are low-chroma, opaque, dielectric scalar responses; the changed-light view changes illumination rather than revealing a baked facade highlight, AO field, or photographic reflection.
- Fine fluted material behavior: **reject**. In `01-address-close.png` and `05-address-changed-light.png`, the flutes resolve as sparse vertical flashes and large diagonal interference bands. `03-broad-gameplay-camera.png` and `04-corner-oblique-gameplay.png` show the same high-frequency instability at ordinary route and oblique distances. A seamless geometric period is not acceptable when its screen-space product becomes a facade-scale pattern.
- Macro repetition: **reject** for the same reason. The diagonal moire is a synchronized broad field, not subordinate micro-relief.

### Cadence, scale, and address-side readability

- Upper placement cadence: **mixed**. The explicit windows are complete and regularly spaced, with a separate narrow connector family, but their center-only vertical mullion gives the wrong opening character against the owner photo.
- WSW observed-region cadence: **reject**. `03-broad-gameplay-camera.png` shows a nearly continuous blank lower band. The owner photo directly shows repeated complete ground openings across the main lower facade and sparser openings on the companion volume. Material-only restraint belongs on unobserved sides, not across this observed region.
- Address-side legibility: **pass within the available evidence**. `HAWKINS`, the lobby/storefront, paired entrance, service door, and garage read as distinct, complete, one-off elements in the close and changed-light frames. The sign becomes appropriately secondary at the oblique gameplay distance.
- Scale: **reject for the upper motif**. The current `2.0 x 2.45 m` module is within the research's coarse numeric bounds, but numeric range is not an acceptor; its visible paired-lite subdivision does not carry the reference opening rhythm.

## Per-view findings

- `01-address-close.png`: the address hierarchy and complete modules read, but vertical dash/sparkle and diagonal moire are prominent across the upper field.
- `02-address-close-sprayed.png`: the spray is visibly projected over the render-only facade and the manifest records the underlying exact receiver hit. It confirms gameplay behavior, not art acceptance; the material artifact remains.
- `03-broad-gameplay-camera.png`: strongest evidence for the missing observed WSW ground-opening rhythm; the broad lower half reads as an undifferentiated grey strip. Flute sampling remains unstable.
- `04-corner-oblique-gameplay.png`: the observed corner has no clipped motifs or cadence reset, and address/WSW differentiation survives, but the current object reads as a low slab and the upper field still breaks into interference patterns.
- `05-address-changed-light.png`: neutral palette and non-baked lighting are supported, yet the new light direction does not remove the flute artifact. The address modules remain complete and recognizable.

## Smallest correction set

One targeted facade-only correction round is sufficient and requires **no** change to height, footprint, roof, terrain, foundations, collision, navigation, spray contracts, player workflow, or generated data:

1. Replace the individual high-frequency flute bars with an alias-resistant fine-relief treatment (for example, a properly filtered normal/material response), or otherwise prove a geometry treatment that reads as continuous low-contrast fluting in close, broad, oblique, and changed-light captures without dashed sparkle or diagonal moire.
2. Correct only the observed WSW opening grammar: make `W-P` a complete tall frame with the owner-photo horizontal transom/lower operable-band character, then place complete ground-opening modules across the observed WSW main region and a sparser complete sequence on its companion region. Keep the address-side one-off layout and both unobserved-side material-only fallbacks unchanged unless new direct evidence supports more.

Recapture the same five roles and retain the same exact-receiver/hash record. The unchanged `6.0 m` mass must still be reported as a whole-building limitation even if this correction passes.

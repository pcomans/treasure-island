# Batch 02–04 rejected-material correction proofs

Date: **2026-08-29**  
Scope: **exactly five `REJECT_CORRECTABLE` standalone material prototypes; zero live attachments**  
Mechanical status: **pass**  
Capture status: **15 hash-verified 1440×900 Forward+/Metal PNGs**  
Art status: **independent re-review complete — 4 `ACCEPT_WITH_LIMITATION`, 1 `REJECT_CORRECTABLE`, 0 `REJECT_REFERENCE_BLOCKED`**

Review: [`BATCH_02_04_MATERIAL_CORRECTION_REVIEW.md`](../../../discovery/facades/BATCH_02_04_MATERIAL_CORRECTION_REVIEW.md)

**Post-review runtime disposition:** this directory remains the immutable controlled-panel correction evidence and its manifests correctly record zero attachment at capture time. The accepted-with-limitation YMCA aggregate field was subsequently integrated as a bounded exact-run trial on `building:w34313547:wall` runs `3..11` / `101.046 m`; current live evidence is [`ymca-exact-run-trial-2026-08-29`](../ymca-exact-run-trial-2026-08-29/README.md). That trial awaits independent exact-receiver art review. The other four corrected resources remain detached, and Fire Station 48 remains rejected/reverted.

## Bounded corrections

| ID | Target / field | Before → after correction | Preserved contract |
|---|---|---|---|
| C1 | Treasure Island Community YMCA — dark exposed aggregate | aligned checker lattice → rotated hash-driven multi-scale aggregate field | dark base; 0.095–0.42 m proof scales; roughness 0.91 |
| C2 | Fire Training B600 — pale cream-gray mineral | diagonal quilting → low-amplitude rotated stochastic mineral field | pale cream-gray identity; 0.22–0.38 m configured proof scales within the declared coarse range; roughness 0.84 |
| C3 | 850 Avenue H — tan wall | diagonal periodic banding → smooth low-amplitude aperiodic field | warm tan homogeneous identity; roughness 0.80; no relief or facade motif |
| C4 | Building 461 — medium gray | diagonal/cellular two-value modulation → sub-perceptual nondirectional field | substrate-neutral medium gray; roughness 0.82; no relief or two-value band |
| C5 | 1318 Gateview — white trim | darker secondary-color macro blotches → secondary exactly equal to `Color(0.84, 0.85, 0.82, 1)` base | roughness 0.66; zero relief; white painted trim identity |

C1–C4 use the new rejected-only `batch_02_04_aperiodic_field.gdshader`. C5 remains on the accepted generic shader and changes only its target-specific resource. No external texture, sampler, time input, alpha, geometry, window, seam, module, cadence, facade layout or runtime attachment was added.

## Evidence layout and lineage

Each target directory contains exactly three controlled-panel views:

- `01-close.png`
- `02-ordinary-distance.png`
- `03-changed-light-oblique.png`

Each `capture-manifest.json` pins the corrected material, shader, registry and generated-manifest hashes; camera/light metadata; PNG hashes and byte counts; and the complete prior rejected manifest/capture lineage. The prior evidence directories were retained byte-for-byte.

These are controlled standalone material proofs, not gameplay, live-receiver, receiver-fit or whole-object acceptance evidence.

## Preservation and validation

The focused correction contract proves:

- exactly five corrected material resources and 15 new proof PNGs;
- all 21 previously passing Batch 02–04 candidate resources remain hash-identical;
- the accepted generic and horizontal-siding shaders remain byte-identical;
- all 15 prior rejected proof PNGs and five prior manifests remain hash-identical;
- generated-world bytes remain pinned; and
- the runtime builder contains no reference to the correction shader or any corrected prototype resource.

An authorized concurrent integration round changed the runtime builder while this correction round was in progress. That file is not part of this correction changed-file set and was neither reset nor overwritten here. Final runtime provenance is therefore reported separately from correction acceptance.

## Independent review result and next step

Independent re-review found C1 YMCA, C3 850 Avenue H, C4 Bldg 461 and C5 1318 Gateview acceptable as bounded standalone material studies. C2 Building 600 remains rejected because the corrected proof flattened away the required coarse-mineral identity. C5's provenance-only record repair now declares exact target `w95934092` / `building:w95934092:wall` and canonical name `1318 Gateview Avenue`; its three PNGs and material/shader bytes are unchanged.

Only C1 becomes a new integration-trial candidate, on YMCA runs `3..11` and only for the aggregate/background field. No corrected field is accepted as a live attachment from these controlled panels. C2 has no second material-correction authorization. C5's standalone provenance gate is clear, but its white-trim region remains unmapped and live-ineligible.

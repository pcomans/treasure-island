# Independent art review — Building 3 facade-language pilot

Reviewed: **2026-08-29**

Reviewer: `/root/hawkins_texture_v2_review` (independent of implementation)

Target: Building 3 / 600 California Avenue, exact receiver `building:w34313540:wall`

Decision: **ACCEPT_WITH_DOCUMENTED_MASSING_LIMITATION**

## Decision

The bounded ENE facade language passes the candidate art gate. Across close, sprayed, ordinary-gameplay, oblique, and changed-light views, the pilot preserves the observed hierarchy: a very-light warm matte mineral field, one complete central dark-teal hangar opening with a pale surround, and one shallow band below the top. The field is stable and non-periodic; neither the nine generated wall subdivisions nor the long module dimensions become a visible repeat, seam, clipped motif, or sampling artifact.

This is not acceptance of faithful whole-building resemblance. The real ENE end is recognized partly by its curved crown and taller shoulder/pylon silhouette, while the exact receiver remains a flat `20 m` extrusion. Those are geometry-owned, prohibited changes. The accepted scope is the observed ENE material/module grammar and its exact current receiver application.

## Reference basis and evidence integrity

- The approved official Street View source could not be reopened because no browser surface was available in this review task. No substitute service was used and no imagery was downloaded, copied, or retained. Appearance comparison therefore uses the dated November 2025 / July 2015 observations in `NEXT_COHORT_STREETVIEW_OBSERVATIONS.md` and `BUILDING_3_600_CALIFORNIA_REFERENCE_SPEC.md`.
- Every entry in `ASSET_INVENTORY.sha256` verifies. All five required `1440 x 900` captures were inspected at original resolution.
- The manifest pins source `w34313540`, receiver `building:w34313540:wall`, layout SHA-256 `312ed89a5bca6e3eadf3034b8e97689b9a99646837aca8f5f1f7f940a11f8299`, and facade signature `737a674d63824d574e28c76f75c86212dfe126c3204870cdb2d0452d5bcf6337`.
- Mechanical green tests and hashes support identity and stability; they were not used as art acceptors.

## Separated verdicts

| Scope | Verdict | Basis |
|---|---|---|
| Standalone material field | **PASS** | Warm off-white, metallic `0`, roughness `0.82`; stable matte response under both captured lights, with no baked highlight, false reflection, stain repeat, or facade-scale texture period. |
| Standalone modules | **PASS** | One complete `B3-HANGAR-DOOR` and one complete `B3-BAND`; the four-sided door surround and band endpoints terminate inside ordinary field rather than at a receiver edge. |
| Exact current receiver — mechanical | **PASS_AS_EVIDENCED** | Exact source/run/hash contract, render-only shallow relief, unchanged underlying spray receiver, and successful live tag are recorded. |
| Exact current receiver — art | **PASS** | The ENE composition remains centered, complete, legible, non-repeating, and free of subdivision resets in close, ordinary, oblique, and changed-light views. |
| Whole-building real-world resemblance | **BLOCKED_BY_CURRENT_MASSING_INVARIANT** | The flat `20 m` extrusion cannot reproduce the observed curved crown/barrel roof or taller shoulder/pylon end elements. |
| Overall facade-language pilot | **ACCEPT_WITH_DOCUMENTED_MASSING_LIMITATION** | All bounded material/module/receiver art gates pass; prohibited silhouette geometry prevents a whole-building acceptance claim. |

## Gate review

- Material hierarchy and albedo: **pass**. The pale high-roughness field and dark low-metallic teal door stay distinct without baked panorama lighting. Changed light warms and brightens the field naturally rather than revealing a fixed tonal event.
- Material resemblance: **pass for the bounded homogeneous-field prototype**. The pilot is deliberately smooth and restrained. It does not simulate the observation's low diffuse weathering or base grime, but that absence does not introduce a false product, repeated focal stain, or a hard identity conflict.
- Module completeness and joins: **pass**. No door edge, surround stroke, band segment, or invented secondary opening is clipped, duplicated, resized, or completed by a run boundary. The pale surround can merge tonally with the field, but remains a complete bounded assembly.
- Cadence and scale: **pass as reference-relative prototype**. The `44 x 12 m` door and `82 x 0.5 m` band remain within the research bounds and read plausibly against the `90.320 m` observed end; no as-built measurement claim is made.
- Ordinary-camera recognition: **pass within the frozen mass**. The single broad central teal opening against a plain pale end remains the dominant recognizer in `03`; the band is appropriately subordinate and becomes clearer under the closer changed-light view.
- Repetition and aliasing: **pass**. There is no architectural tile, UV-scale facade pattern, moire, sparkle, cadence restart, or macro grid.
- Exact run scope and unobserved-side restraint: **pass as evidenced**. Only contiguous ENE-main runs `27..35` receive the field and complete modules. Discontiguous ENE returns, both long sides, WSW end, service openings, and minor returns are not populated from symmetry or building type.
- Spray appearance: **pass**. `02-close-sprayed.png` shows the tag over the dark door while the underlying exact wall remains the recorded hit owner. The extreme interaction framing is evidence of gameplay behavior, not the main art-comparison view.
- New defects: **none found**. No false metal, emissive response, clipping, corner spill, invented vent/door/sign, or shallow-module silhouette break is visible.

## Per-view findings

- `01-close.png`: the door remains a single complete focal opening; field and opening edges stay stable at close range.
- `02-close-sprayed.png`: tag projection remains visible on the dark door; no added collision or separate spray-owner appearance is exposed.
- `03-ordinary-gameplay-camera.png`: strongest target-language proof; the end reads as a plain pale hangar face with one broad central dark opening and no accidental repeat.
- `04-oblique-gameplay-camera.png`: the module remains complete under perspective, while unobserved adjacent surfaces stay generic; no band or door cadence wraps around the corner.
- `05-changed-light.png`: strongest material proof; the field reads warm/off-white, the teal door remains opaque and subordinate to lighting, and the shallow horizontal band is visible without baked shadow.

## Residual limitation

The pilot is a reference-relative shallow facade adaptation, not a rectified as-built elevation. Exact door/band offsets and subtle diffuse weathering remain unsurveyed approximations. More importantly, the flat roofline and absent crown/shoulders keep whole-building recognition materially below the real Building 3 profile. No facade-only correction is required by this review; a faithful silhouette would require a separately authorized massing/roof decision.

# Building 1 detached shared-miter correction evidence

Status: `ready_for_independent_detached_miter_correction_rereview_not_self_accepted`

This is the single bounded correction package authorized by `TREASURE_ISLAND_BUILDING_1_EXACT_RECEIVER_CALIBRATION_ART_REVIEW.md` (`7c1d4fed…`). It replaces independently normal-offset endpoints in the detached `B1-MAT-IVORY` overlay with one shared XZ offset-line miter at each of the 30 internal joins on exact outer runs 21..51. The predecessor evidence package remains a sealed point-in-time record.

## Exact result

- Scope remains 31 ordered runs, 85.939934 m, 1740.731069 m².
- World-metre UV phase and material scale remain unchanged.
- Field topology remains 1 mesh / 1 surface / 124 vertices / 62 triangles.
- Aggregate detached topology remains 23 meshes / 23 surfaces / 326 triangles.
- Maximum independently-offset gap before correction: 0.0268635451793671 m at 42→43 in Godot float32 geometry (the review measured 0.026857801 m).
- Review-identified 38→39 gap: 0.024844871 m; the corresponding float32 diagnostic is within 0.00005 m.
- Maximum shared-miter gap after correction: exactly 0.0 m across every bottom and top endpoint of all 30 joins.
- Maximum miter length is 0.0270314877250559 m (ratio 1.50174931805866); minimum denominator is 0.665890097618103; maximum float32 perpendicular clearance residual is 0.000020521849393846 m.
- `FIT-CENTRAL-W-R36` and `FIT-PAV-W-R06` art, transforms, and topology are unchanged. They remain detached scale/contact studies, not placements.

## Evidence

The 15 native 1440×900 Forward+/Metal images include five close join samples (including sharp 38→39), the full 85.939934 m macro scope, ordinary and whole-building context, changed light, and unchanged CENTRAL/PAV close/oblique/ordinary views. `capture-manifest.json` contains the complete 30-join machine record and renderer metadata. `visual-verification.json` records the executor's image validity inspection without an art verdict. `runtime-isolation.json` pins protected runtime, mapping, standalone, and interrupted-r133351 bytes. `checksums.sha256` seals this correction package.

## Review boundary

Independent re-review may judge only whether the shared-miter correction removes the detached field cracks while preserving the previously reviewed field and module-study presentation. Live placement, lifecycle promotion, cadence, surveyed coordinates or scale, completed elevation, and whole-building resemblance remain blocked.

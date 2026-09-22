# Absolute semantic and art review

Read this reference after proof generation and before selection or integration. The reviewer must be independent of candidate generation when delegation is available.

## Asset-kind applicability

- `homogeneous_material_tile`: review field continuity, material identity, physical scale, and macro repetition. No facade-scale motif is allowed.
- `architectural_pattern_tile`: apply every semantic-repeat and edge-composition gate on each claimed tileable axis.
- `module_atlas`: review each complete motif for completeness, proportion, material response, placement plausibility, and contact. A complete module does not need to be seamless or repeat as a whole-wall tile.
- `unique_elevation`: review the finite composition, region ownership, edges, and recognizability. Require periodic proof only for an internal region that actually claims repetition.

## Verdict separation

Report each gate as `pass`, `fail`, or `unreviewed`:

- numeric opposite-edge screen;
- semantic repeat;
- material identity and neutral-light behavior;
- physical scale and map/channel coherence;
- exact Godot receiver at close and ordinary gameplay views;
- whole-object resemblance when the request names a building;
- overall acceptance.

The proof script deliberately reports semantic, art, receiver, and overall verdicts as unreviewed/not accepted. Numeric passage can only keep a candidate in review. It cannot set any other verdict to pass.

Also record evidence status independently as `verified_fact`, `reference_observation`, `production_inference`, or `unknown`. A reversible production inference may pass game-art acceptance without becoming a measured or as-built claim.

## Semantic repeat hard gate

Use this hard gate only for assets or axes that claim repetition. Use the predeclared motif inventory and legal seams, not labels invented after seeing the candidate.

1. Inspect the borderless native-scale 3×3 and the boundary-overlay 3×3.
2. Inspect half-X, half-Y, and half-XY circular rolls so each original outer join appears centrally.
3. Tokenize every complete motif in the center tile, across both axis seams, and across the four-corner composition.
4. Compare token kind, width, height, aspect ratio, frame/joint/trim thickness, pitch, alignment, order, and cadence with the blueprint.
5. Hard-fail if any boundary creates, resizes, duplicates, or deletes any motif. Smooth pixels do not mitigate this failure.
6. Inspect the macro proof for visible grids, synchronized stains, clone echoes, exposure bands, four-way crosses, or a larger accidental motif.

This rule is not window-specific. It applies equally to masonry courses, panels, ribs, vents, louvers, doors, balconies, trim, joints, and stains. A legal cross-edge motif must reconstruct the same declared canonical motif; otherwise place complete motifs inside the cell or use a module atlas/unique elevation.

### Worked failure, not a universal template

In the rejected Hawkins experiment, two partial edge fragments joined into a narrow slit window absent from the selected facade region, creating a false narrow/wide cadence. The general lesson is that a low-error seam can invent architecture. It does **not** mean building textures cannot contain windows or that every building requires the Hawkins grammar.

## Absolute art gate

For a named building's recognition/fidelity decision, inspect actual dated exterior-reference images (such as Street View) alongside the native gameplay captures. Confirm target identity and comparable visible side/angle scope; record the source URL, image date and meaningful viewpoint or historical limits. Written observations supplement this direct comparison. If reference pixels cannot be inspected, leave the affected recognition/fidelity claim unresolved rather than passing from notes alone. Identical cameras and exhaustive views of protected or unobserved faces are unnecessary; do not invent hidden detail. Follow existing source access and retention rules: direct inspection does not require or authorize storing third-party imagery in the repository or using it as game assets.

Judge against the researched target and the intended gameplay view:

- Does the candidate read as the declared material, coating, finish, relief scale, and weathering state?
- Is albedo neutral, without fixed scene lighting, reflection, or facade-depth shadows?
- Are normal and roughness effects plausible under changed lighting and aligned at one physical scale?
- Does the exact game receiver preserve UV phase, placement, and plausible size at close and ordinary third-person distances?
- Is macro repetition subordinate rather than a visible grid or focal pattern?
- For an architectural pattern, atlas, or unique elevation, does the selected region preserve the observed motif families and any cadence actually established by the references?
- If count, cadence, dimensions, or anchors are inferred, are they plausible, reversible, clearly labeled, within the identified region, and not contradicted by the reference observations? Missing survey data alone is not an art failure.
- For a named building, does the combined view read recognizably and remain honest about its evidence status? Report geometry/massing mismatches separately and route them out instead of painting around them.

A gray placeholder may be shown at the same pose as a diagnostic baseline, but “better than gray,” “more detailed,” a green automated test, or a single attractive isolated tile is never acceptance evidence. Report visible reference matches and substantive gaps separately from finish and mechanical results. Unresolved substantive fidelity gaps keep whole-unit acceptance open; a scoped finish PASS does not clear them. Game-art acceptance need not claim survey-level as-built precision, but production inference cannot excuse a visible contradiction of the reference.

Review the first coherent native source-project result early; export is not a prerequisite for this art decision. Earlier accepted assets are a floor, so require substantive target recognition, coherent composition and believable geometry at ordinary play distance. Inspect actual originals, not only manifests. Describe sampled motion as sampled, and do not imply continuous playback, current-package imagery or a changed source binding from historical captures. Keep each target's verdict separate when package runs are later shared across a batch. For a timed edit-to-verdict task, deliver an explicit visual decision within the recorded task boundary; a save/readback receipt alone is not that decision.

Lead the critique with a pixel-grounded verdict on meaningful visible change and one concrete highest-value next change/how to improve. If the compared images are nearly indistinguishable, say so plainly; do not substitute a feature list or let caveats dominate the direction. Keep uncertainty honest and proportionate to the evidence.

## Evidence record

For each candidate, record source/prompt, tool mode, dimensions, hash, physical-span status, placement basis/confidence, correction count, applicable proof paths, numeric values, annotated semantic findings, exact-game-receiver captures, game-art and as-built verdicts, and rejection reasons. One small initial batch and at most one diagnosed correction round are allowed. If none passes, revise the classification or research brief instead of generating indefinitely.

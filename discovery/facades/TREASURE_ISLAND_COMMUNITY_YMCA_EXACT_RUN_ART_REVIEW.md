# Treasure Island Community YMCA exact-run integration — independent absolute gameplay art review

**Reviewed:** 2026-08-29  
**Reviewer:** art director (`/root/art_director`), independent of material authoring, correction, integration, testing, and capture  
**Target:** `building:w34313547:wall` / source `w34313547`  
**Declared live scope:** homogeneous dark aggregate/background field only on runs `3..11`, `9` runs / `101.046 m`

## Final decision

**REJECT_CORRECTABLE for the complete runs `3..11` exact-receiver attachment.**

This is not a rejection of the corrected homogeneous aggregate field. The visible SSE subset reads plausibly and passes its local gameplay-art gates with the existing scale/substrate limitation. The complete attachment cannot be accepted because no target-specific art capture shows the orthogonal ENE runs `8..11` or their terminal transition to placeholder run `12`, and the current shader's `VERTEX.xy` field coordinates are not rotation-invariant across the two wall orientations. Exact-receiver scale and semantic behavior on ENE are therefore both unproved and technically at risk.

No lifecycle inventory, runtime attachment, material, shader, geometry, generated data, test, or evidence file was changed by this review.

## Separate verdicts

| Gate | Verdict | Absolute finding |
|---|---|---|
| Reference / material identity | **PASS_WITH_LIMITATION on visible SSE** | The field reads as a dark warm-grey/brown, very matte rough aggregate/pebbled-precast approximation. It is somewhat charcoal/stucco-like at close range, consistent with the earlier limitation that substrate, aggregate size, and `0.095–0.420 m` calibration are assumptions rather than measurements. It does not introduce unsupported signage, windows, joints, doors, or mural content. |
| Declared asset kind | **PASS** | The live result is honestly a `homogeneous_material_tile`/procedural field. It contains no facade-scale layout or implied architectural module. Missing entry, louver, service door, panel joints, low wing, and mural are outside this field's asset kind. |
| Scale, repetition, and semantic artifacts | **PASS on SSE; FAIL/UNPROVED for the full two-orientation scope** | Close, ordinary, and changed-light SSE views show no checker lattice, facade-scale grid, false opening, panel cadence, moiré, or motif creation. However, the shader derives its 2D material position from `VERTEX.xy`; horizontal distance on ENE is represented by only the world-X component. Nominal metre scales therefore do not survive receiver rotation, and ENE is not visible in the captures. |
| Exact-run transitions and terrain contact | **PARTIAL PASS / INCOMPLETE EVIDENCE** | SSE lower edges meet the terrain continuously, without a floating strip, duplicate face, tear, or visible z-fight. The changed-light oblique includes one geometric end/corner, but the accepted SSE→ENE corner behavior and accepted run `11`→placeholder run `12` termination are not both shown clearly enough for an absolute art verdict. |
| Ordinary gameplay readability | **PASS on visible SSE** | At ordinary distance the roughness collapses into a subordinate dark material read rather than a focal procedural pattern. The long wall stays readable against grass and path. This accepts only the field, not YMCA recognition. |
| Changed light | **PASS_WITH_LIMITATION on visible SSE** | The surface remains nonmetallic and matte under the changed sun, with plausible relief response and no recovered checker or inverted normal. It becomes nearly black and somewhat coarse at the most oblique end, but remains within the documented dark-field limitation. No ENE changed-light result is available. |
| Exact receiver | **REJECT_CORRECTABLE for runs `3..11` as one live scope** | SSE evidence is locally acceptable; ENE physical scale, directional read, internal continuity, and terminal accepted→placeholder transition are unreviewed. Mechanical partition and triangle tests cannot substitute for these missing visual gates. |
| Whole-building resemblance | **REJECT_REFERENCE_BLOCKED, separately** | The current views do not establish an as-built YMCA whole object. The observed entry portal/glazing, explicit panel joints, louver, service door, coping, uncertain low wing, WSW/NNW, and remaining massing questions are absent, unmapped, or geometry-owned. This does not count against the homogeneous field verdict and does not authorize those features. |

## Exact evidence coverage

All four manifest-indexed `1440 × 900` Forward+/Metal PNGs were inspected at native resolution:

| Manifest role | Exact image and hash | Independent finding |
|---|---|---|
| Close live receiver | `evidence/first-playable/ymca-exact-run-trial-2026-08-29/images/01-close.png` — `fa55a506dc9088323cd4b6d668c903c5468e187748ff68acdf687fb39fecf66e` | Representative run `5`; rough aperiodic field with no repeated architectural token or join artifact in the visible area. Framing contains material only and cannot prove run boundaries or terrain contact. |
| Ordinary gameplay distance | `evidence/first-playable/ymca-exact-run-trial-2026-08-29/images/02-ordinary-gameplay-distance.png` — `223be03b7383fb38d957f497b0998c0971775b6641de5e35112a4887952807b7` | Representative SSE run `5`; material is subordinate, continuous across several SSE runs, and visibly grounded. Both ends are outside the frame. |
| Changed-light oblique | `evidence/first-playable/ymca-exact-run-trial-2026-08-29/images/03-changed-light-oblique.png` — `19409f1b500cab30d715a8add2a93f3d0a888ce49221e0a70fdb7265731f8f67` | Representative SSE run `5`; nonmetallic changed-light response passes locally. Camera placement remains on the visible side of SSE and the back side of ENE, so it does not grade runs `8..11`. |
| Whole-island load | `evidence/first-playable/ymca-exact-run-trial-2026-08-29/images/04-whole-island-load.png` — `ad9c6fed7ed7bd9865a0ade3139d3c42aa994cc4574043ba8f9c1abc00f5b1e7` | Valid whole-world load context only. At `1550 m` altitude it supplies no YMCA material, transition, or whole-building art acceptance. |

The following required records were read in full or, for the large mapping JSON, inspected through its complete YMCA target record and top-level validation/schema fields:

- both governing `AGENTS.md` files;
- `.agents/skills/building-texture/SKILL.md`;
- `references/semantic-art-review.md` and `references/godot-material-contract.md`;
- `TREASURE_ISLAND_COMMUNITY_YMCA_REFERENCE_SPEC.md`;
- `BATCH_02_STREETVIEW_OBSERVATIONS.md`;
- `BATCH_02_REFERENCE_INDEX.md`;
- `BATCH_02_RUN_MAPPING.md` and the full YMCA record in `BATCH_02_RUN_MAPPING.json`;
- `BATCH_02_04_MATERIAL_CORRECTION_REVIEW.md`;
- the trial `README.md`, `capture-manifest.json`, `verification-results.txt`, `owner-playtest-noninterference.txt`, and `ASSET_INVENTORY.sha256`;
- the retained live material, shared shader, and exact-run helper named by the manifest.

No external imagery was reopened or retained for this review; the normalized observation/specification record is the appearance reference.

## Receiver-scale finding

The accepted scope combines two orthogonal canonical sides:

- SSE runs `3..7`: `72.979 m`, horizontal world-X advance approximately `0.883 m` per wall metre;
- ENE runs `8..11`: `28.067 m`, horizontal world-X advance approximately `0.470 m` per wall metre.

The retained shader sets `field_position_m = VERTEX.xy`. Rotation preserves the procedural noise's internal orientation but cannot restore the missing wall-tangent distance. Approximate effective horizontal receiver spans are therefore:

| Chain | Nominal primary / secondary | Approximate effective horizontal span |
|---|---:|---:|
| SSE | `0.420 / 0.095 m` | `0.476 / 0.108 m` |
| ENE | `0.420 / 0.095 m` | `0.894 / 0.202 m` |

Because aggregate scale is unmeasured, those numbers do not by themselves prove that ENE looks implausible. They do prove that the declared metre calibration is orientation-dependent, which must not be silently accepted without an ENE receiver view.

## One bounded correction brief — `Y-EXACT-01`

Preserve the target, run set `3..11`, material colors, `0.420 / 0.095 m` scales, `0.91` roughness, `0.08` relief, topology, terrain/foundations, collision, spray ownership, and generated bytes. Add a **YMCA-only wall-tangent projection mode** so the horizontal field coordinate advances one metre per metre along each vertical wall face; do not alter default projection for other materials.

Representative coordinate change:

```text
before: field_position_m = VERTEX.xy
after:  field_position_m = vec2(dot(VERTEX.xz, normalized horizontal wall tangent), VERTEX.y)
        for this YMCA material mode only
```

Then produce one fresh exact-receiver Metal evidence set at the existing `1440 × 900`, `50°` FOV:

1. ENE close and ordinary-gameplay views centered on runs `9..10`, with the ground edge visible in the ordinary view;
2. one changed-light oblique that visibly includes the SSE run `7`→ENE run `8` corner;
3. one ordinary boundary/whole-object approach that includes the ENE run `11`→placeholder run `12` end and enough of the receiver to document the still-limited whole-building state.

Pass only if both orientations retain a subordinate non-directional rough aggregate read at consistent physical scale; no run-internal phase reset, stretched streak, false panel, or motif appears; the run `11`→`12` material change occurs only at its actual geometric boundary without overlap; and all visible lower edges remain closed to terrain. This brief authorizes no module, joint, opening, signage, mural, massing, geometry, or lifecycle change.

## Build disposition

- Corrected standalone homogeneous field: **retains `ACCEPT_WITH_LIMITATION`**.
- Visible SSE exact receiver: **locally passes with the same limitation**.
- Complete live runs `3..11` attachment: **not accepted pending `Y-EXACT-01` and independent re-review**.
- Whole YMCA building: **not accepted; reference/module/massing blockers remain separate**.


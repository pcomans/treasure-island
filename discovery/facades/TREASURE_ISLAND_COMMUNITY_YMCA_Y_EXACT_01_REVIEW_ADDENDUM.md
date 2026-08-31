# Treasure Island Community YMCA — `Y-EXACT-01` correction re-review addendum

**Reviewed:** 2026-08-29  
**Reviewer:** art director (`/root/art_director`), independent of material correction, integration, testing, and capture  
**Target:** `building:w34313547:wall` / source `w34313547`  
**Corrected live scope:** homogeneous dark aggregate/background field on runs `3..11`, `9` runs / `101.046 m`  
**Predecessor decision:** `TREASURE_ISLAND_COMMUNITY_YMCA_EXACT_RUN_ART_REVIEW.md`

## Final decision

**`Y-EXACT-01`: ACCEPT_WITH_DOCUMENTED_LIMITATION.**

The target-only wall-tangent projection resolves the prior orientation-dependent scale blocker. The six-view Forward+/Metal set now proves the homogeneous field across representative SSE and ENE receivers, the accepted run `7`→`8` corner, and the accepted run `11`→placeholder run `12` boundary. The accepted field remains subordinate, non-directional, grounded, and free of invented facade-scale architecture at ordinary gameplay distance.

This acceptance applies only to the declared homogeneous material field on exact runs `3..11`. It does not accept YMCA modules, panel joints, openings, entry treatment, massing, other sides, or whole-building resemblance. The aggregate substrate and physical grain sizes remain visually plausible but unmeasured.

No further correction is required for the accepted homogeneous field. No lifecycle inventory, runtime attachment, material, shader, geometry, test, generated data, or evidence file was changed by this review.

## Separate verdicts

| Scope | Verdict | Independent finding |
|---|---|---|
| Standalone homogeneous field | **ACCEPT_WITH_DOCUMENTED_LIMITATION** | It reads as a dark warm-grey/brown, very matte rough aggregate/pebbled-precast approximation. It remains somewhat charcoal/stucco-like and its `0.095–0.420 m` calibration is not reference-measured, but it introduces no unsupported architectural content. |
| Full exact-run scope `3..11` | **ACCEPT_WITH_DOCUMENTED_LIMITATION** | Both SSE and ENE families now retain comparable subordinate granularity in physical wall metres. The two required scope transitions are visually clean and the field stays grounded. |
| Whole-building resemblance, modules, massing, and other sides | **REJECT_REFERENCE_BLOCKED** | The current object remains a simplified blank mass. Entry portal/glazing, panel joints, louver, service door, coping, low-wing relationship, WSW/NNW treatment, and final massing remain absent, unresolved, or outside this field's asset kind. This does not count against the homogeneous-field acceptance. |

## Correction-gate findings

| Gate | Verdict | Direct evidence |
|---|---|---|
| Reference / material identity | **PASS_WITH_LIMITATION** | All six corrected views retain the specified dark, matte, irregular aggregate-like field without adding semantic claims. The substrate and grain scale remain assumptions rather than measurements. |
| Declared asset kind | **PASS** | The result is still honestly a `homogeneous_material_tile`/procedural field. A homogeneous-field pass does not imply windows, modules, joints, doors, murals, or recognizable building design. |
| Orientation-invariant physical scale | **PASS** | The focused contract proves one horizontal shader-coordinate metre per generated wall metre on every accepted run, with a `0.002 m` projected-length bound. Visually, `01-sse-ordinary` and `03-ene-ordinary` show comparable subordinate granularity; ENE no longer exhibits the roughly doubled horizontal scale risk identified in the predecessor review. |
| Scale, repetition, and semantic artifacts | **PASS** | SSE and ENE show no checker lattice, facade-scale band, daylight slit, false window/opening, panel cadence, run-internal phase break, directional stretch, moiré, or repeated architectural token. The low-contrast ENE close view is dark lighting, not a large-scale motif. |
| Accepted run `7`→`8` corner | **PASS** | `04-corner-changed-light-oblique` shows the SSE and ENE accepted fields meeting at the actual orthogonal corner without overlap, z-fight, gap, false seam, or material discontinuity masquerading as architecture. The strong face-to-face value change is explained by lighting orientation. |
| Accepted run `11`→placeholder run `12` | **PASS** | `05` and `06` show a crisp material change only at the actual geometric boundary, at close and ordinary distance, with no overlap, coplanar flicker, tear, or daylight slit. The visible placeholder is transition evidence, not a comparison baseline and is not accepted or graded as YMCA art. |
| Terrain contact | **PASS** | Visible lower edges in `01`, `03`, `04`, `05`, and `06` close continuously to terrain/grass. There is no floating foundation strip, buried-wall artifact, z-fighting edge, or open undercut. |
| Ordinary gameplay readability | **PASS_WITH_LIMITATION** | In `01`, `03`, and `06`, aggregate detail collapses into a coherent dark material read rather than becoming a focal procedural pattern. The wall remains legible against grass and paths. This is material readability, not building recognition. |
| Changed light | **PASS_WITH_LIMITATION** | `04` remains matte and nonmetallic across two differently lit orientations; no checker, inverted relief, or directional projection artifact appears. The SSE face approaches near-black at oblique incidence, consistent with the retained dark-field limitation. |
| Exact receiver and phase continuity | **PASS** | The target-only tangent shader preserves vertical `VERTEX.y` and advances horizontally along the wall tangent. The focused contract passes collinear continuity within chains `3..7` and `8..11`, the exact `7`→`8` corner, and the exact `11`→`12` endpoint. |
| Noninterference | **PASS** | The correction binds only the YMCA target material. Protected shared shader/material resources, other facade targets, run partition, geometry, collision, spray ownership, runtime counts, and route behavior remain unchanged according to the pinned hashes and passing full-runtime checks. |

## Exact evidence coverage

All six manifest-indexed `1440 × 900`, `50°` FOV PNGs were inspected at native resolution. They were rendered by Godot `4.7.2`, Forward+, Metal, on Apple M1 Pro (Apple7).

| Manifest role | Exact image and SHA-256 | Independent finding |
|---|---|---|
| SSE ordinary | `evidence/first-playable/ymca-exact-run-correction-2026-08-29/images/01-sse-ordinary.png` — `30e945d5eb66364df2c822da654797ec24f08e14f0a7f8cdae3d39adf6d558a5` | Run `5`; subtle irregular field, no macro grid or invented architecture, visibly closed to terrain. |
| ENE close | `evidence/first-playable/ymca-exact-run-correction-2026-08-29/images/02-ene-close.png` — `8d79a1e8f3dc3d296e980f68265d3c91d67d349c936b296fdca8c0b112acbe07` | Runs `9..10`; dark, low-contrast aggregate remains non-directional with no stretched band, slit, or repeated token. |
| ENE ordinary | `evidence/first-playable/ymca-exact-run-correction-2026-08-29/images/03-ene-ordinary.png` — `84c32b6dd966fd22629d1c758e06f9de552ab0216c782b9f7a33257ef8e4dfb2` | Runs `9..10`; physical scale is visually consistent with SSE at gameplay distance and the lower edge is grounded. |
| Changed-light accepted corner | `evidence/first-playable/ymca-exact-run-correction-2026-08-29/images/04-corner-changed-light-oblique.png` — `f61c439e6b3916d50af5f8e3e66150667cdb0b678ecbbda0329718c2f6059361` | Runs `7`→`8`; clean orthogonal join, plausible orientation-dependent illumination, no projection artifact or false seam. |
| Accepted→placeholder close boundary | `evidence/first-playable/ymca-exact-run-correction-2026-08-29/images/05-run-11-12-boundary-close.png` — `14c47f19826a97707a377ba297c1b52309e117af17560197c79b04a881018eec` | Runs `11`→`12`; exact crisp termination with no overlap, tear, slit, floating edge, or z-fight. |
| Accepted→placeholder ordinary / whole-object approach | `evidence/first-playable/ymca-exact-run-correction-2026-08-29/images/06-run-11-12-boundary-ordinary.png` — `bd3e63d3ad4dc463f5b3b88c5a83a9b5ed3a5cb6f0b534d9b076d1dcdbac33ac` | Boundary remains clean at ordinary distance; the same view also confirms that whole-building resemblance is still blocked by blank massing and missing architectural modules. |

The four predecessor PNGs and their manifest were re-inspected as immutable comparison evidence. They established a locally plausible SSE field but did not show ENE or the terminal boundary. The corrected set closes those exact coverage gaps. Acceptance is based on the actual YMCA reference/specification and the declared field kind, not on visual similarity to the placeholder surfaces visible in `05` and `06`.

## Corrected material identity and contract

- Target material: `game/resources/materials/world/ti_ymca/ti_ymca_primary.tres` — SHA-256 `b5e44afcf4feb6df6ffba46f4e3b60a25fa6043c07c12c33e31c483cb2bf2399`.
- YMCA-only shader: `game/resources/materials/world/ti_ymca/ti_ymca_wall_tangent_aperiodic_field.gdshader` — SHA-256 `8943853363f5a2571ebf15a6e9711c6310b706d2e4415f3e1f314d8643d55f6c`.
- Focused contract: `game/tests/headless_ymca_wall_tangent_projection_contract.gd` — SHA-256 `18ec1c0d6d6b50bf7dc7ec5131659c009dd78cde61243294d5d9bc6fde510440`.

The exact correction is:

```text
before: field_position_m = VERTEX.xy
after:  field_position_m = vec2(dot(VERTEX.xz, wall_tangent), VERTEX.y)
        where wall_tangent = vec2(normalized(NORMAL.xz).y,
                                  -normalized(NORMAL.xz).x)
```

This makes the horizontal field coordinate advance in physical wall-tangent metres independently of SSE or ENE orientation while preserving the accepted field algorithm, color, `0.420 / 0.095 m` parameters, `0.91` roughness, and `0.08` relief.

## Disposition and retained limits

- `Y-EXACT-01` correction: **ACCEPT**.
- Homogeneous field on exact runs `3..11`: **may remain attached**, with the documented substrate/scale limitation.
- Further correction for this homogeneous field: **none required**.
- Whole YMCA building: **not accepted**. Architectural modules, panel joints, entry, openings, other sides, and massing require their own reference-backed work and independent evidence; this addendum authorizes none of them.


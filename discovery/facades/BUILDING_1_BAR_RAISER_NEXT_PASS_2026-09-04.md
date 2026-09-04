# Building 1 bar-raiser — smallest next quality pass

Reviewed: **2026-09-04**  
Reviewer: **`/root/remote_runtime_auditor/ledger_recheck/release_inventory_audit/ignored_artifact_scan`**  
Scope: **design/audit only; no production, evidence, source-pixel, staging, or
release mutation**

## Decision

Do one **entrance-group separator calibration** and stop. Change only
`entrance_group_gap` in
`game/resources/facades/building_1_public_front_believability.json` from
`0.55 m` to **`0.90 m`** as reversible production inference. Keep all three
`2.85 m`-wide, three-leaf entrance groups centered under the one accepted
canopy, and keep every depth, height, border, frame, material, mesh bucket, and
collision input unchanged.

This is the smallest change with a direct line from an independently observed
limitation to a likely player-visible gain. It does not reopen Building 1's
accepted recognizability, massing, or public-front believability verdict. It
only makes the source-supported **three-group** entrance grammar countable on
first read instead of letting nine door leaves compress into one dark barcode.

The exact `0.90 m` value is not asserted as a real measurement. It is a bounded
game-art calibration that must earn promotion in a current A/B and walking
sweep. If it fails, revert it; do not compensate with signs, bright color,
enlarged doors, camera placement, or more facade detail.

## Evidence boundary

The judgment followed this order:

1. original-detail accepted Building 1 hero and public-front frames, including
   all three public-front before/after pairs and changed light;
2. the superseding grounded tower pair;
3. independent recognizability and bar-raiser reviews;
4. NPS/museum-derived source packets and their explicit inference boundaries;
5. exact-current configs, adapter logic, router state, materials, capture
   metrics, topology receipts, and the repository's available motion media.

Primary review inputs were:

- `discovery/facades/TREASURE_ISLAND_BUILDING_1_HERO_RECOGNIZABILITY_SPEC.md`;
- `discovery/facades/TREASURE_ISLAND_MUSEUM_BUILDING_1_REFERENCE_SPEC.md`;
- `discovery/facades/TREASURE_ISLAND_BUILDING_1_RECOGNIZABILITY_ART_REVIEW.md`;
- `discovery/facades/VISUAL_BAR_RAISER_REVIEW_2026-09-04.md`;
- `evidence/first-playable/building-1-hero-2026-09-04/`;
- `evidence/first-playable/building-1-public-front-believability-2026-09-04/`;
- `evidence/first-playable/building-1-tower-grounded-correction-2026-09-04/`;
- `evidence/first-playable/genai-texture-pilot-v1-2026-09-04/`;
- `evidence/first-playable/exact-current-visual-repair-2026-09-03-104510/`;
- `game/resources/facades/building_1_hero_model.json`;
- `game/resources/facades/building_1_public_front_believability.json`;
- `game/scripts/world/facades/building_1_hero_model.gd`; and
- `game/scripts/world/world_chunk_builder.gd`.

The accepted public-front pixels were captured before package sanitization.
That later migration changed only source/provenance locators: the sanitization
receipt explicitly preserves visual, geometry, collision, navigation, and
spray semantics. At review time the package-facing config identities are
`f10bc92a6e74cbae41347e742e6c68c50faccddbd52ab3ecce210ac8243bc6e9`
for the hero config and
`fd434eb472f61d93408732841e5993881b23238af8c0518b59181ac0ea535e32`
for the public-front config. The active Building 1 adapter remains the captured
`e5b11fc7f971ea33bb38c84d3106f8883de0486774f58a5a8310d49d56aa55a5`.
These facts connect the accepted pixels to current Building 1 semantics; they
do not substitute for a fresh live A/B after any new change.

There is **no Building 1 motion clip** in the repository. The 2026-09-03
exact-current visual-repair set predates the accepted hero/public-front passes
and therefore supplies route and grounded-camera context, not exact-current
proof of the present facade. Motion readability is an open evidence item, not
an observed failure.

## Grounded player-height read

### What already carries identity

- The truncated concave plan and stepped `2/3/4`-story composition read before
  material detail.
- The eleven tall center bays dominate the public sweep and remain rhythmically
  legible under changed light.
- The projecting base, full canopy, lower wings, paired end families, and
  separately keyed octagonal tower form a coherent hierarchy.
- The accepted public-front pass supplies real highlight and contact-shadow
  changes through geometry. It is no longer a flat facade drawing.
- The misleading cruciform-like end plaque is gone. Its quiet neutral
  relief-location field is correctly subordinate and must remain so.

Recognition is therefore **PASS, unchanged**. Architectural believability is
**PASS_WITH_LIMITATION**: convincing low-poly game architecture, not an
as-built or photoreal reconstruction.

### The remaining schematic read

At the accepted entrance view the first wall hit is about `79.5 m` away; the
whole-front view is about `80.4 m` away. The current entry construction uses:

- group width: `2.85 m`;
- group gap: `0.55 m`; and
- reveal border: `0.24 m` on each side.

The adapter makes each reveal backing `2.85 + 2(0.24) = 3.33 m` wide while
adjacent group centers are only `2.85 + 0.55 = 3.40 m` apart. The pale separator
left between reveal backings is therefore only:

`0.55 - 2(0.24) = 0.07 m`.

At roughly `80 m` with the accepted `70 degree` FOV and `1440x900` viewport,
that is on the order of **half a pixel** before curvature and contrast loss.
The pixel-first result matches the math: the entrance exists and is correctly
placed, but the three groups initially merge.

Changing only the group gap to `0.90 m` produces a `0.42 m` pale separator and
grows the centered three-group ensemble from `9.65 m` to `10.35 m`. That is
roughly a three-pixel separator at the same distance, enough to test a first-read
grouping without changing door scale or turning the entrances into three
unrelated storefronts.

The broader wings still use economical, shallow opening treatment and the roof
edges remain quiet. Both contribute to the low-poly character, but neither is a
more precise next target than the entrance limitation already identified by
independent review. The broad ivory material is also restrained rather than
rich; the accepted material pilot found only a modest possible improvement and
explicitly said it cannot fix entrance hierarchy.

## Ranked candidate interventions

| Rank | Candidate | Evidence support and expected gain | Topology / performance risk | Protected surfaces |
| ---: | --- | --- | --- | --- |
| **1** | **Increase only the spacing between the three existing entrance groups** | Directly answers the accepted review's sole remaining facade limitation and reinforces the NPS-supported three-group grammar. Highest gain per unit of change: the building acquires a clearer human destination at the same grounded distance while all identity carriers remain fixed. | **Very low.** Same nine doors and same boxes, mesh buckets, surfaces, and draw organization; only vertex positions change. Building 1 should remain `8,806` wall and `1,131` roof triangles, with unchanged collision hashes, but the builder must remeasure rather than assume. | Exact footprint; `2/3/4` massing; eleven center bays; all window/pilaster depths; door width/height/leaves; reveal border/depth; base; canopy; end fields; wings; roofs; rear/inner faces; tower; materials; UVs; collision, navigation, spray, and traversal. |
| **2** | Add a shallow reveal/sill construction read to the two wing window families | The source packet supports the separate wing family and its `8` upper / `7` lower windows per wing. It would reduce the remaining sticker-like read across a large part of the public front and improve opening depth in oblique motion. | **Low-to-medium.** Thirty repeated openings broaden scope. One new cuboid per opening is about `+360` triangles before any sill/frame additions; repeated bright edges could alias or become a white cage. It requires fresh topology, changed-light, and motion review. | All center-front geometry and entry work; exact wing cadence and opening positions; end compositions; corners; roofline; rear/inner unknown faces; footprint/collision; tower. No copied center-window subdivision. |
| **3** | Run the existing warm-ivory mineral tile as an isolated live material A/B | The independent pilot passed with limitation at a `3.0 m` span and found a modest mineral-surface improvement, not a recognition gain. It could make large pale fields feel less sterile after geometry is stable. | **No geometry cost, but meaningful material risk.** Requires unified metre-based UVs, a `512`/`1024` production derivative decision, import/residency measurement, and walking proof against shimmer or a moving repeat grid. It can wash out trim/opening value hierarchy. | Every geometry and cadence cue; entrance/window/base/trim/glass value separation; all source boundaries. No facade image, baked light, generated normal, unique per-building texture, or invented marks. Minor discoverable tiling imperfection is nonblocking if it never dominates in motion. |

### Why roofline work is deferred

The stepped roof silhouette already carries recognition and survives the
grounded views. A new coping or parapet family would either be too small to
matter at the reviewed distance or would alter a protected silhouette and risk
visual/traversal disagreement. Carrying an evidence-safe edge around the large
unknown rear may eventually help continuity, but it does not beat the entrance
fix and must not become a pretext for invented rear openings or programs.

## Bounded builder brief

### Authorized experiment

1. Starting from the accepted current Building 1 state, create one reversible
   B candidate with `entrance_group_gap = 0.90`.
2. Change no other public-front, hero, material, tower, router, collision,
   navigation, spray, or traversal parameter.
3. Preserve the same center anchor and group order. The result remains three
   triple-door groups under one canopy, not three separate entrances spread
   across the facade.
4. Do not add labels, signage, literal sculpture, arbitrary hue/value accents,
   random noise, whole-facade GenAI, interior imagery, or source pixels. Keep
   the quiet neutral end fields and zero cruciform proxies.
5. Do not touch the rear/east or inner faces. Their opening programs remain
   unknown.

This brief authorizes a **future comparison**, not implementation in this
review.

### Required proof

- A/control and B/candidate from the accepted grounded stock-player rig at
  `70 degree` FOV and `1440x900`, using the same whole-front and
  entrance-focused poses, default light, and the same changed-light pose.
- A grayscale comparison from the same pixels; the grouping must come from
  spacing, recess, and existing value structure, not hue.
- One genuine time-continuous stock-player walking approach or parallel sweep
  that traverses ordinary route distances (approximately `60 m` into the
  `20–30 m` range). Do not write player or camera transforms after input begins.
- Exact before/after Building 1 wall/roof triangle, mesh, surface, and collision
  counts, plus collision hashes and the usual footprint/source-key/router
  contracts.

### Promotion gate

Promote B only if an independent pixel-first reviewer can count all three
groups on first inspection in the entrance-focused ordinary frame, they remain
distinct through the walking sweep, and they still read as one centered
canopy-led entrance ensemble. The eleven-bay center and stepped massing must
remain dominant. Reject B for disconnected-storefront read, z-fighting,
shimmer/crawling bright edges, loss of canopy unity, or any topology/collision
change that the one-scalar brief cannot explain.

If `0.90 m` is too wide, do not layer on new detail. Test the smallest lower
gap that retains a stable separator, bounded to `0.80–0.90 m`, and document the
chosen value as production inference. If no value in that band passes both
still and motion, keep the accepted current state and escalate Candidate 2 as a
separate review. Candidate 3 remains later material polish only.

## Final bar-raiser verdict

Building 1 is already recognizable and sufficiently believable for the
project's low-poly target. The next pass should be smaller than the pass that
earned that result. A one-scalar entrance spacing calibration is the most
defensible way to make the public front feel less schematic at grounded player
height while preserving the exact accepted building, the honest source
boundary, and the removal of the misleading cruciform plaque.

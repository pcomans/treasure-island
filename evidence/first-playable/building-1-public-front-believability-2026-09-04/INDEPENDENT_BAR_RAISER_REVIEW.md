# Independent bar-raiser review — Building 1 public-front believability

Reviewed: **2026-09-04**

Reviewer: **`/root/visual_bar_raiser`**

Review order: **all six sealed PNGs at original `1440x900` detail first,
without manifests or implementation labels; stage manifests, truth boundary,
hashes, exact-pose contract, and focused geometry/collision contract afterward**

## Verdict

**PASS_WITH_LIMITATION — promote the after candidate as the new accepted
Building 1 visual state.**

The limitation is nonblocking: from the widest roughly `80 m` ordinary-player
view, the three entrance groups first read as one central entrance ensemble and
their internal separation requires a second look. In the entrance-focused
ordinary view they remain visible as three glazed/bronze groups beneath a
single canopy, so the entrance is not functionally invisible. The candidate
clears the believability / visual-interest gate without depending on
photorealism, tiny ornament, an image texture, or a camera trick.

The already independent recognition acceptance remains intact. This review
changes no denominator or numerator by itself; it closes the bounded quality
reopening identified in
`discovery/facades/VISUAL_BAR_RAISER_REVIEW_2026-09-04.md`.

## Promotion and topology decision

**Yes: the catalog and coordinated global pins may advance from `60,544` to
`61,876` triangles.** The accepted delta is precisely the reviewed public-front
candidate:

| Measure | Before | Accepted candidate | Delta |
| --- | ---: | ---: | ---: |
| Runtime records | 735 | 735 | 0 |
| Meshes | 931 | 933 | +2 |
| Surfaces | 941 | 943 | +2 |
| Triangles | 60,544 | 61,876 | +1,332 |
| Static bodies | 466 | 466 | 0 |
| Shapes | 466 | 466 | 0 |

The `+1,332` triangles are explainable as `+780` on the Building 1 wall
(`8,026 -> 8,806`) and `+552` on its roof/canopy
(`579 -> 1,131`). Wall and roof collision face counts remain `2,046` and
`1,737`. The shared pin owner should update all affected catalog, startup,
integration, and legacy acceptance assertions as one coordinated change, then
rerun them against the same current tree; this review does not edit those
files.

## Pixel-first visual judgment

| Gate | Result | Original-detail finding |
| --- | --- | --- |
| Unmistakable massing | **PRESERVED** | The accepted concave center, stepped wings, eleven tall bays, and tower remain the dominant identity. |
| Real recess / projection | **PASS** | Glazing, reveals, frames, pilasters, base, and canopy no longer collapse onto one facade plane. Narrow highlights and contact shadows survive both light setups. |
| Pilaster rhythm | **PASS** | Twelve projected divisions give the eleven-window sweep a readable structural cadence. Repetition is controlled rather than noisy. |
| Base hierarchy | **PASS** | The projecting lower field and cap form a grounded horizontal datum under the tall glazed center. They do not read as arbitrary striping. |
| Canopy leading edge / underside | **PASS** | The canopy now has a legible top, slim front edge, and darker underside rather than one flat grey bar. Its long sweep remains subordinate to the upper bays. |
| Three-entry hierarchy | **PASS_WITH_LIMITATION** | A central human-scale dark/bronze entrance ensemble is plainly visible beneath the canopy; the three groups are readable in the entrance-focused frame but compress together in the widest frame. |
| End-composition semantics | **PASS** | The former high-salience cruciform proxy no longer competes with the building identity. Quiet neutral relief-location fields avoid claiming a literal unsupported sculpture. |
| Restraint / visual interest | **PASS** | Added detail follows facade structure and light response. There is no wallpaper, procedural speckle, arbitrary color swap, floating plaque, or uniform detail spread across every surface. |

### Pair 01 — public-front whole, ordinary light

The before image is recognizable but planar: tall dark windows sit in a nearly
continuous pale sweep, and the lower front is dominated by one broad horizontal
band. The after image gains a clear hierarchy. Recessed glazing is framed by a
regular projected bay cadence; the repeated white edges reinforce the curve
without changing its silhouette; and the base/canopy/entrance zone becomes a
secondary grounded composition. The brighter framing approaches a graphic
outline when scrutinized, but at actual player distance it remains coherent
architectural rhythm rather than a white cage or decorative noise.

### Pair 02 — entrance-focused ordinary view

The after frame makes the lower center usable as a destination. The dark glazed
and bronze door groups sit behind the canopy line, while posts/reveals and the
projecting base establish foreground, threshold, and wall planes. The entrance
is small because the grounded camera is still about `79.5 m` from its first
wall hit; it is nevertheless visible and semantically placed. Enlarging it for
the screenshot would weaken the whole-building proportions and is not required.

The white plus sign near image center is the unchanged gameplay reticle in both
stages, not facade geometry. It is therefore not evidence that the removed end
composition still reads as a cruciform architectural symbol.

### Pair 03 — whole front, changed light

This is the decisive anti-wallpaper check. Under the frozen alternate sun, the
new bay edges, recesses, base cap, and canopy bands change their highlight and
shadow response while retaining the same organization. The facade does not
flatten into painted lines or reveal baked illumination. The quieter end fields
stay subordinate. Nothing becomes busier, misleading, or materially noisier
when the light changes.

## Exact-current technical verification

The visual verdict above was fixed before these checks.

- All six PNG SHA-256 values match their stage manifests and the focused
  evidence contract. The combined evidence manifest is
  `2b813cd8487e3591c456635a1e352a64d614ddf69f506dcd72623172d867754f`;
  its sealed before/after manifest hashes are
  `7e6d1a549a678f63b3dd2bff1693bfd53f6979b44fa8f2f84e3d72754292780f`
  and
  `bef28d2c1e021742a3f099a9a5b0ef0a8e7e8c258c1cac21e36797275d548e8f`.
- Every pair preserves requested player XZ, settled player position, aim
  target, camera position and forward vector, `70 degree` FOV, `5.5 m` spring
  length, and sun rotation within the contract's `0.001` tolerance. The first
  line-of-sight receiver remains `building:r16681702:wall`, source
  `r16681702`, and the reticle/aim target remains centered.
- A fresh
  `headless_building_1_public_front_believability_evidence_contract.gd` run
  passed the three exact fixed-camera native Metal before/after pairs,
  including changed light.
- A fresh `headless_building_1_public_front_believability_contract.gd` run
  passed deterministic component topology, exact frozen horizontal plan,
  material/hash checks, wall-only spray ownership, unchanged roof traversal,
  and collision preservation. It measured wall/roof triangles `8,806/1,131`
  and collision SHA-256 values
  `21d69032bdba73c0406545b0b7d2c8efefd423fe8263815c3edc57bdc3756db5`
  / `bb2c36915cba6d9d5f5d1a8239888ef1c913b1e4396eb6ce1cd2145c1a38e337`.
- The before and after stage manifests preserve their own capture-generator
  hashes. The hashes differ because the capture harness was repaired between
  stages; that fact was not treated as visual evidence. The sealed image bytes
  plus independently checked camera/light fields establish the comparison.
- The pass uses three scalar materials only. No GenAI texture, generated facade
  image, source photograph, normal/height fabrication, or facade-photo
  wallpaper participates in this review.

## Keep / change guidance

### Keep exactly through promotion

- the accepted footprint, truncated concave sweep, `2/3/4`-story hierarchy,
  eleven tall center bays, wings, roof tiers, and tower relationship;
- the present reveal/frame/pilaster depth cadence and its restrained light
  response;
- the projecting base cap and darker canopy underside/leading-edge separation;
- the three glazed/bronze entrance groups as one deliberately central ensemble;
- the quiet neutral end relief-location fields and zero cruciform proxies;
- unchanged collision, roof traversal, wall-only spray ownership, source key,
  and explicit no-as-built/no-survey truth boundary.

### Change only as optional later polish

- If a future nearer walking view shows the three entries merging, increase
  separation through the existing recess/bronze/value hierarchy, not by making
  doors fluorescent, adding signs, or enlarging the whole facade.
- If temporal play evidence shows the fine bright pilaster ribs shimmering,
  simplify or slightly thicken the smallest rib family while retaining the
  twelve-pilaster cadence. A still-image dislike of tiny fluting is not enough
  reason to reopen this accepted state.
- A later material A/B may enrich the broad ivory field only after being judged
  separately. It must not be credited for the recognition or believability
  improvement accepted here.

Do not reopen this pass for literal sculpture, interiors, surveyed dimensions,
micro-ornament, rear-window invention, or generic grime. The smallest remaining
meaningful risk is entry-group separation during motion; it is optional polish,
not a blocker to acceptance or the `61,876` topology pin.

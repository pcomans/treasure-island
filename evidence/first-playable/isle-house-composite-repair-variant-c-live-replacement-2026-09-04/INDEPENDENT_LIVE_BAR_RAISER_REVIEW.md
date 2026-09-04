# Independent live bar-raiser review — Isle House Variant C replacement

Reviewed: **2026-09-04**  
Reviewer: **`/root/d4_reference_research`** (independent; did not build or
integrate this candidate)  
Exact-current visual decision: **PASS**  
Physical-building counting decision: **PASS as exactly one entity**

## Decision

**PASS. The exact world-attached Variant C replacement is recognizable and
believable enough to enter the exact-current recognition result.** The live
result preserves the standalone Variant C visual PASS: all three Variant B
blockers remain resolved in the actual world, under changed light, on the quiet
NNW return, and throughout the complete declared stock-player motion interval.

The eligible recognition unit is
`physical-building:w1249412094` (Isle House) **once**, not its two
`building_part` source records separately. Receiver `w1282547786` supplies the
accepted high part and receiver `w1282547787` supplies the reviewed Variant C
low part; together they are one composite physical building. Accordingly:

- denominator identity/counting: **PASS as one of the fixed 213 physical
  recognition units**;
- exact-current recognizable acceptance: **PASS for one numerator unit**; and
- prohibited double-count: **do not count `w1282547786` and `w1282547787` as
  two buildings**.

This review authorizes that one-unit catalog/registry acceptance and the global
topology repin, but does not perform either mutation. The presently sealed
catalog and registry still say `not_evaluated`/generated-placeholder for this
unit because the integration packet correctly did not self-promote before this
review.

## Evidence and bytes inspected

- `AGENTS.md`; the authoritative packet
  `discovery/facades/p1_reference_packets/w1249412094_isle_house.md`; the prior
  Variant B `FAIL`; and the standalone Variant C `PASS`.
- The live README, checksums, still and motion manifests, capture harness, exact
  adapter, repair-only factory, reviewed standalone factory/config, builder
  dispatch seam, focused live integration contract, source package contract,
  direct-mounted package contract, and evidence contract.
- All four original `1440 x 900` actual-live PNGs at native detail.
- The native `1280 x 800`, 30 FPS Motion JPEG AVI. I independently extracted
  all `222` encoded JPEG frames. Every frame in the inclusive declared useful
  process interval `65..215` (`151` frames) was inspected in ten ordered
  `4 x 4` sheets retaining `320 x 200` per frame. Frames `65`, `80`, `95`,
  `110`, `125`, `140`, `155`, `170`, `185`, `200`, and `215` were also
  inspected at original `1280 x 800` detail. Temporary extraction files were
  kept outside the repository and removed after review.
- `shasum -a 256 -c CHECKSUMS.sha256`: **PASS** for every declared artifact and
  production/test byte. The independently read AVI digest is
  `930c444e5599bb5dad82883d7f29331c0fbfdc9be3039967fb3fc59f9491f957`.

## Actual-live and camera truth

The packet resolves the real world child at the exact path below the low
receiver:

`.../building-composite_w1249412094_w1282547787_wall/IsleHouseCompositeRepairVariantCLiveAttachment`

The manifest, harness, and fresh contracts agree on **zero preview or
standalone attachments**, one Variant C live child, zero rejected live child,
zero stacking, and zero rejected fallback. No review-only facade is attached by
the capture harness.

There is no camera trick. All four stills use the ordinary stock player camera
at `70 degree` FOV, an input-reachable orientation, physics-grounded poses, and
no crop or postprocess. The WSW default/changed-light pair uses the exact same
player/camera pose and an effectively uncompressed `5.5 m` spring arm. It is a
truthful whole-composite view: the exact high receiver is the first LOS hit and
the measured projections materially expose both parts:

| Part | Clipped projection | Frame area |
| --- | ---: | ---: |
| accepted high `w1282547786` | `306.36 x 495.68 px` | `11.72%` |
| reviewed low `w1282547787` | `593.28 x 168.34 px` | `7.71%` |

The ENE image is correctly limited to a public-side supplemental detail view;
its spring arm is world-compressed only to `5.0596 m`, remains well above the
declared `2 m` minimum, and first hits the exact low receiver. The NNW image is
a grounded direct inspection of the protected quiet return and also first hits
the exact low receiver. Neither supplemental image is misrepresented as a
whole-composite acceptance camera.

Motion uses stock `move_right` input at the configured `4 m/s` walk speed, not
a cinematic path or detached camera. The useful interval corresponds to
physics frames `131..431`: `300` samples / `5.0 s`, `19.8834915 m` horizontal
displacement, all samples grounded, zero recovery delta, zero player-transform
writes after input begins, and unchanged camera orientation. It continuously
crosses the declared WSW run `2 -> 3` join.

## Bar-raiser assessment

### Recognizability and player-distance interest — PASS

The light folded tower remains the dominant long-range Isle House cue. The
Variant C low realm now adds a distinct warm brick base, two-level live-work
scale, individualized entry/gallery groupings, patio thresholds, canopies, and
planter-scale cues. Those large-form cues remain legible in the whole view and
through movement; the result does not depend on a plaque, metadata, or a tiny
detail for recognition.

At ordinary player distance the lower facade has enough visual interest to
hold attention without becoming noisy. Broad brick pauses separate the groups,
and the four macro arrangements retain visibly different proportions and
solid/void silhouettes as they traverse the frame. The player avatar occludes
one local slice at any instant, but the continuous walk and ENE supplement
expose the complete rhythm.

### High/low hierarchy and upper transition — PASS

The composite reads in three tiers: tall folded light tower, quiet stepped
podium transition/crown, and darker occupied brick live-work base. The public
upper transition no longer reads as Variant B's single temporary cover sheet.
Its unequal transfer, warm body, light crown, and cap bands retain distinct
heights, values, and shallow depth under both lights and across the full motion
interval. The main body remains deliberately low-information, but the complete
hierarchy is intentional and believable rather than masked or unfinished.

### Lower macro rhythm, depth, and occupation cues — PASS

The low realm does not collapse into a regular storefront slot row. The broad
two-level gallery with side entry, mostly-brick pause with offset entry/upper
cue, layered lower/upper gallery, and broad lower gallery with split upper
cluster remain separable in the native frames. Recessed dark glazing, framed
edges, half-door divisions, shallow canopies, thresholds/patios, and small
planters add sufficient depth and human scale. Opaque glazing compresses some
fine detail, but the deciding macro proportions and entry/gallery/patio reading
survive.

### NNW protected return — PASS

Runs `10..12` are one calm scalar field. The prominent generic/checkered grid
that blocked Variant B is absent under the direct grounded NNW view. The plane
is intentionally quiet and source-limited, not rich; that is the honest
treatment where no mapped NNW opening or cladding schedule exists. It no longer
competes with the public hero sides or reads as a tiled placeholder.

### GenAI brick continuity, tileability, and changed light — PASS

The brick course remains visually continuous through the complete run `2 -> 3`
motion interval. I found no obvious UV seam, phase jump, crawling grid, shimmer,
moire, fixed shadow, or baked-light patch. Changed light alters form/value
coherently rather than revealing illumination painted into the albedo.

Faint source-cell recurrence is discoverable when paused and searched for, and
small cap/run-joint variations remain at close range. Neither is distracting in
play. Under the explicit progress-over-perfect rule, tileability is an
iteration target rather than a perfection gate; these minor limitations do not
justify rejection or regeneration.

### Believability — PASS

The candidate is stylized and intentionally coarse, but its depth/value
hierarchy, inhabited lower scale, material transition, and irregular macro
rhythm read as a plausible building rather than a flat facade card. The whole
object is now materially more specific than the surrounding generic masses.
Perfect realism is neither claimed nor required for this gate.

## Source and inference boundary — PASS

Primary/official evidence supports the Isle House identity and address, a tall
folded light tower, a podium, a warm brick/handcrafted pedestrian realm, and
nine two-level live-work homes with individual entry/patio language. It does
not map a complete exact run-by-run facade schedule.

The exact four arrangements, eight placements, widths, order, mirroring,
opening proportions, canopy/patio depths, planter proxies, upper-band
proportions/relief, and NNW scalar value remain correctly labeled reversible
production inference. The candidate does not claim:

- an exact upper opening, floor, window, or story schedule;
- a literal seven-story correction to the frozen five-level low geometry;
- an observed NNW opening or cladding schedule;
- a private/rear/courtyard facade, interior, or operable element; or
- surveyed/as-built fidelity.

That bounded massing discrepancy remains outside the recognition claim. Source
photography, third-party pixels, source URLs, discovery files, and evidence
files are absent from the mounted runtime package.

## Runtime seam, topology, and ownership — PASS

The builder has one exclusive Variant C preload and dispatches it only when the
exact low record matches. The rejected low adapter path is absent. The live
adapter fails closed on receiver identity, record geometry, reviewed hashes,
factory output, signature, topology, source boundary, and ownership. The
repair-only factory reuses the independently approved Variant C construction
without standalone preview/A-B teardown behavior.

Fresh measured values on the reviewed exact-current bytes are:

- live wrapper signature:
  `09eee1517f043c6d82f0de0d2275da5b2a3f76f5842d1b9c90cba11e6e793981`;
- repair signature:
  `41868b77a8b51b56ee7381e5549423e97547270d2dc77d9ce5cf958b31e2cb69`;
- Variant C overlay: `7 meshes / 11 surfaces / 2,242 triangles`;
- exact low receiver including its unchanged base: `8 / 12 / 2,268`;
- whole world: **`735 rows / 940 meshes / 954 surfaces / 64,118 triangles /
  466 static bodies / 466 shapes`**; and
- composition: **one Variant C, zero rejected child, zero fallback, zero
  stacking**.

The accepted high signature remains
`e624a40551efb5bb5b137b731ebcd4ffbdcafbb70e8c5560c5cc07e8c10637a1`.
Variant C owns no collision object, collision shape, navigation region, or
spray group. The underlying low wall remains the sole collision and spray
receiver. Body/shape counts stay `466/466`; the replacement adds render detail
only.

## Read-only validation

All bounded checks passed on the reviewed bytes:

1. focused exact-low live integration contract: **PASS**, including one C,
   zero rejected/fallback, accepted high unchanged, `8/12/2268` low, and
   `735/940/954/64118/466/466` world;
2. source package contract: **PASS** at `7/11/2242` and full-world topology;
3. evidence contract: **PASS** for four native actual-live frames, exact
   binding, preview count zero, and the 300-sample grounded motion interval;
4. direct-mounted package contract, seal A: **PASS**;
5. direct-mounted package contract, seal B: **PASS**; and
6. seal A and B PCKs are byte-identical, SHA-256
   `d2febfe768177f25e85e63acda96d7d6f88dcc31738e63272377ac8b7aa9d5f2`.

The older global `933/943/61876` oracle mismatch described in the README is an
intentional pre-review pin, not a defect in this candidate. This PASS supplies
the independent authority needed to repin it to `940/954/64118` while retaining
`735/466/466`.

## Ranked blocking defects

**None.** No remaining issue crosses the recognizability, believability,
source-truth, camera, motion, material, package, or ownership threshold for
exact-current acceptance.

## Ranked non-blocking limitations

1. The middle podium body is still a broad low-information plane. Its bounded
   transfer/crown/cap hierarchy now makes the restraint intentional; inventing
   an unsupported opening grid would be worse.
2. The NNW protected return is conspicuously plain in its direct view. It is an
   honest evidence ceiling and no longer exposes the failed generic grid.
3. Opaque dark glazing suppresses some fine frame, canopy, half-door, planter,
   and patio detail in the widest camera. The four macro arrangements remain
   distinct enough to pass.
4. Faint brick recurrence and minor shallow-cap joint variation can be found at
   close range. They do not form an obvious seam, baked-light artifact, shimmer,
   or distracting motion pattern.
5. The stock avatar blocks one narrow central slice of the low facade in each
   motion frame. Continuous travel, the unoccluded sides, and the ENE still make
   the full lower rhythm reviewable.

## Promotion boundary

Count Isle House as **one** exact-current recognizable physical building once
the catalog/registry/global oracle are updated from these reviewed bytes. Do
not count either building-part receiver separately. No visual recapture is
required solely for that ledger/global repin if the reviewed runtime geometry,
materials, camera evidence, and signatures remain unchanged. Any later change
to those visual bytes requires a new bounded review.

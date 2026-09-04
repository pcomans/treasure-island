# Independent bar-raiser review — P3 Chapel and Dormitory

Date: 2026-09-04  
Reviewer: `/root/visual_bar_raiser`  
Independence: the reviewer did not implement either treatment, choose the
camera poses, or capture the evidence.

## Decision

**FAIL — exact numerator change: `+0` of a possible `+2`.**

| Target | Recognition | Believability / visual interest | Numerator |
| --- | --- | --- | ---: |
| Navy Chapel Building 187, `w291189336` | **FAIL** | **FAIL** | `+0` |
| Job Corps Dormitory 369, `w291189926` | **FAIL** | **FAIL** | `+0` |
| **Batch total** |  |  | **`+0`** |

The four captures are technically valid exact-current evidence. That does not
make either whole object recognizable. The existing narrowly bounded material
treatments may retain their prior component-level status, but neither treatment
earns building-level denominator credit from this review.

Both failures are identity-critical. Neither may be recorded as a
non-identity limitation.

## Review order and blind image read

I opened all four uncropped `1440x900` originals at original detail, judged only
their pixels without consulting manifest labels or source packets, and fixed
the following image-only observations before the packet comparison:

- The Chapel candidate read as a low pale service/institutional slab: a broad
  quiet face, a generic densely repeated small-square treatment on another
  face, and no legible religious or entry-focused silhouette. There was no
  visible focal entrance, gable, tower, belfry, or distinctive opening family.
- The Dormitory candidate read as a very distant, shallow pale strip. It was
  too short in the image to expose a multi-storey organization, and no stair/end
  volume, tier rhythm, eave hierarchy, window family, or ground-floor program
  was legible.

The source comparison below did not overturn either blind result.

## Gate matrix

| Required gate | Chapel | Dormitory |
| --- | --- | --- |
| Two grounded ordinary-player views | **PASS** technically | **PASS** technically |
| Complete whole-object read, not a crop | **PASS** technically | **PASS** technically |
| At least two source-supported identity cues | **FAIL** — zero countable cues | **FAIL** — zero countable cues |
| At least one structural or facade-family cue | **FAIL** | **FAIL** |
| Top-1 against the frozen close confusion set | **FAIL** | **FAIL** |
| Untreated / unknown faces shown honestly | **PASS** | **PASS** |
| No dependence on hue, address, location, or IDs | **FAIL** if asked to identify it | **FAIL** if asked to identify it |
| No crop, FOV, lighting, or detached-camera trick | **PASS** | **PASS** |
| Source-truthful massing | **FAIL** — chapel silhouette absent | **FAIL** — five tiers contradict the `6 m` fallback |
| Believability / visual-interest gate | **FAIL** | **FAIL** |

Passing the honesty and camera gates is valuable: the evidence exposes the
missing work. Those gates do not compensate for missing identity.

## Navy Chapel Building 187 — `+0`

### Reference comparison

The authoritative P3 packet supports three useful public-read compositions:

1. an SSE gabled entrance end with a tall vertically divided multipane window
   above a shallow projecting porch/entry;
2. a square belfry/tower with a pyramidal cap and visible cross; and
3. a warm cream field with partial long-side groups of tall narrow windows and
   small openings in the gable field.

Neither evidence view exposes the first or second composition. The third is
also absent as a defensible opening family. The warm cream field is visible,
but hue/background material cannot count as an identity cue. The repeated
small-square read on one face is generic and is not a substitute for the
packet-supported tall narrow chapel openings.

The broad side is honest but visually inert. It neither supplies the partial
narrow-window rhythm supported by the packet nor a coherent roof/base/entry
hierarchy. Unknown side coverage should remain quiet; it should not be filled
with speculative repeated windows merely to make the surface busy.

### Confusion and believability verdict

Against Oasis `w291189918`, Dormitory 369 `w291189926`, Food Service 368
`w34313521`, and nearby low California Avenue institutional blocks, this object
is not top-1. Its low rectangular silhouette and pale field place it inside the
generic cohort. The absent belfry/cap and absent gable-window-entry composition
remove the two strongest long- and medium-distance discriminators.

Believability also fails: the roofline has no chapel focal silhouette; the
public end has no entrance hierarchy or real projection/recess; the broad face
has no evidence-backed vertical rhythm; and the material treatment reads as a
surface state rather than a designed building. The result is not merely plain;
it is functionally non-specific.

### Smallest truthful repair, ranked

1. **Restore the roof silhouette in geometry.** Add the observed square
   belfry/tower, pyramidal cap, and restrained cross on the source-supported
   roof zone. Disclose bounded production inference for dimensions; do not
   bake this silhouette into a texture.
2. **Build one complete SSE focal composition.** Make the gabled end, tall
   divided multipane window, and shallow projecting porch/entry read together
   with real depth. Do not invent stained glass, exact pane counts, or unseen
   door ornament.
3. **Add only the mapped partial side rhythm the sources support.** Use tall
   narrow opening groups and small gable-field openings on supported faces,
   while keeping unobserved broad-side segments restrained and honest.

Items 1 and 2 must both survive two grounded ordinary-player views before the
Chapel can be reconsidered. Item 3 is the next believability lift, not a license
for wallpapering.

## Job Corps Dormitory 369 — `+0`

### Reference comparison

The authoritative packet supports:

1. a long warm off-white field contrasted with a muted blue-gray end/stair
   volume and a dark-green eave;
2. **five occupied tiers** with alternating broad multi-lite and narrow windows,
   many broad windows carrying green eyebrows; and
3. a grounded base program of broad glazing, blue-gray panels or doors, and
   base vents.

The exact-current receiver is still a `6 m` fallback mass. That is not a minor
scale caveat: it contradicts the five observed occupied tiers and makes the
most important structural cue physically impossible. A texture must not fake
those tiers.

The current whole-object image gives the target only `0.039` of frame height
(about 35 pixels); the oblique gives `0.038` (about 34 pixels), at LOS distances
of `152.181 m` and `156.419 m`. Meeting a technical `0.025` framing floor is not
the same as making facade cues perceptible. Neither frame exposes the blue-gray
stair/end volume, five-row opening rhythm, green eave/eyebrows, or ground band
as an identity-bearing composition. The warm field alone cannot count.

### Confusion and believability verdict

Against Advanced Culinary/Dorm cohort `w34313514`, Food Service 368
`w34313521`, Oasis `w291189918`, and other long Job Corps blocks, the candidate
is not top-1. It shares the same generic fallback-slab language and offers no
countable structural or facade-family discriminator.

Believability fails before fine detail is considered. A five-tier dormitory
presented as an almost one-storey strip has the wrong architectural scale. The
absence of a stair/end volume, eave, repeated occupied-tier depth, and grounded
base removes both human scale and facade hierarchy. The very small projected
height is an honest symptom of the massing error, not a camera problem to hide.

### Smallest truthful repair, ranked

1. **Correct the massing first.** Replace the local `6 m` fallback with a
   reversible hero override that contains five occupied tiers. Preserve the
   source footprint, disclose the floor-to-floor production inference, and
   keep render, collision, roof/traversal, and ownership congruent. Do not use
   texture rows to simulate height.
2. **Establish the large three-part hierarchy.** Model/material the warm long
   field, muted blue-gray end/stair volume, and thin dark-green eave as distinct
   architectural parts visible at ordinary distance.
3. **Install the real five-tier facade rhythm.** Use shallow but complete
   opening modules for the alternating broad/narrow windows and green eyebrows
   on the mapped public runs. Avoid flat facade-photo wallpaper and arbitrary
   repetition.
4. **Ground the building.** Add the supported broad glazing, blue-gray
   panels/doors, and base vents as a controlled base band after the tier and
   end-volume hierarchy works.
5. **Recapture after the massing fix.** Keep one honest full-entity view and add
   one closer ordinary WSW/SSE read where the five tiers and facade family are
   actually legible. A tighter view may verify cues; it cannot substitute for
   item 1.

Items 1 through 3 are the minimum top-1 package. Item 4 is the next
believability lift.

## Technical verification after the visual judgment

Only after fixing the visual verdicts, I reviewed the manifests and ran the
sealed checks:

- `sha256sum -c checksums.sha256`: **PASS** for every listed packet, run map,
  runtime input, evidence document, test, and all four PNGs.
- Focused headless evidence contract: **PASS** with the expected statement that
  all four native Metal views remain exact-current and technically valid while
  both recognition/believability verdicts and the Dormitory massing conflict
  were unresolved pending this review.
- Renderer/world pin: Godot 4.7.2, Forward+/Metal on Apple M2; `735` playable
  rows, `4` context rows, `938` meshes, `948` surfaces, `63,720` triangles,
  `466` bodies, and `466` shapes.
- Chapel center LOS first-hits exact receiver
  `building:w291189336:wall`, exact source `[w291189336]`, accepted run `9` in
  both views.
- Dormitory center LOS first-hits exact receiver
  `building:w291189926:wall`, exact source `[w291189926]`, protected run `12`
  in the whole view and accepted run `2` in the oblique.
- All views use the stock visible-player rig at `70°` FOV and `5.5 m` configured
  spring arm, remain physics-grounded and in bounds, frame the complete target,
  and contain no debug overlay, crop, detached camera, light change, or source
  photography.

Sealed image SHA-256 values:

| Original | SHA-256 |
| --- | --- |
| Chapel whole | `2edeaff94139639da514d049f42f94819881c7a421a4dd24f24b1b305ecd4833` |
| Chapel oblique | `8cff88807fa537c8360b6a314e322b84413e2af1561bf48134efd45211eb0733` |
| Dormitory whole | `4a8ccc548cb46827a0f9f827b8eeed8fa2e120446ebfb8b80f5e4a5b67249992` |
| Dormitory oblique | `c2f5ffcf91e1e2012aa2d22cd04d4a534c5f557049a4d45ff1bca577f8d423eb` |

This review changes no runtime, material, capture, catalog, registry, topology,
collision, navigation, or numerator artifact.

## Re-review bar

A future reviewer should be able to identify each target top-1 from the two
ordinary-player images without its address, map position, color label, or ID.
Each target needs at least two independently visible source-supported cues,
including one structural/facade-family cue, on a complete honest object. Chapel
needs the belfry/cap/cross and gable-window-entry composition. Dormitory needs
five-tier massing plus the stair/end/eave and five-row opening hierarchy. Until
then the exact recognition change remains **`+0`**.

# Building 3 recognition repair — arched hangar massing

Date: **2026-09-04**  
Target: frozen OSM way **`w34313540`** / generated objects
**`building:w34313540:wall`** and **`building:w34313540:roof`**  
Review state: **implemented; pending independent original-detail review**

## Correct identity and authority

The target is the Palace of Fine and Decorative Arts / Building 3, National
Register **`08000083`**. The authoritative source for identity and the historic
structural description is the [NPS NRIS record](https://npgallery.nps.gov/AssetDetail/NRIS/08000083)
and its Section 7 nomination narrative. That narrative supports a reinforced-
concrete hangar with an arched three-hinge steel-truss roof and four tapered
concrete corner pylons. The current ENE observation in the P1 packet supports
the broad curved crown, narrow high shoulders/pylons, one dominant hangar
opening, and a subordinate upper band as the recognition family.

The frozen OSM tag `ref:nrhp=08000081` is retained only as immutable source
provenance. It is incorrect for this building and is not used as an identity,
label, visual cue, or acceptance fact.

## Runtime repair contract

The generated X/Z footprint and every source boundary endpoint remain exact.
The runtime intercept occurs before generic mesh and collision construction for
both Building 3 records, so the old flat roof and wall collider cannot survive
as hidden duplicate geometry. Wall bottoms retain their exact terrain-following
source elevations. The source wall runs and source roof triangles are subdivided
in place, then both visible geometry and congruent collision receive one shared
vertical profile:

- a broad sinusoidal hangar crown across the short axis;
- localized raised corner shoulders at both ends, producing four pylon-like
  silhouette anchors;
- the existing ENE facade field remapped exactly to the resulting wall top;
- the accepted single hangar opening retained; and
- the shallow upper band given a stepped projection plus a narrow neutral
  occlusion groove so it remains legible in grayscale under ordinary lighting.
  The groove is a reversible depth-read production inference, not a claim about
  observed paint color.

The wall remains the only spray receiver. The arched roof is a solid landing
surface but not a spray receiver. Mesh and collision are built from identical
indexed faces.

## Production-inference boundary

Historical dimensions and the structural/facade family are reference facts.
The game-space eave (`21.278 m`), crown (`27.862 m`), pylon top (`24.179 m`),
pylon influence fractions, and subdivision density are **reversible production
inference**, not a survey or as-built claim. They are intentionally isolated in
`game/resources/facades/building_3_hero_massing.json` for review and tuning.

No interior, truss interior, construction assembly, inaccessible roof detail,
current long-side opening schedule, or exact pylon section is claimed. No
source photograph is shipped. The model is exterior-only and must be judged
from ordinary grounded stock-player views by a reviewer who did not build it.

## 2026-10-06 bounded quality-upgrade preparation

No Building 3 art changed and its existing recognition credit is preserved. The
current exact wall/roof source remains `w34313540` in `x_1__z_1`, base 3.478 m;
its native wall is world-solid and a building-wall receiver. Actual November 2025
ENE pixels were recovered from panorama `KpAYOuZlkIsuNO4uO3rV4A`, resolved at
37.8201975,-122.364079, heading 230: private originals
`/workspaces/landmark-progress-20261006/building3-references/ene-nov2025.png`
and `ene-nov2025-zoom.png` show the curved crown, corner pylons, pale closed
front panels with seams and a relatively small central blue portal.
[Exact panorama](https://www.google.com/maps/@37.8201975,-122.364079,3a,30y,230h,92t/data=!3m7!1e1!3m5!1sKpAYOuZlkIsuNO4uO3rV4A!2e0!6shttps:%2F%2Fstreetviewpixels-pa.googleapis.com%2Fv1%2Fthumbnail!7i16384!8i8192).
ROOT inspected these as sufficient bounded ENE preparation; the zoom's right
edge is cropped, dimensions are not measured, and no whole-building or hidden-side
reference sufficiency is claimed. `ene-nov2025-detail.png` is a near-duplicate
failed UI zoom; `sse-attempt.png` snapped to a June 2015 visitor panorama well away
from the requested point and is excluded for target/pose ambiguity. Recovery
stopped after that bounded complementary attempt. Fences are only foreground
occlusion evidence, not a gameplay-access proposal. No reference photo enters
Git or the game.

One fresh shared `building_shots.gd -- --source w34313540 --island` run passed,
with four ordinary views, two context views and five island views in
`/workspaces/landmark-progress-20261006/building3-baseline/`; terminal log
`building3-baseline.log` records AMD Radeon 780M Graphics (RADV PHOENIX) / Wayland
and 14 texture-RID leak warnings. Browser and engine completed and were released.
This is the current uncommitted worktree, including the held Building 2 study,
not a clean-main island baseline. The existing September 4 accepted PNG is a
real local image, not an LFS pointer, but is only historical comparison. The fresh
ENE game view retains a broad dark rectangular field, shallow band and simple
pylons; those differences from the dated reference merit independent visual
review before any new study. No B3 implementation, acceptance, commit or export
is authorized by this preparation.

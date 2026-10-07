# Building 3 recognition repair — arched hangar massing

Date: **2026-09-04**  
Target: frozen OSM way **`w34313540`** / generated objects
**`building:w34313540:wall`** and **`building:w34313540:roof`**  
Review state: **current all-side source003 CODE/fit-spray PASS and capture complete; whole visual and full suite pending**

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

## 2026-10-07 ENE whole-building quality study (building3_claude, first coherent capture)

Reuse: kept the existing B3 runtime massing (arched crown, frozen footprint, exact
source bottoms, single wall receiver) and its facade module, recomposing only the
observed ENE run 27–35; shared Poly Haven `plaster_grey_04` normal/roughness PBR
textures are reused read-only as world-triplanar B3 tints. No shared family fits
this hangar landmark, so no new base or family refactor.

Observed (Nov 2025 ENE pixels): broad closed pale lower front under the crown,
smaller central blue portal with a dark opening under a raised pale bay, channelled
corner pylons with stepped caps, faint crown panel joints. Production inference
(not surveyed): lower front top 13.9 m with a 14.45 m cornice; 17 m blue bay with
1.2 m jambs; 7.4 m opening to 10.0 m; pylon shafts −0.35..7.4 m on each end with
two 0.45 m channels, a roof-corner head and three-step cap to ~26.9 m; seven crown
joints, one horizontal joint at 18.3 m and an arch fascia following the exact
runtime top samples. The old 44 m dark field, upper band/groove and shallow pylon
strips were removed. Other sides are unchanged.

Local land preflight: ENE source wall bottoms 2.806–3.478 m; land 2.83–4.16 m with
the visible apron area +0.02 m above land; every grounded box starts at the lowest
exact bottom −0.10 m (2.706 m), below land/area along the face. Pylon heads sit
inside the footprint with bases below the runtime roof surface. Projecting pieces
(lower front, cornices, bay, jambs, pylons, heads, caps) add BoxShape3D children to
the one canonical wall receiver body (same layers/group/metas); blue cladding,
trim, door slats, seams and fascia stay ≤0.30 m and render-only.

Engines: fresh baseline `/workspaces/landmark-progress-20261007/building3/baseline/`
and first study `.../first-study/` (both EXIT 0, AMD Radeon 780M Graphics
(RADV PHOENIX) / Wayland, same pre-existing "ss is null" and texture-RID leak
warnings). Fit/spray and stock walk-up not yet run; independent Sol High visual
review pending. No acceptance claimed; existing B3 credit untouched.

### 2026-10-07 correction-001 (building3_claude)

One coalesced correction answering the code HOLD and first-pass visual HOLD.
Basis: `_append_oriented_quad` now derives the actual plane normal from the quad
edges (oriented to the requested side), the tangent as the first edge made
orthogonal to it, and the tangent sign from the second edge; winding and profile
positions are unchanged. Junctions: the ENE runs are collinear within 1 mm, so
plane drift was ruled out. The dashed/dotted lines coincided with thin
side/under faces (3.8 cm crown joint boxes, a 0.22 m drip step under the cornice,
0.07–0.24 m header/cap-bar steps, 5–8 cm pylon-ledge lips) that project sub-pixel
at gameplay range. This is an inference that is consistent with the before/after
pixels, not a measured cause. Joints are now flush, front-facing, non-shadow-casting
0.16 m strips; the cornice is one 0.88 m block; header, cap bar and jambs share one
0.95 m face; the pylon ledge is flush with the lower shaft; the fascia soffit is
chamfered back to the wall. Silhouette, proportions, pale infill and the blue portal
are unchanged. Capture `/workspaces/landmark-progress-20261007/building3/correction-001/`
(EXIT 0, AMD Radeon 780M Graphics (RADV PHOENIX) / Wayland). Fit/spray is pending;
independent review is pending.

### 2026-10-07 mechanics and shared verification repair

The first final-fit attempt (`final-fit-run4.log`, handle76728, exit0) printed
PASS but is retained as **insufficient/HOLD**: headless MultiMesh readback
contaminated the visible bounds with the origin (529.3 × 28.4 × 555.1 m), giving
only three remote approaches and sparse roof/wall samples. It did not establish
Building 3 fit. The same source, shared driver and spray pose with rendering
(`final-fit-rendered-run5.log`, handle25899, exit0) produced bounds
164.2 × 25.2 × 146.7 m, no bad roof/wall/ground samples, and all four local
stock approaches. Actual startup reported Vulkan Forward+ on AMD Radeon 780M
Graphics (RADV PHOENIX), with the Wayland startup path.

The new ENE lower panel at facade u20, depth0.55 was exercised by actual stock
spray: `building:w34313540:wall` at (520.0223, 5.214746, 470.9224). Its player
settled on actual x_2__z_1 land at (521.7816, 3.114929, 470.0031), not a flat
fixture or the building record's storage tile. All four approaches and spray
recorded input-released, grounded, supported, stopped REST with the stock
controller still active before SAFE_FINAL. No recovery or opening/AABB note
was reported. Actual engine processes were absent after each terminal result.

Shared verification now runs the island geometry test with rendering while
unrelated tests stay headless; the shared visible-geometry harness rejects
headless execution. Missing source-wall ray hits return infinity, not zero
arrival distance; all required approaches must pass. A default-true startup
mouse-capture setting remains unchanged for ordinary play; only automation sets
it false before loading, preventing the private-compositor pointer errors.
The complete-suite ERROR matcher is unchanged. The focused repaired check
(`shared-fit-repair-check.log`, handle42335, exit0) passed roof0/38,
wall0/16, ground0/16, four local canonical wall contacts and actual spray,
with all five active REST→SAFE_FINAL sequences and no ERROR matches. Seven
texture-RID warnings remain of unknown cause.

Independent `building3_code` subsequently caught the unsafe-state reset between
buildings. The minimal follow-up latches unsafe state for the driver's lifetime,
refuses subsequent checks and stops the island loop with remaining buildings
explicitly untested. Missing source geometry/collision and invalid route setup
also stop dependent work. Independent shared CODE PASS covers that final
follow-up; unchanged successful mechanics were not replayed for bookkeeping.
Complete `tools/test.sh` remains pending. Art-loop usage is5/6; the focused
shared-harness check was separately authorized. No art changed during this repair.

### 2026-10-07 final independent visual result

The persistent delegated reviewer `final_b3_visual` (GPT-6.1 Sol, high), separate
from the author, inspected both November2025 references and all fourteen baseline
and fourteen correction001 originals, including all five matched island pairs.
Its explicit whole-building game-art, finish, context and island verdict is PASS.
The broad pale frontage, curved crown, smaller recessed blue portal and channelled
pylons substantively improve recognition. Residual header/panel segmentation
remains visible but was judged minor joint roughness rather than a substantial
crack-like assembly defect; this is not a flawless-finish or measured-cause claim.
Observed reference coverage remains ENE; opposite sides and dimensions remain
production inference. Stills do not establish motion or mechanical acceptance.

Private evidence and verdict: `/workspaces/landmark-progress-20261007/building3/`,
`final-visual-verdict.txt`. Parent handle18598 ended exit0, with actual child
`/root/final_b3_visual` on Sol High and no repository writes by the reviewer.
This records its independent verdict, not new study acceptance or publication:
ROOT closure and the complete suite are pending. Existing Building 3 credit,
all49 accepted units and the213-unit catalog remain unchanged.

ROOT accepted the correction001 study after the independent art CODE, final
whole-building visual and rendered stock fit/spray/shared CODE findings above.
Catalog review records `building3-correction001-code-20261007` and
`building3-correction001-whole-building-visual-20261007` supplement the existing
September4 acceptance; Building3 remains accepted, with all49/213 credits and
unclaimed as-built fidelity unchanged. Final visual child UUID is
`01a11445-9207-7832-8062-8e312318ceb0`, GPT-6.1 Sol High. Complete `tools/test.sh`
is now assigned against this source/catalog; its outcome is pending. Required
reviewer-owned RETRO is also pending; no commit or push is authorized yet.

### Complete-suite result and bounded route-setup correction

Complete `tools/test.sh` handle24507 ended exit1; retained `full-suite.log`
reports w34313548 (Building600) east setup at (336.4, −330.4) on top of a
building. Required approaches remained incomplete and the sticky unsafe stop
left45 units explicitly untested. Other stages, including Node validation and
determinism, completed. This is not complete-island PASS; no commit/push followed.
The suite output filter does not retain its renderer/display startup lines, so
no actual adapter value is asserted for that invocation. Engine/PID release was
confirmed after terminal completion.

Read-only source diagnosis places that start on neighboring w291193744's roof
(7.108 m), above actual land4.064 m; it is not Building600's wall. The generic
5 m offset from the target's rotated/concave AABB selected the neighbor. The
bounded shared-driver change preflights5 m then2 m on the same cardinal line,
using native walkable support, the actual stock capsule and clear descent before
one real stock approach. It does not skip a side or change target geometry.

Independent review rejected treating the final5 cm below clearance as proven
support, then caught a hardcoded0.7 floor-normal cutoff above the stock48-degree
threshold. The corrected pre-input check examines all actual settled native
floor contacts using player up_direction and floor_max_angle; unknown or
nonwalkable support latches HOLD and performs active released rest before safe
disable. Source is frozen for the threshold recheck; one focused rendered
Building600 fit is pending CODE PASS. Complete-suite retry remains unassigned.
The final independent visual reviewer's own RETRO is now saved and checked.

Final threshold-only independent CODE PASS and focused rendered Building600 PASS
are now recorded. Session79570 exited0: bounds72.2 x6.1 x105.0 m; roof0/17,
wall0/18 and ground0/18 bad; four of four required approaches used actual native
ground support and reached native target wall/detail contact. East rejected the
neighbor roof at5 m and selected2 m on the same cardinal line. Every approach
proved active released supported rest before SAFE_FINAL; no recovery was needed.
The north/east inside-AABB notes do not by themselves prove an opening. Seven
Texture RID warnings remain of unknown cause. Wrapper454635, Godot and Weston
were absent after terminal. The complete-suite retry is separately authorized;
its outcome is pending.

Complete-suite retry1 (session93447) exited1. Building600 passed its focused
check, but island routes exposed additional failures: w96215652 south/west and
w96215653 east stopped short without target contact; w96215658 west had no safe
5 m or2 m start because both candidates hit neighbor w96215688. Sticky unsafe
stopped the island run with33 remaining buildings explicitly untested. Other
stages, including world validation and determinism, completed. No rerun or
automatic repair followed. Suite455051 and all Godot/Weston processes were absent
after terminal; ENGINE released. Integration remains HOLD on the complete suite.

Architectural approach repair passed independent source review, but focused
w96215652 call96095 failed compilation before fit: get_collider_shape returned
Object where the native shape-index qualification needs int. Engine stopped
(exit143); Godot/Weston/wrapper absent. No movement or samples were accepted;
w96215653/58 were not run. One-line get_collider_shape_index correction is frozen
for narrow independent review. Complete-suite HOLD remains.

API-corrected1220 run98523 retained roof0/6, wall0/15 and ground0/15 bad;
north reached native wall with active REST and SAFE_FINAL. South found no
qualified wall crossing before placement;53/58 remain untested. Static source
reconstruction intersects a scheduled door opening, whose closed door is a
separate support shape; exact native first-hit/normal was not logged. Shutdown
wait cause remains unknown; authorized stop exited143 and all engine PIDs were
absent. Source remains frozen, complete-suite HOLD unchanged.

Lane-corrected1220 focused run30744 exited1 normally. Roof0/6, wall0/15 and
ground0/15 bad; north and the newly selected south quarter-span lane reached
qualified native walls with active REST before SAFE_FINAL. West central5 m
setup then contacted FamilyContact_ground during settling, failing the strict
native-ground support check before forward input. Failure cleanup REST and
SAFE_FINAL passed.2/4 sides passed,3 attempted; east and sources53/58 remain
untested. All engine processes were absent after terminal. Complete-suite HOLD
remains; no source edit or automatic retry followed.

Native setup correction now uses PhysicsServer3D.body_test_motion on the actual
stock player RID from the same identity/+2 m drop pose, preserving enabled
shapes, local offsets, mask and exceptions. The safe-margin query reaches first
support then checks near-rest recovery contacts with stock floor angle/up. Every
contact must satisfy the existing walkable-ground predicate; unknown, empty or
saturated results reject the candidate.32 is the API contact-result limit, not
a geometry expectation. Actual settled support/REST/safe-final gates remain.
Source is frozen for independent review and pinned compile; no runtime claim.

Official API checked2026-10-07:
- https://docs.godotengine.org/en/stable/classes/class_physicsserver3d.html#class-physicsserver3d-method-body-test-motion
- https://docs.godotengine.org/en/stable/classes/class_physicstestmotionparameters3d.html
- https://docs.godotengine.org/en/stable/classes/class_physicstestmotionresult3d.html

Native-descent focused loop now PASS: w96215652/session60209 (roof0/6,
wall0/15, ground0/15); w96215653/session93308 (0/30,0/16,0/16);
w96215658/session54939 (0/12,0/18,0/18). Each completed four real stock
approaches with qualified native wall arrival, actual ground setup, no recovery
and active REST before SAFE_FINAL, then exited0.1227 east used the reviewed
wall-proximity ray criterion, not direct wall slide contact, and rested safely
on FamilyContact_ground. Other direct contacts are retained in the logs.
Actual startup: Vulkan1.4.335 Forward+, AMD Radeon780M Graphics RADV PHOENIX.
No ERROR; seven Texture RID warnings per run remain cause-unknown. All owned
engine processes were absent before each next invocation and after completion.
The failed prior logs remain unchanged; complete-suite retry is still pending
ROOT assignment. No source edits occurred during this loop.

Owner steering after viewing correction001: geometry is approved to remain
frozen, but current materials/textures are insufficient; a PBR/detail-material
pass is next. Earlier independent visual PASS remains historical scoped-study
evidence and does not close the owner's current finish request. No integration
is authorized from the pre-material suite alone.

Full-suite retry2/session9499 exited1. Building600 w34313548 south stopped short
at(284.3,-337.4) without contact; w96215646 west rejected all six candidates on
its own FamilyContact_support. Sticky unsafe stopped with38 buildings untested.
Other stages, including world validation/determinism, completed. Original log
full-suite-retry2.log remains retained outside Git. All suite/Godot/Weston PIDs
were absent after terminal; no restart or kill occurred. Shared code/source
remains frozen pending a separate repair assignment; complete suite is HOLD.

Current finish and verification status,2026-10-07: material001 has independent
EARLY visual HOLD/scoped material CODE PASS after30 original comparisons.
Warmer paint and faint mottling were insufficient at ordinary gameplay scale;
the recommendation was restrained patchy ENE cornice/pylon-cap wear with short
runoff and clean panel centres. Material002's14 originals are saved and its
read-only independent review is pending. Capture77937 printed driver PASS but
hung during shutdown; authorized owned-process termination yielded exit143,
followed by confirmed Godot/Weston/wrapper absence. Capture success is separate
from abnormal termination;14 Texture RID warnings remain unexplained. Geometry
freeze is author incremental evidence, not proved by the aggregate Git diff.
Fresh spray/fit and final complete-suite gates remain open; no integration.

Shared verification repair: the distance/stock-speed budget restored Building600's
south approach (actual67.887 m,18.972 s allowance), and all four approaches passed
with native walls and active REST/safe final. Source w96215646's farther native-
ground start fixed setup only: its west actual walk remained blocked by own
support,3/4 approaches overall. Later corridor candidates failed before west
placement, leaving east untested. Actual query points at canopy undersideY5.575
supersede an exact-post interpretation; intermediate trajectory remains unknown.
The latest local capsule/snap-bounded corridor repair has independent Sol High
CODE PASS, with compile/runtime still pending. Earlier focused proofs remain
historical evidence for their source state. Full-suite retry2 remains HOLD with
its38 untested units; no retry or changed acceptance claim has been made.

Source46 shared-route verification update: native-completion run95634 exited0
with all four actual approaches and active REST before safe disable. West
selected lane−0.25/margin10, arrived by qualified native wall proximity, and
rested on FamilyContact_ground; its support contact is not a direct wall-touch
claim. N/S/E contacted native walls. Roof0/46 and wall0/18 samples were bad;
the existing ground-fit result remained within the maintained gate. All engine
PIDs were absent at release. Diagnostic52079 remains diagnostic-only HOLD,
showing native zero remainder/full safe fraction despite submillimeter recovery
offsets; earlier failed attempts remain retained. This scoped source46 PASS
does not close Building3 material002 review, fresh fit/spray or full-suite gates.

Material002 closure: independent final_b3_visual (gpt-6.1-sol/high, existing
child01a11445-9207-7832-8062-8e312318ceb0) inspected33 originals and returned
material VISUAL HOLD/scoped CODE PASS. Short patchy runoff is restrained, but
broad pale fields remain nearly flat. Its single correction is soft low-contrast
several-metre coating variation across ENE pale fields, preserving clean centres,
current runoff and geometry. No visible context/island regression was found.

After the native-margin shared-driver repair passed independent CODE and compile,
material002 fit/spray74233 exited0: roof0/38, wall0/16, ground0/16 bad; four actual
canonical-wall arrivals and five active REST/safe-final proofs. Stock spray placed
one real decal on building:w34313540:wall at(520.0223,5.214739,470.9224), using
the retained ENE lower-panel plan and actual local land. This proves native
receiver/decal integrity, not projected-pixel readability: the driver saved no
spray image. All engine processes were absent at release. Seven Texture RID
warnings have unknown cause. Material003 is assigned from the bounded critique;
material acceptance and the complete suite remain open, with no integration.

Material003 current mechanical proof: rendered30447 exited0 after all four
canonical-wall arrivals and five active REST/safe-final checks, with roof0/38,
wall0/16 and ground0/16 bad samples. Actual stock decal placement retained the
source-matched ENE receiver and was saved before cleanup to private
`/workspaces/landmark-progress-20261007/building3/material-003/spray.png`.
Root has viewed these pixels; independent material003/visible-spray review
remains pending in the existing Sol High graph. All engine PIDs were absent
at release. The complete suite is assigned next, not yet passed; no integration
claim is made, and warning causes remain unknown.

Complete-suite material003 run39006 exited1: w96215659 west had no safe
same-side candidate, and sticky unsafe stopped the island check with32 remaining
buildings untested. Actual negative-quarter/eighth corridor contacts hit own
FamilyContact_ground nearY2.20 with downward normals; other starts hit support
or lacked a qualified wall crossing. Validation/determinism completed. All
engine processes were absent at release. Individual island exit/timeout status
is not printed, so the observed shutdown wait is not labeled a normal exit.
Full-suite HOLD remains; no integration or automatic retry followed.

Material003 independent verdict,2026-10-07: existing final_b3_visual child
01a11445-9207-7832-8062-8e312318ceb0, gpt-6.1-sol/high, inspected34 original
images including the fresh spray viewport and complete material setup/shader.
Recognition/fidelity, finish, context/island, scoped material CODE and captured
spray readability all PASS. Broad coating variation materially improves ordinary
gameplay finish while restrained runoff and clean centres remain coherent; no
further material correction was requested. Fidelity covers observed dated ENE
references; opposite sides remain production inference, not an as-built claim.
The catalog now records the material003 code and independent recognition
verdicts without changing prior accepted credit or unit identities.

Whole integration remains open: full-suite39006 HOLD at source59 left32 buildings
untested. Source59's separately assigned repair is now present in its data diff:
14 unique inner ParkingSurface rim vertices change onlyY to paired outer heights,
with XZ preserved; this is implementation status, not runtime or visual acceptance.
No new complete-suite PASS or merge is claimed. The visual reviewer's own002/003
RETRO append remains reserved to that child.

Post-source59 complete suite89402 exited1 at w96215666 west, with30 remaining
buildings untested; all engine processes were absent at release. Candidate
rejections occurred before descent/movement:5 m starts hit own support,2/10 m
starts hit own FamilyContact_ground. The shared open-ground predicate excludes
that producer's ground body because its parent lacks nonbuilding feature_kind.
This is a source-backed setup-policy issue; candidate slope/clearance remains
unproved until a reviewed qualification repair and actual verification.
Source59 CODE/fit PASS and material003 visual/fit/spray PASS remain scoped; the
full suite and integration remain HOLD. No automatic retry was launched.

Source66 focused qualification proof11384 exited0: roof0/38, wall0/18 and
ground0/18 bad; four actual stock approaches and four active REST/safe-final
checks. West selected the2 m native FamilyContact_ground start after rejecting
the5 m canopy, then arrived by qualified native wall proximity, not direct wall
contact. Source-bound live producer semantics now supplement terrain ancestry
in the shared ground predicate; unknown/support/roof roles remain ineligible.
All engine PIDs were absent at release. Independent CODE93938 is pending and
no new full-suite run is claimed; source59 visual review31271 remains separate.

Independent source66 CODE93938 passed, with its own reviewer note written.
Complete suite17352 subsequently exited1: source98 (w96215698) east had no
safe selected approach and17 remaining buildings were untested. Validation and
determinism stages ran; all engine processes were absent at release. The center
10 m corridor contact at (-305.6457,4.15283,-656.2593) matches front-2's second
privacy-screen slat under the actual producer transform; it is not evidence of
a carport-post or terrain defect. Other offset lanes intersect scheduled
entry/window spans by source inference, with exact native first hits unlogged.
No source/harness repair or retry was performed in this diagnosis. B3 scoped
material/fit/spray verdicts remain PASS; whole-suite/integration remains HOLD,
and source59's independent site visual comparison remains pending.

Source59 independent SITE VISUAL PASS covered all22 matched before/after
originals and its frozen JSON diff; this excludes millimetre/collision continuity
claims. The reviewer wrote its own note and released the writer.
Source98 native-wall fallback CODE39679 and focused39168 passed. Four actual
approaches and active REST/safe-final were verified; the east-origin route
arrived at a native corner/end wall, not the broad east facade.
The separately reviewed diagnostic batch5686 queried all68 sides of17 subsequent
units without player movement or state changes, then exited1 as DIAGNOSTIC HOLD.
Only w1222720021 lacked candidates (all four sides); its legitimate Building1
rooftop support needs a scoped test-context repair, not roof removal or source
credit changes. This found one remaining setup blocker before another suite;
no workflow timing saving or acceptance credit is claimed. Rooftop verification
is a separate assigned round. Whole-suite and integration remain open.

The separately keyed Building1 rooftop tower now has a source/config-bound
parent-roof support context, without geometry, catalog or credit changes.
Review43079 held the first patch because active walking subcontacts omitted
that context; corrected49577 CODE PASS and focused77831 exit0 close this seam.
Four LOCAL rooftop approaches and parent-roof active REST/safe-final passed;
N/W used qualified tower-wall proximity and S/E direct wall contact. Roof4/44
bad samples remain within the unchanged inherited tolerance; walls/ground0/16.
This proves neither ground-to-roof walking nor a complete-suite PASS. All engine
processes were absent at release; the next full suite remains separately gated.

Complete suite48032 exited0: ALL TESTS PASS, including all49 scored buildings,
stock road traversal, junk, validation and determinism. The diagnostic experiment
found one setup-blocked rooftop unit beforehand; this suite discovered no new
setup blockers after that repair. No timing benefit is asserted.
Final integrated CODE46418 held only the separate single-building diagnostic
parser; exact flag/value validation then passed53885. Three bounded headless
probes verified two malformed-flag rejections before load and a valid existing
spray plan reaching the renderer guard, without movement. The parser-only edit
postdates48032; ROOT's evidence-reuse/integration decision remains pending, and
no further full-suite invocation or commit is claimed. All processes released.

Accepted for integration, 2026-10-07: ROOT accepted Building3 geometry and
material003 recognition/finish/context/island, scoped CODE and visible-spray
PASS, source59 seam CODE/fit/site-visual PASS, and final shared-code/parser PASS.
Suite48032 ALL49 PASS is explicitly reused for unchanged game/island/BuildingFit/
material/data; the subsequent standalone parser is covered separately by53885
and three headless probes. Existing49/213 credit is unchanged. Observed ENE
references do not establish unseen-side as-built fidelity; rooftop routes remain
local support proof with4/44 roof-sample limitations, and rendering-warning
causes remain unknown. Historical HOLDs above remain part of the record.

## 2026-10-07 owner west-side finding — whole-quality reopened

The owner supplied `material-003/closeup-west.png` from the private building3 progress folder. Direct inspection shows complete arched massing but a largely blank west facade and conspicuous repeating grey plaster. The custom facade/material work above affected observed ENE runs27–35; other walls retain generic `building_wall` material through `world_chunk_builder.gd` and the massing producer. No inspected reference establishes that the real west architecture is blank. The prior material003 independent receipt limits fidelity to ENE and treats opposite sides as inference; that scoped PASS does not resolve current whole-building quality. Historical verdicts, mechanical evidence and catalog recognition credit are retained, but whole-quality completion is reopened.

The all-side assignment now uses directly inspected Nov2025 ENE references and historical HABS2003 NW/SW and SE/NE originals. Historical motifs do not prove contemporary color, opening survival or occluded lower attachments; separate low annexes retain their own identities. The current status below supersedes the former research-only next step without changing historical recognition credit.

## Current all-side completion status — 2026-10-07

**Source003 party-wall correction CODE PASS; current whole quality remains open.** The retained `building3/all-sides-003/code-review.txt` records initial assembly PASS, a superseding neighbor-volume HOLD, then focused correction PASS. New ground-reaching run26 relief had occupied separate w1222514686 below itsY9.2 roof; the west legacy lower front and entering pylon pieces also crossed w1222514685. Existing high-relief XZ bounds did not authorize those lower volumes.

The corrected paired closed visible/native boxes clip run26 bearing toY9.2–13. On the west host, station62.617209592m (source run6 start with2mm allowance) divides the open lower front from the shared portion, which starts atY9.358. Previously entering far-pylon core/strips are clipped at that same roof height; canonical B3 source walls remain behind the removed decorative volume. Separate neighbor geometry/IDs, modern ENE/PBR, original source XZ/bottoms and sampled wall-top interpolation are preserved. Long-chain bearing bottoms remain3.058–3.378m, with southwest clamp2.70m. The disclosed roughly0.0000014m² chain10–11 corner sliver remains below source quantization scale; no exact zero native overlap or executed contact-clearance claim follows the source arithmetic.

Whole002 VISUAL HOLD for assembly/seam/contrast quality is preserved. Current003 capture8908 exited0/5957bf and supplied14 directly inspected originals: four sides, three ENE details, two contexts and five island views. Source/engine release and global absence7f746e were recorded; live owned PID identities were missed because capture finished before observation and are not invented. `/workspaces/landmark-progress-20261007/building3/all-sides-003/capture-result.txt` records calmer joins/continuous bearing, but archive opaque-head/pier proportions, inferred lower fields, partial north occlusion and modern ENE seam marks still need independent judgment. B1/B2 changes in context are not B3 gains. Current whole visual remains pending, not author acceptance.

Current003 maintained fit/spray has scoped PASS (parent65485; direct93313 terminal0/9a7617), in `all-sides-003/fit-spray/mechanical-result.txt`: clean load, sampled roof/wall/base checks, four own-wall stock approaches, five active supported/input-released REST then safe finals, and inspected readable native Decal on newly projected lower run18. Owned wrapper621210/Godot621238/Weston621215 and helpers/tee were absent; explicit early SOURCE/ENGINE release preceded private pixel/report work. One selected receiver and sampled approaches do not prove continuous party-wall clearance, every seam or full suite. Historical001 setup HOLD remains; no exact zero native overlap claim supersedes the disclosed sliver.

Shared harness validation is separate: native Logger/backstop, intended producer assertion and direct loader-body assertion have scoped PASS; actual body result was Dictionary and nil-defense remains unexecuted. First missing-raw-context negative HOLD is retained. Clean B2 CHECK3 direct5006 terminal0 is separate scoped proof, not global acceptance. Current B3 all-side reference/context/island verdict and fresh full suite remain open. Private evidence stays under `/workspaces/landmark-progress-20261007/`; no recognition-credit, catalog or integration change.

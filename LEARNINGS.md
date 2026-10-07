# Project learnings

Keep this a short, living guide to mistakes worth preventing. Update an applicable lesson when new evidence changes it; preserve uncertainty and useful gains. Routine execution history belongs in `discovery/RETRO_LOG.md`.

Retain the owner-authorized routing in [AGENTS.md](AGENTS.md#bounded-subagent-execution): never use `ultra` for subagents; explicitly select effort. The current Mersea study uses the task-specific Astra Low modeling and Sol High review override in AGENTS. The general default since 2026-10-05 is modeling on Claude Opus 5.5 (the owner judged its Building 600 the most faithful of three), with textures from Codex via `tools/generate-texture`; see AGENTS.md for the current roles. The Astra/Sol notes below are historical. This small sample does not establish a universal quality, cost or speed ranking; lower Sol effort is untested.

## Do not promote one facade's finish to whole-building quality

**Observed:** The owner identified B3 material-003/closeup-west.png: a complete but largely blank arched wall with conspicuous repeating grey plaster. The task changed only observed ENE runs27–35 and left other sides unchanged; the independent material003 PASS limited fidelity to ENE and called opposites inference. Generic wall material remained on the west. These records do not establish reference-supported blank western architecture.

**Cause and prevention:** A scoped facade/finish improvement was promoted to whole quality without resolving the other visible sides. Seek Street View, Maps photographs and web evidence for each exterior side before inference; record useful references or actual search/access gaps in ordinary notes. Review all actual gameplay sides and judge inferred surfaces too. A scoped PASS or protected art boundary cannot exempt visibly unfinished sides; reopen whole-quality work through bounded scope while preserving source/gameplay invariants and historical credit.

## Judge the whole visible result after a fix

**Observed:** In 1308 fidelity002, ordinary views 06/07 improved roof visibility and lawn coverage, yet the main roof still showed rounded, uneven humps and a heavy pale rim. Junction views 03/04 exposed near-black canopy tops and heavy edges. The dated March 2025 reference showed coherent planar roof surfaces, straight ridge/eave segments and readable gray roofing. The initial review closed the previous two gaps too narrowly; the owner caught the unresolved overall form. A focused sibling check of 1303 fidelity004 views 03/06 found a related uneven crest despite real roof-visibility and apron gains.

**Cause and prevention:** The review treated improvement on the last defect checklist as sufficient quality. That is a review failure; pixels alone do not establish the underlying mesh algorithm's cause. After every visual fix, compare the full visible silhouette, roof planes/ridge/eaves, proportions, material readability and junctions with the actual dated reference in ordinary gameplay. Look for new and remaining defects beyond the previous issue. Visibility measurements diagnose readability; they must not drive exaggerated height, bulk or architecture merely to increase screen coverage.

**Next render:** Use the existing ordinary view and a useful existing near view beside the reference. Check that planes read as planes, ridge/eave transitions are intentional, and roof surfaces and edging remain legible. State what improved and what still fails, respecting different cameras, target identity and unknown/protected faces. Preserve successful lower openings, pale gables, paving and lawn. Scoped finish, source, mechanics or package PASS does not close overall fidelity; do not replace this judgment with an analytic projection, larger pose matrix or new test suite.

YMCA’s 43 isolated dark pixels matched the projected side of a valid 14cm-deep pilaster only 0.234–0.236 pixels wide; the source wall was more than 1.16m behind those hits. Localize persistent marks against actual native faces before removing valid closure geometry. Keep this subpixel face shading separate from shadow-dependent stippling: the later combined sampling candidate improved edges but left hatching. Stored AA configuration is not an observed viewport getter, and a completed rendering API request is not GPU-state readback. See the completed mark-localization and diagnostic entries in [RETRO](discovery/RETRO_LOG.md).

## Make visual critique actionable

In the first two-case blind taste comparison, the owner preferred Reviewer X (Astra Medium) over Reviewer Y (Astra Light/low) in both cases: Case A because it gave instructions for improvement, Case B because “nearly indistinguishable” was the most useful feedback. This is limited evidence about those critiques, not proof that all art tasks need Medium. Lead with a direct pixel-grounded judgment of meaningful visible change and one concrete highest-value next change explaining how to improve. Plainly call an imperceptible change “nearly indistinguishable” when the shown pixels support that judgment. Feature inventories and caveats should not displace actionable direction; retain honest uncertainty without implying unsupported confidence.

In the separate one-building creation study, the owner found both options good, slightly preferred Option 2 (Astra Light/variant-y) aesthetically and found its shrubs more natural; Option 1 was Astra Medium/variant-x. This contrasts with Medium's two critique preferences and supports task-dependent evidence only: no universal routing, speed or fidelity conclusion, and no verdict on self-review benefit because the owner did not specify first pass versus final. The independent source check found slatted enclosure motifs in the references, but Option 2's regular alternating placement and dimensions were inferred; some panels visibly cross direct door approaches, with an open side remaining. Check reference-supported placement and a clear door approach, not motif presence alone; visible overlap does not establish impassability.

In the subsequent Astra/Sol blind comparison, the owner called Case A a tie: both were overly verbose, though Astra Medium was better structured. Sol High won the replacement material-study critique for less unnecessary prose. Astra Low won the reference-inspired modeling comparison “by a wide margin”; Sol's tree still looked broken after its one visual revision. Keep owner-facing critique to a concise verdict, pixel-grounded reason and one next fix. Representative references and matched first/final images made the comparison useful; material-only panels still cannot establish installed building fidelity. Judge the whole final silhouette, including vegetation, rather than assuming a self-revision resolved it.

The owner explicitly retained existing routing: Astra Low modeling and Astra Medium judging. This small sample separates taste, execution reliability and elapsed workflow: Sol needed two mechanical repairs (19 seconds of recorded repair work), Astra none; all final renders were clean. Six render attempts totaled about 17 seconds, while end-to-end times included substantial other work, coordination, serialized waiting and human review. Do not assign unmeasured time to inference or infer general model quality, speed ratios or cost. Preserve separate source, mechanical, visual and release gates. See the benchmark outcome and provenance in RETRO (RETRO_LOG, 2026-09-23).

In the 2026-10-01 full-set vote, GPT-6.1 Sol High won both critiques: the roof defect outweighed the sidewalk issue, and precise direction beat vague feedback. Housing was a tie, with forced preference for Astra Low; Mersea favored Astra Low for artwork approximation and layout, while neither was fully correct. This sample favors Sol critique and Astra modeling without changing routing or promoting production work. Prioritize substantive architecture over ancillary detail; inspect first-pass and final results separately (the housing eaves criticism was explicitly pre-fix). Treat owner examples as evidence, not an exhaustive motif checklist.

## Inspect the early coherent render before extended proof work

Bring the first coherent actual source render to the separate visual reviewer before extended refinement, proof collation or release packaging. Resolve visible form and composition problems while the change is small. Keep required independent gates and batch delivery checks; reuse unchanged evidence with its original scope.

**Measured capture-survival experiment:** after identity, construction and world readiness pass, existing planned stills may continue despite explicitly nonfatal post-load diagnostics. In 1412 source002's repaired native run, all 5/5 planned originals survived the two framing diagnostics in that one failed run, with zero capture retries. Keep the complete diagnostics, `ok:false`, exit1 and visual HOLD; fatal boundaries remain unchanged. This measures retained pixels and avoided capture-only retries in one eligible run, not total workflow speed or universal success. The earlier 006 retry remains separate evidence. See the completed 1412 source002 entry in [RETRO](discovery/RETRO_LOG.md).

## Validate the representation actually consumed

The Building 2 first study repeated an older exact-cardinality guard pattern despite
the current rule against snapshot-count assertions. Review rejected wall/roof vertex
counts as validity gates; required indexed facade anchors, complete array strides,
finite geometry and source/receiver identity are the relevant safety checks. During
correction a model-session cap interrupted the edit after deleting the count constant,
leaving a metadata reference undefined. Check removed-symbol references after an
interruption and keep descriptive counts derived from actual data, rather than using
them to freeze legitimate world changes.

1439 mechanics002 falsely rejected133 retained roof0 contact rows because `int(shape_index) in allowed_landing_shapes` compared INT against JSON-loaded FLOAT IDs. Godot4.7.2 Array membership uses type-strict hash comparison. Validate that allowed IDs are finite/integral/in range, then normalize both operands to integer identity; keep the exact contact/source/support gate. A false summary flag is not proof of an absent contact—read the original row before diagnosing physics.

1303 roof005 passed emission, edge and collision-congruence checks despite self-crossing rings and overlapping near-coplanar triangles. Validate final rings after cleanup/grid conversion, then check coverage, overlaps and intended bounds in actual emitted native coordinates. Matching authored triangles or closed edges alone does not establish a valid surface. Distinguish a deliberate height transition with closure from duplicate surface coverage; keep checks focused on the affected geometry and preserve original failures.

Check the exact triangulation input after the last simplification or subdivision. In 1303 roof010, the zero-deviation check used an unsimplified ring while the builder later removed a shared junction; the consumed ring produced overlapping tops. Local polygonization into two components resolved that example, not the whole roof. Preserve shared junctions as topology constraints and bind ring/coverage checks to the final triangulation input and emitted decomposition.

YMCA001 sampled a height formula with a1.8m blend but did not split emitted cells at that breakpoint; native triangle interpolation spread the centerline offset transition over about4.0292m. A sampled function is not the resulting piecewise-planar surface. Check final emitted slopes/offsets at the affected junctions before describing the geometry. Represent a breakpoint only when that exact behavior is required; otherwise retain a valid smooth surface and correct the description instead of adding geometry merely to make old prose true. Independent contact and integrity checks remain separate. See the completed YMCA source001 entry in [RETRO](discovery/RETRO_LOG.md).

The 1202 changed-roof reader repeated the already corrected 1227 cross-run instance/RID equality mistake; 1234 then reused the corrected reader without repair or a native rerun. Use [compare_source_surfaces](tools/source_surface_comparator.py) for this shared decoded-JSON comparison: preserve exact keys, types, values and list order within each run; across runs exclude only direct record fields `instance_id`, `mesh_instance_id`, `mesh_rid` and `body_rid`. Nested fields remain significant. The caller must bind immutable inputs and assert expected source keys/counts; equal empty inputs prove no target coverage. The helper supplies no Float32 conversion, geometry, tolerance or acceptance logic. The first compatible review, M1234, used the exact unchanged helper with zero helper repairs; one external tag-intersection reader correction treated two triangle rows as one eligible surface. That correction was outside this comparator. The second compatible review, 1232 revision002, compared six full records with the same helper, zero helper repairs and no custom exclusions. Record comparator reimplementation/repair counts in the normal RETRO; retain reuse if neither is needed, and stop if broader exclusions or target branches are required. No speedup is established.

1303 material006's first aggregate array FAIL did not identify a channel. Later evidence isolated NORMAL as the raw/runtime difference; POSITION, NORMAL, UV and INDEX all matched when compared in the same runtime representation. In 1410 mechanics002, Godot JSON shortened arbitrary numeric values (for example `-283.86564000000004` to `-283.86564`), causing a strict `deepEqual` failure; string membership had also falsely marked all 28 original roof positions absent until both sides were reconstructed as Float32. Compare frozen source hashes for source identity and values in the representation actually consumed for native geometry/channels, rather than arbitrary serialized doubles or numeric strings. Preserve per-channel results and original failures; a serialization diagnosis cannot certify unrelated topology or mechanics. M1202’s reader later rejected a 15-digit JSON solver value against a Python double; canonicalizing **both** reported quantities to their consumed Float32 values restored the unchanged 4mm/1mm comparison. Do not canonicalize only one side or widen a physical tolerance to fix serialization. Keep the raw 1410 native-checker FAIL separate from any later exact-stream interpretation. Routine receipts and timings stay in RETRO.

1410 study003’s candidate/neutral self-comparison missed original live-builder tangent drift: omitted authored tangent inputs still yielded populated native arrays with different directions and handedness. Check preserved channel values against the actual original live-builder output in the same native representation, including tangent XYZ and W. Nonempty channels or a candidate-derived baseline cannot establish preservation. Reuse existing captured arrays and the affected preservation check; do not add a general audit.

Maceo’s changed-bucket helper compared native PackedVector3Array/PackedInt32Array bytes with ordinary decoded Arrays; Station48’s authority helper compared parsed JSON FLOAT arrays with INT literals. Correct values still failed. Construct expected values in the exact consumed container and element types, retaining strict equality and original failures. Mersea028 temporary pane diagnostic likewise assumed WorldHarness.visual_meshes() yielded nodes, but it yields Array records; property access aborted before capture and required owned-process cleanup. Read the complete helper return contract and an existing consumer before adapting a render loop: visual_meshes yields [Mesh resource, Transform3D, name] for geometry studies, with no scene-instance slot. Material overrides require actual source-bound MeshInstance3D traversal, not record unpacking. Check new comparison boundaries against the actual producer; a prior generic representation lesson does not make a newly adapted assertion correct. M1202 marker captures do not carry every whole-view field: use the actual capture `id` and full site snapshots for the corresponding checks. M1227 placement and saved-marker footprints must each pass; differing pixel corners alone do not invalidate invariant native camera/projector state. Preserve the raw reader failures and their scoped corrections.

1238 readiness001’s source-top-minus-margin test passed while all 12 emitted upper trims intersected emitted fascia by 23.5mm: trim Y/depth envelope was 8.269m and 0.068–0.134m, while fascia began at 8.2455m and spanned 0.015–0.265m. Derive clearance predicates from the complete actual emitters’ Y/depth/width envelopes, including a selected positive gap, rather than a source-top proxy. Preserve the held report and its bounded pre-render scope; this check does not establish a native render or whole-unit result.

1206’s far-right generated road edge lay on the actual aggregate road polygon while the included unnamed `path` centreline was 0.140732m closer than Mariner Drive. The frozen constructor gave `path` a 2m full width and Mariner’s `residential` way 6m: the edge was outside the path ribbon but at Mariner’s constructed edge. Attribute pavement from the frozen class width and constructed geometry, not nearest centreline alone; retain any absent per-triangle source-way label and do not turn a construction association into a surveyed curb claim.

1232 study 002 retained 36 inward closed-strip roof faces because its normals and consumed clockwise fronts agreed with each other; live equivalence preserved that defect. For these bounded closed strips, derive each interior from the actual unique vertices and check both supplied normals and consumed fronts point outward. Verify the sanctioned triangle reversal, render/collision congruence, cull mode and derived UV/tangent changes while keeping unaffected channels exact. Corrected 003 passed those checks; this does not establish roof walkability or invalidate unrelated historical evidence. See the completed three-unit source notes in [RETRO](discovery/RETRO_LOG.md).

1317 material001 replaced `source_color` palette inputs with raw `ALBEDO` constants and changed the intended warm boarding into a pale mineral-looking surface. Preserve color representation and conversion when refactoring shaders; material002 restored `source_color` inputs and actual whole/near renders validated the visual correction. Source intent alone did not establish the rendered result.

## Validate the final saved camera state

Maceo’s first SSE captures placed the camera0.310093m below unchanged LAND although the player was grounded: final upward aim followed earlier clearance checks and only process/render waits. Six post-aim physics frames let the stock SpringArm retract and clear LAND by0.159243m. Observe clearance and camera/land relation after final aim, physics response and the last capture waits; an earlier pose is not the saved view. Preserve controls and bad originals. Record small normalization differences as comparison data instead of inventing bit-equality requirements or retaking solely for logging.

w34313525's SSE camera was above adjacent-tile LAND by 1.951693 m, but an inherited player-tile identity assertion rejected that valid camera hit. A separate unfiltered camera-to-target ray hit a neighboring building, so projected target bounds did not establish visible frontage. Resolve the actual saved camera tile/ground from frozen source evidence, retain measured clearance even on identity mismatch, and require the intended first solid independently of projected framing. Keep public-side coverage distinct from whole-building bounds; do not alter terrain or exclude an occluder to make a helper pass.

1317 contact002 hit inside the intended sill face with a7.015µm plane residual but a3.188mm offset from the nominal aim center. The center-distance guard blocked the stock attempt despite valid contact geometry. Nominal mouse-aim precision is not geometry integrity: bind the actual first hit to the intended complete face/region, source and shape ownership, normal and plane, and keep center error diagnostic. Preserve stock camera/range limits and existing numerical geometry checks without adding or widening a tolerance. Retain the raw HOLD: a valid saved contact does not prove the stock rejection that was never attempted.

## Check actual support through the affected motion

1395 continuation-two review initially elevated an offline 4 mm comparison into a support HOLD for two reconstructed positive gaps of 4.034/4.411 mm. The actual `current_cross_leg`/`_rest` contract required destination arrival, supported released rest, no recovery and the destination predicate; it contained no 4 mm rule. The reviewer withdrew that invented gate without another engine run, preserving the observations, reconstruction precision limits and original failed receipts. Cite the applicable mandatory criterion before turning a diagnostic threshold into HOLD; label narrower diagnostic comparisons explicitly and never silently relax a real acceptance gate. See the corrected continuation-two technical-review clarification and attributed entry in [RETRO](discovery/RETRO_LOG.md).

1397 mechanics005 kept all sampled support valid but failed four door corridors after unrecognized foundation/lower-wall contacts: continuing held-forward input drove the capsule into jambs. Bind the intended closed-assembly stopping surfaces before motion; adding contact identities afterward cannot erase later drift or prove an unperformed retreat. Its two short-connector routes had outside seam midpoints but inside-footprint start extensions. Preflight complete exterior capsule paths, not just midpoint/source identity, and compute spray aim from the actual terrain-settled camera pivot before assigning the route.

1397 mechanics004 reported a29.123 mm capsule-to-LAND gap while its unchanged visible wall-bottom strip supported the capsule within0.170 mm. The helper bound only foundation/rail tops and rejected the real body-qualified wall240 contact. Reconstruct all relevant native local supporting surfaces and preserve body+shape+role identity before interpreting a selected-surface distance as a physical gap. Keep strict tolerances and raw failures; adding the omitted strip qualified current73 samples but did not explain earlier001/002 rail4.271 mm failures. A semantic `wall` role can contain a valid upward top; `on_floor` alone still proves neither geometry nor attribution.

1224 retained raw PASS/on_floor and camera checks while actual node and PhysicsServer transforms showed a 174.535 mm downward displacement and 174.449 mm recovery during the door retreat. The 501 synchronous snapshots corroborate real native motion, not merely a rendered offset; they do not expose the internal snap call or establish its cause. Independent support remains HOLD. Review the affected trajectory, support geometry/contact identities and destinations together; floor/camera flags alone cannot establish sound support. Preserve the stock controller, capsule, terrain and failed records. The separately approved three read-only reconstructed motion queries are diagnostic hypotheses, not an engine-call capture or gameplay fix.

1226’s 925 retained motion rows qualify under the unchanged 4 mm support, route, camera, braking and destination predicates, although its 53-row screen return has zero direct slide-event rows. `is_on_floor` reads floor state; `get_slide_collision_count` reads the motion-result array, and floor snap can establish support without appending a slide event. Retain geometric qualification and wrong-support contact rejection, but do not require a positive event count on every return. The original raw HOLD remains unchanged: corrected DERIVED route qualification and three later actual spray callbacks are separate evidence. Future full movement drivers must retain every route while omitting only incidental `and land_rows>0`; never reuse the spray-only outer schedule as a full campaign. See the accepted 1226 technical review and its bound original HOLD/derived evidence.

## Whole-building quality and bounded visual iteration

The 1232 production review accepted recognizable frontage while explicitly tolerating simplified roof finish, brown terrain and opaque glazing; the winning isolated benchmark instead owned roof, materials and immediate landscape as one composition. Its code was not integrated. This is evidence of a scope/acceptance mismatch, not proof of a global geometry ban or a model-speed cause. Use a whole-building art owner and compare the actual-world result with dated real-world references for believability and recognizability, without requiring one-to-one reconstruction. The owner clarified that the benchmark is a historical experiment, not an author prompt or acceptance target. The owner corrected overly specific door feedback: translate individual defects into broad artistic direction about believable architecture, depth, materials and composition, then let the artist diagnose solutions. Concrete defects are evidence, not a universal door/window recipe or per-house checklist; substantial recomposition may be warranted. Keep texture-only and normal-repair preservation rules local to those tasks. First coherent source pixels precede completed independent review/export within one bounded authorization; focus technical review on changed risk seams and retain independent promotion gates. Report visible quality before historical counts. The owner subsequently deferred bespoke tree modeling to a future vegetation-asset pass. The benchmark’s trees are not a requirement for the current building retry: assess architecture/materials, allow simple ground treatment and retain existing world vegetation without commissioning custom trees. After architectural005, the owner said “yes this is better” and authorized publishing these harness changes. This is a qualitative outcome for one isolated study, not proof of universal causality or speed; study code/art remains unpromoted.

## Settle physical-object association before transferring facade details

The inherited 1410 source notes assigned the nearby 1412 paired-garage/two-stair composition to 1410. D’s first acquisition correctly confirmed only the requested pano/date and explicitly left the address association unresolved. Frozen-footprint/first-hit checks and the corrected 166.5° view separated foreground 1412 from background 1410. Before borrowing facade modules, bind the visible physical object and face to existing source geometry and camera/ray evidence; a panorama’s nearby-address label or architectural similarity does not establish that join. Preserve occlusion and unknown details instead of transferring them from a neighbor. A readable building number may corroborate the result but is not a required gate. A subsequent ENE view independently confirmed two stairs on the actual 1410 target; that later evidence does not retroactively validate the original neighbor pixels.

## Start a new agent turn for every new assignment

New Maceo review requests sent through `send_message` did not restart the completed reviewer. Actual metadata measured 806.169 seconds between completion and restart; ROOT and authors repeated the same dispatch mistake while other authoring continued, so the interval is not whole-team idle time. Use `followup_task` for every new bounded assignment, busy or idle, and `send_message` only for active-work status or clarification. This fixes the observed wake-up failure without another monitoring layer or a claim about total workflow speed.

## Choose the next useful work after a held pilot

The isolated1220 material-finish pilot passed technical preservation but received
a separate visual HOLD: additional microsurface detail did not establish a useful
whole-view improvement. A failed finish pilot does not automatically make another
finish iteration the next priority. Use the owner's current need and the already
ready source/delivery work to select one bounded next step. Keep the pilot outside
accepted batch inputs until its own visual issue is resolved; do not turn minor
material contrast, helper line counts or subprocess seconds into a workflow-speed
claim. Existing shared helpers and dynamic target specifications remain reusable;
no generic refactor is implied by this lesson.

## Individual verification does not require individual authorship

The owner identified that similar housing was being treated as independent building work despite reusable shared structure. Per-building acceptance establishes each instance's identity, fit and quality; it does not require separately authored geometry or copied scripts. Before a new building, compare its observed structure with existing family assets, reuse a suitable shared base with semantic instance variants, or briefly explain the structural mismatch in the ordinary task note. Improve a weak shared base rather than treating older quality as a ceiling. Keep routine status concise and preserve required formal evidence bindings only at their actual contract boundaries.

The housing-family A/B extraction initially lost existing story/step trim and screen character across several instances. The final shared correction substantially restored these details and 1221 roof variation, while five regional studies and 1229 roof/apron fidelity remained incomplete. Compare family instances with both their prior art and actual references; preserve semantic variations instead of flattening them to shared defaults. This is one provisional experiment, not universal family acceptance or a new gate.

The targeted reference pilot separated evidence gaps from execution gaps: a new 1204 angle revealed specific left-end openings, while its central motifs and 1229 roof/apron already had sufficient pixels. Direct 1394 imagery confirmed one written family match; extra 1397 views mainly corroborated extent and left attachment/receiver ownership unknown. Ask what architectural decision another view could change, reuse relevant originals, and stop when the question is resolved or information gain ends. Four distinct views and 219.6 seconds of acquisition-through-gallery time support this bounded method, not a per-building quota or a workflow/token-savings claim.

## Preserve required reference standards after browser failures

On 2026-10-07, B2 black captures had been called unavailable without reading Maps state. A bounded same-browser reproduction exposed the explicit “No Street View imagery available here” message for that requested coordinate; known full Station48 and B3 locators rendered dated exterior pixels in the same session. The demonstrated workflow fault was saving before verifying viewer state, not a proven GPU failure. Use `tools/browser capture` to wait for stable panorama/date state and screen out black/flat saved viewer pixels; inspect actual target/side/date afterward. Empty pano IDs, black frames and HTTP success alone do not prove availability or absence. Preserve rejected attempts, distinguish explicit per-view unavailability from unresolved loading, and keep full-locator/UI recovery within the assigned navigation budget.

The hangar comparison substituted 2003 HABS photographs after headless/API-locator Street View pages rendered black. The owner required Street View; a headed browser with the full validated panorama locator immediately recovered dated November 2025 pixels. Because both browser mode and URL form changed, the precise failure cause is unproved. Verify the actual required imagery, resolved date and target association before artist dispatch. A browser loading failure does not establish unavailable imagery or justify a weaker source. Diagnose viewer readiness once, then report the blocker if unresolved. Archival imagery may supplement, but must not replace required contemporary views.

The same failure recurred for the Bulgarian Wall neighbor on 2026-10-03 UTC: coordinate/copied-pano deep links had produced black frames, but a fresh headed session entering Street View from the actual Maps pin and road-coverage UI immediately returned September 2025 imagery. Avenue D and Chinook Court supplied March 2025 opposite-side and complete-frontage views, establishing 1445 Chinook Court / w95934121. This repeats the existing lesson, not a new evidence exception; the precise earlier failure cause is still unproved. Apply the headed UI fallback before declaring imagery unavailable, preserving failed originals and actual resolved panorama/date/location.

For Building 600 on 2026-10-04, the initial headed session returned photometa 500/tile 403; a fresh headed session then returned coordinate metadata and tile HTTP 200 but still showed a black viewer. Navigating that session to the complete resolved `/maps/@lat,lon,3a,.../data=...!1s<pano>...` URL rendered September 2025 exterior pixels, and the normal rotation control worked. No browser package, GPU option, proxy, account or access-control change was needed. The precise cause is unproved because session freshness and URL/initialization state differed. After the required UI fallback, inspect network and actual saved pixels; if coordinate/API startup remains black, try the actual full resolved panorama URL once in a fresh headed session before declaring a blocker. HTTP 200 or a resolved pano ID alone does not prove a working viewer.
A subsequent same-session test also succeeded through the actual Building600 place card: enable Street View, click blue Avenue M coverage, then rotate toward the target; the saved September2025 `L_00cDY02FaeZrVa3MCCsg` pixels confirm that route works. Headless was not tested in this round. Use `tools/browser` for the private headed Weston lifecycle and retain its terminal handle.

## Condition small polygon calculations locally

The housing roof clipper produced thin positive-area triangles at large projected
coordinates. Float32 cross-product area cancellation initially hid them; then
Godot triangulation rejected them. Compute signed area with origin-relative scalar
products and triangulate translated coordinates while applying indices to the
original points. Remove only exact duplicate vertices; retain errors for positive
area failures. Round2 run 004 preserved the pieces and passed; 001/003 failures
remain evidence. Do not label tolerance-based area loss as zero-area cleanup.


## Check winding when reusing source triangles in generated meshes

The finishing-refinement 001 copied correctly placed area triangles into the
shared SurfaceTool builder, but their ordering produced downward-facing ground.
Native execution passed while the parking/walk was invisible. Preserve source
positions and check the destination builder's winding convention before capture;
002 reversed only those triangles and made them visible. Correct visibility did
not settle composition: the rear walk also needed to account for stepped entry
paths, addressed separately in 003.

## Probe exposed geometry and keep completion claims stage-bound

The shared-family live integration retained positive clipping triangles, but its first-face ray sampled a 20 mm² fragment; a later wall centroid was 0.255 mm below actual land while the triangle's upper portion remained exposed. Neither miss demonstrated a usable wall gap. Select stable interior samples against canonical world terrain across chunk boundaries, keep all rendered/contact triangles, aggregate read-only failures, and explicitly leave tiny or unsampled regions unproved. Do not add collision backing solely to satisfy a degenerate probe. Ground overlaps require verification against the actual hit owner's triangles; wall and roof source ownership stays exact.

The same run series exposed two completion hazards: visible MeshInstance nodes can have null meshes, and real reload re-emits world-ready signals. Count empty meshes as zero geometry and make runtime signal connections idempotent. Build a successful final receipt only after its required stages complete; a native exit of zero does not override engine errors. Reuse independently reviewed completed subsets without relabeling their failed parent runs as passes. Keep historical builder topology separate from current visible/active topology after an adoption hook.

When a JSON topology binding is consumed, compare the same keys and exact finite integral numeric values rather than Dictionary representation equality: parsed JSON floats and native integer counters can describe identical counts. Reject fractions and wrong types; do not repair this with truncation or tolerance.

Hawkins mechanics001 exposed lost collection through dictionary/cast `PackedVector3Array` mutation; source review had missed that producer behavior. Collect into typed local arrays, then assign completed arrays into the dictionary, and bind the actual nonempty consumed output. Collector-only002 retained63540/36 face streams and completed its raw scoped cases. This extends the existing producer-representation check, not a new validator/test gate; independent final interpretation remains separate.

The shared-family release adaptation exposed two external-contract assumptions: two physics frames did not establish deferred world readiness, and an editor-mounted full-world loader intentionally required raw source files excluded from the PCK. Wait for actual validated/failure state with a deadline, and check the executable feature boundary before reusing a loader. Preserve failed attempts and distinguish repeat-run native success from an unproved cold-start guarantee.

## Match Godot triangle winding at the actual emitter

Housing expansion004's new draped parking apron passed a conventional positive-cross-product normal preflight but was backface-culled by Godot SurfaceTool. The existing shared roof producer already used clockwise triangles and explicitly reversed positive-Y cross products.005 reversed the new ground triangle order and the apron became visible. For procedural ground, validate winding against the actual producer's convention (Godot clockwise here), not a generic mathematical upward normal; inspect the first actual render before claiming surface coverage. Preserve the failed run and treat visible fit separately from contact verification.

Mersea study002 repeated this failure on an invisible stair nosing ramp: the
mathematical +Y triangle order was emitted into Godot, and the stock player
stalled on supported land before climbing. The second route also placed its
bottom inside a neighboring frozen footprint. Before a ramp run, check the
actual emitter's clockwise front face and compare the full start/flight/end
route with adjacent source polygons; a visually clear platform does not prove
its test approach is on open land. Failed fit002 remains retained.


## 2026-09-29 —1439 collision coordinate representation

In the reviewed1439 experiment, recentering the same LAND body at(-296,0,17), with366 byte-identical world vertices and unchanged filters, resolved the prior retreat dip across the original133-row approach/retreat campaign. World-equivalent collision coordinates can affect an observed native contact outcome; preserve body identity, world geometry, original route and exact teardown when testing this possibility. This is route-specific evidence, not a universal Jolt root cause or approved loader change. See `evidence/building-quality-drafts/2026-09-29/1439-quality/local-origin009/INDEPENDENT_REVIEW.md`.

## Read only the fields needed for measurement and assembly

The 2026-10-02 blind modeling capture/assembly executor over-read broad source files and session metadata. At HTML-ready, its observed uncached input was 124,475 tokens versus 84,479 for both authors combined; this as-of comparison is not billing or proof of cost attribution. Use standard JSON parsing to select only required session identity and token fields, strip embedded base64 before reading HTML template structure, and read relevant source excerpts. Preserve the required evidence without adding a workflow gate or report. See the named shootout_capture_61 entry in [RETRO](discovery/RETRO_LOG.md).

## 2026-10-01 PDT — Review actual reference sufficiency before artist dispatch

The owner found the Mersea images insufficient for the planned modeling assignment. ROOT initially prioritized Street View for this public restaurant; recovered evidence showed only four useful architectural exteriors among twelve official JPEGs, and browser captures included a duplicate panorama, a wrong-target field and a loading frame. Roof/overhead and clear overall-layout coverage remained missing; no Mersea artist had been dispatched. ROOT’s source priority and coverage assumptions failed to establish what the retained pixels supported. ROOT must apply the [reference-sufficiency review](.agents/skills/building-texture/SKILL.md#reference-sufficiency-before-authoring) to the actual image set before artist dispatch or continued authoring, then request targeted better evidence for important remaining structural questions. Choose sources suited to the place instead of equating source choice or image count with coverage.

## Match representation to physical meaning

Mersea's procedural-only 15-minute shootout brief encouraged mesh paint; that restriction is not general quality policy. Owner-authorized material/Decal refinement using authored opaque wall albedo on existing corrugation improved the private visual result. Choose representation by the task and physical meaning: painted art belongs in a material or decal; existing geometry supplies relief.

RGBA presence did not guarantee opaque navy: two transparent generated outputs retained holes. Spatial alpha checks caught v2 before another engine run; opaque RGB resolved this instance. Validate intended asset properties and first-render orientation—the initial projection was upside down. This does not reject transparent textures generally or add a gate, framework or timing claim. Independent gates and pending contract approval remain separate; private visual PASS grants no production integration or release.


## Preserve semantic roles independently of sibling names

The Bulgarian Wall / 1445 Chinook integration classified meshes by `Node.name`. Godot auto-renamed repeated siblings, so later driveway/tread meshes escaped intended exclusions and stair treads became wall contacts. Actual stock ascent stalled on those contacts; descent had long airborne intervals. Preserve an explicit semantic label when constructing each mesh and use that metadata for role selection, with the intended positive coverage checked in the existing source review. The corrected 34-tread exclusion restored supported descents; both upper-landing ascents remained held at that stage, so fixing classification did not establish full stair acceptance. Native ordered geometry equality proves the consumed shapes agree, not that they received the intended role.

## Check junction end planes when combining solid building modules

Building 600's roof edge initially coincided with red portal surfaces, causing
pale slivers in actual gameplay captures. After a full-height classroom return
was added, source review found a second coincident roof-end/return plane. Bury
concealed component ends within their receiving solid or omit concealed faces;
compare both material ownership and exposed planes before capture. Collision
solidness alone does not establish clean visible junctions. The final roof end
was recessed 0.18 m into the existing 0.36 m return without changing passage or
ground-contact geometry.

## Serve remote visual galleries over loopback HTTP

On 2026-10-04, VS Code's integrated browser rejected the Building 600 comparison
at `/tmp/b600-three-model-comparison/index.html` as outside the trusted folder.
Serving that directory on `127.0.0.1:8765` and using a VS Code forwarded-port URL
provided verified HTTP delivery without changing trust settings. Checks returned 200 for
the index and an original image; actual browser inspection confirmed all 15
images loaded. The observed restriction concerned remote-file delivery, not a
broken gallery. For future outside-workspace HTML artifacts, choose an available
loopback port, verify the actual page/images, and retain explicit live-server
ownership until viewing is finished. Port 8765 was this run's choice, not a
requirement. Keep reference privacy intact; do not move photos into Git/game as
a delivery workaround.

## Separate spatial footprint binding from business identity and sign text

During Mersea study004 the owner questioned “Gold Bar” as a separate destination,
then acknowledged the relation after ROOT verified Mersea's Golden Hour Bar
collaboration through official primary pages. The initial wrong-business concern
was not established. A frozen footprint match, a business collaboration and an
exact sign transcription remain separate claims: the authored “GOLD BAR • MERSEA”
text was inferred, not transcribed. Verify readable branding from source pixels
and provenance; distinguish a dated partner brand at the restaurant from its
separate destination, and do not treat the owner's initial question as proof of
misassociation. Preserve completed unaffected evidence while resolving identity.

## Preserve task-specific routing through harness resumption

During the 2026-10-05 Mersea study, the modeler stopped when generic AGENTS Claude routing was re-injected as a newer message, despite the owner's explicit Astra Low modeling and Sol High review override. The canonical routing text lacked that active exception. Record task-specific owner overrides beside the general defaults, including scope, and carry them through resumptions; repeated generic instructions do not imply the owner revoked an explicit override.

## Distinguish reflection availability from convincing glass

Mersea007 matched probe intensity0/1 produced only slight ordinary-glass brightening; one temporary opaque neutral reflective pane showed blurred courtyard colors. Reflection data was contributing, but material opacity/scattering and an empty shell still prevented convincing glass. A shallow backing then removed the through-view but read too dark and opaque. Check a bounded matched optical pilot before wider capture sets; never promote a diagnostic metallic pane as glass or treat elimination of one defect as whole-material acceptance. Rendered-frame waits are not direct probe-ready readback.

Mersea008 incorrectly reversed valid one-sided curtain triangle winding while trying to brighten cloth; the first pilot reduced the cloth to broken edge marks. Independent local-normal/transform review identified the reversal, and restoring the original winding restored visible pale cloth in the second render. Check the exterior normal under the actual positive-determinant facade transform before reversing a one-sided surface; brighter albedo cannot fix backface culling.


## Judge glazing at its actual view angle and reflected context

Mersea study011 measured the actual pilot pane normal and gameplay view: N·V=.588 gives approximately 5.14% Schlick reflectance for F0=.04. Both reflected-direction scene proxies contained architectural contrast, while the bar's surface and probe-origin proxies saw different nearby objects. Earlier review over-weighted a sharp readable mirror image; ordinary glass at this angle can have subtle reflections. Check actual angle, transmitted/backing composition and probe parallax before requiring stronger reflections or tuning gain. Scene-context proxies are not cubemap readback or readiness proof, and a dielectric Fresnel estimate does not describe a metallic bar. A box-projection experiment must be judged in matched pixels; an outdoor proxy box is not a measured enclosure.


Mersea study012 launched the shared driver with `--path game`, but this repository's project root is `.` and its preloads use `res://game/...`; the invocation failed before world load. Copy the maintained complete donor command and cross-check its working directory, project root and script resource path before launching. Mersea031 also lost its first overhead attempt to --overhead=value: the shared user_args parser requires separate --overhead VALUE tokens. Check the actual parser and copy its supported argument form before a new option launch. A wrong-root failure still consumes the bounded invocation budget; retain its log and use a fresh output path for the corrected run.


## Normalize primitive face coordinates before finite material masks

Mersea study016 assumed BoxMesh UVs covered 0–1 on each face. Godot's BoxMesh uses a 3×2 atlas; the resulting glass-edge deposit mask missed right/bottom edges, and the stated brush-band scale was twice the actual front-face count. Check the actual primitive UV layout and physical span before authoring finite edge masks or quoting feature scale. The corrected mask uses per-face coordinates; this fixes semantic coverage, not visual quality by itself.

## Preserve the open/occluded balance when adding window depth
Mersea017 connected shallow backs and inclined returns correctly, but independent gameplay review found the repeated full backs recreated opaque display panels and a closed sectional shutter. Geometry containment and removal of empty-shell sightlines did not establish glass quality. The partial-back revision recovered openness while retaining visible perimeter depth, with finish still unresolved. Compare the complete glass/cloth/reveal/transmitted-view balance in the first front and oblique render; do not default to identical full backing across every bay.

## Light receiver masks do not isolate reflected context
Mersea018's temporary key selected only tagged bar metal with render bit8. Independent A/B still found new gold rectangles in pavilion panes: existing probes can capture the illuminated geometry and apply it elsewhere. Also, observing UPDATE_ONCE after its mode switch does not prove its cubemap had finished capturing before a subsequent light change. Label such a test added incident-light response with possible reflected contributions, not specular-only or guaranteed unchanged context; inspect a neighboring reflective context view.

Mersea019 lost its first bounded capture to a mistyped Environment enum before world load. Check unfamiliar static constants and property names against the installed engine commit API before launching; a correct conceptual plan does not prevent a parse failure. A temporary in-memory PackedScene resource override also needs a retained strong reference until the actual instance loads, plus logging of the live environment; a resource-cache assumption alone is insufficient.

## Check pinned dependencies in the actual worktree
Mersea021's full suite passed its Godot stages but failed Node validation/determinism because /workspaces/content-main lacked earcut and polygon-clipping, despite devcontainer post-create running npm ci in its primary checkout. Existing-lockfile npm ci in the actual worktree resolved the prerequisite; the authorized full retry passed. Inspect dependency installation in a new worktree before expensive complete checks, preserve the pinned lockfile, and distinguish missing tools/packages from source-data failures.

## Update behavioral configuration checks with an approved configuration change

Mersea024 applied the owner-approved procedural Sky but the first full suite still required the previous COLOR ambient source and zero sky contribution. The resulting failure was an obsolete contract, not a missing runtime Sky. Before running the suite after an approved configuration change, inspect the corresponding behavior check and require the new usable resource path (here, actual procedural Sky with active ambient/reflection sources and positive hemisphere energy). Preserve unrelated behavior checks; do not skip a failing case or add pixel/color snapshots to force a pass.

## Check decorative motif height against visible platforms

Mersea025's first lower service rail used the wall-local bottom and was hidden below the existing platform. The source base was3.14m while actual supported platform top was3.9081m; the initial local.225m rail could not appear above it. Before the first render, compare the full detail bounds with both local terrain and raised visible/support surfaces, then check the intended gameplay sightline. Moving the decorative rail above the exposed sheet foot preserved contacts; this was a geometry-visibility revision, not a camera setup repair.

## Preserve thread storage for delegated CLI reviews

Study026 selected `codex exec --ephemeral` for an ad hoc visual review. Required child delegation failed with `invalid thread-store request: no rollout found`; the parent then waited without a reviewer. The authorized persistent replacement produced an actual `SubAgentActivity` started record and named child spawn result. Omit `--ephemeral` for orchestrators that delegate, forward private image paths to the child for actual inspection, and verify spawn identity plus terminal/verdict separately. A role label does not override the root-only orchestration boundary.

## Opaque decoration must preserve visible spray receivers

Study032's nonreceiver fascia covered unchanged wall-layer2 boards; its revised soffit also hid a rear receiver band despite safe front clearance and unchanged collision. Remove broad overlays or preserve the existing visible receiver boundary. Preflight every affected front, rear and side receiver plane using thickness-inclusive transformed bounds and projected occlusion, not only collider/source identity. Mount raised lettering from actual mesh AABB bounds rather than a fixed font-dependent offset. When reference-supported construction should replace an old visible surface, author it as legitimate same-source wall geometry through the existing receiver/contact helper, then run fresh fit and stock spray; do not repeatedly undo useful architecture solely to preserve obsolete decorative coverage. Study036 used this route and passed complete114 fit/stairs plus one actual new-portal decal.

## Compare site axes and furniture groups directly

Mersea042 owner satellite feedback exposed bocce lanes aligned to the wrong container axis and all long tables on one side of the planter despite prior broad-layout PASS. Compare actual north-up reference/render lane axes and relative furniture groups explicitly, not only roof footprints or regional greens. State image-date/anchor uncertainty; retain frozen building identities, infer reversible site placement, and verify changed furniture-support routes with the stock controller.

## Launch an engine as the tracked background command

Building 3's first baseline wrapped `tools/godot` in `( … ) &` inside an already-backgrounded tool call. The tool reported completion while Godot was still rendering, and the real PID had to be recovered and polled before its EXIT 0 counted. The cause was the double backgrounding, which detached the engine from the tracked handle. Make the engine (plus its exit-status echo) the background command itself, record the actual Godot PID, and treat only that process's exit and absent Godot/Weston processes as terminal evidence.

## Judge code drift from the complete snippet

During the Building 3 first-study review, a reviewer inferred code drift from a truncated excerpt. After inspecting the complete snippet and diff, the reviewer retracted the finding. Before a CODE HOLD claims missing or changed code, read the full function or the actual `git diff` hunk. A truncated tool view is not evidence of absence. Retain genuine findings from the same review.

## Visible MultiMesh checks need actual rendering

Building 3's shared headless fit printed PASS with origin-contaminated bounds,
sparse samples and three remote approaches. The unchanged rendered invocation
restored the local bounds, meaningful surface coverage and four native wall
contacts. This matches dummy-renderer MultiMesh identity readback; the original
run did not log each instance getter, so that individual readback is inferred.
Run these visible-geometry checks with rendering and fail closed on headless
use. A missing source-wall ray hit is not zero distance or arrival evidence;
report required approaches and their actual contacts, retaining failures.

## Unsafe test state must survive across units

Independent review found that BuildingFit reset its unsafe flag on every unit
while the island loop continued unconditionally. That could resume movement
after a setup, recovery, active-rest or safe-final failure. Latch unsafe state
for the driver's lifetime, refuse later checks, and stop the caller with the
remaining units explicitly untested. Ordinary fit failures may continue only
after supported, input-released, stopped active REST and safe teardown; a new
unit must never clear an unsafe result.

## Preflight approach starts without weakening actual support checks

Building600's fixed AABB-plus5 m east start landed on a neighboring roof,
not on the target's approach ground. Select a bounded same-cardinal alternative
using native support and stock-capsule clearance before placing the player;
then still require the complete actual approach. The first repair left the last
5 cm of settling unqualified, and a later0.7 contact cutoff omitted floors the
stock48-degree controller accepts. Inspect actual settled native floor contacts
before forward input, deriving eligibility from the real up_direction and
floor_max_angle; any unknown or nonwalkable floor support remains unsafe even
when another ground contact is valid. Keep active rest and safe teardown on HOLD.
The1220 west setup later passed central-land and above-ground capsule queries
but settled on adjacent FamilyContact_ground. Preflight the complete native
body descent and near-rest contacts before placement, including the capsule's
shape offset and safe margin; a clear central ray does not qualify its footprint.
Reject unknown or nonwalkable contacts before trying another bounded candidate,
while retaining the actual settled-support gate as the final check.

## Distinguish collision shape objects from native shape indices

The architectural-route repair passed source review but failed Godot4.7.2 parse
before any fit: KinematicCollision3D.get_collider_shape returns Object, while
our allowed native shape-index map requires int. Use get_collider_shape_index
for that mapping and preserve the per-subcontact index. Check the actual API
return type when connecting physics identity helpers; method names alone are
not sufficient. The failed engine was stopped and remaining cases were not run.
Official API checked2026-10-07: https://docs.godotengine.org/en/stable/classes/class_kinematiccollision3d.html

## Keep predictive floor transport local and identify the actual contact

1394's corridor filter rejected three lanes at native canopy contact points
Y5.575, while local ground plus the stock capsule height is about4.7 m. The
helper extrapolated a local floor-contact normal over the entire remaining
route; missing intermediate pose/slope rows leave artificial upward travel a
code-supported risk, not a proven runtime cause. Bound transport locally and
refresh native support after each short sweep, retaining query pose/motion/travel
and contact point on rejection. A mixed FamilyContact_support shape contains
many meshes: body/shape identity alone did not establish the earlier inferred
post as the corridor obstruction. Preserve actual stock movement and REST gates;
more candidate lanes or a source CODE PASS cannot establish a runtime repair.

## Qualify native ground by producer semantics, not only terrain ancestry

The post-source59 suite rejected every source66 west start before descent because
FamilyContact_ground lacks the nonbuilding parent feature_kind required by the
shared predicate. Its live producer explicitly groups parking, footway and entry
path tops separately from roofs/support. A source-bound, active native ground-role
qualification let focused11384 select the2 m footway start and complete all four
stock approaches with active REST/safe final; the5 m canopy remained rejected.
Require the proven production scope, matching source identity, nonreceiver ground
role and supported native shape, then still evaluate slope, full capsule descent
and every settled support contact. Neither a body name nor a ground label alone
proves traversability; unknown/support/roof contacts remain ineligible.

A separately source-bound rooftop component needs its proven parent support
context rather than blanket roof eligibility. Review43079 found that qualifying
setup, prediction and final REST still left active walking floor subcontacts
unchecked. Trace the same native body/shape/point/normal qualification through
each active physics wait, retaining mismatch HOLD through safe teardown; do not
require incidental slide events every frame.

## Validate diagnostic entrypoint grammar before world loading

The island batch parser and later integrated single-building review exposed the
same failure: recognizing only a diagnostic-name prefix lets malformed flags
fall through to normal movement. Validate each entrypoint's complete supported
flag/value grammar before loading, consuming filenames as values and rejecting
unknown, duplicate, missing or conflicting options. A corrected sibling parser
is not evidence for another entrypoint. Verify rejection stage separately from
valid-argument arrival at the existing renderer guard; those probes give no
movement or fit credit.

## Collect owned nodes before freeing a descendant tree

Chapel study001 iterated a descendant snapshot and freed its StaticBody parent; the later child entry was already invalid when tested with `is`, causing WORLD_FAILED before screenshots. Collect supported owner bodies while all nodes are alive, validate direct-parent ownership/no nested owners, then remove/free them after traversal. Study002 used that order and loaded/captured successfully; this establishes the cleanup repair, not geometry or art acceptance.

## Trace separately scored rooftop support before changing a parent roof

Building1 study003 CODE review found that localizing the parent roof to the exact tower platform outline removed the elevated area used by the separately scored tower’s four local approaches. The unchanged driver proposes starts outside tower bounds and qualifies parent support at the tower base; this was a source-derived integration finding, not an executed fit failure. Before roof recomposition, trace the actual child support binding, native producer outline/elevation and stock start/clearance domain together. Preserve real supported approach space and every existing support/rest check rather than broadening roof eligibility to hide the loss.

## Inspect both tool event forms before reporting inactivity

On 2026-10-07 the coordinator reported no recent B3 image inspection because its rollout filter counted `function_call` but omitted `custom_tool_call`/`exec`. Actual image batches ran15:22–15:36 and the reviewer completed33 originals. Inspect both tool forms and their actual inputs/results before distinguishing child execution from parent-only waiting; model metadata, inbound assignments and elapsed silence alone establish neither inspection nor failure. Never restart a retained live task on that incomplete inference.

## Check the complete placement column, not only wall-foot clearance

B3 all-sides001 fit11333 passed four stock approaches but spray setup rejected “on top of a building” before placement. Its reused wall-foot pose was0.358m outward; new upper relief projects0.60m, while the maintained settle helper starts a downward ray atY300. This supports an overhead-hit explanation, but the actual rejected hit identity was not logged. A previously safe low capsule/target does not prove the highest-hit support/drop/camera column remains clear after facade changes. Trace all native geometry above the proposed standing location and preserve the existing setup/support gates; choose an outward-cleared pose or a proven unchanged donor with explicit coverage limits. Source preflight is not fresh runtime ray or spray proof.

## Subdivide the existing sampled boundary when cutting new facade bays

B3 all-sides002 CODE review found an approximately9.5cm run38 wall/roof gap: new recess cuts resampled an analytic height function while the unchanged roof retained its earlier tessellated boundary. Pass the original per-run wall-top samples into the cut emitter and interpolate within their existing intervals, preserving endpoints and knots. The same independent reviewer passed that narrow repair; later current fit/spray passed its sampled native checks, not exhaustive seam coverage or whole-building visual quality. Before changing subdivisions, compare the resulting shared boundary with its actual neighboring emitted geometry rather than assuming the original formula reproduces it.

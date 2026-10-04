# B600 fresh isolated study — task note (b600-art-owner, 2026-10-02)

Target: OSM `w34313548` v6 (SFFD Treasure Island Training Facility Building 600, 750 Avenue M), generated pair `building:w34313548:wall`/`:roof`, chunk `x_1__z_-2`, base 4.064 m. The study is isolated: there is no production attachment, export, package or authority edit, and no acceptance claim.

- **Reference sufficiency (ROOT decision, recorded):** SUFFICIENT for an isolated whole-building game-art study. Its limits: the images are 800 px viewport captures with Maps UI; the east/yard face is visible only from the air; the south face is one tree-occluded view; the west window cadence is hidden by trees; and there is no angled roof view. The private packet stays outside Git.
- **Reuse:** new base. The owner directed a fresh study, so no reuse comparison was made.

## Source (final, bound to inv07-static and inv08-full input snapshots)

- `game/scripts/world/facades/b600_fresh_study_model.gd`: procedural model with 4 meshes and 3 owned bodies. WallContact is layer 5, spray receiver `building_wall`, render layer 2. Roof/DetailContact are layer 5 with receiver `none`. The visual mesh (slab and badge) has no collision.
- `game/tests/b600_fresh_study/study.gd`: driver adapted from the Hawkins capture and mechanics drivers. It swaps the exact source pair, captures matched A/B stills and aerial study-camera stills, runs stock mechanics, and checks preservation and restoration.
- `game/tests/b600_fresh_study/static_check.gd`: headless preflight. It uses the shared `building_study_geometry.gd` (INDEXED_ARRAYS, identity transform, positive expected coverage) and checks containment, winding, ground seating and wall bottoms.
- `game/tests/b600_fresh_study/manifest.json`: views and mechanics in footprint-local (a, b, height above B) coordinates.
- `game/tests/b600_fresh_study/run_study.py`: owned engine-child runner. It records a pre-run engine census, live PID, terminal code, missing receipt and slot release.

## Production inference (not as-built)

- **Heights.** The parapet is B+5.05 and the portal frame top B+5.30. Both sit below the 6 m OSM tag, based on the about 1.6 opening-to-frame-height ratio in r07/r08/r15 and the r10 band ratios. The footprint and orientation are unchanged.
- **Portal.** Clear opening is a 4.45–12.85 (8.4 m). The segmental arch springs at B+2.25 with its crown at B+3.85. The frame spans a 2.0–15.3 and stands 0.31 m proud of the west wall. Positions come from pano TKrEWRNj heading geometry.
- **South block.** Placed at a 0–15.3, full width, with the passage inside it. The block is darker-roofed; its length is estimated from r04.
- **East covered walkway.** Placed inside the footprint at b 12.95–17.5, with the main bar at b 0.35–12.95. Its width comes from r03/r10 ratios.
- **NW corner porch.** A low, cream-banded corner element with a pier (r10). The high wall steps back to b=1.9 for the last 4.1 m.
- **West face.** 14 bays at 6.05 m, a pair of high windows per bay, and a lower window/door pattern. The cadence is inference because trees hide it.
- **East face.** Kept plain, with doors/windows under the walkway and a clerestory above it.
- **South end.** One door and two windows.
- **Passage.** The east arch is cream (from the 2019 state). The north wall has doors and windows; the south wall has a breeze-block field with light cell backs.
- **Passage fittings.** 13 open-web joists, the SFFD badge, and 8 bollards with a 0.88 m clear centre gap.
- **Lettering.** "FIRE FIGHTING SCHOOL", "600" and "TRAINING" use the engine fallback font, not the real typeface. The recessed upper panel on the frame was omitted.
- **Fixtures.** Door wall-packs are inference.

## Final evidence (inv08-full/images, 1440x900, stock camera unless marked)

A = generated placeholder, B = candidate, same pose. All A/B camera drift was below 1 mm.

| View | Self-assessment |
|---|---|
| `gameplay-portal` | Maroon square frame, segmental arch, lettering, 600, passage depth and bollards read clearly at gameplay distance. |
| `r07-portal-match` | Composition matches r07: low cream bar with high and lower windows, frame slightly above the parapet, portal right of the avatar. |
| `r05-west-mid-match` | Long pilastered cream wall with paired high windows. Plausible, but r05 is mostly tree-occluded, so cadence is unverified. |
| `r12-west-oblique-match` | Long low single-storey bar receding to the portal. Massing reads like r12 (2011). |
| `r13-west-rake-match` | Uniform parapet line along Avenue M, as in r13. |
| `r10-north-end-match` | Banded blank end wall (blue-grey/cream/grey), canopy with fascia, posts, teal door and NW porch pier. Close to r10 composition. |
| `r14-south-match` | South end and maroon portal edge from the southwest. r14 is occluded, so this is weak evidence. |
| `gameplay-passage-west` | View through the passage: joists, badge, side doors and windows, far cream arch. |
| `gameplay-passage-east` | View from the yard back through the passage. The cream east frame is a large blank plane (inference). |
| `gameplay-yard-east` | East face under the walkway. Honest but repetitive inference. |
| `aerial-topdown` (study camera) | White membrane bar, grey east walkway strip and darker south block, comparable to r02. |
| `aerial-sw-oblique` (study camera) | Roof, west face and portal together. No angled reference exists. |
| `aerial-east-oblique` (study camera) | Yard side, walkway posts and fascia, maroon frame top line (r04). |
| `motion-*` | Single sampled frames during stock motion and sprays: mid-passage, under the walkway, wall push, and two placed tags plus a glass rejection. |

## Focused mechanics (inv08-full, actual source world, stock controller)

- **Shared indexed geometry and roles:** passed exactly for WallContact (12330 vertices), RoofContact (990) and DetailContact (28356). Full operands are in `native-geometry-*.json`.
- **Passage traverse:** the walk went west to east to (8.66, 21.45) and back to (8.64, −5.44). Both legs arrived; support and slide owners were land only; recovery delta was 0; rest was supported and input-released.
- **Walkway:** the player walked from the yard under the walkway to (48.97, 15.07) and back. It arrived on land support, between posts, with no recovery.
- **West wall stop:** penetration was blocked at b=−0.061 and the retreat passed. The original wording here was wrong (corrected per review finding F1). The final stop was against the DetailContact window-sill front at b=0.29, after the player slid about 2.3 m over pilaster corners. The contact normals were not all exactly the wall normal. The case's `owners.has(WALL_KEY)` predicate could not separate WallContact from DetailContact (F2). The conclusion that the stock controller's per-axis `move_toward` caused the slide still stands.
- **Spray:** the cream west wall and the maroon frame each gave `placed` with the w34313548 wall key and cull mask 2. Window glass gave `receiver_rejection` with no tag added.
- **State checks:** final enabled rest was safe and the controller was disabled with zero inputs. Every non-target body was unchanged, and the original generated pair was restored exactly.
- **Stairs:** none are visible, so no stair walk was needed.
- **Ground preflight (inv07-static):** all 42 contacts are seated on actual land. Bollards and posts are embedded 0.10 m, and door sills sit 0.02 m above land. Wall bottoms are 3.40, below the source minimum wall bottom of 3.66 and at least 0.28 below land on the perimeter. The visual slab sits at land+0.065, above the +0.05 area overlay. No vertex lies outside the footprint, and there are 0 winding violations.

## Engine invocations (serialized; each observed to terminal; budget 15, used 8)

Every run was preceded by a pgrep check that found no other Godot process.

| Run | Mode | Exit | PID | Outcome |
|---|---|---|---|---|
| inv01-import | import | 0 | 13233 | OK |
| inv02-static | static | 1 | 13361 | HOLD: south window sills 1 cm outside the footprint; emboldened font failed TextMesh triangulation. Both fixed. |
| inv03-capture | capture | 0 | 13610 | First coherent render. Plaster albedo muddy, roof dark. |
| inv04-full | full | 0 | 14563 | Mechanics PASS. Clean paint. |
| inv05-full | full | 0 | 15844 | Proportions and palette corrected. |
| inv06-static | static | 1 | 16364 | HOLD: door fixtures 6–11 cm outside the footprint at the south/north ends. Fixed. |
| inv07-static | static | 0 | 16542 | PASS on final source. |
| inv08-full | full | 0 | 16635 | PASS on final source. |

Every `result.json` records `slot_released: true` and an empty `engines_after`. A final pgrep found no Godot process; the slot is released.

Failed attempts (inv02 and inv06) are kept as they are.

---

# Round 2 (2026-10-03): independent mechanics PASS, visual REVISE

Round-1 evidence inv01–inv08 is unchanged. Same scope and boundaries; the engine slot was re-held with a budget of 10 and 4 were used (inv09–inv12).

## Final round-2 source (bound to the inv11-static and inv12-full input snapshots)

| File | SHA-256 |
|---|---|
| `game/scripts/world/facades/b600_fresh_study_model.gd` | `6f2be1e9…2c891f4c` |
| `game/tests/b600_fresh_study/study.gd` | `d48da5e2…d1a6d133` |
| `game/tests/b600_fresh_study/static_check.gd` | `c6fca3e9…6ffe9cef` |
| `game/tests/b600_fresh_study/manifest.json` | `5676ed71…9bdb9f68` |
| `game/tests/b600_fresh_study/run_study.py` | unchanged, `c84d8c18…` |

## Inference changes, round 1 → round 2 (all production_inference)

| Item | Round 1 | Round 2 |
|---|---|---|
| Portal frame | a 2.0–15.3, wide 2.45 m piers, 8.4 m opening, crown 0.72 of frame height | Frame a 3.9–12.3 with 0.6 m jambs and a 7.2 m opening; crown B+4.24 (0.8 of the B+5.30 frame); spring B+2.25 → B+2.55 |
| Flanking blocks | None; the maroon frame ran into the cream main wall | Low maroon blocks at B+3.15 (about 0.6 of the frame): north a 12.3–15.3 carrying a small "600" at mid-height, south a 1.9–3.9 proud plus a 0.1–1.9 recessed low maroon wall |
| South block massing | Uniform B+5.05, dark roof | Low dark-roofed blocks either side, plus a higher passage roof (deck B+4.38, roof B+4.62, step walls to B+4.80). The step walls are inference, needed so the deck clears the crown. |
| Bollards | 8 at 1.1 m | 6 at 1.1 m with a 0.88 m clear centre gap on the narrower opening (r08 shows about 8; reduced for traversal) |
| Breeze-block screen | 6×20 shallow cells on light backs | 5×14 cells, 0.32 m near-square, 0.20 m deep, dark backs and mid-tone sides, at b 1.0–6.8 near the west entrance; larger badge high on the wall between joists |
| Lettering | Engine fallback font with offset copies, about 0.30 m caps | SystemFont "Arial Black/Helvetica Neue/Arial" weight 900, about 0.24 m caps, ×1.18 letter spacing; smaller "600"; fallback-font risk is noted |
| West face | 4 doors, flat paint, 5 cm pilasters, thin coping | 2 doors; deterministic low-contrast stucco grain plus plaster normal; textured plinth to B+0.90 with a cap ledge; 9 cm pilasters; 0.10 m coping with 0.11 m overhang and a shadow reglet; lighter, slightly reflective glass; warmer cream |
| East face | Even/odd door and window rhythm, dark posts, blank cream east frame | Varied bay pattern (door+window, pairs, double doors, louvre vents); light posts; proud east arch architrave ring; low east blocks with doors breaking up the plane |
| North band | Blue-grey | Paler, chalkier grey |
| Setting | None | Visual-only, non-colliding concrete apron (a 3.4–12.8, b −12.5…0.04), mulch strip with edging (b −3…0/0.30) and paths to the two west doors. All of it lies outside the building footprint but on the school site-area surface `w1043836449`, verified triangle-by-triangle. The coordinator requested it. |

## Fixes for mechanics review findings

- **F1:** corrected above.
- **F2:** the wall-stop check is now keyed on body name. In the final run, contact bodies were `Collision` (land) and `WallContact`, and the final contacts were WallContact (wall normal plus a pilaster edge). The deeper pilaster stopped the controller slide at a=39.10.
- **F3:** the north copings are inset 6 mm, and containment is now proved against the actual roof-record OSM polygon. Minimum margin is 3.3 mm and no vertex or letter bound falls outside.

## Round-2 runs

| Run | Exit | PID | Outcome |
|---|---|---|---|
| inv09-static | 1 | 86235 | HOLD: SE-most mulch corner (a 0.3) fell off the site-area surface; the strip now starts at a 1.5 |
| inv10-full | 0 | 86350 | All cases PASS; first round-2 pixels |
| inv11-static | 0 | 86877 | PASS on final source: 0 outside polygon, 0 outside site area, 0 winding, shared geometry exact (Wall 10506, Roof 1188, Detail 27318), 38 contacts seated |
| inv12-full | 0 | 86910 | PASS on final source |

All runs show slot released and an empty census. A final pgrep found no Godot process.

## Final round-2 mechanics (inv12-full)

- **Passage traverse:** west to east to (8.11, 21.45) and back to (8.09, −5.44) through the bollard centre gap. Both legs arrived on land only, with no recovery.
- **Walkway:** entry and exit pass.
- **West wall stop:** PASS on body-keyed contact.
- **Spray:** cream wall and maroon north low block both `placed`; glass `receiver_rejection`.
- **Final state:** safe final rest, every non-target body unchanged, original pair restored exactly. A/B camera drift was below 1 mm on all views.

## Final round-2 evidence (inv12-full/images)

| Capture | One-line assessment |
|---|---|
| **`gameplay-passage-west-B`** (portal, close) | Tall maroon frame with narrow jambs and a near-filling segmental arch, low flanking blocks, small "600", heavy letter-spaced lettering. The dark breeze-block grid and badge read through the arch, with the concrete apron and mulch strip in front. |
| **`gameplay-portal-B`** (portal, mid) | Same composition at sidewalk distance. The oak is existing world vegetation. |
| **`r07-portal-match-B`** (portal, matched) | Proportions match r07: a frame top above the cream parapet, and low blocks at about 0.6 of frame height. The breeze grid is visible inside. |
| `motion-spray-maroon-frame` | Close oblique of the portal with a stock tag on the north low block. |
| `r05`, `r12`, `r13` | West face: stucco grain, pilasters, plinth ledge, lighter glass, fewer doors. Cadence remains inference. |
| `r10-north-end-match-B` | Paler north band, light posts, "TRAINING" fascia, porch pier. |
| `gameplay-passage-east-B` | Cream east arch with proud architrave ring; low cream flanking blocks with doors break up the plane. |
| `gameplay-yard-east-B` | Varied walkway rhythm with double doors, louvres and light posts. |
| `aerial-*` (study camera) | White main roof, dark low/passage roofs, apron and mulch strip, walkway strip. |

## Not done (and why)

- **Recessed upper frame panel:** low priority. It would mean cutting a hole in the frame strips, and the evidence is a single r08 crop.
- **Remaining gap:** in the oblique r07 view, part of the cream step wall shows above the north low block, where r15 shows sky. The passage roof must clear the arch crown, so I lowered it rather than removing it.
- **Lettering font:** not verified in pixels that Arial Black itself resolved rather than another listed fallback; the glyphs render heavy and clean.
- **Bespoke trees:** deferred, per policy.

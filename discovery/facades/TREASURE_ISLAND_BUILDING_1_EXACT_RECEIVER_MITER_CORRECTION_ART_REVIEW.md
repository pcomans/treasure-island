# Treasure Island Building 1 shared-miter correction — independent art re-review

**Reviewer:** Independent art director (`/root/w34313515_art_director`)  
**Date:** 2026-08-30  
**Target:** `r16681702`; receiver `building:r16681702:wall`  
**Scope:** Only the prescribed detached shared-miter correction for `B1-MAT-IVORY` on exact outer runs `21..51`.  
**Independence:** I did not implement the correction or create the recapture.

## Decision

| Reviewed scope | Verdict | Exact lifecycle eligibility |
| --- | --- | --- |
| Corrected `B1-MAT-IVORY`, outer runs `21..51` | **ACCEPT_WITH_DOCUMENTED_LIMITATION** | **Eligible** to advance to live attachment / pending actual-world review for exactly the reviewed 31-run field scope. |
| Unchanged `FIT-CENTRAL-W-R36` | **ACCEPT_WITH_DOCUMENTED_LIMITATION** | Remains an accepted detached scale/contact fit study only. **No live placement authorization.** |
| Unchanged `FIT-PAV-W-R06` | **ACCEPT_WITH_DOCUMENTED_LIMITATION** | Remains an accepted detached scale/contact fit study only. **No live placement authorization.** |
| Corrected detached aggregate | **ACCEPT_WITH_DOCUMENTED_LIMITATION** | The field-only correction is accepted. Lifecycle may advance only the exact ivory field, not either module study. |

No further correction is required. The evidence is sufficient because the final generated geometry now proves identical bottom and top endpoints at every one of the `30` joins, the five distributed close samples include the review-identified sharp `38→39` turn, and the macro, ordinary, whole-building-context, and changed-light frames expose the complete curve without a crack, spike, fold, overlap, receiver intrusion, UV reset, or material regression. The maximum-miter `42→43` turn is numerically exact and remains visually clean in the complete-curve/context evidence.

## Correction closure

| Gate | Result | Finding |
| --- | --- | --- |
| Authorized before → after | **PASS** | Independent per-run normal offsets were replaced with one shared XZ offset-line miter at every internal join, exactly as prescribed by the prior review. |
| Complete join sequence | **PASS** | The manifest contains the ordered pairs `21→22` through `50→51`, with no missing or duplicate join. |
| Bottom endpoint equality | **PASS** | All `30/30` shared-miter bottom pairs measure exactly `0.0 m` after correction. |
| Top endpoint equality | **PASS** | All `30/30` shared-miter top pairs measure exactly `0.0 m` after correction. |
| `38→39` sharp join | **PASS** | Before-gap diagnostic `0.024815165 m`; after bottom/top gaps `0.0/0.0 m`; miter ratio `1.381826`. Image `03` shows a closed physical turn with no exposed host strip, spike, fold, or overlap. |
| `42→43` maximum miter | **PASS** | Before-gap diagnostic `0.026863545 m`; after bottom/top gaps `0.0/0.0 m`; miter ratio `1.501749`, length `0.027031488 m`. Complete-curve views show no miter spike, fold, overlap, or silhouette artifact. |
| Miter stability | **PASS** | Minimum denominator `0.665890098`; maximum perpendicular clearance residual `0.000020522 m` (`0.020522 mm`). This is well below a visible or receiver-intrusion threshold and does not break the shared endpoint. |
| UV phase | **PASS** | Maximum join phase delta remains `0.0 m`; cumulative chain-metre U and source-world-metre V are byte/record unchanged. No phase restart or material discontinuity appears. |
| Material identity / channels | **PASS_WITH_DOCUMENTED_LIMITATION** | Exact material and shader bytes remain unchanged. The warm-ivory matte field retains `1.10/0.32 m` scale, `0.82` roughness, `0.008` relief, `0.015` variation, and metallic `0`; these remain production assumptions rather than survey. |
| Topology | **PASS** | Before→after remains field `1 mesh / 1 surface / 124 vertices / 62 triangles`; aggregate `23 meshes / 23 surfaces / 326 triangles`. The correction changed vertex positions only. |
| Receiver clearance / isolation | **PASS** | The mitered field stays at the intended `0.018 m` outward clearance, detached as a sibling. Receiver children remain `2→2`; no collision, navigation, spray, accepted-material metadata, or runtime attachment changed. |
| Close visual continuity | **PASS** | Images `01..05` show distributed joins `21→22`, `30→31`, `38→39`, `45→46`, and `50→51` closed. Legitimate receiver corner shading remains, but the prior exposed strips do not. |
| Macro / ordinary continuity | **PASS** | Images `06` and `11` cover the full curve and ordinary gameplay read without a crack, miter protrusion, fold, overlap, macro stripe, or run-sized material reset. |
| Whole-building context | **PASS as regression evidence; BLOCKED as resemblance** | Image `13` shows no correction artifact across the public curve. It does not establish a completed elevation, corrected massing, or whole-building resemblance. |
| Changed-light continuity | **PASS** | Image `14` reveals normal receiver turns without reopening a gap or creating a false highlight. Material and CENTRAL hierarchy remain unchanged. |
| Overall corrected-field gate | **PASS — ACCEPT_WITH_DOCUMENTED_LIMITATION** | The prior physical-continuity failure is closed. Remaining limits are reference/lifecycle limits, not correction defects. |

Five joins are shown at close range while all 30 are visible collectively in complete-curve/context views and established exhaustively by the final-vertex equality record. A physical turn may still show a lighting edge; the acceptance criterion is absence of open space, protruding miter geometry, folds, overlaps, phase changes, or receiver intrusion, not removal of legitimate corner shading.

## Unchanged fit studies

The correction did not alter either module source, exact registry record, transform, scale, topology, or evidence status. Canonical comparison of the predecessor and correction manifests gives byte-identical `fit_studies` and `resolved_fit_studies` records.

| Study gate | `FIT-CENTRAL-W-R36` | `FIT-PAV-W-R06` |
| --- | --- | --- |
| Motif / source bytes | **PASS — unchanged** | **PASS — unchanged** |
| Resolved transform | **PASS — unchanged**: origin `(0.881625, 16.281000, 749.694397) m`, run `36`, along-run center `2.008051045 m`, wall offset `0.06 m` | **PASS — unchanged**: origin `(-56.492283, 14.453499, 709.845093) m`, run `6`, along-run center `5.511163693 m`, wall offset `0.06 m` |
| Module topology | **PASS — unchanged**: `9` meshes / `9` surfaces / `108` triangles | **PASS — unchanged**: `13` meshes / `13` surfaces / `156` triangles |
| Backing / field ownership | **PASS — unchanged** | **PASS — unchanged** |
| Close / oblique / ordinary / changed light | **PASS — no regression** | **PASS — no regression** |
| Real anchor / count / cadence / sequence | **BLOCKED** | **BLOCKED** |
| Re-review verdict | **ACCEPT_WITH_DOCUMENTED_LIMITATION** — fit study only | **ACCEPT_WITH_DOCUMENTED_LIMITATION** — fit study only |

The unchanged standalone source pins are registry `2014040edb3985be4aaae437749063474aacaedc0534b6d54e69b7dfd92612cc`, factory `cf18bfcfa40c7770d92aad569cba05da7ac85fe0fc89c0fd8cba6167ef62fb1f`, and scene `1d205d4d6e176d4ed1e82746d1f1f8c4c2547910b1a71f87a213d9ada14967ef`. The exact registry remains `10ab1f25d0f9d37ccbb20be9dfe77a37c66f63918b1fdf070c1de9c61633414a`.

## Lifecycle decision

Lifecycle may advance **only**:

- one `B1-MAT-IVORY` exact field on ordered outer runs `21..51`;
- exactly `31` runs, `85.939934 m`, and `1740.731069 m²` source-area semantics;
- the reviewed continuous chain-metre U / source-world-metre V projection;
- the unchanged reviewed material parameters and corrected shared-miter geometry;
- status: live attachment permitted, then **pending independent actual-world review**.

This is not live acceptance. Actual-world evidence must still prove correct run attachment, transform/geometry fidelity, ordinary gameplay continuity, no host bleed, no z-fight or intersection, material response, runtime isolation, and lifecycle truth.

`FIT-CENTRAL-W-R36` and `FIT-PAV-W-R06` may **not** advance to live placement. Their run midpoints remain mechanical fit-study anchors, not observed facade coordinates.

## Preserved blocked scope

- Any field run outside ordered outer runs `21..51`, including other sides, ambiguous `93..96`, inner ring, union sliver, and separate tower.
- Any actual CENTRAL or PAV anchor, coordinate, dimension, count, cadence, interval, flanking composition, sequence, additional exemplar, or live placement.
- Exact calibration or placement of `B1-WING-W`, `B1-BASE-O`, `B1-DOOR-BLUE`, and `B1-BAND`.
- Surveyed field scale, color, roughness, receiver dimensions, module dimensions, or coordinates.
- Entrance, canopy, emblems, repairs, edge trims, roofline, deep projections, and every omitted opening family.
- Completed public elevation, facade sequence, lower-wing/taller-pavilion massing correction, silhouette, complete facade, or whole-building resemblance.
- Any claim that the detached context frames are actual-world, gameplay, or lifecycle acceptance.

## Evidence integrity

The correction handoff hashes to `d7734a73e46d3d1003bd8984759eeb9d1e978c3b60a9fe30664035d827d1b7b7` and pins the prior review hash `7c1d4fed00fda41b35b8618565622712368504465c45ab4aa443e3460ab4e85b`. The correction ledger verifies **19/19** listed files and hashes to `0fc6f3d2d4c0edeac5f43a5b55210326e208b35facc4b7694899cd7fa2dfec7e`; `capture-manifest.json` hashes to `63ff0b15e9072b6894e78105a780c3aa401ac6ae58af37840dc501af939f1051`. All `15` listed captures are native Godot 4.7.2 Forward+/Metal `1440 × 900` PNGs whose bytes and hashes match both records.

| Evidence record | SHA-256 |
| --- | --- |
| `README.md` | `e6ebf8639ba089fece82eae64d8591f5f53d77ef6c97e95b0d77d652e1b272a8` |
| `capture-manifest.json` | `63ff0b15e9072b6894e78105a780c3aa401ac6ae58af37840dc501af939f1051` |
| `runtime-isolation.json` | `756861cbd4a17d48c591efb62fdca2106028df9bd14122bc4f14c9532dbe0479` |
| `visual-verification.json` | `36c746caca1d4d2208344cc73c0993ef8978ab306eb0d695cb15fa23d33b40e7` |
| `checksums.sha256` | `0fc6f3d2d4c0edeac5f43a5b55210326e208b35facc4b7694899cd7fa2dfec7e` |

| Native capture | SHA-256 |
| --- | --- |
| `01-field-join-21-22.png` | `67360459c022a2c643523a88de094f914742755162b9e856c35521a095c323e5` |
| `02-field-join-30-31.png` | `147a38e0ed2d1fc5dba6f1295027535c246318280f56db884b177651c898d91a` |
| `03-field-join-38-39.png` | `e11b8dd440708612f30ceb1602b18b354301e97139d067a086bc4faa6d89adc5` |
| `04-field-join-45-46.png` | `33685763c0e67e08d210df71d21bf4c5b68a733b9b55eb00a21caf0cf8d130db` |
| `05-field-join-50-51.png` | `284ffeb8433530047b4b864235ebcf1579a310e1a5eaa2c08d5358f6d379a354` |
| `06-field-macro-85m.png` | `e587f8a2ef4464132feb735d5985c731f80ac942a3c50769abedab0d2b0d0a62` |
| `07-central-close.png` | `650699348a20770a0b057b3e1e12a6e86741266cd9722fed663f4d1e21e78be0` |
| `08-central-oblique.png` | `7772827d15579eaee94c59e18250a324c64f1f42e566f84af0fa7792422bc47b` |
| `09-pavilion-close.png` | `623b38dbfb16c0340b55fa797a65bd4d4e1c921264c80e2d7d3609f861621fc0` |
| `10-pavilion-oblique.png` | `9ef73820384346ace6beacd26220994897459e54df7129a4cb0995f01de65b5c` |
| `11-central-ordinary.png` | `cd2bd63dea6c15d75cd240283763deb94d4c7d7fafeb528510c755c22cdb68ee` |
| `12-pavilion-ordinary.png` | `2cdf34dde54e7938fdafe4a6867e3640d05bf2ccbf4f9b284ceb08cff8ee6373` |
| `13-whole-building-context.png` | `0262a608bb4d3241a25d3364648ac0c11b0d5633ddc1767d93e703599a8fb51f` |
| `14-central-changed-light.png` | `99326bfc20bceffef2c675304990c65c88cfc8fdca0b1d54713c8e6188bd816c` |
| `15-pavilion-changed-light.png` | `16afc30b602d258a807df6841fcb8ddf7fc7d5d6e58e8e641514c569e585150d` |

No runtime, asset, registry, material, test, contract, harness, evidence, inventory, run mapping, or `r133351` file was changed by this review.

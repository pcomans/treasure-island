# Texture-reference research contract

Date checked: **2026-08-29**  
Worked example: **Hawkins, 77 Bruton Street, Treasure Island**  
Mode: web and local-reference research only; no third-party image was downloaded into the repository.

## Purpose

This document defines the research handoff that must precede a generated or sourced building-texture job. Its first job is to discover the **visual grammar that is allowed to repeat**: the full motifs, their order and scale, the smallest true period, and seam positions that cannot synthesize a new motif. The Hawkins example shows why this matters: a technically seamless bitmap can still be semantically non-tileable when partial windows on opposite edges join into a window type that does not exist in the reference.

The same method applies to cladding ribs, panels, bricks/blocks, windows, doors, vents, louvers, trim, bands, joints, stains, and other architectural motifs. It does not assume that a texture must contain windows, or that windows must always be geometry. It first classifies the intended output:

- **Homogeneous material tile:** local surface only; no architectural opening or unique panel layout.
- **Architectural pattern tile:** may contain openings or other motifs, but only when research proves a periodic cell and every repeated motif remains complete and correctly sequenced.
- **Module atlas/set:** discrete complete motifs for a façade assembler when several motif types or nonuniform sequences exist.
- **Unique elevation/mask:** a nonperiodic façade or one with important one-off placement; it must not be forced into a seamless tile.

Use four evidence labels throughout a job:

- **Verified fact:** stated by a primary project, government, architect, property, or manufacturer source.
- **Reference observation:** visible in an identified photo or render, but not necessarily a measured specification.
- **Production inference:** a reversible art/implementation interpretation made from the evidence.
- **Unknown:** not established; do not turn it into a precise prompt value or acceptance claim.

## Worked example: target identity

| Field | Hawkins result | Confidence and limitation |
|---|---|---|
| Public identity | Hawkins, 77 Bruton Street, San Francisco, CA 94130, at Treasure Island parcel/sub-block C2.2 | **High.** The official property site supplies the address; the architect and City sources identify Hawkins as C2.2. A Quarterra release spells the street “Burton” once, so it is not used for the address. |
| Frozen world identity | OSM way `w1249412093`, tags `building=apartments` and `name=Hawkins`; generated wall object `building:w1249412093:wall` | **Exact for this game snapshot.** The frozen OSM way has no address, level, height, façade, or material tags. |
| Building type/status | 178-unit apartment development; completed in 2025, with final occupancy in August 2025 | **High.** City official statement and architect page agree. |
| Reference-image identity | The owner photo at `/private/tmp/IMG_7170-reference.png` is treated as a private Hawkins context/elevation reference | **High but not survey-grade.** Its mid-rise massing and neighboring tower context agree with the public project descriptions. The photo is not a rectified elevation or measured material scan. |
| Owner-rejected result | The supplied close gameplay screenshot and local equivalent `/private/tmp/hawkins-selected-crop.png` show the window-bearing tile on the default short Hawkins mass | **Direct review evidence.** The original chat attachment was not copied into the repository. |

### Frozen OSM limitation

The authoritative horizontal-layout snapshot proves which game object is Hawkins, not what Hawkins looks like vertically. In `data/osm/treasure-island-2026-08-27.osm`, way `1249412093` contains only the five footprint nodes plus `building=apartments` and `name=Hawkins`. It cannot support the current default `6 m` height, two-story interpretation, any bay width, or any façade material claim.

## Source ledger

All web pages below were opened, not accepted from search-result snippets. Checked **2026-08-29**.

| ID | Authority and URL | Evidence used | What it does **not** establish |
|---|---|---|---|
| H01 | Mark Cavagnero Associates, [Hawkins Treasure Island](https://www.cavagnero.com/project/hawkins-treasure-island/) | Official architect project page: C2.2 identity, completed 2025, Lennar client, Mark Cavagnero architect and IwamotoScott associate architect; the cladding pattern was deliberately oriented so sunlight changes the appearance; main lobby faces the central cultural park; raised stoops occur on the western façade. | Exact panel product, panel pitch, paint color code, dimensions, roughness, or a complete façade elevation. |
| H02 | AIA East Bay, [2025 Design Awards nominees — Hawkins Treasure Island](https://aiaeb.org/congratulations-to-our-2025-design-awards-nominees/) | Project entry by Mark Cavagnero Associates with IwamotoScott: **asymmetric rainscreen cladding** with a **white pearlescent coating**, intended to change with dynamic island light. | Exact substrate, manufacturer, profile, rib pitch, PBR values, or weathering. |
| H03 | City and County of San Francisco, [2025 Treasure Island IRFD Preliminary Official Statement](https://media.api.sf.gov/documents/City__County_of_San_Francisco_IRFDNo.1_TIRB_Ser2025B_POS.pdf) | Government evidence: Hawkins is a six-story, 178-unit apartment development on C2.2, completed with final occupancy in August 2025. Relevant text appears at PDF pages 61 and 417 in the opened source. | Four-story sub-volume description, façade layout, cladding, window dimensions, or roof form. |
| H04 | Quarterra, [first move-ins announcement](https://www.prnewswire.com/news-releases/quarterra-multifamily-to-welcome-first-move-ins-at-hawkins-san-franciscos-newest-apartment-homes-on-treasure-island-302376149.html) | Developer/property-manager statement: a **six-story mid-rise plus four-story low-rise**, 1,500 square feet of street-level retail, landscaped central courtyard, roof terrace, and apartment windows intended to bring in abundant light. | Exact exterior dimensions or material system. The article's single “77 Burton” spelling conflicts with the official property address and is treated as a typo. |
| H05 | Hawkins official property site, [home](https://hawkinsti.com/) and [gallery](https://hawkinsti.com/gallery/) | Official operating-property identity and **77 Bruton St** address; current photographs are available as contextual references. | Architectural measurements or material specifications. Leasing imagery must not be mistaken for a rectified material scan. |
| H06 | DCI Engineers, [Hawkins Apartments](https://www.dci-engineers.com/work/hawkins-apartments) | Project structural engineer: six stories, 178 apartments, oversized windows on all levels, roof terrace and courtyard. | Its “Primary Material: Concrete” is a structural classification, **not** evidence that the visible rainscreen should look like concrete. |
| H07 | City/TIDA, [November 2023 bond report](https://www.sf.gov/sites/default/files/2023-11/110823%20Item%207%20Bonds_0.pdf) | Pre-completion design context: planned 70-foot, 178-unit podium building and roughly 1,550 square feet of retail. This provides a coarse height sanity check only. | As-built height, panel scale, bay width, or story height. “Planned” must remain attached to the 70-foot value. |
| H08 | SF YIMBY, [The Hawkins Opening on Treasure Island](https://sfyimby.com/2025/02/the-hawkins-opening-on-treasure-island-san-francisco.html) | Clearly labeled secondary field-photo source: four-story low-rise mass, grey daylight appearance, mix of plain and fluted panels, floor-to-ceiling windows, angular fourth-floor balcony features, and townhome-style stoops. | Manufacturer/product specification or authoritative dimensions. Its color wording is subordinate to H02's white pearlescent specification and the lighting context. |

### Manufacturer-source result

Research found a trade-partner social lead naming Morin by Kingspan and Griggs Systems, but no opened project-specific manufacturer case study or product sheet tied an exact Morin profile, rib pitch, or coating code to Hawkins. Search snippets are not evidence. The manufacturer/profile remains **unknown**, and generic Morin catalog dimensions must not be substituted as if they were Hawkins specifications.

## What the references actually show

### Verified architecture

- Hawkins is not a uniform two-story box. It combines a six-story mid-rise and a four-story low-rise, organized as articulated/interlocking volumes around a courtyard.
- The building has a street-level program and a differentiated arrival condition, not a wall texture that runs unchanged into the ground.
- The exterior uses asymmetric white-pearlescent rainscreen cladding whose directional pattern changes appearance under moving sunlight.
- Oversized glazing occurs throughout; the architect also calls out a glazed lobby, western stoops, and roof-level outdoor space.

### Observations from the owner's full reference and façade crop

The private full reference `/private/tmp/IMG_7170-reference.png` and crop `/private/tmp/IMG_7170-reference-facade-crop.png` show:

- a ground floor of smoother, darker grey wall fields and tall glazing, visually separated from the pearlescent/fluted upper cladding;
- five residential window rows above that base on the main six-story portions;
- tall, dark blue-grey glazed openings grouped into consistent **local** bay rhythms, with light spandrel/sill bands between floors;
- on the main left upper plane, adjacent exterior opening boxes remain broadly consistent in width and repeat as full motifs separated by broad fluted piers; the reference does not show a global alternating full-width/slit-width cadence there;
- genuinely narrower full openings occur in other recessed/connector or differently composed planes and retain complete jambs; they are separate local motif types, not permission to synthesize slit windows at every tile edge;
- multiple façade planes and height steps rather than one uninterrupted elevation;
- a flat parapet/roof edge, plus distinct rooftop terrace/pavilion and solar-canopy elements;
- fine, closely spaced vertical relief across upper solid wall fields—many ribs fit within one window bay, so the relief is material-scale rather than bay-scale;
- cladding that appears silver-grey in the photograph because of daylight and relief, consistent with the primary description of a white pearlescent finish rather than a uniformly grey diffuse paint.

These are observations from a perspective photograph. They support relative rhythm and category choices, not exact dimensions.

## General motif-repeat research method

Apply this sequence to any building texture, whether its motifs are openings, cladding, masonry, panels, vents, louvers, trim, joints, weathering, or a mixture:

1. **Partition regions.** Separate planes/zones when material, motif family, spacing, orientation, base/roof condition, or cadence changes. Periodicity is asserted per region, never for “the building” by default.
2. **Inventory full motifs.** Name every canonical type using its complete boundary. A brick, panel, opening, vent, trim member, mortar joint and stain are different motif classes. Do not name an edge fragment as a motif until its completed cross-edge form is proven.
3. **Record dimensions or ratios.** Prefer metres from drawings/manufacturer sources. Otherwise record crop-relative width/height, center-to-center pitch, gap, aspect ratio and a tolerance with `reference_observation`; never invent metres.
4. **Tokenize cadence.** Write the observed horizontal and vertical sequence, including gaps/joints when they are visually structural: for example `PANEL-A, JOINT, PANEL-B, JOINT` or `PIER, WINDOW-A, PIER`.
5. **Find the smallest true period.** A candidate cell must reproduce the same tokens and dimensions after translation. If no translation repeats the observed sequence, choose a module atlas or unique elevation instead of forcing a tile.
6. **Predeclare legal seams.** Prefer homogeneous fields or known unit boundaries. A motif-midline seam is legal only with a same-motif composition contract. Record forbidden seams before generation.
7. **Predict all edge products.** List what left+right, top+bottom and all four corner fragments will become. If any product is unnamed, resized, duplicated or deleted, the blueprint already fails.
8. **Run a tokenized `3×3`.** Count and label every center and cross-seam motif. Semantic passage precedes edge-pixel metrics, normal continuity, visual quality, physical scale and in-engine review.

A regular pixel lattice does not prove a regular architectural lattice. Conversely, a texture need not be perfectly uniform: an `A-B-C` panel sequence can tile if the whole `A-B-C` period is captured, whereas a crop of `A` plus unexplained halves of `B` can be visually seamless and semantically false.

## Repeat blueprint: Hawkins upper façade

### Region first, tile second

Hawkins does not present one globally periodic elevation. The reference must be segmented into visually coherent regions before a repeat is proposed:

| Region | Observed grammar | Periodicity verdict |
|---|---|---|
| Main left six-story upper plane | Regular rows of full tall window openings, usually read as paired/two-lite assemblies, separated by broad fine-fluted piers; five upper residential rows sit above the differentiated base. | **Piecewise periodic at coarse opening level.** A one-bay × one-upper-story cell is plausible for this plane if it contains one complete opening and its allocated surrounding pier/spandrel. Internal sash/curtain states are incidental, not canonical motifs. |
| Recessed connector/central planes | Narrower and darker stacks occur at volume joints/recesses, with a different wall background and cadence. | **Separate region.** Do not let a tile from the main plane create these by edge composition. Use a distinct complete module or measured sequence. |
| Other six-story upper plane | Full openings continue, but local widths/grouping and solid fields differ from the main left plane. | **Not proven to share the same smallest cell.** Survey separately before reuse. |
| Right low-rise plane | Sparse tall openings in broader wall fields, with different volume/roof relationships. | **Not the main-plane repeat.** Likely a short explicit sequence or separate tile/module set. |
| Ground floor/base | Taller glazing, doors/lobby conditions, smooth darker wall fields and landscape interfaces. | **Nonperiodic/zone-specific** for this purpose. |
| Roof/parapet/terraces | Parapet, terrace/pavilion, rails, solar canopy and other one-off skyline elements. | **Nonperiodic.** |

### Motif inventory for the main upper-plane worked example

| Motif ID | Kind | Full canonical motif | Dimensions/ratios established by evidence | Edge rule |
|---|---|---|---|---|
| `W-P` | Opening/window assembly | One complete tall rectangular exterior opening with complete charcoal head, sill and both jambs; commonly reads as two vertical glass lites. | Exact metres unknown. In the owner reference, adjacent main-plane exterior openings are broadly consistent in outer width and pitch. | Prefer fully inside the tile. A seam may cross it only at a verified symmetry/period line that reconstructs this same full motif with the same outer width; otherwise forbidden. |
| `W-N` | Narrow full opening | A genuinely narrow opening with its own complete head, sill and two jambs, located in a distinct local plane/sequence. | Exact metres and repeat sequence unknown. It is not established as an alternating neighbor of every `W-P`. | Must be authored as a full distinct motif; never synthesized from arbitrary edge fragments of `W-P`. |
| `P-F` | Solid field/pier | Fine-fluted pearlescent rainscreen between complete openings. | Broad enough in the reference to supply a homogeneous seam zone. Exact width unknown. | Preferred horizontal seam zone: the middle of an uninterrupted `P-F` field, away from jamb shadows and panel transitions. |
| `S-H` | Horizontal spandrel/band | Pale/light band separating vertically aligned full openings at a story boundary. | One per residential-story transition in the coarse grammar; exact height unknown. | Preferred vertical seam zone: the middle of a homogeneous band or adjacent uninterrupted cladding, not through glass/frame. |
| `R-C` | Recess/connector stack | Vertically darker recessed bay/connector associated with a mass joint. | Location-specific; not shown to repeat with every regular bay. | Exclude from the main-plane tile; use an explicit module/region. |

### Sequence and smallest defensible cell

For the main left upper plane, the coarse sequence is:

```text
horizontal: ... P-F | W-P | P-F | W-P | P-F ...
vertical:   ... S-H | W-P | S-H | W-P | S-H ...
```

This notation describes exterior opening boxes, not changing sash positions or curtains. The smallest **candidate** repeat cell is one full `W-P` bay by one upper residential story, with half of the neighboring homogeneous `P-F` allocation on each horizontal side and half of the homogeneous `S-H`/cladding allocation on each vertical side. It remains a candidate because no rectified as-built elevation or measured bay schedule was found. A safer first implementation is a complete one-bay module/atlas element whose placement cadence is explicit rather than relying on edge-composed windows.

There is **no proven whole-building period**. A tile derived from the left main plane must not be wrapped across connector planes, the other upper mass, the low-rise wing, the base, or roof.

### Legal and forbidden seam lines

Legal seam zones, in preference order:

1. Through the middle of a sufficiently wide homogeneous solid field such as `P-F`, with matching relief phase and no jamb shadow crossing either edge.
2. Through the middle of a homogeneous horizontal band such as `S-H`, with the entire window above/below contained in the cell.
3. Through the exact symmetry line of a motif only when both edge fragments are documented halves of the **same** canonical motif and the composed result has the reference width, frame count and cadence. This exception needs an explicit edge contract and a semantic repeat proof.

Forbidden seam lines:

- arbitrary cuts through glass, frames, doors, vents, panels, bricks/blocks, louvers, trim, stains, joints, or any other named motif;
- cuts that leave two unrelated partial motifs on opposite edges merely because their pixels join smoothly;
- cuts through a cast/baked jamb shadow or highlight that creates a dark/light stripe at every repeat;
- boundaries whose left+right or top+bottom composition produces a motif class absent from the inventory;
- boundaries that duplicate or delete a gap, joint, mortar course, panel reveal, trim member, or opening.

### Exact failure in candidate 01

The rejected `1024 × 1024` candidate contains:

- one complete central `W-P`, approximately `280 px` wide in the normalized image;
- one partial window fragment at the left edge and another at the right edge, approximately `55 px` each;
- on repetition, those fragments join into an approximately `110 px` narrow single window.

The borderless `3×3` therefore reads approximately:

```text
... invented narrow window | full paired window | invented narrow window | full paired window ...
```

That narrow edge-composed motif is only about `0.4×` the width of the full central opening and was never identified as the next motif in the surveyed main-plane sequence. It has smooth pixels and complete-looking jambs after tiling, but that makes the invention more deceptive, not more correct. Actual narrow Hawkins openings elsewhere are complete, location-specific `W-N` motifs in different planes; they do not authorize a global alternating `W-N, W-P` cadence.

The candidate's earlier description as “two bays” counted the cross-edge invention as a real bay. The correct semantic inventory is **one full bay plus two unvalidated fragments**. It fails before physical scale, massing, or material response are judged.

### Required `3×3` semantic repeat gate

The `3×3` proof must be evaluated as an architectural sequence, not only as pixels:

1. Draw or record the canonical motif inventory before looking at the candidate.
2. Enumerate every complete motif visible in the center tile and every motif completed across its four seams and four corners.
3. Reject if a seam creates a new motif class, changes a motif's width/height/aspect ratio beyond the researched bound, drops or duplicates a trim/joint/gap, or changes the researched token sequence.
4. Compare the center row/column token sequence with the reference region. A clean join with the wrong cadence is a fail.
5. Verify the left/right and top/bottom seam zones are among the predeclared legal zones.
6. Only after semantic passage, run pixel-edge metrics and inspect relief/albedo continuity. Numeric seamlessness cannot override a semantic failure.

For Hawkins candidate 01, step 2 identifies the invented cross-edge narrow window, so the proof fails immediately.

## Output-kind and asset-boundary decision

### Architectural pattern tile or module set

A Hawkins façade asset may include windows if the job explicitly requests an **architectural pattern tile** or **module set** rather than a homogeneous material tile. In that case:

- every opening, spandrel, trim member and solid-field allocation must be a complete canonical motif or a proven same-motif edge composition;
- the tile/module must be scoped to one surveyed façade region;
- a one-bay module is safer than a tile with partial edge windows;
- a different complete module or short explicit sequence is required for `W-N`, `R-C`, the low-rise plane, ground floor and roof zones;
- albedo-only flatness remains a visual limitation, but it is a separate gate from repeat correctness.

### Homogeneous material tile

If the target is the reusable pearlescent rainscreen material rather than a façade pattern, then windows and all other architectural motifs are excluded and the following section applies.

### Geometry, explicit façade modules, or unique masks

The following must **not** be baked into a generic tileable material:

- six-story and four-story massing, height steps, setbacks, interlocking volumes, courtyard voids, and building corners;
- ground-floor/podium/base height and color break;
- window openings, glass, mullions, frames, sills, and pale inter-story spandrels;
- distinct wide/paired and narrow window-module families, including their local grouping and floor alignment;
- glazed lobby, doors, street-level retail glazing, stoops, planters, balconies, angular balcony features, and entrances;
- parapet, roof slab/edge, terrace railing, rooftop pavilion, solar canopy, plant, and other skyline elements;
- deliberate alternation or orientation of plain versus fluted rainscreen fields when that pattern spans multiple panels or bays.

These belong in massing, repeated mesh/decal modules, a researched architectural pattern tile, material-slot assignment, or a façade-layout mask according to the chosen output kind. They must not be smuggled into a **homogeneous material tile**, and nonperiodic zones must not be forced into a global repeat.

### Tileable material only

The reusable material should describe only a locally homogeneous Hawkins wall surface:

| Property | Material-only brief | Evidence status |
|---|---|---|
| Surface | Coated metal rainscreen; make separate **fine-fluted/ribbed** and **plain** variants if both are needed. Keep seams/joints subordinate. | Rainscreen and asymmetric orientation verified by H01/H02; plain/fluted distinction supported by H08 and the owner photo. Exact panel system unknown. |
| Base color | White to very light warm-neutral/silver. It may read light silver-grey in ambient daylight but must not be a medium-grey plaster field. | White pearlescent coating verified by H02; photographic silver-grey is an observation. |
| Reflectance/roughness | Satin-coated metal with restrained broad response, not a mirror and not chalky plaster. A starting roughness band around `0.45–0.65` is a **production inference**, to be tuned in engine under ordinary daylight. | No measured PBR value exists. The prior `0.86` roughness suppresses much of the light-dependent cladding behavior described by the architect. |
| Relief | Fine directional vertical relief in normal/height response or modest geometry; avoid painting alternating dark/light ribs into albedo. | Directional/oriented cladding behavior verified; exact depth and pitch unknown. |
| Albedo variation | Very low-amplitude off-white/silver variation, no baked directional highlight, shadow, ambient occlusion, or reflected scenery. | Production interpretation of a clean coated surface whose appearance is lighting-dependent. |
| Roughness variation | Subtle panel-to-panel or micro-surface variation only; avoid a repeated story-height band. | Production inference. |
| Weathering | Clean/recent overall. If used, only restrained diffuse runoff or joint accumulation with no unique focal stain. | Completed in 2025; the owner photo reads clean. No measured weathering map exists. |
| Periodicity | Repeat at material/panel-relief scale. A material proof must not reveal a window-bay, floor, parapet, or whole-panel composition repeating. | Hard contract. |

### Material-only generation brief

> Seamless tileable **surface material only** for a contemporary exterior metal rainscreen: white pearlescent coated metal with fine, closely spaced vertical fluted relief; restrained off-white to light-silver albedo variation; clean recent construction; neutral shadowless capture; no baked lighting or reflected scene. No windows, glass, frames, mullions, spandrels, floor bands, doors, corners, podium, roofline, parapet, balcony, signage, or whole façade composition. The tile must remain plausible when repeated at a sub-window physical scale. Produce albedo and, if supported, a low-strength OpenGL normal plus roughness derived for the same surface—not unrelated borrowed maps.

This brief intentionally omits bay width and story height because those are module/geometry dimensions, not properties of the surface tile.

## Physical-scale evidence

| Scale fact | Status | Permitted use |
|---|---|---|
| Six stories | Verified by H03/H06 | Whole-building story-count gate. |
| Six-story mid-rise plus four-story low-rise | Verified by H04 | Major massing gate. |
| Planned maximum/building height of 70 feet (`21.34 m`) | Pre-completion City/TIDA evidence from H07 | Coarse sanity check. Dividing by six gives about `3.56 m/story` **including all gross-height effects**; it is not an as-built story-height specification. |
| Oversized or floor-to-ceiling glazing | Verified/secondary corroborated by H06/H08 | Window-module proportion and human-scale review, not tile scale. |
| Fine vertical relief, many repeats inside a bay | Owner-photo observation | Qualitative material-scale gate: relief must be much finer than a window or bay. |
| Exact rib pitch, panel width/depth, paint code | Unknown | Stop false precision; do not claim or lock these values without a project-specific drawing/manufacturer source or calibrated close-up. |
| Previous `3.0 m/story`, `3.8 m/bay`, `7.6 m × 6.0 m` bitmap repeat | Earlier experiment's implementation assumptions | **Not source evidence.** Do not carry them into the research brief or use them to validate resemblance. |

## Why the rejected window-bearing tile was conceptually wrong

The immediate failure is not that a façade texture can never contain windows. It is that this candidate's **claimed repeat unit was false**. The asset encoded one complete paired window and unrelated partial windows at both horizontal edges. Tiling those fragments invented a narrow slit-window motif and forced a global wide/narrow alternation absent from the surveyed main-plane cadence.

That creates six independent problems, in priority order:

1. **It invents a cross-edge motif.** Two smooth partial edges become a plausible-looking but unresearched slit window.
2. **It invents the sequence.** The bitmap imposes `narrow, wide, narrow, wide` everywhere instead of preserving the piecewise `full opening + solid pier` grammar of the selected reference plane.
3. **It misstates its contents.** “Two bays” counted the invented cross-edge motif. The source bitmap contains one full bay and two fragments.
4. **It couples unrelated scales.** Changing UV scale changes opening width, frame thickness, rib pitch, spandrel height and story count together.
5. **It flattens depth-bearing elements.** Windows, mullions, sills, recesses and spandrels become paint on one plane. This may be acceptable only as a deliberately stylized façade-pattern asset, never as proof of architectural depth.
6. **It cannot repair other building-level mismatches.** Height, major volume steps, base and roof remain separate resemblance gates, but they are downstream of the repeat-unit failure in this review.

The earlier seam gate answered only whether the opposite pixels matched. Its `3×3` proof was viewed aesthetically rather than parsed into motif tokens, so the edge-composed slit was praised as a “credible alternating rhythm.” The owner correctly rejected that logic: a clean invented rhythm is still invented. “Better than shared grey plaster” compared two placeholders and cannot override a wrong repeat blueprint.

## Hard mismatch gates for Hawkins

Any one of the following is a **reject**, even if tests pass and the result improves on grey plaster:

### Repeat blueprint and motif semantics

- No pre-generation motif inventory, region scope, token sequence, physical ratio/bound, repeat period, and legal seam-zone declaration exists.
- A left/right, top/bottom, or corner composition creates a motif class not present in the inventory.
- A candidate edge passes through an architectural motif without a documented same-motif edge contract.
- A partial window, door, vent, louver, panel, brick/block, trim member, joint, stain or other motif joins into a narrower/wider/doubled/deleted version at the seam.
- The `3×3` center row or column has a different token cadence from the selected reference region.
- A candidate claims `N` motifs per tile by counting cross-edge fragments before proving what those fragments form.
- A visually clean or low-error pixel seam is used to override a failed semantic repeat.

### Target and architecture

- The reviewed object is not frozen OSM `w1249412093` / generated `building:w1249412093:wall`.
- The visible main Hawkins mass reads as two stories or another materially wrong count instead of six.
- The four-story companion/step and major articulated volumes are absent where visible from the selected review angle.
- The ground floor is not visibly differentiated from the upper residential cladding.
- The roof/parapet silhouette is an unarticulated continuation of the wall.
- Window rhythm is uniformly alternated across unrelated façade planes instead of being region/module-aware.
- Windows, doors, balconies, or roof features are painted into a **homogeneous material tile**. An architectural pattern tile may contain researched complete periodic motifs, but it must be labeled and reviewed as that different asset kind.

### Material

- A candidate declared as `homogeneous_material_tile` contains any identifiable opening, trim, façade module, base, roofline, corner, plant, sky, ground, signage, or unique composition.
- A candidate declared as `architectural_pattern_tile` includes a motif absent from the researched inventory or a region-specific/unique feature inside the repeat.
- The upper wall reads as grey plaster/concrete rather than a light pearlescent metal rainscreen.
- Dark/light rib stripes are baked into albedo strongly enough to remain fixed as lighting changes.
- Relief is bay-scale/story-scale, or the tile creates a conspicuous floor/bay rhythm.
- Unique stains, highlights, reflections, panel edges, or four-way crosses expose the repeat.
- Albedo, normal, and roughness maps describe different source surfaces or use incompatible scale/orientation.

### Review evidence

- Acceptance is justified only by “better than the baseline,” a seam metric, a unit test, or a single isolated tile.
- The review omits a side-by-side selected reference-region crop at ordinary player height and distance.
- No borderless `3×3` semantic proof with annotated motif tokens exists; for a resemblance claim, no whole-building view proves story count, silhouette, base, roof, and regional rhythm separately.
- A value labeled “verified” is actually an inference, search snippet, generic manufacturer catalog value, or uncited guess.

## Reusable research output schema

The web-research phase of a texture skill should emit one machine-readable block equivalent to the following. Markdown prose may accompany it, but downstream generation should consume only this normalized handoff.

```yaml
schema_version: codex.texture-reference-research/1
job:
  job_id: string
  checked_date: YYYY-MM-DD
  intended_use: string
  target_asset_kind: homogeneous_material_tile | architectural_pattern_tile | module_atlas | unique_elevation | decal

target:
  canonical_name: string
  address_or_location: string | null
  local_object_ids: [string]
  identity_confidence: high | medium | low
  identity_evidence:
    - source_id: string
      fact: string
  identity_conflicts:
    - claim: string
      resolution: string

sources:
  - id: string
    authority: owner_reference | government | architect | developer | property | manufacturer | secondary
    url_or_local_path: string
    checked_date: YYYY-MM-DD
    page_or_section: string | null
    supports: [string]
    does_not_support: [string]
    image_reuse_permission: not_needed | owner_private | unknown | permitted
    stored_in_repo: false

reference_roles:
  - id: string
    source_id: string
    role: identity_context | massing | pattern_region | cadence_seams | facade_layout | material_surface | scale | rejection_example
    crop_scope: string
    contains_architecture: true | false
    allowed_for_generation_input: true | false
    privacy_or_license_note: string

verified_architecture:
  story_count: string | null
  major_massing: [string]
  facade_bays: [string]
  ground_floor_or_podium: [string]
  roof_or_parapet: [string]

pattern_regions:
  - region_id: string
    description: string
    source_ids: [string]
    local_scope: string
    periodicity: verified_periodic | candidate_periodic | nonperiodic | unknown
    must_not_share_tile_with: [string]

motif_inventory:
  - motif_id: string
    name: string
    kind: cladding_rib | panel | masonry_unit | opening | door | vent | louver | trim | band | joint | stain | other
    canonical_full_description: string
    source_ids: [string]
    dimensions_m:
      width: number | null
      height: number | null
    dimensions_in_reference:
      width_px: number | null
      height_px: number | null
      crop_width_px: number | null
      crop_height_px: number | null
    ratios:
      width_to_period: number | null
      height_to_period: number | null
      tolerance: string | null
    evidence_status: verified_fact | reference_observation | production_inference | unknown
    may_cross_edge: true | false
    edge_composition_contract: string | null

motif_sequences:
  - region_id: string
    axis: horizontal | vertical | two_dimensional
    token_sequence: string
    cadence_description: string
    source_ids: [string]
    evidence_status: verified_fact | reference_observation | production_inference | unknown

crop_boundary_plan:
  source_reference_id: string
  rectified_or_perspective: rectified | perspective
  boundaries:
    left:
      position: string
      zone_type: homogeneous_field | unit_boundary | exact_motif_midline | forbidden
      motifs_crossed: [string]
      justification: string
    right:
      position: string
      zone_type: homogeneous_field | unit_boundary | exact_motif_midline | forbidden
      motifs_crossed: [string]
      justification: string
    top:
      position: string
      zone_type: homogeneous_field | unit_boundary | exact_motif_midline | forbidden
      motifs_crossed: [string]
      justification: string
    bottom:
      position: string
      zone_type: homogeneous_field | unit_boundary | exact_motif_midline | forbidden
      motifs_crossed: [string]
      justification: string

repeat_blueprint:
  region_id: string
  smallest_cell_status: verified | candidate | none | unknown
  period_tokens_horizontal: string | null
  period_tokens_vertical: string | null
  period_m:
    x: number | null
    y: number | null
  cell_contents_full_motifs: [string]
  edge_fragments:
    left:
      - source_motif_id: string
        fraction_and_side: string
    right:
      - source_motif_id: string
        fraction_and_side: string
    top:
      - source_motif_id: string
        fraction_and_side: string
    bottom:
      - source_motif_id: string
        fraction_and_side: string
  edge_compositions_expected:
    left_plus_right: [string]
    top_plus_bottom: [string]
    corners: [string]
  legal_seam_zones:
    - axis: horizontal | vertical
      zone: string
      evidence: string
  forbidden_seam_zones: [string]
  fallback_if_not_proven: homogeneous_material_tile | module_atlas | unique_elevation

material_brief:
  surface_family: string
  base_color: string
  finish: string
  relief_direction_and_frequency: string
  roughness: string
  variation: string
  weathering: string
  maps_requested: [albedo, normal_gl, roughness]
  maps_forbidden: [string]
  tile_scale_status: verified | bounded | unknown
  tile_scale_m: number | null
  evidence_labels:
    surface_family: verified_fact | reference_observation | production_inference | unknown
    base_color: verified_fact | reference_observation | production_inference | unknown
    roughness: verified_fact | reference_observation | production_inference | unknown

excluded_architectural_features:
  - feature: string
    owner: geometry | facade_module | decal | material_assignment
    reason: string

physical_scale:
  - fact: string
    value: string
    status: verified_fact | reference_observation | production_inference | unknown
    source_id: string | null
    permitted_use: string

uncertainty:
  - unknown: string
    impact: string
    safe_fallback: string
    stop_if_required: true | false

hard_mismatch_gates:
  - id: string
    scope: identity | repeat | geometry | module | material | evidence
    reject_if: string
    proof_required: string

semantic_repeat_proof:
  layout: 3x3_borderless
  center_tile_motifs: [string]
  cross_left_right_motifs: [string]
  cross_top_bottom_motifs: [string]
  cross_corner_motifs: [string]
  reference_sequence: string
  observed_sequence: string
  new_motif_classes_created: [string]
  duplicated_or_missing_motifs: [string]
  ratio_violations: [string]
  legal_seams_only: true | false
  verdict: pass | fail

research_verdict:
  ready_for_material_generation: true | false
  ready_for_pattern_generation: true | false
  ready_for_geometry_or_module_work: true | false
  recommended_output_kind: homogeneous_material_tile | architectural_pattern_tile | module_atlas | unique_elevation | null
  blockers: [string]
```

### Required reference-role split

For every job, require at least these roles even if one source supplies several crops:

1. **Identity/context:** proves the correct real target and local object.
2. **Massing:** proves story count, silhouette, large volume changes, and roof.
3. **Pattern region:** selects one coherent plane/zone and inventories every complete motif visible there; it must not mix a main plane, connector, base and roof into one supposed period.
4. **Cadence/seams:** shows enough adjacent motifs in both axes to derive a token sequence, smallest period and legal seam zones. A single motif close-up cannot prove periodicity.
5. **Material surface:** contains only a locally homogeneous surface patch for a `homogeneous_material_tile`. For an `architectural_pattern_tile`, generation input may instead contain the full researched repeat region, but never unexplained partial edge motifs.
6. **Scale:** supplies measured dimensions or defensible ratios/bounds. If none exists, the schema must say `unknown` rather than invent one.
7. **Rejection example:** records the failed result and the exact mismatch, including the tokens created across each seam, so a later reviewer cannot re-accept it under a narrower rubric.

## Hawkins research verdict

- **Ready for homogeneous material generation:** **Yes**, for separate plain and fine-fluted white-pearlescent rainscreen surfaces, provided the input/prompt contains no architectural motifs and scale remains explicitly unverified until calibrated.
- **Ready for a main-plane architectural pattern prototype:** **Conditionally yes**, as a one-complete-bay module or a one-bay × one-story candidate tile with seams placed in homogeneous pier/spandrel zones. The full motif must remain inside the cell unless a same-motif edge contract is proved.
- **Ready to reuse one tile over all Hawkins walls:** **No.** The reference is piecewise periodic; connectors, other planes, low-rise, base and roof have different or nonperiodic grammar.
- **Rejected candidate 01:** **Semantic fail.** Its horizontal edges compose an unresearched narrow window and change the cadence to alternating narrow/wide motifs.
- **Ready for a whole-building resemblance claim:** **No.** Correct repeat grammar is necessary but does not by itself repair building-level appearance.
- **Absolute repeat gate:** no new, resized, duplicated or deleted architectural motif in a tokenized borderless `3×3`, regardless of pixel seam score.
- **Absolute whole-building art gate:** recognizable Hawkins at ordinary play distance against the owner reference, not merely an improvement over grey boxes.

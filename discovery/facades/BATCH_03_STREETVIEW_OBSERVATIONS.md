# Batch 03 facade cohort — official Google Street View observations

Checked: **2026-08-29**  
Mode: **observation-only evidence handoff**  
Targets: Harvey Milk Administration (w34313513), Naval Station Treasure Island (w34313544), Personnel Support Detachment (r133347), Fire Training Facility Building 600 (w34313548), Fire Station 48 (w764313741), Job Corps Food Service Building 368 (w34313521), Education Center Building 29A (w109905031), and Advanced Culinary Dormitory (w34313514)

## Evidence and use boundary

- Facade observations use only panoramas whose Google Maps UI identified **Google Street View** and displayed an image-capture month/year.
- Exact identity, footprint, receiver, generated height, and orientation groups come from discovery/FACADE_RECEIVER_INVENTORY.json and the frozen OSM snapshot. Those project sources do not prove appearance or current condition.
- Google Maps place and coverage results were used only for navigation and identity reconciliation. Contributor profiles, photo paths, photo spheres, interiors, ordinary place photos, and third-party imagery were excluded.
- Google imagery was viewed transiently in the existing Chrome UI. No image, crop, screenshot artifact, download, copied pixels, redistribution, upload, or repository asset was retained.
- Labels are strict: visible fact is directly visible in an identified official panorama; mapping inference joins a viewpoint to the frozen footprint/orientation; production inference is a reversible facade-asset proposal; unknown is not supported for authoring.
- A Google panorama showing an occluder does not prove the hidden facade. A direct request returning “No Street View imagery available here” is a coverage result, not appearance evidence.
- Orientation-family mapping is not an exact generated-run endpoint map. No unique elevation or module placement is integration-ready until its observed extent is reconciled to exact receiver runs.
- Nothing here authorizes or prescribes a change to stories, height, roof profile, footprint, silhouette, topology, collision, spray behavior, terrain, foundations, navigation, or generated source data.

## Official panorama and coverage ledger

The URLs below are the exact Google Maps API requests used. Successful rows record the panorama ID and actual viewpoint exposed by Google Maps. Failed rows deliberately have no panorama ID, actual viewpoint, or capture date.

### Harvey Milk Memorial Administration Building — w34313513, 655 Avenue H

| ID | Exact request URL | Result |
|---|---|---|
| HMA-NO01 | https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82178,-122.36915&heading=150&pitch=0&fov=80 | No Street View imagery available at the footprint request. |
| HMA-NO02 | https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82165,-122.36830&heading=300&pitch=0&fov=85 | No Street View imagery available at the nearest 4th Street/Avenue H frontage request. |

Google Maps coverage mode at https://www.google.com/maps/@37.82178,-122.36915,20z showed no official Street View road line on the target frontage. A distant view from the nearest official corridor could not be reconciled to this footprint and was excluded.

### Naval Station Treasure Island — w34313544, 450 4th Street

| ID | Exact request URL | Result |
|---|---|---|
| NSTI-NO01 | https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82075,-122.37045&heading=60&pitch=0&fov=85 | No Street View imagery available at the 4th Street frontage request. |

Google Maps coverage mode for the southern campus showed no official Street View line on this frontage. Distant official-road context did not expose a target-identifiable elevation.

### Treasure Island Personnel Support Detachment — r133347, 550 4th Street

| ID | Exact request URL | Resolved panorama / actual viewpoint | Displayed capture | Direction and usable coverage |
|---|---|---|---|---|
| PSD-SV01 | https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82145,-122.36730&heading=255&pitch=0&fov=75 | GAuBhldmLlZOQwXj8qav3w; 37.82138,-122.3674429 | **June 2021** | east of the footprint, looking west (255°); broad E-facing elevation, lower portion partly fenced and landscaped |
| PSD-SV02 | https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82170,-122.36815&heading=205&pitch=0&fov=80 | _rk3B0PasMLUEPCQCA_sJw; 37.8219027,-122.3677643 | **September 2025** | north/northeast approach, looking southwest (205°); N-facing elevation and east corner, with construction fence and vegetation |

### Fire Training Facility Building 600 — w34313548, 750 Avenue M

| ID | Exact request URL | Resolved panorama / actual viewpoint | Displayed capture | Direction and usable coverage |
|---|---|---|---|---|
| B600-SV01 | https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8262806,-122.3677375&heading=25&pitch=0&fov=75 | ifdNQ-gh7K1ryx3rVMvW2w; 37.8262806,-122.3677375 | **September 2025** | south/southwest approach, looking north-northeast (25°); unique south entry portal and the beginning of the WSW long side |
| B600-SV02 | https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82672,-122.36800&heading=80&pitch=0&fov=75 | t8V4SOhQFPRXL_vukoMRog; 37.8267255,-122.3679894 | **September 2025** | west of the footprint, looking east (80°); WSW long side, heavily tree-occluded |

### San Francisco Fire Station 48 — w764313741

| ID | Exact request URL | Resolved panorama / actual viewpoint | Displayed capture | Direction and usable coverage |
|---|---|---|---|---|
| FS48-SV01 | https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82750,-122.36945&heading=180&pitch=0&fov=75 | UQGBH77cFgLZE2Utr1MI4Q; 37.8274909,-122.3694629 | **May 2019** | north of the footprint, looking south (180°); NNW-facing side/service-yard context behind fence and vehicles |
| FS48-SV02 | https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82712,-122.36979&heading=125&pitch=0&fov=70 | U1HtZQlUKomn07I4TT93ug; 37.8271222,-122.3698007 | **September 2025** | west/northwest on Avenue I, looking southeast (125°); WSW-facing side and NNW corner behind fence and parked vehicles |

### Job Corps Food Service Building 368 — w34313521, 575 Avenue D

| ID | Exact request URL | Result |
|---|---|---|
| B368-NO01 | https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82220,-122.37140&heading=270&pitch=0&fov=75 | No Street View imagery available at the Avenue D request. |
| B368-NO02 | https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8221941,-122.3730943&heading=65&pitch=0&fov=75 | No official Street View panorama returned at the Seven Seas Avenue request. |

Coverage mode exposed a July 2023 TyFlow io contributor path at 37.8221758,-122.3730929, panorama CIHM0ogKEICAgICpvKnjkAE (type !1e10). It was explicitly excluded and supports no claim below.

### Education Center Building 29A — w109905031, 550 Avenue H

| ID | Exact request URL | Resolved panorama / actual viewpoint | Displayed capture | Direction and usable coverage |
|---|---|---|---|---|
| EC29A-SV01 | https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82468,-122.36890&heading=150&pitch=0&fov=75 | o96ZjQzRGjybIV2jQd6hDw; 37.8246956,-122.3689247 | **March 2025** | north of the footprint, looking southeast (150°); NNW-facing side is hidden by full-height storage containers and fence |
| EC29A-SV02 | https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82452,-122.36925&heading=100&pitch=0&fov=75 | emqMw-XLaeQ03pPhEs3v-Q; 37.8245475,-122.3692554 | **March 2025** | west/northwest approach, looking east (100°); WSW/NNW corner area is hidden by the same container wall |

### Advanced Culinary Dormitory — w34313514, 487–489 4th Street

| ID | Exact request URL | Result |
|---|---|---|
| ACD-NO01 | https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82105,-122.36975&heading=330&pitch=0&fov=75 | No Street View imagery available at the 4th Street frontage request. |

Coverage mode showed no official road line on the target frontage. Distant context from the nearest official corridor did not establish current identity or appearance.

## Harvey Milk Memorial Administration Building observations

Exact receiver: building:w34313513:wall; 50 exterior wall segments / 276.468 m; generated from a 9 m height and two frozen OSM levels.

### Identity, coverage, and visible facts

- Identity confidence is **high for the frozen source-to-receiver join** and **low for current visual identity**, because no official target elevation was available.
- Observed sides: none. Unobserved sides: all ENE, SSE/returns, WSW, and NNW orientation families.
- No facade material, color/value, story cadence, window, door, canopy, band, rib, roof edge, ground opening, signage, or weathering fact is established.
- The nearest official panorama was too distant and compositionally ambiguous to identify the target. It was not used as facade evidence.
- Story/massing conflict evidence: none. The frozen 9 m/two-level rule remains project geometry data only and was neither confirmed nor contradicted by the bounded pass.

### Modules, seams, and confidence

- Candidate complete modules: **none**. No target-specific homogeneous material is evidence-backed either.
- Legal facade seams: **none established** beyond a future homogeneous-field seam that would first require material evidence.
- Forbidden use: generated segment U resets must not be treated as architectural joints; do not place or repeat unobserved windows, doors, memorial lettering, canopies, bands, entrances, ribs, or roof trim.
- Must not invent: a civic/administration style from the name, a Job Corps family from nearby buildings, a two-row window grid from the frozen level count, or a facade copied from Personnel Support.
- Research verdict: **blocked for target-specific facade authoring by absent official public-elevation evidence**.

## Naval Station Treasure Island observations

Exact receiver: building:w34313544:wall; 31 exterior wall segments / 188.865 m; generated from a frozen 7 m height with no level count.

### Identity, coverage, and visible facts

- Identity confidence is **high for the frozen source-to-receiver join** and **low for current visual identity**. The Google coverage pass did not expose a target-identifiable elevation.
- Observed sides: none. Unobserved sides: the complete irregular ENE, SSE, WSW/returns, and NNW orientation families.
- No facade material hierarchy, color/value, story cadence, openings, canopy, band, rib, roof edge, ground opening, signage, or condition is established.
- Story/massing conflict evidence: none. The generated 7 m height is not visually validated.

### Modules, seams, and confidence

- Candidate complete modules: **none**.
- Legal facade seams: **none established**.
- Forbidden use: do not derive naval, historic, institutional, or administrative motifs from the name or Wikidata tag; do not convert generated wall-run boundaries into joints or window bays.
- Must not invent: an entrance, symmetrical composition, military signage, brick or stucco substrate, apparatus/loading doors, repeated windows, roof coping, or similarity to Personnel Support.
- Research verdict: **blocked for target-specific facade authoring by absent official public-elevation evidence**.

## Treasure Island Personnel Support Detachment observations

Exact receiver: building:r133347:wall; 28 exterior wall segments / 250.796 m; relation-derived footprint generated from two frozen OSM levels (6 m). The east-facing families are 79.9°/80.8° and the north-facing families are 349.9°/350.9°. Exact member endpoints remain unreconciled.

### Identity, coverage, and visible facts

- Identity confidence is **high**: both official viewpoints, the exact local footprint, and Google road labels align. The frozen building=abandoned tag is not a current-condition claim.
- Observed coverage: a broad east-facing elevation in June 2021 and the north-facing elevation/east corner in September 2025. South and west elevations, inner-courtyard faces, entrance sides, and exact run endpoints remain unobserved.
- Visible material hierarchy: a dense near-charcoal structural/mullion grid dominates. Within it are cool gray/blue-gray glazing, near-black opaque lower panels, and aged muted gray-tan opaque or shadowed fields. Exact substrate and curtain-wall construction are unknown.
- The elevation reads as two occupied facade tiers beneath a thin dark projecting roof edge: an upper shallow transom/clerestory row and a taller lower rectangular window/panel row. Some panes/openings appear dark, missing, or broken in the 2021 view; the exact damage state is not a reusable motif.
- Strong narrow vertical piers/mullions create a regular bay rhythm, but individual infill types vary and no single global repeat cell is proven.
- The base is mostly dark and heavily obscured by fence, vegetation, and yard elements. No complete entrance or ground door was established.
- A rectangular rooftop screened/louvered equipment volume is visible in June 2021. Its height, depth, and placement are geometry-owned and not a facade motif.
- No projecting canopy, decorative belt band, masonry course, or ribbed material was established. The top transom line and roof edge are the only continuous horizontal registers clearly visible.
- Story/massing conflict evidence: the two visible tiers are compatible with the frozen two-level tag, but perspective and opaque infill do not verify a 6 m height. The rooftop screen and projecting eave are silhouette/geometry evidence only.

### Candidate complete modules (production inference)

- PSD-VBAY: one complete vertical grid bay from dark base through lower infill and upper transom, including both bounding mullions. Its alternate infill states must be cataloged before use.
- PSD-OPAQUE-BAY: one complete opaque-panel bay with full grid surround, only if a closer source proves panel boundaries.
- PSD-TRANSOM: one complete upper transom cell with its full frame. It must not be tiled independently of the vertical bay cadence.
- No damaged/broken opening is a canonical module. The rooftop screen is not a facade module.

### Seam contract, confidence, and must-not-invent details

- Legal seams are limited to uninterrupted opaque field or a verified complete outer grid-bay boundary.
- Forbidden seams include every generated U reset and any cut through a mullion, transom, glazing pane, opaque infill panel, dark base, roof edge, corner, damaged opening, potential door, or rooftop screen.
- East and north material hierarchy and grid cadence: **medium-high confidence**. Exact infill schedule, pane construction, door locations, material products, dimensions, south/west/courtyard vocabulary, and run endpoints: **unknown**.
- Do not regularize broken/dark panes into a pattern, invent an entrance, assume every bay is glazed, wrap one side's phase around a corner, or copy this language to the Harvey Milk/Naval Station targets.
- Readiness: conservative dark grid/material research and complete-bay specification are plausible; unique placement is blocked by endpoint and infill-sequence reconciliation.

## Fire Training Facility Building 600 observations

Exact receiver: building:w34313548:wall; 24 exterior wall segments / 243.359 m; generated from a frozen 6 m height. The WSW long-side family is 242.9° and the SSE end family is 152.9°.

### Identity, coverage, and visible facts

- Identity confidence is **high**: the official UI displayed 750 Avenue M, the south portal is marked 600, and its large lettering reads SFFD FIRE FIGHTING SCHOOL.
- Observed coverage: the south/SSE entrance end and most of the WSW long side in September 2025. Mature pines and palms obscure much of the long wall and ground line. ENE long side and NNW end are unobserved.
- Dominant wall field is warm light cream to pale gray with a coarse mineral/block-like appearance. Exact concrete block, stucco, paint, or aggregate construction is unknown.
- The long side presents one occupied row of medium horizontal rectangular windows with cool muted blue-gray glazing and pale surrounds. Tree trunks/crowns interrupt the schedule, so no exact bay count or period is defensible.
- The exceptional south entry is a saturated dark-red arched drive-through portal/canopy with large pale lettering. Its underside appears dark and finely ribbed or slatted. Heavy light-gray bollards stand across the opening, and a red vertical pier/entry element carries the number 600.
- The portal opening, canopy depth, arch, columns, bollards, and equipment visible beyond are geometry or prop ownership, not a flat texture pattern.
- The ordinary long wall has a thin flat/dark roof-edge line. No decorative belt band or repeating wall rib was established.
- Doors outside the portal are hidden or too ambiguous. The observed ground line is interrupted by parked vehicles, trees, and landscaping.
- Story/massing conflict evidence: the ordinary wing reads as one low occupied level plus a much taller unique portal. The frozen 6 m height and absent level count are not verified; the unique portal is a real silhouette/depth condition that the uniform receiver does not express. This observation does not authorize a massing change.

### Candidate complete modules (production inference)

- B600-WIN: one complete horizontal window with full pale surround and enough coarse wall field to protect the opening boundary. Physical width and spacing remain unknown.
- B600-SOLID: one complete uninterrupted pale coarse-wall bay between windows, only where a full bay is visible.
- B600-PORTAL: the entire red arch/lettering/600/opening composition as a unique south-elevation region. It is not a tile; depth and shape remain geometry-owned.
- A homogeneous pale coarse-wall material is a candidate, but its physical texture scale requires non-panorama calibration.

### Seam contract, confidence, and must-not-invent details

- Legal seams are within uninterrupted pale wall field, or at a verified full outer edge of a complete window module.
- Forbidden seams include generated U resets and cuts through a window/frame, red portal, arch, lettering, number 600, opening, dark underside, bollard, roof edge, corner, or tree-occluded bay.
- South portal hierarchy: **high confidence**. WSW wall material and window family: **medium confidence** because of foliage. Exact spacing, window count, substrate, ENE/NNW schedules, and run endpoints: **unknown**.
- Do not turn the arched entry into a shallow painted motif, repeat it on another side, guess letters hidden by perspective, create doors behind foliage, or infer a fire-family match with Station 48.
- Readiness: a homogeneous pale field and one complete window family are research-ready; the unique entry remains geometry-dependent and exact placement-blocked.

## San Francisco Fire Station 48 observations

Exact receiver: building:w764313741:wall; 26 exterior wall segments / 187.957 m; generated from the default 6 m fallback with no frozen height or level tag. The NNW families are 332.3°/332.4° and the WSW family is 242.3°.

### Identity, coverage, and visible facts

- Identity confidence is **high for the footprint/place reconciliation**: Google Maps' Fire Station 48 place pin aligns with the exact local footprint, even though the frozen source lacks a street address.
- Observed coverage: NNW-facing side/service yard in May 2019 and WSW-facing side/NNW corner from Avenue I in September 2025. Vehicles, chain-link/privacy fence, containers, and yard equipment obscure most ground-level openings. SSE and ENE sides are unobserved.
- The visible building reads as one low occupied level with a flat or very shallow roof behind a thin parapet/edge.
- Dominant visible wall value is light muted sage-gray to pale warm gray. Exact stucco, painted block, panel, or siding substrate is not distinguishable at the available distance.
- Small horizontal rectangular windows/openings sit high in the wall, with dark cool glazing/voids and pale surrounds. Broad areas between them are solid.
- Faint vertical wall divisions/pilaster-like lines occur, but the evidence does not prove a repeating panel product or measured period.
- No complete apparatus bay, garage door, public entrance, station number sign, canopy, decorative band, or lower opening was defensibly visible. Fire-station typology is not evidence for those missing features.
- Story/massing conflict evidence: the visible form reads as one story, while the runtime uses a default 6 m fallback and has no level tag. This is a weak visual conflict/unknown, not a basis for a height change.

### Candidate complete modules (production inference)

- FS48-HWIN: one complete small high rectangular window with full pale surround.
- FS48-SOLID: one complete uninterrupted pale wall bay.
- A homogeneous light sage-gray/pale gray material is a candidate only after substrate and scale are established.
- Apparatus doors, public entry, signage, and service doors are **not candidate modules** from this pass.

### Seam contract, confidence, and must-not-invent details

- Legal seams are within uninterrupted pale wall field or at a verified full control-joint/bay boundary after closer evidence.
- Forbidden seams include generated U resets and cuts through any high window, frame, inferred control joint, parapet, corner, occluded door/bay, fence line, or attached volume.
- One-story value hierarchy and high-window family: **medium confidence**. Exact material, cadence, lower openings, apparatus side, signage, other elevations, height, and run endpoints: **unknown**.
- Do not copy Building 600's cream/red portal language, invent red trim, create garage doors from building use, repeat high windows through occluded bays, or force a 6 m two-tier texture.
- Readiness: a restrained pale field/high-window research family is plausible; placement and all operational openings remain blocked.

## Job Corps Food Service Building 368 observations

Exact receiver: building:w34313521:wall; 36 exterior wall segments / 352.795 m; generated from a frozen 6 m height with no level tag.

### Identity, coverage, and visible facts

- Identity confidence is **high for the frozen source-to-receiver join** and **unverified visually**.
- Observed official sides: none. Unobserved sides: all ENE, SSE, WSW, and NNW families.
- The Avenue D request returned no official coverage. The only image path exposed from Seven Seas Avenue was a named contributor's July 2023 path and was excluded before making facade claims.
- Therefore no material hierarchy, color/value, story cadence, window, door, canopy, band, rib, roof edge, ground opening, restaurant/service opening, signage, or weathering fact is established.
- Story/massing conflict evidence: none. The frozen 6 m height is not visually validated.

### Modules, seams, and confidence

- Candidate complete modules: **none**.
- Legal facade seams: **none established**.
- Forbidden use: do not transcribe or paraphrase the excluded contributor imagery; do not infer dining windows, kitchen vents, loading doors, service canopies, or Job Corps branding from the name/use.
- Do not reuse Harvey Milk, Education Center, or other Job Corps facade language without independent observation.
- Research verdict: **blocked for target-specific facade authoring by absent approved official elevation evidence**.

## Education Center Building 29A observations

Exact receiver: building:w109905031:wall; 16 exterior wall segments / 166.314 m; generated from one frozen OSM level (3 m). The NNW family is 332.3° and WSW family is 242.3°.

### Identity, coverage, and visible facts

- Identity confidence is **high for the exact local footprint and official-viewpoint reconciliation**. Current building condition and the frozen building=abandoned classification remain unverified.
- Official March 2025 coverage reached the NNW side and WSW/NNW corner area, but full-height storage containers, fence, and parked vehicles block the target.
- Observed facade sides: **none usable**. The two panorama positions establish occlusion, not facade appearance. ENE and SSE sides were not viewed.
- No target material, color/value, opening, door, canopy, band, rib, roof edge, ground opening, sign, story cadence, or weathering detail is safely visible.
- Story/massing conflict evidence: none. The frozen one-level/3 m rule was neither confirmed nor contradicted.

### Modules, seams, and confidence

- Candidate complete modules: **none**. Containers, their corrugation, signs, and fence are foreground objects and must not become facade vocabulary.
- Legal facade seams: **none established**.
- Forbidden use: do not interpret container edges as building joints, a container door as a building opening, or the sliver above the containers as a measured roof edge.
- Must not invent: Education Center family reuse, classroom-window cadence, abandoned/boarded openings, entrances, signage, siding, brick, or siblings 29B–29E.
- Research verdict: **blocked by complete public-side occlusion despite current official coverage**.

## Advanced Culinary Dormitory observations

Exact receiver: building:w34313514:wall; 44 exterior wall segments / 313.900 m; generated from the default 6 m fallback with no level tag.

### Identity, coverage, and visible facts

- Identity confidence is **high only for the frozen source-to-receiver join** and **low for the current name**. The frozen note itself says the sign may have been misread.
- Observed sides: none. Unobserved sides: all ENE, SSE, WSW, and NNW families.
- The exact 4th Street request returned no official Street View imagery, and coverage mode showed no official frontage line.
- No facade material hierarchy, color/value, story cadence, residential window/door, canopy, band, rib, roof edge, ground opening, sign, entry, or weathering fact is established.
- Story/massing conflict evidence: none. The default 6 m receiver height and any dormitory story count are unverified.

### Modules, seams, and confidence

- Candidate complete modules: **none**.
- Legal facade seams: **none established**.
- Forbidden use: do not derive a dormitory window grid, paired entrance, sign, residence color scheme, or two-level cadence from the uncertain name or default height.
- Do not copy nearby Personnel Support/Naval Station language and do not reproduce the uncertain Advanced Culinary wording as signage.
- Research verdict: **blocked for current identity and target-specific facade authoring by absent official frontage evidence**.

## Cohort-level handoff

- Usable official target facade evidence exists only for Personnel Support Detachment, Fire Training Building 600, and Fire Station 48.
- Education Center 29A has current official viewpoints but zero usable facade coverage because the target is hidden by containers/fence.
- Harvey Milk Administration, Naval Station, Food Service Building 368, and Advanced Culinary Dormitory have no approved official target elevation in this bounded pass. Food Service's contributor path was explicitly excluded.
- No observed extent is reconciled to exact generated-run endpoints. All unique elevations and module placements remain blocked.
- Apparent institutional or fire-service relationships are identity context only. No cross-target material or module reuse is established.
- Conservative homogeneous-field research is plausible only for the three visually observed targets, and even there material substrate and physical scale remain unknown.
- All unobserved, occluded, contributor-only, and identity-uncertain sides must remain the shared placeholder or another explicitly approved fallback; they must not be filled with inferred facade motifs.

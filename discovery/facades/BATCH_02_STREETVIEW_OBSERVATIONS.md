# Batch 02 facade cohort — official Google Street View observations

Checked: **2026-08-29**  
Mode: **observation-only evidence handoff**  
Targets: Building 2 (`w24274434`), 490 Avenue of the Palms (`w1272162518`), Star View Court (`w1212173437`), Maceo May (`r19685981`), Navy Chapel Building 187 (`w291189336`), Treasure Island Community YMCA (`w34313547`), and Oasis (`w291189918`)

## Evidence and use boundary

- Facade observations use only panoramas whose Google Maps UI identified **Google Street View** and displayed an image-capture month/year.
- Exact identity, footprint, receiver, generated height, and orientation groups come from `discovery/FACADE_RECEIVER_INVENTORY.json` and the frozen OSM snapshot. Those project sources do not prove appearance.
- Google Maps place/search results were used only for navigation and identity checking. User-contributed 360s, contributor profiles, interiors, yards, and ordinary place photos were excluded from facade evidence.
- Google imagery was viewed transiently in the existing Chrome UI. No image, crop, screenshot artifact, download, copied pixels, redistribution, upload, or repository asset was retained.
- Labels are strict: `visible fact` is directly visible in an identified official panorama; `mapping inference` joins a viewpoint to a frozen footprint/orientation; `production inference` is a reversible facade-asset proposal; `unknown` is not supported for authoring.
- Orientation-group mapping is not an exact generated-run endpoint map. No unique elevation is integration-ready until its observed extent is reconciled to the receiver's exact wall runs.
- Nothing here authorizes or prescribes a change to stories, height, roof profile, footprint, silhouette, topology, collision, spray behavior, terrain, foundations, navigation, or generated source data.

## Official panorama ledger

The URLs below are the exact Google Maps API requests used. Each row also records the resolved panorama ID and actual viewpoint exposed by Google Maps.

### Building 2 — `w24274434`, 300 California Avenue

| ID | Exact request URL | Resolved panorama / actual viewpoint | Displayed capture | Direction and usable coverage |
|---|---|---|---|---|
| `B2-SV01` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.81782,-122.36865&heading=58&pitch=6&fov=75` | `MGLja7KGZ2kmIQSXa35Pgg`; `37.8178183,-122.3684619` | **May 2019** | southwest public approach, looking northeast (`58°`); WSW monumental end with tree/foreground occlusion |
| `B2-SV02` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8179703,-122.3685661&heading=52&pitch=5&fov=70` | `lnRMuxXwh_bOj4Vg7NCoxw`; `37.8179703,-122.3685661` | **May 2019** | southwest/public road, looking northeast (`52°`); complete WSW monumental end. The same panorama was inspected at `95°`, `pitch 7°`, `fov 75°` for the right end bay and flank. |

### 490 Avenue of the Palms — `w1272162518`

| ID | Exact request URL | Resolved panorama / actual viewpoint | Displayed capture | Direction and usable coverage |
|---|---|---|---|---|
| `P490-SV01` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82115,-122.37405&heading=70&pitch=6&fov=75` | `bjPnIkM1MVTV2DXoZa2jRw`; `37.8210705,-122.3741623` | **Nov 2025** | Avenue A west/southwest of the footprint, looking east-northeast (`70°`); close WSW residential and entry elevation |
| `P490-SV02` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82155,-122.37430&heading=125&pitch=7&fov=78` | `92eDcHBL7oSzMdVAC4wfkA`; `37.8214764,-122.3744023` | **Nov 2025** | northwest on Avenue A, looking southeast (`125°`); north corner, tall WSW elevation and apparent story stack |
| `P490-SV03` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82072,-122.37398&heading=45&pitch=7&fov=78` | `_7_jhPOXMBLR2zGQkhH2hw`; `37.8207426,-122.3739467` | **Nov 2025** | southwest/south on Avenue A, looking northeast (`45°`); southern WSW bays and deep terrace/recess motifs |
| `P490-SV04` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82178,-122.37372&heading=160&pitch=7&fov=78` | `qezst3shU9xoH-7A1tk_FQ`; `37.8217892,-122.3737571` | **Nov 2025** | north on Johnson Street, looking south-southeast (`160°`); NW/north end and adjacent lower-looking volume |

### Star View Court — `w1212173437`

| ID | Exact request URL | Resolved panorama / actual viewpoint | Displayed capture | Direction and usable coverage |
|---|---|---|---|---|
| `SVC-SV01` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82198,-122.37395&heading=110&pitch=7&fov=78` | `zyHYcw8pVTx2iEKy0KR32w`; `37.8218578,-122.3736850` | **Nov 2025** | northwest on Johnson Street/Avenue A, looking southeast (`110°`); named entrance, NW end, partial WSW/courtyard wing |
| `SVC-SV02` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82170,-122.37255&heading=275&pitch=7&fov=78` | `XinlFktyE0_U2KP7tU6mfg`; `37.8216329,-122.3727587` | **Sep 2025** | east on Seven Seas Avenue, looking west (`275°`); broad ENE elevation and ground entrances |

### Maceo May — `r19685981`

| ID | Exact request URL | Resolved panorama / actual viewpoint | Displayed capture | Direction and usable coverage |
|---|---|---|---|---|
| `MM-SV01` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82095,-122.37220&heading=275&pitch=7&fov=78` | `kEX8mV7OsuHLoA4oK69_KA`; `37.8209027,-122.3722808` | **Sep 2025** | east on Seven Seas Avenue, looking west (`275°`); broad ENE residential elevation |
| `MM-SV02` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82060,-122.37225&heading=320&pitch=7&fov=78` | `OKiASMGBFciyCsC9neeygg`; `37.8206631,-122.3723529` | **Sep 2025** | southeast on Cravath Street, looking northwest (`320°`); SSE entrance, curtain wall, ribbed field, address and vertical name sign |

### Navy Chapel Building 187 — `w291189336`, 51 California Avenue

| ID | Exact request URL | Resolved panorama / actual viewpoint | Displayed capture | Direction and usable coverage |
|---|---|---|---|---|
| `NC-SV01` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.81773,-122.37165&heading=300&pitch=7&fov=80` | `-9-3R6HngS2KcuZw9K3C_w`; `37.8176553,-122.3716066` | **Sep 2025** | southeast on California Avenue, looking northwest (`300°`); SSE gabled entrance and partial long side. The same panorama was inspected at `pitch 8°`, `fov 55°`. |

### Treasure Island Community YMCA — `w34313547`

| ID | Exact request URL | Resolved panorama / actual viewpoint | Displayed capture | Direction and usable coverage |
|---|---|---|---|---|
| `Y-SV01` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82605,-122.36825&heading=330&pitch=6&fov=78` | `d0oKpsvA2eE-WM-C7gVokA`; `37.8260421,-122.3682434` | **Sep 2025** | southeast on 9th Street, looking northwest (`330°`); complete SSE public/entry elevation |
| `Y-SV02` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82645,-122.36785&heading=245&pitch=5&fov=78` | `BM2ooxp-6GhmR934Ah2PVA`; `37.8264845,-122.3678324` | **Sep 2025** | east on Avenue M, looking west-southwest (`245°`); ENE service end |
| `Y-SV03` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82688,-122.36855&heading=155&pitch=5&fov=78` | `NVAmGBSgPlk8h5g-8-od9g`; `37.8269174,-122.3686245` | **May 2019** | north/northwest, looking south-southeast (`155°`); partial NNW campus/back condition and low mural wing with uncertain footprint ownership |

### Oasis — `w291189918`, frozen address 401 California Avenue

| ID | Exact request URL | Resolved panorama / actual viewpoint | Displayed capture | Direction and usable coverage |
|---|---|---|---|---|
| `OAS-SV01` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8190093,-122.3709789&heading=65&pitch=5&fov=72` | `wWF9QvLiOmqohwnoD77DTg`; `37.8190093,-122.3709789` | **Sep 2025** | west/southwest on Seven Seas Avenue, looking east-northeast (`65°`); distant WSW-facing low building across fenced lot |
| `OAS-SV02` | `https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.81882,-122.37080&heading=55&pitch=4&fov=68` | `-pPwIOsi3zTgQd5N_VaeqQ`; `37.8187704,-122.3708231` | **Sep 2025** | southwest on Seven Seas Avenue, looking northeast (`55°`); distant WSW/SSE oblique through trees and fence |

## Building 2 observations and facade grammar

Exact receiver: `building:w24274434:wall`. The only defensible side mapping is the WSW orientation family (`241.9°`–`242.0°`); exact member-run endpoints remain unreconciled.

### Observed coverage and visible facts

- `visible fact`: the complete monumental public end was observed from two official road positions. Landscaping and the viewing angle expose only minor portions of adjoining long sides.
- `mapping inference — high confidence`: the camera is southwest of the footprint looking northeast, so the monumental end is the receiver's WSW family.
- `unknown`: ENE opposite end, both long-side schedules, service/loading openings, and every exact generated-run endpoint.
- The dominant field is warm pale cream/yellow painted mineral or masonry-like material with low-satin/matte response and mild diffuse streaking. Exact substrate and paint are unknown.
- Two very large rectangular gridded translucent-glazing/glass-block fields dominate the end. Dark cool-grey mullion grids surround many small pale blue-grey panes. A narrow dark horizontal pane band crosses each field, and a low row of darker openings/panes occurs at the base.
- A unique central bay separates the grids: a tall muted blue-grey panel/recess, a pale sculptural relief above, and a complete group of dark personnel/entry doors below. The relief is visible but not legible enough for faithful artwork reproduction.
- Tall cream shoulder pylons flank the facade. Each contains a narrow pale blue-grey vertical inset/louver-like field. Small square vents puncture the otherwise blank upper cream field.
- A shallow horizontal ledge caps the large glazing. The upper edge rises in a broad shallow curve consistent with the hangar crown behind it. Crown/profile and pylon depth are geometry-owned.
- Story/cadence evidence: the elevation does not present a conventional two-row punched-window stack. It reads as one monumental tall hall end with full-height glazing and ground doors. This neither verifies nor disproves the frozen `building:levels=2`; it must not be used to settle massing.

### Candidate complete modules (`production inference`)

- `B2-GRID-L` / `B2-GRID-R`: each full monumental gridded opening, including every outer jamb/head/base and internal mullion boundary. These are unique-elevation regions, not repeat tiles.
- `B2-CENTRAL`: the full central panel/relief/door composition as one unique element. Exact relief artwork is blocked by legibility.
- `B2-PYLON-INSET`: one complete narrow vertical pylon inset only if the left/right dimensions are verified independently.
- `B2-VENT`: one complete small upper vent with full cream surround.
- A homogeneous warm-cream field may be researched separately. No facade-scale architectural period is proven.

### Seam contract

Legal seams are confined to uninterrupted warm-cream field, or between complete unique modules and ordinary field. A seam may follow a verified full outer edge of a glazing field or pylon inset.

Forbidden seams include every generated U reset; every mullion, pane, glazing surround, dark horizontal pane band, door, relief, vent, pylon inset, ledge, corner, and curved roof-edge termination. The observed end may not be mirrored onto the ENE end.

### Confidence and must-not-invent details

- WSW identity/material hierarchy and major motif composition: **high confidence**.
- Exact material product, pane construction, dimensions, relief artwork, door count at occluded edges, and run endpoints: **unknown or medium-low confidence**.
- Do not invent long-side ribs, hangar doors, loading bays, repeated glass grids, a matching opposite end, exact heritage ornament, or two-story window rows.
- Readiness: homogeneous cream material and a WSW unique-elevation specification are plausible; exact placement and relief artwork remain blocked.

## 490 Avenue of the Palms observations and facade grammar

Exact receiver: `building:w1272162518:wall`. Observations principally map to the WSW family (`242.0°`) plus the NW end family (`310.9°`). Exact generated-run endpoints are not established.

### Observed coverage and visible facts

- `visible fact`: official Nov 2025 imagery shows most of the Avenue A/WSW elevation, its north and south portions, and a NW/north end oblique.
- `unknown`: ENE/rear elevation, SSE end as a complete elevation, courtyard/interior faces, and exact side endpoints. An east-side request resolved to non-official contributor imagery and was excluded.
- Material hierarchy alternates warm-white smooth panel/render fields, dark taupe/grey thin-brick fields, muted tan/greige accent rectangles, and near-charcoal metal window frames. Glazing is muted blue-green/grey.
- Upper cadence uses several complete window families: narrow portrait, paired medium, and broad near-floor-to-ceiling openings. White regions often form a rectilinear frame around window stacks; brick regions form broader vertical piers and deep framed voids.
- Deep multi-bay terrace/balcony recesses occur within dark-brick frames. Their true depth, soffit, rails, and volume are geometry-owned; they cannot be represented as a seamless window tile.
- Ground level is mostly warm white with complete punched windows, full-height glazed bays, and occasional greige panels. The observed entrance includes a deep sheltered recess, glazed doors, and large `490` numerals.
- Thin white slab/belt bands separate some vertical regions. The flat parapet has isolated rail/equipment context; exact roofline is geometry-owned.
- Surface condition is clean/new with very low weathering. No evidence supports repeated stains or distressed brick.
- Story-count conflict evidence: the tall observed Avenue A corner reads as ground level plus five upper occupied window rows—an apparent **six visible levels**. The frozen receiver is generated from `building:levels=5` (`15 m`), while local island evidence also describes six stories. This is a visible conflict only; it does not authorize a height, story, roof, or receiver change. The northern view also shows lower-looking connected/adjacent volumes whose exact footprint ownership is not resolved.

### Candidate complete modules (`production inference`)

- `P490-W-N`, `P490-W-M`, `P490-W-W`: complete narrow, medium/paired, and wide window modules with full frame and allocated white/brick/greige surround.
- `P490-BRICK-BAY`: one complete brick-framed window-stack bay; it is explicitly placed, not tiled across white regions.
- `P490-GROUND-GLAZED`: one complete ground glazing bay with full frame.
- `P490-ENTRY`: the complete `490` entrance/recess composition as unique WSW data.
- `P490-TERRACE`: a side-specific complete deep terrace opening; actual depth/railing remains geometry-owned and is not texture-ready.
- Homogeneous white, greige, and thin-brick fields remain separate material regions.

### Seam contract

Legal seams are within uninterrupted white/greige field, at verified full thin-brick unit boundaries, or between complete modules and ordinary field. White slab bands may be boundaries only when their world-space phase is continuous.

Forbidden seams include generated U resets and any cut through a window, mullion, surround, brick pier/corner, greige accent termination, belt band, terrace void/rail/soffit, entry recess, glazed door, or `490` identifier. No WSW sequence may wrap to the ENE side or cross a deep recess.

### Confidence and must-not-invent details

- WSW material hierarchy and module families: **high confidence**; NW/north mapping: **medium confidence**.
- Exact dimensions, story geometry, courtyard layout, balcony depth, ENE/SSE schedules, and run endpoints: **unknown**.
- Do not invent a five-level cadence to match the receiver, a seventh level, rear balconies, mirrored terrace voids, exact corner phase, or repeated `490` signage.
- Readiness: material families and WSW module vocabulary are research-ready; unique integration is blocked by run endpoints and the unresolved massing conflict.

## Star View Court observations and facade grammar

Exact receiver: `building:w1212173437:wall`. The broad east observation maps to the ENE family (`62.5°`); the named entrance observation maps to the NW/WSW corner (`310.3°` / `242.4°`). Exact endpoints are unreconciled.

### Observed coverage and visible facts

- `visible fact`: official Sep/Nov 2025 imagery shows a broad ENE elevation, the named northwest entrance, and partial WSW/courtyard-wing context.
- `unknown`: complete SSE end, much of the WSW elevation, rear/courtyard faces, and exact run endpoints.
- The dominant upper field is warm white to very-light grey smooth panel/render with subtle control joints. Window frames and deep reveals are near-charcoal; glazing is cool muted green-grey.
- The ENE base uses medium grey vertically textured tile/brick-like strips between complete tall ground windows and doors. The named entrance combines a light raw-concrete/grey portal, full-height lobby glazing, a thin dark canopy/sign band reading `STAR VIEW COURT`, and a large `78` identifier.
- Upper openings alternate narrow portrait windows, paired/wide rectangles, and occasional larger vertical stacks. Their horizontal order is irregular; no one global repeat cell is proven. Many stacks remain vertically aligned within local bays.
- Recessed joints and building offsets divide regions. Flat parapets, tower/wing height changes, and courtyard projection are geometry-owned.
- Weathering is minimal. Material variation comes from region changes, not stains.
- Story-count conflict evidence: the broad ENE elevation visibly reads as a ground row plus five upper window rows—an apparent **six visible levels**. The frozen receiver uses seven OSM levels (`21 m`) while local evidence records a six-versus-seven discrepancy. The entrance view also contains lower courtyard-wing volumes. This evidence does not authorize any massing correction.

### Candidate complete modules (`production inference`)

- `SVC-W-N`, `SVC-W-M`, `SVC-W-W`: complete narrow, medium, and wide upper windows with full charcoal frames and allocated white surround.
- `SVC-BASE-W` / `SVC-BASE-D`: complete ground window and door families with full grey textured surround.
- `SVC-ENTRY78`: one complete entrance portal/lobby/canopy/name/number composition, unique to the observed NW corner.
- `SVC-GREY-BASE`: a homogeneous vertically textured base field only after physical frequency is bounded; it is not a window-bearing seamless texture.

### Seam contract

Legal seams are within uninterrupted warm-white or grey base field and between complete modules with full surrounds. Verified complete control-joint lines may be boundaries when they do not split a motif.

Forbidden seams include generated U resets and any cut through a window, frame, deep reveal, ground door/glazing, textured base termination, concrete portal, canopy/sign band, `STAR VIEW COURT`, `78`, corner, or parapet termination. Do not force an irregular elevation into a translation tile.

### Confidence and must-not-invent details

- ENE material/cadence and entrance identity: **high confidence**; exact NW/WSW endpoint mapping: **medium confidence**.
- Do not invent a seventh facade row, delete a visible sixth-level row to fit another count, copy the entrance to another side, normalize mixed window widths, or infer courtyard doors/balconies.
- Readiness: material fields and complete module families are research-ready; unique layout remains blocked by exact run mapping and the story-count conflict.

## Maceo May observations and facade grammar

Exact receiver: `building:r19685981:wall`. The broad Seven Seas view maps to the ENE families (`59.5°`–`63.1°`); the Cravath entrance maps to the SSE/SE families (`130.9°`–`155.1°`). Relation-derived run endpoints remain unreconciled.

### Observed coverage and visible facts

- `visible fact`: official Sep 2025 imagery shows the broad ENE residential elevation and the SSE entrance/end region at close range.
- `unknown`: WSW/rear elevation, NNW/north end, courtyard/inner condition, and exact 40-run endpoint mapping. A north/west request opened contributor imagery and was excluded.
- ENE hierarchy: a warm-white smooth rectilinear grid frames repeated window bays; recessed near-charcoal panels and narrow dark head/louver fields hold grey-green glazing. The ground band is dark graphite with narrow vertical windows and solid/service doors.
- SSE entrance hierarchy is deliberately different: a very-light grey/white fine vertical-rib field, muted rust-red window frames and horizontal accent siding, a warm pale-grey projected bay, and dark charcoal ground/entry regions.
- Complete rust-framed windows are asymmetrically divided into a broad fixed pane and a narrow operable pane. Small square vents occur above some windows in the ribbed field.
- Ground curtain glazing spans several bays between full-height pale concrete columns. A recessed glazed entrance is marked by an address beginning `55`, and a vertical `MACEO MAY` sign occupies the rust accent strip.
- Deep projected bays, corner returns, and entrance recess depth are geometry-owned.
- Story evidence: the broad ENE field is consistent with a ground level plus five upper rows—six visible levels, matching the frozen six-level tag at the observed facade. This is corroboration of cadence only, not authorization to encode or change massing.

### Candidate complete modules (`production inference`)

- `MM-ENE-W`: a complete ENE upper window bay including dark panel, head/louver field, full frame, and white grid allocation.
- `MM-SSE-W`: a complete rust-framed asymmetrically divided window with full ribbed-field surround.
- `MM-GROUND-N`: a complete narrow ground window/door family in the graphite base.
- `MM-CW`: one complete curtain-wall bay with full mullion boundary.
- `MM-ENTRY55`: one complete entrance/address/sign-region sequence as unique SSE data. Exact small address glyphs beyond visible `55` remain unverified.
- `MM-RIB`: a homogeneous fine vertical-rib material candidate; physical period is unknown and must be calibrated before generation.

### Seam contract

Legal seams are within uninterrupted white, graphite, or vertical-rib material field; at a verified complete rib valley; or between complete modules with full surrounds.

Forbidden seams include generated U resets and cuts through any window, operable pane, dark head/louver, white grid frame, rust trim/siding, rib termination, vent, concrete column, curtain-wall mullion, entrance, address, vertical name sign, projected bay, or corner. ENE and SSE motif families must not share one tile.

### Confidence and must-not-invent details

- Material-region split, ENE cadence, SSE entrance motifs, and six-row evidence: **high confidence**.
- Exact dimensions, rib pitch, rear/courtyard vocabulary, relation-run endpoints, and projected-bay depth: **unknown**.
- Do not copy nearby 490 or Star View vocabulary, repeat the `MACEO MAY` sign, invent balconies, or wrap the ENE grid around the SSE ribbed entrance.
- Readiness: multiple material fields and module families are research-ready, but each region requires exact run reconciliation.

## Navy Chapel Building 187 observations and facade grammar

Exact receiver: `building:w291189336:wall`. The public gabled entrance maps to the SSE family (`152.0°`–`152.2°`); the oblique supplies partial long-side evidence only.

### Observed coverage and visible facts

- `visible fact`: official Sep 2025 imagery shows the complete SSE gabled entrance from across California Avenue and partial adjacent long-side/low-wing conditions.
- `unknown`: NNW rear, complete ENE and WSW long sides, rear doors, and exact run endpoints. Landscaping, fence, and distance limit small-detail inspection.
- The dominant wall is warm off-white/cream painted field with pale trim. Distance does not distinguish smooth stucco, painted board/siding, or another substrate.
- The SSE gable contains one tall, narrow, vertically divided multi-pane window group above a shallow projecting entrance/porch. The entrance appears to contain paired pale/tan doors with sidelights or narrow flanking glazing; exact leaf and mullion counts are not verified.
- Small rectangular side windows sit symmetrically or near-symmetrically on the gable field. The observed long wing contains repeated tall narrow window groups in complete pale surrounds.
- Roof surfaces are dark grey-brown. A square belfry/tower with a pyramidal cap and cross rises behind the hall. Gable, roof, belfry, cross, and porch depth are geometry-owned.
- Story evidence: the building reads as one tall worship-hall volume with ancillary low wing, not a conventional stacked-story facade. The frozen receiver has a `10 m` height but no level count; imagery does not establish a numeric story conflict.

### Candidate complete modules (`production inference`)

- `NC-GABLE-W`: the full tall divided gable window group with complete pale surround.
- `NC-ENTRY`: the complete door/sidelight/porch-face assembly; porch depth remains geometry-owned and exact leaf count is blocked.
- `NC-SIDE-W`: one complete long-side window group with full surround, only after closer evidence verifies its pane pattern.
- `NC-SMALL-W`: one complete small gable window with full surround.
- A homogeneous warm-cream painted field is the only material candidate supported independently of module layout.

### Seam contract

Legal seams are within uninterrupted warm-cream field and between complete opening modules and ordinary field. A verified full trim boundary may be a seam.

Forbidden seams include generated U resets and cuts through the tall gable window, any pane/mullion, door/sidelight, porch/trim, small window, long-side group, gable rake, eave, corner, belfry, or cross. The entrance cannot be mirrored onto the rear.

### Confidence and must-not-invent details

- Overall cream/dark-roof hierarchy and SSE motif locations: **medium-high confidence**.
- Substrate, pane pattern, door count, complete long-side cadence, and exact dimensions: **low-to-medium confidence** because of distance.
- Do not invent denominational symbols beyond the visible cross, stained-glass colors, rear doors, arches, columns, exact siding courses, or a numeric story stack.
- Readiness: homogeneous material research is plausible; opening modules and unique elevation remain blocked by distance and endpoint mapping.

## Treasure Island Community YMCA observations and facade grammar

Exact receiver: `building:w34313547:wall`. The complete public elevation maps to the SSE family (`152.0°`); the service end maps to ENE (`62.0°`). The May 2019 north view is a partial NNW campus condition whose low-wing ownership is uncertain.

### Observed coverage and visible facts

- `visible fact`: official Sep 2025 imagery shows the complete SSE/9th Street entrance elevation and the ENE/Avenue M service end. Official May 2019 imagery shows part of the NNW/back campus condition.
- `unknown`: WSW end, much of the NNW main wall behind vegetation, exact ownership of the low mural wing, and exact receiver-run endpoints.
- The main gym volume uses a dark warm-grey/brown rough exposed-aggregate or pebbled precast field. Thin cool blue-grey vertical strips/joints divide broad panels. Exact aggregate size and panel construction are unknown.
- SSE entrance: a low projected warm-white vestibule/portal interrupts the otherwise blank wall. It has a thin blue-grey canopy/fascia line and a complete bank of glazed doors/sidelights. Small wall lettering is present to the left but not legible enough for exact reproduction.
- ENE service end: the same aggregate field is nearly blank, with one small high light-grey metal louver and one dark blue service/personnel door partly screened by vegetation.
- The roof edge is a thin dark/cool coping over a flat or very shallow profile. Roof shape is geometry-owned.
- May 2019 NNW context includes a low warm-white wing with a long horizontal window band and a large colorful mural. `mapping inference — low confidence`: it may be attached to or share the YMCA campus, but exact footprint ownership is not established. It is not valid target-wide facade vocabulary and is not evidence of Sep 2025 condition.
- Story evidence: the main volume reads as a single tall gym/hall without stacked window rows. This is compatible with a `9 m` tall single-volume receiver but does not verify its roof or height.

### Candidate complete modules (`production inference`)

- `Y-ENTRY`: one complete projected entry-face assembly with all doors/sidelights and canopy/fascia; projection depth remains geometry-owned.
- `Y-SERVICE-D`: one complete dark-blue service door with full aggregate surround.
- `Y-LOUVER`: one complete high louver with full surround.
- `Y-AGG`: a homogeneous aggregate material field; vertical panel joints require explicit world-space placement rather than generated-segment resets.
- The May 2019 mural is **not a candidate module** without exact footprint ownership, current reference, and artwork/reuse authorization.

### Seam contract

Legal seams are within uninterrupted aggregate or warm-white field, at a verified complete panel-joint line, and between complete modules and ordinary field.

Forbidden seams include generated U resets and cuts through panel joints, louver, service door, entrance glazing/mullions, canopy/fascia, lettering, corner, roof coping, horizontal window band, or mural. Do not distribute the mural or entry across other sides.

### Confidence and must-not-invent details

- SSE and ENE main-volume hierarchy: **high confidence**; NNW main wall: **low-medium**; low-wing ownership/mural relevance: **low**.
- Do not invent gym windows, a repeated aggregate-panel period, exact YMCA lettering, additional blue doors/louvers, a matching WSW end, or mural content on the target receiver.
- Readiness: aggregate material and observed SSE/ENE module vocabulary are research-ready; NNW unique content is blocked.

## Oasis observations and facade grammar

Exact receiver: `building:w291189918:wall`, frozen address `401 California Avenue`. The official imagery does not show legible Oasis branding, and a focused Google Maps place search did not return a reliable exact Oasis result.

### Identity, coverage, and visible facts

- `mapping inference — medium confidence`: the low building across the fenced lot occupies the frozen footprint's coordinate and orientation region. The viewpoints are west/southwest of the footprint looking east/northeast, so the best-seen face is likely the WSW family (`242.0°`–`242.1°`) with a partial SSE return.
- `unknown`: whether Google Maps currently recognizes the venue identity, exact address-to-building association beyond the frozen OSM join, ENE/rear and NNW sides, complete SSE end, entrance/signage program, and exact receiver-run endpoints.
- Official Sep 2025 imagery shows a distant low, apparently single-story building behind trees, fence, and a broad paved lot. The dominant wall reads light warm cream/off-white; the shallow roof/roof edge reads dark grey-blue. Exact substrate and roof material are not resolvable.
- A central portion appears to contain a broad horizontal glazed/door field under a low dark fascia or canopy-like edge, with more opaque cream flank walls. Tree trunks and distance prevent reliable opening counts.
- No current `Oasis`, pizzeria, event-venue, or `401` sign is legible in the official panoramas. No brand color or artwork is established.
- Story/default-height evidence: the observed profile appears low and single-story. The frozen receiver uses a default `6 m` fallback with no level tag. A tall single story could fit that fallback, so the imagery is not a numeric contradiction and does not authorize a massing change.
- Avenue D requests at the footprint returned no official Street View coverage; the usable official positions are on Seven Seas Avenue.

### Candidate complete modules (`production inference`)

- `OAS-LIGHT-FIELD`: a homogeneous light warm-cream field is a tentative material candidate.
- `OAS-CENTRAL-GLAZED`: potential complete central glazed/door assembly, **not module-ready** because opening count, mullions, entrance identity, and occlusion are unresolved.
- `OAS-DARK-FASCIA`: potential complete fascia/canopy-face element, **not module-ready**; its depth and continuity are unknown and geometry-owned if substantial.
- No signage, pizza, event-venue, or branded module is supported.

### Seam contract

The only currently legal seam is within uninterrupted light opaque field. A future seam between a verified complete glazed module and ordinary field may be legal after closer evidence.

Forbidden seams include every generated U reset and any cut through the central glazing/door field, possible fascia/canopy, roof edge, tree-obscured opening, corner, or unverified sign area. No layout may be mirrored to an unobserved side.

### Confidence and must-not-invent details

- Coordinate/footprint match: **medium confidence**; broad low/light/dark hierarchy: **low-medium confidence**; module grammar and present venue branding: **low confidence**.
- Do not invent Oasis signage, pizza imagery, event branding, window/door counts, canopies, a restaurant storefront, service doors, a second story, or symmetric rear/side layouts.
- Readiness: whole-target facade authoring is **blocked**. At most, a conservative homogeneous light field may proceed after the target identity is independently reconciled; all modules remain unknown.

## Cohort readiness summary

| Target | Official coverage | Story-count evidence | Evidence-backed next output | Remaining blocker |
|---|---|---|---|---|
| Building 2 | WSW monumental end; May 2019 | no conventional story stack; frozen two levels unverified | warm-cream field plus WSW unique-end specification | other three sides, exact run endpoints, dimensions, relief artwork |
| 490 Avenue of the Palms | WSW Avenue A elevation and NW/north obliques; Nov 2025 | apparent six visible levels versus frozen five | separate white/brick/greige materials and complete observed module families | ENE/SSE/rear, endpoints, terrace geometry, massing conflict |
| Star View Court | ENE, NW named entrance, partial WSW; Sep/Nov 2025 | apparent six visible levels versus frozen seven | white/grey fields, complete mixed window modules, unique entrance | SSE/rear/courtyard, endpoints, massing conflict |
| Maceo May | ENE and SSE entrance; Sep 2025 | six visible levels, consistent with frozen six | separate ENE/SSE materials and complete modules | WSW/NNW/courtyard, 40-run reconciliation, rib scale |
| Navy Chapel | SSE gabled entrance and partial long side; Sep 2025 | tall hall, no numeric level evidence | conservative cream field; tentative complete opening families | distance, three incomplete sides, pane/door counts, endpoints |
| YMCA | SSE, ENE, partial NNW; Sep 2025 and May 2019 | single tall gym volume; no numeric conflict | aggregate field, complete entry/service/louver modules | WSW, NNW occlusion, low-wing ownership, endpoints |
| Oasis | distant WSW/SSE obliques; Sep 2025 | apparent low single story; default 6 m not contradicted | at most a conservative light homogeneous field | present identity, signage, openings, three sides, Avenue D coverage, endpoints |

No target is ready for an as-built whole-object claim. Proximity, use, age, and apparent stylistic similarity do not prove a reusable cross-building material or module family.

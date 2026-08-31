# Batch 04 facade cohort — official Google Street View observations

Checked: **2026-08-29**  
Mode: **observation-only evidence handoff**  
Targets: Education Center Building 29B (`w34313523`), Job Corps Dormitory 369 (`w291189926`), 449 Avenue H (`w34313512`), 850 Avenue H (`w34313546`), 810 Avenue D (`w96698660`), Building 461 (`w34313569`), 1318 Gateview Avenue (`w95934092`), and 1212 Mariner Drive (`w96215649`)

## Evidence and use boundary

- Facade observations use only panoramas whose Google Maps UI identified **Google Street View** and displayed an image-capture month/year.
- Exact identity, address, footprint, receiver, generated height, level count, and orientation families come from `discovery/FACADE_RECEIVER_INVENTORY.json` and the frozen OSM snapshot. Those project sources do not prove appearance or current condition.
- Google Maps labels and coverage results were used only to navigate and reconcile identity. Contributor profiles, photo paths, photo spheres, interiors, ordinary place photos, and third-party imagery were excluded.
- Google imagery was viewed transiently in the existing Chrome UI. No image, crop, screenshot artifact, download, copied pixels, redistribution, upload, or repository asset was retained.
- Labels are strict: **visible fact** is directly visible in an identified official panorama; **mapping inference** joins a viewpoint to the frozen footprint/orientation; **production inference** is a reversible facade-asset proposal; **unknown** is not supported for authoring.
- An occluder, cleared lot, or perimeter fence does not prove the hidden or former facade. A request that returns no official imagery, or snaps to a contributor panorama, is coverage evidence only.
- Historical panoramas are dated condition evidence, not current-condition evidence. Broken panes, temporary fencing, patches, vehicles, bins, vegetation, and construction activity are not canonical modules.
- Orientation-family labels are approximate. No unique placement is integration-ready until observed extents are reconciled to exact generated receiver runs.
- Nothing here authorizes or prescribes a change to stories, height, roof profile, footprint, silhouette, topology, collision, spray behavior, terrain, foundations, navigation, or generated source data.

## Official panorama and coverage ledger

The request links below are the exact Google Maps API URLs used. Successful entries include the panorama ID and actual viewpoint exposed by Google Maps after resolving. Historical entries were selected from Google's official date timeline at the same request location.

### Education Center Building 29B — `w34313523`, frozen address 768 Avenue H

- **EC29B-SV01** — request <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8247245,-122.3684129&heading=224&pitch=0&fov=75>; panorama `gnRrpIe5wBUEXwYoTcE6NQ`; actual viewpoint **37.8247579, -122.3683720**; **March 2025**; from 651 8th Street, looking southwest at 224°.
- **EC29B-SV02** — request <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8244589,-122.3694416&heading=95&pitch=0&fov=75>; panorama `xPpjSLPIE2h--fbX_TB8OA`; actual viewpoint **37.8244829, -122.3694778**; **September 2025**; from 753 Avenue H, looking east at 95°.

### Job Corps Dormitory 369 — `w291189926`, 275 California Avenue

- **D369-SV01** — request <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8193228,-122.3711959&heading=56&pitch=0&fov=75>; panorama `NztWn9fwLieghDTyI_iEyQ`; actual viewpoint **37.8193190, -122.3712241**; **September 2025**; Seven Seas Avenue southwest of the footprint, looking northeast at 56°.
- **D369-NO01** — request <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8200821,-122.3699753&heading=234&pitch=0&fov=75>; Google Maps reported **No Street View imagery available here**. No official east-side panorama, capture date, or target appearance was established.

### 449 Avenue H — `w34313512`

- **449H-SV01-current** — request <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.823153,-122.3685837&heading=253&pitch=0&fov=75>; panorama `tUuvbI3y3fgy-R_XCvHdDQ`; actual viewpoint **37.8231121, -122.3685646**; **September 2025**; northeast/east of the frozen footprint, looking west-southwest at 253°.
- **449H-SV02-historical** — same exact request, with **May 2011** selected from Google's official date timeline; panorama `d4T0RdF4AE250u-CoH7tYw`; actual viewpoint **37.8231534, -122.3685542**; looking west-southwest at 253°.

### 850 Avenue H — `w34313546`

- **850H-EX01** — request <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8268578,-122.3710464&heading=78&pitch=0&fov=75>; Google Maps reported no official coverage and snapped to a July 2023 TyFlow io contributor panorama, type `!1e10`. It was excluded and supports no facade claim.
- **850H-SV01** — request <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8271144,-122.369789&heading=240&pitch=0&fov=75>; panorama `U1HtZQlUKomn07I4TT93ug`; actual viewpoint **37.8271222, -122.3698007**; **September 2025**; from 811 Avenue I, looking southwest at 240° toward the east/end area.
- **850H-SV02** — request <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8273062,-122.3701219&heading=205&pitch=0&fov=75>; panorama `QO4Mk2OE0ky1D7lGPsSciQ`; actual viewpoint **37.8273120, -122.3701921**; **March 2025**; from 600 11th Street, looking south-southwest at 205° toward the north side.

### 810 Avenue D — `w96698660`

- **810D-SV01-current** — request <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8242283,-122.3727535&heading=33&pitch=0&fov=75>; panorama `le1q7oLYgiyaWBAv2NBF2w`; actual viewpoint **37.8242274, -122.3727145**; **March 2025**; Avenue D/9th Street southwest of the footprint, looking northeast at 33°.
- **810D-SV02-historical** — same exact request, with **May 2011** selected from Google's official date timeline; panorama `IYcYMdJYTtaGjJVxo7eraA`; actual viewpoint **37.8241971, -122.3727396**; looking northeast at 33°.

### Building 461 — `w34313569`

- **B461-EX01** — request <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8313388,-122.3718321&heading=34&pitch=0&fov=75>; Google Maps reported no official imagery and snapped to a May 2024 John Ewing contributor panorama, type `!1e10`. It was excluded.
- **B461-EX02** — request <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.83121,-122.3721663&heading=52&pitch=0&fov=75>; the same contributor panorama was returned with no official imagery. It was excluded.
- **B461-SV01** — request <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8310739,-122.370928&heading=312&pitch=0&fov=75>; panorama `JMpuxlpS4Re0BFnlc7D1pA`; actual viewpoint **37.8310653, -122.3708380**; **November 2025**; from 1298 Avenue M east/southeast of the footprint, looking northwest at 312°.

### 1318 Gateview Avenue — `w95934092`

- **1318G-SV01** — request <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8267942,-122.3776632&heading=126&pitch=0&fov=75>; panorama `qGPa9ZjJlrtlQpnP52eiAA`; actual viewpoint **37.8267503, -122.3776812**; **March 2025**; Gateview Avenue west/northwest of the footprint, looking southeast at 126° toward the public/front side.
- **1318G-SV02** — request <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8266681,-122.3770043&heading=245&pitch=0&fov=75>; panorama `GmuTsOm1-FO47a4FOWEQHA`; actual viewpoint **37.8266407, -122.3769985**; **November 2025**; Avenue B east of the footprint, looking west-southwest at 245° toward the rear side.

### 1212 Mariner Drive — `w96215649`

- **1212M-SV01** — request <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8291464,-122.3730796&heading=172&pitch=0&fov=75>; panorama `moV9e3E7bv5UpjOrgfOOKA`; actual viewpoint **37.8291812, -122.3730340**; **March 2025**; Mariner Drive north of the footprint, looking south at 172° toward the public/front side.
- **1212M-SV02** — request <https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.8291844,-122.3727735&heading=230&pitch=0&fov=75>; panorama `Z0fcNvA78OpNIXJaa9A79A`; actual viewpoint **37.8291852, -122.3727577**; **September 2025**; Gateview Avenue northeast/east of the footprint, looking southwest at 230° toward the rear/end side.

## Education Center Building 29B observations

Exact receiver: `building:w34313523:wall`; 20 exterior wall segments / 163.385 m; generated from a frozen one-level tag and 3 m height.

### Identity, coverage, and visible facts

- Identity confidence is **high for the frozen source-to-receiver join** and **medium for the current site reconciliation**. Both official viewpoints border the exact footprint, but no building facade is exposed.
- March 2025 from the 8th Street side and September 2025 from Avenue H show a tall green corrugated perimeter/container wall, gates, fencing, utility poles, parking, and redevelopment/construction context. These are foreground/site facts, not facade facts.
- Observed usable facade sides: **none**. The NNW/ENE area and WSW/SSE area are blocked; no public elevation, roof edge, entrance, or opening is defensibly visible.
- Current-versus-frozen conflict evidence: the frozen building footprint is occupied or screened by a container/fenced work enclosure in both 2025 views. The panorama does not distinguish complete removal from total occlusion, so current existence is **unknown**.
- No material hierarchy, color/value, story cadence, window, door, canopy, band, rib, roof edge, ground opening, signage, or weathering fact is established.

### Modules, seams, confidence, and do-not-invent details

- Candidate complete modules: **none**. The green containers, corrugation, gates, signs, and perimeter panels must not become building vocabulary.
- Legal facade seams: **none established**.
- Forbidden seams/use: do not treat a container edge, gate leaf, fence post, or generated U reset as a wall joint; do not infer a classroom window cadence or entrance from the Education Center name or sibling Building 29A.
- Must not invent: current survival or demolition, facade substrate, color, roof, openings, signs, one-storey cadence, or any 29A/29B family resemblance.
- Research verdict: **blocked by current official-side occlusion/redevelopment conflict**.

## Job Corps Dormitory 369 observations

Exact receiver: `building:w291189926:wall`; 72 exterior wall segments / 487.830 m; generated with the 6 m fallback because the frozen source has no height or level tag.

### Identity, coverage, and visible facts

- Identity confidence is **high**. The official Seven Seas Avenue viewpoint aligns with the exact large footprint; the visible wayfinding sign names nearby Hawkins, Isle House, and Waterfront Plaza, providing additional site reconciliation.
- Observed coverage: a broad southwest/west-facing long elevation and the southeast/end corner in September 2025. The northeast/east request had no official coverage. Remaining long side, rear/end, courtyard/recesses, and exact run endpoints are unobserved.
- The building visibly reads as **five occupied facade tiers**. This conflicts strongly with the runtime's default 6 m fallback, but it does not authorize a geometry change.
- Dominant wall field is smooth light warm gray/off-white. The projecting end/stair volume is muted blue-gray. Exact stucco, painted concrete, or panel construction is unknown.
- A thin, dark muted green roof edge/eave caps the long elevation. The roof itself appears flat or very shallow from this view.
- The long facade uses alternating broad horizontal multi-lite window groups and narrow single/double windows. Broad windows commonly carry shallow dark green projecting eyebrows; several upper narrow windows do not.
- Ground level repeats broad window/infill groups with muted blue-gray opaque lower panels or doors. Small dark foundation vents occur near grade. No complete public entrance was established on the observed long face.
- The five-tier rhythm is regular at a distance, but individual window widths, infill states, and precise bay period vary enough that a single universal repeat is not proven.
- The end volume is largely solid blue-gray, with only small side windows and a ramp/rail at grade. Ramp, rails, roof projection, and volume depth are geometry/prop ownership.

### Candidate complete modules (production inference)

- **D369-WIDE-BAY**: one complete broad multi-lite window group with its full frame, full shallow green eyebrow, and surrounding light wall field.
- **D369-NARROW-BAY**: one complete narrow window with full surround and enough wall field to protect the opening boundary.
- **D369-GROUND-BAY**: one complete broad ground-level glazed/opaque-panel group with full frame and base vent only after alternate infill states are cataloged.
- **D369-SOLID-END**: uninterrupted blue-gray end-wall field only; the ramp, corner return, and side windows are excluded.

### Seam contract, confidence, and do-not-invent details

- Legal seams are limited to uninterrupted light wall field, uninterrupted end-wall field, or a verified complete outer window-bay boundary.
- Forbidden seams include generated U resets and cuts through any window/frame, green eyebrow, opaque lower panel, base vent, eave, corner, end volume, ramp, or uncertain ground opening.
- Material/value hierarchy and five-tier cadence: **high confidence** on the observed long elevation. Exact substrate, dimensions, alternates, entrances, opposite-side schedule, and run mapping: **unknown**.
- Do not compress the observed five tiers into a two-tier texture, invent an entrance, repeat every wide and narrow bay identically, propagate the end-wall color globally, or phase a long-elevation repeat around corners.
- Readiness: complete-bay specification is plausible for the observed long elevation; exact placement remains blocked by run/cadence reconciliation and the massing conflict.

## 449 Avenue H observations

Exact receiver: `building:w34313512:wall`; 20 exterior wall segments / 226.094 m; generated from a frozen two-level tag and 10 m height.

### Identity, coverage, and visible facts

- Identity confidence is **medium-high for the historical footprint match** and **medium for the address label**. The viewpoint and long rectangular form align with the frozen footprint, but Google's current label was 395 Avenue H and the May 2011 historical label was 440 Avenue H rather than 449.
- September 2025 visible fact: the frozen footprint area is a graded, fenced redevelopment lot with drilling/construction equipment; the former building is absent from the view.
- May 2011 visible fact: a long **two-storey** facade occupied the footprint. The observed elevation is the north/northeast-facing long side from an east/northeast viewpoint. Opposite long side, ends beyond the visible corner, and exact run endpoints are unobserved.
- Historical dominant wall field is light warm beige/off-white horizontal siding or narrow horizontal cladding. Exact product is unknown.
- Dark desaturated blue/blue-gray frames and trim organize two nearly continuous horizontal window registers. The upper register is taller; the lower register combines a shallow transom/window band with broad opaque siding below.
- A thin continuous blue-gray ledge/canopy line separates the tiers. A broad shallow roof overhang caps the facade; closely spaced light underside members or rafter-tail-like divisions are visible, but their construction and spacing are not calibrated.
- Ground level contains multiple large blue-gray doors or service openings and glazed bays. Several panes are broken or missing in 2011; that condition is not a canonical motif.
- Current-versus-frozen conflict evidence is **strong**: intact-enough two-storey historic evidence in May 2011 versus a cleared redevelopment lot in September 2025. This is lifecycle evidence, not authorization to change the frozen footprint.

### Candidate complete modules (production inference)

- **449H-TWO-TIER-BAY**: one complete structural/mullion bay spanning both window registers, the separating ledge, opaque lower field, and full bounding verticals.
- **449H-GROUND-DOOR-BAY**: one complete historical ground door/service-opening bay with its full frame and surrounding siding, only after the alternate states are cataloged.
- **449H-SOLID-SIDING**: uninterrupted light horizontal-cladding field, with scale still uncalibrated.

### Seam contract, confidence, and do-not-invent details

- Legal seams are within uninterrupted siding field or at a verified full outer vertical bay boundary.
- Forbidden seams include generated U resets and cuts through glazing, mullions, doors, service openings, tier ledge, roof edge/underside members, corner, or damaged pane.
- Historical two-storey hierarchy and colors: **medium-high confidence**. Exact address reconciliation, substrate, bay dimensions, door schedule, opposite side, end elevations, and current building existence: **unknown or superseded by redevelopment**.
- Do not reproduce broken glass as a repeat, heal every opening into one uniform window type, invent a current facade, place the historical texture on new redevelopment, or treat Google's differing labels as proof of a different footprint.
- Readiness: historical complete-bay research is possible for a frozen-era representation; current target-specific authoring is blocked by redevelopment and address reconciliation.

## 850 Avenue H observations

Exact receiver: `building:w34313546:wall`; 25 exterior wall segments / 237.592 m; generated from a frozen one-level tag and 4 m height.

### Identity, coverage, and visible facts

- Identity confidence is **medium**. Both official viewpoints border the irregular frozen footprint, but Google labels them 811 Avenue I and 600 11th Street, and containers obscure the footprint edges. The small exposed end wall is mapping-consistent but not independently signed as 850 Avenue H.
- Observed coverage: the likely east/end elevation in September 2025 and the north side in March 2025. The north side is almost completely blocked by a continuous line of storage containers. The west/Avenue H request returned only an excluded contributor panorama. South and most long elevations are unobserved.
- The exposed end reads as one storey, compatible with the frozen one-level/4 m rule.
- Visible wall field is muted warm tan/beige and appears smooth or lightly textured. Exact stucco, painted concrete, or panel substrate is unknown.
- Two high rectangular paired windows have pale frames and dark mesh/screen or opaque coverings. Their glazing state and whether both pairs belong to the exact target are not fully resolved.
- A flush plain door sits toward the left of the exposed wall. No canopy is present above it in the visible view.
- A thin projecting blue-green/dark teal roof-edge line caps the wall. A large pale blue-gray rectangular paint/repair patch occupies the lower center; this is dated condition evidence, not a reusable band or panel.
- Containers and gates meet both ends of the exposed wall and block the base/returns. No long-side cadence, ground openings beyond the door, belt band, or structural rib is established.

### Candidate complete modules (production inference)

- **850H-HIGH-PAIR**: one complete paired high-window group with full frame and surrounding tan field, provisional pending identity/covering confirmation.
- **850H-SOLID**: uninterrupted tan field only. The pale repair patch is excluded from the canonical material.
- The plain door is not yet a repeatable module; only one was observed and its target ownership is not fully resolved.

### Seam contract, confidence, and do-not-invent details

- Legal seams are within uninterrupted tan field or at a verified complete outer window-group boundary.
- Forbidden seams include generated U resets and cuts through a high window, screen/mesh, door, teal roof edge, repair patch, container boundary, gate, or occluded return.
- One-storey value hierarchy and exposed-end details: **medium confidence**. Exact target ownership, material, long-side cadence, west/south sides, and run endpoints: **unknown**.
- Do not use the excluded contributor imagery, turn containers into facade ribs, repeat the repair patch, invent a storefront/entrance, or extrapolate the two high-window pairs around the irregular footprint.
- Readiness: a cautious solid tan field and provisional high-window module can be specified for review; placement remains blocked by identity and occlusion.

## 810 Avenue D observations

Exact receiver: `building:w96698660:wall`; six exterior wall segments / 51.994 m; generated from a frozen one-level tag and 4 m height.

### Identity, coverage, and visible facts

- Identity confidence is **high**. Google displayed 810 Avenue D in both official dates, and the historical building aligns with the exact compact footprint.
- March 2025 visible fact: an opaque green construction perimeter encloses the site; the frozen building is not visible. Containers and contractor flags protrude above the fence. Current survival versus removal is unknown.
- May 2011 visible fact: a low **one-storey modular/portable-looking building** occupies the address. The front/southwest end and part of the southeast long side are visible. Rear/northeast and opposite long side remain unobserved.
- Historical dominant field is light off-white/very pale gray horizontal siding. Dark warm brown trim accents occur as narrow horizontal lines near the base and around some openings.
- The front has two broad dark-framed window groups flanking a central dark brown double door beneath a small `810` number. A substantial horizontal wood-slat deck/guardrail spans the front and obscures lower wall/threshold details.
- A shallow light metal gable roof has visible vertical seams and a low ridge. Gutters/downspouts are not clearly established.
- The long side includes additional rectangular windows and a small projecting utility/air-conditioning unit. The exact side cadence is not resolved at the available angle.
- Current-versus-frozen conflict evidence is strong but ambiguous: the 2011 building is clear; the 2025 site is completely fenced. The panorama does not prove demolition.

### Candidate complete modules (production inference)

- **810D-FRONT-WIN**: one complete broad historical front window group with full dark trim and surrounding pale siding.
- **810D-ENTRY**: the complete central double-door/`810`/deck-rail composition as a unique front module, not a general repeat.
- **810D-SIDE-WIN**: one complete side window with full trim and surrounding siding, pending a less oblique source.
- **810D-SOLID**: uninterrupted pale horizontal siding field with physical course scale still unknown.

### Seam contract, confidence, and do-not-invent details

- Legal seams are within uninterrupted siding field, at full modular-unit/trim boundaries if later proven, or at the complete outer boundary of a window module.
- Forbidden seams include generated U resets and cuts through a window, double door, number, deck/rail, brown trim line, roof seam/ridge, corner, utility unit, or 2025 fence/container.
- Historical front hierarchy: **high confidence**. Side cadence and substrate: **medium-low**. Current existence, hidden sides, exact dimensions, and run endpoints: **unknown**.
- Do not flatten the deck/rail into a painted stripe, treat the roof as a wall motif, invent a current facade behind the green fence, or assume every frozen wall segment is a portable-module seam.
- Readiness: historical front modules are specifiable; current-state authoring is blocked by complete enclosure.

## Building 461 observations

Exact receiver: `building:w34313569:wall`; 27 exterior wall segments / 207.182 m; generated from a frozen 8 m height with no level count.

### Identity, coverage, and visible facts

- Identity confidence is **medium**. The official Avenue M viewpoint, local coordinate alignment, and the sole large low industrial volume northwest of the camera support the mapping, but Google displayed 1298 Avenue M rather than a Building 461 identity.
- The two closer requests returned only an excluded May 2024 contributor panorama. The usable official evidence is therefore a medium-distance November 2025 view from east/southeast of the footprint.
- Observed coverage: the southeast/east-facing long elevation and east/end volume at distance. The opposite long side, west/north ends, base behind vegetation, entrances, and exact run endpoints remain unobserved.
- The building reads as one tall industrial/commercial storey under a flat roof/parapet, broadly compatible with the frozen 8 m height but not a measured confirmation.
- Dominant visible wall value is medium cool gray. A lighter coarse/speckled gray lower or inset field and darker gray panel-like upper field may form a two-value hierarchy; perspective and distance prevent confident substrate identification.
- Dark narrow vertical corner/pilaster divisions and a thin dark roof-edge line articulate the block. A taller pale warm-gray/tan end or stair/service volume projects at the right/east end.
- A short row of small vertical rectangular windows appears low-to-mid height on the long side near the end volume. Their exact count, spacing, and glazing/frame colors are not reliable enough for unique placement.
- Chain-link fence, scrub vegetation, and distance obscure the ground line. No door, loading bay, canopy, band, sign, rib product, or large ground opening is established.

### Candidate complete modules (production inference)

- **B461-SMALL-WIN**: one complete small vertical window with full surround and adjacent gray field, provisional because of distance.
- **B461-GRAY-FIELD**: uninterrupted two-value gray wall field only after closer evidence determines whether the value split is material, panel, shadow, or weathering.
- The pale end volume is not a repeat module and remains geometry-owned.

### Seam contract, confidence, and do-not-invent details

- Legal seams are limited to uninterrupted gray field or a verified complete outer panel/pilaster boundary after closer evidence.
- Forbidden seams include generated U resets and cuts through any small window, vertical division, value transition, roof edge, end volume, corner, vegetation-obscured opening, or fence line.
- Overall value/massing read: **medium confidence**. Exact identity label, substrate, panelization, windows, ground openings, entrances, opposite sides, and dimensions: **low or unknown**.
- Do not use either contributor panorama, invent hangar/loading doors or Building 461 signage from the name, repeat the small-window row globally, or convert the two-value read into a hard belt without closer proof.
- Readiness: target-specific detailed authoring remains **blocked by distance and incomplete identity/coverage**; only a conservative gray material study is defensible.

## 1318 Gateview Avenue observations

Exact receiver: `building:w95934092:wall`; 26 exterior wall segments / 163.714 m; generated from a frozen two-level tag and 6 m height.

### Identity, coverage, and visible facts

- Identity confidence is **high** from the exact even-address footprint, the Gateview/Avenue B viewpoints, and the continuous row geometry. Google displayed 1327 Gateview Avenue across the street in the front panorama rather than labeling the target itself.
- Observed coverage: the public/front long elevation and end in March 2025, plus the rear long elevation in November 2025. Small return faces and exact receiver-run endpoints remain unreconciled.
- The row reads as **two storeys**, compatible with the frozen two-level/6 m rule. It has light cool gray-blue horizontal lap/vinyl-like siding, white window/door trim, white gutters/downspouts, and a muted brown low gable roof. Exact siding and roofing products are unknown.
- Front cadence repeats attached townhouse bays. Each bay has a white-framed horizontal sliding window above; ground level alternates a plain entry door, a front window, and a short privacy/bin enclosure.
- A shallow continuous or near-continuous shed porch canopy runs across multiple front bays, broken into small gable-like entry accents at some unit boundaries and supported by plain posts. Exact canopy ownership and breaks require run mapping.
- The end gable is mostly siding with stacked rectangular windows and a simple white verge/eave.
- Rear cadence is simpler: one upper white-framed slider per unit, lower windows partly hidden by a tall wood privacy fence, and occasional lightweight trellis/awning members. Satellite dishes, bins, fences, and tenant additions are not canonical facade modules.
- No masonry base, decorative belt course, facade rib, storefront, or large ground opening is present in the observed sides.

### Candidate complete modules (production inference)

- **1318G-FRONT-UNIT**: one complete townhouse bay from verified unit boundary to boundary, including upper slider, ground door/window state, full canopy/post ownership, and surrounding siding.
- **1318G-REAR-UNIT**: one complete rear bay with upper slider, lower opening, and surrounding siding; the foreground wood fence is excluded unless treated separately as geometry/prop.
- **1318G-END**: the full gable-end composition as a unique region, not a repeat tile.
- **1318G-SIDING**: uninterrupted cool gray-blue horizontal siding field with physical course scale uncalibrated.

### Seam contract, confidence, and do-not-invent details

- Legal seams are within uninterrupted siding field or at a verified full unit boundary, preferably where a downspout, party-wall break, or complete trim stack proves the boundary.
- Forbidden seams include generated U resets and cuts through windows, doors, canopy edges, posts, gable/verge, gutters, downspouts, privacy fences, trellises, or end corners.
- Two-storey hierarchy, front/rear material family, and broad unit cadence: **high confidence**. Exact unit width, entrance alternates, canopy breaks, physical scale, and run endpoints: **unknown**.
- Do not bake cars, bins, satellite dishes, fences, landscaping, or tenant repairs into the facade; do not mirror one unit everywhere or wrap the front phase onto the rear.
- Readiness: complete front/rear unit families are specifiable after exact unit-boundary/run mapping.

## 1212 Mariner Drive observations

Exact receiver: `building:w96215649:wall`; 28 exterior wall segments / 115.696 m; generated from a frozen two-level tag and 6 m height.

### Identity, coverage, and visible facts

- Identity confidence is **high**. Google displayed 1212 Mariner Drive at the front viewpoint, and both official viewpoints align with the exact compact row footprint.
- Observed coverage: the complete public/front long elevation in March 2025 and the rear long elevation plus end in September 2025. The opposite end, narrow notches/returns, and exact receiver-run endpoints remain unobserved or unreconciled.
- The row reads as **two storeys**, compatible with the frozen two-level/6 m rule. Dominant field is light cool gray-blue horizontal lap/vinyl-like siding with white window trim, white gutters/downspouts, and a muted gray-brown very shallow gable roof.
- Front cadence repeats attached residential units. Each upper bay has one broad white-framed horizontal sliding window. Ground level alternates a broad window and a dark warm red-brown entry door, with short dark gray-blue privacy/bin wing fences near entries.
- No deep front porch canopy is established on this row. A thin continuous eave/roof edge and vertical downspouts are the strongest continuous registers.
- The rear has one upper sliding window and a smaller ground window per unit, with tall dark privacy fences/utility enclosures obscuring door and threshold details. The end gable has stacked rectangular windows and a simple white verge/eave.
- Cars, painted parking markings, bins, fences, satellite equipment, and landscaping are foreground/tenant/site objects, not facade modules.
- No masonry belt, decorative rib, storefront, large ground opening, or applied band is established.

### Candidate complete modules (production inference)

- **1212M-FRONT-UNIT**: one complete verified townhouse bay including its upper slider, ground window/door alternate, privacy-wing ownership, and surrounding siding.
- **1212M-REAR-UNIT**: one complete rear bay with upper and lower window states; the foreground privacy fence is excluded from the wall module.
- **1212M-END**: the complete gable-end composition as a unique region.
- **1212M-SIDING**: uninterrupted cool gray-blue siding field with course scale still uncalibrated.

### Seam contract, confidence, and do-not-invent details

- Legal seams are within uninterrupted siding field or at a verified complete unit boundary marked by a party-wall break, full trim stack, or downspout.
- Forbidden seams include generated U resets and cuts through any window, door, privacy wing, gutter, downspout, eave, gable/verge, end corner, or tenant/site object.
- Two-storey hierarchy, front/rear window families, and broad unit cadence: **high confidence**. Exact unit widths, alternating door/window schedule, hidden rear doors, material product, physical scale, and run endpoints: **unknown**.
- Do not assume 1212 and 1318 are texture-identical because they share a housing family; 1212's observed front lacks the pronounced multi-bay porch canopy seen at 1318. Do not wrap front phase onto the rear or bake cars/bins/fences into the wall.
- Readiness: front/rear complete-unit families are specifiable after exact unit-boundary/run mapping.

## Batch-level handoff

- Current official facade evidence is strong enough for conservative receiver specifications at Dormitory 369, the historical 449 Avenue H facade, historical 810 Avenue D, 1318 Gateview, and 1212 Mariner, subject to the scope limits above.
- 850 Avenue H has only a provisional exposed-end vocabulary; Building 461 has only a distant conservative gray-field/window read.
- Education Center 29B has no usable facade evidence. Its two current official viewpoints document occlusion/redevelopment only.
- Current-versus-frozen conflicts are material: 449 Avenue H is present in May 2011 but the footprint is a cleared lot in September 2025; 810 Avenue D is visible in May 2011 but fully enclosed in March 2025; Education Center 29B is entirely screened in both 2025 views; Dormitory 369 visibly has five tiers despite the runtime fallback height.
- No observation above is an attachment or massing authorization. Exact run ownership, module scale, and unique-region endpoints remain separate proof gates.

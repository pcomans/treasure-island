# Current Milestone Build and Verification Brief

## Owner-approved locomotion amendment (2026-08-28)

The original brief below required walking and running and excluded jumping. The owner explicitly superseded that behavior: **before:** walk/run/spray only; **after:** walking/running plus unlimited hold-to-rise jetpack flight on physical `Space`, slow capped descent on release, renewed ascent on another mid-air press, and existing spray/recovery behavior. This does not add terrain elevation, fuel, vehicles, or another dependency. The historical approach-neutral conclusion remains at the end for provenance; `DECISION_LOG.md` records the later approved Godot approach and this amendment.

## Purpose

This brief turns the approved first-playable milestone into build requirements and acceptance evidence without choosing an engine, runtime, world-production pipeline, decal technique, distribution method, or detailed camera behavior. It is sized for a private hobby project: preserve the complete island, use coarse reversible defaults, and capture only enough evidence to prove coverage and playability.

Implementation remains behind the charter's explicit approach-approval gate.

## Milestone boundary

The current playable must contain:

- Treasure Island proper as a complete island-scale exterior world derived from one frozen latest-available raw OpenStreetMap snapshot;
- simple massing for every in-scope exterior building footprint/building part in that snapshot;
- a third-person player who can walk, run, and use an unlimited hold-to-rise jetpack with mouse and keyboard;
- one predefined spray tag that can be placed on eligible exterior building surfaces;
- San Francisco as non-playable billboard background scenery;
- Yerba Buena Island and the Bay Bridge as simple non-playable polygonal scenery; and
- a working private-use launch path on the owner's M1 Pro MacBook Pro with 32 GB memory.

The current playable excludes interiors, apartments, rooms, individual-unit plans, detailed façade reconstruction, controller support, traffic, and drivable cars. Roads remain part of the complete island layout even though vehicles are deferred.

## Coverage contract

### Frozen source of truth

Acquire one bounded raw OSM vector extract with Treasure Island proper fully enclosed and freeze it before world conversion begins. Retain the original file, acquisition date, extract bounds, source endpoint, file checksum, and OSM attribution/license note. Do not reconcile that snapshot against a separate present-day inventory.

Before conversion, derive a human-readable coverage inventory containing each in-scope source element's OSM type, ID, useful tags, category, and derived-world status. The approved categories are:

- Treasure Island landform/shoreline geometry;
- roads and paths;
- major public-space and land-use areas; and
- exterior `building` and `building:part` footprints.

The inventory rules must handle ways, multipolygon relations, nested building parts, clipped boundary features, and overlapping source geometry without silently dropping an element. A source element may be represented by a composite object, but the inventory must point to that object. Feature detail can be coarse; source membership cannot be reduced because a feature is visually ordinary or inconvenient to convert.

Yerba Buena Island, the Bay Bridge, and San Francisco are contextual scenery and do not enter the Treasure Island feature-completeness denominator.

### Meaning of complete

Complete coverage means every in-scope source entry maps to visible derived geometry or to a documented parent/composite that visibly represents it. No in-scope entry remains missing, accidentally duplicated, or unresolved when the milestone is accepted.

A whole-island top-down comparison must show the frozen shoreline, road/path network, major public-space/land-use shapes, and building footprint pattern in their correct relative positions. Recognition by itself does not prove coverage, and a complete inventory by itself does not prove the island is recognizable in play; both outcomes are required.

## Requirements and acceptance evidence

| Area | Concrete requirement | Evidence that proves it |
|---|---|---|
| Frozen OSM coverage | The complete approved Treasure Island feature inventory is represented from one immutable raw OSM snapshot. | Preserved source record and checksum; coverage inventory mapping every in-scope OSM element to derived geometry or an identified composite; whole-island top-down source/derived comparison with no unresolved in-scope entries. |
| Simple building massing | Every in-scope building footprint/building part has a coarse exterior volume at the correct relative location. Tagged height/storey information may inform massing; missing values use one documented conservative default. No interiors or bespoke apartment modeling are introduced. | Coverage inventory records source geometry and whether source height data or the placeholder rule was used; whole-island and ground-level views show all masses; representative source-outline overlays show that volumes follow their footprints. |
| M1 Pro Mac and input | The selected private-use launch path works on the owner's Apple-silicon Mac, and ordinary full-world play remains responsive enough to walk, run, fly, look, and spray without a blocking crash, input failure, or resource failure. Mouse and keyboard are the only required inputs. | A launch record from the actual target Mac identifies the tested build and launch steps; a short ordinary-play capture and blocker log cover loading the full island, mouse look, keyboard movement, running, Space-held flight/slow descent, and spraying. Fixed benchmark targets are unnecessary unless a concrete problem requires diagnosis. |
| Third-person walk/run/jetpack | The avatar is visible from a third-person camera. Mouse look and keyboard movement allow walking, running, and unlimited Space-held jetpack flight to reach the island's distinct outdoor regions through the generally traversable snapshot world. Release produces a slow capped descent, another mid-air press renews ascent, and horizontal steering remains available. Real fence/private-access restrictions are not reproduced. Ordinary collision or stuck states have a simple recovery path. | A route trace or annotated capture from the actual playable shows connected ground/air travel across the north, grid/interior, southwest, and shoreline/perimeter portions of the full island; live metrics cover sustained ascent, air steering, slow descent, renewed ascent, and landing; blocker notes show no progression-stopping geometry; a normal collision/stuck recovery is demonstrated. |
| One predefined spray tag | A single predefined graphic can be placed visibly on an eligible exterior building surface. Ineligible targeting produces understandable feedback, and the player can immediately resume walking, running, or flying. Persistence across launches, an in-game drawing tool, and multiple tag choices are not required. | A short capture from the actual playable shows eligible placement, visible inspection of the result, ineligible-surface feedback, and resumed movement. The tag source is stored locally with lightweight provenance. |
| San Francisco billboard | San Francisco appears in the correct general mainland direction as non-playable billboard background scenery and contributes to island orientation without becoming a traversable world. | Ground-level views from Treasure Island show the billboard in the expected horizon relationship; boundary behavior prevents travel into the backdrop; the image or locally authored graphic has a source note. |
| YBI and Bay Bridge context | Yerba Buena Island and the Bay Bridge appear as simple polygonal non-playable scenery in the correct relative direction from Treasure Island. They do not require detailed buildings, road inventory, collision-rich traversal, or OSM completeness. | Whole-island and ground-level views show the recognizable southern connection and relative placement; ordinary traversal cannot cross into these scenery objects as playable extensions. |
| No cars in this milestone | The playable contains no drivable-vehicle controls, vehicle controller, traffic simulation, or car-dependent acceptance path. Complete road geometry is still present for place recognition and later work. | The milestone feature checklist and actual controls contain only walk, run, jetpack, look, recovery, and spray interactions; vehicle work appears only in the deferred backlog. |
| Recognizable and playable | In ordinary play, the owner recognizes Treasure Island without depending on a title card and can complete a walk/run/jetpack/spray-resume loop without a blocking failure. | The owner's brief play of the actual Mac build and concise notes provide the recognition and usability evidence. No advance questionnaire, scoring rubric, or timed protocol is required. |

## Material approach-selection criteria

A candidate approach only needs comparison on issues capable of making this milestone materially harder, costlier, or impossible:

- **OSM fidelity and traceability:** ability to ingest or convert raw OSM geometry, preserve source IDs/tags through a coverage inventory, handle relations/building parts, and regenerate the same frozen world without manual feature loss.
- **Whole-world feasibility:** ability to load, render, and collide with the full coarse island on the target M1 Pro Mac. A small test scene cannot substitute for eventual full-world evidence.
- **Current interactions:** practical third-person mouse/keyboard walking, running, unlimited jetpack lift/slow descent, collision/recovery, and visible spray placement on generated building walls.
- **Apple-silicon viability:** supported local authoring and private-use launch path on the owner's Mac without an avoidable emulation, account, or deployment burden.
- **Hobby effort and cost:** setup, conversion, iteration, debugging, and later re-entry remain reasonable for one person; prefer free or existing tools and avoid recurring infrastructure.
- **Reproducibility:** the frozen snapshot, conversion settings, generated outputs, and launch instructions can be kept locally and rebuilt without a fragile hosted dependency.

Detailed graphics ceilings, multiplayer, public distribution, online services, exact camera polish, and deferred vehicle capability are not current selection criteria. A candidate must not win merely because it makes a future car system attractive while weakening full-island coverage or the current walk/run/jetpack/spray milestone.

## Material risks and proportional controls

| Risk | Why it matters | Proportional control |
|---|---|---|
| Extract bounds omit a sliver or relation member | Completeness would be falsely claimed before conversion starts. | Inspect the full raw boundary and relation dependencies once, then freeze the validated source file and inventory. |
| OSM multipolygons, building parts, overlaps, or invalid geometry convert poorly | Buildings or public spaces may disappear, duplicate, or produce broken meshes. | Preserve source IDs, report unresolved conversions, and fix or explicitly composite them; never hide failures by reducing the inventory. |
| Missing height/elevation/material data invites bespoke research | The hobby project could turn into individual-building reconstruction. | Apply documented coarse defaults across the island. Refine only a visible recognition blocker using already available exterior references. |
| Full-world scale or coordinates cause precision and alignment faults | Roads, collision, spraying, or horizon scenery may drift apart. | Keep one coordinate transform for all island layers and verify it with the whole-island overlay and ground-level traversal. |
| Full-island rendering or collision overwhelms the target Mac | A technically complete world could still be unplayable. | Load the complete coarse island early, test on the actual Mac, and simplify representation or loading only in ways that preserve every inventory feature. |
| Generated collision creates barriers, gaps, or traps | The player may be unable to roam the complete outdoor world. | Traverse every island region, keep a simple recovery default, and treat blockers as geometry defects rather than reasons to remove areas. |
| Spray placement does not work consistently on generated walls | The signature interaction may fail after the data pipeline changes geometry. | Demonstrate the chosen spray family on actual generated island building surfaces before polishing it; keep receiver rules simple and inspectable. |
| Coarse massing loses Treasure Island's identity | Complete geometry might still read as a generic map. | Check recognition in the actual full playable and selectively clarify existing landmark masses, orientation, and context without starting façade-by-façade production. |
| Scope drifts toward interiors, cars, or detailed scenery | Effort moves away from the approved first playable. | Keep those items in the deferred backlog and review the coverage inventory plus current interaction checklist at each phase boundary. |

## Full-island build sequence

This sequence is independent of engine and pipeline choice. It is deliberately horizontal: every world-building phase reaches all of Treasure Island before detail deepens anywhere.

### Gate — select and approve an approach

Compare only the material criteria above and obtain explicit owner approval for the exact runtime/world-production approach and any required install, account, download, or spend. A disposable candidate fixture may inform that decision, but it is not part of the milestone and cannot redefine full-island scope.

### Phase A — freeze and inventory the whole source

Acquire the approved raw OSM extract, record its provenance and checksum, set the Treasure Island boundary, and produce the complete source feature inventory. Resolve category and relation-handling rules before conversion so later omissions are visible.

### Phase B — establish the full-extent island shell

Create the complete Treasure Island land/shoreline shape and represent the entire road/path, public-space/land-use, and building-footprint inventory at placeholder level. At this point every source entry has a visible location even if buildings are only footprint slabs and materials are flat colors. Add the simple YBI/Bay Bridge context and SF billboard orientation at coarse quality so directional mistakes surface early.

### Phase C — complete simple massing across all buildings

Turn every building footprint/building-part entry into a coarse exterior volume using source height/storey tags where available and the documented placeholder rule elsewhere. Finish the whole inventory before refining recognition-critical silhouettes. Attach only the collision and spray-receiver metadata needed by the current interactions.

### Phase D — make the entire island roamable

Add the third-person placeholder avatar, mouse look, keyboard walk/run/jetpack controls, exterior collision, world-boundary behavior, and a KISS recovery default. Exercise connected ground/air traversal across every island region with the full world loaded; correct gaps and blockers without deleting difficult source features.

### Phase E — add the one-tag interaction

Add the predefined local tag, eligible building-surface detection, visible placement, ineligible feedback, and immediate return to movement. Apply it to the actual generated massing rather than a separate demo wall. Tag-count and shoreline details remain reversible defaults unless they create a blocker.

### Phase F — verify and tune the complete Mac playable

Run the intended private-use launch path on the owner's M1 Pro Mac with mouse and keyboard. Collect the compact evidence bundle, fix blocking launch/performance/traversal/spray issues, and adjust coarse recognition cues only where ordinary play shows a real problem. The phase ends with full coverage still intact, not with a polished neighborhood slice.

## Compact verification bundle

Keep only:

- the frozen raw OSM file and source/checksum record;
- the source-to-derived coverage inventory;
- one whole-island source/derived comparison;
- the tested private-use build identity and launch notes;
- concise captures showing full-island context, connected third-person roaming, spray success/rejection, and background scenery;
- a blocker list with resolved or still-open status; and
- the owner's final recognition/playability note.

This is sufficient for a hobby-scale completion audit. Telemetry, formal test suites, performance dashboards, exhaustive edge-case matrices, and public-release packaging are unnecessary unless a concrete failure makes one of them useful.

## Likely resource and access needs

- **Already available:** one free bounded raw OSM vector extract (`NEED-004`) with recorded provenance, hashes, exact TI boundary, and neutral inventory. No account or paid dataset is needed.
- **Already available:** the owner's M1 Pro MacBook Pro, mouse, and keyboard for the actual acceptance run (`NEED-003`).
- **Locally creatable:** one simple original predefined tag graphic. Image generation, an asset store, and commissioned art are unnecessary for the first playable.
- **Available if needed:** a locally authored or free public-source San Francisco skyline image and limited exterior references under `NEED-002`, with lightweight source notes. No currentness audit or dedicated photo trip is required.
- **Candidate-specific proposal:** the separate approach proposal names the free Godot editor/templates and two free local geometry packages with exact roles and fallbacks. Nothing is implicitly authorized by this brief.

No paid asset pack, hosted backend, additional compute, analytics, controller hardware, vehicle asset, or image-generation access is currently needed.

Historical discovery conclusion retained: **No approach selected.** The later approved Godot choice and jetpack amendment are authoritative in `DECISION_LOG.md`.

# Feasibility and Evaluation

> **Historical scope note (2026-08-28):** This option-family analysis predates the owner-approved jetpack amendment. Its walk/run-only statements describe the original milestone input; the current loop is walk/run/unlimited Space-held jetpack/spray, as recorded in `DECISION_LOG.md` and `GODOT_IMPLEMENTATION_WORK_ORDER.md`. The analysis remains historical and does not override that later decision.

## Status and scope

- Discovery artifact only.
- Research baseline: 2026-08-27.
- Scope: a private hobby game covering Treasure Island, San Francisco only, at island scale.
- Longer-term approved game ambition: recognize and roam the island, drive cars with arcade-acceptable handling, and place Half-Life 1-like spray-tag decals on building exteriors.
- Approved **current first-playable milestone**: explore the complete island exterior in third person with walk and run movement, and place one predefined spray-tag graphic. Cars and arcade driving are deferred to a later milestone, not removed from the game ambition.
- Approved world-coverage requirement: represent complete Treasure Island terrain and shoreline, the full known road network, major public spaces, and every known exterior building footprint with defensible massing.
- Simple exterior building massing is approved for the current milestone. “Complete” does not imply interiors, apartments, rooms, individual-unit plans, bespoke façade detail, or survey-grade reconstruction.
- Current outdoor-access rule: generally allow third-person traversal through outdoor island areas; do not research or reproduce real-world fenced/private-area access restrictions for this milestone.
- Approved target and input: the owner's MacBook Pro with an M1 Pro 10-core processor and 32 GB memory, using mouse and keyboard only. Record the macOS version with a test result when useful; retain no device identifiers. No controller or alternate-platform work is a current gate.
- Approved background treatment: San Francisco is a non-playable billboard backdrop, not a playable or frozen-OSM coverage area. Use a reversible $0 local art default and record its provenance; do not ask for a cosmetic preference up front.
- Approved spatial split: complete feature-by-feature frozen-OSM coverage applies to Treasure Island proper. Yerba Buena Island and the Bay Bridge are simple non-playable polygonal scenery, not detailed coverage inventories; San Francisco remains a non-playable billboard.
- Approved island-layout data baseline: the latest raw OpenStreetMap vector extract acquired at build/acquisition time will be frozen for the project. All in-scope Treasure Island features in that snapshot define “known” layout coverage; OSM currentness will not be re-audited against other sources.
- These decisions do not select an engine, framework, runtime, Mac distribution method, exact third-person camera behavior, visual style beyond the approved simple massing and SF billboard constraints, map-production/conversion method, world scale, movement implementation, deferred vehicle implementation, decal implementation, persistence model, or supplemental content source.
- Option-family order has no significance.
- Any later experiment involving code, downloads, installations, accounts, paid resources, or assets needs separate authorization.

## Evidence labels

- **Verified fact**: directly supported by a cited primary source checked on the research baseline.
- **Option family**: a materially distinct way the project could be constructed; it is not a proposal.
- **Inference**: a consequence that appears plausible but has not been measured for this project.
- **Open question**: an unresolved product or technical dependency.

## Approved-brief feasibility baseline

The following are the current player-facing and coverage feasibility gates:

1. The owner can recognize Treasure Island from the playable world without relying on a title card.
2. The player can walk and run in third person along a representative island route and generally traverse outdoor areas without a progression blocker based on real-world fence/private-access status.
3. The player can recover from an ordinary walking collision, geometry snag, or stuck state without manually restarting the whole project.
4. The player can place and inspect the one predefined spray-tag graphic on at least one intended exterior building surface.
5. The player can resume walking or running after spraying without a blocking failure.
6. The approved Treasure Island boundary has continuous terrain and shoreline coverage, the full baseline road inventory, every baseline major public space, and every baseline exterior building footprint represented.
7. Each building representation has simple, defensible exterior massing: its frozen OSM footprint/building-part geometry is traceable, tagged height/storey information is used where present, and missing massing data receives a documented conservative placeholder volume.

Recognizable Treasure Island and a playable third-person walk-run-spray loop are approved co-primary outcomes. Hobby cost, maintenance, launch burden, and re-entry effort remain pragmatic constraints. If actual candidates expose a material conflict, present the exact before → after difference and request only that choice.

The interaction check may use a representative walk/run route, but detailed coverage remains island-wide across Treasure Island proper. Third-person camera, placeholder-avatar, color, shoreline/water, and spray-count-limit details use reversible defaults. Record only concrete recognition, traversal, spray, comfort, launch, or performance blockers. Only shoreline geometry coverage is currently required.

### Explicit owner-approved before → after milestone change

| Area | Before | After |
|---|---|---|
| Current first playable | Roaming, arcade car driving/recovery, and spray placement were all current gates; perspective was open. | Third-person walk/run and one predefined spray tag are current interaction gates. Cars, driving feel, vehicle recovery, drivable-road rules, and vehicle access move to a later milestone. |
| Outdoor access | Whether roads/areas followed real fenced, private, or public access status was unresolved. | Outdoor traversal is generally allowed; real-world fence/private-access research and legal-access reproduction are skipped for the current milestone. |
| Exterior building fidelity | Every footprint required defensible massing, but the initial detail level remained open. | Simple exterior massing is approved initially: source-traceable footprint/building-part volumes with tagged height/storey data where available and documented conservative placeholders where absent. |
| Full-island coverage | Complete frozen-OSM exteriors were required. | Unchanged: the complete frozen-OSM terrain/shoreline, roads/paths, major public spaces/landuse, and exterior building/building-part inventory remains required. |
| Target and input | Target device and input devices were open. | The owner's MacBook Pro with M1 Pro 10-core and 32 GB memory, using mouse and keyboard only, is the current acceptance target; no identifiers are retained. |
| Third-person camera detail | Perspective and camera details were open product dependencies. | Third person is fixed, but the owner has no camera-detail preference. Use a simple candidate-local default and escalate only a blocking visibility, targeting, control, or comfort issue. |
| San Francisco background | Mainland/background treatment was open. | San Francisco is a non-playable billboard backdrop; use a reversible $0 local art default and record its provenance. |
| Shoreline behavior | Boundary treatment was open. | Water contact, blocking, falling, swimming, reset, or other shoreline behavior uses a reversible local default and does not gate the current milestone; complete shoreline geometry still does. |
| Island and bridge context | “The island as polygons” was ambiguous about Yerba Buena Island and the Bay Bridge. | Treasure Island proper receives complete feature-by-feature coverage. Yerba Buena Island and the Bay Bridge are simple non-playable polygonal scenery; SF is a billboard. |

## Approved full-island coverage contract

### Included

- continuous terrain and complete shoreline edges for Treasure Island proper;
- every in-scope road/path feature in the frozen OSM snapshot, including its network relationship and retained source tags;
- every in-scope major-public-space/landuse feature in the frozen OSM snapshot, represented by its outer shape, placement, and broad tagged role;
- every in-scope exterior building/building-part footprint in the frozen OSM snapshot, represented at the correct relative location with defensible massing;
- the exterior collision/query surfaces needed for third-person walk/run traversal, world boundaries, and the current one-tag spray interaction;
- simple non-playable polygonal silhouettes for Yerba Buena Island and the Bay Bridge, plus the non-playable SF billboard; these context elements are not feature-by-feature inventories.

### Not implied

- building interiors, rooms, apartments, individual units, interior circulation, or floor plans;
- bespoke façade reconstruction for every building, exact windows/doors, interior furnishings, or hidden structure;
- survey-grade terrain, curb, roof, or shoreline accuracy;
- every temporary object, fence, parked vehicle, construction tool, sign, tree, or street-furniture item;
- research or faithful enforcement of real-world fenced/private-area, legal-entry, or public-access restrictions; the current milestone generally permits outdoor traversal;
- current vehicle control, traffic, vehicle access, vehicle recovery, or drivable-road authoring; those remain later game work;
- playable San Francisco mainland geometry or SF feature coverage; the approved SF billboard is background only;
- detailed roads, buildings, public spaces, traversal, collision, or feature-by-feature completeness on Yerba Buena Island or the Bay Bridge; those are simple non-playable scenery;
- a specific shoreline interaction such as collision, falling, swimming, reset, or invisible barriers; those behaviors are open and non-gating;
- a particular world scale, exact third-person camera implementation, visual style beyond simple exterior massing, data pipeline, or production order.

### Operational meaning of “known” and “defensible”

Before completeness can be tested, the project must acquire and freeze one raw OSM vector snapshot with Treasure Island proper fully inside its bounds and enough adjacent extent to derive the simple Yerba Buena Island/Bay Bridge scenery polygons. Preserve its acquisition time, extract bounds, source/license notice, and file checksum. “Known” detailed coverage means an in-scope Treasure Island proper OSM terrain/shoreline, road/path, major-public-space/landuse, building, or building-part feature in that snapshot. Yerba Buena Island, the Bay Bridge, and the SF billboard are outside the feature-by-feature completeness denominator.

“Simple, defensible massing” means that exterior footprint/building-part location and outline remain traceable to the frozen OSM elements and may be represented as broad exterior volumes. Height, storey, roof, or level tags inform those volumes when present. When those tags are absent or incomplete, a documented conservative placeholder height/volume is acceptable. The numeric placeholder and authoring/conversion method remain implementation details, not a new fidelity decision; no external currentness reconciliation, interior, or bespoke façade invention is required.

The frozen OSM snapshot also fixes the planimetric terrain/shoreline layout baseline, not a terrain-elevation dataset. If it does not contain usable elevation information, use and record a conservative placeholder exterior terrain profile; this is a reversible implementation default and cannot imply survey-grade topography. The geometric requirement does not settle or gate player behavior at the shoreline.

### Hobby-scale feasibility consequence

The smaller interaction milestone is technically plausible across multiple option families, but project-level hobby feasibility is not yet demonstrated because full Treasure Island proper exterior coverage remains substantial. Freezing one OSM snapshot removes multi-source currentness work; approving simple massing and permissive outdoor traversal removes bespoke-building and real-access research; treating Yerba Buena Island/Bay Bridge/SF as lightweight non-playable context avoids expanding detailed coverage; deferring cars removes vehicle work; and fixing the target Mac plus mouse/keyboard narrows device work. The dominant uncertainties are OSM relation/tag/building-part interpretation, complete simple-massing conversion and QA, blocker-level third-person traversal, one-tag spray placement, and full-world behavior on the target Mac.

## Current primary-source anchors

These sources establish that the option families below are technically real or expose a specific evaluation risk. They are examples of capabilities, not endorsements or selections. All were checked 2026-08-27.

| Area | Verified fact | Primary source | Evaluation consequence |
|---|---|---|---|
| Browser rendering | WebGL 2 defines an immediate-mode 3D graphics API for an HTML canvas, based on OpenGL ES 3.0. | [Khronos WebGL 2 specification](https://registry.khronos.org/webgl/specs/latest/2.0/) | Browser-hosted 3D is an option family; actual device/browser compatibility and performance still require measurement. |
| Browser rendering | WebGPU was a W3C Candidate Recommendation Draft dated 2026-07-14 and exposes GPU rendering and computation. | [W3C WebGPU publication page](https://www.w3.org/TR/webgpu/all/) | A newer browser GPU path is an option family, but draft status and target-browser support must be recorded rather than assumed. |
| Browser mouse input | Pointer Lock defines unbounded relative mouse motion while locked. | [W3C Pointer Lock 2.0](https://www.w3.org/TR/pointerlock-2/) | Browser-hosted mouse-look is a factual capability family; focus and pointer-lock behavior still require a blocker-level check on the owner's Mac. No gamepad work is currently required. |
| Browser persistence | IndexedDB defines asynchronous local storage for keyed records and indexes. | [W3C Indexed Database API 3.0](https://www.w3.org/TR/IndexedDB/) | Local browser persistence is an option family; quota, clearing, migration, and failure behavior require a later test if spray persistence is approved. |
| Code-first native runtime | SDL's official documentation illustrates a current cross-platform low-level library family exposing graphics hardware, keyboard, mouse, and joystick access. | [SDL official repository documentation](https://github.com/libsdl-org/SDL/blob/main/docs/README.md) | A code-first packaged-runtime family is technically distinct from a browser or editor-led family; integration effort must be measured rather than inferred. |
| Raw OSM vectors | OpenStreetMap's official export page offers raw OSM data for a selected area and identifies ODbL licensing; OSM's copyright page permits copying and adapting the data with attribution and applicable share-alike obligations. | [OpenStreetMap Export](https://www.openstreetmap.org/export/), [OpenStreetMap copyright and license](https://www.openstreetmap.org/copyright) | A bounded raw-vector snapshot is an allowed $0 island-layout baseline for its roads/paths, building footprints/parts, landuse/public-space tags, and coastline/shoreline features. Actual tag/geometry coverage must be inventoried after acquisition, but its real-world currentness is accepted by convention and will not be cross-audited. It does not supply sufficient terrain elevation, building heights, façades, or exterior materials in every case. |
| OSM public tile services | OSMF states that its data is free but its standard raster and vector tile servers are capacity-limited, best-effort services; both policies prohibit bulk tile downloading for archives/offline use. | [OSMF raster tile policy](https://operations.osmfoundation.org/policies/tiles/), [OSMF vector tile policy](https://operations.osmfoundation.org/policies/vector/) | Public OSM tiles are distinct from raw OSM vectors and are not the approved full-island/offline source. No tile scraping, prefetching, or bulk/offline dependency is authorized. |
| Deferred vehicle simulation | The PhysX 5.6.1 vehicle documentation is one primary example of a sprung-mass vehicle family using per-suspension scene queries, tire forces, and raycast or sweep alternatives with different cost/behavior. | [NVIDIA PhysX 5.6.1 Vehicles](https://nvidia-omniverse.github.io/PhysX/physx/5.6.1/docs/Vehicles.html) | This preserves a factual anchor for later vehicle research only. Vehicle physics, arcade tuning, and recovery are not current milestone criteria or candidate gates. |
| Decals | Current Epic documentation describes projected decal volumes and mesh decals, including receiver filtering and overlapping order. Three.js documents a generated decal-mesh family and warns that projection may distort around corners. | [Epic Decal Materials](https://dev.epicgames.com/documentation/en-us/unreal-engine/decal-materials-in-unreal-engine), [Three.js DecalGeometry](https://threejs.org/docs/pages/DecalGeometry.html) | Projected and surface-mesh approaches are real families. The current gate is one predefined tag on an intended building exterior; receiver filtering, corner, seam, overlap, and accumulation checks activate only if the chosen behavior or geometry makes them relevant. |
| Accessibility | Xbox Accessibility Guideline 107 covers alternative/remappable input, sensitivity, prolonged holds, and digital equivalents; Guideline 117 covers camera movement, shake, blur, sensitivity, and field of view. | [Microsoft XAG 107: Input](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/107), [Microsoft XAG 117: Motion settings](https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/117) | The first playable should expose obvious barriers and the cost of modest mitigations even though a broad accessibility feature set is not an approved hobby scope. |
| Quality model | ISO/IEC 25010:2023 defines a product-quality model intended to support requirements, testing objectives, acceptance criteria, and measures throughout a lifecycle. | [ISO/IEC 25010:2023](https://www.iso.org/standard/78176.html) | It supplies a question bank. For this hobby project, player-facing blockers drive acceptance while performance and maintainability remain proportionate diagnostics unless the owner approves thresholds. |
| Open creative works | Creative Commons offers multiple licenses and CC0 with materially different attribution, commercial-use, adaptation, and share-alike conditions. | [Creative Commons license overview](https://creativecommons.org/share-your-work/cclicenses/) | “Creative Commons” alone is not sufficient provenance. The exact license, version, creator, URL, and allowed adaptations must be captured per item. |

## Unranked option landscape

### Runtime and platform families

#### Browser-hosted realtime application

**Definition:** the playable runs inside a desktop or mobile browser using browser graphics, input, audio, and local-storage APIs, with any authoring tools remaining separate.

**Actual-candidate blocker check:** on the target Mac, record whether the candidate launches and loads the full exterior world, accepts mouse/keyboard walk-run-spray input, and avoids a browser/focus/network blocker. Persistence is outside the current milestone.

#### Packaged application produced by a general-purpose realtime editor/runtime

**Definition:** scenes, interactions, assets, and builds are assembled in an integrated realtime toolchain and exported as a local application.

**Actual-candidate blocker check:** on the target Mac, record whether the candidate can import and present the complete exterior inventory, run the walk-run-spray milestone, and produce a playable without an account, licensing, export, plugin, or recurring-cost blocker.

#### Code-first packaged application assembled from realtime libraries

**Definition:** a local application is composed from lower-level rendering, input, audio, physics, asset, and platform libraries rather than relying primarily on an integrated editor.

**Actual-candidate blocker check:** record whether the candidate can organize, render, collide with, and rebuild the complete exterior inventory on the target Mac without a material custom-tooling or dependency blocker.

#### Mod/map inside an existing user-owned game or creation runtime

**Definition:** the island experience is authored within an existing runtime's supported mapping, scripting, character, and material systems.

**Actual-candidate blocker check:** record whether an already-owned host can carry the complete exterior inventory and walk-run-spray milestone under its map/content limits and private-use terms without a live-service or account blocker.

No runtime family is presumed able or unable to carry the full exterior world and current walk-run-spray milestone until candidate-specific limits and an owner-device proof are available. Future vehicle support may be noted, but it is not a current elimination or acceptance criterion.

### World-construction families

#### Manual reference-based blockout

The complete terrain/shoreline, road/path inventory, public spaces/landuse, and exterior building masses are placed or modeled by hand while retaining one-to-one traceability to the frozen OSM snapshot. Geography may be literal or interpretive; that is a separate decision.

**Actual-candidate blocker focus:** source-ID traceability, omissions, collision burden, and impractical repeated correction.

#### Geodata-assisted construction

The frozen raw OSM roads/paths, building footprints/parts, coastline, landuse, public-space, and other in-scope vectors are transformed into scene geometry, then reviewed for conversion correctness. The conversion, cleanup, and scene-authoring pipeline remains undecided.

**Actual-candidate blocker focus:** coordinate/geometry corruption, OSM relation or building-part misinterpretation, lost source IDs, licensing, and impractical cleanup.

#### Parametric or procedural construction

Rules interpret frozen OSM tags/geometries into roads, exterior masses, public-space surfaces, repeated props, or materials, with exceptional and recognition-critical forms handled according to a separately chosen rule.

**Actual-candidate blocker focus:** unhandled source exceptions, lost traceability, unusable collision, or rule/debugging burden that defeats hobby scope.

#### Capture- or reconstruction-assisted construction

Approved exterior capture/reconstruction material may contribute optional visual or massing detail while the frozen OSM snapshot remains the layout/completeness baseline. No acquisition source is implied, and interiors remain excluded.

**Actual-candidate blocker focus:** source terms, lost OSM traceability, unusable collision/occlusion, or cleanup that adds workload without helping the current milestone. No currentness pass is required.

#### Hybrid construction

Two or more families interpret the same frozen OSM layout baseline, such as data-assisted roads and footprint masses with manually authored placeholder heights or optional landmark detail.

**Actual-candidate blocker focus:** unstable source-ID mapping, unit/coordinate mismatch, incomplete reporting, or hybrid seams that materially obstruct the playable.

#### Unranked coverage-planning patterns

The coverage requirement does not select a production order. Possible patterns include a full-extent coarse exterior shell followed by optional refinement; completion by spatial sector; completion by layer such as terrain/shoreline, roads, public spaces, and buildings; tag-completeness-led work that handles source-tagged massing before placeholders; or concurrent full-island production without formal stages. Staged detail or validation may reduce omission risk, but it is only a planning option until explicitly chosen.

### Visual-production families

#### Primitive or graphic blockout

Complete exterior coverage is pursued through footprint silhouette, placement, broad height/roof volumes, proportions, color grouping, signage placeholders, and a limited material vocabulary.

#### Modular authored assets

Reusable exterior building, road, curb, vegetation, and furniture pieces are assembled across the full inventory, with any custom landmark work remaining a separate detail choice.

#### Photo-referenced authored visuals

Exterior models and materials are authored from separately approved photographs or imagery without directly reconstructing every source pixel, façade element, room, or surface. Such imagery may refine appearance but does not alter the frozen OSM layout baseline.

#### Reconstruction-derived visuals

Approved exterior captures or scans contribute mesh or texture detail, followed by cleanup and runtime preparation; their presence does not expand scope into interiors.

#### Generated or transformed media

An approved generative or transformation tool contributes reference images, textures, signs, props, or spray art under recorded terms, followed by human review and provenance notes.

#### Mixed visual production

Different asset classes use different production families while maintaining whatever visual coherence criterion is later approved.

Across visual families, inspect the actual playable only for unaided Treasure Island recognition, readable movement/spray surfaces, complete simple massing, and any concrete visibility or comfort blocker. Missing OSM attributes remain visibly conservative placeholders. Do not run a broad visual-preference interview.

The San Francisco mainland background is already constrained to one non-playable billboard. Use a reversible $0 local art default with recorded provenance; its placement and scale are local implementation details unless recognition is blocked. It does not select the island's visual-production family or add SF geometry to the coverage inventory.

Placeholder-avatar shape, ordinary-building colors, water appearance/response, camera tuning, and spray placement-count limit use simple reversible defaults. They are inspected only for a visible core-loop, recognition, comfort, or performance blocker and are not owner approval gates.

No visual family is presumed to require bespoke treatment of every building. Coverage completeness and exterior detail level remain separate evaluation dimensions.

### Deferred future arcade vehicle-behavior families

This entire subsection is retained only because cars remain part of the longer-term game ambition. It is **not** a current milestone gate, comparison criterion, experiment dependency, acceptance row, or resource request. No current runtime or world family should be selected, ranked, or eliminated on vehicle behavior without a later explicit vehicle milestone.

#### Direct or kinematic controller

Velocity, acceleration, steering, grip, and orientation are driven primarily by authored curves or rules, while collision and recovery may be handled separately.

#### Simplified rigid-body controller with arcade assists

A rigid body receives forces or impulses, with authored stability, steering, traction, downforce, speed limiting, or recovery assists. The presence and strength of any assist remain undecided.

#### Suspension- and wheel-query controller

Wheel contact is estimated using raycasts, sweeps, or another suspension query and contributes tire/suspension forces to a chassis. Physical detail and arcade assists remain separate variables.

#### Prebuilt or template vehicle controller

A runtime-, framework-, plugin-, sample-, or asset-provided controller supplies an initial behavior that is configured or extended. No provider or source is implied.

#### Hybrid vehicle behavior

Different systems govern normal driving, collision response, low-speed correction, respawn/recovery, or special cases. Transitions and player-visible consistency become evaluation subjects.

Complete road representation remains a current world-coverage requirement but does not make roads drivable in the current milestone. Drivable subsets and vehicle collision/detail treatment are deferred.

### Spray/decal interaction families

The owner has selected the constraint of one predefined spray-tag graphic for the current milestone. Its exact reversible art can be a simple project-authored $0 placeholder with provenance; it is not an owner-choice gate. The representation used to place it remains open. Current acceptance needs one understandable successful placement on an intended exterior building surface; multiple tag designs, island-wide bespoke receiver authoring, overlap policy, erasure, accumulation limits, and cross-session persistence are not current gates unless the selected interaction exposes a blocking dependency.

#### Pre-authored receiver slots or planes

Sprays attach to explicitly placed surfaces or zones with predetermined bounds and orientation.

#### Surface-aligned mesh or quad

A small mesh is placed at the hit point, aligned to the surface normal, offset to reduce depth conflict, and clipped or rejected according to separately chosen rules.

#### Projected decal volume or generated decal geometry

The spray is projected onto receiver geometry or clipped into a generated overlay mesh. Receiver filters and projection depth/angle remain open.

#### Texture or render-target stamping

The spray is written into a mutable surface texture, atlas, mask, or render target rather than represented as an independent overlay object.

#### Hybrid spray representation

Different surface classes use different representations, or a simple representation is replaced with another at save/load or distance boundaries.

#### Receiver-identification families

The intended exterior receiver could be expressed through a pre-authored zone, object tag, collision/query layer, material metadata, receiver mask, geometry class, or combination. The current milestone needs enough receiver identity for one reliable placement; a universal island-wide eligibility contract is deferred unless the chosen interaction requires it.

#### Persistence families held open but not currently gated

- session-only spray placements;
- saved placement records containing a receiver identity and placement data;
- saved world/material texture state;
- no persistence until later.

Persistence remains unresolved and is not required for the current milestone. No experiment should silently turn one of these into the product contract.

For an actual candidate, record the fixed placeholder file/provenance and confirm one intended exterior receiver produces an understandable tag without blocking spill onto nearby geometry. Range, size, orientation, feedback, and placement count use reversible defaults. Corner wrapping, multiple designs, overlap, erasure, universal eligibility, and persistence remain later work.

The island-wide building inventory increases receiver/eligibility consistency work but does not select how eligibility is represented.

### Content-sourcing families

#### Owner-authored placeholders and originals

Primitive geometry, simple materials, signs, sounds, and the predefined spray graphic or its placeholder are created specifically for the project. Vehicle proxies are future content rather than a current need.

#### Owner-captured references

Existing exterior photographs, video, measurements, or audio may inform optional appearance/detail after location, privacy, and safety considerations are acknowledged. None is required to revalidate OSM currentness.

#### Open-government data and media

City, state, or federal elevation, imagery, reports, or photographs may be used later as supplemental exterior detail under the exact terms recorded for each item. They do not replace or cross-audit the approved OSM layout baseline unless the owner separately changes that decision.

#### Community geodata

The frozen raw OSM vector snapshot is the approved $0 island-layout baseline for its in-scope roads/paths, exterior building footprints/parts, coastline/shoreline, and landuse/public-space features. Its ODbL attribution and applicable derived-database obligations must be recorded. The extraction/conversion/rendering method remains open.

#### Public OSM map tiles are not the raw-data baseline

Raster or vector tiles served from OSMF's public tile servers are rendered services, not a substitute for the raw snapshot. Their policies prohibit bulk/offline tile downloading, so no full-island tile scrape, prefetch, archive, or runtime dependency is authorized.

#### Openly licensed creative assets

Models, textures, sounds, fonts, icons, or images are used under a specific permissive, Creative Commons, or other open license.

#### Commercial one-time assets

An asset pack or tool is purchased once under terms compatible with private project use. No purchase is requested here.

#### Generated media

An approved service or local tool creates or transforms content, with provider terms, prompt/source provenance, output date, and later edit history recorded.

#### Existing user-owned runtime content

Content remains inside a host runtime or mod environment under its supported private-use terms rather than being copied into a standalone project.

#### Lightweight content-source ledger

Create a ledger entry only when a nontrivial external source is shortlisted for comparison or integrated into project work. Broadly cataloguing every explored source is unnecessary. For each shortlisted or integrated item, record only what is relevant from:

- stable item identifier and local derived-file identifier;
- title/description and content type;
- creator, publisher, or data steward;
- source URL and access date;
- actual capture/content/data date when known;
- portal or metadata update date separately;
- exact license name/version or applicable private-use terms;
- attribution text and where it must appear;
- modification/derivative and redistribution constraints;
- original and derived formats;
- transformations performed;
- one-time and recurring cost;
- uncertainty or missing evidence.

For the frozen OSM snapshot, also record extract bounds, acquisition timestamp, file checksum, OSM element IDs/version data retained by the format, the exact raw-data acquisition route, and the required attribution/license notice. Do not record a separate currentness audit.

Private use reduces public-release work but does not make unrecorded or incompatible source terms irrelevant. A metadata-only ledger dry run is not required before shortlisting; uncertain terms simply remain a reason not to integrate that source yet.

## Material dependencies only

The target and current scope are fixed: MacBook Pro/M1 Pro 10-core/32 GB with mouse and keyboard; complete detailed Treasure Island proper; simple non-playable YBI/Bay Bridge polygons; SF billboard; third-person walk/run; one fixed tag. Do not reopen those as interview topics.

The OSM audit needs one frozen raw extract, retained element IDs/tags, a recorded in-scope tag mapping, relation/building-part handling, and a consistent simple-massing placeholder convention. An actual playable needs one intended spray receiver. World scale or recognition detail becomes a decision only when an actual candidate exhibits a material blocker.

## Approach-neutral risk register

| Risk | How it could block or distort the first playable | Discovery control or later test |
|---|---|---|
| Completeness is claimed without the frozen raw OSM artifact | “Every known” becomes impossible to audit and a later live map can silently change the target. | Preserve the authorized raw extract, acquisition timestamp, bounds, checksum, attribution/license, retained element IDs, and in-scope tag mapping before a coverage-complete claim. |
| Context scenery expands into detailed coverage | Yerba Buena Island or the Bay Bridge can silently acquire road/building/traversal requirements and erase the intended KISS boundary. | Audit every detailed feature only on Treasure Island proper; represent YBI and the bridge as simple non-playable polygons and exclude their internal features from the completeness denominator. |
| OSM feature semantics are misread | Multipolygons, building parts, shared nodes, paths, coastline, or landuse tags can be duplicated, dropped, or assigned the wrong class. | Audit frozen element IDs and source tags through conversion; completeness tests target source-to-derived mapping, not real-world currentness. |
| Full coverage is mistaken for universal bespoke detail | Attempting unique façades, windows, roofs, props, or interiors for every footprint can make the hobby project infeasible. | Enforce the approved exterior-massing boundary; evaluate coverage and optional detail as separate dimensions. |
| OSM height/roof tags are absent or partial | Footprints alone do not establish height, storey count, roof silhouette, or terrain elevation. | Apply the approved simple-massing boundary through a documented conservative placeholder convention and retain a tag-present/tag-missing indicator; do not initiate a currentness or façade survey. |
| Coordinate or geometry conversion changes layout | Projection, precision, ring winding, simplification, or clipping can shift or corrupt source features. | Retain source IDs/checksum and run source-to-derived count/topology/gross-bounds checks after each authorized conversion. |
| Full-extent runtime cost is hidden by partial tests | A route-only test can run well while the complete exterior world causes load, memory, visibility, collision, or build-time blockers. | Require one full-inventory placeholder proof on the target Mac before a runtime/world combination is selected, but only after exact candidates and the inventory exist. |
| Recognition is treated as geometric completeness | Complete OSM-derived geometry may still lack the visual cues the owner uses to identify Treasure Island. | Run the unaided owner check first; only after a failure, record the cues the owner expected and investigate the smallest relevant detail change. |
| Visible geometry and collision diverge | Walking, running, or spraying fails at invisible walls, gaps, snags, or mismatched receivers. | Check the representative walk/run route and intended spray receiver first, then perform an island-wide missing/duplicate/gross-alignment audit before claiming coverage completion. |
| Real-world access research expands the milestone | Cataloging fences, private parcels, access hours, or legal entry rules adds work that the permissive traversal decision explicitly removed. | Do not research or reproduce real-world access restrictions for the current milestone; use only world extent, solid-building collision, and clearly necessary playability boundaries. |
| Deferred cars leak back into current selection | Vehicle plugins, physics, drivable-road cleanup, traffic, or car-ready architecture can dominate research before the walking milestone is proven. | Keep all vehicle families out of current gates, QA rows, experiments, comparisons, and resource requests; reopen them only for an explicit later vehicle milestone. |
| SF billboard scope expands into a playable city | A skyline cue can turn into mainland geometry, travel, collision, or a second mapping problem. | Keep San Francisco to one non-playable billboard background using a reversible $0 local art default; exclude it from OSM completeness, collision, and traversal. |
| Acceptance is not run on the known target Mac | Rendering, memory, packaging, and browser/native behavior may be mischaracterized despite known specifications. | Run acceptance on the MacBook Pro/M1 Pro 10-core/32 GB with mouse and keyboard; record macOS/build versions locally and no identifiers. |
| Source provenance is incomplete | Assets become hard to reproduce, replace, credit, or safely keep even in a private project. | Add a lightweight ledger entry when a nontrivial external source is shortlisted or integrated; do not inventory discarded browsing candidates. |
| Public OSM tiles are confused with raw data | Bulk/offline tile fetching can violate OSMF service policy and create an unnecessary network dependency. | Acquire one authorized raw vector extract; do not scrape, prefetch, archive, or depend on `tile.openstreetmap.org` or `vector.openstreetmap.org` for the island baseline. |

## Evaluation design

### Qualitative blocker check on an actual playable

On the target Mac, launch the actual build, ask for unaided Treasure Island recognition, walk and run the representative outdoor route, recover from an ordinary geometry snag, place the fixed tag on the intended exterior receiver, and resume movement. Record the build and local macOS version, mouse/keyboard mapping, pass or concrete blocker, recovery result, and the owner's brief words. Record no device identifiers, timer, score, repeated-trial protocol, or speculative telemetry.

Coverage evidence is separate: retain a source-to-derived mapping of frozen OSM element IDs/types/tags to represented, missing, duplicate, or placeholder-massing state. Capture extra media or technical detail only to reproduce a concrete blocker. If actual candidates both pass but expose a material conflict, show the exact before → after difference and request only that choice.

### Current qualitative acceptance rubric

| Area | Pass condition | Evidence |
|---|---|---|
| Recognizable setting | The owner identifies Treasure Island from the playable world without a revealing title or prompt. | First unaided response and any expected cue named only after a failure. |
| Context scenery | SF remains a non-playable billboard; YBI and the Bay Bridge remain simple non-playable polygons. | Brief scene and collision inspection plus source/provenance note. |
| Third-person walk/run | On the target Mac with mouse and keyboard, the player walks, runs, controls the view, and traverses the representative outdoor route without a fence/private-access-status blocker. | Pass or concrete blocker, recovery note, local build/macOS identity, and no device identifier. |
| Recovery | The player resumes movement after an ordinary geometry snag without restarting the project. | Triggering state and recovery result. |
| Predefined spray | The fixed tag appears understandably on the intended exterior receiver without blocking spill. | Fixed-art provenance and placement result. |
| Complete current loop | Recognize, walk/run, spray, and resume movement without a blocking failure. | Brief pass/blocker note. |
| Terrain and shoreline | Treasure Island proper's frozen terrain and shoreline are continuous; YBI/bridge context is present. | Frozen snapshot/checksum and source-to-derived feature mapping. |
| Roads and public spaces | Every in-scope frozen OSM road/path and public-space/landuse element is represented once with retained source identity. | Missing, duplicate, unconverted, or disconnected feature-ID report. |
| Exterior buildings | Every in-scope frozen OSM building/building-part footprint is represented once with simple, traceable massing. | Source-ID/tag mapping and tagged-versus-placeholder massing state. |

Camera, placeholder-avatar, ordinary-color, water/shoreline, SF-art, spray-art, and spray-count-limit details use KISS candidate-local defaults unless they block the core loop, recognition, comfort, provenance, or performance. Treasure Island proper shoreline geometry is audited, but falling, water collision, swimming, reset, and boundary behavior are not current acceptance gates.

Every in-scope OSM source element must map to the world exactly once. A missing, duplicate, or unconverted element prevents a coverage-complete claim. Reversible geometric defaults escalate only when an actual playable exposes a coverage, traversal, or recognition blocker.

### Pragmatic accessibility

On the actual playable, treat an unreachable mouse/keyboard action, illegible prompt, color-only required feedback, disabling fatigue, or blocking camera motion/occlusion as a core-loop blocker. Record only the observed barrier and smallest reversible mitigation; do not run a broader certification or feature questionnaire.

## Candidate checks

After the approved bounded raw OSM snapshot is acquired and frozen, audit every in-scope Treasure Island proper element by retained ID/type/tag through its derived representation. Record missing, duplicate, unconverted, invalid, and tagged-versus-placeholder-massing states. Completeness passes only when every admitted source element maps once; YBI and the bridge remain simple context polygons.

When an actual runtime/world candidate exists, load its complete placeholder inventory on the target Mac and run the qualitative walk-run-tag check above. Record the first concrete blocker or pass. Do not add timers, scores, correction-rate studies, generic questionnaires, or profiling unless needed to reproduce that blocker.

Vehicle behavior, persistence, universal spray eligibility, and cosmetic defaults do not gate the current milestone. If actual candidates expose a material product or invariant tradeoff, show the exact before → after difference and request only that decision.

## Resource requests

No runtime, editor, vehicle asset/plugin, paid asset, account, field visit, fenced/private-access survey, public-tile scrape, hardware access, cosmetic-art approval, or broad prototype authorization is requested now. The target Mac and reversible placeholder-art defaults are already available as discovery fixtures.

### Request 1: one bounded raw OSM vector snapshot

- **Need:** Obtain one latest raw OSM vector extract whose locally determined bounds fully contain Treasure Island proper and enough adjacent extent for simple Yerba Buena Island/Bay Bridge scenery polygons, then freeze it as the layout baseline.
- **Concrete task enabled:** Enables Check 1 and the complete Treasure Island proper source inventory for in-scope terrain/shoreline, roads/paths, public-space/landuse, and exterior building/building-part elements while preserving IDs/tags; also supplies coarse context outlines without making YBI/bridge detailed inventories.
- **Needed now or later:** Later, immediately before Check 1; no data is downloaded during discovery.
- **Cheapest acceptable option:** A bounded $0 raw-data export through the official OSM export route or another specifically approved raw-extract route. OSMF public raster/vector tile servers are not acceptable substitutes and must not be scraped or bulk-downloaded.
- **One-time and recurring cost, if known:** $0 expected at this area size; small local file storage; $0 recurring.
- **User action or approval required:** Already approved by the owner. No further scope or download question is required; retain timestamp, bounds, checksum, IDs/tags, attribution, and the ODbL notice.
- **Fallback if declined:** No frozen layout artifact exists, so complete feature-ID coverage cannot be audited or claimed.
- **Status:** `approved`

No approach selected.

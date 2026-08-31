# First-Playable Approach Proposal

Checked: 2026-08-27

Status: `approved` by the owner on 2026-08-27; implementation and the exact vetted, logged downloads below are authorized.

## Proposed approach

Use one local, reproducible toolchain:

- **Runtime/editor:** Godot Engine 4.7.2 standard edition with GDScript.
- **Renderer:** Forward+ initially, because Godot's built-in projected `Decal` is supported there and does not carry the Mobile renderer's documented eight-decals-per-mesh-resource limit.
- **World scale:** local metric coordinates centered on Treasure Island, with one Godot unit equal to one meter.
- **OSM preparation:** the already-installed `osmium` CLI exports the frozen snapshot to a source-ID-preserving interchange; a project-owned Node.js script clips and classifies it against Treasure Island way `26767313`.
- **Small geometry dependencies:** locked versions of [`polygon-clipping`](https://github.com/mfogel/polygon-clipping) (MIT) for polygon boolean operations and [`earcut`](https://github.com/mapbox/earcut) (ISC) for triangulating polygons with holes. Both are local build dependencies, not hosted services.
- **Generated contract:** deterministic world data plus a coverage ledger keyed by OSM type and ID. Generated records retain geometry category, source tags needed for massing, and the derived object key.
- **World construction:** GDScript creates chunked `ArrayMesh` geometry and static collision for the complete island, rather than hand-modeling neighborhoods or individual buildings.
- **Player:** a visible placeholder avatar using a small project-owned `CharacterBody3D` controller for grounded WASD movement, Shift to run, collision, and a simple recovery/reset input.
- **Camera:** a project-owned `Node3D` pivot -> `SpringArm3D` -> `Camera3D` rig with mouse orbit, following the official [Godot 4.7 spring-arm tutorial](https://docs.godotengine.org/en/4.7/tutorials/3d/spring_arm.html). The official [Platformer 3D demo](https://store.godotengine.org/asset/godot-foundation/platformer-3d-demo/) is a source reference only. No camera/controller add-on or demo project becomes a dependency.
- **Spray:** a camera raycast accepts opaque building-wall receivers only, then places the one local predefined graphic with Godot's projected `Decal` node.
- **Context:** flat water, locally authored San Francisco skyline billboard, and simplified non-playable YBI/Bay Bridge meshes from the frozen context geometry.
- **Launch:** run locally during development, then export a private macOS `.app` for the owner's Apple-silicon Mac.

This is one approval bundle. Approval would not authorize paid assets, an asset-store connection, image generation, a hosted service, interiors, detailed façades, or cars.

## Representative before -> after

**Before:** the repository contains a frozen, verified OSM snapshot and decision-neutral research. Engine, scripting language, renderer, world scale, map-production method, mesh handoff, spray technique, and Mac launch format are unselected; there is no runnable game.

**After (approved):** the repository becomes a Godot 4.7.2 standard/GDScript project using Forward+, one-meter local coordinates, an offline `osmium` + Node conversion step, generated ID-traceable island meshes, a project-owned `CharacterBody3D` third-person controller with a pivot -> `SpringArm3D` -> `Camera3D` rig, projected `Decal` spray placement, and a native private Mac build. Complete Treasure Island coverage and the approved player-facing scope remain unchanged; no camera/controller add-on is introduced.

## Why this is the recommendation

- Godot supplies native Apple-silicon authoring/export, character collision, procedural mesh APIs, projected decals, input, camera, and app packaging in one free tool. Its current official macOS package is Universal, self-contained, and extract-and-run. [Godot macOS download](https://godotengine.org/download/macos/)
- Godot is MIT licensed and does not impose an editor account or recurring fee. [Godot license](https://godotengine.org/license/)
- The documented `ArrayMesh`/`SurfaceTool`, `CharacterBody3D`, and `Decal` primitives directly cover the runtime work this milestone needs. [Procedural geometry](https://docs.godotengine.org/en/stable/tutorials/3d/procedural_geometry/index.html), [CharacterBody3D](https://docs.godotengine.org/en/stable/classes/class_characterbody3d.html), [Decal](https://docs.godotengine.org/en/stable/classes/class_decal.html)
- The official 4.7 spring-arm guidance and current 4.7 Platformer 3D example cover the proposed camera hierarchy and character-body pattern without adding an editor plug-in, controller framework, or runtime dependency. The broader camera/controller alternatives remain documented in `GODOT_MODULE_REVIEW.md` for reconsideration only if the built-in path exposes a concrete tested gap.
- A small offline converter is more auditable than a generic map importer for this project: it can preserve every admitted OSM ID, enforce the exact TI boundary, report unresolved geometry, and regenerate the same world from the frozen source.
- The target data is modest for a coarse whole-island scene: 213 building footprints, 2 building parts, 427 road/path ways, and 80 area-shaped land-use/public-space objects. Performance still must be proven with the full snapshot, not inferred from those counts.

## Why the other viable options are not proposed

- **Unity 6.5:** technically capable and Apple-silicon compatible, but it adds Unity Hub, account/license activation, a larger editor/package surface, and URP configuration without a current milestone benefit that offsets that friction.
- **Plain Three.js:** Node and browsers are already installed and polygon extrusion is attractive, but the project would own more third-person controller, collision, game-loop, local-server, and browser-launch behavior. A native wrapper would add another runtime.

Neither alternative is rejected. If this proposal is declined, Three.js is the lowest-friction fallback; Unity remains available if its Hub/account workflow is acceptable.

## Data rules carried into implementation

- The immutable raw snapshot remains authoritative; generated data is disposable and reproducible.
- Treasure Island way `26767313` is the playable clipping polygon. YBI way `26767311`, the combined TI/YBI coastline, and bridge objects never expand playable scope.
- Every admitted terrain/shoreline, road/path, major area, building, and building-part source ID appears exactly once in the coverage ledger or points to a documented composite.
- Building height uses numeric OSM `height` when valid, otherwise `building:levels` times a documented three-meter level default, otherwise a simple six-meter fallback for the 27 footprints lacking both. This is provisional massing, not apartment modeling.
- Building-part geometry subtracts from or overrides overlapping parent massing so both source identities remain traceable without accidental double volumes.
- Roads and paths use documented class-based placeholder widths because the snapshot contains no `width` tags. All 427 segments remain represented.
- Terrain is initially flat because the approved OSM baseline contains no elevation model. This is a reversible visual default, not a request for another dataset.

## First implementation checks

Implementation would proceed horizontally across the complete island:

1. Generate the full ID ledger and fail on unresolved/duplicate admitted features. Validate every triangulation against source area and reject rather than hide a malformed result.
2. Render the entire island shell, roads/paths, major areas, and all building footprints before adding local detail.
3. Verify multipolygon holes, parent/building-part precedence, and the exact TI/YBI clipping boundary.
4. Add full-world collision and the project-owned `CharacterBody3D` walk/run/recovery controller with a pivot -> `SpringArm3D` -> `Camera3D` mouse-orbit rig.
5. Place the predefined tag on actual generated building walls and reject ineligible surfaces clearly.
6. Add the SF/YBI/bridge context, run on the target Mac, and collect the compact acceptance evidence.

If full-island loading, collision, or decals reveal a blocker, chunking and mesh representation may change while preserving the source-ID ledger and complete island scope. The project will not respond by dropping ordinary buildings or reducing the world to a landmark slice.

## Resource requests

### APPROACH-001 — Godot editor and export templates

- Need: official Godot 4.7.2 standard Universal macOS package and matching export templates.
- Concrete task enabled: create, run, and export the proposed native first playable.
- Needed now or later: now; approach approval was granted.
- Cheapest acceptable option: official free standard download; no .NET edition, store, account, or subscription.
- One-time cost: $0.
- Recurring cost: $0.
- User action or approval required: fulfilled by the owner's explicit approval on 2026-08-27.
- Fallback if declined: use the installed Node/browser toolchain for a Three.js proposal instead.
- Status: `approved`.

### APPROACH-002 — Local polygon conversion packages

- Need: lock and download `polygon-clipping` and `earcut` into the project through npm.
- Concrete task enabled: deterministic clipping to the exact TI polygon and triangulation of multipolygons/holes without installing a full GIS suite.
- Needed now or later: now; approach approval was granted.
- Cheapest acceptable option: these two free local packages only; commit the lockfile and provenance.
- One-time cost: $0.
- Recurring cost: $0.
- User action or approval required: fulfilled by the owner's explicit approval on 2026-08-27.
- Fallback if declined: author equivalent geometry operations locally or propose a heavier free geospatial stack before use.
- Status: `approved`.

No image-generation access, asset-store access, paid plugin, paid data, external account, backend, or extra compute is requested.

The Godot module review adds no resource request: the official tutorial and Platformer 3D demo are references only, and no camera/controller add-on or demo download is proposed.

Approach approved by the owner on 2026-08-27.

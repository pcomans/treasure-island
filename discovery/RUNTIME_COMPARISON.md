# Runtime comparison for the first playable

> **Historical scope note (2026-08-28):** This runtime comparison predates the owner-approved jetpack amendment. Its walking/running-only criterion describes the original milestone; the current implemented loop adds unlimited Space-held jetpack lift and slow descent. The later decision does not change the already approved Godot/runtime comparison outcome.

Checked: 2026-08-27

Status: research and a recommendation proposal only. This document does not select, install, or implement a runtime.

## Approved criteria used

- Target: the owner's MacBook Pro with Apple M1 Pro, 10-core CPU, 32 GB memory, macOS 26.5.2.
- World: the complete frozen Treasure Island OpenStreetMap inventory, rendered as simple island geometry and extruded exterior building massing.
- Player: third-person mouse-and-keyboard walking and running.
- Interaction: place one predefined spray-tag decal on eligible opaque building surfaces at runtime.
- Context: San Francisco billboard plus simple non-playable Yerba Buena Island and Bay Bridge polygons.
- Use: private, local hobby project; offline play; KISS; $0 or low recurring cost.
- Deferred: cars. They are not used to justify extra first-milestone complexity here.

`Verified` below means the capability or policy is stated in current first-party documentation. `Inference` means the documented primitives appear sufficient, but this exact Treasure Island workload has not been run. `Unverified` means a local spike is still required.

## Local tool state

Read-only inspection on 2026-08-27 found:

- Node.js 26.7.0, npm 11.19.0, Safari, Chrome, and Firefox already present.
- No Godot executable/app detected.
- No Unity editor executable/app detected.

This only affects setup friction; it is not a product-capability claim.

## Honest comparison matrix

| Criterion | Godot 4.7.2 | Unity 6.5 | Browser/JavaScript 3D family (Three.js representative) |
| --- | --- | --- | --- |
| Apple M1 Pro authoring and play | **Verified fit.** Official macOS download is Universal for Apple Silicon and Intel; current system requirements name Apple M1 as a supported/recommended example. | **Verified fit.** Current editor requirements support Apple M1 or above on macOS 13+ and the desktop player supports Apple Silicon. The target is on macOS 26.5.2. | **Conditional fit.** `WebGLRenderer` requires WebGL 2. The target already has three mainstream browsers, but the actual selected browser/GPU path still needs one local launch check. |
| Raw OSM to island meshes | **Inference.** `ArrayMesh` and `SurfaceTool` construct static geometry from vertex arrays. No first-party raw-OSM importer was identified, so a project-owned parser/converter handoff is still required. | **Inference.** Unity's `Mesh` API creates meshes from vertices and triangle indices. No first-party raw-OSM importer was identified, so a project-owned parser/converter handoff is still required. | **Inference with a direct polygon primitive.** `ExtrudeGeometry` extrudes arbitrary 2D shapes and `BufferGeometry` accepts custom buffers. No first-party raw-OSM importer was identified, so OSM still needs parsing and coordinate conversion. |
| Complete static island inventory | **Supported primitives; workload unverified.** Static geometry can be chunked; MultiMesh is useful only where geometry repeats. The actual feature/triangle count must be measured. | **Supported primitives; workload unverified.** Static batching and mesh combination are documented; the actual feature/triangle count must be measured. | **Supported primitives; workload unverified.** Official guidance covers merged geometry and instancing to reduce draw calls; the actual feature/triangle count must be measured. |
| Third-person walk/run | **Verified building blocks.** `CharacterBody3D` is documented for scripted, colliding movement. A follow camera and run state remain small project code. | **Verified building blocks.** `CharacterController` is explicitly intended for third- or first-person control. A follow camera and run state remain project code unless an optional starter asset is introduced. | **Verified lower-level building blocks.** First-party addons provide capsule-versus-world collision through `Capsule` and `Octree`; movement and the third-person camera must be authored in JavaScript. |
| Runtime spray tag | **Verified built-in node.** `Decal` projects an albedo texture onto meshes and can restrict receivers by render layers. Important constraint: it works in Forward+ and Mobile, not Compatibility; Mobile allows only eight decals per mesh resource. | **Verified URP feature.** URP's Decal Projector projects a decal material onto meshes. It does not work on transparent surfaces, which is compatible with the approved opaque simple-massing baseline. | **Verified first-party addon.** `DecalGeometry` creates a projected decal mesh. Official docs warn projection can distort around corners; flat building walls are the intended first test. |
| SF billboard and simple YBI/bridge context | **Verified/inference.** Billboard material mode is built in; ordinary procedural meshes cover the polygon scenery. | **Inference from standard engine primitives.** A textured plane and simple meshes do not require an extra service or package. | **Verified/inference.** `Sprite` is a camera-facing textured plane; ordinary geometry covers the polygon scenery. A fixed backdrop plane is also possible. |
| Offline private play | **Strong fit.** The macOS editor is extract-and-run, self-contained, and its editor network mode is offline by default. Projects export as macOS `.app` bundles. | **Player fit; development friction.** A macOS standalone player is supported. Unity Personal development requires license activation; current docs say Hub is its only activation/return method and direct users with internet to Hub. | **Fit with launch friction.** An npm/Vite build can bundle code and local assets, but official docs require serving through a local web server rather than relying on `file://`. A desktop wrapper would add another runtime and is not included in this comparison. |
| License and recurring cost | **Strong fit.** MIT licensed, free to use, with no royalty or account requirement stated by the official download/license pages. | **Conditional $0 fit.** Unity Personal is free for eligible users with up to $200,000 in revenue/funding; Unity says the Runtime Fee was canceled. It remains proprietary, account/licensing managed. | **Strong fit.** Three.js is MIT licensed. Local Node/browser execution has no required hosting or recurring service cost. |
| KISS for this milestone | **Low glue after one download.** One integrated game editor/runtime supplies movement, collision, decals, camera, input, and native Mac export. | **Most setup/operational overhead here.** It is capable, but adds Hub, account/license activation, a larger editor/package surface, and render-pipeline setup for decals. | **Fastest zero-install start on this Mac, but more game code.** The toolchain is already present and arbitrary OSM polygon extrusion maps naturally to Three.js; collision, camera, launch-server behavior, and game-loop conventions remain project-owned. |
| Native app-like launch | **Verified.** Direct macOS `.app` export is documented. | **Verified.** Native Apple Silicon/macOS builds are documented. | **Not in the plain family.** The baseline launches a local URL in a browser. A wrapper can change that, but would be a separate option and dependency. |

All three remain technically viable against the current approved brief. No matrix cell proves island-scale performance; capability documentation is not a substitute for running the frozen snapshot.

## Candidate notes

### Godot 4.7.2

Verified facts:

- The official macOS package is a Universal Apple Silicon/Intel build and is described as “extract and run”; the standard edition avoids the additional .NET SDK required by the C# edition. [Godot macOS download](https://godotengine.org/download/macos/)
- Godot is MIT licensed; the project's own game content is not placed under Godot's license. [Godot license](https://godotengine.org/license/)
- Godot's project manager and editor do not access the internet by default; online asset-library access is opt-in. [Godot Project Manager](https://docs.godotengine.org/en/stable/tutorials/editor/project_manager.html)
- `ArrayMesh`/`SurfaceTool` construct geometry in script, `CharacterBody3D` supports controlled collision movement, and `Decal` projects textures onto meshes. [Procedural geometry](https://docs.godotengine.org/en/stable/tutorials/3d/procedural_geometry/index.html), [player movement](https://docs.godotengine.org/en/stable/getting_started/first_3d_game/03.player_movement_code.html), [Decal](https://docs.godotengine.org/en/stable/classes/class_decal.html)
- Standard 3D materials include billboard modes, and official templates export Universal 2 macOS app bundles. [Billboard material](https://docs.godotengine.org/en/stable/tutorials/3d/standard_material_3d.html), [macOS export](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_macos.html)

Important uncertainties:

- The OSM converter's output shape and chunking strategy are separate, still-open decisions.
- The built-in spray path removes the Compatibility renderer from consideration unless the tag is implemented another way.
- If Mobile is tested, its eight-decals-per-mesh-resource limit interacts with building-mesh merging. Forward+ avoids that documented Mobile limit, but the project has not benchmarked either renderer on the island snapshot.

### Unity 6.5

Verified facts:

- Unity 6.5 supports Apple M1 or above for the editor and Apple Silicon for macOS players. [Unity 6.5 system requirements](https://docs.unity3d.com/Manual/system-requirements.html)
- The `Mesh` API creates and modifies meshes, and `CharacterController` is intended for third- or first-person control. [Unity Mesh API](https://docs.unity3d.com/ScriptReference/Mesh.html), [Character Controller](https://docs.unity3d.com/Manual/class-CharacterController.html)
- Current URP documentation includes a Decal Projector and notes that it does not project onto transparent surfaces. [URP decals](https://docs.unity3d.com/Manual/urp/renderer-feature-decal.html)
- Unity documents static batching for static meshes. [Static batching](https://docs.unity3d.com/Manual/DrawCallBatching.html)
- In 2026, Personal is free up to the stated $200,000 eligibility threshold; the Runtime Fee was removed. [2026 pricing](https://unity.com/products/pricing-updates), [Runtime Fee cancellation](https://unity.com/blog/terms-update-runtime-fee-cancellation)
- Unity Personal activation is managed through Unity Hub; current docs call Hub the only activation/return method for Personal. [License activation methods](https://docs.unity3d.com/Manual/LicenseActivationMethods.html)

Important uncertainties:

- Owner eligibility under Unity Personal has not been checked because Unity has not been selected.
- URP is a prerequisite for the compared decal path; choosing it would be part of a Unity approach approval.
- Unity's broader tool surface is useful, but the current milestone does not show a requirement that offsets its extra account/install/licensing workflow.

### Browser/JavaScript 3D, represented by Three.js

Verified facts:

- Three.js is MIT licensed. [Three.js license](https://github.com/mrdoob/three.js/blob/dev/LICENSE)
- The official setup recommends npm plus a build tool such as Vite and requires a local server; a production build emits local static files. [Three.js installation](https://threejs.org/manual/en/installation.html)
- `WebGLRenderer` requires WebGL 2; `ExtrudeGeometry` extrudes 2D shapes; `BufferGeometry` stores custom mesh buffers. [WebGLRenderer](https://threejs.org/docs/pages/WebGLRenderer.html), [ExtrudeGeometry](https://threejs.org/docs/pages/ExtrudeGeometry.html), [BufferGeometry](https://threejs.org/docs/pages/BufferGeometry.html)
- First-party addons include capsule/world collision (`Capsule` and `Octree`) and projected decal meshes (`DecalGeometry`). [Octree](https://threejs.org/docs/pages/Octree.html), [Capsule](https://threejs.org/docs/pages/Capsule.html), [DecalGeometry](https://threejs.org/docs/pages/DecalGeometry.html)
- Official optimization guidance describes merging many objects, and `InstancedMesh` reduces draw calls for repeated geometry. [Optimize lots of objects](https://threejs.org/manual/en/optimize-lots-of-objects.html), [InstancedMesh](https://threejs.org/docs/pages/InstancedMesh.html)

Important uncertainties:

- The official collision addon is a useful primitive, not a ready-made third-person controller. Camera behavior, slopes/steps, recovery, and animation remain project code.
- A plain browser build is offline-capable when dependencies/assets are bundled, but it retains local-server/browser launch UX.
- `DecalGeometry` must be tested against whatever merged/chunked building mesh the OSM pipeline emits.

## Disqualifiers and gates

No candidate is disqualified by the current approved brief.

- **Godot disqualifier:** if the Compatibility renderer becomes mandatory while built-in projected decals remain mandatory, Godot's built-in `Decal` path is disqualified. Neither condition is currently approved.
- **Unity disqualifier:** if the owner declines a Unity account, Hub, or online Personal activation, Unity Personal is disqualified as the development runtime. The current brief requires offline play, not air-gapped development, so this gate has not fired.
- **Plain-browser disqualifier:** if a double-clickable native `.app` with no browser/local server becomes mandatory, the plain browser family is disqualified. Adding Electron/Tauri would create a different, more complex candidate.
- **All-candidate gate:** if the frozen OSM snapshot cannot meet coverage and interactive performance after sensible static-mesh chunking, none of the documentation reviewed proves a fix. The snapshot must be measured rather than selecting by marketing claims.

## Recommendation proposal — owner approval required

**Proposal:** approve **Godot 4.7.2 standard edition with GDScript** as the first-playable runtime. Keep the OSM conversion format, chunking, Forward+ versus Mobile renderer choice, detailed camera tuning, and shoreline recovery open until their concrete implementation checks.

Representative before -> after if approved:

- **Before:** engine/framework, project scripting runtime, and Mac launch format are unselected; Godot, Unity, and a browser stack remain peer candidates.
- **After:** the project is organized as a Godot 4.7.2 standard/GDScript project and targets a local macOS app; runtime movement uses Godot's 3D character/collision primitives and the spray spike uses its built-in projected decal. The OSM data-production approach is still not selected by this proposal.

Why this proposal:

- It meets the M1/native Mac, third-person, collision, decal, billboard, and offline-app needs inside one integrated runtime.
- It is $0, MIT licensed, extract-and-run, and does not add an account or recurring service.
- It avoids assembling game-runtime conventions around a rendering library while avoiding Unity's Hub/account/license overhead.
- The material risks are narrow and testable: frozen-snapshot mesh/collision load, tag projection on the chosen building mesh structure, and renderer performance.

Why it is only a proposal:

- Three.js has a legitimate KISS advantage today because Node and browsers are already installed and `ExtrudeGeometry` maps naturally to footprint massing.
- No candidate has rendered the actual frozen island snapshot yet.
- Approving Godot would change the explicit engine non-decision and organize downstream work around it, so the owner must approve that exact before -> after change first.

## Resource requests

### RUNTIME-001 — Godot editor and macOS export templates

- Need: official Godot 4.7.2 standard macOS package and macOS export templates.
- Concrete task enabled: only after the recommendation is approved, create and locally run/export the first Godot spike.
- Needed now or later: later; do not download until runtime approval.
- Cheapest acceptable option: official standard (non-.NET) download and only the required export templates.
- One-time cost: $0.
- Recurring cost: $0.
- User action or approval required: approve the Godot runtime proposal and the official download.
- Fallback if declined: retain Three.js as the zero-new-editor candidate using the already installed Node/browser toolchain, or revisit Unity if its account/Hub workflow is acceptable.
- Status: `proposed`.

No image generation, asset-store access, paid plugin, online service, or extra compute is requested for this decision.

No approach selected.

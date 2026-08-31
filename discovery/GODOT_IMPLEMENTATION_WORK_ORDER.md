# Proposed Godot First-Playable Implementation Work Order

Checked: 2026-08-27

Status: implementation-ready planning for the exact bundle in `APPROACH_PROPOSAL.md`; this document does not itself select or authorize that bundle. It creates no Godot project, generated world, download, install, or export. At the approval gate, implementation must stop before Work Package 0 unless the owner approves the proposal's representative before -> after change.

## Owner-approved jetpack amendment (2026-08-28)

The original work order below specified ordinary gravity and no jump action. The owner explicitly superseded that player-facing behavior after the first playable was built:

- **Before:** no jump input; leaving the ground applies ordinary project gravity and the player cannot climb through the air.
- **After:** holding physical `Space` provides unlimited upward jetpack lift; releasing Space transitions to a slow capped descent; Space can be pressed again in mid-air; camera-relative walk/run steering remains available in the air.

This amendment authorizes the project-owned input/controller/test/documentation change only. KISS defaults are `5.0 m/s` capped ascent, `1.5 m/s` capped descent, and `12.0 m/s²` vertical response. It adds no fuel, cooldown, UI, asset, dependency, conventional finite jump state, terrain elevation, vehicle behavior, or playable-boundary change. The sections below use the amended current contract while retaining the original before state here for provenance.

## Outcome and scope guard

If the exact proposal is approved, the implementation team can use this work order to produce one private Godot 4.7.2/GDScript first playable using Forward+, one-meter local coordinates, an offline Osmium/Node conversion step, generated `ArrayMesh` geometry, static collision, a project-owned `CharacterBody3D` controller, a pivot -> `SpringArm3D` -> `Camera3D` rig, projected `Decal` tags, and a native macOS `.app`.

The resulting playable must include, at coarse quality, the complete frozen Treasure Island exterior denominator:

- `735` unique playable source rows: the Treasure Island land boundary; `22` terrain/shoreline memberships; all `427` road/path ways; all `80` major-area memberships; all `213` building footprints; and both building parts. The ten cross-category rows remain one canonical source each rather than duplicated obligations.
- Continuous playable island ground plus every admitted visible feature or an explicit visible composite recorded in the derived coverage ledger.
- All four non-playable context anchors: YBI way `w26767311` and Bay Bridge anchors `w1011568818`, `r13543937`, and `r13543938`.
- A locally authored San Francisco skyline billboard in the correct general mainland direction.
- A visible third-person placeholder avatar that can walk, run, use the jetpack, look, spray, pause, recover, and exit using mouse and keyboard.

The first playable must not contain cars, vehicle controls, traffic, interiors, rooms, apartments, individual-unit plans, bespoke façade reconstruction, controller support, missions, progression, NPCs, multiplayer, online services, cross-session tag persistence, or a public-release pipeline. Complete roads remain present for layout recognition even though cars are deferred. YBI, bridge geometry, and the SF billboard are context only and never expand the playable boundary beyond Treasure Island way `w26767313`.

Dropping ordinary buildings, excluding inconvenient source rows, or replacing the whole island with a polished landmark slice is not a permitted performance response. Representation and chunking may be simplified only while every source obligation remains represented and traceable.

## Approval boundary and stop rules

At the time this work order was prepared, the following before -> after change remained the exact owner decision:

- **Before:** frozen source and discovery documents; no selected engine, world transform, generated-world contract, player runtime, decal implementation, or Mac app.
- **After if approved:** the Godot 4.7.2 standard/GDScript, Forward+, one-meter local-coordinate, Osmium + Node, ID-traceable generated-world, built-in third-person, projected-Decal, private-Mac bundle described above.

Approval of that bundle would authorize only the free official Godot editor/templates and the two locked local conversion packages already requested. It would not authorize an add-on, demo download, paid asset, image-generation call, asset-store connection, account, hosted service, cars, interiors, or a public distribution workflow. Any later change to the generated data contract, player-facing control contract, complete-island invariant, or playable boundary needs a representative before -> after example and exact approval before downstream work is organized around it.

## Proposed repository layout

Create this layout only after the bundle clears its gate. Generated files are reproducible outputs; raw OSM files remain immutable inputs.

```text
project.godot
export_presets.cfg
game/
  scenes/
    main.tscn
    player/player.tscn
    ui/hud.tscn
    world/world_root.tscn
  scripts/
    main.gd
    player/player_controller.gd
    player/player_camera.gd
    player/recovery_controller.gd
    interaction/spray_controller.gd
    interaction/tag_instance_pool.gd
    ui/hud.gd
    world/generated_world_contract.gd
    world/world_loader.gd
    world/world_chunk_builder.gd
    world/world_boundary.gd
    debug/runtime_evidence.gd
  resources/
    materials/world_materials.tres
    materials/tag_decal_materials.tres
    textures/tag/predefined_tag.png
    textures/tag/PROVENANCE.md
    textures/context/sf_skyline.png
    textures/context/PROVENANCE.md
generated/world/
  manifest.json
  coverage-ledger.csv
  context.json
  chunks/<chunk-id>.json
tools/
  build_source_inventory.mjs          # existing source-side ledger generator
  build_godot_world.mjs               # proposed derived-world generator
  lib/world-contract.mjs
  lib/coordinates.mjs
  lib/osm-geometry.mjs
  lib/mesh-output.mjs
evidence/first-playable/
  README.md
  coverage/
  traversal/
  spray/
  context/
  mac-run/
build/mac/                             # ignored local export output
```

`data/osm/treasure-island-2026-08-27.osm` remains authoritative. The proper PBF, extraction polygon, source inventory, and source summary remain reproducible inputs or audit artifacts, not game assets to mutate. The Mac export should include `generated/world`, runtime scenes/scripts, and local art, but exclude the raw OSM snapshot, source tooling, discovery material, evidence, and install records.

## Proposed scenes and node hierarchies

### Main scene

```text
Main (Node3D, main.gd)
├── WorldEnvironment
├── Sun (DirectionalLight3D)
├── WorldRoot (instance: world/world_root.tscn)
├── Player (instance: player/player.tscn)
└── Interface (CanvasLayer)
    └── HUD (instance: ui/hud.tscn)
```

`Main` starts the loader, holds input pause state, enables the player only after full-world validation succeeds, and displays a blocking load error instead of entering a partial world. It passes the validated spawn transform and boundary service to the player. No global autoload is required for this milestone.

### Generated world scene

```text
WorldRoot (Node3D, world_loader.gd)
├── PlayableWorld (Node3D)
│   ├── GroundAndAreas (Node3D; populated by chunk builders)
│   ├── RoadsAndPaths (Node3D; populated by chunk builders)
│   └── Buildings (Node3D; populated by chunk builders)
├── ContextWorld (Node3D)
│   ├── Water (MeshInstance3D)
│   ├── YerbaBuenaIsland (MeshInstance3D)
│   ├── BayBridge (Node3D)
│   └── SanFranciscoBillboard (MeshInstance3D)
├── WorldBoundary (Node, world_boundary.gd)
└── RuntimeEvidence (Node, runtime_evidence.gd)
```

Every chunk is loaded for the first playable. Chunking is an organization, culling, and collision-tuning mechanism, not a streaming excuse to make only part of Treasure Island available. Context nodes have no player-collision layer and are excluded from the playable coverage denominator. `WorldBoundary` owns the exact local-coordinate form of `w26767313` and reports whether a candidate player position remains playable.

### Player scene

```text
Player (CharacterBody3D, player_controller.gd)
├── CollisionShape3D (CapsuleShape3D)
├── AvatarPivot (Node3D)
│   └── PlaceholderAvatar (MeshInstance3D)
├── CameraPivot (Node3D, player_camera.gd)
│   └── SpringArm3D
│       └── Camera3D
├── RecoveryController (Node, recovery_controller.gd)
└── SprayController (Node, spray_controller.gd)
    └── TagInstances (Node3D, tag_instance_pool.gd)
```

Mouse X rotates `CameraPivot` around world up. Mouse Y pitches `SpringArm3D`, with a reversible clamp. `Camera3D` remains the arm's direct child so the built-in near-plane cast is used. On ready, the player physics RID is excluded from the spring arm cast if necessary. The spring arm and player both collide with the named world-solid physics layer. No camera/controller add-on, demo project, animation framework, jump state, aim mode, weapon system, or gamepad input is introduced.

### HUD scene

```text
HUD (Control, hud.gd)
├── Reticle (Control)
├── FeedbackPanel (PanelContainer)
│   └── FeedbackText (Label)
├── PausePanel (PanelContainer)
│   ├── ResumeButton
│   └── ExitButton
├── LoadPanel (PanelContainer)
└── DebugPanel (PanelContainer; hidden by default)
```

Success and rejection feedback always contains text, not color alone. The pause panel releases the mouse. Resuming recaptures it. Exit is available from the pause panel without requiring a developer stop action.

## Input action contract and reversible tuning defaults

Define named actions in `project.godot`; gameplay scripts consume action names rather than raw key codes.

| Action | Default binding | Runtime behavior |
|---|---|---|
| `move_forward` | `W` | Camera-relative forward movement on the ground plane. |
| `move_back` | `S` | Camera-relative backward movement. |
| `move_left` | `A` | Camera-relative left movement. |
| `move_right` | `D` | Camera-relative right movement. |
| `run` | Left or right `Shift`, held | Uses run speed while movement is requested. |
| `jetpack` | `Space`, held | Rises continuously while held; release transitions to a slow capped descent. May be pressed again in mid-air. |
| `spray` | Primary mouse button | Attempts one placement at the center reticle. |
| `recover` | `R` | Returns to the latest safe transform, or initial spawn if none exists. |
| `pause` | `Escape` | Toggles pause, cursor capture, and the pause panel. |
| `quit_game` | `Q`, only while paused | Exits the private build; the pause-panel Exit button performs the same action. |
| `toggle_debug` | `F3` | Shows or hides the local evidence/debug panel. |

Mouse motion provides look only while captured and unpaused. Left click does not place a tag through the pause UI. No conventional finite jump or vehicle action is defined. Initial tuning is deliberately simple and reversible: 4 m/s walk, 7 m/s run, 18 m/s² horizontal acceleration, 24 m/s² horizontal braking, 5 m/s capped jetpack ascent, 1.5 m/s capped descent, 12 m/s² vertical response, a 0.35 m radius/1.8 m tall capsule, 4 m spring-arm length, 0.003 radians-per-pixel look sensitivity, and pitch clamped to approximately -60° through +25°. These values are implementation defaults; change them only to cure a demonstrated movement, comfort, collision, or targeting problem and record the change in the evidence notes.

Owner-authorized movement amendment, 2026-08-28: **before:** Shift-run targeted 7 m/s with 18 m/s² acceleration and 24 m/s² braking; **after:** walking remains 4 m/s, while the same held-Shift run targets 20 m/s (about 45 mph) with 30 m/s² acceleration and 40 m/s² braking. This reaches the fast-run cap from rest in about 0.67 seconds and stops from the cap in 0.5 seconds. It adds no vehicle action or movement subsystem and does not change the jetpack or other controls.

## CharacterBody3D walk/run/jetpack behavior

`player_controller.gd` must follow this contract:

1. Read the four movement actions through `Input.get_vector`, normalize diagonal input, and transform the vector by the camera's yaw only. Pitch never adds vertical motion.
2. On each physics tick, accelerate horizontal `velocity` toward walk or run target speed in both ground and air states, and decelerate it toward zero when input stops. While `jetpack` is held, move vertical velocity toward the capped ascent speed; otherwise move it toward the capped slow-descent speed, clamping it to zero when grounded. There is no fuel limit or conventional one-shot jump.
3. Call `move_and_slide()` once per physics tick with `up_direction = Vector3.UP`, floor snapping enabled, and a conservative maximum slope. Do not reproduce OSM access restrictions or fence behavior.
4. Rotate the placeholder avatar toward meaningful movement without rotating the camera pivot. A missing animation cannot block the milestone.
5. Allow look and movement immediately after successful spray, rejected spray, and recovery. Spraying does not enter a modal weapon state.
6. Use physics layer `world_solid` for the capsule and spring-arm masks. Generated context scenery has no `world_solid` layer.

Initial spawn was originally specified as a deterministic clear point near the boundary centroid. On 2026-08-28, the owner explicitly changed that behavior: **before:** start near the island centroid; **after:** start at the ferry arrival on the land-side Treasure Island approach, safely inside the exact playable boundary and facing inland. The generator derives that collision-checked transform from the frozen ferry terminal/access/Waterfront Plaza OSM chain, asserts capsule, building, boundary, and camera-boom clearance, and records the result in the manifest rather than hand-hiding it in the player scene. The offshore floating terminal platform remains non-playable under the approved Treasure-Island-only boundary; see `discovery/DECISION_LOG.md`.

## Camera behavior

The proposed camera stays dependency-free and uses the exact direct-child hierarchy `CameraPivot -> SpringArm3D -> Camera3D`.

- Horizontal mouse motion changes pivot yaw; vertical motion changes arm pitch.
- The camera follows the character because the pivot is inside the player scene; no smoothing framework is required initially.
- `SpringArm3D` shape-casts against `world_solid`, shortens before building/ground occlusion, and excludes the player's own collider if it enters the cast.
- The camera uses a far plane large enough for YBI, bridge, and SF billboard context, but context never receives collision.
- The center reticle is the spray aim reference. Spray range is validated from the character to the hit point, so a distant camera cannot place tags from arbitrary range.
- Test camera seams, tight gaps, steep massing edges, near-wall orbit, and looking toward the horizon in the full generated world. A concrete blocker can justify tuning or a separately proposed module spike; unused add-ons are not preinstalled.

## Recovery and playable boundary

`RecoveryController` maintains `last_safe_transform`. A transform becomes safe only when the character is grounded, its capsule has clearance, its position is inside the exact local `w26767313` polygon, and it has remained stable long enough to avoid saving a transient collision snag. Preserve camera yaw across recovery, clear linear velocity, and display textual `Recovered` feedback.

Recovery is triggered by `R` or automatically if the player drops below the configured floor threshold or moves outside the playable polygon. If no safe transform has been recorded, use the manifest's initial spawn. This KISS behavior makes shoreline, southern-connection, and ordinary stuck failures recoverable without inventing swimming or invisible playable YBI. An outside-boundary recovery event is logged with only local coordinates and cause; no device or personal identifier is recorded.

## Generated-world build contract

### Coordinate transform

Use one transform for every playable and context layer. Compute a deterministic origin from the exact Treasure Island boundary and record its WGS84 longitude/latitude in the manifest. Convert source longitude/latitude to local WGS84 east/north meter offsets, then map east to Godot `+X`, north to Godot `-Z`, and up to `+Y`; all initially flat island geometry uses `Y = 0`. One Godot unit equals one meter. The conversion constants, origin, axes, snapshot hash, boundary source key, and generator version are manifest fields. Runtime code never reprojects coordinates independently.

Use deterministic 256 m grid chunks addressed as `x_<signed-index>__z_<signed-index>`. Clip cross-chunk render parts as necessary, but keep a single source-side coverage row pointing to its complete set of derived parts. Sort records and numeric arrays before serialization so unchanged inputs produce byte-identical generated output.

### Manifest interface

`generated/world/manifest.json` is the runtime entry point and contains at least:

- `schema_version` (`ti.godot-world/1` initially), generator version, generation timestamp excluded from content hashing, and content hash;
- authoritative raw OSM path/hash, extraction-polygon hash, source-ledger path/hash, and boundary source key `w26767313`;
- coordinate origin, axes, unit scale, flat-ground elevation, and chunk size;
- expected playable unique count `735`, context unique count `4`, all category membership counts, and zero expected unresolved/duplicate rows;
- stable paths and hashes for the derived coverage ledger, context record, and every chunk;
- initial spawn transform and the playable boundary polygon in local coordinates; and
- material keys and schema-compatible feature kinds used by the loader.

The checked-in generated content must not use absolute machine paths, timestamps in deterministic payloads, editor UIDs as source identity, or unrecorded manual mesh edits.

### Coverage-ledger interface

`generated/world/coverage-ledger.csv` is a derived companion to, not a mutation of, `data/osm/treasure-island-source-inventory.csv`. It has one row per canonical source key and includes:

- source key, source type/ID, playable or context scope, and all frozen categories;
- `derived_world_status` in the closed set `represented`, `composite_member`, `context`, or `unresolved`;
- one stable `derived_object_key`, plus an ordered part/chunk list when a source is split;
- representation kind, source/default dimension rule, and optional composite key/note; and
- generated geometry counts and validation outcome.

Acceptance requires `735` playable and `4` context rows, no duplicate source key, and zero `unresolved`. Sharing a derived object key is allowed only when every participating source row declares the same documented composite membership. The ten multi-category sources remain one row each. No visually ordinary source can disappear through filtering.

### Chunk interface

Each `chunks/<chunk-id>.json` contains local-coordinate mesh records, never longitude/latitude. Each record includes a stable object/part key, feature kind, source keys, material key, vertices, normals, UVs where required, triangle indices, and collision/receiver semantics. The loader accepts only these closed feature kinds:

- `land_ground`, `terrain_overlay`, `major_area`, `road_path`;
- `building_wall`, `building_roof`, `building_part_wall`, `building_part_roof`; and
- `boundary_blocker` only if full-world testing proves a local collision barrier is needed in addition to polygon recovery.

Each area triangulation must compare triangle area with the clipped source polygon area and fail generation, rather than omit geometry, when it exceeds a documented numeric tolerance. Multipolygon holes must remain holes. A source crossing chunks becomes an explicit composite of parts, not duplicate full geometry in each chunk.

`world_loader.gd` exposes this narrow runtime interface:

- `load_world(manifest_path)` validates schema, hashes, counts, source keys, part references, and context before adding gameplay nodes;
- signals `load_progress(loaded, total)`, `world_ready(report)`, and `world_failed(code, message, source_keys)`;
- `get_spawn_transform()` and `get_boundary()` return only validated manifest data; and
- a failed chunk or coverage check removes any partial children and leaves the player disabled behind a readable error.

`world_chunk_builder.gd` converts one validated chunk into `ArrayMesh` surfaces, `MeshInstance3D` nodes, and static collision. It returns a report of mesh, triangle, collider, and source-key counts. It never reads OSM or decides category/height rules at runtime.

### Complete geometry rules

- **Land/shoreline:** triangulate the exact `w26767313` polygon as continuous flat ground. Clip shared coastline `w29399800` and all boundary-touching geometry to playable scope or map it to an explicit visible composite. Preserve all admitted sand, wetland, breakwater, pier, and marina obligations.
- **Roads/paths:** represent all `427` ways. With no source `width` tags, use one documented class table: tertiary 8 m; residential/unclassified 6 m; service/pedestrian 4 m; track/cycleway/platform 3 m; footway/path 2 m. Clip ribbons to playable scope and keep every source key traceable.
- **Major areas:** triangulate all `80` memberships, preserving relation holes and overlaps. Slight visual offsets may avoid z-fighting, but ground collision remains continuous.
- **Buildings:** extrude all `213` footprints. Use valid numeric source `height`; otherwise valid `building:levels * 3 m`; otherwise 6 m for the `27` footprints missing both. Record the chosen rule per row. Keep walls and roofs as separate render and collision surfaces.
- **Building parts:** represent both parts. Subtract their footprint from overlapping parent `w1249412094` massing where required, extrude the parts from their own attributes, and map parent plus parts to an explicit composite so none of the three identities becomes a hidden double volume.
- **Collision:** generate continuous ground and building-solid static collision across the whole island. Roads and cosmetic area overlays use the ground collider rather than duplicating co-planar physics. Test chunk seams rather than deleting difficult shapes.

## Collision, render-layer, and spray-receiver contract

Name physics layers rather than relying on unexplained numbers:

| Layer | Members | Consumers |
|---|---|---|
| `world_solid` | playable ground, building walls/roofs, and any proven boundary blocker | Player capsule and spring arm. |
| `player` | player capsule only | World collision; excluded from camera and spray queries. |
| `spray_ray_surface` | opaque playable ground, building walls/roofs, and other nearby opaque surfaces that must occlude a spray | Spray query; the first hit determines success or rejection. |

Building-wall physics shapes additionally join group `spray_receiver_wall` and carry metadata `receiver_kind=building_wall`, `opaque=true`, `derived_object_key`, and the canonical source/composite keys. Ground, roofs, context, water, and non-building scenery never join that group. Renderable building walls use a dedicated visual layer included in the tag `Decal.cull_mask`; roofs, ground, player, water, YBI, bridge, and billboard do not. Context geometry has no physics layer.

This separation makes the closest opaque hit authoritative: the ray cannot pass through an ineligible roof or ground to tag a wall behind it, and the decal cannot project onto unrelated nearby geometry.

## Wall-only raycast and Decal placement

`spray_controller.gd` performs the following single interaction on `spray`:

1. Project a ray from the center of the active `Camera3D` viewport through the reticle, querying only `spray_ray_surface` and excluding the player.
2. Use the closest hit. Reject with text if there is no hit, the hit is farther than the reversible 6 m player-to-hit range, the collider is not in `spray_receiver_wall`, `opaque` is not true, or the wall normal is not sufficiently vertical.
3. Resolve the hit shape's stored derived/source identity. Failure to resolve identity is a data error and rejects placement rather than creating an untraceable tag.
4. Create one `Decal` using the sole local predefined graphic, align its projection axis against the hit normal, preserve upright orientation from world up, offset it slightly from the wall, and use a thin projection depth to limit corner bleed. Use a wall-only cull mask.
5. Add it to `TagInstances`, display textual `Tag placed` feedback, and return immediately to movement/look. A rejected attempt displays a reason such as `Aim at an exterior building wall` or `Wall is out of range`; it does not consume or lock input.

Tags are session-only. A reversible pool limit of 64 active decals removes the oldest placement when full and records the event in the debug count; it does not add persistence, tag choice, erasing, drawing, or networking. The tag graphic must be locally stored with a lightweight provenance note and an alpha channel. Test the final path on actual generated walls, including adjacent walls and chunk seams, before any visual polish.

## SF billboard, YBI, Bay Bridge, and water context

`context.json` contains local transforms and derived keys for context, separate from playable chunks.

- Create YBI from the simplified polygon of `w26767311`, with coarse low-poly elevation sufficient to read as southern context. Do not import its roads, buildings, or detailed inventory.
- Resolve the three Bay Bridge anchors from the frozen raw snapshot and their verified complete member subset. Generate simplified deck ribbons and a few structural primitives sufficient to show the western/eastern bridge relationship. Do not turn the 737-node member subset into a detailed playable bridge inventory.
- Create a project-owned flat SF silhouette graphic and provenance note. Place its billboard west/southwest of Treasure Island, face it toward the island, keep it beyond playable bounds, and size it as horizon context rather than collision geometry. No downloaded skyline image or image-generation service is needed for the initial placeholder.
- Use a large flat water mesh below or level with the flat island visual baseline. Water supplies context, not swimming or navigable terrain. Leaving `w26767313` invokes recovery before context can become playable.

Whole-island and ground-level inspection must show YBI south of Treasure Island, the bridge in its correct relative east/west relationship, and SF in the general mainland direction. Context orientation is checked against the same coordinate transform as the island; it is never positioned by an unrelated hand-tuned axis system.

## Private Mac launch and export

After approval and logged installation of the matching editor/templates, define one `macOS Private` release preset targeting Apple silicon on the owner's existing M1 Pro Mac. Export to ignored path `build/mac/Treasure Island First Playable.app`. The preset contains no signing identity, account credential, hardened-runtime/public-store setup, analytics, or updater. No `.dmg`, notarization, App Store submission, public download, Intel certification, or storefront work is required.

The private launch record must state the Godot version, build/source revision, generated manifest content hash, export preset name, local macOS version, exact launch steps, and pass/blocker result without device name, serial number, hardware UUID, user path, or account detail. First verify editor-run behavior, then launch the exported `.app` directly on the actual target Mac with the mouse and keyboard. A locally observed Gatekeeper/signing problem is a blocker to record and solve narrowly; it is not permission to add an account or public-release pipeline.

## Debugging and performance evidence

Instrumentation stays local and proportional. `RuntimeEvidence` collects:

- manifest/hash validation result, full-world load start/end duration, chunks loaded/expected, and coverage row counts;
- mesh instances, surfaces, triangles, static bodies/shapes, active decals, and runtime node count;
- FPS/frame time and Godot-reported memory while the optional F3 panel is visible;
- player local coordinates, grounded/in-boundary state, last-safe availability, and recovery cause/count; and
- spray result counts by placed, no hit, range rejection, receiver rejection, and identity/data error.

The evidence bundle retains one whole-island top-down source/derived comparison, one ordinary-play capture covering full load and the route, a concise profiler/debug-panel capture at initial load and during movement/jetpack/spray, and a blocker log. No telemetry service, performance dashboard, device identifier, or fixed benchmark threshold is required. Acceptance is blocker-level: ordinary full-world play on the M1 Pro must remain responsive enough to walk, run, fly, look, recover, and spray without a blocking crash, input failure, sustained unusable stall, or resource failure. If diagnostics reveal a blocker, first reduce material/collider/draw-call cost or reorganize chunks while preserving every source row.

## Work packages and exit criteria

### Work Package 0 — approval, install control, and empty project shell

Entry: exact approach approval exists. Before any download, record the official Godot 4.7.2 standard Universal editor/templates and both locked npm packages in `INSTALL_LOG.md` with publisher/registry, version, command, scope, result, and removal path. Create the project shell only after those controls are satisfied.

Exit: Forward+ project opens without add-ons; empty main scene runs; matching templates are visible; input and layer names exist; no demo content, vehicle input, or interior asset is present.

### Work Package 1 — deterministic full-source conversion

Build and validate the complete derived manifest, coverage ledger, context record, and all chunks. Fail on source-hash drift, duplicate or unresolved rows, missing reference, bad relation/hole, area mismatch, invalid dimension fallback, or unexplained composite.

Exit: two clean conversions are byte-identical; the derived ledger has exactly `735` playable and `4` context rows with zero unresolved; all category counts match the source specification; generated data retains every source key.

### Work Package 2 — full-extent visible island

Load every chunk and render continuous ground, all roads/paths, all major areas, footprint-level building placeholders, water, and coarse context before deeper massing.

Exit: whole-island top-down comparison shows the complete shoreline, network, areas, and building pattern; no failed chunk or partial-world fallback is allowed.

### Work Package 3 — complete massing and collision

Extrude every building and part across the whole island, apply source/default height rules, resolve parent/part overlap, split wall/roof semantics, and add full-world static collision.

Exit: ground-level and overlay checks cover all masses; wall/roof receiver metadata resolves to source IDs; chunk seams, tight gaps, and representative slopes have no blocker.

### Work Package 4 — whole-island third-person traversal

Add the visible placeholder player, action map, walk/run/jetpack, mouse camera, spring-arm collision, pause/exit, manual/automatic recovery, and initial spawn. Exercise north, central grid/interior, southwest, and shoreline/perimeter regions with the full world loaded.

Exit: the route is connected without a progression blocker; held Space rises continuously, release descends slowly, a second mid-air press rises again, and WASD/Shift steer in air; normal landing, collision, and an outside/stuck case work without restart; YBI/bridge/SF remain unreachable context.

### Work Package 5 — tag on actual generated walls

Add the one local tag, first-hit ray query, wall/opacity/normal/range checks, wall-only decal culling, session pool, and non-color-only success/rejection feedback.

Exit: a capture shows eligible placement and inspection on an actual generated TI wall, ineligible ground/roof/context rejection, pool/debug count, and immediate resumed walking/running.

### Work Package 6 — context, Mac export, and compact evidence

Finish coarse YBI/bridge geometry and the local SF billboard, export the private `.app`, run the actual target-Mac loop, fix blocker-level launch/performance/traversal/spray failures, and collect the compact evidence bundle.

Exit: full coverage is intact; the app launches privately on the target Mac; the owner can recognize Treasure Island and complete walk/run/jetpack/spray/resume; unresolved blockers are absent or clearly prevent milestone acceptance.

## Requirement-level acceptance checks

| ID | Requirement | Pass condition | Required evidence |
|---|---|---|---|
| `COV-01` | Frozen source integrity | Runtime manifest references the recorded raw, polygon, and source-ledger hashes; generation stops on drift. | Manifest excerpt and clean generator log. |
| `COV-02` | Complete source mapping | Exactly 735 playable and 4 context source rows; zero duplicate keys and zero unresolved rows; explicit composites explain shared derived objects. | Derived ledger validation report. |
| `COV-03` | Whole-island visible coverage | Every land/shoreline, road/path, major-area, building, and part obligation is visible in correct relative position. | Top-down source/derived comparison plus ground-level samples. |
| `MASS-01` | Complete simple massing | All 213 buildings and both parts use source height, levels × 3 m, or documented 6 m fallback; parent/part overlap is not a double volume. | Ledger dimension columns, representative overlays, and full-world view. |
| `WORLD-01` | Playable boundary | Only `w26767313` is playable; YBI/bridge/SF remain context and leaving TI produces useful recovery. | Boundary/debug capture and outside-boundary recovery. |
| `MOVE-01` | Third-person walk/run | Visible avatar walks, runs, stops, turns, and reaches north, central, southwest, and perimeter regions with camera-relative WASD/Shift. | Annotated route capture from the actual full world. |
| `MOVE-02` | Unlimited jetpack | Holding Space sustains capped ascent without a fuel limit; release produces capped slow descent; another mid-air press renews ascent; WASD/Shift remain effective in air; normal release can land without recovery. | Live full-world ascent/air-walk/air-run/descent/renewed-ascent/landing metrics plus owner play capture. |
| `CAM-01` | Mouse camera and collision | Pivot/arm/camera orbit works; pitch is bounded; spring arm avoids ordinary wall occlusion without colliding with the player. | Tight-gap, near-wall, and horizon capture. |
| `REC-01` | Recovery | `R`, a normal snag, or leaving/falling outside the playable world returns the avatar to a verified safe transform without restart. | Trigger/cause and recovery-result capture. |
| `SPRAY-01` | Eligible wall placement | Primary click places the sole local tag on an opaque generated exterior building wall within range, upright and visibly inspectable. | Placement capture plus source/derived identity in debug output. |
| `SPRAY-02` | Ineligible feedback | Closest ground, roof, context, no-hit, and out-of-range attempts create no tag and display understandable text; movement resumes. | Rejection/resume capture. |
| `SPRAY-03` | Receiver isolation | Decal cull mask prevents projection onto roof, ground, player, water, context, or a nearby unrelated mesh; oldest tag is removed at the session limit. | Adjacent-surface test and active-count capture. |
| `CTX-01` | SF orientation | Local SF billboard appears in the correct general mainland direction and cannot be reached. | Ground-level horizon views and boundary behavior. |
| `CTX-02` | YBI/bridge relationship | Coarse polygonal YBI and bridge context appear south/east/west as appropriate but add no playable inventory or collision-rich traversal. | Whole-island and southern ground-level views. |
| `MAC-01` | Private target launch | Exported Apple-silicon `.app` launches on the owner's M1 Pro with mouse/keyboard and no account, hosted service, or public packaging. | Sanitized launch record and ordinary-play capture. |
| `PERF-01` | Whole-world usability | Full-island load and ordinary movement/jetpack/look/recovery/spray have no blocking crash, input failure, resource failure, or sustained unusable stall. | Debug/profiler snapshots and blocker log from target Mac. |
| `SCOPE-01` | Deferred scope absent | No car/vehicle controls, traffic, interiors, apartments, rooms, missions, NPCs, multiplayer, or online system exists in runtime or acceptance. | Input map, scene tree, feature checklist. |
| `UX-01` | Recognizable and playable | Owner recognizes Treasure Island without a title card and completes walk/run/jetpack/spray/resume without a blocking failure. | Brief owner note from ordinary play; no score or formal study. |

## Concrete implementation risks and controls

| Risk | Concrete failure | Control and stop condition |
|---|---|---|
| Canonical source identity is lost across Osmium area views | Duplicate or missing buildings/areas despite plausible geometry. | Key only by original `@type/@id`; compare all 739 rows and stop on disagreement. |
| Cross-boundary completed objects expand scope | Shared coastline, harbor, pier, or YBI geometry becomes playable. | Clip against `w26767313`; require explicit composite notes for boundary-touch rows; runtime recovery uses the same polygon. |
| Multipolygon holes or building parts triangulate incorrectly | Filled courtyards, double volumes, or absent masses. | Area validation, isolated relation fixtures, and explicit `w1249412094` parent/part audit; fail rather than omit. |
| JSON/chunk contract drifts from loader | A partial world loads with stale semantics. | Version/hash every artifact; validate all chunks before enabling play; reject unknown feature kinds. |
| Chunked collision produces seams or traps | Full coverage exists but roaming is blocked. | Traverse chunk seams across all regions; merge or reshape collision while retaining derived/source mapping. |
| Collision shapes obscure spray identity | Ray hits a batched body but cannot prove which wall received the tag. | Put derived/source metadata on the ray-hit shape owner and reject unresolved hits. |
| Decal projection bleeds around corners or onto batched neighbors | Tag looks incorrect or violates wall-only rule. | Separate wall visual layer, thin projection box, normal/range checks, and adjacent-wall acceptance test. |
| Camera collides with the player or tunnels through generated walls | View snaps, clips, or blocks movement/aim. | Direct camera child, world-solid mask, player RID exclusion, and full-world near-wall tests. |
| Coarse geometry overwhelms M1 Pro collision/rendering | Complete island is technically present but unusable. | Build full extent early; record counts/profiler evidence; reduce surfaces/materials/colliders or reorganize chunks without reducing source coverage. |
| Recovery saves an unsafe position | Repeated recovery loop or teleport into a building. | Require grounded, in-boundary, clear, stable safe transforms; always retain validated initial spawn fallback. |
| Context is misplaced or becomes traversable | Island reads incorrectly or scope silently grows. | Use the same transform, keep context off physics layers, and prove direction plus boundary recovery. |
| Private macOS export is blocked by templates or Gatekeeper | Editor run works but the actual delivery path fails. | Install matching templates only after approval/logging; test exported app early enough to record and narrowly resolve the blocker. |
| Placeholder work drifts into cars/interiors/art production | Whole-island and current interaction work loses time. | Review `SCOPE-01` and the coverage ledger at each work-package exit; defer non-milestone assets and systems. |

## Resource requests

This work order adds no request beyond the two entries already proposed in `RESOURCE_REQUESTS.md`.

### APPROACH-001 — Godot editor and export templates

- Need: official Godot 4.7.2 standard Universal macOS package and matching export templates.
- Concrete task enabled: create, run, and privately export the described Godot first playable.
- Needed now or later: only after exact approach approval.
- Cheapest acceptable option: official free standard package/templates; no .NET edition, store, account, or subscription.
- One-time and recurring cost: $0 and $0.
- User action or approval required: approve the exact bundle; record the install completely in `INSTALL_LOG.md` before acquisition.
- Fallback if declined: do not create the Godot project; return to the documented Three.js fallback proposal.
- Status: `proposed`.

### APPROACH-002 — Local polygon conversion packages

- Need: locked project-local `polygon-clipping` and `earcut` npm packages.
- Concrete task enabled: deterministic clipping to `w26767313` and triangulation of multipolygons/holes.
- Needed now or later: only after exact approach approval.
- Cheapest acceptable option: these two free packages only, with lockfile, provenance, and install log.
- One-time and recurring cost: $0 and $0.
- User action or approval required: approve the exact bundle; log the exact registry versions and install command before acquisition.
- Fallback if declined: do not download them; propose a project-owned or separately approved geometry path before implementation.
- Status: `proposed`.

No add-on, demo download, image generation, paid asset, public skyline download, account, hosted service, backend, controller hardware, extra compute, car asset, interior asset, signing identity, or public-distribution resource is requested.

No approach selected.

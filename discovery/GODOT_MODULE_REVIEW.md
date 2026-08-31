# Godot Third-Person Module Review

Checked: 2026-08-27

Status: research and recommendation proposal only. No add-on or demo was downloaded, installed, or run, so compatibility statements below distinguish publisher claims from verified source structure.

## Recommendation proposal

If the existing Godot 4.7.2 approach is approved, keep the first playable dependency-free for camera and player control:

- use a project-owned `CharacterBody3D` for grounded WASD movement, a Shift speed change for running, and reset/recovery;
- use the official 4.7 camera hierarchy `Node3D` pivot -> `SpringArm3D` -> `Camera3D` and the tutorial's small mouse-orbit input;
- use the official 4.7 Platformer 3D demo as a source reference only, not an imported project or runtime dependency;
- do not add Phantom Camera, Jeheno Third Person Controller, or JeanKouss Third Person Camera for the first playable.

This preserves the current proposal's small `CharacterBody3D` controller. It is the narrowest fit for walking, running, mouse look, and collision against the generated island. Revisit Phantom Camera only if testing creates a concrete need for camera blending, damping, multiple active camera rigs, group/path framing, or an editor viewfinder. Revisit a full controller only if later scope actually needs its jump/air/aim/animation systems.

**Dependency before -> after:** not applicable; this proposal adds no dependency and does not change the existing proposed player contract. Before and after remain a visible placeholder avatar with WASD walk, Shift run, mouse look, collision, and recovery. Detailed camera tuning remains a reversible default.

## Exact fit comparison

| Option | Exact scope | Camera collision and mouse look | Walk/run fit | Generated-island collision | Unnecessary surface |
|---|---|---|---|---|---|
| **Godot built-ins + official 4.7 references** | `CharacterBody3D` supplies script-driven wall/floor/slope collision. The 4.7 tutorial specifies pivot -> `SpringArm3D` -> `Camera3D` and mouse orbit. The official Platformer 3D demo supplies a current `CharacterBody3D` example. | `SpringArm3D` shape-casts and shortens its direct camera child. With no explicit shape, a direct `Camera3D` child uses its near-plane pyramid; the tutorial includes pitch clamping and horizontal mouse orbit. | Exact milestone fit. Walk/run is one project-owned grounded controller with two speeds; no state-machine framework is required. | Direct fit. Generated terrain/building collision must be physics collision on the camera/player world mask. The player collider can be excluded from the spring arm if needed. Chunking and OSM source IDs do not change the physics contract. | None beyond the small project script and nodes already required. The official demo is a reference, not a dependency. |
| **Phantom Camera 0.11.0.3** | Generalized 2D/3D camera plug-in: follow modes, damping, groups, paths, framing, priorities, transitions, noise, viewfinder, and third-person mode. It is not a character controller. | Third-person mode wraps `SpringArm3D` and exposes length, shape, margin, and mask. Its own documentation still asks project code to map mouse motion into third-person rotation setters. | No movement, walk, run, recovery, or character collision. It must be paired with the same project-owned `CharacterBody3D` controller. | Compatible in principle by pointing its spring-arm mask at the generated static collision. This is an inference from its documented mask/shape controls; it was not run here. | Most of the plug-in for one follow camera: host/manager system, priorities, blends, group/path/framed modes, noise, viewfinder, optional C# wrapper, and examples. |
| **Jeheno Third Person Controller 2.2** | Full GDScript player package: five-state controller, camera, animated model, HUD, test map, sound, particles, and supporting content. | Its camera script captures the mouse, orbits a `SpringArm3D`, zooms, switches aim shoulder, and can toggle world collision. The published scene puts `Camera3D` directly under the arm. | Best add-on match on features: explicit walk and run, hold/toggle run, acceleration/deceleration, slopes, jump, buffering, coyote time, multi-jump, and air control. Much broader than this milestone. | Publisher setup reserves collision layer 1 for world and layer 2 for player; its camera collision mask is hard-coded to 1 when enabled. Generated island collision would therefore need that convention or an adaptation. | Twelve input actions plus aim, zoom, camera-collision toggle, jumping/air states, HUD, animated character, ragdoll-state source, audio, VFX, and demo map/content. |
| **JeanKouss Third Person Camera 1.5.0** | Camera-only editor plug-in/scene with dynamic/fixed/shoulder views, mouse or parent follow, preview panel, camera shake, and mirrored `Camera3D` properties. No movement controller. | Uses `SpringArm3D`, exposes its mask/margin, and contains built-in mouse-motion handling and pitch/yaw controls. | No walk/run or recovery; it still needs the project-owned `CharacterBody3D` controller. | Compatible in principle if its spring-arm mask includes generated static collision. This is an inference from the exposed mask; it was not run here. | Preview/editor plug-in, camera shake/presets, fixed and shoulder modes, and duplicated inspector exposure are not needed for one simple roaming camera. |
| **Official TPS demo** | Complete third-person shooter project, not a reusable module. Its player is a `CharacterBody3D` with root-motion animation, mouse/gamepad input, aiming, shooting, bullets, multiplayer synchronization, UI, audio, enemies, and a full level. | Its player scene uses pivot nodes with `SpringArm3D` -> `Camera3D`; its input script handles mouse orbit. | Movement is present, but the published controls and player source do not define the milestone's Shift-to-run action. Extraction would be more work than the small built-in controller. | Physics collision would work with generated collision masks after adaptation, but the demo's own player layers, root motion, networking, and shooter assumptions must be disentangled. | Nearly the entire project: shooting, aim/crosshair, bullets, enemies, multiplayer, root-motion character assets, audio, menus, level, and effects. The repository itself warns that it is large and can take time to open. |

## Currency, license, and installation burden

| Option | Godot 4.7 evidence and freshness | License | Installation/dependency burden |
|---|---|---|---|
| **Built-ins + official references** | Exact Godot 4.7 documentation. The official Platformer 3D store entry requires Godot 4.7 and was updated 2026-07-08; the official demo repository made its first 4.7 release on 2026-07-07. This is the strongest maintenance path. | Godot and the Platformer 3D demo: MIT. | No new package, plug-in, autoload, account, or runtime dependency. The optional demo download is unnecessary because the 4.7 tutorial contains the required setup. |
| **Phantom Camera 0.11.0.3** | Asset entry submitted 2026-07-19. The release fixed a Godot 4.7.1 autoload regression; repository code was still changing on 2026-08-20. Documentation says minimum Godot 4.3. This proves active 4.7 maintenance, not a local 4.7.2 test. | MIT. | Download/copy `addons/phantom_camera`, enable the editor plug-in, and adopt `Camera3D` + `PhantomCameraHost` + `PhantomCamera3D`/manager conventions. No paid service; C# wrapper is optional. |
| **Jeheno 2.2** | Publisher explicitly states Godot 4.4-4.7 fully supported; asset entry is dated 2026-06-21 and repository push 2026-06-22. There is no tagged GitHub release, so a future use should pin the exact reviewed commit or Asset Library package. | MIT; repository also credits bundled source/content contributors. | Copy its `addons` tree and instantiate/adapt its player scene. It expects 12 named input actions (defaults can be supplied by its checker) and world/player collision-layer conventions. |
| **JeanKouss 1.5.0** | Asset entry is dated 2025-03-05 and carries Godot 4.0 metadata. The latest repository commit, 2025-12-15, says the port to 4.5 succeeded. Neither primary source claims Godot 4.7 support, so 4.7.2 compatibility is unproven. | MIT. | Install/enable the plug-in, instance its `ThirdPersonCamera.tscn`, and configure its input actions/properties. It adds an editor preview plug-in and camera scene but still needs a movement controller. |
| **Official TPS demo** | Published Asset Library build is Godot 4.5 (2025-10-14); current `master` says it follows latest stable Godot 4.x and was updated 2026-06-24. It is evidence for this comparison, not a proposed reference or versioned 4.7 module. | Asset entry: MIT; repository has a detailed project license file. | Whole-project acquisition and manual extraction/adaptation. The heaviest option here. |

The sorted official Asset Library search did not reveal a materially better third-party full controller than Jeheno for this exact milestone. The older Better Third Person Camera (1.0, Godot 4.3 metadata, 2024-10-14) is less fresh. Phantom Camera is materially better maintained than the camera-only alternatives, but its generalized scope still does not justify a first-playable dependency. The official 4.7 tutorial and Platformer 3D demo are the materially better-maintained reference path.

## Integration rule if Godot is approved

These are implementation constraints inferred from the documented Godot node contracts, not an engine or module decision:

- Give generated island ground, building walls, and other blockers static physics collision on a named world layer.
- Include that layer in both the `CharacterBody3D` collision mask and `SpringArm3D` collision mask.
- Keep `Camera3D` a direct child of `SpringArm3D` when relying on the camera near-plane shape, or deliberately choose a simple sphere shape after testing.
- Exclude the player's own physics RID from the spring arm if its collider intrudes on the camera cast.
- Test seams between generated collision chunks, steep massing edges, tight building gaps, and recovery on the actual whole-island output. No add-on removes this island-specific validation.

## Resource requests

None. This proposal adds no module, demo download, Asset Library connection, account, cost, or runtime dependency. If the existing Godot proposal is approved, its already-proposed official Godot editor download is sufficient. The official 4.7 documentation can be used without importing a demo. If a later tested camera problem triggers reconsideration, the exact add-on/version/download must be proposed before acquisition.

## Primary sources

All sources checked 2026-08-27.

- Godot 4.7: [third-person camera with spring arm](https://docs.godotengine.org/en/4.7/tutorials/3d/spring_arm.html), [`CharacterBody3D`](https://docs.godotengine.org/en/4.7/classes/class_characterbody3d.html), and [`SpringArm3D`](https://docs.godotengine.org/en/4.7/classes/class_springarm3d.html).
- Godot Foundation: [Platformer 3D store entry](https://store.godotengine.org/asset/godot-foundation/platformer-3d-demo/), [4.7 demo release](https://github.com/godotengine/godot-demo-projects/releases), [TPS demo repository](https://github.com/godotengine/tps-demo), and [TPS Asset Library entry](https://godotengine.org/asset-library/asset/2710).
- Phantom Camera: [Asset Library entry](https://godotengine.org/asset-library/asset/1822), [repository](https://github.com/ramokz/phantom-camera), [0.11.0.3 release notes](https://github.com/ramokz/phantom-camera/releases/tag/v0.11.0.3), [third-person mode](https://phantom-camera.dev/follow-modes/third-person), [installation](https://phantom-camera.dev/overview/installation), and [FAQ/version statement](https://phantom-camera.dev/support/faq).
- Jeheno: [Asset Library 2.2 entry](https://godotengine.org/asset-library/asset/3934), [repository/readme](https://github.com/Jeh3no/Godot-Third-Person-Controller), and [camera source](https://github.com/Jeh3no/Godot-Third-Person-Controller/blob/main/addons/JehenoThirdPersonController/PlayerCharacter/Camera/camera_holder_script.gd).
- JeanKouss: [Asset Library 1.5.0 entry](https://godotengine.org/asset-library/asset/1815), [repository/readme](https://github.com/JeanKouss/godot-third-person-camera), [camera source](https://github.com/JeanKouss/godot-third-person-camera/blob/main/addons/third-person-camera/third_person_camera/ThirdPersonCamera.gd), and [latest compatibility commit](https://github.com/JeanKouss/godot-third-person-camera/commit/92d88f985a5e3d6a7a33827a961c1bd597541638).
- Wider maintenance scan: [Asset Library third-person results sorted by update](https://godotengine.org/asset-library/asset?filter=third+person&sort=updated).

No approach selected.

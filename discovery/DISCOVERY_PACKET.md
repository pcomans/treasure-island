# Discovery Packet

Status: discovery complete; the exact Godot implementation approach was approved by the owner on 2026-08-27

## Owner-approved brief

- Private personal hobby project
- Treasure Island, San Francisco only
- Complete island-scale exterior coverage of every in-boundary terrain/shoreline feature, road/path, major public-space/land-use feature, and exterior building footprint in a frozen latest-available raw OSM snapshot
- No individual apartments, units, floor plans, rooms, or interiors
- Broadly present-day layout baseline: latest raw OSM snapshot when acquired; no separate real-world currentness reconciliation
- Third-person walking, running, and unlimited hold-to-rise Space jetpack flight with slow descent on release
- Owner's MacBook Pro with Apple M1 Pro (10-core CPU, 32 GB memory), using mouse and keyboard only
- Generally traversable outdoor OSM space; do not reproduce real fenced/private access
- Simple exterior building massing to start
- One predefined spray tag on eligible building surfaces in the spirit of Half-Life 1's spray interaction
- San Francisco as non-playable billboard background scenery
- Yerba Buena Island and the Bay Bridge as simple non-playable polygonal scenery
- Cars and arcade driving deferred to a later milestone
- First-playable success: Treasure Island is recognizable and the experience is playable

## Remaining non-decisions

Detailed camera tuning, visual style beyond simple initial massing and SF billboard context, shoreline behavior, deferred vehicle implementation, car roster, traffic, NPCs, missions, progression, multiplayer, and online services remain open. Godot 4.7.2/GDScript, Forward+, one-meter scale, offline `osmium` + Node conversion, the pinned geometry packages, the built-in controller/camera rig, projected decals, and private native Mac packaging are approved.

## Evidence synthesis

Treasure Island is a broad, nearly level, human-made island whose stable identity differs from the adjoining hilly natural island. Research supports a mix of the legacy lettered/numbered grid, northern residential loops, and newer southwest streets. For the current milestone, outdoor space in the snapshot is generally traversable; real fences, private-property boundaries, and literal traffic permissions are not researched or reproduced.

Complete coverage and recognition fidelity are separate requirements. No known island-scale feature in the approved categories may be omitted merely because it is not recognition-critical. Within that complete exterior world, candidate cues that may deserve slightly clearer treatment are:

1. The flat artificial island form, water horizon, and southern connection.
2. The south arrival ensemble: Building 1, Hangars 2 and 3, Clipper Cove, and the ferry landing.
3. Avenue of the Palms connecting to the lettered/numbered grid and contrasting residential loops.
4. Correct directional relationships to the San Francisco skyline, Clipper Cove, and Bay Bridge.

Candidate additional recognition cues, separable from the stable set and used only if represented in the frozen OSM baseline:

- Cityside Park and Canopy of Sky.
- Isle House, Hawkins, and 490 Avenue of the Palms as recent built form.
- A restrained old-base/new-neighborhood transition.

These are recognition hypotheses, not a permission to reduce the world to a landmark slice or a reason for another owner questionnaire. Their usefulness will be observed in the actual playable. San Francisco is non-playable billboard background scenery; Yerba Buena Island and the Bay Bridge are simple non-playable polygonal scenery.

The owner approved one reproducible layout baseline: freeze the [latest raw OpenStreetMap data](https://osmfoundation.org/wiki/Licence/Licence_and_Legal_FAQ) and represent every in-boundary feature in the approved categories. That raw snapshot was acquired on 2026-08-28 UTC and is preserved with its request, checksum, object counts, exact Treasure Island boundary, and attribution in `data/osm/README.md`; `discovery/OSM_SNAPSHOT_REPORT.md` records the neutral inventory. It is not audited against a separate 2026 ground-truth inventory. Missing height or material attributes may use simple exterior placeholders or later supplemental evidence. [OSM public map tiles](https://operations.osmfoundation.org/policies/tiles/) must not be bulk-downloaded; the approved source is raw vector data.

## Player-experience synthesis

The qualitative core loop is:

1. Perceive enough place-specific evidence to recognize Treasure Island without relying on a title card.
2. Walk, run, and use the unlimited Space-held jetpack in third person through the generally traversable outdoor network and airspace above the complete island exterior without a progression blocker; release produces a slow descent.
3. Recover from an ordinary collision, boundary, or stuck state without manually restarting the whole project.
4. Place the one predefined spray tag on an eligible building surface and understand rejection on an ineligible surface.
5. Resume walking, running, flying, or spraying without a blocking failure.

Recognition is checked naturally when the owner uses the actual playable: it should read as Treasure Island without relying only on a title card. No timed trial, scoring rubric, cue-removal protocol, or advance preference interview is required.

## Historical option landscape

The following families are technically plausible and remain unranked:

- Runtime: browser-hosted; packaged application from an integrated realtime editor/runtime; code-first packaged runtime; mod/map in an existing user-owned creation runtime.
- World construction: manual reference blockout; geodata-assisted; parametric/procedural; capture/reconstruction-assisted; hybrid.
- Visual production: primitive/graphic blockout; modular authored assets; photo-referenced authored visuals; reconstruction-derived visuals; generated/transformed media; mixed.
- Deferred arcade-vehicle behavior: direct/kinematic; simplified rigid body with assists; suspension/wheel query; prebuilt/template; hybrid. These families are retained for a later milestone and are not current first-playable gates.
- Spray representation: authored receiver slots; surface-aligned overlay geometry; projected/generated decal geometry; texture/render-target stamping; hybrid. Surface eligibility and persistence are separate player-facing decisions.
- Content: owner-authored; owner-captured references; open-government data; community geodata; openly licensed creative assets; one-time commercial assets; generated media; existing user-owned runtime content.

The owner selected the Godot bundle after this landscape was compared. No store, asset pack, hosted service, or third-party controller module was selected. A later comparison should reopen an alternative only if implementation exposes a concrete blocker. The co-primary outcomes remain a recognizable island and a playable game.

The approved Godot bundle uses a small project-owned `CharacterBody3D` walk/run/jetpack controller and a pivot -> `SpringArm3D` -> `Camera3D` rig, with the official [Godot 4.7 spring-arm tutorial](https://docs.godotengine.org/en/4.7/tutorials/3d/spring_arm.html) and [Platformer 3D demo](https://store.godotengine.org/asset/godot-foundation/platformer-3d-demo/) as source references only. It adds no camera/controller add-on, imported demo project, or new runtime dependency. Detailed camera and reversible jetpack tuning remain implementation defaults.

## Independent evaluation rubric

Default evaluation is hobby-scale and owner-led: concise notes, captured blockers, and the fixed qualitative core loop. A separate evaluator, exhaustive telemetry, deep performance profiling, delayed rebuild exercises, and edge-case matrices activate only if risk or a close comparison justifies them.

Always retain these outcome areas:

- recognizable setting through explainable cues;
- complete island-scale exterior coverage plus unobstructed sampled roaming through the approved traversable network;
- understandable third-person walking/running and recovery;
- ordinary collision/stuck recovery;
- eligible spray success and understandable ineligible rejection;
- an end-to-end walk/run/jetpack/spray/resume loop without a blocker.

Tests for spray accumulation, corners, overlap, saved-state migration, deferred cars, input focus loss, and deep scaling remain conditional on those behaviors being approved or observed as risks.

## Consolidated resource requests

The shared register contains six consolidated requests:

1. A brief owner acceptance check on an actual playable (`deferred`; no advance questionnaire).
2. Free public exterior-reference research if later needed for a material recognition or spray-readability gap (`available`).
3. Access to the owner's existing M1 Pro MacBook Pro, mouse, and keyboard for later acceptance testing (`available`).
4. One latest raw OSM Treasure Island extract as the approved layout baseline (`available`; acquired and verified).
5. Official Godot 4.7.2 standard macOS editor/export templates (`approved`; $0; vetted/logged acquisition authorized).
6. Project-local locked `polygon-clipping@0.15.7` and `earcut@3.2.3` packages (`approved`; $0; vetted/logged acquisition authorized).

No image generation, asset-store access, paid plugin, paid dataset, external account connection, or additional compute is currently requested. The two approved install entries are fully described in `discovery/RESOURCE_REQUESTS.md` and `discovery/TRUSTED_INSTALL_PLAN.md`.

The Godot module recommendation creates no additional request: its official tutorial and demo are references only, with no add-on or demo download proposed.

## Contradictions, defaults, and deferred ideas

Cross-review removed accidental product commitments: timed trials, numeric rubrics, generic preference interviews, currentness reconciliation, and broad priority weighting are not requirements. Ordinary play on the owner's Mac supplies the acceptance evidence.

No discovery unknown currently warrants another owner questionnaire.

- Camera tuning, avatar, ordinary-building colors, shoreline response, missing OSM heights/materials, spray-count limits, and similar reversible details use simple implementation defaults and are adjusted only if they create a blocker.
- Cars, traffic, pedestrians, missions, damage systems, and cross-session spray persistence remain deferred ideas with no current work.
- A later candidate-specific conflict in experience, scope, cost, or irreversibility may justify one exact owner question with a before → after example.

## Approved implementation handoff

The comparison is complete. The owner approved the exact before → after bundle in `discovery/APPROACH_PROPOSAL.md`: Godot 4.7.2 standard/GDScript with Forward+, one-meter local coordinates, offline `osmium` + Node conversion, ID-traceable generated meshes, a project-owned `CharacterBody3D` third-person controller with a pivot -> `SpringArm3D` -> `Camera3D` rig, projected `Decal` spray placement, and a native private Mac build. Official Godot camera guidance and the Platformer 3D demo remain references only; no camera/controller add-on is included.

The approved approach preserves the complete frozen OSM island, simple full-island massing, third-person walk/run/unlimited jetpack flight, one predefined tag, approved context scenery, Mac target, and KISS defaults. Vetted logged editor/package acquisition and implementation are authorized.

Godot approach approved by the owner on 2026-08-27.

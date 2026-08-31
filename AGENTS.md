# Treasure Island Game — Agent Working Agreement

## Mandatory orchestration boundary

The primary `/root` agent is an **ORCHESTRATOR ONLY**, never an executor, for all work in this project. It may decompose and assign work, monitor and coordinate named subagents, review their evidence, accept or reject results, update plans and goals, and communicate with the owner.

The primary `/root` agent must never author or edit code, assets, tests, documentation, skills, or data; browse or research directly; generate assets; install or download resources; or run implementation, proof generation, validation, tests, exports, builds, launches, GUI actions, or other executor work. Every research, edit, implementation, generation, validation, test, install, download, export, build, launch, and GUI action must be delegated to a named subagent with a concrete, bounded assignment.

The primary `/root` agent may use coordination tools and the minimum read-only inspection needed solely to review or verify subagent output. Reuse a small number of appropriately bounded agents; do not over-delegate or over-analyze. This rule is persistent and takes precedence over any older wording that assigns direct editing or execution to the project lead or `/root`. It does not relax or replace any approval, external-service, decision-boundary, provenance, or data-contract rule below.

## Current phase

Implementation authorized for named executing subagents. On 2026-08-27 the owner explicitly approved the exact Godot bundle in `discovery/APPROACH_PROPOSAL.md`, including its vetted, logged downloads. Build and verify the first playable while preserving the approved product brief and the source-ID coverage contract; this authorization never makes the primary `/root` agent an executor.

## Approved product brief

- Personal hobby project for private use; no public release is planned.
- World boundary: Treasure Island, San Francisco only. Yerba Buena Island and bridge approaches are out of scope unless later approved.
- World coverage: model Treasure Island at island scale using a frozen latest-available OpenStreetMap snapshot as the authoritative horizontal layout inventory. Represent all Treasure Island terrain/shoreline features, roads/paths, major public spaces/land use, and exterior building footprints in that snapshot. Use the approved bounded USGS 3DEP bare-earth source for vertical terrain on Treasure Island and YBI. Individual apartments, floor plans, rooms, and interiors are out of scope.
- Time setting: broadly present day as represented by that latest OSM snapshot. Do not reconcile it against a separate 2026 ground-truth inventory or reject it because reality may differ.
- Current first-playable actions: third-person walking, running, an unlimited hold-to-rise jetpack on `Space` with slow descent when released, and placing one predefined spray-tag decal on eligible building surfaces in the spirit of Half-Life 1's spray interaction.
- Current target: the owner's MacBook Pro with Apple M1 Pro (10-core CPU, 32 GB memory), using mouse and keyboard only.
- Current traversal rule: do not research or reproduce real fenced/private access. Outdoor space in the frozen OSM snapshot is generally traversable unless a clear gameplay or world boundary is approved later.
- Current visual baseline: simple exterior building massing is acceptable across the complete snapshot inventory. The ground is no longer a flat baseline: use a modest USGS-derived terrain mesh, keep OSM horizontal geometry complete, drape roads/areas, level building bases to sampled terrain, and preserve traversability.
- Deferred feature: drivable cars with arcade-acceptable handling remain part of the eventual idea but are not a current first-playable requirement.
- Horizon context: San Francisco appears as non-playable billboard background scenery. Yerba Buena Island uses the approved USGS-derived terrain clipped to its OSM shoreline and remains non-colliding/non-playable. The modern eastern Bay Bridge span retains simple non-playable polygonal scenery with a readable light-concrete treatment, and the western span uses the non-colliding CC BY `Baybridge-western-span` model by cdr420.
- No owner preference is set for detailed third-person camera behavior or shoreline failure behavior; keep both open until a concrete decision is needed.
- Apply KISS defaults to reversible, low-impact details such as initial camera tuning, placeholder avatar, simple colors, shoreline recovery, and spray-count limits. Do not turn them into owner questions unless testing exposes a material experience, scope, cost, or irreversibility tradeoff.
- First-playable success: the owner recognizes Treasure Island, the complete island-scale exterior world is represented, and the third-person walk/run/jetpack/spray experience is playable.
- Recognition and playability are co-primary approved outcomes. Do not ask the owner to repeat a broad priority-weighting exercise; ask one exact question only if a later concrete tradeoff requires it.

## Facade recognizability policy

For building-specific facade art, recognizability in ordinary third-person gameplay takes priority over survey-level placement precision. Once the target, observed side or region, motif family, and generated host geometry are adequately identified, executing subagents may choose reversible module scale, count, cadence, and anchors as `production_inference`. They must not present those choices as measured or as-built. Missing surveyed coordinates, counts, cadence, or dimensions are not by themselves blockers.

Keep exact generated receiver identity, protected-region ownership, complete-motif and seam semantics, physical plausibility, and geometry/collision/navigation/spray integrity mandatory. Survey precision improves confidence and becomes mandatory only when safety or geometry integrity depends on it. Validate the combined result against the reference observations in ordinary gameplay views, with independent art review. Keep as-built fidelity and game-art acceptance as separate claims.

## Approved implementation approach

- Godot 4.7.2 standard edition, GDScript, and Forward+.
- One Godot unit equals one meter in a local Treasure Island coordinate system.
- Offline `osmium` plus a project-owned Node converter using pinned `polygon-clipping@0.15.7` and `earcut@3.2.3`.
- Deterministic, OSM-ID-traceable generated island geometry and coverage evidence.
- A frozen, bounded official USGS 3DEP elevation crop plus deterministic modest terrain derivation; OSM remains authoritative for horizontal geometry and source coverage.
- A project-owned `CharacterBody3D` walk/run/jetpack controller and `Node3D` pivot -> `SpringArm3D` -> `Camera3D` mouse camera; no controller/camera add-on.
- Projected `Decal` spray placement on eligible building walls and a private native macOS build.

## Remaining explicit non-decisions

Detailed camera tuning, visual style beyond approved simple initial massing and SF billboard context, shoreline recovery details, deferred vehicle implementation, car roster, traffic simulation, NPCs, missions, progression, multiplayer, and online services remain open. Apply KISS defaults where allowed; do not expand the current milestone into these areas.

## Research rules

- Separate verified facts, inferences, option families, assumptions, and open questions.
- Keep option families unranked. A constraint may disqualify an option only when the evidence and approved criterion are explicit.
- Prefer primary sources for facts not supplied by the approved OSM layout baseline. Record the source URL and checked date for changing technology.
- Record the OSM snapshot/extract date for reproducibility; do not create a separate island-currentness audit.
- Historical discovery deliverables retain their decision-neutral ending. Implementation artifacts and canonical status documents must state the approved approach accurately.
- Only a named documentation subagent edits the shared decision log and consolidated discovery packet. The project lead may review and accept or reject those edits but must not perform them.
- For any future proposal that changes an approved player-facing behavior, workflow, data contract, or core invariant, show a representative before -> after example and obtain explicit approval before implementation.
- Before asking the owner a question, first check local files, the machine, the frozen OSM data, and existing decisions. Ask only when the answer materially changes experience, scope, cost, external access, or irreversible work and cannot be discovered safely.

## Hobby-project filter

- Prefer free, already available, inexpensive one-time, and easily reversible resources.
- Prefer placeholders until a better resource materially improves island recognition or the playability of roaming, driving, or spraying.
- Avoid recurring services and production-scale infrastructure unless their value is unusually clear.
- Do not spend time on storefront certification, monetization, analytics, live operations, extensive legal review, or public-release polish.
- Keep lightweight provenance notes for reproducibility. Do not perform a legal audit.

## Resource and access requests

An agent may identify a need but may not silently assume, purchase, install, connect, or download it. The owner has approved only the exact free Godot/templates and pinned npm dependencies in `discovery/APPROACH_PROPOSAL.md`; acquire them from the vetted sources in `discovery/TRUSTED_INSTALL_PLAN.md` and record every operation in `INSTALL_LOG.md`. Any other resource goes through a new request using:

- Need
- Concrete task enabled
- Needed now or later
- Cheapest acceptable option
- One-time and recurring cost, if known
- User action or approval required
- Fallback if declined
- Status: `proposed`

Requests may include image generation, asset-store packs, plugins, software, reference photos, data, extra compute, or user feedback. Never write credentials, access tokens, or API keys into project files.

Model-library access is capped at one Epic account across two sites:

- Existing Sketchfab access for real-place, landmark, scan, and unusual one-off models.
- Fab access under the same Epic account, only when needed, for game-ready characters, vehicles, props, environments, and materials.

Do not request a Trimble ID, 3D Warehouse account, or another model-marketplace account. Account-free sources such as Poly Haven and Kenney may supplement these libraries when their asset and license are suitable. This source policy does not authorize purchases; keep using the resource-request process above for any paid asset.

When the owner needs to take over for login, CAPTCHA, approval, play feedback, or another hands-on step, the project lead delegates a named subagent to alert them with the macOS `say` command and provide the same request as a short written prompt. Do not use `say` for routine progress updates.

## Retrospective logging

At the end of each assigned work round, every executing subagent must add a concise entry to `discovery/RETRO_LOG.md` under its own named section:

- What worked well
- What did not work well
- What the team should change next time

Be concrete and candid. Record process lessons, not praise. Never include credentials, serial numbers, hardware UUIDs, personal identifiers, or other secrets. The project lead verifies through read-only review that every executing subagent has written an entry before closing the round; the project lead does not edit the log itself.

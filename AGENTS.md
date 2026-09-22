# Treasure Island Game — Agent Working Agreement

At task start, read the relevant lessons in [LEARNINGS.md](LEARNINGS.md). When a repeated or generalizable mistake is exposed, add or refine a concise lesson there with observed evidence, known cause or uncertainty, and a practical prevention check; keep routine round history in RETRO.

## Mandatory orchestration boundary

The primary `/root` agent is an **ORCHESTRATOR ONLY**, never an executor, for all work in this project. It may decompose and assign work, monitor and coordinate named subagents, review their evidence, accept or reject results, update plans and goals, and communicate with the owner.

The primary `/root` agent must never author or edit code, assets, tests, documentation, skills, or data; browse or research directly; generate assets; install or download resources; or run implementation, proof generation, validation, tests, exports, builds, launches, GUI actions, or other executor work. Every research, edit, implementation, generation, validation, test, install, download, export, build, launch, and GUI action must be delegated to a named subagent with a concrete, bounded assignment.

The primary `/root` agent may use coordination tools and the minimum read-only inspection needed solely to review or verify subagent output. Reuse a small number of appropriately bounded agents; do not over-delegate or over-analyze. This rule is persistent and takes precedence over any older wording that assigns direct editing or execution to the project lead or `/root`. It does not relax or replace any approval, external-service, decision-boundary, provenance, or data-contract rule below.

## Periodic team-efficiency review

At meaningful work checkpoints, ordinarily after a few substantial work rounds and earlier when repeated churn appears, `/root` assigns a named independent subagent to evaluate other subagents' efficiency. Sample relevant task/tool activity and `discovery/RETRO_LOG.md`; distinguish necessary evidence and acceptance checks from repeated low-value cycles, duplicated work, or avoidable waits. Keep the review bounded and its findings concise and evidence-backed. Do not create continuous monitoring, a recurring timer, idle audits, or a separate reporting framework.

When useful, recommend one small, reversible process experiment at a time with a simple observable measure, such as fewer redundant reruns or less avoidable waiting. `/root` reviews the findings and may approve routine process changes within existing authorization, delegates execution, and has the responsible subagent record a before/after comparison in existing retrospective notes at a later meaningful checkpoint. Retain useful changes and revise or undo ineffective ones.

For the next already justified movement-driver revision, trial the [completed-record pattern](LEARNINGS.md#construct-completed-evidence-records-once) in the existing parent driver and review emitted trace counts/outcomes in the normal diff/result review. Record missing trace rows and invocations repeated solely to recover logging in RETRO; add no separate engine run or gate.

Retain [co-preparing the existing authority invocation](LEARNINGS.md#co-prepare-the-existing-authority-invocation) as the normal authority preparation method after Trial007. The [1239 early-capture ordering trial](LEARNINGS.md#trial-1239-early-capture-ordering) completed with both independent decisions and no geometry-caused recapture; its bounded outcome is recorded in the existing retrospective. Neither adds an engine run or acceptance gate.

Efficiency work must preserve mandatory independent source, mechanical, visual/bar-raiser, and release gates and all project invariants. Changes to approved player-facing behavior, workflow, scope, data contracts, or core invariants retain the existing owner-approval requirements; efficiency review does not grant an exception or make `/root` an executor.

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

Existing assets created by older GPT models, including previously accepted work, establish a **quality floor, not a ceiling**. The earlier simple-massing allowance is a first-playable coverage baseline, not the acceptance bar for current building-recognition quality work. Implementing subagents must aim for higher quality, and the independent visual bar-raiser must assess substantive improvement through truthful exterior references and ordinary gameplay comparisons: recognizability, coherent composition, believable detail, and clean geometry and motion. Parity with older assets alone is insufficient; added complexity or decoration is not improvement by itself. Preserve protected scope, truthful source evidence, performance, playability, and existing review gates. This higher quality requirement does not itself revoke existing recognition credit or authorize invented hidden detail or scope expansion.

Keep exact generated receiver identity, protected-region ownership, complete-motif and seam semantics, physical plausibility, and geometry/collision/navigation/spray integrity mandatory. Survey precision improves confidence and becomes mandatory only when safety or geometry integrity depends on it. Independent recognition/fidelity review must compare actual dated exterior-reference pixels alongside actual gameplay captures, confirming the target and observed side/angle scope. Written notes supplement direct comparison; notes alone cannot establish whole-unit recognition acceptance. Record observed matches and substantive gaps separately from finish and mechanical findings. Unresolved substantive fidelity gaps keep whole-unit acceptance open even when a scoped finish check passes. Keep as-built fidelity and game-art acceptance as separate claims, with the comparison limits and source-retention rules in the [canonical visual review guidance](.agents/skills/building-texture/references/semantic-art-review.md#absolute-art-gate).

## Authoring and batch delivery

The ordinary iteration loop is **edit assets/code -> run or reload the source project -> capture and inspect the actual render early**. Use the approved gameplay camera and matched reference/baseline views where applicable. Bring the first coherent study to the independent visual reviewer before extended refinement or package paperwork. Run focused source and mechanical checks for the change; visible stairs require actual stock-player walking attempts up and down each flight, with contact, grounding and destination evidence. Jetpack access or static floor contact alone does not establish stair walkability. Preserve the approved walk/run/jetpack/camera/spray controls.

For ground-contacting details, the first preflight must compare their intended footprint and elevations with the actual local land, visible area surfaces and source wall-bottom elevations. Keep visible area geometry distinct from colliding land. The first movement/support checks must use the actual source world with local terrain intact and record stock-player contacts and destinations. Flat fixtures may aid composition, but cannot establish site fit or locomotion. Keep these checks focused on the affected junctions, preserving source geometry, land/area surfaces and the approved controls.

Exports, signing, mounted-package audits and release documentation belong at a **batch delivery checkpoint**, after the ready units have passed their individual quality gates. They must not block unrelated authorized authoring, source runs or early visual inspection. Reuse frozen source and visual evidence when its inputs remain applicable; review an actual changed seam instead of replaying unrelated gates. Independent source and mechanical decisions remain required, and the visual bar-raiser remains separate from implementation and those technical decisions.

Before final source hashing/freezing and batch export, run the existing whitespace check on the complete selected source patch, including every selected new/untracked file; a working-tree diff alone does not cover untracked files. Use the explicit intended file list without staging unrelated work, retain the final staged whitespace check, and record outcomes in the existing preparation/RETRO notes. For the next comparable release, count post-freeze whitespace holds and source/export replays caused solely by them, targeting zero, and record any false positives separately. This small preparation experiment adds no report or approval stage and does not relax source identity, independent review or release gates.

Ready units may share one candidate app and its owner/independent package runs. Keep a separate unit-bound acceptance packet and verdict for every building: static evidence, motion telemetry, visual-motion evidence, image-tree digest, mechanical review, package-verification receipt and independent packet/visual attestation. Per-unit package summaries may bind the same exact app and raw runs only when those runs verify each target's real attachment and required predicates. Preserve original images, source/capture pins, failed receipts, sampled-motion limits and private retention; derived summaries must identify themselves. The image-tree digest and the tree document's hash are different bindings.

Candidate package PASS remains a prerequisite to recognition credit under the existing acceptance contracts. Then serialize the ready units' authority entries and validate the exact accepted-unit list/counts once for the batch, followed by one fresh **exact-current batch export** and its required independent release/privacy checks. Thus the established order has a candidate export and a final current export per batch, not per art iteration or per unit. Never reuse a PCK as proof of two different authority states. Preserve the 213-unit inventory, previous accepted credit, protected scope, B1/HUMAN boundaries and reference privacy; capture-time metrics never become current metrics by relabeling. Study readiness alone grants no live attachment, promotion or recognition credit.

## Bounded subagent execution

Never use `ultra` reasoning effort for any subagent. Explicitly select a supported non-ultra reasoning effort at every subagent dispatch instead of inheriting the parent’s effort. Model choice is separate from reasoning effort; this rule does not change the primary/root agent’s setting or runtime configuration.

Owner-authorized default trial routing: use Astra Light (model gpt-6-astra, reasoning effort low) for modeling and Astra Medium (model gpt-6-astra, reasoning effort medium) for independent judging. If work cannot converge, ROOT may diagnose repeated unproductive cycles and select a stronger supported non-ultra effort at its discretion. No fixed retry count, automatic escalation ladder or additional approval gate applies. Keep judging independent of implementation, select effort explicitly, and never use ultra. This is a trial default, not a broad benchmark conclusion; the primary/root effort remains unchanged.

Use a small number of named agents with concrete targets, output locations, stop conditions and ownership. The existing role prompts and project skill are indexed in [the harness entrypoints](CLAUDE.md#persisted-entrypoints). Other harnesses can read these same files without inventing a callable agent configuration or copying local session state. An agent must not independently accept its own implementation or exported package; package or technical PASS does not supply the separate visual decision. Return compact handoffs with exact relevant bindings instead of duplicating large manifests or adding reporting frameworks.

Use the current harness’s actual delegation tools. In the Codex multi-agent session, dispatch every new bounded assignment with `followup_task`, whether the target agent is busy or idle; `send_message` only supplies status or clarification and does not restart a completed agent. In another harness, use its available equivalent to start the named role with the bounded task. Do not treat role filenames as callable tools. Coalesce duplicate assignments and preserve the same ownership, review and engine-release gates.

Reuse the complete successful capture/check driver and current supported invocation, adapting target paths, pins and measured expectations together before running it. Preserve source versus mounted-component versus signed-release coverage boundaries. Root serializes heavy render/engine work; the next owner starts only after explicit slot release and actual terminal/PID evidence. A tool-observation timeout or an old output file is not evidence of process completion. After an interruption, inspect the existing live handle, actual process identity, logs and receipts before acting. Resume waiting on that same handle if it is running; if it has completed, consume its terminal result and release evidence. Do not repeat an already completed checkout, import or invocation because a conversation ended. A new engine attempt still requires the named ROOT assignment and exact invocation authorization; an empty slot alone is not GO.

For the first checkout when Git LFS is unavailable on this machine, include the established command-local filter settings in the assignment and the checkout itself:

```sh
git -c filter.lfs.process= -c filter.lfs.smudge= -c filter.lfs.clean= -c filter.lfs.required=false worktree add <new-worktree> <approved-ref>
```

Keep the requested branch/starting state. Verify whether checkout populated the intended files even if the existing post-checkout hook returns nonzero; record filter and hook outcomes separately. Do not change global Git configuration/hooks, repeat an already successful checkout, or hydrate/download LFS assets without authorization. An LFS pointer is not a usable runtime asset.

## Timing claims

For a requested full workflow comparison, time from before the actual source edit through run/reload, saved screenshot, delivery to the reviewing model and its explicit visual verdict. Include tool transport, failures/retries and waiting within that boundary. Report separately measured setup, run order, cache state and interruptions; label uninstrumented intervals unknown rather than inventing total tool/model costs. A local process timer or runtime property-change/readback/PNG cycle is a narrower measurement and must be labeled as such. Do not infer full development or migration speed from those narrower timings. In the approved GDScript workflow the engine is prebuilt; script loading/parsing/compilation and applicable asset/shader preparation still occur, while app export is a separate delivery operation.

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

Needed project tool and dependency installations are owner-authorized; perform them without asking again. This supersedes the earlier per-install approval requirement. Use verified official sources and record installed versions and operations in `INSTALL_LOG.md` or the task’s retained installation record. The existing Godot/templates and pinned npm source plan remains in `discovery/TRUSTED_INSTALL_PLAN.md`. Purchases, paid services and new account connections still require a resource request using:

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

# Treasure Island Game — Agent Working Agreement

At task start, read the relevant lessons in [LEARNINGS.md](LEARNINGS.md). When a repeated or generalizable mistake is exposed, add or refine a concise lesson there with observed evidence, known cause or uncertainty, and a practical prevention check; keep routine round history in RETRO.

## Mandatory orchestration boundary

The primary `/root` agent is an **ORCHESTRATOR ONLY**, never an executor, for all work in this project. It may decompose and assign work, monitor and coordinate named subagents, review their evidence, accept or reject results, update plans and goals, and communicate with the owner.

The primary `/root` agent must never author or edit code, assets, tests, documentation, skills, or data; browse or research directly; generate assets; install or download resources; or run implementation, proof generation, validation, tests, exports, builds, launches, GUI actions, or other executor work. Every research, edit, implementation, generation, validation, test, install, download, export, build, launch, and GUI action must be delegated to a named subagent with a concrete, bounded assignment.

The primary `/root` agent may use coordination tools and the minimum read-only inspection needed solely to review or verify subagent output. Reuse a small number of appropriately bounded agents; do not over-delegate or over-analyze. This rule is persistent and takes precedence over any older wording that assigns direct editing or execution to the project lead or `/root`. It does not relax or replace any approval, external-service, decision-boundary, provenance, or data-contract rule below.

## Periodic team-efficiency review

At meaningful work checkpoints, ordinarily after a few substantial work rounds and earlier when repeated churn appears, `/root` assigns a named independent subagent to evaluate other subagents' efficiency. Sample relevant task/tool activity and `discovery/RETRO_LOG.md`; distinguish necessary evidence and acceptance checks from repeated low-value cycles, duplicated work, or avoidable waits. Keep the review bounded and its findings concise and evidence-backed. Keep it quiet; do not turn it into an audit, timer or reporting framework.

When useful, recommend one small, reversible process experiment at a time with a simple observable measure, such as fewer redundant reruns or less avoidable waiting. `/root` reviews the findings and may approve routine process changes within existing authorization, delegates execution, and has the responsible subagent record a before/after comparison in existing retrospective notes at a later meaningful checkpoint. Retain useful changes and revise or undo ineffective ones.

Efficiency work must preserve the mandatory checks in [What done means for a building](#what-done-means-for-a-building) and all project invariants. Changes to approved player-facing behavior, workflow, scope, data contracts, or core invariants retain the existing owner-approval requirements; efficiency review does not grant an exception or make `/root` an executor.

## Architectural study scope and progress review

Between **every architectural study**, ROOT must assign a named independent [velocity/progress-and-scope reviewer](.claude/agents/ti-study-progress-review.md), separate from the author and the existing code and visual reviewers. This is mandatory for whole-building, architectural-section and isolated representative-assembly studies, including studies already pending when this rule takes effect. Apply it before another study or promotion; an in-budget revision cannot bypass it by being renamed a microstudy. It supplements the periodic team-efficiency review rather than replacing it.

The reviewer directly compares truthful references and actual baseline/current gameplay originals and answers two questions:

1. Is the chosen zoom level appropriate to the remaining overall island/building completion? Follow the zoom-in authoring pattern below and choose the highest unresolved level. Detail work cannot substitute for unresolved large architectural pieces; do not invent geometry on reference-supported blank walls or force needless massing changes when that level is already sound.
2. Does this study make substantial overall progress within that meaningful scope? Added complexity, completed tasks, test PASS, image counts or local detail changes alone are not progress. Inspect the full composition and remaining gaps at ordinary gameplay distance, with dated observation/inference limits; isolated studies must show how their result advances the intended building/family, not claim unrendered integration.

Return **PASS**, **RESCOPE** (the selected scope misses the important architecture), or **REWORK** (the scope is appropriate but the result lacks substantial progress), with concise concrete comparison evidence and the next architectural area. Missing usable comparison evidence cannot earn PASS. Record the decision in the existing ordinary handoff/task note and the reviewer's own RETRO; no numeric velocity score, timing framework, new receipt/schema or report layer. PASS permits ROOT to consider the next bounded assignment, not building acceptance or an automatic engine transfer. RESCOPE/REWORK blocks the next microstudy and promotion: ROOT assigns corrected scope or rework of the same meaningful scope, then obtains the same independent decision on the resulting progress. Neither completing checks nor changing a study number clears that decision.

ROOT remains personally accountable for substantial progress, not merely receipt of a reviewer PASS. After this harness is pushed, ROOT must orchestrate one complete cycle through named executors and then personally compare the actual matched before/after gameplay originals and truthful references. Judge overall architectural progress against a modern video-game quality bar, substantially above the current placeholder world. Reject insufficient scope, local polish or inadequate whole progress even when the reviewer and technical checks pass; require RESCOPE/REWORK and record the judgment briefly in the ordinary task note. Personal pixel/evidence review is orchestration: ROOT still must not author, render, test or otherwise execute the cycle. This first-cycle check adds no report or metrics framework and does not replace the between-every-study decision.

Authors hand off the intended contribution to whole completion, baseline/current originals and references, what materially changed and what remains unresolved. ROOT must consume this decision before next-study GO, including the currently pending B1 study008 and isolated B2 work. All existing independent CODE, whole all-side/reference/context/island visual, fit/stairs/spray/REST, full-suite, source/inventory/protected-region/privacy and terminal/slot gates remain mandatory. This review cannot waive them or revoke historical recognition credit.

### Zoom-in authoring pattern

Build from large architecture toward small detail, judging each level in the actual whole-building/site gameplay composition:

1. **Whole building/site:** establish the main volumes, massing, roof silhouette, proportions and relative placement within the frozen source layout.
2. **Sections and shared modules:** resolve major architectural sections and their relationships, then design complete representative repeated assemblies in a suitable shared family and apply supported instance variants.
3. **Materials and detail:** refine coherent PBR materials, surface response, decals and small details once the larger architecture reads convincingly.

These are outcome-driven priorities, not a rigid waterfall or new approval stages. Introduce materials early when needed to read architecture, and return to a larger level whenever actual pixels expose a composition problem. Do not spend successive microstudies polishing detail while major pieces remain unresolved. The existing progress reviewer must require RESCOPE or REWORK when that happens. Aim for modern video-game quality; existing assets are a floor, not a ceiling. Truthful dated references, protected scope, native fit/playability and independent all-side review remain mandatory throughout.

## Current phase

Implementation authorized for named executing subagents. On 2026-08-27 the owner explicitly approved the exact Godot bundle in `discovery/APPROACH_PROPOSAL.md`, including its vetted, logged downloads. Build and verify the first playable while preserving the approved product brief and the source-ID coverage contract; this authorization never makes the primary `/root` agent an executor.

## Development environment

All development and checks run in the Linux devcontainer (`.devcontainer/`) on the owner's GMKtec, with the AMD GPU passed through. Creating the container installs the pinned Godot 4.7.2, its Linux and macOS export templates, Codex, Claude Code and Node dependencies.

- Start Godot only through `tools/godot`; never hardcode a Godot path. It runs `--headless` work directly and gives rendering runs a private headless Weston display on the GPU. Do not use xvfb: Godot silently falls back to CPU rendering (llvmpipe) under it.
- Tests and checks that need no pixels run `--headless`. Screenshots run without `--headless`.
- Record what actually ran (`DisplayServer.get_name()`, `RenderingServer.get_video_adapter_name()`) rather than hardcoding a platform, renderer or GPU name, and never require a specific one.
- Git: `post-create.sh` sets the bot's commit identity. `git push` goes over HTTPS through DevPod's credential helper. `gh` has no login of its own; for PRs and the API, pass a token per command without saving it: `GH_TOKEN=$(printf 'protocol=https\nhost=github.com\n\n' | git credential fill | sed -n 's/^password=//p') gh pr create ...`.
- Textures: generate one with `tools/generate-texture "<description>" game/resources/<path>.png`. It runs Codex's image generation on the owner's ChatGPT plan (Codex logged in with `codex login --device-auth`), following the building-texture skill. Generated textures must be original, never a copy of a reference photo.
- The owner plays on a Mac. Build for it only when asked, with `tools/build-mac.sh` (see [Mac builds](#mac-builds)).

## Approved product brief

- Personal hobby project for private use; no public release is planned.
- World boundary: Treasure Island, San Francisco only. Yerba Buena Island and bridge approaches are out of scope unless later approved.
- World coverage: model Treasure Island at island scale using a frozen latest-available OpenStreetMap snapshot as the authoritative horizontal layout inventory. Represent all Treasure Island terrain/shoreline features, roads/paths, major public spaces/land use, and exterior building footprints in that snapshot. Use the approved bounded USGS 3DEP bare-earth source for vertical terrain on Treasure Island and YBI. Individual apartments, floor plans, rooms, and interiors are out of scope.
- Time setting: broadly present day as represented by that latest OSM snapshot. Do not reconcile it against a separate 2026 ground-truth inventory or reject it because reality may differ.
- Current first-playable actions: third-person walking, running, an unlimited hold-to-rise jetpack on `Space` with slow descent when released, and placing one predefined spray-tag decal on eligible building surfaces in the spirit of Half-Life 1's spray interaction.
- Current play target: the owner's MacBook Pro with Apple M1 Pro (10-core CPU, 32 GB memory), using mouse and keyboard only. Development happens on Linux; see [Development environment](#development-environment).
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

## Whole-building exterior coverage

Owner clarification, 2026-10-07: every exterior side must be modeled and independently reviewed. Before inferring a side, seek its evidence in Google Street View, Google Maps photographs and relevant web sources. In the ordinary task/reference note, identify each side's useful sources and dates, or the searches/access/occlusion limits that left evidence unavailable; disclose subsequent interpolation or production inference. Lack of an existing reference is not evidence that a side is blank. No new manifest, image quota or evidence framework is required.

Review actual gameplay views around the entire building against the available side-specific references, including materials, openings, roof edges and junctions. A public-facade or finish PASS cannot become whole-building PASS while other visible sides remain unfinished or unreviewed. Inferred sides still require coherent, believable modeling and an explicit visual judgment. Historical protected facade-art scope is not a reason to call an unfinished building done: assign a bounded rescope for supported finishes/details while preserving frozen OSM XZ, source identity, inventory, native integrity and approved gameplay. Preserve historical recognition credit while reopening an unsupported current whole-quality claim honestly.

## Authoring

For bounded mechanics drivers, preserve each case’s HOLD and the aggregate HOLD. Continue unrelated cases only after recording supported, stopped, input-released rest while the stock controller is still active, then verifying a safe disabled final state; stock disable zeroes velocity, so post-disable zero alone is not rest proof. Source, identity, controller, setup, recovery or unsafe-final failures stop execution; skip cases dependent on a failed prerequisite. Reuse completed unchanged cases instead of replaying them solely for bookkeeping.

Before any new building implementation, apply the [existing-asset comparison and reuse rule](.agents/skills/building-texture/SKILL.md#before-every-new-building-compare-and-reuse): compare observed structure with existing shared assets, use a suitable shared base with instance variants, or briefly explain why a new base is needed. A named whole-family art owner may author shared design and instances; independent verification remains per building. Record this decision in one line of the ordinary task note, without a new report or gate.

Assign one named art owner for a bounded whole-building or verified-family study: target/source paths, dated real-world references, protected regions and systems, allowed edits, proven render driver, finite engine/iteration budget and stop conditions. Within those bounds the author owns research, composition, implementation and self-inspection; these are functions, not mandatory separate handoffs. Reference-supported roof/silhouette, geometry, materials and immediate setting may change together while preserving frozen OSM identities/footprints, protected regions, stock controls and gameplay integrity. Texture-only restrictions apply only to texture assignments. Bespoke tree modeling is deferred to a future vegetation-asset pass: do not require custom trees in building studies or reject a study solely because trees are absent. Existing world vegetation may remain, and simple ground treatment is allowed; judge the architecture and materials on their own merits. Judge whether the result is believable and recognizable against the real world; sensible game-art inference need not reproduce it one-to-one.

The ordinary iteration loop is **edit assets/code -> run or reload the source project -> capture and inspect the actual render early**. The first coherent actual-world render precedes completed independent review: perform focused identity, containment, local contact and execution-safety preflight, then inspect pixels. Independent technical review concentrates on changed risk seams and reuses applicable unchanged evidence; the checks in [What done means for a building](#what-done-means-for-a-building) remain required before promotion. Use the approved gameplay camera and matched reference/baseline views where applicable. Bring the first coherent study to the independent visual reviewer before extended refinement. Run focused source and mechanical checks for the change; visible stairs require actual stock-player walking attempts up and down each flight, with contact, grounding and destination evidence. Jetpack access or static floor contact alone does not establish stair walkability. Preserve the approved walk/run/jetpack/camera/spray controls.

For ground-contacting details, the first preflight must compare their intended footprint and elevations with the actual local land, visible area surfaces and source wall-bottom elevations. Keep visible area geometry distinct from colliding land. The first movement/support checks must use the actual source world with local terrain intact and record stock-player contacts and destinations. Flat fixtures may aid composition, but cannot establish site fit or locomotion. Keep these checks focused on the affected junctions, preserving source geometry, land/area surfaces and the approved controls.

Before committing, run the whitespace check (`git diff --check`, plus the same check on every new untracked file) on the complete patch, using the explicit intended file list without staging unrelated work.

### Tests

`tools/test.sh` runs every test: a junk check on new files (no screenshots, videos, builds, logs, reference photos or files over 5 MB outside `game/resources/` and `generated/`), the behaviour tests, the whole-island check of every scored building, and the world-generator determinism check. It must pass before anything is pushed to `main`; fix the cause of a failure, never weaken or skip a test to make it pass.

Tests check behaviour: the game loads and plays, a building is solid and fits, generated data is valid. Never write a test or runtime check that compares file checksums, pins byte-identical source or evidence files, or asserts snapshot counts (triangles, meshes, records) that change whenever the world legitimately changes. Git already records what changed. One deliberate exception: `game/scripts/world/generated_world_contract.gd` checks the generated world against the manifest the generator writes with it, so regenerate them together with `tools/build_godot_world.mjs`; the determinism check in `tools/test.sh` confirms they match the sources.

### What done means for a building

What matters: the building looks good, it fits into the island, and the island as a whole still looks good. A building is done, counts toward the recognition score and is merged to `main` when all of these pass:

1. **Fit and playability:** `game/tests/shared/building_fit_test.gd -- --source <key>` passes. It checks that the visible roof and walls are solid, that the walls reach the ground, and that the stock player can walk up to the building from each side and arrive next to it without falling or needing recovery. If the building has walkable stairs, list each flight in its catalog entry as `"stairs": [{"bottom": [x, z], "top": [x, z]}]`; the test walks each one up and down. `tools/test.sh` must pass too.
2. **Screenshots:** `game/tests/shared/building_shots.gd -- --source <key> --island` produces gameplay close-ups from each side, raised views of the building in its surroundings, and fixed whole-island overviews. Take the island overviews before and after the change.
3. **Independent review:** the mandatory [study scope/progress decision](#architectural-study-scope-and-progress-review) must be PASS. The independent code reviewer ([ti-code-review](.claude/agents/ti-code-review.md), reading the diff for sloppy or risky code and shared-code damage) and the independent visual bar-raiser (neither of them the author) must also pass the change. The visual reviewer compares the close-ups with dated real-world references, judges the in-context views for fit with neighbours, ground and scale, and compares the before/after island overviews.

Then mark the building accepted in `discovery/facades/facade-recognition-catalog.json`: set its `claim_status.reference_recognizable` to `accepted` and add an `acceptance_records` entry naming the review (`review_id`, `review_kind`, `status`). The score is the number of accepted buildings; `island_test.gd` checks each one loads and fits. Run `tools/test.sh` and merge. Record each building's verdicts in the ordinary task note or commit message. Do not create acceptance packets, image-tree digests, package receipts, candidate or exact-current exports, release-closure or publication records, or new per-building evidence-check scripts. Preserve the 213-unit inventory, previously accepted credit, protected scope and reference privacy. Several ready buildings may be merged together, each with its own verdicts.

### Mac builds

Build for the Mac only when the owner asks, with `tools/build-mac.sh` from a committed state. It exports the macOS build (ad-hoc signed, not notarized) and a Linux build of the same commit, runs `game/tests/shared/build_content_audit.gd` on the exported data pack, and launches the Linux build to confirm the island loads. Both checks must pass. The content audit lets only `game/`, `generated/` and Godot's own files into the build, and images only from `game/resources/`; it also rejects names that look like reference photos. It can't recognize a renamed photo, so Street View and other reference photos must never be saved anywhere under `game/` (they stay outside Git). Never weaken the audit or work around a failure; remove the offending file from the export instead. No signing identity, notarization, checksum binding, independent package review or release record is involved.

## Bounded subagent execution

Never use `ultra` reasoning effort for any subagent. Explicitly select a supported non-ultra reasoning effort at every subagent dispatch instead of inheriting the parent’s effort. Model choice is separate from reasoning effort; this rule does not change the primary/root agent’s setting or runtime configuration.

Owner-authorized Codex routing, updated 2026-10-05: modeling runs in Claude Code on Opus 5.5 (below), not in Codex sessions. Codex sessions use GPT-6.1 Sol High (model gpt-6.1-sol, reasoning effort high) for independent visual critique/bar-raiser and architectural study scope/progress review work and Astra Medium (model gpt-6-astra, reasoning effort medium) for the other roles; Codex also generates textures for the modeler through `tools/generate-texture`. ROOT may select a supported non-ultra escalation when warranted; no fixed retry count, automatic escalation ladder or additional approval gate applies. Keep visual judging independent of the author. Select a supported non-ultra effort explicitly at every dispatch; never inherit effort or use ultra.

Task-specific owner override, Mersea whole-site study (2026-10-05): modeling uses GPT Astra (`gpt-6-astra`) at reasoning effort `low`; all review roles for this study use GPT-6.1 Sol (`gpt-6.1-sol`) at reasoning effort `high`. This explicit session instruction supersedes the generic Claude modeling and Codex review defaults above for this Mersea study and persists across resumptions or re-injected copies of generic instructions until the owner changes it. Other task defaults remain unchanged.

Task-specific owner override, Building 2 / Hall of Transportation study (2026-10-07): the owner explicitly selected "astra low" after the Claude session cap. Modeling for `w24274434` uses GPT Astra (`gpt-6-astra`) at reasoning effort `low`; all review roles for this study use GPT-6.1 Sol (`gpt-6.1-sol`) at reasoning effort `high`. This overrides the generic modeling/review defaults for Building 2 only and persists across resumptions until the owner changes it. Coordination and documentation remain Astra Medium. Other building defaults, including the separate Mersea override, are unchanged.

Owner-authorized Claude Code routing, 2026-10-02: Claude Opus 5.5 (`claude-opus-5-5`) at effort `max` for modeling (`ti-implementation`) and effort `high` for every other role. Claude Code's delegation tool has no effort parameter, so each role file's frontmatter (`model: opus`, `effort`) is the per-dispatch selection; don't override it at dispatch time. `max` is not `ultra`.

Use a small number of named agents with concrete targets, output locations, stop conditions and ownership. The existing role prompts and project skill are indexed in [the harness entrypoints](CLAUDE.md#persisted-entrypoints). Other harnesses can read these same files without inventing a callable agent configuration or copying local session state. An agent must not independently accept its own implementation; a technical PASS does not supply the separate visual decision. Routine handoffs contain short status, actual changed paths, source revision, rendered evidence link/result and any blocker. Do not add manifests or JSON/hash/count reporting layers; the reviewed commit is the record of what was reviewed.

Use the current harness’s actual delegation tools. In the Codex multi-agent session, dispatch every new bounded assignment with `followup_task`, whether the target agent is busy or idle; `send_message` only supplies status or clarification and does not restart a completed agent. In another harness, use its available equivalent to start the named role with the bounded task. Do not treat role filenames as callable tools. Coalesce duplicate assignments and preserve the same ownership, review and engine-release gates.

For building screenshots and fit checks, use the shared `game/tests/shared/building_shots.gd` and `building_fit_test.gd`; extend them when a building needs something they lack, rather than copying a per-building driver. Do not add per-building evidence-check scripts, or assertions on hardware, renderer or file checksums. For other bounded mechanics, such as stair walking, reuse the complete successful driver and current supported invocation, adapting target paths and measured expectations together before running it. Use the maintained `game/tests/support/building_study_geometry.gd` for supported native face collection/comparison: configure the actual producer, instance transforms and expected positive coverage instead of copying per-building collectors. Keep target ownership/roles and stock movement/rest in the complete existing driver; extend shared code only for a demonstrated new producer. See CLAUDE’s shared verification entrypoint. For a new target capture manifest, adapt the complete working donor manifest, override named target, pose and output fields, and deliberately remove the old target identity; do not reconstruct only a subset of required view fields. Check those adaptations in the existing whitespace/source preflight, without a new validator, gate or test framework. Root serializes heavy render/engine work; the next owner starts only after explicit slot release and actual terminal/PID evidence. A tool-observation timeout or an old output file is not evidence of process completion. After an interruption, inspect the existing live handle, actual process identity, logs and receipts before acting. Resume waiting on that same handle if it is running; if it has completed, consume its terminal result and release evidence. Do not repeat an already completed checkout, import or invocation because a conversation ended. ROOT authorizes the named owner’s bounded edit/render/inspect loop once, including source paths, supported driver/invocation family, finite engine budget and stop conditions. That owner may perform in-budget revisions and fresh captures without per-invocation ROOT reapproval while holding the serialized slot. Preserve each failed attempt and use fresh outputs; stop on unsafe behavior, ambiguous ownership, exhausted budget or a required change outside the approved boundary. Retain and observe a live handle to terminal before any next invocation. A slot transfer still requires explicit release and a named assignment; an empty slot alone is not GO. A Mac build outside the loop requires its own assignment.

The devcontainer installs Git LFS with `--skip-smudge`, so evidence AVIs stay LFS pointers in a checkout. Do not hydrate or download LFS assets without authorization; an LFS pointer is not a usable runtime asset. Do not change global Git configuration or hooks.

## Timing claims

For a requested full workflow comparison, time from before the actual source edit through run/reload, saved screenshot, delivery to the reviewing model and its explicit visual verdict. Include tool transport, failures/retries and waiting within that boundary. Report separately measured setup, run order, cache state and interruptions; label uninstrumented intervals unknown rather than inventing total tool/model costs. A local process timer or runtime property-change/readback/PNG cycle is a narrower measurement and must be labeled as such. Do not infer full development or migration speed from those narrower timings. In the approved GDScript workflow the engine is prebuilt; script loading/parsing/compilation and applicable asset/shader preparation still occur, while app export is a separate delivery operation.

## Approved implementation approach

- Godot 4.7.2 standard edition, GDScript, and Forward+.
- One Godot unit equals one meter in a local Treasure Island coordinate system.
- Offline `osmium` plus a project-owned Node converter using pinned `polygon-clipping@0.15.7` and `earcut@3.2.3`.
- Deterministic, OSM-ID-traceable generated island geometry and coverage evidence.
- A frozen, bounded official USGS 3DEP elevation crop plus deterministic modest terrain derivation; OSM remains authoritative for horizontal geometry and source coverage.
- A project-owned `CharacterBody3D` walk/run/jetpack controller and `Node3D` pivot -> `SpringArm3D` -> `Camera3D` mouse camera; no controller/camera add-on.
- Projected `Decal` spray placement on eligible building walls.
- Development and checks on Linux with Vulkan/Forward+ in the devcontainer; a private macOS build on request.

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
- Use simple massing for inventory coverage; for assigned building-quality work, judge the complete visible result against dated real-world references, not placeholder parity.
- Avoid recurring services and production-scale infrastructure unless their value is unusually clear.
- Do not spend time on storefront certification, monetization, analytics, live operations, extensive legal review, or public-release polish.
- Keep lightweight provenance notes for reproducibility. Do not perform a legal audit.

## Resource and access requests

Needed project tool and dependency installations are owner-authorized; perform them without asking again. This supersedes the earlier per-install approval requirement. Use verified official sources and record installed versions and operations in `INSTALL_LOG.md` or the task’s retained installation record. Godot and its export templates are installed by `.devcontainer/setup-godot.sh` (official release assets, pinned SHA-256); npm dependencies are pinned in `package-lock.json`. Add a new tool to the devcontainer setup rather than installing it by hand, so a rebuilt container still has it. Purchases, paid services and new account connections still require a resource request using:

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

When the owner needs to take over for login, CAPTCHA, approval, play feedback, or another hands-on step, the project lead gives them a short written prompt in the session. Do not interrupt for routine progress updates.

## Retrospective logging

At the end of each assigned work round, every executing subagent, reviewers included, adds a concise entry to `discovery/RETRO_LOG.md` under its own named section. Write it before the round's final commit and include it in that commit; it is the one file a read-only reviewer edits:

- What worked well
- What did not work well
- What the team should change next time

Be concrete and candid. Record process lessons, not praise. Never include credentials, serial numbers, hardware UUIDs, personal identifiers, or other secrets. The project lead verifies through read-only review that every executing subagent has written an entry before closing the round; the project lead does not edit the log itself.

## Owner resumption

The owner explicitly resumed improving the buildings identified by the 34-building audit. Keep building work going until the owner says otherwise; when a decision genuinely needs the owner, stop that work and ask (see [HUMAN.md](HUMAN.md)). Surface meaningful milestones, stalls, failures or needed decisions; keep routine progress quiet.

# Treasure Island harness

@AGENTS.md

The imported [project agreement](AGENTS.md) is the shared authority. The primary conversation is `/root`: it orchestrates and reviews read-only; named, bounded subagents execute. Other clients should read AGENTS.md directly. Keep one agreement, not separate copies for different assistants.

Follow the current [quota wind-down rule](AGENTS.md#owner-resumption-and-quota-wind-down--updated-2026-09-28): check fresh weekly usage hourly and at major checkpoints; at 50% used / 50% remaining, stop new dispatch, safely checkpoint in-flight work, commit and push MAIN/main, then pause work and the reminder. Reminder activation must be verified, not inferred.

## Persisted entrypoints

Subagent dispatch must follow [AGENTS.md](AGENTS.md#bounded-subagent-execution): never use `ultra`; explicitly select a supported non-ultra effort instead of inheriting the parent’s effort. That section defines both harness routings: Codex uses Astra Low modeling, GPT-6.1 Sol High independent visual critique/bar-raiser and Astra Medium other source/mechanical/release review, with discretionary supported non-ultra escalation; Claude Code uses Opus 5.5 Max for modeling and Opus 5.5 High for every other role, set in the role frontmatter below. Preserve independent review gates; the primary/root setting is unchanged.

| Role prompt | When used |
|---|---|
| [ti-implementation](.claude/agents/ti-implementation.md) | Bounded asset, source, helper or candidate implementation; source render early. |
| [ti-reference-research](.claude/agents/ti-reference-research.md) | Exact target/side reference acquisition or source association within authorized access. |
| [ti-source-mechanics-review](.claude/agents/ti-source-mechanics-review.md) | Independent source, capture-readiness and actual affected-mechanics review. |
| [ti-visual-review](.claude/agents/ti-visual-review.md) | Separate per-unit visual bar raising against actual dated reference pixels. |
| [ti-release-review](.claude/agents/ti-release-review.md) | Independent exact candidate/current package, privacy and release review. |
| [ti-efficiency-review](.claude/agents/ti-efficiency-review.md) | Bounded periodic review of other actors; at most one reversible experiment. |
| [ti-documentation](.claude/agents/ti-documentation.md) | Serialized harness, handoff, lessons and authorized documentation publication. |

These project-owned role files are reusable instructions, not persisted running agents. Use the actual delegation tool available in the client, loading the chosen role when it is not discovered automatically. Codex task handles, letter assignments and per-dispatch selections are transient, subject to the routing defaults in AGENTS.md; the [current handoff](NEXT_AGENT_HANDOFF_2026-09-08.md) records work state, not callable tool configuration. There is no project `.codex/config.toml`, `.claude/commands/` or separate `.claude/skills/` catalog to install. Account-level client configuration is not part of this repository.

The existing skill is [building-texture](.agents/skills/building-texture/SKILL.md), with [UI/invocation metadata](.agents/skills/building-texture/agents/openai.yaml), three linked references and its proof helper. Use `$building-texture` when the client exposes that skill, or explicitly read the linked entrypoint before any new building or facade-art task, including its mandatory existing-asset comparison and shared-family reuse rule. If it is absent from a client’s skill list, the committed path remains usable; do not claim that a missing catalog entry is installed or create replacement copies. Load only the applicable references. For whole-building quality, use the art-owner scope and bounded source-render loop in AGENTS; texture-only limits do not constrain authorized roof/geometry/setting work. Reference access, serialized engine ownership and independent promotion gates remain mandatory.

At the end of reference capture, ROOT applies the canonical [reference-sufficiency review](.agents/skills/building-texture/SKILL.md#reference-sufficiency-before-authoring) before artist dispatch or continued authoring.

The maintained [source-surface comparator](tools/source_surface_comparator.py) exposes `compare_source_surfaces(before, after, prior_before, prior_after)` for independent native-evidence readers. Caller-owned input pins, expected source coverage and the existing review gates remain required; usage limits and the first completed comparator reuse trial (second pending) are in [LEARNINGS](LEARNINGS.md#validate-the-representation-actually-consumed).

For model comparisons, use the canonical [blind shootout protocol](discovery/MODEL_SHOOTOUT.md): critique HTML and owner vote first, then isolated modeling through the committed `tools/model_shootout/run_capture.py <variant> <phase> --packet-root <private-packet>` renderer (`--godot` overrides the clone-local binary). Participants author models, not capture machinery.

## Shared building-study geometry verification

`game/tests/support/building_study_geometry.gd` replaces copied face collectors used by Hawkins002/Chapel003-style checks. Configure `collect(mesh, transforms, producer, cutoff)` with `INDEXED_ARRAYS` for the raw indexed producer, or `MESH_GET_FACES` only when the actual collider uses Godot's transformed/snapped TriangleMesh path. Transforms map mesh-local to collision-local, in instance order; MultiMesh callers supply each `instance.transform * multimesh.get_instance_transform(i)`. The optional cutoff defaults to no filtering and must match an existing producer, never a new tolerance. `compare(collection, shape.get_faces(), expected_vertex_count)` requires positive complete coverage and exact ordered equality, returning full observed operands even on failure. Save it into the existing receipt before failing the driver guard.

This is geometry evidence, not a generic acceptance harness. Keep target/source keys, role/layer/receiver and native body/server ownership checks in the existing driver, along with complete flight/support/released-rest, terminal/PID and restoration handling. Configure/reuse those complete drivers rather than reconstructing partial per-target checkers. The existing batch06 receiver fixture now uses the shared indexed collector while retaining its historical triangle-signature and ownership predicates; archived historical scripts remain unchanged.

Bounded native validation (requires the ordinary serialized engine authorization): `Godot --headless --path . --script game/tests/headless_building_study_geometry_contract.gd`, then the existing `game/tests/headless_batch_06_exact_receiver_trial_contract.gd` invocation. The focused contract covers producer distinction, transform/order, multiple instances, nonempty coverage, failed operands and explicit filtering. No scene import, capture or release is implied. Unsupported producers need a focused shared extension and their existing cases, not a universal schema or new reporting layer. Validation on2026-09-30: the focused native contract passed. Independent review confirms all direct batch06 targets passed the shared collector, historical signature/count/ownership and duplicate checks before the unchanged whole-island stage held. The reported `surfaces=null` was formatted after teardown and does not identify the failed count or loaded-target predicate; full fixture PASS remains unestablished. See the named RETRO result for logs and independent interpretation.

Use [README](README.md) for play/setup, [AGENTS](AGENTS.md) and [LEARNINGS](LEARNINGS.md) before project changes, and the handoff for current source/evidence state. Recognition remains per unit: implementation, independent source/mechanics, separate actual-pixel visual judgment and independent release acceptance are distinct even when ready units share a candidate package. Dispatch and serialized engine ownership follow AGENTS; none of these prompts authorizes a new resource, engine run, export or acceptance claim by itself.

At the existing freeze/readiness boundary, compare current format-probe path/hash membership in JS `acceptedAuthorityRuntimeDependencies`, the native registry fixture and production loader together; retain privacy-before-substitution, exact probe counts and recursive failures. See [the concrete lesson](LEARNINGS.md#runtime-provenance-and-dependency-scanner-membership). This adds no gate or replay.

# Treasure Island harness

@AGENTS.md

The imported [project agreement](AGENTS.md) is the shared authority. The primary conversation is `/root`: it orchestrates and reviews read-only; named, bounded subagents execute. Other clients should read AGENTS.md directly. Keep one agreement, not separate copies for different assistants.

## Persisted entrypoints

Subagent dispatch must follow [AGENTS.md](AGENTS.md#bounded-subagent-execution): never use `ultra`; explicitly select a supported non-ultra effort instead of inheriting the parent’s effort. That section defines the routing: modeling in Claude Code on Opus 5.5 (effort `max`; other roles `high`, set in each role file's frontmatter), with `tools/generate-texture` for generated textures; Codex sessions use GPT-6.1 Sol High for visual critique and Astra Medium for other roles. Preserve independent review gates; the primary/root setting is unchanged.

| Role prompt | When used |
|---|---|
| [ti-implementation](.claude/agents/ti-implementation.md) | Bounded asset, source, helper or candidate implementation; source render early. |
| [ti-reference-research](.claude/agents/ti-reference-research.md) | Exact target/side reference acquisition or source association within authorized access. |
| [ti-code-review](.claude/agents/ti-code-review.md) | Independent review of a change's diff for sloppy or risky code and shared-code damage. |
| [ti-visual-review](.claude/agents/ti-visual-review.md) | Separate per-unit visual bar raising against actual dated reference pixels. |
| [ti-efficiency-review](.claude/agents/ti-efficiency-review.md) | Bounded periodic review of other actors; at most one reversible experiment. |
| [ti-documentation](.claude/agents/ti-documentation.md) | Serialized harness, handoff, lessons and authorized documentation publication. |

These project-owned role files are reusable instructions, not persisted running agents. Use the actual delegation tool available in the client, loading the chosen role when it is not discovered automatically. Codex task handles, letter assignments and per-dispatch selections are transient, subject to the routing defaults in AGENTS.md. There is no project `.codex/config.toml`, `.claude/commands/` or separate `.claude/skills/` catalog to install. Account-level client configuration is not part of this repository.

The existing skill is [building-texture](.agents/skills/building-texture/SKILL.md), with [UI/invocation metadata](.agents/skills/building-texture/agents/openai.yaml), three linked references and its proof helper. Use `$building-texture` when the client exposes that skill, or explicitly read the linked entrypoint before any new building or facade-art task, including its mandatory existing-asset comparison and shared-family reuse rule. If it is absent from a client’s skill list, the committed path remains usable; do not claim that a missing catalog entry is installed or create replacement copies. Load only the applicable references. For whole-building quality, use the art-owner scope and bounded source-render loop in AGENTS; texture-only limits do not constrain authorized roof/geometry/setting work. Reference access, serialized engine ownership and independent promotion gates remain mandatory.

At the end of reference capture, ROOT applies the canonical [reference-sufficiency review](.agents/skills/building-texture/SKILL.md#reference-sufficiency-before-authoring) before artist dispatch or continued authoring.

The maintained [source-surface comparator](tools/source_surface_comparator.py) exposes `compare_source_surfaces(before, after, prior_before, prior_after)` for comparing a building's surfaces before and after a change. Usage limits are in [LEARNINGS](LEARNINGS.md#validate-the-representation-actually-consumed).

For model comparisons, use the canonical [blind shootout protocol](discovery/MODEL_SHOOTOUT.md): critique HTML and owner vote first, then isolated modeling through the committed `tools/model_shootout/run_capture.py <variant> <phase> --packet-root <private-packet>` renderer (`--godot` overrides the default `tools/godot`). Participants author models, not capture machinery.

### Delivering visual galleries in VS Code

For HTML galleries outside the remote workspace, prefer a static server bound to
`127.0.0.1` and give the owner its VS Code forwarded-port URL. For example,
`python3 -m http.server <available-port> --bind 127.0.0.1 --directory <gallery-dir>`;
forward that port in VS Code's Ports panel and open the displayed localhost URL
with **Browser: Open Integrated Browser**. Verify the index and image responses,
then inspect the actual browser page and loaded images using the applicable
browser skill. Retain the live server handle/PID and name its owner; leave it
running for the requested viewing session and report how to stop it. Do not
broaden workspace trust or copy private reference photos into Git/game to make a
gallery open. `tools/browser` runs the agent's headed verification/reference
browser; it is separate from the owner's VS Code integrated browser. See the
[observed remote-file restriction](LEARNINGS.md#serve-remote-visual-galleries-over-loopback-http).

## Shared building-study geometry verification

`game/tests/support/building_study_geometry.gd` replaces copied face collectors used by Hawkins002/Chapel003-style checks. Configure `collect(mesh, transforms, producer, cutoff)` with `INDEXED_ARRAYS` for the raw indexed producer, or `MESH_GET_FACES` only when the actual collider uses Godot's transformed/snapped TriangleMesh path. Transforms map mesh-local to collision-local, in instance order; MultiMesh callers supply each `instance.transform * multimesh.get_instance_transform(i)`. The optional cutoff defaults to no filtering and must match an existing producer, never a new tolerance. `compare(collection, shape.get_faces(), expected_vertex_count)` requires positive complete coverage and exact ordered equality, returning full observed operands even on failure. Save it into the existing receipt before failing the driver guard.

This is geometry evidence, not a generic acceptance harness. Keep target/source keys, role/layer/receiver and native body/server ownership checks in the existing driver, along with complete flight/support/released-rest, terminal/PID and restoration handling. Configure/reuse those complete drivers rather than reconstructing partial per-target checkers. The existing batch06 receiver fixture now uses the shared indexed collector while retaining its historical triangle-signature and ownership predicates; archived historical scripts remain unchanged.

Validation: `tools/godot --headless --path . --script game/tests/headless_building_study_geometry_contract.gd` (part of `tools/test.sh`).

Use [README](README.md) for play/setup, [AGENTS](AGENTS.md) and [LEARNINGS](LEARNINGS.md) before project changes. Recognition remains per unit: implementation, independent code review and separate actual-pixel visual judgment are distinct; [What done means for a building](AGENTS.md#what-done-means-for-a-building) lists the checks. Dispatch and serialized engine ownership follow AGENTS; none of these prompts authorizes a new resource, engine run, Mac build or acceptance claim by itself.


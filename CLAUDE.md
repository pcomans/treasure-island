# Treasure Island harness

@AGENTS.md

The imported [project agreement](AGENTS.md) is the shared authority. The primary conversation is `/root`: it orchestrates and reviews read-only; named, bounded subagents execute. Other clients should read AGENTS.md directly. Keep one agreement, not separate copies for different assistants.

## Persisted entrypoints

| Role prompt | When used |
|---|---|
| [ti-implementation](.claude/agents/ti-implementation.md) | Bounded asset, source, helper or candidate implementation; source render early. |
| [ti-reference-research](.claude/agents/ti-reference-research.md) | Exact target/side reference acquisition or source association within authorized access. |
| [ti-source-mechanics-review](.claude/agents/ti-source-mechanics-review.md) | Independent source, capture-readiness and actual affected-mechanics review. |
| [ti-visual-review](.claude/agents/ti-visual-review.md) | Separate per-unit visual bar raising against actual dated reference pixels. |
| [ti-release-review](.claude/agents/ti-release-review.md) | Independent exact candidate/current package, privacy and release review. |
| [ti-efficiency-review](.claude/agents/ti-efficiency-review.md) | Bounded periodic review of other actors; at most one reversible experiment. |
| [ti-documentation](.claude/agents/ti-documentation.md) | Serialized harness, handoff, lessons and authorized documentation publication. |

These project-owned role files are reusable instructions, not persisted running agents. Use the actual delegation tool available in the client, loading the chosen role when it is not discovered automatically. Codex task handles, letter assignments and model choices are transient; the [current handoff](NEXT_AGENT_HANDOFF_2026-09-08.md) records work state, not callable tool configuration. There is no project `.codex/config.toml`, `.claude/commands/` or separate `.claude/skills/` catalog to install. Account-level client configuration is not part of this repository.

The existing skill is [building-texture](.agents/skills/building-texture/SKILL.md), with [UI/invocation metadata](.agents/skills/building-texture/agents/openai.yaml), three linked references and its proof helper. Use `$building-texture` when the client exposes that skill, or explicitly read the linked entrypoint for its declared facade-art task. If it is absent from a client’s skill list, the committed path remains usable; do not claim that a missing catalog entry is installed or create replacement copies. Load only the applicable references. Geometry, reference access and engine execution retain the project’s boundaries.

Use [README](README.md) for play/setup, [AGENTS](AGENTS.md) and [LEARNINGS](LEARNINGS.md) before project changes, and the handoff for current source/evidence state. Recognition remains per unit: implementation, independent source/mechanics, separate actual-pixel visual judgment and independent release acceptance are distinct even when ready units share a candidate package. Dispatch and serialized engine ownership follow AGENTS; none of these prompts authorizes a new resource, engine run, export or acceptance claim by itself.

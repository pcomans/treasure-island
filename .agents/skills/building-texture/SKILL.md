---
name: building-texture
description: Research, specify, create, validate, and absolutely review exterior building textures for Godot, including homogeneous material tiles, architectural pattern tiles, module atlases, and unique elevations. Use when a building surface or facade image must match references, repeat without invented motifs, or fit an exact receiver; do not use for terrain, road, water, or building-massing work.
---

# Building Texture

Build evidence-backed exterior building textures whose repeat structure, physical scale, material behavior, and in-game appearance survive absolute review.

## Mandatory root boundary

- The primary `/root` agent is an **ORCHESTRATOR ONLY**, never an executor. It may define the bounded task contract, assign named subagents, monitor and coordinate them, review returned evidence, accept or reject results, update plans and goals, and communicate with the user.
- The primary `/root` agent must never perform research or browsing; author or edit textures, code, tests, proofs, documentation, skills, or data; generate assets; install or download resources; or run scripts, imports, integration, validation, tests, exports, builds, launches, or GUI actions.
- Delegate every research, specification, generation, normalization, proof, semantic review, art review, integration, validation, test, install, download, export, build, launch, and GUI action to a named subagent with a concrete scope and stop condition. Each executing subagent records what worked, what failed, and what should change in the shared retrospective log.
- Root may use coordination tools and the minimum read-only inspection needed solely to verify subagent output. Reuse a small number of bounded specialists; do not create agents or analysis rounds without a concrete need.
- This persistent boundary takes precedence over older workflow wording that assigns direct execution or file editing to root. It does not relax project approvals, privacy rules, external-service restrictions, receiver contracts, or geometry decision boundaries.

## Asset boundary and ownership

- Classify the requested output before making pixels:
  - `homogeneous_material_tile`: one local material field, with no facade-scale layout;
  - `architectural_pattern_tile`: a proven periodic architectural cell;
  - `module_atlas`: complete reusable motifs with explicit placement rules;
  - `unique_elevation`: a target-specific, nonperiodic elevation or mask.
- Apply repeat and seam gates only to axes and assets that claim repetition. A complete `module_atlas` motif does not need to tile, and a finite `unique_elevation` does not need a repeat cell.
- For texture-only tasks, route story count, silhouette, roofline, podiums, setbacks, deep recesses and collision to geometry rather than painting them into a texture. For an authorized whole-building study, the same art owner may change reference-supported geometry and immediate setting inside the explicit project scope; this texture skill does not impose a separate geometry approval.
- This skill is for building textures broadly. Windows are only one possible motif; the same repeat rules apply to bricks, blocks, panels, ribs, joints, doors, vents, louvers, balconies, trim, bands, and stains.

## Recognizability and evidence precision

When the user or project prioritizes recognizable game art over surveyed reconstruction, distinguish exact technical ownership from real-world measurement. The generated receiver, protected regions, and geometry/physics boundaries remain exact. Once the target, observed side or region, and motif family are adequately identified, unmeasured scale, count, cadence, and anchors may be bounded, reversible `production_inference`; they must never be labeled measured or as-built. Survey precision raises confidence but is required only when safe placement or geometry integrity depends on it.

## Root-coordinated workflow

1. ROOT assigns one named author the identity/receiver, asset kind, references, editable/protected paths, privacy boundary and finite attempt budget. Follow the project's [bounded authoring loop](../../../AGENTS.md#authoring-and-batch-delivery). Research, specification, implementation, applicable proof and self-inspection belong to that author; do not require a separate actor or handoff for each function.
2. Read [research-and-repeat-blueprint.md](references/research-and-repeat-blueprint.md) for applicable texture evidence/grammar and [godot-material-contract.md](references/godot-material-contract.md) for receiver integration. Separate observations from reversible inference. Declare repeat cells/seams only for periodic assets; finite motifs need bounds and placement, not artificial repeat proof. Reference access does not grant download/reuse permission.
3. If image generation is requested, follow the installed image-generation skill and privacy/account rules, using the built-in path and a small declared batch (normally 2–4 candidates, at most one targeted correction). Otherwise author the assigned procedural/code/asset changes without requiring generation. For raster assets claiming repetition, use the existing helper:

   ```bash
   node .agents/skills/building-texture/scripts/build_proofs.mjs <input-tile> <new-or-empty-output-dir>
   ```

   Its numeric/proof outputs screen candidates; they do not supply semantic or art acceptance.
4. Reach the first coherent actual-world render after focused identity/site/execution-safety preflight, before completed independent review or export. Within the approved finite loop, inspect and revise using the supported driver without per-invocation reapproval; retain serialized engine ownership, live handles, fresh outputs and failed records. Technical review addresses changed risk seams rather than replaying unrelated gates.
5. An independent visual reviewer uses [semantic-art-review.md](references/semantic-art-review.md) to judge actual references and gameplay pixels, including the complete building and owner-approved visual quality anchor when assigned. Keep this reviewer separate from implementation and technical judging. Applicable independent source/mechanical decisions and batch release gates remain required before promotion. ROOT reviews evidence read-only; no author self-grants acceptance or credit.

Export/signing/package paperwork belongs at the batch checkpoint, not each art revision. Keep standalone texture quality, receiver integrity, whole-building game-art quality, as-built fidelity and release verdicts distinct. The owner-approved benchmark establishes quality ambition, not a surveyed replica or permission for unsupported motifs.

## Stop conditions

The responsible subagent stops and returns a precise blocker to root when the asset kind or exact game receiver is unknown; target or side/region identity is inadequate; a claimed periodic asset lacks a defensible motif grammar, repeat cell, or edge contract; safe placement cannot be bounded; any boundary changes a motif; the finite attempt budget is exhausted; or proceeding requires unapproved geometry, download, external service, account/upload, skill/install, new resource, license assumption, integration, export, launch, overwrite, or commit. For a complete module atlas or finite unique elevation, unknown surveyed anchors, count, cadence, or dimensions are not blockers when plausible bounds can be recorded as reversible production inference and geometry integrity does not depend on survey precision.

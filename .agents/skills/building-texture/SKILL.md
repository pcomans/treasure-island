---
name: building-texture
description: Author reference-grounded Godot building art with a mandatory existing-asset comparison before any new building, shared-family reuse, instance variants, and exterior texture validation. Use for building authoring and facade work; not terrain, road, or water assets.
---

# Building Authoring and Texture

Before authoring any new building, compare it with existing assets and reuse a suitable shared base. Build reference-grounded geometry and facade art within the assignment; apply the texture guidance only to applicable surfaces.

## Mandatory root boundary

- The primary `/root` agent is an **ORCHESTRATOR ONLY**, never an executor. It may define the bounded task contract, assign named subagents, monitor and coordinate them, review returned evidence, accept or reject results, update plans and goals, and communicate with the user.
- The primary `/root` agent must never perform research or browsing; author or edit textures, code, tests, proofs, documentation, skills, or data; generate assets; install or download resources; or run scripts, imports, integration, validation, tests, exports, builds, launches, or GUI actions.
- Delegate every research, specification, generation, normalization, proof, semantic review, art review, integration, validation, test, install, download, export, build, launch, and GUI action to a named subagent with a concrete scope and stop condition. Each executing subagent records what worked, what failed, and what should change in the shared retrospective log.
- Root may use coordination tools and the minimum read-only inspection needed solely to verify subagent output. Reuse a small number of bounded specialists; do not create agents or analysis rounds without a concrete need.
- This persistent boundary takes precedence over older workflow wording that assigns direct execution or file editing to root. It does not relax project approvals, privacy rules, external-service restrictions, receiver contracts, or geometry decision boundaries.

## Before every new building: compare and reuse

This check happens before new building implementation, including whole-building studies. Inspect the target's actual dated exterior references and the existing shared family entrypoints and relevant building assets. Compare silhouette and massing, roof form, opening organization, canopies, stairs and other structural motifs; palette similarity alone is not a close match. Confirm target association rather than borrowing a neighboring building's identity.

Start with the [housing row family and variant usage](../../../game/resources/housing_family/README.md) when its repeated-bay, shallow-gable and detached-canopy structure fits. Its shared modules support bay count, canopy start/extent and wall/door palettes without scaling openings. It is an isolated structural visual study: target footprint, grade, source identity, collision and gameplay fit still require integration and their existing verification. The earlier [1232 palette adapter](../../../game/scripts/world/facades/northpoint_1232_asset.gd) remains available for fixed 1232 geometry with color-only changes. Inspect other relevant family builders when neither fits; neither entrypoint grants production attachment or acceptance.

When the structure closely matches a suitable asset, build from its shared base geometry, components or master family. Express differences as instance parameters with semantic material roles (for example, blue walls and a red door), plus reference-supported structural variants where needed. Preserve each target's frozen footprint, orientation, local grade and source identity. Copying a complete building script into another file is not reuse.

Existing quality is a floor: do not force a poor or incorrect base onto the target. Improve the shared family when that serves its instances, respecting the assigned edit scope and checking affected instances. If no base fits, state the structural reason briefly and author a new reusable base within the assignment. A whole-family art owner may handle shared design and variants; independent source/mechanical, visual and release verification remains per building.

Record the choice in about one line of the ordinary assignment or handoff: base/family and instance differences, or why a new base is needed. This is an authoring decision, not another approval, report, JSON schema, hash/count layer or acceptance gate.

## Asset boundary and ownership

- For texture work, classify the requested texture output before making pixels:
  - `homogeneous_material_tile`: one local material field, with no facade-scale layout;
  - `architectural_pattern_tile`: a proven periodic architectural cell;
  - `module_atlas`: complete reusable motifs with explicit placement rules;
  - `unique_elevation`: a target-specific, nonperiodic elevation or mask.
- Apply repeat and seam gates only to axes and assets that claim repetition. A complete `module_atlas` motif does not need to tile, and a finite `unique_elevation` does not need a repeat cell.
- For texture-only tasks, route story count, silhouette, roofline, podiums, setbacks, deep recesses and collision to geometry rather than painting them into a texture. For an authorized whole-building study, the same art owner may change reference-supported geometry and immediate setting inside the explicit project scope; this texture skill does not impose a separate geometry approval.
- The texture guidance covers building textures broadly. Windows are only one possible motif; the same repeat rules apply to bricks, blocks, panels, ribs, joints, doors, vents, louvers, balconies, trim, bands, and stains.

## Recognizability and evidence precision

When the user or project prioritizes recognizable game art over surveyed reconstruction, distinguish exact technical ownership from real-world measurement. The generated receiver, protected regions, and geometry/physics boundaries remain exact. Once the target, observed side or region, and motif family are adequately identified, unmeasured scale, count, cadence, and anchors may be bounded, reversible `production_inference`; they must never be labeled measured or as-built. Survey precision raises confidence but is required only when safe placement or geometry integrity depends on it.

## Root-coordinated workflow

1. ROOT assigns one named author the building or family scope, identity/receiver, texture asset kind when applicable, references, editable/protected paths, privacy boundary and finite attempt budget. That author completes the existing-asset comparison above before implementing a new building. Follow the project's [bounded authoring loop](../../../AGENTS.md#authoring-and-batch-delivery). Research, specification, implementation, applicable proof and self-inspection belong to that author; do not require a separate actor or handoff for each function.
2. For whole-building or facade work with unresolved architectural evidence, use [targeted reference questions](references/research-and-repeat-blueprint.md#targeted-reference-questions) before deciding whether to acquire more imagery. Read [research-and-repeat-blueprint.md](references/research-and-repeat-blueprint.md) for applicable texture evidence/grammar and [godot-material-contract.md](references/godot-material-contract.md) for receiver integration. Separate observations from reversible inference. Declare repeat cells/seams only for periodic assets; finite motifs need bounds and placement, not artificial repeat proof. Reference access does not grant download/reuse permission.
3. If image generation is requested, follow the installed image-generation skill and privacy/account rules, using the built-in path and a small declared batch (normally 2–4 candidates, at most one targeted correction). Otherwise author the assigned procedural/code/asset changes without requiring generation. For raster assets claiming repetition, use the existing helper:

   ```bash
   node .agents/skills/building-texture/scripts/build_proofs.mjs <input-tile> <new-or-empty-output-dir>
   ```

   Its numeric/proof outputs screen candidates; they do not supply semantic or art acceptance.
4. Reach the first coherent actual-world render after focused identity/site/execution-safety preflight, before completed independent review or export. Within the approved finite loop, inspect and revise using the supported driver without per-invocation reapproval; retain serialized engine ownership, live handles, fresh outputs and failed records. Technical review addresses changed risk seams rather than replaying unrelated gates.
5. An independent visual reviewer uses [semantic-art-review.md](references/semantic-art-review.md) to judge actual references and gameplay pixels, including the complete building’s believability and recognizability against real-world references when assigned. Keep this reviewer separate from implementation and technical judging. Applicable independent source/mechanical decisions and batch release gates remain required before promotion. ROOT reviews evidence read-only; no author self-grants acceptance or credit.

Export/signing/package paperwork belongs at the batch checkpoint, not each art revision. Keep standalone texture quality, receiver integrity, whole-building game-art quality, as-built fidelity and release verdicts distinct. Sensible game-art inference may support a believable, recognizable result without claiming surveyed fidelity or inventing unsupported motifs.

## Stop conditions

The responsible subagent stops and returns a precise blocker to root when the exact game receiver is unknown, or a texture task has an unknown asset kind; target or side/region identity is inadequate; a claimed periodic asset lacks a defensible motif grammar, repeat cell, or edge contract; safe placement cannot be bounded; any boundary changes a motif; the finite attempt budget is exhausted; or proceeding requires unapproved geometry, download, external service, account/upload, skill/install, new resource, license assumption, integration, export, launch, overwrite, or commit. For a complete module atlas or finite unique elevation, unknown surveyed anchors, count, cadence, or dimensions are not blockers when plausible bounds can be recorded as reversible production inference and geometry integrity does not depend on survey precision.

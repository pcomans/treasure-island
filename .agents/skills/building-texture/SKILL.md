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
- Route story count, silhouette, roofline, podiums, setbacks, deep recesses, collision, and other true massing to geometry. Do not hide them in a texture or change them without approval.
- This skill is for building textures broadly. Windows are only one possible motif; the same repeat rules apply to bricks, blocks, panels, ribs, joints, doors, vents, louvers, balconies, trim, bands, and stains.

## Recognizability and evidence precision

When the user or project prioritizes recognizable game art over surveyed reconstruction, distinguish exact technical ownership from real-world measurement. The generated receiver, protected regions, and geometry/physics boundaries remain exact. Once the target, observed side or region, and motif family are adequately identified, unmeasured scale, count, cadence, and anchors may be bounded, reversible `production_inference`; they must never be labeled measured or as-built. Survey precision raises confidence but is required only when safe placement or geometry integrity depends on it.

## Root-coordinated workflow

1. Root establishes the object identity, requested asset kind, evidence directory, privacy boundary, attempt budget, and stopping conditions in delegation prompts. A named rules/specification subagent reads the project rules and exact target contract and returns a written handoff.
2. Before generation, a named research subagent studies target identity, material, pattern regions, cadence, and scale. That subagent reads [research-and-repeat-blueprint.md](references/research-and-repeat-blueprint.md) and produces its normalized handoff. Sources may inform a brief without authorizing image download or reuse. It separates observed facts from reversible implementation inference instead of treating every unmeasured value as a blocker.
3. A named specification subagent declares the motif grammar, legal and forbidden seams, physical scale status, map set, and exact game receiver. It declares a smallest true repeat cell and edge products only for assets or axes that claim repetition. For a module atlas or unique elevation, it may instead declare complete motif bounds, an identified receiver region, protected regions, and a reversible placement envelope.
4. A named generation subagent generates only when the user asked for generation. It reads and follows the installed image-generation skill and its privacy/account rules, then uses only the built-in image-generation path. It makes one small, predeclared batch (normally 2–4 candidates) and at most one targeted correction round. Research and review requests alone do not authorize generation.
5. A named proof subagent normalizes all candidates mechanically and consistently and runs:

   ```bash
   node scripts/build_proofs.mjs <input-tile> <new-or-empty-output-dir>
   ```

   The script records dimensions, hashes, and opposite-edge MAE/RMSE; emits native 3×3, boundary-overlay, circular-roll, and macro-repeat proofs; and deliberately leaves semantic, art, receiver, and overall acceptance unreviewed. Numeric passage is only a candidate screen, never acceptance.
6. A named semantic/art-review subagent, independent from generation, reads [semantic-art-review.md](references/semantic-art-review.md). It hard-fails any join that creates, resizes, duplicates, or deletes a motif, even when the pixels match.
7. A named Godot integration/test subagent reads [godot-material-contract.md](references/godot-material-contract.md) before importing or reviewing in Godot. It validates exact game-receiver ownership and the declared measured or inferred scale, including a close view and the ordinary gameplay camera, and grades against the target and an absolute rubric; “better than a gray placeholder” is diagnostic only.
8. Root performs read-only evidence review and accepts only when every applicable hard gate has direct evidence. It keeps standalone asset quality, exact game-receiver integrity, game-art recognizability, as-built fidelity, and geometry verdicts distinct. A clearly labeled production inference may pass game-art review without becoming an as-built claim. Any remediation is a new bounded subagent assignment, never direct root execution.

## Stop conditions

The responsible subagent stops and returns a precise blocker to root when the asset kind or exact game receiver is unknown; target or side/region identity is inadequate; a claimed periodic asset lacks a defensible motif grammar, repeat cell, or edge contract; safe placement cannot be bounded; any boundary changes a motif; the finite attempt budget is exhausted; or proceeding requires unapproved geometry, download, external service, account/upload, skill/install, new resource, license assumption, integration, export, launch, overwrite, or commit. For a complete module atlas or finite unique elevation, unknown surveyed anchors, count, cadence, or dimensions are not blockers when plausible bounds can be recorded as reversible production inference and geometry integrity does not depend on survey precision.

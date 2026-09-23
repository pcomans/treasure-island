# Reusable building art assignment

## Role boundary

- Project lead/root: remains orchestrator-only, supplies a bounded target and stop condition, coordinates named subagents, and reviews their evidence.
- Whole-building art owner: owns research, composition, reference-supported geometry/materials/immediate setting, self-inspection and applicable texture proof inside the assignment. Independent art review remains separate from implementation and source/mechanics review. Texture-only specialization is used when that is the requested task.
- No role may acquire a new resource, use an external service, install a skill/tool, upload reference material, require an account, integrate, export, launch, commit, or push unless that action is explicitly authorized.

## Required task contract

1. Exact project source and Godot receiver identity.
2. Whole-building quality study or texture-only task; for the latter, declare `homogeneous_material_tile`, `architectural_pattern_tile`, `module_atlas`, or `unique_elevation`.
3. Reference roles or an approved observation ledger, including observed side/region and protected/unobserved regions.
4. Placement goal: surveyed reconstruction or recognizable game art.
5. Evidence directory, source/asset paths, editable and protected regions/systems, owner-approved visual quality anchor, supported source-render driver, finite engine/iteration budget and stop conditions.

## Asset-kind dispatch

- A homogeneous material tile contains no facade-scale motif and is reviewed as a repeatable local field.
- An architectural pattern tile declares a true periodic cell and passes semantic seam proofs on every tileable axis.
- A module atlas contains complete reusable motifs. A complete module does not need to tile or pass whole-wall edge metrics.
- A unique elevation is finite and region-specific. It needs correct edges and receiver ownership, not a fabricated global period.

Never reject a good complete window, door, vent, band, or other module merely because it is not a seamless wall tile.

## Recognizability-first placement

When the approved project goal is recognizable ordinary-gameplay art, exact generated receiver ownership remains mandatory but survey-level real-world placement does not. Once target, side/region, and motif identity are adequate, the specialist may choose bounded scale, count, cadence, and anchors as reversible `production_inference`.

- Record the observed basis, candidate region, protected regions, confidence, adjustable scale range, and every inferred transform.
- Do not call inferred values measured, surveyed, exact real-world placement, or as-built fidelity.
- Use enough complete motifs to create a coherent facade composition; do not default to isolated sparse exemplars merely to avoid inference.
- Stop if target or side/region identity is inadequate, safe placement cannot be bounded, the result contradicts the observations, a protected region would be touched, or geometry integrity would require survey precision.

## Workflow

1. Read `AGENTS.md` and the installed `building-texture` skill. Read only the skill references relevant to the assigned role.
2. Treat Street View or other restricted imagery as observation-only unless the owner separately authorizes reuse. Do not download, copy, store, upload, embed, or redistribute Street View pixels.
3. For whole-building work, compose reference-supported roof/geometry, materials and immediate setting together; preserve exact OSM identities/footprints, protected regions and approved gameplay systems. For texture-only work, create the declared asset kind with its applicable complete-motif/seam contracts.
4. Follow the once-authorized bounded edit/render/inspect loop in AGENTS. After focused identity/site/execution-safety preflight, obtain the first coherent actual-world render before completed independent review/export. Texture-only assignments keep massing/roof/terrain/collision unchanged unless included in their approved scope; this is not a whole-building geometry prohibition. Review changed technical risk seams and retain independent source/mechanical/visual/release gates before promotion.
5. Validate at close range and in ordinary third-person gameplay. For a named building, include a whole-object view and grade recognizability separately from as-built fidelity and geometry limitations.
6. Obtain independent art review before lifecycle acceptance. Preserve provenance, decision, installation, evidence, and retrospective records required by the project.

## Delegation prompt template

```text
Role: [whole-building art owner | texture-only author | independent reviewer]
Target: [source ID, building identity, exact Godot receiver]
Task: [whole-building quality | texture-only asset kind]
Reference basis: [approved source/observation paths and observed regions]
Placement goal: [surveyed reconstruction | recognizable ordinary-gameplay art]
Protected scope: [unobserved sides, runs, geometry, systems]
Allowed mutations: [exact allowlist]
Quality anchor: [owner-approved actual image; not an as-built specification]
Render loop: [supported driver, serialized slot, finite engine/iteration budget]
Evidence and stop condition: [paths, safety/scope/budget limits, required independent review]

For recognizable game art, do not stop solely because real-world anchors, count,
cadence, or dimensions are unmeasured. Use bounded reversible production inference
inside adequately identified regions, label it honestly, and preserve exact game
receiver ownership plus all geometry/physics/privacy/resource invariants.
```

## Acceptance

- Correct asset-kind review and complete motif/seam semantics.
- Reference-observed facade language and plausible bounded inference.
- Complete actual-world composition judged against dated references and the owner-approved quality anchor when whole-building work is requested; historical credit or a repaired local defect alone is insufficient.
- Correct game receiver, containment, contact, scale, lighting response, and protected-region ownership.
- No unauthorized massing, collision, navigation, spray, terrain, roof, source, or generated-data change.
- Independent art verdict plus explicit `as-built fidelity: claimed | limited | unclaimed`.

## Retrospective

At the end of every executing round, append a concise named entry to `discovery/RETRO_LOG.md` covering what worked, what did not, and what should change next time.

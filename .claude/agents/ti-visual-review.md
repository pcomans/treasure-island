---
name: ti-visual-review
description: Independently judge actual Treasure Island native visuals against the target references and older-asset quality floor.
model: opus
effort: high
---

Read the [shared active zoom level](../../AGENTS.md#shared-active-zoom-level)
from the task note and assignment, and name it in your verdict. Judge the assigned
level; park other-level findings in the same critique without silently changing
focus. Distinguish an in-level verdict from whole-quality acceptance, retaining
all existing whole-quality HOLDs and immediate identity/safety/fit findings.

Follow the independent visual critique/bar-raiser routing and discretionary non-ultra escalation in [AGENTS.md](../../AGENTS.md#bounded-subagent-execution); select effort explicitly at dispatch.

Read project AGENTS.md, the assignment, the screenshots from `game/tests/shared/building_shots.gd` and the [canonical visual review guidance](../../.agents/skills/building-texture/references/semantic-art-review.md#absolute-art-gate). Apply its direct dated reference-pixel comparison and separate fidelity/finish findings; notes-only review cannot close whole-unit recognition. Remain separate from implementation and source/mechanical judgment. Inspect actual native originals at useful detail, ordinary gameplay views, relevant changed light and the supplied bounded motion samples. Do not wait for export before reviewing a coherent source render.

Compare the complete actual-world result against dated real-world target references: is it believable and recognizable, even without one-to-one fidelity? Evaluate the complete building’s believability, architectural depth, materials and composition at gameplay distance, excluding trees from the building's quality expectation and preserving protected scope. Judge building studies with the placed street-detail layers off; vegetation belongs to the street-detail work and uses only species evidenced on Treasure Island. Identify the highest-impact visual weaknesses; call for substantial recomposition when warranted, leaving design solutions to the artist. Specific defects may support the diagnosis without becoming universal construction recipes. Reassess the whole result after fixes; cue presence, a resolved local defect or historical recognition credit does not establish current visual quality. Extra decoration or parity with older assets is insufficient. Keep inferred dimensions and historical observations honest; report sampled motion as sampled. Do not claim walking success from pictures or current-package pixels from historical captures.

Return one scoped per-unit PASS/HOLD with concrete defects or limits. At Levels 1–2 you may review a compatible whole family in one pass, still giving each building its own verdict. In a timed edit-to-model-verdict task, provide the explicit visual verdict as the endpoint; saved screenshots alone are not a verdict. Do not change assets or request unrelated recaptures. Coordinate a concise named retrospective append.

Inspect every exterior side in actual gameplay originals, not just the detailed public facade. Compare side-specific references and check that each side reported unphotographed follows recorded Street View, Maps-photo and web searches. A side without a dated photo stays as it is ([owner, 2026-11-03](../../AGENTS.md#facade-recognizability-policy), superseding the earlier inference of such sides): flag any detail newly added to it, and do not hold a unit for its missing openings. Return whole-quality HOLD for unfinished photographed sides or unreviewed sides even if the public facade, scoped finish or historical recognition passed; state per-side evidence and limits in the ordinary critique. Protected art scope is not an exemption from this judgment; recommend bounded rescoping while preserving source/gameplay invariants.

Judge the basic form at the declared level against the assignment's description, [plan view](../../AGENTS.md#describe-build-check-show) and dated photos, and the defects below ([describe, build, check, show](../../AGENTS.md#describe-build-check-show)). Don't ask for fine detail or small objects beyond the declared level; missing form at the declared level is a form finding. Ask for a further round only for a defect you name.

Work from the small set the assignment hands you (about eight images: a matched reference photo and render for each side in question), then the in-context views and before/after island overviews in a second short pass, within the assignment's time budget. When the set cannot settle a finding, ask for that one view rather than opening the whole capture set.

Your whole-quality PASS/HOLD remains separate from the [mandatory between-study scope/progress decision](ti-study-progress-review.md), made by another named independent reviewer. Surface larger architectural gaps and actual baseline/current comparisons for that handoff; do not treat a local fix, test PASS or its progress PASS as whole visual acceptance. ROOT must consume its PASS / RESCOPE / REWORK before next-study GO or promotion.

## Defect pass

Work through this list on every study and report each defect with its view and place:

- broken or missing surfaces, and faces seen from the back;
- see-through gaps in walls, roofs and joints;
- sky showing where the building should hide it;
- floating parts that do not touch what holds them;
- parts clipping into each other;
- stray lines, dashes or artefacts under eaves, along roof edges, and at joints and steps between parts.

Cite a shared check's result instead of judging by eye only for what it detects: `building_fit_test.gd` fails walls that stop short of the ground and visible roof or walls the player could pass through; the shell check in `game/tests/headless_interior_ground_contract.gd` fails see-through gaps into a building with an interior; the passage walk fails stuck doorways. No shared check detects faces seen from the back, clipping, floating parts above the ground or stray lines; judge those by eye. A defect found here is a named defect for a further round.

# Project learnings

Keep this a short, living guide to mistakes worth preventing. Update an applicable lesson when new evidence changes it; preserve uncertainty and useful gains. Routine execution history belongs in `discovery/RETRO_LOG.md`.

## Judge the whole visible result after a fix

**Observed:** In 1308 fidelity002, ordinary views 06/07 improved roof visibility and lawn coverage, yet the main roof still showed rounded, uneven humps and a heavy pale rim. Junction views 03/04 exposed near-black canopy tops and heavy edges. The dated March 2025 reference showed coherent planar roof surfaces, straight ridge/eave segments and readable gray roofing. The initial review closed the previous two gaps too narrowly; the owner caught the unresolved overall form. A focused sibling check of 1303 fidelity004 views 03/06 found a related uneven crest despite real roof-visibility and apron gains.

**Cause and prevention:** The review treated improvement on the last defect checklist as sufficient quality. That is a review failure; pixels alone do not establish the underlying mesh algorithm's cause. After every visual fix, compare the full visible silhouette, roof planes/ridge/eaves, proportions, material readability and junctions with the actual dated reference in ordinary gameplay. Look for new and remaining defects beyond the previous issue. Visibility measurements diagnose readability; they must not drive exaggerated height, bulk or architecture merely to increase screen coverage.

**Next render:** Use the existing ordinary view and a useful existing near view beside the reference. Check that planes read as planes, ridge/eave transitions are intentional, and roof surfaces and edging remain legible. State what improved and what still fails, respecting different cameras, target identity and unknown/protected faces. Preserve successful lower openings, pale gables, paving and lawn. Scoped finish, source, mechanics or package PASS does not close overall fidelity; do not replace this judgment with an analytic projection, larger pose matrix or new test suite.

## Inspect the early coherent render before extended proof work

Bring the first coherent actual source render to the separate visual reviewer before extended refinement, proof collation or release packaging. Resolve visible form and composition problems while the change is small. Keep required independent gates and batch delivery checks; reuse unchanged evidence with its original scope.

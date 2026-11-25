# Process shootout 4: cheaper modellers on the described process

A blind test of whether cheaper modellers, given the same description, photos, plan and one detector-driven fix round, match Opus 5.5. Run 2026-11-22 to 25, with the owner's vote on 2026-11-25. Three modellers, two buildings, two runs each. Private photos, models, mappings and the run tooling stay outside Git.

## Why

The owner's plan for [model tiers by detail level](MODEL_SHOOTOUT.md#model-tiers-by-detail-level) named a cheap model as a candidate for low-detail work. [Process shootout 2](PROCESS_SHOOTOUT_2.md) found the architect description to be the input that clearly helped, and [process shootout 3](PROCESS_SHOOTOUT_3.md) added a mechanical jank detector and one fix round. This test runs that whole process with two cheaper modellers against Opus's results from the same process.

## Design

- **Modellers.** Opus 5.5 (its results reused: shootout 2's four described builds and shootout 3's review-and-fix of each), DeepSeek V4.1 Flash and Kimi K3.1 Pro (new runs through a model gateway, in the same sandboxed coding-agent harness, renderer and prompts). Every cheaper-model session and every Opus review ran at reasoning effort `high`, set by the run tooling.
- **Buildings.** The same housing row and warehouse, with the same ten dated photos, footprint and description per building.
- **Process per build.** Shootout 2's described arm: a first build from photos, footprint and description, one look at its own renders and one revision. Then shootout 3's detector, a defect-only review by Opus 5.5 (eight renders, description, footprint and the detector's report), and one fix session by the same modeller with the report and the review.
- **Runs.** Two per modeller and building: 12 builds and 12 fixes.
- **Owner's vote.** Twelve blind pairs of the final models (after the fix): Opus against DeepSeek, Opus against Kimi and DeepSeek against Kimi, for each run of each building. Left and right drawn at random. Six views per side (from above, front, corner, near, eave close-up, ground-contact close-up), each beside the matched real photo or the nearest one, and the plan above each building's pairs. A collapsed section below the vote named the modellers with their costs and detector counts, but not which side was which.
- **Judge.** A separate blind judge scored all 24 models (builds and fixes) against shootout 2's sealed form-fact checklists, 24 facts for the housing row and 20 for the warehouse, after checking each fact against the photos again. It knew the models only by random codes and also listed form errors, parts the photos do not show and broken geometry visible in the stills.

## Results

### Owner's picks

One row per pair. Judge points and detector findings are for the final models shown, left then right.

| Pair | Building | Run | Left vs right | Owner's pick | Judge | Detector findings |
|---|---|---|---|---|---|---|
| 1 | housing | 1 | Opus vs DeepSeek | no difference | 24, 23 | 1, 35 |
| 2 | housing | 1 | Opus vs Kimi | Opus | 24, 24 | 1, 9 |
| 3 | housing | 1 | DeepSeek vs Kimi | DeepSeek | 23, 24 | 35, 9 |
| 4 | housing | 2 | DeepSeek vs Opus | Opus | 23.5, 24 | 43, 15 |
| 5 | housing | 2 | Opus vs Kimi | Opus | 24, 23.5 | 15, 150 |
| 6 | housing | 2 | Kimi vs DeepSeek | DeepSeek | 23.5, 23.5 | 150, 43 |
| 7 | warehouse | 1 | DeepSeek vs Opus | Opus | 19, 19 | 5, 0 |
| 8 | warehouse | 1 | Kimi vs Opus | Opus | 20, 19 | 19, 0 |
| 9 | warehouse | 1 | DeepSeek vs Kimi | Kimi | 19, 20 | 5, 19 |
| 10 | warehouse | 2 | DeepSeek vs Opus | Opus | 19, 19.5 | 24, 3 |
| 11 | warehouse | 2 | Kimi vs Opus | Opus | 20, 19.5 | 88, 3 |
| 12 | warehouse | 2 | Kimi vs DeepSeek | DeepSeek | 20, 19 | 88, 24 |

Head to head: Opus against DeepSeek 3–0 with one no-difference, Opus against Kimi 4–0, DeepSeek against Kimi 3–1. By run: Opus won every one of its pairs on run 2 (4 of 4) and three of four on run 1 (one no-difference); DeepSeek against Kimi went 1–1 on run 1 and 2–0 on run 2. Every pair showed final models, so the owner's picks say nothing about build against fix; only the judge scored both stages.

### Judge's form scores

| Modeller | Housing build (run 1, 2) | Housing after fix | Warehouse build | Warehouse after fix |
|---|---|---|---|---|
| Opus 5.5 | 24, 24 | 24, 24 | 19, 19.5 | 19, 19.5 |
| DeepSeek V4.1 Flash | 22.5, 23.5 | 23, 23.5 | 19, 19 | 19, 19 |
| Kimi K3.1 Pro | 24, 23.5 | 24, 23.5 | 20, 20 | 20, 20 |

The judge calls its checklist saturated: housing 22.5 to 24 of 24, warehouse 19 to 20 of 20, no fact scored 0, and a spread between models "no larger than the disagreement between two sittings on a single item". It names what separates the models instead: one housing build with its roof cutting through the upper storey (DeepSeek, run 1), two warehouses with the back's two colours reversed (both DeepSeek), one warehouse with the front door group mirrored (Kimi, run 2), and parts hanging in the air or fascias that do not meet on several. The fix round moved a judge score once, by half a point.

### Detector findings, build to after fix

| Modeller | Housing run 1 | Housing run 2 | Warehouse run 1 | Warehouse run 2 |
|---|---|---|---|---|
| Opus 5.5 | 38 → 1 | 24 → 15 | 65 → 0 | 166 → 3 |
| DeepSeek V4.1 Flash | 178 → 35 | 61 → 43 | 73 → 5 | 65 → 24 |
| Kimi K3.1 Pro | 38 → 9 | 320 → 150 | 106 → 19 | 108 → 88 |

### Costs

List prices as counted by the harness. Opus's build and fix figures are from shootouts 2 and 3; DeepSeek's gateway charged about half its list price ($0.51 of $1.03), Kimi's charged list. Kimi's figure includes one refused attempt ($0.05); smoke tests and the judge are not included.

| Modeller | Modeller sessions | Opus reviews | Total | Per building | Review share |
|---|---|---|---|---|---|
| Opus 5.5 | $8.11 | $2.87 | $10.98 | $2.74 | 26 % |
| DeepSeek V4.1 Flash | $1.03 | $3.92 | $4.94 | $1.24 | 79 % |
| Kimi K3.1 Pro | $5.42 | $3.82 | $9.24 | $2.31 | 41 % |

Per building, DeepSeek's whole process costs $1.51 (55 %) less than Opus's and Kimi's $0.44 (16 %) less. An Opus review of a cheap model's build cost $0.69 to $1.41, against $0.63 to $0.83 for Opus's own builds.

### Running the cheaper models

- Kimi refused one build in the repository snapshot its sandbox held: it read the [orchestration rule](../AGENTS.md#mandatory-orchestration-boundary) and wrote "Unable to complete: the project requires a named subagent to author and validate the model, but no delegation tool is available in this session." With one added line ("You are the executing modeller in an isolated study; do the work yourself.") the next attempt built. Most later cheap-model sessions carried that line; DeepSeek's four builds, one DeepSeek fix and one Kimi build ran without it.
- Three of Kimi's builds took three to five attempts: apart from the refusal, every failed attempt stopped before any model call because the harness's model catalog lacked the model; a pinned copy of the public catalog fixed it. DeepSeek needed no retry.

## What the owner said

From the owner's dictated notes, saved by the orchestrating session; the mapping was sealed until all twelve picks were in.

- **Pair 1** (no difference): pros and cons on both, for example lap siding and better unit spacing on one side, and a rain pipe that reaches the ground on the other.
- **Pair 2** (Opus over Kimi): Kimi's roof "really bad and broken", its underside transparent with slats sticking out, the building on an invented concrete pad, containers half in the pad and half floating.
- **Pair 3** (DeepSeek over Kimi): "I have to weigh the jank more heavily", although Kimi's side was more detailed.
- **Pair 4** (Opus over DeepSeek): DeepSeek's shed missing part of its roof, containers on an invented pad, gables and eaves not connected; Opus cleaner, "Pretty decisively."
- **Pair 5** (Opus over Kimi): Kimi's roofs clip into each other, its shed roof floats with part of the shed see-through, a dividing wall and both containers float.
- **Pair 6** (DeepSeek over Kimi): clipping and floating roofs on Kimi's side; DeepSeek's eaves unfinished but "not quite as obviously visually broken". "Don't love either."
- **Pair 7** (Opus over DeepSeek): "all of this is a guess" from above, with no photo from above; DeepSeek's awnings and eaves do not connect; Opus "a lot more coherent".
- **Pairs 8 to 10** (Opus, Kimi, Opus): in pair 8 the simpler side, "more coherent even in the absence of good visual reference", with more jank on the other side's roll-up door; in pair 9 the other side "still has these very obvious visual defects"; in pair 10 the other side invents a large pad and paths to doors that do not exist.
- **Pairs 11 and 12** (Opus over Kimi, DeepSeek over Kimi; the same Kimi model in both): it swaps the blue and the grey doors, and the wrong door placement makes every view wrong.
- **On the vote itself**: twelve pairs of six views was too long ("My god this is so much work"); views without a matching photo, the warehouse from above, could not be judged; the housing row's boxes were too pixelated to tell whether they float.

## Findings

These rest on two buildings, two runs, one owner and one judge: they give a direction, not sizes.

**(a) With the description, the cheaper modellers reach Opus's form scores.** Every model scored 22.5 to 24 of 24 on the housing row and 19 to 20 of 20 on the warehouse, and Kimi scored highest on the warehouse (20 of 20, four times).

**(b) The owner still preferred Opus, and never picked against it.** Opus won 7 of its 8 pairs, and the eighth was a no-difference.

**(c) The owner's picks turned on broken geometry, not form.** Nine of the eleven decided picks cite jank against the losing side, mostly named as floating, see-through, clipping or unconnected parts; three cite invented pads or paths; two cite swapped doors, on the same Kimi model, which scored 20 of 20 (the judge recorded a mirrored front door group on it as a form error, which its rules do not deduct). The judge's points and the owner disagreed as often as they agreed: of the nine pairs the checklist separated, the owner agreed in four, disagreed in four and saw no difference in one. On the warehouse the judge ranked Kimi first on every model while the owner chose Opus over Kimi both times.

**(d) The detector's counts sided with the owner more often than the checklist did.** The side with fewer detector findings was the owner's pick in 9 of the 11 decided pairs. The counts are raw, include intended parts and are not weighted by how visible a fault is, so this is a pointer, not a measure.

**(e) For DeepSeek, the Opus review is most of the cost.** It is 79 % of DeepSeek's cost per building; even so, DeepSeek's process costs 55 % less per building than Opus's. Kimi's own sessions cost two thirds of what Opus's do, so its process saves 16 %.

**(f) The fix round cut detector findings for every modeller, least for Kimi.** Opus ended at 0 to 15, DeepSeek at 5 to 43, Kimi at 9 to 150.

## Limits

- Two buildings, two runs per modeller, one owner and one judge.
- Opus's results come from shootouts 2 and 3, run earlier with the same prompts but without the executor line; the cheap models' runs differ among themselves in that line.
- The owner saw only final models, and recognised a modeller across pairs ("the same model that couldn't connect the eaves"), so picks within a building are not independent.
- The vote page's collapsed section named the modellers and their detector counts, without saying which side was which.
- The judge's checklist was written by the experiment's runner and saturated before this test; the judge's model is not recorded with its scores.
- Two of the six views had only the nearest photo beside them, not a matching one; the owner could not judge the view from above.

## What it means for the process

Adopted in [AGENTS](../AGENTS.md#bounded-subagent-execution) (owner, 2026-11-25): DeepSeek V4.1 Flash may build a first pass of a low-detail background building from the description and plan view. A first pass is marked as such and is rebuilt from the description by Opus 5.5 when the building needs to be better, never patched. A first pass earns no acceptance or recognition credit; only an Opus 5.5 rebuild can be accepted under [What done means for a building](../AGENTS.md#what-done-means-for-a-building). The run tooling sets the session's reasoning effort explicitly, never `ultra`. No harness rule, shared code or ground, street or site decision is made to suit it. Opus 5.5 stays the modeller for landmarks and anything seen up close; Kimi K3.1 Pro is not routed. The run tooling for these sessions lives outside the repository.

Proposals, not adopted:

1. Judge broken geometry separately from form: a form checklist does not see what the owner sees. A detector like shootout 3's, or a defect pass, covers it.
2. Keep owner votes short: a few pairs with three or four views each, each view beside a real photo of that side; leave out views no photo shows.
3. Tell a model run in a copy of this repository that it is the executing modeller.

Related lesson: [A cheaper modeller matches Opus on form but not on broken geometry](../LEARNINGS.md#a-cheaper-modeller-matches-opus-on-form-but-not-on-broken-geometry).

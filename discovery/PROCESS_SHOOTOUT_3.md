# Process shootout 3: a mechanical jank detector and one fix round

A test of a script that finds broken geometry in a model, and of one fix round driven by its report, run 2026-11-22 on the described builds of [process shootout 2](PROCESS_SHOOTOUT_2.md). One modeller, two buildings. **The owner has not voted on this test's blind pairs**, so every result below is the script's own count, not a judgement of how the models look. Private photos, models, mappings and the run tooling stay outside Git.

## Why

In shootout 2 the owner found the best builds "sort of maxed out on architectural correctness" and asked for "like a jank detector agent", for surfaces that are broken, seeing through the building, sky showing where it should not, floating objects and objects clipping into each other. No review format in that test removed those faults.

## Design

- **Start models.** Shootout 2's four described first builds (FD arm, Opus 5.5): a housing row and a warehouse, two runs each.
- **Detector.** A Godot script loads a model exactly as the study renderer does, splits every mesh into connected parts and reports, with place, colour and size, six kinds of finding: floating parts (not connected to the ground through touching parts), solid parts hovering just above the ground, see-through surfaces (outside rays that first hit a back face or an inside face), parts clipping through each other, coplanar overlapping faces (flicker), and thin pieces with an end in mid-air. It makes no model call and took 2 to 9 seconds per model. It needs a rendering display, not a headless one: headless Godot keeps no MultiMesh instance transforms, so an early headless version read every such instance at the origin.
- **Defect review.** A fresh Opus 5.5 session lists defects only (the kinds above, plus misattached parts) from eight renders, six standard views and two new close views of an eave corner and of where the building meets the ground, with the description, the footprint and the detector's report. It may name report items it thinks are false alarms. Detail, colour, form and likeness are out of scope.
- **Fix arms**, each one Opus 5.5 session told to fix exactly the listed defects, change nothing else and add nothing:
  - **JM**: given the detector's report alone;
  - **JR**: given the report and the defect review.
- **Runs.** JM on run 1's start of each building, JR on both runs' starts: six fixes, four reviews.
- **Recount.** Every start and fix was re-run through the final detector version after the runs, so all counts below come from one version. The fixers saw the report of the version current at the time; for the warehouse's run 1 that listed 72 findings, against 65 on the recount.
- **Owner's page.** Eight blind pairs (start against JM, start against JR and JM against JR on run 1, start against JR on run 2, for each building), six views each with the matched real photo beside every view. Not voted.

## Results

Detector findings, all kinds together, on the final version:

| Building | Run | Start | After JM | After JR |
|---|---|---|---|---|
| housing | 1 | 38 | 1 | 1 |
| housing | 2 | 24 | not run | 15 |
| warehouse | 1 | 65 | 0 | 0 |
| warehouse | 2 | 166 | not run | 3 |

By kind, the starts' findings were mostly coplanar overlaps and clipping (the warehouse's run 2 had 126 overlaps); none had a see-through surface.

What the fixes changed, from a part-by-part comparison of each model before and after:

| Fix | Parts | Changed at a listed defect | Changed elsewhere | Added / removed |
|---|---|---|---|---|
| housing JM, run 1 | 382 | 38 | 10 | 0 / 0 |
| housing JR, run 1 | 382 | 42 | 8 | 0 / 0 |
| housing JR, run 2 | 371 | 9 | 0 | 0 / 0 |
| warehouse JM, run 1 | 1045 | 51 | 26 | 2 / 2 |
| warehouse JR, run 1 | 1045 | 52 | 25 | 4 / 2 |
| warehouse JR, run 2 | 1026 | 315 | 7 | 3 / 2 |

Of the housing row's run-2 result, 12 of the 15 remaining findings are vent pipes counted as clipping through the roof slab. The reviewer named them false alarms ("a vent pipe is meant to pass through the roof"), and the fixer agreed and left them. The same review listed the short white piece ending in mid-air that the shootout 2 judge had named on that build; the fixer could not find a part matching it and changed nothing there.

**Costs.** The ten review and fix sessions cost $8.60, as counted by the harness at list prices on the owner's API credit: reviews $0.63 to $0.83 each ($2.87 together), fixes $0.31 to $1.21 each ($5.73). Every session finished within its caps. The detector costs nothing per run beyond engine time.

## Findings

These rest on two buildings, few runs and no owner vote; see the limits below.

**(a) One fix round driven by the detector's report removes most of what the detector finds.** On three of the four starts the round took the count to 3 or fewer (38 to 1, 65 to 0, 166 to 3), and on the fourth (24 to 15) most of what remained were intended parts the reviewer called false alarms. Whether the owner sees a cleaner building is not measured.

**(b) Adding the defect review changed little on run 1.** JM and JR reached the same counts on both buildings (1 and 1, 0 and 0) and moved about the same parts. The review's value here was naming false alarms, which keeps a fixer from "fixing" intended parts.

**(c) The fixes stayed near the listed defects.** Each changed 0 to 26 parts away from a listed defect. The housing fixes added no part; the warehouse fixes added two to four and removed two each.

**(d) The detector counts intended overlaps.** Vent pipes through a roof and similar seated parts are counted as clipping, so a count is a list to check, not a defect total.

## Limits

- Two buildings, one modeller, one or two runs per arm.
- The owner has not voted, and no judge scored these fixes for looks. The JR results were later scored by the blind form judge of [process shootout 4](PROCESS_SHOOTOUT_4.md), at the same points as their starts.
- The counts come from the detector itself, so a fall in the count shows the fixer addressed the report, not that the building looks better.
- The detector was written and tuned on shootout 2's models, these starts among them; its findings on other buildings are untested.

## What it suggests for the process

Proposals, not adopted:

1. Run a detector like this on every first build, before any review.
2. Give the fixer its report with a defect-only review that may strike false alarms, and the rule to fix only what is listed.
3. Show the owner before and after, with the matched photos, before relying on the counts.

The detector and its runner live outside the repository today; the [defect pass](../.claude/agents/ti-visual-review.md#defect-pass) still says which defects a shared check covers and which are judged by eye. The same process with cheaper modellers is [process shootout 4](PROCESS_SHOOTOUT_4.md).

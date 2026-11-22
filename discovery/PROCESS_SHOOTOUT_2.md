# Process shootout 2: description, photos and review rounds

A blind test of proposed process rules, run 2026-11-21 to 22, with the owner's vote on 2026-11-22. One modeller, two buildings. Private photos, models and mappings stay outside Git.

## Why

Several process rules had been proposed from single runs (one review round by default, a form-first review, corrections as measured targets, describing a building before modelling it). The owner on those rules: "we would need to know if any of these really … make a difference. Right now it's just a hypothesis, right?", and asked to "come up with a completely new shootout that can help us test our hypotheses". It also answers the open question in the [architect-description shootout](ARCHITECT_DESCRIPTION_SHOOTOUT.md): whether a description improves a first modelling round.

## Design

- **Modeller.** Opus 5.5 only, for every build, review and fix, each step a fresh session in the same sandbox and renderer.
- **Buildings.** A housing row and a warehouse on the island, each with ten dated street-level photos from 2025 (three of them close-ups) and the plan footprint from the game's map data.
- **Build arms**, each a build, one look at its own renders and one revision, every one given the footprint:
  - **P2**: built from two of the photos;
  - **F**: built from the full photo set;
  - **FD**: the full photos plus an architect-style description, written from the photos by a Fable 5.2 session that was given a one-sentence footprint (plan shape and size).
- **Review arms**, each one review and one fix of FD's first build:
  - **R4**: the four-question review;
  - **RF**: form-first (describe the form before colours and sizes);
  - **RM**: form-first with corrections given as measured targets;
  - **RF2** (housing only): a second form-first round on top of RF's fix.

  Every reviewer and fixer also got the description.
- **Runs.** Build arms ran twice per building, review arms once.
- **Owner's vote.** Blind pairs, left and right shuffled, four views each (raised, front, one corner, near). After the owner said "I can't give feedback on the shootout because you're not giving me photos of the real building", the page was rebuilt with the real building's photos above each building's pairs and the matching photo beside every view.
- **Judge.** A separate blind session scored every model against a form-fact checklist written and sealed before any run. Before scoring any model it checked each fact against the photos and could split, reword or strike it, which left 24 scored facts for the housing row and 20 for the warehouse. It knew the models only by random codes.

## Results

One row per pair. The judge's points are for the two sides shown, one figure per run (run 1, run 2 where the pair showed two). Housing is out of 24, the warehouse out of 20.

| Pair | Building | Left vs right | Owner's pick | Judge, left | Judge, right |
|---|---|---|---|---|---|
| 1 | housing | F vs P2 | right (P2) | 19.5, 20.5 | 19.5, 19.5 |
| 2 | housing | F vs FD | right (FD) | 19.5, 20.5 | 24, 23 |
| 3 | housing | FD vs RF | right (RF) | 24 | 24 |
| 4 | housing | RF vs R4 | no difference | 24 | 24 |
| 5 | housing | RF vs RM | no difference | 24 | 24 |
| 6 | housing | RF vs RF2 | no difference | 24 | 24 |
| 7 | warehouse | F vs P2 | right (P2) | 18.5, 19 | 14.5, 13 |
| 8 | warehouse | F vs FD | right (FD) | 18.5, 19 | 19, 19.5 |
| 9 | warehouse | RF vs FD | right (FD) | 20 | 19 |
| 10 | warehouse | R4 vs RF | right (RF) | 20 | 20 |
| 11 | warehouse | RM vs RF | no difference | 20 | 20 |
| 12 | warehouse | RF vs RF2 | not shown: RF2 was not run within the budget | | |

The review arms' fixes all start from FD's run 1 (housing 24, warehouse 19), except RF2, which starts from RF's fix.

## What the owner said

From the owner's dictated notes.

- **Pair 1** (housing, P2 on the right): "I would say left is like eighty percent the quality of right".
- **Pair 2** (housing, FD on the right): the right side "is the only option that shows the second floor overhanging the first floor", and "already like a big step up", with "some jank … under the eaves, there's like some weird floating line".
- **Pair 3** (housing, RF on the right): "It's almost as if right is just an iteration on left". The only difference was blinds drawn in the windows, "cute, but I think at this level completely unnecessary", because blinds would be generated per window, not authored per building.
- **Pairs 4 to 6** (housing, review formats and a second round): no difference. "it seems like we're sort of maxed out on architectural correctness. And now we're sort of looking for jank". "Maybe we just need like a jank detector agent", for surfaces that are broken, seeing through the building, sky showing where it should not, floating objects and objects clipping into each other.
- **The warehouse**: "from the photos you're giving me, I cannot tell the shape of the building", and "it would be good to know like what the entire blueprint of the building looks like".
- **Pair 7** (warehouse, P2 on the right): the right side is "a lot more true", but "they're both honestly kind of bad".
- **Pair 8** (warehouse, FD on the right): the right side "just looks like a real building".

## Findings

These rest on two buildings and few runs; see the limits below.

**(a) The description was the one input that clearly helped.** The owner picked the described build on both buildings (pairs 2 and 8). On the housing row the judge agrees strongly: the two described builds scored 24 and 23 of 24, the full-photo builds 19.5 and 20.5, and the two-photo builds 19.5 and 19.5. Every build without the description made the same form errors: three narrow units per part instead of two (nine front doors instead of six) and a +X end the colour of the long walls instead of lighter. The owner named the described build as the only one showing the upper floor overhanging the ground floor, which every version in the earlier [review-format test](MODEL_SHOOTOUT.md#review-format-test-opus-only) had missed until a form-first review asked for it. On the warehouse the judge's checklist barely separates them (described 19 and 19.5 of 20, full-photo 18.5 and 19), but the judge counted no form errors in either described build against two in each full-photo build (both had the low roof's fascia crossing the taller block; their other error differed).

**(b) After the description, a review-and-fix round changed little.** The owner saw near-identical results and split one each way: RF over FD on the housing row (pair 3, for drawn-in blinds), FD over RF on the warehouse (pair 9). The judge's scores moved by at most one point (housing 24 to 24 for every fix; warehouse 19 to 20 for every fix). Review format (pairs 4, 5, 10, 11), measured targets (pairs 5, 11) and a second form-first round (pair 6) made no difference the owner could see; the one format pick (pair 10, RF over R4) came with equal judge scores. The fixes changed mostly colours and small parts. They also added parts the reviews asked for: R4 and RM added rows of roof vents on the housing row, RF and RM a brown band under the warehouse's fascia.

**(c) More photos alone did not help in the owner's eyes.** The owner preferred the two-photo build on both buildings (pairs 1 and 7). The judge disagrees on the warehouse: it scored the full-photo builds 18.5 and 19 against 14.5 and 13 for the two-photo builds, which lacked the taller block, the canopied end door and the rafter eave. On the housing row the judge scored them about equal (19.5 and 20.5 against 19.5 and 19.5). Owner and judge disagree here, and the owner said the warehouse photos did not let them tell the building's shape, so the owner's warehouse picks were made without a clear picture of the real building.

**(d) The number of images a reviewer got mattered more than the format.** Reviewers given about 20 images (ten photos and nine or ten renders) did not finish in 5 of 5 attempts: each spent its whole allowance re-reading images and measuring (57 to 106 tool calls) and wrote no review, three stopped by the 20-minute cap and two by a spend cap. They cost $25.19, 57 % of all spend. A time line in the prompt and a $3 cap did not make the last of them finish. Reviewers given eight images (four photos, four renders) finished 7 of 7 times, for $0.47 to $0.82 each in 2.7 to 4.9 minutes, and all seven fixes that followed finished too. The same three formats failed with 20 images and finished with eight.

**(e) What remained wrong in the best builds was jank, and no arm addressed it.** The judge's notes on the described and reviewed builds list dark ticks along the housing row's end wall at eave height, storage boxes overlapping glazing, a trim piece ending in mid-air, roof-edge wires breaking into floating dashes and a doubled roof-edge band on the warehouse. The judge notes that dashed lines may be render aliasing rather than mesh faults; of these, the trim ending in mid-air is clearly geometry. The owner named the same class: a floating line under the eaves, floating and clipping objects. No review format asked for these, and no fix removed them.

**Costs.** The 50 modelling, review and fix sessions cost $44.34, as counted by the harness at list prices on the owner's API credit; sessions cut off at a cap may be billed beyond what was counted. The description and judge sessions are not in that figure. Typical cost per arm, from the run's cost log:

| Arm | Housing row | Warehouse |
|---|---|---|
| P2 build (per run) | $0.34, $0.39 | $0.51, $0.48 |
| F build (per run) | $1.28, $0.69 | $0.87, $0.87 |
| FD build (per run) | $0.98, $0.83 | $1.37, $1.15 |
| R4 review and fix, eight images | $1.56 | $1.60 |
| RF review and fix, eight images | $1.11 | $1.23 |
| RM review and fix, eight images | $1.40 | $1.34 |
| RF2 review and fix, eight images | $1.12 | not run |
| Failed reviews, about 20 images | $5.01 (R4), $5.40 (RF) | $6.09 (R4), $5.55 (RF), $3.14 (RM) |

## Limits

- Two buildings and one modeller.
- Build arms ran twice, review arms once; one description per building.
- The checklist was written by the experiment's runner, from the same photos. The judge could strike or reword facts before scoring and reworded four and split two, but struck none.
- The judge was a session of the describer's model.
- The checklists separate few models: 17 of 24 housing facts scored the same for every model, and 11 of 20 warehouse facts. The judge calls a half-point between near-identical builds noise.
- The owner's picks were made from four views per side, and for the warehouse from photos that did not show its shape.
- The eight-image reviews also had the time line in their prompt, so image count and the time line changed together for the runs that finished; the one 20-image review with the time line still failed.

## What it suggests for the process

Proposals, not adopted:

1. Describe first, with the footprint supplied to the describer.
2. Build from the photos, the footprint and the description.
3. Check for jank mechanically, or with a dedicated defect pass that looks only for broken surfaces, see-through gaps, sky where it should not show, floating parts and clipping.
4. Show the owner.
5. Skip look-review rounds unless a defect is named (by the owner, a mechanical check or a defect pass).
6. Give any reviewer few, well-chosen images, with a hard time and spend cap.
7. Show the owner the real photos and the footprint beside every result.

Related lessons: [A further review round on a decent first build buys little](../LEARNINGS.md#a-further-review-round-on-a-decent-first-build-buys-little), [A review round adds objects](../LEARNINGS.md#a-review-round-adds-objects-removing-is-a-valid-fix), [Give a describer or modeller the footprint](../LEARNINGS.md#give-a-describer-or-modeller-the-footprint-dont-let-it-guess-depth-from-photos) and [Give a reviewer few images, not twenty](../LEARNINGS.md#give-a-reviewer-few-images-not-twenty).

# Architect-description shootout

Can a model describe a building from its photos the way an architect would, well enough to brief the first modelling round? This document holds the experiment: its purpose, the private eval set, the method and each round's results. It is a test, not routing; [AGENTS](../AGENTS.md#bounded-subagent-execution) says how modelling runs. The modelling shootouts themselves are in [MODEL_SHOOTOUT](MODEL_SHOOTOUT.md).

## Purpose

The owner's idea: "before we even send a building for modeling, we need an agent to describe that building like an architect would … find a building online that has good photo resources and a good architect-written description … test if Opus or Fable can describe the building from the images clearly enough and correctly in architect's terms. And then … pass [it] in to the agent that generates iteration 1."

Their requirement: "whoever judges the output of the 1st modeling round has to have access to the architectural … description as well".

The larger modelling shootout waited for this test until the owner lifted the hold on 2026-11-21. The owner: "Can we wait until we know that the architect descriptions are good".

## The eval set

The eval set is private: it is kept outside this repository and backed up privately. Nothing from it (photos, answer keys, building names, sources) goes into Git.

- **What a case is.** A building with dated exterior photos and a professionally written exterior description from the same documentation campaign.
- **Answer keys.** Each description is reduced to a checklist of single checkable facts. Each fact is tied to its source sentence, marked visible, partly visible or not visible in the photos, and given a category. Where the sources disagree, the fact is recorded as a source conflict rather than resolved.
- **Cases.** Six have photos: four out of domain (a modest residential type, an operations building with a tower, an industrial warehouse, a plain storehouse) and two in domain, this island's Buildings 2 and 3. Two more have answer keys but no photos yet.
- **Correlations.** The six are not independent: Buildings 2 and 3 are sister buildings, and the warehouse and storehouse come from one site and one survey. That makes about four independent buildings.

The owner wants it kept as a permanent eval set for the describer: "this is going to be the basis of an eval data set that we might not be able to publish, but we should absolutely use it to assess and maintain the quality of our … architecture descriptor agent".

## Method

- **Blind inputs.** Each case gets a neutral code (fresh codes and a fresh view order each round). Labels and margins are cropped from the photos and metadata is stripped. A describer sees only the photos and a one-line context file.
- **One shared brief.** Every describer gets the same brief. It asks for a survey-style exterior description that a modeller who has not seen the building could build a first version from, in a fixed order: overall form, roof, materials, each elevation, entrances and attached elements, ornament, alterations. Its rules:
  - describe only what the photos show; do not identify the building, and say in one line at the end if it is recognised;
  - separate what is seen from what is inferred, with a confidence where it is not obvious;
  - write "not shown" rather than guess;
  - say at the top if the photos are insufficient or contradict each other;
  - give metres only when something of known size supports them;
  - end with 12–20 one-line "key form facts".
- **Describers.** Opus 5.5 and Fable 5.2, each as fresh sessions. No session that saw earlier inputs or outputs is reused.
- **Judges.** Judges score each description against the answer key without knowing which describer wrote it. The mapping from describer label to model stays sealed until scoring is done.
- **Scores.** Per fact: correct, partly, incorrect, not mentioned, or an honest "not shown".

**Numbering differs between rounds.** In round 1, model-1 was Opus 5.5 and model-2 was Fable 5.2. In round 2 it is the other way: describer-1 is Fable 5.2 and describer-2 is Opus 5.5. The tables below use the model names.

## Round 1 (2026-11-21)

Six cases, photos only, draft answer keys. One blind judge, an Opus session that did not know which describer was which, first decided per fact whether it can be determined from the photos, then scored.

Result over 103 determinable facts (correct / partly / incorrect / not mentioned / honest "not shown"):

| Describer | All six cases | Out of domain only (70 facts) | Other claims contradicted |
|---|---|---|---|
| Opus 5.5 | 63 / 25 / 5 / 9 / 1 | 44 / 16 / 3 / 6 / 1 | 7 substantive |
| Fable 5.2 | 72 / 23 / 0 / 6 / 2 | 48 / 16 / 0 / 4 / 2 | 4 substantive, 5 low-weight |

Both followed the brief in every case and named no building. Fable said it recognised both in-domain buildings, Opus one of them, with a vague sense about the other; the judge found no statement that could only have come from memory or signage.

- **Errors.** Opus's worst: it read one vaulted hall as two buildings (a flat-roofed hall plus a separate vault hall); gave a plan 4–5 times longer than deep where the key gives about 2:1; placed tower windows as a central stack instead of wrapping the corners; and miscounted doors. Fable's errors were all sizes and ratios (a plan called "close to square" where the key gives about 1.5:1; a depth about 25–40 % short of the key's), never the form itself.
- **Shared patterns.** Plan depth and length-to-depth ratios are the weakest area for both. Roof features are under-described: both missed three saw-tooth roof monitors visible in one view. Altered openings were seen but not called alterations, and neither committed to how windows open. Reliable for both: storey counts, roof types, bay systems and entrance compositions.
- **Confidence: low to moderate.** Six cases, two pairs of them correlated (sister buildings; one shared site); monochrome photos of about 900 px; draft checklists from scanned text, in which the judge listed several facts as wrong, self-contradictory or not checkable; one judge. The gap between the describers comes from about four misreadings in two cases; on two cases and most of a third they were indistinguishable.
- **Next steps then.** Fix the answer-key problems the judge listed; add the two cases whose photos could not be fetched yet; in the next shootout, give the description to the first modelling round and to its reviewer, as one blind pair: built from photos alone against photos plus description.

## Round 2 (2026-11-21 to 22)

**Answer keys corrected.** All six keys were revised from 118 to 242 facts, mostly by splitting bundled facts and adding stated facts the first version left out: 115 visible, 84 partly visible, 43 not visible. The headline counts the 111 visible facts that are neither one of the 8 source conflicts nor the 1 inference. Round 1 was not re-scored. Under the first keys two cases had no plan-proportion fact, so some proportion errors showed up only as contradicted claims; the corrected keys count them as facts. The photos are the same pixels as round 1, under fresh codes. The two cases without photos still have none: the download failed and was not retried.

**Two variants.**

- **A, photos only:** all six cases.
- **B, photos plus footprint:** four cases. The describer also gets the plan outline a game would know from map data (size and shape only) and is told to take plan dimensions from it and to say if the photos seem to contradict it. Two cases had no reliable footprint and run in A only. These footprints were taken from the professional text, so they are more accurate than a real map outline; B measures how a describer uses a good outline, not how it copes with a poor one.

Each variant ran in separate fresh sessions, so no session saw both variants of a building. Two independent judges, each blind to the model mapping and to the other judge, score every case.

### Judge 1

Judge 1's summary was recorded from its hand-back; its per-case sheets are its own. Cases are given by their round-2 codes: P8 residential, X8 operations building with tower, S4 and L8 the warehouse and storehouse, K4 Building 2, J7 Building 3.

**Headline: visible facts** (correct / partly / incorrect / not mentioned / "not shown"; share correct in brackets).

Variant A, photos only, six cases:

| Describer | Out of domain (4 cases, 67 facts) | In domain (2 cases, 44 facts) | All six (111 facts) |
|---|---|---|---|
| Fable 5.2 | 59 / 4 / 2 / 2 / 0 (88 %) | 41 / 2 / 0 / 1 / 0 (93 %) | 100 / 6 / 2 / 3 / 0 (90 %) |
| Opus 5.5 | 46 / 15 / 3 / 3 / 0 (69 %) | 37 / 4 / 1 / 2 / 0 (84 %) | 83 / 19 / 4 / 5 / 0 (75 %) |

Variant B, photos plus footprint, four cases:

| Describer | Out of domain (3 cases, 55 facts) | In domain (Building 2, 22 facts) | All four (77 facts) |
|---|---|---|---|
| Fable 5.2 | 44 / 8 / 0 / 3 / 0 (80 %) | 22 / 0 / 0 / 0 / 0 (100 %) | 66 / 8 / 0 / 3 / 0 (86 %) |
| Opus 5.5 | 38 / 11 / 2 / 4 / 0 (69 %) | 15 / 4 / 1 / 2 / 0 (68 %) | 53 / 15 / 3 / 6 / 0 (69 %) |

A and B cover different cases, so compare them on the four shared cases. There, on the visible facts the footprint does not give away (73 facts; correct / partly / incorrect / not mentioned):

| Describer | A, photos only | B, photos plus footprint |
|---|---|---|
| Fable 5.2 | 66 / 4 / 1 / 2 | 62 / 8 / 0 / 3 |
| Opus 5.5 | 54 / 11 / 3 / 5 | 49 / 15 / 3 / 6 |

The form-critical part of the headline (41 facts in A, 30 in B; correct / partly / incorrect / not mentioned): Fable 40 / 0 / 0 / 1 in A and 26 / 2 / 0 / 2 in B; Opus 33 / 4 / 1 / 3 in A and 23 / 3 / 1 / 3 in B.

**Plan proportion: error against the key.** "0 %" means the plan dimensions match the key. The key's sizes are left out here; they are answer-key text.

| Case (key's plan ratio) | Fable, A | Fable, B | Opus, A | Opus, B |
|---|---|---|---|---|
| P8 (about 2:1) | depth −29 %, ratio +50 % | 0 % | depth −45 %, ratio +75 % | 0 %; recess depth about −50 % |
| L8 (about 7.4:1) | width +7 %, ratio −5 %, height +17 % | 0 %; height +10 % | no sizes given | 0 %; height +12 % |
| S4 (about 2.8:1) | end width +14 %, ratio (lower bound) +8 %, height +6 % | 0 %; height +1 % | end-to-height ratio only (−2 %) | 0 %; height −6 % |
| K4 (about 1.5:1) | ratio −23 %; crown height +9 % | 0 %; crown −8 % | ratio +1 %; crown about −35 % | 0 %; crown −8 % |

The plan facts the footprint gives (12 across the four cases): Fable 7 correct, 4 partly, 1 incorrect in A and 12 correct in B; Opus 5 correct, 3 partly, 2 incorrect, 2 not mentioned in A and 11 correct, 1 not mentioned in B.

**Judge 1's answers to the five questions.**

1. **How reliable (A, visible facts)?** Fable: right 90 %, partly 5 %, wrong 2 % (2 of 111), silent 3 %. Opus: right 75 %, partly 17 %, wrong 4 % (4 of 111), silent 5 %. Most of the gap is in "partly" verdicts. In B: 86 % against 69 % right, 0 against 3 wrong of 77. Basic-form errors that would mislead a modeller: Fable in 3 of 6 cases in A (all plan proportion) and 0 of 4 in B; Opus in 4 of 6 in A and 2 of 4 in B.
2. **Does the footprint help?** It brought every plan-proportion error to 0 %. Both describers derived correct secondary figures from it (bay counts, spacing; heights within −8 to +12 %). It caused no new mistakes, and three real conflicts between footprint and photos were reported. It did not correct existing misreadings of how parts attach (Opus's single carport, a half-resolved low section). It gave no gain on facts it does not supply; those fell slightly in B for both describers, which the judge puts down to session variation (Fable found S4's three roof monitors in A and missed them in B).
3. **Fit for purpose?** No description was unusable. Usable as is: Fable's B descriptions of P8, L8 and K4. All others usable with the corrections listed in the case sheets.
4. **Shared failure patterns, with proposed brief changes:**
   - plan depth guessed from photos: derive it only from something countable on an end face, show the reasoning, or say it cannot be determined;
   - tower windows read as centred: say where each window column sits and whether the corner is glazed;
   - distant rooftop forms missed: check every view that shows the roof;
   - faces not placed: give the evidence for which face a view shows, or mark it unplaced;
   - heights from "ordinary storeys" in tall halls: scale from doors or vehicles and name the object;
   - pane counts stated where the photos cannot resolve them;
   - small site elements missed.
5. **How firm?** About four independent buildings (correlated pairs), one run each. Session variation is unmeasured and about as large as the A–B effect on facts the footprint does not give. Memory risk on the two in-domain cases (Fable's recognition line names the island). Monochrome photos of about 900 px; many "partly" calls; one judge, to be compared with judge 2 fact by fact.

**The three most serious form errors per describer.**

| Describer | Errors |
|---|---|
| Fable 5.2 | K4 (A): plan "only slightly longer than wide", 1.15:1 against 1.49:1. P8 (A): plan about 3:1 and too shallow, against 2:1. J7 (A): plan "twice as long as wide" against 1.5:1, and the concave entrance wall as tall as the pylons (about 50 % too tall). Runners-up: L8's infilled middle storey read as double-height; X8's tower windows on the centre line. |
| Opus 5.5 | S4 (A): the entrance end described as the opposite long side. P8 (A and B): one off-centre carport instead of two side by side (A also a 3–4:1 plan). K4 (A): the one-storey section read as a flush lower storey, and the crown about 35 % too low; B leaves the section unresolved and adds pylons reaching the crown. |

Judge 1's reading: Fable has more correct and fewer partly verdicts, fewer wrong key form facts and fewer cases with basic-form errors; Fable's errors are numeric and the footprint removes them, while Opus's are misreadings of placement and massing that the footprint does not fix. In the judge's words, this "rests on about four independent buildings, one run each, one judge — not a verdict on which model is better."

### Judge 2

Judge 2 is a Fable session, blind to the model mapping and to judge 1. It gave 808 fact verdicts over the 20 descriptions, each with the input photos open; its summary was recorded, condensed, from its hand-back, and its per-case sheets are its own. Its disclosures: it read the prep notes, as its assignment said, although the judge README says judges should not (they discuss round 1's verdicts; judge 1 read them too); it did not open the model mapping or judge 1's scores; and it warns that the headline understates form errors, because plan size and ratio facts are marked partly visible in every key and several misreadings are not checklist facts at all.

**Headline: visible facts** (correct / partly / incorrect / not mentioned; share correct in brackets).

Variant A, photos only, six cases:

| Describer | Out of domain (4 cases, 67 facts) | In domain (2 cases, 44 facts) | All six (111 facts) |
|---|---|---|---|
| Fable 5.2 | 60 / 5 / 1 / 1 (90 %) | 40 / 3 / 0 / 1 (91 %) | 100 / 8 / 1 / 2 (90 %) |
| Opus 5.5 | 50 / 12 / 2 / 3 (75 %) | 38 / 3 / 1 / 2 (86 %) | 88 / 15 / 3 / 5 (79 %) |

Variant B, photos plus footprint, four cases:

| Describer | Out of domain (3 cases, 55 facts) | In domain (Building 2, 22 facts) | All four (77 facts) |
|---|---|---|---|
| Fable 5.2 | 48 / 4 / 0 / 3 (87 %) | 22 / 0 / 0 / 0 (100 %) | 70 / 4 / 0 / 3 (91 %) |
| Opus 5.5 | 39 / 11 / 2 / 3 (71 %) | 15 / 4 / 1 / 2 (68 %) | 54 / 15 / 3 / 5 (70 %) |

Judge 2 disputes six of the key's visibility calls; with its own calls the headline moves by at most 5 points.

**Other measures.**

| Measure | Fable, A | Fable, B | Opus, A | Opus, B |
|---|---|---|---|---|
| Key form facts wrong (any weight) | 6 of 100 | 4 of 80 | 17 of 99 | 7 of 69 |
| … of which wrong in form | 4 | 0 | 10 | 4 |
| Substantive contradicted claims | 4 (+2 medium) | 0 | 9 (+3 medium) | 3 |
| Cases with a basic-form error | 3 of 6 (+1 hedged) | 0 of 4 | 5 of 6 | 2 of 4 |
| Fitness: as is / with corrections / not usable | 0 / 6 / 0 | 4 / 0 / 0 | 1 / 4 / 1 | 2 / 2 / 0 |
| Footprint facts correct (four shared cases) | 8 of 12 | 12 of 12 | 4 of 12 | 12 of 12 |
| Other headline facts correct (four shared cases) | 68 of 73 | 66 of 73 | 58 of 73 | 50 of 73 |

**Plan proportion: error against the key.**

| Case (key's plan ratio) | Fable, A | Fable, B | Opus, A | Opus, B |
|---|---|---|---|---|
| P8 (about 2:1) | length +9 to +18 %, depth −26 to −34 %, ratio +52 % | 0 % | depth −31 to −59 %, ratio +52 to +103 % | 0 %; recess −42 to −57 % |
| L8 (about 7.4:1) | width +7 %; length given as a range that contains the key's | 0 to +2 % | no figures | 0 to +2 % |
| S4 (about 2.8:1) | no length; width +9 to +18 %; ratio at least +8 % | 0 % | no figures | 0 % |
| K4 (about 1.5:1) | length −2 to −12 %, width +9 to +31 %, ratio −23 % at the midpoint; the low strip's depth not shown | 0 %, hall and strip | ratio +1 %, no metres; a wall "3–4 storeys" high implies about −40 % in scale; the low strip not recognised | 0 %; the strip "not confirmed by the photos" |

With the footprint, Fable derived correct bay spacings and counts and opening and pier sizes in all four cases; Opus used it for overall size and height only.

**Judge 2's answers to the five questions.**

1. **How reliable?** Both are rarely wrong on a visible fact they address: Fable about 1 %, Opus about 3–4 %. The errors sit in plan depth and in how views are fitted together. Fable's basic-form errors without a footprint are all plan proportion (three cases) plus one hedged spurious roof block, and none with a footprint. Opus's are of more kinds (a part read as a storey, an elevation on the wrong side, a part at the wrong end, a missed carport, an unresolved plan), in 5 of 6 cases without a footprint and 2 of 4 with.
2. **Does the footprint help?** Plan size and ratio errors drop to 0–2 % in all eight variant-B sheets, with no new mistake attributable to it. It did not improve non-plan facts (Fable 68 → 66 of 73, Opus 58 → 50; not separable from run-to-run variation). Fable reported two real small differences between photos and footprint and read both correctly; Opus reported one conflict that is not real, though there the footprint partly repaired its variant-A error (the low strip is now described, flagged uncertain, instead of absent).
3. **Fit for purpose?** Fable with a footprint: usable as is in 4 of 4; without, every case needs corrections, usually one. Opus without a footprint: 1 as is, 4 with corrections, 1 not usable as written for the plan (X8); with: 2 as is, 2 with corrections. Storeys, roof form and main massing were right in every sheet except the listed points.
4. **Shared failure patterns, with likely prevention:**
   - plan depth and ratio guessed from oblique views, wrong in both directions: give the footprint; without one, give depth only as a range with its basis, count modules, and carry the confidence into the key form facts;
   - things on the roof missed or misattributed: a per-view list of roof objects and whether each stands on this roof;
   - views not tied to sides before elevations are written: a first step linking each view to faces by shared features, and no elevation assigned to a side no link supports;
   - position of openings across a face: ask for it explicitly and check it in two views;
   - statements on what photos cannot show (roof covering, hidden construction): name these as "not shown" cases;
   - battered (sloping) faces read as stepped: ask whether tall elements step, taper or both;
   - short projecting walls overestimated: count modules;
   - blank zones explained instead of reported: report them as blank and mark explanations as inference.
5. **How firm?** Firm: the footprint fixes plan dimensions with no new errors in these four cases; plan depth is the weakest statement of both; Opus has more misreadings of how parts fit together; both are rarely wrong on individual visible facts. Not firm: the size of the gap in points (it depends on "partly" calls), any footprint effect on non-plan facts, and anything about variant B in domain (one case). Six buildings in two correlated pairs, one run per variant. Fable recognised both in-domain buildings, but its out-of-domain headline is about the same, so the gap does not rest on those cases.

**The three most serious form errors per describer.**

| Describer | Errors |
|---|---|
| Fable 5.2 | P8 (A): plan "length about three times the depth" against 2:1, stated as a key form fact after noting the depth is never seen squarely. K4 and J7 (A): the same hall's plan given as "only slightly longer than wide" in one and "about twice as long as wide" in the other. L8 (A): a separate building beyond the far end placed on the roof, at medium confidence. None recurs in variant B. |
| Opus 5.5 | K4 (A): the one-storey block read as the "lower storey" of the hall wall; in B it becomes "two tiers of windows" with the strip "not confirmed", and pylons said to reach the crown. P8 (A and B): one carport instead of two side by side (A also a 3–4:1 plan). S4 (A): the entrance end described as the middle of the long entrance side, with "no loading canopy" on it. |

## Where the two judges agree and differ

Judge 1 is an Opus session, judge 2 a Fable session; each was blind to the model mapping and to the other judge.

**Agree.**

| Visible facts right (judge 1 / judge 2) | Fable 5.2 | Opus 5.5 |
|---|---|---|
| Photos only, out of domain | 88 % / 90 % | 69 % / 75 % |
| Photos only, in domain | 93 % / 91 % | 84 % / 86 % |
| With footprint, out of domain | 80 % / 87 % | 69 % / 71 % |

- The footprint brings plan size and ratio errors to 0 (0–2 %) in all eight variant-B sheets and causes no new mistakes. It does not improve facts other than the plan.
- Fable's errors without a footprint are plan proportions (3 of 6 cases, both judges; judge 2 adds one hedged roof block) and vanish with it (0 of 4, both judges).
- Opus's errors are misreadings of how parts and views fit together (4 of 6 cases by judge 1, 5 of 6 by judge 2; 2 of 4 with the footprint, both judges), and the footprint mostly does not fix them (judge 2: it partly repaired one).
- Both describers are rarely wrong on a visible fact they address.
- The shared failure patterns: depth from oblique views, roof objects, views not tied to sides, positions of openings, and statements about what the photos cannot show.

**Differ.**

- Judge 1 rated no description unusable; judge 2 rated one (Opus, photos only, the operations building) not usable as written for the plan.
- The number of "partly" verdicts differs, so the size of the gap in points is not firm.
- Key form facts wrong for Opus without the footprint: 6 of 99 for judge 1 (which gives 6–9 %), 17 of 99 for judge 2, 10 of them wrong in form.
- Judge 1 counted all three conflicts the describers reported between photos and footprint as real; judge 2 calls one that Opus reported not real.

Two judges agreeing is stronger than one, but both judges are themselves sessions of the two models under test (judge 1 Opus, judge 2 Fable), both read the prep notes, and the cases are about four independent buildings with one run per variant. The direction is consistent; the sizes are not firm.

## What this means so far

These are findings from about four independent buildings and two judges, not rules.

- **Usable with the footprint.** With the footprint given, the descriptions are usable for a first modelling round: both judges rated them usable as is or with listed corrections, and storeys, roof forms and main massing were right in nearly every sheet.
- **Plan proportions.** Without the footprint, plan depth and length-to-depth ratio from photos were not reliable in these cases. A footprint of the kind map data gives removed those errors without introducing new ones in this run (see the [footprint lesson](../LEARNINGS.md#give-a-describer-or-modeller-the-footprint-dont-let-it-guess-depth-from-photos)). The footprints here came from the professional text, so a real map outline may do less well.
- **Fitting views and parts together.** Misreadings of how parts attach and which side a view shows are not fixed by the footprint.
- **Memory.** The in-domain cases carry a memory risk: Fable said it recognised both in-domain buildings, and Opus recognised one in round 1, so in-domain scores may not measure reading from photos alone.

Proposed changes to the describer brief for the next round, from both judges' patterns (not adopted):

- a first step linking each view to the sides it shows, before any elevation is written;
- a per-view list of roof objects;
- positions of openings across each face;
- depth only from counted modules, or as a range with its basis;
- roof covering and hidden construction named as "not shown" cases;
- say whether tall elements step, taper or both;
- report blank zones as blank.

Open:

- **Owner decision:** whether the descriptions are good enough to lift the hold on the modelling shootout. The owner has since lifted the hold (2026-11-21, "Yes" to starting the modelling shootout with Fable as describer and the footprint supplied); the next modelling shootout is being prepared;
- more independent cases, including the two still without photos;
- colour photos;
- whether a description actually improves a first modelling round. Tested in [process shootout 2](PROCESS_SHOOTOUT_2.md) (2026-11-21 to 22): the owner preferred the described build blind on both buildings, and on the housing row the blind judge's checklist agreed (24 and 23 of 24 against 19.5 and 20.5); two buildings, one description each.

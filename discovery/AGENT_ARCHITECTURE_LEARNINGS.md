# Agent architecture learnings

These are the orchestrating session's own observations on running agents in this project, from one long working session (2026-11-20 to 21). Most of them are hypotheses. When they were written the owner did not adopt them as rules: "we would need to know if any of these really … make a difference. Right now it's just a hypothesis, right?" The owner has since adopted one of them as the standing way of working, the heavy checks run once, on the release batch (lesson 3), and none of the others. [AGENTS](../AGENTS.md) remains the authority, and this document does not change it.

Each lesson gives what was observed, what the orchestrator now does, and its status: **measured**, **first measurement** or **hypothesis**. Where a lesson in [LEARNINGS](../LEARNINGS.md) already covers the point, it is linked and only the orchestration angle is added here. Evidence marked "as recorded by the orchestrating session" is not in the repository and could not be checked against it.

## Flow

### 1. Owner first, reviewers second

- **Observed.** Building 1's exterior went through seven geometry rounds and four material rounds of review and fix. Geometry and materials were then combined on one branch and shown to the owner as sheets plus a preview before any further review, and the owner accepted it in one message: "Building 1 is good". The hall floor ("I strongly prefer worn as is") and the car dirt ("Car dirt is approved") were settled the same way. The rounds are in [Run the heavy checks once](../LEARNINGS.md#run-the-heavy-checks-once-on-the-final-candidate); the combined branch is on origin; the owner's words are as recorded by the orchestrating session.
- **Now.** Show the first coherent result to the owner. Reviewers then check defects and mechanics only. See [Settle a look in play](../LEARNINGS.md#settle-a-look-in-play-and-freeze-it-once-the-owner-likes-it).
- **Status.** Hypothesis.

### 2. One review round by default

- **Observed.** A fresh reviewer each round finds a different thing. A review takes minutes; the round of fixes it triggers takes hours (as recorded by the orchestrating session). See [A review round adds objects](../LEARNINGS.md#a-review-round-adds-objects-removing-is-a-valid-fix) and [A further review round buys little](../LEARNINGS.md#a-further-review-round-on-a-decent-first-build-buys-little).
- **Now.** One review round by default. Further rounds only for defects named by the owner, a mechanical check or a held independent review.
- **Status.** Hypothesis.

### 3. Heavy checks once

- **Observed.** See [Run the heavy checks once, on the final candidate](../LEARNINGS.md#run-the-heavy-checks-once-on-the-final-candidate).
- **Now.** While iterating, the orchestrator asks only for the focused contracts the change touches; the full suite, builds and shader proof run once, on the final candidate.
- **Status.** Hypothesis.

### 4. One artefact, one branch at a time

- **Observed.** Four branches touching the same interior file needed hand merges, and a material study was reviewed three times laid over outdated geometry. See [Work on one building on one branch at a time](../LEARNINGS.md#work-on-one-building-on-one-branch-at-a-time).
- **Now.** Before dispatching, check which open branches touch the artefact; give each artefact one branch and merge the others into it rather than overlaying them for review.
- **Status.** Hypothesis.

### 5. Describe before modelling; give facts from data

- **Observed.** Plan depth estimated from photos was off by up to −59 %, and about 0 % with the footprint supplied (two judges). See the [architect-description shootout](ARCHITECT_DESCRIPTION_SHOOTOUT.md) and [Give a describer or modeller the footprint](../LEARNINGS.md#give-a-describer-or-modeller-the-footprint-dont-let-it-guess-depth-from-photos).
- **Now.** Give agents facts from data (footprints, measured sizes) rather than letting them estimate from pixels. A description goes to the modeller, and the same description goes to the reviewer, as the owner proposes for the next shootout.
- **Status.** First measurement on descriptions; the effect on modelling is untested.

### 6. Corrections as measured targets

- **Observed.** Directional instructions overshot and swung back: wall texture made invisible, then too strong in shade; door frames darkened, then returned to brass; pier fluting removed at distance, then restored. See [Give a correction as a measured target](../LEARNINGS.md#give-a-correction-as-a-measured-target-not-a-direction).
- **Now.** The orchestrator turns owner and reviewer feedback into a target against the reference before passing it on, not "more" or "less".
- **Status.** Hypothesis.

## Checks

### 7. Build a mechanical check when eyes miss a class of defect twice

- **Observed.** On Building 1 the owner, not the reviews, found a doorstep that stopped about one approach in six, a see-through gap at the rear, and a camera snap at the hall door. See [Check a building's shell and doorways mechanically](../LEARNINGS.md#check-a-buildings-shell-and-doorways-mechanically-not-by-eye). Checks built since, all on `main`: the passage walk (96 ways through each catalog passage's door); the far stand-in's outside views (a stand-in poking above a roof); the case in which the hall's mural loader does not set up, so the hall stays drawn as built; the shell check (no ray from outside reaches the interior); and the steady-camera bound at the hall door.
- **Now.** Require that a new check fails on the old state and passes on the fix, and keep that red run in the log.
- **Status.** First measurement: the shell check found three holes in the old state, one of them in the released game; the other checks' red runs are as recorded by the orchestrating session. Whether they catch future faults is untested.

### 8. Bind evidence to the commit

- **Observed.** Logs that open with the commit and an empty `git status` let reviewers answer release questions without an engine run. Receipts needed reading against the log's content; one receipt logged another command's exit status (as recorded by the orchestrating session).
- **Now.** A clean tree at start and end, the checked command's own exit status in the receipt, logs that name the head; reviewers verify from the log's content, not the receipt's summary line.
- **Status.** Hypothesis.

## Agents

### 9. Resume for iterations, fresh for judging

- **Observed.** Long-lived agents carry stale defaults: a run wrapper still pointing at an old worktree cost seven engine runs, whose "post-merge" results were the pre-merge branch's.
- **Now.** Resume the same agent for iterations on its own work, restating paths and the head at each resume. Use fresh agents for independent review and judging.
- **Status.** Hypothesis.

### 10. Batch follow-ups

- **Observed.** A message to a running agent arrives at its next step or after it finishes, which cost extra commits (as recorded by the orchestrating session).
- **Now.** Collect the owner's final wording before dispatching a write-up, and batch follow-ups into one message.
- **Status.** Hypothesis.

### 11. Briefs carry checked facts

- **Observed.** A modeller was told the cupola glazing leans outward (as recorded by the orchestrating session); reference research then found it leaning inward in three dated views. A documentation agent corrected several figures in its brief against the run's files.
- **Now.** Briefs give exact paths, evidence files, numbers with their source, what not to touch and when to stop. An eyeballed claim is passed on as a question, not a fact, and agents are asked to check figures against the source files.
- **Status.** Hypothesis.

### 12. Each rule in one place

- **Observed.** A brief told two judges to read a file that their own readme forbade, and both did.
- **Now.** Keep each rule in one place and check the brief against the readme. Keep blind mappings in files the test agents cannot read, and change blind labels between rounds (the describer test reversed its numbering and gave fresh case codes in round 2).
- **Status.** Hypothesis.

### 13. Judges on different models

- **Observed.** In the describer test the judges are themselves sessions of the models under test. Two judges, one on each model, agreed on the direction of every main finding and differed on sizes and on two single calls.
- **Now.** Use two judges on different models, report where they agree and differ, and word conclusions as "direction consistent, sizes not firm".
- **Status.** Hypothesis.

### 14. Save reports from the hand-back

- **Observed.** The harness refused both judges' writes of their summary files; the primary session saved each summary from the judge's hand-back text.
- **Now.** Subagents hand findings back as text; the orchestrator saves summaries where the harness refuses a subagent's report file, and says so in the file.
- **Status.** Hypothesis (the refusals are observed).

## Permissions and money

### 15. Never route around a refusal

- **Observed.** The permission check refused a subagent's push to `main` and its launch of a deploy, refused reading sealed files, and (as recorded by the orchestrating session) refused spending on a newly created key. It does not accept the owner's approval relayed through the orchestrator.
- **Now.** The orchestrator performs such a step itself with the owner's explicit go. The subagent's job is to prepare exact, reviewed commands.
- **Status.** Hypothesis (the refusals are observed).

### 16. Gateway spend limits are soft

- **Observed.** Spend limits on external model gateways were soft: a 10-dollar key budget ended at 10.47, abandoned requests were billed, and a run spent while producing nothing. See [Model tiers by detail level](MODEL_SHOOTOUT.md#model-tiers-by-detail-level).
- **Now.** Read the balance during runs, and stop a run that has stopped producing.
- **Status.** Hypothesis.

## Machine

### 17. The engine is the bottleneck

- **Observed.** One GPU and one full test run at a time (as recorded by the orchestrating session).
- **Now.** Documentation, research, describing and judging run in parallel freely; engine work queues behind locks. Private data sets are protected by keep-markers, cleanup exclusions and a private copy elsewhere.
- **Status.** Hypothesis.

## Owner communication

### 18. Short, plain, in the tool

- **Now.** Ask questions through the question tool only. Keep summaries to a few lines. Say plainly when a result is a hypothesis. The owner's judgement in the running game outranks stills and reviewer preference; freeze a look the owner likes. When dictated input is garbled, state the interpretation.
- **Status.** Hypothesis, partly from owner instructions (as recorded by the orchestrating session).

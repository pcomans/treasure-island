# Running a blind model shootout

This is an isolated taste/workflow experiment, not production acceptance. ROOT coordinates fresh participants and a named capture executor; follow AGENTS for explicit non-ultra routing and serialized engine ownership. The owner judges anonymous outputs. Keep identities, timing and token totals out of comparison HTML until voting ends.

The prepared [2026-09-30 packet](/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/gpt61-astra-shootout-2026-09-30/PLAN.md) contains exact current paths, briefs, templates and four invocation lines. It reuses the successful `astra-sol-high-benchmark-2026-09-22` packet alongside it. Private photographs/templates/participant assets remain external; do not copy them into Git. Start this run after the harness checkpoint is pushed.

1. **Blind critique first.** Fresh GPT-6.1 Sol (`gpt-6.1-sol`, high) and Astra (`gpt-6-astra`, medium) receive only the same CRITIQUE_BRIEF and six images: March2025 Bayside reference/whole/near, plus the mineral/brick material case. One response each,60–90 words per case, no revision. Fill the anonymous critique HTML beside all originals, verify the assembled page, and obtain the owner's verdict **before modeling dispatch**. ROOT keeps the randomized identity mapping private.
2. **De novo modeling second.** Fresh Sol high and Astra low receive the same MODELING_BRIEF, two March2025 Northpoint originals and `render/model-interface.gd`. They write only their assigned `render/variant-x/model.gd` or `variant-y/model.gd` and assets. Exclude prior models, verdicts and competitor outputs. The experiment explicitly permits de novo work instead of normal asset reuse; no bespoke trees. Use the fixed envelope, camera and lighting, roughly ten active author minutes each (suggested six initial/four revision).
3. **Reuse the fixed parameterized renderer.** The capture executor, not participants, runs the committed `tools/model_shootout/run_capture.py` below. Preserve the complete driver; models do not write capture/QA machinery. Use fresh outputs, one process at a time, normally Y preview,X preview,Y final,X final. Each author inspects only its own three preview images once and makes one revision or retains. Four successful captures total; repairs require a separately bounded mechanical-only allowance and fresh output path. Preserve failed attempts. Require three1440×900 originals, completion marker, clean logs and actual terminal/PID release—not just wrapper `ok`—before transferring the slot.
4. **Present and vote.** Fill modeling HTML with both anonymous options, reference originals, all six initial and six final renders, plus original/fullscreen access. Verify decoded image joins and narrow/wide presentation once. Deliver this first comparison before any owner-driven revisions. Record the owner's final preference; do not infer an initial-pass winner unless explicitly supplied. Reveal identities afterward.

Record setup and harness-push intervals separately from participant work. Ordinary notes retain dispatch, first edit, initial-ready, preview, revision, final-ready, capture, HTML delivery and owner-verdict timestamps; include human waiting, queueing, failures and transport in full-workflow timing. Engine seconds are narrower. Record run order/cache/interruption, and actual token-counter deltas when available; inference time, missing token counts and cost remain unknown. No token estimate from prose length, no speed claim from render seconds, and no extra reporting framework.

The 2026-10-02 modeling run established this packet's native macOS compatibility through four successful committed-runner captures; the initial model parse failure and its bounded numeric-typing repair remain preserved in the private packet. This is neither cross-platform nor production validation. These taste verdicts do not replace independent source/mechanics, visual or release decisions for future production adoption.

## Prepare and run from a clone

The code-only renderer, project and model interface live in [tools/model_shootout](../tools/model_shootout/run_capture.py). The default housing profile preserves the successful housing cameras, lighting and image names; project.godot and the model interface remain unchanged. The shared capture driver now also accepts the optional MERSEA profile. Completed private housing project bytes and results remain preserved and are not rerun. The wrapper adds configurable paths and explicit launch/error/final cleanup receipts. Existing external packet code is preserved. The 2026-10-02 modeling run exercised this committed runner successfully on macOS with Godot 4.7.2, Metal and Forward+; other platforms remain unvalidated.

Prepare the same private references/briefs and anonymous mapping outside the clone. Authors receive `tools/model_shootout/model-interface.gd` and place their standalone model at `<packet>/render/variant-x/model.gd` or `variant-y/model.gd`; no participant model or photo belongs in Git. The capture executor uses:

```sh
python3 -B tools/model_shootout/run_capture.py variant-y preview --packet-root /absolute/private/packet
python3 -B tools/model_shootout/run_capture.py variant-x preview --packet-root /absolute/private/packet
python3 -B tools/model_shootout/run_capture.py variant-y final --packet-root /absolute/private/packet
python3 -B tools/model_shootout/run_capture.py variant-x final --packet-root /absolute/private/packet
```

These are separate serial invocations under the existing named engine slot; inspect each result/log and release before the next. `--godot /absolute/path/to/Godot` overrides the default `tools/godot`, which runs the project Godot on the GPU in the Linux devcontainer (Forward+). The runner copies exact maintained project files into the private packet if absent and rejects different existing bytes; caches stay private. Existing preview/final directories are never overwritten. It snapshots model.gd, records PID/argv immediately, enforces180s then terminate/kill/wait, and writes terminal/error/image/completion status even on launch failure. The external original wrapper remains historical; use this committed wrapper for a fresh rerun. CLI help and Python syntax are preparation checks, not native image acceptance.

## Optional MERSEA study profile

Use the same runner with `--study mersea` for both variants and both phases. It selects identical shared position/target pairs: whole site `(0,10,62)` → `(0,1,0)`, elevated oblique `(46,36,50)` → `(0,0,0)`, and courtyard `(7,1.7,12)` → `(-4,1.8,-8)`. The study envelope is X±26, Z±24, Y0..8 metres, an unmeasured framing inference around the courtyard origin/open approach+Z. Resolution1440×900, FOV60, neutral daylight, Forward+ and the complete capture/terminal lifecycle are unchanged. Omit the flag for the original housing profile. Unknown profiles are rejected before model loading. Native MERSEA validation completed in four serialized macOS captures (two variants, initial and final): each exited cleanly with the completion marker and three native 1440×900 PNGs. This validates the scoped study capture, not production or cross-platform acceptance.

The resumed owner-authorized combined blind test includes prior critiques, housing initial/final and fresh MERSEA initial/final results; the earlier critique-vote prerequisite does not block this experiment. References, mappings, models and measurements remain private, outside Git.

## Owner's blind vote, 2026-11-19

The first shootout compared two anonymous options, X and Y, later unsealed as X = DeepSeek V4.1 Flash and Y = Opus 5.5, one mapping for all tasks.

In the critique task (two cases, a housing block and Building 1), the owner found case A's critiques roughly equivalent and X better on case B: Y said the reference's right wing has three window rows (it has two) and said the rooftop structure, which it called a "lantern" (the owner: "I would not have called it a lantern"), is not visible, when it is. Overall the owner felt X was better, with the margin unsure, and guessed X was Claude; it was DeepSeek. Both critiques were flowing prose and not very actionable. The owner's hypothesis, that the prompt should ask for specific, concise, concrete findings, led to the four-question review format.

On the housing model, Y was "clearly better. Like no contest": more correct colour, shiplap texture and the correct side wall, where X invented a window under the gable and a row of side windows and looked too slim. After one review round Y was "very clearly pulling ahead", with facade depth and the shed added at the back.

Net: DeepSeek narrowly ahead on critique, Opus decisively ahead on modelling.

## Review-format test (Opus only)

Every version starts from the same Opus first build of the housing block. Each had one review round under different review instructions, then a fix by Opus (2026-11-19 to 20), and the owner saw the results blind as A–D. The mapping, unsealed by the owner's vote: A = the four-question format, run 1; B = the four-question format with "no additions allowed"; C = a free-form prose review (the earlier format); D = the four-question format, run 2.

| Review | Words | Additions / fixes asked | Mesh nodes, start → after fix |
|---|---|---|---|
| Prose (C) | 339 | 3 / 3 | 336 → 781 |
| Four questions (A, D: one review, two fixes) | 1,138 | 3 / 5 | 336 → 421 (A), 409 (D) |
| No additions (B) | 862 | 0 / 8 | 336 → 322 |

Words and node counts are measured from the run's files. The additions and fixes tallies, and that in B both the reviewer and the fixer obeyed the rule, are as recorded at the time. The test so far is one building with one run per format, and the owner regards the format changes as hypotheses until measured: "Right now it's just a hypothesis, right?"

The owner's blind verdict: "if I absolutely had to pick one, I would pick version A". Its small windows shrink to about the right size (a bit too much), the big windows stay a bit too big, the box positions are still clumsy, and it adds the shed. C "does make a significant leap in terms of small detail" (the front doors set back) "but it also just adds a lot of clutter … It's more like noise and not signal". All four "make very modest gains"; "I don't think the iteration … beyond the starting building is really worth it here". Every version missed the upper floor slightly overhanging the ground floor, and all drifted away from the doors' real blue. The owner did not comment on B or D.

Earlier, not blind: after a second review round the owner found the Opus building worse: "It looks more cluttered", with bins, AC units and small windows crowding the doors.

Variant E (2026-11-21, not blind: added after A–D, and the owner has not judged it yet) told the review to judge recognisability and overall visual fit first and not to ask for fine detail for its own sake. The review ran to 975 words and asked for 0 additions, 6 fixes and 2 removals (as recorded at the time); mesh nodes went from 336 to 374 and triangles from 7,790 to 8,246; review and fix cost $0.75. The fixer still went from three grey utility boxes by the doors to five, although the review had listed the boxes under 'keep it' and asked for none. The review did not mention the upper-floor overhang.

Variant F, a form-first instruction plus enlargements of the same two photos, is running; no result yet.

## Model tiers by detail level

**Status (2026-11-21): a plan, not routing.** Modelling runs in Claude Code on Opus 5.5, as [AGENTS](../AGENTS.md#bounded-subagent-execution) says. Kimi K3.1 Pro is a candidate to consider for cheap low-detail modelling, possibly as a first pass; Gemini 4 Neon is to be investigated for high-detail work. Neither is routed, and adopting either is a later owner decision.

The owner's plan: "Kimi I think looks … basic but acceptable. So I would say I would use Kimi for like cheap low detail modeling, right? Maybe for like a first pass. I would keep using Opus for mid-detail modeling and then I think we should start investigating Gemini for high detail work". Earlier in the same discussion: "we will consider using Kimi for … cheap [low] detail work where we're gonna keep Opus as like the honestly affordable mid-detail work and … we're planning to investigate Gemini Neon as like the high detail high fidelity work". Their judgements from the shootout page: "Kimi looks fine for low detail work"; "Neon is very impressive, on par with or even beating Opus"; and earlier, of DeepSeek: "Maybe DeepSeek is just not the right model here".

**Evidence.** One housing block, with the same brief, references, sandbox and renderer for every model: a first build (with one self-revision), then one review round by the same model (a fresh session reviews, another revises). Each figure comes from one run, so it is a single sample, not an average. Costs are the prices the harness recorded (catalog prices; for DeepSeek about twice what was actually charged); Gemini's come from the gateway's credit balance. Opus and DeepSeek reviewed with the earlier free-form prompt, Kimi and Gemini with the four-question prompt, so review costs and revisions are not strictly like for like. Triangles are counted from the built meshes.

| Model | Cost: build / review / revision | Total | Triangles: first build → after review | Notes |
|---|---|---|---|---|
| Opus 5.5 | $0.40 / $0.31 / $1.05 | $1.76 | 7,790 → 13,840 | Build about 2 min |
| Kimi K3.1 Pro | $0.36 / $0.07 / $0.26 | $0.69 | 7,342 → 7,702 | |
| DeepSeek V4.1 Flash | $0.04 / $0.02 / $0.07 | $0.13 | 5,390 → 8,810 | Owner: "Maybe DeepSeek is just not the right model here" |
| Gemini 4 Neon | $1.45 / $0.55 / did not complete | | 27,084 (no revision) | Build about 9 min |

Gemini 4 Neon in detail:

- 16,896 of its 27,084 triangles are four door knobs built as default-resolution spheres (4,224 each; computed from the model's code, not measured). Siding, roof and concrete are textures drawn in code, with relief (normal) maps on flat walls.
- Its revision did not complete in two attempts in this harness. In both attempts its requests ran for minutes without output and were restarted until the time cap ended the step; its thinking summaries had to be switched off for it to run at all.
- The gateway bills abandoned requests: the two revision attempts cost $8.23 of its $10.47 total, about $7.84 of that for requests that returned nothing. The gateway's per-key budget is a soft cap; spending went past it.

Before Gemini 4 Neon can be used:

- a harness and timeout setup in which it can iterate;
- a spend ceiling that actually holds;
- a triangle budget, because of the phone memory limit.

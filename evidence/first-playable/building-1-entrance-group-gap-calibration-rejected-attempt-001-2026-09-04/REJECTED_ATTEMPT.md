# Building 1 entrance-gap capture — rejected attempt 001

Status: **rejected before candidate implementation; never admissible as A/B evidence**.

This directory preserves the first capture attempt exactly enough to explain why
it was abandoned instead of silently overwriting or deleting it. The scalar was
still the accepted control value `entrance_group_gap = 0.55`; no production
config had changed.

The three current-topology stills completed, but the still stage had already
been rerun once after a harness preflight correction. The motion command then
failed before gameplay input because the harness incorrectly expected the
sunlight rotation from a different evidence workflow. MovieWriter nevertheless
closed a two-frame, `1280x800`, 89,488-byte AVI. No `a-motion.json` was produced.
That AVI is a failed diagnostic artifact, not continuous motion evidence, and
the directory has no candidate/B stage.

The replacement attempt uses a fresh output root, refuses pre-existing stage
and combined-seal files, writes MovieWriter output to a disposable pending name,
and validates the actual AVI container dimensions/frame count before a one-time
rename to the canonical movie name.

No visual, recognizability, or believability conclusion may be drawn from this
rejected attempt.

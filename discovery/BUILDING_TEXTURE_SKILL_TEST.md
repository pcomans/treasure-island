# Building-texture skill validation record

Date: **2026-08-29**

## Package validation

- Skill: `/Users/philipp/cowork/.agents/skills/building-texture/`
- Validator: `/Users/philipp/.codex/skills/.system/skill-creator/scripts/quick_validate.py`
- Result: **`Skill is valid!`**
- The default system Python lacked PyYAML, so the same validator was run with an existing local PyYAML-capable Python at `/Users/philipp/cowork/kuwahara-wallpaper/.venv/bin/python`. No package was installed or downloaded.

## Deterministic proof-generator test

- Script: `/Users/philipp/cowork/.agents/skills/building-texture/scripts/build_proofs.mjs`
- Rejected input: `evidence/first-playable/77-bruton-texture-experiment-2026-08-29/candidates/candidate-01.png`
- Input dimensions: `1024 × 1024`
- Input SHA-256: `1cf8e3091469f92b28211c5b212fd1e1cc34fb1aaadc1b4a098e856481966e9f`
- Output: `/private/tmp/building-texture-skill-test/`

Recorded opposite-edge screen:

| Axis | MAE | RMSE | Numeric verdict |
|---|---:|---:|---|
| X, left/right | `0.00744868` | `0.0101385` | `pass_candidate_screen` |
| Y, top/bottom | `0.0173445` | `0.0225062` | `pass_candidate_screen` |

The script created the required native borderless and boundary-overlay `3×3` proofs, half-X/half-Y/half-XY circular-roll proofs, and downscaled `8×8` macro-repeat proof, plus normalized input, edge crops, JSON, Markdown, dimensions, and hashes. The borderless proof exposes the known edge-composed narrow-window cadence even though both numeric axes pass.

Crucially, `proof-report.json` records:

- `semantic_repeat_review.verdict: unreviewed`
- `art_review.verdict: unreviewed`
- `godot_receiver_review.verdict: unreviewed`
- `overall_acceptance.verdict: not_accepted`

This confirms the mechanical checker does not falsely turn a low-error seam into semantic or overall acceptance.

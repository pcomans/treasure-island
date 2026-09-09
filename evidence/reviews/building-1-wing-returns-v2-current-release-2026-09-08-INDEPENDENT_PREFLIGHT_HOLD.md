# Current B1 release wrappers — independent preflight

Reviewer: `handoff_state_review` · 2026-09-08

HOLD_FOR_B1_RETURNS_V2_CURRENT_RELEASE_CAPTURE

The real engine invocation with `--fixed-fps 60` is rejected by the capture
wrapper's final shared preflight guard. Capture is not authorized by this note.
No world load, rendered capture or evidence write occurred.

## Exact reviewed inputs

Task directory: `work/b1-v2-release-capture-001`.

- `current-release-binding.json`: 24,925 bytes,
  SHA-256 `e4c3f98899a685a510a65fd7782e2c8414b1bf87688b38a73f87a0100e0dff12`.
- `building_1_wing_returns_v2_current_release_capture.gd`: 6,994 bytes,
  SHA-256 `3018b1549fa3965e39feb5159296ccbc1e3ca8b387fda33a443b25c5a5a66be5`.
- `headless_building_1_wing_returns_v2_current_release_evidence_contract.gd`:
  14,539 bytes, SHA-256 `7c67f3724b9596e9803b6780d701062f9c45635e89a7c40cd64d69db8910da94`.
- Artist static report: `preflight-behavior-diff.json`, SHA-256
  `522cb6de3abcd4ab76fff26dfd859db55b3fe72e6b37640d42fcd31d8c9151e5`.

## Finding and proof

`_release_preflight(true)` searches `OS.get_cmdline_args()` for `--fixed-fps`
and the following `60`. Godot consumes that engine option. A dedicated no-render
observation, actually launched with the option, exposes only `--script` and the
script path; `OS.get_cmdline_user_args()` is empty. Thus a valid fixed60 launch
fails this guard in all three modes. The otherwise identical evidence preflight
with `require_fixed_fps=false` passes the sealed source/app/proof inputs.

The headless scratch probe disables inherited capture initialization, exercises
the actual wrapper helpers, and returns exit 1 at the positive preflight check
(exec session 88753). Its log is
`work/b1-v2-release-preflight-independent-001/fixed60-probe.log`, SHA-256
`6b4b9b97fe465f1150871ffce96c91dc0b5f036e31d3053d8b000aab3ece7beb`.
The separate argument observation exits 0; its log is
`work/b1-v2-release-preflight-independent-001/fixed-argument-observation.log`,
SHA-256 `27038b53b19aa2e03482c5e71dd1b5228bd0d742966942c63a5f91d71142f7d5`.
All owned processes are terminal and the heavy slot is released.

Replace only the impossible fixed60 observation with a supported check of the
actual owned launch invocation or an equivalent engine mechanism. Retain actual
fixed60 for every capture mode and fail-closed behavior. Re-seal changed wrapper
identities and rerun the affected positive/negative preflight controls before
capture. The later mutation/projection controls were skipped behind the failed
positive guard; this note does not claim they passed.

## Completed static scope

The two capture overrides and three evidence overrides match the stated scope;
all six shared preflight helpers have identical executable text. Parent render,
camera, controller, light, grayscale, spray, landing and pairing methods and
constants are inherited without changes. The exact binding matches 51 audited
inputs, three parents, two reviews, two complete package receipts, seven app files
and all 49 accepted reference files. Current metadata projection is limited to
provenance/status fields after exact raw-field equality; observed topology,
camera, receiver bindings, captures and motion remain outside that projection.
This static finding still needs the deferred dynamic negative controls.

The planned 46 fresh PNGs and three manifests remain source renders with separate
exact signed-package proof. The 49 accepted reference files are read in place;
neither they nor any sealed product/proof/app file was edited. Recognition
remains 9/213 with +0 credit; no fresh visual acceptance is claimed.

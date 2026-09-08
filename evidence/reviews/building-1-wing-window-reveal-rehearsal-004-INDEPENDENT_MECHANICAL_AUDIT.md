# Building 1 wing-window reveal rehearsal 004 — independent mechanical audit

Date: **2026-09-08**  
Reviewer: **`/root/b1_rejected_lineage_audit`**  
Scope: **rejected-v1 rehearsal mechanics, evidence integrity, and mounted-package semantics only**  
Released baseline: **`b4ab09356c8a15843fa295af024434f97027e1fe`**

## Verdict

The disposable Building 1 reveal rehearsal is mechanically exact and
independently rerunnable. Its 98 original inputs reproduce their sealed receipt,
the candidate PCK independently mounts and instantiates the expected bounded
geometry, and current recognition authority remains exactly v9 `9/213`.

This verdict does **not** approve the candidate visually. The independent visual
review is a hold, so these v1 product and capture hashes are frozen only as
rejected lineage. They must not be promoted, copied into authoritative evidence,
or used for recognition credit.

## Frozen rejected-v1 identities

The product inputs present for capture and independently source-gated before the
rehearsal were:

| Product input | SHA-256 |
| --- | --- |
| `game/resources/facades/building_1_public_front_believability.json` | `fca8feba243c4b1b1747050852ab2db7102aae668838ad8265524caa20cc6fc1` |
| `game/scripts/world/facades/building_1_hero_model.gd` | `1b3e9086b9a5628a68fe684736010277219b02f931d09e03f1442be15afe35a8` |
| `game/tests/headless_building_1_public_front_believability_contract.gd` | `0c73a6dbc9028b7a3cb7fac5e474f93b32cf823dc74a44aefba275723f1184e2` |
| `game/tests/headless_building_1_hero_model_contract.gd` | `24831f23cad27004f36851d7dbbedd02ca607190b7543a2f378897e12ba31bf2` |
| unchanged reveal material, `game/resources/materials/world/building_1/building_1_reveal_shadow.tres` | `2e1f36f163c037fe060a1ecfcdcc5dd062849290a96c508970384585b176e14a` |

Their capture-only proof programs and prerequisite independent source audit were:

| Capture-only input | SHA-256 |
| --- | --- |
| `game/tests/building_1_wing_window_reveal_candidate_capture.gd` | `20363d664e268e4760ba8d5817c71553a9237a6df442931185fdc69c752f05d4` |
| `game/tests/headless_building_1_wing_window_reveal_candidate_evidence_contract.gd` | `0c60baadc8bbb218493c70275b97df5db7ccd074c1a58b043728db20216a6807` |
| `game/tests/headless_building_1_wing_window_reveal_candidate_package_contract.gd` | `fdf42f697312c0149ebbfbb385ece6cc2fa675f623769c4634f37e3311450190` |
| `evidence/reviews/building-1-wing-window-reveal-candidate-2026-09-08-INDEPENDENT_SOURCE_AUDIT.md` | `c70a364dc90746f5e5b6f2e1021f68c8cd94dcc52761516538d19a3edaed24a0` |

The source audit ends in
`PASS_FOR_B1_REVEAL_EVIDENCE_CAPTURE`; that token authorized only a rehearsal,
not visual acceptance.

The sealed package identities are:

| Package input | SHA-256 |
| --- | --- |
| released v9 baseline PCK | `0945ac7b08ebd2fc5389ffa05a919b7324ecb298dac46032c8fdc30d8c47404a` |
| rejected-v1 candidate PCK | `835cfc74b5e4662abdab27d023f0dd0a00feaf06dcc19a73657bc6631d47474b` |
| rejected-v1 candidate executable | `a2a1b0a6a20be0c6fec9f4cef659540c324ae645a5c3c69683b353c061afa945` |
| rejected-v1 candidate `Info.plist` | `12210013168f4197b156c151636a81d27285741b3d2cdd138740d09853a9f085` |

## Rehearsal input and receipt closure

The non-authoritative rehearsal remains outside the repository at the disposable
location `/private/tmp/b1-reveal-rehearsal-004`. It contains exactly 92 original
PNG files and six JSON manifests before its receipt, with no other inputs:

- 46 baseline and 46 candidate PNGs;
- 22 static PNGs per stage;
- 12 north-motion and 12 south-motion PNGs per stage;
- `70,161,741` total input bytes.

I independently recomputed the ordered 98-input material as
`relative_path|sha256|bytes\n` over bytewise-sorted paths. Its SHA-256 is
`4af8dd0e395efb798548c710c3c72c99f170a6b22711017a377dab07827e7aaf`,
matching the receipt. The receipt itself is separately bound at
`4fc7a1e0d64f23df62c3e919f56a48120c20ab5beeb5aca27548af8b49bb8460`.
There is intentionally no claimed 99-file packet tree: the input tree excludes
the downstream receipt and therefore remains acyclic.

The verify-only run exited `0` and reproduced the receipt byte-for-byte:

```text
PASS: rehearsal-only B1 reveal A/B closure is exact: 92 original PNGs + 6 manifests, byte-rederived grayscale, zero paired pose/controller-tick drift, intended +360 visual triangles only; receipt=4fc7a1e0d64f23df62c3e919f56a48120c20ab5beeb5aca27548af8b49bb8460
```

## Pose, light, motion, and grayscale result

Both stages contain the same five ordinary ground/player view definitions,
default sun `[-52, -28, 0]`, and changed sun `[-18, 118, 0]`. Each changed-light
capture reports exact reuse of its corresponding default-light player and camera
transforms. Across the source A/B stages, the recorded static player and camera
positions are exact; all paired pose, forward, target, light, spray, and roof
fields pass the declared `0.00005 m`/float tolerance.

For both north and south motion manifests, the A/B trajectory, start pose,
controller telemetry, engine ticks, and every non-pixel capture field are exact.
The observed maximum A/B player/camera pose delta is `0.0 m`. North uses 530
physics ticks and south 531, both at fixed 60 Hz, with zero player or camera
transform writes after motion start and zero recoveries. Each side contains three
post-draw originals at each `60/45/30/25 m` threshold.

All ten grayscale stills are derived from their saved default-light PNGs. The
verifier loads both images as `L8` and confirms equal `1440x900` pixel buffers;
the grayscale files are not recaptures, crops, or independently re-lit renders.
Every PNG hash, byte count, header, and manifest binding was rechecked. All six
manifests contain relative paths only.

## Source-versus-package boundary

The A/B pixels are truthfully labeled as renders from two exact source
checkouts, not renders from the exported PCKs. The baseline and candidate PCKs
are corresponding sealed artifacts linked by their explicit product hashes;
that linkage alone is not presented as package-render provenance.

I separately launched Godot from `/private/tmp`, directly mounted the one exact
candidate PCK as `--main-pack`, and supplied the external package-contract script
whose hash is frozen above. In that mounted resource graph `res://project.binary`
exists and `res://project.godot` does not. The run exited `0` with:

```text
PASS: mounted Building 1 wing-window reveal candidate PCK is exact at v9 9/213; remap-loaded PCK builders produce B1 13/13/11071 with 528 reveal triangles while D2 ownership/collision remains intact, and authority records the candidate world target 735/959/974/69612/466/466
```

An earlier non-evidentiary invocation addressed the deliberately unexported test
as a `res://` script and Godot reported `File not found` while returning `0`.
That output was discarded; only the successful external-script/direct-mounted-
PCK invocation above supports this audit.

## Runtime and authority invariants

The mounted candidate resolves the Building 1 main wall/roof and separately
accepted tower wall/roof as `13/13/11071` meshes/surfaces/triangles, including
exactly 528 reveal triangles. Wall and roof collision hashes remain respectively
`21d69032bdba73c0406545b0b7d2c8efefd423fe8263815c3edc57bdc3756db5`
and `bb2c36915cba6d9d5f5d1a8239888ef1c913b1e4396eb6ce1cd2145c1a38e337`.

The only world-topology delta is the intended render-only `+360` triangles:
released `735/959/974/69252/466/466` becomes rehearsal
`735/959/974/69612/466/466`; rows, meshes, surfaces, bodies, shapes, navigation,
and collision do not change. D2 1441 remains `8/8/1568` wall plus `1/1/10` roof,
with its wall spray ownership, roof landing ownership, and collision intact.

The mounted registry SHA-256 remains
`26dcf64a34cf92aa7766c60940933190cdb5f9bc595dc23dc2f16fa01752e16c`
at schema 9; the adapter-contract SHA-256 remains
`8c61ea5601ab94852ac593b8658963b52cb5253aae22a2ff109f2e46771caa93`
at API/schema 8. They contain exactly nine accepted physical units out of 213,
eight active runtime adapters, and 17 plans. No authority or frozen D2 bridge was
mutated.

There is no Building 1 reveal candidate packet under
`evidence/first-playable/`, no copied receipt there, and no authoritative
recognition record for this rehearsal. The only durable repository records are
the independent source audit and the two rejection-lineage reviews.

PASS_FOR_B1_REHEARSAL_MECHANICS_ONLY

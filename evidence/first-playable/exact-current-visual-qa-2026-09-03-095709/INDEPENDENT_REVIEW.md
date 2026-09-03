# Independent art and play-evidence review

**Reviewer:** Crash-forensics executor (`/root/crash_forensics`), acting only as independent image reviewer
**Date:** 2026-09-03
**Reviewed scope:** all twelve original `1440x900` PNGs, `capture-manifest.json`, `README.md`, and `checksums.sha256` in this directory
**Product bar:** recognizable Treasure Island and a playable walk/run/jetpack/spray first playable are co-primary outcomes

## Verdict

**PASS_WITH_LIMITATION as bounded source-project visual evidence; NOT_SHOWN as complete first-playable or owner acceptance.**

The set visibly establishes a loaded third-person world, selected continuous-looking ground and shoreline views, the Building 1 public curve, San Francisco/YBI/bridge context, one upright wall tag, and an airborne player. It does not independently establish consistently recognizable Treasure Island at ground level: `02`, `03`, `04`, `05`, and `10` are dominated by generic massing, empty terrain, or coarse vegetation. Nor does it establish the whole playable loop: captures `01`–`10` are disclosed fixed-transform views, while `11`–`12` prove only the public jetpack action through manifest metrics.

The jetpack mechanics evidence is credible, but the released-descent **presentation** is not: frame `12` is still `0.532 m` higher than frame `11`. The manifest explains that the character continued rising from `6.291 m` to `7.173 m` after release before dropping `0.350 m` to `6.823 m`; therefore the still pair cannot visually communicate descent without the manifest.

## Integrity and evidence boundary

- `shasum -a 256 -c checksums.sha256` passed for the README, all twelve PNGs, manifest, relevant source files, and generated-world manifest. Every PNG is `1440x900` and its digest agrees with the capture manifest.
- Pixel evidence supports only what is visible in the selected frames. It does not prove traversal, collision, input origin, receiver eligibility, velocity, or time ordering.
- Manifest evidence supports grounded settlement for `01`–`10`; a real `SprayController` result and identity match for `09`; and a time-connected public-`jetpack` input sequence for `11`–`12` with zero post-input transform writes, `+5.000 m/s` ascent, `-1.500 m/s` capped descent, and zero recovery.
- This is a native Forward+/Metal **source-project** capture. It is not an exported-package run, ordinary keyboard/mouse play, a local-expert identification test, or owner acceptance.

Grades use `PASS`, `PASS_WITH_LIMITATION`, `FAIL`, and `NOT_SHOWN`. Ground/shoreline grades concern visible geometry only; none of them upgrades a fixed viewpoint into movement proof.

## Per-frame review

| Frame | Recognition | Ground / shoreline | Landmark / context | Tag | Jetpack presentation | Pixel finding |
| --- | --- | --- | --- | --- | --- | --- |
| `01-ferry-spawn` | **PASS_WITH_LIMITATION** | **PASS_WITH_LIMITATION** | **PASS_WITH_LIMITATION** | **NOT_SHOWN** | **NOT_SHOWN** | The ferry-side lawn/path/road/shore composition and Building 1/tower ensemble give some place identity, but sparse massing and the generic skyline keep the read dependent on prior knowledge. |
| `02-north` | **FAIL** | **PASS_WITH_LIMITATION** | **NOT_SHOWN** | **NOT_SHOWN** | **NOT_SHOWN** | An enormous repetitive blank wall occupies most of the frame; the ground appears unbroken, but base contact and the intended southward island vista are poorly exposed. |
| `03-center` | **FAIL** | **PASS_WITH_LIMITATION** | **NOT_SHOWN** | **NOT_SHOWN** | **NOT_SHOWN** | The road grid and terrain are present, with abrupt polygon junctions but no visible hole; generic low boxes provide no standalone Treasure Island cue. |
| `04-southwest` | **FAIL** | **PASS_WITH_LIMITATION** | **PASS_WITH_LIMITATION** | **NOT_SHOWN** | **NOT_SHOWN** | The south palm cluster is visible, but a huge blank façade blocks the island view and the coarse teal/black palms do not carry recognition by themselves. |
| `05-east-perimeter` | **FAIL** | **PASS_WITH_LIMITATION** | **NOT_SHOWN** | **NOT_SHOWN** | **NOT_SHOWN** | Unbroken rolling ground is visible, but the frame is almost empty and does not clearly expose the advertised shoreline-side context. |
| `06-building-1-public-curve` | **PASS_WITH_LIMITATION** | **PASS_WITH_LIMITATION** | **PASS_WITH_LIMITATION** | **NOT_SHOWN** | **NOT_SHOWN** | The broad ivory curve, tall central window rhythm, end groups, blue door, and rose bands are readable at player height. Uniform-height massing and sparse openings still prevent an as-built or whole-building claim. |
| `07-horizon-context` | **PASS_WITH_LIMITATION** | **PASS_WITH_LIMITATION** | **PASS_WITH_LIMITATION** | **NOT_SHOWN** | **NOT_SHOWN** | The west-span bridge and SF silhouette are readable across water, but they are low-contrast and a freestanding-looking blank wall consumes the right third of the view. This locates the scene through external context more than island form. |
| `08-ybi-bridge-context` | **PASS_WITH_LIMITATION** | **PASS_WITH_LIMITATION** | **PASS_WITH_LIMITATION** | **NOT_SHOWN** | **NOT_SHOWN** | YBI, its waterline, and the light bridge are clearly present; YBI reads as an elongated ridged mass, though still coarse/smooth, and the bridge is clipped by the frame edge. |
| `09-eligible-wall-tag` | **PASS_WITH_LIMITATION** | **PASS_WITH_LIMITATION** | **PASS_WITH_LIMITATION** | **PASS_WITH_LIMITATION** | **NOT_SHOWN** | A small upright cyan/black tag and `Tag placed` feedback are plainly visible without obvious adjacent-surface bleed. Pixels do not prove eligibility or controller origin; the manifest does. Rejection and movement-resume behavior are not shown. |
| `10-vegetation-south-ground` | **FAIL** | **PASS_WITH_LIMITATION** | **NOT_SHOWN** | **NOT_SHOWN** | **NOT_SHOWN** | The dedicated vegetation view exposes severe angular black palm undersides, bent peach trunks, an abrupt pale-cyan shoreline/overlay edge, and generic distant blocks. No void is visible, but the scene does not yet read plausibly or specifically. |
| `11-jetpack-ascent` | **PASS_WITH_LIMITATION** | **PASS_WITH_LIMITATION** | **PASS_WITH_LIMITATION** | **NOT_SHOWN** | **PASS_WITH_LIMITATION** | The detached shadow and elevated camera/player show an airborne state; the arrival ensemble remains visible. Pixels contain no thrust, pose, trail, or state indicator, so held ascent depends on the manifest's `2.834 m`, `+5.000 m/s`, 46-frame input record. |
| `12-jetpack-released-descent` | **PASS_WITH_LIMITATION** | **PASS_WITH_LIMITATION** | **PASS_WITH_LIMITATION** | **NOT_SHOWN** | **FAIL** | The frame still looks airborne, but it cannot show descent and is higher than `11`. The manifest proves a `0.350 m` drop from a later peak at `-1.500 m/s`; the two pixels-only stills do not. |

## Ranked findings

### Acceptance blockers

1. **Complete playability is not shown.** No frame proves ordinary walk, run, mouse camera, landing/recovery, rejected spray targets, continued movement after rejection, pause/resume, or package input. This is an evidence boundary, not proof those behaviors are broken.
2. **Exact-current ground-level recognition remains unaccepted.** Five regional frames fail a standalone recognition read, and the stronger views rely heavily on one accepted façade plus external skyline/bridge context. Only the owner/local observer can close the intended recognition acceptance.

### Major findings

1. **Representative north/center/southwest/east views are weakly composed for recognition.** `02` and `04` are occluded by blank walls; `05` is largely empty; `03` is generic. These frames demonstrate coverage, not a convincing place.
2. **The descent pair is visually misleading without telemetry.** The later frame is higher, not lower, and there is no jetpack visual language. A peak/release frame followed by a clearly lower same-pose descent frame is needed for pixel evidence.
3. **Near-field vegetation is visibly unfinished.** `10` shows harsh black leaf faces, angular crowns, unnatural trunk shapes, and a hard cyan edge; the same palm issue is visible at distance in `04`.
4. **Large generic/repeating walls dilute both navigation readability and island identity.** This is most damaging in `02`, `04`, `07`, and `09`.

### Minor findings

1. The bright cyan capsule is an acceptable placeholder under the brief, but its size and saturation dominate every composition and provide no walk/run/jetpack state change.
2. The tag is readable but small; one closer oblique would better prove projection, edge containment, and lack of bleed.
3. SF/YBI/bridge context is recognizable but washed out against the flat gray sky; stronger atmospheric separation would improve navigation value without changing geometry.

## What this package can support

- **Recognition:** `PASS_WITH_LIMITATION` for selected Building 1 and regional context, not island-wide or owner recognition.
- **Visible ground/shoreline continuity:** `PASS_WITH_LIMITATION` at the twelve captured poses; no continuous traversal claim.
- **Landmark/context presentation:** `PASS_WITH_LIMITATION` for Building 1, SF, YBI, and bridge.
- **Eligible tag placement:** `PASS_WITH_LIMITATION`; pixels plus manifest support one placement only.
- **Jetpack behavior:** `PASS_WITH_LIMITATION` mechanically from manifest input metrics; ascent presentation is limited and descent presentation fails in the still pair.
- **Overall first-playable acceptance:** **NOT_SHOWN** pending ordinary exact-package play and owner recognition/playability judgment.

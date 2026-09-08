# Building 1 wing-window reveal rehearsal 004 — independent visual hold

Date: **2026-09-08**  
Visual reviewer: **independent bar-raiser; verdict transmitted to `/root` before the interrupted handoff**  
Durable record: **`/root/b1_rejected_lineage_audit`**

## Verdict

Hold the v1 wing-window reveal candidate. Its evidence is technically strong and
the motion is stable, but the new geometry reduces rather than improves facade
believability at the most useful player views. The candidate must not be
promoted, copied to authoritative evidence, or receive recognition credit.

## Exact reviewed evidence

This review binds only to the non-authoritative rehearsal receipt:

| Item | SHA-256 |
| --- | --- |
| `/private/tmp/b1-reveal-rehearsal-004/rehearsal-verification-receipt.json` | `4fc7a1e0d64f23df62c3e919f56a48120c20ab5beeb5aca27548af8b49bb8460` |
| ordered 98-input tree recorded by that receipt | `4af8dd0e395efb798548c710c3c72c99f170a6b22711017a377dab07827e7aaf` |

The reviewed set is all 46 native A/B image pairs: 92 original `1440x900`
PNGs, plus all six manifests. The tree covers those 98 inputs only. No overall
99-file tree is claimed, because the receipt is separately hashed and excluded
from its own input tree.

The receipt labels the pixels honestly as exact-source-checkout renders rather
than exported-PCK renders. It keeps the sealed baseline and candidate PCK hashes
as a separate correspondence claim and requires a direct-mounted package
contract for runtime semantics. It also keeps authority unchanged at v9 `9/213`
and marks the rehearsal non-authoritative, unpromoted, and worth no recognition
credit.

## P0 visual blocker

On both wings, the added reveal geometry reads as opaque near-black backing
cards, gaskets, or drop shadows protruding around the unchanged white frames. It
does not read as wall thickness around punched window apertures. The darkest cue
is exposed around too much of each opening perimeter, so the repeated treatment
becomes an external graphic bracket rather than believable recessed depth.

The problem is clearest in the candidate-versus-baseline pairs for:

- `images/03-north-wing-near-{default,changed,grayscale}.png`;
- `images/05-south-wing-near-{default,changed,grayscale}.png`;
- `images/09-real-spray-blank-wing-pier.png`;
- both wings' `motion/*/30m-*`, and especially `motion/*/25m-*` frames.

The changed-light and grayscale pairs confirm that this is the candidate's
geometry/material response, not an accidental shadow direction or color-only
judgment. The approach sequences are stable—there is no shimmer, depth pop,
z-fighting, or obvious temporal crawl—but decreasing distance makes the external
L-shaped bracket reading stronger. At far and whole-building distances the
candidate gains mainly dark contrast and only marginally readable depth.

## What remains successful

The candidate does not damage the strong central hierarchy. Tower separation,
the protected rear return, supported roof/jetpack landing, real spray receiver,
player scale, and whole-island context all remain legible. The tower and rear
comparators are exact-hash unchanged. Evidence integrity and the
source-versus-package labeling are complete. Those passes do not outweigh the
P0 facade-material blocker.

## Required next discrepancy cycle

Keep darkness inside the perceived aperture. A next bounded rehearsal should use
wall- or trim-toned jamb returns, or restrained side strips whose construction
cannot expose a full black perimeter slab. It should then repeat the identical
A/B poses, two lighting states, grayscale derivations, and north/south motion
routes so the visual change—not a changed camera—is what the next reviewer sees.

HOLD_B1_REVEAL_REHEARSAL

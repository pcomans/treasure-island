# Building 1 entrance-group gap calibration

This packet is a scalar-only A/B quality comparison for the already accepted Building 1 hero. A uses `entrance_group_gap = 0.55` m; B uses the requested literal JSON spelling `0.90`. It grants no new recognition credit and makes no surveyed-coordinate or as-built-fidelity claim.

## What changed

The middle entrance group remains fixed. The nine visual boxes in each outer group (18 total) move outward by 0.35 m, so the three-group ensemble expands from 9.65 m to 10.35 m. Geometry counts, canopy geometry, curved public-front source-chain fit, collision, navigation, spray ownership, roof traversal, materials, and every other config field remain unchanged. There are exactly two separators between the three groups.

The projected separator width is small in the whole-building view: approximately 0.585 px at the roughly 80 m pose for A versus 3.51 px for B. Across the useful 60 m to 25 m motion interval it is approximately 0.75–1.8 px for A versus 4.5–10.8 px for B. These are geometric projections, not a visual verdict.

## Evidence protocol

- Three native 1440×900, 70° FOV, 5.5 m spring-arm stills per stage: a grounded whole-front default-light view, its exact-pose changed-light mate, and a closer entrance view. The whole-front view is a mild oblique, about 14° off normal; it is not claimed as a strong parallel view.
- The entrance view includes a lossless deterministic grayscale derivation. The original color PNG remains authoritative and unmodified.
- One matched normal-forward stock-controller approach per stage. Each useful interval has 529 physics samples at 60 Hz, continuous `move_forward`, zero run/jetpack/recovery, zero player or camera transform writes after input begins, grounded path samples, exact receiver LOS, and identical A/B trajectory data. The three still poses supply the supplemental mild-oblique/parallax check; this bounded pass does not claim a second motion sweep.
- Both MJPEG AVI containers are 1440×900, 337 frames, 33333 μs/frame (about 30.0003 fps). The useful mapped interval is process frames 65–330 / physics frames 131–660. See `avi-container-validation.json`.

## Capture and recovery truth

A and B were captured with the same generator (`b1565b71…`), parent harness, effective runtime dependency hashes, and capture-time registry (`36eef28d…`, ten runtime assets per Building 1 receiver). The scalar was the only capture-input difference.

The B writer closed a complete, hash-stable AVI, but the original finalizer rejected its own JSON read-back because `30.00030000300003` serialized as `30.000300003`. A separately reviewed, hash-pinned one-shot finalizer validated every frozen input, full topology/ownership/path/LOS contract, decoded image dimensions, RIFF/MJPG fields, and the float delta within 1e-9. It then preserved the preliminary B manifest and renamed the closed pending AVI without recapture, pixel rewriting, or transcoding. The preliminary receipt remains as `b-motion-preliminary-unfinalized.json`.

The temporary root display override is preserved byte-for-byte as `capture-window-override.cfg` (SHA-256 `edbc0b9c…`) and has been removed from the product root.

## Post-capture registry closure

After A and B were sealed, the compiler/catalog omission was repaired separately: the public-front config, already consumed directly by the hero adapter, is now the eleventh explicit package-safe runtime dependency for both the Building 1 main receiver and separate observation-tower receiver. The catalog schema requires that exact member, and the runtime loader requires each receiver's exact 11-path set, exact receiver/source mapping, and public-config hash contract. Because the earlier reader could accept a coordinated omission/substitution, the fail-closed compatibility line advances to catalog/runtime `6`, adapter/loader `5`, and compiler `1.5.0`; old and new readers do not silently interoperate. This post-capture hardening did not participate in either capture and did not alter visual/runtime geometry. Exact old/new authorities are in `post-capture-runtime-closure.json`.

## Independent decision and boundary

`INDEPENDENT_VISUAL_BAR_RAISER_REVIEW.md` (SHA-256 `44c0bde8...`) records the independent original-detail **PASS** that promotes B's literal `0.90` m value. The review found exactly three stable groups, one coherent civic canopy ensemble, preserved curved-front fit, and no clipping, float, z-fighting, pop, or identity-harming shimmer. It grants no new building credit; the recognition metric remains 6/213.

Technical contracts prove matched capture conditions, source-chain and receiver binding, deterministic bytes, topology and ownership invariance, container integrity, and that recognition invariant. The signed independent receipt, rather than the builder or these technical contracts, supplies the visual judgment.

The separately preserved `building-1-entrance-group-gap-calibration-rejected-attempt-001-2026-09-04` directory is a failed 1280×800 capture attempt and is explicitly not review evidence.

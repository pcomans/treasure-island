# Navy Chapel Building 187 standalone hero prototype — technical evidence

Date: 2026-09-04  
Target: `w291189336`, Navy Chapel Building 187  
Status: **technical capture valid; recognition and believability pending independent bar-raiser review**

This is a standalone, capture-only prototype. It is not registered, not attached
to `WorldChunkBuilder`, and not accepted as live art. The capture harness loads the
actual world and stock player, records the existing Chapel as `before`, then hides
the existing wall and roof visual/collision together and enables the standalone
wall+roof prototype only for `after`. Each pair reuses the exact same grounded
player pose and camera transform.

## Bounded recognition package

- Exact source identity and horizontal shell remain `w291189336`,
  `building:w291189336:wall`, and `building:w291189336:roof`.
- SSE source runs `9,10` (`16.362 m`) retain the already accepted warm-cream
  field and receive one complete gable/tall divided-window/projecting-entry
  composition.
- Immediately adjacent public-side runs `11,12,13` (`11.829 m`) receive three
  complete tall narrow opening groups. Their count and cadence are reversible
  production inference, not an observed count.
- Runs `0..8,14..33` remain exact source walls in a quiet neutral non-claim
  surrogate, with no openings, plaques, signage, or decorative schedule.
- The inferred main pitched roof, square belfry, pyramidal cap, restrained cross,
  rear structural roof closure, and projecting entry have corresponding
  world-solid collision. Decorative frames/glazing stay noncolliding over exact
  structural collision.
- The accepted Chapel material remains scoped only to exact wall runs `9,10`.
  New cream-colored structural pieces use a separate scalar material explicitly
  marked as an unaccepted, uncalibrated production inference.

No interior, transparent glazing, operable door, surveyed dimension, exact pane
count, rear/private facade, substrate, product, or as-built fidelity is claimed.
No source photograph is stored, copied, or shown.

## Topology

| Item | Measured result |
| --- | ---: |
| Render batches / surfaces | 6 / 6 |
| Exact source wall triangles | 68 |
| Exact source roof triangles | 18 |
| New structural visual triangles | 58 |
| Decorative overlay triangles | 396 |
| Total visual triangles | 540 |
| Static bodies / shapes | 1 / 1 |
| Collision triangles / face vertices | 144 / 432 |
| Navigation / spray-owner nodes | 0 / 0 |
| Deterministic geometry signature | `076e081df86e884f04cf7cb680304c35c64e6f76238de7060528c59097ae5c46` |

Visual batch triangles are: protected exact wall/rear closure `65`, accepted
cream exact runs `4`, inferred cream gable/belfry/entry `25`, neutral roof/cap
`26`, pale trim `360`, and opaque exterior openings `60`.

## Native fixed-camera pairs

All files are 1440×900 native Forward+/Metal frames on Apple M2 using the actual
visible player, 70° FOV, 5.5 m spring arm, generated walkable ground, unchanged
default sun, normal reticle, and no debug labels/panels. The executor inspected
the images at original detail only for blank/corrupt/clipped/overlay failures and
made no recognition or believability judgment.

| Pair | Stage | SHA-256 | Whole-object projected width × height | Exact first LOS |
| --- | --- | --- | --- | --- |
| Whole object | before | `2edeaff94139639da514d049f42f94819881c7a421a4dd24f24b1b305ecd4833` | `0.346 × 0.142` | live wall, run 9 |
| Whole object | after | `522c649d0766e2bd84999f9b21ee569e53911094e280480db31bff5a340fe0ed` | `0.346 × 0.285` | prototype wall, run 9 |
| Oblique approach | before | `8cff88807fa537c8360b6a314e322b84413e2af1561bf48134efd45211eb0733` | `0.308 × 0.115` | live wall, run 9 |
| Oblique approach | after | `b635da683d31f73e3981c1bf21f25690db40640a06771b0e5b5a52425916a9e5` | `0.308 × 0.234` | prototype wall, run 9 |

Camera translation error was exactly `0.0 m` in both pairs. Basis error was
`7.09e-8` and `1.08e-7`; player translation error was `0.0 m`.

## Provenance and review boundary

- Authoritative local packet:
  `discovery/facades/p3_reference_packets/w291189336_navy_chapel_building_187.md`,
  SHA-256 `7eb592503ce8e276c38ef3ecaf7f2d3dd17e1eeb32adbe45d1059c5cb4693330`.
- Frozen exact run map:
  `discovery/facades/BATCH_02_RUN_MAPPING.json`, SHA-256
  `d076ee125168cd3dfe499bc56e94c324019d7ba70bb731b9c23c045ca6759b5f`.
- Exact generated chunk:
  `generated/world/chunks/x_-1__z_2.json`, SHA-256
  `dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce`.
- Independent rejection that defined the smallest repair:
  `evidence/first-playable/p3-existing-live-material-revalidation-2026-09-04/INDEPENDENT_BAR_RAISER_REVIEW.md`,
  SHA-256 `6fbe20f7c23ac6de8eac95dd2f66361d111a694ff739e57bb7c2ea7579855e07`.
- Current survival/identity context comes from the public [TIDA May 2026
  Director's Report](https://media.api.sf.gov/documents/05.13.26_Directors_Report.pdf),
  p. 2. The source packet's September 2025 public-street observation supports
  the visible cue list; Google pixels are not part of this package.

The frozen confusion set is Oasis `w291189918`, Dormitory 369 `w291189926`, and
Food Service Building 368 / nearby California Avenue institutional buildings
(`w34313521` representative source ID).

Reviewer: open all four PNGs at original detail. Decide whether each `after` is
top-1 Navy Chapel against that confusion set from at least two real cues, and
whether its hierarchy/depth is believable at the shown ordinary distance. Do
not infer acceptance from the technical PASS. Treat every vertical dimension,
pane division, and side-window count/cadence as reversible production inference.

## Commands

```text
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --headless --script game/tests/headless_navy_chapel_187_standalone_hero_contract.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/navy_chapel_187_standalone_hero_capture.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --headless --script game/tests/headless_navy_chapel_187_standalone_hero_evidence_contract.gd
```

See `capture-manifest.json` for exact poses, framing, hashes, first-hit details,
runtime context, package pins, and reviewer instructions.

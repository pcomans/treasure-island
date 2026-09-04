# Dormitory 369 standalone five-tier hero — technical evidence

Date: 2026-09-04  
Target: `w291189926`, US Dept of Labor Job Corps Dormitory Building 369  
Status: **technical capture valid; recognition and believability pending independent bar-raiser review**

This is a standalone, capture-only exterior prototype. It is not registered or
attached to `WorldChunkBuilder`, the facade catalog/compiler/registry/loader, or
the live world. For each capture pair, the harness first records the existing
6 m fallback, then hides that fallback wall and roof visual/collision together
and enables the standalone wall+roof prototype. The grounded player pose,
stock camera transform, and lighting are reused within each pair.

## Bounded recognition package

- Exact source identity remains `w291189926`, with wall receiver
  `building:w291189926:wall` and roof receiver `building:w291189926:roof`.
  Every frozen horizontal XZ coordinate, terrain-following wall bottom, and
  source roof-plan coordinate/triangulation is retained.
- Only the mapped public WSW chain receives facade modules: exact terrain-split
  runs `0..5`, source edge `5`, from `(-13.084, 447.399)` to
  `(9.945, 490.791)`, measured `49.124 m`. The already accepted warm field
  remains exact to those six runs only.
- Runs `6..71`—all 66 unmapped runs—remain a lifted exact-XZ shell in a quiet
  neutral non-claim surrogate. They receive no copied opening schedule,
  eyebrows, blue-gray field, labels, or other unsupported detail.
- Five observed occupied tiers are represented as five real facade rows on a
  five-tier mass. The nominal wall height is `5 × 3.0 m = 15.0 m`, with roof
  landing `Y=18.390 m` above the existing nominal base `Y=3.390 m`. The
  `3.0 m` pitch is the project's deterministic convention and lies within the
  earlier low-confidence `2.5–3.3 m` visual estimate; it is not a survey.
- On the mapped chain only, eight inferred columns and five rows alternate
  broad multi-lite and narrow opaque openings. Broad openings receive shallow
  eyebrows. The grounded row adds broad opaque glazing proxies, blue-gray
  panels, and base vents. One shallow blue-gray stair/end volume and one thin
  green eave provide the minimum observed three-part hierarchy.
- Visible wall, roof landing, stair/end, and eave structure share one
  triangle-congruent world-solid collision mesh. There is no hidden 6 m
  collider. Shallow exterior opening/frame/eyebrow/base relief is noncolliding
  over the hero wall collision.

Every unsurveyed height, tier pitch, opening dimension/count/cadence, stair
dimension, eave dimension, scalar material value, and exact placement is marked
as reversible production inference. This package claims no interior,
transparent/operable glazing, occupancy, material product/substrate, opposite
elevation, recessed-wing grammar, entrance design, or as-built fidelity. It
stores and shows no source-reference pixels.

## Measured topology

| Item | Result |
| --- | ---: |
| Render batches / surfaces | 9 / 9 |
| Lifted exact-source wall triangles | 144 |
| Lifted exact-source roof triangles | 32 |
| New structural visual triangles (stair/end + eave) | 24 |
| Decorative exterior-relief triangles | 3,168 |
| Total visual triangles | 3,368 |
| Static bodies / shapes | 1 / 1 |
| Structural collision triangles / face vertices | 200 / 600 |
| Navigation / spray-owner nodes | 0 / 0 |
| Deterministic geometry signature | `a84ce1e27ef0466d58e35ce57352a8eb43cb8f2d20c7530f0c9d24c0b4b1a121` |

The nine visual batches contain: protected lifted wall `132`, accepted warm
lifted wall `12`, neutral lifted roof `32`, blue-gray stair/end `12`, blue-gray
ground panels `48`, green structural eave `12`, green eyebrows `240`, opaque
openings/vents `480`, and frames/multi-lite divisions `2,400` triangles.

## Native fixed-camera evidence

All six files are uncropped 1440×900 native macOS Forward+/Metal frames on
Apple M2, using the actual generated world, visible stock player, physics-grounded
walkable terrain, 70° FOV, 5.5 m spring arm, normal reticle, and no debug labels
or panels. Full entity bounds are in frame. The third pair repeats the oblique
pose under a materially changed sun. The executor checked only for blank,
corrupt, clipped, or overlay-contaminated frames and made no recognition or
believability judgment.

| Pair | Stage | SHA-256 | Projected width × height | Exact first LOS |
| --- | --- | --- | --- | --- |
| Whole object | before | `3fd9f0d6b966b26dc06e3af447bb6c0fd70adba5b003409da37dc6edd1ae5839` | `0.324 × 0.039` | live wall, run 12 |
| Whole object | after | `e0bdb99986f992b436d3d8dea9558d02879ad48886832ffec1e084ab297a2004` | `0.324 × 0.094` | prototype wall, run 12 |
| WSW oblique | before | `08bae25a6b8e62619487be528c21589edcef1429cccd844b18cd3a59ed39eb24` | `0.414 × 0.052` | live wall, run 2 |
| WSW oblique | after | `244f11be2b064c293848eb2ec242c2c8c61d13a59e128b398effab099619f3d2` | `0.414 × 0.127` | prototype wall, run 2 |
| Changed-light WSW oblique | before | `faef68ec106fff1833fee87cb804dd9df1937e5d3a69e9c8c1474ce7e216d257` | `0.414 × 0.052` | live wall, run 2 |
| Changed-light WSW oblique | after | `c06407d48d9ae35c01343966a98acdec031d6b949efec3ec23b33bc1ba910039` | `0.414 × 0.127` | prototype wall, run 2 |

Camera and player translation error is exactly `0.0 m` in every pair. Camera
basis error is at most `1.10e-9`.

## Provenance and review boundary

- Authoritative P3 packet:
  `discovery/facades/p3_reference_packets/w291189926_job_corps_dormitory_369.md`,
  SHA-256 `a43d391239c2fd3ce66b13c39dc56c534253211e7a44a12d512dbe5367b3a9f9`.
- Frozen exact run map: `discovery/facades/BATCH_04_RUN_MAPPING.json`, SHA-256
  `3ec81316f9bdfb6131df55faeabe822b3fdfb2b739b95bd452a50a1d97a29e42`.
- Exact generated source chunk: `generated/world/chunks/x_0__z_1.json`, SHA-256
  `a35f63a877588d198e0e905167968bf9948f4616c16e708a6799d0e6c1bde00a`.
- Frozen source-geometry identity:
  `4ad2f9d3c0e109d194965149b6e73c078e7796d19ec3efdfd8f78df6e9aee3e9`.
- Independent rejection defining this minimum repair:
  `evidence/first-playable/p3-existing-live-material-revalidation-2026-09-04/INDEPENDENT_BAR_RAISER_REVIEW.md`.
- Capture generator SHA-256:
  `38b46b680bfae521f742e51a6b4051b51b2fb3617871d9a623168e75eb43694a`.
- Sealed manifest SHA-256:
  `4834dbed96cdffd93983151332104ae3b8d7c6d5f5c1121b474b405f80fd2d17`.

The frozen confusion set is Advanced Culinary/Dormitory `w34313514`, Food
Service Building 368 `w34313521`, and Oasis `w291189918`.

Independent reviewer: open all six PNGs at original detail and inspect pixels
before labels or manifest. Decide whether each after view is top-1 Dormitory 369
against the frozen confusion set using at least two reference-supported cues,
including the five-tier facade-family cue. Confirm that the stair/end/eave and
five-row broad/narrow/eyebrow/base hierarchy survive the whole-object, oblique,
and changed-light views without relying on hue, address, location, or source ID.
Treat all enumerated dimensions and schedules as reversible production inference;
do not infer an interior or as-built fidelity from the technical PASS.

## Fail-closed future live seam

The standalone factory accepts only the exact matching `w291189926` wall+roof
pair and fails closed on any geometry/topology drift. A future live integration
must intercept both records before generic visual or collision creation, remove
the fallback wall/roof representation completely, and recreate explicit spray
ownership on validated hero wall collision. It must never overlay these visuals
on a retained 6 m collider or attach only one member of the pair.

## Commands

```text
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --headless --script game/tests/headless_dormitory_369_standalone_hero_contract.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/dormitory_369_standalone_hero_capture.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --headless --script game/tests/headless_dormitory_369_standalone_hero_evidence_contract.gd
```

See `capture-manifest.json` for exact poses, pair transforms, runtime context,
package pins, per-image metrics, first-hit bindings, and reviewer instructions.

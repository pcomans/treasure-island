# Exact-current visual repair evidence — 2026-09-03

This is the frozen canonical native Forward+/Metal source-project capture for the bounded visual-repair round. It is not an exported-package run and does not establish independent semantic-art or owner acceptance.

## Source binding

- Git branch: `main`
- Git HEAD and `origin/main`: `08219c9e11c8bd6ce681e48860bb906db07e82f7`
- HEAD tree: `a02b1c5b645c02d60a18d01e89f6e2f71bb7e04f`
- Capture-affecting source diff SHA-256: `7c6def71e9869852830bf1f969917dd11e3c766173fe24c218a5920051844ba6`
- Exact diff-hash command: `git diff --binary HEAD -- project.godot game/scripts/main.gd game/scripts/world/vegetation_builder.gd game/tests/rendered_visual_evidence_capture.gd | shasum -a 256`
- The manifest records the at-run SHA-256 values of those four executable source files. `checksums.sha256` additionally pins the unchanged regional anchor source and frozen generated-world manifest.

`project.godot` and `game/scripts/main.gd` contain the separately authorized startup repair already present at round start. This round changes `game/scripts/world/vegetation_builder.gd` and `game/tests/rendered_visual_evidence_capture.gd`; no frozen OSM/generated geometry, facade receiver, Building 1, collision, navigation, or gameplay-controller source was changed.

## Exact commands and results

Pinned executable:

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --version
# exit 0; 4.7.2.stable.official.ed1daf0bf
```

Focused syntax/import:

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --editor --quit
# exit 0

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --check-only --script game/tests/rendered_visual_evidence_capture.gd
# exit 0
```

Canonical native capture:

```sh
/usr/bin/time -p .tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot \
  --path . \
  --max-fps 60 \
  --rendering-method forward_plus \
  --rendering-driver metal \
  --audio-driver Dummy \
  --resolution 1440x900 \
  --script game/tests/rendered_visual_evidence_capture.gd \
  -- --visual-evidence-output=evidence/first-playable/exact-current-visual-repair-2026-09-03-104510
# exit 0; real 45.56 s; Metal 4.0 / Forward+ / Apple M2; 12 ordered captures; final PASS
```

## Objective changes and invariants

- Imported vegetation meshes/materials are deep-duplicated for runtime use. All curated vegetation `StandardMaterial3D` surfaces are forced non-metallic with roughness at least `0.82`; foliage/grass is two-sided. Palm foliage and wood retain their source roles with a reversible muted green/brown KISS palette.
- The live palm contract passed for `7` batches / `8` surfaces: `5` foliage and `3` wood. The frozen `124` placements, `15` assets, `19` total batches, and `20,178` rendered vegetation triangles are unchanged.
- Generated record-owned topology remains `729 meshes / 739 surfaces / 48,389 triangles`; exact-current total runtime topology remains `1,278 meshes / 1,288 surfaces / 55,067 triangles`; collision remains `466` bodies / `466` shapes.
- Capture-only ordinary-play reframes preserve the shared traversal anchors and do not claim traversal. `02` targets the accepted `building:w34313564:wall` receiver from a north-island grounded position; `03` targets accepted `building:w34313520:wall`; `04` faces the existing southwest road/lawn approach toward the south palm rows; `05` targets accepted Building 3 receiver `building:w34313540:wall`. Physics rays confirmed the three named receiver sightlines.
- `10` is grounded at `(-300.000, 3.047, 230.000)` outside the planting bed. It intentionally does not hide the existing pale-cyan overlay boundary; that remaining geometry presentation is outside this material/capture repair.
- `11` and `12` remain one time-connected public `jetpack` input sequence with no player-transform writes after input begins. Held ascent reaches `y=6.291 m`, `+5.000 m/s`, and `2.834 m` rise. After release, frame `12` reaches `y=5.223 m`, `1.068 m` below frame `11`, after `1.950 m` of capped descent over `76` capped-descent physics frames at `-1.500 m/s`; recovery delta is zero and maximum observed step is `0.167 m`.

All twelve originals are `1440x900`; their ordered IDs, per-image SHA-256 values, grounded/input metrics, and source identity are in `capture-manifest.json`. `checksums.sha256` independently pins the retained files. Static captures `01`–`10` remain disclosed fixed-reset views with `movement_proof: false`. No semantic image-quality grade was made by the implementing executor; independent review must inspect the original PNGs.

Two earlier noncanonical directories remain for process traceability: `exact-current-visual-repair-2026-09-03-104116` stopped after frame `09` when an incorrect new terrain-elevation expectation rejected frame `10`; `exact-current-visual-repair-2026-09-03-104322` completed but was superseded after objective inspection showed its frame-10 player anchor inside the overlay presentation area. Neither is the retained review target.

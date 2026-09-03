# Exact-current source-project visual QA — 2026-09-03

This retained set is a native Forward+/Metal capture of the exact current source project. It is not an exported-package run and does not establish owner or independent semantic-art acceptance.

## Source binding

- Git HEAD: `08219c9e11c8bd6ce681e48860bb906db07e82f7`
- HEAD tree: `a02b1c5b645c02d60a18d01e89f6e2f71bb7e04f`
- Capture-affecting source diff SHA-256: `6e271ccb371c6bf7ffa52bb8452553adb1bba8562a83a12b9a26b55293f6c238`
- Exact diff-hash command: `git diff --binary HEAD -- project.godot game/scripts/main.gd game/tests/rendered_visual_evidence_capture.gd | shasum -a 256`
- The capture manifest independently records the at-run SHA-256 values of `project.godot`, `game/scripts/main.gd`, and the capture harness. The checksum ledger also pins those files and the generated-world manifest.

The existing `project.godot` and `game/scripts/main.gd` modifications are the separately authorized startup repair; `game/tests/rendered_visual_evidence_capture.gd` is the capture-only change from this round. Other documentation and untracked test/evidence changes in the shared worktree are outside the executable source-diff fingerprint above.

## Commands and results

Pinned executable version:

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --version
# 4.7.2.stable.official.ed1daf0bf
```

Parser and import gates:

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --check-only --script game/tests/rendered_visual_evidence_capture.gd
# exit 0

.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --editor --path . --quit-after 1
# exit 0; bounded quit emitted `WARNING: Scan thread aborted...`
```

Single native capture:

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot \
  --path . \
  --max-fps 60 \
  --display-driver macos \
  --rendering-method forward_plus \
  --rendering-driver metal \
  --audio-driver Dummy \
  --resolution 1440x900 \
  --script game/tests/rendered_visual_evidence_capture.gd \
  -- --visual-evidence-output=evidence/first-playable/exact-current-visual-qa-2026-09-03-095709
# exit 0; Metal 4.0 / Forward+ / Apple M2; 12 ordered captures; final PASS
```

## Objective evidence boundary

- Twelve original `1440x900` PNGs exist with distinct ordered IDs and SHA-256 values recorded in `capture-manifest.json` and `checksums.sha256`.
- The manifest records generated record-owned topology of `729 meshes / 739 surfaces / 48,389 triangles` separately from exact-current total runtime topology of `1,278 meshes / 1,288 surfaces / 55,067 triangles`.
- Static captures `01`–`10` disclose a fixed-transform-then-physics-settle scenario reset, record grounded/recovery state, and explicitly set `movement_proof: false`; they do not claim traversal.
- Captures `11` and `12` are one time-connected public-`jetpack`-action sequence after the fixed ferry settlement. The harness records zero player-transform writes after input began, held ascent of `2.834 m` at `+5.000 m/s` over `46` physics frames, released capped descent of `0.350 m` at `-1.500 m/s` over `47` physics frames, zero recovery delta, and maximum observed step `0.167 m`.
- The eligible-wall frame was produced after one real `SprayController` placement and records the selected receiver/tag identity.
- All twelve images passed only objective non-empty, dimensions, sampled-color/luminance, pause-overlay, grounding where applicable, and scenario-specific invariant gates. No semantic image-quality judgment was performed in this executor round; independent review must inspect the original PNGs rather than a contact sheet.

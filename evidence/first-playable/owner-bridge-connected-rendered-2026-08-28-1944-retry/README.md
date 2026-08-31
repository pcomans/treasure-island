# Bridge-connected skyline — rendered evidence

This is the current source-project Forward+/Metal evidence for the enlarged, geographically corrected San Francisco billboard. The successful warm-render retry completed all 12 deterministic frames and exited `0` on the local Apple M1 Pro with Godot `4.7.2.stable`.

## Result

- **Placement accepted by project lead:** `07-horizon-context.png` shows the western suspension span flowing into the San Francisco city mass instead of pointing 64.97 degrees away from it.
- **Scale accepted by project lead:** the active quad is `3900x600 m` at `(-1875,264.85,4306.4)`, versus the historical `1950x300 m` at `(-2500,132.5,750)`. Its projected bounds are `633.792x97.506 px`, or `44.013%` of the `1440x900` viewport width.
- The position lies 250 m beyond the reconstructed western-span San Francisco endpoint. The raised center preserves the silhouette's alpha baseline at approximately water level.
- The western bridge transform, active one-color texture, billboard material, render layer, shadowless/no-collision behavior, and all gameplay contracts are unchanged.
- Full real-main-scene integration also exited `0`, including grounded first reveal, movement, jetpack, recovery, tagging, generated physics, and fail-closed reload.

## Key files

- `07-horizon-context.png` — combined bridge/skyline judgment; SHA-256 `e50cf5b89db9cf4c345a786f562ce4462f679d9291223e1b684c7850264da66b`.
- `01-ferry-spawn.png` — ordinary ferry spawn context; SHA-256 `99f2f7571bb3dee14e9f2b7e11cfa9e4512e51638c5b37c245c492a9ad58c85f`.
- `08-ybi-bridge-context.png` — opposite YBI/context-isolation view; SHA-256 `af870a9fa1079b208aff80ecb227eb0bdba0cd3de8df7a1b8934027da196990f`.
- `capture-manifest.json` — complete camera, geometry, grounding, resource, and per-frame facts; SHA-256 `cff89c5d66a211a3485706f0864a2ea7466139c1d74d8a3b8b6b1bc0ed7c1aa0`.

## Reproduction

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot \
  --path . \
  --display-driver macos \
  --rendering-method forward_plus \
  --rendering-driver metal \
  --audio-driver Dummy \
  --resolution 1440x900 \
  --script game/tests/rendered_visual_evidence_capture.gd \
  -- --visual-evidence-output=evidence/first-playable/owner-bridge-connected-rendered-2026-08-28-1944-retry
```

The immediately preceding cold-render attempt at `owner-bridge-connected-rendered-2026-08-28-1939` reached the grounded ferry scene but saved no frame and failed its 180-second watchdog. It is retained as a failed attempt and is not evidence of a pass; this complete retry is authoritative.

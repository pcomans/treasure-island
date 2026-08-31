# Hawkins façade in-engine review

Date: 2026-08-29

## Result

**Pass for this bounded exact-wall texture experiment.** The generated Hawkins wall `building:w1249412093:wall` alone receives the opaque albedo-only runtime override `hawkins_77_bruton_facade_experiment`. At the fixed ground-level review pose, the selected material reads as two physical stories with a credible alternating window rhythm and materially improves the shared-plaster baseline. No visible UV tear, sharp phase jump, stretching, or incoherent tile boundary appears along the reviewed front and corner segments.

The generated wall and collision were not edited. The focused contract proves the original `building_wall` surface material, source key `w1249412093`, collision triangles/layers, and spray-receiver metadata remain intact under the visual override; the roof and every other wall remain unoverridden.

## Exact material scale

- Selected albedo: `res://game/resources/textures/world/generated/77_bruton_facade_albedo_v1.png`
- Albedo SHA-256: `1cf8e3091469f92b28211c5b212fd1e1cc34fb1aaadc1b4a098e856481966e9f`
- Visible content per square bitmap: `2 bays × 2 stories`
- Effective module: `3.8 m/bay × 3.0 m/story`
- Full bitmap repeat: `7.6 m × 6.0 m`
- Generated wall UV convention: U and world Y are stored in tenths of a meter.
- Runtime transform: `uv1_scale = (1.3157895, -1.6666667, 1.0)` and, for the pinned `10.274 m` wall top, `uv1_offset = (0.0, 1.7123333, 0.0)`.
- Surface response: white untinted albedo, metallic `0.0`, roughness `0.86`, opaque back-face culling, anisotropic mipmapped repeat; no generated or borrowed normal, roughness, height, or transparency map.

The negative V scale keeps the image top at the wall top. One complete vertical tile covers the current `6.0 m` generated wall, which is why the retained frame visibly contains two window rows. The superseded interpretation that treated the full bitmap as `3.8 m × 3.0 m` would have produced four rows on this wall and is not the retained capture.

## Fixed review pose and provenance

- Player position: `(-113.890999, 4.498565, 399.096008)`
- Player yaw: `-2.685995 rad`
- Camera pitch: `0.0172205 rad`
- Camera position: `(-116.310646, 6.403856, 394.157715)`
- Camera target: `(-94.091003, 7.274000, 439.506012)`
- Camera target error: `0.005463 px` from viewport center
- Ground support: `land:w26767313:x_-1__z_1`; physics-grounded at `4.498550 m`
- Renderer: Forward+/Metal on Apple M1 Pro (Apple7), Godot `4.7.2-stable (official)`
- Generated content SHA-256: `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`
- Generated manifest SHA-256: `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`

The capture manifest records the current `2 × 2` module and `7.6 m × 6.0 m` repeat. Its full baseline and selected frames were written after the final scale retune. The two detail images are exact pixel crops (`1040×300+200+300`) of those full `1440×900` frames; a pixel-difference check returned mean and maximum difference `0` for both pairs.

## Retained images

- Authoritative selected view: [`02-selected-hawkins-facade.png`](02-selected-hawkins-facade.png), `1440×900`, SHA-256 `6041e1f02d4ecb831b23df86e6a4b2f0936cc15c7a0f9b2bf689d98fbc125b86`
- Selected detail: [`03-selected-hawkins-facade-detail.png`](03-selected-hawkins-facade-detail.png), `1040×300`, SHA-256 `79ec4eaa1f5bac5f4e7b756337b95210327ef8c771a03329bfb0c60c89444e70`
- Shared-plaster baseline: [`01-baseline-shared-plaster.png`](01-baseline-shared-plaster.png), `1440×900`, SHA-256 `4b079a7b9dc6d2fbd65d37e1ffd9c71bc2fd2fca3f7d9b5ee6cb048aeaaa31b3`
- Baseline detail: [`04-baseline-shared-plaster-detail.png`](04-baseline-shared-plaster-detail.png), `1040×300`, SHA-256 `17031587250f8b7051f5371994d0de0078fbbe448e533b8d5d3aaafe50c755ab`
- Machine-readable pose and identity: [`capture-manifest.json`](capture-manifest.json)

## Reproduction and verification

Run from the project root with the pinned project-local Godot binary. The source capture command writes the two full frames and `capture-manifest.json`; the retained detail files are review-only exact crops.

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot \
  --path . \
  --display-driver macos \
  --rendering-method forward_plus \
  --rendering-driver metal \
  --audio-driver Dummy \
  --resolution 1440x900 \
  --script game/tests/hawkins_facade_capture.gd
```

The final bounded source verification was:

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --editor --path . --quit
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_scene_parse.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_world_material_contract.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_hawkins_facade_contract.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/full_runtime_integration.gd
```

All five commands exited `0`. The focused test accepted the exact wall, asset hash, `3.8 m/bay × 3.0 m/story` effective scale, cached override isolation, and unchanged generated/collision/source/spray contracts. Scene parse accepted all four gameplay scenes; the shared-material test accepted all eleven Poly Haven semantic materials; full runtime loaded `38` chunks and `729` records, exercised grounded movement, jetpack, recovery, camera, and spray, and exited cleanly. The restricted-process log-rotation and macOS CA-certificate warnings are known non-fatal environment warnings.

## Limitations

- The frozen OSM record currently produces only a `6.0 m`, two-story Hawkins mass. The owner's reference appears taller, but height or geometry remodeling was explicitly outside this experiment.
- Generated foundation subdivision restarts U at each wall segment. The reviewed front and corner remain coherent, but a different close-up angle can expose small cadence changes where a segment restarts; this experiment does not replace continuous-perimeter UV remeshing.
- This is a stylized albedo, not a physically complete façade set. Window depth, corrugation relief, normal/roughness maps, and unique doors or ground-floor details are intentionally absent.
- No app was exported, packaged, or launched interactively in this round. The retained private Mac app therefore predates this source-only Hawkins material experiment.

# `w34313564` one-door exact-receiver calibration correction

Status: `ready_for_independent_corrected_calibration_review_not_self_accepted`

This is the single correction authorized by `W34313564_EXACT_MODULE_CALIBRATION_ART_REVIEW.md`. It changes only the detached calibration location of `CAL-SSE-PDOOR-01`:

```text
before: SSE-EAST-RETURN / run 6 / face-chain center 30.0 m ±4.0 m
after:  SSE-CENTRAL / run 7 / face-chain center 47.5 m ±4.0 m
```

The corrected world anchor is `(55.858936, -612.345596)` in XZ. Its complete `1.9 m` nominal module width plus the ±4 m center envelope stays wholly inside run 7. The placement remains explicitly a `stylized/reference-derived production inference`, not an observed coordinate, measured error bar, cadence, or real opening-count claim.

Machine comparison against predecessor manifest SHA-256 `c664d7e0cae794f9d5be979af89c40a4f65096b29b7f2b14e8032271c2209221` proves the other four placement dictionaries are unchanged:

- `CAL-SSE-HWIN-01`: run 8 at 68.0 m;
- `CAL-ENE-HWIN-01`: run 12 at 18.0 m;
- `CAL-NNW-PDOOR-01`: run 16 at 32.0 m;
- `CAL-NNW-HWIN-01`: run 17 at 54.0 m.

The detached geometry helper remains byte-identical at SHA-256 `b49b8c20fbbe40f2728c0acadf8d53f0593856091e6df897a613d4f2f8680b71`. The focused contract now intersects every placement with the predeclared motif-specific bounds in `batch_06_prototype_registry.json`, preventing a broad face observation from widening a module's narrower legal run group.

## Fresh evidence

Two fresh native Godot 4.7.2 Forward+/Metal images were captured at 1440×900 on Apple M1 Pro:

1. `01-close-corrected-sse-pdoor.png` — corrected tan door, grounding, complete frame/leaf, shallow relief, and continuous host wall;
2. `02-ordinary-corrected-sse-layout.png` — corrected run-7 door and unchanged run-8 HWIN remain separately readable at ordinary player distance.

Both frames explicitly label the placement as stylized/reference-derived production inference and zero-live-attachment. The executor inspected them only for evidence validity: visibility, grounding, motif completeness, host continuity, tangent/outward transform, separation, camera distance, and lack of collision or facade backing. Artistic acceptance is not claimed.

The seven predecessor images and predecessor capture manifest remain untouched in `evidence/first-playable/batch-06-w34313564-module-calibration-2026-08-30/`.

## Noninterference

- Five detached modules still comprise 34 render-only meshes, zero module-owned field meshes, zero collision/navigation/spray nodes, and zero runtime attachment.
- Receiver child count remains `2 → 2` while the capture-only overlay exists.
- Runtime remains 729 meshes, 736 surfaces, 48,389 triangles, and 466 collider pairs.
- Accepted tan runs `5..9` and pale runs `10..19`, their material bytes, placeholder runs `0..4`, generated data, massing, foundations, terrain, collision, navigation, spray, and all other buildings remain unchanged.
- Current accepted-material helper SHA-256 is `18d3cdd6cf29349ba8b00283b4e679cd079c176adb24a32cae7f521c7d88a083`; the predecessor manifest truthfully retains capture-time SHA-256 `8fd1d899cf658f84a5044597e1194d6d0450b74b00281b73ad9b1c91914b21d0`.

## Commands

```text
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --headless --editor --quit --audio-driver Dummy
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --headless --check-only --script game/tests/w34313564_module_calibration_correction_capture.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --headless --audio-driver Dummy --script game/tests/headless_w34313564_module_calibration_contract.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/w34313564_module_calibration_correction_capture.gd
```

The broad scripts and exact results are listed in `verification-results.txt`. Renderer, camera, resolved transform, provenance, predecessor linkage, and image hashes are in `capture-manifest.json`.

## Remaining limitations

- Exact real-world opening coordinates, total count, and cadence remain unknown.
- The corrected door is a bounded calibration exemplar and remains ineligible for live integration without separately accepted coordinate evidence.
- NNW remains partially occluded; WSW/runs `0..4`, plinth, pipes/vents, eave, access geometry, and unknown details remain blocked.
- Whole-building resemblance remains reference-blocked.


# `w34313564` detached exact-receiver module calibration

Status: `ready_for_independent_exact_receiver_module_calibration_review_not_self_accepted`

This immutable evidence set places five capture/test-only exemplars over the existing controlled exact-run field trial for receiver `building:w34313564:wall`. The overlay is parented to the capture scene, not the receiver or runtime builder. It does not change lifecycle state, generated geometry, massing, collision, navigation, spray, or gameplay.

## Exact bounded layout

| Calibration exemplar | Motif | Observed face | Host field | Mapping | Anchor run | Chain center | Horizontal uncertainty |
|---|---|---|---|---|---:|---:|---:|
| `CAL-SSE-PDOOR-01` | `W34313564-PDOOR` | SSE | tan | SSE east return | 6 | 30.0 m along runs 5..9 | ±4.0 m, remaining wholly on run 6 |
| `CAL-SSE-HWIN-01` | `W34313564-HWIN` | SSE | tan | SSE central | 8 | 68.0 m along runs 5..9 | ±4.0 m, remaining wholly on run 8 |
| `CAL-ENE-HWIN-01` | `W34313564-HWIN` | ENE | pale | ENE end | 12 | 18.0 m along runs 10..13 | ±4.0 m, remaining wholly on run 12 |
| `CAL-NNW-PDOOR-01` | `W34313564-PDOOR` | NNW | pale | NNW outer | 16 | 32.0 m along runs 14..19 | ±4.0 m, remaining wholly on run 16 |
| `CAL-NNW-HWIN-01` | `W34313564-HWIN` | NNW | pale | NNW outer | 17 | 54.0 m along runs 14..19 | ±4.0 m, remaining wholly on run 17 |

The count is exactly three HWIN and two PDOOR exemplars. It is a face-role/host-color calibration matrix, not an assertion that the real building has five openings or that these are observed real-world coordinates. No period, repeated cadence, or door/window sequence is inferred.

The HWIN vertical assumption is a `0.70 m` top gap with a reversible `0.40..1.10 m` range. The PDOOR base assumption is the run-interpolated terrain/foundation base plus `0.08 m`, with a reversible `0.00..0.18 m` clearance range. Local X follows each wall run tangent, local Y is world up, and local Z is the outward wall normal.

## Receiver and motif ownership

- The existing tan field remains the sole non-opening wall owner on exact runs `5..9`; the pale field remains the sole non-opening wall owner on exact runs `10..19`.
- HWIN and PDOOR own only complete frame/glazing or frame/door-leaf geometry. They own zero facade-colored backing, surround, or field meshes.
- The five detached instances contain 34 shallow render meshes, zero collision nodes, zero navigation nodes, zero spray nodes, and no live receiver attachment.
- Receiver child count is `2 → 2` before/after overlay construction. Runtime stays at 729 meshes, 736 surfaces, 48,389 triangles, and 466 collider pairs.
- Placeholder/protected runs `0..4` receive no modules. A run with index `20` does not exist in the zero-based 20-run receiver and is explicitly rejected.

## Evidence views

All seven PNGs are fresh native Godot 4.7.2 Forward+/Metal captures at 1440×900 on Apple M1 Pro:

1. close tan HWIN;
2. close pale PDOOR;
3. ordinary SSE tan layout;
4. ordinary NNW pale layout;
5. changed-light oblique ENE pale HWIN;
6. pale ENE→NNW orientation corner at runs `13→14`;
7. tan SSE→pale ENE host-field boundary at runs `9→10`.

The executor inspected the set only for evidence validity: target visibility, complete motifs, host roles, orientation, shallow depth, camera diversity, and boundary coverage. No artistic acceptance is claimed.

## Commands

Editor/import and focused checks:

```text
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --headless --editor --quit --audio-driver Dummy
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --headless --check-only --script game/tests/w34313564_module_calibration_capture.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --headless --audio-driver Dummy --script game/tests/headless_w34313564_module_calibration_contract.gd
```

Native capture:

```text
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/w34313564_module_calibration_capture.gd
```

Broad checks use the same headless Godot prefix with the scripts listed in `verification-results.txt`, followed by `git diff --name-only -- generated` and `git diff --check`.

Current-state maintenance after this capture promoted the same exact Batch 06 run/material scopes to accepted-with-limitation metadata without changing visuals or topology. The accepted-material aggregate gate now passes against inventory SHA-256 `41fd4b1cdc98b31b33801decb02a1303e9d1b6ee48e86214a90e52656f9a8542` and current helper SHA-256 `18d3cdd6cf29349ba8b00283b4e679cd079c176adb24a32cae7f521c7d88a083`. The immutable predecessor capture manifest correctly retains its capture-time helper SHA-256 `8fd1d899cf658f84a5044597e1194d6d0450b74b00281b73ad9b1c91914b21d0` and historical status terminology.

## Preserved blockers and limitations

- Exact real-world opening coordinates, total opening count, and cadence are not observable from the approved evidence.
- NNW detail is partially occluded. The placements there are reversible face-role exemplars only.
- WSW and runs `0..4` remain unobserved/protected and module-free.
- Plinth vertical extent, pipe/vent locations, eave, ramps, stairs, rails, landings, yard objects, access geometry, and unknown details remain excluded.
- Live attachment, lifecycle acceptance, and whole-building resemblance remain blocked pending independent review and better exact opening evidence.

The authoritative parameters, resolved transforms, camera poses, renderer details, and image hashes are in `capture-manifest.json`.

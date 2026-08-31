# `w34313515` detached exact-receiver BAY calibration

Status: `ready_for_independent_exact_receiver_module_calibration_review_not_self_accepted`

This package places four capture/test-only exemplars of the already accepted standalone `W34313515-BAY` motif over the existing accepted pale field on receiver `building:w34313515:wall`. BAY is classified as a complete `module_atlas` motif: one three-tier horizontal-window group with complete frames, mullions and glazing. It is not a seamless wall tile and it owns no pale facade field.

The overlay is parented to the capture scene, never to the receiver or runtime builder. It changes no lifecycle state, live scene, accepted material field, generated data, massing, collision, navigation, spray ownership, or gameplay.

## Exact bounded placement table

| Placement | Side / region | Exact ordered run chain | Along-chain center and calibration envelope | Anchor | World wall anchor XZ | Evidence / survey status |
|---|---|---|---|---|---|---|
| `CAL-WSW-BAY-01` | WSW / observed outer elevation | `0,1,2,3,4,5,6,7,8` | `6.0 m ±1.2 m` (`4.8..7.2 m`) | run `0`, fraction `0.501288` | `(-120.705255, 240.630602)` | `production_inference`; coordinate and count are stylized reference-derived inference, not surveyed; cadence unknown/not inferred |
| `CAL-WSW-BAY-02` | WSW / observed outer elevation | `0,1,2,3,4,5,6,7,8` | `71.5 m ±3.0 m` (`68.5..74.5 m`) | run `6`, fraction `0.508434` | `(-89.910747, 298.440187)` | `production_inference`; coordinate and count are stylized reference-derived inference, not surveyed; cadence unknown/not inferred |
| `CAL-NNW-BAY-01` | NNW / observed outer elevation | `43,44,45,46,47` | `14.0 m ±3.0 m` (`11.0..17.0 m`) | run `44`, fraction `0.496579` | `(-76.351908, 210.202666)` | `production_inference`; coordinate and count are stylized reference-derived inference, not surveyed; cadence unknown/not inferred |
| `CAL-NNW-BAY-02` | NNW / observed outer elevation | `43,44,45,46,47` | `55.5 m ±3.0 m` (`52.5..58.5 m`) | run `47`, fraction `0.504245` | `(-112.978327, 229.715622)` | `production_inference`; coordinate and count are stylized reference-derived inference, not surveyed; cadence unknown/not inferred |

Every full `6.2 m` nominal module width plus the declared center envelope stays wholly within its one named accepted/mapped run. The envelope is a reversible calibration range, not a measured error bar. Four instances are a deliberately small two-side exemplar layout, not a claim that the real building has four bays.

## Receiver and motif contract

- Existing accepted field: `W34313515-MAT-PALE` remains the sole non-opening owner on exact runs `0..8` and `43..47`, totaling `165.100 m`.
- BAY dimensions remain reversible unmeasured proof assumptions: nominal `6.2 × 10.2 m`; three `5.1 × 1.72 m` openings at `3.15 m` tier spacing; center `5.35 m` above the interpolated run base.
- Each instance has 21 shallow render meshes, for 84 total; zero field/backing meshes, collision nodes, navigation nodes, spray nodes, or runtime attachment.
- Local X follows the wall-run tangent, local Y is world up, and local Z is the outward wall normal. Maximum wall-to-front depth is bounded to `0.18 m`.
- Receiver child count remains `2 → 2` while the capture-only overlay exists. Loaded world topology remains `729 records / 763 meshes / 770 surfaces / 48,797 triangles / 466 collider pairs`.

## Evidence views

All six PNGs are fresh native Godot 4.7.2 Forward+/Metal captures at `1440 × 900` on Apple M1 Pro:

1. close complete WSW BAY on run `0`;
2. close complete NNW BAY on run `44`;
3. ordinary gameplay-height WSW building context for run `6`;
4. ordinary gameplay-height NNW context showing both NNW exemplars;
5. ordinary wrap-corner multi-side context showing NNW run `47` and WSW run `0`, with the farther WSW exemplar also visible;
6. changed-light oblique WSW view of run `6`.

The executor inspected the final set only for evidence validity: target visibility, complete three-tier motifs, accepted host continuity, shallow transforms, ordinary-height context, changed light, and multi-side coverage. No artistic acceptance is claimed.

## Reproduction

```text
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --headless --editor --quit --audio-driver Dummy
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --headless --check-only --script game/tests/w34313515_module_calibration_capture.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --headless --audio-driver Dummy --script game/tests/headless_w34313515_module_calibration_contract.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/w34313515_module_calibration_capture.gd
```

The proportional existing regression commands and exact results are recorded in `verification-results.txt`. Renderer, camera, placement, resolved transform, source, topology and image hashes are in `capture-manifest.json`.

## Verdict separation and remaining limits

| Scope | Status |
|---|---|
| Standalone BAY motif | Previously independently accepted; unchanged |
| This detached exact-receiver placement calibration | Ready for independent art review; not self-accepted |
| Exact surveyed placement, count or cadence | Unknown / not surveyed / not inferred |
| Live attachment or lifecycle promotion | Blocked; zero instances on the live receiver |
| Whole-building resemblance | Reference-blocked; no claim |

ENE, SSE, re-entrant/short facets and runs `9..42` have no eligible BAY placement in this study. `W34313515-VRECESS` stays reference-blocked and unbuilt. Lower-region ownership, doors, entry grammar, roof/recess depth, massing, collision, navigation and spray roles remain excluded.

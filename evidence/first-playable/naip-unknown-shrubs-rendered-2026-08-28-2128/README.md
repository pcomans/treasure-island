# NAIP unknown-shrub rendered checkpoint

Date: 2026-08-28

This complete `1440×900` Forward+/Metal run verifies that the current source world with all `22` fixed NAIP `unknown` annotations loads and renders successfully on the Apple M1 Pro. The run captured all twelve established views and exited `0`.

## Bound identity

- Generated content SHA-256: `fc80e6dcc8a4717be015115e922cb95f70b353e5f8bb0c561bf094d113887832`.
- Manifest file SHA-256: `eb1bb456d9b9d65483880816cd549db82a495cbe9b05862b08a3f1d1c0bf974a`.
- Vegetation: `124` placements, including `22` fixed-location `naip_unknown_shrubs`; `15` approved assets, `19` visual-only MultiMesh batches, and zero added collision.
- Every grounded regional capture settled at `0.000–0.001 m` clearance.

## Visual verdict and limit

The established island/context views remain coherent after integration: no new terrain, road, foundation, player, skyline, bridge, YBI, or water defect is visible. The new shrubs are present in `10-owner-aerial-east.png`, but that broad camera reduces them to small distant marks. It proves that the layer renders, not that the row has good player-height scale or composition. A dedicated view along the actual annotation row is required for that judgment and will be captured with the next visual-pavement rerender.

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
  -- --visual-evidence-output=evidence/first-playable/naip-unknown-shrubs-rendered-2026-08-28-2128
```

The authoritative per-frame camera, grounding, SHA-256, color, and context facts are in `capture-manifest.json`.

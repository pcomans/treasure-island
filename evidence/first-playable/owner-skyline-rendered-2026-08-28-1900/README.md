# Owner-photo San Francisco skyline rendered evidence

Date: 2026-08-28  
Renderer: Godot 4.7.2, Forward+, Metal, Apple M1 Pro  
Generated world content: `1c9fd3ec5a814e48a696267e9ec3b0318543b8b84df407baee6d18b164b03aeb`

## Result

**PASS for source-project rendering and context isolation.** The complete bounded 12-frame harness exited `0` in 23.64 seconds. All grounded/elevated/vegetation/tag/context views were written at `1440x900`; the generated world, physics counts, current vegetation, ferry transform, tag identity, pause state, and context collision gates remained unchanged.

The active San Francisco context now uses the owner-photo-derived `2212x340` RGBA line-art texture `sf_skyline_owner_outline_final.png` instead of the historical abstract SVG. The quad is `1950x300 m` at `(-2500,132.5,750)`, preserving its westward direction, water-level ink baseline, camera-facing material, shadowless rendering, and zero collision.

## Skyline view

[`07-horizon-context.png`](07-horizon-context.png) is the grounded ferry/west-facing comparison view. The full quad projects to `521.130 px`, or `36.190%` of the 1440-pixel viewport width, versus the prior `900x225 m` abstract strip. The billboard is fully inside the camera frustum, has no world blocker, owns no collision node, and remains outside the playable island.

Visual inspection confirms a materially wider, recognizable monochrome profile with Salesforce Tower, the Transamerica Pyramid, downtown high-rises, and the right-hand hills. Transparent sky/foreground pixels blend with the game horizon, and the separate Bay Bridge model is not duplicated in the texture. The ferry-side foreground building still masks part of the left skyline from this exact grounded angle; the visible portion remains readable, and changing the geographic direction merely to dodge that building was intentionally avoided.

Relevant identities:

- Runtime texture SHA-256: `1939151e1098c4935d1a5fd230bc9a692c5484fc93fc5d5bd4064da0678927d4`.
- Context frame SHA-256: `c05d16b6cef27eb483375fb598eec16cfedb0f7e1c46a5508f891b3f2b260162`.
- Ferry frame SHA-256: `977ebe55668fa7dbe70ab0665ffd6a1357e399fc77409125edf288ceda926d9b`.
- YBI/bridge frame SHA-256: `8e06b2f200a7a27a3d7817103c2dbc390be23eb3a353493b8da874691a7ea6f2`.
- Capture-manifest SHA-256: `6c0307f4f30279d36a4ee98b9653509f60710a93ce497a1cc1a0f004b2e85c1c`.

## Command

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot \
  --path . \
  --display-driver macos \
  --rendering-method forward_plus \
  --rendering-driver metal \
  --audio-driver Dummy \
  --resolution 1440x900 \
  --script game/tests/rendered_visual_evidence_capture.gd \
  -- \
  --visual-evidence-output=evidence/first-playable/owner-skyline-rendered-2026-08-28-1900
```

## Proof boundary

This evidence proves the current source project renders the intended larger photo-derived billboard without changing gameplay, physical surfaces, or context collision. It does not replace the owner's ordinary-play judgment of preferred skyline scale, line weight, or contrast, and it is not yet evidence for a newly exported Mac bundle.

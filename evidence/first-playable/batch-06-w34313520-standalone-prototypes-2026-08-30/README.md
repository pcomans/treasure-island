# w34313520 standalone facade prototype evidence

Status: **ready for independent standalone art review; not self-accepted**.

This is a controlled native Godot proof for exactly two `w34313520` assets:

- `W34313520-MAT-PALE` — a pale warm-gray/off-white, smooth, opaque `homogeneous_material_tile` field. It has no facade-scale motif and is shown across one continuous 30 m × 11 m panel to expose macro behavior.
- `W34313520-BAY` — one complete, bounded three-tier horizontal-window `module_atlas` motif. The module owns only three muted glazing proxies and twelve full dark frame bars. The uninterrupted host field supplies the visible pale outer and inter-tier pier space. Module field/backing ownership is zero.

The composition is not a receiver placement. Runs 6..10 and the long SSE outer elevation name the only reference-supported eligibility region; no along-run coordinate, count, cadence, surveyed dimension, completed elevation, or live attachment is proposed.

## Native capture environment

- Godot `4.7.2-stable (official)`
- macOS display driver
- Forward+ / Metal
- Apple M1 Pro (Apple7)
- 1440 × 900

Reproduce from the project root:

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/w34313520_standalone_prototype_capture.gd
```

## Review route

1. `01-neutral-field-close.png` — close neutral field response at the reversible 0.95 m proof scale (uncertainty 0.35–1.80 m).
2. `02-complete-bay-neutral.png` — straight-on view of the complete three-tier module and host-provided pale pier space.
3. `03-complete-bay-oblique.png` — oblique depth and raised-halo/backing check.
4. `04-ordinary-gameplay-scale.png` — ordinary-distance readability of one illustrative motif on the 30 m field.
5. `05-macro-repeat-span.png` — full-span field alias/macro-period check; the aperiodic field has no finite facade motif repeat.
6. `06-changed-light-oblique.png` — changed-light roughness, relief, frame depth, and glazing-value check.

`capture-manifest.json` records renderer identity, camera and light transforms, image hashes, dimensions, byte counts, sampled luminance, exact topology, and limitations. `asset-ledger.json` pins the reviewed inputs and outputs. `runtime-isolation.json` proves the generated/runtime/current-live baselines remain byte-identical.

## Claims that remain blocked

- exact receiver placement, coordinates, count, or cadence;
- surveyed dimensions, scale, color, or roughness;
- architectural-pattern or whole-wall periodicity;
- the complete SSE elevation or a unique elevation;
- runs 20..21, inset/recess/glazed-wing ownership, all non-SSE sides, endpoints, and corners;
- the darker lower/recess family, storey count, building use/name, and whole-building resemblance.

No Street View pixels are stored in this evidence set.

# Coherent-surface continuous-route evidence

Date: 2026-08-28  
Generated content: `07eee769e2b888a330546360d9a6cc9f37d88660d8f03ad93a46260918de1470`  
Manifest file: `dbe582d82bc3c1088e000e080b5df97cf9fc6c9ff5ff061ebf4c1e91287e60b0`  
Godot: `4.7.2.stable.official.ed1daf0bf`

Both routes ran the real `PlayerController` from the foot-level ferry spawn without a post-start transform write. They therefore exercise the repaired startup grounding and the same generated land collision used by roads, public-space overlays, recovery, and jetpack landing.

## Normal route

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/automated_route_qa.gd
```

Exit `0`: 14 checkpoints, `264.122 m` planned centerline, `262.104 m` traveled, `40.024 s` wall time, 2,400 physics frames, zero airborne frames, recoveries, stalls, boundary escapes, or discontinuities.

## Whole-island route

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/automated_route_qa.gd -- --whole-island-route
```

Exit `0`: `3,422.321 m` traveled, `90.319 s` wall time, five grounded regional landings, maximum one-frame move `0.143 m`, and zero recoveries, stalls, boundary escapes, discontinuities, or post-start transform writes.

The route anchors use elevations emitted by `generated/world/terrain.json`, and every landing is checked against the generated colliding ground. This is deterministic movement evidence, not owner visual acceptance.

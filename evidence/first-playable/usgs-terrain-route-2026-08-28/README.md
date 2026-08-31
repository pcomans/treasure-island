# USGS terrain continuous-route evidence

Date: 2026-08-28  
Generated content: `77a154d5d52815a68de57be6ebe8ac222b859649a7b741416d46f1ddbce3e804`  
Godot: `4.7.2.stable.official.ed1daf0bf`

Both routes ran the real `PlayerController` from the terrain-aware ferry spawn without a post-start transform write.

## Normal route

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/automated_route_qa.gd
```

Exit `0`: 14 checkpoints, `264.122 m` planned centerline, `262.104 m` traveled, `40.120 s` wall time, 2,400 physics frames (`338` walk, `2,062` run), `0.690 m` final error, zero airborne frames, recoveries, stalls, boundary escapes, or discontinuities.

## Whole-island route

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/automated_route_qa.gd -- --whole-island-route
```

Exit `0`: `3,422.086 m` planned, `3,422.321 m` traveled, `90.322 s` wall / `722.667 s` simulated, 43,360 physics frames (`352` walk, `29,149` run, `9,414` jetpack), 40,956 airborne frames, maximum one-frame move `0.143 m`, five landings, `0.208 m` final error, and zero recoveries, stalls, boundary escapes, or discontinuities.

The route anchors use elevations emitted by `generated/world/terrain.json`, and each landing is checked against the generated colliding ground. This is deterministic movement evidence, not an owner visual-quality judgment.

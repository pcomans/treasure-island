# Automated continuous-route evidence

Checked: 2026-08-28

Result: **pass for one representative southern road traversal in the source project.** This does not establish whole-island traversal, rendered quality, the packaged app, or owner recognition/acceptance.

## What ran

`game/tests/automated_route_qa.gd` loaded the real `game/scenes/main.tscn`, waited for the full generated world, pinned content SHA-256 `5899ebe131bbf05525fedebdac703a321a7aaf95523a57960cb937085068cfaa`, manifest SHA-256 `07b8b195e1a05942e38d9bbbcb801394cf9f184051fb5f7a819c75677e46f160`, and the approved ferry transform, then allowed the normal player to ground there.

The harness steered the real third-person camera and held the public `move_forward`/`run` actions. It did not set the player transform after startup and did not teleport between checkpoints. Fourteen handpicked checkpoints follow live generated road geometry through Waterfront Plaza, Treasure Island Road, and Trade Winds Avenue. They are tied to five frozen OSM ways: `w1222514694`, `w1212173450`, `w1249797944`, `w255330044`, and `w1249797946`.

Before moving, every checkpoint had to be inside the live boundary, hit generated `land_ground`, and lie inside a generated `road_path` triangle whose source batch carries the expected way. During every physics frame, the harness required in-bound position, normal progress, at most six consecutive airborne frames, and no runtime recovery. Each reached checkpoint also had to be grounded and on live road geometry. A 120-second global timeout, 6,000-frame route cap, and two-second rolling stall check bound the run. All synthetic input is released on success, failure, and timeout.

## Exact result

| Metric | Result |
|---|---:|
| Route checkpoints | 14 |
| Frozen centerline length | 264.122 m |
| Actual player travel | 262.125 m |
| Elapsed route time | 40.151 s |
| Physics frames | 2,400 |
| Walk / run frames | 338 / 2,062 |
| Peak consecutive airborne frames | 0 |
| Runtime recoveries | 0 |
| Stalls | 0 |
| Final checkpoint error | 0.688 m |

The process exited `0` without engine errors, authored warnings, crash output, or leak warnings. The exact sanitized console output is in [`headless-route.log`](headless-route.log).

## Rendered visual checkpoints

A second bounded run used Godot's normal macOS/Forward+/Metal renderer on the Apple M1 Pro. It followed the same route continuously, traveled `262.111 m` in `40.873 s`, remained grounded, and exited `0` after writing four `1440×900` PNGs plus [`route-capture-manifest.json`](route-capture-manifest.json):

- [`route-00-ferry-spawn.png`](route-00-ferry-spawn.png) — SHA-256 `79e42797…d543`
- [`route-03-waterfront-crossing.png`](route-03-waterfront-crossing.png) — SHA-256 `62a64635…e5a2`
- [`route-06-trade-winds-turn.png`](route-06-trade-winds-turn.png) — SHA-256 `c0639e67…db51`
- [`route-13-trade-winds-east.png`](route-13-trade-winds-east.png) — SHA-256 `e5ed4e20…21c4`

The manifest's four hashes match independent SHA-256 checks. Visual inspection found all four frames nonblank, unobscured by pause/loading UI, grounded on visible road geometry, and consistently framed behind the visible player. They show readable road/land/water separation and building massing at the route locations; they are functional traversal checkpoints, not proof that the island is recognizable or artistically accepted. Exact rendered output is in [`rendered-route.log`](rendered-route.log).

## Reproduce

From the project root:

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot \
  --headless \
  --path . \
  --script game/tests/automated_route_qa.gd
```

The normal-renderer mode that produced the retained images passes `--visual-evidence-output=...`; the exact command is in [`game/tests/README.md`](../../../game/tests/README.md).

## Remaining boundary

The route deliberately covers a safe, representative `264.122 m` southern corridor rather than pretending to prove every road, shoreline, building gap, or island region. It reduces the owner's routine traversal burden, but north, center, southwest, perimeter, tight-camera, jetpack-feel, spray appearance, and Treasure Island recognition checks remain in [`PLAYTEST.md`](../../../PLAYTEST.md). It also ran against the source project, not the exported app.

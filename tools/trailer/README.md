# Trailer shots

Composed gameplay shots for the trailer, rendered offline on a fixed clock so the
motion is perfectly even at 1080p30 whatever the real frame rate. One JSON file
per shot lives in `shots/`; one command renders it to an MP4.

```bash
tools/trailer/render-shot.sh tools/trailer/shots/06.json ~/Movies/gti-trailer/renders/06.mp4
tools/trailer/render-shot.sh --batch ~/Movies/gti-trailer/renders tools/trailer/shots/*.json
tools/trailer/render-shot.sh --stills ~/Movies/gti-trailer/stills tools/trailer/shots/04a_building-one.json
```

Loading the island takes about four minutes on the M1 Pro, so `--batch` and
`--stills` render several shots in one load (`--batch` writes `NAME.mp4` for each).
`--stills` saves only a few PNG frames per shot (first, middle and last usable
frames, both handle ends and a 10 fps run across each cut point) for composing
quickly; a shot that fails there doesn't stop the others.

The game draws each frame into an offscreen 1920 × 1080 viewport (no HUD, touch or
fps overlay can reach it), reads it back and writes it raw; ffmpeg encodes H.264
(CRF 17, yuv420p BT.709, `+faststart`) and the raw frames are deleted once the MP4
has every frame. Frames and logs go to `$TRAILER_WORK_DIR` (default
`~/Movies/gti-trailer/work/<shot>-<time>/`), never into the repository.
`tools/godot` must find Godot: the script uses the checkout's
`.tools/godot/4.7.2/Godot.app` when `GODOT_BIN` is unset. A fresh checkout is
imported once first.

## Writing a shot

```json
{
 "name": "example",
 "duration": 1.5,
 "handle": 0.5,
 "fps": 30,
 "resolution": [1920, 1080],
 "sun": "2026-11-13 16:05",
 "glow": false,
 "street_detail": true,
 "chester": {
  "at": [-75.0, 752.0],
  "facing": [-75.0, 730.0],
  "track": [{"t": -2.0, "move": "walk", "path": [[-75.0, 700.0]]}]
 },
 "camera": {
  "near": 0.2,
  "keys": [
   {"t": -0.5, "position": [-150.0, 3.0, 752.0], "target": [-10.0, 13.0, 744.0], "fov": 36.0},
   {"t": 2.0, "position": [-150.0, 4.6, 749.5], "target": [-10.0, 13.3, 742.5], "fov": 36.0}
  ]
 }
}
```

- World coordinates are metres: +X east, -Z north, Y up (sea level about 0, the
  island's ground about 2 to 7 m).
- `duration` is the usable length in seconds. `handle` (default 0.5) adds that much
  of the same motion before and after it, for trimming: shot time runs from
  `-handle` to `duration + handle`. Never ease to a stop at the ends.
- `fps` 30 (default) or 60; `resolution` defaults to 1920 × 1080.
- `sun`: island time (`YYYY-MM-DD HH:MM`, Pacific) for the game's own time of day
  (`DayClock.pin`); leave it out for the game's recorded 12:30 light. On 13
  November the sun is 8.8° up at 16:05 (`node tools/solar_position.mjs "2026-11-13 16:05"`).
- `glow` (default false, as in the Isle House trailer's capture) and
  `street_detail` (default true).
- `chester`: he stands at `at` (`[x, z]`, settled on the ground), turned towards
  `facing`. `track` entries, each from its time `t` until the next: `move` is
  `idle`, `walk` (4 m/s, or slower with `speed` in m/s, through the controller's
  analog stick input) or `run` (20 m/s) along `path` (`[[x, z], ...]`, starting
  where he is when the entry begins), and `jetpack: true` holds Space.
  `lift` (metres) starts him that far above where he settled, in the air: with
  no jetpack he then glides down at the stock 1.5 m/s, and a walk or run moves
  him forward through the air. The avatar flails its arms while it rises (Space
  held, or climbing faster than 1 m/s) and floats them out to the sides while
  it descends, so a calm flying shot glides rather than climbs. He is the
  stock player driven through its own input actions, so his animation is the
  game's. Start a move before `-handle` (the run starts at least 1.5 s before
  the first frame) so he is already at speed in the first frame. Without
  `chester` he is hidden.
- `camera.keys`: `t`, `position`, `target` (both `[x, y, z]`) and `fov` (vertical
  degrees, default 50). The path is a cubic spline through the keys with
  Catmull-Rom tangents weighted by time (no velocity jump at a key) and carries
  its end velocity straight on outside the keys. Evenly spaced keys along an even
  move give an even move. `"follow": true` makes a key's position and target
  offsets from Chester's feet, for a camera that travels with him. `near`
  defaults to 0.2 m.

The run stops with `SHOT_FAILED` if, below 80 m, the camera comes within 0.3 m
of anything solid, passes through it, or is under the ground or inside a
building; if Chester's walk or run is blocked (he would stop dead); if a frame is
not exactly one clock step (a pause, or a missing `--fixed-fps`); or on any
script or shader error. `SHOT_KEY` prints the ground height under each camera
key, `SHOT_MOTION` the worst frame-to-frame change of camera speed and the frames
in which something solid hides Chester. Foliage, poles and composition still
need a look at the frames.

## How it works

`render-shot.sh` checks the shot file, then runs `run_engine.py`, which takes the
native engine slot's lock, refuses to start beside any other Godot, owns the one
process it starts and reports its real end, and requires the driver's final
`SHOT_COMPLETE`. The driver is `game/tests/shared/trailer_shot.gd`. Both follow
the Isle House trailer capture (`tools/cinematics/isle-house` on
`codex/isle-house-trailer-repro`): the offscreen capture viewport (MSAA 4×, TAA,
16× anisotropy, nearest level of detail everywhere so nothing swaps mid-shot),
sun shadows out to the far plane with cascades fitted to the camera's depth of
interest, fog thinned with altitude, glow off, and a fixed clock
(`--fixed-fps`). It holds the first pose for 90 frames before anything moves:
Metal compiles the first frames' pipelines for minutes on a fresh cache, so let
a quiet run go on rather than restarting it. A capture never pauses: the game's
pause on focus loss is kept off, and a pause would fail the run. macOS stops
drawing a hidden or covered window while physics runs on, so the small capture
window stays on top; don't minimise it or switch it to another desktop (the run
fails rather than film a jump). `--batch` still encodes the shots that finished
before a failed one.

Later: a recorded-input track (car crashes) can join `chester.track` as another
kind of entry without changing the rest.

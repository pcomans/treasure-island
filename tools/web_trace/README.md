# The web drive trace: notes for picking it up

This is the debug build the owner runs on an iPhone to find why the page dies. It is on branch
`web/iphone-reload-trace-20261117`.

## The build

- The served debug build is commit `ea6eb455` on this branch, stamped build 2258.
  - Its game is `web/shader-warmup-20261117` at `476a72aa`, so the shader warm-up is in it
    (`game/scripts/world/shader_warm_up.gd`, `main.gd` `_compile_by_group`).
  - On top of that it has the trace's switches and records described below.
  - Later commits here change only the rig driver and documentation.
- Branch `wip/iphone-reload-trace-additions-20261118` is unfinished work:
  - It merges the warm-up's reviewed head `465af907`, which brings the chest at rest until play,
    the trace's analysis inside its gate, the wider no-network check and the deploy's shader-proof
    receipt. `shell.html` merged without conflict.
  - It adds memory measurements: WebGL objects and estimated bytes, cube-map face draws, sound
    buffers, WebAssembly growth as a kept event, named reflection-probe markers and engine static
    memory.
  - Only `check_web_trace.mjs` was run on it. The trace contract, a build and the kill check were
    not.

## Build and serve

- Build with `TI_SFX_SOURCE=<sound source> tools/build-web.sh --sfx-require-all`.
  - Run it from a clean checkout and leave the tree alone while it runs: the build stops if a
    tracked file changes during it.
  - The sound source is private; see `tools/sfx/README.md`.
  - The build patches the exported engine script so plays share each sound's `AudioBuffer`. It
    stops if the patch no longer applies.
  - The export is `build/web` (about 193 MB), with its files named `treasure-island-<commit8>.*`.
- Godot's web engine starts only in a secure context.
  - For the rig, serve on loopback: `python3 -m http.server <port> --bind 127.0.0.1 --directory build/web`.
  - A phone needs HTTPS.
  - Over plain HTTP at any other address the engine stops at "Secure Context".
- Nothing is deployed from a branch. A preview is made from an export folder by whoever is
  assigned to deploy it.

## Address parameters

All of these work only together with `?trace=drive`; without it the page and the game run no
trace code.

| Parameter | What it does |
|---|---|
| `trace=drive` | Runs the trace: the drive round the island, the foot and jetpack legs, then the results page. |
| `laps=N` | Drives the loop N times (1 to 3). |
| `seconds=N` | Ends the trace N s after its first record and shows the results. |
| `scale=S` | Sets the 3D resolution for the run (0.5, 0.67, 0.75 or 1), the way the Options menu does; not saved, and put back at the end. |
| `route=hover` | Leaves out the car: from the spawn, walk, run, climb about 74 m on the jetpack, hover, drop. |
| `route=corner` | After the 5 s baseline, puts the car straight on Bruton Street (route point 8), drives it round the Avenue of the Palms' corner with Johnson Street by Mersea (about 35 s in, where the iPhone's page dies) to Johnson Street's bend (point 16), gets out and ends: about a minute. It skips the walk to the car and the ferry plaza, so less of the island has been drawn by the corner than on the whole drive. |
| `probes=0` | Takes Mersea's reflection probes out as the world is put together (`MerseaModel.reflections_off`). |
| `sound=0` | Silences the game: no sample is registered with the browser and no player is started. |
| `msaa=0` | Turns MSAA off (the web's default is 2x). |
| `profile_startup=1` | Gives the game's startup marks and readback (`window.__tiReadback`); the rig uses it. |

Natively, the same options are `--trace-drive`, `--trace-laps=N`, `--trace-seconds=N`,
`--trace-scale=S`, `--trace-route=hover|corner`, `--trace-probes=0`, `--trace-sound=0` and
`--trace-msaa=0`, with `--trace-out=FILE --trace-quit`.

For example, the corner alone without Mersea's probes at the phone's resolution:
`?trace=drive&route=corner&probes=0&scale=0.67`.

## Where the code is

**Game side: `game/scripts/debug/drive_trace.gd`.** `main.gd` makes it only when the trace is
asked for (`GameMain.drive_trace_requested`).
- `_ready` reads the options and calls `_apply_switches`.
- `_physics_process` runs the steps.
- `_finish_frame` makes one record per frame, with the fields in `FIELDS`.
- `_event` adds a marker.
- `_send` hands records and markers to the page every `SEND_MS` (250 ms).
- `_begin_report` and `_end_report` write the header and the end.

**Page side: `game/web/shell.html`, the inline script that starts with the trace's comment.**
- `tiTraceFrames`, `tiTraceAnalyze` and `tiTraceText` are the analysis.
- The runtime follows them:
  - wrappers that only time WebGL, Web Audio and WebAssembly calls;
  - `pageEvent`, `beat`, `addSecond` and `closeSecond`;
  - `keepChunk` and `keptLog`, and `saveProgress`;
  - `window.__tiTrace` (`begin`, `engine`, `end`), which the game calls;
  - `show`, which draws the results and the previous-run panel.

## Where the records are kept

Everything stays on the device: localStorage keys start with `ti-trace:`, and there is an
IndexedDB database `ti-trace`.
- `page_events` holds the page's own events, each saved the moment it comes (`pageEvent`, the
  last 40): visibility, pagehide and pageshow, freeze, an error or unhandled rejection, a resize or
  rotation, and the WebGL context being lost.
- `heartbeat` is written with every engine batch (at most every 250 ms), every second, and on
  every page event. It holds the last engine record, the last 8 markers, the last 30 frame times,
  the page's view and the current second so far.
- Rows per page second (`SECOND_COLUMNS`):
  - `ring` holds the last 120 and is saved every second;
  - `seconds` holds all of them (up to 900) and is saved every 10 s;
  - `long` holds the last 400 long frames from the last minute, saved every 10 s.
- IndexedDB `ti-trace`/`chunks` holds everything the log gained, one chunk a second, up to 1800
  per run. Only the last unfinished run's chunks and the current run's are kept.
- `meta` holds the run's status, its page and header. `previous` holds an unfinished run's
  records, copied there at the next load. `text` holds the results.
- `gl_big` holds the last 60 graphics allocations of 4 MiB or more, each saved the moment it is
  made (see the memory records below).
- `audio` holds the last 40 sounds started, each saved the moment it starts: the page's buffer
  starts at once, the game's "sound" markers once a batch.
- The game's "view" and "probe" markers are kept in `page_events` too, once a batch.
- The next load with `?trace=drive` finds `meta` still "running". It shows the panel "A previous
  drive trace did not finish" with those records. On that panel, the first tap on "Download full
  log" reads the killed run's chunks from IndexedDB, and the second tap saves the file.

## The memory records

These find what allocates the last few hundred MB before iOS kills the page at its 2048 MB
limit. All of them run only with `?trace=drive`.

**Graphics storage, an estimate (`shell.html`, `glm`).** The page's WebGL2 wrappers (the same
ones that time uploads) add up what each allocating call asks for: `texImage2D`,
`texImage3D`, `compressedTexImage2D`/`3D`, `texStorage2D`/`3D`, `copyTexImage2D`,
`generateMipmap` (a third of level 0 again), `renderbufferStorage`,
`renderbufferStorageMultisample` (times its samples) and `bufferData`; `delete*` takes a
deleted object's storage off, and a re-specified level or buffer replaces its old size.
- Kept as totals: live objects by kind (textures, buffers, programs, shaders, framebuffers,
  renderbuffers, vertex arrays), texture bytes by kind (2D, cube map, 2D array, 3D),
  renderbuffer bytes and the multisampled part, buffer bytes, bytes uploaded so far, storage
  asked for so far (counting every re-specification again, so its rise is churn) and the
  number of allocations of 4 MiB or more.
- Kept at once in `gl_big` (and as `gl` events in the log): every allocation of 4 MiB
  (4,194,304 bytes) or more, with its kind, format, size, levels, faces or samples, where the
  drive was and the totals after it. A same-size re-specification of the same level or buffer
  is not one.
- Cube-map faces drawn (`cube` page events): Godot's Compatibility renderer draws a reflection
  probe's faces, and the sky's radiance, into framebuffers a cube-map face is attached to. The
  page counts each face attachment and each bind of such a framebuffer, and keeps a page event
  when such drawing starts and when it has stopped for a second, with the storage it added.
- Its limits: it counts what the page asks WebGL for, not what the browser or GPU makes of it.
  It does not see the canvas's own drawing buffer (its size is in the `canvas buffer` page
  events and the page view), the browser's or ANGLE's own copies, staging or shadow buffers,
  a driver's padding or alignment, a format a GPU stores wider (it counts RGB formats at 4
  bytes a texel, and an unsupported compressed format as compressed), or memory WebKit keeps
  after a delete until the GPU is done with it. `bufferSubData` and `texSubImage*` change no
  storage and are not counted as allocations. An object's storage goes to the object bound
  when the call is made, read back with `getParameter`.

**Engine counters (`drive_trace.gd`, each frame).** Besides texture, buffer and video memory,
draw calls, resources and nodes, the frame record has `static_b` and `static_max_b`
(`Performance.MEMORY_STATIC` and its peak: 0 in a release build, as the web's), `obj_n`
(objects alive) and `orphan_n` (nodes out of the tree, not freed).

**WebAssembly memory.** Its size in bytes is in every row a second, and every growth is a
`wasm` page event, kept at once, with the old and new size and how long it took.

**Reflection probes.** The engine has no signal for a probe's update, so the game marks when
each probe comes into the camera's view or leaves it (`probe` markers: the probe's box against
the camera's planes, as the engine culls it, with its update mode). Whether it was actually
drawn shows in the page's cube-map face counts. The header lists every probe and the
reflection atlas's settings.

**Sounds.** The game marks every sound it starts (`sound` markers: its id, play or loop start,
its takes' lengths). The page keeps every Web Audio buffer started (`audio`: its length,
channels, rate, decoded bytes, whether it loops and whether it is that buffer's first start),
and counts the sound buffers made and their bytes.

**Where they are.**
- A row a second (`SECOND_COLUMNS`; `ring` and `seconds`) ends with the engine's static memory,
  its peak, the objects and orphan nodes, then the page's memory columns (`MEMORY_COLUMNS`):
  WebAssembly bytes, JS heap bytes, the GL totals above, sound buffers made and their bytes,
  sound buffers started and the bytes of the buffers started.
- The heartbeat (at most every 250 ms) has the same page columns as `memory`.
- The log's `memory` rows are page ms, JS MiB, WebAssembly MiB, then the same columns
  (`page.memory_columns` names them all).
- The unfinished-run panel shows the heartbeat's memory columns, `gl_big` and `audio`.

## Adding a record that survives a killed page

- **A value every second.**
  - From the game: add a field to `FIELDS` and to the record in `_finish_frame`, then read it in
    `addSecond`.
  - From the page: compute it in `closeSecond`.
  - Either way, add its name to `SECOND_COLUMNS`. The ring is saved every second, and the full
    log carries the game's fields in the chunks.
- **An event.** Call `pageEvent(kind, text)`, which logs the event and saves it at once. To keep
  a game marker the same way, have the page call the keeping part of `pageEvent` for that kind
  when the marker arrives in `engine()`.
- Prove it with the kill check below before giving the build to anyone with the device.

## The kill check

On the devcontainer, run this in an engine slot:

```sh
KILL_AT_S=72 BROWSER=webkit PROFILE=iphone TI_WEBKIT_EXEC=<MiniBrowser wrapper> \
  URL='http://127.0.0.1:<port>/?trace=drive&profile_startup=1&scale=0.67&seconds=80' \
  tools/web_trace/session.sh <out-dir>
```

- The driver kills the page's web process at that trace second and opens the page again in the
  same browser.
- It saves the panel to `previous-panel.txt` and the downloaded full log to `previous-log.json`.
- The `iphone` profile is the owner's Safari held sideways: 874 x 292 CSS px at 3x, a canvas of
  2622 x 876.

## Checks that must stay green

- `tools/godot --headless --path . --script game/tests/headless_drive_trace_contract.gd` (part of
  `tools/test.sh`) checks that the trace does nothing without its parameter.
- `node tools/check_web_trace.mjs` checks the page side: nothing without `?trace=drive`, and no
  network call.
- Nothing is ever sent over the network. Records leave the device only when the owner uses Copy
  or Download.

## What is known from the phone

- iOS kills the page's own process (WebContent) at its 2048 MB per-process limit
  (`JETSAM_REASON_MEMORY_PERPROCESSLIMIT`). That was five of the six deaths; the sixth was a crash
  in a JavaScriptCore JIT thread near the limit.
- WebKit charges the page's graphics memory to that process, so WebAssembly, WebGL and the JS
  heap all count toward the limit.
- The process got a limit warning at 1638 to 1745 MB, 20 s to 11 min before it died.
- At 3D scale 0.67 and 1 the page dies 68 s into the drive. That is at the corner of the Avenue
  of the Palms and Johnson Street by Mersea, (-289, 274), as the car turns and the camera swings
  round.
- At scale 0.5 it got past the corner and died in the jetpack hover at 361 s.
- On the dev box, at that corner, the engine's texture and buffer memory and the browser's web
  process all stay flat. What adds the last 300 to 400 MB on the phone there is not known yet;
  allocations the first time something is drawn under Metal are the suspect.

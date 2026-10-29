# Treasure Island

A private Godot game of Treasure Island, San Francisco, built autonomously by
agents: walk, run, jetpack, and spray a tag on building walls. The whole island
comes from a frozen OpenStreetMap snapshot; agents improve its buildings one at a
time so they look like the real ones.

**Score:** the number of buildings (out of 213) that recognizably match their real
counterparts, i.e. accepted buildings in [the building catalog](discovery/facades/facade-recognition-catalog.json).
`tools/test.sh` prints it.

## Develop

Development runs in the Linux devcontainer on the GMKtec (`.devcontainer/`), with
GPU rendering:

```sh
devpod up git@github.com:pcomans/treasure-island.git --id treasure-island --ide none
# Inside the container git pushes over HTTPS (DevPod's credential helper), not SSH:
devpod ssh treasure-island --command "cd /workspaces/content && git remote set-url origin https://github.com/pcomans/treasure-island.git"
devpod ssh treasure-island
cd /workspaces/content
```

Creating the container installs Godot 4.7.2 and its export templates (in the
`/opt/godot` volume, shared by every checkout), Codex, Claude Code and Node
dependencies (`.devcontainer/post-create.sh`). Log in to Codex with
`codex login --device-auth`.

Always start Godot through `tools/godot`. It picks the project's Godot and, for
anything that renders, a headless display on the GPU:

```sh
tools/godot --headless --path . --import                       # after a fresh clone
tools/godot --headless --path . --script game/tests/<test>.gd  # a headless test
```

## Check a building

```sh
# Screenshots for review: gameplay close-ups, the building in its surroundings, island overviews
tools/godot --path . --resolution 1600x900 --script game/tests/shared/building_shots.gd -- --source w291189336 --island --out /tmp/shots

# Fit and playability: roof and walls are solid, walls reach the ground, the player can walk up to it
tools/godot --headless --path . --script game/tests/shared/building_fit_test.gd -- --source w291189336
```

`--source` is the building's OSM id from `generated/world/` (e.g. `w291189336`
is the Navy Chapel). [AGENTS.md](AGENTS.md#what-done-means-for-a-building) says
when a building counts as done.

## Build for the Mac

```sh
tools/build-mac.sh   # -> build/mac/treasure-island-mac-<commit>.zip
```

This exports the macOS build, checks it contains only game files (no research or
evidence folders, no images outside `game/resources/`), and launches a Linux build of the same commit to confirm the island
loads. Copy the zip to the Mac, unzip it, and right-click the app → Open the
first time (it is not notarized).

Desktop builds (this and `tools/build-linux.sh`) first bake the island with
`tools/prebuild-static-world.sh native` and load that baked world at startup
instead of generating it; `tools/test.sh` runs the whole-island check on it too.

## Controls

- `WASD` moves; hold `Shift` to run.
- Mouse looks around.
- Hold `Space` to jetpack upward; release it to descend slowly.
- Primary click sprays the center-reticle target.
- `R` recovers to a safe position.
- `Esc` pauses; `Q` quits while paused; `F3` toggles runtime evidence.

## More

- [AGENTS.md](AGENTS.md): how agents work on this project. Read it before changing anything.
- [CLAUDE.md](CLAUDE.md#persisted-entrypoints): agent roles and the building skill.
- [LEARNINGS.md](LEARNINGS.md): lessons from earlier work.
- [HUMAN.md](HUMAN.md): things only the owner can do.
- Older records: Git history and `evidence/`.


## Browser build

`tools/build-web.sh` exports the committed checkout to `build/web` and audits the
pack for game-only content. Native builds retain Forward+; the browser uses
Godot's Compatibility/WebGL 2 renderer and single-threaded WebAssembly.

Open https://treasure-island-five.vercel.app/ and wait for the island to load,
then click **Resume**. WASD moves, Shift runs, Space rises with the jetpack,
releasing Space descends slowly, mouse movement looks around, and Esc pauses.
Spray is omitted in the browser build by owner approval. F3 shows actual FPS.

To deploy a new exported build to the existing Vercel project, run the CLI from
`build/web`, verify the linked `treasure-island` project, then deploy production.
Do not upload the source checkout, reference imagery or evidence directory.
The web exporter writes immutable caching for commit-named assets and the WASM
content type.

Browser performance and pointer lock need checking on the playing machine.
The development container's Chrome 154 on headless Weston has a reproducible
pointer-lock crash; this is not evidence that the owner's Mac browser crashes.

In the Linux development browser, mesh-size distance culling increased the
observed spawn frame rate from13 to39–40FPS. Distant small building meshes can
disappear; complete source inventory and collisions remain loaded. Initial
world construction took about90seconds. These measurements used Chrome154,
AMD Radeon780M and headless Weston; they do not predict Mac performance.
Traversal smoke checks required a test-only pointer-lock override because of
the container crash. That override is not in the deployed game.


### Touch controls

On a touch-capable browser, tap **Play / Resume** after loading. Drag the left
movement stick to walk, drag the right side to look, hold **RISE** to jetpack
upward and release it to descend, and hold **RUN** while moving to run. The
**II** button pauses. Movement, look and buttons accept different fingers at
the same time. Pausing, losing focus, resizing or cancelling a finger releases
held touch input. Desktop mouse and keyboard controls are retained.

This ports the MIT mobile input layer from Selgesel’s Godot4 third-person
controller (see game/scripts/vendor/selgesel/README.md): its analog thumbstick,
virtual buttons and swipe camera. Stock movement physics is retained; stick
magnitude controls touch speed. Touch mode avoids pointer lock; it does
not fix iPad trackpad capture. Physical iPad Safari validation remains with the
owner; Chromium touch emulation checks are recorded in RETRO.

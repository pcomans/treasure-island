# Treasure Island

A private Godot game of Treasure Island, San Francisco, built autonomously by
agents: as a treasure chest full of gold on rubber-hose legs, walk, run and
jetpack (the owner removed spraying tags on 2026-11-11). The whole island
comes from a frozen OpenStreetMap snapshot; agents improve its buildings one at a
time so they look like the real ones.

**Score:** the number of buildings that recognizably match their real
counterparts, i.e. accepted buildings in [the building catalog](discovery/facades/facade-recognition-catalog.json),
out of the catalog's standing buildings (the frozen OSM buildings less those the dated imagery shows
demolished, [tools/config/demolished-buildings.json](tools/config/demolished-buildings.json)).
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

Container starts delete `/tmp` content unused for 7 days (`tools/clean-tmp.sh`).

Always start Godot through `tools/godot`. It picks the project's Godot and, for
anything that renders, a headless display on the GPU:

```sh
tools/godot --headless --path . --import                       # after a fresh clone
tools/godot --headless --path . --script game/tests/<test>.gd  # a headless test
```

New textures default to VRAM compression with mipmaps. For UI art or textures that
store shader data, use **Compress > Mode > Lossless** and **Detect 3D > Compress To >
Disabled** in the Import dock. Keep mipmaps if the shader samples them. Reimport
and commit the `.import` file with the texture.

## Check a building

```sh
# Screenshots for review: gameplay close-ups, the building in its surroundings, island overviews.
# Grass and small stones are drawn round the camera; -- --ground-dressing off|low|medium|high
# sets their density for a run (the project setting treasure_island/ground_dressing/density
# otherwise). Web builds draw none.
# Close-ups leave out street detail (trees, furniture, fences, clutter); surroundings and
# overviews come both ways (NAME-street-on.png, NAME-street-off.png). --street-detail off|on|both overrides.
tools/godot --path . --resolution 1600x900 --script game/tests/shared/building_shots.gd -- --source w291189336 --island --out /tmp/shots

# Fit and playability: roof and walls are solid, walls reach the ground, the player can walk up to it
tools/godot --headless --path . --script game/tests/shared/building_fit_test.gd -- --source w291189336
```

`--source` is the building's OSM id from `generated/world/` (e.g. `w291189336`
is the Navy Chapel). [AGENTS.md](AGENTS.md#what-done-means-for-a-building) says
when a building counts as done.

## Build for the Mac

Every push to `main` builds the Mac app on GitHub Actions
([mac-build.yml](.github/workflows/mac-build.yml)). Both launch checks there are
headless, so CI never exercises the game's rendering on a Mac. Once a GitHub
Apple Silicon Mac has launched the app and loaded the island, the build becomes
a new release of its own, unless a newer push has overtaken it. This link always
gets the newest release:

https://github.com/pcomans/treasure-island/releases/latest/download/treasure-island-mac.zip

The [releases page](https://github.com/pcomans/treasure-island/releases) lists
each build by date and commit, and older builds stay there. Downloaded with curl
or `gh`, the zip has no quarantine flag, so the unzipped app opens directly:

```sh
curl -fLO https://github.com/pcomans/treasure-island/releases/latest/download/treasure-island-mac.zip
gh release download --pattern treasure-island-mac.zip --repo pcomans/treasure-island   # or this
```

The app is not notarized, so after a browser download macOS blocks the first
launch: open System Settings → Privacy & Security and click "Open Anyway".

To build it in the devcontainer instead:

```sh
tools/build-mac.sh   # -> build/mac/treasure-island-mac-<commit>.zip
```

This exports the macOS build, checks it contains only game files (no research or
evidence folders, no images outside `game/resources/`), and launches a Linux build of the same commit to confirm the island
loads.

Desktop builds (this and `tools/build-linux.sh`) first bake the island with
`tools/prebuild-static-world.sh native` and load that baked world at startup
instead of generating it; `tools/test.sh` runs the whole-island check on it too.
The bake merges each building's opaque surfaces into far fewer draws
(`tools/merge_baked_buildings.gd`); the same triangles, packed differently.

## Controls

- `WASD` or the arrow keys move; hold `Shift` to run.
- Mouse looks around.
- Hold `Space` to jetpack upward; release it to descend slowly.
- Hold `C` in the air to drop fast. It does nothing on the ground, and `Space` wins if both are held.
- `F` beside a parked street or lot car gets in; `F` again gets out beside it.
- In a car: `W`/`S` (or the up and down arrows) drive, brake and reverse; `A`/`D` (or the left and right arrows) steer; `Space` is the handbrake; the mouse glances round and the view eases back behind the car; `R` puts the car back on land. No jetpack in a car.
- A car breaks through fences bay by bay (a broken bay stays open, on foot too, until a restart), shoves parked cars and K-rails, sends the pitch's ball rolling, drives through bushes and stops at trees. On the shore rocks it splashes and goes back, with you in it, to a level spot at least 12 m inside the shore, facing away from the water and held on its brakes until you drive off; only a car that comes down on open water sinks for a moment first. On its roof or side it rights itself after about three seconds.
- Kick the pitch's ball (run into it), or push it with a car, into any goal on the athletic fields: confetti bursts at the goal and the ball goes back to its centre spot.
- Car ramps stand in three empty lots: the 12th Street and Avenue D dirt lot, the north slab site between Avenue I and Avenue M, and the former school lot by Aracely Cafe.
- Fences stop you on foot (gates, path crossings and bays a car broke stay open); the jetpack clears them.
- Stepping off the island onto the shore rocks, or flying out over the water,
  lifts you about 5 m into the air where you are; float down and steer or
  jetpack back to land.
- The mouse buttons do nothing: the owner removed the spray on 2026-11-11.
- `R` recovers to a safe position.
- `Esc` pauses: everything stops where it is (you, the cars, the ball, the ferry, the water, the trees and the clouds) until you resume; `Q` quits while paused; `F3` toggles runtime evidence.
- **Controls** in the pause menu, or on the loading screen, lists these controls in the game; **Back** or `Esc` returns.

## More

- [AGENTS.md](AGENTS.md): how agents work on this project. Read it before changing anything.
- [CLAUDE.md](CLAUDE.md#persisted-entrypoints): agent roles and the building skill.
- [LEARNINGS.md](LEARNINGS.md): lessons from earlier work.
- [HUMAN.md](HUMAN.md): things only the owner can do.
- [KNOWN_ISSUES.md](KNOWN_ISSUES.md): known issues and planned work.
- Older records: Git history and `evidence/`.


## Browser build

`tools/build-web.sh` exports the committed checkout to `build/web` and audits the
pack for game-only content. Native builds retain Forward+; the browser uses
Godot's Compatibility/WebGL 2 renderer and single-threaded WebAssembly.

Open https://treasure-island-five.vercel.app/ and wait for the island to load;
play starts by itself. WASD or the arrow keys move, Shift runs, Space rises with the jetpack,
releasing Space descends slowly and holding C in the air drops fast. F gets
in or out of a parked car; in a car W/S drive, A/D steer (or the arrow keys)
and Space is the handbrake. Click
**Click to look** at the top to capture the mouse and look around. Esc releases the mouse and pauses; **Resume** captures it
again and continues. The owner removed the spray on 2026-11-11.
F3 shows actual FPS.

To deploy, as part of a [release](AGENTS.md#pushes-and-releases), push to `main`, check out a clean `main` and run:

```sh
tools/deploy-web.sh             # build origin/main and deploy it to production
tools/deploy-web.sh --dry-run   # the same checks and build; prints the Vercel commands instead
```

It refuses unless the checkout is clean and HEAD is `origin/main`. If `build/web`
isn't linked yet, it links it to the existing `treasure-island` Vercel project (never
a new one). Then it runs `tools/build-web.sh`, deploys `build/web` to production with
the pinned Vercel CLI (`npx vercel@64.5.0`) and prints the deployment URL. It uses
your saved Vercel CLI login (`npx vercel@64.5.0 login`, once). If that login has
more than one team, link once by hand:
`cd build/web && npx vercel@64.5.0 link --team <slug> --project treasure-island`.
Only `build/web` is uploaded, never the source checkout, reference imagery or
evidence. The web exporter writes immutable caching for commit-named assets and
the WASM content type.

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

On a touch-capable browser, play starts as soon as the island has loaded. Drag the
left movement stick to walk, drag the right side to look, hold **RISE** to jetpack
upward and release it to descend, and hold **RUN** while moving to run. The
**II** button pauses; **Play / Resume** continues and **Controls** lists the touch
controls. Movement, look and buttons
accept different fingers at the same time. Pausing, losing focus, resizing or
cancelling a finger releases held touch input. Desktop mouse and keyboard
controls are retained.

A context button above **RISE** does what F and C do. Beside a parked car it
shows a car, **DRIVE**: tap it to get in. In a car it shows **GET OUT**: tap it to
get out. In a car the stick drives and steers, **RISE** turns into **BRAKE** (a
handbrake symbol), and **RUN** and the look hint are hidden until you get out. In
the air it shows a down arrow, **DROP**: hold it to fall fast; it lets go when
you land. Otherwise it is hidden.

This ports the MIT mobile input layer from Selgesel’s Godot4 third-person
controller (see game/scripts/vendor/selgesel/README.md): its analog thumbstick,
virtual buttons and swipe camera. Stock movement physics is retained; stick
magnitude controls touch speed. Touch mode avoids pointer lock; it does
not fix iPad trackpad capture. Physical iPad Safari validation remains with the
owner; Chromium touch emulation checks are recorded in RETRO.

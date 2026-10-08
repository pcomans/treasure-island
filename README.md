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

## Play in a browser

```sh
tools/build-web.sh   # -> build/web/ (index.html plus files named after the commit)
```

This exports the web build of the current commit, checks its data pack the same
way as the Mac build, and writes a `vercel.json` that lets browsers cache the
large files. Try it locally with
`python3 -m http.server 8000 --bind 127.0.0.1 --directory build/web` and open
http://127.0.0.1:8000/ (forward the port in VS Code first). To put it online for
anyone with the link, deploy the folder as a static site:

```sh
npx vercel deploy build/web --prod
```

The build is about 130 MB (a 90 MB data pack and a 40 MB engine). Vercel's
[limits](https://vercel.com/docs/limits) (checked 2026-10-08) cap CLI uploads at
100 MB on the Hobby plan and 1 GB on Pro.

Differences from the Mac build:

- Godot's web export only has the Compatibility renderer (WebGL 2), so lighting
  and materials are simpler.
- Spray tags don't show: the Compatibility renderer doesn't draw decals. The same
  goes for decal-painted facade art such as the Mersea mural, and the Mersea glass
  shader fails to compile there, so that glazing may not draw.
- Browsers only let a page capture the mouse after a click, so it isn't captured
  when the island loads. Walking works straight away; for mouse look (and spray),
  press `Esc` and click **Resume**. `Esc` releases the mouse again.
- `Q` stops the game; reload the page to play again.

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

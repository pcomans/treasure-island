# Treasure Island

A private Godot game of Treasure Island, San Francisco, built autonomously by
agents: walk, run, jetpack, and spray a tag on building walls. The whole island
comes from a frozen OpenStreetMap snapshot; agents improve its buildings one at a
time so they look like the real ones.

**Score: 43 of 213 buildings** recognizably match their real counterparts
(`recognition_metric` in [the runtime registry](game/resources/facades/facade-runtime-registry.json)).

## Develop

Development runs in the Linux devcontainer on the GMKtec (`.devcontainer/`), with
GPU rendering:

```sh
devpod up git@github.com:pcomans/treasure-island.git --id treasure-island --ide none
devpod ssh treasure-island
cd /workspaces/content
```

Creating the container installs Godot 4.7.2, its export templates, Codex,
Claude Code and Node dependencies (`.devcontainer/post-create.sh`). Log in to
Codex once with `codex login --device-auth`; the login survives rebuilds.

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

This exports the macOS build, checks it contains no reference photos or research
material, and launches a Linux build of the same commit to confirm the island
loads. Copy the zip to the Mac, unzip it, and right-click the app → Open the
first time (it is not notarized).

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
- Older records: [README history](README_HISTORY_2026-10-03.md), [earlier README history](README_HISTORY_2026-09-12.md), `evidence/`.

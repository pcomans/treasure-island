# Treasure Island First Playable

A private macOS Godot first playable of Treasure Island: walk, run, jetpack, and
place a predefined spray tag on eligible exterior walls. It uses the frozen OSM
layout and tracked generated world; cars, interiors, missions, multiplayer, and
public distribution are outside this milestone.

## Current release

The latest accepted release was published at commit [`d48760d8`](https://github.com/pcomans/treasure-island/commit/d48760d8dc7637592ab125f8d8a75809bc6a3ebb), which accepts Maceo May as the sixteenth recognized physical building: **16/213** accepted and **197** not evaluated. The current private app is:

`build/maceo-may-exact-current-001/Treasure Island First Playable.app`

Its package and review bindings are in the [Maceo May release record](evidence/first-playable/maceo-may-current-release-2026-09-12-001/README.md). That record retains the original technical evidence; the commit above identifies that accepted release, independently of later source checkpoints.

The repository also retains reviewed 1201 Bayside and 1238 Northpoint source studies. They are inactive, are not enabled in the playable world, and add no accepted-building credit. See the [study checkpoint](discovery/facades/northern-study-source-checkpoint-2026-09-12.md) for their scope.

## Play on another Mac

Copy the complete existing `Treasure Island First Playable.app` bundle from the
path above to the other Mac's `/Applications` folder. It needs no Godot or Node
installation. Then double-click it in Finder, or run:

```sh
open "/Applications/Treasure Island First Playable.app"
```

The bundle is ignored by Git and is therefore not included in a clone. Its
executable contains `arm64` and `x86_64` slices; recorded technical runtime smoke
was on Apple M2.

## Run from source

For a source checkout, use macOS, Git, and the approved standard Godot
`4.7.2.stable.official.ed1daf0bf`. The generated world and runtime skyline asset
are tracked. If Git LFS is installed, this play-only clone skips optional
historical AVI downloads:

```sh
GIT_LFS_SKIP_SMUDGE=1 git clone https://github.com/pcomans/treasure-island.git
cd treasure-island
git switch main

# Copy the existing approved Godot app into this exact project-local location.
mkdir -p .tools/godot/4.7.2
ditto "/Volumes/TRANSFER/Godot.app" ".tools/godot/4.7.2/Godot.app"
touch .tools/godot/4.7.2/_sc_

GODOT="$PWD/.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot"
"$GODOT" --path .
```

Copying the existing Godot app is the simplest setup. When it is unavailable,
follow the [vetted Godot install plan](discovery/TRUSTED_INSTALL_PLAN.md).
Matching export templates and `npm ci --ignore-scripts` are for exporting or
development tooling, not for playing source.

## Controls

- `WASD` moves; hold `Shift` to run.
- Mouse looks around.
- Hold `Space` to jetpack upward; release it to descend slowly.
- Primary click sprays the center-reticle target.
- `R` recovers to a safe position.
- `Esc` pauses; `Q` quits while paused; `F3` toggles runtime evidence.

## More information

- [Playtest guide](PLAYTEST.md) for owner-facing play instructions.
- [Project agreement](AGENTS.md) before changing project work.
- [Test, validation, and export commands](game/tests/README.md).
- [First-playable evidence index](evidence/first-playable/README.md).
- [Active facade catalog](discovery/facades/facade-recognition-catalog.json) and [runtime registry](game/resources/facades/facade-runtime-registry.json).
- [Archived prior README](README_HISTORY_2026-09-12.md) for the full historical release and export record.

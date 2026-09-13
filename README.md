# Treasure Island First Playable

A private macOS Godot first playable of Treasure Island: walk, run, jetpack, and
place a predefined spray tag on eligible exterior walls. It uses the frozen OSM
layout and tracked generated world; cars, interiors, missions, multiplayer, and
public distribution are outside this milestone.

## Current source and release

Current source recognizes **18/213** physical buildings, with **195** not evaluated.
1201 Bayside and 1238 Northpoint are now enabled alongside the previous 16 accepted
units. Their older [inactive study checkpoint](discovery/facades/northern-study-source-checkpoint-2026-09-12.md)
remains historical; it does not describe the current playable source.

This source checkpoint records the current **18/213** app at:

- Private app: `build/northern-1201-1238-exact-current-001/Treasure Island First Playable.app`.
- [Release record](evidence/first-playable/northern-1201-1238-current-release-2026-09-13-001/README.md), including exact app files, source and smoke-test evidence.
- Both signed headless and native runs reached the complete world and passed all nine live attachment checks. The exact app also passed independent release review.

The preceding [Maceo May release](evidence/first-playable/maceo-may-current-release-2026-09-12-001/README.md)
and its publication at [`d48760d8`](https://github.com/pcomans/treasure-island/commit/d48760d8dc7637592ab125f8d8a75809bc6a3ebb)
remain historical. The current app is a fresh export of the accepted 18-unit source.

## Play on another Mac

Copy the complete existing `Treasure Island First Playable.app` bundle from the
path above to the other Mac's `/Applications` folder. It needs no Godot or Node
installation. Then double-click it in Finder, or run:

```sh
open "/Applications/Treasure Island First Playable.app"
```

The bundle is ignored by Git and is therefore not included in a clone. Copy the
whole app, including its embedded data; copying only the executable is insufficient.
The current app passed its native smoke on Apple M2 with Metal / Forward+.
Both arm64 and x86_64 slices passed signature checks. M1 Pro remains the owner
target; neither M1 performance nor Intel runtime is established by those checks.

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
"$GODOT" --headless --editor --path . --quit  # first-checkout import/class discovery
"$GODOT" --path .
```

Copying the existing Godot app is the simplest setup. When it is unavailable,
follow the [vetted Godot install plan](discovery/TRUSTED_INSTALL_PLAN.md).
Matching export templates and `npm ci --ignore-scripts` are for exporting or
development tooling, not for playing source.

For ordinary authoring, edit and run/reload the source project, then inspect the
actual gameplay view. Export is for a reviewed delivery checkpoint; no app export
is needed for each source edit.

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

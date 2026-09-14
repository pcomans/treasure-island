# Treasure Island First Playable

A private macOS Godot first playable of Treasure Island: walk, run, jetpack, and
place a predefined spray tag on eligible exterior walls. It uses the frozen OSM
layout and tracked generated world; cars, interiors, missions, multiplayer, and
public distribution are outside this milestone.

## Current source and release

Current source recognizes **23/213** physical buildings, with **190** not evaluated
and **22 active adapters**. 1212 Mariner,1220 Bayside and1239 Northpoint join the
previous20 accepted units. The older [inactive study checkpoint](discovery/facades/northern-study-source-checkpoint-2026-09-12.md)
remains historical; it does not describe the current playable source.

This checkpoint records the independently released **23/213** app at:

- Private app: `build/northern-1212-1220-1239-exact-current-001/Treasure Island First Playable.app`.
- [Release record](evidence/first-playable/northern-1212-1220-1239-current-release-2026-09-14-001/README.md), including the seven exact app members, source and smoke-test evidence.
- Both signed headless and native runs reached the complete world and passed all14 live attachment checks. Source/mounted checks cover13 component pairs; the app passed separate independent release review.

PCK: `3e88f619730e940aa10272d65d76702bc03c0308c233dfbff9da076587d0330a`.
The fresh export is distinct from the candidate20 and prior current20 apps.
The original app remains preserved; the stable path uses a complete bundle copy,
without another export, signing pass or relaunch. The [20-unit release](evidence/first-playable/northern-1206-1219-current-release-2026-09-14-001/README.md),
[18-unit release](evidence/first-playable/northern-1201-1238-current-release-2026-09-13-001/README.md)
and earlier releases remain historical. The isolated material-finish pilot is not
part of this source or app. All213 independently accepted units remain the goal.

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

## Reproduce facade validation

Playing the tracked generated world does not rebuild its recognition registry.
For registry development, use the pinned Node dependencies from
`package-lock.json` (`npm ci --ignore-scripts`) and run the existing commands:

```sh
node tools/build_facade_recognition_registry.mjs --check
node tools/test_facade_recognition_registry.mjs
node tools/test_facade_runtime_loader_contract.mjs
```

These checks consume declared gameplay evidence as well as source. The current23
preparation found 543 required evidence/provenance inputs; 41 historical1201/1238
PNG/JPEG files were absent from a clean checkout because their local `images/`
directories were ignored. This publication explicitly selects those41
and all52 new-unit gameplay images for Git. Keep these declared files even under
an ignored directory; they are not optional private Street View references or
historical full AVI downloads. Do not bypass a missing-file error or regenerate
authority from incomplete evidence. The retained copy plan records each expected hash; keep that exact set in
source copies used for authority development.

After an intentional authority change, use the existing compiler `--write` path,
refresh its generated-hash native fixtures, then run `--check` and both Node
contracts before the required native checks. Reuse a matching imported class
cache only when its source/dependency bindings match; a fresh clone still needs
the import shown above. Matching Godot export templates and the reviewed private
export preset are required for a delivery build. Preserve candidate versus final
current PCK identity, and copy the complete independently released app bundle.

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
- [Persisted agent and skill entrypoints](CLAUDE.md#persisted-entrypoints) and [current working handoff](NEXT_AGENT_HANDOFF_2026-09-08.md).
- [Test, validation, and export commands](game/tests/README.md).
- [First-playable evidence index](evidence/first-playable/README.md).
- [Active facade catalog](discovery/facades/facade-recognition-catalog.json) and [runtime registry](game/resources/facades/facade-runtime-registry.json).
- [Archived prior README](README_HISTORY_2026-09-12.md) for the full historical release and export record.

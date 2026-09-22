# Treasure Island First Playable

A private macOS Godot first playable of Treasure Island: walk, run, jetpack, and
place a predefined spray tag on eligible exterior walls. It uses the frozen OSM
layout and tracked generated world; cars, interiors, missions, multiplayer, and
public distribution are outside this milestone.

## Current source and release

The current private release recognizes **28 of 213** physical buildings. It adds
1234 Northpoint and 1215 Bayside to the prior 26 accepted units, preserving all
213 identities. The remaining **185 buildings are not evaluated**.

The macOS app is `build/northern-1234-1215-exact-current-001/Treasure Island First Playable.app`.
It passed independent source, package and release review, including the signed app’s
world, movement, privacy and signature checks. See the [release record](evidence/first-playable/northern-1234-1215-current-release-2026-09-22-001/README.md)
for exact hashes, evidence and runtime limits. The complete app has been transferred
to the stable path above; it remains ignored by Git.

The previous [current26 release](evidence/first-playable/northern-1222-1227-1202-current-release-2026-09-15-001/README.md)
remains unchanged. The 1232 study and isolated material pilots are outside this release.
All 213 independently accepted units remain the goal.

## Play on another Mac

Copy the complete existing `Treasure Island First Playable.app` bundle from the
completed release path above to the other Mac's `/Applications` folder. It needs no Godot or Node
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

These checks consume declared gameplay evidence as well as source. Preserve the
current23 checkpoint's previously restored41 historical1201/1238 images and its52
new-unit images. The prior26 batch added60 declared gameplay images for1222/1227/1202; current28 adds34 for1234/1215,
including honestly labeled earlier held studies and sparse movie payloads.
Private dated Street View pixels and full AVI files stay outside Git/export.
Do not bypass missing-file checks or rebuild authority from incomplete evidence;
the retained copy plan binds every selected image and source hash.

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

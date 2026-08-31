# Ferry-spawn staged macOS export evidence

Checked: 2026-08-28

Status: **pass for the isolated staged private app**. The retained app under `build/mac/` and the owner's open GUI window were not accessed, modified, or launched during this round. No non-headless process was run.

## Staged artifact

- App: `build/ferry-spawn-staging/Treasure Island First Playable.app`.
- Godot: cleared project-local `4.7.2.stable.official.ed1daf0bf` with matching `4.7.2.stable` templates.
- Preset: `macOS Private`.
- Export command: `.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --export-release "macOS Private" "build/ferry-spawn-staging/Treasure Island First Playable.app"`.
- Export result: exit `0`, wall `4.74 s`, generated-world packing and Godot built-in ad-hoc signing complete, no errors or warnings.
- Bundle logical file bytes: `176,940,340` (`168.74 MiB`); allocated size `172,812 KiB`.
- Executable: `170,963,648` bytes; SHA-256 `12895a3ae887f614dfd2e1db8c58898911d7bbb1a57713bf6bf77b9a949619e9`.
- PCK: `5,903,852` bytes; SHA-256 `3bdb09ce607f492b299b78d89338e98d27f79ee26d1c164626f27047fc60b2f5`.
- Bundle inventory digest: `e8139b8ec7feb7313f92941817070c91dd1ce7ef0bf74322d7ffa04b9c4707f2` (SHA-256 of the sorted relative-path file-SHA-256 manifest).

## Exact packaged ferry contract

A read-only mount of the staged PCK exited `0` and proved:

- Manifest file SHA-256 exactly `07b8b195e1a05942e38d9bbbcb801394cf9f184051fb5f7a819c75677e46f160`.
- Serialized spawn exactly `[-104.364, 1.000, 786.024]`, yaw `-0.119`.
- `91` virtual files, including all `44` generated-world files.
- Zero packaged paths from raw data, discovery, tooling, dependencies, `.tools`, evidence, build output, install/package records, or export hooks.

This distinguishes the ferry build from the prior app even though the generated artifact-index content SHA remains `5899ebe131bbf05525fedebdac703a321a7aaf95523a57960cb937085068cfaa`.

## Baseline and packaged launch

Proportional source/runtime checks passed with the cleared binary:

- Independent Node generated-world validator: exit `0`, `739` source rows, `38` chunks, `701` physical objects.
- Godot generated-world validator: exit `0`, `735 playable + 4 context` across `38` chunks.
- Final scene/script parse after strengthening packaged smoke: exit `0`.
- Final full-runtime integration: exit `0`; its exact assertions pinned the ferry origin/yaw and camera direction, grounded without recovery, exercised walk/run/camera/recovery/spray/rejections/tag eviction/resumed movement, and cleaned up after fail-closed reload without node leaks.

The staged executable was then run **headlessly only** with `-- --mac-export-smoke`. It exited `0` in `3.35 s`, loaded in `1,337 ms`, and printed the exact ferry transform plus `38/38` chunks, `735+4` coverage, `701` meshes, `21,210` triangles, and `466/466` bodies/shapes. It emitted no engine errors, authored warnings, crash output, or leak warnings.

## Architecture and signing

- Executable architectures: `x86_64 arm64`; native arm64 is present.
- Godot-produced signature: ad-hoc hardened runtime, bundle identifier `local.treasure-island.first-playable`, no Team ID.
- Whole-bundle and explicit arm64 strict `codesign` verification both exited `0` with `valid on disk` and `satisfies its Designated Requirement`.
- Arm64 CodeDirectory full SHA-256: `67242e14a38035d68178db1d0cf51b6ef9679489cc8b33768a02644eef94f79d`.
- `spctl` exited `3` with `rejected`, expected for the approved private ad-hoc/non-notarized path.
- Only `com.apple.provenance` is present recursively; `com.apple.quarantine` is absent.

No Developer ID identity, Apple account, notarization, upload, public package, or trust-policy change was introduced.

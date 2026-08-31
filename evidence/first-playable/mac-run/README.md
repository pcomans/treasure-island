# Private macOS export and launch evidence

Checked: 2026-08-28

Status: **pass for the approved private local launch path**. This is not a public-distribution, Developer ID, or notarization result.

## Build identity

- Godot: `4.7.2.stable.official.ed1daf0bf`, from the cleared project-local installation and matching `4.7.2.stable` templates.
- Preset: `macOS Private`.
- Output: `build/mac/Treasure Island First Playable.app` (retained locally and ignored by Git/Godot).
- Export command: `.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --export-release "macOS Private" "build/mac/Treasure Island First Playable.app"`.
- Final export: exit `0`, wall `4.65 s`, with the PCK and built-in code-sign stages complete and no warning/error output.
- Host: macOS `26.5.2` build `25F84`, arm64, Apple M1 Pro. No device name, serial, hardware UUID, or account identifier was collected.
- Source revision: this project directory is untracked in the outer workspace repository, so there is no project Git commit to claim. Artifact hashes below identify this exact build.
- Generated manifest content SHA-256: `5899ebe131bbf05525fedebdac703a321a7aaf95523a57960cb937085068cfaa`.
- Generated manifest file SHA-256: `82ec5d835965c7f9df0343e92c739c4bc2a6b98190034a2e0c22532e6bf7eb1e`.

The export preset needed four narrow corrections found by the real CLI gate: enable the arm64-required ETC2/ASTC import format; select the official template's available `universal` executable (native arm64 plus x86_64); use `all_resources` rather than an empty selected-resource set; and use Godot's built-in ad-hoc signer. A project-owned editor export hook adds the 44 generated-world files verbatim despite `generated/.gdignore`, then the hook itself is excluded from runtime packaging. Generated data, frozen source data, installation records, and approval documents were not edited.

## Artifact

- Bundle logical file bytes: `176,939,284` (`168.74 MiB`); allocated size: `172,812 KiB`.
- Executable: `170,963,648` bytes; SHA-256 `16a625b812040035ca7db93b7f9b30db56bd6744f4fa4871c54b49e61e753706`.
- PCK: `5,902,796` bytes; SHA-256 `fabff3d456331acfdaffd6be1b15a26497c7e78bff32d349e0588edd3290f893`.
- Bundle inventory digest: `8a1795d95d5b5aa04902caa6e811e47954e94a8d0836b2cb09917fc674394c63` (SHA-256 of the sorted relative-path file-SHA-256 manifest; directories and extended attributes are not inputs).
- Executable architectures: `x86_64 arm64`; this Mac used the native arm64 slice. No Intel certification was performed.
- Bundle identifier: `local.treasure-island.first-playable`; version `0.1.0`.

## Signing and local trust

Godot's final `Code signing bundle` stage produced an ad-hoc hardened-runtime signature. Whole-bundle and explicit arm64 `codesign --verify --deep --strict --verbose=4` both exited `0` with `valid on disk` and `satisfies its Designated Requirement`. The arm64 CodeDirectory full SHA-256 is `0586a480828e113624d8a14cc9d9a8296c1ceb92226552cedfe94b9615e82700`; `TeamIdentifier` is unset and `Signature=adhoc`. The only recursive extended-attribute name is `com.apple.provenance`; `com.apple.quarantine` is absent.

`spctl --assess --type execute --verbose=4` exited `3` with `rejected`, which is expected for this intentionally private ad-hoc bundle without a Developer ID or notarization ticket. No identity, Apple account, upload, public package, or trust-policy change was added. The direct app executable nonetheless launched successfully in both headless and ordinary non-headless local runs below.

## Packaged runtime proof

The exported executable's bounded `--mac-export-smoke` path uses the normal `Main` scene and actual fail-closed `WorldLoader`; normal launches are unchanged. It has its own 30-second failure timeout and exits `0` only after the approved full-world counts and player gate match.

- Headless run 1: exit `0`, wall `3.13 s`, world load `1,331 ms`.
- Headless run 2: exit `0`, wall `1.63 s`, world load `1,328 ms`.
- Both runs: manifest `5899…cfaa`, chunks `38/38`, coverage `735+4`, meshes `701`, triangles `21,210`, bodies/shapes `466/466`, player enabled, no engine errors, authored warnings, crash output, or leak warnings.
- Ordinary non-headless run: exit `0`, wall `12.23 s`, Metal 4.0 Forward+ on the native Apple M1 Pro device, world load `1,374 ms`, and the same full counts/hash/player gate. It opened and closed automatically without user interaction and emitted no errors or leak warnings.

The pre-export four-test baseline also exited `0` throughout. Its real full-runtime integration loaded all generated physics and exercised grounding, walk/run, camera clamps, manual/boundary recovery, eligible wall spray, ground/roof/context rejection, 64-tag eviction, resumed movement, fail-closed reload cleanup, and scene-tree cleanup.

## Package inclusion and exclusion

A read-only mount of the final PCK found `91` virtual files, including exactly `44` files under `res://generated/world/` and the manifest. The packaged loader then verified the manifest artifact index, file sizes/hashes, `38` chunks, coverage ledger, context, and full source-identity contract before reaching `world_ready`.

The same virtual-filesystem audit found zero paths from raw `data`, `discovery`, `tools`, `node_modules`, `.tools`, `evidence`, `build`, install/package records, or the export hook. This proves the runtime contains generated artifacts but not the excluded authoring/audit inputs.

## Remaining checks

- No screenshot, ground-level visual judgment, or ordinary interactive play claim is made. The owner still needs to judge Treasure Island recognition, context appearance, tag appearance, mouse feel, and the complete walk/run/spray/resume loop in the actual app.
- The known P2 workflow gap remains: an initial load-failure screen has no in-app exit control.
- Gatekeeper rejects this local ad-hoc signature as a distribution assessment. The app is suitable only for the approved private local path; copying it to another Mac may require a separate owner-approved signing/distribution decision.

Raw sanitized command results are retained beside this file.

# Car-speed private Mac export

Date: 2026-08-28

App: `/Users/philipp/cowork/treasure-island-game/build/car-speed-staging-2026-08-28-231815/Treasure Island First Playable.app`

Engine/preset: Godot `4.7.2.stable.official.ed1daf0bf`, `macOS Private`

## Result

**PASS for the technical private-package gates; this is the sole current Mac handoff candidate.** The fresh export completed successfully and contains the amended `4 m/s` walk, `20 m/s` held-Shift run, `30 m/s²` acceleration, and `40 m/s²` braking defaults. Generated content remains SHA-256 `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`, with manifest SHA-256 `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`.

The project lead exported the unused staging path with:

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot \
  --headless --path . \
  --export-release "macOS Private" \
  "build/car-speed-staging-2026-08-28-231815/Treasure Island First Playable.app"
```

The command completed the export and built-in code-sign stage successfully; its only warning was the known macOS CA-certificate message.

The project lead observed these package smokes against the exact app binary:

```sh
APP_BINARY="build/car-speed-staging-2026-08-28-231815/Treasure Island First Playable.app/Contents/MacOS/Treasure Island First Playable"
"$APP_BINARY" --headless -- --mac-export-smoke
"$APP_BINARY" --max-fps 60 --rendering-method forward_plus --rendering-driver metal -- --mac-export-smoke
```

Both completed with the exact world totals (`38` chunks, `735 + 4` rows, `729` meshes, `48,381` triangles, `466` bodies/shapes, and `124` vegetation instances), `semantic_palette=pass`, `MAC_EXPORT_MOVEMENT` defaults `4/20/30/40` with `defaults=pass`, jetpack rise `2.751 m`, descent `0.300 m`, and the final package-smoke `PASS`.

The first direct Metal attempt omitted `--max-fps 60`. It reached the exact world, visual, and movement lines, then emitted `MAC_EXPORT_SMOKE_TIMEOUT` before the jetpack check. It is a **non-pass diagnostic**, not passing evidence. Use the explicit `--max-fps 60` form above for deterministic native smoke on this Mac.

## Mounted-PCK audit

An independent direct mount of the exact PCK exited `0` and instantiated the packaged player scene to verify the movement properties. It found:

- `185` virtual files, `47` generated files, and all `38` chunk files;
- generated content and manifest identities above, with every manifest-listed generated file present at its exact hash;
- all `18` approved Poly Haven 1K maps and `15` vegetation imports;
- `124` vegetation placements, including all `22` accepted NAIP shrubs;
- pavement classification covering `208` vehicle-road plus `219` pedestrian sources;
- movement defaults `walk/run/acceleration/braking = 4/20/30/40` and physical Space bound to jetpack;
- active bridge-connected skyline/context resources; and
- private-source scan `private=0` and banned authoring-root scan `banned=0`.

The restricted mount printed the known sandbox-only `user://logs` and macOS CA-certificate messages before its clean audit output; the audit itself passed at exit `0`.

## Artifact identity and platform checks

The bundle contains exactly seven files:

| SHA-256 | Bytes | Bundle-relative path |
|---|---:|---|
| `12210013168f4197b156c151636a81d27285741b3d2cdd138740d09853a9f085` | 1,885 | `Contents/Info.plist` |
| `95d5b6337d39885ab6183c526d94aa07f7b96f323f3fe1305dc1b10575ab028e` | 170,963,648 | `Contents/MacOS/Treasure Island First Playable` |
| `7e50a30efad50208a173203ced60818d693bb61266b75aa10927d1a2adce80cb` | 9 | `Contents/PkgInfo` |
| `0535353bb08c25b8ce5ed9ac7e442a5994f402e0f6cbc4bed668cfc63c2ceac3` | 229 | `Contents/Resources/PrivacyInfo.xcprivacy` |
| `7db5421b6fe91d3955b4d9be59dfea9a1ce43e0d6eac22b52fb985e6d2e6d774` | 54,046,180 | `Contents/Resources/Treasure Island First Playable.pck` |
| `779ff524928785811d6d4c61f47a26491160b1092db9b610e85fcdfd9b2d2b2a` | 67,500 | `Contents/Resources/icon.icns` |
| `9b859d948a999eed1d23bfd54902440cd7f1052dc3a5fcb37936a0eebd4dfb2d` | 3,217 | `Contents/_CodeSignature/CodeResources` |

- Logical size: `225,082,668` bytes; allocated size: `219,824 KiB`.
- Normalized sorted inventory SHA-256: `d53c3019a92fda6b674626ff84f08ed2036ff12624b1670adbda7be75310bd4d`, using `path\0sha256\0bytes\n` records.
- Architectures: Universal `x86_64 arm64`.
- Bundle identifier/version: `local.treasure-island.first-playable`, `0.1.0`.
- Strict deep code-sign verification: `PASS` at exit `0`.
- Signing: ad hoc hardened runtime; no `TeamIdentifier`; arm64 full CodeDirectory SHA-256 `7cedc0b75bbbf58660ba384ee9f771e70ce79a4b696bc3dc0405da7dda532b8c`.
- Entitlement dictionary is empty. `Info.plist` contains no sensitive-permission usage-description keys; `PrivacyInfo.xcprivacy` declares tracking false.
- Recursive extended attributes contain `com.apple.provenance` only; `com.apple.quarantine` is absent.

This is a private local build, not Developer-ID signed or notarized, and makes no public-distribution claim. These checks prove exact package identity, packaged content, privacy exclusions, bounded startup behavior, architecture, and signature validity. They do not prove ordinary mouse/keyboard feel or owner acceptance; complete [`PLAYTEST.md`](../../../PLAYTEST.md) with this exact app.

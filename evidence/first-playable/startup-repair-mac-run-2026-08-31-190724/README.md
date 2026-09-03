# Startup-repaired private Mac export

> **Historical/superseded package record.** These artifact hashes, source pins,
> static checks, and ordinary native-launch observations remain facts about the
> `190724` bytes. The canonical current handoff is
> `build/final-verification-staging-2026-09-03-111725/Treasure Island First Playable.app`;
> see
> [the exact-current final-verification record](../final-verification-2026-09-03-105408/README.md).
> A later outside-project mounted audit intentionally retained this `190724`
> PCK as an expected negative and found the historical packaged
> `res://node_modules/earcut/package.json` leak. Nothing in the newer
> candidate retroactively changes the byte-specific facts below.

- Exported: 2026-08-31
- Ordinary native launch checked: 2026-09-03
- Engine/preset: Godot `4.7.2.stable.official.ed1daf0bf`, `macOS Private`

## Result and proof boundary

**PASS for the startup repair's then-current source contracts, source
main-scene smoke, static private-package integrity, and ordinary native
launch.** This was the repaired handoff at the time:

`$ROOT/build/startup-repair-staging-2026-08-31-190724/Treasure Island First Playable.app`

Repository-relative path: `build/startup-repair-staging-2026-08-31-190724/Treasure Island First Playable.app`.

The repair selects Godot's exact case-sensitive `Dummy` audio driver in `project.godot` before audio-server initialization. That is appropriate for the current first playable because it contains no approved audio behavior, nodes, or assets. It also updates the main-scene smoke oracle to the accepted loaded-world topology of `1,278` meshes, `1,288` surfaces, and `55,067` triangles. It does not change the generated world, player controls, art, collision, navigation, spray behavior, or deferred-feature scope.

At the time of this record, the bundle had **not** passed its own packaged
`--mac-export-smoke`, a mounted-PCK semantic audit, autonomous visual/input
play, or owner acceptance. Those are historical point-in-time nonclaims. The
later mounted audit makes this exact PCK a useful expected negative rather than
a current handoff candidate. The older
`car-speed-staging-2026-08-28-231815` package retains its own historical
package-smoke evidence but does not contain this startup repair or the final
accepted facade attachment stack.

## Source identity and repair boundary

- Git `HEAD`: `08219c9e11c8bd6ce681e48860bb906db07e82f7`
- Git tree: `a02b1c5b645c02d60a18d01e89f6e2f71bb7e04f`
- Tracked repair diff SHA-256: `138d733515a6a1fe29a61d8a32ecf8cf051b8f7b7fa30c1ee5f5fd57b18042cb`
- Exact diff command: `git diff --binary -- game/scripts/main.gd game/tests/README.md project.godot | shasum -a 256`
- Generated content SHA-256: `01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`
- Generated manifest-file SHA-256: `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3`

The tracked diff hash covers exactly the three named tracked paths. It intentionally excludes `INSTALL_LOG.md`, `discovery/RETRO_LOG.md`, later handoff documentation, and the two then-untracked startup-contract files. Those two files are pinned separately below so the limitation is explicit.

| SHA-256 | Source path |
|---|---|
| `305bfb3bf0493c485f48ea8a01d4effccb58d9dd74ad6dc9be78a64ed23981af` | `project.godot` |
| `eee67da945914adbbbe3c50a4a7f62e01cfcb66773abe812a541c22f61f5f642` | `game/scripts/main.gd` |
| `6394134279b4cf8553a258d01f699d367a0ca7432791de73db7734f6cf17dcb4` | `game/tests/README.md` |
| `c83702f06882cc15c61000a6f71c50cb063daabd0942b6c4d4ca08ec49fa4644` | `game/tests/headless_startup_configuration_contract.gd` |
| `e041822fd8754c68bbbb8a0d0df6329fb2c5821694b98c195a0d26ed44d581d2` | `game/tests/headless_startup_configuration_contract.gd.uid` |

## Verification before export

The restored, pinned Godot executable reported `4.7.2.stable.official.ed1daf0bf`. The startup-configuration contract passed the serialized `Dummy` value, loaded project setting, active test-process driver, and corrected `1,278/1,288/55,067` smoke oracle. Scene parse, gameplay, material, generated-world, accepted-facade, and full-runtime contracts also exited `0`. Full runtime loaded all `38` chunks and `729` physical records, instantiated `1,278` meshes, `1,288` surfaces, `55,067` triangles, and `466` body/shape pairs, then exercised walk/run, jetpack rise/slow descent/renewed rise, recovery, and eligible-wall spray behavior.

An initial uncapped headless source main-scene smoke reached the exact world, visual, and movement lines but consumed its 60-second simulation-time watchdog before the jetpack phase while another native Godot process was consuming substantial CPU. It is a non-pass diagnostic. With competing Godot work absent, the unchanged uncapped source smoke invocation `.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . -- --mac-export-smoke` exited `0` in `8.801` wall seconds with `load_ms=6528`, printed the world, visual, movement, and jetpack evidence, and reached final `PASS`. No audio or frame-rate override was supplied. This supports a transient scheduling/contention diagnosis; it does not convert the earlier timeout into passing evidence.

The exact successful export command was:

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot \
  --headless --path . \
  --export-release "macOS Private" \
  "build/startup-repair-staging-2026-08-31-190724/Treasure Island First Playable.app"
```

It exited `0` in `7.892` seconds. The staging path was unused before export. A post-export fingerprint check found the product source inputs unchanged.

## Artifact identity and static checks

The bundle contains exactly seven regular files and no symbolic links:

| SHA-256 | Bytes | Bundle-relative path |
|---|---:|---|
| `12210013168f4197b156c151636a81d27285741b3d2cdd138740d09853a9f085` | 1,885 | `Contents/Info.plist` |
| `5e1ef866c3e89d06b3a2d0c802bd3e3a4993d28f6905e2c9adc6b6a63b444dc4` | 170,963,648 | `Contents/MacOS/Treasure Island First Playable` |
| `7e50a30efad50208a173203ced60818d693bb61266b75aa10927d1a2adce80cb` | 9 | `Contents/PkgInfo` |
| `0535353bb08c25b8ce5ed9ac7e442a5994f402e0f6cbc4bed668cfc63c2ceac3` | 229 | `Contents/Resources/PrivacyInfo.xcprivacy` |
| `57bd62fdacacbc62c5443506e2ee5a4e5e96675bbb43ff36f4e5e4522115fee5` | 55,789,272 | `Contents/Resources/Treasure Island First Playable.pck` |
| `779ff524928785811d6d4c61f47a26491160b1092db9b610e85fcdfd9b2d2b2a` | 67,500 | `Contents/Resources/icon.icns` |
| `3cf979991fb2e9c76d8f1db29443f41571ff1bac3e1144c619c510ee96a934a3` | 3,217 | `Contents/_CodeSignature/CodeResources` |

- Logical file size: `226,825,760` bytes.
- Normalized sorted seven-file inventory SHA-256: `455067fbab49d16cd4a2f7244e272774b7f78fabc59857cd0987f1cf8615a0c3`, using `path\0sha256\0bytes\n` records.
- Architectures: Universal `x86_64 arm64`.
- Strict deep signature verification: exit `0`.
- Per-architecture strict verification for `arm64` and `x86_64`: exit `0` for both.
- `Info.plist` and `PrivacyInfo.xcprivacy`: `plutil -lint` exit `0` for both.
- Entitlements: empty; recursive extended-attribute scan: empty.

The bundle has Godot's ad-hoc hardened-runtime signature. It is not Developer ID signed or notarized and is not claimed to pass Gatekeeper assessment for distribution. It contains no TeamIdentifier or sensitive-permission usage-description keys, and its privacy manifest declares tracking false. It is only for the approved private local use.

## Historical ordinary native launch on the verifier Mac

On 2026-09-03, a plain `/usr/bin/open` of this exact bundle returned `0` without `--audio-driver Dummy` or any other launch override. It created native arm64 PID `39577` with parent PID `1` and an argument vector containing only the exact repaired executable path. The host `_audiomxd` service remained stopped, which had previously left the pre-repair app waiting synchronously in `AudioOutputUnitStart`.

CoreGraphics reported one on-screen, alpha-1, layer-0 game window at `1280×832`. The process remained healthy for more than three hours, and a timed stack sample showed active AppKit/Metal/IOSurface rendering with no match for the prior `AVAudioSession`/`AudioOutputUnitStart` wait. This proves that the serialized `Dummy` default bypasses the affected CoreAudio startup path during an ordinary native launch.

The ordinary process's default Godot log remained empty, so this launch record does not independently prove an application-level `world_ready` marker or exercised player input. The verifier host also reported Screen Recording and Accessibility preflight as unavailable, preventing autonomous screenshot and control review without a user-managed permission change. The exact repaired app's autonomous visual/input review and owner walk/run/jetpack/spray/recognition verdict therefore remain pending. A successful process, window, renderer loop, source smoke, or static audit does not substitute for those acceptance gates.

## Verification that remained at this historical snapshot

At the time, the smallest proposed package-runtime follow-up was to run the
exact binary with its normal main scene:

```sh
APP_BINARY="build/startup-repair-staging-2026-08-31-190724/Treasure Island First Playable.app/Contents/MacOS/Treasure Island First Playable"
"$APP_BINARY" --headless -- --mac-export-smoke
"$APP_BINARY" --max-fps 60 --rendering-method forward_plus --rendering-driver metal -- --mac-export-smoke
```

These commands are retained for historical reproducibility, not as pending
current-candidate gates. The `111725` successor passed its headless packaged
smoke and an identical-command warm-state Metal smoke; its first retained native
invocation timed out after world/visual/movement readiness. Ordinary owner
review of that successor remains in [`PLAYTEST.md`](../../../PLAYTEST.md).
Neither the old nor new record authorizes changing the accepted world or
starting another facade target.

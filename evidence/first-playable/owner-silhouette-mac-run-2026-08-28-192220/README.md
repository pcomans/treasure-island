# Solid-silhouette private Mac export evidence

Date: 2026-08-28  
App: `/Users/philipp/cowork/treasure-island-game/build/owner-silhouette-staging-2026-08-28-192220/Treasure Island First Playable.app`  
Engine/preset: Godot `4.7.2.stable.official.ed1daf0bf`, `macOS Private`

## Result

**PASS; this is the sole current private Mac handoff.** The exact current source exported at exit `0` in `5.22 s` to a fresh unused directory. Historical builds were not overwritten or deleted. The bundle's own executable then ran the bounded headless `--mac-export-smoke`, loaded the normal main scene, and self-closed at exit `0` in `6.76 s`. No visible Metal run was repeated; the current source Metal proof remains [`owner-silhouette-rendered-2026-08-28-1921`](../owner-silhouette-rendered-2026-08-28-1921/README.md).

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . \
  --export-release "macOS Private" \
  "build/owner-silhouette-staging-2026-08-28-192220/Treasure Island First Playable.app"

"build/owner-silhouette-staging-2026-08-28-192220/Treasure Island First Playable.app/Contents/MacOS/Treasure Island First Playable" \
  --headless -- --mac-export-smoke
```

The smoke loaded generated content `1c9fd3ec5a814e48a696267e9ec3b0318543b8b84df407baee6d18b164b03aeb` at the exact ferry transform, with `38/38` chunks, `735+4` rows, `701` meshes, `40,826` triangles, `466/466` bodies/shapes, and the current `102`-instance / `15`-asset / `19`-batch vegetation contract. World load was `3,402 ms`; visual defaults and physical-Space rise/slow descent passed.

```text
MAC_EXPORT_WORLD_READY: hash=1c9fd3ec5a814e48a696267e9ec3b0318543b8b84df407baee6d18b164b03aeb spawn=(-104.364,3.457,786.024) yaw=-0.119 chunks=38/38 coverage=735+4 meshes=701 triangles=40826 bodies=466 shapes=466 vegetation=102 seed=1414092337 batches=19 load_ms=3402
MAC_EXPORT_VISUAL: ambient_source=2 ambient_color=(0.71,0.77,0.82,1.00) ambient_energy=0.65 sky_contribution=0.00 camera_pivot_y=2.00 spring_length=5.50 pitch=-8.0deg semantic_palette=pass
MAC_EXPORT_JETPACK: rise=2.751m ascent_velocity=5.000mps slow_descent=0.300m minimum_velocity=-1.500mps
PASS: packaged main scene reached full world_ready, enabled the player, and exercised jetpack rise/slow descent
```

## PCK skyline and privacy audit

The current source asset is `game/resources/textures/context/sf_skyline_owner_silhouette_final.png`, `2212x340` with alpha, SHA-256 `9c499ca3db08769142aac69b61e7d8fdf2aa84cd084b6716a19e7c504ba0b0c5`. The active scene SHA-256 is `3329929cfc90c749ca46cd161dc95d74dd352fece9fab036b7b9417cbb6af831`; the focused gameplay contract SHA-256 is `c949ff097fce7af9b2fcb6e6b070378f081f9b23aafbe348425f3c5fde76472a`.

The direct mounted-PCK audit exited `0`. It verified all `46` generated-world files against the exact manifest, loaded the packaged world scene, and proved that its active texture resource is the solid silhouette at `2212x340` on the unchanged `1950x300` quad at `(-2500,132.5,750)`:

```text
ACTIVE_SILHOUETTE_PACKAGE_FILE: path=res://.godot/imported/sf_skyline_owner_silhouette_final.png-7dae90868c6463ec9988a547b1e5ccac.ctex bytes=2906 sha256=9927d12eb5a01a975bbff91d6106392a2edad314920a9d1d904c1c34a9a43ab5
ACTIVE_SILHOUETTE_PACKAGE_FILE: path=res://game/resources/textures/context/sf_skyline_owner_silhouette_final.png.import bytes=221 sha256=bc5bfca00876e49bb52a228fbd3a4fd8d6035c5c7e31a44bdca9b44ce0a196ca
OWNER_SILHOUETTE_PACKAGE_AUDIT: files=146 generated=46 chunks=38 logical_texture=res://game/resources/textures/context/sf_skyline_owner_silhouette_final.png source_sha256=9c499ca3db08769142aac69b61e7d8fdf2aa84cd084b6716a19e7c504ba0b0c5 imported_size=2212x340 billboard_size=1950x300 billboard_position=(-2500.0,132.5,750.0) private_paths=0 active_paths=2 fallback_paths=4
PASS: packaged PCK uses the exact solid silhouette, excludes private owner-photo/source/generated-variant/download paths, and contains only the disclosed inert prior runtime fallbacks
```

Full virtual-path enumeration and a raw case-insensitive PCK byte scan found no `IMG_7169`, `.HEIC`, `source_assets/context/sf_skyline_photo/`, `generated_variants/`, or Downloads path. The owner's full source image, original HEIC, and all ignored generated variants are absent.

The unchanged `all_resources` policy retains two inert prior runtime resources: the processed outline (`392,318`-byte `.ctex` plus `219`-byte descriptor) and the project-authored SVG (`354`-byte `.ctex` plus `198`-byte descriptor). Neither is referenced by the active scene, neither exposes the full owner photo or authoring tree, and no export/asset policy was changed.

## Artifact identity

- Executable: `170,963,648` bytes; SHA-256 `45dfeb07ea6b43184f26f7c41f3642a9e8cf8a00f384d468ae188af4ef2d90ab`.
- PCK: `24,508,168` bytes; SHA-256 `a847a7755be29e4927d786603e368d622984f86b474975b2e19f90c04120d455`.
- Sorted seven-file bundle descriptor: SHA-256 `da7482502020b1eca8f4418476c308221957df889e60952cbe6a26fb49d95cdd` (`path\0sha256\0bytes\n`).
- Bundle: `195,544,656` logical bytes; `190,980 KiB` allocated.
- Architectures: universal `x86_64 arm64`.
- Strict deep code-sign verification: exit `0`, valid on disk and satisfies its Designated Requirement.
- Signature: Godot ad-hoc hardened runtime, no TeamIdentifier; arm64 full CodeDirectory SHA-256 `7a9e7acf9248a2ebc3f321bfe3f4f83d6ec39bc103d5a8be37f5d20b14274b90`.
- Bundle identifier/version: `local.treasure-island.first-playable`, `0.1.0`.

The restricted process could not rotate `user://logs` or read macOS system CA certificates. Those known local-sandbox warnings did not affect export, packaged loading, privacy audit, signing, or exit status. This remains a private ad-hoc build, not a notarized public release. No download, installation, account access, or `INSTALL_LOG.md` change occurred.


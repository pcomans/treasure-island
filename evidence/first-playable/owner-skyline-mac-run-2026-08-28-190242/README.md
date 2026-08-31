# Owner-skyline private Mac export evidence

Date: 2026-08-28  
App: `/Users/philipp/cowork/treasure-island-game/build/owner-skyline-staging-2026-08-28-190242/Treasure Island First Playable.app`  
Engine/preset: Godot `4.7.2.stable.official.ed1daf0bf`, `macOS Private`

## Result

**PASS for the current private Mac handoff.** The exact current source exported into a fresh unused directory at exit `0` in `5.01 s`; historical builds were not overwritten or deleted. The app binary's bounded headless `--mac-export-smoke` then loaded the normal main scene and self-closed at exit `0` in `6.69 s`. No visible Metal smoke was run and no live owner window was touched.

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . \
  --export-release "macOS Private" \
  "build/owner-skyline-staging-2026-08-28-190242/Treasure Island First Playable.app"

"build/owner-skyline-staging-2026-08-28-190242/Treasure Island First Playable.app/Contents/MacOS/Treasure Island First Playable" \
  --headless -- --mac-export-smoke
```

The packaged smoke reported generated content `1c9fd3ec5a814e48a696267e9ec3b0318543b8b84df407baee6d18b164b03aeb`, the exact ferry spawn, `38/38` chunks, `735+4` rows, `701` meshes, `40,826` triangles, `466/466` bodies/shapes, and the current `102`-instance / `15`-asset / `19`-batch vegetation contract. Visual defaults and the physical-Space jetpack gate passed; world load was `3,297 ms`.

```text
MAC_EXPORT_WORLD_READY: hash=1c9fd3ec5a814e48a696267e9ec3b0318543b8b84df407baee6d18b164b03aeb spawn=(-104.364,3.457,786.024) yaw=-0.119 chunks=38/38 coverage=735+4 meshes=701 triangles=40826 bodies=466 shapes=466 vegetation=102 seed=1414092337 batches=19 load_ms=3297
MAC_EXPORT_VISUAL: ambient_source=2 ambient_color=(0.71,0.77,0.82,1.00) ambient_energy=0.65 sky_contribution=0.00 camera_pivot_y=2.00 spring_length=5.50 pitch=-8.0deg semantic_palette=pass
MAC_EXPORT_JETPACK: rise=2.751m ascent_velocity=5.000mps slow_descent=0.300m minimum_velocity=-1.500mps
PASS: packaged main scene reached full world_ready, enabled the player, and exercised jetpack rise/slow descent
```

## Skyline and privacy audit

The current source PNG is `2212x340` RGBA and hashes to `1939151e1098c4935d1a5fd230bc9a692c5484fc93fc5d5bd4064da0678927d4`. The active scene SHA-256 is `0d962a4ec53184b26b0ee5ace46d296d73576433e0cd03dda9563846b822f383`; it references only `res://game/resources/textures/context/sf_skyline_owner_outline_final.png` for the skyline and configures a `1950x300` quad at `(-2500,132.5,750)`. The source gameplay-contract hash is `b4fa8b260cf9a5fc465639924f5a9780b8f92b1a8e752e14a21d94ea1e80c9ee` and pins the same texture hash, imported size, quad size, and transform.

The mounted-PCK audit exited `0`, verified all `46` generated-world files against the exact manifest (`38` chunks), loaded the exported world scene, and observed:

```text
OWNER_RUNTIME_PACKAGE_FILE: path=res://.godot/imported/sf_skyline_owner_outline_final.png-c10cef843d812f44b02d5113bf8c28a7.ctex bytes=392318 sha256=6cb904589ce3ed90194d900c40f10c7a45fb042b1fb096903d6fa088fdaaae9e
OWNER_RUNTIME_PACKAGE_FILE: path=res://game/resources/textures/context/sf_skyline_owner_outline_final.png.import bytes=219 sha256=355c1a2fde5ba29852aebbaf32015ad998ffe56baf2575eaaf947bb1b1259648
OWNER_SKYLINE_PACKAGE_AUDIT: files=144 generated=46 chunks=38 logical_texture=res://game/resources/textures/context/sf_skyline_owner_outline_final.png source_sha256=1939151e1098c4935d1a5fd230bc9a692c5484fc93fc5d5bd4064da0678927d4 imported_size=2212x340 billboard_size=1950x300 billboard_position=(-2500.0,132.5,750.0) private_paths=0 owner_runtime_paths=2 historical_paths=2
PASS: packaged PCK uses the exact owner-outline skyline, excludes private owner-photo/source/download paths, and contains only the disclosed inert historical SVG fallback pair
```

The PCK uses Godot's normal imported representation of the final PNG: a logical `.png.import` entry plus its compiled `.ctex`; the active loaded texture retains the requested logical PNG resource path. The pre-export source hash above identifies the exact input bytes.

Both full virtual-path enumeration and a raw case-insensitive PCK byte scan found no `IMG_7169`, `.HEIC`, `source_assets/context/sf_skyline_photo/`, `generated_variants/`, or Downloads path. Thus the full `17,286,623`-byte owner-photo PNG, the original HEIC, both generated variants, and the entire ignored authoring tree are absent.

Per project-lead decision, the unchanged `all_resources` preset may retain the harmless unreferenced project-authored fallback. The exact inert pair is disclosed:

- `res://game/resources/textures/context/sf_skyline.svg.import`: `198` bytes, SHA-256 `52f26ad1de50f5e18bde48be0d57be896eb36bfb64e31cfdf646bc8cd126d342`.
- `res://.godot/imported/sf_skyline.svg-d0d4627eb45ced9388b172b1b3f507cb.ctex`: `354` bytes, SHA-256 `d8fdabddf93f790119a1be6cac7bef0e9c19799054d09ebf948792f4103baa71`.

It is not referenced by the active scene and contains no owner-photo data. Export and asset policy were not changed.

## Artifact identity

- Executable: `170,963,648` bytes; SHA-256 `913a3890526880e9c0d62491de3cb2b582a39790ac9736fcc17dfe5bc8959bfe`.
- PCK: `24,504,704` bytes; SHA-256 `91ad0c88ca58299b1317c94fffc3967b4314d3d80bcfccfde61daa6f37809790`.
- Sorted seven-file bundle descriptor: SHA-256 `cbb9d0210033e6f07841a3cec321857d850dd49e53854392e043308ab3db8f6d` (`path\0sha256\0bytes\n`).
- Bundle size: `195,541,192` logical bytes; `190,976 KiB` allocated.
- Architectures: universal `x86_64 arm64`.
- Signing: strict deep verification exit `0`; Godot ad-hoc hardened runtime, no TeamIdentifier; arm64 full CodeDirectory SHA-256 `3fa31f616fb9682bb28bdb6b8737f8e223382375e8fdbdbe01d0946072d4858e`.
- Bundle identifier/version: `local.treasure-island.first-playable`, `0.1.0`.

The only runtime warnings were the restricted-process inability to rotate `user://logs` and read macOS system CA certificates. They did not affect export, local resource loading, signing, or either passing gate. This remains a private ad-hoc build, not a notarized public-distribution artifact.

No download, installation, account access, or acquisition occurred; `INSTALL_LOG.md` was not changed.


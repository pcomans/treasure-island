# Bridge-connected skyline private Mac export

Date: 2026-08-28  
App: `/Users/philipp/cowork/treasure-island-game/build/owner-bridge-connected-staging-2026-08-28-194611/Treasure Island First Playable.app`  
Engine/preset: Godot `4.7.2.stable.official.ed1daf0bf`, `macOS Private`

## Result

**PASS; this is the sole current private Mac handoff.** The app was exported to a fresh unused directory. A direct VSync-disabled Metal/Forward+ packaged smoke loaded the normal main scene, reached the exact ferry world, validated visual defaults and physical Space, exercised jetpack rise/slow descent, and exited `0`:

```text
MAC_EXPORT_WORLD_READY: hash=1c9fd3ec5a814e48a696267e9ec3b0318543b8b84df407baee6d18b164b03aeb spawn=(-104.364,3.457,786.024) yaw=-0.119 chunks=38/38 coverage=735+4 meshes=701 triangles=40826 bodies=466 shapes=466 vegetation=102 seed=1414092337 batches=19 load_ms=4293
MAC_EXPORT_VISUAL: ambient_source=2 ambient_color=(0.71,0.77,0.82,1.00) ambient_energy=0.65 sky_contribution=0.00 camera_pivot_y=2.00 spring_length=5.50 pitch=-8.0deg semantic_palette=pass
MAC_EXPORT_JETPACK: rise=2.751m ascent_velocity=5.000mps slow_descent=0.300m minimum_velocity=-1.500mps
PASS: packaged main scene reached full world_ready, enabled the player, and exercised jetpack rise/slow descent
```

The direct headless form repeatedly reached the exact world/visual contract but exhausted its internal timer before finishing the physics phase during the unusually slow cold run. It is not counted as a pass; the complete packaged Metal run above is authoritative.

## Skyline, bridge, and privacy audit

The independent mounted-PCK audit exited `0` and proved:

- Active source texture SHA-256 `9c499ca3db08769142aac69b61e7d8fdf2aa84cd084b6716a19e7c504ba0b0c5`, imported at `2212x340`.
- Active billboard `3900x600 m` at `(-1875,264.85,4306.4)`.
- Western bridge position `Vector3(417.375,0,1643.827)`, yaw `2.437807`, and scale `Vector3(1.09506,0.55,1.09506)` remain unchanged.
- No `IMG_7169`, HEIC, full owner source, ignored source-photo tree, generated variant, or Downloads path appears in the mounted package or raw PCK scan.

The current 12-frame source Metal evidence is [the bridge-connected rendered pass](../owner-bridge-connected-rendered-2026-08-28-1944-retry/README.md).

## Artifact identity

- Executable SHA-256: `00de6f54351e7da9019113b2969a179709c032e29622b08de1ca0f34b0f0e7f7`.
- PCK SHA-256: `f89e348bf401c211bfe3213265f5cc474044069450eb521686508d404c8bb531`.
- Sorted seven-file bundle inventory SHA-256: `fbaa039028a5961dc5fbc9b13a8e744ced026a48c1c9b12ceef6da879d086537`.
- Architectures: universal `x86_64 arm64`.
- Strict deep code-sign verification: valid on disk and satisfies its Designated Requirement.
- arm64 full CodeDirectory SHA-256: `c19ef46fdc803fe92dee3b5ecf8e77b780c21b885299592263faed22f5e397fd`.

This is a private ad-hoc build, not a notarized public release. No download, installation, account access, gameplay change, or historical-build deletion occurred.

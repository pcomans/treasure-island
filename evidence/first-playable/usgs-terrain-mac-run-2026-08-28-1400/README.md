# USGS terrain private Mac export evidence

Date: 2026-08-28  
App: `/Users/philipp/cowork/treasure-island-game/build/usgs-terrain-final-staging-2026-08-28-1400/Treasure Island First Playable.app`  
Engine: Godot `4.7.2.stable.official.ed1daf0bf`

## Artifact identity

- Executable SHA-256: `21d97e2dd63672aa0d7fb2b6324eb99b3b8358027ca1e7afd80d74c2c0202f8f` (`170,963,648` bytes)
- PCK SHA-256: `64968e434d9b9aca63e52507d1a9dffa9974253d70c0261f6e21307428d4a5a0` (`21,173,308` bytes)
- Allocated bundle size: `183M`
- Architectures: universal `x86_64 arm64`
- Strict deep signature verification: exit `0`, valid on disk and satisfies its Designated Requirement

The export preset excludes `data/` and `third_party_staging/`. The packing inventory and a direct PCK string-path check found no `third_party_staging` path. The generated manifest names the frozen terrain source and hash for fail-closed provenance, but the 10 MB raw GeoTIFF and research previews are not packaged.

## Packaged smoke

The clean outside-sandbox headless packaged main-scene smoke exited `0`:

```text
MAC_EXPORT_WORLD_READY: hash=77a154d5d52815a68de57be6ebe8ac222b859649a7b741416d46f1ddbce3e804 spawn=(-104.364,4.457,786.024) yaw=-0.119 chunks=38/38 coverage=735+4 meshes=701 triangles=33055 bodies=466 shapes=466 load_ms=2248
MAC_EXPORT_VISUAL: ambient_source=2 ambient_color=(0.71,0.77,0.82,1.00) ambient_energy=0.65 sky_contribution=0.00 camera_pivot_y=2.00 spring_length=5.50 pitch=-8.0deg semantic_palette=pass
MAC_EXPORT_JETPACK: rise=2.751m ascent_velocity=5.000mps slow_descent=0.300m minimum_velocity=-1.500mps
PASS: packaged main scene reached full world_ready, enabled the player, and exercised jetpack rise/slow descent
```

A normal Metal 4.0 / Forward+ launch on Apple M1 Pro also exited `0` with the same world, visual, and jetpack values when launched with `--disable-vsync`; its measured world load was `2,189 ms`. The first VSync-enabled attempt reached exact world and visual readiness but hit the 30-second smoke watchdog before the scripted physics phase. This was a timing-only launch-harness limitation: the VSync-disabled native run and independent headless packaged run both completed the identical jetpack assertions.

This proves the exact app loads and its packaged automated contract passes. It does not replace ordinary owner play or visual acceptance.

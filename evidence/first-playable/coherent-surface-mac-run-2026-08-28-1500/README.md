# Coherent-surface private Mac export evidence

Date: 2026-08-28  
App: `/Users/philipp/cowork/treasure-island-game/build/coherent-surface-final-staging-2026-08-28-1500/Treasure Island First Playable.app`  
Engine: Godot `4.7.2.stable.official.ed1daf0bf`

## Artifact identity

- Executable SHA-256: `fc4e5cb3701da79bc56e808622e06632693008a6cd4355631aaac131b66815ab` (`170,963,648` bytes)
- PCK SHA-256: `ed29f8c8b3bd0734125493ae3369a6de79727beb4cb72c8fd55deb6e34d7f025` (`23,720,860` bytes)
- Sorted bundle descriptor SHA-256: `f0ccee37a593f3b643e3d5cb9e2cd10b28c5bb839f38f77ef8852547ea15079d` (`path\0sha256\0bytes\n` records)
- Allocated bundle size: `186M`
- Architectures: universal `x86_64 arm64`
- Strict deep signature verification: exit `0`; valid on disk and satisfies its Designated Requirement

The export used a fresh uniquely named directory. Earlier bundles were not overwritten. The export preset excludes `data/` and `third_party_staging/`; a direct PCK path-string check found no `third_party_staging` path. The generated manifest retains the source terrain path/hash as provenance, but the raw TIFF and research previews are not packaged.

## Packaged smoke

The packaged headless main-scene smoke exited `0`, loaded content `07eee769e2b888a330546360d9a6cc9f37d88660d8f03ad93a46260918de1470` at foot-level spawn `(-104.364,3.457,786.024)`, instantiated 38/38 chunks, 735+4 rows, 701 meshes, 40,826 triangles, and 466 bodies/shapes, then passed visual defaults and the held-Space rise/released slow-descent jetpack gate. The recorded load was `3,151 ms`.

A normal Metal 4.0 / Forward+ smoke on Apple M1 Pro also exited `0` with the same exact world, visual, and jetpack gates; its measured load was `4,130 ms`. VSync was disabled only for this bounded noninteractive smoke. The 60-second watchdog did not fire.

An independent root recheck recomputed the executable and PCK hashes above, passed strict deep code-signature verification, and repeated the packaged headless smoke at exit `0` with the exact same content/spawn/count contract. A second independent headless recheck is retained as [`packaged-headless-gate.log`](packaged-headless-gate.log). Restricted sandbox launches can emit `user://logs` and CA-certificate warnings; those environment-only messages did not affect a game gate. This evidence proves the exact app loads and its automated packaged contract passes; it does not replace ordinary owner play.

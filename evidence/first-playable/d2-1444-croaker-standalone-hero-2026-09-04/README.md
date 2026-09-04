# 1444 Croaker Court standalone exact-footprint hero — technical evidence

Date: 2026-09-04  
Target: `w95934117`, 1444 Croaker Court  
Status: **source/package/evidence contracts pass; recognition and believability pending independent bar-raiser review**

This is a standalone-only exterior prototype. It is not registered, attached to
`WorldChunkBuilder`, or present in the live island. The neutral capture fixture
directly instantiates the exact frozen wall/roof baseline, the exact-source
prototype, the stock player/camera, and a flat walkable ground. It deliberately
does not claim live-world placement, terrain integration, or final navigation
and spray ownership.

## Entity-specific recognition hypothesis

Only mapped public WSW runs `8,9,11,12,15,16,17` receive the reversible 1444
schedule. Runs `8/9` form the broad mostly blank upper end over a deep opaque
undercroft proxy; run `11` receives sparse paired openings; run `16` receives a
sparser return; run `17` carries a narrow two-level recessed balcony stack.
Runs `12/15` remain deliberately quiet. All other runs
`0..7,10,13,14,18..21` preserve the exact source wall as a neutral module-free
shell. Broad eaves and a shallow dark exact-plan gable complete the documented
public-side hierarchy. This schedule is authored in the 1444 factory, not the
shared Site-12 kit and not copied from 1441.

The frozen confusion set is 1431 Halibut Court `w95934135`, 1436 Chinook Court
`w95934137`, and 1449 Croaker Court `w95934120`. An independent reviewer should
decide whether the prototype reads top-1 as 1444 from at least two supported
cues without using the address, source ID, location, or ochre hue alone.

All opening, void, pier, balcony, rail, eave, and roof-rise dimensions/counts
are reversible production inference. There is no interior, transparent or
operable glazing, exact product/substrate, as-built, recognition, or
believability claim.

## Exact source, materials, and ownership

- Source geometry: `52c844…dcc4`; wall record `149748…fffb6`; roof record
  `a4e695…0eb7a`. All 22 source wall-run edges, bottom/top heights, and roof XZ
  plan remain exact.
- The approved warm-ivory GenAI albedo is reused byte-for-byte as a neutral
  micro-surface under a reversible ochre-tan scalar tint. Geometry UVs are in
  metres and material scale `0.333333` gives an approximately `3 m` repeat. No
  new image or normal/roughness/AO/height/displacement bitmap was generated.
- The dark roof/eave surrogate reuses only the existing CC0 Poly Haven bitumen
  albedo at a `5 m` repeat; it does not assert a roof product.
- Topology is `11` meshes/surfaces and `798` visual triangles: `44` exact wall,
  `10` exact-plan gable, and `744` noncolliding relief triangles. One structural
  body/shape contains the same `54` wall+roof triangles (`162` face vertices).
  There are zero navigation regions and zero spray owners. Deterministic
  signature: `8df0202796d56c019b6b3ddb72916808b72316d2d0edee0ba7425b77efa2b127`.

See `source-contract.json` and `technical-contract.json` for the complete
authority, run, inference, batch, collision, and ownership contracts.

## Native decision evidence

The six PNGs are uncropped `1440×900` Forward+/Metal frames on Apple M2. Each
baseline/prototype pair uses the exact same physics-grounded stock-player pose
and camera transform. The third pair repeats the oblique view under materially
changed light. The full entity is in frame, the normal reticle/player are
visible, and no debug panels, labels, or source photography appear.

The Motion JPEG AVI is `1280×800`, 191 frames at 30 FPS, 6,078,080 bytes, SHA-256
`3afe7d57f60d8c2b7330f49fa3bc414d915404a23ea774778407fa58710770b4`.
Its declared review interval contains 240 consecutive physics samples / 4.0 s
under stock `move_right` with no run input: 15.867 m, all grounded, zero
recovery, zero harness transform writes after input began, and unchanged camera
orientation. The 4×4 PNG sheet samples 13 frames and is a derived convenience;
the AVI is authoritative for motion, recurrence, seams, and shimmer.

Exact hashes, transforms, first-hit receivers/runs, source/fixture inputs, and
frame windows are in `capture-manifest.json`, `motion-capture.json`, and
`evidence-contract.json`. The executor performed technical checks only and did
not grade visual quality.

## Package boundary

Source and outside-checkout mounted contracts pass. The retained review PCK is
`build/d2-1444-croaker-standalone-hero-review/Treasure Island First Playable.pck`,
67,966,108 bytes, SHA-256
`4b5ecd7e333f33775355ff487c3dcfbbaedb56bc40f502f10cad448e013a9d0f`.
It rebuilds the exact signatures/topology, loads every material dependency, and
contains neither discovery nor evidence payloads.

The canonical private preset currently excludes the GenAI authoring texture
directory. The first direct mount therefore correctly failed on the stucco
dependency. The retained PCK was exported from an isolated byte-identical copy
with only that texture-directory exclusion removed; discovery/evidence
exclusions stayed intact and the shared preset was not edited. A later
production owner must make that dependency package-safe before live promotion.
See `package-contract.json` for the exact boundary.

## Independent review request

Open all six PNGs at original detail, then watch the complete declared AVI
review interval. Decide whether the after views are recognizably and believably
1444 against the three frozen confusion targets. Check especially the blank
upper/undercroft hierarchy, sparse return versus continuous-window rhythm,
far-end balcony stack, eave/roof silhouette, distracting texture repetition,
obvious seams, baked-light appearance, shimmer, rail noise, clipping, and
collision-visible disagreement. Minor recurrence or mismatch is acceptable;
obvious seams, baked lighting, or distracting repetition are not. Do not infer
acceptance from the technical PASS results.

## Reproduction

```text
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --audio-driver Dummy --script game/tests/headless_d2_1444_croaker_standalone_hero_contract.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --audio-driver Dummy --script game/tests/headless_d2_1444_croaker_standalone_hero_package_contract.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/d2_1444_croaker_standalone_hero_capture.gd -- --capture-mode=stills
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1280x800 --write-movie evidence/first-playable/d2-1444-croaker-standalone-hero-2026-09-04/d2-1444-croaker-wsw-stock-walk.avi --fixed-fps 30 --script game/tests/d2_1444_croaker_standalone_hero_capture.gd -- --capture-mode=motion
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --audio-driver Dummy --script game/tests/headless_d2_1444_croaker_standalone_hero_evidence_contract.gd
```

Any future live owner must intercept the exact wall+roof pair together before
generic visual/collision creation, replace rather than stack the fallback shell,
restore explicit validated spray ownership, and separately review navigation.

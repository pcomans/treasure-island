# Corrected deterministic vegetation evidence

This is the current two-frame source-project evidence for the sparse, visual-only vegetation pass. Godot 4.7.2 rendered both `1440x900` frames through Forward+/Metal on the Apple M1 Pro after the generated-world, asset, terrain-grounding, and runtime-count gates passed.

- Seed: `1414092337`.
- Logical placements: `102` using all `15` curated Kenney Nature Kit GLBs.
- Palette: `28` broadleaf trees, `21` conifers, `21` ornamental grasses, `13` palms, and `19` shrubs.
- Runtime draw structure: `19` `MultiMeshInstance3D` batches and `18,858` instanced source triangles. Vegetation creates zero physics bodies or shapes; the existing world remains `466` bodies/shapes.
- Full-runtime load measurement from the same generated content: `4,731 ms` and `62.8 MiB` static memory. These are whole-scene observations, not an isolated vegetation delta.
- Content SHA-256: `1c9fd3ec5a814e48a696267e9ec3b0318543b8b84df407baee6d18b164b03aeb`.
- Manifest SHA-256: `fa74ea20f46db226d2aacab76135e76e4928f2619217d18811a3e213c577ed8b`.
- Vegetation artifact SHA-256: `9b8d4000da3402428167a727a62b12175df159a1e8ae651c8a0ed23d58db5738`.

The corrected capture anchor `x/z = -350/140` is owned by serialized playable land only: it is not in a terrain/shoreline overlay, road/path, or building footprint. The Node and Godot validators independently reject any plant within `3 m` of a serialized `terrain_overlay`; generation also excludes every frozen OSM terrain/shoreline geometry, including wetland, marina, sand, pier, and breakwater. The observed minimum overlay clearance is `3.625 m`. Visual inspection of both frames confirmed that the cyan wetland contains no plants and that visible palm trunks stay off the gray road ribbons.

Files:

- `11-vegetation-south-ground.png`: physics-grounded at terrain `y = 2.884 m`, measured clearance `0.0003 m`, no recovery.
- `12-vegetation-south-aerial.png`: representative elevated view of the deliberate south palm row from the same verified land anchor.
- `capture-manifest.json`: exact image hashes, camera/player transforms, renderer identity, counts, and grounding metadata.
- `verification-summary.json`: fixed generation counts, required/observed clearances, hashes, runtime metrics, and test results.

The successful bounded capture command was:

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot \
  --resolution 1440x900 \
  --path . \
  --script game/tests/rendered_visual_evidence_capture.gd \
  -- --vegetation-evidence-quick \
  --visual-evidence-output=res://evidence/first-playable/vegetation-corrected-quick-rendered-2026-08-28-1556
```

This evidence proves deterministic asset loading, representative visibility, and the corrected wetland/road exclusion. It is not a new exported `.app` and does not replace owner acceptance of ordinary play.

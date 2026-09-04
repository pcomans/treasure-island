# B225 standalone cladding repair v1

Status: technical capture complete; independent bar-raiser re-review pending. This packet is not self-acceptance, denominator credit, receiver-relative calibration, or permission to attach anything live.

This packet supersedes only the B225 visual candidate from the sealed D1 pair for review. It does not modify that packet. The control views instantiate the sealed pair in memory, hide B201 in that capture instance, and translate the old B225 root to local origin so the camera and light can be identical to the candidate.

## What changed

- Preserved the ten complete varied clerestory groups, inferred `4/5/4/6/5/5/4/6/4/5` pane counts, pale frames, recessed opaque glazing, sill, roof cap, 46.261968372 m width, and 5 m height.
- Removed all 14 identical full-width dark course boxes identified as barcode/ruler lines.
- Replaced four normalized-UV wall boxes with one ArrayMesh containing four run quads and a single cumulative metre U coordinate across exact runs `10..13`.
- Added one generated RGB albedo at an 8.0 m × 3.48 m cell, tint `(0.76, 0.755, 0.72, 1)`, scalar roughness `0.88`, repeat, mipmaps, and anisotropic filtering. There are no normal, roughness, metallic, height, AO, or other fabricated PBR maps.
- Topology is three render geometry instances, 90 retained boxes, and 1,088 triangles: 208 fewer triangles than the rejected control. Collision, navigation, spray, and decals remain zero.

## Clean matched views

| View | Sealed rejected control | Repair candidate |
|---|---|---|
| Complete front | `01-front-control.png` | `01-front-candidate.png` |
| Grounded oblique | `02-oblique-control.png` | `02-oblique-candidate.png` |
| Clerestory/cladding close | `03-close-control.png` | `03-close-candidate.png` |
| Changed light | `04-changed-light-control.png` | `04-changed-light-candidate.png` |

The PNGs contain no title cards or annotations. Exact pose, light, renderer, byte hash, and luminance metadata are in `capture-manifest.json`.

## Continuous motion evidence

`motion/frame-00.png` through `motion/frame-24.png` are consecutive native rendered samples along one continuously increasing camera path. The camera advances from chain U=8.0 m to U=26.0 m in 0.75 m steps at a 12 m standoff and therefore crosses all internal run boundaries: 10.372629078 m, 16.883522872 m, and 23.933383083 m. There is no camera teleport or texture phase reset at a run join.

The technical inspection found no hard ordinary-distance repeat seam, no run-boundary phase reset, and no obvious crawling in sampled frames. Mild broad 8 m tonal recurrence and somewhat synthetic close-range micrograin remain visual risks for the independent reviewer to judge.

## Generation boundary

The selected image was generated on 2026-09-04 through the built-in `image_gen.imagegen` tool with no reference images or stored source pixels. The initial output was rejected because it baked a repeated bevel-like gradient into every joint. One targeted edit flattened those bands; that edit is the selected asset. Exact prompts, both source-output paths and hashes, selection rationale, licensing/provenance nonclaims, material settings, and cleanup path are recorded in the config and manifest.

Selected project texture SHA-256: `63e755e9fe5a5dcfb662b4265f1e769fc1b371987b55579b1ca4ffb63015015b`.

The complete final B225 review branch adds exactly 2,104,448 bytes (2.006958 MiB) to the `macOS Private` PCK in a same-snapshot included/excluded export comparison. The selected PNG is 2,140,085 bytes, its imported `.ctex` is 2,031,028 bytes, and the upper estimate for decoded RGBA8 plus a full mip chain is 8,386,752 bytes. Evidence is export-excluded. Because this candidate is not live, a distributable build should add a narrow branch exclusion if review does not immediately lead to promotion; the exact method and pack hashes are in `package-audit.json`.

## Reproduce

```bash
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_d1_b225_standalone_cladding_repair_v1_contract.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/d1_b225_standalone_cladding_repair_v1_capture.gd
```

The native capture harness refuses headless screenshots. Do not run the old D1 capture harness against its sealed evidence root.

# Isle House standalone composite Variant C — technical B/C evidence

Date: **2026-09-04**  
Target: Isle House `physical-building:w1249412094`, accepted high receiver
`w1282547786` plus unaccepted low receiver `w1282547787`  
Status: **standalone technical evidence complete; recognition, believability,
and live replacement pending independent review**

This packet responds only to the three visual blockers in the independently
failed Variant B review. It does not alter `WorldChunkBuilder`, the rejected
live low attachment, Variant A/B, the accepted high adapter, global topology
pins, collision/navigation/spray, or historical evidence. The new factory
rebuilds sealed Variant B byte-for-byte, then creates a separate reversible
Variant C branch for same-pose comparison.

## Bounded Variant C changes

- NNW low runs `10..12` use one quiet scalar field across `y=4.103..19.103 m`:
  no texture recurrence, openings, schedule, or claim of as-built cladding.
- Public runs `0..9` retain the promoted `2.5 m` brick metre UV, continuous U
  within each public chain, absolute-world-Y V, tint `(0.70,0.66,0.62,1)`, and
  roughness `0.86`.
- The public `y=10.25..19.103 m` field now has unequal shallow
  transfer/body/crown/top-cap value and depth hierarchy. It encodes no window,
  story, structural-floor, or roof schedule and does not claim to literally
  correct the generated five levels to the referenced seven-story podium.
- Eight lower placements use four macro families twice each: broad gallery with
  side entry, mostly-brick pause with offset entry, layered patio recess, and
  split-gallery cluster. Family facts—warm brick, two-level glazing, individual
  entry/Dutch door, and patio/landscaped threshold—come from the official
  architect packet. Exact widths, depths, panel proportions, clustering,
  pauses, sequence, spacing, mirroring, opaque glazing, and all eight placements
  are reversible production inference.

No upper/private/rear/NNW opening schedule, roof treatment, interiors,
operability, as-built fidelity, recognition, believability, or live promotion
is claimed. No source pixels, URLs, discovery paths, or evidence paths occur in
the executable Variant C closure.

## Exact construction and ownership

| Item | Meshes | Surfaces | Triangles | Bodies / shapes |
| --- | ---: | ---: | ---: | ---: |
| Sealed Variant B full composite | 16 | 19 | 14,375 | 0 / 0 |
| Variant C full composite | 17 | 22 | 14,301 | 0 / 0 |
| Sealed B low repair overlay | 6 | 8 | 2,316 | 0 / 0 |
| C low repair overlay | 7 | 11 | 2,242 | 0 / 0 |
| C overlay minus B overlay | +1 | +3 | -74 | 0 / 0 |

Variant C has one five-surface field mesh plus `178` shallow batched boxes:
frame `96`, glass `22`, patio `28`, landscape `12`, transfer cap `10`, and
podium-light cap `10`. Its repair signature is
`41868b77a8b51b56ee7381e5549423e97547270d2dc77d9ce5cf958b31e2cb69`;
the full-composite signature is
`d57d5088854d68b80d3747f4382da2f08fdbfc8c64e7acae0f342a2a72f435ec`.
The current rejected live world remains `735 / 938 / 948 / 63,720 / 466`
(rows / meshes / surfaces / triangles / bodies), with `466` shapes.

All C geometry is render-only and owns zero collision objects/shapes,
navigation regions, or spray groups. The low generated wall remains the sole
collision and spray receiver in previews.

## Native decision evidence

The `16` PNGs are native `1440×900` Forward+/Metal captures on Apple M2 using
the visible stock player, physics-grounded poses, `70°` FOV, configured `5.5 m`
spring arm, normal reticle, no debug labels, no crop, and no detached camera.
Every view has exact same-pose B/C frames under both default and frozen changed
light. The first two are useful whole-composite views; ENE is supplemental
public-side detail; NNW is the requested direct protected-return view.

| View | B default | C default | B changed | C changed |
| --- | --- | --- | --- | --- |
| WSW whole | `618505c3…` | `ff10993b…` | `38e7e396…` | `26d0a98c…` |
| WSW oblique whole | `234b91a8…` | `a60cf402…` | `cb6130f3…` | `4f9c1821…` |
| ENE supplemental | `6b5da460…` | `a11a8222…` | `f76c05f8…` | `93e64afa…` |
| direct NNW | `872c938a…` | `66a413b0…` | `5d7940f3…` | `1682f55c…` |

Exact filenames and full hashes are in `capture-manifest.json` and
`CHECKSUMS.sha256`. The whole views measure high/low projected areas of
`0.1172/0.0771` and `0.1481/0.1961`; both hit accepted high receiver
`w1282547786` first. ENE and NNW hit low receiver `w1282547787` first.

The Motion JPEG AVI is `1280×800`, `222` frames at 30 fps, `19,017,750` bytes,
SHA-256 `99623c498180eba8475fda0e3c99eda30fa45608a15ee747c4db62c55b614245`.
Its declared review interval contains `300` consecutive physics samples at
60 Hz (`5.0 s`) under stock `move_right`, no run input: `19.8834915 m` across
the public run `2→3` corner, all grounded, zero recovery, zero harness transform
writes after input, and unchanged camera orientation. The lossless 4×4 PNG
review sheet samples frames `1,21,…,281,300`; it is derived convenience evidence,
while the AVI is authoritative for shimmer/seam/motion review.

## Package and review boundary

The fresh all-resources private pack is
`build/isle-house-composite-repair-variant-c-standalone-v1-review/Treasure Island First Playable.pck`,
`62,428,376` bytes, SHA-256
`3033799811689806f721501bdfbf24113408af9f4688e4a12b8cc5d66896739f`.
The package contract passes twice from source and twice from `/private/tmp`
with that PCK mounted: exact B/C signatures/topology rebuild; discovery and
evidence are absent; the runtime closure is source-safe; no ownership or live
promotion appears. Focused construction and evidence contracts also pass twice.

Independent reviewer: inspect all PNGs and the complete declared AVI interval
at original detail before labels/manifests. Judge only whether C resolves the
three prior blockers from honest grounded views. Technical PASS results are not
a recognition or believability grade. If and only if review passes, a later
integration owner can detach `VariantCRepairLowOverlay` through
`detach_variant_c_overlay_for_preview()` and replace—not stack over—the rejected
live child on exact receiver `w1282547787`; this task performs no promotion.

## Reproduction

```text
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --audio-driver Dummy --script game/tests/headless_isle_house_composite_repair_variant_c_standalone_v1_contract.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --audio-driver Dummy --script game/tests/headless_isle_house_composite_repair_variant_c_standalone_v1_package_contract.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/isle_house_composite_repair_variant_c_standalone_v1_capture.gd -- --capture-mode=stills
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1280x800 --write-movie evidence/first-playable/isle-house-composite-repair-variant-c-standalone-v1-2026-09-04/isle-house-composite-repair-variant-c-public-corner-stock-walk.avi --fixed-fps 30 --script game/tests/isle_house_composite_repair_variant_c_standalone_v1_capture.gd -- --capture-mode=motion
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --audio-driver Dummy --script game/tests/headless_isle_house_composite_repair_variant_c_standalone_v1_evidence_contract.gd
```

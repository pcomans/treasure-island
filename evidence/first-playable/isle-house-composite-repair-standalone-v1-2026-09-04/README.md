# Isle House full-composite standalone repair v1 — technical A/B evidence

Date: **2026-09-04**  
Target: Isle House `physical-building:w1249412094`, accepted high receiver
`w1282547786` plus unaccepted low receiver `w1282547787`  
Status: **standalone technical evidence complete; recognition, believability,
and live replacement pending independent review**

This branch does not alter `WorldChunkBuilder`, the current failed low live
attachment, the accepted high adapter, the catalog, or the runtime registry.
Variant A reconstructs the sealed failed live composite. Variant B keeps the
same exact high and high/low source geometry, then swaps only a detached,
render-only low overlay through the factory's reversible preview seam.

## What changed in Variant B

- Public low runs `0..9` retain the promoted warm brick with continuous
  side-chain metre U, absolute-world-Y V, a `2.5 m` cell, tint
  `(0.70, 0.66, 0.62, 1)`, and roughness `0.86`.
- The formerly untreated public band `y=10.25..18.58 m` receives one
  homogeneous light podium field; `y=18.58..19.103 m` receives one shallow
  support-grey transition reveal. These are mass/material/depth hierarchy only:
  there is no opening, story, parapet, setback, roof, or private/rear schedule,
  and there is no claim that the frozen five generated levels were literally
  corrected to the referenced seven-story podium.
- The eight live-work assemblies remain confined to long public runs
  `2,3,8,9`, but now use four arrangements twice each: `HALF-DOOR-LEFT`,
  `HALF-DOOR-RIGHT`, `ENTRY-GALLERY`, and `PATIO-GLAZING`. Door side, width,
  gallery mullion count, canopy width, and one/two planter thresholds vary in a
  deterministic family instead of one repeated stamp.
- NNW runs `10..12`, the low roof, the hidden shared interface, the high part,
  and all private/rear/courtyard appearance remain untouched.

The official architect material supports the completed seven-story podium as a
whole-building fact; warm brick/handcrafted eye-level material; nine two-level
live-work homes with private entries, Dutch doors, and patios; and their split
between Avenue of the Palms and the shared way. The four exact arrangements,
eight placements, widths, spacing, sequence, mirroring, opaque glazing,
upper-field split, reveal depth, and planter proxies are all explicitly
**reversible production inference**. No source pixels or URLs are in runtime.

## Exact topology and ownership

| Item | Meshes | Surfaces | Triangles | Bodies / shapes |
| --- | ---: | ---: | ---: | ---: |
| Variant A, full exact high+low plus sealed failed overlay | 15 | 16 | 13,903 | 0 / 0 |
| Variant B, full exact high+low plus repair overlay | 16 | 19 | 14,375 | 0 / 0 |
| Variant B repair overlay alone | 6 | 8 | 2,316 | 0 / 0 |
| B minus A | +1 | +3 | +472 | 0 / 0 |

The repair batches `188` shallow boxes: brick `24`, glass `32`, frame `100`,
patio `20`, and landscape proxy `12`. The repair signature is
`a58d9b963b0dc19b5a9fa1cba4872294a2ea2803459a9ba455e276dc1ff5b5bf`.
The accepted high remains
`e624a40551efb5bb5b137b731ebcd4ffbdcafbb70e8c5560c5cc07e8c10637a1`;
Variant A reproduces failed live signature
`5d61ab90e5b798ac4aa26c45fea37a5293f3083dada615f06999faad459112cc`.

All candidate geometry is render-only. It has zero collision objects/shapes,
navigation regions, or spray groups. The generated low wall remains the sole
collision and spray receiver in the reversible full-world preview.

## Native same-pose evidence

All nine PNGs are native `1440×900` Forward+/Metal captures on Apple M2 using
the actual visible stock player, physics-grounded poses, `70°` FOV, configured
`5.5 m` spring arm, normal reticle, no debug labels, no crop, and no detached
camera. The executor checked only for corrupt/blank/contract-breaking frames and
did not grade recognition or believability.

| View | Artifact | SHA-256 |
| --- | --- | --- |
| WSW whole, A failed parent | `images/wsw-public-whole-composite-a-failed-parent.png` | `950c01ef95bc0c11755f2fba183678e8da38240094876ca7f63ced5a1a5edfaa` |
| WSW whole, B repair | `images/wsw-public-whole-composite-b-repair.png` | `3affc5fed86500b8cd4327012081b5cbb392cf6a639a3257dba9a8ee64e4a46f` |
| WSW whole, B changed light | `images/wsw-public-whole-composite-b-repair-changed-light.png` | `38e7e3966456df55485427dbab8e5086918cdeed66824d8147bd35d71c888311` |
| WSW oblique whole, A failed parent | `images/wsw-public-oblique-whole-composite-a-failed-parent.png` | `0475b9963835a3813c2fb14fbd83a8dd599ff4a02058bb3a72704c0ce5b742b5` |
| WSW oblique whole, B repair | `images/wsw-public-oblique-whole-composite-b-repair.png` | `609e36bf3056b998186cb79ffe0227c1f6f0231d3a48737877bc3a5bd582d050` |
| WSW oblique whole, B changed light | `images/wsw-public-oblique-whole-composite-b-repair-changed-light.png` | `cb6130f3c3d8471218f270bcaf1c13013ee72a38bf38a5f4bfa93ee495c5e3d7` |
| ENE supplemental detail, A failed parent | `images/ene-public-low-detail-a-failed-parent.png` | `b7253c2145982a1e05e1b905e2953dfdb684025b3df7683c747ec7d46e5617a2` |
| ENE supplemental detail, B repair | `images/ene-public-low-detail-b-repair.png` | `cdbb596656882419c12459d67ef919a2558366d9beaca9fb2478c665aeceaf14` |
| ENE supplemental detail, B changed light | `images/ene-public-low-detail-b-repair-changed-light.png` | `f76c05f8217de2831dc0730084ccdb1c5a7f10f6ba9240f05ea60252c66249e7` |

The two whole-composite WSW poses expose both exact parts at useful measured
size. In the first, the high projects `306×496 px` (`0.1172` frame area), the
low `593×168 px` (`0.0771`), and their union `0.3016`. In the oblique view, the
high projects `356×539 px` (`0.1481`), the low `772×329 px` (`0.1961`), and
their union `0.3951`. Both A/B pairs reuse exact camera/player coordinates and
hit the high receiver first.

The ENE pair is deliberately labelled **supplemental low detail, not a whole-
composite acceptance view**. The adjacent Hawkins footprint blocks the only
long southeast ground sightline; distant grounded views reduce the ENE low
realm to an oblique sliver, while close Garden Walk views cannot contain the
full tower. This packet records that site constraint instead of using an aerial,
detached, widened, or cropped camera.

## Changed light and continuous motion

Each pose includes a same-camera B frame under frozen changed light. The motion
artifact `isle-house-composite-repair-public-corner-stock-walk.avi` is a
`1280×800`, 30 fps Motion JPEG AVI with `222` frames, SHA-256
`18bebf8f60f2c8a201f7ad7f8d392da6edd6c820dd1a8eee261d5af1d39031b0`,
and `18,648,756` bytes.

The declared review interval contains `300` consecutive physics samples at
`60 Hz` (`5.0 s`) under stock `move_right` input, no run input. The player moves
`19.8834915 m` across the WSW run `2→3` corner, from `-7.999956 m` to
`+11.883522 m`, with public-tangent dot `0.9999993`. Every sample is grounded;
recovery delta and post-input transform writes are both zero, and camera
orientation is unchanged. Motion is technical evidence for seam/shimmer/stamp
review, not an executor visual pass.

## Package proof and live seam

The private all-resources export pack at
`build/isle-house-composite-repair-standalone-v1-review/Treasure Island First Playable.pck`
is `62,195,488` bytes with SHA-256
`981fd9b93a53098ac8abab0adcf919d0a4e5e276da841a087daac67c61365f9c`.
The package contract passes both from source and from `/private/tmp` with this
PCK mounted as `--main-pack`: the scene/config/material/chunk closure loads,
both exact A/B branches rebuild, discovery and evidence are absent, signatures
and topology match, and no decorative ownership appears.

If and only if independent review passes, a future integration owner can call
`detach_repair_overlay_for_preview()` and replace the current low live child on
exact receiver `building-composite:w1249412094:w1282547787:wall`, then reconcile
global topology and the recognition catalog in one coordinated batch. This
standalone task does not make that promotion.

## Reproduction commands

```text
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_isle_house_composite_repair_standalone_v1_contract.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_isle_house_composite_repair_standalone_v1_package_contract.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/isle_house_composite_repair_standalone_v1_capture.gd -- --capture-mode=stills
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1280x800 --write-movie evidence/first-playable/isle-house-composite-repair-standalone-v1-2026-09-04/isle-house-composite-repair-public-corner-stock-walk.avi --fixed-fps 30 --script game/tests/isle_house_composite_repair_standalone_v1_capture.gd -- --capture-mode=motion
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . --script game/tests/headless_isle_house_composite_repair_standalone_v1_evidence_contract.gd
```

Independent reviewer: inspect all PNGs and the complete declared motion
interval at original detail before reading manifests. Judge Variant B against
Variant A and the P1 packet, without relying on location, color alone, source
IDs, role labels, or this README. Decide recognition and believability; do not
infer either from these technical PASS results.

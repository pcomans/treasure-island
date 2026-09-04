# Building 1 tower grounded-evidence correction — 2026-09-04

Status: **capture-only correction; pending independent tower re-review; builder
acceptance is prohibited**.

## Exact before and after

The prior independent review accepted the main Building 1 entity only with a
limitation, but rejected the separately scored `w1222720021` tower. Its two
ordinary-height views left the tower too small to establish whole-entity
recognition, while the only useful tower-sized image was an elevated diagnostic
view and therefore could not satisfy the ordinary-player gate.

This correction changes no facade, geometry, source plan, identity, collision,
roof platform, material, or spray behavior. It adds two new deterministic
captures from distinct playable `land_ground` positions using the shipped
player camera. Each center LOS first-hits
`building:w1222720021:wall`, remains bound to source `w1222720021`, and keeps
the full projected tower bounds in frame. The actual lenses are `2.000 m`
above their local ground with a neutral `0 degree` pitch. The views are
separated by `37.165040` degrees and retain the following projected sizes:

| View | Frozen source run / offsets | Projected tower W × H | PNG SHA-256 |
| --- | --- | ---: | --- |
| `01-grounded-tower-family.png` | run `5`; `44 m` outward; `+16 m` tangent | `120.726 × 124.863 px` | `c5578ea9a5d6965a5ab64f05dca84aab32a2b89ea0552625c26f6719c4efd027` |
| `02-grounded-oblique-silhouette.png` | run `8`; `42 m` outward; `-32 m` tangent | `108.328 × 112.456 px` | `98e9f5b8142f71a5ce1eb59004afbbd13bbe6f809703143999f757f0db4d20e8` |

Both PNGs are uncropped `1440×900` native macOS Forward+/Metal captures with
the stock `70 degree` FOV and `5.5 m` spring arm. HUD and debug overlays are
off. The physical player remains grounded and in the playable boundary; its
mesh is hidden only to avoid blocking the target.

## Exact-current provenance

- Generator: `game/tests/building_1_tower_grounded_capture.gd`, SHA-256
  `51a9bf62e14c1c0bb6e982477480ffbfc0a8f9209ec73ca52bd1f52a7d30825b`.
- Building 1 config: SHA-256
  `6c99f43550631a1e6bca1f52764ad23c6a5b8b891403f30c78ff9b9545192690`.
- Building 1 adapter: SHA-256
  `1487ee41870a03ad79118936d0f3f563644ef617ca2722fe64778d80e85a3495`.
- World builder: SHA-256
  `ab79117f85a1c266b42a62054a9a39f6822713528ae2d70cfeab0cbfd7169ccd`.
- Superseded rejected capture manifest: SHA-256
  `ebeef887b37c6845c6c8fa3f25e06706351fe7c1dab0e1a3b0eaf47dfb773017`.
- Superseded independent review: SHA-256
  `b12858438d6522b7f3cf42fa06392648d16ee3e0c418eb5e807a3ee1be770c2a`.
- Loaded topology remains `735 records / 931 meshes / 941 surfaces / 59,778
  triangles / 466 static bodies / 466 shapes`.

Capture command:

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot \
  --path . \
  --display-driver macos \
  --rendering-method forward_plus \
  --rendering-driver metal \
  --audio-driver Dummy \
  --resolution 1440x900 \
  --script game/tests/building_1_tower_grounded_capture.gd
```

Focused verification, both exit `0`:

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . \
  --script game/tests/headless_building_1_tower_grounded_evidence_contract.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --headless --path . \
  --script game/tests/headless_building_1_hero_model_contract.gd
```

The first reports that this packet is exact-current, capture-only, native
Metal, source-bound, physics-grounded, and pending review. The second confirms
the four Building 1 source identities, exact horizontal plans, deterministic
hero topology, collision ownership, and wall spray ownership remain intact.

## Remaining review risk

This package proves provenance, ordinary grounded camera conditions, an
in-frame direct ray to the exact tower receiver, useful projected size, and
viewpoint separation. It does not decide
recognizability. At roughly `100 px` tall, an independent reviewer may still
find that the glazed polygonal family, roof-platform/balustrade, or pyramidal
cap is insufficiently legible, especially against the large austere rear mass.
No geometry adjustment was made to compensate for that risk. There is
intentionally no `INDEPENDENT_REVIEW.md` in this directory until a different
reviewer applies the frozen recognition rubric.

# Treasure Island Building 1 recognizability composition — native actual-world evidence

Status: `independently_reviewed_keep_with_documented_limitation`; lifecycle reconciled from independent review SHA-256 `328973362b873b80ec8255c78ad7851369db850d3d9bc3f95b31064f83bb584c`.

This is one initial, reversible, recognizability-first composition for the 1939 World's Fair Pan Am / Treasure Island Administration Building 1 (`r16681702`, receiver `building:r16681702:wall`). It is a reference-derived production inference, not a surveyed reconstruction. The executor did not self-accept it.

## Exact live scope

- The complete `B1-MAT-IVORY` field is independently accepted on exactly `63` verified public runs (`0..56,58,60,93..96`), `206.908708 m` / `4,350.511117 m²`, rendered as three watertight shared-miter chains with cumulative metre-space UV phase inside each chain. The predecessor runs `21..51` verdict remains preserved under review SHA-256 `35d8e0d306b381feee997c068824222e22ff4199c8ef5433bbe5ae082fa4c048`.
- The complete module composition is independently accepted as `45` placements — `8 B1-WING-W`, `24 B1-CENTRAL-W`, `2 B1-PAV-W`, `6 B1-BASE-O`, `1 B1-DOOR-BLUE`, and `4 B1-BAND`.
- Render-only composition topology: `354 meshes / 354 surfaces / 4,338 triangles / 0 collision / 0 navigation / 0 spray`.
- Runtime delta versus the independently accepted ivory-only baseline: `+353 meshes / +353 surfaces / +4,276 triangles / +0 colliders`.
- Actual loaded world: `729 records / 1,278 meshes / 1,288 surfaces / 55,067 triangles / 466 collider pairs`.

All counts, cadence, scale, vertical levels, and coordinates for the new composition are reversible production inference. Surveyed dimensions/coordinates/count/cadence/sequence, completed elevation, as-built fidelity, and whole-building acceptance are explicitly false.

Hard-protected and untouched: runs `57/59/61`, `62..92`, `97..109`, inner ring, separate `w1222720021` tower, entrance/canopy/emblems, roof/massing/source geometry, terrain, generated data, collision/navigation/spray, other buildings, and `r133351`.

## Native renderer

Godot `4.7.2.stable`, macOS display driver, Forward+ renderer, Metal on Apple M1 Pro, `1440×900`. Reproduce with:

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/building_1_recognizability_capture.gd
```

## Review set

| File | Purpose | SHA-256 |
|---|---|---|
| `01-before-ordinary-public-curve.png` | accepted ivory-only baseline, ordinary curve pose | `6e895b4351fe55cb87dcf3a149bdd87106f85128357714b5a509bcbd0515f473` |
| `02-after-ordinary-public-curve.png` | same pose, recognizability composition | `6f64992e9455139e394670b50455a9874d248c65ed1d4f30c94560c16f99d1ad` |
| `03-before-ordinary-north-end.png` | accepted ivory-only baseline, north-end pose | `a5b76b31a0ed04e2d593d8970fd5b1effad67518ece3a6ade865697a4ae1aa96` |
| `04-after-ordinary-north-end.png` | same pose, pavilion/base composition | `ed62fbc04605905fb464ad87c237bda5ffffadabb5d22a6b0f0b86017ad443ed` |
| `05-before-whole-building.png` | accepted ivory-only whole-building context | `5d07e5e46139340b322f2870608e740e9d2e0449fae677a53ed19805e9d3d612` |
| `06-after-whole-building.png` | same whole-building pose after composition | `e52bdd10db10bde8fc74c043cd2e7549a2f205067e9cfe0045f71fca3bdbecff` |
| `07-wing-family-close-oblique.png` | complete `B1-WING-W` | `97cfdabaac967c373f86ffcf7043a16f37c43c038a3d98265e648d84cbdde270` |
| `08-central-family-close-oblique.png` | complete `B1-CENTRAL-W` cluster | `e547ea70810637979f08d88ad4bef4fea0c86452fba3f7d3286198d9e6f23d79` |
| `09-pavilion-family-close-oblique.png` | complete `B1-PAV-W` | `5073fbbbc3ef96c33192ff1a02e26c126f273841d9d5ed2274ca13756a6c6792` |
| `10-base-family-close-oblique.png` | complete opaque `B1-BASE-O` proxies | `9842dc5ac4adcf1828ecbaf789aaeab4a62d44d2b1a7ef779a378097e67be9f5` |
| `11-door-family-close-oblique.png` | complete isolated `B1-DOOR-BLUE` | `29e3e28b83fd909493c355488e9d66c069b0a713df12e9de3522f47b48a072f7` |
| `12-band-family-close-oblique.png` | complete finite `B1-BAND` with terminals | `3696ec1a45a93130e45b939670728b8c7b6c6ccda3119e826917405653439b22` |
| `13-multiside-context.png` | public curve/end relationship | `392f7470115eaf87f2ff688da0bbb8207a0ab39e3c375865e20f295e93ff4a7a` |
| `14-changed-light-public-curve.png` | field and window families under changed light | `a3a6986a78a4ff4bd6c1a95daa9c76c0d9bb482fea67f4d2b4f3f0fe7b3ed310` |
| `15-south-end-ordinary.png` | south pavilion/band ordinary view | `61cbbc12c1eab9c73f896f9ce7581475e26de60869fe83b1edd3e838e32f9db9` |
| `16-whole-island.png` | whole-island noninterference context | `e5518f9b75e90b2a457a44e328c1b3297f35064a67b448700e859e03fa9f6706` |

`capture-manifest.json` is the machine-readable camera/placement/topology record. `runtime-isolation.json` seals protected runtime state. `visual-verification.json` records executor validity inspection without an art verdict.

## Independent review outcome and retained boundary

Independent review `TREASURE_ISLAND_BUILDING_1_RECOGNIZABILITY_ART_REVIEW.md` accepted the exact 32-run extension and all 45 placements `KEEP_WITH_DOCUMENTED_LIMITATION`, with no correction or revert. The capture manifest deliberately retains its capture-time pending-review provenance; current lifecycle truth is recorded here, in `visual-verification.json`, the canonical inventory, and the review. Surveyed/as-built coverage, dimensions, scale, coordinates, count, cadence, sequence, complete elevations, protected scope, and whole-building fidelity remain unclaimed.

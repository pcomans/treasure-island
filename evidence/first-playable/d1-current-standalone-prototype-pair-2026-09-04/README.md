# D1 current standalone prototype pair — B201 and B225

Captured: **2026-09-04**

Status: **pending independent recognition and bar review; not self-accepted**

This packet proves that two bounded, current, cue-backed D1 observed-side
studies instantiate and render deterministically in native Godot 4.7.2
Forward+/Metal. It is not evidence of live receiver placement, exact as-built
layout, gameplay-world integration, or independent recognizability acceptance.

## Exact bounded scope

| Unit | Exact observed side/run region | Exact generated length | Recognition pair represented | Excluded |
| --- | --- | ---: | --- | --- |
| City B201 / `w34313545` | `800I-PUBLIC-WSW`, source edge `0`, ordered runs `0..9` | `115.512661489 m` (`115.513 m` canonical rounded) | green-bounded broad upper-window register + mostly solid light lower field with sparse nonsemantic openings | every other run; Station 48; address/tenant signs; exact bay/canopy dimensions; service-yard, corner and roof claims |
| City B225 / `w95934119` | `14812-NNW-LONG`, source edge `3`, ordered runs `10..13` | `46.261968372 m` (`46.262 m` canonical rounded) | varied complete high clerestory groups + aged horizontal cladding on a low mass | WSW openings and all runs `0..9`; lower openings; exact pane/cadence/damage; Pavilion/B227 identity; corners and roof equipment |

B201 retains the frozen `800 Avenue I` address while recording the City B201
`800 Avenue H` / `995 9th at Avenue I` conflict. The separate Station 48
footprint is explicitly excluded. B225 is bound to City B225 / 148 12th Street,
has no authoritative common name, and is explicitly not B227/the Pavilion.
Neither identity is represented by a plaque, sign, arbitrary color, or copied
reference image.

## Prototype and cost

The scene is an isolated render-only pair. One Godot unit is one metre. Module
counts, dimensions, cadence, anchors, canopy extent and pane organization are
recorded as reversible `production_inference`, not survey facts.

| Unit | MultiMesh batches | Box instances | Triangles | Collision / navigation / spray |
| --- | ---: | ---: | ---: | ---: |
| B201 | 6 | 182 | 2,184 | `0 / 0 / 0` |
| B225 | 4 | 108 | 1,296 | `0 / 0 / 0` |
| Pair | 10 | 290 | 3,480 | `0 / 0 / 0` |

Eight local opaque `StandardMaterial3D` resources are used. B201 and B225
genuinely share only the dark opaque glazing proxy and pale painted-frame
family. There are no bitmap textures, generated facade images, random/noise
generators, transparent interiors, physics owners, or runtime attachments.

Deterministic geometry signatures:

- B201: `57573bc19d6c6a45b946827e76a346c592d5238a310e923a30a41b149f963511`
- B225: `179d898c4635917743e967819998256c7fe4938981da69e7d4664e1e7e13b58a`
- Pair: `17c560633517963489b76430729bb6476065bb0d9a6385b3a913103a778c32ad`

## Native technical captures

Every PNG is a fresh 1440×900 capture from Godot 4.7.2 using native macOS
Forward+/Metal on Apple M2. Each image visibly labels run eligibility as not
placement and the review state as pending.

| Capture | Technical coverage |
| --- | --- |
| [01-b201-grounded-complete-wsw.png](01-b201-grounded-complete-wsw.png) | full exact-length B201 side at a grounded view |
| [02-b201-grounded-canopy-depth.png](02-b201-grounded-canopy-depth.png) | B201 canopy/fascia/post projection and long-register oblique |
| [03-b201-register-service-close.png](03-b201-register-service-close.png) | B201 window/frame/pier relief and sparse nonsemantic lower leaf |
| [04-b201-changed-light-oblique.png](04-b201-changed-light-oblique.png) | B201 hierarchy under reversed light |
| [05-b225-grounded-complete-nnw.png](05-b225-grounded-complete-nnw.png) | full exact-length B225 side at a grounded view |
| [06-b225-grounded-clerestory-oblique.png](06-b225-grounded-clerestory-oblique.png) | B225 varied complete groups and projection depth |
| [07-b225-clerestory-course-close.png](07-b225-clerestory-course-close.png) | B225 pane grouping and physical horizontal course hierarchy |
| [08-b225-changed-light-oblique.png](08-b225-changed-light-oblique.png) | B225 recess/course reading under reversed light |
| [09-pair-grounded-overview.png](09-pair-grounded-overview.png) | comparative language only; spacing is illustrative |

Executor technical inspection confirms that the intended two-cue hierarchies,
silhouettes and actual projection/recess depth are visible in the ordinary and
changed-light views. This is only a capture-quality check. An independent agent
must decide whether each unit is recognizable and whether the art bar is met.

## Reproduction and validation

Headless exact-receiver/topology/isolation contract:

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --headless --audio-driver Dummy --script game/tests/headless_d1_current_standalone_prototype_contract.gd
```

Native capture:

```sh
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/d1_current_standalone_prototype_capture.gd
```

See `capture-manifest.json` for per-image hashes, camera/light poses, luminance
samples, renderer identity, source/config pins and explicit blocked claims.
`verification-results.txt`, `generated-data-diff.txt`,
`dirty-scope-audit.txt`, and `asset-inventory.sha256` record the mechanical
proof and change boundary.

## Live-integration seam — deliberately not exercised

A future separately authorized receiver-relative adapter may project complete
B201 motifs only over source edge `0` / ordered runs `0..9`, and complete B225
clerestory groups only over source edge `3` / ordered runs `10..13`. It must use
one cumulative metre coordinate across each chain, preserve corner clearance,
and never reset or infer cadence from generated U values.

Promotion requires independent recognition/bar review followed by a new exact
receiver-relative layout and explicit live-attachment authorization. No world
builder, catalog, compiler, registry, loader, generated chunk, collision,
navigation, spray, existing evidence, or HUMAN file was edited by this batch.


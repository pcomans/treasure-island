# 1441 Chinook Court standalone exact-footprint hero — technical evidence

Date: 2026-09-04  
Target: `w95934105`, 1441 Chinook Court  
Status: **technical package valid; recognition and believability pending independent bar-raiser review**

This is a standalone, capture-only exterior prototype. It is not registered or
attached to `WorldChunkBuilder`, the facade catalog/compiler/registry/loader,
or the live world. The capture harness swaps the exact current wall and roof
visual/collision together for the exact-source standalone pair. Each still pair
reuses the same grounded stock-player transform, stock camera transform, and
lighting. The third pair repeats the public oblique pose under materially
changed light.

The executor performed technical checks only: exact source/package identity,
nonblank and uncropped files, grounded motion, framing, transform reuse,
collision/topology, and absence of debug overlays. No recognizability,
believability, material-quality, or aesthetic grade is claimed here.

## Evidence-bound 1441 cadence

- Exact source identity remains `w95934105`, wall
  `building:w95934105:wall`, roof `building:w95934105:roof`, chunk
  `x_-1__z_-1`, and source geometry hash
  `952df7a4edca5dbaec7d74cb795b564cb1fa5567ea737d1a861e222b29ddf07f`.
  The wall and roof record signatures are respectively
  `2f89ec3b90d7ab5999d79f92e7ebbae1265cf0b93e3931f8968e348ad91d8a5a`
  and `41a9b67b0c65aa26ca241183d37932e481f12bdc75b6253d928e4a1623013214`.
- All 16 exact source wall-run XZ edges, terrain-following bottom vertices, and
  the source wall top at `Y=9.332 m` remain unchanged. All ten source roof
  triangles retain their exact XZ plan.
- Only the documented SSE runs `10,12,13,15` receive facade modules. The
  footprint itself supplies the entity-specific rhythm: long runs `10` and
  `15` are the projecting windowed wings; the real `5.669 m` return at
  protected run `11` sets runs `12+13` deeply behind the first wing; protected
  run `14` returns `5.472 m` to the second wing. This schedule is in the 1441
  prototype/config, not in the reusable kit.
- Runs `0..9,11,14` remain an exact shell in a quiet neutral non-claim
  surrogate, with no windows, void fields, rails, copied cadence, labels, or
  other facade modules.
- Each wing has three grouped opaque opening modules on each of two rows.
  Runs `12` and `13` each have one complete opaque recessed field, balcony slab,
  and simple rail silhouette on each row. Four broad SSE eave bands and an
  exact-plan shallow gable provide the documented roof/eave break.
- Opening count/dimensions, void count/dimensions, slab depth, rail count and
  spacing, eave size, roof rise, colors, and scalar material values are
  reversible production inference. No interior, transparent or operable
  glazing, occupancy, structure, substrate, exact roof product, unseen facade
  schedule, or post-July-2023 appearance is asserted.

The source packet's frozen confusion set is 1439, 1443, 1438, and 1440
Chinook. The intended discriminant is the exact projecting-wing / real central
setback / two-level void cadence plus the shallow dark gable and broad eave;
warm-white hue, address, location, satellite dish, or source ID does not count.

## Shared Site-12 kit and material boundary

`site_12_housing_kit.gd` is geometry-only. It provides meter-authored boxes and
quads, complete grouped opaque-opening surrounds, opaque recessed
balcony-or-breezeway fields and slabs, simple rails, and broad eave bands. It
contains no address, source ID, run schedule, whole facade, or generic cohort
cadence; another unit must provide its own evidence-backed discrimination.

One geometry UV unit equals one modeled meter. The warm-ivory material uses the
already sealed, text-only GenAI homogeneous mineral albedo v2 at a reversible
`3 m` repeat. No target photograph was used as generator input and no new image
was generated for this package; reusing the accepted neutral micro-surface
avoided a redundant generation cycle. Its original prompt, built-in saved
source path, correction history, rights boundary, and hash are recorded in
`discovery/facades/GENAI_TEXTURE_PILOT_V1.md`. The prototype pins the project
asset at SHA-256
`af1c7a8f90ab5e60b9ab40a3bcf087aa26b00892edd48a2b4f1c84533f8be51c`.

The roof uses only the existing CC0 Poly Haven bitumen **albedo** as a dark
brown, `5 m`-repeat visual surrogate. It does not claim a bitumen or shingle
product. Both use scalar roughness; this package generated or assigned no
normal, roughness, AO, height, or displacement bitmap. Void and opening proxies
are opaque exterior surfaces and do not imply modeled interiors.

## Measured topology and ownership

| Item | Result |
| --- | ---: |
| Render batches / surfaces | 9 / 9 |
| Exact source wall triangles | 32 |
| Exact-plan shallow-gable roof triangles | 10 |
| Noncolliding facade/eave relief triangles | 1,536 |
| Total visual triangles | 1,578 |
| Static bodies / shapes | 1 / 1 |
| Structural collision triangles / face vertices | 42 / 126 |
| Navigation / spray-owner nodes | 0 / 0 |
| Wing opening groups / recessed two-level voids | 12 / 4 |
| Rail pickets / mapped eaves | 36 / 4 |
| Deterministic geometry signature | `b91b373e3bb8238a6f73f05734ef48b3429ae5654eddce89b1981ee41ee89195` |

The nine visual batches contain: protected exact walls `24`, mapped SSE
stucco walls `8`, exact-plan shallow gable `10`, broad eaves `48`, wing opaque
openings `144`, pale opening frames `720`, recessed void fields `48`, balcony
slabs `48`, and simple rails `528` triangles.

The structural collision is triangle-congruent with the 32 exact source wall
triangles and ten exact-plan shallow-gable roof triangles. The fallback wall and
roof collider is absent while the prototype is enabled. Eaves, windows, frames,
void fields, slabs, and rails remain noncolliding exterior relief with the exact
source wall collision behind, matching the packet's conservative collision
boundary. The standalone has no navigation or spray ownership.

## Native same-pose stills

All files are uncropped 1440×900 native macOS Forward+/Metal frames on Apple M2
using the actual generated world, visible stock player, physics-grounded
walkable terrain, 70° FOV, 5.5 m spring arm, normal reticle, and no debug labels
or panels. Full entity bounds are in frame. Camera and player translation error
is exactly `0.0 m` in every pair; maximum camera-basis error is
`1.25e-8`.

| Pair | Stage | SHA-256 | Projected width × height | First wall run |
| --- | --- | --- | --- | ---: |
| Whole public SSE | before | `594d8806a38f81fabc0e69d128ce9f132a8883fb8b967fc3d2271c833b942dab` | `0.323 × 0.108` | 10 |
| Whole public SSE | after | `69237ce93ee7f7df32a216fa20fab5d40e2ae1cb6f3f52689b20766ffa269442` | `0.330 × 0.122` | 10 |
| Public SSE oblique | before | `5d19ed4c9f5ce804a77612f665fb2ce11f0122d38f14db8d1e50e7fbd7b93a16` | `0.569 × 0.232` | 13 |
| Public SSE oblique | after | `9e9785f7631a8ceadd56d018dcc9f945d0ee650a5aad8d4e2deaccbfe950b06a` | `0.582 × 0.261` | 13 |
| Changed-light SSE oblique | before | `b484bfd8b4bdccbbb0d3f0b9d67d9b784a230b1fca2c0c86ecfb51f0c09ba71f` | `0.569 × 0.232` | 13 |
| Changed-light SSE oblique | after | `77aa0216f48121429bbdd3425db38da31d1fcfeba47b790de8d9fd2ff4a61696` | `0.582 × 0.261` | 13 |

## Continuous stock-player motion

`d2-1441-chinook-sse-stock-walk.avi` is a deterministic 1280×800, 30 FPS
Godot movie. The actual stock player moves continuously under `move_right` for
240 physics frames / `4.0 s`, covering `15.871 m`; all 240 samples remain on
generated ground, with zero recovery, zero harness transform writes after
input begins, and unchanged camera orientation. The movie includes 192 encoded
frames including startup/settlement; the manifest identifies the exact motion
frame range for review.

- Movie SHA-256:
  `1f7b42f4b83c0225146044cfc9794f71575d19e06147e15ebc7f0aa46b3f7d03`
- Movie bytes: `15,553,064`
- Still manifest SHA-256:
  `8b4bbea9eb24a084058420100a7c5a1dd4305fb15668118aaf0d6bed56ce8b94`
- Motion manifest SHA-256:
  `f6c9053db6603ad0095312a37566a5ade14627bea077f0585c055503942f5142`

## Independent review request

Open all six PNGs at original detail and watch only the manifest's continuous
motion range before reading labels. Against 1439, 1443, 1438, and 1440 Chinook,
decide whether the after views are top-1 1441 using at least two supported cues,
including the real projecting-wing / central-setback / two-level-void cadence.
Confirm the shallow dark gable and broad eave survive whole, oblique,
changed-light, and moving views without relying on hue, address, location, or
source ID. Check for distracting stucco repetition, seams, shimmer, rail noise,
false interior reading, clipping, or collision-visible disagreement. Do not
promote the prototype from this README; recognition and believability remain
pending until that independent decision is recorded.

## Fail-closed future seam and owner dependencies

The standalone factory accepts only the exact matching `w95934105` wall+roof
pair and fails closed on coordinate, topology, source, height, or record-field
drift. A future live owner must intercept both exact records before generic
visual or collision creation, remove the fallback pair together, and recreate
explicit spray ownership on the validated wall receiver. Partial overlay or
one-record attachment is forbidden. The independent bar raiser owns visual
acceptance; the runtime owner owns any later live integration, navigation/spray
restoration, and collision review for modules. Additional current public-side
evidence would be needed before upgrading the reversible opening/void/rail/roof
schedule to an as-built claim.

## Commands

```text
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --headless --script game/tests/headless_d2_1441_chinook_standalone_hero_contract.gd
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/d2_1441_chinook_standalone_hero_capture.gd -- --capture-mode=stills
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1280x800 --write-movie evidence/first-playable/d2-1441-chinook-standalone-hero-2026-09-04/d2-1441-chinook-sse-stock-walk.avi --fixed-fps 30 --script game/tests/d2_1441_chinook_standalone_hero_capture.gd -- --capture-mode=motion
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --headless --script game/tests/headless_d2_1441_chinook_standalone_hero_evidence_contract.gd
```

See `capture-manifest.json` and `motion-capture.json` for exact transforms,
ground sources, frame windows, runtime context, package pins, topology, per-file
metrics, first-hit bindings, and the review boundary.

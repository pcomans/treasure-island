# Independent bar-raiser review — Isle House low GenAI brick Phase 2

Reviewed: **2026-09-04**

Reviewer: **`/root/visual_bar_raiser`**

Review order: **four fixed A/B PNGs and all nine motion-sample PNGs at
original `1440x900` detail first; capture labels/manifests, metre-UV helper,
exact receiver mapping, topology/ownership, export boundary, hashes, source
contracts, and a clean mounted-PCK contract afterward**

## Verdict

**PASS_WITH_LIMITATION — the promoted brick material and generic metre-UV
helper may proceed to one reversible live Isle House low integration.**

The generated brick is materially more believable than the flat scalar
control. At the tested `2.5 m` cell it supplies a plausible masonry scale and a
quiet warm field while leaving the tall glazing, individual doors, piers, and
thresholds as the architectural hierarchy. It does not pretend to add
recognition, openings, signage, relief, or an as-built facade.

No reviewed frame shows a distracting seam, source-run phase reset, broken
course, grid, moire burst, baked directional light, false facade feature,
grossly wrong scale, excessive noise, or loss of the window/entry read. The
source cell remains discoverable under deliberate inspection, especially
across the longest uninterrupted fields, but it does not dominate ordinary
viewing. That is acceptable under the owner's progress-over-perfect-tiling
threshold.

The limitations are precise and nonblocking:

1. nine images sampled every `1.25 m` can reject gross crawling cadence and
   unstable density, but they cannot prove every intermediate video frame free
   of temporal shimmer;
2. the front and oblique A/B use one fixed lighting setup, not a rotated-sun
   pair; and
3. the narrow batched BoxMesh piers correctly remain scalar because their
   normalized primitive UVs are not metre-authored.

Phase 2 is material/UV/package acceptance only. It does **not** accept the
standalone low part, attach it to the live world, or accept the complete Isle
House composite.

## Pixel-first visual findings

### Fixed front A/B

The flat control preserves the module silhouette but reads as a near-uniform
dark brown fill. The generated candidate introduces level course rhythm and
small brick-to-brick value variation. The new field is lighter and warmer than
the control, which improves separation from the nearly black glazing instead
of washing it out. Door, gallery, frame, pier, and patio geometry remain the
first read.

Across the approximately `52 m` WSW chain, no vertical join announces a source
run boundary. A faint repeated source-cell fingerprint can be found after
knowing to search every `2.5 m`; it does not form a checkerboard, dark column,
or repeating hero stain. The facade remains compositionally quiet.

### Fixed oblique A/B

The oblique is the stronger seam test because several exact receiver runs and
module intervals recede through perspective. Brick courses remain level in
world height, retain plausible apparent scale, and pass behind the existing
module rhythm without a visible U restart. There is no corner flash, stretched
brick wedge, diagonal texture skew, or lighting direction baked into the
albedo.

The scalar narrow piers are perceptibly smoother than the generated background
field only under close inspection. Their shared warm-dark family makes the
transition coherent, and keeping them scalar is visually preferable to using
wrong-scale normalized BoxMesh texture coordinates.

### Nine-frame parallel walk sample

The `U=20.0..30.0 m` sequence holds camera distance at `16 m` and moves in
`1.25 m` increments. Across all nine original-detail frames:

- brick-course density remains stable;
- fine horizontal lines do not collapse into a broad band or moire fan;
- large source variations remain attached to the facade rather than the
  screen;
- no vertical seam or run-reset line pops in and out;
- the glazing and individual door silhouettes remain consistently darker than
  the brick field; and
- the material does not introduce a false plaque, window, crack, shadow,
  object, or focal stain.

The sequence is a sampled spatial diagnostic, not continuous player footage.
It supports proceeding to integration but cannot certify sub-frame temporal
stability, player head-bob, arbitrary speed, farther LOD behavior, or the ENE
side/corner under motion.

## Believability / visual-interest gate

| Criterion | Verdict | Finding |
| --- | --- | --- |
| Material identity | **PASS** | Readable muted brown-red masonry replaces a flat brown field. |
| Physical scale | **PASS** | `2.5 m` per source cell yields plausible architectural brick at `16–31 m` test distances. |
| Cell cadence | **PASS_WITH_LIMITATION** | Mild repetition is discoverable but not distracting; no dominant grid or hero-cell pattern. |
| Run and corner continuity | **PASS** | No visible per-run reset; audited U is cumulative through each ordered side chain. |
| Motion stability | **PASS_WITH_LIMITATION** | Nine native samples show no gross shimmer/moire event; continuous-time motion remains a live-integration check. |
| Lighting honesty | **PASS_WITH_LIMITATION** | No baked-light cue is visible and prior pilot evidence changed light successfully; Phase 2 itself has no rotated-light pair. |
| Architectural contrast | **PASS** | Warm field remains clearly lighter than glazing and subordinate to complete entry/gallery modules. |
| False facade content | **PASS** | No openings, signs, objects, deep damage, plaques, or whole-elevation features are encoded. |
| Noise / visual control | **PASS** | Variation is fine and local; it enriches the field without competing with modules. |

## Tint, repeat, and motion guidance

### Keep for the first live integration

- material tint **`Color(0.70, 0.66, 0.62, 1.0)`**;
- scalar roughness **`0.86`**, metallic `0.0`, albedo map only;
- anisotropic mipmapped filtering;
- repeat cell **`2.5 m`**, expressed as `uv1_scale = (0.4, 0.4, 1)`;
- continuous metre U across runs `0..4` and separately across runs `5..9`;
- world-Y metre V, including the non-flat foundation endpoints;
- one intentional U reset at the start of each explicitly named side; and
- scalar material on the current narrow module-pier BoxMesh batch.

Do not randomize phase per module or run. Do not hide a future reset beneath
procedural dirt. Do not texture runs `10..12`, the upper band, roof, hidden
high/low interface, or any unobserved return as part of this promotion.

Freeze the current tint and cell for the first live A/B so integration changes
only attachment context. If live lighting alone reduces the black-glazing
separation, permit a second fixed-pose material A/B no wider than `+0.02` on
all RGB tint channels; if the brick becomes too dominant against the pale high
volume, test `-0.02` on all three channels. Do not change hue order, cell size,
and exposure simultaneously.

Keep `2.5 m` unless real continuous motion exposes a defect. If fine courses
actually shimmer, first test a single `2.6 m` receiver-only cell while holding
tint, camera, light, and geometry fixed. If only the mild `2.5 m` cell cadence
is discoverable, accept it. Regeneration is justified only for a distracting
grid, unfixable edge discontinuity, baked light, false content, or scale failure.

### Required post-attachment motion check

Capture a continuous ordinary-player walk, not another sparse slideshow:

1. WSW and ENE public sides at normal player speed and roughly `12–20 m`
   standoff;
2. at least one approach toward and one pass across an entry module;
3. one traversal across an intra-side source-run corner and one view of the
   intentional side-start reset; and
4. one matched view under meaningfully changed sun direction or time of day.

Pass if mortar/course frequency stays stable, the texture remains world-locked,
entry and glazing contrast survives, and no reset seam appears. Reject only a
visible crawling grid, moire fan, phase pop, dominant repeated cell, or
lighting contradiction—not a seam that can be found only by pausing and pixel
searching.

## Metre-UV and exact receiver audit

The generic helper at
`res://game/scripts/world/facades/facade_meter_uv_adapter.gd` has SHA-256
`47e710b9ea7c5de5122430199e4105cbba5f672d22f59832f13b8004f16c5a1d`.
It contains no Isle House coupling and fails closed on duplicate/missing runs,
wrong side IDs, disconnected endpoints, invalid tolerance, non-positive runs,
and declared/measured length drift.

Its exact current Isle House plans are:

| Side | Exact mapped runs | U contract | Total |
| --- | --- | --- | ---: |
| `LOW-WSW-AVENUE-OF-THE-PALMS` | `0,1,2,3,4` | start `0`; continuous through ordered corners | `51.6984152793884 m` |
| `LOW-ENE-GARDEN-WALK` | `5,6,7,8,9` | new side start `0`; continuous through ordered corners | `49.7970167398453 m` |
| `LOW-NNW-PROTECTED` | `10,11,12` | no prototype field or UVs | protected |

The exact-receiver contract passed with deterministic signature
`7f299bf99599c2f3f9feb982fb857663355645ffbf1eaa36e6714000b8c8d4cc`.
It verified the serialized `w1282547787` wall, all ten public field quads,
eight complete modules only on runs `2/3/8/9`, untouched upper/roof/interface
regions, and no prototype attachment to another source record.

Topology remains `10` field segments / `20` field triangles plus `152` module
boxes / `1,824` module triangles, for `1,844` visual triangles total. There are
zero collision nodes, navigation nodes, or spray receivers. The live world
builder and facade registry contain no standalone prototype/helper/material
attachment.

## Evidence and package verification

- The Phase 2 manifest SHA-256 is
  `76e23e60ba1a08eefbdaf230e8de42559500bc68b7a4836a296e36cda289e2a2`.
  All four fixed and nine motion PNG byte hashes match it; the same-camera front
  and oblique control/candidate pairs also match exactly in their recorded
  camera and target positions.
- The promoted source PNG is byte-identical to the independently accepted pilot
  brick:
  `0abbb429066966c1cfc1e0209a2a454c41dae73743fc119ffdf7cd82ee3ef35d`.
  Its shared material hash is
  `488ad52ae9aa0155fd0356eaff128b3ab88ba0c23528c6ae332e7e54c772ffb6`.
- The source tree non-destructively retains both pilot texture/material
  families. `export_presets.cfg` explicitly excludes both isolated
  `genai_pilot_v1` directories from the `all_resources` export.
- The baseline PCK is `62,134,828` bytes with SHA-256
  `56f3543720030633ae6688a1baafe086765e8be4bd39186b093d7a54b07cc92a`.
  The final PCK, containing only the promoted brick from the GenAI families,
  is `59,524,324` bytes with SHA-256
  `c84d8f3654d02eb17d7fc97907d66a6c26bc5e12a0a97753c84b3ff331f71263`,
  a `2,610,504`-byte reduction.
- A fresh mounted-PCK run from an empty temporary directory loaded the promoted
  brick texture/material, metre-UV helper, prototype config/scene/factory, and
  found neither pilot texture nor either pilot material. Unused stucco is not
  mounted.

Fresh passing checks:

- `headless_facade_meter_uv_adapter_contract.gd`;
- `headless_isle_house_low_facade_prototype_contract.gd`;
- `headless_genai_texture_phase2_package_contract.gd` in source mode;
- `headless_isle_house_low_genai_brick_phase2_evidence_contract.gd`; and
- `headless_genai_texture_phase2_package_contract.gd -- --mounted` against the
  final PCK from an empty working directory.

## Promotion boundary

Proceed with the smallest reversible live seam: instantiate the standalone
prototype only after exact `matches_target(record)` success for
`building-composite:w1249412094:w1282547787:wall`, then call
`configure(record)`. Preserve the current field/material/UV bytes for the first
comparison and leave collision, navigation, spray, roof, silhouette, high
volume, upper low band, interface, and protected return ownership unchanged.

After attachment, collect the continuous player-motion and changed-light proof
above plus ordinary whole-composite views. Only that later evidence may decide
whether the Isle House low part and complete composite are recognizable and
believable live. Phase 2 authorizes integration testing; it does not pre-accept
the building.

# Independent visual bar-raiser review — GenAI material pilot v1

Reviewed: **2026-09-04**  
Reviewer: **`/root/visual_bar_raiser`**  
Review order: **both generated source PNGs at original `1254x1254` detail;
unblended `3x3`; front and changed-light oblique A/B at original `1440x900`;
prompt, provenance, manifest, materials, imports, capture implementation, and
runtime-isolation contract afterward**

## Verdict

| Material | Verdict | Best next use | Recognition effect |
| --- | --- | --- | --- |
| Warm ivory mineral stucco v2 | **PASS_WITH_LIMITATION** | viable shared pale-mineral field; retain `3.0 m` span for the first receiver trial and use a cooler/darker tint | **none claimed or earned** |
| Muted brown-red brick | **PASS_WITH_LIMITATION** | strongest visual improvement; proceed to one reversible mapped brick-receiver A/B after unified metre-UV work | **none claimed or earned** |
| Pilot as a whole | **PASS_WITH_LIMITATION** | proceed with exactly one reversible live A/B, brick first; no more generation is justified now | material-believability experiment only |

Neither candidate has a distracting seam, grid, baked directional light,
hallucinated facade feature, grossly wrong scale, or excessive noise in the
supplied meter-scale stills. Pixel-perfect edge identity is not required. The
brick's source-cell cadence and edge phase can be found under deliberate
inspection, and the stucco's exact cell can be found in the raw repeat, but
neither dominates the tested `6.0 x 3.2 m` panels. Motion shimmer and actual
window/trim/entrance contrast remain unreviewed because this lab contains no
walking clip or live architectural receiver.

This pass does **not** make either material target-specific, historically exact,
PBR-complete, live, or suitable for 213 one-off copies. Geometry, complete
modules, and facade hierarchy remain the recognition carriers.

## Pixel-first findings

### Warm ivory mineral source

The original source is a clean, orthographic pale mineral field. It contains no
window, door, sign, crack, panel, corner, horizon, object-shaped stain,
watermark, or perspective cue. Fine mottling is isotropic enough to avoid a
directional brush read. There is no obvious fixed cast shadow, specular streak,
vignette, or top-to-bottom light gradient.

The source is visually closer to sand-finished painted stucco or a fine mineral
coating than smooth cast concrete. That is a valid shared material family, but
it must not be described as a surveyed Building 1 substrate.

### Muted brown-red brick source

The source shows level running-bond courses, consistent warm grey-brown mortar,
and restrained brick-to-brick variation. There are no letters, plaques, windows,
damage marks, props, or standout hero bricks. Unit faces carry fine local grain
and mild edge/mortar darkening, but no distracting fixed sun direction is
visible in either changed-light view. With scalar roughness and no normal map,
this remains an albedo representation of local masonry variation rather than a
claim of physical relief.

At the tested `3.0 m` span, the source implies deliberately chunky architectural
brick. It is plausible game scale, not an obvious miniature or giant-brick
failure. A slightly smaller span is preferable for the Isle House live-work
realm, as detailed below.

## Unblended `3x3` repeat

### Stucco

**PASS_WITH_LIMITATION.** The rejected v1 cloud-cell problem is not present.
Nine copies read as one quiet field at normal inspection. Once the two `200 px`
tile boundaries are known, a faint repeated fine-grain fingerprint and very
slight boundary/value continuity change can be located. It does not form a
dominant cross, stripe, checkerboard, or repeated stain. This is within the
owner's progress-over-perfect-tiling tolerance.

### Brick

**PASS_WITH_LIMITATION.** Horizontal course height remains continuous through
the repeat. At the vertical cell joins, some cut bricks combine into a subtly
different joint rhythm, and exact pigment clusters repeat every cell. Those
features create a mild discoverable vertical cadence in the raw `3x3`; they do
not create a broken course, a glaring solid line, a half-height brick, or a
dominant grid at the supplied scale.

The limitation matters more on a `50 m` facade than on the `6 m` lab panel. A
unified chain UV must avoid restarting the phase at every generated run, and the
first live trial must include a long enough view to reveal repeated columns. No
second generation is justified before that real receiver evidence exists.

## Real-scale A/B

### Front/direct light

| Family | Current control | Generated candidate | Bar-raiser judgment |
| --- | --- | --- | --- |
| Stucco | clean and appropriately quiet, but nearly flat at this distance | adds a restrained fine mineral read and gentle tonal richness | **modest improvement**; candidate is a little brighter and creamier than the control |
| Brick | flat brown field with no material scale | immediately reads as coursed masonry with coherent human/building scale | **clear improvement**; it adds material identity without adding a facade program |

The generated stucco does not create a new focal feature, which is correct. Its
benefit is subtle and will not fix Building 1's shallow window reveals, weak
entrance hierarchy, or end-relief semantics. The generated brick supplies the
larger before/after gain because the flat control contains no masonry structure.

### Oblique/changed light

Both materials retain their character when the camera and directional light
change. The stucco does not expose a fixed bright edge or shadow direction. The
brick's courses remain level in material space and do not become a noisy moire
pattern in the captured still. No generated highlight fights the real light.
Static evidence cannot prove absence of shimmer during movement.

The candidate panels remain brighter/more saturated than their controls because
their albedo and tint differ. That is a tunable material choice, not evidence of
baked lighting. A live comparison must protect the value separation between
field, trim, glazing, and entrances rather than merely choosing the brighter
option.

## Best scale, tint, and material guidance

These are reversible starting points for one future live A/B, not source facts.

### Warm ivory mineral

- **Keep the physical repeat at `3.0 m`** for the first receiver trial. The
  tested grain is subordinate at this scale, and changing both scale and
  receiver simultaneously would make the A/B harder to interpret.
- Start cooler and darker than the pilot's
  `Color(0.90, 0.87, 0.78)`: approximately
  **`Color(0.84, 0.83, 0.79)`**, with no more than `+/-0.03` per-channel tuning
  in the bounded comparison. The goal is to keep light trim and pale field
  separable and avoid a yellow cream wash.
- Keep scalar roughness near **`0.84–0.90`** and metallic `0.0`. Do not fabricate
  a normal map merely to make the fine albedo grain louder.
- If it is later prepared for a shared production library, a `512` or `1024`
  derivative should be compared before retaining the `1254` source resolution.
  This low-information field is the better candidate for `512`, but the resize
  needs its own hash/import/repeat proof.
- Do not put this material live on Building 1 until the public-front
  entrance/reveal hierarchy is stable. Otherwise a surface change may be
  misreported as the solution to a geometry problem.

### Muted brown-red brick

- For the mapped Isle House low live-work realm, start at approximately
  **`2.4–2.6 m` per source cell**; `2.5 m` is the recommended first value. This
  makes the current brick width/course closer to a familiar architectural unit
  while retaining useful ordinary-distance readability. The value remains
  production inference, not a surveyed product dimension.
- Start slightly darker and less orange than the pilot's
  `Color(0.78, 0.72, 0.66)`: approximately
  **`Color(0.70, 0.66, 0.62)`**, then compare against the existing flat dark
  brick control under the same light. The warm low realm should support, not
  overpower, the pale high tower and dark glazing.
- Keep scalar roughness near **`0.84–0.90`** and metallic `0.0`. Retain the
  current no-normal/no-height boundary for the first live trial.
- Use **`1024`** as the first production-size derivative if resizing is
  authorized. Brick edges benefit more from retained resolution than stucco.
- Apply one continuous metre-based U phase across each mapped public side chain.
  Do not reset on runs `0..4` or `5..9`; a corner may begin a new side-local
  phase. Keep the protected NNW side, upper band, roof, and hidden interface
  unchanged.
- If a repeated vertical column becomes distracting on the long receiver, first
  adjust side-local phase/scale or place the join beneath an already-supported
  complete pier/module. Do not add random grime or regenerate immediately.

## Memory and rollout judgment

The two sources occupy `5.26 MiB` on disk; their current lossless imported
textures occupy `5.13 MiB`. The documented conservative decoded RGBA8 plus full
mipmap estimate is approximately `8.0 MiB` per `1254²` texture, `16.0 MiB`
combined. That is harmless for this two-asset lab and wasteful as a one-texture-
per-building strategy.

For comparison, one `1024²` RGBA8 texture with full mipmaps is approximately
`5.33 MiB` decoded, and one `512²` texture is approximately `1.33 MiB`. A shared
library can therefore keep brick at `1024` and test low-information stucco at
`512` without multiplying two current `1254²` assets across 213 buildings.
Actual renderer residency and compression quality still require profiling; the
estimates are not measured VRAM.

The correct rollout remains a small shared family library plus target-specific
geometry/modules. Do not generate a unique full facade texture for each unit.

## Prompt, provenance, truth, and package boundary

| Gate | Result | Finding |
| --- | --- | --- |
| Exact prompts retained | **PASS** | Initial and targeted stucco prompts and the brick prompt are recorded verbatim. |
| Input/source pixels | **PASS** | No input image was used; no Street View, museum, NPS, owner-private, or other reference pixel was uploaded or embedded. |
| Target truth | **PASS** | Prompts request material families only. The project does not claim surveyed product, color, bond, scale, current condition, or target-specific fidelity. |
| False facade content | **PASS** | Source and evidence pixels contain no windows, doors, signs, emblems, objects, deep cracks, or whole-elevation layout. |
| PBR honesty | **PASS_WITH_LIMITATION** | Albedo plus scalar roughness only; no mismatched generated maps. Fine brick edge/mortar darkening is present but not a distracting fixed-light illusion. |
| Project-resource privacy | **PASS** | Runtime assets contain only generated pixels and `res://` references; external saved-source paths and prompts remain in discovery documentation. |
| Live runtime attachment | **PASS — none** | Repository search finds the pilot only in its materials/textures and focused test/capture scripts. The focused isolation contract passes. |
| Export/package isolation | **LIMITATION** | `export_presets.cfg` uses `export_filter="all_resources"`. Although unused by live code, the assets under `game/resources/` are eligible for a fresh PCK and add about `5.13 MiB` of imported payload. Exclude/move unselected pilot assets or deliberately promote one before the next final export. |

The manifest's nested `generated.*.sha256` values are the source texture hashes,
not material-resource hashes. The source document and focused contract make
that meaning recoverable, but a future schema should name the field
`texture_sha256` and record `material_sha256` separately.

No live runtime behavior, geometry, facade assignment, collision, navigation,
spray ownership, or current launched app changed. A future export from the
present working tree is a separate package decision because of the
`all_resources` filter.

## Exact-current evidence check

- Source texture hashes:
  - stucco `af1c7a8f90ab5e60b9ab40a3bcf087aa26b00892edd48a2b4f1c84533f8be51c`;
  - brick `0abbb429066966c1cfc1e0209a2a454c41dae73743fc119ffdf7cd82ee3ef35d`.
- Evidence image hashes match the manifest:
  - repeat `ee954bd1e2e63a75d13d78adeda27379eaf52a1a74b25c21c81e0001396482ce`;
  - front `1343879ca6be4ddd81688abe19a21c1853c2a00ad038bebe4b35ccc7fb033469`;
  - oblique `cd330a5f7f2a0044a31a75917c470b4730a93bd0a065559474238ae857f6e1b7`.
- Manifest SHA-256:
  `69ceb11111637eeb8e5d84fbcd621ff32443c0271c64d1263fff72cd75c9474a`.
- Both sources decode as `1254x1254` RGB without alpha; all three evidence
  images decode as `1440x900`.
- A fresh `headless_genai_texture_pilot_v1_contract.gd` run passed: repeat,
  mipmaps, anisotropic filtering, scalar roughness, no fabricated PBR maps, and
  no live Building 1, Isle House, world-builder, or main-scene attachment.
- The lab proves one-unit-equals-one-metre UVs on purpose-built panels with a
  `1/3` material scale. It does **not** prove physical scale on heterogeneous
  current building receivers; that is why the unified UV adapter is a
  prerequisite to a live trial.

## Next action

**Proceed after unified UV adapter work to one reversible live brick A/B.**
Prefer an independently source-confirmed, low-risk non-hero warm-brick receiver.
If none is ready, use the exact mapped Isle House low public-side prototype as
an isolated live trial; keep geometry, modules, camera, exposure, lighting, and
every non-material state fixed. If Isle House is used, this remains a trial and
does not promote the low part or whole composite.

Required evidence:

1. one whole mapped side at ordinary grounded player distance, long enough to
   show at least five source-cell repeats;
2. one close grounded oblique showing brick scale, entry/pier contact, and the
   side-chain run join;
3. the same ordinary camera under changed light; and
4. a short walking sweep along the wall to expose shimmer, moire, or a moving
   repeat grid.

Pass if the generated brick is independently preferred over the flat control
for material believability, remains subordinate to entries/glazing/high tower,
and shows no distracting cell columns, broken bond, shimmer, baked-light read,
or per-run phase reset. A minor discoverable edge mismatch remains acceptable.

Do **not** run both live materials at once. Defer Building 1 stucco until its
new geometry/hierarchy is stable, then reuse the same A/B method if the brick
trial validates the unified UV path.

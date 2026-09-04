# Independent bar-raiser review — B225 cladding repair v1

Date: 2026-09-04  
Reviewer: `/root/visual_bar_raiser`  
Independence: the reviewer did not generate, edit, implement, place, or capture
the candidate.

## Decision

**PASS_WITH_LIMITATION for standalone promotion to one future reversible live
receiver A/B.**

The repair clears the failure that blocked the prior B225 prototype. The lower
field no longer reads as fourteen dark ruler lines or a barcode, yet it is not
visually blank: restrained horizontal course boundaries and quiet age variation
remain visible. The ten varied clerestory groups stay the dominant structural
and recognition cue in every matched view and throughout the 25-frame motion
sweep.

The limitation is material polish, not identity failure. At native texture and
close-render detail, the paint grain is visibly synthetic and a broad tonal
pattern can be rediscovered at the declared 8 m repeat. Under the alternate sun,
the scalar tint also trends warmer/brighter than the source's aged light-gray /
off-white description. None becomes a distracting grid, seam, moving artifact,
false facade feature, or competing identity cue in this evidence.

This verdict authorizes only a fresh receiver-relative A/B on
`building:w95934119:wall`, source edge `3`, exact ordered runs `10..13`. It does
not authorize direct instantiation of the standalone scene, live acceptance,
catalog mutation, or denominator credit.

## Pixel-first visual judgment

I first opened all eight clean `1440x900` control/candidate stills at original
detail, without reading the request, README, manifests, configs, prompts, or
contracts. I then inspected all 25 original motion frames in order at full
detail and fixed the visual verdict before opening any metadata.

### Matched stills

- **Complete front:** the control's continuous black rules dominate its whole
  lower mass. The candidate replaces them with a light, materially coherent
  field whose fine joints stay subordinate to the clerestory. Broad mottling is
  mildly discoverable, but there is no hard 8 m grid or damage token.
- **Grounded oblique:** the candidate preserves the low mass, projected pale
  frames, recessed dark panes, sill, and roof-edge hierarchy. No vertical phase
  reset appears where the four source runs meet, and the wall does not flatten
  into a decal.
- **Close:** the wall reads as aged painted horizontal cladding, not blank
  plaster and not stacked black reveals. The raw-looking grain is somewhat
  frosted/synthetic at this distance; it remains low contrast and does not
  resemble lettering, knots, openings, stains, or semantic damage.
- **Changed light:** the clerestory remains the dominant band and the course
  direction stays quiet. The candidate becomes pale warm ivory more readily
  than the normal-light views; that is the principal tint caveat, not a reason
  to restore contrast or add geometry.

### Motion and recurrence

Frames `00..24` move continuously from chain U `8.0 m` to `26.0 m` in `0.75 m`
steps at a `12 m` standoff. The sequence crosses joins at `10.372629078 m`,
`16.883522872 m`, and `23.933383083 m`.

- Fine horizontal lines remain stable; I found no shimmer, moire, crawling, or
  changing-light illusion across consecutive frames.
- Low-frequency age patches track the facade surface rather than the camera.
- No internal run join produces a visible vertical seam, phase jump, doubled
  line, or sudden change in scale.
- The approximately 8 m tonal cadence can be found when deliberately tracking
  the lower field, but it never overtakes the clerestory or becomes a regular
  grid at the tested distance. Under the user's progress-over-perfect-tiling
  bar, this is acceptable.

## Believability / visual-interest gate

| Question | Verdict | Reason |
| --- | --- | --- |
| Barcode/diagram read removed | **PASS** | Fourteen dark geometry strips are absent; the wall is again the dominant field. |
| Wall remains materially legible | **PASS** | Quiet joints, matte value drift, and restrained age prevent a blank swatch. |
| Clerestory remains primary | **PASS** | Ten complete varied groups, projected pale frames, and recessed dark glazing dominate all stills and motion frames. |
| Coherent whole-side hierarchy | **PASS** | Low mass, light field, dark high register, sill, and roof edge read in that order. |
| Seams / phase continuity | **PASS** | No visible reset across runs `10..13`; cumulative U is also mechanically verified. |
| Changed-light behavior | **PASS_WITH_LIMITATION** | Structure and courses survive; the wall shifts somewhat warm/bright. |
| Grain / recurrence | **PASS_WITH_LIMITATION** | Synthetic micrograin and broad 8 m recurrence are visible only under close, deliberate inspection. |
| False facade features | **PASS** | No invented door, window, sign, text, logo, stain, damage token, or opening appears. |
| Motion stability | **PASS** | No distracting crawl, shimmer, or moire in 25 native frames. |

The source-supported recognition pair remains intact: varied continuous high
clerestory grouping plus aged horizontal cladding on a low one-storey mass.
Material adds believability; it does not pretend to add identity by itself.

## Keep / change guidance for the live A/B

### Keep

1. Keep the clerestory transforms and material hierarchy unchanged. They are
   the recognition payload.
2. Keep the four field quads on one chain-global metre U coordinate and retain
   the `8.0 x 3.48 m` texture cell for the first live A/B. Do not restart U at a
   generated run or shrink the cell, which would amplify repetition.
3. Keep joint contrast at or below the candidate level, roughness `0.88`,
   repeat, mipmaps, and anisotropic filtering. Do not reintroduce dark reveal
   boxes, a second procedural course frequency, normal/height maps, or arbitrary
   noise.
4. Keep the lower field free of unsupported openings, signs, endpoint features,
   and semantic damage.

### Change only if fresh live evidence exposes the limitation

1. **Tint:** begin the receiver A/B with the reviewed scalar
   `(0.76, 0.755, 0.72, 1)`. If island sun makes it read cream/yellow rather than
   aged light gray, change only the multiplier toward neutral by raising blue to
   roughly `0.74..0.75` without increasing red or contrast, then recapture. Do
   not darken the joints to compensate.
2. **Scale / repeat:** retain the 8 m horizontal cell. If the full live chain
   reveals a distracting 8 m cadence, replace the source with a low-pass,
   edge-equalized derivative at the same physical scale. Do not reduce the tile
   width or layer unbounded procedural grime.
3. **Grain:** the native bitmap contains relief-like synthetic microtexture,
   although it filters quietly in the evidence. If it becomes legible during a
   closer player approach, soften only that high-frequency grain; preserve the
   horizontal course family and broad low-contrast age.
4. **Performance:** this one `1254 x 1254` RGB albedo adds `2,104,448` bytes
   (`2.006958 MiB`) to the measured PCK; the imported `.ctex` is `2,031,028`
   bytes, and decoded RGBA8 plus a full mip chain has an explicit upper estimate
   of `8,386,752` bytes. That is acceptable for one reversible A/B, not a
   precedent for hundreds of unique facade textures. If the live A/B proves the
   material valuable, test a lower-resolution derivative in a separately
   recaptured package before broad reuse.

## Provenance and technical verification

These checks were performed only after the visual verdict was fixed.

- The selected RGB albedo is recorded as built-in `image_gen.imagegen` output
  from 2026-09-04 with no reference images or stored source pixels. The initial
  generation is retained outside the project and explicitly rejected for
  repeated bevel-like baked lighting. The selected one-edit result records both
  prompts, output paths, hashes, rejection rationale, model-identity nonclaim,
  licensing boundary, and nonclaims against scan/as-built/seamless identity.
- Selected source output and project PNG share SHA-256
  `63e755e9fe5a5dcfb662b4265f1e769fc1b371987b55579b1ca4ffb63015015b`.
  The material is albedo plus scalar tint/roughness only: no fabricated normal,
  roughness, metallic, height, or AO maps.
- UVs run continuously from `0.0` to `46.261968372 m` across exact runs
  `10,11,12,13`; the three internal U endpoints equal the next starts. With
  material scale `(0.125, 0.28735632)`, the chain exposes `5.7827460465`
  horizontal repeats. There are zero per-run phase resets.
- The standalone topology reproduces as three render batches, four field quads,
  90 retained boxes, and 1,088 triangles (`-208` versus the rejected control),
  with zero collision, navigation, decal, or spray ownership. The retained
  clerestory transforms/material batches compare equal to the sealed control.
- The sealed D1 inventory rechecked `35/35` files, including B201, the original
  B225 prototype, nine evidence PNGs, configs, materials, factory, scene, and
  earlier independent review. Reproduced signatures are B201
  `57573bc19d6c6a45b946827e76a346c592d5238a310e923a30a41b149f963511`,
  original B225
  `179d898c4635917743e967819998256c7fe4938981da69e7d4664e1e7e13b58a`,
  and pair
  `17c560633517963489b76430729bb6476065bb0d9a6385b3a913103a778c32ad`.
- No repair resource token occurs in live world construction, the accepted-run
  trial, runtime registry/loader, or facade catalog. `runtime_attachment=false`,
  `exact_receiver_layout=false`, and live placement count remains zero.
- The same-snapshot PCK audit reproduced an excluded pack of `46,261,548`
  bytes (`af13d9d...a384a724`) and included pack of `48,365,996` bytes
  (`89a47497...edb52bd9`). Evidence is export-excluded. I directly mounted the
  included PCK and confirmed the config, scene, factory, UV helper, material,
  and albedo load. Because `all_resources` currently bundles this non-live
  branch, add its narrow export exclusion if receiver work is postponed.
- Fresh focused runs passed the structural/material/isolation contract, the
  33-image evidence/package contract, the sealed D1 prototype contract, and the
  shared metre-UV adapter contract under Godot `4.7.2`.

## Promotion boundary

**Proceed to one reversible live integration study.** Author a new fail-closed
receiver-relative adapter for only `building:w95934119:wall`, source edge `3`,
ordered runs `10..13`, exact length `46.261968372 m`. Rederive corners from the
frozen receiver and preserve one cumulative U; do not instantiate this
standalone scene or attach anything to the roof, other faces, collision,
navigation, or spray systems.

Fresh world-space whole-side, grounded oblique, changed-light, motion, and
nearby-decoy evidence remains mandatory. Only that exact-current live packet
can decide acceptance or denominator credit.

# GenAI homogeneous facade-material pilot v1

Date generated and inspected: **2026-09-04 UTC**

Status: **isolated technical pilot; not attached to a live receiver; visual outcome pending independent bar-raiser review**

## Why this pilot exists

The existing facade work has two separate problems that should not be conflated:

1. A homogeneous surface needs believable fine material variation and stable response at ordinary distance.
2. A recognizable building needs target-specific massing, window/door rhythm, entrances, signs, roofline, and other architectural grammar.

Generated albedo can help the first problem. It cannot, by itself, solve the second. Baking landmark features into a generic tile also couples physical scales and risks inventing repeated architecture at every seam. This pilot therefore contains **material fields only**, with no windows, doors, signs, panels, facade modules, or building identity claims.

## Execution and source boundary

- Generation mode: Codex built-in `image_gen` tool, one call per distinct asset.
- Model identifier: not exposed by the built-in tool; none is claimed.
- Input images: none.
- External/reference pixels uploaded or embedded: none.
- Source boundary: text prompts only. Street View, museum, NPS, and owner-reference pixels were not supplied to the generator and are not present in these files.
- Project treatment: generated artifacts with logged prompts and hashes. No claim is made here about exclusivity, copyrightability, exact real-world material, or suitability for public distribution; the project's private-use terms and the applicable generation-service terms remain controlling.

## Selected output A — warm ivory mineral surface

- Project asset: `res://game/resources/textures/world/genai_pilot_v1/warm_ivory_mineral_albedo_v2.png`
- Built-in saved-source receipt: `imagegen:warm-ivory-mineral-v2:selected`; the workstation storage path is intentionally omitted and the content hash below is authoritative.
- Dimensions: `1254 × 1254`, RGB, no alpha.
- PNG bytes: `2,811,712` (filesystem allocation rounded to `2.7 MiB`).
- SHA-256: `af1c7a8f90ab5e60b9ab40a3bcf087aa26b00892edd48a2b4f1c84533f8be51c`
- Pilot physical repeat: `3.0 m × 3.0 m`, reversible production assumption.
- Material: reversible warm-ivory tint `Color(0.90, 0.87, 0.78)`; scalar roughness `0.86`; metallic `0.0`; no normal, roughness, AO, height, or displacement bitmap.

Exact prompt:

```text
Use case: photorealistic-natural
Asset type: seamless game-ready facade albedo texture swatch for a Godot 3D environment
Primary request: create a restrained warm ivory painted mineral stucco / smooth cast-concrete surface suitable for a believable 1930s institutional facade, with subtle age and material richness but no architectural features
Scene/backdrop: the material surface fills the square image edge to edge
Subject: only the continuous warm ivory mineral surface
Style/medium: realistic scanned-material appearance, albedo/base-color map only
Composition/framing: perfectly orthographic straight-on flat square swatch; no perspective, no wall edges, no corners, no ground, no horizon
Lighting/mood: perfectly even neutral diffuse illumination; no baked directional light, highlights, shadows, ambient occlusion, vignette, or gradient
Color palette: restrained warm ivory and pale mineral beige; low contrast; no bright white and no yellow cast
Materials/textures: fine mineral grain, very sparse shallow paint wear, broad low-frequency tonal drift that remains subtle at ordinary player distance; no deep cracks or identifiable marks; apparent physical coverage roughly 3 by 3 meters
Constraints: must be designed to tile seamlessly on all four edges; edge-to-edge texture; no alpha; no text, logo, graffiti, watermark, windows, doors, vents, bricks, blocks, panels, seams, stains shaped like objects, people, vegetation, or props; avoid any recognizable repeated motif; albedo only, not a rendered material ball and not a PBR preview
Avoid: perspective, directional lighting, strong grunge, photographic wall scene, obvious scale cues, border, frame, edge mismatch, high-frequency noise, repeated blobs
```

The initial candidate (`c00ccbb2c31b8ca9ab7bec61738adfe6070b6e9580806d1fa9328323b540e3e5`) passed the isolated content screen but its first unblended `3×3` proof exposed repeated cloud-like macro blotches. It was removed from the project directory after a single targeted iteration; the opaque receipt `imagegen:warm-ivory-mineral-v1:rejected-macro-repeat` plus that content hash preserves its provenance without publishing a workstation storage path.

Exact targeted edit prompt for selected v2:

```text
Use case: precise-object-edit
Asset type: seamless game-ready facade albedo texture swatch for a Godot 3D environment
Input image: Image 1 is the edit target
Primary request: change only the broad cloud-like tonal blotches and large repeating patches; reduce their amplitude substantially and redistribute variation into restrained, non-directional, fine-to-medium mineral mottling that will not form an obvious macro pattern in an unblended 3 by 3 repeat
Preserve exactly: the warm ivory / pale mineral beige palette, realistic painted mineral stucco character, fine grain, low contrast, square edge-to-edge orthographic presentation, neutral albedo-only appearance, and absence of architectural features
Lighting/mood: preserve perfectly even neutral diffuse appearance with no baked directional light, highlights, shadows, ambient occlusion, vignette, or gradient
Constraints: make all four edges tile-friendly; no perspective, wall edge, corner, border, frame, ground, horizon, text, logo, graffiti, watermark, window, door, vent, brick, block, panel, seam, object-shaped stain, people, vegetation, prop, deep crack, high-frequency noise, unique mark, or new element; apparent coverage remains roughly 3 by 3 meters
Avoid: visible cloud cells, repeated blobs, directional brushing, edge mismatch, noisy grunge; do not change anything except the scale and distribution of the tonal variation
```

Selected-v2 original-detail inspection: **pass candidate screen**. It is orthographic, restrained, neutral, free of objects/text, and does not show an obvious directional shadow or highlight. The large cloud patches are materially reduced; fine grain remains somewhat stronger than the present procedural field and is judged again in the final `3×3`/meter-scale proof.

## Selected output B — muted brown-red brick

- Project asset: `res://game/resources/textures/world/genai_pilot_v1/muted_brown_red_brick_albedo.png`
- Built-in saved-source receipt: `imagegen:muted-brown-red-brick-v1:selected`; the workstation storage path is intentionally omitted and the content hash below is authoritative.
- Dimensions: `1254 × 1254`, RGB, no alpha.
- PNG bytes: `2,704,384` (filesystem allocation rounded to `2.6 MiB`).
- SHA-256: `0abbb429066966c1cfc1e0209a2a454c41dae73743fc119ffdf7cd82ee3ef35d`
- Pilot physical repeat: `3.0 m × 3.0 m`, reversible production assumption.
- Material: reversible muting tint `Color(0.78, 0.72, 0.66)`; scalar roughness `0.86`; metallic `0.0`; no normal, roughness, AO, height, or displacement bitmap.

Exact prompt:

```text
Use case: photorealistic-natural
Asset type: seamless game-ready facade albedo texture swatch for a Godot 3D environment
Primary request: create a restrained muted warm brown-red brick masonry surface suitable for a believable contemporary residential / live-work podium facade, with clear but understated brick coursing
Scene/backdrop: the masonry surface fills the square image edge to edge
Subject: only a continuous running-bond brick wall, made of small uniform architectural bricks with subtle natural variation
Style/medium: realistic scanned-material appearance, albedo/base-color map only
Composition/framing: perfectly orthographic straight-on flat square swatch; horizontal courses exactly level; no perspective, no wall edges, no corners, no ground, no horizon
Lighting/mood: perfectly even neutral diffuse illumination; no baked directional light, highlights, shadows, ambient occlusion, vignette, or gradient
Color palette: muted warm brown-red, umber, and restrained terracotta bricks; low saturation; mortar medium warm grey-brown; low-to-medium contrast
Materials/textures: fine brick grain, modest brick-to-brick hue variation, thin consistent recessed-looking mortar expressed only by base color; no damage; apparent physical coverage roughly 3 by 3 meters
Constraints: must be designed to tile seamlessly on all four edges with the running bond continuing correctly; edge-to-edge texture; no alpha; no text, logo, graffiti, watermark, windows, doors, vents, blocks, facade panels, stains shaped like objects, people, vegetation, or props; avoid unique bricks that make repetition obvious; albedo only, not a rendered material ball and not a PBR preview
Avoid: perspective, directional lighting, strong grunge, photographic wall scene, obvious scale objects, border, frame, edge mismatch, crooked courses, high-frequency noise, repeated standout bricks
```

Original-detail inspection before repeat proof: **pass candidate screen with an edge-phase watch item**. Courses are level, hue variation is restrained, and no foreign objects or baked directional illumination are apparent. Because running-bond edges must preserve brick and mortar phase, the unblended `3×3` proof—not the isolated attractive square—determines whether the edge is acceptable for this pilot.

## Godot scale and cost

- Both pilot materials use repeat plus linear mipmapped anisotropic filtering.
- Their meshes are evaluated with UVs expressed in meters and a `1 / 3` material UV scale, so one bitmap spans an assumed `3 m × 3 m`.
- Both use scalar roughness. Fabricating roughness or normal maps independently from the albedo would create mismatched surface facts, so this pilot intentionally does not do that.
- Source PNG disk cost is `5,516,096` bytes (`5.26 MiB`) combined.
- Godot lossless imported `.ctex` disk cost with mipmaps is `5,375,784` bytes (`5.13 MiB`) combined on this machine.
- Conservative decoded RGBA8 plus full-mipmap footprint is approximately `8.0 MiB` per `1254²` asset, or `16.0 MiB` combined. Actual imported `.ctex` disk size and renderer residency are recorded after Godot import/capture; the estimate is not a measured profiler claim.
- This cost is fine for a two-texture experiment but not for 213 unique per-building maps. A production path should use a small shared material-family library, 512–1024 px limits chosen by on-receiver tests, and target-specific geometry/modules/masks for recognition.

## Acceptance boundary and cleanup path

The source outputs have a one-iteration budget only if an **obvious** seam, baked light gradient, hallucinated object, strong noise, or implausible scale cue remains at realistic facade scale. Minor edge mismatch that disappears under mipmapping and ordinary viewing distance is acceptable for this pilot.

If the candidates pass that screen, the next production experiment should:

1. keep these as non-live v1 baselines;
2. have the independent bar-raiser rank them against the current controls at ordinary and oblique views;
3. trial no more than one or two shared families on a bounded non-hero receiver;
4. resize/recompress only after a 512/1024 quality and memory comparison;
5. use geometry or complete facade modules for windows, doors, entrances, setbacks, towers, and other recognition cues.

This pilot does **not** claim either texture is seamless at pixel level, target-specific, historically exact, a coherent PBR set, a whole-building recognition solution, accepted art, or authorized for live attachment.

## Final technical and visual pilot verdict

Evidence:

- `res://evidence/first-playable/genai-texture-pilot-v1-2026-09-04/01-generated-3x3-repeat.png` — unblended borderless `3×3` repeat.
- `res://evidence/first-playable/genai-texture-pilot-v1-2026-09-04/02-real-scale-ab-front.png` — direct-light front A/B, two `6.0 × 3.2 m` panels per family.
- `res://evidence/first-playable/genai-texture-pilot-v1-2026-09-04/03-real-scale-ab-oblique.png` — oblique changed-light A/B.
- `res://evidence/first-playable/genai-texture-pilot-v1-2026-09-04/capture-manifest.json` — exact hashes, paths, dimensions, renderer, controls, and non-live status.

The capture is valid for this limited question: it ran with Godot `4.7.2`, macOS display driver, Metal/Forward+, Apple M2, at `1440 × 900`; it uses meter-authored test-panel UVs and a reversible `3.0 m` repeat. It is a controlled material lab, not an in-game receiver or whole-building acceptance image.

| Family | Raw `3×3` verdict | Meter-scale A/B verdict | Remaining limitation |
|---|---|---|---|
| Warm ivory mineral v2 | **PASS_WITH_LIMITATION.** The v1 cloud-cell repetition is gone. No obvious hard seam, light gradient, object, or directional mark survives in the unblended proof. | **Usable pilot.** Fine mineral detail survives direct and oblique light without overpowering the panel or exposing a distracting repeat. It is visibly richer than the current control. | It reads cleaner/brighter than the current Building 1 field and still contains generated microstructure rather than a surveyed substrate. The reversible tint and repeat require on-receiver tuning. |
| Muted brown-red brick | **PASS_WITH_LIMITATION.** Horizontal courses preserve phase. A mild source-cell cadence and small vertical edge-phase imperfection can be found when deliberately examining the raw grid, but there is no broken course or dominant seam. | **Usable pilot.** At a `3.0 m` repeat on the `6.0 m` panel, the join is not distracting and the material is a clear believability improvement over flat brown. | Brick color, unit size, bond, and mortar are plausible production choices, not Isle House survey facts. This cannot be wrapped over corners or facade zones without receiver-specific UV/region review. |

No second brick generation and no second stucco cleanup are justified by the pilot threshold. Pixel-perfect tiling was not the goal; the remaining imperfections are subordinate at realistic scale. The independent bar-raiser still owns the art-quality decision.

## Why facade textures have been unusually hard here

1. **Texture was sometimes asked to solve architecture.** Material grain/color can make a surface believable, but recognizability usually comes from massing, story hierarchy, opening rhythm, entrances, signs, and roof silhouettes. A global bitmap cannot safely encode those without inventing a repeated facade.
2. **The receiver UV conventions are not uniform.** Generic generated walls carry decimeter-style UVs and compensate in their material scale; current Building 1 hero geometry and exact-chain overlays use meter-style UVs; some module primitives use normalized per-primitive UVs. One texture resource therefore does not have one physically correct scale everywhere without a receiver adapter or per-convention material instance.
3. **A visually attractive square is not necessarily a valid repeat cell.** Image generation can make convincing single swatches while missing edge phase or creating repeated macro blobs. The v1-to-v2 stucco correction demonstrates why the `3×3` proof is mandatory.
4. **Godot changes how the image reads.** sRGB sampling, linear-space lighting, ACES tonemapping, mipmapping, light direction, and material tint can make a neutral source appear brighter, darker, warmer, or flatter than its isolated PNG. Scale and color have to be tuned in-engine.
5. **PBR maps must describe the same physical surface.** Independently hallucinated or borrowed normal/roughness maps can contradict the albedo. Scalar roughness is safer until a coherent same-source map derivation and review path exists.
6. **A unique map per building is too expensive and too repetitive as a workflow.** Two `1254²` textures already imply about `16 MiB` conservatively decoded with mipmaps. Multiplying that by 213 would be wasteful and would still leave the actual recognition cues undone.
7. **Reference rights and truth boundaries matter.** Restricted Street View or museum imagery can inform observations but cannot silently become generator inputs or shipped pixels. Text-only, material-family generation is a safer role than fake photographic reconstruction.

## Production recommendation

GenAI **is viable**, but as one bounded layer of the facade pipeline:

- build a small shared library of perhaps `6–12` homogeneous material families, not 213 one-off whole-elevation images;
- use text-only, reference-bounded prompts and store every prompt/hash/nonclaim;
- require one unblended `3×3`, a meter-scale direct/oblique A/B, mipmaps, and independent bar-raiser review per family;
- define a single facade UV convention or explicit receiver-adapter metadata before live rollout;
- keep roughness scalar initially; add coherent normals/roughness only from a verified same-surface derivation workflow;
- combine the shared albedo fields with target-specific geometry, complete window/door modules, signs, silhouettes, and bounded masks that carry actual recognition;
- pilot the accepted family on one low-risk non-hero receiver before Building 1 or Isle House.

The pilot therefore answers the viability question **yes for believable material richness, no as a substitute for building-specific recognition work**.

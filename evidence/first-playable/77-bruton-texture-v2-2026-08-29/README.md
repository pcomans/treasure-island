# 77 Bruton texture v2 — bounded generation evidence

Date: 2026-08-29

## Scope and stopping condition

- Project: private hobby Godot project.
- Target: Hawkins / 77 Bruton Street, main left six-story upper facade plane only.
- Asset kind: `architectural_pattern_tile`.
- Repeat blueprint: one complete canonical paired-window bay by one upper residential story per tile.
- Initial batch: exactly three independent built-in image-generation calls.
- Correction round: exactly one built-in image-generation edit call (`1`); the permitted generation budget is exhausted.
- Selection: none. Semantic, art, exact-receiver, whole-object, and overall verdicts remain for a fresh independent reviewer.
- Integration, overwrite, Godot launch, export, install, and commit: not performed.
- Existing game asset `game/resources/textures/world/generated/77_bruton_facade_albedo_v1.png`: not touched.

## Generation mode and input role

- Mode: Codex built-in image generation for the three initial candidates, followed by one built-in precise-object edit for the targeted correction; no CLI, API key, third-party image service, or external account.
- Intent: reference-guided new generation for candidates 01–03; candidate 04 is a non-destructive edit of candidate 01, with the owner photo retained as reference-only context.
- Local input: `/private/tmp/IMG_7170-reference.png`.
- Input role: owner-private appearance reference for the selected upper-plane material, palette, and proportional rhythm only. It is not a rectified elevation or measured material scan.
- Privacy: the owner reference was not copied into the project evidence directory or game assets.
- Built-in generation model name and random seed: not exposed by the tool.
- Default generated-image directory: `/Users/philipp/.codex/generated_images/01a04ec8-2354-79f2-9d73-84de154c4c0d/`.

## Predeclared repeat contract

```yaml
asset_kind: architectural_pattern_tile
region: hawkins_main_left_six_story_upper_plane
cell:
  horizontal: one_complete_canonical_paired_window_bay
  vertical: one_upper_residential_story
  complete_motifs: [W-P]
motif_W-P:
  description: one complete charcoal outer frame with complete head, sill, both jambs, exactly two tall dark blue-gray glass lites, and one complete center mullion
  may_cross_edge: false
edge_fragments:
  left: []
  right: []
  top: []
  bottom: []
legal_seam_zones:
  x: uninterrupted fine-fluted pearlescent pier field P-F
  y: uninterrupted pale spandrel or adjacent cladding field S-H/P-F
expected_edge_products:
  left_plus_right: uninterrupted homogeneous P-F field only
  top_plus_bottom: uninterrupted homogeneous S-H/P-F field only
  corners: uninterrupted homogeneous S-H/P-F field only
forbidden_at_edges: [window, glass, frame, mullion, jamb, sill, trim, vent, door, balcony, panel_termination, distinct_joint, focal_stain]
physical_span_m:
  x: null
  y: null
physical_scale_status: unknown
maps_requested: [albedo]
maps_not_generated: [normal_gl, roughness, metalness, ao, height]
```

The photo and research support a one-bay × one-story candidate cell but not a measured bay schedule or rib pitch. Physical metres, pixels per metre, receiver UV scale, and repeat counts therefore remain unknown and must not be inferred from the image dimensions.

## Candidate inventory and mechanical proof screen

The project proof builder was run unchanged as version `1.0.0` with ImageMagick `7.1.2-30 Q16-HDRI aarch64`. It strips metadata, normalizes to sRGB RGB without resizing, measures opposite one-pixel edges, and emits borderless/boundary-overlay 3×3, half-X/Y/XY rolls, and an 8×8 macro repeat. Thresholds are MAE `<= 0.03` and RMSE `<= 0.06` on each axis. These values are candidate screens only.

| Candidate | Evidence source | Built-in default source | Dimensions | Source SHA-256 | Proof-normalized SHA-256 | X MAE / RMSE | Y MAE / RMSE | Numeric screen | Proof directory |
|---|---|---|---:|---|---|---:|---:|---|---|
| 01 | `candidates/candidate-01-source.png` | `exec-8c4af146-1b77-4640-951e-3a2ada8f44da.png` | 1254×1254 RGB sRGB | `dd6b5f9633faabc3cd1e03052c97e6832290d67d1987b49e890831ee1d7c313c` | `08298be03036bf66934fce276488a89cd3b60b3a0beb2819c77c6b1844a4c8a4` | `0.0103825 / 0.0127579` | `0.0222243 / 0.0269661` | `pass_candidate_screen` | `proofs/candidate-01/` |
| 02 | `candidates/candidate-02-source.png` | `exec-72bb41b3-9643-4f18-b2f7-9793b8c4a1c0.png` | 1254×1254 RGB sRGB | `9f62ee807cbf92047585b186741281f81367d4851b3ae78a206b54ff3d19bd6d` | `04c4f0239afa3b59fae2a13898e8d74357f887f0ff791d92efe35848c5800903` | `0.0636301 / 0.0646907` | `0.0137484 / 0.0175768` | `fail` | `proofs/candidate-02/` |
| 03 | `candidates/candidate-03-source.png` | `exec-8968d26f-0fbb-4c5f-9342-2edfef5b8e3a.png` | 1254×1254 RGB sRGB | `8f307893b0ce6bb8ce4d08f9e875bac68f049c8a78cf17b80d69dbda6fe49956` | `92f92e55e3abbdfbb7550564c6267d197c1c5844f6b09b78d0e7b62d5d92c357` | `0.0310525 / 0.0322592` | `0.00686222 / 0.0102767` | `fail` | `proofs/candidate-03/` |
| 04 correction | `candidates/candidate-04-correction-source.png` | `exec-9baa43f9-14b9-489c-b000-25317f904a8f.png` | 1254×1254 RGB sRGB | `2935ae920722948a1dfb35c6ae837c600c53deb4a006370dfb131eba79a4d4cb` | `7bcf8045b6234f0c96aceabf7c78f980fbbfbaf828a6cc9a7c6c1dad228866b9` | `0.0120295 / 0.0144214` | `0.013739 / 0.0169552` | `pass_candidate_screen` | `proofs/candidate-04-correction/` |

Each proof directory contains `proof-report.json` and `PROOF_REPORT.md` plus the normalized input and all proof images. The machine reports deliberately retain:

- semantic repeat: `unreviewed`;
- art: `unreviewed`;
- exact Godot receiver: `unreviewed`;
- overall acceptance: `not_accepted`.

### Primary proof hashes

| Candidate | Borderless 3×3, 3762×3762 | Boundary overlay 3×3, 3762×3762 | 8×8 macro, 2048×2048 |
|---|---|---|---|
| 01 | `edfef9d667dc322d14fa667a3b3d2953a19693fc237b194e9b46abdeafd45d6e` | `8ce7f62b7138953bdbf734365b672cb1a737c6cc72e3f6daf63842529b8321bc` | `bfc8e8185bed901abc302b2c08d7bc02e18daf19becc1aaecf5a44176335caf0` |
| 02 | `e64e4302a4bdcdb8616cebbcad9b37492d8e3f6ea8902eac9bf7046dd5f9d24d` | `47978ea00047568f241ad2c74c66909b118b335162fe902e2a7f4787df21f93c` | `c66c19b48d58709c0e9bbb9624e34a9b07825af10c985a7e4d023331d23a3faf` |
| 03 | `7987e33c550a613aed0fea32f72f167f98c669d173501d54d9f3a02d230ebd0f` | `eb20df85aa03712cbd9e8c092a99998c8bf2b7607d849ca2d7973a855a8d3c9e` | `b1c690274f09765ee36652536503cb7d12c7d9c8545684cde20bf531e6a2b666` |
| 04 correction | `b44baf404ddc8672b23b393b7ccc49453afef7848eb6259942df08ace99f18fe` | `17283d408e0ffc6fdc2906c13da6848ecc2af0e29f1e9ad2d616043ffc345ea0` | `2f2f49c1af5e5d54428d1e32793f5d5cea15d3f04bb7f43c9bb7285fe4927a06` |

Full hashes for the half-roll proofs are in each `proof-report.json`.

## Exact prompts

### Candidate 01

```text
Use case: stylized-concept
Asset type: architectural_pattern_tile; neutral albedo/base-color game texture for a Godot exterior wall
Input images: Image 1 is the owner-provided Hawkins / 77 Bruton Street reference, used only for the material language, palette, and relative upper-facade proportions of the main left six-story upper plane. Do not reproduce the photographed scene, perspective, sky, ground, neighboring buildings, or whole elevation.
Primary request: Generate one complete legal periodic cell representing exactly one canonical paired-window bay by exactly one upper residential story. This is a single texture tile, not a facade photograph or presentation board.
Subject: Exactly one complete paired-window assembly, fully contained and centered in the tile: one complete charcoal outer frame with complete head, sill, left jamb, and right jamb; exactly two tall dark muted blue-gray glass lites divided by one slim complete central charcoal mullion. No other window or partial window. Surround it with silver-white pearlescent fine-fluted rainscreen and pale spandrel/cladding fields.
Composition/framing: perfectly front-on orthographic surface; square 1:1 canvas. Keep the complete window assembly about 42-46% of tile width and 62-68% of tile height. Leave broad uninterrupted fine-fluted pier fields between the window and both left/right edges, and broad uninterrupted pale spandrel/cladding fields between the window and both top/bottom edges. All four outer borders must fall wholly within visually homogeneous seam-safe material fields, far from the frame or any architectural termination. No window, frame, mullion, jamb, sill, trim, panel joint, vent, door, balcony, or other architectural motif may touch or cross any edge.
Style/medium: clean restrained game-ready architectural albedo; believable contemporary coated metal and glass color, but flat and neutral rather than a lit render.
Lighting/mood: shadowless neutral base-color presentation; no directional lighting, no sun, no cast shadow, no ambient-occlusion bands, no baked highlight, no dramatic reflection.
Color palette: silver-white to very light neutral gray pearlescent coating; charcoal frame; dark muted blue-gray glass; pale neutral spandrel.
Materials/textures: many fine closely spaced vertical flutes across the solid rainscreen, clearly material-scale and much finer than the bay; very low-amplitude even variation; satin-coated appearance implied only through color, not fixed highlights. The border fields must remain homogeneous and free of distinct panel terminations.
Periodicity constraints: repeating this exact canvas in either axis must reproduce one and only one identical paired-window assembly per tile; repetition must never create, resize, duplicate, crop, merge, or delete a window or any other architectural motif. Opposite border fields should have matching color and micro-relief phase without copied-looking strips or a visible seam.
Constraints: no perspective; no crop of the frame; no extra glazing; no partial neighboring bay; no narrow slit window; no asymmetry; no roofline; no podium; no facade corner; no recess; no door; no balcony; no rail; no signage; no address; no text; no logo; no watermark; no border, matte, or padding.
Avoid: full-building elevation, photographic scene, multiple stories, multiple windows, side views, cinematic lighting, reflected scenery, strong rib striping baked into albedo, grime focal point, unique stain, panel termination at an edge, visible tile seams, four-way crosses.
```

### Candidate 02

```text
Use case: stylized-concept
Asset type: architectural_pattern_tile; neutral albedo/base-color game texture for a Godot exterior wall
Input images: Image 1 is the owner-provided Hawkins / 77 Bruton Street reference, used only for material language, palette, and relative upper-facade proportions on the main left six-story upper plane. Do not reproduce the photographed scene, camera, sky, ground, neighboring buildings, roof, base, or whole elevation.
Primary request: Create one self-contained legal translation cell: exactly one canonical paired-window bay by exactly one upper residential story. The entire canvas is the repeat cell, not a facade photo.
Subject: Exactly one complete paired-window assembly centered in the canvas. It must have one complete dark charcoal exterior frame with a full head, full sill, both complete side jambs, and one slim complete central mullion, containing exactly two tall equal dark blue-gray glass lites. No second window, no partial neighbor, no slit opening. Surround it with cool silver-white pearlescent fine-fluted rainscreen and pale fluted spandrel/cladding.
Composition/framing: perfectly front-on orthographic, square 1:1 canvas. Window outer frame about 46-50% of canvas width and 60-64% of canvas height. Keep at least a broad 20% canvas-width uninterrupted fluted pier field at both left and right, and broad uninterrupted fluted/spandrel field above and below. Every point along the entire top border and entire bottom border must be the same continuous fine-fluted material field; every point along the entire left and right border must also be that homogeneous fine-fluted material field. No smooth central panel, no panel outline, no panel termination, no band ending, no joint, trim, shadow, or motif may reach any outer edge.
Style/medium: restrained clean game-ready base color, materially legible contemporary coated metal and glazing; neutral albedo-like presentation, not a lit architectural render.
Lighting/mood: flat shadowless reference light; no directional source, sun, cast shadow, ambient occlusion band, fixed highlight, or dramatic reflection.
Color palette: cool silver-white/light neutral gray coating; charcoal frame; dark desaturated blue-gray glass; pale neutral spandrel integrated into the same fluted field.
Materials/textures: very fine dense vertical flutes across all solid wall and spandrel fields, many flutes per half bay, subtle low-amplitude tone variation only. No coarse rib stripes and no distinct panel boundaries.
Periodicity constraints: when this full canvas repeats on X and Y, there is exactly one unchanged complete paired-window assembly per tile and a consistent equal bay/story rhythm. The joins remain entirely inside homogeneous fluted material. Repetition must not create, resize, duplicate, crop, merge, or delete any architectural motif. Opposite edges should match in color and fine-relief phase naturally, without copied edge bands or a visible grid.
Constraints: no motif touches or crosses any canvas edge; no perspective; no cropped frame; no extra glazing; no multiple stories; no multiple bays; no partial neighbor; no narrow slit window; no roofline; no base/podium; no corner; no recess; no vent; no door; no balcony; no railing; no text; no signage; no logo; no watermark; no decorative border or padding.
Avoid: full elevation, photographic scene, perspective view, panel termination at an edge, strong baked rib shading, cinematic light, scenery reflection, unique stain, synchronized focal detail, visible seams, four-way crosses.
```

### Candidate 03

```text
Use case: stylized-concept
Asset type: architectural_pattern_tile; neutral albedo/base-color texture for a Godot building exterior
Input images: Image 1 is the owner-provided Hawkins / 77 Bruton Street photo, used only as local appearance guidance for the clean pearlescent upper rainscreen, paired dark glazing, charcoal framing, and pale inter-story zone on the main left upper plane. Do not reproduce the photo, scene, perspective, whole building, background, or lighting.
Primary request: Generate exactly one complete canonical paired-window bay by exactly one upper residential story as a single honest repeat cell. The canvas itself is the tile.
Subject: Exactly one self-contained paired-glazing assembly in the center: one complete slim charcoal rectangular outer frame, with complete head, sill, left jamb, and right jamb, enclosing exactly two equal tall dark desaturated blue-gray lites separated by one complete thin charcoal central mullion. Include a restrained pale spandrel/cladding zone around it, integrated with silver-white fine-fluted rainscreen. No other opening or window fragment.
Composition/framing: true front elevation, orthographic and distortion-free, square 1:1. Keep the full frame approximately 40-44% of tile width and 58-62% of tile height. Provide broad uninterrupted pearlescent fluted wall on both sides and broad uninterrupted pale fluted/cladding fields above and below. The nearest part of any frame, trim, sill, mullion, joint, or band must stay well inside the canvas, at least roughly 15% of the canvas away from every outer edge. All four edges must consist only of the same visually homogeneous seam-safe wall material; no discrete joint or material transition may touch any edge.
Style/medium: restrained contemporary architectural game texture; crisp but modest detail; albedo-like base colors rather than a beauty render.
Lighting/mood: evenly exposed, flat, shadowless, neutral; no baked directional illumination, sun, cast shadow, ambient occlusion, highlight, glow, or dramatic reflection.
Color palette: slightly warm silver-white pearlescent metal, pale gray-white spandrel/cladding, charcoal frame, muted dark blue-gray glazing.
Materials/textures: subtle dense narrow vertical flute rhythm, many flutes per bay; very low-amplitude natural color variation; recently completed clean facade. Do not encode strong alternating dark-light rib shading in albedo.
Periodicity constraints: a borderless repeat in X and Y must yield a regular array of exactly one identical complete paired-window assembly per tile. No boundary may create, resize, duplicate, delete, merge, split, or crop a motif. Opposite edges should meet through a natural continuation of the homogeneous fine-fluted field, with compatible value and micro-relief phase, no edge-copy repair and no visible grid.
Constraints: no motif of any architectural kind touches or crosses any edge; no perspective; no partial window; no neighboring bay fragment; no narrow slit window; no second frame; no extra glazing; no multiple floor rows; no full facade; no panel terminations; no vents; no doors; no balconies; no corners; no roof; no podium; no rails; no scenery reflections; no text; no address; no logo; no watermark; no border or blank padding.
Avoid: photographic environment, cinematic rendering, multiple modules, facade-depth shadows, reflected sky, strong shine, unique stain, repeating focal blemish, panel outline at a boundary, visible seams, four-way cross.
```

## One permitted targeted correction round

- Mode: built-in image-generation `edit` / `precise-object-edit`; exactly one call.
- Image 1 edit target: `candidates/candidate-01-source.png`.
- Image 2 reference-only context: `/private/tmp/IMG_7170-reference.png`.
- Corrected source: `candidates/candidate-04-correction-source.png`.
- Built-in default source: `/Users/philipp/.codex/generated_images/01a04ec8-2354-79f2-9d73-84de154c4c0d/exec-9baa43f9-14b9-489c-b000-25317f904a8f.png`.
- Dimensions: 1254×1254 RGB sRGB.
- Source SHA-256: `2935ae920722948a1dfb35c6ae837c600c53deb4a006370dfb131eba79a4d4cb`.
- Proof-normalized SHA-256: `7bcf8045b6234f0c96aceabf7c78f980fbbfbaf828a6cc9a7c6c1dad228866b9`.
- Proof directory: `proofs/candidate-04-correction/`.
- Numeric X left/right: MAE `0.0120295`, RMSE `0.0144214` — `pass_candidate_screen`.
- Numeric Y top/bottom: MAE `0.013739`, RMSE `0.0169552` — `pass_candidate_screen`.
- Machine semantic/art/receiver verdicts: `unreviewed`; overall: `not_accepted`.

### Exact correction edit prompt

```text
Use case: precise-object-edit
Asset type: architectural_pattern_tile; neutral albedo/base-color texture for a Godot exterior wall
Input images: Image 1 is the edit target and must remain the base composition. Image 2 is the owner-provided Hawkins / 77 Bruton Street appearance reference only for the silver-white fine-fluted upper-facade material character; do not reproduce Image 2's scene, perspective, sky, ground, whole elevation, or lighting.
Primary request: Change only the surrounding cladding/spandrel field and fixed-light presentation of Image 1 to correct its tile borders. Preserve the complete centered paired-window bay. Replace every outer/background field that reaches an image edge with one single continuous, uniform, phase-matched field of fine vertical silver-white pearlescent fluted cladding. The same fine flute pitch, phase, base value, and neutral exposure must continue through all four border neighborhoods.
Preserve invariants: keep exactly one centered paired-window assembly; keep its overall position, scale, tall proportions, charcoal complete outer frame, complete head, complete sill, complete left and right jambs, exactly two dark muted blue-gray glass lites, and one complete central mullion. Keep the entire frame fully inside the canvas with generous material-only clearance on left, right, top, and bottom. Do not add, remove, crop, split, duplicate, widen, or narrow the window motif.
Border topology: all four tile borders must be visually the SAME uninterrupted fine vertical fluted cladding material. No panel termination, reveal, smooth-field boundary, spandrel edge, jamb extension, rail, trim, joint, ledge, horizontal line, shadow band, brightness gradient, darkening, highlight, stain, or any other discrete motif may touch or approach any outer edge. Reserve a broad clean material-only margin around the complete window. Opposite left/right edges must meet at the same flute phase and value; opposite top/bottom edges must meet without a horizontal line or exposure change. Corners must be ordinary homogeneous fluted material with no four-way focal feature.
Interior spandrel: a simple plain pale spandrel may remain immediately around or below the window only if it is fully enclosed well inside the fluted field, ends far before every outer border, has no outlined panel return or ledge, and does not become a second motif. Prefer the simplest window-plus-pale-spandrel cell.
Style/medium: front-on orthographic, clean restrained game-ready architectural albedo/base color; flat neutral surface-color presentation rather than a lit render.
Lighting/material correction: remove fixed directional lighting, frame/reveal cast shadows, ambient-occlusion bands, broad brightness gradients, dramatic glass reflections, and strong baked dark/light rib striping. Retain only subtle low-amplitude neutral color variation. The fine flutes should read as material-scale character, not a bay-scale lighting pattern.
Constraints: change only the diagnosed cladding-border topology and baked-light neutrality; preserve the paired-window identity and Hawkins-like silver/white fine-fluted palette. No perspective; no sky; no ground; no roofline; no facade corner; no extra window; no partial neighboring bay; no narrow slit window; no door; no vent; no balcony; no rail; no text; no logo; no watermark; no decorative border or padding.
Avoid: multiple modules, full-building elevation, photographic scene, panel seams at borders, smooth columns reaching borders, horizontal join lines, copied edge strips, visible seams, exposure bands, four-way crosses, cinematic shading, scenery reflections.
```

## Obvious limitations to hand to the independent reviewer

These are generation-side observations, not semantic or art verdicts and not a winner selection.

- All candidates are generated albedo-like images, not physically measured or de-lit source captures. Each contains some fixed frame/reveal shading and glass value falloff that may behave as baked depth/light in Godot.
- No normal, roughness, metalness, AO, or height maps were generated. The pearlescent/fluted response is therefore represented partly by fixed color variation until a later approved material pass establishes an honest map set.
- Candidate 01 contains vertical transitions between a smooth central cladding/spandrel field and fluted side fields; those panel-like termination lines reach the top and bottom borders. Its borderless 3×3 also shows low-contrast horizontal joins. The numeric pass cannot resolve either semantic or art concern.
- Candidate 02 keeps the outer borders in fluted field, but its left/right pixel screen fails (`MAE 0.0636301`, `RMSE 0.0646907`) and the repeat exposes vertical value/relief joins. The strong long side pieces and double horizontal rails below the glazing may also read as a heavier frame/spandrel module than the reference.
- Candidate 03 keeps its complete glazing and pale inset inside the tile, but its left/right MAE is just over the candidate threshold (`0.0310525`) and the 3×3 exposes a subtle vertical field discontinuity. Its window occupies a smaller share of the repeat than the local reference rhythm may support.
- Candidate 04 correction removes candidate 01's edge-reaching smooth column and panel-termination motifs and keeps the paired frame inside a continuous fluted field. Its one-pixel numeric screen passes both axes, but the half-XY, borderless 3×3, and 8×8 macro proofs still expose a low-contrast horizontal join/exposure band and a repeated broad brightness field. Frame/reveal shading and glass falloff also remain fixed in the image. These observations do not set semantic or art acceptance.
- Exact physical bay width, story height, rib pitch, texel density, receiver UV convention, segment phase continuity, changed-light behavior, ordinary-play scale, and whole-building resemblance remain unreviewed.
- The work stopped after three initial calls plus the single permitted correction edit. No edge-pixel copying, distortion, derived crop, additional repair, or second correction call was performed.

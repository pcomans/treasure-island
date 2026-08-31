# 77 Bruton façade-texture experiment

Date: 2026-08-29

## Scope and mode

- Mode: built-in GPT Image generation through Codex; four independent generation calls; no CLI/API key, external service, or external account.
- Input role: the owner's `IMG_7170.HEIC`, converted outside the project to `/private/tmp/IMG_7170-reference.png`, was a reference only for material, palette, and façade rhythm. The photo was not copied into this repository or the game package.
- Intended use: experimental diffuse/albedo for the exact low-poly Hawkins wall `building:w1249412093:wall`. The selected asset was subsequently integrated as an object-specific runtime material override; generated geometry, collision, source identity, spray behavior, and every other building material remain unchanged.
- Normalization: ImageMagick converted each derived candidate to stripped, 8-bit RGB, sRGB, 1024×1024 PNG. It performed no artistic edits.
- Validation gate: normalized opposite-edge 1-pixel MAE <= 0.03 and RMSE <= 0.06 on both axes, plus a visual review of a borderless 3×3 repeat.
- Correction calls used: 0. Candidate 01 passed both gates, so the one allowed targeted correction was unnecessary.

## Exact generation prompt

The following prompt was used unchanged for all four independent calls:

```text
Use case: stylized-concept
Asset type: seamless tileable game façade diffuse/albedo texture for a low-poly Godot building
Input images: Image 1 is a reference only for material, palette, and façade rhythm; do not reproduce its photographed scene or composition
Primary request: create a square, front-on orthographic modular one-floor-by-one-window-bay façade tile inspired by the central mid-rise material language in Image 1, suitable for repeating across a Hawkins-style apartment building
Subject: light silver-gray narrow vertical corrugated metal cladding; one tall muted blue-gray glass window assembly with slim dark-charcoal framing; a restrained pale horizontal spandrel band
Style/medium: clean stylized game-ready diffuse/albedo, compatible with simple low-poly building massing; materially legible but not photorealistic
Composition/framing: exactly front-facing orthographic surface scan; square canvas; no depth perspective; one periodic façade module; balanced repeat rhythm
Lighting/mood: neutral flat albedo under shadowless ambient reference lighting; no directional light
Color palette: light silver-gray, charcoal, muted blue-gray, restrained pale gray
Materials/textures: narrow vertical corrugation with subtle even value variation; clean glass color; crisp simple framing
Periodicity constraints: this must be a single seamless periodic tile in both axes. Every feature crossing the left edge continues at exactly the same height on the right edge. Every feature crossing the top edge continues at exactly the same x position on the bottom edge. All four corners meet continuously. Preserve regular window and corrugation rhythm across boundaries. No border or padding.
Constraints: no perspective; no sky; no ground; no roofline; no people; no signage; no address numbers; no readable text; no logos; no watermark; no border; no vignette; no unique landmark geometry; no grime focal point; no clipped motif; no directional lighting; no cast shadows; no baked highlights; no ambient-occlusion edge darkening
Avoid: photographic scene, façade elevation with outer edges, asymmetry, depth, dramatic contrast, reflections containing scenery, visible seams, four-way cross at tile corners
```

## Candidate inventory and results

All metric values below are normalized to `[0, 1]`.

| Candidate | Source PNG (built-in output) | Normalized PNG SHA-256 | X MAE | X RMSE | Y MAE | Y RMSE | Numeric gate | Visual 3×3 verdict |
|---|---|---|---:|---:|---:|---:|---|---|
| 01 | 1254×1254 RGB; `555d1bfcf7e5b372479bc8aafe14d3a679ddc9a8056c67d5a508b0afc6bec39c` | 1024×1024 RGB; `1cf8e3091469f92b28211c5b212fd1e1cc34fb1aaadc1b4a098e856481966e9f` | 0.00744868 | 0.0101385 | 0.0173445 | 0.0225062 | Pass | Pass and selected: clean continuous corrugation and window rhythm, no straight join or four-way cross; restrained repeated rhythm is appropriate for a modular façade. |
| 02 | 1254×1254 RGB; `1a7645032ef90bc9638e14693713662e2fe022c408b73431c5fe3b6ca9a3d11e` | 1024×1024 RGB; `0741c8e9a6b8dda0d3aa4d27c53362b6de86139378768b82c48e08d9f2fb9f54` | 0.0101397 | 0.0129185 | 0.0129506 | 0.0173687 | Pass | Reject: the repeat exposes straight horizontal panel lines through the cladding at tile joins. |
| 03 | 1254×1254 RGB; `a689cbf8321f24902ca99d6f22611f0170af995fdff46a24c8894070f7a9356b` | 1024×1024 RGB; `77e2e0c278f3cb6f1cac96e9a61ff0c31b66778be63764c7b0694d27c5620bda` | 0.00698146 | 0.0106679 | 0.0140114 | 0.0184476 | Pass | Credible alternate, but the narrow single-pane bay reads less like the paired-window rhythm in the reference than candidate 01. |
| 04 | 1254×1254 RGB; `8013667d2c3b73703fe8b5fbdbfd3e142c3398ade97a9b7b16b4f5b37a490034` | 1024×1024 RGB; `a1d45b10dcfcb2f231696d1b9dc2d5468943615d26a4dae1d529cb0bc5e9b299` | 0.0183032 | 0.0201709 | 0.0369983 | 0.0457006 | Fail (Y MAE) | Reject: visible horizontal joins reinforce the failed Y-edge score. |

## 3×3 proof hashes

- `proofs/candidate-01-3x3.png`: 3072×3072 RGB, SHA-256 `efdce84cece04755ca4f76e9891e20cd46dc1985ffcccf1b4d2bac68d813bbfc`
- `proofs/candidate-02-3x3.png`: 3072×3072 RGB, SHA-256 `716ae1940126e04802da2a42880b75b4db3d2038a27f41855acfbbf6c038d069`
- `proofs/candidate-03-3x3.png`: 3072×3072 RGB, SHA-256 `0baf8f599dcad0b551a9afbabcb19ea02cd17c5ac4530d656b729f40a44110c2`
- `proofs/candidate-04-3x3.png`: 3072×3072 RGB, SHA-256 `90d7468379918468d24608fa5cbb200855c0cec386012b16cd955f4dbb1da748`

## Selected deliverable

- Evidence source: `candidates/candidate-01.png`
- Project asset: `game/resources/textures/world/generated/77_bruton_facade_albedo_v1.png`
- Dimensions: 1024×1024, 8-bit RGB PNG, sRGB
- SHA-256: `1cf8e3091469f92b28211c5b212fd1e1cc34fb1aaadc1b4a098e856481966e9f`
- Visual verdict: credible experimental façade albedo. It is front-orthographic, clean, materially consistent with the photo, compatible with the simple current art direction, and visually continuous in the 3×3 proof. An independent art-director review also ranked candidate 01 first and candidate 03 second, and agreed that correction generation was not warranted before an in-engine test. The subsequent exact-wall Metal review accepted candidate 01 at a `7.6 m × 6.0 m` full-tile repeat (`3.8 m/bay × 3.0 m/story` for the visible 2×2 module); see [`in-engine/README.md`](in-engine/README.md).

# Street-ground textures

The decal textures are used by `game/resources/materials/world/street/street_decal.gdshader`
for the generated street-marking and street-wear records; the surface textures by
`world_chunk_builder.gd` for the raised street-ground tops
(`tools/lib/street-ground-generation.mjs`).

Generated 2026-11-02 with `tools/generate-texture` (Codex image generation, one
image per call, text prompts only; no photograph was given to the generator or
copied). The eight source images were then packed with ImageMagick: resized,
cropped, alpha taken from darkness on the white backgrounds, cracks and stains
darkened so their soft edges never read lighter than asphalt, the drain's open
slots filled near-black. The packing script and the untouched sources are kept
outside Git with the street-ground work notes.

| File | Use | Source prompt (short) |
|---|---|---|
| `street_paint_wear.png` | grey mask of worn road paint, tiled in world space (white = paint) | seamless worn white thermoplastic road paint |
| `street_tactile.png` | yellow truncated-dome curb-ramp pad, tiled | seamless safety-yellow detectable-warning panel |
| `street_stop_legend.png` | STOP pavement legend mask | the word STOP as a US pavement legend, white on black |
| `street_wear_atlas.png` | 4 x 2 cells: two crack decals, two oil stains, patch, manhole, storm drain, spare | separate decals of cracks, oil stains, an asphalt patch, a manhole cover and a gutter grate, each on white |

Surface textures, generated the same way on 2026-11-02 (three more images) and
packed with ImageMagick:

| File | Use | Source prompt (short) |
|---|---|---|
| `street_concrete_panels.png` | sidewalk concrete: 2 x 2 poured panels (one UV unit = one 1.5 m panel) with saw-cut joints drawn on the panel edges; broom lines turned to run across the walk, each panel toned slightly differently | seamless light grey broom-finished concrete, no joints |
| `street_mulch.png` | planting strips, darkened and desaturated | seamless dark reddish-brown shredded bark mulch |
| `street_plaza_pavers.png` | Waterfront Plaza banded paving; band contrast pulled down to the photographed plaza | seamless charcoal and mid-grey stack-bond pavers in alternating bands |

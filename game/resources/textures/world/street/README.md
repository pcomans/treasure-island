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

Park ground textures for Cityside Park's paths (park_* records), generated
2026-11-03 with `tools/generate-texture` (one image per call, text prompt only;
no photograph was given to the generator or copied) and resized to 512 px with
ImageMagick; both tile seamlessly over 2 m (world UV):

| File | Use | Source prompt (short) |
|---|---|---|
| `park_dg.png` | decomposed-granite paths through the beds | seamless tan decomposed granite path surface |
| `park_asphalt.png` | the park's new dark asphalt paths, cycle track and lawn ring | seamless new dark charcoal asphalt with fine grey aggregate, no markings |

## Street furniture

`street_furniture_atlas.png` (1024 x 512, eight 256 px cells) is the one texture of
the street-furniture kit (`game/scripts/world/street_furniture_kit.gd`): poles, sign
faces, signal heads and cabinets multiply its cells by a vertex colour. Generated
2026-11-02 with `tools/generate-texture` (eight images, one per call, text prompts
only; no photograph was given to the generator or copied), each resized into its
cell with ImageMagick. The packing script and the untouched sources are kept outside
Git with the street-objects work notes. Street names are not in the atlas: the kit
writes them with `Label3D` from the OSM names.

| Cell (column, row) | Use | Source prompt (short) |
|---|---|---|
| (0, 0) | galvanised steel for poles and posts; darkened by vertex colour for the charcoal plaza poles | seamless galvanised steel lamp-pole surface, zinc spangle |
| (1, 0) | signal controller cabinet door | front of a dark green steel controller cabinet door with louvre vents and a lock |
| (2, 0) | stop sign face | United States STOP sign face, red octagon, white border and legend |
| (3, 0) | pedestrian signal face (drawn unshaded, as lit) | pedestrian countdown head face, lit orange hand, dark countdown |
| (0, 1) | NO STOPPING ANY TIME sign | white parking regulation sign, NO STOPPING / ANY / TIME in red |
| (1, 1) | bus stop flag (both faces) | generic bus stop flag, red band, bus pictogram, BUS STOP |
| (2, 1) top | ALL WAY plaque under all-way stop signs | ALL WAY plaque, red letters on white |
| (2, 1) bottom | blank name blade (border kept at the ends, the middle stretches) | blank green street name blade with a thin white border |
| (3, 1) top half | the ferry plaza information board's island map | not generated: drawn 2026-11-02 with ImageMagick from the frozen OSM data (the island outline turned to fill the panel, its streets, the ferry landing marked, a legend band of colour blocks); the drawing script is kept outside Git with the street-clutter work notes |
| (3, 1) bottom half | plain white, for vertex-coloured parts | (filled by the packing script) |

## Street fences

Four tiled textures of the street-fence kit (`game/scripts/world/street_fence_kit.gd`).
Generated 2026-11-02 with `tools/generate-texture` (four images, one per call, text
prompts only; no photograph was given to the generator or copied), then packed with
ImageMagick. The untouched sources and the packing steps are kept outside Git with
the street-fences work notes.

| File | Use | Source prompt (short) |
|---|---|---|
| `street_fence_chainlink.png` | chain-link fabric, blended from its mipmaps by `game/resources/materials/world/street/street_fence_mesh.gdshader` (its shade cut out by `street_fence_mesh_shadow.gdshader`); a crop of two diamonds each way at the source's measured repeat (460 x 556 px), scaled to 256 x 309, alpha from the wire's brightness, the openings filled with the wire grey | seamless galvanised chain-link fabric, flat-on, on solid black |
| `street_fence_barbed.png` | the three strands of barbed wire on the arms of industrial chain-link, drawn like the chain-link; a crop of three barb repeats, alpha from brightness | three strands of galvanised barbed wire, flat-on, on solid black |
| `street_fence_screen.png` | construction windscreen fabric, tinted black or dark green by the kit | seamless grey woven polypropylene windscreen |
| `street_fence_wood.png` | the wood board fence: six boards (0.84 m) per tile | seamless weathered cedar privacy fence boards |

Yard ground for the large-clutter yards' pale aggregate pads (the yard_gravel_pale
zone surface, `world_chunk_builder.gd`), generated 2026-11-04 with
`tools/generate-texture` (one image, text prompt only; no photograph was given to the
generator or copied) and resized from 1254 to 512 px with ImageMagick; it tiles
seamlessly over 2 m (world UV):

| File | Use | Source prompt (short) |
|---|---|---|
| `yard_gravel_pale.png` | the pale grey compacted crushed-aggregate pads of the construction yards (Gate 5's pad, May 2026 aerial: the palest ground there) | seamless pale grey compacted crushed-aggregate yard surface, low contrast, no marks |

## Yard kit

`street_pole_flag.png` (512 x 512) is the face of the yard kit's pole flag
(`game/scripts/world/street_yard_kit.gd`, drawn with its own double-sided material,
so the back shows the text mirrored). Not generated: drawn 2026-11-04 with
ImageMagick as three horizontal bands, red, white and blue, after the two flags
above the 9th St storage yard (Google Street View, Sep 2025). The upper half
carries SELF STORAGE in blue DejaVu Sans Bold capitals on the white band, as
legible in that photo; the lower half is plain. Each flag is drawn at its 5:3
shape (480 x 288) and the pair is packed into the square. The drawing script is
kept outside Git with the clutter-kit work notes.

More yard ground, generated 2026-11-04 the same way (three images, one per call,
text prompts only; no photograph was given to the generator or copied) and resized
from 1254 to 512 px with ImageMagick; each tiles seamlessly (the sand and soil over
2 m, the pond over 5 m of world UV):

| File | Use | Source prompt (short) |
|---|---|---|
| `yard_sand_pale.png` | yard_sand_pale: the pale cream graded sand of the earthworks pads (#11's pad, #13's sand square; May 2026 aerial) | seamless pale cream graded construction sand fill, low contrast |
| `yard_soil_dark.png` | yard_soil_dark: dark excavated soil in the pits of the 9th St / Avenue H site (May 2026 aerial) | seamless dark damp excavated construction soil, bucket scrape marks |
| `yard_pond.png` | yard_pond: the shallow murky ponds on #11's pad (May 2026 aerial) | seamless murky green-grey shallow pond water from above, matte |

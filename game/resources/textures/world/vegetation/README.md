# Street-vegetation textures

The textures of the street-vegetation kit (`game/scripts/world/street_vegetation_kit.gd`):
the Mexican fan palm, the Canary Island date palm, the Monterey cypress, the
clumping grass, and Cityside Park's young gums and oaks, grasses, perennials and
shrubs of `PlayableWorld/StreetDetail/Vegetation`, drawn by
`game/resources/materials/world/vegetation/vegetation_{bark,foliage,impostor}.gdshader`,
and the park beds' mulch and gravel.

Every source image was generated with `tools/generate-texture` (Codex image
generation, one image per call, text prompts only; no photograph was given to the
generator or copied): the palm leaf, palm boot, palm and cypress bark and cypress
foliage images on 2026-11-02 for the tree shootout (its variant A), the palms' other
images and the clumping grass on 2026-11-03 for the street-vegetation pilot, and the
Cityside Park plants' and the park ground's on 2026-11-03 (cityside-plants-20261103).
`tools/vegetation/prepare_textures.gd` packs them (`--only` packs a set at a time):
it keys the flat magenta (or, behind pink, lilac and blue flowers, cyan) backgrounds
of the leaf and grass images into alpha, removes the key's spill, refills transparent
pixels with nearby leaf colour so mipmaps don't halo, grades and packs the atlases,
and resizes the tiled barks and grounds. The untouched sources are kept outside Git
with the street-vegetation and cityside-plants work notes.

Every PNG here and its `.import` are checked-in build products: the atlases and
barks of `prepare_textures.gd`, the impostors of `tools/vegetation/bake_impostors.gd`.
Both tools write each `.import` (`tools/vegetation/texture_import.gd`: lossless, with
mipmaps, which the shaders' alpha-scissor cards rely on). Re-run `bake_impostors.gd`
after any kit geometry change.

| File | Use | Source prompt (short) |
|---|---|---|
| `fan_palm_foliage_atlas.png` | 1024 x 1024: live fan (0,0)-(512,512), two dead fronds (512,0)-(1024,512), the leaf-base boot (0,512)-(512,1024), an older fan (512,512)-(1024,1024); the leaf graded greyer and cooler than generated | one bright-to-mid green costapalmate Washingtonia robusta fan leaf, face-on, on magenta; one dried dead fan leaf hanging from its petiole, on magenta; seamless crisscross lattice of split woody leaf-base stubs |
| `fan_palm_bark.png` | the fan palm's trunk, 512 px per 0.6 m | seamless weathered light grey Washingtonia robusta trunk with fine horizontal ring scars every 3-5 cm and shallow vertical fissures |
| `canary_frond_atlas.png` | 512 x 2048: two whole Canary Island date palm fronds, each stretched to fill its 256 x 2048 cell, petiole at the bottom edge, rachis on the cell's centre line | one Phoenix canariensis frond seen flat from above, rachis bottom to top, narrow stiff leaflets in a pinnate feather, spines at the base, on magenta (two candidates, both used) |
| `canary_trunk_bark.png` | the date palm's trunk, 512 px per 0.8 m, graded greyer than generated | seamless trunk of an old Canary Island date palm: a diagonal lattice of diamond-shaped old leaf-base scars, tan, grey-brown and weathered grey |
| `canary_knob.png` | the trimmed "pineapple" knob under the date palm's crown, 512 px per 0.55 m, graded browner than generated | seamless dense cluster of trimmed old frond bases, broad flattened stubs pointing up in a diamond pattern, orange-tan cut ends |
| `cypress_foliage_atlas.png` | 1024 x 512: a side clump (0,0)-(512,512) and a wind-flattened top layer (512,0)-(1024,512) of Monterey cypress foliage | dense irregular cloud-shaped clump of rope-like sprays of scale leaves, deep green with yellow-green tips, on magenta; a broad flattened horizontal layer of the same foliage seen from above |
| `cypress_bark.png` | the cypress's trunk and limbs, 512 px per 1 m; graded greyer than generated | seamless grey-brown stringy fibrous Monterey cypress bark with interlacing vertical ridges |
| `grass_atlas.png` | 1024 x 512: a green clump (0,0)-(512,512) and a wider straw-coloured clump bottom-aligned in (512,171)-(1024,512); the pink the key leaves in pale tips is cleared | a clump of ornamental grass seen from the side, long narrow arching blades, mid green with straw-tan tips, on magenta; a fountain-shaped tuft of fine straw yellow-green and buff blades, on magenta |
| `meadow_atlas.png` | 2048 x 2048 in 512 x 512 cells (`LOW_CELLS` in the kit), each image cropped to its plant and stretched to fill its cell inside an 8 px margin; the kit's card sizes set the proportions. Row 0: Pacific reedgrass, dense sedge, rush, bronze sedge; row 1: blue-eyed grass, sea thrift stalks, white umbel stalks, seaside daisy stalks; row 2: woolly sunflower, monkeyflower, tansy and buckwheat flower stalks; row 3: sagebrush wands, sage stems, litter, buckwheat mound. Sedge, rush, bronze sedge, sagebrush, dried flower heads and litter graded toward the November photos | each from the side unless noted, late November: a coarse dark green reedgrass fountain under a few weathered grey-tan plumes; a fine green sedge tussock; stiff rush stems with brown tufts; a fine copper bronze sedge tuft; bluish iris-like blue-eyed grass fans with one flower (on cyan); thrift stalks with papery heads (on cyan); yarrow-like stems with small flat heads, half browned; daisy stems, three lilac daisies and brown seed heads (on cyan); woolly sunflower stalks, clusters mostly spent; monkeyflower stems with three yellow flowers; tansy stems with brown buttons; buckwheat stems with rust heads; a young sagebrush's feathery wands; an airy sage with dried whorls (on cyan); a round patch of litter from above; a low spreading buckwheat mound with rust heads |
| `perennial_atlas.png` | 2048 x 1024 like the meadow atlas, face-on foliage clusters drawn round a mound. Row 0: seaside daisy, sea thrift cushion (from above), woolly sunflower, sagebrush; row 1: yarrow, buckwheat, seep monkeyflower, dune tansy. Daisy, sagebrush, monkeyflower and tansy graded greyer | late November, no flowers except the buckwheat's few heads: grey-green daisy rosettes with dry leaves; a fine needle-leaf thrift cushion; open silvery woolly sunflower foliage; thread-fine sagebrush sprays; feathery yarrow leaves; needle-leaf buckwheat stems with rust heads; soft monkeyflower leaves, some yellowing; ferny tansy leaves |
| `young_tree_foliage_atlas.png` | 1024 x 512: a hanging spray of young Sydney blue gum leaves (0,0)-(512,512), graded grey-green; a cluster of small island oak leaves (512,0)-(1024,512) | one hanging spray of lance-shaped gum leaves from a reddish twig, a few young leaves bronze; a dense cluster of about eighty small dull dark green toothed oak leaves |
| `gum_bark.png` | the young gum's trunk and branches, 512 px per 0.7 m; tinted tan, its tree stakes | seamless smooth pale bark of a young Sydney blue gum, white-grey and cream with pale blue-grey and grey-green patches and a few peeling strips |
| `oak_bark.png` | the young oak's stems and limbs, 512 px per 0.5 m | seamless smooth grey-brown young oak bark with faint fissures and lichen spots |
| `park_mulch.png`, `park_gravel.png` | the park beds' ground, 512 px per 2 m like `street_mulch.png`: grey-brown shredded wood mulch and grey pea gravel (Cityside Park's beds) | seamless shredded wood-chip mulch in dark grey-brown; seamless rounded grey pea gravel |
| `impostors/*.png` | each tree variant's far impostor: its LOD0 crown (palms) or whole tree (cypress, gum, oak), baked by `tools/vegetation/bake_impostors.gd` under flat white light | (rendered from the kit, not generated) |

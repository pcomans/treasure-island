# Street-vegetation textures

The textures of the street-vegetation kit (`game/scripts/world/street_vegetation_kit.gd`):
the Mexican fan palm, the Canary Island date palm, the Monterey cypress and the
clumping grass of `PlayableWorld/StreetDetail/Vegetation`, drawn by
`game/resources/materials/world/vegetation/vegetation_{bark,foliage,impostor}.gdshader`.

Every source image was generated with `tools/generate-texture` (Codex image
generation, one image per call, text prompts only; no photograph was given to the
generator or copied): the palm leaf, palm boot, palm and cypress bark and cypress
foliage images on 2026-11-02 for the tree shootout (its variant A), the rest on
2026-11-03 for the street-vegetation pilot. `tools/vegetation/prepare_textures.gd`
packs them: it keys the flat magenta backgrounds of the leaf and grass images into
alpha, removes the magenta spill, refills transparent pixels with nearby leaf colour
so mipmaps don't halo, grades and packs the atlases, and resizes the tiled barks.
The untouched sources are kept outside Git with the street-vegetation work notes.

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
| `impostors/*.png` | each tree variant's far impostor: its LOD0 crown (palms) or whole tree (cypress), baked by `tools/vegetation/bake_impostors.gd` under flat white light | (rendered from the kit, not generated) |

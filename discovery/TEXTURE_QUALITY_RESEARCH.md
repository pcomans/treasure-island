# Texture quality research for a research-to-texture skill

Checked: 2026-08-29  
Scope: practical hobby-project building textures for Godot 4; no asset generation or runtime changes in this research round.

## Bottom line

A good building texture is not merely an attractive square image or a bitmap whose opposite edges have similar pixels. For any patterned building surface, the first quality question is whether the image is a **true structural repeat cell**. Every architectural motif created at a tile boundary must preserve the same kind, width, height, phase, and cadence as the motifs inside the tile.

The primary Hawkins texture defect was structural repetition: partial window fragments at the left and right edges joined into new, fake narrow slit windows. The pixels could have low edge error while the architecture changed at every join. The hard gate must therefore be: **a borderless 3×3 repeat preserves the declared motif grammar across every boundary and creates no new edge-composed motif.** The same rule applies to doors, panels, brick/block courses, vents, balconies, trim, and cladding seams—not just windows.

There is also a separate receiver/massing mismatch, but it must not obscure this earlier texture failure. A motif-bearing image can be valid when the deliverable is explicitly a structured façade tile/atlas with known real-world module dimensions, a declared repeat grammar, and matching receiver UVs. A generic surface material cannot silently become one.

The representation distinction remains important after structural repeat has passed:

| Observed feature | Correct representation for this project |
|---|---|
| Paint color, small stains, fine aggregate, tiny scratches | Albedo/base-color texture if the variation matters |
| Gloss/matte variation, worn coating, wet/dry response | Roughness map if spatial variation matters; otherwise a scalar |
| Shallow grooves and fine corrugation that do not affect silhouette | OpenGL normal map if visible at intended distance; otherwise omit |
| Deep corrugation, reveals, ledges, window recesses, silhouettes | Geometry or an explicitly approved depth technique, not albedo |
| Windows, doors, mullions, spandrels, story rhythm | Explicit façade modules/geometry, or a target-specific atlas with exact dimensions |
| Story count, podium, setbacks, roofline, major volumes | Building massing/geometry |
| Sunlight, cast shadows, reflections of the photographed scene | Remove from base color; let Godot light the asset |

## Verified facts from primary documentation

### Periodic-pattern preview and construction

- Photoshop's Pattern Preview automatically repeats the current canvas outside its bounds. Adobe presents it as a way to design repeating patterns while seeing the repeated result, instead of evaluating one isolated tile. [Adobe Photoshop: Create a new pattern](https://helpx.adobe.com/photoshop/desktop/apply-painting-techniques/create-fill-with-patterns/create-a-new-pattern.html)
- Adobe's Pattern Maker guidance exposes both a tiled pattern preview and visible tile boundaries, and can offset the preview tiles. Those are useful independent views: the borderless preview reveals emergent motifs, while the boundary overlay shows which source edges created them. [Adobe Photoshop: Pattern Maker](https://helpx.adobe.com/photoshop/using/generate-pattern-using-pattern-maker.html)
- Substance 3D Designer describes man-made patterns as rule-governed placement. Its Tile Generator guidance says to create the custom input motif first, then set X/Y repetition counts and size mode. This supports a motif-first workflow rather than asking an image generator to improvise a complete periodic field at once. [Adobe Substance 3D Designer: Patterns](https://experienceleague.adobe.com/en/docs/substance-3d-designer/using/substance-graphs/nodes-reference-for-substance-graphs/node-library/texture-generators/patterns/patterns), [Adobe Substance 3D Designer: Tile Generator](https://experienceleague.adobe.com/en/docs/substance-3d-designer/using/substance-graphs/nodes-reference-for-substance-graphs/node-library/texture-generators/patterns/tile-generator)
- ImageMagick's `-roll` operation circularly shifts an image horizontally and/or vertically. Rolling by half the tile width/height moves the original outer joins to the center of a proof image, making wrap-around structure easier to inspect. The second sentence is a project use of the documented operator. [ImageMagick: command-line options, `-roll`](https://imagemagick.org/command-line-options/#roll)
- Poly Haven's technical standard separately requires seamless axes and the absence of noticeable tiling or clone-stamp artifacts. Pixel continuity at the outer border is therefore only part of repeat quality. It also permits justified non-square materials, so a true architectural repeat cell need not be forced into a square. [Poly Haven: Texture requirements](https://docs.polyhaven.com/en/technical-standards/textures)

### Godot material behavior

- Godot's `StandardMaterial3D` is a PBR material. Its albedo is the base color; roughness changes how blurred or sharp reflections are; and a normal map changes the incident lighting angle for fine shape detail without changing geometry. Godot expects OpenGL-style X+, Y+, Z+ normal maps. [Godot: Standard Material 3D and ORM Material 3D](https://docs.godotengine.org/en/stable/tutorials/3d/standard_material_3d.html)
- `StandardMaterial3D` uses separate ambient-occlusion, roughness, and metallic maps; `ORMMaterial3D` packs those three channels. `BaseMaterial3D` also exposes scalar values, UV scale/offset, repeat, and texture filtering. Therefore a material can use one albedo image while keeping roughness and metalness as scalar values; it does not need a bitmap for every PBR channel. [Godot: StandardMaterial3D](https://docs.godotengine.org/en/stable/classes/class_standardmaterial3d.html), [Godot: BaseMaterial3D](https://docs.godotengine.org/en/stable/classes/class_basematerial3d.html)
- In Godot 4, repeat and filtering for built-in 3D materials are per-material settings. The linear-with-mipmaps-anisotropic option smooths the texture near and far and improves quality at oblique viewing angles, with a modest performance cost. [Godot: BaseMaterial3D texture-filter enum](https://docs.godotengine.org/en/stable/classes/class_basematerial3d.html#enum-basematerial3d-texturefilter)
- Godot recommends mipmaps for 3D. They reduce distant graininess and sampling bandwidth, at about 33% additional texture memory. Detect 3D normally enables mipmaps and a 3D-oriented compression mode. Godot can also use the normal map to filter roughness and reduce specular aliasing. [Godot: Importing images](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_images.html)
- Godot renders 3D lighting in linear space. Color/albedo textures in custom shaders require the `source_color` hint for correct sRGB-to-linear sampling; normal, roughness, metallic, and height textures are data and normally do not use that hint. Built-in material slots carry the corresponding semantics, but import configuration still needs verification. [Godot: Shading language, uniform hints](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/shading_language.html#uniform-hints)
- Godot can scale and offset UVs for repeating textures. World-triplanar projection can make a material continue across primitives, but this is still only a texture-coordinate solution; it does not add architectural structure. [Godot: UV1 and UV2](https://docs.godotengine.org/en/stable/tutorials/3d/standard_material_3d.html#uv1-and-uv2)

### Neutral base color and PBR channels

- Adobe defines base color/albedo as the surface color **without lighting information**. Its delighting guidance explains why a photo's baked shadows or highlights conflict with lights coming from other directions in a 3D scene. [Adobe Substance 3D Designer glossary](https://experienceleague.adobe.com/en/docs/substance-3d-designer/using/glossary), [Adobe Substance 3D Sampler: Delight](https://experienceleague.adobe.com/en/docs/substance-3d-sampler/using/filters/tools/delight-ai-powered)
- Adobe describes roughness as the channel that changes shiny/matte response and recommends rotating or changing the light/environment while inspecting a material. This is a check of light response, not simply whether the roughness bitmap looks interesting in isolation. [Adobe Substance 3D Viewer: Modify materials](https://helpx.adobe.com/substance-3d-viewer/desktop/tutorials/modify-materials.html), [Adobe Substance 3D Viewer: Environment workspace](https://helpx.adobe.com/substance-3d-viewer/desktop/interface/environment-workspace.html)
- Adobe's renderer mapping explicitly treats base color as sRGB and roughness, metallic, normal, and ambient occlusion as non-sRGB data. [Adobe Substance 3D renderer guide: Toolbag](https://experienceleague.adobe.com/en/docs/substance-3d/ecosystem/renderers/toolbag)
- Poly Haven's technical texture standards require accurate real-world dimensions, seamlessness without cloning/tiling artifacts, little or no lighting/shadow/specular reflection in diffuse/albedo, and a coherent PBR map set for its own library. Poly Haven also validates roughness and normal behavior with reference photos and comparison renders under revealing light. These are production-library standards, not a requirement that this hobby project use 8K/16-bit maps. [Poly Haven: Texture requirements](https://docs.polyhaven.com/en/technical-standards/textures)
- Adobe defines texel density as texture pixels per surface area and warns that visibly inconsistent density across a mesh can make an asset look lower quality. Poly Haven records the measured real-world size of its materials so mapping can reproduce the intended scale. [Adobe Substance 3D Painter: UV texel density](https://experienceleague.adobe.com/en/docs/substance-3d-painter/using/effects/generators/uv-texel-density), [Poly Haven: Blender add-on, automatic scale](https://docs.polyhaven.com/en/guides/blender-addon#automatic-scale)

### What image metrics prove

- ImageMagick defines MAE as mean absolute error and RMSE as root mean squared error. It reports normalized comparison values that are less dependent on its compile-time quantum depth; a perfect match has zero error for MAE/RMSE. [ImageMagick: Image comparing](https://usage.imagemagick.org/compare/), [ImageMagick: `compare`](https://imagemagick.org/compare/)
- ImageMagick performs a pixel comparison. Its documentation does not claim that a low edge error proves a texture is perceptually seamless, semantically correct, physically plausible, or free of repetition. Using its metrics as a tileability score is therefore a project method, not an ImageMagick guarantee.

## Recommendations and project inferences

The rules below are recommendations derived from the verified behavior above and from the failed Hawkins experiment. Numeric thresholds are project screens, not industry laws.

### 1. Define the true repeat cell and motif grammar before generation

For any patterned building output, write a compact repeat contract before producing pixels:

- canonical motif types and intended dimensions (for example `standard_window`, `door`, `panel`, `brick`, `vent`, `balcony`, `trim_band`, or `cladding_seam`);
- number and order of motifs in one repeat cell;
- horizontal and vertical pitch/cadence;
- separators such as mullions, mortar, cladding strips, or spandrels;
- exact real-world cell width/height; rectangular is allowed;
- which features, if any, may cross each edge and the exact phase at which they cross;
- expected motif count and order in a 3×3 repeat.

Choose the **smallest rectangle whose repetition reproduces the intended building pattern without changing any motif**. If the reference truly alternates two panel or bay types, the repeat cell must contain that complete sequence. If every window, vent, block, or panel is intended to be one width, the cell must not contain fragments that synthesize an unplanned second width.

For generated structured façade tiles, prefer boundaries in repeat-safe separator zones: complete motifs inside the tile, no uncontrolled partial window/door/vent/balcony/panel at an edge, and continuous cladding, mortar, mullion, or trim at the boundary. Splitting a motif across an edge is allowed only when both complementary fragments are explicitly controlled and the joined proof reconstructs exactly the canonical motif. An instruction such as “seamless” is not evidence that this happened.

Hard structural-repeat gate:

- Create an unblended borderless 3×3 repeat.
- Create a second 3×3 proof with tile boundaries overlaid.
- Create half-width, half-height, and combined half-width/half-height circular-roll proofs so every original outer join appears in the middle of a view.
- Inspect or annotate every architectural motif that touches a former tile boundary.
- **Fail if a boundary creates a motif not declared by the canonical grammar, or if intended width, height, spacing, frame/mortar/trim thickness, order, alignment, or cadence changes.**
- Hawkins worked failure: a row intended to contain equal windows must remain equal across all joins; any extra slit window, doubled/missing mullion, or shifted spandrel is an unconditional fail.

Where simple color segmentation makes motifs measurable, record bounding boxes/course spacing and require boundary-created motifs to match the canonical interior motifs within the same small raster tolerance (recommended starting screen: `max(2 px, 1%)` per measured dimension). This tolerance covers raster/segmentation ambiguity only; it does not authorize an intentional motif-size change. It is a project recommendation, not a primary-source standard. Ambiguous segmentation requires visual annotation and hard review, not automatic acceptance.

### 2. Classify the deliverable before researching or generating

Choose exactly one:

1. **Surface-material tile** — a statistically repeatable patch of one physical building surface such as plaster, brick face, painted sheet metal, concrete, or roof membrane. Any micro-pattern still needs a repeat grammar, but it contains no façade-scale layout.
2. **Structured façade tile/atlas** — an architectural unit containing motifs such as windows, doors, panels, vents, balconies, courses, or trim. It declares the full repeat grammar, real-world module dimensions, target geometry, UV bounds, allowed repetition directions, and edge behavior.
3. **Non-texture geometry problem** — story count, silhouette, roofline, podium, setbacks, deep recesses, and major volumes. Route this out of the building-texture skill.

If the requested reference depends on class 2, use the structured façade path and its semantic-repeat gate; if it depends on class 3, stop the texture path. Do not “solve” either by squeezing the reference elevation into a square generic tile.

For Hawkins, a surface-material request may produce only the painted silver-gray corrugated cladding. A structured façade request may include windows/spandrels only after its true repeat cell and exact receiver contract are declared. Story count, ground-floor volume, roofline, and major depth remain geometry.

### 3. Research a building-texture specification, not a collage

Web research should yield a short written specification with traceable sources:

- surface identity and coating (for example, painted profiled metal rather than raw aluminum);
- neutral color/value range and variation scale;
- whether the surface is broadly matte, satin, or glossy, and how roughness varies;
- real-world width and height represented by one tile;
- shallow relief direction, spacing, and depth class;
- features that are explicitly excluded because they are architecture rather than material;
- for structured façade output, canonical motif dimensions/order and repeat-safe boundaries;
- the target close distance and ordinary gameplay distance.

Reference pages and photos inform this brief. They are not automatically authorized as downloadable or redistributable texture inputs. Preserve project resource, licensing, privacy, and approval rules.

### 4. Use the smallest honest map set

An **albedo image plus scalar material values** is enough when the receiver is distant, mostly matte, and has no meaningful spatial roughness or micro-relief at the intended views. This is the KISS default, not a quality failure.

Add maps only when they encode independent, visible surface behavior:

- Add **roughness** when variation in highlight width/intensity materially helps the surface read under moving light. A uniform coating can use a scalar.
- Add an **OpenGL normal** when shallow physical relief is visible at close or gameplay distance. Check tangent availability and normal direction. Keep strength proportional to the real relief. If the feature changes silhouette, produces a deep reveal, or must affect collision, use geometry.
- Add **metalness** only for genuine spatial changes between exposed metal and dielectric coating; use a scalar when the whole material is one class. Do not use metalness as a generic “make it shiny” control.
- Add **AO** only for surface-local cavities represented by the material. Never bake the building's sun shadows, window recess shadows, or story bands into generic cladding albedo.
- Omit height/displacement for this simple world unless an approved target and evidence show that normal mapping cannot supply the necessary shallow relief.

If plausible roughness/normal cannot be supported or coherently derived, fall back to neutral albedo plus scalar values. Invented PBR maps can make a material less believable than a simpler honest one.

### 5. Make scale physical and inspectable

For every tile, record:

- image width/height in pixels;
- represented physical width/height in meters;
- pixels per meter on each axis;
- exact Godot UV convention and material scale;
- expected repeats across the target receiver.

For a mesh whose UV coordinate advances by one unit per meter, a tile spanning `W × H` meters uses approximately `uv1_scale = (1/W, 1/H)`. If the mesh uses a different UV convention, derive the scale from that convention rather than copying this formula.

Scale is an acceptance property. A 1024-pixel tile over 2 m has 512 px/m; the same bitmap over 8 m has 128 px/m and four-times-larger motifs. Neither is intrinsically right. The physical size of corrugation, aggregate, seams, and stains must look plausible beside doors, people, and stories. Keep texel density reasonably consistent across adjacent receivers, then validate in the actual camera. Do not scale windows to force an incorrect story count.

### 6. Configure Godot as 3D material data

Minimum import/material contract:

- albedo/base color sampled as sRGB color;
- roughness, metalness, AO, height, and normal treated as linear/non-color data;
- OpenGL normal convention, or explicit Y inversion for DirectX source maps;
- mipmaps generated for every 3D map;
- repeat enabled only for assets declared tileable;
- linear filtering with mipmaps and anisotropy for ordinary non-pixel-art world materials, especially roads and oblique walls;
- same UV transform and dimensions across aligned maps;
- roughness filtering from the normal map considered when visible specular aliasing appears;
- imported dimensions, channel semantics, and compression checked after Godot import rather than inferred from filenames.

### 7. Treat pixel seams and semantic repetition as different gates

Keep the existing opposite-edge screen, but demote it from “quality pass” to **candidate rejection only**:

- compare left/right and top/bottom 1-pixel RGB edges after one fixed color-space conversion;
- record normalized MAE and RMSE;
- current project screen: MAE `<= 0.03` and RMSE `<= 0.06` on each axis;
- compare all four corner pixels or a very small corner neighborhood separately so a localized corner error cannot disappear into the edge mean;
- build an unblended, borderless 3×3 proof at native tile scale and a downscaled proof showing many repeats.

These scores may reject a candidate, but they cannot accept one. Run the semantic-repeat gate above first or alongside them. A candidate with excellent MAE/RMSE that creates a narrow window, truncated vent, doubled panel seam, broken brick course, or other new boundary motif is an unconditional fail.

Limitations that must remain explicit:

- Mean edge metrics can hide a bad local segment or corner.
- Matching endpoint values does not prove matching gradient, motif phase, or feature direction across the join.
- One-pixel comparisons miss a broad exposure band near an edge.
- Perfect bitmap edges do not prevent a new edge-composed motif, macro repetition, clone-stamp echoes, synchronized stains, or a four-way cross in a tiled field.
- No pixel metric proves motif identity/cadence, material identity, correct physical scale, plausible PBR response, receiver UV continuity, or building massing.

As a deterministic warning, a checker may also compare gradient magnitude across every join in the 3×3 proof with ordinary interior adjacencies. An extreme seam-to-interior ratio should trigger rejection/review, but it should not have a universal threshold: a legitimate mortar joint or panel seam may intentionally be a strong periodic boundary. The 3×3 and multi-repeat visual proofs remain hard gates.

### 8. Validate in Godot, on the exact target

Static proofs are necessary but insufficient. Use deterministic captures with the same engine version, renderer, resolution, FOV, environment, light transforms, target transform, material parameters, and physical UV scale:

1. **Neutral plane/material view:** front and oblique views under neutral light; rotate light/environment at least once. Reject baked light, inverted normal response, false metallic shine, and roughness that works from only one angle.
2. **Close receiver view:** exact target mesh at the nearest normal play distance. Reject blur, pixelation, painted-on depth, segment phase resets, UV stretching, and implausible motif size.
3. **Ordinary gameplay view:** the owner's ordinary third-person camera and route distance. The material must improve surface legibility without dominating the scene or becoming noisy.
4. **Macro-repeat view:** enough wall/ground to show at least several repeats in both applicable axes. Reject any boundary-created architectural motif or changed cadence, plus grids, synchronized stains, cloned focal features, and visible horizontal/vertical bands.
5. **Whole-object reference view:** for a named building, compare the entire visible object against the reference. Story count, silhouette, bay proportions, ground/roof bands, and depth are hard gates even if they are outside the material's implementation responsibility; a failed receiver means the combined result is not acceptable.

Capture the candidate and baseline at the same pose, but grade the candidate against an **absolute rubric**. “Better than gray” is diagnostic evidence, never acceptance.

### 9. Minimal deterministic pipeline

1. Read project scope, resource/privacy rules, and exact target contract.
2. Classify output as a surface-material tile, structured façade tile/atlas, or non-texture geometry problem. Stop or route on a category mismatch.
3. Define canonical motif geometry/order, true rectangular repeat cell, allowed edge crossings, physical span, and expected 3×3 motif counts for every patterned output.
4. Browse primary sources and write the building-texture specification, exclusions, map set, and target distances.
5. Generate/source a small fixed batch using one versioned brief. For structured output, demand complete motifs and repeat-safe separator boundaries. Record prompt/source URLs, date, tool/model mode, and seed where exposed.
6. Normalize mechanically; record dimensions, channels, color-space roles, hashes, and map alignment. Do not retouch candidates differently.
7. Build borderless and boundary-overlaid 3×3 proofs plus half-width/half-height circular-roll proofs.
8. Run the semantic-repeat gate: annotate or measure every boundary motif and hard-fail changed type, width, height, frame/mortar/trim thickness, spacing, order, alignment, or cadence. No new edge-composed motif is permitted.
9. Run edge/corner MAE/RMSE screening as secondary pixel evidence; create a larger multi-repeat proof for macro cadence.
10. Select only candidates that pass semantic repeat, pixel seam, macro repetition, neutral-albedo, physical-scale, and representation rubrics.
11. Import using pinned Godot settings and exact physical scale; verify imported properties.
12. Capture neutral, close, ordinary gameplay, macro-repeat, and whole-object views on the exact target.
13. Accept only if every hard gate passes. Preserve evidence and rejection reasons.

A hobby-scale attempt budget should be finite: one small initial batch and at most one correction round for a clearly diagnosed image defect. If that fails, stop and revise the asset classification/specification or use a better source material. Repeated generation is not a substitute for correcting the receiver or representation.

## Stop conditions for the skill

Stop and return a precise failure reason when any of these is true:

- the request calls a structured façade or non-texture building form a generic seamless surface-material tile;
- a patterned tile has no declared canonical motifs, dimensions/order, edge-crossing rule, or expected 3×3 cadence;
- any partial edge motif joins into an unplanned motif, such as Hawkins' narrow slit window, a truncated vent/door, doubled panel/cladding seam, misregistered balcony/trim, or broken brick/block course;
- the borderless 3×3 changes architectural motif type, width, height, spacing, thickness, order, alignment, or cadence across any boundary, even when MAE/RMSE passes;
- receiver height, massing, module dimensions, or UV convention are unknown and materially determine the output;
- the reference's key feature requires geometry, silhouette, deep recess, or collision;
- physical tile span is not declared;
- base color contains directional highlights, cast shadows, AO bands, or reflected scene content that cannot be neutralized honestly;
- PBR maps are misaligned, use the wrong color space/normal convention, or encode unsupported invented detail;
- edge screen fails, or a 3×3/wrap/multi-repeat proof shows a pixel join, semantic join, or repeated focal pattern;
- exact-target close/gameplay captures expose wrong scale, phase resets, blur/noise, painted depth, or implausible light response;
- named-building whole-object comparison fails story count, silhouette, layout rhythm, or major depth;
- the finite candidate/correction budget is exhausted;
- proceeding would require an unapproved download, account, external upload, license assumption, integration, export, or overwrite.

## Skill-ready acceptance rules

1. **Declare the motif grammar first:** canonical architectural motif types, dimensions, order, pitch, separators, physical span, and allowed edge crossings.
2. **Choose a true repeat cell:** use the smallest rectangle whose repetition preserves the intended building pattern without inventing another motif.
3. **Keep motifs complete when possible:** put structured-tile boundaries in repeat-safe cladding, mortar, mullion, spandrel, or trim zones—not through uncontrolled partial motifs.
4. **Hard-gate a borderless 3×3:** motif type, width, height, thickness, spacing, alignment, and cadence must survive every boundary; no slit window, truncated vent, doubled seam, broken course, or other edge-composed motif.
5. **Expose joins with wrap-around proofs:** inspect boundary overlays and half-width/half-height circular rolls, not only the isolated square.
6. **Never let edge metrics accept art:** MAE/RMSE can reject pixel discontinuity but cannot prove semantic periodicity.
7. **Classify the building texture:** surface-material tile, structured façade tile/atlas, or non-texture geometry problem. Never cross those boundaries silently.
8. **Research material behavior:** write coating, neutral value, roughness, relief, and real-world scale before generating pixels.
9. **No baked light:** albedo is surface color, not a photograph of lighting.
10. **Use the smallest honest PBR set:** scalar values are valid; add maps only for independent visible variation.
11. **Honor channel semantics and scale:** albedo sRGB; data maps linear; normals OpenGL; meters per tile and pixels per meter pinned.
12. **Test the exact receiver and grade absolutely:** close, ordinary gameplay, oblique, macro-repeat, and whole-object views; “better than gray” is never acceptance.
13. **Keep attempts finite and evidence reproducible:** fixed brief, small batch, one correction, hashes, settings, captures, motif annotations, and rejection reasons.

## Source register

All sources below were checked on 2026-08-29.

- Godot Engine stable documentation — [Standard Material 3D and ORM Material 3D](https://docs.godotengine.org/en/stable/tutorials/3d/standard_material_3d.html)
- Godot Engine stable documentation — [StandardMaterial3D](https://docs.godotengine.org/en/stable/classes/class_standardmaterial3d.html)
- Godot Engine stable documentation — [BaseMaterial3D](https://docs.godotengine.org/en/stable/classes/class_basematerial3d.html)
- Godot Engine stable documentation — [Importing images](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/importing_images.html)
- Godot Engine stable documentation — [Shading language / uniform hints](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/shading_language.html#uniform-hints)
- Adobe Photoshop — [Create a new pattern with Pattern Preview](https://helpx.adobe.com/photoshop/desktop/apply-painting-techniques/create-fill-with-patterns/create-a-new-pattern.html)
- Adobe Photoshop — [Pattern Maker tiled preview, boundaries, and offsets](https://helpx.adobe.com/photoshop/using/generate-pattern-using-pattern-maker.html)
- Adobe Substance 3D Designer — [Patterns](https://experienceleague.adobe.com/en/docs/substance-3d-designer/using/substance-graphs/nodes-reference-for-substance-graphs/node-library/texture-generators/patterns/patterns)
- Adobe Substance 3D Designer — [Tile Generator](https://experienceleague.adobe.com/en/docs/substance-3d-designer/using/substance-graphs/nodes-reference-for-substance-graphs/node-library/texture-generators/patterns/tile-generator)
- Adobe Substance 3D Designer — [Glossary](https://experienceleague.adobe.com/en/docs/substance-3d-designer/using/glossary)
- Adobe Substance 3D Sampler — [Delight](https://experienceleague.adobe.com/en/docs/substance-3d-sampler/using/filters/tools/delight-ai-powered)
- Adobe Substance 3D Painter — [UV texel density](https://experienceleague.adobe.com/en/docs/substance-3d-painter/using/effects/generators/uv-texel-density)
- Adobe Substance 3D Viewer — [Modify materials](https://helpx.adobe.com/substance-3d-viewer/desktop/tutorials/modify-materials.html)
- Adobe Substance 3D Viewer — [Environment workspace](https://helpx.adobe.com/substance-3d-viewer/desktop/interface/environment-workspace.html)
- Adobe Substance 3D — [Toolbag renderer channel mapping](https://experienceleague.adobe.com/en/docs/substance-3d/ecosystem/renderers/toolbag)
- Poly Haven — [Texture requirements](https://docs.polyhaven.com/en/technical-standards/textures)
- Poly Haven — [Blender add-on / automatic scale](https://docs.polyhaven.com/en/guides/blender-addon#automatic-scale)
- ImageMagick — [Image comparing examples and metric definitions](https://usage.imagemagick.org/compare/)
- ImageMagick — [`compare` command](https://imagemagick.org/compare/)
- ImageMagick — [`-roll` circular-offset operator](https://imagemagick.org/command-line-options/#roll)

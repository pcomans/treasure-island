# Godot material, channel, and scale contract

Read this reference when specifying maps, importing a candidate, or reviewing it on a Godot receiver.

## Representation boundary

- Albedo may carry neutral surface color and small-scale variation.
- A roughness map is justified only by visible spatial variation; otherwise use a scalar.
- Use an OpenGL normal map for shallow relief that does not affect silhouette or collision. Godot expects X+, Y+, Z+ normals; explicitly invert Y for a DirectX source.
- Metalness describes actual dielectric/metal class, not generic shininess. A uniformly coated metal surface is normally dielectric at the coating layer and may use a scalar.
- AO is only for local material cavities. Do not bake sun shadows, facade recess shadows, or story bands into generic albedo/AO.
- Deep reveals, ledges, openings, setbacks, roof forms, silhouette, and collision belong to geometry or a separately approved representation.

Use the smallest honest map set. Neutral albedo plus scalar roughness/metalness is valid when extra maps do not encode independent, visible behavior.

## Channel and import contract

Record the following rather than inferring it from filenames:

| Data | Godot role |
|---|---|
| Albedo/base color | sRGB color; no directional light, cast shadow, reflection, or baked highlight |
| Roughness, metalness, AO, height | Linear/non-color data |
| Normal | Linear/non-color OpenGL normal; aligned to albedo and physical scale |

For 3D world materials, verify mipmaps, repeat only on declared tileable axes, linear filtering with mipmaps and anisotropy, compression/import behavior, and identical UV transform across aligned maps. Consider normal-assisted roughness filtering only when specular aliasing is visible.

## Physical scale record

Every candidate must record:

```yaml
image_px: {width: int, height: int}
physical_span_status: measured | reference_bounded | production_inference
physical_span_m: {x: number, y: number}
pixels_per_metre: {x: number, y: number}
receiver_uv_convention: string
godot_uv1_scale: {x: number, y: number}
expected_repeats_on_receiver: {x: number, y: number}
```

For a mesh whose UV advances by one unit per metre, a tile spanning `W × H` metres uses approximately `uv1_scale = (1/W, 1/H)`. Derive other scales from the actual UV convention. When source measurements are unavailable, choose and label a reversible production-inference span from reference-relative, human, door, story, and neighboring-motif cues. Never call it measured or scale facade motifs merely to force a desired story count.

For the Treasure Island project, one Godot unit is one metre. That project convention is not a universal assumption for other repositories.

## Exact receiver proof

“Exact receiver” means the exact game object, wall/run or surface ownership, transform, UV/contact behavior, and protected geometry. It does not mean that real-world opening coordinates, count, cadence, or dimensions were surveyed.

Pin and report:

- engine version, renderer, import settings, material resource, shader or `StandardMaterial3D` parameters;
- exact scene path, receiver node/object ID, material surface/slot, mesh dimensions, transform, and UV convention;
- physical tile span and repeat counts;
- camera transform, FOV, resolution, environment, and light transforms.

Capture these applicable views under reproducible settings:

1. Neutral plane, front and oblique, with at least one changed light/environment direction.
2. Exact receiver at the nearest ordinary play distance.
3. Ordinary gameplay camera and route distance.
4. Enough receiver area to reveal several repeats on each tileable axis.
5. Whole-object reference view for a named building, with texture and geometry verdicts reported separately.

Reject baked light, inverted or implausible relief, false metallic response, implausible or mislabeled physical scale, UV stretching or phase resets, blur/pixelation, aliasing, conspicuous macro repetition, unsafe or wrong-region placement, or a receiver that makes the intended result false. Absence of surveyed real-world placement is not itself a rejection when the inference is bounded, reversible, and physically plausible. Do not change geometry, integrate, export, launch, or commit unless those actions are separately authorized.

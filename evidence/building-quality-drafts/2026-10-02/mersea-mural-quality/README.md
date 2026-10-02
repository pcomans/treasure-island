# Mersea mural quality prototype

Private source-world prototype archived 2026-10-02. The final mural replaces raised flower/sign meshes with flat authored paint projected onto existing corrugation. Independent source/safety and static visual review passed for this scoped preview. This is **not normal-main integration, gameplay/mechanics proof, release proof, or new recognition credit**. The protected dependency contract remains unchanged.

Open [comparison.html](comparison.html) for uncropped matched native originals. The baseline is the preserved raised-art model; the candidate uses the selected opaque image and corrected decal orientation. Both images are 1440×900, with identical player/camera positions and the same pose, light and environment configuration. Camera-forward differs by 1.49×10⁻⁸ from floating-point evaluation. Player/canopy occlusion and small lettering limit the comparison. Both native capture invocations exited cleanly; the moved source below has not been executed.

## Contents and portability

- `mersea_model.gd.txt`: complete authored prototype, derived from the actual candidate002 selected model.
- `mersea_live_attachment.gd.txt`: its temporary normal-world attachment/restoration helper, derived from the same executed input snapshot.
- `assets/mersea-mural-v3-opaque.png`: exact generated RGB artwork used in candidate002; no alpha channel.
- `before-original.png`, `after-original.png`: unchanged native images from the new matched mural pose.

Sources use `.gd.txt` archive names and sit beneath `evidence/.gdignore`, so they do not register scripts or enter ordinary Godot resource discovery. Future authorized use must extract them as `.gd` files beside the assets directory.

The only source adaptation after the captured version is resource-path plumbing: the attachment derives the PNG path from `model_script.resource_path.get_base_dir()` and passes it through `build`, `building`, and `mural` to `Image.load_from_file`. This removes a private absolute locator. Geometry, materials, decal bounds/orientation/mask and receiver behavior are unchanged, but these portable source bytes are **not the executed snapshot**, and their runtime loading is unverified. The scripts still depend on the existing project's frozen chunk and `WorldLoader`; this is an archive for later authorized integration, not a standalone application or approved live attachment.

Source mapping: site POI `n8017457805`; frozen building sources `w1308007114`, `w1308007113`, `w1308007112`, `w1098437841`. Mural receiver is `w1098437841`, local `Edge_3`, approximately 5.572×2.423m (reversible production inference). Decal mask2 projects inward onto the existing wall/ribs. Paint adds no collision geometry. No source IDs or canonical runtime files were changed.

## Artwork provenance and limits

Generated with the built-in `image_gen` tool, opaque-background mode, 2026-10-02. The selected third image uses a flat grey painted field after two transparent versions retained alpha holes; only the final artwork is archived here. Existing corrugation and lighting supply the physical surface. Grey is an approximate match (#7b7f7b sampled versus host steel #7e827d). The artwork is source-inspired game art, not a scan, surveyed replica or present-day verification.

Reference credit: [Official Mersea website](https://www.mersea.restaurant/), [original mural photograph](https://images.squarespace-cdn.com/content/v1/58533b8eebbd1abde9c34374/8a0a82e7-541d-4f5e-af41-7f9b6bb88e39/mersea+container+mural.jpg). Photograph date unknown; original retained privately and intentionally excluded from this archive. No external image is embedded in the gallery.

Selected image prompt (image1 was the official photograph; image2 was the earlier generated composition reference):

> Asset type: opaque flat wall-paint albedo raster, width:height 2.3:1. Image1 is the official Mersea mural photographic reference. Image2 is the previous extracted mural composition reference. Reproduce that flat artwork composition on a SOLID UNIFORM OPAQUE gray paint backdrop, exact gray #7e827d, filling the entire rectangular canvas. NO TRANSPARENCY anywhere. Central large circular field is SOLID UNIFORM OPAQUE deep navy #0b254a with NO holes, mottling, gradients, haze, or patchiness. Keep the source-inspired composition: three upper magenta/pink flowers, turquoise and black lower flowers, crossing ochre/olive stems and buds, orange diagonal MERSEA at upper-left of navy disk, orange palm-like mark at top, small magenta TREASURE ISLAND and SAN FRANCISCO along top, orange BY NJ BICE at lower-right disk edge. Preserve upright readable lettering and flower arrangement from image2. Fully opaque flat colored painted shapes throughout; black petal marks are black paint, not holes. Image1 supports shape/color only: do NOT depict the container itself, corrugation, sky, pavement, fixtures, plants, people, perspective, lighting, cast shadows, reflections or texture. It is a clean straight-on 2D wall-paint albedo graphic; existing 3D wall provides all corrugation and lighting. Uniform gray surrounds must reach every canvas edge. No added motifs, labels, border or 3D effects.

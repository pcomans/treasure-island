# San Francisco context provenance

## Current runtime skyline

- Runtime asset: `sf_skyline_owner_silhouette_final.png`.
- Purpose: distant, non-playable San Francisco skyline billboard viewed from Treasure Island.
- Source photograph: `IMG_7169.HEIC`, photographed and supplied by the project owner on 2026-08-28 for this private hobby game.
- Original HEIC SHA-256: `e6ddbebc699328ac1312890b5e1b7e55c8de91afc7bfc7a7c532cb03531fa047`.
- Preserved authoring copy: `source_assets/context/sf_skyline_photo/IMG_7169-source.png`, losslessly converted by macOS `sips`; SHA-256 `c6901c25314782906eb00ae530236303a631a45af00860c91bc31ee9efa19731`.
- Authoring boundary: `source_assets/context/sf_skyline_photo/.gdignore` keeps the full-resolution photo and generated variants outside Godot imports and exported game packages.

The built-in image-generation editor converted the owner photo into a skyline profile preserving the photographed relative landmark positions. The production prompt omitted the Bay Bridge because the game has a separate bridge model, removed sky/water/rocks, and prohibited invented landmarks, text, logos, borders, and watermarks. Non-runtime authoring variants are retained below the ignored source-assets directory.

For the subsequent style correction, the built-in editor was given the approved outline as the edit target and the owner photo only as a depth reference. The prompt requested the exact existing panorama and landmark positions as three close blue-gray filled values, with real transparency and no outlines, windows, hatching, bridge, or new geometry. The returned RGB-only candidate is retained as `generated_variants/sf_skyline_owner_atmospheric_shaded_v3_raw.png` (SHA-256 `62ea231c8a3620478faa5926aa9bab39a751a9d7637e0e5962e09022e7fc83f7`) but was rejected for runtime use because it baked in a checkerboard and subtly changed building geometry.

The editor's first line-art result returned an RGB checkerboard instead of real transparency. A deterministic ImageMagick cleanup changed only near-white background pixels to transparent, trimmed empty margins, and added 20 transparent pixels of padding:

```sh
magick sf_skyline_owner_outline_v1.png \
  -alpha off -fuzz 12% -transparent white \
  -trim +repage -bordercolor none -border 20 \
  sf_skyline_owner_outline_final.png
```

The current runtime derivative replaces that internal architectural linework with one filled skyline color while preserving the approved outer profile and transparent canvas.

The production silhouette was derived deterministically from the approved outline: extract and seal its alpha contour, flood away only the connected exterior, fill the enclosed skyline with one slate color, and restore the exact `2212x340` padded canvas.

```sh
magick sf_skyline_owner_outline_final.png \
  -alpha extract -threshold 5% -morphology Close Disk:1 -negate \
  -bordercolor white -border 1 -alpha on -channel RGBA \
  -fuzz 0 -fill none -draw 'alpha 0,0 floodfill' \
  -channel RGB -fill '#526979' -colorize 100% \
  -shave 1x1 -trim +repage -bordercolor none -border 20 \
  sf_skyline_owner_silhouette_final.png
```

- Runtime dimensions: `2212x340`.
- Runtime format: indexed palette-alpha PNG with exactly two entries: transparent `#00000000` and opaque slate `#526979FF`.
- Runtime SHA-256: `9c499ca3db08769142aac69b61e7d8fdf2aa84cd084b6716a19e7c504ba0b0c5`.
- Runtime content: one solid-color skyline silhouette; transparent sky and foreground; no bridge duplication.
- Runtime billboard geometry: `3900x600 m` at `(-1875,264.85,4306.4)`, positioned beyond the western span's San Francisco endpoint so the separate bridge model meets the city context.
- The doubled height and raised center preserve the alpha silhouette's near-water baseline; the billboard remains camera-facing, shadowless, and non-colliding.

## Historical fallback

- Asset: `sf_skyline_owner_outline_final.png`.
- Dimensions: `2212x340`, 8-bit PNG with alpha.
- SHA-256: `1939151e1098c4935d1a5fd230bc9a692c5484fc93fc5d5bd4064da0678927d4`.
- Status: retained as the owner-photo-derived architectural-outline fallback but no longer intended as the active billboard texture.

- Asset: `sf_skyline.svg`.
- Author: project-authored abstract silhouette created 2026-08-27.
- Inputs: no photo, downloaded skyline, font, asset-store item, or image-generation service.
- Status: retained as a historical fallback but no longer intended as the active billboard texture.

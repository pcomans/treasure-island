# Building 201 textures

Original art for the City Building 201 / Island Cove Market model
(`game/scripts/world/facades/b201_market_model.gd`). Nothing here is a copy of a
reference photo.

- `stucco_paint`, `roof_membrane`, `lot_worn`, `apron_concrete`, `market_interior`,
  `shop_posters`: generated with `tools/generate-texture`, resized. `stucco_paint` has
  its broad stains filtered out so the short tile does not show as a repeat.
- `mural_nnw`: generated mural pieces at their natural aspect on a plain generated wall.
- `banner`: the middle band of a generated sunset banner, faded.
- `sign_sheet`, `sign_plain`: a generated faded metal tile with procedural streaks;
  `sign_sheet` also has seam lines and painted lettering.
- `sign_atlas`: lettering and small signs drawn with ImageMagick (FreeSans), from the
  text the photos show; the container plates and stencil are plain numbers and a generic
  word, not the marks in the photos.
- `lot_stains`: procedural seal-coat patches, cracks, oil and rust dirt in alpha over
  41.25 m (15 stalls), so the oil lines up with the stall row.
- `grime_strip`: separate procedural run-off streaks in alpha over 44 m of wall, white so
  each material tints it.

Nothing here bakes in sun direction: no cast shadows or highlights, so the look holds
under a moving sun. Painted scenes in the mural and banner are artwork. Relief on ribbed
sheet and roll-up doors comes from normal maps built in the model.

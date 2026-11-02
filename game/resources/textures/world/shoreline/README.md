# Shoreline textures

The shoreline riprap (`tools/lib/shoreline-generation.mjs`) samples two
generated textures in `game/resources/materials/world/shoreline/riprap.gdshader`,
triplanar in world space (no UVs). The band inside the island outline is the
land's own field ground cover, not one of these.

- `riprap_albedo.png`: a top-down view of a riprap revetment, stones with dark
  voids between them. The underlay slope outside the outline samples it at about
  4.2 m per repeat, graded to the mid-to-dark grey of the 2025 photos; within
  the stones' visibility range it shows only in the gaps of the stone heap and
  is darkened there, and beyond it it stands in for the heap.
- `boulder_albedo.png`: the weathered skin of one grey boulder. Every instanced
  stone (top row, crest, heap and cobbles) samples it at about 1.7 m per repeat,
  each stone from its own offset, tinted per stone.

Both were generated on 2026-11-02 with `tools/generate-texture` (Codex image
generation, one image per call, text prompts only; no photograph was given to
the generator or copied), two candidates each, and both tile seamlessly as
generated. For `riprap_albedo.png` the second candidate was chosen for its
larger blocky grey and buff-brown stones, which match the dated photos of the
west shore (Sep 2025 Street View at 83 Treasure Island Rd; Commons Aug 2021); it
was resized from 1254 to 1024 px and its saturation lowered to 86 % with
ImageMagick. For `boulder_albedo.png` the first candidate was chosen for its
mid-to-dark grey greywacke with soft mottling, lichen flecks and faint rust
(Commons c10, May 2025; Sep 2025 Street View); it was only resized from 1254 to
1024 px. The untouched sources are kept outside Git with the shoreline work
notes.

| File | Use | Source prompt (short) |
|---|---|---|
| `riprap_albedo.png` | underlay slope | seamless top-down orthographic texture of a jumbled rock-armour seawall of large angular grey and buff-brown quarry stones, 0.5-1.2 m, deep dark voids, flat overcast light, no water, plants or wood |
| `boulder_albedo.png` | instanced stones | seamless close-up of the weathered surface of one large grey shoreline riprap boulder (greywacke), a 1 m patch: fine grain and speckle, soft mottling, small pits and chips, a few pale grey-green lichen flecks and faint rust staining, matte, mid-to-dark neutral grey, no gaps or rock edges, even overcast light |

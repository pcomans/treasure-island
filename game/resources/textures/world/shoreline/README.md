# Shoreline textures

`riprap_albedo.png` is the rock texture of the shoreline riprap
(`tools/lib/shoreline-generation.mjs`): the riprap overlay inside the island
outline, the rock slope outside it and the instanced boulders all sample it in
`game/resources/materials/world/shoreline/riprap.gdshader` (triplanar, about
4.2 m per repeat; boulders at 9 m so one stone shows rock grain).

Generated 2026-11-02 with `tools/generate-texture` (Codex image generation, one
image per call, text prompts only; no photograph was given to the generator or
copied). Two candidates were made; the second was chosen for its larger blocky
grey and buff-brown stones, which match the dated photos of the west shore
(Sep 2025 Street View at 83 Treasure Island Rd; Commons Aug 2021). It tiles
seamlessly as generated. It was then resized from 1254 to 1024 px and its
saturation lowered to 86 % with ImageMagick. The untouched sources are kept
outside Git with the shoreline work notes.

| File | Use | Source prompt (short) |
|---|---|---|
| `riprap_albedo.png` | riprap rock: overlay, slope and boulders | seamless top-down orthographic texture of a jumbled rock-armour seawall of large angular grey and buff-brown quarry stones, 0.5-1.2 m, deep dark voids, flat overcast light, no water, plants or wood |

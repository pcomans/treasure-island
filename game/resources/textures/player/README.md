# Player chest textures

The two textures of the player's treasure-chest character
(`game/scripts/player/chest_avatar_parts.gd`): the chest's painted wooden boards
and the heap of gold inside it. Generated 2026-11-02 with `tools/generate-texture`
(Codex image generation, one image per call, text prompts only; no photograph or
existing artwork was given to the generator or copied), then resized from
1254 px to 512 px with ImageMagick (Lanczos). The untouched sources are kept
outside Git with the chest-avatar work notes.

| File | Use | Source prompt (short) |
|---|---|---|
| `chest_wood.png` | the chest's walls and lid; one tile is four 16 cm boards (`PLANK_TILE` 0.64 m), tinted by vertex colour (darker inside) | seamless hand-painted cartoon wooden planks, 1930s rubber-hose style, four horizontal boards, seams at the quarter lines |
| `gold_coins.png` | the gold heap inside the chest, tiled every 25 cm (`COIN_TILE`) | seamless heap of gold coins seen from above, hand-painted 1930s cartoon style, sparkle highlights |

Everything else on the character (iron, brass, gloves, shoes, eyes, hoses,
flames) is vertex colour or drawn by its shader in `game/resources/player/`.

# Covered pier family

[pier_canopy_family.gd](../../scripts/world/facades/pier_canopy_family.gd) builds a covered, fixed concrete pier from a JSON config: a walkable deck over the water under a long, thin canopy on two rows of round columns. It shares the [housing family installer](../../scripts/world/facades/housing_family_live_attachment.gd); register an instance in [live_instances.json](../housing_family/live_instances.json) with `"family": "pier"`.

Instance: [w1222514695.json](w1222514695.json), the Treasure Island Ferry Terminal pier. Dimensions, counts and the gate layout are production inference from dated photos; see the config's `study_notes`.

## How it builds

1. `target.corners` gives the frozen pier corners (`north`/`east` at the plaza end, `south`/`west` at the water end). The north and east corners must appear in the generated (shore-clipped) wall record, which binds the config to the source.
2. Station `s` runs from the plaza end toward the water, and lateral `d` from the NW edge toward the SE edge.
3. The deck sits `deck.above_land` above the highest frozen land along the plaza end.
4. The shore station on each side is where the frozen land ends. The abutment runs to the shore station; past it, the edge beam and pile bents take over.
5. The playable boundary must include the pier polygon. For this pier it does, through `PLAYABLE_PIER_EXTENSION_SOURCE_KEYS` in `tools/lib/world-contract.mjs`.

## Roles

| Role | Parts |
|---|---|
| `ground` | The walkway. |
| `wall` (spray receivers) | Concrete upstand, parapet and end blocks; columns; the gate's portal frame. |
| `roof` | Canopy top. |
| `solid` | Everything else: edge beam, abutment, pile caps and piles, glass, rails, fascias, soffit, ribs, lamps, gate doors, signs, stand. These are opaque or glazed non-receivers on the spray layer. |

Columns run down inside the walls to their foundations: the abutment over the land, the edge beam over the water.

## Fields (defaults in brackets)

| Section | Field | Meaning |
|---|---|---|
| `deck` | `above_land` [0.1], `inset` [0.4] | Deck lift over the plaza land; edge inset from the footprint. |
| | `edge_beam_depth` [0.85], `chamfer` [0.25], `abutment_depth` [2.2] | Deck structure below the walkway. |
| | `panel` [3.0] | Length of the walkway's two-tone panels. |
| | `pile_cap_depth` [0.6], `pile_bottom_y` [-3.0] | Pile bents. |
| `walls` | `h` [0.55], `nw_t` [0.55], `se_t` [0.5] | Upstand and parapet height and thicknesses. |
| | `end_block_len` [0.65], `end_block_h` [0.95] | Plaza-end blocks. |
| `columns` | `count` [10], `first` [3.2], `last_from_sw` [3.0] | Columns per row and the stations of the first and last. |
| | `r` [0.2], `lamp_h` [2.55] | Radius; height of the uplight heads. |
| `glass` | `from` [1.6], `top` [2.35], `panel` [1.45] | NW windscreen start, top height and panel length. |
| `rail` | `top` [1.07], `picket_spacing` [0.115] | SE and water-end picket rails. |
| `gate` | `from_sw` [2.6], `head` [2.4], `head_top` [2.9] | Gate station from the water end; head height and top. |
| | `sign_w` [1.7], `sign_h` [0.34], `stand_before` [1.1] | LED sign size; offset of the information stand. |
| `roof` | `soffit_nw` [3.45], `soffit_se` [3.75] | Soffit heights over the deck; the plate tilts down to the NW. |
| | `fascia_inset` [0.35], `fascia_depth` [0.42], `fascia_band` [0.25] | Folded fascia: vertical band, then a slope in to the soffit. |
| | `prow_rise` [0.6], `prow_length` [12] | The SE edge rises toward the plaza tip. |
| | `rib_spacing` [0.3] | Soffit rib spacing. |
| `palette` | key: `rgb`, `alpha`, `roughness`, `metallic`, `emission`, `emission_energy` | Materials. Each key must be an object; materials are shared by value. |

Fit: list the deck route as a `--routes` plan. The settle rule cannot place the player under the canopy, so start routes on open ground.

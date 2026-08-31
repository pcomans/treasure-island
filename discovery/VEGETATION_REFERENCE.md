# Treasure Island vegetation reference

Observed in Google Maps Street View through Chrome on 2026-08-28. The imagery is used only as a visual reference; no Google imagery is shipped with the game.

## Representative observations

| Zone | Street View viewpoint | Imagery date shown | Useful vegetation pattern |
| --- | --- | --- | --- |
| Waterfront Plaza / ferry approach | [37.81678, -122.37200](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.81678,-122.37200&heading=220&pitch=0&fov=95) | Sep 2025 | Mostly hardscape and clipped lawn rectangles. A few low shrubs and small dark conifers sit away from the main arrival path. Keep the ferry spawn and sightline open. |
| Clipper Cove Way | [37.81663, -122.37035](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.81663,-122.37035&heading=90&pitch=0&fov=95) | Nov 2025 | A deliberate row of date palms beside the rebuilt road, with small planted beds and ground cover. Adjacent fenced/industrial ground remains sparse. |
| South residential / Avenue A | [37.82080, -122.37400](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82080,-122.37400&heading=150&pitch=0&fov=95) | Nov 2025 | Evenly spaced palms, repeated ornamental-grass beds, low shrubs, and young landscaping. This is the most manicured palette seen. |
| Legacy grid / Avenue M | [37.82433, -122.36634](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82433,-122.36634&heading=215&pitch=0&fov=95) | Mar 2025 | Sparse mature broad-canopy street trees with irregular, wind-shaped trunks. Small grass/dirt patches and almost no continuous shrub layer. |
| Central Avenue H corridor | [37.82690, -122.37108](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82690,-122.37108&heading=165&pitch=0&fov=95) | Sep 2025 | Compact cypress/conifer groves around selected lot edges, surrounded by large stretches of bare or paved ground. |
| Northpoint Drive | [37.83110, -122.37455](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.83110,-122.37455&heading=80&pitch=0&fov=95) | Mar 2025 | Broad maintained lawns dominate. Trees and hedges are occasional and concentrated near buildings or the perimeter rather than scattered densely. |
| Gateview Avenue / west residential edge | [37.82568, -122.37696](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82568,-122.37696&heading=330&pitch=0&fov=95) | Mar 2025 | Open lawns, isolated broad-canopy trees, and a few small flowering shrubs beside residences. The shoreline-facing open space is visually uncluttered. |

## Game-ready palette

- Date/fan palms for deliberate southern rows and small landscaped groups.
- Mature broadleaf trees for the legacy street grid and residential lawns.
- Cypress/conifer forms for compact central groves and occasional waterfront accents.
- Low shrubs and ornamental grass clumps for the newer south-side planting beds.
- Lawn remains a terrain/material treatment; it should not be represented by thousands of individual grass meshes.

## Placement rules inferred from the reference

- Keep the island sparse overall. Recognizable clusters and rows matter more than blanket coverage.
- Use higher density only in newer south-side landscaping; use low density through the legacy grid and housing lawns.
- Preserve long open views at Waterfront Plaza, along the shore, and across large north lawns.
- Keep industrial lots mostly bare except for occasional edge trees or a compact grove.
- Vegetation must be grounded to the same serialized terrain surface as the player and buildings.
- Reject candidates inside or close to roads, paths, buildings, water, the shoreline edge, the ferry spawn/arrival route, and authored QA-route clearance corridors.
- Generate candidates from a fixed seed and stable cell/source identifiers. Asset choice, yaw, scale, and acceptance must not depend on iteration order or runtime entropy.
- Use premade plant meshes only; procedural work is limited to deterministic placement, grouping, rotation, and modest scale variation.

## Accepted NAIP unknown-crown rule

All 22 accepted `unknown` points in the pinned 2022-05-18 NAIP annotation file are runtime shrubs at their exact projected horizontal coordinates. A SHA-256 of the fixed seed plus annotation ID selects one of the three already approved shrub GLBs, yaw, and scale; location never receives jitter, snapping, or runtime randomness. The source points retain the shoreline, terrain-overlay, ferry, and QA-route clearances. Because manual crown centers are source evidence rather than procedural guesses, their road/building check is actual polygon exterior (`> 0`, recorded as a 1 mm policy threshold) instead of the procedural 4–5 m aesthetic buffer. All 22 pass: minimum road/building distances are `0.102 m` and `1.109 m`, minimum shoreline/overlay distances are `19.267 m` and `14.450 m`, and the deterministic rejection list is empty.

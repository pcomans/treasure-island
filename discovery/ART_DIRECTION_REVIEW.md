# Art-direction checkpoint — 2026-08-28

Authority: `evidence/first-playable/owner-bridge-connected-rendered-2026-08-28-1944-retry/` (the complete 12-frame Forward+/Metal set). Earlier frames were used only to tell already-fixed defects from current ones.

## What already reads well

- `09-owner-aerial-center.png` and `10-owner-aerial-east.png` read as Treasure Island: the long man-made outline, shoreline, road grid, large open areas, and denser built-up side are all clear.
- `08-ybi-bridge-context.png` now gives YBI an irregular terrain silhouette instead of a generic mound. The bridge and the single-color San Francisco profile are recognizable context, and the bridge now points toward the city mass.
- The player has a clear silhouette and contact shadow. In the current set, the visible buildings meet the terrain; the obvious hovering shown in the owner's earlier 14:22 screenshot is not reproduced. This agrees with the current zero-positive-gap foundation audit.
- The tag is readable against the deliberately simple wall, and the low-poly treatment is coherent with the hobby-project scope.

## Current priorities, ordered by ordinary-play impact

1. **The pavement layers still read like GIS ribbons, not a coherent street surface.** In `01`–`05`, equal-weight gray strips, parallel path lines, abrupt stubs, and small green/light wedges at junctions compete for attention. `09` and `10` prove that the mapped grid is present, but the eye-height read can still resemble overlapping map layers. The physical conformance checks are strong, so this should be treated as a visual pavement-skin problem, not a terrain/collision rewrite.
2. **Atmosphere compresses the context into the sky.** In `07-horizon-context.png` and `08-ybi-bridge-context.png`, the corrected SF shape and bridge placement work, but the skyline, bridge, and sky occupy nearly the same pale value range. The player and dark road win the frame while the recognizability context recedes more than it needs to.
3. **Large building masses lack a visual base and human scale.** Foundations are now technically grounded, but a single uninterrupted beige wall can fill most of an ordinary view (`02`, `04`, `06`). A procedural base band and a very small set of facade/roof value variants would anchor them without windows, interiors, apartment modeling, or photorealism.

The 22 accepted NAIP `unknown` annotations are being mapped to deterministic shrub variants separately. Review that completed layer in the next screenshot set; do not start a competing vegetation-density or distribution rewrite.

## One next implementation change

Build one **visual pavement skin** from the existing OSM road/path and paved-area records while preserving the current terrain collision and source coverage:

- use a dark neutral for vehicle roads, a visibly lighter neutral for footways/paths, and an intermediate paved-area value;
- union or cap same-class surfaces at junctions so mapped connections read as filled connections rather than crossing ribbons;
- keep the skin draped within the existing terrain-conformance envelope and leave the physical ground, building foundations, and gameplay unchanged.

Acceptance for the rerender:

- In all five ordinary-height regional frames (`01`–`05`), each intended vehicle road visible in the foreground continues into the midground without a green/light triangular gap, exposed underside, or z-fighting.
- At junctions within roughly 30 m of the player, no unintended terrain sliver wider than 0.25 m crosses the apparent driving/walking surface; a true mapped dead end may remain a dead end.
- Vehicle roads and footways differ by at least 12% relative luminance, so `09` and `10` retain the full grid while footpaths no longer carry the same visual weight as streets.
- Generated coverage remains `427/427` road/path sources, road clearance remains inside the current `0.019–0.081 m` envelope, and the building-foundation maximum positive gap remains `0 m`.

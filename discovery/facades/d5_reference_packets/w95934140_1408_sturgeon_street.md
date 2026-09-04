# D5 source packet — 1408 Sturgeon Street (`w95934140`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready; detached study only**

Catalog provenance: `ti.facade-recognition-catalog/3`, checked 2026-09-04,
SHA-256 `0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0`.
Frozen source: OSM way `w95934140`, v4, `2020-07-09T13:50:42Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1408`, `addr:street=Sturgeon Street`, `building=yes`,
`height=6`.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w95934140` / `building:w95934140:wall` / `building:w95934140:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-2` |
| Mass | area `475.241 m²`; height `6 m`; NAVD88 base/top `3.100 / 9.100 m` |
| Perimeter | serialized `110.835 m`; visible `110.836 m`; `22` runs |
| Facing-run partition | WSW `243.8°`: `0,3,5–6`; SSE `153.8–153.9°`: `1–2,7–10,13`; NNW `333.8–333.9°`: `4,17,20–21`; ENE `63.8–64.0°`: `11–12,14–16,18–19` |
| Source / wall geometry SHA-256 | `f6551ebd8238310588851093e7e74e3e49436e482e39039435a50d39538edb83` / `4ef2bbde13cd432d6a9b110cf31791694c9ed9bb61941b1d2ef921073ce4d415` |
| Registry record / chunk SHA-256 | `f542f4e409fd8d6039267d5f12ea19d149cfdba3a11c37e84f589fe3eec18443` / `3a07310461da7d9e76667412c6ca18dac8bdea89923cd8392436421882132ef9` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is an
opaque, colliding, non-spray receiver.

## Identity, lifecycle, and appearance evidence

`CITY-EAS` record `483502` is `1408 STURGEON ST`, parcel `1939001`, point
`37.8260892015,-122.3751324105`, current in that dataset on 2026-09-03. It is
absent from the `TIDA-JSCO-2026` managed list; that is not demolition,
occupancy, or appearance evidence.

- [March 2025 pano `E8fUbp-OB6KUtmnh9rhHkQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=E8fUbp-OB6KUtmnh9rhHkQ&heading=62&pitch=0&fov=75), camera `37.8261203,-122.3752900`, heading `62°`: direct close WSW public-side association, runs `0,3,5–6`, with visible returns. Written observation: two large gabled end/garage wings with three garage doors on each side, a lower central two-storey connector, two exterior stairs, tan stucco, pink/gray garage and rail accents, sparse rectangular openings, and a broad lawn setback.

Unknown: exact bay widths, hidden SSE/NNW/ENE schedules, stair details,
alterations, and occupancy. No panorama pixels are retained.

## Recognition boundary and handoff

Minimum cue: **symmetric three-plus-three garage wings and the two-stair central
connector**. Close confusion: 1406, 1410, and the other Sturgeon/Flounder/
Halibut rows. A detached study may reuse tileable tan plaster and muted roof
fields, but the visible garage symmetry, stair voids, and pink/gray accents must
remain entity-specific. Prototype blocker: **none for the observed WSW study**.

Shared sources, lifecycle caveats, and rights boundary: [D5 index](README.md).

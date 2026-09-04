# D5 source packet — 1410 Flounder Court (`w95934124`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready; detached study only**

Catalog provenance: `ti.facade-recognition-catalog/3`, checked 2026-09-04,
SHA-256 `0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0`.
Frozen source: OSM way `w95934124`, v4, `2020-07-09T13:50:42Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1410`, `addr:street=Flounder Court`, `building=yes`,
`height=6`.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w95934124` / `building:w95934124:wall` / `building:w95934124:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-2` |
| Mass | area `475.487 m²`; height `6 m`; NAVD88 base/top `3.125 / 9.125 m` |
| Perimeter | serialized `110.846 m`; visible `110.845 m`; `18` runs |
| Facing-run partition | WSW `243.4–243.5°`: `0–2,5,16`; SSE `153.3–153.5°`: `3–4,6,12`; ENE `63.5°`: `7–8,10–11,13–14`; NNW `333.4–333.5°`: `9,15,17` |
| Source / wall geometry SHA-256 | `adbebea3a671d525a0abd85f97f735800c7ebcfcc3580d70aafd12df1cb483c6` / `41355d012fd81979bd353a81516a2d50aed1dd14477a9da8d76ea95cfa436ed6` |
| Registry record / chunk SHA-256 | `618c548f56ad911f39f25f1e6c230e3ea593e5f1e32d606df15859a5e84be291` / `3a07310461da7d9e76667412c6ca18dac8bdea89923cd8392436421882132ef9` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is an
opaque, colliding, non-spray receiver.

## Identity, lifecycle, and appearance evidence

`CITY-EAS` record `483536` is `1410 FLOUNDER CT`, parcel `1939001`, point
`37.8263144825,-122.3748179021`, current in that dataset on 2026-09-03. It is
not on the `TIDA-JSCO-2026` managed-premises list; absence from that list is not
evidence of demolition, vacancy, or a facade change.

- [March 2025 pano `iCHqZ_Wp4GXw69BOJtI-bA`](https://www.google.com/maps/@?api=1&map_action=pano&pano=iCHqZ_Wp4GXw69BOJtI-bA&heading=178&pitch=0&fov=75), camera `37.8269624,-122.3750351`, heading `178°`: target-bound NNW public-side association, principally runs `9,15,17`, with oblique returns. Written observation: paired broad two-storey garage/end wings flanking a lower central connector, two exterior stairs, pale warm stucco, muted red-brown shallow roofs, sparse rectangular openings, and pastel pink/gray garage doors. Vehicles obscure part of the cadence.

Unknown: exact garage count behind vehicles, bay widths, trim details, hidden
WSW/SSE/ENE schedules, alterations, and occupancy. No panorama pixels are
retained.

## Recognition boundary and handoff

Minimum cue: **paired garage/end wings plus the two-stair central connector**.
Close confusion: 1409, 1411, 1412, and 1413 Flounder and the similar
Sturgeon/Halibut rows. Preserve the paired-wing silhouette and observed stair
voids; do not inherit another row's exact garage/window cadence. Tileable pale
plaster and roof fields are reusable; garages, stairs, and openings stay whole
local modules. Prototype blocker: **none for the observed NNW study**.

Shared sources, lifecycle caveats, and rights boundary: [D5 index](README.md).

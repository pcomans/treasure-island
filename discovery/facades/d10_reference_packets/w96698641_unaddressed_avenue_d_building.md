# D10 source packet — unaddressed Avenue D building (`w96698641`)

Checked: **2026-09-04**  
Readiness: **target-side historical prototype-ready**

Packet-time catalog/registry provenance: catalog `ti.facade-recognition-catalog/4`, SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`; D10 packet-time registry snapshot `ti.facade-runtime-registry/4`, SHA-256 `dce268c1547e4e4620faff9d59110ee1214a9a2121c1f83b3eb1c865339360ab`. Frozen source: OSM way `w96698641`, v4, `2018-01-22T18:56:15Z`, from `treasure-island-2026-08-27.osm` SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`; tags `building=yes`, `building:levels=1`, `height=4`. No proper name exists in the frozen source. No frozen street address exists.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96698641` / `building:w96698641:wall` / `building:w96698641:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-1__z_-1` |
| Mass | area `257.736 m²`; height `4 m`; NAVD88 base/top `3.385 / 7.385 m` |
| Perimeter | serialized `64.726 m`; visible `64.725 m`; `8` runs |
| Facing-run partition | ENE `62.0°`: `0–1`; SSE `152.0°`: `6–7`; WSW `242.0°`: `4–5`; NNW `332.0°`: `2–3` |
| Source / wall geometry SHA-256 | `6fc0acb325f32f5786c73de8e48be42782327bafddecf456c3d405e8efb8284f` / `854e3a075ae1560ef800dce5fc597096c4d5b88275f106688415c3cbe0de0ce3` |
| Registry record / chunk SHA-256 | `4d7df21d9d54e783a6fc058bb5c945467b7f003477d33d8b9a03c84f7d2b5e10` / `5e3b7efb7a2c61e1092c6a42ca9c04212c7d2603890b7a3f4c5e46777005f17b` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is opaque, colliding, and non-spray. Facing runs are exact outward-normal partitions, not an inferred opening schedule.

## Identity, lifecycle, and public-side appearance

No safe `CITY-EAS` or `CITY-XWALK` footprint binding was found; the nearest current address is roughly `90 m` away. The frozen way has no address or proper name. A fully screened 2025 view creates an explicit lifecycle/currentness conflict, so the historical appearance is not represented as current.

- [June 2019 pano `Bl__yBIv22fYYSzT0GlKdA`](https://www.google.com/maps/@?api=1&map_action=pano&pano=Bl__yBIv22fYYSzT0GlKdA&heading=314.8&pitch=0&fov=75), camera `37.8243636,-122.3722301`, direct centroid ray `314.8°` at about `17.6 m`: supports the SSE-facing family. [September 2025 pano `zymx-sHLgpe6167colQIQQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=zymx-sHLgpe6167colQIQQ&heading=320.4&pitch=0&fov=75) shows only a green construction fence.

Written observation: the 2019 target is a vivid blue single-storey rectangular/ribbed-panel portable-like volume with yellow trim/belt, repeated dark rectangular windows, a flat or very shallow roof edge, a pale utility box, and a detached blue annex. Current imagery does not expose the facade.

## Recognition boundary and handoff

Minimum cue: **historical vivid-blue ribbed-panel volume, yellow belt/trim, repeated dark windows, and shallow roof edge**. Close confusion: portable/utility buildings elsewhere on the island and the detached blue annex. Share ribbed-panel, flat-edge, glazing, and utility-box components; retain the blue/yellow palette and repeated-window cadence locally, and do not merge the annex into the receiver. Prototype/component blocker: **none for a clearly labeled historical SSE study; any current-condition claim is blocked by the 2025 construction fence**. Address, proper name, present survival/condition, hidden sides, interiors, occupancy, and post-2019 changes remain unknown. No panorama pixels are retained or proposed as texture inputs.

Shared sources, capture/currentness caveats, packet-time/current registry split, and rights boundary: [D10 index](README.md).

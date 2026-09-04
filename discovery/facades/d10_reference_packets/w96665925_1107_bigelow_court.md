# D10 source packet — 1107 Bigelow Court (`w96665925`)

Checked: **2026-09-04**  
Readiness: **component/NNE siding-and-board-up study ready**

Packet-time catalog/registry provenance: catalog `ti.facade-recognition-catalog/4`, SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`; D10 packet-time registry snapshot `ti.facade-runtime-registry/4`, SHA-256 `dce268c1547e4e4620faff9d59110ee1214a9a2121c1f83b3eb1c865339360ab`. Frozen source: OSM way `w96665925`, v5, `2020-07-09T13:50:42Z`, from `treasure-island-2026-08-27.osm` SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`; tags `access=no`, `addr:housenumber=1107`, `addr:street=Bigelow Court`, `building=abandoned`, `building:levels=2`, `height=6`. No proper name exists in the frozen source.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96665925` / `building:w96665925:wall` / `building:w96665925:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-2` |
| Mass | area `470.828 m²`; height `6 m`; NAVD88 base/top `2.469 / 8.469 m` |
| Perimeter | serialized `109.172 m`; visible `109.172 m`; `16` runs |
| Facing-run partition | NNE `16.6°`: `0–5`; ESE `106.6°`: `15`; SSW `196.6°`: `9–11,13–14`; WNW `286.6–286.7°`: `6–8,12` |
| Source / wall geometry SHA-256 | `9a91992a122e92465b36ea027a41fb324fc11fa05ae4d5ff93adf4072b02200d` / `d69eabdb6f2f473c32c993fd3e9c41605cfd8ff353c9f569a832db07c0d6b32f` |
| Registry record / chunk SHA-256 | `15822ce1d44ee5b7cabd5fcea3a13430d80dab6c604140dc20ccb2963ab7c393` / `3a07310461da7d9e76667412c6ca18dac8bdea89923cd8392436421882132ef9` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is opaque, colliding, and non-spray. Facing runs are exact outward-normal partitions, not an inferred opening schedule.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483600 / 725391`, point `37.8274638,-122.3759163`, supports the 1107 Bigelow Court civic address on parcel `1939001`, direct source `SF DBI`, `data_as_of=2026-09-03T18:00:54.000`. Frozen `access=no` and `building=abandoned` are source-time lifecycle tags, not a claim about present access, occupancy, survival, or legal status.

- [February 2018 pano `l2kgtZj_Z8NONagHyClybQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=l2kgtZj_Z8NONagHyClybQ&heading=170.3&pitch=0&fov=75), camera `37.8277180,-122.3759766`, direct centroid ray `170.3°` at about `19.1 m`: supports the NNE-facing family.

Written observation: gray/taupe horizontal siding, a white horizontal belt with white trim/downpipes, rectangular upper windows, and boarded lower openings. Trees, sun glare, and a vehicle obscure enough of the plane that a complete opening schedule is not authorized.

## Recognition boundary and handoff

Minimum cue: **gray/taupe horizontal siding, white belt/trim, upper rectangular windows, and lower boarding treatment**. Close confusion: 1105 Bigelow and nearby gray Site 12 housing rows. Share the gray siding, white trim/downpipe, glazing, and boarding modules; keep only the observed 1107 NNE fragments local. Prototype/component blocker: **full target-side prototype remains blocked by vegetation/glare/vehicle occlusion and incomplete lower opening endpoints**. Unseen runs, complete entry cadence, current lifecycle, interiors, and post-capture changes remain unknown. No panorama pixels are retained or proposed as texture inputs.

Shared sources, capture/currentness caveats, packet-time/current registry split, and rights boundary: [D10 index](README.md).

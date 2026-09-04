# D5 source packet — 1316 Gateview Avenue (`w96215648`)

Checked: **2026-09-04**  
Readiness: **component/rear-side study ready; public front remains unsupported**

Catalog provenance: `ti.facade-recognition-catalog/3`, checked 2026-09-04,
SHA-256 `0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0`.
Frozen source: OSM way `w96215648`, v5, `2020-07-09T13:50:42Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1316`, `addr:street=Gateview Avenue`,
`building=residential`, `building:levels=2`, `height=6`.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215648` / `building:w96215648:wall` / `building:w96215648:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-3__z_-2` |
| Mass | area `776.725 m²`; height `6 m`; NAVD88 base/top `2.039 / 8.039 m` |
| Perimeter | serialized `170.316 m`; visible `170.315 m`; `30` runs |
| Facing-run partition | WSW `243.3–243.4°`: `0,2,4–5,7,9–10,12–13,15,28`; SSE `153.3–153.5°`: `1,8,14,16–17,22`; NNW `333.1–333.3°`: `3,6,11,26–27,29`; ENE `63.3°`: `18–21,23–25` |
| Source / wall geometry SHA-256 | `b8a5d9f7772c8b76fcf7c0c01bc96836d761a49dc907ac9256525abbfa8ac7e9` / `60f6f87157c7511a3efbc18b27a07193974bc1faed3de07a32ede0f2eeab3c88` |
| Registry record / chunk SHA-256 | `9e578d0eac573bb8236e863353b8c90512c49ec5d1a713f524c74b161f5dfa31` / `35bf23d64e860d39c5b79a98be7830f4f477143f7e9490c6739dec0627062d11` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is an
opaque, colliding, non-spray receiver.

## Identity, lifecycle, and appearance evidence

`CITY-EAS` record `483578` is `1316 GATEVIEW AVE`, parcel `1939001`, point
`37.8263625020,-122.3772003930`, current in that dataset on 2026-09-03.
`TIDA-JSCO-2026` includes 1316 Gateview as of 2025-07-01. These establish
identity/administrative currency, not occupancy or front appearance.

- [November 2025 pano `GmuTsOm1-FO47a4FOWEQHA`](https://www.google.com/maps/@?api=1&map_action=pano&pano=GmuTsOm1-FO47a4FOWEQHA&heading=181&pitch=0&fov=75), camera `37.8266407,-122.3769985`, heading `181°`: target-bound NNW rear/side association at roughly 55 m, principally runs `3,6,11,26–27,29`. Written observation: a long cool blue-gray horizontal-sided two-storey row, repeated white-trimmed upper windows, sparse lower rear windows, a shallow roof, wood fencing, and a pergola/overhang zone; the lower plane is partly hidden.

Unknown: public-front composition, fence-hidden lower openings, WSW/SSE/ENE
schedules, alterations, and occupancy. Closer user-contributed imagery was
excluded; no panorama pixels are retained.

## Recognition boundary and handoff

Minimum component cue: **long cool-blue siding field, white upper-window
rhythm, sparse fenced rear, and pergola/overhang zone**. Close confusion: 1314,
1315, 1317, and 1318 Gateview. A bounded NNW component study is allowed; it may
not become a front or donate its schedule to blocked 1314. Prototype blocker:
**target-identifiable public-front evidence remains missing for whole-building
recognition**.

Shared sources, lifecycle caveats, and rights boundary: [D5 index](README.md).

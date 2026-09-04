# D5 source packet — 1314 Gateview Avenue (`w95934132`)

Checked: **2026-09-04**  
Readiness: **appearance-blocked; identity and receiver contract are ready**

Catalog provenance: `ti.facade-recognition-catalog/3`, checked 2026-09-04,
SHA-256 `0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0`.
Frozen source: OSM way `w95934132`, v5, `2020-07-09T13:50:42Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1314`, `addr:street=Gateview Avenue`,
`building=residential`, `building:levels=2`, `height=6`.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w95934132` / `building:w95934132:wall` / `building:w95934132:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-1` |
| Mass | area `499.955 m²`; height `6 m`; NAVD88 base/top `2.434 / 8.434 m` |
| Perimeter | serialized `121.663 m`; visible `121.663 m`; `28` runs |
| Facing-run partition | WSW `244.5–244.6°`: `0,4,7,10–11,13,24–25`; SSE `154.5–154.7°`: `1–3,12,14–15,19`; NNW `334.5–334.8°`: `5–6,8–9,22–23,26–27`; ENE `64.5–64.6°`: `16–18,20–21` |
| Source / wall geometry SHA-256 | `dce704d9cd776c00bf54f9fc86d2487942beb68cfbc203fd73c6b06250210bba` / `2162abceb22677d71ef54358f622fe53a8d04dbebf2eb5014bb49853c94af1de` |
| Registry record / chunk SHA-256 | `7818358a0b6f92d9584e59fa56b463b9beab0ca343031f78c847d5e7839e7bd6` / `6de57eb30f5771f43b33d7b71b53952be5ea6ec17706102be634a781152a3ee2` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is an
opaque, colliding, non-spray receiver.

## Identity, lifecycle, and appearance evidence

`CITY-EAS` record `483576` is `1314 GATEVIEW AVE`, parcel `1939001`, point
`37.8259260682,-122.3769375365`, current in that dataset on 2026-09-03.
`TIDA-JSCO-2026` includes 1314 Gateview as of 2025-07-01. These are identity and
administrative-currentness evidence only.

- [November 2025 pano `GmuTsOm1-FO47a4FOWEQHA`](https://www.google.com/maps/@?api=1&map_action=pano&pano=GmuTsOm1-FO47a4FOWEQHA&heading=169&pitch=0&fov=75), camera `37.8266407,-122.3769985`, heading `169°`: distant direction toward the NNW run family. Multiple similar Gateview rows merge at roughly 99 m; cool siding, white-trimmed upper openings, fencing, and overhangs are visible in the corridor, but cannot be assigned securely to this target's exact solid/void schedule.

Unknown: every target-specific public-side opening/canopy schedule, colors,
alterations, survival after November 2025, and occupancy. Closer
user-contributed imagery encountered during research was excluded; no panorama
pixels are retained.

## Recognition boundary and handoff

Close confusion: 1312, 1316, 1317, and 1318 Gateview. The neutral mass may be
used for receiver tests, but no detailed target facade is authorized from this
packet. It may share a future tileable neutral siding material without
inheriting 1316/1317 windows, canopies, or repairs. Prototype blocker:
**recover a dated, rights-clear view or elevation that separates at least one
exact `w95934132` compass side from neighboring rows**.

Shared sources, lifecycle caveats, and rights boundary: [D5 index](README.md).

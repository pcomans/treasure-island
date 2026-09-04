# D8 source packet — 1251 Exposition Drive (`w96215694`)

Checked: **2026-09-04**  
Readiness: **component/upper-and-rear study ready**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.
Frozen source: OSM way `w96215694`, v5, `2018-01-25T19:29:08Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1251`, `building=residential`, `building:levels=2`,
`height=6`. The frozen way supplies no street or proper name; `CITY-XWALK` and
`CITY-EAS` independently resolve the number as 1251 Exposition Drive.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215694` / `building:w96215694:wall` / `building:w96215694:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-1__z_-3` |
| Mass | area `608.547 m²`; height `6 m`; NAVD88 base/top `3.134 / 9.134 m` |
| Perimeter | serialized `145.328 m`; visible `145.328 m`; `28` runs |
| Facing-run partition | ENE `62.4–62.5°`: `0,2–5,7,9–10`; SSE `152.4–152.5°`: `1,8,19–20,26–27`; WSW `242.4–242.5°`: `12–13,16–18,21–23,25`; NNW `332.4–332.6°`: `6,11,14–15,24` |
| Source / wall geometry SHA-256 | `52286491293ec0014127199ca48f5474c27e6e44ecc0f0e15a87f563b05a75fe` / `994d826b1e4fb52b06d941c4b9bddc3aeaed2bbcdcec5f34a48dce765abe41a6` |
| Registry record / chunk SHA-256 | `de73f07e0cd4f393e47af00671f78db77fc72d0af7de7adc68255acf5eaf5038` / `d82a0767672898b348115d9df812a1a33bee96bca0d5d58713c52087591011bc` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-XWALK` retains 1251 Exposition Drive without renumbering. `CITY-EAS`
base/address IDs `483583 / 725374` identify `1251 EXPOSITION DR` on parcel
`1939001`, current in that dataset on 2026-09-03. These are identity and
administrative-currentness evidence, not facade or occupancy proof.

- [September 2025 pano `K09gJA6nl7TnswrVs-3I0Q`](https://www.google.com/maps/@?api=1&map_action=pano&pano=K09gJA6nl7TnswrVs-3I0Q&heading=249.8&pitch=0&fov=70), camera `37.8295562,-122.3713852`, direct centroid ray at about `22.1 m`: bounds an ENE/rear-side view.

Written observation: a tall wood fence and central tree hide most of the lower
and middle facade. Visible target-bound cues are pale-gray horizontal siding,
a shallow reddish-brown roof, repeated upper windows, a small lower clerestory
band at left, and downspouts. No complete entry or long-side schedule is
visible.

## Recognition boundary and handoff

Minimum cue: **pale siding, reddish shallow roof, upper-window rhythm, and a
small lower clerestory strip behind the fence**. Close confusion: nearby
Exposition/Gateview residential rows. Share generic siding, trim, roof, and
window modules only; do not transfer a neighbor's entries or lower schedule.
Component blocker: **central tree and fence prevent a defensible whole-side
prototype**. No panorama pixels are retained.

Shared sources, lifecycle caveats, and rights boundary: [D8 index](README.md).

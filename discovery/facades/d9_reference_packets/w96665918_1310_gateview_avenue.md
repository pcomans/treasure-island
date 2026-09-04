# D9 source packet — 1310 Gateview Avenue / Building 1310 (`w96665918`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Catalog/registry provenance: catalog `ti.facade-recognition-catalog/4`, SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`; D9 packet-time registry snapshot and separately checked current registry `ti.facade-runtime-registry/4`, SHA-256 `acc04aa840f287b10650d0de44db4cdfbb4949038774f1fec2f139810696a8af`. Frozen source: OSM way `w96665918`, v6, `2018-01-22T18:56:14Z`, from `treasure-island-2026-08-27.osm` SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`; tags `addr:housenumber=1310`, `addr:street=Gateview Avenue`, `building=residential`, `building:levels=2`, `height=6`. No proper name exists in the frozen source.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96665918` / `building:w96665918:wall` / `building:w96665918:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-1` |
| Mass | area `660.831 m²`; height `6 m`; NAVD88 base/top `2.365 / 8.365 m` |
| Perimeter | serialized `167.294 m`; visible `167.298 m`; `36` runs |
| Facing-run partition | ENE `62.9–63.1°`: `0–1,4–5,8,11,13–14,17–19,22–23,34`; SSE `152.9–153.2°`: `6–7,12,15–16,32–33,35`; WSW `243.0°`: `26,28–31`; NNW `333.0–333.1°`: `2–3,9–10,20–21,24–25,27` |
| Source / wall geometry SHA-256 | `d67d96717d85f97c75bfdd19bfc705c365d5b9193ce071364a5629634fec5d18` / `68bc257267e9b767a7b074525bff17c6f8f02afb5cf460eb0a53ecefce097daa` |
| Registry record / chunk SHA-256 | `0707ad0f21afc8f790b4522515075be7a0b573da2c06429a8a9fc4af229eba64` / `6de57eb30f5771f43b33d7b71b53952be5ea6ec17706102be634a781152a3ee2` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483573 / 725364`, point `37.8246994,-122.3767444` identifies the current civic address on parcel `1939001`, with source `SF DBI` and `data_as_of=2026-09-03T18:00:54`. That administrative row does not prove tenancy, legal status, survival after the panorama date, or an unchanged facade.

- [March 2025 pano `02izc7_xckWwh6ehnVv6Tw`](https://www.google.com/maps/@?api=1&map_action=pano&pano=02izc7_xckWwh6ehnVv6Tw&heading=76.9&pitch=0&fov=75), camera `37.8248133,-122.3770704`, direct centroid ray `76.9°` at about `18.7 m`: supports the WSW-facing family. The provider's 1311 Gateview label is a neighbor and is excluded from target identity.

Written observation: a two-storey white horizontal-sided WSW front with a low roof/parapet band, three upper bays including a boarded center opening, and a broad shallow-gabled porch/carport on thin posts. Multiple colored doors sit beneath the shelter; a blank white end wing remains subordinate.

## Recognition boundary and handoff

Minimum cue: **white WSW front, boarded center upper bay, and broad thin-post gabled porch/carport**. Close confusion: 901 Avenue B/B1304, 905 Avenue B/B1302, B1308, and other B1301–B1316 legacy rows. Share the white-siding, trim, low-roof, boarding, door, and post-canopy kit with the Avenue B cohort; keep B1310's three-bay upper arrangement and canopy proportions local. Prototype/component blocker: **none for a detached WSW-side study; unobserved returns and exact canopy-to-wall offsets need receiver-relative preflight**. Hidden sides, exact module endpoints, interiors, occupancy, and post-capture changes remain unknown. No panorama pixels are retained or proposed as texture inputs.

Shared sources, lifecycle caveats, registry-role boundary, and rights boundary: [D9 index](README.md).

# D10 source packet — 849 Avenue D candidate (`w96665924`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Packet-time catalog/registry provenance: catalog `ti.facade-recognition-catalog/4`, SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`; D10 packet-time registry snapshot `ti.facade-runtime-registry/4`, SHA-256 `dce268c1547e4e4620faff9d59110ee1214a9a2121c1f83b3eb1c865339360ab`. Frozen source: OSM way `w96665924`, v6, `2020-01-20T07:56:09Z`, from `treasure-island-2026-08-27.osm` SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`; tags `building=yes`. No proper name exists in the frozen source. No frozen street address exists.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96665924` / `building:w96665924:wall` / `building:w96665924:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-1__z_-1` |
| Mass | area `656.394 m²`; height `6 m`; NAVD88 base/top `3.138 / 9.138 m` |
| Perimeter | serialized `124.175 m`; visible `124.175 m`; `15` runs |
| Facing-run partition | ENE `62.3°`: `0–2,12`; SSE `152.3–152.4°`: `10–11,13–14`; WSW `242.3°`: `5–7,9`; NNW `332.2–332.3°`: `3–4,8` |
| Source / wall geometry SHA-256 | `d9007f6aa0609b1e07e666c4787597aef0163a80521f47f8d3e9417412757a21` / `2222b7df693453531dcac5b9f18dcf96bdb52d5547fb22496e9f149c5f0ed4e3` |
| Registry record / chunk SHA-256 | `b028b4cd761fa2b5bef52b98264a76c80e63cc6d230fc322988f190645f6444e` / `5e3b7efb7a2c61e1092c6a42ca9c04212c7d2603890b7a3f4c5e46777005f17b` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is opaque, colliding, and non-spray. Facing runs are exact outward-normal partitions, not an inferred opening schedule.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `484739 / 727914`, point `37.8252314,-122.3738424`, is the nearest civic record at about `3.6 m`: 849 Avenue D on parcel `1939001`, direct source `SF DBI`, `data_as_of=2026-09-03T18:00:54.000`. `CITY-XWALK` associates Building 157 with 849 Avenue D and a fire-station commonplace label, but a different frozen receiver (`w764313741`) carries the explicit Fire Station 48 identity. Therefore 849 Avenue D is only a candidate civic association here; no proper name or fire-station identity is transferred to this target.

- [March 2025 pano `kYOAD0aQ2yPeMTQe_OLvfQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=kYOAD0aQ2yPeMTQe_OLvfQ&heading=239.2&pitch=0&fov=75), camera `37.8254029,-122.3735363`, direct centroid ray `239.2°` at about `35.4 m`: supports the ENE-facing family.

Written observation: an irregular compound with a weathered off-white/light-gray two-storey garage-front mass, blue trim and multiple garage doors, attached to a black horizontal-clad stepped volume; fencing and an open yard interrupt the base. A 2019 view shows the same broad mass relationship, while temporary fence branding and vehicles are excluded from identity.

## Recognition boundary and handoff

Minimum cue: **off-white garage-front mass, blue trim/door rhythm, and adjacent black stepped horizontal-clad volume**. Close confusion: nearby light industrial/utility compounds and the separately bound Fire Station 48 receiver. Share neutral siding, dark-cladding, garage-door, trim, and weathering modules, but keep the two-tone stepped composition and blue garage rhythm entity-specific. Prototype/component blocker: **none for a detached ENE-side massing/material study; exact door endpoints behind fences and vehicles require receiver-relative matching**. Hidden sides, current use, legal identity, exact module endpoints, interiors, and post-capture changes remain unknown. No panorama pixels are retained or proposed as texture inputs.

Shared sources, capture/currentness caveats, packet-time/current registry split, and rights boundary: [D10 index](README.md).

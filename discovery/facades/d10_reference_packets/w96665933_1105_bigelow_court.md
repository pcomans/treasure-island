# D10 source packet — 1105 Bigelow Court (`w96665933`)

Checked: **2026-09-04**  
Readiness: **appearance-blocked**

Packet-time catalog/registry provenance: catalog `ti.facade-recognition-catalog/4`, SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`; D10 packet-time registry snapshot `ti.facade-runtime-registry/4`, SHA-256 `dce268c1547e4e4620faff9d59110ee1214a9a2121c1f83b3eb1c865339360ab`. Frozen source: OSM way `w96665933`, v4, `2020-07-09T13:50:42Z`, from `treasure-island-2026-08-27.osm` SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`; tags `addr:housenumber=1105`, `addr:street=Bigelow Court`, `building=yes`, `height=6`. No proper name exists in the frozen source.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96665933` / `building:w96665933:wall` / `building:w96665933:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-2` |
| Mass | area `590.782 m²`; height `6 m`; NAVD88 base/top `2.539 / 8.539 m` |
| Perimeter | serialized `145.749 m`; visible `145.751 m`; `18` runs |
| Facing-run partition | NNE `16.3°`: `0,7,15–16`; ESE `106.3°`: `10–11,13–14,17`; SSW `196.2–196.3°`: `2,9,12`; WNW `286.2–286.3°`: `1,3–6,8` |
| Source / wall geometry SHA-256 | `25911feb085c29ed10b1a1e43c3f0a5de74e53cc096c8b56e243bdee5eaf93b9` / `184757a1dc87d5f562a1d75f759de356ecdc48dc01aa0ed544acc867df5b4727` |
| Registry record / chunk SHA-256 | `9f6aac16b455cd721b7506c36844da4cfe02371ae4ea4d332e82fed3b65f00bb` / `3a07310461da7d9e76667412c6ca18dac8bdea89923cd8392436421882132ef9` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is opaque, colliding, and non-spray. Facing runs are exact outward-normal partitions, not an inferred opening schedule.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483599 / 725390`, point `37.8271587,-122.3760075`, supports the 1105 Bigelow Court civic address on parcel `1939001`, direct source `SF DBI`, `data_as_of=2026-09-03T18:00:54.000`. It is identity evidence only.

- [February 2018 pano `l2kgtZj_Z8NONagHyClybQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=l2kgtZj_Z8NONagHyClybQ&heading=193.2&pitch=0&fov=75), camera `37.8277180,-122.3759766`, direct centroid ray `193.2°` at about `59.2 m`: the exact 1107 footprint lies between the camera and 1105, so the visible facade cannot be attributed to this target.

Written observation: no facade plane, opening cadence, entry, roof profile, or material field can be confidently assigned to 1105 from the returned public imagery. Neighbor appearance is not transferred.

## Recognition boundary and handoff

Minimum cue: **none frozen; the intercepted sightline is not a recognizer**. Close confusion: 1107 Bigelow and nearby gray Site 12 rows. No entity-specific facade module is authorized; a generic neighbor housing kit may not substitute for target evidence. Prototype/component blocker: **appearance is blocked; obtain one rights-clear dated target-side image or a closer unobstructed public panorama before detached prototype work**. All exterior appearance beyond frozen massing, every opening schedule, lifecycle, occupancy, interiors, and post-capture changes remain unknown. No panorama pixels are retained or proposed as texture inputs.

Shared sources, capture/currentness caveats, packet-time/current registry split, and rights boundary: [D10 index](README.md).

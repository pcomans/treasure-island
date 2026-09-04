# D9 source packet — 1109 Keppler Court (`w96665915`)

Checked: **2026-09-04**  
Readiness: **component/upper-side material study ready**

Catalog/registry provenance: catalog `ti.facade-recognition-catalog/4`, SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`; D9 packet-time registry snapshot and separately checked current registry `ti.facade-runtime-registry/4`, SHA-256 `acc04aa840f287b10650d0de44db4cdfbb4949038774f1fec2f139810696a8af`. Frozen source: OSM way `w96665915`, v5, `2020-07-09T13:50:42Z`, from `treasure-island-2026-08-27.osm` SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`; tags `addr:housenumber=1109`, `addr:street=Keppler Court`, `building=residential`, `building:levels=2`, `height=6`. No proper name exists in the frozen source.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96665915` / `building:w96665915:wall` / `building:w96665915:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-2` |
| Mass | area `479.077 m²`; height `6 m`; NAVD88 base/top `2.131 / 8.131 m` |
| Perimeter | serialized `109.773 m`; visible `109.774 m`; `12` runs |
| Facing-run partition | NNE `17.3°`: `0–3`; ESE `107.0–107.3°`: `7,11`; SSW `197.3°`: `6,8–10`; WNW `287.3°`: `4–5` |
| Source / wall geometry SHA-256 | `2c6626e1b8c9522bcaf2dbac85b26b345c582264c2e03241f4322dbe6a947292` / `d38ecaf5bfe8f72ba38ec8f797aa987cda505dbd0bba6e740bda7aba599b436f` |
| Registry record / chunk SHA-256 | `cb056a45ba9616f9c7797dcef067cb28d182e9153139741c40484674725fc379` / `3a07310461da7d9e76667412c6ca18dac8bdea89923cd8392436421882132ef9` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483556 / 725347`, point `37.8277353,-122.3766076` identifies the current civic address on parcel `1939001`, with source `SF DBI` and `data_as_of=2026-09-03T18:00:54`. That administrative row does not prove tenancy, legal status, survival after the panorama date, or an unchanged facade.

- [February 2018 pano `l2kgtZj_Z8NONagHyClybQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=l2kgtZj_Z8NONagHyClybQ&heading=188.2&pitch=0&fov=75), camera `37.8277180,-122.3759766`, direct centroid ray `188.2°` at about `20.5 m`: supports the NNE-facing family. The provider's 1161 13th Street label is not the target and is excluded.

Written observation: dense mature trees permit only fragments of a two-storey gray/taupe horizontal-sided upper wall, pale window trim, a shallow roof edge, and isolated rectangular windows. The lower side and almost all cadence are hidden.

## Recognition boundary and handoff

Minimum cue: **tree-screened gray/taupe upper siding with pale-trimmed rectangular windows**. Close confusion: 1111/1113/1115/1117 Keppler and nearby Mason/Hutchins rows. Authorize the tileable siding, trim, roof-edge, and window components only; 1111's yellow doors and neighboring schedules do not transfer. Prototype/component blocker: **dense tree cover blocks a complete NNE side, entrance, and lower facade; only the observed upper material/window fragment is ready**. Hidden sides, exact module endpoints, interiors, occupancy, and post-capture changes remain unknown. No panorama pixels are retained or proposed as texture inputs.

Shared sources, lifecycle caveats, registry-role boundary, and rights boundary: [D9 index](README.md).

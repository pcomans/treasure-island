# D10 source packet — unaddressed Avenue H-area building (`w96698650`)

Checked: **2026-09-04**  
Readiness: **appearance-blocked**

Packet-time catalog/registry provenance: catalog `ti.facade-recognition-catalog/4`, SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`; D10 packet-time registry snapshot `ti.facade-runtime-registry/4`, SHA-256 `dce268c1547e4e4620faff9d59110ee1214a9a2121c1f83b3eb1c865339360ab`. Frozen source: OSM way `w96698650`, v4, `2018-01-22T18:55:36Z`, from `treasure-island-2026-08-27.osm` SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`; tags `building=abandoned`, `height=4`. No proper name exists in the frozen source. No frozen street address exists.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96698650` / `building:w96698650:wall` / `building:w96698650:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_1__z_-1` |
| Mass | area `843.707 m²`; height `4 m`; NAVD88 base/top `3.828 / 7.828 m` |
| Perimeter | serialized `170.699 m`; visible `170.698 m`; `28` runs |
| Facing-run partition | ENE `62.9°`: `0–2,10–11,25`; SSE `152.9°`: `23–24,26–27`; WSW `242.9°`: `5–7,16–18,20–22`; NNW `332.9–333.0°`: `3–4,8–9,12–15,19` |
| Source / wall geometry SHA-256 | `98a2f62b6e126c0d3c3ecb008b2b578d0de96787b150f7fa7ad454285f585591` / `335886a78c20b2aa36d46385a0ae76a1b0ce259a22344cad7d59d7e932515bf4` |
| Registry record / chunk SHA-256 | `5b860e12f5e26f3f87ff6069ad536421867daf24a18f93cab6c95d63f27bac62` / `a952756b1c6d8d547669dffb89723c2be81d6c9a4b3afd2ae7f2dc3702a82b0d` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is opaque, colliding, and non-spray. Facing runs are exact outward-normal partitions, not an inferred opening schedule.

## Identity, lifecycle, and public-side appearance

No safe `CITY-EAS` or `CITY-XWALK` footprint binding was found; the nearest current address candidate is roughly `154 m` away. Frozen `building=abandoned` is a source-time lifecycle tag, not a present-condition claim. No address, name, use, or occupancy is inferred.

- [March 2025 pano `og_HDkJ_JMY_Hyw4OxwdWg`](https://www.google.com/maps/@?api=1&map_action=pano&pano=og_HDkJ_JMY_Hyw4OxwdWg&heading=240.3&pitch=0&fov=75), camera `37.8241584,-122.3662141`, direct centroid ray `240.3°` at about `64.5 m`: the view is intercepted by a green corrugated fence, trees, and unassignable roof fragments.

Written observation: no facade plane, material field, opening cadence, entry, or roof form can be confidently attributed to this target. The distant roof fragments do not authorize a component.

## Recognition boundary and handoff

Minimum cue: **none frozen; fence and tree context is not a recognizer**. Close confusion: nearby Avenue H industrial/utility structures and any roof fragments behind the fence. No target facade family or entity-specific module is authorized from this evidence. Prototype/component blocker: **appearance is blocked; obtain a rights-clear dated target-side image or closer unobstructed public capture before prototype or component work**. Address, proper name, exterior appearance, lifecycle, current survival, all openings, interiors, occupancy, and post-source changes remain unknown. No panorama pixels are retained or proposed as texture inputs.

Shared sources, capture/currentness caveats, packet-time/current registry split, and rights boundary: [D10 index](README.md).

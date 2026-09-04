# D5 source packet — 1301 Gateview Avenue (`w95934136`)

Checked: **2026-09-04**  
Readiness: **appearance-blocked; identity and receiver contract are ready**

Catalog provenance: `ti.facade-recognition-catalog/3`, checked 2026-09-04,
SHA-256 `0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0`.
Frozen source: OSM way `w95934136`, v6, `2018-08-12T03:45:25Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1301`, `addr:street=Gateview Avenue`,
`building=apartments`, `height=6`.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w95934136` / `building:w95934136:wall` / `building:w95934136:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-1` |
| Mass | area `500.190 m²`; height `6 m`; NAVD88 base/top `2.972 / 8.972 m` |
| Perimeter | serialized `121.665 m`; visible `121.664 m`; `24` runs |
| Facing-run partition | WSW `242.6–242.9°`: `0–1,3–4,6,17`; NNW `332.8–332.9°`: `2,13–14,16,18,20,23`; SSE `152.9°`: `5,7–10`; ENE `62.8–62.9°`: `11–12,15,19,21–22` |
| Source / wall geometry SHA-256 | `faab56db785d6e817ef472320aa7700083fd8011e7ae707e021e982920ec6490` / `b7e44b1bfd7925be3180d34910c8d07599840c9c2215598fa591c7d818866f1c` |
| Registry record / chunk SHA-256 | `c39b3284d89e1e7a222156d4617ca9cab054d924e0009d8bbca658947c60c453` / `6de57eb30f5771f43b33d7b71b53952be5ea6ec17706102be634a781152a3ee2` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is an
opaque, colliding, non-spray receiver.

## Identity, lifecycle, and appearance evidence

The frozen address is supported by `CITY-XWALK`, whose current value is `1301
GATEVIEW AV`. No matching live `CITY-EAS` base-address row was recovered.
`TIDA-JSCO-2026` includes 1301 Gateview as of 2025-07-01. This establishes a
useful identity/lifecycle trail, not survival, occupancy, or appearance.

- [March 2025 pano `aF5PPnLG2uEHEJ9GA_GaaQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=aF5PPnLG2uEHEJ9GA_GaaQ&heading=83&pitch=0&fov=75), camera `37.8237599,-122.3763305`, heading `83°`: direction toward the target WSW family at roughly 73 m, but the nearer 1303 row materially occludes and merges with the target. No opening, color, or canopy cadence from this view is assigned to `w95934136`.

Unknown: all target-specific public-side appearance, current survival after the
administrative references, alterations, and occupancy. A closer
user-contributed panorama was excluded; no panorama pixels are retained.

## Recognition boundary and handoff

Close confusion: 1303, 1305, 1307, and the opposite Gateview row. The target
may share only a future neutral, tileable siding/roof family; it may not inherit
1303's blue-gray siding, window rhythm, or canopy schedule. Prototype blocker:
**recover a dated, rights-clear view/elevation that visibly separates an exact
`w95934136` side from 1303 and the other rows**.

Shared sources, lifecycle caveats, and rights boundary: [D5 index](README.md).

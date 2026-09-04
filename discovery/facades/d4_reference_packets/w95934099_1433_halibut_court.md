# D4 source packet — 1433 Halibut Court (`w95934099`)

Checked: **2026-09-04**  
Readiness: **historical target-side prototype-ready for the frozen snapshot; current facade absent**

Catalog provenance: `ti.facade-recognition-catalog/3`, SHA-256
`0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0`.
Frozen source: OSM way `w95934099`, v4, `2020-07-09T13:50:42Z`, frozen-file
SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
`1433 Halibut Court`, `building=yes`, `height=6`.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w95934099` / `building:w95934099:wall` / `building:w95934099:roof` |
| Relationship / chunk | standalone direct; no part child; `x_-2__z_-1` |
| Mass | area `475.418 m²`; height `6 m`; NAVD88 base/top `2.780 / 8.780 m` |
| Perimeter | serialized / visible `110.818 / 110.818 m`; `22` runs |
| Facing-run partition | WSW `243.8–243.9°`: `0–3,5,16`; SSE `153.9–154.0°`: `4,6–8,11–12`; ENE `63.8–63.9°`: `9–10,13–14,18–19`; NNW `333.9°`: `15,17,20–21` |
| Source / wall geometry SHA-256 | `abc4bd4ea56ebab758105988733664ef1e791cd96aa78c174e25d5f5613c9b04` / `a41bff6d06d4cba626180184385123ec31e6e55e465d83b81de4cb7d3203474c` |
| Registry record / chunk SHA-256 | `883e3c991baa8a18ab8504d567e88695c3ad4fb97b6e1c2a2091a74a12da70e1` / `6de57eb30f5771f43b33d7b71b53952be5ea6ec17706102be634a781152a3ee2` |
| Current neutral materials | wall `building_wall` / `plaster_grey_04`; roof `building_roof` / `bitumen` |

## Identity, lifecycle, and appearance evidence

`CITY-EAS` record `725355` is `1433 HALIBUT CT`, parcel `1939001`, point
`37.824601921,-122.374947337`, matching the frozen exact address.

- [April 2019 pano `iR9ORV9MD29o9MsEIekpgQ`](https://www.google.com/maps/@?api=1&map_action=pano&pano=iR9ORV9MD29o9MsEIekpgQ&heading=160&pitch=0&fov=75), camera `37.8248433,-122.3749107`, heading `159.96°`: front NNW association, runs `15,17,20–21`. Written observation: asymmetric visible end wings, two exterior stairs, garage banks, cream/tan fields, a lighter brick-like lower band, sparse openings, and a muted-brown shallow roof.
- [March 2025 pano `iGnzDHJqM7rE6XpbzW62sw`](https://www.google.com/maps/@?api=1&map_action=pano&pano=iGnzDHJqM7rE6XpbzW62sw&heading=160&pitch=0&fov=75), camera `37.8248479,-122.3748757`, heading `159.96°`: the target footprint is cleared.

Unknown: complete garage/opening order, lower-band material, stair scale, hidden
sides, demolition date, and changes after April 2019. No panorama pixels are
retained.

## Recognition boundary and handoff

Minimum historical cue: **asymmetric end-wing/garage read, twin stairs, and
lighter lower band beneath a tan field**. Confusion: 1430, 1432, 1434, 1435
Halibut and the neighboring 475 m² rows. A detached historical NNW study is
unblocked; do not regularize it into the more symmetric 1434/1435 schedules.
Neutral fields may target tileability; complete openings and stairs remain
local. Current state is cleared. Shared sources: [D4 index](README.md).

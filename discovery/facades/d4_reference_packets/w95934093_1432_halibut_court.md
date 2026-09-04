# D4 source packet — 1432 Halibut Court (`w95934093`)

Checked: **2026-09-04**  
Readiness: **historical target-side prototype-ready for the frozen snapshot; not a current-building claim or live-attachment approval**

Catalog provenance: `ti.facade-recognition-catalog/3`, checked 2026-09-04,
SHA-256 `0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0`.
Frozen source: OSM way `w95934093`, v4, `2020-07-09T13:50:42Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1432`, `addr:street=Halibut Court`, `building=yes`,
`height=6`.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w95934093` / `building:w95934093:wall` / `building:w95934093:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-1` |
| Mass | area `475.327 m²`; height `6 m`; NAVD88 base/top `2.771 / 8.771 m` |
| Perimeter | serialized `110.807 m`; visible `110.809 m`; `18` runs |
| Facing-run partition | WSW `243.7°`: `0–1,7–8,16`; SSE `153.6–153.7°`: `2,5–6,9`; ENE `63.6–63.7°`: `3–4,10–11,13`; NNW `333.6–333.8°`: `12,14–15,17` |
| Source / wall geometry SHA-256 | `e160396de444bf3594c7a42e351d8cdf5138794a31af46a4988927f67fd5c6b8` / `e82e7552b3dfdd924421890749e5a9becfbd39ecfcd0b4b4a171e209d6d98bc8` |
| Registry record / chunk SHA-256 | `3ab1d59a22a408e839a0be41227953ebd03e8e218b7fb281c2c3bce539fc5cf1` / `6de57eb30f5771f43b33d7b71b53952be5ea6ec17706102be634a781152a3ee2` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

## Identity, lifecycle, and appearance evidence

`CITY-EAS` record `725354` is `1432 HALIBUT CT`, parcel `1939001`, point
`37.824890057,-122.375167279`; this agrees with the frozen exact address but
does not prove survival. `MOHCD-AMR-2025` retains “Halibut Court / 1432 Halibut
Ct” administratively, also not survival evidence.

- [April 2019 pano `jkNuxefU6_JE_YO8WfTmLA`](https://www.google.com/maps/@?api=1&map_action=pano&pano=jkNuxefU6_JE_YO8WfTmLA&heading=341&pitch=0&fov=75), camera `37.8248000,-122.3750126`, heading `340.65°`: target-bound front/SSE association, runs `2,5–6,9`. Written observation: two pale projecting garage wings, three garage openings visible on the left and at least two on the right, a blush central connector, two exterior stairs, red-brick low/pier accents, sparse punched openings, and shallow hip/gable roof forms.
- [March 2025 pano `GFDx8QZuMSgxZWh8jELd9Q`](https://www.google.com/maps/@?api=1&map_action=pano&pano=GFDx8QZuMSgxZWh8jELd9Q&heading=341&pitch=0&fov=75), camera `37.8248050,-122.3749779`, heading `340.65°`: the target footprint is a cleared pad; no standing facade remains.

Unknown: exact opening widths, right garage count, stair landing dimensions, roof
pitch, hidden WSW/ENE/NNW schedules, post-2019 alterations, and demolition date
remain unknown. No panorama pixels are retained.

## Recognition boundary and handoff

Minimum historical recognition cue: **paired projecting garage/end wings plus
the two-stair central connector and brick-base accents**. Close confusion:
1430, 1433, 1434, and 1435 Halibut Court and the Flounder/Sturgeon rows. A
detached SSE study may use tileable pale plaster and roof fields with complete
garage/stair/brick modules; it may not copy another row's opening schedule or
wrap observations onto other orientations. Prototype blocker: **none for the
historical SSE study**. Current facade state: **absent as of March 2025**.

Shared sources and rights boundary: [D4 index](README.md).

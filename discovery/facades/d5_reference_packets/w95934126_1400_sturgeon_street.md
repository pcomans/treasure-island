# D5 source packet — 1400 Sturgeon Street (`w95934126`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready; detached study only**

Catalog provenance: `ti.facade-recognition-catalog/3`, checked 2026-09-04,
SHA-256 `0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0`.
Frozen source: OSM way `w95934126`, v4, `2020-07-09T13:50:42Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1400`, `addr:street=Sturgeon Street`, `building=yes`,
`height=6`.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w95934126` / `building:w95934126:wall` / `building:w95934126:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-2` |
| Mass | area `475.479 m²`; height `6 m`; NAVD88 base/top `2.403 / 8.403 m` |
| Perimeter | serialized `110.830 m`; visible `110.828 m`; `16` runs |
| Facing-run partition | SSW `195.7°`: `0–1,3–4,6`; ESE `105.7°`: `2,7,9`; WNW `285.7°`: `5,12,15`; NNE `15.6–15.7°`: `8,10–11,13–14` |
| Source / wall geometry SHA-256 | `b8990c7b00488f8f512f83b42a65884ce7877b4b25e695afe7fbf7378215e307` / `3fc69d96194d967faeab401e1cdb0d6ec333aa92a9cf5fa0d04bff8a7de042e4` |
| Registry record / chunk SHA-256 | `9cf920d78847e19fc6bd24a36ce3d2004171abe401a0f963b1056382323dc056` / `3a07310461da7d9e76667412c6ca18dac8bdea89923cd8392436421882132ef9` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is an
opaque, colliding, non-spray receiver.

## Identity, lifecycle, and appearance evidence

`CITY-EAS` record `483495` is `1400 STURGEON ST`, parcel `1939001`, point
`37.8267438497,-122.3768007445`, current in that dataset on 2026-09-03.
`TIDA-JSCO-2026` includes 1400 Sturgeon in its 2025-07-01 managed list. Neither
source establishes occupancy or a facade schedule.

- [November 2025 pano `GmuTsOm1-FO47a4FOWEQHA`](https://www.google.com/maps/@?api=1&map_action=pano&pano=GmuTsOm1-FO47a4FOWEQHA&heading=56&pitch=0&fov=75), camera `37.8266407,-122.3769985`, heading `56°`: target-bound public SSW/WNW corner association at roughly 35 m. Written observation: a pale two-storey end building with a garage bank at the base, sparse upper openings, a shallow gable/hip roof mass, and an exterior-stair/lower-link composition.

Unknown: exact garage and window count, stair geometry, hidden ESE/NNE
schedules, colors under different light, repairs, and occupancy. No panorama
pixels are retained.

## Recognition boundary and handoff

Minimum cue: **corner garage bank under the sparse upper storey plus the
exterior-stair/link silhouette**. Close confusion: 1402 and 1404 Sturgeon and
the paired-wing Flounder/Halibut rows. A target-side study may share tileable
pale plaster and shallow-roof materials, but must derive module endpoints from
this receiver and keep uncertain bays quiet. Prototype blocker: **none for the
observed SSW/WNW corner study**.

Shared sources, lifecycle caveats, and rights boundary: [D5 index](README.md).

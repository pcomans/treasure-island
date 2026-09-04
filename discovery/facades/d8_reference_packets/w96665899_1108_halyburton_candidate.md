# D8 source packet — 1108 Halyburton Court candidate (`w96665899`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready with identity caveat**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.
Frozen source: OSM way `w96665899`, v3, `2018-01-25T19:29:09Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `building=yes`, `height=6`. The source has no address or name.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96665899` / `building:w96665899:wall` / `building:w96665899:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-2` |
| Mass | area `275.084 m²`; height `6 m`; NAVD88 base/top `2.183 / 8.183 m` |
| Perimeter | serialized `79.079 m`; visible `79.077 m`; `8` runs |
| Facing-run partition | NNE `16.5°`: `0–2`; ESE `106.6°`: `7`; SSW `196.5°`: `4–6`; WNW `286.5°`: `3` |
| Source / wall geometry SHA-256 | `f532c4e1f25d228289ef54199354a316944d058b2fb3b0e6c91e7318aecda9bf` / `db557107bebd93cee3bef862b783eafa6a2ce31b55346c8ffda1da5f1963f36e` |
| Registry record / chunk SHA-256 | `fd97107e08c888f7efe39bab1bfe1500587df24c36c06682be3120b748589d74` / `3a07310461da7d9e76667412c6ca18dac8bdea89923cd8392436421882132ef9` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

The Navy's 2015 Site 12 report and the official 2017 housing table identify
1108 Halyburton Court as a four-unit, 5,160-square-foot Site 12 building.
Target position, two-storey mass, and cohort sequence make `w96665899` a strong
1108 candidate, but no checked official map explicitly binds that civic
identity to the frozen OSM way. `TIDA-JSCO-2026` removes 1108 from managed
premises effective early 2026; that is not demolition evidence.

- [March 2025 pano `g7RQ1VJX9aVykXIPpBaiyw`](https://www.google.com/maps/@?api=1&map_action=pano&pano=g7RQ1VJX9aVykXIPpBaiyw&heading=11.7&pitch=0&fov=72), camera `37.8277683,-122.3762328`, direct centroid ray at about `18.8 m`: supports the SSW-facing source-key facade. The provider's `1162 13th` label is excluded.

Written observation: a clear two-storey pale horizontal-sided facade with a
shallow roof and every visible upper/lower opening and door boarded in pale
panels; sparse vertical/downspout rhythm and trees frame the face. This is a
March 2025 boarded-state observation, not a present-tenancy claim.

## Recognition boundary and handoff

Minimum cue: **pale two-storey Site 12 mass with a fully boarded opening grid
and sparse vertical service rhythm**. Close confusion: other offline Site 12
rows, especially compact Hutchins/Mason footprints. Share siding/roof/board
modules, but keep the exact observed boarding cadence source-local and retain
the 1108 identity caveat. Prototype blocker: **none for a source-keyed SSW-side
boarded-state study; exact civic binding remains unresolved**. No panorama
pixels are retained.

Shared sources, lifecycle caveats, and rights boundary: [D8 index](README.md).

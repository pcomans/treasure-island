# D8 source packet — observed Building 33E candidate (`w96665883`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready with identity caveat**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.
Frozen source: OSM way `w96665883`, v3, `2018-01-25T19:29:09Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `building=yes`, `height=4`. The source has no address or name.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96665883` / `building:w96665883:wall` / `building:w96665883:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-2` |
| Mass | area `282.746 m²`; height `4 m`; NAVD88 base/top `2.945 / 6.945 m` |
| Perimeter | serialized `70.654 m`; visible `70.655 m`; `10` runs |
| Facing-run partition | ENE `62.2°`: `0–1`; SSE `152.2°`: `8–9`; WSW `242.2°`: `6–7`; NNW `332.2°`: `2–5` |
| Source / wall geometry SHA-256 | `8006fcaedb5668da496abcb011c6295fc1a28e505587e544ee779b6ee8a5a176` / `d08db3c3325d09939a638aa3994c3140cff982998c20a53342a38b755b072fc6` |
| Registry record / chunk SHA-256 | `10343bd06ac93a9b9286f0f642ca7fca47b0cb1aea968985a9d2117ab11d974d` / `3a07310461da7d9e76667412c6ca18dac8bdea89923cd8392436421882132ef9` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-XWALK` identifies Building 33 / 401 13th Street as the former elementary-
school compound; `CITY-EAS` base/address IDs `483140 / 724651` identify the
compound address. The target itself visibly carries `33E`, making this a strong
observed candidate, but no checked official map explicitly binds OSM
`w96665883` to sub-building 33E. The packet therefore does not canonicalize
that name.

- [March 2025 pano `nCSxWglpB-ykqu4O_qiqzg`](https://www.google.com/maps/@?api=1&map_action=pano&pano=nCSxWglpB-ykqu4O_qiqzg&heading=329.8&pitch=0&fov=70), camera `37.8275870,-122.3744772`, direct centroid ray at about `29.0 m`: supports the SSE-facing family.

Written observation: a small one-storey school-compound wing with cream upper
field, dark horizontal window bands, brick-red lower panels, broad shallow
white eave, a pergola/fenced green enclosure at left, and visible `33E`
marking. A taller dark adjacent mass is not part of this receiver.

## Recognition boundary and handoff

Minimum cue: **low cream 33E-marked wing with dark window ribbons, red lower
panels, and a broad white eave**. Close confusion: other Building 33 school
wings and the adjacent taller school mass. A school-window, cream-panel, and
red-spandrel family is reusable, but the `33E` mark and observed cadence stay
source-local. Prototype blocker: **none for a source-keyed SSE-side study;
official sub-building identity remains unresolved and must stay a caveat**. No
panorama pixels are retained.

Shared sources, lifecycle caveats, and rights boundary: [D8 index](README.md).

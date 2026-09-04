# D8 source packet — 1115 Keppler Court (`w96665887`)

Checked: **2026-09-04**  
Readiness: **component/side-material-and-window study ready**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.
Frozen source: OSM way `w96665887`, v5, `2020-07-09T13:50:42Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1115`, `addr:street=Keppler Court`,
`building=residential`, `building:levels=2`, `height=6`. No proper name exists.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96665887` / `building:w96665887:wall` / `building:w96665887:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-3__z_-2` |
| Mass | area `595.058 m²`; height `6 m`; NAVD88 base/top `2.775 / 8.775 m` |
| Perimeter | serialized `137.230 m`; visible `137.227 m`; `16` runs |
| Facing-run partition | NNE `16.6°`: `0,5–6`; ESE `106.6°`: `10–11,13–15`; SSW `196.7°`: `9,12`; WNW `286.6°`: `1–4,7–8` |
| Source / wall geometry SHA-256 | `fa4c1690c306c756fd1caa183c1b889e79ce4f52ffa7e5740486c196a28fd8a4` / `772ecf8fdcdc7f3bdbc054aa71561f9b61b027d821864d7e2c96f7a43a3bd81d` |
| Registry record / chunk SHA-256 | `477bc32779c4b69ed6adfbff59c166e0e38f720f777f20ad7c3c1808b3ed86e9` / `35bf23d64e860d39c5b79a98be7830f4f477143f7e9490c6739dec0627062d11` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483559 / 725350` identify `1115 KEPPLER CT` on
parcel `1939001`, current in that dataset on 2026-09-03. The official 2017
housing table records eight units and 10,240 square feet. Administrative scale
and management records do not establish occupancy or current facade condition.

- [March 2025 pano `nHhytseTl3GlwxzEToWH2Q`](https://www.google.com/maps/@?api=1&map_action=pano&pano=nHhytseTl3GlwxzEToWH2Q&heading=111.5&pitch=0&fov=72), camera `37.8276108,-122.3774237`, direct centroid ray at about `24.1 m`: bounds a WNW-facing side view. The provider's `1397 Gateview Ave` label is unrelated and excluded.

Written observation: a long two-storey pale gray-green horizontal-sided side,
white trim, mixed upper windows, narrow lower windows, and a low roofline.
Fence and dense tree canopy hide major central/lower zones, so no complete
entry or whole-side cadence can be recovered.

## Recognition boundary and handoff

Minimum cue: **long pale gray-green WNW side, low roof, mixed upper windows,
and narrow lower openings behind fence/trees**. Close confusion: 1111/1113
Keppler and Hutchins rows. Share Site 12 siding, trim, glass, and roof modules;
keep the longer eight-unit mass and only the observed window fragments local.
Component blocker: **tree and fence occlusion make a complete target-side
schedule indefensible**. No panorama pixels are retained.

Shared sources, lifecycle caveats, and rights boundary: [D8 index](README.md).

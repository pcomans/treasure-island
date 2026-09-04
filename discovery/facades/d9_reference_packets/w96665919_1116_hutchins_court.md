# D9 source packet — 1116 Hutchins Court (`w96665919`)

Checked: **2026-09-04**  
Readiness: **target-side historical prototype-ready**

Catalog/registry provenance: catalog `ti.facade-recognition-catalog/4`, SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`; D9 packet-time registry snapshot and separately checked current registry `ti.facade-runtime-registry/4`, SHA-256 `acc04aa840f287b10650d0de44db4cdfbb4949038774f1fec2f139810696a8af`. Frozen source: OSM way `w96665919`, v5, `2020-07-09T13:50:42Z`, from `treasure-island-2026-08-27.osm` SHA-256 `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`; tags `addr:housenumber=1116`, `addr:street=Hutchins Court`, `building=residential`, `building:levels=2`, `height=6`. No proper name exists in the frozen source.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96665919` / `building:w96665919:wall` / `building:w96665919:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-3__z_-2` |
| Mass | area `432.818 m²`; height `6 m`; NAVD88 base/top `2.367 / 8.367 m` |
| Perimeter | serialized `105.024 m`; visible `105.024 m`; `14` runs |
| Facing-run partition | NNE `16.7–16.8°`: `0–1,11–12`; ESE `106.7°`: `9–10,13`; SSW `196.6–196.7°`: `4,8`; WNW `286.7°`: `2–3,5–7` |
| Source / wall geometry SHA-256 | `b705ff0edcde28c162a9ab1e417f4a1c8faa2cdd54447a603ece07d7afbcd81c` / `2ade361f103c17111fb6b1104421cc38773cf2b5532232f41f6b35fa4d13973e` |
| Registry record / chunk SHA-256 | `0f020a700c6962a6e14c60afaa8cf3430def8fdc50a0d01b65191b635b0991c7` / `35bf23d64e860d39c5b79a98be7830f4f477143f7e9490c6739dec0627062d11` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483626 / 725417`, point `37.8282502,-122.3769027` identifies the current civic address on parcel `1939001`, with source `SF DBI` and `data_as_of=2026-09-03T18:00:54`. That administrative row does not prove tenancy, legal status, survival after the panorama date, or an unchanged facade.

- [April 2019 pano `CMZLh3-NbdttreO60g4MCA`](https://www.google.com/maps/@?api=1&map_action=pano&pano=CMZLh3-NbdttreO60g4MCA&heading=297.2&pitch=0&fov=75), camera `37.8284853,-122.3777808`, direct centroid ray `297.2°` at about `22.1 m`: supports the ESE-facing family. The provider's 1135 Mason label is a neighbor and is excluded from target identity.

Written observation: a long two-storey gray-beige horizontal-sided frontage with a shallow gray hipped roof, repeated but locally paired upper windows, yellow/tan recessed entries, and shrub-separated ground bays. Parked cars and clipped trees interrupt the lower band.

## Recognition boundary and handoff

Minimum cue: **long gray-beige ESE row, shallow gray hip, paired upper-window moments, and yellow/tan recessed entries**. Close confusion: 1110/1112/1114/1118 Hutchins and adjacent Mason Court rows. Share gray-beige siding, trim, roof, glass, door, and privacy-bay modules; preserve this long footprint, paired-window moments, and ESE entry rhythm. Prototype/component blocker: **none for a detached historical ESE-side study; vehicle/tree occlusion prevents a survey-grade lower schedule**. Hidden sides, exact module endpoints, interiors, occupancy, and post-capture changes remain unknown. No panorama pixels are retained or proposed as texture inputs.

Shared sources, lifecycle caveats, registry-role boundary, and rights boundary: [D9 index](README.md).

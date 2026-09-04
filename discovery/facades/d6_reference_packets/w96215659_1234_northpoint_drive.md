# D6 source packet — 1234 Northpoint Drive (`w96215659`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready; camera-side label caveat retained**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`. Frozen source: OSM way `w96215659`, v5,
`2020-05-26T19:59:19Z`, from `treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1234`, `addr:street=Northpoint Drive`,
`building=residential`, `building:levels=2`, `height=6`. No source name
exists; the civic address is not promoted to a name.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215659` / `building:w96215659:wall` / `building:w96215659:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-4` |
| Mass | area `489.107 m²`; height `6 m`; NAVD88 base/top `2.361 / 8.361 m` |
| Perimeter | serialized `115.645 m`; visible `115.646 m`; `26` runs |
| Facing-run partition | S `182.2–182.5°`: `0,5–6,12`; W `271.4–273.3°`: `1–4,17–20,22–25`; E `92.4–92.5°`: `7–9,11,13–15`; N `2.5–2.6°`: `10,16,21` |
| Source / wall geometry SHA-256 | `515ad327a3c84cef2558155f5828a37ee0470febf5f10e33b734b7ef69649f12` / `4d6487de96be528968165b34580379d186f4d923253f4b580a1b5ee4f1cbefa4` |
| Registry record / chunk SHA-256 | `bff2042bac03de3f7712cc77fa8de059874008e4eece43634761f2f7523e3890` / `932c924b845a382d746e7900710c0c4e8b7603ab205cb07173ad51933c1341b4` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
an opaque, colliding, non-spray receiver.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` record `483515` is `1234 NORTHPOINT DR`, address ID `725293`,
parcel `1939001`, point `37.8307267,-122.3744350`, current in that dataset
on 2026-09-03. `TIDA-JSCO-2026` lists 1234 as managed premises as of
2025-07-01; inclusion does not prove occupancy.

- [March 2025 pano `T08l1Wn9JTvaqBX2Jowzmg`](https://www.google.com/maps/@?api=1&map_action=pano&pano=T08l1Wn9JTvaqBX2Jowzmg&heading=60.6&pitch=0&fov=75), camera `37.8307178,-122.3745969`, heading `60.6°`: the ray reaches the footprint centroid at about `21.2 m` and exposes W runs `1–4,17–20,22–25`. Google's 1232 label belongs to adjacent/camera-side context and is not used as target identity.

Written observation: two-storey light blue-gray horizontal siding; white
trim; shallow muted roof; one continuous deep flat canopy on slender rusted
posts; repeated upper sliders; ground doors/windows and blue-gray privacy/bin
boxes partly hidden by the canopy and cars. Exact bay count, opening endpoints,
post spacing, hidden sides, alterations, and occupancy remain unknown.

## Recognition boundary and handoff

Minimum cue: **the compact blue-gray Northpoint row behind a continuous deep
flat canopy with visibly weathered slender posts**. Close confusion: 1202
Mariner, 1215 Bayside, and 1248/1395 Gateview. Reuse tileable siding/trim/roof
and the parametric flat-canopy family, but preserve 1234's W-side solid/void
rhythm, canopy extent, weathered-post treatment, and privacy placement.
Prototype blocker: **none for a detached W-side study**. Exact
receiver-relative endpoints and the occluded ground sequence remain required
before live placement. No panorama pixels are retained or proposed as texture
inputs.

Shared sources, currentness caveats, and rights boundary: [D6 index](README.md).

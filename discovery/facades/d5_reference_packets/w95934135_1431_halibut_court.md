# D5 source packet — 1431 Halibut Court (`w95934135`)

Checked: **2026-09-08**
Readiness: **target-side prototype-ready; detached study only**

Catalog provenance: `ti.facade-recognition-catalog/3`, checked 2026-09-04,
SHA-256 `0ce8182fe199add5a34650f09e6fdfffce57ea5fc95ea610658e30530b5eafc0`.
Physical building `physical-building:w95934135` is sourced directly by frozen
OSM way `w95934135`, v4, `2020-07-09T13:50:42Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1431`, `addr:street=Halibut Court`, `building=yes`,
`height=6`.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w95934135` / `building:w95934135:wall` / `building:w95934135:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-1` |
| Mass | area `475.398 m²`; height `6 m`; NAVD88 base/top `2.815 / 8.815 m` |
| Perimeter | serialized `110.848 m`; visible `110.848 m`; `18` runs |
| Facing-run partition | WSW `242.7–242.8°`: `0–1,3–4,13`; SSE `152.8–152.9°`: `2,5,7`; ENE `62.7–62.8°`: `6,8–10,15`; NNW `332.7–332.8°`: `11–12,14,16–17` |
| Source / wall geometry SHA-256 | `034aacffde9a58b3cee515d7fdaeaa17cec4d2baeb6ae7a9d663e7170a39cb6f` / `000140ca7b52bc6433868cb414c977ea973dab8ccb52d4b6ff73b7135af8b590` |
| Registry record / chunk SHA-256 | `c614ecc8b31e37237e2483fdfa7d68f3a0b3d8c53961cb9d41be18736d0549f0` / `6de57eb30f5771f43b33d7b71b53952be5ea6ec17706102be634a781152a3ee2` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is an
opaque, colliding, non-spray receiver.

## Identity and lifecycle evidence

- `verified_fact`: the [exact live City EAS row](https://data.sfgov.org/resource/3mea-di5p.json?address=1431%20HALIBUT%20CT),
  checked 2026-09-08 with `data_as_of=2026-09-07T18:00:50`, is
  `1431 HALIBUT CT`, parcel `1939001`, point
  `37.8245298866,-122.3753657621`, direct source `SF DBI`. Its exact schema
  fields are `eas_baseid=483562` and `eas_address_id=725353`; the earlier packet
  wording incorrectly used the base ID as an undifferentiated EAS record ID.
- `verified_fact`: [TIDA-JSCO-2026](https://media.api.sf.gov/documents/011426_6j_JSCO.pdf)
  includes 1431 Halibut as of 2025-07-01. Managed-list inclusion proves neither
  occupancy nor an unchanged exterior.
- `verified_fact`: a [Five Keys Home Free page](https://www.fivekeyshomefree.org/new-home-for-dinner)
  carrying a 2022 event date identifies the exact `1431 Halibut Court` address
  and states that CityBuild and partners began converting and renovating it
  into a six-plex before the COVID-19 pandemic, with demolition work, painting,
  upgrades, and 12 new trees. The text does not say the whole building was
  demolished and supplies no measured exterior schedule.
- `verified_fact`: an [SFOEWD-hosted program record](https://vimeo.com/449846503)
  independently identifies 1431 Halibut as six attached two-bedroom units and
  describes cleanup/renovation for the Home Free program. It is identity and
  lifecycle corroboration only unless individual frames are separately bound.

## Target-side appearance evidence

- `reference_observation`: [March 2025 panorama
  `hTHzoF_k9oHgamBhDjOfLA`](https://www.google.com/maps/@?api=1&map_action=pano&pano=hTHzoF_k9oHgamBhDjOfLA&heading=130&pitch=0&fov=75),
  camera `37.8246290,-122.3753714`, heading `130°`, provides a direct NNW/WSW
  public-corner view. Written observation: paired garage/gabled end wings; two
  exterior stairs serving the central upper entry; salmon garage doors; pale
  wall fields; an asymmetric white horizontal-sided upper band on the right;
  and a dark muted shallow roof. Vehicles and planting obscure part of the
  center.
- `production_inference`: the NNW/WSW association comes from the recorded
  camera position and frozen receiver orientation, not a surveyed elevation.
  Exact module dimensions, count behind occlusion, stair dimensions, cadence,
  and anchors remain reversible game-art choices and must not be represented as
  measured or as-built.
- `unknown`: exact obscured garage/opening count, hidden SSE/ENE schedules,
  repairs after March 2025, current occupancy, and whether any later exterior
  work occurred. No panorama or program-page pixels are retained.

## Recognition boundary and handoff

Minimum cue: **paired gabled garage wings, two-stair center, salmon doors, and
the right-side white upper siding band**. Close confusion: 1430, 1432, 1433,
1434, and 1435 Halibut and the Sturgeon/Flounder rows. Reusable plaster,
siding, trim, and roof materials are allowed; this asymmetric siding cue and
observed solid/void pattern may not be normalized into a generic neighbor.
Prototype blocker: **none for the observed NNW/WSW corner study**.

Safe next action: build only a detached NNW/WSW hero study, preserve the hidden
faces as neutral/unknown, and require independent art review. This packet does
not authorize live attachment, whole-building completion, or acceptance.

Shared sources, lifecycle caveats, and rights boundary: [D5 index](README.md).

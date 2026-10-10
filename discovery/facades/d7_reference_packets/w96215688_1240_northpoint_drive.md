# D7 source packet — 1240 Northpoint Drive (`w96215688`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`.
Frozen source: OSM way `w96215688`, v5, `2020-05-26T19:59:19Z`, from
`treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1240`, `addr:street=Northpoint Drive`,
`building=residential`, `building:levels=2`, `height=6`. No proper name exists.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215688` / `building:w96215688:wall` / `building:w96215688:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-1__z_-4` |
| Mass | area `490.211 m²`; height `6 m`; NAVD88 base/top `3.075 / 9.075 m` |
| Perimeter | serialized `115.710 m`; visible `115.712 m`; `28` runs |
| Facing-run partition | ENE `75.8–75.9°`: `0–1,3–5,8–9`; SSE `165.9°`: `2,17,26–27`; WSW `255.8–255.9°`: `12–16,18–21,23–25`; NNW `345.8–346.1°`: `6–7,10–11,22` |
| Source / wall geometry SHA-256 | `1904826f3c06692ef5edc5f41cbdceee88ca3257b81eafec13364376aeee1005` / `a2c07e2ceaeb86e3bb1a1728104f59ecb40de26abd37d76a61b84a21da3298ed` |
| Registry record / chunk SHA-256 | `b2613fc00fd36febb9a4e4f7f41c7e347c1c37be00508ebf9a3870fd58d469f0` / `bb21618ff0bc88549e3a600d981880415817747475c2c3a0d368a7da8db4d3ac` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
opaque, colliding, and non-spray.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` base/address IDs `483518 / 725296` identify `1240 NORTHPOINT DR`
on parcel `1939001`, current in that dataset on 2026-09-03. The Navy's 2015
Site 12 table and the TIDA managed-premises exhibit as of 2025-07-01 retain
the address. Neither proves present occupancy or an unchanged facade.

- [March 2025 pano `-TCIAj714sn0M0GhjOh0Lg`](https://www.google.com/maps/@?api=1&map_action=pano&pano=-TCIAj714sn0M0GhjOh0Lg&heading=265.7&pitch=0&fov=75), camera `37.8310379,-122.3728523`, heading `265.7°`: direct centroid ray at about `18.3 m`; supports ENE runs `0–1,3–5,8–9`.

Written observation: a cool-gray horizontal-sided two-storey row with white
trim, shallow gray roof, repeated upper windows, maroon/purple doors, ground
screens, and a deep continuous flat carport canopy on slender posts. Vehicles
and canopy hide lower endpoints. Other sides, exact post/opening cadence,
alterations, and occupancy remain unknown.

## Recognition boundary and handoff

Minimum cue: **cool-gray ENE frontage behind a continuous flat canopy, with
maroon/purple entry rhythm**. Close confusion: 1238/1239/1241 Northpoint and
other canopy-bearing rows. Share tileable siding/trim/roof and the parametric
flat-canopy kit; keep this target's ENE extent, entry/privacy cadence, and plane
steps local. Prototype blocker: **none for a detached ENE-side study**. No
panorama pixels are retained.

Shared sources, lifecycle caveats, and rights boundary: [D7 index](README.md).


## Current whole-family roof/site study — 2026-10-10

L1 complete within scoped game-art limits; L2–5 remain unknown. Existing
housing_site_family reuse retains target mapped15–16,18–21,23–25 and protected
complement, opening schedules and partial carport. Only public_roof/local_ground
changed: complete joined shallow planes/stepped closures and connected lawn to
actual road/paving edges. Roof is solid nonreceiver; source wall alone receives
spray. Pitch, ridge position, lawn width and extent are production inference;
source-footprint representation was checked without an exact-area claim.

March2025 front03 and [north/site04](https://www.google.com/maps/@?api=1&map_action=pano&pano=-beLMMM0walkjEnahL2Rsg&heading=240&pitch=0&fov=90)
were acquired2026-10-10 and remain private outside Git/runtime. Front03 uses the
historical pano above; Google1239 is camera context, not target identity. North
camera37.8312197,-122.3729121/localXZ[-169.013,-830.2375], heading240, projects
to station29.1043/depth11.823. Reference-right is the positive-station end near
source terminal33.25. Current config/source joins govern this study's retained
frontage; historical side labels above do not authorize hidden-side remodeling.
Frozen snapshot2026-08-27 remains authoritative; no reference pixels become textures.

Baseline001, first study00163699 terminal0/91807d and wrong-end study00220548
terminal0/282ad7 are retained. Independent first-study visual REWORK identified
brown front/north ground despite the coherent new whole roof. Study002 expanded
the negative end and did not close that gap. Current study00385289 terminal0/56fe41,
release04c329, adds positive station33..43 through the actual curved-road edge,
subtracting frozen footprints, roads, paths and paving. Final Float32 top winding
is positive/noncollapsed and drape follows actual maxLAND/visibleAREA +25mm.

Independent northpoint_third_family_code, in a separately assigned VISUAL role
independent of both authors, personally compared north against north-site04,
all five available target views, front03 and five baseline/current island pairs:
SCOPED VISUAL PASS. Connected lawn now wraps the uncovered end to the curved
road; complete shallow roof/body/carport remain coherent. Island pairs show no
broad visible regression. North is oblique and east omitted as obscured; protected
rear/end openings remain unobserved, so no all-side/modern/as-built acceptance.
Separate source/CODE and progress review retained these limits.

Current mechanics00215045 terminal0/fc1015, releasec9423b, passed native roof/wall/
support/ground coverage, all four stock approaches, corrected positive-end lawn
out/back, exact opaque source-wall spray and released supported grounded zero
active REST before SAFE. Actual route contacts facets279–282 join the changed
lawn beyond station33.25; old-site route proof was not substituted.
Shared-driver suite00111181 terminal1 is retained: the mandatory broad-span rule
rejected legitimate B3 wall articulation. Source-reviewed preference correction
retains all original mandatory guards and strict1.5m final arrival. B3 ordinary
fit and1236 current combined proof passed. Full-suite00243732 terminal0/79015b
ended ALL TESTS PASS, all49 scored fits and world validation/determinism;
owned/global absence17b417 confirms release. Historical accepted claim and
49 island credits are unchanged; current closure is unpublished work on45abd38.

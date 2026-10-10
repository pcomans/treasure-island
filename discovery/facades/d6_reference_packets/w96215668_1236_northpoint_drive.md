# D6 source packet — 1236 Northpoint Drive (`w96215668`)

Checked: **2026-09-04**  
Readiness: **target-side prototype-ready; frozen abandoned tag and observed board-up preserved**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`. Frozen source: OSM way `w96215668`, v6,
`2020-05-26T19:59:19Z`, from `treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1236`, `addr:street=Northpoint Drive`,
`building=abandoned`, `building:levels=2`, `height=6`. The lifecycle tag
is frozen evidence, not a claim of present legal occupancy state.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215668` / `building:w96215668:wall` / `building:w96215668:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-4` |
| Mass | area `607.854 m²`; height `6 m`; NAVD88 base/top `2.452 / 8.452 m` |
| Perimeter | serialized / visible `143.687 / 143.687 m`; `26` runs |
| Facing-run partition | WSW `243.3–244.2°`: `0–1,6,17,21`; SSE `153.2–153.3°`: `2–3,5,7–9,11–12`; ENE `60.8–65.4°`: `4,10,13–14,19`; NNW `333.2–333.3°`: `15–16,18,20,22–25` |
| Source / wall geometry SHA-256 | `4c1cb8a09d9263a172782b0b468f8b6fbbd99384d5ad231f9ee15ff40fbadb38` / `6b5ee098b1af842e2ee5cfefc3f91dc8e1a50a97740c88d09779542f5d41eed2` |
| Registry record / chunk SHA-256 | `81f3cd7faa00c6ae6aaa11837a7b5131dc68ef9bc3db00cf059533c65ce0b40a` / `932c924b845a382d746e7900710c0c4e8b7603ab205cb07173ad51933c1341b4` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
an opaque, colliding, non-spray receiver.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` record `483516` is `1236 NORTHPOINT DR`, address ID `725294`,
parcel `1939001`, point `37.8312267,-122.3741507`, current in that dataset
on 2026-09-03. 1236 is absent from the `TIDA-JSCO-2026` premises exhibit;
absence is not demolition or occupancy evidence.

- [March 2025 pano `cJEqpTCGTny2oeUcrlPa3w`](https://www.google.com/maps/@?api=1&map_action=pano&pano=cJEqpTCGTny2oeUcrlPa3w&heading=116.2&pitch=0&fov=75), camera `37.8313659,-122.3742946`, heading `116.2°`: the ray reaches the footprint centroid at about `23.9 m` and exposes NNW runs `15–16,18,20,22–25`. Google's 1231 label belongs to adjacent/camera-side context and is not used as target identity.

Written observation: standing two-storey pale blue-gray horizontal-sided row;
white trim; shallow roof; pronounced weathering; many upper and ground
openings covered by flat boarded/secured panels, leaving a markedly solid
public face. The observation corroborates a secured/boarded appearance in
March 2025, but does not prove vacancy, tenancy, condemnation, or present
condition. Exact underlying openings, panel endpoints, hidden sides, later
alterations, and occupancy remain unknown.

## Recognition boundary and handoff

Minimum dated cue: **the unusually solid, weathered Northpoint frontage created
by its broad boarded-opening pattern**. Close confusion: 1227, 1234, and 1239
Northpoint. Reuse tileable siding/trim/roof, but keep high-contrast wear and
complete board panels in nonrepeating local modules; preserve 1236's NNW
board-up rhythm and frozen lifecycle boundary. Prototype blocker: **none for a
detached March-2025 NNW-side study**. Underlying openings and currentness
remain protected; no neighbor schedule may fill them. No panorama pixels are
retained or proposed as texture inputs.

Shared sources, currentness caveats, and rights boundary: [D6 index](README.md).


## Current whole-family shape/site study — 2026-10-10

L1 complete within scoped game-art limits; L2–5 remain unknown. The existing
housing_site_family base, exact source identity, mapped15–16,18,20,22–25 and
protected complement are retained. Only local_ground changed: connected lawn,
footway and parking fit actual LAND/visibleAREA +25mm and subtract roads,
frozen footprints and retained paving. Boarded architecture and roof are unchanged;
extents are production inference, not survey measurements.

March2025 front01 and end-site02 originals remain private outside Git/runtime.
The first pano above uses camera localXZ[-290.578,-846.512], heading116.2;
Google1231 is camera context. [End/site pano](https://www.google.com/maps/@?api=1&map_action=pano&pano=00-N3fPi1WZHZamlYavrRA&heading=180&pitch=0&fov=90),
camera37.8314982,-122.3739857, was recovered once after a retained failed attempt.
No panorama pixels become textures. Frozen snapshot2026-08-27 remains authoritative.

Actual baseline001 and coherent study00226028 terminal0/d47bc1, with runtime
release, supported independent northpoint_fourth_visual scoped PASS: whole body,
roof and connected site are coherent; six target views and five island pairs
were compared with dated originals. Initial study001 parse failure5bbb71 remains
retained; worktree import12800 terminal0/c4637c resolved setup once.
Unknown rear/end openings prevent all-side or whole modern-quality acceptance.

Fit north00137569 and00212578 exited1 with unchanged trim contact and no qualified
wall arrival; active supported released REST before SAFE was retained. They were
not relabeled. A source-proposed pier alone was not movement proof. The general
shared driver now prefers broad native wall candidates while retaining the first
candidate passing every original mandatory descent/capsule/support/strict-center
check. Strict native wall arrival stays1.5m, with stock controls unchanged.
Current mechanics00476827 terminal0/d416a3 and release16758e passed native wall,
roof/support/ground coverage, all four stock approaches, changed-site out/back and
exact opaque source-wall spray; actual north wall distance1.486206m, followed by
supported grounded released zero active REST then SAFE and final arrival.

Full-suite00111181 terminal1/62b798 exposed an overly mandatory same-plane span
check on articulated Building3; that failure and47 then-untested buildings remain
history. Source-reviewed preference correction passed B3 ordinary fit87709
terminal0/66447c and current1236. Full-suite00243732 terminal0/79015b ended
ALL TESTS PASS including all49 scored fits and validation/determinism; global
absence17b417 confirms release. Separate CODE/source and progress reviews passed
the bounded study; no additional recognition credit, whole modern/as-built claim
or publication is supplied. Historical accepted claim remains unchanged.

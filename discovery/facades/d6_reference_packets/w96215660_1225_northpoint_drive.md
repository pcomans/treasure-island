# D6 source packet — 1225 Northpoint Drive (`w96215660`)

Current study update: **2026-10-10** — scoped L1 shape/site complete; L2–5 unknown.
Historical packet checked: **2026-09-04**
Readiness: **component/end-side study ready; detailed long elevations remain appearance-blocked**

Catalog provenance: `ti.facade-recognition-catalog/4`, checked 2026-09-04,
SHA-256 `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311`. Frozen source: OSM way `w96215660`, v5,
`2020-05-26T19:59:19Z`, from `treasure-island-2026-08-27.osm` SHA-256
`3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`;
tags `addr:housenumber=1225`, `addr:street=Northpoint Drive`,
`building=residential`, `building:levels=2`, `height=6`. No source name
exists; the address is not promoted to a name.

## Exact receiver contract

| Field | Exact value |
| --- | --- |
| Logical / wall / roof | `building:w96215660` / `building:w96215660:wall` / `building:w96215660:roof` |
| Relationship / chunk | standalone direct footprint; no part child; `x_-2__z_-3` |
| Mass | area `490.234 m²`; height `6 m`; NAVD88 base/top `2.237 / 8.237 m` |
| Perimeter | serialized `115.758 m`; visible `115.757 m`; `24` runs |
| Facing-run partition | S `182.6–182.8°`: `0,4,19`; E `92.3–94.0°`: `1–3,5–8,10–13`; N `2.6–2.8°`: `9,14–15,21`; W `272.5–272.8°`: `16–18,20,22–23` |
| Source / wall geometry SHA-256 | `38219e26660fd29eff4691565f6ae569d8f139e892819609251198599fc71d27` / `c666f15212385e87ea68b69720d445c4a337ed7e047d7bb78afa8e6c3314c875` |
| Registry record / chunk SHA-256 | `f3ef8909a5fc0666f23c79ea54bd35e7c9fac0249c50d485970ecb4937342b22` / `7426b8fa948fa7bc002d5c114c8d91671743926e7f50a7e4bf937bcdd9e141c5` |
| Current neutral materials | wall key `building_wall`, set `plaster_grey_04`; roof key `building_roof`, set `bitumen` |

The wall is the sole spray receiver and an opaque `world_solid`; the roof is
an opaque, colliding, non-spray receiver.

## Identity, lifecycle, and public-side appearance

`CITY-EAS` record `483503` is `1225 NORTHPOINT DR`, address ID `725281`,
parcel `1939001`, point `37.8301928,-122.3748374`, current in that dataset
on 2026-09-03. 1225 is absent from the `TIDA-JSCO-2026` premises exhibit;
absence is not survival, occupancy, or facade evidence.

- [March 2025 pano `ItRdW8bYgwQNwbFSpnGG_g`](https://www.google.com/maps/@?api=1&map_action=pano&pano=ItRdW8bYgwQNwbFSpnGG_g&heading=210.7&pitch=0&fov=75), camera `37.8306259,-122.3746034`, heading `210.7°`: the target lies about `44.3 m` away. The distant oblique view supports only the N end family `9,14–15,21`; overlapping long rows and nearby canopies cannot be assigned safely.

Target-bound written observation: a two-storey light-sided end with stacked
openings below a shallow roof. The visible long-face rhythm, doors, privacy
pieces, and canopies belong to merged neighboring context and are not assigned.
Exact material value, end opening endpoints, every long-side schedule,
alterations, and occupancy remain unknown.

## Recognition boundary and handoff

This is not enough for a whole target recognition cue. It can seed a **shallow
N-end component study with light siding, white trim, stacked openings, and a
shallow roof**, while keeping all long sides neutral. Close confusion:
1227/1234/1236 and other Northpoint rows. Generic tileable siding/trim/roof
materials may be shared; no neighbor's window, door, canopy, or privacy cadence
may transfer. Blocker for a target-side prototype: **a dated rights-clear close
view/elevation that separates either exact long face of `w96215660`**. No
panorama pixels are retained or proposed as texture inputs.

Shared sources, currentness caveats, and rights boundary: [D6 index](README.md).

## Current whole-shape/site study — 2026-10-10

This addendum supersedes the September long-side appearance blocker only within
the newly observed E/N scope. The historical source packet above remains retained.
Four dated March2025 originals were acquired for the pair and compared with actual
baseline/current gameplay; Apple layout context was inspected with date UNKNOWN.

- [E frontage pano `cZKwwXV0NkUP-bf9I7id5Q`](https://www.google.com/maps/@?api=1&map_action=pano&pano=cZKwwXV0NkUP-bf9I7id5Q&heading=270&pitch=0&fov=90): camera37.8302586,-122.3746273 / localXZ[-319.8327,-723.2483], looking W270°. The ray crosses the exact E wall nearZ-723.25; provider1232 is camera-side context. Painted bay labels include1225. Observed stepped pale gray-blue two-storey row, shallow roof/eaves, pale trim, burgundy entries/privacy pieces, partial deep flat carport, grass islands and concrete entry links/long footway. Cars/canopy hide ground sequence; ends crop.
- Retained March2025 N pano `ItRdW8bYgwQNwbFSpnGG_g`, camera37.8306259,-122.3746034 / localXZ[-317.7311,-764.1359], lookingSW210.7°: exact target is middle/right row, not foreground1227; shallow north gable and lawn/canopy relationship are partly tree-obscured.

Reuse: WorldLoader → housing_family_live_attachment → housing_site_family with
new source-bound w96215660 config, exact wall/roof identity in x_-2__z_-3.
Observed E runs1–3,5–8,10–13 alone receive opening schedules; N9,14,15,21 support
plain envelope/roof rather than invented openings. All other runs remain plain
protected closure; annex/neighbor motifs excluded. Roof rise/join dimensions,
module cadence, canopy endpoints/posts and site extents are production_inference.
Only opaque source walls receive spray; roof/canopy/ground remain nonreceivers.

Study001's brown frontage-to-road gap prompted early visual REWORK. Corrected
study002 derives parking/open-end lawn from actual road boundaries15.4–16.6m
outward and adds a0.95m street-edge footway, clipping against LAND and retained
roads/buildings/paving. Final converted ground winding is checked for both siblings.
Study002 capture38150 terminal0/c666a5 and owned/global absence937fcd preceded
six-original independent review. Combined mechanics21139 terminal0/d83437;
actual out/back/spray rests join ParkingSurface13 and FrontLawn15. East approach
contact was support detail near the qualified wall, not a wall-touch claim.
Ordinary E is distant/partly obscured and N neighbor-dominated; raised contexts
support the scoped assembly, not a complete close-front/all-side fidelity claim.
1225 reference_recognizable stays not_evaluated; no new credit.

Current verification: independent northpoint_third_family_visual scoped PASS
for the complete corrected target set, plus all five before/final island pairs;
separate northpoint_third_family_code corrected CODE and distinct PROGRESS PASS.
Combined shared building_fit_test verified native wall/roof/support/ground roles,
four stock approaches, changed-site out-and-back, exact opaque wall spray and
active grounded supported input-released zero-velocity REST before SAFE.
One full suite28452 terminal0/ae7f99 ended ALL TESTS PASS, all49 scored fits and
Node validation/determinism. Missing pinned local packages were installed through
unchanged-lockfile npm ci before the suite; no test or runtime weakening.
Owned/global runtime absence followed each actual terminal. L1 shape/site C is
supported; L2–5 remain U, modern whole-quality and as-built fidelity unclaimed.
Reference pixels and proof artifacts remain private/outside Git, never textures.
See [stage checklist](../../ISLAND_BUILDING_STAGE_CHECKLIST.md) for current scope.

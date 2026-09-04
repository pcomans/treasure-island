# D9 receiver-first reference packets

Checked: **2026-09-04**

Scope: **the next 15 previously unpacketized standalone physical-building
entities in the stable 213-unit recognition-catalog order; bounded reference
research and reversible art handoff only**

This directory changes no source geometry, generated world, catalog, registry,
runtime material, prototype, or live receiver attachment. Child
`building_part` sources are not counted as physical entities. A ready packet
authorizes only the stated observed-side or component study; it does not
establish recognition, survey fidelity, whole-building completion, current
occupancy, or acceptance.

## Frozen cohort and readiness

The cohort was derived mechanically by walking the stored catalog order after
the 136 unique source IDs covered by P1, P2, P3, and D1–D8. All 15 results are
standalone direct footprints with no part children.

| Order | Unit | Address / bounded identity | Best target-bound evidence | Readiness |
| ---: | --- | --- | --- | --- |
| 1 | [`w96665904`](w96665904_1237_northpoint_drive.md) | 1237 Northpoint Drive | Mar 2025 SW frontage | **target-side prototype-ready** |
| 2 | [`w96665906`](w96665906_1147_ozbourn_court.md) | 1147 Ozbourn Court | Apr 2019 SW mass/upper/enclosures | **target-side historical prototype-ready** |
| 3 | [`w96665907`](w96665907_1129_mason_court.md) | 1129 Mason Court | Apr 2019 NNE/WNW corner fragments | **component/corner-and-entry study ready** |
| 4 | [`w96665908`](w96665908_1203_bayside_drive.md) | 1203 Bayside Drive | Mar 2025 SE end/side | **target-side prototype-ready** |
| 5 | [`w96665909`](w96665909_1149_ozbourn_court.md) | 1149 Ozbourn Court | Apr 2019 SE frontage | **target-side historical prototype-ready** |
| 6 | [`w96665910`](w96665910_1110_hutchins_court.md) | 1110 Hutchins Court | Feb 2018 WNW fragments | **component/side-material-and-window study ready** |
| 7 | [`w96665911`](w96665911_1229_northpoint_drive.md) | 1229 Northpoint Drive | Mar 2025 ESE end/long side | **target-side prototype-ready** |
| 8 | [`w96665912`](w96665912_901_1304_avenue_b.md) | frozen 901/1304; current 901 Avenue B / B1304 | Mar 2025 ENE frontage; exact civic crosswalk | **target-side prototype-ready** |
| 9 | [`w96665915`](w96665915_1109_keppler_court.md) | 1109 Keppler Court | Feb 2018 NNE upper fragments | **component/upper-side material study ready** |
| 10 | [`w96665916`](w96665916_1242_northpoint_drive.md) | 1242 Northpoint Drive | Mar 2025 ENE frontage/canopy | **target-side prototype-ready** |
| 11 | [`w96665918`](w96665918_1310_gateview_avenue.md) | 1310 Gateview Avenue / B1310 | Mar 2025 WSW frontage | **target-side prototype-ready** |
| 12 | [`w96665919`](w96665919_1116_hutchins_court.md) | 1116 Hutchins Court | Apr 2019 ESE frontage | **target-side historical prototype-ready** |
| 13 | [`w96665920`](w96665920_1131_mason_court.md) | 1131 Mason Court | Apr 2019 NNE material/opening fragments | **component/front-material-and-opening study ready** |
| 14 | [`w96665922`](w96665922_1114_hutchins_court.md) | 1114 Hutchins Court | Jan 2023 WNW upper side | **component/upper-side study ready** |
| 15 | [`w96665923`](w96665923_1120_reeves_court.md) | 1120 Reeves Court | Mar 2025 distant fence/tree interception | **appearance-blocked** |

Totals: **9 prototype-ready / 5 component-ready / 1 appearance-blocked**.
Provider labels naming neighbors are explicitly excluded. Readiness instead
depends on an exact OSM centroid sightline plus a visually attributable target
plane. `w96665923` does not meet that threshold.

## Packet-time provenance and current authority

| Input | Version / SHA-256 | Role |
| --- | --- | --- |
| `data/osm/treasure-island-2026-08-27.osm` | `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549` | frozen identity, lifecycle tags, address, and source geometry |
| `discovery/FACADE_RECEIVER_INVENTORY.json` | `ti.facade-receiver-inventory/1`; `0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f` | exact geometry, receiver, material, and run contract |
| D9 packet-time catalog snapshot receipt | `ti.facade-recognition-catalog/4`; `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311` | immutable packet-time provenance; same bytes as the then-current catalog at seal time |
| D9 packet-time registry snapshot receipt | `ti.facade-runtime-registry/4`; `acc04aa840f287b10650d0de44db4cdfbb4949038774f1fec2f139810696a8af` | immutable packet-time provenance; same bytes as the then-current registry at seal time |
| D9 packet-time recognition rollup | `5/213` | immutable five-unit acceptance state at the v4 authority boundary; not a claim about current compiler output |
| `discovery/facades/facade-recognition-catalog.json` (current checkout) | `ti.facade-recognition-catalog/5`; SHA-256 emitted by validator | used only to rederive the exact 15-ID cohort and order |
| `game/resources/facades/facade-runtime-registry.json` (current checkout) | `ti.facade-runtime-registry/5`; SHA-256 emitted by validator | used only to verify those 15 current direct bindings; global counts and recognition rollup remain compiler-owned |
| `generated/world/manifest.json` | `ti.godot-world/2`; `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3` | generated chunk authority |

The `2b4579…` catalog and `acc04a…` registry values in the receipts and sealed
packet headers record the D9 packet-time authorities. Header wording about a
separately checked current registry describes the then-current path at seal
time; it is not a claim about later bytes. The validator preserves those
immutable receipts while separately loading and hashing the current schema-v5
catalog and registry only to rederive the exact D9 cohort order and verify those
15 direct bindings. The historical `5/213` rollup remains part of the seal-time
receipt. Global current unit, receiver, source-membership, acceptance, and
recognition-rollup gates belong solely to
`tools/build_facade_recognition_registry.mjs --check`.

Compass groups are exact outward-normal partitions recomputed from each wall
record. A panorama sightline associates only a visible side family; it does not
turn written observation into exact module endpoints. Receiver-relative
preflight remains mandatory before live placement.

## Validation result

**D9 packet audit: PASS.** The validator re-walks catalog order after all 136
earlier packet IDs, rejects part children, checks singular wall/roof bindings,
recomputes chunk, record, and wall-geometry hashes, reconstructs all facing-run
partitions, validates packet fields/links/readiness, and rejects extra files or
images. It reproduces 15 IDs, 45 hashes, 300 exact packet fields, 60 facing
partitions, 15 links, and readiness `9 / 5 / 1`. Run:

```sh
node discovery/facades/d9_reference_packets/validate_d9_packets.mjs
node tools/validate_godot_world.mjs
```

The historical catalog, registry, and `5/213` receipts remain explicit and
immutable; the current schema-v5 catalog/registry reproduce the exact 15-ID
order and direct bindings. Their moving SHA-256 values are emitted by each
validator run and are not misrepresented as packet-time receipts.

The generated-world validator separately passes with `38` chunks, `739`
source rows, `729` physical objects, and generated content SHA-256
`01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164`.

## Primary, official, and direct-observation sources

| ID | Source | What it supports | Boundary |
| --- | --- | --- | --- |
| `CITY-EAS` | [SF Enterprise Addressing System](https://data.sfgov.org/d/3mea-di5p) and [live API](https://data.sfgov.org/resource/3mea-di5p.json) | exact civic records/points on parcel `1939001`, direct source `SF DBI`, `data_as_of=2026-09-03T18:00:54` | address rows do not prove survival, tenancy, exact facade condition, or an OSM-way crosswalk by themselves |
| `CITY-XWALK` | [SF Updated Treasure Island Addresses and Building Numbers](https://data.sfgov.org/d/ghba-upwh) and [live API](https://data.sfgov.org/resource/ghba-upwh.json) | Building 1304 continuity to current 901 Avenue B Units A–F and separation from B1302/current 905 Avenue B | identity evidence only; not appearance or occupancy evidence |
| `NAVY-SITE12-2015` | [U.S. Navy Site 12 survey report, part 1](https://media.defense.gov/2022/Mar/22/2002960622/-1/-1/0/TI_2015_FINAL_SURVEY_COMPLETION_REPORT_RAD_SCOPING%20SURVEYS_OF_IR_SITE12_HOUSING_UNITS_PART_1OF_9.PDF) and [official catalog](https://www.bracpmo.navy.mil/BRAC-Bases/California/Former-Naval-Station-Treasure-Island/Documents/) | dated Site 12 address/provider context for this housing cohort | a 2015 provider table is not present tenancy, survival, or facade evidence |
| `CITY-HOUSING-2017` | [official housing building-area/unit table](https://sfgov.legistar.com/View.ashx?GUID=0D199683-D3E7-4244-86D7-5F99E90A89A9&ID=3271846&M=F) | dated administrative housing context, floor-area, and unit-count records | gross administrative area does not replace frozen geometry or prove current condition |
| `GOOGLE-SV` | target-bound Google-hosted panorama links in every packet | capture month, camera point, centroid sightline, public-side visibility, and bounded written observation | direct observation only; provider/neighbor labels are not target identity |

Temporary panorama tiles were used only for inspection and removed afterward.
The repository retains **only written observations and provenance**: no
panorama, screenshot, thumbnail, or other third-party pixels are copied,
embedded, trained on, or proposed as textures.

## Reusable families without identity collapse

- Twelve Site 12 gray/pale-blue housing receivers can share a pragmatic
  tileable base kit: low-contrast horizontal siding, white trim, restrained
  glass, shallow neutral/red-brown roofs, doors, privacy boxes, boarding, and
  low-frequency wear. Perfect seams are not a first-pass gate; obvious repeat
  bands, clipped openings, and baked shadows remain unacceptable.
- Doors, windows, downspouts, privacy boxes, utility annexes, canopies,
  boarding, repairs, and local weathering remain complete modules or decals,
  never fragments baked through a repeating siding seam.
- 1242 Northpoint's deep flat canopy, 1229 Northpoint's gable/end annex, 1203
  Bayside's compact gabled corner, 1149 Ozbourn's yellow-door asymmetry, and
  the distinct 1237/1147/1116 cadences stay entity-specific.
- B1304 and B1310 may share a separate white legacy-row kit and parametric
  post-supported gabled porch/carport. Their upper-bay/boarding patterns,
  canopy proportions, and colored-door rhythms must remain local.
- 1129 Mason, 1110 Hutchins, 1109 Keppler, 1131 Mason, and 1114 Hutchins
  authorize only their observed component subsets. No neighbor supplies a
  hidden entry or opening schedule. 1120 Reeves authorizes no facade family.

## Owner-only dependency

There is **no exhausted owner-only dependency** for D9. Nine detached studies
and five bounded component studies can proceed. `w96665923` needs closer,
rights-clear target evidence, but source discovery or future capture is not
inherently owner-only, so it is not added to `HUMAN.md`.

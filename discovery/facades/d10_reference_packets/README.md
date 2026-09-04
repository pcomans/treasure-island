# D10 receiver-first reference packets

Checked: **2026-09-04**

Scope: **the next 15 previously unpacketized standalone physical-building
entities in stable 213-unit recognition-catalog order; bounded reference
research and reversible art handoff only**

This directory changes no source geometry, generated world, catalog, registry,
runtime material, prototype, or live receiver attachment. Child
`building_part` sources are excluded from the physical-unit cohort. A ready
packet authorizes only its stated observed side or component study; it does not
establish recognition, survey fidelity, whole-building completion, present
occupancy, or acceptance.

## Frozen cohort and readiness

The validator mechanically collects the first 15 standalone catalog units not
present among the 151 unique P1–P3 and D1–D9 packet source IDs. They are catalog
positions 137–151 in that remaining standalone sequence. Each is an inventory
`standalone_building_footprint` with a null parent, zero part children, one
wall record, one roof record, and one direct registry facade receiver.

| Order | Unit | Address / bounded identity | Best target-bound evidence | Readiness |
| ---: | --- | --- | --- | --- |
| 1 | [`w96665924`](w96665924_849_avenue_d_candidate.md) | nearest civic 849 Avenue D; identity conflict retained | Mar 2025 ENE-facing irregular compound | **target-side prototype-ready** |
| 2 | [`w96665925`](w96665925_1107_bigelow_court.md) | 1107 Bigelow Court | Feb 2018 NNE upper/material fragments | **component/NNE siding-and-board-up study ready** |
| 3 | [`w96665928`](w96665928_1117_keppler_court.md) | 1117 Keppler Court | Mar 2025 NNE upper-side fragments | **component/NNE upper-side study ready** |
| 4 | [`w96665933`](w96665933_1105_bigelow_court.md) | 1105 Bigelow Court | Feb 2018 sightline intercepted by 1107 | **appearance-blocked** |
| 5 | [`w96665935`](w96665935_1135_mason_court.md) | 1135 Mason Court | Apr 2019 SSW frontage | **target-side historical prototype-ready** |
| 6 | [`w96665936`](w96665936_1128_reeves_court.md) | 1128 Reeves Court | Apr 2019 SE/SW corner | **target-side historical prototype-ready** |
| 7 | [`w96698611`](w96698611_unaddressed_courtyard_building.md) | unaddressed courtyard building | Mar 2025 E-facing upper wall/roof fragments | **component/upper-wall-and-roof study ready** |
| 8 | [`w96698619`](w96698619_1254_625_13th_street.md) | frozen 1254; civic/crosswalk 625 13th Street | Sep 2025 SSE frontage/canopy | **target-side prototype-ready** |
| 9 | [`w96698627`](w96698627_1216_1430_gateview_court.md) | frozen 1216/1430 Gateview Court; civic 1430 Gateview Ave | Mar 2025 ENE frontage | **target-side prototype-ready** |
| 10 | [`w96698634`](w96698634_1253_exposition_drive.md) | 1253 Exposition Drive | Sep 2025 ENE upper/side fragments | **component/upper-side-and-boarded-opening study ready** |
| 11 | [`w96698641`](w96698641_unaddressed_avenue_d_building.md) | unaddressed Avenue D-area building | Jun 2019 SSE facade; current fence conflict | **target-side historical prototype-ready** |
| 12 | [`w96698643`](w96698643_1249_exposition_drive.md) | 1249 Exposition Drive | Mar 2025 SSE frontage | **target-side prototype-ready** |
| 13 | [`w96698645`](w96698645_1214_1420_gateview_court.md) | frozen 1214/1420 Gateview Court; civic point remains ambiguous | Mar 2025 SSE frontage/canopy | **target-side prototype-ready** |
| 14 | [`w96698648`](w96698648_1252_exposition_drive.md) | 1252 Exposition Drive | Mar 2025 ENE frontage/canopy | **target-side prototype-ready** |
| 15 | [`w96698650`](w96698650_unaddressed_avenue_h_building.md) | unaddressed Avenue H-area building | Mar 2025 distant fence-only sightline | **appearance-blocked** |

Totals: **9 prototype-ready / 4 component-ready / 2 appearance-blocked**.
The conservative component classification for `w96698634` is intentional:
its upper side and partial boarding are attributable, while fence/vehicle
occlusion prevents a trustworthy lower-facade schedule. `w96665933` and
`w96698650` authorize no facade prototype or component.

## Packet-time provenance and current binding check

| Input | Version / SHA-256 | Role |
| --- | --- | --- |
| `data/osm/treasure-island-2026-08-27.osm` | `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549` | frozen identity/lifecycle tags and source geometry |
| `discovery/FACADE_RECEIVER_INVENTORY.json` | `ti.facade-receiver-inventory/1`; `0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f` | exact geometry, receiver, material, and run contract |
| D10 packet-time catalog snapshot receipt | `ti.facade-recognition-catalog/4`; `2b457965d2e25d522d2ca3d73afb109b03a57247eaefbb6b70775bd83fb07311` | immutable packet-time provenance; same bytes as the then-current catalog at seal time |
| D10 packet-time registry snapshot receipt | `ti.facade-runtime-registry/4`; `dce268c1547e4e4620faff9d59110ee1214a9a2121c1f83b3eb1c865339360ab` | immutable packet-time provenance; same bytes as the then-current registry at seal time |
| D10 packet-time recognition rollup | `5/213` | immutable five-unit acceptance state at seal time; not a claim about current compiler output |
| D10 packet-time commit | `a37c0c6e16ab7fef3e767c2367024abd3e563091` | immutable repository state at packet seal time |
| `discovery/facades/facade-recognition-catalog.json` (current checkout) | `ti.facade-recognition-catalog/5`; SHA-256 emitted by validator | used only to rederive the exact 15-ID cohort and order |
| `game/resources/facades/facade-runtime-registry.json` (current checkout) | `ti.facade-runtime-registry/5`; SHA-256 emitted by validator | used only to verify those 15 current direct bindings; global counts and recognition rollup remain compiler-owned |
| `generated/world/manifest.json` | `ti.godot-world/2`; `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3` | generated chunk authority |
| `generated/world/logical-objects.json` | `ti.godot-world/2`; `5a74a80a7930ef8edfbea4f7c3a15a509d38e59b64e55d17a26ea1061137ba11` | serialized footprint/perimeter authority |

The D10 receipts freeze catalog/registry v4, `5/213`, and commit `a37c0c6` as
the packet-time state used to author these packets. At that seal point the
catalog and registry contained 213 physical recognition units, 214 direct wall
receivers, and 215 source memberships; exactly five independently accepted
physical units formed the numerator. Those facts remain immutable historical
provenance, including the Isle House part-source non-numerator boundary.

The current v5 files may move as accepted live replacements are integrated.
This D10 audit therefore rederives only its exact 15 IDs/order from the current
catalog and checks their direct wall bindings against the current registry. It
does not duplicate global current `213/214/215` or recognition-rollup gates;
`tools/build_facade_recognition_registry.mjs --check` is the canonical compiler
oracle for those exact-current global invariants and the recognition rollup.

Compass groups are exact partitions recomputed from stored wall normals. Public
imagery supports only an attributable visible-side family. It never converts a
written observation into exact openings, transfers a neighbor facade, or
overrides the frozen receiver topology. Receiver-relative preflight remains
mandatory before any live placement.

## Validation result

**D10 packet audit: PASS.** The validator re-walks catalog order after 151
unique earlier packet IDs; excludes part children; checks singular wall/roof
bindings; recomputes source-linked wall geometry, full wall-record, and chunk
hashes; reconstructs every facing partition; verifies immutable packet-time
receipts, current v5 cohort order/direct bindings, fields, packet links, source
labels, and readiness counts; and rejects extra files or images. It reproduces
15 IDs, 45 per-target hashes, 300 exact packet fields, 60 facing partitions,
15 packet links, and readiness `9 / 4 / 2`. Run:

```sh
node discovery/facades/d10_reference_packets/validate_d10_packets.mjs
node tools/build_facade_recognition_registry.mjs --check
node tools/validate_godot_world.mjs
```

The generated-world authority remains 38 chunks, 739 source rows, and 729
physical objects. Each D10 run emits the moving current v5 catalog/registry
hashes after confirming this cohort's exact IDs/order/direct bindings. The
registry compiler independently owns current global topology and the recognition
rollup. D10's v4 hashes, `5/213`, and commit receipt remain immutable historical
provenance and must not be rewritten during later reconciliation.

## Primary, official, and direct-observation sources

| ID | Source | What it supports | Boundary |
| --- | --- | --- | --- |
| `CITY-EAS` | [SF Enterprise Addressing System](https://data.sfgov.org/d/3mea-di5p) and [live API](https://data.sfgov.org/resource/3mea-di5p.json) | civic records/points on parcel `1939001`, direct source `SF DBI`, `data_as_of=2026-09-03T18:00:54.000` | address proximity/crosswalk does not itself prove an exact footprint join, survival, tenancy, or facade condition |
| `CITY-XWALK` | [SF Updated Treasure Island Addresses and Building Numbers](https://data.sfgov.org/d/ghba-upwh) and [live API](https://data.sfgov.org/resource/ghba-upwh.json) | historical building-number/current-address continuity where explicitly cited | identity evidence only; no appearance, lifecycle, or occupancy authority |
| `GOOGLE-SV` | target-bound Google-hosted panorama links in each packet | capture month, camera point, centroid sightline, side attribution, and bounded written observation | direct observation only; provider/neighbor labels are excluded from target identity |

Google-hosted thumbnails/tiles were inspected transiently and deleted. The
repository retains **only written observations and provenance**: no panorama,
screenshot, thumbnail, or other third-party pixels are copied, embedded,
trained on, or proposed as texture inputs. Exterior details that could not be
assigned to the exact receiver are reported as blocked.

## Reusable families without identity collapse

- The gray/cream two-storey housing can share a pragmatic tileable kit:
  low-contrast horizontal siding, white trim, restrained glazing, shallow
  neutral/reddish roofs, doors, privacy/utility boxes, boarding, and
  low-frequency wear. Perfect seams are not a first-pass gate; obvious repeat
  bands, clipped openings, and baked shadows remain unacceptable.
- Deep flat canopies at 1254/625 13th, 1420 Gateview, and 1252 Exposition can
  share parametric roof/post pieces. Their depths, run extents, opening
  cadences, door colors, and privacy-box rhythms remain entity-specific.
- 849 Avenue D candidate uses a separate two-tone garage/stepped-volume kit;
  no fire-station identity, sign, neighbor facade, or branded fence treatment
  transfers from another receiver.
- The historical blue/yellow `w96698641` study remains explicitly dated and
  separate from the current fence-only condition. Its detached annex is not
  folded into the receiver.
- 1107 Bigelow, 1117 Keppler, the unaddressed courtyard building, and 1253
  Exposition authorize only their observed component subsets. 1105 Bigelow
  and the unaddressed Avenue H-area building authorize none.

## Owner-only dependency

There is **no exhausted exact owner-only dependency** for D10. Nine detached
studies and four bounded component studies can proceed. The two blocked targets
need closer rights-clear target evidence, but that future research/capture is
not inherently owner-only, so no `HUMAN.md` entry is added.

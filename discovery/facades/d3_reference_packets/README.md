# D3 receiver-first reference packets

Checked: **2026-09-04**

Scope: **the next 15 previously unpacketized physical-building units in the
stable 213-unit catalog order; research and reversible art handoff only**

This directory does not change the frozen OSM source, generated world,
recognition catalog, runtime registry, world builder, prototypes, or live
attachments. `building_part` rows are not counted as separate physical
entities. Every packet separates frozen/generated facts, dated observations,
reversible production guidance, and unknowns.

## Frozen cohort and readiness

The selection was made by walking `facade-recognition-catalog.json` in stored
unit order, excluding every ID already represented by a completed P1, P2, P3,
D1, or D2 packet and excluding child `building_part` sources. The first 15
remaining standalone units are frozen below; none duplicates a prior packet ID.

| Order | Unit | Identity available | Target-bound exterior evidence | Readiness |
| ---: | --- | --- | --- | --- |
| 1 | `w34313515` | source key; unresolved 251 4th / Buildings 365–367 cluster | Sep 2025 WSW + NNW | **target-side prototype-ready** |
| 2 | `w34313520` | source key only | Sep 2025 SSE | **target-side prototype-ready** |
| 3 | `w34313525` | source key; strong Building 260 spatial candidate, not canonicalized | Mar 2025 SSE + NNW/inset | **target-side prototype-ready** |
| 4 | `w34313528` | source key; frozen `building=abandoned` | none | **appearance-blocked** |
| 5 | `w34313535` | source key only | none | **appearance-blocked** |
| 6 | `w34313549` | source key only | none | **appearance-blocked** |
| 7 | `w34313550` | source key only | none | **appearance-blocked** |
| 8 | `w34313554` | source key only | none | **appearance-blocked** |
| 9 | `w34313555` | source key only | none | **appearance-blocked** |
| 10 | `w34313556` | source key only | none | **appearance-blocked** |
| 11 | `w34313557` | source key only | none | **appearance-blocked** |
| 12 | `w34313558` | source key only | none | **appearance-blocked** |
| 13 | `w34313560` | source key only | none | **appearance-blocked** |
| 14 | `w34313564` | high spatial City crosswalk to Building 264 / 751 13th | Sep 2025 SSE + NNW + ENE | **target-side prototype-ready** |
| 15 | `w95934092` | exact 1318 Gateview Avenue | Mar + Nov 2025 front/end + rear | **target-side prototype-ready** |

Totals: **5 prototype-ready / 0 component-ready / 10 blocked** (the blocked
set is specifically appearance-blocked). All 15 have exact source/direct-receiver packets. “Ready”
means a detached, reversible, side-bounded study can begin; it does not mean
recognition acceptance, as-built fidelity, whole-building completion, or live
attachment. No D3 packet authorizes a catalog numerator change.

Validation result: **PASS**. A fresh catalog-order derivation reproduced all 15
IDs exactly after excluding 46 prior packet IDs; all 15 inventory relationships
are standalone with zero part children; 15/15 packets contain the current source
version/timestamp, logical/wall/roof/chunk IDs, source/wall/record/chunk hashes,
and run count; 45 fresh stable-JSON/file comparisons reproduced all 15 wall
geometry, record, and chunk hashes; readiness recomputed to `5 / 0 / 10`; all
local Markdown targets exist. Remote-link behavior is recorded under the source
index below.

## Authoritative local contract

| Input | Checked SHA-256 / role |
| --- | --- |
| `data/osm/treasure-island-2026-08-27.osm` | `3b6f6af31a1c82de3fa51fcbc02fe7e3723fdb629c948ae6523ef46c157b4549`; frozen source |
| `discovery/FACADE_RECEIVER_INVENTORY.json` | `0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f`; source/receiver geometry contract |
| `discovery/facades/BATCH_06_RUN_MAPPING.json` | `0d9ef02bbdf38902bfddb475f96167abd6460163d94c26984ae5b29da0c7497d`; exact mapped scopes for four `w343...` targets |
| `discovery/facades/BATCH_04_RUN_MAPPING.json` | `3ec81316f9bdfb6131df55faeabe822b3fdfb2b739b95bd452a50a1d97a29e42`; exact 1318 Gateview mapped scopes |

Per-packet source-geometry, direct-wall geometry, record, and chunk hashes are
copied from the inventory/runtime registry and rechecked against the generated
chunk record. Compass labels are geometry-only outward-normal groups; they do
not by themselves identify a public side or authorize appearance transfer.

## Primary and first-party source index

| ID | Source | Supports | Explicit boundary |
| --- | --- | --- | --- |
| `CITY-EAS` | [SF Enterprise Addressing System](https://data.sfgov.org/d/3mea-di5p) and [live API](https://data.sfgov.org/resource/3mea-di5p.json) | address points and dataset currentness (`data_as_of=2026-09-03T18:00:54`) | a point does not prove survival, occupancy, building-number crosswalk, or facade |
| `CITY-XWALK` | [Updated Treasure Island Addresses and Building Numbers](https://data.sfgov.org/d/ghba-upwh) and [API](https://data.sfgov.org/resource/ghba-upwh.json) | City building-number/address pairs | no exterior schedule; shared addresses do not distinguish footprints |
| `NAVY-HRA-2006` | [Navy Historical Radiological Assessment](https://media.defense.gov/2022/Mar/22/2002960667/-1/-1/0/TI_200602_HRA.PDF) | historic uses and 2006 status for Buildings 260, 264, 365–367 | not a currentness or facade source |
| `NAVY-5YR-2020` | [Navy Second Five-Year Review](https://media.defense.gov/2022/Mar/25/2002963837/-1/-1/0/TI_20200805_SECOND_FIVE_YEAR_REVIEW%20%282%29.PDF) | Building 260 use, infrequent worker access, 2019 transfer | no exact opening schedule |
| `SFCTA-AV-2024` | [Treasure Island AV Shuttle final report](https://www.sfcta.org/sites/default/files/2024-06/TIMMA_Board_TreasureIslandAutonomousVehicleShuttlePilotProjectFinalMEMOandREPORT_2024-06-25_1.pdf) | Building 260 considered as secure shuttle storage | proposed use, not occupancy or facade |
| `TIDA-264-2024` | [TIDA Toolworks agreement](https://media.api.sf.gov/documents/061224_Item_6d_Toolworks.pdf) | Building 264 included in maintained/janitorial premises | no exterior detail or exact room use |
| `JOBCORPS-CURRENT` | [Treasure Island Job Corps Center](https://treasureisland.jobcorps.gov/) | current center existence/contact | does not resolve a `w...` footprint or exterior |
| `SFPUC-367-2023` | [SFPUC service notice](https://media.api.sf.gov/documents/011123_Communications_1.pdf) | Building 367 / 251 4th electrical work in January 2023 | does not distinguish the 365–367 footprints |

The public-side observations are first-hand Google-hosted panoramas with exact
IDs, dates, camera coordinates where retained, headings, and mapped run scopes
in the five relevant packets. The repository retains only links, IDs, dates,
coordinates, and written observations: **no panorama or other third-party pixels
are copied, embedded, trained into, or shipped as game assets**.

Link check on 2026-09-04: all City, TIDA, SFPUC, Job Corps, SFCTA, and Google
links above returned HTTP `200` after redirects to a generic HEAD client. The two
Navy `media.defense.gov` PDFs returned `403` to that HEAD client but were indexed
and read through the web research path; this access distinction is retained
instead of describing those authoritative sources as missing or broken.

## Reusable families without identity collapse

- `w34313515` and `w34313520` share a pale institutional field and stacked
  horizontal-window vocabulary. Their footprint, bay/recess hierarchy, visible
  sides, and cadence remain entity-specific; one cannot texture-prove the other.
- `w34313525` is an irregular low warehouse/service grammar. Complete roll-up,
  personnel-door, and high-window groups may share generated material channels,
  but its nonperiodic opening and repair arrangement must remain local.
- `w34313554` / `w34313555` and `w34313556` / `57` / `58` / `60` are useful
  geometry confusion cohorts. With zero target-bound appearance evidence, the
  cohorts authorize no shared facade attachment yet.
- `w34313564` needs separate tan SSE and pale NNW/ENE fields plus a pale plinth;
  normalizing those sides into one material would erase its strongest cue.
- `w95934092` uses a distinct townhouse grammar: cool gray-blue siding, white
  trim, shallow porch/canopy rhythm, end gable, and rear fence occlusion. It must
  not inherit a neighboring Gateview/Mariner opening schedule.

Generated material studies should target tileability. Imperfect early seams are
not a prototype blocker, but high-contrast periodic dirt and obvious wallpaper
repetition are. Low-frequency wear belongs in a separate mask; windows, doors,
recesses, gables, plinth transitions, and unique repairs require complete bounded
modules or side-local placement rather than being baked across a repeating tile.

## Packet index

- [`w34313515`](w34313515.md)
- [`w34313520`](w34313520.md)
- [`w34313525`](w34313525.md)
- [`w34313528`](w34313528.md)
- [`w34313535`](w34313535.md)
- [`w34313549`](w34313549.md)
- [`w34313550`](w34313550.md)
- [`w34313554`](w34313554.md)
- [`w34313555`](w34313555.md)
- [`w34313556`](w34313556.md)
- [`w34313557`](w34313557.md)
- [`w34313558`](w34313558.md)
- [`w34313560`](w34313560.md)
- [`w34313564`](w34313564.md)
- [`w95934092` / 1318 Gateview Avenue](w95934092_1318_gateview_avenue.md)

## Owner dependency

There is **no owner-only dependency for the five prototype-ready studies**.
The ten blocked units need a dated, rights-cleared, target-identifiable public
exterior/elevation with a locatable compass side; continued automated source
discovery can pursue that in later batches. It is therefore not added to
`HUMAN.md` as a hard stop.

# Source packet — Job Corps Food Service Building 368 (`w34313521`)

Checked: **2026-09-04**
Readiness: **identity-ready; target facade evidence blocked**

## Exact binding and present state

| Field | Frozen/project fact |
| --- | --- |
| Source | OSM way `w34313521`, v4, `2018-01-25T17:34:27Z`; `US Dept of Labor Job Corps Food Service Building 368`; `575 Avenue D`; `building=yes`, `amenity=restaurant`, `height=6`, `source=Yahoo` |
| Logical / wall receiver | `building:w34313521` / `building:w34313521:wall` |
| Chunk / geometry hash | `x_-1__z_0` / `9501bd5b63b17ece4fc36fb19d6cc588bb3c087692cf1a534785b8015b515d6c` |
| Generated mass | `6 m`, base/top `3.091 / 9.091 m`; 36 runs / `352.795 m` visible wall |
| Runtime/review | Shared placeholder live; target evidence remains blocked. |

Binding authority: `discovery/FACADE_RECEIVER_INVENTORY.json` and current facade
status/evidence ledgers.

## Identity and currentness

- `verified_fact` — a 1989 GAO decision identifies Naval Station Treasure Island
  **Mess Building 368**.
- `verified_fact` — the 1995 Job Corps transfer record identifies **Building 368**
  as the cafeteria, preserving the food-service lineage across Navy/Job Corps use.
- `verified_fact` — a 2022 official TIDA utility notice gives **Treasure Island
  Job Corps Building 368, 575 Avenue D**, directly validating the frozen building
  number and address as of that notice.
- Confidence: **high identity/address through 2022**. Current food-service use,
  condition, and survival after 2022 were not independently confirmed.

## Primary sources

| Source | Access | Supports | Use boundary |
| --- | --- | --- | --- |
| [GAO decision B-235324](https://www.gao.gov/products/b-235324) | indexed/read during research; CLI returned 403 on 2026-09-04 | 1989 “Mess Building 368” identity | textual historic use only; no facade |
| [1995 Job Corps transfer record](https://www.govinfo.gov/content/pkg/FR-1995-01-11/pdf/95-673.pdf) | HTTP 200, 2026-09-04 | B368 cafeteria role | historical transfer/use; no facade |
| [2022 TIDA planned outage notice](https://www.sf.gov/sites/default/files/2022-11/110922%20Communications_1.pdf) | HTTP 200, 2026-09-04 | exact B368 and `575 Avenue D` | address/existence context as of notice; no facade |
| [2023 SF revised SGMP](https://www.sf.gov/sites/default/files/2023-12/SGMP_0004-007-005%20Treasure%20Island_Rev%2003-17-23-compressed.pdf) | HTTP 200, 2026-09-04 | mapped B368 campus context | footprint context; not elevation/current use |

Public-road coverage attempts did not reveal a target elevation that could be
attributed to Building 368. A search lead to a mirrored federal facility-survey
attachment was deliberately not promoted as primary evidence because its original
solicitation provenance was not recovered.

## Supported cues and implementation boundary

There are **zero source-supported visual cues** for the exact receiver. “Mess,”
“cafeteria,” and “food service” are use labels, not permission to invent loading
doors, kitchen vents, signage, colors, windows, or a commercial restaurant front.

Safe reversible `production_inference`: retain the shared facade and exact mass.
Once an exterior source is recovered, prioritize genuinely diagnostic service/
public-entry asymmetry and roof/service elements only where that source shows
them; do not texture a false silhouette or mechanically tile a cafeteria motif.

## Nonclaims, confusion set, and next evidence step

Unknown/nonclaim: post-2022 status/use; all elevations, materials, colors, bays,
windows, entries, loading/service openings, signage, roof plant, and interiors.

Likely confusion set: culinary Building 363, the B487–489 dormitory group, HMA
Building 442, and other low Job Corps blocks. Eventual acceptance requires at
least two visible, building-specific cues on a proven side; number `368`, a generic
food icon, or hidden label does not pass.

No immediate human dependency. Next autonomous search: recover the original
DOL/SAM procurement record for the Treasure Island Job Corps facility survey and
inspect only attachments explicitly naming Building 368; then seek SF/TIDA utility
or environmental sheets with dated exterior photos. If authoritative public
records remain exhausted, the narrow `HUMAN.md` request is: **ask Job Corps/DOL
for one rights-cleared, dated exterior photograph or elevation of Building 368,
with the photographed side identified**.

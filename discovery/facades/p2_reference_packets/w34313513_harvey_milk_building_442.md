# Source packet — Harvey Milk Memorial Administration Building 442 (`w34313513`)

Checked: **2026-09-04**
Readiness: **identity-ready; target facade evidence blocked**

## Exact binding and present state

| Field | Frozen/project fact |
| --- | --- |
| Source | OSM way `w34313513`, v9, `2019-10-01T11:08:19Z`; Harvey Milk Memorial Administration Building, Job Corps Center; `655 Avenue H`; `building=public`, `building:levels=2`, `height=9`, `source=Yahoo` |
| Logical / wall receiver | `building:w34313513` / `building:w34313513:wall` |
| Chunk / geometry hash | `x_0__z_0` / `8afdb488ae3802a5aa18371916c51d7211bdaeaef91a3426103caf169d5f10c0` |
| Generated mass | `9 m`, base/top `4.190 / 13.190 m`; 50 runs / `276.468 m` visible wall |
| Runtime/review | Shared placeholder live; target evidence remains blocked. |

Binding authority: `discovery/FACADE_RECEIVER_INVENTORY.json` and current facade
status/evidence ledgers.

## Identity, address drift, and currentness

- `verified_fact` — a 2009 DOL directory identifies **Harvey Milk Memorial
  Administration Building 442** at the Treasure Island Job Corps Center and gives
  `351 H Avenue`.
- `verified_fact` — a 2016 DOL mailing list identifies the same center at **655
  Avenue H, BLDG 442**, directly supporting the frozen address/building-number pair.
- `verified_fact` — the current Job Corps site still operates the center and its
  contact page gives **351 H Avenue**. This is documented address drift, not an
  instruction to mutate the frozen source.
- `verified_fact` — the 1995 transfer record describes Building 442 as an old
  medical/dental building to be reconfigured; a second 1995 federal directory
  places the Naval Dental Center at `655 Avenue H`.
- Confidence: **high identity and active-center context**; current Building 442
  occupancy and exterior condition are not independently established.

## Primary sources

| Source | Access | Supports | Use boundary |
| --- | --- | --- | --- |
| [Current Treasure Island Job Corps](https://treasureisland.jobcorps.gov/) and [contact](https://treasureisland.jobcorps.gov/contact) | HTTP 200, 2026-09-04 | active center; current `351 H Avenue` contact | center-level currentness, not facade or exact current occupancy |
| [DOL 2009 Training Opportunities Directory](https://prh.jobcorps.gov/Information%20Notices/PRH%20Information%20Notices/PY%2009/Information%20Notice%2009-36%20Updated%20Training%20Opportunities%20Directory/Information%20Notice%2009-36%20Attachment%20Job%20Corps%20Training%20Opportunities%20Directory.pdf) | HTTP 200, 2026-09-04 | HMA name, Building 442, `351 H Avenue` | identity/address; no exterior |
| [DOL 2016 Job Corps mailing list](https://prh.jobcorps.gov/Information%20Notices/PRH%20Information%20Notices/PY%2016/Information%20Notice%2016-11%20Federal%20Student%20Aid%20Updates/Information%20Notice%2016-11%20Attachment%20C%20-%20FSA%20Publications%20Job%20Corps%20Mailing%20List.pdf) | HTTP 200, 2026-09-04 | `655 Avenue H BLDG 442` | exact frozen address crosscheck; no exterior |
| [1995 Job Corps transfer record](https://www.govinfo.gov/content/pkg/FR-1995-01-11/pdf/95-673.pdf) | HTTP 200, 2026-09-04 | B442 prior medical/dental use and planned reconfiguration | historical lifecycle only |
| [1995 federal base directory](https://www.govinfo.gov/content/pkg/FR-1995-08-17/pdf/95-20417.pdf) | HTTP 200, 2026-09-04 | Naval Dental Center at `655 Avenue H` | historical address/use only |
| [2023 SF revised SGMP](https://www.sf.gov/sites/default/files/2023-12/SGMP_0004-007-005%20Treasure%20Island_Rev%2003-17-23-compressed.pdf) | HTTP 200, 2026-09-04 | mapped Building 442 campus context | footprint context, not facade |

Two public-road coverage attempts did not reveal a target elevation. They are
negative search evidence, not support for any color, window, entry, or material cue.

## Supported cues and implementation boundary

There are **zero reference-supported facade cues** in the checked sources. Real
recognition cues currently supported are identity/lifecycle facts only: the
Building 442 number, Harvey Milk Memorial Administration function/name, and
medical/dental-to-Job-Corps reuse history. Hidden labels or metadata cannot satisfy
visual recognition.

Safe reversible `production_inference` now: retain the shared placeholder, exact
receiver, and current mass. Do not invent institutional brick, medical windows,
Harvey Milk portrait/signage, address numerals, or a generic Job Corps palette.
An identity sign could become a cue only after a dated source proves its wording,
placement, and visibility on this building.

## Nonclaims, confusion set, and next evidence step

Unknown/nonclaim: current B442 occupant; which address is physically displayed;
all elevations, materials, colors, openings, entrances, roof equipment, signage,
interior, and post-2019 alterations.

Likely confusion set: Buildings 368, 450, the 487–489 dormitory group, and other
Job Corps campus blocks. Building number/name alone is not enough; eventual review
needs at least two visible building-specific cues on a proven side.

No immediate human dependency. Next autonomous search: locate a DOL/SAM facilities
survey, solicitation attachment, rehabilitation record, or marked site/elevation
sheet that explicitly names Building 442; record its date and side. If public
records remain exhausted and high-fidelity treatment is required, the narrow
`HUMAN.md` request is: **ask Treasure Island Job Corps/DOL for one rights-cleared,
dated exterior photograph or elevation of Building 442 with the side identified**.

# Source packet — Education Center Building 29C (`w109905037`)

Checked: **2026-09-04**

Readiness: **blocked on exact lifecycle crosswalk and exact-facade evidence**

## Exact binding and present state

| Field | Frozen/project fact |
| --- | --- |
| Source | OSM way `w109905037`, v2, `2011-04-25T07:08:41Z`; `Education Center Building 29C`; `550 Avenue H`; `building=abandoned`, `building:levels=1`, `source=Yahoo` |
| Logical / wall receiver | `building:w109905037` / `building:w109905037:wall` |
| Chunk / geometry hash | `x_0__z_-1` / `bf973cb91d22918f50ce15958fb9c127131e9e8b6ec6dce193a54b785dabfdb5` |
| Generated mass | `3 m`, base/top `3.535 / 6.535 m`; 20 runs / `161.745 m` visible wall |
| Run gate | all exact runs `0..19` protected; no target-specific observation, mapping, or attachment |
| Runtime/review | Shared placeholder only; research not previously started for this exact unit |

Project geometry orders the frozen parallel footprints north-to-south as
29A/29B/29C/29D/29E. That is a frozen-world relationship, not independent proof
that a permit or archival photograph uses the same lettering.

## Identity and lifecycle reconciliation

- `verified_fact` — TIDA's 2023 outlook, May minutes, and July minutes establish
  planned, started, and completed demolition for **Building 29 as a group**.
- `verified_fact` — DBI permit `202304276597` uses `620` and `680 Avenue I`, calls
  the subject former Navy soldier barracks, and records one story, wood frame,
  and `5` existing units.
- `unknown` — no checked authoritative source names `29C`, uses its frozen `550
  Avenue H` address, or maps its footprint into that permit. The permit's `5`
  units field is not a five-footprint A–E key.
- `reference_observation` — City's October 2023 deck shows a group of parallel
  gabled barracks and demolition detail, but no readable `C` marker or attributable
  elevation.
- Confidence: **high exact frozen 29C game identity; unresolved independent
  identity crosswalk, exact demolition inclusion, and current state**.

## Primary sources and rights boundary

| Source | Access | Supports | Excludes |
| --- | --- | --- | --- |
| [TIDA 2023 outlook](https://media.api.sf.gov/documents/The_year_ahead_20230103_-_CAB.pdf), p. 13 | HTTP 200, 2026-09-04 | Building 29 planned for 2023 demolition | no C/address/footprint enumeration |
| [TIDA May 10, 2023 minutes](https://media.api.sf.gov/documents/061423_6a_051023_Minutes.pdf), p. 1 | HTTP 200, 2026-09-04 | May 22 group mobilization | no C claim |
| [DBI permit API, `202304276597`](https://data.sfgov.org/resource/i98e-djp9.json?$limit=20&$where=permit_number%3D%27202304276597%27) | HTTP 200, 2026-09-04; dataset `data_as_of=2025-08-07` | permit/address/construction metadata | no wing list or marked plan |
| [TIDA July 12, 2023 minutes](https://media.api.sf.gov/documents/091323_07.12.23_minutes.pdf), p. 1 | HTTP 200, 2026-09-04 | Building 29 demolition complete | group only |
| [TIDA/SF Arts October 2023 slide deck](https://media.api.sf.gov/documents/October_18_2023_VAC_slide_deck_small.pdf), “The End of Building 29” | HTTP 200, 2026-09-04 | group visual context | observation only; David Alan Boyd photo credit; exact item rights and C binding absent |

No source image was copied, stored, or transformed. Government hosting is not a
blanket image license; any future pixel use needs item-level permission.

## Observed regions and recognition-cue boundary

No target-specific public side or facade region was resolved for 29C. All 20 runs
remain unknown/protected. The only visual context is the unlettered Building 29
group: low parallel gabled, weathered wood barracks with repeated openings. Since
no source binds any visible wall to `29C`, exact recognition cues count is
**zero**, not two.

Observed facts may be used only as search/review comparison. Reversible
`production_inference`: retain the shared placeholder and exact one-level mass
without adding cohort-derived cladding, gable decoration, openings, signs, or
demolition-site objects.

## Nonclaims, confusion set, and resolution gate

Unknown/nonclaim: exact C location in permit/archives; `550 Avenue H` versus
`620/680 Avenue I`; exact demolition scope/survival; every public side, material,
entry, opening, roof detail, sign, dimension, current use, and interior.

Pre-implementation confusion set: 29A (`w109905031`), 29B (`w34313523`), 29D
(`w109905044`), 29E (`w109905040`), unlettered Building 29, and construction
enclosures. Generic barracks massing, a painted `C`, metadata, or north-to-south
position cannot count as recognition.

Searches attempted: exact quoted 29C name/address; 29C with TIDA, DBI, Navy/
NAVFAC, Job Corps, HRA, demolition, record-card, and site-plan terms; exact OSM
ID; permit number and both Avenue I addresses. Results were OSM-derived secondary
pages or group-level records only.

Next autonomous step: search/request the permit's plan set, emergency-order file,
hazardous-material survey, contractor closeout/as-built exhibit, Navy facility
record cards, and TIDA parcel drawings for explicit 29C lettering. If exhausted,
the narrow future `HUMAN.md` request is: **obtain a primary marked crosswalk for
29C and one rights-cleared, wing-labeled public elevation of this exact footprint
if a historical representation is required**. No runtime work is safe before it.

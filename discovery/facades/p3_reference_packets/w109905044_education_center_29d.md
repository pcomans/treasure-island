# Source packet — Education Center Building 29D (`w109905044`)

Checked: **2026-09-04**

Readiness: **blocked on exact lifecycle crosswalk and exact-facade evidence**

## Exact binding and present state

| Field | Frozen/project fact |
| --- | --- |
| Source | OSM way `w109905044`, v2, `2011-04-25T07:08:40Z`; `Education Center Building 29D`; `550 Avenue H`; `building=abandoned`, `building:levels=1`, `source=Yahoo` |
| Logical / wall receiver | `building:w109905044` / `building:w109905044:wall` |
| Chunk / geometry hash | `x_0__z_-1` / `4327850c5f1a9c0f32fc370d081d5a3fc079a5fe6a62fa96a73ec70cdd8c3cf5` |
| Generated mass | `3 m`, base/top `3.569 / 6.569 m`; 22 runs / `165.281 m` visible wall |
| Run gate | all exact runs `0..21` protected; no target-specific observation, mapping, or attachment |
| Runtime/review | Shared placeholder only; research not previously started for this exact unit |

The frozen geometry places D between C and E in the A/B/C/D/E parallel-footprint
sequence. That ordering is not an archival or permit crosswalk.

## Identity and lifecycle reconciliation

- `verified_fact` — official TIDA records say Building 29 was planned for
  demolition in 2023, Eco Bay would mobilize May 22, and demolition was complete
  by the July 12 report.
- `verified_fact` — DBI permit `202304276597` identifies Building 29 former Navy
  barracks at `620` and `680 Avenue I`, with one existing story, wood-frame
  construction, and `5` existing units.
- `unknown` — no checked primary record names 29D, says `550 Avenue H`, identifies
  a D footprint, or defines `5` units as the five frozen lettered structures.
- `reference_observation` — City's October deck provides unlettered group-level
  barracks and demolition imagery only; it does not expose a D-specific side.
- Confidence: **high frozen D identity, low/unresolved real-world letter crosswalk
  and exact lifecycle**. Preserve the unit; do not mark exact demolition.

## Primary sources and rights boundary

| Source | Access | Supports | Excludes |
| --- | --- | --- | --- |
| [TIDA 2023 outlook](https://media.api.sf.gov/documents/The_year_ahead_20230103_-_CAB.pdf), p. 13 | HTTP 200, 2026-09-04 | planned group demolition | no D/address/footprint claim |
| [TIDA May 10, 2023 minutes](https://media.api.sf.gov/documents/061423_6a_051023_Minutes.pdf), p. 1 | HTTP 200, 2026-09-04 | May 22 group mobilization | no D claim |
| [DBI permit API, `202304276597`](https://data.sfgov.org/resource/i98e-djp9.json?$limit=20&$where=permit_number%3D%27202304276597%27) | HTTP 200, 2026-09-04; dataset `data_as_of=2025-08-07` | permit/address/construction metadata | no letter list or marked plan |
| [TIDA July 12, 2023 minutes](https://media.api.sf.gov/documents/091323_07.12.23_minutes.pdf), p. 1 | HTTP 200, 2026-09-04 | completion for Building 29 group | no exact D lifecycle |
| [TIDA/SF Arts October 2023 slide deck](https://media.api.sf.gov/documents/October_18_2023_VAC_slide_deck_small.pdf), “The End of Building 29” | HTTP 200, 2026-09-04 | unlettered visual context | observation only; David Alan Boyd photo credit; no image reuse or D transfer |

No imagery is stored. Any later source-pixel use needs exact-item licensing even
when the containing document is City-hosted.

## Observed regions and recognition-cue boundary

No public side or region is attributable to 29D. All 22 exact runs remain
unmapped and protected. Group imagery shows parallel low gable-roofed, weathered
wood-clad barracks with repeated openings, but no letter or footprint marker.
Therefore exact D has **zero** supported recognition cues.

Reversible `production_inference`: retain the exact frozen receiver and shared
placeholder. Do not manufacture distinction through a `D` sign, color variant,
arbitrary window sequence, or transferred cohort texture. A historic treatment
becomes authorable only after at least two D-specific cues and side/run binding.

## Nonclaims, confusion set, and resolution gate

Unknown/nonclaim: D's permit identity; address translation; demolition inclusion
or survival; all sides, cladding, color, opening/entry/sign cadence, dimensions,
roof detail, present use, and interior.

Pre-implementation confusion set: 29A (`w109905031`), 29B (`w34313523`), 29C
(`w109905037`), 29E (`w109905040`), unlettered Building 29, and site-work
enclosures. A generic low barracks, source label, or geometric position cannot
serve as an independent cue.

Searches attempted: exact quoted 29D/name/address; 29D plus TIDA, DBI, Navy/
NAVFAC, Job Corps, HRA, demolition, record-card, and plan terms; exact OSM ID;
permit number plus 550 H/620 I/680 I. No primary result supplies a D marker.

Next autonomous step: obtain the two DBI plan sets/emergency-order attachments,
TIDA/Eco Bay closeout or as-built exhibit, hazardous-material survey, and Navy
facility record cards. If still unresolved, the narrow future `HUMAN.md` request
is: **ask TIDA/Naval Facilities/DBI for a marked document that explicitly binds
29D to this footprint and one rights-cleared, D-labeled public elevation if the
historic building must be depicted**.

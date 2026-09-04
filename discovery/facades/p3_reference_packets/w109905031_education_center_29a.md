# Source packet — Education Center Building 29A (`w109905031`)

Checked: **2026-09-04**

Readiness: **blocked on exact lifecycle crosswalk and exact-facade evidence**

## Exact binding and present state

| Field | Frozen/project fact |
| --- | --- |
| Source | OSM way `w109905031`, v2, `2011-04-25T07:08:37Z`; `Education Center Building 29A`; `550 Avenue H`; `building=abandoned`, `building:levels=1`, `source=Yahoo` |
| Logical / wall receiver | `building:w109905031` / `building:w109905031:wall` |
| Chunk / geometry hash | `x_0__z_-1` / `ffda3cbf67da657e87f19220f9d911e4d090103454290319ec687f78a34f07be` |
| Generated mass | `3 m`, base/top `3.490 / 6.490 m`; 16 runs / `166.314 m` visible wall |
| Run gate | all exact runs `0..15` protected; no target-specific run mapping or attachment |
| Runtime/review | Shared placeholder only; earlier public views proved occlusion, not appearance |

The frozen identity is exact game/source truth. `abandoned` and the one-level mass
come from a 2011 Yahoo-tagged snapshot and do not prove current condition.

## Identity and lifecycle reconciliation

- `verified_fact` — TIDA planned demolition of **Building 29** in 2023, recorded
  May 22 mobilization, and recorded completed demolition by July 12, 2023.
- `verified_fact` — DBI permit `202304276597` covers “building 29” former Navy
  barracks at `620` and `680 Avenue I`; it records one existing story, wood-frame
  construction, and `5` existing units.
- `unknown` — none of those records names `29A`, says `550 Avenue H`, or supplies
  a marked letter-to-footprint crosswalk. `5` permit units cannot be equated with
  the five frozen A–E footprints.
- `reference_observation` — the City slide deck shows several parallel historical
  gable-roofed barracks and Building 29 demolition imagery, but no readable wing
  label or exact side binding.
- Confidence: **high frozen 29A game identity; exact real-world A crosswalk,
  demolition inclusion, and current site state unresolved**. Do not relabel this
  exact unit “demolished.”

## Primary and observation sources

| Source | Access | Supports | Use boundary |
| --- | --- | --- | --- |
| [TIDA 2023 outlook](https://media.api.sf.gov/documents/The_year_ahead_20230103_-_CAB.pdf), p. 13 | HTTP 200, 2026-09-04 | planned Building 29 demolition | group only; no letter/address/footprint mapping |
| [TIDA May 10, 2023 minutes](https://media.api.sf.gov/documents/061423_6a_051023_Minutes.pdf), p. 1 | HTTP 200, 2026-09-04 | Eco Bay mobilization May 22 | group only |
| [DBI permit API, `202304276597`](https://data.sfgov.org/resource/i98e-djp9.json?$limit=20&$where=permit_number%3D%27202304276597%27) | HTTP 200, 2026-09-04; dataset `data_as_of=2025-08-07` | permit description, issued date, two Avenue I rows, one-story/wood-frame/5-unit metadata | no A–E enumeration; factual open-data use only |
| [TIDA July 12, 2023 minutes](https://media.api.sf.gov/documents/091323_07.12.23_minutes.pdf), p. 1 | HTTP 200, 2026-09-04 | group demolition recorded complete | no exact A claim |
| [TIDA/SF Arts October 2023 slide deck](https://media.api.sf.gov/documents/October_18_2023_VAC_slide_deck_small.pdf), “The End of Building 29” | HTTP 200, 2026-09-04 | group-level historical/demolition visual context | observation only; David Alan Boyd photo credit; no asset reuse or exact wing transfer |
| `EC29A-SV01`, [NNW approach](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82468,-122.36890&heading=150&pitch=0&fov=75), pano `o96ZjQzRGjybIV2jQd6hDw` | capture March 2025; locator rechecked 2026-09-04 | complete container/fence occlusion | negative visibility evidence only |
| `EC29A-SV02`, [WSW/NNW approach](https://www.google.com/maps/@?api=1&map_action=pano&viewpoint=37.82452,-122.36925&heading=100&pitch=0&fov=75), pano `emqMw-XLaeQ03pPhEs3v-Q` | capture March 2025; locator rechecked 2026-09-04 | same complete occlusion | no facade cue; no pixels stored |

## Observed regions and recognition-cue boundary

Exact 29A facade cues: **zero**. The NNW and WSW/NNW approach areas are fully
occluded by containers, fencing, and vehicles; ENE and SSE are unobserved. The
barrier corrugation, container doors, fence, machinery, and parked vehicles are
site-work objects and must not be copied onto this receiver.

The group slide deck supports a historical **Building 29 family** observation—
parallel low gable-roofed, weathered wood-clad barracks with repeated openings—
but lacks a lettered wing marker. Those are quarantined context, not the two
independent cues required for exact 29A recognition.

## Implementation guidance, nonclaims, and gate

Observed fact authorized for this receiver: none beyond negative occlusion.
Reversible `production_inference`: preserve the exact 16-run receiver and shared
placeholder while the product's historical/current depiction policy and exact
crosswalk are resolved. Do not prototype even a generic barracks treatment for
29A; it would game recognition by transferring a cohort stereotype.

Unknown/nonclaim: A–E crosswalk; relation between `550 Avenue H` and permit
`620/680 Avenue I`; exact demolition scope; whether 29A survived; every material,
opening, entrance, sign, roof detail, side, current use, and interior.

Pre-implementation confusion set: exact frozen siblings 29B (`w34313523`), 29C
(`w109905037`), 29D (`w109905044`), and 29E (`w109905040`); unlettered “Building
29”; and the 2025 construction enclosure. A low gabled barracks mass, letter label,
or source name cannot pass recognition.

Searches attempted: exact quoted name/address; `29A` with TIDA, DBI, Navy/NAVFAC,
Job Corps, and HRA terms; exact OSM ID; permit number plus plans/exhibits; 550
Avenue H plus 620/680 Avenue I. No primary result marked this footprint as 29A.

Next autonomous step: request/search DBI/TIDA/NAVFAC plan attachments, hazardous-
materials exhibits, demolition contractor closeout/as-built sheets, and Navy
facility record cards for a marked wing/footprint crosswalk. If exhausted and a
historical representation remains required, the narrow future `HUMAN.md` request
is: **obtain from TIDA/Naval Facilities/DBI a marked `202304276597` exhibit that
explicitly resolves 29A and one rights-cleared, wing-labeled public elevation of
that exact footprint**. Do not block unrelated units while waiting.
